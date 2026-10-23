[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'mission\tests\fixed-wing-cas-response\src\acceptance-2-three-flight-joined-departure.lua'
$destination = Join-Path $repoRoot 'mission\tests\fixed-wing-cas-response\dist\OMW_FixedWing_CAS_Response_Acceptance_2.lua'
$builderVersion = 'OMW-FIXED-WING-CAS-RESPONSE-A2-1'
$expectedMooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing acceptance source: $source" }
$sourceText = Get-Content -LiteralPath $source -Raw -Encoding UTF8
foreach ($required in @(
    'COMMANDER:New(', 'AddAirwing(', 'state.commander:AddMission(',
    'AUFTRAG:NewCAS(', 'mission:AssignSquadrons(', 'mission:SetRequiredAssets(1, 1)',
    'SetMissionHoldingCoord(', 'AddConditionPush(', 'OnAfterElementAirborne',
    'MOOSE_FUEL_LOW', 'MOOSE_FUEL_CRITICAL', 'MOOSE_RTB',
    'TWO_SHIP_JOINED', 'C2_PENDING', 'CAS_F16', 'CAS_A10', 'CAS_F15E'
)) {
    if (-not $sourceText.Contains($required)) { throw "Missing MOOSE mechanism: $required" }
}
foreach ($forbidden in @(
    'world.addEventHandler', 'timer.scheduleFunction', 'trigger.action',
    'controller:setTask', 'Controller.setTask', 'SPAWN:New(', ':Teleport(',
    'KnowTarget(', 'SetFuelLowThreshold(', 'SetMissionIngressCoord(',
    'SetMissionEgressCoord(', 'FlightGroup:Refuel(', 'mist.'
)) {
    if ($sourceText.Contains($forbidden)) { throw "Forbidden scenario execution override: $forbidden" }
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($commit)) {
    throw 'Unable to read current Git commit'
}

# The uploaded source mission is an immutable test input. The builder does not mutate it.
$nl = "`r`n"
$header = @(
    '-- AUTO-GENERATED; do not edit directly.',
    "-- BuilderVersion: $builderVersion",
    "-- GitCommit: $commit",
    "-- GeneratedUtc: $([DateTime]::UtcNow.ToString('o'))",
    '-- Test: fixed-wing CAS response acceptance 2, two-ship holding plus three missions',
    '-- Scope: MOOSE C2 mission creation plus passive events/telemetry',
    '-- Exclusions: no MIZ mutation; no route, tanker, fuel, ATC or RTB overrides',
    '-- MooseCommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54',
    "-- MooseSha256: $expectedMooseSha256"
) -join $nl

$targetDir = Split-Path -Parent $destination
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($destination, $header + $nl + $nl + $sourceText, $utf8WithoutBom)

Write-Host ('BuilderVersion: ' + $builderVersion)
Write-Host ('GitCommit: ' + $commit)
Write-Host ('Bundle: ' + $destination)
Get-FileHash -LiteralPath $destination -Algorithm SHA256 | Format-List Algorithm, Hash, Path
