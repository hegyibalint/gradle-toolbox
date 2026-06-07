function __gt_cmd_cleanup_cache
    # Reclaim disk by nuking every git-ignored file in a worktree (build/,
    # .gradle/, .idea/, scratch, ...) and then restoring the shared resources
    # gt provisions. Tracked and untracked-but-not-ignored files are kept, so
    # uncommitted work is never touched. Nested git worktrees are skipped.
    set -l dry_run 0
    set -l branches
    for arg in $argv
        switch $arg
            case --dry-run
                set dry_run 1
            case '*'
                set -a branches $arg
        end
    end

    # Resolve the target worktrees: explicit branches, or every worktree.
    set -l worktrees
    if test (count $branches) -gt 0
        for b in $branches
            set -l d $GT_WORKTREE_DIR/$b
            if test -e $d/.git
                set -a worktrees $d
            else
                echo "Branch '$b' is not checked out."
            end
        end
    else
        set worktrees (__gt_util_worktree_paths)
    end

    if test (count $worktrees) -eq 0
        echo "No worktrees to clean."
        return
    end

    echo "Scanning "(count $worktrees)" worktrees for ignored content..."
    echo
    printf '  %6s  %6s  %s\n' TOTAL SAVED WORKDIR

    set -l removals
    set -l total_all 0
    set -l saved_all 0
    for wt in $worktrees
        # `git clean -dXn` lists every removable ignored entry and SKIPS nested
        # git repos (e.g. agent worktrees), so those survive the sweep. LC_ALL=C
        # keeps the "Would remove " prefix stable for parsing.
        set -l found
        for line in (env LC_ALL=C git -C $wt -c core.quotePath=false clean -dXn)
            set -l p (string replace -r '^Would remove ' '' -- $line)
            test "$p" = "$line"; and continue
            test -z "$p"; and continue
            set -a found $wt/$p
        end

        set -l total_kb (du -sk $wt 2>/dev/null | cut -f1)
        test -z "$total_kb"; and set total_kb 0

        set -l saved_kb 0
        set -l saved_disp -
        if test (count $found) -gt 0
            set saved_kb (du -sck $found 2>/dev/null | tail -1 | cut -f1)
            test -z "$saved_kb"; and set saved_kb 0
            set saved_disp (__gt_util_human_kb $saved_kb)
            set -a removals $found
        end

        set total_all (math $total_all + $total_kb)
        set saved_all (math $saved_all + $saved_kb)

        printf '  %6s  %6s  %s\n' (__gt_util_human_kb $total_kb) $saved_disp (string replace "$GT_WORKTREE_DIR/" '' -- $wt)
    end

    if test (count $removals) -eq 0
        echo
        echo "Nothing to clean."
        return
    end

    set -l saved (__gt_util_human_kb $saved_all)
    set -l total (__gt_util_human_kb $total_all)
    set -l n (count $worktrees)
    set -l noun worktrees
    test $n -eq 1; and set noun worktree

    echo
    if test $dry_run -eq 1
        echo "Would free $saved of $total across $n $noun (dry run)."
        return
    end

    for r in $removals
        rm -rf $r
    end

    # Restore resources (and run any other health checks) via doctor.
    __gt_cmd_doctor

    echo "Freed $saved of $total across $n $noun."
end
