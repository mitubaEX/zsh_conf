# =====================key bindings============================== {{{

# jj で vi コマンドモードへ
bindkey -M viins 'jj' vi-cmd-mode
bindkey -v '^F' forward-char
bindkey -v '^B' backward-char
bindkey -v '^P' up-line-or-history
bindkey -v '^N' down-line-or-history

# Ctrl+G で ghq-cd（リポジトリを選択して cd）
_ghq-cd-widget() {
    ghq-cd
    zle accept-line
}
zle -N _ghq-cd-widget
bindkey '^G' _ghq-cd-widget

# }}}
