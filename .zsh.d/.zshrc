#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...
#
git-info on
bindkey -M viins '^W' vi-cmd-mode
bindkey -v '^L'   forward-char
bindkey -v '^H'   backward-char
bindkey -v '^K'   up-line-or-history
bindkey -v '^J'   down-line-or-history

# zshの起動時のprofile表示用の設定
# zprofの呼び出しをファイルの下に置くと
# profileをゲットできる
# zmodload zsh/zprof
# if (which zprof > /dev/null 2>&1) ;then
#   zprof
# fi

. $ZDOTDIR/utils/alias.zsh
. $ZDOTDIR/utils/env-tools.zsh
. $ZDOTDIR/utils/fzf-config.zsh
. $ZDOTDIR/utils/fzf-functions.zsh
. $ZDOTDIR/utils/git-alias.zsh

stty stop undef
stty start undef

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

# key-bind
bindkey -M viins 'jj' vi-cmd-mode
bindkey -v '^F'   forward-char
bindkey -v '^B'   backward-char
bindkey -v '^K'   up-line-or-history
bindkey -v '^J'   down-line-or-history
bindkey -v '^P'   up-line-or-history
bindkey -v '^N'   down-line-or-history

# lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

export PATH=$PATH:$HOME/.local/bin:$HOME/.rbenv/bin:$HOME/.cabal:/usr/local/bin:$HOME/.cargo/bin

# vim
stty stop undef
stty start undef

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH:$HOME/node_modules/.bin"

# 全体で共有したい情報はこれを使う
# source $HOME/.env

# Docker completions
if [ -e ~/.zsh/completion ]; then
  fpath=(~/.zsh/completion $fpath)
fi

printf "\e[4 q"

# ls
function chpwd() { rename_session && ls }

function gcopr() {
  git fetch upstream pull/$1/head:$1
  git checkout $1
}

function gplpr() {
  git pull upstream pull/$(git branch | grep \* | cut -d ' ' -f2)/head
}

if [ -f './crefre.zsh' ]; then
  . ./crefre.zsh
fi

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

# Add Visual Studio Code (code)
export PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin:$PATH"

export LDFLAGS="-I/usr/local/opt/openssl/include -L/usr/local/opt/openssl/lib"

export JAVA_HOME=`/usr/libexec/java_home -v 11`

test -e "${ZDOTDIR}/.iterm2_shell_integration.zsh" && source "${ZDOTDIR}/.iterm2_shell_integration.zsh"

# fzf floating window
export FZF_TMUX_OPTS="-w80% -h80%"
