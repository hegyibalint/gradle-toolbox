function gt -d "Gradle toolbox"
    if test (count $argv) -eq 0
        echo "Usage: gt <subcommand> [args]"
        echo "  Initialization:"
        echo "    init      Initialize a new git repository"
        echo "  Repository operations:"
        echo "    create    Create a new branch [--open/-o]"
        echo "    update    Update the repository"
        echo "    checkout  Check out branch"
        echo "    pull      Fetch and checkout a GitHub PR [--open/-o]"
        echo "    delete    Delete a branch"
        echo "    move      Move/rename a branch and its worktree"
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
            __gt_cmd_init $argv

            # Repository operations
        case create
            __gt_cmd_create $argv
        case update
            __gt_cmd_update $argv
        case checkout
            __gt_cmd_checkout $argv
        case pull
            __gt_cmd_pull $argv
        case delete
            __gt_cmd_delete $argv
        case move
            __gt_cmd_move $argv
        case git
            __gt_cmd_git $argv

            # Development
        case open
            __gt_cmd_open $argv
        case cd
            __gt_cmd_cd $argv
        case install
            __gt_cmd_install $argv
        case use
            __gt_cmd_use $argv

            # Default
        case '*'
            echo "Unknown command: $subcommand"
    end
end
