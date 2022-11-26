# ~/.profile - sh/bash login script
# vim: ft=sh

. ~/dotfiles/environ

if [ "$BASH" ] && [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

true
