function __gt_cmd_checkout
    set -l options (fish_opt -s o -l open)
    argparse $options -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Usage: gt checkout <branch> [--open/-o]"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    __gt_util_worktree_add $branch
    or return

    if set -q _flag_open
        idea $branch_dir
    end
end
