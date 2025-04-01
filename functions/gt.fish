# ==============================================================================
# UTILITY FUNCTIONS
# ==============================================================================

# GIT HELPER FUNCTIONS ---------------------------------------------------------

function __gt_exec_git
    git -C $GT_REPOSITORY_DIR $argv
    or return
end

function __gt_git_update
    __gt_exec_git fetch --all
    or return
end

function __gt_checkout_branch
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    __gt_git_update
    __gt_exec_git worktree add $branch_dir $branch
end

function __gt_is_worktree_checked_out
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if test -d $branch_dir
        return 0
    else
        echo "Branch '$branch' is not checked out. Should I check it out? [Y/n]"
        read -l checkout
        if test "$checkout" = Y
            __gt_checkout_branch $branch
        else
            return 1
        end
    end
end

# ==============================================================================
# SUBCOMMANDS
# ==============================================================================

function __gt_command_git
    __gt_exec_git $argv
    or return
end

function __gt_command_run
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if not test -d $branch_dir
        echo "Branch '$branch' is not checked out."
        return 1
    end

    set -l gradle_executable $branch_dir/build/dist/bin/gradle
    if not test -x $gradle_executable
        echo "Distribution for branch '$branch' is not installed."
        return 1
    end

    set_color yellow
    echo -n "Running gradle from branch "
    set_color --bold
    echo $branch
    set_color normal
    echo ----
    $gradle_executable $argv[2..-1]
end

function __gt_command_update
    __gt_git_update
    or return
end

function __gt_command_checkout
    if test (count $argv) -eq 0
        echo "Usage: gt checkout <branch>"
        return 1
    end

    set -l branch $argv[1]
    __gt_checkout_branch $branch
end

function __gt_command_open
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

function __gt_command_cd
    if test (count $argv) -eq 0
        echo "Usage: gt cd <branch>"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if not test -d $branch_dir
        echo "Branch '$branch' is not checked out."
        return 1
    end

    cd $branch_dir
end

function __gt_command_create
    if test (count $argv) -eq 0
        echo "Usage: gt create <branch>"
        return
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    # Create a worktree for the new branch
    __gt_exec_git worktree add -b $branch $branch_dir master
    or return
end

function __gt_command_delete
    if test (count $argv) -eq 0
        echo "Usage: gt delete <branch>"
        return
    end

    set -l branch $argv[1]
    # Pop the branch argument off the list
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    echo "Deleting branch '$branch'"
    __gt_exec_git worktree remove $branch_dir
    __gt_exec_git branch -D $branch
end

function __gt_command_install
    if test (count $argv) -eq 0
        echo "Usage: gt install <branch>"
        return
    end

    set -l branch $argv[1]
    if not __gt_is_worktree_checked_out $branch
        echo "Branch '$branch' is not checked out."
        return 1
    end

    cd $GT_WORKTREE_DIR/$branch
    ./gradlew install -Pgradle_installPath="build/dist"
end

function __gt_command_use
    if test (count $argv) -eq 0
        echo "Usage: gt use <branch>"
        return
    end

    set -l branch $argv[1]
    if not __gt_is_worktree_checked_out $branch
        return 1
    end

    set -l dist_dir $GT_WORKTREE_DIR/$branch/build/dist
    if not test -d $dist_dir
        echo "Distribution for branch '$branch' is not installed. Should I install? [Y/n]"
        read -l install
        if test "$install" = Y
            __gt_install $branch
        else
            return 1
        end
    end

    # Alias the gradle command to the new distribution
    alias gradle="__gt_command_run $branch"
    echo "Gradle is now aliased to the distribution from branch '$branch'"
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
        echo "    create    Create a new branch"
        echo "    update    Update the repository"
        echo "    checkout  Check out branch"
        echo "    delete    Delete a branch"
        echo "    git       Git command alias for the repository"
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
            __gt_command_init $argv

            # Repository operations
        case create
            __gt_command_create $argv
        case update
            __gt_command_update $argv
        case checkout
            __gt_command_checkout $argv
        case delete
            __gt_command_delete $argv
        case git
            __gt_command_git $argv

            # Development
        case open
            __gt_command_open $argv
        case cd
            __gt_command_cd $argv
        case install
            __gt_command_install $argv
        case use
            __gt_command_use $argv

            # Default
        case '*'
            echo "Unknown command: $subcommand"
    end
end
