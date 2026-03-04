# This is the root data directory for the gradle-toolbox.
set -l _gt_data_home $HOME/.local/share
if set -q XDG_DATA_HOME; and test -n "$XDG_DATA_HOME"
    set _gt_data_home $XDG_DATA_HOME
end
set -x GT_DIR $_gt_data_home/gradle-toolbox
set -x GT_REPOSITORY_DIR $GT_DIR/repo
set -x GT_WORKTREE_DIR $GT_DIR/worktrees
