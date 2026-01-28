function __gt_cmd_run
    set -l branch $argv[1]
    set -l branch_dir $GT_WORKTREE_DIR/$branch
    if not test -d $branch_dir
        echo "Branch '$branch' is not checked out."
        return 1
    end

    set -l gradle_executable $branch_dir/build/dist/bin/gradle
    if not test -x $gradle_executable
        echo "Distribution for branch '$branch' is not installed."
        return 1
    end

    set_color yellow
    echo -n "Running gradle from branch "
    set_color --bold
    echo $branch
    set_color normal
    echo ----
    $gradle_executable $argv[2..-1]
end
