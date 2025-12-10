<#
commit-and-push.ps1
Usage:
  .\commit-and-push.ps1 -RepoPath 'C:\path\to\repo' -Branch 'improve/run-fixes' -Message 'your commit message'

What it does:
  - Creates branch if missing
  - Commits all changes
  - Pushes to origin

Note: Git must be installed and you must have permission to push to the remote.
#>
param(
  [string]$RepoPath = '.',
  [string]$Branch = 'improve/run-fixes',
  [string]$Message = "chore(run): apply local run fixes (sass, cross-env)"
)

if (-not (Test-Path $RepoPath)) { Write-Error "Repo not found: $RepoPath"; exit 1 }
Push-Location $RepoPath

if (-not (Test-Path .git)) {
  Write-Output "Initializing git repository"
  git init
}

# add remote if missing
$remote = git remote get-url origin 2>$null
if (-not $remote) {
  Write-Output "No origin remote found. Please set remote URL or add 'origin' manually."
  Pop-Location
  exit 1
}

# create and switch branch
git fetch origin 2>$null
if ((git branch --list $Branch) -eq '') {
  git checkout -b $Branch
} else {
  git checkout $Branch
}

git add .
git commit -m "$Message" || Write-Output "No changes to commit or commit failed"

git push -u origin $Branch

Pop-Location
