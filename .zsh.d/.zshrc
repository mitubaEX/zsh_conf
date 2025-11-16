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

        # 指定されたブランチ名でworktreeを作成しようと試みる
        if ! git worktree add "$worktree_dir" "$branch_name" 2>/dev/null; then
            # 失敗した場合 (ブランチが存在しない可能性)
            echo "ブランチ '$branch_name' が見つかりません。"
            # デフォルトブランチ (main or master) を取得
            local default_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
            echo "↪︎ デフォルトブランチ ('$default_branch') から新しいブランチとして作成します..."

            git worktree add -b "$branch_name" "$worktree_dir" "$default_branch"
            if [ $? -ne 0 ]; then
                echo "エラー: ワークツリーの作成に失敗しました。"
                return 1
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

# PRレビュー用の 'review' 関数
review() {
    # 1. 引数（PR番号）が指定されているかチェック
    if [ -z "$1" ]; then
        echo "使用方法: review <pr-number>"
        echo "例: review 123"
        return 1
    fi

    local pr_number="$1"
    # タスク名（セッション名、ディレクトリ名）
    local task_name="pr-$pr_number"

    # 2. Gitリポジトリのルートディレクトリを取得
    local repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -z "$repo_root" ]; then
        echo "エラー: Gitリポジトリ内で実行してください。"
        return 1
    fi

    # 3. 変数の設定
    local worktree_dir="$repo_root/.worktrees/$task_name"
    local session_name="$task_name"

    # GitHub (や多くのGitホスティング) が提供するPRの参照 (ref)
    local pr_refspec="pull/$pr_number/head"
    # フェッチしたブランチをローカルで追跡するための名前
    local remote_tracking_branch="origin/pr/$pr_number"

    # --- Git Worktree の作成 ---
    if [ ! -d "$worktree_dir" ]; then
        echo "🚚 PR $pr_number をフェッチ中..."

        # 'origin' から 'pull/123/head' を 'origin/pr/123' としてフェッチ
        # (フォーク元のリポジトリを意識する必要がないのが利点)
        if ! git fetch origin "$pr_refspec:refs/remotes/$remote_tracking_branch"; then
            echo "エラー: PR $pr_number のフェッチに失敗しました。"
            echo "PR番号が正しいか、リモートリポジトリが 'origin' か確認してください。"
            return 1
        fi

        echo "🌳 ワークツリーを作成中: $worktree_dir"

        # フェッチしたブランチから、新しいローカルブランチ (例: 'pr-123') を作成し、
        # 同時にworktreeをセットアップします。
        if ! git worktree add -b "$task_name" "$worktree_dir" "$remote_tracking_branch"; then
            echo "エラー: ワークツリーの作成に失敗しました。"
            return 1
        fi
    else
        echo "🌳 ワークツリーは既に存在します: $worktree_dir"
        echo "ℹ️  (ヒント: 最新の状態にするにはセッション内で 'git pull' または 'git rebase $remote_tracking_branch' を実行してください)"
    fi

    # --- Nvim終了後のコマンドを定義 ---
    # (work関数と全く同じロジック)
    local nvim_exit_command
    if [ -n "$TMUX" ]; then
        # Tmux内にいる場合: Nvim終了後、直前のセッション(-l)に切り替え、このセッションを閉じる(exit)
        nvim_exit_command="nvim; tmux switch-client -l; exit"
    else
        # Tmux外から実行した場合: Nvim終了後、このセッションを閉じる(exit)
        nvim_exit_command="nvim; exit"
    fi


    # --- Tmux セッションの作成 & Nvim起動 ---
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo " sessão 💻 Tmuxセッションを作成し、Nvimを起動中: $session_name"

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
