#!/bin/bash

# Navigate to your repository directory
# cd /path/to/your/repository

# Add all changes to staging
git add .

# Commit changes with a predefined message
git commit -m "Your predefined commit message"

# Check if the current branch has an upstream set
if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} &> /dev/null; then
    # If no upstream is set, push and set the upstream
    git push -u origin $(git branch --show-current)
else
    # If upstream is set, just push
    git push
fi

echo "Git add, commit, and push executed successfully."