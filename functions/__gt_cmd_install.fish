function __gt_cmd_install
    if test (count $argv) -eq 0
        echo "Usage: gt install [--all] <branch>"
        return
    end

    set -l all_flag false
    set -l branch ""

    for arg in $argv
        switch $arg
            case --all
                set all_flag true
            case '*'
                set branch $arg
        end
    end

    if test -z "$branch"
        echo "Usage: gt install [--all] <branch>"
        return 1
    end

    if not __gt_util_worktree_check $branch
        echo "Branch '$branch' is not checked out."
        return 1
    end

    cd $GT_WORKTREE_DIR/$branch
    if test $all_flag = true
        echo "Installing full distribution (with sources)..."
        ./gradlew installAll -Pgradle_installPath="build/dist"
    else
        ./gradlew install -Pgradle_installPath="build/dist"
    end
end
