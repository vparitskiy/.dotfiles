#!/bin/sh
# ~/.xinitrc - `xinit`/`startx` startup script

have() { type "$1" > /dev/null 2>&1; }

[ "$1" ] || set -- gnome

cd ~ || exit

# ensure ssh-agent, session bus

if [ ! "$SSH_AUTH_SOCK" ] && have ssh-agent; then
	exec ssh-agent ~/.xinitrc "$@" || exit
fi

if [ ! "$XDG_RUNTIME_DIR" ] || [ ! -S "$XDG_RUNTIME_DIR/bus" ]; then
	# As of systemd v240 (2b2b7228bf), $DBUS_SESSION_BUS_ADDRESS is no longer set.
	# (I expect they'll revert this as soon as someone informs them that not all
	#  DBus clients are based on libdbus or glib2.)

	if [ ! "$DBUS_SESSION_BUS_ADDRESS" ] && have dbus-run-session; then
		exec dbus-run-session ~/.xinitrc "$@" || exit
	fi

	if [ ! "$DBUS_SESSION_BUS_ADDRESS" ] && have dbus-launch; then
		exec dbus-launch --exit-with-session ~/.xinitrc "$@" || exit
	fi
fi

if have dbus-update-activation-environment; then
	dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
fi

# load global profile

[ -f /etc/profile ]	&& . /etc/profile
[ -f ~/.profile ]	&& . "$HOME"/.profile

# initial appearance

bg_color='#222222'

if have xsetroot; then
	xsetroot -solid "$bg_color" -cursor_name 'left_ptr'
fi
if have hsetroot; then
	hsetroot -solid "$bg_color"
fi

# expand aliases in command line

case $1 in
	cinnamon)	set -- cinnamon-session;;
	e)		set -- enlightenment_start -i-really-know-what-i-am-doing-and-accept-full-responsibility-for-it;;
	gnome)		set -- gnome-session;;
	kde)		set -- startkde;;
	mate)		set -- mate-session;;
	openbox)	set -- openbox --startup ~/.config/openbox/autostart;;
	xfce)		set -- xfce4-session;;
esac

# inform .xprofile about session type

case $1 in
	cinnamon-session)	DESKTOP_SESSION=cinnamon;;
	gnome-session)		DESKTOP_SESSION=gnome;;
	enlightenment_start)	DESKTOP_SESSION=enlightenment;;
	mate-session)		DESKTOP_SESSION=mate;;
	startkde)		DESKTOP_SESSION=kde-plasma;;
	xfce4-session)		DESKTOP_SESSION=xfce;;
	xterm)			DESKTOP_SESSION=xterm;;
esac

export DESKTOP_SESSION

# load X11-specific profile

[ -f /etc/xprofile ]	&& . /etc/xprofile
[ -f ~/.xprofile ]	&& . "$HOME"/.xprofile
[ -f ~/.Xresources ]	&& xrdb -merge ~/.Xresources
[ -f ~/.Xkbmap ]	&& setxkbmap "$(cat ~/.Xkbmap)"

# run the session

exec "$@"
