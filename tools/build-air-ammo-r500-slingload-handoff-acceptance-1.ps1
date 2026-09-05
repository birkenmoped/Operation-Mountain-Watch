[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$corridorFile = Join-Path $repoRoot 'scripts\air-operations\OMW_HelicopterFlightPathCorridor.lua'
$handoffFile = Join-Path $repoRoot 'scripts\air-operations\OMW_SlingloadCorridorHandoff.lua'
$acceptanceFile = Join-Path $repoRoot 'mission\tests\air-ammo-resupply\src\02-air-ammo-r500-slingload-handoff-acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-ammo-resupply\dist'
$outputFile = Join-Path $distDir 'OMW_Air_AMMO_R500_Slingload_Handoff_Acceptance_1.lua'

$builderVersion = 'AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-1'
$testId = 'AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

foreach ($file in @($corridorFile,$handoffFile,$acceptanceFile)) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) { throw "Required isolated R500 acceptance source not found: $file" }
}

$corridorSource = Get-Content -LiteralPath $corridorFile -Raw -Encoding UTF8
$handoffSource = Get-Content -LiteralPath $handoffFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
$combined = $corridorSource + $handoffSource + $acceptanceSource

foreach ($marker in @(
  'OMW-HELICOPTER-FLIGHTPATH-CORRIDOR-8',
  'OMW-SLINGLOAD-CORRIDOR-HANDOFF-3',
  'AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1',
  'ZON_BLUE_LOG_SLG_JALALABAD_01',
  'OMW_BLUE_LZ_WRIGHT_01',
  'OMW_FlightPath_R500',
  'AUFTRAG:NewCARGOTRANSPORT',
  'GetTaskCurrent',
  'GetMissionCurrent',
  'PauseMission',
  'CARGOTRANSPORT_PAUSE_REQUESTED',
  'CARGOTRANSPORT_TASK_STILL_EXECUTING',
  'GetWaypointCurrentUID',
  'AddWaypoint',
  'AddTaskWaypoint',
  'UpdateRoute',
  'CargoTransportation',
  'AUFTRAG:Success()',
  'InitValidateAndRepositionStatic(false)',
  'MAX_HANDOFF_ATTEMPTS = 12'
)) {
  if (-not $combined.Contains($marker)) { throw "Isolated R500 acceptance missing required marker: $marker" }
}

foreach ($marker in @('Controller:setTask','coalition.addGroup','coalition.addStaticObject',':Teleport(','world.addEventHandler','timer.scheduleFunction','MissionScripting.lua','mist.','MIST')) {
  if ($combined.Contains($marker)) { throw "Isolated R500 acceptance exceeds approved boundary: $marker" }
}

function Embed-Module([string]$Name,[string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-ammo-r500-slingload-handoff-acceptance-1.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- Scope: isolated Jalalabad CH-47 physical slingload pickup -> public MOOSE task release -> R500 outbound -> Wright delivery -> R500 reverse -> Jalalabad recovery.
-- StrategicAuthority: none in this isolated physical-route probe.
-- MizMutation: false.

"@

$bundle = $header
$bundle += Embed-Module 'OMW_STAGE3_HELICOPTER_FLIGHTPATH_CORRIDOR' $corridorSource
$bundle += Embed-Module 'OMW_STAGE3_SLINGLOAD_CORRIDOR_HANDOFF' $handoffSource
$bundle += $acceptanceSource

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
[System.IO.File]::WriteAllText($outputFile,$bundle,[System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'Scope: isolated CH-47 R500 slingload handoff only'
Write-Host 'PickupZone: ZON_BLUE_LOG_SLG_JALALABAD_01'
Write-Host 'Route: pickup -> MOOSE PauseMission/TaskDone -> R500 outbound -> Wright -> R500 reverse -> Jalalabad'
Write-Host 'DropZone: OMW_BLUE_LZ_WRIGHT_01'
Write-Host 'FullStage3Required: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
