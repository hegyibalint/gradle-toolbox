function __gt_cmd_create
    set -l options (fish_opt -s o -l open)
    argparse $options -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Usage: gt create <branch> [--open/-o]"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    # Create a worktree for the new branch
    __gt_util_git_exec worktree add -b $branch $branch_dir master
    or return

    if set -q _flag_open
        idea $branch_dir
    end
end
