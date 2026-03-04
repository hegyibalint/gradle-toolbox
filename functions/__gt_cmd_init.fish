function __gt_cmd_init
    if test (count $argv) -ne 1
        echo "Usage: gt init <repository-url|repository-path>"
        return 1
    end

    # Resolve the active XDG data root when init runs.
    set -l xdg_data_home $HOME/.local/share
    if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
        set xdg_data_home $XDG_DATA_HOME
    end

    set -gx GT_DIR $xdg_data_home/gradle-toolbox
    set -l source $argv[1]
    set -l repo_path $GT_DIR/repo

    # If the argument is an existing directory, use it as the repository path.
    # Otherwise treat it as a remote URL and clone a bare repository into $GT_DIR/repo.
    if test -d $source
        set repo_path $source
        if not test -d $repo_path/.git
            echo "Error: Not a git repository: $repo_path"
            return 1
        end
    else
        if test -e $repo_path
            echo "Error: Repository path already exists: $repo_path"
            echo "Hint: remove it or run 'gt init <existing-repository-path>'."
            return 1
        end

        mkdir -p $GT_DIR
        if not git clone --bare $source $repo_path
            echo "Error: Failed to clone bare repository from: $source"
            return 1
        end

        if test (git -C $repo_path rev-parse --is-bare-repository) != true
            echo "Error: Cloned repository is not bare: $repo_path"
            return 1
        end
    end

    # Clear stale universal paths from earlier setups.
    set -eU GT_REPOSITORY_DIR 2>/dev/null
    set -eU GT_WORKTREE_DIR 2>/dev/null

    # Set active paths from the current XDG data directory.
    set -gx GT_REPOSITORY_DIR $repo_path
    set -gx GT_WORKTREE_DIR $GT_DIR/worktrees

    # Create worktrees directory if it doesn't exist.
    mkdir -p $GT_WORKTREE_DIR

    echo "Gradle toolbox initialized:"
    echo "  Data dir:   $GT_DIR"
    echo "  Repository: $GT_REPOSITORY_DIR"
    echo "  Worktrees:  $GT_WORKTREE_DIR"
end
