#!/bin/bash

set -Euo pipefail

#set -x
#trap 'echo -e "\n\x1b[97mScript failed at $LINENO!\x1b[39m"' ERR

GITREPO="https://github.com/piksel/dotfiles"

VERBOSE=""
CONTINUE=""
DOTROOT="$HOME/.dotfiles"
BREW_BASH="/usr/local/bin/bash"

usage(){
	echo $0: usage: none
}

for i in "$@"
do
case $i in
    -v|--verbose)
		VERBOSE="INDEED"
		shift 
		;;
    -d=*|--install-dir=*)
		DOTROOT="${i#*=}"
		shift 
		;;
    *)
        # unknown option
        echo error: unknown argument "$i"
		usage
		exit 1
    ;;
esac
done

indent() { sed "s/^/ ${1:- } /"; }

verb(){
	if [ $VERBOSE ] && [ -n "$1" ]; then
		echo -e "$1" | indent "\x1b[90mv\x1b[39m"
	fi
}

install(){
    local ix=0
    local cmds="$(expr ${#} - 1)"
    echo -ne "\x1b[97mInstalling \x1b[94m$1\x1b[97m... \x1b[39m"

    if [ "$cmds" -gt "1" ]; then
        echo -e "[$cmds]"
    fi
    for i in "${@:2}"; do
	    if [ "$cmds" -gt "1" ]; then
            ix=$(expr $ix + 1)
            echo -en " [$ix/$cmds]... "
        fi
        run_command "$i"
    done 
}

run_command(){
    local result
    local cmd=$1
    result="$($cmd 2>&1)"
    local code="$?"
    if [ "$code" -ne "0" ]; then
        print_failed
        echo "+ $cmd" | indent
        echo "$result" | indent
        if [ -z "$CONTINUE" ]; then exit $code; fi
    else
        print_ok    
        verb "+ $cmd"
        verb "$result"
    fi
}

print_failed(){
    echo -e "\x1b[91mFailed!\x1b[39m"
}

print_ok(){
    echo -e "\x1b[92mOK\x1b[39m"
}

print_skipping(){
    echo -e "Skipping \x1b[94m$1\x1b[39m: $2"
}

print_warn(){
    echo -en "\x1b[93mWarning\x1b[39m: $1"
}

check_bash_version() {
    if [ -e $BREW_BASH ]; then

        BREW_BASH_VERSION=$($BREW_BASH -c 'echo "${BASH_VERSION}"')

        if [[ "$BASH_VERSION" != "$BREW_BASH_VERSION" ]]; then
            local IFS=.
            local CVER=($BASH_VERSION) BVER=($BREW_BASH_VERSION)

            if [[ ${CVER[0]} -lt ${BVER[0]} ]] || [[ ${CVER[0]} -eq ${BVER[0]} && ${CVER[1]} -lt ${BVER[1]} ]]; then
                echo -e "Found newer bash version: \x1b[92m${BVER[0]}.${BVER[1]}\x1b[39m >= \x1b[91m${CVER[0]}.${CVER[1]}\x1b[39m, relaunching with \x1b[94m$BREW_BASH\x1b[39m..."
                return 0
            fi

            echo -e "Using the latest bash version available: \x1b[94m${CVER[0]}.${CVER[1]}\x1b[39m"
        fi
    fi

    return 1
}

install_symlink(){
    local link="$HOME/$2"
    local target="$DOTROOT/$1"
    local name="symlink:$2"
    if [ ! "$(readlink $link)" -ef "$target" ]; then
        if [ -e "$link" ]; then
            print_warn "Moving old \x1b[94m$2\x1b[39m to \x1b[94m$link.bak\x1b[39m... "
            run_command "mv $link $link.bak"
        fi
        local dir="$(dirname $link)"
        if [ ! -e "$dir" ]; then
            echo -ne "Creating directory \x1b[94m$dir\x1b[39m... "
            run_command "mkdir -p $dir"
        fi
        install "$name" "ln -s $target $link"
    else
        print_skipping "$name" "Already exists"
    fi
}

install_github(){
    local target="$DOTROOT/vendor/$1"
    local name="github:$2"
    if [ ! -e "$target" ]; then
        local repo="https://github.com/$2.git"
        install "$name" "git clone --depth=1 $repo $target" 
    else
        print_skipping "$name" "Already exists"
    fi
}

install_maybe(){
    local name="$1"
    local cmd="$2"
    echo -en "Install \x1b[94m$name\x1b[39m? "
    read -n 1 -r < /dev/tty
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install "$name" "$cmd"
    else
        print_skipping "$name" "Got reply '$REPLY'"
    fi
}

install_bashit(){
    set +u
    BASH_IT=$DOTROOT/vendor/bash_it
    source $BASH_IT/bash_it.sh
    install_maybe "bash-it:default-aliases" "bash-it enable alias alias-completion base explain extract git git-subrepo history less-pretty-cat nginx node python sshagent ssh tmux"
    install_maybe "bash-it:default-plugins" "bash-it enable plugin apt curl docker docker-compose general git systemd tmux vim yarn"
    set -u
}

install_vim(){
    local name="vim:$1"
    local cmd="$2"
    echo -en "Install \x1b[94m$name\x1b[39m? "
    read -n 1 -r < /dev/tty
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -n "Installing $name... "
        vim "+$cmd" +qall < /dev/tty
        print_warn "Cannot determine success!\n"
    else
        print_skipping "$name" "Got reply '$REPLY'"
    fi
}

install_ycm(){
	local name="compile:ycm"
    echo -en "Install \x1b[94m$name\x1b[39m? "
    read -n 1 -r < /dev/tty
    echo
    local prereqs="build-essential cmake python-dev python3-dev"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [[ -n "$(which apt)" && "$(uname -s)" != "Darwin" ]]; then
            echo -e "Retrieving prerequisites using apt:\x1b[33m"
            sudo apt install $prereqs
            echo -e "\x1b[39m"
        else
            echo -e "\x1b[93mWarning:\x1b[39m No \x1b[97mapt\x1b[39m command found. Skipping installation of prerequisites."
            echo -e "Make sure that the equivalent packages are installed: \x1b[36m$prereqs\x1b[39m."
        fi 
        echo -en "Installing \x1b[94m$name\x1b[39m... "
		pushd $HOME/.vim/bundle/YouCompleteMe > /dev/null
        run_command "./install.py"
        popd >/dev/null

    else
        print_skipping "$name" "Got reply '$REPLY'"
    fi

}

install_lscolors() {
    local name="bash:lscolors"
    if command -v dircolors &> /dev/null; then
        echo -en "Installing \x1b[94m$name\x1b[39m... "
        run_command "dircolors -b $DOTROOT/vendor/lscolors/LS_COLORS > $DOTROOT/bash/lscolors"
    else
        print_skipping "$name" "Command 'dircolors' does not exist"
    fi
}

echo -e "\n\n\x1b[96m -- piksel dotfiles installer\x1b[39m\n"

if check_bash_version; then
    $BREW_BASH "$0" "$@"
    exit $?
fi

if [ ! -e "$DOTROOT" ]; then
    name="dotfiles:base"
	echo -en "Install \x1b[94m$name\x1b[39m in \x1b[94m$DOTROOT\x1b[39m? "
    read -n 1 -r < /dev/tty
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -en "Installing \x1b[94m$name\x1b[39m... "
        run_command "git clone $GITREPO $DOTROOT"
    else
        echo "Note: Download script and run with --install-dir=/your/path to change install directory."
        exit 0
    fi
    unset name
fi

verb "dotfiles root: $DOTROOT"

# bash
install_github 'composure' "erichs/composure"
install_github 'bash_it' "Bash-it/bash-it"
install_github 'commacd' "shyiko/commacd"
install_github 'hhighlighter' "paoloantinori/hhighlighter"
install_github 'lscolors' 'trapd00r/LS_COLORS'

install_lscolors 'lscolors' 

# vim
install_github 'vundle' "VundleVim/Vundle.vim"

# symlinks
install_symlink 'bash/main' '.bashrc'
install_symlink 'vendor/vundle' '.vim/bundle/Vundle.vim'
install_symlink 'vim/main' '.vimrc'
install_symlink 'vim/neovim' '.config/nvim/init.vim'
install_symlink 'git/config' '.gitconfig'
#install_symlink 'misc/input' '.inputrc'

# vundle
install_vim 'vundle' 'PluginInstall'
install_ycm

install_symlink 'composure' '.local/composure'
install_bashit
