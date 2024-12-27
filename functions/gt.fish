# ============================================================================++
# UTILITY FUNCTIONS
# ============================================================================++

# GIT HELPER FUNCTIONS ---------------------------------------------------------

function _gt_git
    git -C $GT_REPOSITORY_DIR $argv
end

function _gt_update
    echo "Updating repository"
    _gt_git fetch origin
end

function _gt_checkout
    if test (count $argv) -eq 0
        echo "Usage: gt checkout <branch>"
        return
    end

    set branch $argv[1]
    set branch_dir $GT_WORKTREE_DIR/$branch
    if _gt_git worktree list | grep -q $branch_dir
        echo "Branch '$branch' is already checked out, updating in ff-mode"
        _gt_git update-ref refs/heads/$branch refs/remotes/origin/$branch
        return 1
    else
        echo "Checking out '$branch'"
        _gt_git worktree add $branch_dir $branch
        _gt_git worktree list
    end
end

# ============================================================================++
# SUBCOMMANDS
# ============================================================================++

function _gt_open
    if test (count $argv) -eq 0
        echo "Usage: gt open <branch>"
        return
    end

    set branch $argv[1]
    set branch_dir $GT_WORKTREE_DIR/$branch
    _gt_checkout $branch
    idea $branch_dir
end

function _gt_install
    if test (count $argv) -eq 0
        echo "Usage: gt install <branch>"
        return
    end

    if not test -d $GT_DISTS_DIR
        mkdir -p $GT_DISTS_DIR
    end

    set branch $argv[1]
    set branch_dir $GT_WORKTREE_DIR/$branch
    set dist_dir $GT_DISTS_DIR/$branch

    _gt_checkout $branchs
    echo "Installing distribution from branch '$branch' to '$dist_dir'"
    echo ----
    cd $branch_dir
    ./gradlew install -Pgradle_installPath="$dist_dir"
end

function _gt_init -d "Initializes gradle-toolbox"
    # If $GT_DIR doesn't exist, create it
    if not test -d $GT_DIR
        mkdir -p $GT_DIR
    end

    # If $GT_DIR/repo doesn't exist, create it
    if not test -d $GT_REPOSITORY_DIR
        mkdir -p $GT_REPOSITORY_DIR
    end
    # Checks if the repo is already initialized
    if _gt_git rev-parse 2>/dev/null
        echo "Repository already initialized"
    else
        git init --bare $GT_DIR/repo
        _gt_git remote add origin git@github.com:gradle/gradle.git
        _gt_git fetch
        echo "Repository initialized"
    end
end

# ============================================================================++
# ENTRY
# ============================================================================++

function gt
    if test (count $argv) -eq 0
        echo "Usage: gt <subcommand> [args]"
        echo "Subcommands:"
        echo "  init      Initialize a new git repository"
        echo "  checkout  Checkout a branch"
        return
    end

    # First parameter
    set subcommand $argv[1]
    set -e argv[1]

    switch $subcommand
        case init
            _gt_init $argv
        case update
            _gt_update $argv
        case checkout
            _gt_checkout $argv
        case install
            _gt_install $argv
        case open
            _gt_open $argv
        case git
            _gt_git $argv
        case '*'
            echo "Unknown command: $subcommand"
    end
end
