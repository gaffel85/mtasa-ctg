#!/bin/bash

# Navigate to your repository directory
# cd /path/to/your/repository

# Function to increment the highest dev-# branch number
increment_branch_number() {
    # Get list of branches, filter by 'dev-', sort, and get the last one
    local last_branch=$(git branch --list 'dev-*' | sed 's/.*dev-//g' | sort -n | tail -n 1)
    # If no dev-# branches exist, start with 0
    if [ -z "$last_branch" ]; then
        echo 1
    else
        echo $((last_branch + 1))
    fi
}

# Check current branch name
current_branch=$(git branch --show-current)

# Check if on a 'dev-#' branch, if not, create and switch to a new 'dev-#' branch
if [[ ! $current_branch =~ ^dev-[0-9]+$ ]]; then
    new_branch_number=$(increment_branch_number)
    new_branch_name="dev-$new_branch_number"
    echo "Creating and switching to new branch: $new_branch_name"
    git checkout -b "$new_branch_name"
fi

# Add all changes to staging
git add .

# Commit changes with a predefined message
git commit -m "dev"

# Check if the current branch has an upstream set
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null; then
    # If no upstream is set, push and set the upstream
    git push -u origin $(git branch --show-current)
else
    # If upstream is set, just push
    git push
fi

echo "Git add, commit, and push executed successfully."