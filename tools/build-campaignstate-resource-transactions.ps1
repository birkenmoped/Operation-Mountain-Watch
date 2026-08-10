[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$campaignStateFile = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
$harnessFile = Join-Path $repoRoot 'mission\tests\campaignstate-resource-transactions\src\01-campaignstate-resource-transactions.lua'
$distDir = Join-Path $repoRoot 'mission\tests\campaignstate-resource-transactions\dist'
$outputFile = Join-Path $distDir 'OMW_CampaignState_Resource_Transaction_Test.lua'
$builderVersion = 'CAMPAIGNSTATE-RESOURCE-TRANSACTION-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/campaignstate-storage-multinode-sync'
$baseCommit = '552377a6e2743edf2b884027963007227db84324'

foreach ($file in @($campaignStateFile, $harnessFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required source file not found: $file"
    }
}

$campaignState = Get-Content -LiteralPath $campaignStateFile -Raw -Encoding UTF8
$harness = Get-Content -LiteralPath $harnessFile -Raw -Encoding UTF8

$requiredCampaignMarkers = @(
    'FUEL_JP8',
    'FUEL_AVGAS',
    'TransactionKind',
    'TransactionStatus',
    'function CampaignState.New',
    'function Store:GetResource',
    'function Store:GetFuelSnapshot',
    'function Store:ReserveResource',
    'function Store:MarkLoading',
    'function Store:MarkInTransit',
    'function Store:MarkDelivered',
    'function Store:MarkLost',
    'function Store:Consume',
    'function Store:Cancel',
    'return CampaignState'
)
foreach ($marker in $requiredCampaignMarkers) {
    if (-not $campaignState.Contains($marker)) { throw "CampaignState source is missing required marker: $marker" }
}

$requiredHarnessMarkers = @(
    'CAMPAIGNSTATE-RESOURCE-TRANSACTION-1',
    'TRANSFER_DELIVERY_IDEMPOTENCY_PASS',
    'CONSUMPTION_IDEMPOTENCY_PASS',
    'CANCELLATION_RELEASE_PASS',
    'LOSS_NO_DESTINATION_CREDIT_PASS',
    'RESERVATION_AND_IDENTITY_GUARDS_PASS',
    'oneTimeCredit=true',
    'oneTimeDebit=true',
    'mooseTransport=false',
    'dcsStorageMutation=false'
)
foreach ($marker in $requiredHarnessMarkers) {
    if (-not $harness.Contains($marker)) { throw "Harness is missing required marker: $marker" }
}

$forbiddenPatterns = @(
    'STORAGE\s*:',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    'WAREHOUSE\s*:',
    'SCHEDULER\s*:',
    'timer\.scheduleFunction',
    'world\.',
    '_DATABASE',
    'io\.',
    'lfs\.',
    'os\.'
)
foreach ($pattern in $forbiddenPatterns) {
    if ($campaignState -match $pattern -or $harness -match $pattern) {
        throw "Resource transaction foundation contains forbidden runtime dependency: $pattern"
    }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-campaignstate-resource-transactions.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: CampaignState-only strategic resource reservation/transfer/consumption/loss/idempotency contract. No MOOSE transport and no DCS STORAGE mutation.

"@

$content = $header
$content += "local OMWCampaignState = (function()`n$campaignState`nend)()`n`n"
$content += $harness

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: CAMPAIGNSTATE_RESOURCE_TRANSACTION_CONTRACT"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "FuelResources: FUEL_JP8,FUEL_AVGAS"
Write-Host "CanonicalUnit: kg"
Write-Host "TransferLifecycle: RESERVED,LOADING,IN_TRANSIT,DELIVERED|LOST|CANCELLED"
Write-Host "ConsumptionLifecycle: RESERVED|LOADING,CONSUMED|CANCELLED"
Write-Host "OneTimeDebit: REQUIRED"
Write-Host "OneTimeDestinationCredit: REQUIRED"
Write-Host "Persistence: ABSENT"
Write-Host "MOOSETransport: ABSENT"
Write-Host "DCSStorageMutation: ABSENT"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
