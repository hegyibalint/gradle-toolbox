function __gt_cmd_cleanup
    set -l subcommand $argv[1]
    set -e argv[1]

    switch $subcommand
        case cache
            __gt_cmd_cleanup_cache $argv
        case pr
            __gt_cmd_cleanup_pr $argv
        case '*'
            echo "Usage: gt cleanup <subcommand> [args]"
            echo "    cache   Delete ignored files from worktrees, keep uncommitted [--dry-run]"
            echo "    pr      Delete branches whose PRs are closed/merged"
            return 1
    end
end
