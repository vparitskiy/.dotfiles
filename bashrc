# ~/.bashrc - bash interactive startup file
# vim: ft=sh

export DOT_DIR=$HOME/.dotfiles

. $DOT_DIR/environ
# Reload environ for every terminal because:
# - `sudo -s` preserves $HOME but cleans other envvars
# - bash is built with #define SSH_SOURCE_BASHRC (e.g. Debian)
# - systemd rejects envvars which contain \e (ESC)

export -n LINES COLUMNS
# Work around a race condition where the creation of LINES/COLUMNS may be
# delayed until bash is in the middle of ~/.environ's "allexport" section.
#
# It's a race condition most likely caused by bash using the "report window
# size" sequence, and the terminal sometimes being slow to reply.
#
# Or it *may* be caused by https://gitlab.gnome.org/GNOME/vte/issues/188; my
# traces show all ioctl(TIOCGWINSZ) returning correct results, but there *does*
# seem to be a difference in how many SIGWINCHs the shell receives during
# startup.

if [[ $TERM == @(screen|tmux|xterm) ]]; then
	OLD_TERM="$TERM"
	TERM="$TERM-256color"
fi

export GPG_TTY=$(tty)
export -n VTE_VERSION

if [[ $SSH_CLIENT ]]; then
	SELF=${SSH_CLIENT%% *}
fi

### Interactive options

[[ $- == *i* ]] || return 0

set -o physical			# resolve symlinks when 'cd'ing
shopt -s autocd 2>/dev/null	# assume 'cd' when trying to exec a directory
shopt -s checkjobs 2> /dev/null	# print job status on exit
shopt -s checkwinsize		# update $ROWS/$COLUMNS after command
shopt -s extglob		# @(…) +(…) etc. globs
shopt -s globstar		# the ** glob

shopt -u hostcomplete		# no special treatment for Tab at @
shopt -s no_empty_cmd_completion

set +o histexpand		# disable !history expansion
shopt -s cmdhist		# store multi-line commands as single history entry
shopt -s histreedit		# allow re-editing failed history subst

HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="../*/"
HISTTIMEFORMAT="(%F %T) "
shopt -s histappend

complete -A directory cd

. $DOT_DIR/bash/prompt.sh
. $DOT_DIR/bash/aliases.sh


# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
#if ! shopt -oq posix; then
#  if [ -f /usr/share/bash-completion/bash_completion ]; then
#    . /usr/share/bash-completion/bash_completion
#  elif [ -f /etc/bash_completion ]; then
#    . /etc/bash_completion
#  fi
#fi
if [ "x${BASH_VERSION-}" != x -a "x${PS1-}" != x -a "x${BASH_COMPLETION_VERSINFO-}" = x ]; then
    # Check for recent enough version of bash.
    if [ ${BASH_VERSINFO[0]} -gt 4 ] || \
       [ ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 1 ]; then
        [ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] && \
            . "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
            # Source completion code.
            . /usr/share/bash-completion/bash_completion
        fi
    fi

fi

if hash hstr 2>/dev/null; then
    alias hh=hstr                    # hh to be alias for hstr
    export HSTR_CONFIG=hicolor       # get more colors
    # ensure synchronization between bash memory and history file
    PROMPT_COMMAND="history -n; history -w; history -c; history -r; $PROMPT_COMMAND"
    # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
    if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
    # if this is interactive shell, then bind 'kill last command' to Ctrl-x k
    if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
fi


. $DOT_DIR/bash/django_bash_completion.sh  # This loads django bash auto completion

# This inits pyenv
if [ -d ${PYENV_ROOT} ] ; then
   eval "$(pyenv init --path)"
fi

[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash auto completion

type hh >/dev/null 2>&1 && bind '"\C-r": "\C-a hh \C-j"'  # bind hh to Ctrl-r


have() { type "$1" > /dev/null 2>&1; }
if [[ ! $SILENT && ! $SUDO_USER ]]; then
	have todo && todo
fi

export PATH="$PATH:/opt/010editor" #ADDED BY 010 EDITOR
