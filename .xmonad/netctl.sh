#!/bin/bash

profile=$1
NOTIF="Network"
export SUDO_ASKPASS=$HOME/bin/rofi-askpass.sh 

main() {
    [[ -z ${profile} ]] && exit 0
    sudo netctl switch-to $profile && notify-send "${NOTIF}" "Connected to ${profile}"
}

output=$(main 2>&1)

[[ -n ${output} ]] && notify-send "${NOTIF}" "${output}"

exit 0
