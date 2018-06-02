#!/bin/sh

SEP=
SEPE=

WIDTH=${1}

SMALL=80
MEDIUM=140

#if [ "$WIDTH" -gt "$MEDIUM" ]; then
#  if type mpc >/dev/null; then
#    MPD="#[fg=colour252,bg=default,nobold,noitalics,nounderscore]$SEP#[fg=colour16,bg=colour252,bold,noitalics,nounderscore] $MUSIC $(mpc current)"
#    date_colour='colour252'
#  fi
#fi

if [ "$WIDTH" -ge "$SMALL" ]; then
  UNAME="#[fg=colour241,bg=colour236,nobold,noitalics,nounderscore]$SEP#[fg=colour16,bg=colour241,nobold,noitalics,nounderscore] #S"
fi

DATE="#[fg=colour236,bg=${date_colour:-default},nobold,noitalics,nounderscore]$SEP#[fg=colour247,bg=colour236,nobold,noitalics,nounderscore] $(date +'%Y-%m-%d')"
TIME="#[fg=colour234,bg=colour236,nobold,noitalics,nounderscore]$SEPE#[fg=colour252,bg=colour236,bold,noitalics,nounderscore] $(date +'%H:%M')"

echo "$MPD $DATE $TIME $UNAME " | sed 's/ *$/ /g'
