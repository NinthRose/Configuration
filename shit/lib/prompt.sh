#!/usr/bin/env bash
#==============================================================#
# Author: Vonng(fengruohang@outlook.com)                       #
# Desc  : Bash Prompt Setting                                  #
# Dep   : None                                                 #
#==============================================================#

# module name
declare -g -r __MODULE_PROMPT="prompt"


#==============================================================#
#                             Theme                            #
#==============================================================#
# term
if [[ ${COLORTERM} = gnome-* && ${TERM} = xterm ]] && infocmp gnome-256color >/dev/null 2>&1; then
    export TERM='gnome-256color';
elif infocmp xterm-256color >/dev/null 2>&1; then
    export TERM='xterm-256color';
fi;

#==============================================================#
#                             Color                            #
#==============================================================#
if tput setaf 1 &> /dev/null; then
    tput sgr0; # reset colors
    bold=$(tput bold);
    reset=$(tput sgr0);
    black=$(tput setaf 0);
    blue=$(tput setaf 33);
    cyan=$(tput setaf 37);
    green=$(tput setaf 64);
    orange=$(tput setaf 166);
    purple=$(tput setaf 125);
    red=$(tput setaf 124);
    violet=$(tput setaf 61);
    white=$(tput setaf 15);
    yellow=$(tput setaf 136);
else
    bold='';
    reset="\e[0m";
    black="\e[1;30m";
    blue="\e[1;34m";
    cyan="\e[1;36m";
    green="\e[1;32m";
    orange="\e[1;33m";
    purple="\e[1;35m";
    red="\e[1;31m";
    violet="\e[1;35m";
    white="\e[1;37m";
    yellow="\e[1;33m";
fi;
#==============================================================#


#--------------------------------------------------------------#
prompt_git() {
    local s='';
    local branchName='';

    # Check if the current directory is in a Git repository.
    if [ $(git rev-parse --is-inside-work-tree &>/dev/null; echo "${?}") == '0' ]; then

        # check if the current directory is in .git before running git checks
        if [ "$(git rev-parse --is-inside-git-dir 2> /dev/null)" == 'false' ]; then

            # Ensure the index is up to date.
            git update-index --really-refresh -q &>/dev/null;

            # Check for uncommitted changes in the index.
            if ! $(git diff --quiet --ignore-submodules --cached); then
                s+='+';
            fi;

            # Check for unstaged changes.
            if ! $(git diff-files --quiet --ignore-submodules --); then
                s+='!';
            fi;

            # Check for untracked files.
            if [ -n "$(git ls-files --others --exclude-standard)" ]; then
                s+='?';
            fi;

            # Check for stashed files.
            if $(git rev-parse --verify refs/stash &>/dev/null); then
                s+='$';
            fi;
        fi;

        # Get the short symbolic ref.
        # If HEAD isn’t a symbolic ref, get the short SHA for the latest commit
        # Otherwise, just give up.
        branchName="$(git symbolic-ref --quiet --short HEAD 2> /dev/null || \
            git rev-parse --short HEAD 2> /dev/null || \
            echo '(unknown)')";

        [ -n "${s}" ] && s=" [${s}]";

        echo -e "${1}${branchName}${blue}${s}";
    else
        return;
    fi;
}
#--------------------------------------------------------------#
prompt_venv() {
    # Get current Python virtual env if any.
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        # Strip out the path and just leave the env name.
        echo -e "${1}(${VIRTUAL_ENV##*/})"
    fi;
}
#--------------------------------------------------------------#
# root with orange
if [[ "${USER}" == "root" ]]; then
    userStyle="${red}";
else
    userStyle="${orange}";
fi;
#--------------------------------------------------------------#
# ssh with red, local with yellow
if [[ "${SSH_TTY}" ]]; then
    hostStyle="${bold}${red}";
else
    hostStyle="${yellow}";
fi;
#--------------------------------------------------------------#
# PS1
PS1="\[\033]0;\w\007\]";
PS1+="\[${bold}\]\n"; # newline
PS1+="\[${cyan}\][\t] "
PS1+="\[${userStyle}\]\u"; # username
PS1+="\[${hostStyle}\]@";
PS1+="\[${hostStyle}\]\h"; # host
PS1+="\$(prompt_venv \"${white} ${purple}\" 2>/dev/null)"; # virtual env
PS1+="\[${white}\] ";
PS1+="\[${green}\]\w"; # working directory
PS1+="\$(prompt_git \"${hostStyle} on ${violet}\" 2>/dev/null)"; # Git repository details
PS1+="\n";
PS1+="\[${violet}\]\$ \[${reset}\]"; # `$` (and reset color)
export PS1;
#--------------------------------------------------------------#
# PS2
PS2="\[${yellow}\]→ \[${reset}\]";
export PS2;
#==============================================================#
