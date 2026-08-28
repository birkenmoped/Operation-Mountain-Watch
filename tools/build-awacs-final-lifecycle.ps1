[CmdletBinding()]
param(
  [string]$Acceptance5Miz,
  [string]$FinalMiz
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot

function Get-LowerSha256 {
  param([Parameter(Mandatory=$true)][string]$Path)
  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "File not found for SHA-256: $Path"
  }
  return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Assert-NoUtf8Bom {
  param([Parameter(Mandatory=$true)][string]$Path)
  $bytes = [System.IO.File]::ReadAllBytes($Path)
  if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    throw "Unexpected UTF-8 BOM: $Path"
  }
}

function Get-MizMissionSha256 {
  param([Parameter(Mandatory=$true)][string]$Path)

  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
  try {
    $entry = $zip.Entries | Where-Object { $_.FullName -eq 'mission' } | Select-Object -First 1
    if ($null -eq $entry) {
      throw "MIZ has no internal mission entry: $Path"
    }

    $stream = $entry.Open()
    try {
      $sha = [System.Security.Cryptography.SHA256]::Create()
      try {
        $hash = $sha.ComputeHash($stream)
        return ([System.BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
      }
      finally {
        $sha.Dispose()
      }
    }
    finally {
      $stream.Dispose()
    }
  }
  finally {
    $zip.Dispose()
  }
}

function Write-MizProvenance {
  param(
    [Parameter(Mandatory=$true)][string]$Label,
    [Parameter(Mandatory=$true)][string]$Path
  )

  if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "$Label MIZ not found: $Path"
  }

  Write-Host "$Label`Miz: $Path"
  Write-Host "$Label`MizSHA256: $(Get-LowerSha256 -Path $Path)"
  Write-Host "$Label`InternalMissionSHA256: $(Get-MizMissionSha256 -Path $Path)"
}

Write-Host '=== OMW AWACS FINAL LIFECYCLE BUILD ==='
$branch = (& git -C $repoRoot branch --show-current).Trim()
$head = (& git -C $repoRoot rev-parse HEAD).Trim()
Write-Host "Branch: $branch"
Write-Host "GitCommit: $head"

if ($branch -ne 'agent/awacs-external-lifecycle-foundation') {
  throw "Wrong branch. Expected agent/awacs-external-lifecycle-foundation, got $branch"
}

& (Join-Path $repoRoot 'tools\build-awacs-base.ps1')
& (Join-Path $repoRoot 'tools\build-awacs-acceptance-4.ps1')

$base = Join-Path $repoRoot 'mission\runtime\air-operations\OMW_AWACS_Base.lua'
$acceptance4 = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\dist\OMW_AWACS_Acceptance_4.lua'
$controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_Controller_FullLifecycle_V3.lua'
$moeRelief = Join-Path $repoRoot 'scripts\air-operations\OMW_AWACS_MOE_Relief.lua'
$observer = Join-Path $repoRoot 'mission\tests\awacs-external-lifecycle\src\04-awacs-full-fuel-aar-acceptance.lua'

Assert-NoUtf8Bom -Path $base
Assert-NoUtf8Bom -Path $acceptance4

Write-Host '=== FINAL ARTIFACT HASHES ==='
Write-Host "ControllerSHA256: $(Get-LowerSha256 -Path $controller)"
Write-Host "MoeReliefSHA256: $(Get-LowerSha256 -Path $moeRelief)"
Write-Host "Acceptance4SourceSHA256: $(Get-LowerSha256 -Path $observer)"
Write-Host "BaseBundleSHA256: $(Get-LowerSha256 -Path $base)"
Write-Host "Acceptance4BundleSHA256: $(Get-LowerSha256 -Path $acceptance4)"
Write-Host 'Utf8BomBase: false'
Write-Host 'Utf8BomAcceptance4: false'

if (-not [string]::IsNullOrWhiteSpace($Acceptance5Miz)) {
  Write-Host '=== ACCEPTANCE 5 PROVENANCE ==='
  Write-MizProvenance -Label 'Acceptance5' -Path $Acceptance5Miz
}
else {
  Write-Host 'Acceptance5Provenance: NOT_REQUESTED_NO_PATH'
}

if (-not [string]::IsNullOrWhiteSpace($FinalMiz)) {
  Write-Host '=== FINAL LIFECYCLE MIZ PROVENANCE ==='
  Write-MizProvenance -Label 'FinalLifecycle' -Path $FinalMiz
}
else {
  Write-Host 'FinalLifecycleMizProvenance: NOT_REQUESTED_NO_PATH'
}

Write-Host '=== GIT STATUS ==='
& git -C $repoRoot status --short
Write-Host '=== OMW AWACS FINAL LIFECYCLE BUILD COMPLETE ==='
