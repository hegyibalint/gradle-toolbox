function __gt_cmd_create
    set -l options (fish_opt -s o -l open) (fish_opt -s n -l navigate)
    argparse $options -- $argv
    or return

    if test (count $argv) -eq 0
        echo "Usage: gt create <branch> [--open/-o] [--navigate/-n]"
        return 1
    end

    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch

    # Create a worktree for the new branch, based on master
    __gt_util_worktree_add $branch master -b $branch
    or return

    if set -q _flag_open
        idea $branch_dir
    end

    if set -q _flag_navigate
        cd $branch_dir
    end
end
