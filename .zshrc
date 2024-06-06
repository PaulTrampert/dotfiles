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
