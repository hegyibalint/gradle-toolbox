function __gt_util_git_exec
    git -C $GT_REPOSITORY_DIR $argv
    or return
end
