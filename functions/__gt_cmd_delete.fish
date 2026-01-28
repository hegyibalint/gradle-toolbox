function __gt_cmd_delete
    if test (count $argv) -eq 0
        echo "Usage: gt delete <branch>"
        return
    end

    set -l branch $argv[1]
    # Pop the branch argument off the list
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    echo "Deleting branch '$branch'"
    __gt_util_git_exec worktree remove $branch_dir
    __gt_util_git_exec branch -D $branch
end
