function __gt_cmd_install
    if test (count $argv) -eq 0
        echo "Usage: gt install <branch>"
        return
    end

    set -l branch $argv[1]
    if not __gt_util_worktree_check $branch
        echo "Branch '$branch' is not checked out."
        return 1
    end

    cd $GT_WORKTREE_DIR/$branch
    ./gradlew install -Pgradle_installPath="build/dist"
end
