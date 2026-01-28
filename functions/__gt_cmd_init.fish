function __gt_cmd_init
    if test (count $argv) -eq 0
        echo "Usage: gt init <repository-path>"
        return 1
    end

    set -l repo_path $argv[1]

    # Set global variables
    set -Ux GT_REPOSITORY_DIR $repo_path
    set -Ux GT_WORKTREE_DIR $repo_path/worktrees

    # Create worktrees directory if it doesn't exist
    mkdir -p $GT_WORKTREE_DIR

    echo "Gradle toolbox initialized:"
    echo "  Repository: $GT_REPOSITORY_DIR"
    echo "  Worktrees:  $GT_WORKTREE_DIR"
end
