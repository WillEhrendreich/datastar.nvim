#!/usr/bin/env pwsh
# Bump the patch version of datastar.nvim, commit, and tag
# Usage: .\scripts\bump-version.ps1 [major|minor|patch]
#   Defaults to "patch" if no argument given

param(
  [ValidateSet("major", "minor", "patch")]
  [string]$Part = "patch"
)

$initFile = Join-Path $PSScriptRoot "..\lua\datastar\init.lua"
$content = Get-Content $initFile -Raw

if ($content -match 'M\.version\s*=\s*"(\d+)\.(\d+)\.(\d+)"') {
  $major = [int]$Matches[1]
  $minor = [int]$Matches[2]
  $patch = [int]$Matches[3]

  switch ($Part) {
    "major" { $major++; $minor = 0; $patch = 0 }
    "minor" { $minor++; $patch = 0 }
    "patch" { $patch++ }
  }

  $newVersion = "$major.$minor.$patch"
  $content = $content -replace 'M\.version\s*=\s*"\d+\.\d+\.\d+"', "M.version = `"$newVersion`""
  Set-Content $initFile $content -NoNewline

  Write-Host "Bumped to v$newVersion" -ForegroundColor Green

  git add $initFile
  git commit -m "chore: bump version to v$newVersion`n`nCo-authored-by: Copilot <223556219+Copilot@users.noreply.github.com>"
  git tag -a "v$newVersion" -m "v$newVersion"

  Write-Host "Tagged v$newVersion - run 'git push && git push --tags' to publish" -ForegroundColor Cyan
} else {
  Write-Error "Could not find M.version in init.lua"
}
