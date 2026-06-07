function __gt_util_worktree_provision --argument-names branch_dir
    # Mirror the shared resources from $GT_DIR/resources into a worktree, copying
    # each file to the same relative path. Existing worktree content is never
    # removed (so e.g. nested .claude/worktrees survive) — files are only
    # overwritten. These copies are git-ignored and ephemeral; `gt cleanup cache`
    # nukes and restores them. The resources repo's own .git is skipped.
    set -l resources_dir $GT_DIR/resources

    test -d $resources_dir; or return 0
    test -d $branch_dir; or return 0

    for src in (find $resources_dir -type f -not -path "$resources_dir/.git/*")
        set -l rel (string replace -- "$resources_dir/" '' $src)
        set -l dest "$branch_dir/$rel"
        mkdir -p (dirname "$dest")
        # Drop any existing copy or (possibly dangling) symlink first, so we
        # always write a fresh real file and migrate old symlinks cleanly.
        rm -f "$dest"
        cp $src "$dest"
    end
end
