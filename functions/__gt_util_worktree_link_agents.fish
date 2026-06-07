function __gt_util_worktree_link_agents --argument-names branch_dir
    # Symlink the shared agent docs from $GT_DIR/agents into a worktree's root.
    # Targets are absolute because worktrees live at varying depths under $GT_WORKTREE_DIR.
    set -l agents_dir $GT_DIR/agents

    test -d $agents_dir; or return 0
    test -d $branch_dir; or return 0

    for src in (find $agents_dir -maxdepth 1 -type f)
        set -l dest $branch_dir/(basename $src)
        # Never clobber a real (non-symlink) file that's part of the checkout.
        if test -e $dest; and not test -L $dest
            continue
        end
        ln -sf $src $dest
    end
end
