#!/bin/sh

userresources=$HOME/.Xresources

export BROWSER=brave
export EDITOR=vim
export SUDO_ASKPASS="/usr/lib/ssh/ssh-askpass"

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrandr --output eDP-1 --mode 1920x1080
setxkbmap -layout es
xsetroot -cursor_name left_ptr
exec xmonad
