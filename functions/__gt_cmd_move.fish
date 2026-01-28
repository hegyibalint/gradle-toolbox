function __gt_cmd_move
    if test (count $argv) -lt 2
        echo "Usage: gt move <old-branch> <new-branch>"
        return 1
    end

    set -l old_branch $argv[1]
    set -l new_branch $argv[2]
    set -l old_dir $GT_WORKTREE_DIR/$old_branch
    set -l new_dir $GT_WORKTREE_DIR/$new_branch

    # Check if old worktree exists
    if not test -d $old_dir
        echo "Error: Branch '$old_branch' worktree not found at $old_dir"
        return 1
    end

    # Check if new worktree already exists
    if test -d $new_dir
        echo "Error: Target directory already exists at $new_dir"
        return 1
    end

    echo "Moving branch '$old_branch' to '$new_branch'"

    # Move the worktree directory (this updates Git's tracking)
    __gt_util_git_exec worktree move $old_dir $new_dir
    or return 1

    # Rename the git branch
    __gt_util_git_exec branch -m $old_branch $new_branch
    or return 1

    echo "Successfully moved branch and worktree to '$new_branch'"
end
