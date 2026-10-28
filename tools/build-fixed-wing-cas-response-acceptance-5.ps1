[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$source = Join-Path $repoRoot 'mission\tests\fixed-wing-cas-response\src\acceptance-5-three-flight-joined-aar-resume.lua'
$destination = Join-Path $repoRoot 'mission\tests\fixed-wing-cas-response\dist\OMW_FixedWing_CAS_Response_Acceptance_5.lua'
$builderVersion = 'OMW-FIXED-WING-CAS-RESPONSE-A5-5'
$expectedMooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'

if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw "Missing acceptance source: $source" }
$sourceText = Get-Content -LiteralPath $source -Raw -Encoding UTF8
$modules = [ordered]@{
    OMW_FixedWingCasFuelPolicy = 'scripts/air-operations/OMW_FixedWingCasFuelPolicy.lua'
    OMW_FixedWingCasProfiles = 'scripts/air-operations/OMW_FixedWingCasProfiles.lua'
    OMW_FixedWingCasRecovery = 'scripts/air-operations/OMW_FixedWingCasRecovery.lua'
}
$moduleBlocks = @()
$allSourceText = $sourceText
foreach ($entry in $modules.GetEnumerator()) {
    $path = Join-Path $repoRoot $entry.Value
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing shared module: $path" }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $moduleBlocks += ('local ' + $entry.Key + ' = (function()' + "`n" + $text + "`nend)()")
    $allSourceText += "`n" + $text
}
foreach ($required in @(
    'COMMANDER:New(', 'AddAirwing(', 'state.commander:AddMission(',
    'AUFTRAG:NewCAS(', 'mission:AssignSquadrons(', 'mission:SetRequiredAssets(1, 1)',
    'SetMissionHoldingCoord(', 'AddConditionPush(', 'OnAfterElementAirborne',
    'TWO_SHIP_JOINED', 'CAS_F16', 'CAS_A10', 'CAS_F15E',
    'flight:SetDefaultAltitude(', 'flight:SetDefaultSpeed(', 'mission:SetProhibitAfterburner()',
    'mission:SetMissionSpeed(', 'Recovery.Bind(', 'FuelPolicy.New(', 'Profiles.Departure(',
    'ELEMENT_FUEL_OBSERVER', 'altitudeAglFt=', 'fuelKg=', 'everAirborneCount=',
    'mission.missionHoldingCoord = nil', 'if record.joinedAt then return true end',
    'flight.flaghold:Is(1)', 'flight.isHoldingAtHoldingPoint == false',
    'CONTROLLABLE.TaskOrbit = function(', 'originalTaskOrbit(controllable, coord, altitude, speed, track.endCoord)'
)) {
    if (-not $sourceText.Contains($required)) { throw "Missing observer/composition mechanism: $required" }
}
foreach ($required in @(
    'RECOVERY_BUDGET', 'ELEMENT_RECOVERY_BUDGET', 'MOOSE_RTB_REQUESTED', 'MOOSE_RTB',
    'RECOVERY_AAR_CURRBASE_RESET', 'f.currbase = nil', 'CAS_RESTART_REJECTED',
    'EXACT_ASSET_RETURNED', 'SAFETY_FAIL_STOP', 'referenceFractionPerS',
    'KRUSTY', 'GetStation(', 'nextPlannedHandoverAt', 'reserveS = 45 * 60'
)) {
    if (-not $allSourceText.Contains($required)) { throw "Missing shared recovery mechanism: $required" }
}
foreach ($removed in @('finalRtbAtS', 'AAR_BLOCKED_FINAL_RTB', 'NO_ELIGIBLE_ACTIVE_TANKER_CLOSER_THAN_HOME', 'A10_PRE_AO_AAR_TRIGGER_PCT', 'RACETRACK_ANGLES_DEG')) {
    if ($allSourceText.Contains($removed)) { throw "Rejected A5-4 policy remains: $removed" }
}
if (($allSourceText.Split([string[]]@('f.currbase = nil'), [System.StringSplitOptions]::None).Length - 1) -ne 1) { throw 'Approved recovery currbase reset must occur exactly once' }
if (($sourceText.Split([string[]]@('mission.missionHoldingCoord = nil'), [System.StringSplitOptions]::None).Length - 1) -ne 1) { throw 'Approved internal holding clear must occur exactly once' }
if (($sourceText.Split([string[]]@('CONTROLLABLE.TaskOrbit = function('), [System.StringSplitOptions]::None).Length - 1) -ne 1) { throw 'Racetrack constructor adapter must be unique' }
if ($sourceText.Contains('flight.flaghold:Set(')) { throw 'OMW may not directly signal MOOSE hold release' }
foreach ($forbidden in @(
    'world.addEventHandler', 'timer.scheduleFunction', 'trigger.action',
    'controller:setTask', 'Controller.setTask', 'SPAWN:New(', ':Teleport(',
    'KnowTarget(', 'SetMissionIngressCoord(',
    'SetMissionEgressCoord(', 'FlightGroup:Refuel(', 'mist.'
)) {
    if ($allSourceText.Contains($forbidden)) { throw "Forbidden scenario execution override: $forbidden" }
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
    '-- Test: fixed-wing CAS response acceptance 5, sticky two-ship join, one-shot holding and AAR resume',
    '-- Scope: shared receiver fuel/recovery policy, native MOOSE flight execution and observer telemetry',
    '-- Exceptions: scoped departure holding/TaskOrbit and guarded post-recovery-AAR currbase reset only',
    '-- MooseCommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54',
    "-- MooseSha256: $expectedMooseSha256"
) -join $nl

$targetDir = Split-Path -Parent $destination
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($destination, $header + $nl + $nl + ($moduleBlocks -join ($nl + $nl)) + $nl + $nl + $sourceText, $utf8WithoutBom)

Write-Host ('BuilderVersion: ' + $builderVersion)
Write-Host ('GitCommit: ' + $commit)
Write-Host ('Bundle: ' + $destination)
Get-FileHash -LiteralPath $destination -Algorithm SHA256 | Format-List Algorithm, Hash, Path

