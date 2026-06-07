function __gt_util_worktree_add
    # The single place a worktree is created. Callers handle their own fetch.
    # Usage: __gt_util_worktree_add <branch> <committish> [extra `git worktree add` opts...]
    set -l branch $argv[1]
    set -l committish $argv[2]
    set -l opts $argv[3..]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    __gt_util_git_exec worktree add $opts $branch_dir $committish
    or return

    __gt_util_worktree_link_agents $branch_dir
end
