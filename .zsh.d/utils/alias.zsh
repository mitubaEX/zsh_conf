# alias tmux='tmux -u'

# alias
alias e='exit'
alias rm='rm -rf'
alias v='vim'
alias vi='nvim'

# docker
alias dockerrm='docker rm -f $(docker ps -qa)'
alias dockerrmi='docker rmi -f $(docker images -q)'

alias atmkdir='for i in A B C D ; do mkdir "$i"; touch "$i"/main.py ;done '
alias mkdir='(){if [ $# -gt 1 ] ; then mkdir $@ ; else mkdir $1;cd $1 ;fi}'

# change ls to exa
alias ls='exa --icons'
alias ll='exa -l'

alias g++="g++ -std=c++11"

alias ghci='stack ghci'
alias ghc='stack ghc --'
alias runghc='stack runghc --'

alias nv="nvr --servername $NVIM_LISTEN_ADDRESS"

alias nasm='/usr/local/bin/nasm'

# k8s
alias k='kubectl'

# ref: https://qiita.com/yusabana/items/b5cc2a706be8c031043e
alias less='less -qR'

alias rm='rm -rf'
alias dockerrm='docker rm -f $(docker ps -qa)'
alias dockerrmi='docker rmi -f $(docker images -q)'
