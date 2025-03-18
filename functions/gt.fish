# ============================================================================++
# UTILITY FUNCTIONS
# ============================================================================++

# GIT HELPER FUNCTIONS ---------------------------------------------------------

function __gt_git
    git -C $GT_REPOSITORY_DIR $argv
    or return
end

function __gt_worktree_checked_out
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if test -d $branch_dir
        return 0
    else
        return 1
    end
end

# ============================================================================++
# SUBCOMMANDS
# ============================================================================++

function __gt_update
    echo "Updating repository"
    __gt_git fetch --all
    or return
end

function __gt_checkout
    if test (count $argv) -eq 0
        echo "Usage: gt checkout <branch>"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    __gt_git worktree add $branch_dir $branch
end

function __gt_open
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

function __gt_create
    if test (count $argv) -eq 0
        echo "Usage: gt create <branch>"
        return
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    # Create a worktree for the new branch
    __gt_git worktree add -b $branch $branch_dir master
    or return
end

function __gt_delete
    if test (count $argv) -eq 0
        echo "Usage: gt delete <branch>"
        return
    end

    set -l branch $argv[1]
    # Pop the branch argument off the list
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    echo "Deleting branch '$branch'"
    __gt_git worktree remove $branch_dir
    __gt_git branch -D $branch
end

function __gt_install
    if test (count $argv) -eq 0
        echo "Usage: gt install <branch>"
        return
    end

    if not test -d $GT_DIST_DIR
        mkdir -p $GT_DIST_DIR
    end

    set -l branch $argv[1]
    if not __gt_worktree_checked_out $branch
        echo "Branch '$branch' is not checked out."
        return 1
    end

    set -l branch_dir $GT_WORKTREE_DIR/$branch
    set -l dist_dir $GT_DIST_DIR/$branch

    echo "Installing distribution from branch '$branch' to '$dist_dir'"
    echo ----
    cd $branch_dir
    ./gradlew install -Pgradle_installPath="$dist_dir"
end

function __gt_use
    if test (count $argv) -eq 0
        echo "Usage: gt use <branch>"
        return
    end
    set -l branch $argv[1]

    if not test -d $GT_DIST_DIR/$branch
        read -P "Branch '$branch' is not installed yet. Should be installed now? [Y/n] " -l should_install
        if test -z $should_install; or test $should_install = y
            __gt_install $branch
        else
            return
        end
    end

    # Make the home directory for the branch
    mkdir -p $GT_HOME_DIR/$branch
    # Alias the gradle command to the new distribution
    alias gradle="gt run $branch"
    echo "Gradle is now aliased to the distribution from branch '$branch'"
end

function __gt_run
    if test (count $argv) -eq 0
        echo "Usage: gt run <branch> [args]"
        return
    end
    set -l branch $argv[1]
    set -e argv[1]
    set -l gradle_command "$GT_DIST_DIR/$branch/bin/gradle -Duser.home=$GT_HOME_DIR/$branch $argv"

    set_color magenta
    echo "Running gradle from branch '$branch'"
    echo "Gradle command: $gradle_command"
    set_color normal
    echo ----
    eval $gradle_command
end

function __gt_init
    # If $GT_DIR doesn't exist, create it
    if not test -d $GT_DIR
        mkdir -p $GT_DIR
    end

    # If $GT_DIR/repo doesn't exist, create it
    if not test -d $GT_REPOSITORY_DIR
        mkdir -p $GT_REPOSITORY_DIR
    end
    # Checks if the repo is already initialized
    if __gt_git rev-parse 2>/dev/null
        echo "Repository already initialized"
    else
        git init --bare $GT_DIR/repo
        __gt_git remote add origin git@github.com:gradle/gradle.git
        __gt_git fetch
        echo "Repository initialized"
    end
end

# ============================================================================++
# ENTRY
# ============================================================================++

function gt -d "Gradle toolbox"
    if test (count $argv) -eq 0
        echo "Usage: gt <subcommand> [args]"
        echo "  Initialization:"
        echo "    init      Initialize a new git repository"
        echo "  Repository operations:"
        echo "    update    Update the repository"
        echo "  Branch operations:"
        echo "    create    Create a new branch"
        echo "    checkout  Check out branch"
        echo "    delete    Delete a branch"
        echo "  Development operations:"
        echo "    open      Open a branch in IntelliJ IDEA"
        echo "    install   Install distribution from a branch"
        echo "    use       Use the distribution from a branch"

        return
    end

    # First parameter
    set -l subcommand $argv[1]
    set -e argv[1]

    switch $subcommand
        case init
            __gt_init $argv
        case create
            __gt_create $argv
        case delete
            __gt_delete $argv
        case update
            __gt_update $argv
        case checkout
            __gt_checkout $argv
        case open
            __gt_open $argv
        case install
            __gt_install $argv
        case use
            __gt_use $argv
        case run
            __gt_run $argv
        case '*'
            echo "Unknown command: $subcommand"
    end
end
