<#
apply-fixes.ps1
Usage (PowerShell):
  - Open PowerShell as Administrator (if needed)
  - cd to the folder containing your cloned repo or pass -RepoPath
  .\apply-fixes.ps1 -RepoPath 'C:\path\to\E-commerce-React'

What this script does:
  - Back up package.json to package.json.bak
  - Replace "node-sass" dependency with "sass"
  - Add "cross-env" to devDependencies
  - Update the "start" script to use cross-env to set NODE_OPTIONS (avoids OpenSSL/webpack errors)
  - Run npm install
  - Optionally prints next steps
#>
param(
  [string]$RepoPath = '.'
)

if (-not (Test-Path $RepoPath)) {
  Write-Error "Repo path not found: $RepoPath"
  exit 1
}

Push-Location $RepoPath
Write-Output "Working in: $(Get-Location)"

if (-not (Test-Path package.json)) {
  Write-Error "No package.json found in $RepoPath"
  Pop-Location
  exit 1
}

# Backup
Copy-Item package.json package.json.bak -Force
Write-Output "Backed up package.json -> package.json.bak"

# Read package.json
$pkgRaw = Get-Content package.json -Raw
$pkg = $pkgRaw | ConvertFrom-Json

# Ensure dependencies section exists
if (-not $pkg.dependencies) { $pkg.dependencies = @{} }
if (-not $pkg.devDependencies) { $pkg.devDependencies = @{} }

# Replace node-sass with sass
if ($pkg.dependencies.'node-sass') {
  Write-Output "Replacing node-sass with sass"
  $pkg.dependencies.PSObject.Properties.Remove('node-sass') | Out-Null
  $pkg.dependencies.sass = '^1.66.1'
} elseif ($pkg.devDependencies.'node-sass') {
  Write-Output "Replacing dev dependency node-sass with sass"
  $pkg.devDependencies.PSObject.Properties.Remove('node-sass') | Out-Null
  $pkg.dependencies.sass = '^1.66.1'
} else {
  Write-Output "node-sass not found; adding sass if missing"
  if (-not $pkg.dependencies.sass) { $pkg.dependencies.sass = '^1.66.1' }
}

# Add cross-env to devDependencies to support cross-platform NODE_OPTIONS
if (-not $pkg.devDependencies.'cross-env') {
  Write-Output "Adding cross-env to devDependencies"
  $pkg.devDependencies.'cross-env' = '^7.0.3'
}

# Update start script to use cross-env so the OpenSSL legacy provider is set for webpack on Node >=17+.
# This is safe: cross-env is a devDependency and works on Windows/macOS/Linux.
if (-not $pkg.scripts) { $pkg.scripts = @{} }

# Preserve existing start if it's already set to react-scripts start; otherwise replace.
$oldStart = $pkg.scripts.start
if ($oldStart -and $oldStart -match 'react-scripts start') {
  Write-Output "Updating existing start script to use cross-env NODE_OPTIONS"
  $pkg.scripts.start = "cross-env NODE_OPTIONS=--openssl-legacy-provider react-scripts start"
} else {
  Write-Output "Setting start script to use cross-env NODE_OPTIONS and react-scripts start"
  $pkg.scripts.start = "cross-env NODE_OPTIONS=--openssl-legacy-provider react-scripts start"
}

# Write package.json back
$pkg | ConvertTo-Json -Depth 10 | Set-Content package.json -Encoding UTF8
Write-Output "Wrote updated package.json"

# Install dependencies
Write-Output "Running npm install... this may take a few minutes"
# Use --no-audit to reduce chatter and --no-fund to avoid prompts
npm install --no-audit --no-fund

Write-Output "npm install finished."

Write-Output "Next steps (run locally):"
Write-Output "  cd $RepoPath"
Write-Output "  npm start"
Write-Output "If you prefer to commit changes automatically, run .\\commit-and-push.ps1 -RepoPath '$RepoPath' -Branch 'improve/run-fixes'"

Pop-Location
