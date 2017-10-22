#!/bin/sh
# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

# This script was ported from:
#  - etc/pm/sleep.d/ValidityServiceSuspend.sh
#  - usr/lib/pm-utils/sleep.d/65ValidityServiceResume.sh

resume_FPS() {
    # Signal the vcsFPService about the resume
    echo "Sending Resume Event"
    pkill -SIGUSR2 vcsFPService
}

suspend_FPS() {
    # Signal the vcsFPService about the suspend/hiberante
    echo "Sending Suspend Event"
    pkill -SIGUSR1 vcsFPService
}

case "$1" in
    'pre')  suspend_FPS ;;
    'post') resume_FPS ;;
esac

exit $?
