#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [ -d "$HOME/.bash_completion.d" ]; then
    for script in $HOME/.bash_completion.d/*; do
        [ -r "$script" ] && . "$script"
    done
fi

if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
    source "$KITTY_INSTALLATION_DIR/shell-integration/$(basename $SHELL)/kitty.bash"
else
    source <(kitty +kitten shell-integration)
fi

if [ -x "$(command -v fzf)" ] && [ -r /usr/share/fzf/key-bindings.bash ]
then
    source /usr/share/fzf/key-bindings.bash
fi


if [ -f "$HOME/.env" ]; then
  while read -r line; do
    export "$line"
  done < "$HOME/.env"
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# Adds date to .bash_history
export HISTTIMEFORMAT="%d/%m/%y %T "

# Vim as default
export EDITOR="vim"

# Color LS output to differentiate between directories and files
export LS_OPTIONS="--color=auto"
export CLICOLOR="Yes"
export LSCOLOR=""

# Customize Path
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export PATH=$HOME/code/monorepo/bin:$HOME/.local/bin:$GOBIN:$PATH

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# https://wiki.archlinux.org/title/Docker#Rootless_Docker_daemon
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
if [ -f /.dockerenv ]; then
  export IN_DOCKER=true
else
  export IN_DOCKER=false
fi

export OLLAMA_HOST=http://ollama.home
export OLLAMA_API_BASE=$OLLAMA_HOST

function parse_git_branch() {
  local branch
  local stat
  branch="$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')"
  if [ ! "${branch}" == "" ]; then
    stat="$(parse_git_dirty)"
    echo "[${branch}${stat}]"
  else
    echo ""
  fi
}

# get current status of git repo
function parse_git_dirty {
  status=`git status 2>&1 | tee`
  dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
  untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
  ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
  newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
  renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
  deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
  bits=''
  if [ "${renamed}" == "0" ]; then
    bits=">${bits}"
  fi
  if [ "${ahead}" == "0" ]; then
    bits="*${bits}"
  fi
  if [ "${newfile}" == "0" ]; then
    bits="+${bits}"
  fi
  if [ "${untracked}" == "0" ]; then
    bits="?${bits}"
  fi
  if [ "${deleted}" == "0" ]; then
    bits="x${bits}"
  fi
  if [ "${dirty}" == "0" ]; then
    bits="!${bits}"
  fi
  if [ ! "${bits}" == "" ]; then
    echo " ${bits}"
  else
    echo ""
  fi
}

PROMPT_COMMAND=__user_prompt_command # Func to gen PS1 after CMDs

__user_prompt_command() {
    local EXIT="$?"             # This needs to be first

    PS1="\n"

    local Red='\[\e[0;31m\]'
    local Gre='\[\e[0;32m\]'
    local Yel='\[\e[0;33m\]'
    local Blu='\[\e[0;34m\]'
    local BluBG='\[\e[48;5;27m\e[38;5;231m\]'
    local GraBG='\[\e[48;5;235m\e[38;5;231m\]'
    local RCol='\[\e[0m\]'
    local GIT_BRANCH=$(parse_git_branch)

    if [ $EXIT != 0 ]; then
        PS1+="[${Red}${EXIT}${RCol}]"      # Add red if exit code non 0
    else
        PS1+="[${Gre}${EXIT}${RCol}]"
    fi

    PS1+=" ${Blu}\w ${RCol}${Gre}${GIT_BRANCH}${RCol} \D{%F %T}"

    if [[ $EUID -eq 0 ]]; then
      PS1+="\n# "
    else
      PS1+="\n$ "
    fi
}

# Aliases
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias gl="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias gs='git status'
alias gc='git checkout'
alias gp='git push -u'
alias gr='git reset --soft HEAD~1 && git commit --amend --no-edit'
alias gg='git log --graph --oneline --all --decorate'
alias ggm='git log --graph --oneline --decorate origin/master HEAD'
alias gd="git diff $(git merge-base origin/master HEAD) --name-only"
alias gb='git for-each-ref --sort=-committerdate refs/heads/'
alias gt='git log --no-walk --tags --pretty="%h %d %s" --decorate=full'
alias grep='grep --color=auto'
alias nit='git commit -am "nit"'
alias kbdoff="sudo sys76-kb set -b 0"
alias ls='ls --color=auto'
alias less='less -R'
alias ll='ls -l'
alias rg='rg --color=always'
alias power="upower -i /org/freedesktop/UPower/devices/battery_BAT0"
alias stop="pkill -STOP"
alias resume="pkill -CONT"
alias hostname="cat /etc/hostname"
alias vim="nvim"
alias kitty="kitty --session ~/.config/kitty/startup-session.conf"
alias zwift="DONT_CHECK=true CONTAINER_TOOL='sudo docker' zwift"
alias pkillgrep='function _pg() { ps aux | grep "$1" | grep -v grep | awk "{print \$2}" | xargs -r kill; }; _pg'
alias enable="swaymsg output eDP-1 enable"
alias disable="swaymsg output eDP-1 disable"
alias snip="slurp | grim -g - ~/Pictures/screenshot.png"
alias snap="sleep 3 && swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | \"\(.x),\(.y) \(.width)x\(.height)\"' | grim -g - ~/Pictures/screenshot.png"
alias chat="ollama run deepseek-j1:8b"
alias weak="ollama run jqwen3:0.6b"
alias sober="echo $(( ($(date +%s) - $(date -d '2025-04-15' +%s)) / 86400 ))"

# Functions
function home() {
  export home="$PWD"
}

function cd() {
  HOME="${home:=$HOME}" builtin cd "$@"
}

function rgplace() {
    if [[ $# -lt 2 ]]; then
        echo "Usage: rgplace <search_pattern> <replacement> [file_pattern]"
        echo "Example: rgplace 'foo' 'bar' '*.txt'"
        return 1
    fi

    local search_pattern=$1
    local replacement=$2
    local file_pattern=$3

    if [ -z "$file_pattern" ]; then
      file_pattern="*"
    fi

    rg --files -g "$file_pattern" | while read -r file; do
        if rg -q "$search_pattern" "$file"; then
            sed -i "s/${search_pattern}/${replacement}/g" "$file"
        fi
    done
}

function ga() {
  local message="$1"
  if [ -z "$message" ]; then
    >&2 echo "Commit message is required."
    return 2
  fi
  git commit --amend -m "${message}"
}
function gsp() {
  local subtree="${1:-}"
  local toplevel
  toplevel=$(git rev-parse --show-toplevel)
  if [ -z "$subtree" ]; then
    >&2 echo "Missing argument 'subtree'."
    echo "Pick one of:"
    # https://stackoverflow.com/a/18339297
    git log | grep git-subtree-dir | tr -d ' ' | cut -d ":" -f2 | sort | uniq | xargs -I {} bash -c 'if [ -d $(git rev-parse --show-toplevel)/{} ] ; then echo "  {}"; fi'
    return 2
  fi
  git -C "$toplevel" subtree push --prefix "$subtree" "git@github.com:jmelahman/$(basename "${subtree}").git" master
}

# Name the current terminal tab in xterm-compatible program.
# See also, https://github.com/lanoxx/tilda/issues/134#issuecomment-419906171
function title() { echo -e  "\e]2;${1}\a  tab --> [${1}]"; }
eval $(ssh-agent) > /dev/null
