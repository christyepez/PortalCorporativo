param(
    [Parameter(Mandatory = $true)][string]$RepoPath,
    [Parameter(Mandatory = $true)][string]$BranchName,
    [Parameter(Mandatory = $true)][string]$CommitMessage
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $RepoPath)) {
    Write-Error "Repo path not found: $RepoPath"
}

Push-Location $RepoPath
try {
    git status
    git diff --check

    $currentBranch = git branch --show-current
    if ($currentBranch -ne $BranchName) {
        git checkout -b $BranchName
    }

    git add .
    git status
    git commit -m $CommitMessage
    git push origin $BranchName
}
finally {
    Pop-Location
}
