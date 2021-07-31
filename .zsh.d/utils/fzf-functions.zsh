# When launch tmux, select session by user
# ref: https://qiita.com/ssh0/items/a9956a74bff8254a606a
if [[ ! -n $TMUX ]]; then
  # get the IDs
  ID="`tmux list-sessions`"
  if [[ -z "$ID" ]]; then
    # tmux new-session && exit
    tmux new-session
  fi
  create_new_session="Create New Session"
  ID="$ID\n${create_new_session}:"
  ID="`echo $ID | fzf --height='30%' --layout='reverse'| cut -d: -f1`"
  if [[ "$ID" = "${create_new_session}" ]]; then
    tmux new-session
  elif [[ -n "$ID" ]]; then
    tmux attach-session -t "$ID"
  else
    :  # Start terminal normally
  fi
fi

## ref: https://www.matsub.net/posts/2017/12/01/ghq-fzf-on-tmux
## ref: http://blog.chairoi.me/entry/2017/12/26/233926
function create_session_with_ghq_for_popup() {
  local moveto=$(ghq root)/$(ghq list | fzf-tmux -w80% -h80%)
  local repo_name=$(basename $moveto)
  if [ $repo_name != $(basename $(ghq root)) ]
  then
    tmux new-session -d -c $moveto -s $repo_name
    tmux switch-client -t $repo_name
  fi
}
zle -N create_session_with_ghq_for_popup
bindkey '^G' create_session_with_ghq_for_popup

function remove_session() {
  local session_name=$(tmux display-message -p '#S')
  if [ ! -z ${session_name} ]
  then
    tmux switch-client -n
    tmux kill-session -t $session_name
  fi
}
zle -N remove_session
bindkey '^X' remove_session

function rename_session() {
  local dir=$(pwd)
  # remove ghq dir
  if [[ $dir != *".ghq"* ]]; then
    local name=$(basename $dir)
    if [[ ! -z ${TMUX} ]]
    then
      if [ ! -z ${name} ]
      then
        tmux rename-session -t $(tmux display-message -p '#S') $name
        # tmux switch-client -t $(echo $moveto | IFS=":" read -r a b; echo $a) 2> /dev/null
      fi
    fi
  fi
}

# cdr, add-zsh-hook を有効にする
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

function move_session_with_fzf() {
  local moveto_session=$(tmux ls | awk -F':' '{print $1}' | fzf-tmux -w80% -h80%)
  if [[ ! -z ${moveto_session} ]]
  then
    tmux switch-client -t $rtmux switch-client -t $moveto_session
  fi
}
zle -N move_session_with_fzf
bindkey '^S' move_session_with_fzf
