#!/bin/bash

DOTROOT=$HOME/.dotfiles

# Use composure for documentation and bash-it
source $DOTROOT/vendor/composure/composure.sh

dot(){
    about 'dotfiles helper tool'
    param '1: verb [one of: update | edit | install] or bit'
    param '2: target (for verb edit) [one of: install | dot | bash | vim]'
    example 'dot edit dot  # edit this script'
    example 'dot install   # runs dotfiles installer'
    example 'dot update    # update dotfiles repo from origin'
    example 'dot bit       # run bash-it function and show its usage'

    typeset verb=${1:-}
    shift

    case $verb in
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
                           return 0
                   esac
               done
            fi
            ;;

        edit)
            typeset target=${1:-}
            shift
            case "$target" in
               install)
                   vim $DOTROOT/install.sh ;;
               dot)
                   vim $DOTROOT/bash/dot.sh ;;
               bash)
                   vim $DOTROOT/bash/main  ;;
               vim)
                   vim $DOTROOT/vim/main ;;
               *)
                   echo "Unknown edit target '$target'. Valid targets are: install, dot, bash and vim."
                   return 1
                   
            esac
            ;;
        
        bit)
            # Add bash-it specific metadata cites
            cite _about _param _example _group _author _version
            source $DOTROOT/vendor/bash_it/lib/helpers.bash
            if [[ "$1" == "list" ]]; then
                if [[ "$2" -eq "plugins" || "$2" -eq "aliases" ]]; then
                    bash-it show $2 | grep "\[x\]" | awk '{ printf $1 " " }'
                else
                    echo "list action needs 'plugins' or 'aliases' as the first parameter"
                    return 1
                fi
            else
                bash-it "$@"
            fi
            ;;

        install)
           $DOTROOT/install.sh
           ;;

       "")
           reference dot
           return 0
           ;;

        *)
            echo "Unknown action '$verb'."
            reference dot
            return 1 
            
    esac
}
