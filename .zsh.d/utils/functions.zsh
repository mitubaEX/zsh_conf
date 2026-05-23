# =====================functions============================== {{{

# デフォルトブランチに切り替えて最新を pull する
gmain() {
    local main_branch
    main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    if [ -z "$main_branch" ]; then
        main_branch="main"
    fi
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
