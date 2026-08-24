[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseBuilder = Join-Path $repoRoot 'tools\build-awacs-base.ps1'

if (-not (Test-Path -LiteralPath $baseBuilder -PathType Leaf)) {
  throw "AWACS Base builder not found: $baseBuilder"
}

Write-Warning 'tools/build-awacs-foundation.ps1 is deprecated. Building OMW_AWACS_Base.lua via tools/build-awacs-base.ps1.'
& $baseBuilder
