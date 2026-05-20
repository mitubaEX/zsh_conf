export EDITOR=nvim

# mise が GitHub の未認証レート制限(60req/h)で 403 になるのを防ぐ。
# neovim@nightly 等は解決時に GitHub releases API を叩くため、gh のトークンを mise に渡す。
# MISE_GITHUB_TOKEN は mise 専用なので、GITHUB_TOKEN を常時 export するより副作用が小さい。
command -v gh >/dev/null && export MISE_GITHUB_TOKEN="$(gh auth token 2>/dev/null)"

# mise: tool version manager (asdf の後継)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# direnv: 環境変数の自動ロード (mise activate の後に hook する)
eval "$(direnv hook zsh)"
