function __gt_util_worktree_paths --description 'Print the path of every worktree except the bare repo'
    for line in (__gt_util_git_exec worktree list --porcelain)
        if string match -q 'worktree *' -- $line
            set -l path (string replace -r '^worktree ' '' -- $line)
            if test "$path" != "$GT_REPOSITORY_DIR"
                echo $path
            end
        end
    end
end
