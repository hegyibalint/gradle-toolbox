function __gt_cmd_doctor
    # Re-provision the shared resources (agent docs, .claude config, ...) into
    # every worktree. Idempotent: copies are merged in, nothing is removed.
    set -l worktrees (__gt_util_worktree_paths)

    if test (count $worktrees) -eq 0
        echo "No worktrees to provision."
        return
    end

    echo "Provisioning resources into "(count $worktrees)" worktrees..."
    for wt in $worktrees
        __gt_util_worktree_provision $wt
        echo "  "(string replace "$GT_WORKTREE_DIR/" '' -- $wt)
    end
end
