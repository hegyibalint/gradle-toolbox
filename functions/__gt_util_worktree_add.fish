function __gt_util_worktree_add
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    __gt_util_git_fetch
    __gt_util_git_exec worktree add $branch_dir $branch
end
