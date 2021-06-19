# =====================git alias============================== {{{
  alias g='git'

  alias ga='git add -p'
  alias gaa='git add -p --all'
  alias gapa='git add --patch'
  alias gau='git add --update'
  alias gav='git add --verbose'
  alias gap='git apply'

  alias gb='git branch'
  alias gba='git branch -a'
  alias gbd='git branch -d'
  alias gbda='git branch --no-color --merged | command grep -vE "^(\*|\s*(master|develop|dev)\s*$)" | command xargs -n 1 git branch -d'
  alias gbl='git blame -b -w'
  alias gbnm='git branch --no-merged'
  alias gbr='git branch --remote'
  alias gbs='git bisect'
  alias gbsb='git bisect bad'
  alias gbsg='git bisect good'
  alias gbsr='git bisect reset'
  alias gbss='git bisect start'

  alias gc='git commit -v'
  alias gc!='git commit -v --amend'
  alias gcn!='git commit -v --no-edit --amend'
  alias gca='git commit -v -a'
  alias gca!='git commit -v -a --amend'
  alias gcan!='git commit -v -a --no-edit --amend'
  alias gcans!='git commit -v -a -s --no-edit --amend'
  alias gcam='git commit -a -m'
  alias gcsm='git commit -s -m'
  alias gcb='git checkout -b'
  alias gcf='git config --list'
  alias gcl='git clone --recurse-submodules'
  alias gclean='git clean -fd'
  alias gpristine='git reset --hard && git clean -dfx'
  alias gcm='git checkout master'
  alias gcd='git checkout develop'
  alias gcmsg='git commit -m'
  alias gco='git checkout'
  alias gcp='git cherry-pick'
  alias gcpa='git cherry-pick --abort'
  alias gcpc='git cherry-pick --continue'
  alias gcs='git commit -S'

  alias gd='git diff'
  alias gdca='git diff --cached'
  alias gdcw='git diff --cached --word-diff'
  alias gdct='git describe --tags `git rev-list --tags --max-count=1`'
  alias gds='git diff --staged'
  alias gdt='git diff-tree --no-commit-id --name-only -r'
  alias gdw='git diff --word-diff'

  alias gf='git fetch'
  alias gfa='git fetch --all --prune'
  alias gfo='git fetch origin'

  alias gg='git gui citool'
  alias gga='git gui citool --amend'

  ggf() {
    [[ "$#" != 1 ]] && local b="$(git_current_branch)"
    git push --force origin "${b:=$1}"
  }

  alias ggsup='git branch --set-upstream-to=origin/$(git_current_branch)'
  alias gpsup='git push --set-upstream origin $(git_current_branch)'

  alias ghh='git help'

  alias gignore='git update-index --assume-unchanged'
  alias gignored='git ls-files -v | grep "^[[:lower:]]"'

  alias gl='git pull'
  alias glg='git log --stat'
  alias glgp='git log --stat -p'
  alias glgg='git log --graph'
  alias glgga='git log --graph --decorate --all'
  alias glgm='git log --graph --max-count=10'
  alias glo='git log --oneline --decorate'
  alias glol="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'"
  alias glod="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'"
  alias glods="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"
  alias glola="git log --graph --pretty='%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --all"
  alias glog='git log --oneline --decorate --graph'
  alias gloga='git log --oneline --decorate --graph --all'

  alias gm='git merge'
  alias gmom='git merge origin/master'
  alias gmt='git mergetool --no-prompt'
  alias gmtvim='git mergetool --no-prompt --tool=vimdiff'
  alias gmum='git merge upstream/master'
  alias gma='git merge --abort'

  alias gp='
  echo "\e[31m動作確認した？"
  read
  echo "\e[31m命名は大丈夫？"
  read
  echo "\e[31mこのコード本当に消しても大丈夫？"
  read
  echo "\e[31mコメントは書いた？"
  read
  echo "\e[31m基本情報負荷対応的に大丈夫？"
  read
  echo "\e[31mspec書いた方がいいやつ？"
  read
  echo "\e[39m"
  git push'
  alias gpd='git push --dry-run'
  alias gpu='git push upstream'
  alias gpv='git push -v'
  alias gpoh="git push origin $(git branch | grep -E '^\*' | cut -b 3-)"

  alias gr='git remote'
  alias gra='git remote add'
  alias grb='git rebase'
  alias grba='git rebase --abort'
  alias grbc='git rebase --continue'
  alias grbd='git rebase develop'
  alias grbi='git rebase -i'
  alias grbm='git rebase master'
  alias grbs='git rebase --skip'
  alias grh='git reset'
  alias grhh='git reset --hard'
  alias grmv='git remote rename'
  alias grrm='git remote remove'
  alias grset='git remote set-url'
  alias grt='cd $(git rev-parse --show-toplevel || echo ".")'
  alias gru='git reset --'
  alias grup='git remote update'
  alias grv='git remote -v'

  alias gsb='git status -sb'
  alias gsd='git svn dcommit'
  alias gsh='git show'
  alias gsi='git submodule init'
  alias gsps='git show --pretty=short --show-signature'
  alias gsr='git svn rebase'
  alias gss='git status -s'
  alias gst='git status'
  alias gsta='git stash save'
  alias gstaa='git stash apply'
  alias gstc='git stash clear'
  alias gstd='git stash drop'
  alias gstl='git stash list'
  alias gstp='git stash pop'
  alias gsts='git stash show --text'
  alias gsu='git submodule update'

  alias gts='git tag -s'
  alias gtv='git tag | sort -V'

  alias gunignore='git update-index --no-assume-unchanged'
  alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'
  alias gup='git pull --rebase'
  alias gupv='git pull --rebase -v'
  alias glum='git pull upstream master'

  alias gwch='git whatchanged -p --abbrev-commit --pretty=medium'
  alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify -m "--wip-- [skip ci]"'
# }}}
