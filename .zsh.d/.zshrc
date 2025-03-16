export PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

. $ZDOTDIR/utils/alias.zsh
. $ZDOTDIR/utils/env-tools.zsh
. $ZDOTDIR/utils/git-alias.zsh

# no check uppper case and lower case
zstyle ':completion:*' matcher-list 'm:{}a-z}={}A-Z}'

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# remove duplication of history
setopt hist_ignore_all_dups

# use dir stack
setopt auto_pushd

# remove duplication of dir stack
setopt pushd_ignore_dups

# no-beep
setopt no_beep

setopt no_global_rcs

# key-bind
bindkey -M viins 'jj' vi-cmd-mode
bindkey -v '^F'   forward-char
bindkey -v '^B'   backward-char
bindkey -v '^P'   up-line-or-history
bindkey -v '^N'   down-line-or-history

# lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# vim
stty stop undef
stty start undef
