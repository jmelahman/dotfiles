alias ls='ls --color=auto'
alias lal='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ll='ls -l'
alias cs='cd;ls'

alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'

alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
