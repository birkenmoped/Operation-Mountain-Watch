[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$builder3 = Join-Path $repoRoot 'tools\build-air-personnel-flightpath-return-acceptance-3.ps1'
$inputFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist\OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_3.lua'
$outputFile = Join-Path $repoRoot 'mission\tests\ground-resupply-execution\dist\OMW_Air_PERSONNEL_FlightPath_Return_Acceptance_4.lua'
$builderVersion = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4-1'
$testId = 'AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4'

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $builder3 | Out-Null
if (-not (Test-Path -LiteralPath $inputFile -PathType Leaf)) { throw "Acceptance-3 bundle not found: $inputFile" }

$text = Get-Content -LiteralPath $inputFile -Raw -Encoding UTF8

function Replace-ExactlyOnce {
  param([string]$Text,[string]$Old,[string]$New,[string]$Label)
  $first = $Text.IndexOf($Old,[System.StringComparison]::Ordinal)
  if ($first -lt 0) { throw "Acceptance-4 transform marker not found: $Label" }
  $second = $Text.IndexOf($Old,$first + $Old.Length,[System.StringComparison]::Ordinal)
  if ($second -ge 0) { throw "Acceptance-4 transform marker occurs more than once: $Label" }
  return $Text.Substring(0,$first) + $New + $Text.Substring($first + $Old.Length)
}

$text = $text.Replace('AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3','AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-4')
$text = $text.Replace('FLIGHTPATH-003','FLIGHTPATH-004')
$text = $text.Replace('__omwPersonnelFlightPathAcceptance3Callbacks','__omwPersonnelFlightPathAcceptance4Callbacks')
$text = $text.Replace('FLIGHTPATH_3','FLIGHTPATH_4')
$text = $text.Replace('LANDAT_MISSION_DONE_NEAR_LZ','LANDAT_TASK_DONE_NEAR_LZ')
$text = $text.Replace('deliveryAuthority=LANDAT_MISSION_DONE','deliveryAuthority=LANDAT_TASK_DONE')
$text = $text.Replace('commitDeliveryOnLandAtMissionDone','commitDeliveryOnLandAtTaskDone')
$text = $text.Replace('AIR_LANDAT_MISSION_DONE_OUTSIDE_FORTRESS_LZ','AIR_LANDAT_TASK_DONE_OUTSIDE_FORTRESS_LZ')
$text = $text.Replace('AIR_DELIVERY_CONFIRMED_ON_LANDAT_MISSION_DONE','AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE')
$text = $text.Replace('missionDoneCount=" .. tostring(air.missionDoneCount)','landTaskDoneCount=" .. tostring(air.landTaskDoneCount)')

$text = Replace-ExactlyOnce -Text $text -Label 'state landTaskDoneCount' -Old @'
    missionDoneCount = 0,
'@ -New @'
    missionDoneCount = 0,
    landTaskDoneCount = 0,
'@

$text = Replace-ExactlyOnce -Text $text -Label 'final missionDone gate' -Old @'
  if air.missionDoneCount ~= 1 then return end
'@ -New @'
  if air.landTaskDoneCount ~= 1 then return end
'@

$oldMissionDone = @'
  local previousMissionDone = flightGroup.OnAfterMissionDone
  flightGroup.OnAfterMissionDone = function(self, From, Event, To, Mission)
    if previousMissionDone then previousMissionDone(self, From, Event, To, Mission) end
    if state.failed or Mission ~= air.mission then return end
    air.missionDoneCount = air.missionDoneCount + 1
    if not expectEqual(air.missionDoneCount, 1, "AIR_MISSION_DONE_COUNT") then return end
    if not commitDeliveryOnLandAtTaskDone(self) then return end
    log("AIR_LANDAT_MISSION_DONE_DELIVERY_SETTLED group=" .. tostring(self:GetName())
      .. " physicalReturnPending=true")
  end
'@

$newCallbacks = @'
  local previousTaskDone = flightGroup.OnAfterTaskDone
  flightGroup.OnAfterTaskDone = function(self, From, Event, To, Task)
    if previousTaskDone then previousTaskDone(self, From, Event, To, Task) end
    if state.failed or self ~= air.flightGroup or not Task then return end
    local missionTask = air.mission:GetGroupWaypointTask(self)
    if not missionTask or Task.id ~= missionTask.id then return end
    air.landTaskDoneCount = air.landTaskDoneCount + 1
    if not expectEqual(air.landTaskDoneCount, 1, "AIR_LANDAT_TASK_DONE_COUNT") then return end
    if not commitDeliveryOnLandAtTaskDone(self) then return end
    log("AIR_LANDAT_TASK_DONE_DELIVERY_SETTLED group=" .. tostring(self:GetName())
      .. " physicalReturnPending=true")
  end

  local previousMissionDone = flightGroup.OnAfterMissionDone
  flightGroup.OnAfterMissionDone = function(self, From, Event, To, Mission)
    if previousMissionDone then previousMissionDone(self, From, Event, To, Mission) end
    if state.failed or Mission ~= air.mission then return end
    air.missionDoneCount = air.missionDoneCount + 1
    log("AIR_MISSION_DONE_DIAGNOSTIC group=" .. tostring(self:GetName())
      .. " deliveryCommitted=" .. tostring(air.deliveryCommitted))
  end
'@

$text = Replace-ExactlyOnce -Text $text -Old $oldMissionDone -New $newCallbacks -Label 'TaskDone settlement callback'
$text = $text.Replace('matching MOOSE LANDATCOORDINATE MissionDone while the FLIGHTGROUP is within 250 m of OMW_BLUE_LZ_FORTRESS_01','matching MOOSE OPSGROUP TaskDone for the LANDATCOORDINATE mission task while the FLIGHTGROUP is within 250 m of OMW_BLUE_LZ_FORTRESS_01')
$text = $text.Replace('matching LANDATCOORDINATE MissionDone near Fortress LZ','matching LANDATCOORDINATE TaskDone near Fortress LZ')

$required = @('OnAfterTaskDone','GetGroupWaypointTask','AIR_DELIVERY_CONFIRMED_ON_LANDAT_TASK_DONE','LANDAT_TASK_DONE_NEAR_LZ','AIR_LANDAT_TASK_DONE_DELIVERY_SETTLED')
foreach ($marker in $required) { if (-not $text.Contains($marker)) { throw "Acceptance-4 missing marker: $marker" } }
if ($text.Contains('AIR_LANDAT_MISSION_DONE_DELIVERY_SETTLED')) { throw 'Acceptance-4 still contains MissionDone settlement marker.' }

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
$text = $text.Replace('-- Builder: tools/build-air-personnel-flightpath-return-acceptance-3.ps1','-- Builder: tools/build-air-personnel-flightpath-return-acceptance-4.ps1')
$text = $text.Replace('-- BuilderVersion: AIR-PERSONNEL-FLIGHTPATH-RETURN-ACCEPTANCE-3-1',"-- BuilderVersion: $builderVersion")
$text = $text -replace '-- GitCommit: [0-9a-fA-F]+', "-- GitCommit: $commit"
$text = $text -replace '-- GeneratedUtc: [^\r\n]+', "-- GeneratedUtc: $generatedUtc"

[System.IO.File]::WriteAllText($outputFile,$text,[System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host 'MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
Write-Host 'MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'
Write-Host 'AirDeliveryProof: MOOSE OPSGROUP OnAfterTaskDone for LANDATCOORDINATE task near Fortress LZ'
Write-Host 'AirDeliveryAcceptanceRadiusM: 250'
Write-Host 'AirPhysicalReturnProof: Jalalabad OnAfterLanded then LegionAssetReturned'
Write-Host 'AirTravelTimeoutSec: none'
Write-Host 'MizMutation: false'
Write-Host "SHA256: $hash"
