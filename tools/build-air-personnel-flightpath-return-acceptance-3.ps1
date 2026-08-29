[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$missionDemandFile = Join-Path $repoRoot 'scripts\campaign\OMW_MissionDemand.lua'
$resourceDemandPolicyFile = Join-Path $repoRoot 'scripts\campaign\OMW_ResourceDemandPolicy.lua'
$acceptance2SourceFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\src\08-air-personnel-resupply-flightpath-return-acceptance-2.lua'
$distDir = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist'
$outputFile = Join-Path $distDir 'OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_3.lua'

$builderVersion = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3-1'
$testId = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'

$files = @(
  $missionDemandFile,
  $resourceDemandPolicyFile,
  $acceptance2SourceFile
)

foreach ($file in $files) {
  if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
    throw "Required Air PERSONNEL FlightPath acceptance-3 input not found: $file"
  }
}

$missionDemand = Get-Content -LiteralPath $missionDemandFile -Raw -Encoding UTF8
$resourceDemandPolicy = Get-Content -LiteralPath $resourceDemandPolicyFile -Raw -Encoding UTF8
$acceptanceSource = Get-Content -LiteralPath $acceptance2SourceFile -Raw -Encoding UTF8

function Replace-ExactlyOnce {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Old,
    [Parameter(Mandatory = $true)][string]$New,
    [Parameter(Mandatory = $true)][string]$Label
  )

  $first = $Text.IndexOf($Old, [System.StringComparison]::Ordinal)
  if ($first -lt 0) {
    throw "Acceptance-3 transform marker not found: $Label"
  }
  $second = $Text.IndexOf($Old, $first + $Old.Length, [System.StringComparison]::Ordinal)
  if ($second -ge 0) {
    throw "Acceptance-3 transform marker occurs more than once: $Label"
  }
  return $Text.Substring(0, $first) + $New + $Text.Substring($first + $Old.Length)
}

# Preserve the accepted Acceptance-2 route implementation unchanged and derive a
# focused Acceptance-3 harness that changes only the settlement proof. Git history
# keeps the runtime-tested Acceptance-2 source immutable at commit 7a37371e....
$acceptanceSource = $acceptanceSource.Replace('AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-2', 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3')
$acceptanceSource = $acceptanceSource.Replace('FLIGHTPATH-002', 'FLIGHTPATH-003')
$acceptanceSource = $acceptanceSource.Replace('__omwPersonnelFlightPathAcceptance2Callbacks', '__omwPersonnelFlightPathAcceptance3Callbacks')
$acceptanceSource = $acceptanceSource.Replace('FLIGHTPATH_2', 'FLIGHTPATH_3')
$acceptanceSource = $acceptanceSource.Replace('local AIR_DEPARTURE_ACCEPTANCE_RADIUS_M = 250', 'local AIR_DELIVERY_ACCEPTANCE_RADIUS_M = 250')

$acceptanceSource = Replace-ExactlyOnce -Text $acceptanceSource -Label 'final-state second-takeoff gate' -Old @'
  if air.takeoffCount < 2 then return end
'@ -New @'
  if air.missionDoneCount ~= 1 then return end
'@

$oldCommitFunction = @'
local function commitDeliveryAtFortressDeparture(flightGroup)
  local air = state.air
  if air.deliveryCommitted then return true end

  local distance = flightGroup:Get2DDistance(air.targetCoordinate)
  if type(distance) ~= "number" or distance > AIR_DEPARTURE_ACCEPTANCE_RADIUS_M then
    fail("AIR_SECOND_TAKEOFF_OUTSIDE_FORTRESS_LZ distanceM=" .. tostring(distance)
      .. " acceptanceRadiusM=" .. tostring(AIR_DEPARTURE_ACCEPTANCE_RADIUS_M))
    return false
  end

  local transaction = state.store:MarkDelivered(AIR_TRANSFER_ID)
  if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "AIR_TRANSFER_DELIVERY_STATUS") then return false end
  state.registry:SetReservationState(AIR_DEMAND_ID, "DELIVERED")
  state.registry:Succeed(AIR_DEMAND_ID, {
    transactionId = AIR_TRANSFER_ID,
    carrierEntityId = AIR_CARRIER_ENTITY_ID,
  })
  air.deliveryCommitted = true
  if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_DELIVERED") then return false end

  log("AIR_DELIVERY_CONFIRMED_ON_DEPARTURE group=" .. tostring(flightGroup:GetName())
    .. " lz=" .. AIR_LZ_ZONE_NAME
    .. " distanceM=" .. string.format("%.1f", distance)
    .. " takeoffCount=" .. tostring(air.takeoffCount)
    .. " quantity=" .. tostring(AIR_TRANSFER_QUANTITY)
    .. " campaignStateStatus=DELIVERED demandStatus=SUCCESS")
  return true
end
'@

$newCommitFunction = @'
local function commitDeliveryOnLandAtMissionDone(flightGroup)
  local air = state.air
  if air.deliveryCommitted then return true end

  local distance = flightGroup:Get2DDistance(air.targetCoordinate)
  if type(distance) ~= "number" or distance > AIR_DELIVERY_ACCEPTANCE_RADIUS_M then
    fail("AIR_LANDAT_MISSION_DONE_OUTSIDE_FORTRESS_LZ distanceM=" .. tostring(distance)
      .. " acceptanceRadiusM=" .. tostring(AIR_DELIVERY_ACCEPTANCE_RADIUS_M))
    return false
  end

  local transaction = state.store:MarkDelivered(AIR_TRANSFER_ID)
  if not expectEqual(transaction.status, state.campaignState.TransactionStatus.DELIVERED, "AIR_TRANSFER_DELIVERY_STATUS") then return false end
  state.registry:SetReservationState(AIR_DEMAND_ID, "DELIVERED")
  state.registry:Succeed(AIR_DEMAND_ID, {
    transactionId = AIR_TRANSFER_ID,
    carrierEntityId = AIR_CARRIER_ENTITY_ID,
  })
  air.deliveryCommitted = true
  if not expectEqual(snapshot(AIR_DESTINATION_NODE).quantity, AIR_FINAL_DESTINATION, "AIR_DESTINATION_DELIVERED") then return false end

  log("AIR_DELIVERY_CONFIRMED_ON_LANDAT_MISSION_DONE group=" .. tostring(flightGroup:GetName())
    .. " lz=" .. AIR_LZ_ZONE_NAME
    .. " distanceM=" .. string.format("%.1f", distance)
    .. " missionDoneCount=" .. tostring(air.missionDoneCount)
    .. " quantity=" .. tostring(AIR_TRANSFER_QUANTITY)
    .. " campaignStateStatus=DELIVERED demandStatus=SUCCESS")
  return true
end
'@

$acceptanceSource = Replace-ExactlyOnce -Text $acceptanceSource -Old $oldCommitFunction -New $newCommitFunction -Label 'delivery settlement function'

$oldTakeoffBranch = @'
    if air.takeoffCount == 2 then
      if not commitDeliveryAtFortressDeparture(self) then return end
      log("AIR_FORTRESS_DEPARTURE_CONFIRMED group=" .. tostring(self:GetName())
        .. " physicalIntermediateLanding=true returnCorridorPending=true")
      return
    end

    log("AIR_ADDITIONAL_TAKEOFF group=" .. tostring(self:GetName())
      .. " takeoffCount=" .. tostring(air.takeoffCount))
'@

$newTakeoffBranch = @'
    log("AIR_ADDITIONAL_TAKEOFF_DIAGNOSTIC group=" .. tostring(self:GetName())
      .. " takeoffCount=" .. tostring(air.takeoffCount)
      .. " deliveryAuthority=LANDAT_MISSION_DONE")
'@

$acceptanceSource = Replace-ExactlyOnce -Text $acceptanceSource -Old $oldTakeoffBranch -New $newTakeoffBranch -Label 'second-takeoff settlement branch'

$oldMissionDone = @'
    air.missionDoneCount = air.missionDoneCount + 1
    if air.deliveryCommitted ~= true then
      air.missionDoneBeforeDelivery = true
      log("AIR_MISSION_DONE_BEFORE_DELIVERY_DIAGNOSTIC group=" .. tostring(self:GetName())
        .. " action=NO_FAILURE physicalDeliveryProof=SECOND_TAKEOFF")
    else
      log("AIR_MISSION_DONE_AFTER_DELIVERY group=" .. tostring(self:GetName()))
    end
'@

$newMissionDone = @'
    air.missionDoneCount = air.missionDoneCount + 1
    if not expectEqual(air.missionDoneCount, 1, "AIR_MISSION_DONE_COUNT") then return end
    if not commitDeliveryOnLandAtMissionDone(self) then return end
    log("AIR_LANDAT_MISSION_DONE_DELIVERY_SETTLED group=" .. tostring(self:GetName())
      .. " physicalReturnPending=true")
'@

$acceptanceSource = Replace-ExactlyOnce -Text $acceptanceSource -Old $oldMissionDone -New $newMissionDone -Label 'MissionDone settlement callback'
$acceptanceSource = $acceptanceSource.Replace('    .. " deliveryProof=SECOND_TAKEOFF_NEAR_LZ"', '    .. " deliveryProof=LANDAT_MISSION_DONE_NEAR_LZ"')

$combined = $missionDemand + $resourceDemandPolicy + $acceptanceSource
$requiredMarkers = @(
  'OMW-MISSION-DEMAND-1',
  'OMW-RESOURCE-DEMAND-POLICY-1',
  'reorderComparison',
  'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3',
  'GROUND_PERSONNEL',
  'GROUND_NODE_JALALABAD',
  'GROUND_NODE_FORTRESS',
  'TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP',
  'SQ_US_JBAD_CH47_HEAVYLIFT',
  'OMW_BLUE_LZ_FORTRESS_01',
  'OMW_FlightPath',
  'PATHLINE:FindByName',
  'AUFTRAG:NewLANDATCOORDINATE',
  'SetMissionEgressCoord',
  'AssignSquadrons({ air.squadron })',
  'OnAfterMissionDone',
  'OnAfterLanded',
  'OnAfterLegionAssetReturned',
  'heading + AIR_RIGHT_OFFSET_HEADING_DELTA_DEG',
  'AIR_DELIVERY_CONFIRMED_ON_LANDAT_MISSION_DONE',
  'LANDAT_MISSION_DONE_NEAR_LZ',
  'leaveMode=NEAREST_OWNER_PATHLINE_WAYPOINT',
  'personnelFloor=80_PERCENT_STRICT_BELOW'
)
foreach ($marker in $requiredMarkers) {
  if (-not $combined.Contains($marker)) {
    throw "Air PERSONNEL FlightPath acceptance-3 sources are missing required marker: $marker"
  }
}

$forbiddenMarkers = @(
  'commitDeliveryAtFortressDeparture',
  'AIR_DELIVERY_CONFIRMED_ON_DEPARTURE',
  'SECOND_TAKEOFF_NEAR_LZ'
)
foreach ($marker in $forbiddenMarkers) {
  if ($acceptanceSource.Contains($marker)) {
    throw "Air PERSONNEL FlightPath acceptance-3 still contains superseded settlement marker: $marker"
  }
}

$forbiddenPatterns = @(
  'MissionScripting\.lua', 'mist\.', '\bMIST\b', '(?<![A-Za-z0-9_])io\.', 'lfs\.',
  'os\.execute', ':Teleport\s*\(', 'world\.addEventHandler', 'timer\.scheduleFunction',
  'OPSTRANSPORT:New', 'AUFTRAG:NewOPSTRANSPORT', 'NewTROOPTRANSPORT', 'AddCargoStorage',
  'SPAWN:', 'OUTBOUND_TIMEOUT', 'RETURN_TIMEOUT'
)
foreach ($pattern in $forbiddenPatterns) {
  if ($acceptanceSource -match $pattern) {
    throw "Air PERSONNEL FlightPath acceptance-3 contains forbidden runtime pattern: $pattern"
  }
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
if (Test-Path -LiteralPath $outputFile -PathType Leaf) {
  Remove-Item -LiteralPath $outputFile -Force
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($commit)) { throw 'Unable to resolve Git HEAD for acceptance-3 build.' }
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$header = @"
-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.
-- Builder: tools/build-air-personnel-flightpath-return-acceptance-3.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- TestId: $testId
-- Scope: Air-only PERSONNEL resupply acceptance using the Acceptance-2 validated route construction, MOOSE LANDATCOORDINATE MissionDone delivery settlement near Fortress, and physical Jalalabad return.
-- MOOSECommit: $mooseCommit
-- MooseLuaSHA256: $mooseSha256
-- StrategicAuthority: existing OMW CampaignState only; GROUND_PERSONNEL is shared and transferable.
-- DeliveryProof: matching MOOSE LANDATCOORDINATE MissionDone while the FLIGHTGROUP is within 250 m of OMW_BLUE_LZ_FORTRESS_01.
-- ReturnProof: physical Jalalabad OnAfterLanded before AIRWING LegionAssetReturned.
-- PhysicalInfantryCargo: false; TROOPTRANSPORT is intentionally excluded from meta-PERSONNEL resupply.
-- No automated MIZ mutation.

"@

function Embed-Module([string]$Name, [string]$Source) {
  return "local $Name = (function()`n$Source`nend)()`n`n"
}

$bundle = $header
$bundle += Embed-Module 'OMW_PERSONNEL_FLIGHTPATH_MISSION_DEMAND' $missionDemand
$bundle += Embed-Module 'OMW_PERSONNEL_FLIGHTPATH_RESOURCE_DEMAND_POLICY' $resourceDemandPolicy
$bundle += $acceptanceSource
[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $($mooseSha256.ToUpperInvariant())"
Write-Host 'Resource: GROUND_PERSONNEL'
Write-Host 'AirOrigin: GROUND_NODE_JALALABAD'
Write-Host 'AirDestination: GROUND_NODE_FORTRESS'
Write-Host 'AirTransferQuantity: 33'
Write-Host 'AirFinalExpected: Jalalabad 447; Fortress 160'
Write-Host 'AirPhysicalMission: MOOSE AUFTRAG LANDATCOORDINATE'
Write-Host 'AirFlightPath: OMW_FlightPath'
Write-Host 'AirFlightPathDirectionalOffsetRightM: 500'
Write-Host 'AirFlightPathRightHeadingDeltaDeg: +90'
Write-Host 'AirLandingDwellSec: 30'
Write-Host 'AirDeliveryProof: matching LANDATCOORDINATE MissionDone near Fortress LZ'
Write-Host 'AirDeliveryAcceptanceRadiusM: 250'
Write-Host 'AirPhysicalReturnProof: Jalalabad OnAfterLanded then LegionAssetReturned'
Write-Host 'AirTravelTimeoutSec: none'
Write-Host 'TROOPTRANSPORT: false'
Write-Host 'PhysicalInfantryCargo: false'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
foreach ($file in $files) {
  $fileHash = (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToUpperInvariant()
  $relative = $file.Substring($repoRoot.Length).TrimStart('\')
  Write-Host "SourceSHA256: $relative = $fileHash"
}
