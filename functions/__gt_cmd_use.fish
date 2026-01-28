function __gt_cmd_use
    if test (count $argv) -eq 0
        echo "Usage: gt use <branch>"
        return
    end

    set -l branch $argv[1]
    if not __gt_util_worktree_check $branch
        return 1
    end

    set -l dist_dir $GT_WORKTREE_DIR/$branch/build/dist
    if not test -d $dist_dir
        echo "Distribution for branch '$branch' is not installed. Should I install? [Y/n]"
        read -l install
        if test "$install" = Y
            __gt_cmd_install $branch
        else
            return 1
        end
    end

    # Alias the gradle command to the new distribution
    alias gradle="__gt_cmd_run $branch"
    echo "Gradle is now aliased to the distribution from branch '$branch'"
end
