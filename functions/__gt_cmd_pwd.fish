function __gt_cmd_pwd
    if test (count $argv) -eq 0
        echo "Usage: gt pwd <branch>"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if not test -d $branch_dir
        echo "Branch '$branch' is not checked out."
        return 1
    end

    echo $branch_dir
end
