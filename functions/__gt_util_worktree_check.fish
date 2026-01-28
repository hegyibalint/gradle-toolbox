function __gt_util_worktree_check
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if test -d $branch_dir
        return 0
    else
        echo "Branch '$branch' is not checked out. Should I check it out? [Y/n]"
        read -l checkout
        if test "$checkout" = Y
            __gt_util_worktree_add $branch
        else
            return 1
        end
    end
end
