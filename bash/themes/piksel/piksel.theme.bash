#!/usr/bin/env bash

SCM_THEME_PROMPT_DIRTY=" ${red}✗"
SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓"
SCM_THEME_PROMPT_PREFIX=" ["
SCM_THEME_PROMPT_SUFFIX="${green}]"

GIT_THEME_PROMPT_DIRTY=" ${red}✗"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓"
GIT_THEME_PROMPT_PREFIX=" ${yellow}["
GIT_THEME_PROMPT_SUFFIX="${yellow}]"

RVM_THEME_PROMPT_PREFIX="|"
RVM_THEME_PROMPT_SUFFIX="|"

function prompt_command() {
    local EXIT="$?"
    if [ "$EXIT" == 0 ]; then
        res_prompt="$green✔"
    else
        res_prompt="$red╳"
    fi
    PS1="\n$cyan\u$white @ $cyan\h $white\w$green$(scm_prompt_info)\n$res_prompt $reset_color➡ "
}

THEME_CLOCK_COLOR=${THEME_CLOCK_COLOR:-"${white}"}

safe_append_prompt_command prompt_command
