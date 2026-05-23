# =====================functions============================== {{{

# origin/HEAD からデフォルトブランチ名を取得する。
# 取れなければ origin/main, origin/master を順に探し、無ければ非ゼロを返す。
_git_default_branch() {
    local default_branch
    default_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [ -z "$default_branch" ] || [ "$default_branch" = "HEAD" ]; then
        if git show-ref --verify --quiet refs/remotes/origin/main; then
            default_branch="main"
        elif git show-ref --verify --quiet refs/remotes/origin/master; then
            default_branch="master"
        else
            return 1
        fi
    fi
    echo "$default_branch"
}

# 指定した worktree ディレクトリで tmux セッションを作成し、nvim を起動してアタッチする。
# work / review 共通のセッション起動ロジック。
#   $1: セッション名  $2: worktree ディレクトリ
_start_worktree_session() {
    local session_name="$1"
    local worktree_dir="$2"

    # nvim 終了後の挙動（Tmux 内なら直前のセッションへ戻ってから抜ける）
    local nvim_exit_command
    if [ -n "$TMUX" ]; then
        nvim_exit_command="nvim; tmux switch-client -l; exit"
    else
        nvim_exit_command="nvim; exit"
    fi

    # セッションが無ければ作成して nvim を起動
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "💻 Tmuxセッションを作成し、Nvimを起動中: $session_name"
        tmux new-session -d -s "$session_name" -c "$worktree_dir" "$nvim_exit_command"
        echo "🚀 Nvimが起動しました。"
    else
        echo "💻 Tmuxセッションは既に存在します: $session_name"
    fi

    # アタッチ（Tmux 内ならネストを避けて switch-client）
    if [ -n "$TMUX" ]; then
        echo "セッションを切り替えます..."
        tmux switch-client -t "$session_name"
    else
        echo "セッションにアタッチします..."
        tmux attach-session -t "$session_name"
    fi
}

# work <branch-name>: ブランチ用の worktree を作り、その中で tmux+nvim セッションを開く
work() {
    if [ -z "$1" ]; then
        echo "使用方法: work <branch-name>"
        echo "例: work feature/new-login"
        return 1
    fi

    local branch_name="$1"
    local task_name="${branch_name//\//-}"   # / を - に置換（セッション名/パス用）

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "エラー: Gitリポジトリ内で実行してください。"
        return 1
    fi

    local worktree_dir="$repo_root/.worktrees/$task_name"

    if [ ! -d "$worktree_dir" ]; then
        echo "🌳 ワークツリーを作成中: $worktree_dir"

        if git ls-remote --exit-code --heads origin "$branch_name" >/dev/null 2>&1; then
            # リモートブランチがある → 追跡ブランチを作成（既存ローカルがあればフォールバック）
            echo "↪︎ リモートブランチ 'origin/$branch_name' を追跡するブランチを作成します..."
            if ! git worktree add -b "$branch_name" "$worktree_dir" "origin/$branch_name"; then
                echo "↪︎ 既存のローカルブランチ '$branch_name' を使用します..."
                if ! git worktree add "$worktree_dir" "$branch_name"; then
                    echo "エラー: ワークツリーの作成に失敗しました。(E1)"
                    rm -rf "$worktree_dir"
                    return 1
                fi
            fi
        elif git show-ref --verify --quiet "refs/heads/$branch_name"; then
            # ローカルブランチがある
            echo "↪︎ 既存のローカルブランチ '$branch_name' を使用します。"
            if ! git worktree add "$worktree_dir" "$branch_name"; then
                echo "エラー: ワークツリーの作成に失敗しました。(E2)"
                rm -rf "$worktree_dir"
                return 1
            fi
        else
            # どこにも無い → デフォルトブランチから新規作成
            local default_branch
            if ! default_branch=$(_git_default_branch); then
                echo "エラー: デフォルトブランチ (main/master) が見つかりません。"
                return 1
            fi
            echo "↪︎ '$default_branch' から新しいブランチ '$branch_name' を作成します..."
            if ! git worktree add -b "$branch_name" "$worktree_dir" "$default_branch"; then
                echo "エラー: ワークツリーの作成に失敗しました。(E3)"
                rm -rf "$worktree_dir"
                return 1
            fi
        fi

        # .envrc があればコピーして direnv allow
        if [ -f "$repo_root/.envrc" ]; then
            echo "📄 .envrc をコピーしています..."
            cp "$repo_root/.envrc" "$worktree_dir/.envrc"
            if command -v direnv >/dev/null 2>&1; then
                direnv allow "$worktree_dir" >/dev/null 2>&1
            fi
        fi
    else
        echo "🌳 ワークツリーは既に存在します: $worktree_dir"
    fi

    _start_worktree_session "$task_name" "$worktree_dir"
}

# review <pr-number>: PR を fetch して worktree を作り、その中で tmux+nvim セッションを開く
review() {
    if [ -z "$1" ]; then
        echo "使用方法: review <pr-number>"
        echo "例: review 123"
        return 1
    fi

    local pr_number="$1"
    local task_name="pr-${pr_number}"

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "エラー: Gitリポジトリ内で実行してください。"
        return 1
    fi

    local worktree_dir="${repo_root}/.worktrees/${task_name}"
    # リモート refs/pull/<n>/head を origin/pr/<n> として取得する
    local fetch_spec="+refs/pull/${pr_number}/head:refs/remotes/origin/pr/${pr_number}"
    local remote_tracking_branch="origin/pr/${pr_number}"

    if [ ! -d "$worktree_dir" ]; then
        echo "🚚 PR ${pr_number} をフェッチ中..."
        if ! git fetch origin "$fetch_spec"; then
            echo "エラー: PR ${pr_number} のフェッチに失敗しました。"
            return 1
        fi

        echo "🌳 ワークツリーを作成中: $worktree_dir"
        if ! git worktree add -b "$task_name" "$worktree_dir" "$remote_tracking_branch"; then
            echo "エラー: ワークツリーの作成に失敗しました。"
            return 1
        fi
    else
        echo "🌳 ワークツリーは既に存在します: $worktree_dir"
        echo "🚚 PR ${pr_number} の最新状態をフェッチ中..."
        if ! git fetch origin "$fetch_spec"; then
            echo "警告: 既存ワークツリーのPRフェッチに失敗しました。"
        fi
    fi

    _start_worktree_session "$task_name" "$worktree_dir"
}

# デフォルトブランチに切り替えて最新を pull する
gmain() {
    local main_branch
    main_branch=$(_git_default_branch) || main_branch="main"
    git checkout "$main_branch" && git pull origin "$main_branch"
}

# ghq + fzf でリポジトリを選択して cd する
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

# }}}
