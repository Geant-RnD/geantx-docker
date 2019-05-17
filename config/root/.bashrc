# ~/.bashrc: executed by bash(1) for non-login shells.

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# PS1='${debian_chroot:+($debian_chroot)}\h:\w\$ '

umask 0000

# environment
export SHELL=$(which bash)
export PS1='[ \[\e[1;33m\]\# \[\e[0;22m\]- \[\e[1;31m\]\u@\h \[\e[0;22m\]- \[\e[1;33m\]\@ \[\e[0;22m\]- \[\e[1;35m\]$(/etc/compute-dir-size.py)\[\e[0;22m\] : \[\e[1;36m\]$(pwd) \[\e[0;22m\]] $ \[\e[m\]\[\e[0;22m\]'
export LS_OPTIONS='--color=auto -F'
eval "`dircolors`"

# aliases
alias ls='/bin/ls $LS_OPTIONS'
alias ll='/bin/ls $LS_OPTIONS -l'
alias la='/bin/ls $LS_OPTIONS -la'
alias  l='/bin/ls $LS_OPTIONS -lA'
alias grep='/bin/grep --color=auto'
alias rgrep='/bin/rgrep --color=auto'
alias egrep='/bin/egrep --color=auto'

# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

export MPLBACKEND=agg
export HISTIGNORE='&:bg:fg:ll:ls'
export HISTCONTROL='ignoreboth:erasedups'
export HISTFILESIZE=5000000

if [ -f "/root/.scl.env" ]; then
    . /root/.scl.env
fi

#------------------------------------------------------------------------------#
remove-static-libs()
#------------------------------------------------------------------------------#
{
    for i in $@
    do
        find ${i} -type f -regex ".*\.a$" -exec rm -v {} \;
    done
}

#------------------------------------------------------------------------------#
remove-broken-links()
#------------------------------------------------------------------------------#
{
    for i in $@
    do
        find ${i} -type l ! -exec test -e {} \; -exec echo "  - Removing {}..." \; -exec rm {} \;
    done
}

#------------------------------------------------------------------------------#
#  CMAKE_PREFIX_PATH
#------------------------------------------------------------------------------#
for i in $(find /opt/local/lib -maxdepth 1 -type d | grep 'Geant4-')
do
    export CMAKE_PREFIX_PATH=${i}:${CMAKE_PREFIX_PATH}
done
