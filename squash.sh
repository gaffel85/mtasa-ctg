#!/bin/bash

# Ensure a commit message was provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 \"commit message\""
    exit 1
fi

commit_message=$1

# Function to find the latest dev-# branch
latest_dev_branch() {
    git branch --list 'dev-*' | sed 's/.*dev-//g' | sort -n | tail -n 1 | awk '{print "dev-"$0}'
}

# Identify the latest dev-# branch
dev_branch=$(latest_dev_branch)

if [ -z "$dev_branch" ]; then
    echo "No dev-# branches found."
    exit 1
fi

echo "Latest dev-# branch is $dev_branch"

# Checkout master branch
git checkout master

# Merge the latest dev-# branch into master with squash option
git merge --squash "$dev_branch"

# If merge was successful, commit with provided message
if [ $? -eq 0 ]; then
    git commit -m "$commit_message [$dev_branch]"
    echo "Merge and commit successful."
else
    echo "Merge failed."
    exit 1
fi