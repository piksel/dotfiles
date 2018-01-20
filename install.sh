#!/bin/bash

#set -uo pipefail
set -Euo pipefail
#set -x

#trap 'echo -e "\n\e[97mScript failed at $LINENO!\e[39m"' ERR



VERBOSE=""
CONTINUE=""
DOTROOT="$HOME/.dotfiles"

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
    echo -ne "\e[97mInstalling \e[94m$1\e[97m... \e[39m"

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
    echo -e "\e[91mFailed!\e[39m"
}

print_ok(){
    echo -e "\e[92mOK\e[39m"
}

print_skipping(){
    echo -e "Skipping \e[94m$1\e[39m: $2"
}

print_warn(){
    echo -en "\e[93mWarning\e[39m: $1"
}

install_symlink(){
    local link="$HOME/$2"
    local target="$DOTROOT/$1"
    local name="symlink:$2"
    if [ ! "$(readlink $link)" -ef "$target" ]; then
        if [ -e "$link" ]; then
            print_warn "Moving old \e[94m$2\e[39m to \e[94m$link.bak\e[39m... "
            run_command "mv $link $link.bak"
        fi
        local dir="$(dirname $link)"
        if [ ! -e "$dir" ]; then
            echo -ne "Creating directory \e[94m$dir\e[39m... "
            run_command "mkdir -p $link"
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

install_vim(){
    local name="vim:$1"
    local cmd="$2"
    echo -en "Install \e[94m$name\e[39m? "
    read -n 1 -r /dev/tty
    echo 
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -n "Installing $name... "
        vim "+$cmd" +qall
        print_warn "Cannot determine success!\n"
    else
        print_skipping "$name" "Got reply '$REPLY'"
    fi
}

install_ycm(){
	local name="compile:ycm"
    echo -en "Install \e[94m$name\e[39m? "
    read -n 1 -r < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -en "Installing \e[94m$name\e[39m... "
		pushd $HOME/.vim/bundle/YouCompleteMe > /dev/null
        run_command "./install.py"
        popd >/dev/null

    else
        print_skipping "$name" "Got reply '$REPLY'"
    fi

}


if [ ! -e "$DOTROOT" ]; then
    name="dotfiles:base"
	echo -en "Install \e[94m$name\e[39m in \e[94m$DOTROOT\e[39m? "
    read -n 1 -r < /dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -en "Installing \e[94m$name\e[39m... "
        run_command git clone $GITREPO $DOTROOT
    else
        echo "Note: Download script and run with --install-dir=/your/path to change install directory."
        exit 0
    fi
    unset name
fi

verb "dotfiles root: $DOTROOT"

# bash
install_github 'bash_it' "Bash-it/bash-it"
install_github 'commacd' "shyiko/commacd"
install_github 'hhighlighter' "paoloantinori/hhighlighter"

# vim
install_github 'vundle' "VundleVim/Vundle.vim"

# symlinks
install_symlink 'bash/main' '.bashrc'
install_symlink 'vendor/vundle' '.vim/bundle/Vundle.vim'
install_symlink 'vim/main' '.vimrc'
install_symlink 'git/config' '.gitconfig'

# vundle
install_vim 'vundle' 'PluginInstall'
install_ycm
