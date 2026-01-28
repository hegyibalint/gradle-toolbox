function __gt_cmd_open
    if test (count $argv) -eq 0
        echo "Usage: gt open <branch>"
        echo "  create    Create a new branch"
        echo "  update    Update the repository"
        echo "  open      Open a branch in IntelliJ IDEA"
        echo "  install   Install distribution from a branch"
        return
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    idea $branch_dir
end
