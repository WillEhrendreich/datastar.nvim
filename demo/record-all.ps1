#!/usr/bin/env pwsh
# Record all VHS demo GIFs for datastar.nvim
# Run this from the datastar.nvim repo root in your own terminal

$ErrorActionPreference = "Stop"
$tapes = Get-ChildItem "demo\tapes\*.tape" | Where-Object { $_.Name -ne "test.tape" }

Write-Host "Recording $($tapes.Count) demo GIFs..." -ForegroundColor Cyan

foreach ($tape in $tapes) {
  Write-Host "`n=> Recording $($tape.Name)..." -ForegroundColor Yellow
  vhs $tape.FullName
  if ($LASTEXITCODE -ne 0) {
    Write-Host "   FAILED: $($tape.Name)" -ForegroundColor Red
  } else {
    Write-Host "   Done!" -ForegroundColor Green
  }
}

Write-Host "`nAll recordings complete! GIFs are in demo/" -ForegroundColor Cyan
