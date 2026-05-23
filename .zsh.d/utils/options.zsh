# =====================zsh options============================== {{{

# 補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# 履歴
export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=1000        # メモリに保存する件数
export SAVEHIST=100000      # ファイルに保存する件数
setopt hist_ignore_all_dups # 重複した履歴は残さない

# ディレクトリスタック
setopt auto_pushd           # cd 時に自動で pushd
setopt pushd_ignore_dups    # スタックの重複を無視

setopt no_beep
setopt no_global_rcs

# ロケール
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# C-s / C-q によるフロー制御を無効化（vim 等のキーバインド用）
stty stop undef
stty start undef

# }}}
