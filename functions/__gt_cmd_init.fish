function __gt_cmd_init
    if test (count $argv) -gt 1
        echo "Usage: gt init [repository-path]"
        return 1
    end

    # Resolve the active XDG data root when init runs.
    set -l xdg_data_home $HOME/.local/share
    if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
        set xdg_data_home $XDG_DATA_HOME
    end

    set -gx GT_DIR $xdg_data_home/gradle-toolbox
    set -l repo_path $GT_DIR/repo
    if test (count $argv) -eq 1
        set repo_path $argv[1]
    end

    # Clear stale universal paths from earlier setups.
    set -eU GT_REPOSITORY_DIR 2>/dev/null
    set -eU GT_WORKTREE_DIR 2>/dev/null

    # Set active paths from the current XDG data directory.
    set -gx GT_REPOSITORY_DIR $repo_path
    set -gx GT_WORKTREE_DIR $GT_DIR/worktrees

    # Create worktrees directory if it doesn't exist
    mkdir -p $GT_WORKTREE_DIR

    echo "Gradle toolbox initialized:"
    echo "  Data dir:   $GT_DIR"
    echo "  Repository: $GT_REPOSITORY_DIR"
    echo "  Worktrees:  $GT_WORKTREE_DIR"
end
