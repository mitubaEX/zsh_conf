# 非対話シェル (エディタやエージェントが起動するシェル) は ~/.zshrc を読まないので、そこでも必要なものだけをここに置く
export PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin

# 隔離環境（サンドボックス等）で ~/.gitconfig を参照できず、author/committer が
# "Test User <test@example.com>" にフォールバックされるのを防ぐ。
# 環境変数は git の identity 解決で最優先のため、ここで明示しておけば常に自分名義になる。
export GIT_AUTHOR_NAME="mitubaEX"
export GIT_AUTHOR_EMAIL=""
export GIT_COMMITTER_NAME="mitubaEX"
export GIT_COMMITTER_EMAIL=""
. "$HOME/.cargo/env"
