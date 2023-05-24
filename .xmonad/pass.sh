#!/bin/bash

PREFIX=${1}
PASS=""

setxkbmap es

while IFS= read -r line; do
    PASS=${PASS:-$line}
    [[ -z "$PREFIX" ]] && break
    [[ "${line%%:*}" == ${PREFIX} ]] && USERNAME="${line##* }" 
done

[[ -n $USERNAME ]] && (xdotool type --clearmodifiers "$USERNAME"; xdotool key Tab)
xdotool type --clearmodifiers "$PASS"

