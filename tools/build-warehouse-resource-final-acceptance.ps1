[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$manifestFile = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsResourceManifest.lua'
$storageObserverFile = Join-Path $repoRoot 'scripts\logistics\OMW_StorageResourceObserver.lua'
$policyFile = Join-Path $repoRoot 'scripts\logistics\OMW_ForcedLandingRecoveryPolicy.lua'
$coordinatorFile = Join-Path $repoRoot 'scripts\logistics\OMW_RecoverySettlementCoordinator.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\warehouse-resource-final-acceptance\src\01-warehouse-resource-final-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\warehouse-resource-final-acceptance\dist'
$outputFile = Join-Path $distDir 'OMW_Warehouse_Resource_Final_Acceptance.lua'

$builderVersion = 'WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-campaignstate-finalization'
$baseCommit = '489f79a621dda8a48862aa0874f8234dd2c2834e'

$files = @(
  $campaignStateFile,
  $manifestFile,
  $storageObserverFile,
  $policyFile,
  $coordinatorFile,
  $harnessFile
)
foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required source file not found: $file"
  }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$manifest = Get-Content -LiteralPath $manifestFile -Raw -Encoding UTF8
$storageObserver = Get-Content -LiteralPath $storageObserverFile -Raw -Encoding UTF8
$policy = Get-Content -LiteralPath $policyFile -Raw -Encoding UTF8
$coordinator = Get-Content -LiteralPath $coordinatorFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
  'function CampaignState.Restore(snapshot)',
  'function Store:CreditResourceOnce(spec)',
  'function Store:BeginAircraftRecovery(spec)',
  'function Store:CompleteAircraftRecovery(entityId, now)',
  'function Store:CompleteAircraftRepair(entityId, now)',
  'function Store:ExportSnapshot()',
  'FUEL_JP8',
  'FUEL_AVGAS',
  'STORAGE:FindByName',
  'GetLiquidAmount',
  'RECOVERABLE_FORCED_LANDING',
  'RECOVERY_DURATION_SECONDS = 30 * 60',
  'REPAIR_LOCK_SECONDS = 6 * 60 * 60',
  'function RecoverySettlementCoordinator:Begin',
  'function RecoverySettlementCoordinator:CompleteRecovery',
  'function RecoverySettlementCoordinator:CompleteRepair',
  'WAREHOUSE-RESOURCE-FINAL-ACCEPTANCE-1',
  'BASELINE_PASS',
  'SETTLEMENT_PASS',
  'RECONCILIATION_SIGNAL_PASS',
  'RESTART_RECONCILIATION_PASS',
  'REPAIR_LOCK_PASS',
  'RESULT status=PASS'
)

$combined = $campaignState + "`n" + $manifest + "`n" + $storageObserver + "`n" + $policy + "`n" + $coordinator + "`n" + $harness
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Final acceptance source is missing required marker: $marker"
  }
}

$forbiddenPatterns = @(
  'SetLiquid\s*\(',
  'AddLiquid\s*\(',
  'RemoveLiquid\s*\(',
  'SetItem\s*\(',
  'AddItem\s*\(',
  'RemoveItem\s*\(',
  'ReturnToLegion\s*\(',
  'coalition\.addGroup',
  'trigger\.action\.explosion',
  'unit:destroy',
  'OPSGROUP\s*:\s*Destroy',
  '_DATABASE',
  'world\.searchObjects',
  'io\.',
  'lfs\.',
  'os\.execute',
  'MissionScripting\.lua'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($coordinator -match $pattern -or $harness -match $pattern) {
    throw "Final acceptance coordinator/harness contains forbidden pattern: $pattern"
  }
}

if ($coordinator -match 'STORAGE:' -or $coordinator -match 'AIRWING:' -or $coordinator -match 'WAREHOUSE:') {
  throw 'Recovery settlement coordinator must remain CampaignState-domain only'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-warehouse-resource-final-acceptance.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: final CampaignState recovery settlement plus read-only MOOSE STORAGE reconciliation and restart-idempotency gate.

"@

$content = $header
$content += "local OMWCampaignState = (function()`n$campaignState`nend)()`n`n"
$content += "local OMWAirOpsResourceManifest = (function()`n$manifest`nend)()`n`n"
$content += "local OMWStorageResourceObserver = (function()`n$storageObserver`nend)()`n`n"
$content += "local OMWForcedLandingRecoveryPolicy = (function()`n$policy`nend)()`n`n"
$content += "local OMWRecoverySettlementCoordinator = (function()`n$coordinator`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: WAREHOUSE_RESOURCE_FINAL_ACCEPTANCE"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "RecoverySettlementCoordinator: PRESENT"
Write-Host "CampaignStateAuthority: PRESENT"
Write-Host "StorageObservation: READ_ONLY"
Write-Host "ReverseOverwrite: ABSENT"
Write-Host "SnapshotRestore: PRESENT"
Write-Host "RestartCreditIdempotency: PRESENT"
Write-Host "FilesystemPersistence: OUT_OF_SCOPE_NO_APPROVED_RUNTIME_PATH"
Write-Host "InheritedForcedLandingRuntimeEvidence: PRESENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
