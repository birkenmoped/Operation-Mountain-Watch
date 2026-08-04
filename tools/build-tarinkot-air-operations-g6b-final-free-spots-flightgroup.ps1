[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseBuilder = Join-Path $repoRoot 'tools\build-tarinkot-air-operations-g6b-final-free-spots.ps1'
$outputFile = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G6B_FinalFreeSpots.lua'

if (-not (Test-Path -LiteralPath $baseBuilder -PathType Leaf)) {
    throw "Base builder not found: $baseBuilder"
}

& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $baseBuilder
if ($LASTEXITCODE -ne 0) {
    throw "Base builder failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
    throw "Generated bundle not found: $outputFile"
}

$content = Get-Content -LiteralPath $outputFile -Raw -Encoding UTF8

$oldBlock = @'
      local verticalUnits = safe("GET_UNITS_VERTICAL_OPTION_" .. family.Key .. "_" .. requestIndex, function()
        return group:GetUnits()
      end) or {}
      if #verticalUnits ~= expectedUnits then
        finish("FAIL_SPAWN", "VERTICAL_OPTION_UNIT_COUNT_MISMATCH_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      for _, verticalUnit in ipairs(verticalUnits) do
        local _, _, _, optionApplied = safe("PREFER_VERTICAL_" .. verticalUnit:GetName(), function()
          return verticalUnit:OptionPreferVerticalLanding()
        end)
        if not optionApplied then
          finish("FAIL_SPAWN", "PREFER_VERTICAL_OPTION_FAILED_" .. verticalUnit:GetName(), groupsSpawned, 0, 0, 0)
          return
        end
        log("VERTICAL_TAKEOFF_OPTION unit=" .. tostring(verticalUnit:GetName()) .. " method=UNIT:OptionPreferVerticalLanding applied=true")
      end
'@

$newBlock = @'
      local flightGroup, _, _, flightGroupCreated = safe("CREATE_FLIGHTGROUP_" .. family.Key .. "_" .. requestIndex, function()
        return FLIGHTGROUP:New(group)
      end)
      if not flightGroupCreated or not flightGroup then
        finish("FAIL_SPAWN", "FLIGHTGROUP_CREATE_FAILED_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      local _, _, _, optionApplied = safe("PREFER_VERTICAL_FLIGHTGROUP_" .. family.Key .. "_" .. requestIndex, function()
        return flightGroup:SetOptionPreferVertical()
      end)
      if not optionApplied then
        finish("FAIL_SPAWN", "PREFER_VERTICAL_FLIGHTGROUP_FAILED_" .. family.Key .. "_" .. requestIndex, groupsSpawned, 0, 0, 0)
        return
      end
      log("VERTICAL_TAKEOFF_OPTION group=" .. tostring(group:GetName()) .. " method=FLIGHTGROUP:SetOptionPreferVertical applied=true")
'@

if (-not $content.Contains($oldBlock)) {
    throw 'Expected UNIT vertical-option block not found in generated bundle.'
}

$content = $content.Replace($oldBlock, $newBlock)
$content = $content.Replace('BuilderVersion: TKOT-G6B-FINAL-FREE-SPOTS-5', 'BuilderVersion: TKOT-G6B-FINAL-FREE-SPOTS-6')
$content = $content.Replace('BuilderVersion = "TKOT-G6B-FINAL-FREE-SPOTS-5"', 'BuilderVersion = "TKOT-G6B-FINAL-FREE-SPOTS-6"')
$content = $content.Replace('CONTROLLABLE:OptionPreferVerticalLanding()', 'FLIGHTGROUP:SetOptionPreferVertical()')
$content = $content.Replace('UNIT:OptionPreferVerticalLanding', 'FLIGHTGROUP:SetOptionPreferVertical')
$content = $content.Replace('every spawned helicopter UNIT receives', 'every spawned helicopter group receives')

if ($content -match 'OptionPreferVerticalLanding') {
    throw 'Obsolete UNIT vertical-option call remained in generated bundle.'
}
if ($content -notmatch 'FLIGHTGROUP\s*:\s*New\s*\(group\)') {
    throw 'Required FLIGHTGROUP:New(group) call missing.'
}
if ($content -notmatch 'flightGroup\s*:\s*SetOptionPreferVertical\s*\(\)') {
    throw 'Required FLIGHTGROUP:SetOptionPreferVertical() call missing.'
}

[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))

$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "BuilderVersion: TKOT-G6B-FINAL-FREE-SPOTS-6"
Write-Host "DeparturePolicy: FLIGHTGROUP:New(group) then FLIGHTGROUP:SetOptionPreferVertical()"
Write-Host "GroupsConfigured: 7"
Write-Host "AircraftConfigured: 8"
Write-Host "BundlesBuilt: 1"
