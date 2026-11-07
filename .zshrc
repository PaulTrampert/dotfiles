_should_start_tmux() {
    command -v tmux >/dev/null 2>&1 || return 1
    [[ -o interactive ]] || return 1
    [[ -z $TMUX && $TERM != (screen|tmux) ]] || return 1
    [[ -z $INSIDE_EMACS ]] || return 1
    [[ $TERM_PROGRAM != vscode ]] || return 1
    [[ $TERMINAL_EMULATOR != JetBrains-JediTerm ]] || return 1
}

if _should_start_tmux; then
    unfunction _should_start_tmux
    exec tmux new-session -A -s main
fi
unfunction _should_start_tmux

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
unsetopt autocd extendedglob
bindkey -e

# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/paul/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

autoload -U +X bashcompinit && bashcompinit

export EDITOR=vim
export PATH=$PATH:~/.local/bin

autoload zkbd
if [[ ! -a ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE} ]]; then
    zkbd
fi


source ~/.zkbd/$TERM-${${DISPLAY:t}:-$VENDOR-$OSTYPE}
[[ -n ${key[CtrlLeft]} ]] && bindkey "${key[CtrlLeft]}" backward-word
[[ -n ${key[CtrlRight]} ]] && bindkey "${key[CtrlRight]}" forward-word
[[ -n ${key[Home]} ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n ${key[End]} ]] && bindkey "${key[End]}" end-of-line
[[ -n ${key[Delete]} ]] && bindkey "${key[Delete]}" delete-char

zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'

autoload -Uz vcs_info
precmd_functions+=( vcs_info )

setopt prompt_subst
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '%F{yellow}' 
zstyle ':vcs_info:git:*' unstagedstr '%F{red}' 
zstyle ':vcs_info:git:*' formats "%F{cyan}%c%u[%b]%f "

alias ls="ls --color=auto"

PROMPT='$vcs_info_msg_0_%F{green}%n@%m%f:%F{blue}%~%f%# '

# Only run fastfetch if it's available on the PATH
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
