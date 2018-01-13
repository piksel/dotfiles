#!/bin/bash

#set -uo pipefail
set -Euo pipefail
#set -x

#trap 'echo -e "\n\e[97mScript failed at $LINENO!\e[39m"' ERR

VERBOSE=""
CONTINUE=""
DOTROOT="$(cd $(dirname $0) && pwd)"

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
    -s=*|--search=*)
		SEARCH="${i#*=}"
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
    local result
    local cmd
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
        cmd="$i"
        result="$($cmd 2>&1)"
        local code="$?"
        if [ "$code" -ne "0" ]; then
            echo -e "\e[91mFailed!\e[39m"
            echo "+ $cmd" | indent
            echo "$result" | indent
            if [ -z "$CONTINUE" ]; then exit $code; fi
        else
                
            echo -e "\e[92mOK\e[39m"
            verb "+ $cmd"
            verb "$result"
        fi
    done 
}

install_symlink(){
    install "symlink $1" "ln -s $DOTROOT/$1/$2 $HOME/$3"
}

verb "dotfiles root: $DOTROOT"

# bash
install 'bash-it' "git clone --depth=1 https://github.com/Bash-it/bash-it.git $DOTROOT/vendor/bash_it"
install 'commacd' "git clone --depth=1 https://github.com/shyiko/commacd.git $DOTROOT/vendor/commacd"
install 'hhighlighter' "git clone --depth=1 https://github.com/paoloantinori/hhighlighter $DOTROOT/vendor/hhighlighter"

# vim
install 'vundle' "git clone --depth=1 https://github.com/VundleVim/Vundle.vim.git $HOME/.vim/bundle/Vundle.vim"

# symlinks
install_symlinks 'bash' 'main' '.bashrc'
install_symlinks 'vim' 'main' '.vimrc'
install_symlinks 'git' 'config' '.gitconfig'
