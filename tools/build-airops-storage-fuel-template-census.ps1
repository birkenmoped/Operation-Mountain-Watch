[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFile = Join-Path $repoRoot 'mission\tests\airops-storage-fuel-template-census\src\01-airops-storage-fuel-template-census.lua'
$distDir = Join-Path $repoRoot 'mission\tests\airops-storage-fuel-template-census\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Storage_Fuel_Template_Census.lua'
$builderVersion = 'AIROPS-STORAGE-FUEL-TEMPLATE-CENSUS-2'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$baseBranch = 'agent/storage-airwing-weapon-lifecycle'
$baseCommit = '718e2e770f1594b205e429b2b898f73b26352c13'

if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
    throw "Required census source not found: $sourceFile"
}

$source = Get-Content -LiteralPath $sourceFile -Raw -Encoding UTF8

$requiredMarkers = @(
    'AIROPS-STORAGE-FUEL-TEMPLATE-CENSUS-2',
    'local aircraft, liquids, weapons = storage:GetInventory()',
    'STORAGE.Liquid.JETFUEL',
    'AIRWING:NewPayload',
    'AUFTRAG:NewORBIT',
    'mission:AddRequiredPayload(testPayload)',
    'mission:AssignSquadrons({ squadron })',
    'ENUMS.ROE.WeaponHold',
    'ENUMS.ROT.NoReaction',
    'flightGroup:GetFuelMin()',
    'unit:GetCurrentFuelKgs()',
    'flightFuelTelemetry(fg, "LANDED", case.id)',
    'selectReturnFuelReference',
    'logTimeoutDiagnostics',
    'mission:IsSuccess()',
    'ASSIGN_TIMEOUT_S = 600',
    'LIFECYCLE_TIMEOUT_S = 3600',
    'GLOBAL_TIMEOUT_S = 21600',
    'POST_RETURN_OBSERVE_S = 30',
    'parallel_by_storage_lane',
    'partialExpenditure=false',
    'storageMutation=false',
    'campaignStateMutation=false',
    'BGRAM_F15E_CAS',
    'BGRAM_F15E_STRIKE',
    'BGRAM_F16C_CAS',
    'BGRAM_C130_TRANSPORT',
    'BGRAM_HH60G_CSAR',
    'BGRAM_UH60_UTILITY',
    'BGRAM_CH47_TRANSPORT',
    'JBAD_OH58D_RECON',
    'JBAD_AH64D_CAS',
    'JBAD_UH60_MEDEVAC',
    'JBAD_CH47_HEAVYLIFT',
    'KAF_A10C_CAS',
    'KAF_HH60G_CSAR',
    'KAF_C130_TRANSPORT',
    'KAF_MQ1A_RECON',
    'KAF_MQ9_RECON',
    'KAF_AH64D_CAS',
    'KAF_OH58D_RECON',
    'KAF_CH47_TRANSPORT',
    'KAF_UH60_TRANSPORT',
    'KAF_UH60_MEDEVAC',
    'SAL_AH64D_CAS',
    'SAL_OH58D_RECON',
    'SAL_UH60_ASSAULT',
    'SAL_UH60_MEDEVAC',
    'SAL_CH47_TRANSPORT',
    'SHND_AH64D_CAS',
    'SHND_UH60_UTILITY',
    'SHND_CH47_HEAVYLIFT',
    'TKOT_AH64D_CAS',
    'TKOT_UH60_MEDEVAC',
    'TKOT_CH47_HEAVYLIFT',
    'AIROPS STORAGE/FUEL CENSUS COMPLETE'
)

foreach ($marker in $requiredMarkers) {
    if (-not $source.Contains($marker)) {
        throw "Census source is missing required marker: $marker"
    }
}

$caseCount = ([regex]::Matches($source, '\{ id="[A-Z0-9_]+", lane=')).Count
if ($caseCount -ne 32) {
    throw "Expected exactly 32 physical AI template cases, found $caseCount"
}

$forbiddenPatterns = @(
    'trigger\.action\.outText',
    'STORAGE\s*:\s*SetItem',
    'STORAGE\s*:\s*AddItem',
    'STORAGE\s*:\s*RemoveItem',
    'STORAGE\s*:\s*SetLiquid',
    'STORAGE\s*:\s*AddLiquid',
    'STORAGE\s*:\s*RemoveLiquid',
    'CampaignState\s*[\.:]',
    'coalition\.addGroup',
    'SPAWN\s*:',
    'OPSTRANSPORT\s*:',
    'CTLD\s*:',
    '_DATABASE',
    'world\.searchObjects',
    'io\.',
    'lfs\.',
    'os\.',
    'SetTeleport\s*\(',
    'ReturnToLegion\s*\(',
    'FlightGroup:Destroy\s*\(',
    'squadron\.ngrouping',
    'testPayload\.uid'
)

foreach ($pattern in $forbiddenPatterns) {
    if ($source -match $pattern) {
        throw "Census source contains forbidden pattern: $pattern"
    }
}

if ($source -match 'squadron:AddMissionCapability') {
    throw 'Census must not mutate production SQUADRON mission capabilities.'
}
if ($source -match 'AUFTRAG:NewALERT5') {
    throw 'Census must not use ALERT5; current OMW SQUADRON capabilities do not include ALERT5.'
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
    Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-airops-storage-fuel-template-census.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- BaseBranch: $baseBranch
-- BaseCommit: $baseCommit
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256
-- Scope: read-only DCS STORAGE aircraft/JETFUEL/weapons observation for every productive OMW AIROPS physical AI template; native AIRWING return; onboard fuel telemetry.

"@

$content = $header + $source
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "Scope: AIROPS_STORAGE_FUEL_TEMPLATE_CENSUS"
Write-Host "BaseBranch: $baseBranch"
Write-Host "BaseCommit: $baseCommit"
Write-Host "PhysicalAITemplatesExpected: 32"
Write-Host "StorageLanesExpected: 7"
Write-Host "Parallelization: ONE_ACTIVE_CASE_PER_STORAGE_LANE"
Write-Host "MissionType: ORBIT"
Write-Host "ExactTemplatePayload: AIRWING_NEWPAYLOAD_PLUS_REQUIRED_PAYLOAD"
Write-Host "SquadronCapabilityMutation: ABSENT"
Write-Host "Alert5: ABSENT"
Write-Host "AircraftInventoryObservation: REQUIRED"
Write-Host "JetFuelObservation: REQUIRED"
Write-Host "WeaponInventoryObservation: REQUIRED"
Write-Host "OnboardFuelMinPercent: REQUIRED"
Write-Host "OnboardFuelKg: ASSIGNMENT_AND_LANDED_OR_ARRIVED"
Write-Host "PartialExpenditure: NOT_INCLUDED"
Write-Host "StorageMutation: ABSENT"
Write-Host "CampaignStateMutation: ABSENT"
Write-Host "DirectSpawn: ABSENT"
Write-Host "CustomReturnToLegionCall: ABSENT"
Write-Host "OPSTRANSPORT: ABSENT"
Write-Host "CTLD: ABSENT"
Write-Host "AssignmentTimeoutSeconds: 600"
Write-Host "LifecycleTimeoutAfterAssignmentSeconds: 3600"
Write-Host "PostReturnObserveSeconds: 30"
Write-Host "GlobalTimeoutSeconds: 21600"
Write-Host "TimeoutDiagnostics: MISSION_FLIGHT_LANDED_ARRIVED_FUEL"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
