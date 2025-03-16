mkdir -p $HOME/.zsh.d
mkdir -p $HOME/.zsh.d/utils
ln -sf $(pwd)/.zsh.d/.zshrc $HOME/.zsh.d/.zshrc
ln -sf $(pwd)/.zsh.d/.zshenv $HOME/.zsh.d/.zshenv
find .zsh.d -type f | xargs -I% ln -sf $(pwd)/% $HOME/%

ln -sf $(pwd)/.zshenv $HOME/.zshenv
ln -sf $(pwd)/.zpreztorc $HOME/.zsh.d/.zpreztorc
