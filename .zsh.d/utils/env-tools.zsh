# direnv
export EDITOR=nvim
eval "$(direnv hook zsh)"

# initializeに0.6secかかっているので、
# 利用する時以外はコメントアウトする
# export PATH="$HOME/.anyenv/bin:$PATH"
# eval "$(anyenv init -)"

# eval "$(nodenv init -)"
# eval "$(rbenv init -)"

. $HOME/.asdf/asdf.sh
