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


autoload -Uz vcs_info
precmd_functions+=( vcs_info )

setopt prompt_subst
zstyle ':vcs_info:git:*' formats '%F{yellow}[%b]%f '

PROMPT='$vcs_info_msg_0_%F{green}%n@%m%f:%F{blue}%1d%f%# '
