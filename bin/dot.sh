#!/bin/bash

DOTROOT=$HOME/.dotfiles

case $1 in
    update)
        pushd $DOTROOT
        git fetch
        if git merge-base --is-ancestor master HEAD; then
            git pull
        else
            echo "Dotfiles repository is not clean, cannot fast-forward."
            while ! [[ "$REPLY" =~ (r|m|s|a)$ ]]; do
                echo -ne "Rebase, Merge, Stash or Abort? "
                read -n 1 -r < /dev/tty
                case "$REPLY" in
                    r|R)
                       git rebase
                       ;;
                    m|M)
                       git merge
                       ;;
                    s|S) 
                       git stash save "dot update stash $(date -Iseconds)" 
                       ;;
                    a|A)
                       echo "Aborted update!"
                       exit 0
               esac
           done
       fi
       ;;

    edit)
       case "$2" in
           install)
               vim $DOTROOT/install.sh
               ;;
           dot)
               vim $DOTROOT/bin/dot.sh
               ;;
           bash)
               vim $DOTROOT/bash/main
               ;;
           vim)
               vim $DOTROOT/vim/main
               ;;
           *)
               echo "Unknown edit target '$2'. Valid targets are: install, dot, bash and vim."
               exit 1
               
       esac
       ;;

    install)
       $DOTROOT/install.sh
       ;;
    *)
        echo "Unknown action '$1'. Valid actions are: install, update and edit."
        exit 1 
        
esac
