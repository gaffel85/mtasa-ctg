# Navigate to the repository directory
# Set-Location -Path "C:\Path\To\Your\Repo"

# Fetch all remote branches
git fetch --all

# Get the list of all branches and trim whitespace
$branches = git branch -r | ForEach-Object { $_.Trim() }

# Filter branches to find those that match 'origin/dev-#' where # is a number
$devBranches = $branches | Where-Object { $_ -match 'origin/dev-\d+$' }

# Extract the numeric part and find the branch with the highest number
$highestBranch = $devBranches | ForEach-Object { 
    if ($_ -match 'origin/dev-(\d+)$') {
        [PSCustomObject]@{ 
            Branch = $_; 
            Number = [int]$matches[1] 
        }
    }
} | Sort-Object -Property Number -Descending | Select-Object -First 1

if ($highestBranch) {
    $branchName = $highestBranch.Branch -replace 'origin/', ''

    # Get the current branch
    $currentBranch = (git symbolic-ref --short HEAD).Trim()

    # Check if the current branch is the highest dev branch
    if ($currentBranch -ne $branchName) {
        # Checkout to the highest dev branch
        git checkout $branchName
    }

    # Pull the latest changes
    git pull origin $branchName
} else {
    Write-Output "No dev-# branches found."
}
