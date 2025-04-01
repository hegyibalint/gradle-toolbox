# Define the subcommands
set -l commands init create delete update checkout open install use git cd

# Define the main subcommands
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments init --description "Initialize repository"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments create --description "Creates a new branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments delete --description "Deletes a branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments update --description "Update repositories"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments checkout --description "Check out branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments open --description "Open a branch in IntelliJ IDEA"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments install --description "Install distribution from branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments use --description "Use branch as gradle"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments git --description "Run a git command on the repository"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments cd --description "Change directory to branch worktree"


function __gt_list_checkouted_branches --description "List all checked-out branches in gradle-toolbox repository"
    __gt_exec_git worktree list --porcelain | grep branch | string replace -r '^branch refs/heads/' ''
end

function __gt_list_remote_branches --description "List remote branches in gradle-toolbox repository"
    __gt_exec_git for-each-ref --sort=-committerdate --format='%(refname:short),%(committerdate:short)' refs/remotes/origin | grep "^origin" | string replace -r '^origin/' '' | while read -l line
        set parts (string split "," $line)
        echo -e "$parts[1]\t$parts[2]"
    end
end

# Create sub-command -----------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from create" --keep-order --description "Branch to create"

# Delete sub-command -----------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from delete" --arguments "(__gt_list_checkouted_branches)" --keep-order --description "Branch to delete"

# Checkout sub-command ---------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from checkout" --arguments "(__gt_list_remote_branches)" --keep-order --description "Branch to check out"

# Install sub-command ----------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from install" --arguments "(__gt_list_checkouted_branches)" --keep-order --description "Branch to install"

# Use sub-command --------------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from use" --arguments "(__gt_list_checkouted_branches)" --keep-order --description "Branch to use as `gradle`"

# Open sub-command -------------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from open" --arguments "(__gt_list_checkouted_branches)" --keep-order

# CD sub-command ---------------------------------------------------------------
complete --command gt --no-files --condition "__fish_seen_subcommand_from cd" --arguments "(__gt_list_checkouted_branches)" --keep-order
