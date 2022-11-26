# bashrc -- aliases and functions

unalias -a

eval "$(dircolors "$DOT_DIR"/dircolors 2>/dev/null)"

grepopt="--color=auto"
alias grep='grep $grepopt'
alias egrep='egrep $grepopt'
alias fgrep='fgrep $grepopt'
unset grepopt

lsopt="-F -h"
if (( UID == 0 )); then
	lsopt="$lsopt -a"
fi
lsopt="$lsopt --color=auto"
alias ls='ls -la $lsopt'
unset lsopt
alias lsd='ls -a --ignore="[^.]*" --color=auto'


diffopt="--color=auto"
alias diff='diff $diffopt'
unset diffopt

treeopt="--dirsfirst"
if (( UID == 0 )); then
	treeopt="$treeopt -a"
fi
alias tree='tree $treeopt'
unset treeopt

alias py='python3'
alias py2='python2'
alias py3='python3'
alias pyclean='find . -name "*.pyc" -exec rm {} \;'
alias pyserver='py3 -m http.server'
alias djserver='python manage.py runserver 127.0.0.1:8000'
alias djshell='python manage.py shell'

alias wine_ja='LANG=ja_JP.UTF-8 wine'

# Dmesg for humans
alias dmesg="dmesg -wH"

# Free for humans
alias free="free -w -h -t"

# Find largest files and dirs
alias ducks='du -hs * | sort -rh | head'

alias gti='git'

alias logoff='logout'

alias who='who -HT'

if [[ $DESKTOP_SESSION ]]; then
  alias logout='env logout'
fi

alias re='hash -r && SILENT=1 . ~/.bashrc && echo reloaded .bashrc && :'


f() { find . \( -name .git -prune \) , \( -iname "*$1*" "${@:2}" \) | natsort; }
ff() { f "$@" | sed 's,^\./,,' | treeify --fake-root "$PWD"; }

kernels() {
  cat https://www.kernel.org/finger_banner | sed -r 's/^The latest (.+) version.*:/\1/' | column -t
}

cat() {
	if [[ $1 == *://* ]]; then
		curl -LsfS "$1"
	else
		command cat "$@"
	fi
}

# function run
# usage: run 10 command
run() {
    number=$1
    shift
    for i in `seq $number`; do
      "$@"
    done
}
# function split csv file into chunks of specified size
# usage: splitCsv <file in> <chunk size>
splitCsv() {
    HEADER=$(head -1 $1)
    if [ -n "$2" ]; then
        CHUNK=$2
    else
        CHUNK=1000
    fi
    tail -n +2 $1 | split -l $CHUNK - $1_split_
    for i in $1_split_*; do
        sed -i -e "1i$HEADER" "$i"
    done
}
