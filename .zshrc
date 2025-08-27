# Enable completion
autoload -Uz compinit
compinit

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# Tab completion tweaks
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}%d%f'
zstyle ':completion:*' list-colors ''

# Options
setopt autocd              # cd into directories without typing 'cd'
setopt correct             # auto-correct commands
setopt no_beep             # disable bell
setopt prompt_subst        # allow command substitution in prompt

bindkey -e                 # enable emacs bindings

# Ctrl+Left/Right word movement
bindkey "^[[1;5D" backward-word  # Ctrl+Left
bindkey "^[[1;5C" forward-word   # Ctrl+Right

# Alternate keycodes for some terminals
bindkey "^[OD" backward-word
bindkey "^[OC" forward-word

bindkey "\e[H" beginning-of-line # Home
bindkey "\e[F" end-of-line       # End

# Make Alt+Backspace behave like bash
bindkey '^[^?' backward-kill-word
WORDCHARS=''

# Make Shift+Tab go backwards for autocomplete
bindkey '^[[Z' reverse-menu-complete

# Prompt
ZSH_FIRST_PROMPT=1
autoload -Uz colors && colors

# Fast dirty check via git porcelain
parse_git_info() {
  local branch dirty marks
  command git rev-parse --is-inside-work-tree &>/dev/null || return

  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [[ -z $branch ]] && return

  marks=""
  dirty=$(git status --porcelain 2>/dev/null)

  [[ $dirty == *"M "* ]] && marks+="!"
  [[ $dirty == *"?? "* ]] && marks+="?"
  [[ $dirty == *"A "* ]] && marks+="+"
  [[ $dirty == *"D "* ]] && marks+="x"
  [[ $(git rev-list --count --left-only @{u}...HEAD 2>/dev/null) -gt 0 ]] && marks+="*"

  echo "[$branch${marks:+ $marks}]"
}

precmd() {
  local exit_code=$?
  local git_info host_info
  git_info=$(parse_git_info)
  host_info=""
  [[ -n $SSH_CONNECTION ]] && host_info=" (%{$fg[yellow]%}$(hostname)%{$reset_color%})"

  local color=$fg[green]
  (( exit_code != 0 )) && color=$fg[red]

  # Only prepend newline if this is not the first prompt
  local newline=""
  (( ZSH_FIRST_PROMPT == 0 )) && newline=$'\n'

  PROMPT="${newline}[%{$color%}$exit_code%{$reset_color%}] %{$fg[blue]%}%~%{$reset_color%} %{$fg[green]%}$git_info%{$reset_color%}$host_info %D{%F %T}"
  PROMPT+=$'\n'"${PROMPT_CHAR:-$([[ $EUID -eq 0 ]] && echo '#' || echo '$')} "

  ZSH_FIRST_PROMPT=0
}

# Aliases
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias clear='clear && ZSH_FIRST_PROMPT=1'
alias gs='git status'
alias gl="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
alias gr='git reset --soft HEAD~1 && git commit --amend --no-edit'
alias gg='git log --graph --oneline --all --decorate'
alias gb='git for-each-ref --sort=-committerdate refs/heads/'
alias gt='git log --no-walk --tags --pretty="%h %d %s" --decorate=full'
alias grep='grep --color=auto'
alias kc="kubectl"
alias nit='git commit -am "nit"'
alias kbdoff="sudo sys76-kb set -b 0"
alias less='less -R'
alias ls='ls --color=auto'
alias ll='ls -lh'
alias rg='rg --color=always'
alias power="upower -i /org/freedesktop/UPower/devices/battery_BAT0"
alias stop="pkill -STOP"
alias resume="pkill -CONT"
alias hostname="cat /etc/hostname"
alias update="sudo nixos-rebuild switch"
alias vim="nvim"
alias kitty="kitty --session ~/.config/kitty/startup-session.conf"
alias zwift="DONT_CHECK=true CONTAINER_TOOL='sudo docker' zwift"
# TODO: Remove python3.12 once https://github.com/Aider-AI/aider/issues/3660 is resolved.
alias aider="uvx --python=3.12 --from=aider-chat aider"
alias ruff="uvx ruff"
alias openhands="uvx --python=3.12 --from=openhands-ai openhands"
alias pkillgrep='function _pg() { ps aux | grep "$1" | grep -v grep | awk "{print \$2}" | xargs -r kill; }; _pg'
alias enable="swaymsg output eDP-1 enable"
alias disable="swaymsg output eDP-1 disable"
alias snip="slurp | grim -g -"
alias snap="sleep 3 && swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | \"\(.x),\(.y) \(.width)x\(.height)\"' | grim -g -"
alias chat="ollama run jqwen3:30b"
alias coder="ollama run devstral:latest"
alias weak="ollama run jqwen3:0.6b"
alias sober='echo $(( ($(date +%s) - $(date -d '2025-04-15' +%s)) / 86400 ))'

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

    rg --color=never --files-with-matches "$search_pattern" --glob "$file_pattern" | while read -r file; do
      sed -i "s|$search_pattern|$replacement|g" "$file"
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

# Kitty init
KITTY_SHELL_INTEGRATION="${KITTY_INSTALLATION_DIR:=/usr/lib/kitty}/shell-integration/$(basename $SHELL)/kitty.zsh"
if [ -f "$KITTY_SHELL_INTEGRATION" ]; then
    source "$KITTY_SHELL_INTEGRATION"
elif [ -x "$(command -v kitty)" ]; then
    source <(kitty +kitten shell-integration)
fi

# FZF init
if [ -x "$(command -v fzf)" ] && [ -r /usr/share/fzf/key-bindings.zsh ]
then
    source /usr/share/fzf/key-bindings.zsh
fi

# Load env
if [ -f "$HOME/.env" ]; then
  while read -r line; do
    export "$line"
  done < "$HOME/.env"
fi

# Vim as default
export EDITOR="vim"

# Color LS output to differentiate between directories and files
export LS_OPTIONS="--color=auto"
export CLICOLOR="Yes"
export LSCOLOR=""

# Customize Path
export GOPATH="$HOME/.go"
export GOBIN="$GOPATH/bin"
export PATH=$HOME/code/monorepo/tools/bin:$HOME/.local/bin:$GOBIN:$PATH

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

export GRIM_DEFAULT_DIR="~/Pictures"

if [ -z "$SSH_AUTH_SOCK" ]; then
  SSH_AUTH_SOCK=$(systemctl --user show-environment | grep SSH_AUTH_SOCK | cut -d= -f2)
  export SSH_AUTH_SOCK=${SSH_AUTH_SOCK:-$XDG_RUNTIME_DIR/ssh-agent.socket}
fi

# https://wiki.archlinux.org/title/Docker#Rootless_Docker_daemon
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
if [ -f /.dockerenv ]; then
  export IN_DOCKER=true
else
  export IN_DOCKER=false
fi
export BUILDX_BAKE_ENTITLEMENTS_FS=0

export OLLAMA_HOST=http://ollama.home
export OLLAMA_API_BASE="$OLLAMA_HOST"

# For torch with AMD GPU
export HSA_OVERRIDE_GFX_VERSION=11.0.0
