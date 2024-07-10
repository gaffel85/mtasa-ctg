#!/bin/bash

# Switch to master branch to ensure we have the latest state
git checkout master
git pull origin master

# List all dev-# branches
for dev_branch in $(git branch --list 'dev-*' | sed 's/\*//g'); do
    # Check if the dev_branch has been squashed into master by searching commit messages
    if git log --oneline | grep -q "\[$dev_branch\]"; then
        echo "Branch $dev_branch has been squashed into master."
        # Delete the branch locally
        git branch -d "$dev_branch"
        # Delete the branch on origin
        git push origin --delete "$dev_branch"
        echo "Deleted squashed branch: $dev_branch"
    else
        echo "Branch $dev_branch has not been detected as squashed into master. Skipping."
    fi
done