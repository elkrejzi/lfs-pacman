# Begin /etc/bash.bashrc

[ -z "$PS1" ] && return

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# set a fancy prompt (non-color, overwrite the one in /etc/profile)
PS1='\u@\h:\w\$ '

# End /etc/bash.bashrc
