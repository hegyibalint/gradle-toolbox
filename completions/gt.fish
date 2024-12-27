# Define the subcommands
set -l commands init update checkout install open

# Define the main subcommands
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments init --description "Initialize repository"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments update --description "Update repositories"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments checkout --description "Check out branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments install --description "Install a distribution from a branch"
complete --command gt --no-files --condition "not __fish_seen_subcommand_from $commands" \
    --arguments open --description "Open a branch in IntelliJ IDEA"

# function __gt_list_remote_branches --description "List available branches in gradle-toolbox repository"
#     _gt_git for-each-ref --sort=-committerdate --format='%(refname:short),%(committerdate:short)' refs/remotes | cut -d/ -f2- | while read -l line
#         set parts (string split "," $line)
#         echo -e (printf "%s\t%s" $parts[1] $parts[2])
#     end
# end

function __gt_list_all_branches --description "List all branches in gradle-toolbox repository"
    _gt_git for-each-ref --sort=-committerdate --format='%(refname:short),%(committerdate:short)' refs | cut -d/ -f2- | while read -l line
        set parts (string split "," $line)
        echo -e (printf "%s\t%s" $parts[1] $parts[2])
    end
end

complete --command gt --no-files --condition "__fish_seen_subcommand_from checkout" --arguments "(__gt_list_all_branches)" --keep-order --description "Branch to check out"
complete --command gt --no-files --condition "__fish_seen_subcommand_from install" --arguments "(__gt_list_all_branches)" --keep-order --description "Branch to install"
complete --command gt --no-files --condition "__fish_seen_subcommand_from open" --arguments "(__gt_list_all_branches)" --keep-order --description "Branch to open"
