ln -sf $(pwd)/.zshenv $HOME/.zshenv
ln -sf $(pwd)/.zshrc $HOME/.zshrc
ln -sf $(pwd)/.zpreztorc $HOME/.zpreztorc

[ -d $HOME/.zprezto ] || git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto
