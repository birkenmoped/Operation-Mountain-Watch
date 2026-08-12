[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$policyFile = Join-Path $repoRoot 'scripts\logistics\OMW_ForcedLandingRecoveryPolicy.lua'
$observerFile = Join-Path $repoRoot 'scripts\logistics\OMW_ForcedLandingObserver.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\storage-forced-landing-recovery-v1\src\01-forced-landing-recovery-v1-gate.lua'
$distDir = Join-Path $repoRoot 'mission\tests\storage-forced-landing-recovery-v1\dist'
$outputFile = Join-Path $distDir 'OMW_Forced_Landing_Recovery_V1_Gate.lua'
$builderVersion = 'FORCED-LANDING-RECOVERY-V1-GATE-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($policyFile, $observerFile, $harnessFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required source file not found: $file"
    }
}

$policy = Get-Content -LiteralPath $policyFile -Raw -Encoding UTF8
$observer = Get-Content -LiteralPath $observerFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'TrackClientGroup',
    'EVENTS.Land',
    'EVENTS.EngineShutdown',
    'RECOVERABLE_FORCED_LANDING',
    'OFF_FIELD_UNRECOVERABLE',
    'RECOVERY_RADIUS_METERS = 5000',
    'RECOVERY_DURATION_SECONDS = 30 * 60',
    'REPAIR_LOCK_SECONDS = 6 * 60 * 60',
    'CLIENT_RETURN_PARKING_DISTANCE_METERS = 5',
    'AIRBASE:GetParkingSpotsTable()',
    'CLIENT_US_SHND_AH64D_01',
    'RECOVERABLE_RUNTIME_PASS',
    'POLICY_TIMING_PASS',
    'RESULT status=PASS'
)
$combined = $policy + "`n" + $observer + "`n" + $harness
foreach ($marker in $requiredMarkers) {
    if (-not $combined.Contains($marker)) {
        throw "Gate source is missing required marker: $marker"
    }
}

$forbiddenPatterns = @(
    'trigger\.action\.explosion',
    'coalition\.addGroup',
    'unit:destroy\(',
    'SetLiquid\(',
    'AddLiquid\(',
    'RemoveLiquid\(',
    'SetItem\(',
    'AddItem\(',
    'RemoveItem\(',
    'ReturnToLegion\(',
    'MissionScripting\.lua',
    'CSAR:',
    'AICSAR:'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($combined -match $pattern) {
        throw "Forced-landing V1 gate contains forbidden pattern: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-forced-landing-recovery-v1-gate.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: forced-landing/recovery V1 policy plus read-only MOOSE client runtime classification gate.

"@

$content = $header
$content += "OMWForcedLandingRecoveryPolicy = (function()`n$policy`nend)()`n`n"
$content += "OMWForcedLandingObserver = (function()`n$observer`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: FORCED_LANDING_RECOVERY_V1_GATE"
Write-Host "ClientGroup: CLIENT_US_SHND_AH64D_01"
Write-Host "RecoveryNode: Shindand Heliport"
Write-Host "RecoveryRadiusMeters: 5000"
Write-Host "ClientReturnParkingDistanceMeters: 5"
Write-Host "RecoveryDurationSeconds: 1800"
Write-Host "RepairLockSeconds: 21600"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "StorageMutation: ABSENT"
Write-Host "PhysicalMutation: ABSENT"
Write-Host "CSAR: OUT_OF_SCOPE"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
