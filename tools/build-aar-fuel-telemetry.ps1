[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\src'
$distDir = Join-Path $repoRoot 'mission\tests\aar-fuel-telemetry\dist'
$outputFile = Join-Path $distDir 'OMW_AAR_Fuel_Telemetry.lua'

$builderVersion = 'AAR-FUEL-TELEMETRY-5'
$testId = 'AAR-FUEL-TELEMETRY-5'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$candidateSpawnSpeedKt = 480
$productionTransitRouteSpeedKt = 300

$files = [ordered]@{
  CampaignState = Join-Path $repoRoot 'scripts\campaign\OMW_CampaignState.lua'
  StrategicStock = Join-Path $repoRoot 'scripts\logistics\OMW_AARStrategicStock.lua'
  Initializer = Join-Path $repoRoot 'scripts\logistics\OMW_AirOpsCampaignStateInitializer.lua'
  Adapter = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_CampaignStateAdapter.lua'
  RuntimeIntegration = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_RuntimeIntegration.lua'
  Controller = Join-Path $repoRoot 'scripts\air-operations\OMW_AAR_Controller.lua'
  Harness = Join-Path $sourceDir '01-aar-fuel-telemetry.lua'
}

foreach ($entry in $files.GetEnumerator()) {
  if (-not (Test-Path -LiteralPath $entry.Value -PathType Leaf)) {
    throw "Required AAR fuel-telemetry source not found: $($entry.Value)"
  }
}

& (Join-Path $repoRoot 'tools\validate-aar-production-finalization.ps1')

$content = @{}
foreach ($entry in $files.GetEnumerator()) {
  $content[$entry.Key] = Get-Content -LiteralPath $entry.Value -Raw -Encoding UTF8
}

$requirements = @(
  @{ File = 'RuntimeIntegration'; Marker = 'controller.StartContinuousCoreCoverage()' },
  @{ File = 'Controller'; Marker = 'STANDARD_TRACK_COUNT = 4' },
  @{ File = 'Controller'; Marker = 'RESERVE_TRACK_COUNT = 2' },
  @{ File = 'Controller'; Marker = 'function Controller.GetActive' },
  @{ File = 'Controller'; Marker = 'local TRANSIT_SPEED_KT = 300' },
  @{ File = 'Controller'; Marker = 'spawner:InitSpeedKnots(TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'mission:SetMissionEgressCoord(firEgressCoord, transit.egressFt, TRANSIT_SPEED_KT)' },
  @{ File = 'Controller'; Marker = 'local function cancelToEgress(runtime, reason)' },
  @{ File = 'Harness'; Marker = 'AAR-FUEL-TELEMETRY-1' },
  @{ File = 'Harness'; Marker = 'TRACK_DEPARTURE' },
  @{ File = 'Harness'; Marker = 'FIR_EGRESS' },
  @{ File = 'Harness'; Marker = 'EXTERNAL_HANDOFF' },
  @{ File = 'Harness'; Marker = 'TestForceEgress' },
  @{ File = 'Harness'; Marker = 'fuelLowExcluded=true' },
  @{ File = 'Harness'; Marker = 'unit:GetFuel()' },
  @{ File = 'Harness'; Marker = 'unit:GetCurrentFuelKgs()' },
  @{ File = 'Harness'; Marker = 'Get2DDistance' }
)

foreach ($requirement in $requirements) {
  if (-not $content[$requirement.File].Contains($requirement.Marker)) {
    throw "Missing AAR fuel-telemetry marker in $($requirement.File): $($requirement.Marker)"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua',
  'world\.addEventHandler',
  'timer\.scheduleFunction',
  '_DATABASE',
  'mist\.',
  'MIST',
  'io\.',
  'lfs\.',
  'os\.execute',
  'runtime\.trackCoord\s*=',
  ':SetFuelLowThreshold\(',
  'fuelLowPct\s*='
)

foreach ($entry in $content.GetEnumerator()) {
  if ($entry.Key -eq 'Controller') { continue }
  foreach ($pattern in $forbiddenPatterns) {
    if ($entry.Value -match $pattern) {
      throw "Forbidden pattern in AAR fuel telemetry $($entry.Key): $pattern"
    }
  }
}

function Replace-ExactOnce {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Old,
    [Parameter(Mandatory = $true)][string]$New,
    [Parameter(Mandatory = $true)][string]$Label
  )

  $count = ([regex]::Matches($Text, [regex]::Escape($Old))).Count
  if ($count -ne 1) {
    throw "Expected exactly one '$Label' marker, found $count"
  }
  return $Text.Replace($Old, $New)
}

# Branch-local test candidate only. The production controller source is not modified.
# Candidate 5 deliberately drops the failed optional 60-NM late-approach experiment.
# It preserves the accepted MOOSE FIR ingress/egress contract, applies the already tested
# spawn/LRC/mission-altitude candidates, and exposes one diagnostic-only egress hook that
# delegates to the controller's existing cancelToEgress() lifecycle path.
$controllerCandidate = $content.Controller

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 33000 },' `
  -New '  MANAS_WEST_HIGH = { ingressFt = 34000, egressFt = 35000 },' `
  -Label 'MANAS_WEST_HIGH transit altitude'
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  MANAS_EAST_HIGH = { ingressFt = 33000, egressFt = 34000 },' `
  -New '  MANAS_EAST_HIGH = { ingressFt = 34000, egressFt = 35000 },' `
  -Label 'MANAS_EAST_HIGH transit altitude'
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  AL_UDEID_NORTH_HIGH = { ingressFt = 33000, egressFt = 34000 },' `
  -New '  AL_UDEID_NORTH_HIGH = { ingressFt = 35000, egressFt = 34000 },' `
  -Label 'AL_UDEID_NORTH_HIGH transit altitude'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  spawner:InitSpeedKnots(TRANSIT_SPEED_KT)' `
  -New "  spawner:InitSpeedKnots($candidateSpawnSpeedKt)" `
  -Label 'candidate KC-135 spawn speed'

$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old '  mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)' `
  -New @"
  mission:SetMissionIngressCoord(firIngressCoord, transit.ingressFt, TRANSIT_SPEED_KT)
  mission:SetMissionAltitude(profile.altitudeFt)
"@ -Label 'preserved FIR ingress and exact mission altitude'

$testEgressHook = @'
function Controller.TestForceEgress(area, receiverProfile, reason)
  local station = state.stationsByKey[resolveTrackKey(area, receiverProfile)]
  if not station then return false, "NO_STATION" end
  local runtime = station.activeRuntime
  if not runtime then return false, "NO_ACTIVE_RUNTIME" end
  if runtime.lossHandled then return false, "RUNTIME_LOST" end
  if runtime.handoffComplete then return false, "HANDOFF_COMPLETE" end
  if runtime.egressOrdered then return false, "EGRESS_ALREADY_ORDERED" end
  local ordered = cancelToEgress(runtime, reason or "TEST_FORCE_EGRESS")
  return ordered == true, ordered and "EGRESS_ORDERED" or "EGRESS_NOT_ORDERED"
end

'@
$controllerCandidate = Replace-ExactOnce -Text $controllerCandidate `
  -Old 'function Controller.GetActive(area, receiverProfile)' `
  -New ($testEgressHook + 'function Controller.GetActive(area, receiverProfile)') `
  -Label 'branch-local telemetry egress hook'

$harnessCandidate = Replace-ExactOnce -Text $content.Harness -Old 'AAR-FUEL-TELEMETRY-1' -New $testId -Label 'AAR telemetry test ID'

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-aar-fuel-telemetry.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Gate/Test-ID: $testId
-- Scope: branch-local KC-135 inbound/outbound fuel telemetry for all six AAR tracks.
-- CandidateSpawnSpeedKt: $candidateSpawnSpeedKt
-- ProductionTransitRouteSpeedKt: $productionTransitRouteSpeedKt
-- CandidateTransitLevels: MANAS inbound FL340 / outbound FL350; AL_UDEID inbound FL350 / outbound FL340.
-- CandidateIngressEgressContract: preserve AUFTRAG FIR routing through EGPAN/PINAX/DAVER.
-- CandidateMissionAltitude: AUFTRAG:SetMissionAltitude(track altitude).
-- Optional60NmApproach: disabled; Candidate-4 experiment is not required for fuel calibration.
-- DiagnosticEgressHook: generated bundle only; delegates to existing controller cancelToEgress lifecycle.
-- CandidateScope: generated test bundle only; production controller source, production fuel and FuelLow remain unchanged.
-- FuelLow is intentionally excluded from telemetry because the threshold remains subject to recalibration.
-- No automated MIZ mutation.
-- MOOSE-Commit: $mooseCommit
-- Moose.lua-SHA256: $mooseSha256

"@

$bundle = $header
$bundle += "local OMW_AAR_TEST_CampaignState = (function()`n" + $content.CampaignState + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_StrategicStock = (function()`n" + $content.StrategicStock + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Initializer = (function()`n" + $content.Initializer + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Adapter = (function()`n" + $content.Adapter + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_RuntimeIntegration = (function()`n" + $content.RuntimeIntegration + "`nend)()`n"
$bundle += "local OMW_AAR_TEST_Controller = (function()`n" + $controllerCandidate + "`nend)()`n"
$bundle += $harnessCandidate + "`n"

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host 'FuelPoints: SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF'
Write-Host 'FuelLowIncluded: false'
Write-Host "CandidateSpawnSpeedKt: $candidateSpawnSpeedKt"
Write-Host "ProductionTransitRouteSpeedKt: $productionTransitRouteSpeedKt"
Write-Host 'CandidateManasIngressFt: 34000'
Write-Host 'CandidateManasEgressFt: 35000'
Write-Host 'CandidateAlUdeidIngressFt: 35000'
Write-Host 'CandidateAlUdeidEgressFt: 34000'
Write-Host 'CandidateMissionAltitudeMode: EXACT_TRACK_ALTITUDE'
Write-Host 'CandidateIngressEgressContract: PRESERVED_MOOSE_FIR_ROUTING'
Write-Host 'Optional60NmApproach: DISABLED'
Write-Host 'DiagnosticEgressHook: EXISTING_CONTROLLER_LIFECYCLE'
Write-Host 'CandidateScope: OUTBOUND_FUEL_TELEMETRY'
Write-Host 'StandardTracks: 4'
Write-Host 'ReserveTracks: 2'
Write-Host 'PollSeconds: 1'
Write-Host 'MizMutation: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"

foreach ($entry in $files.GetEnumerator()) {
  $hash = (Get-FileHash -LiteralPath $entry.Value -Algorithm SHA256).Hash.ToLowerInvariant()
  Write-Host "$($entry.Key)SHA256: $hash"
}

$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "BundleSHA256: $bundleHash"
