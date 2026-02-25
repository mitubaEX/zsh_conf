# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

. $ZDOTDIR/utils/alias.zsh
. $ZDOTDIR/utils/env-tools.zsh
. $ZDOTDIR/utils/git-alias.zsh

# no check uppper case and lower case
zstyle ':completion:*' matcher-list 'm:{}a-z}={}A-Z}'

# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history

# メモリに保存される履歴の件数
export HISTSIZE=1000

# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000

# remove duplication of history
setopt hist_ignore_all_dups

# use dir stack
setopt auto_pushd

# remove duplication of dir stack
setopt pushd_ignore_dups

# no-beep
setopt no_beep

setopt no_global_rcs

# key-bind
bindkey -M viins 'jj' vi-cmd-mode
bindkey -v '^F'   forward-char
bindkey -v '^B'   backward-char
bindkey -v '^P'   up-line-or-history
bindkey -v '^N'   down-line-or-history

# lang
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# vim
stty stop undef
stty start undef


export PATH="$PATH:/opt/homebrew/bin"

# alias claude="/Users/jun-nakamura/.claude/local/claude"
direnv allow

# aqua
# export PATH="$(aqua root-dir)/bin:$PATH"

# 'work' という名前の関数を定義
work() {
    # 1. 引数（ブランチ名）が指定されているかチェック
    if [ -z "$1" ]; then
        echo "使用方法: work <branch-name>"
        echo "例: work feature/new-login"
        return 1
    fi

    local branch_name="$1"
    # ブランチ名の / を - に置換 (Tmuxセッション名とディレクトリパスのため)
    local task_name=$(echo "$branch_name" | sed 's|/|-|g')

    # 2. Gitリポジトリのルートディレクトリを取得
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "エラー: Gitリポジトリ内で実行してください。"
        return 1
    fi

    # 3. 変数の設定
    # worktreeを .worktrees ディレクトリ配下に集約
    local worktree_dir="$repo_root/.worktrees/$task_name"
    local session_name="$task_name" # tmuxセッション名をタスク名と同一にする

    # --- Git Worktree の作成 ---
    if [ ! -d "$worktree_dir" ]; then
        echo "🌳 ワークツリーを作成中: $worktree_dir"

        # (1) リモートブランチ (origin/$branch_name) が存在するかチェック
        # (git ls-remote --heads origin $branch_name は完全一致のみを返す)
        if git ls-remote --exit-code --heads origin "$branch_name" > /dev/null 2>&1; then
            echo "↪︎ リモートブランチ 'origin/$branch_name' が見つかりました。"
            echo "↪︎ これを追跡する新しいローカルブランチ '$branch_name' を作成します..."

            # -b $branch_name でローカルブランチを作成し、
            # 追跡対象を origin/$branch_name に設定して worktree を作成
            if ! git worktree add -b "$branch_name" "$worktree_dir" "origin/$branch_name"; then

                # ★ "already exists" で失敗した場合のフォールバック ★
                echo "↪︎ ブランチ '$branch_name' は既にローカルに存在していたようです。"
                echo "↪︎ 既存のローカルブランチ '$branch_name' を使用します..."
                if ! git worktree add "$worktree_dir" "$branch_name"; then
                     echo "エラー: ワークツリーの作成に失敗しました。(E1)"
                     rm -rf "$worktree_dir" # クリーンアップ
                     return 1
                fi
            fi

        # (2) リモートにない場合、ローカルブランチ ($branch_name) が存在するかチェック
        elif git show-ref --verify --quiet "refs/heads/$branch_name"; then
            echo "↪︎ 既存のローカルブランチ '$branch_name' を使用します。"
            if ! git worktree add "$worktree_dir" "$branch_name"; then
                 echo "エラー: ワークツリーの作成に失敗しました。(E2)"
                 rm -rf "$worktree_dir" # クリーンアップ
                 return 1
            fi

        # (3) リモートにもローカルにもない場合、デフォルトブランチから新規作成
        else
            echo "↪︎ ブランチ '$branch_name' が見つかりません。"

            # デフォルトブランチ (main or master) を取得
            local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@' 2>/dev/null)
            if [ -z "$default_branch" ] || [ "$default_branch" = "HEAD" ]; then
                if git show-ref --verify --quiet refs/remotes/origin/main; then
                    default_branch="main"
                elif git show-ref --verify --quiet refs/remotes/origin/master; then
                    default_branch="master"
                else
                    echo "エラー: デフォルトブランチ (main/master) が見つかりません。"
                    return 1
                fi
            fi

            echo "↪︎ デフォルトブランチ ('$default_branch') から新しいブランチ '$branch_name' を作成します..."
            if ! git worktree add -b "$branch_name" "$worktree_dir" "$default_branch"; then
                 echo "エラー: ワークツリーの作成に失敗しました。(E3)"
                 rm -rf "$worktree_dir" # クリーンアップ
                 return 1
            fi
        fi

        # --- ★ 追加: .envrc のコピーと許可 ---
        if [ -f "$repo_root/.envrc" ]; then
            echo "📄 .envrc をコピーしています..."
            cp "$repo_root/.envrc" "$worktree_dir/.envrc"

            # direnvがインストールされていれば allow する
            if command -v direnv >/dev/null 2>&1; then
                echo "🔓 direnv allow を実行中..."
                direnv allow "$worktree_dir" >/dev/null 2>&1
            fi
        fi
    else
        echo "🌳 ワークツリーは既に存在します: $worktree_dir"
    fi


    # --- ★ Nvim終了後のコマンドを定義 ★ ---
    # (この work 関数を実行しているシェルが Tmux 内かどうかで分岐)

    local nvim_exit_command
    if [ -n "$TMUX" ]; then
        # 【A】既にTmux内にいる場合:
        # Nvim終了後、直前のセッション(-l)に切り替え、その後このセッションを閉じる(exit)
        nvim_exit_command="nvim; tmux switch-client -l; exit"
    else
        # 【B】Tmux外から実行した場合:
        # Nvim終了後、このセッションを閉じる(exit)
        nvim_exit_command="nvim; exit"
    fi


    # --- Tmux セッションの作成 & Nvim起動 ---
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo " sessão 💻 Tmuxセッションを作成し、Nvimを起動中: $session_name"

        # -d: バックグラウンドで起動
        # -s: セッション名を指定
        # -c: 開始ディレクトリを指定
        # $nvim_exit_command: 上で定義した動的なコマンドを実行 (★ 修正点)
        tmux new-session -d -s "$session_name" -c "$worktree_dir" "$nvim_exit_command"

        echo "🚀 Nvimが起動しました。"
    else
        echo "💻 Tmuxセッションは既に存在します: $session_name"
        # (注: 既存セッションにアタッチする際は、Nvim終了後の動作は
        #      そのセッションが起動した時のものに依存します)
    fi

    # --- Tmux へのアタッチ ---
    # (この分岐は、セッションに *入る* 時の動作)
    if [ -n "$TMUX" ]; then
        # 【A】既にTmux内にいる場合 (ネスト防止)
        echo "セッションを切り替えます..."
        tmux switch-client -t "$session_name"
    else
        # 【B】Tmux外から実行した場合
        echo "セッションにアタッチします..."
        tmux attach-session -t "$session_name"
    fi
}

# PRレビュー用の 'review' 関数（堅牢版）
# ghq + fzf でリポジトリに移動
ghq-cd() {
    local selected
    selected=$(ghq list --full-path | fzf \
        --preview '
            dir={}
            if [ -d "$dir/.git" ] || git -C "$dir" rev-parse --git-dir >/dev/null 2>&1; then
                echo "── Branch ──"
                git -C "$dir" branch --color=always -vv 2>/dev/null
                echo ""
                echo "── Log (recent 5) ──"
                git -C "$dir" log --oneline --graph --color=always -5 2>/dev/null
                echo ""
                echo "── Status ──"
                git -C "$dir" status --short 2>/dev/null || echo "(clean)"
            else
                echo "(not a git repository)"
            fi
        ' \
        --preview-window 'right:55%:wrap:+0' \
        --layout reverse \
        --height '80%' \
        --prompt 'ghq> ' \
        --header 'Select a repository to cd into' \
        --bind 'ctrl-/:toggle-preview' \
    )

    if [ -n "$selected" ]; then
        cd "$selected" || return 1
        echo "cd $selected"
    fi
}

# Ctrl+g で ghq-cd を起動
_ghq-cd-widget() {
    ghq-cd
    zle accept-line
}
zle -N _ghq-cd-widget
bindkey '^G' _ghq-cd-widget

review() {
    # 1. 引数（PR番号）が指定されているかチェック
    if [ -z "$1" ]; then
        echo "使用方法: review <pr-number>"
        echo "例: review 123"
        return 1
    fi

    local pr_number="$1"
    # タスク名（セッション名、ディレクトリ名）
    local task_name="pr-${pr_number}"

    # 2. Gitリポジトリのルートディレクトリを取得
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "エラー: Gitリポジトリ内で実行してください。"
        return 1
    fi

    # 3. 変数の設定
    local worktree_dir="${repo_root}/.worktrees/${task_name}"
    local session_name="${task_name}"

    # ★ 修正点: 文字列結合エラーを防ぐため、変数展開を明確にし、フェッチ指定を変数に入れる
    # リモート側: refs/pull/123/head
    # ローカル側: refs/remotes/origin/pr/123
    local fetch_spec="+refs/pull/${pr_number}/head:refs/remotes/origin/pr/${pr_number}"

    # 追跡対象のブランチ名
    local remote_tracking_branch="origin/pr/${pr_number}"

    # --- Git Worktree の作成 ---
    if [ ! -d "$worktree_dir" ]; then
        echo "🚚 PR ${pr_number} をフェッチ中..."

        # ★ 修正点: 定義済みの fetch_spec を使用
        if ! git fetch origin "$fetch_spec"; then
            echo "エラー: PR ${pr_number} のフェッチに失敗しました。"
            echo "コマンド: git fetch origin \"$fetch_spec\""
            return 1
        fi

        echo "🌳 ワークツリーを作成中: $worktree_dir"

        # 新しいローカルブランチを作成してチェックアウト
        if ! git worktree add -b "$task_name" "$worktree_dir" "$remote_tracking_branch"; then
            echo "エラー: ワークツリーの作成に失敗しました。"
            return 1
        fi
    else
        echo "🌳 ワークツリーは既に存在します: $worktree_dir"

        echo "🚚 PR ${pr_number} の最新状態をフェッチ中..."
        # 既存の場合も最新をフェッチ
        if ! git fetch origin "$fetch_spec"; then
            echo "警告: 既存ワークツリーのPRフェッチに失敗しました。"
        fi
    fi

    # --- Nvim終了後のコマンドを定義 ---
    local nvim_exit_command
    if [ -n "$TMUX" ]; then
        # Tmux内にいる場合: 直前のセッションに戻る
        nvim_exit_command="nvim; tmux switch-client -l; exit"
    else
        # Tmux外から実行した場合
        nvim_exit_command="nvim; exit"
    fi

    # --- Tmux セッションの作成 & Nvim起動 ---
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo " sessão 💻 Tmuxセッションを作成し、Nvimを起動中: $session_name"

        # 修正: session_name なども一応ダブルクォートで囲む
        tmux new-session -d -s "$session_name" -c "$worktree_dir" "$nvim_exit_command"

        echo "🚀 Nvimが起動しました。"
    else
        echo "💻 Tmuxセッションは既に存在します: $session_name"
    fi

    # --- Tmux へのアタッチ ---
    # (work関数と全く同じロジック)
    if [ -n "$TMUX" ]; then
        # 既にTmux内にいる場合 (ネスト防止)
        echo "セッションを切り替えます..."
        tmux switch-client -t "$session_name"
    else
        # Tmux外から実行した場合
        echo "セッションにアタッチします..."
        tmux attach-session -t "$session_name"
    fi
}
