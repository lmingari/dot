#!/usr/bin/env bash

ACTION="toggle"
ACTION="${1:-$ACTION}"

STEP="5%"

amixer get Master | grep -q '\[on\]' && TOGGLE="mute" || TOGGLE="unmute"

case $ACTION in
  up) 
      amixer set Master ${STEP}+ unmute 
      ;;
  down) 
      amixer set Master ${STEP}- unmute 
      ;;
  *) 
      amixer set Master $TOGGLE
      ;;
esac
