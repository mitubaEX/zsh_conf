# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# utils/ 以下の設定をすべて読み込む（alphabetical 順）
for conf in "${ZDOTDIR:-$HOME}"/utils/*.zsh(N); do
  source "$conf"
done
