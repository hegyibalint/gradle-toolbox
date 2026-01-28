function __gt_cmd_pull
    set -l options (fish_opt -s o -l open)
    argparse $options -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Usage: gt pull <pr-number> [--open/-o]"
        return 1
    end

    set -l pr_number $argv[1]
    set -l branch "pull/$pr_number"
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    # Fetch the pull request from GitHub
    echo "Fetching pull request #$pr_number..."
    __gt_util_git_exec fetch origin pull/$pr_number/head:$branch
    or return

    # Create a worktree for the PR branch
    __gt_util_git_exec worktree add $branch_dir $branch
    or return

    echo "Created branch '$branch' at $branch_dir"

    if set -q _flag_open
        idea $branch_dir
    end
end
