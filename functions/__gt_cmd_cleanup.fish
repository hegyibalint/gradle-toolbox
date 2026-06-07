function __gt_cmd_cleanup
    set -l origin_url (__gt_util_git_exec config --get remote.origin.url)
    set -l slug (string replace -r '^.*github\.com[:/](.+?)(\.git)?$' '$1' -- $origin_url)
    if test -z "$slug"
        echo "Error: could not determine GitHub repo from origin URL '$origin_url'"
        return 1
    end

    # Parallel arrays: branches[i] lives at paths[i]
    set -l branches
    set -l paths
    set -l current_path
    for line in (__gt_util_git_exec worktree list --porcelain)
        if string match -q 'worktree *' -- $line
            set current_path (string replace -r '^worktree ' '' -- $line)
        else if string match -q 'branch *' -- $line
            set -l branch (string replace -r '^branch refs/heads/' '' -- $line)
            if test "$current_path" != "$GT_REPOSITORY_DIR"; and test "$branch" != release
                set -a branches $branch
                set -a paths $current_path
            end
        end
    end

    if test (count $branches) -eq 0
        echo "No worktree branches found."
        return
    end

    echo "Checking "(count $branches)" branch(es) against $slug PRs..."
    echo

    set -l del_branches
    set -l del_paths

    for i in (seq (count $branches))
        set -l branch $branches[$i]
        set -l path $paths[$i]

        if string match -q 'pr-*' -- $branch
            printf "  %-10s %s\n" pulled $branch
            set -a del_branches $branch
            set -a del_paths $path
            continue
        end

        set -l states (gh -R $slug pr list --head $branch --state all --json state -q '.[].state' 2>/dev/null)

        if test (count $states) -eq 0
            printf "  %-10s %s\n" "no PR" $branch
            continue
        end

        set -l has_open 0
        for s in $states
            if test "$s" = OPEN
                set has_open 1
                break
            end
        end

        if test $has_open -eq 1
            printf "  %-10s %s\n" open $branch
        else
            set -l unique_states (printf '%s\n' $states | sort -u)
            set -l label (string lower (string join "," $unique_states))
            printf "  %-10s %s\n" $label $branch
            set -a del_branches $branch
            set -a del_paths $path
        end
    end

    if test (count $del_branches) -eq 0
        echo
        echo "Nothing to clean up."
        return
    end

    echo
    echo "Branches to delete:"
    for b in $del_branches
        echo "  - $b"
    end
    echo

    read -P "Proceed with deletion? [y/N] " confirm
    if test "$confirm" != y -a "$confirm" != Y
        echo "Aborted."
        return
    end

    for i in (seq (count $del_branches))
        set -l b $del_branches[$i]
        set -l p $del_paths[$i]
        echo "Deleting branch '$b'"
        __gt_util_git_exec worktree remove --force $p
        __gt_util_git_exec branch -D $b
    end
end
