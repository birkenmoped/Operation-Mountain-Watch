[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$g7Builder = Join-Path $repoRoot 'tools\build-tarinkot-air-operations-g7-foundation.ps1'
$g7Bundle = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G7_Foundation.lua'
$g8cSource = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\src\10-tarinkot-g8c-uniform-rotary-hover-dispatch.lua'
$distDir = Join-Path $repoRoot 'mission\tests\tarinkot-air-operations\dist'
$outputFile = Join-Path $distDir 'OMW_AirOps_Tarinkot_G8C_UniformRotaryHoverDispatch.lua'

foreach ($path in @($g7Builder, $g8cSource)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Required file not found: $path" }
}

& $g7Builder
if ($LASTEXITCODE -ne 0) { throw "G7 foundation builder failed with exit code $LASTEXITCODE" }
if (-not (Test-Path -LiteralPath $g7Bundle -PathType Leaf)) { throw "G7 foundation bundle was not produced: $g7Bundle" }

$g7Text = Get-Content -LiteralPath $g7Bundle -Raw -Encoding UTF8
$g8cText = Get-Content -LiteralPath $g8cSource -Raw -Encoding UTF8

foreach ($pattern in @('TKOT-G7-AIRWING-FOUNDATION-4', 'SetOptionPreferVerticalLanding')) {
    if ($g7Text -notmatch $pattern) { throw "Required G7 foundation pattern missing: $pattern" }
}
foreach ($pattern in @('AUFTRAG\s*:\s*NewHOVER\s*\(', 'AUFTRAG\.Type\.HOVER', 'AddMissionCapability\s*\(\s*AUFTRAG\.Type\.HOVER', 'AddPayloadCapability\s*\(\s*payload\s*,\s*AUFTRAG\.Type\.HOVER', 'OnAfterFlightOnMission', 'PASS_RUNTIME_TELEMETRY_PENDING_OWNER_VISUAL', 'AH64_1', 'AH64_2', 'UH60_1', 'UH60_2', 'CH47_1', 'taxiInference=disabled')) {
    if ($g8cText -notmatch $pattern) { throw "Required G8C source pattern missing: $pattern" }
}
foreach ($pattern in @('NewCAS\s*\(', 'NewLANDATCOORDINATE\s*\(', 'COMMANDER\s*:\s*New\s*\(', 'OPSTRANSPORT\s*:\s*New\s*\(', 'SPAWN\s*:', 'FLIGHTGROUP\s*:\s*New\s*\(', ':\s*SetOptionPreferVertical\s*\(', 'ZONE_RADIUS\s*:\s*New\s*\(', 'CampaignState\s*[\.:]', ':\s*Destroy\s*\(', ':\s*Despawn\s*\(', 'coalition\s*\.\s*addGroup\s*\(')) {
    if ($g8cText -match $pattern) { throw "Forbidden G8C source pattern matched: $pattern" }
}
if ([regex]::Matches($g8cText, 'AUFTRAG\s*:\s*NewHOVER\s*\(').Count -ne 1) { throw 'G8C must contain exactly one AUFTRAG:NewHOVER constructor.' }
if ([regex]::Matches($g8cText, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) { throw 'G8C must contain exactly one loop-based AIRWING:AddMission path.' }

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
$builderVersion = 'TKOT-G8C-UNIFORM-ROTARY-HOVER-DISPATCH-1'
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = [DateTime]::UtcNow.ToString('o')
$header = @"

-- BEGIN TARINKOT G8C UNIFORM ROTARY HOVER DISPATCH
-- Builder: tools/build-tarinkot-air-operations-g8c-uniform-rotary-hover-dispatch.ps1
-- BuilderVersion: $builderVersion
-- GitCommit: $commit
-- GeneratedUtc: $generatedUtc
-- Runtime scope: five rotary groups, five HOVER missions, one AIRWING dispatch path.
-- Acceptance: runtime telemetry plus mandatory owner visual confirmation.

local OMW_TKOT_G8C_BUILD = {
  Builder = "tools/build-tarinkot-air-operations-g8c-uniform-rotary-hover-dispatch.ps1",
  BuilderVersion = "$builderVersion",
  GitCommit = "$commit",
  GeneratedUtc = "$generatedUtc"
}

"@
$content = $g7Text + $header + $g8cText + "`n-- END TARINKOT G8C UNIFORM ROTARY HOVER DISPATCH`n"
[System.IO.File]::WriteAllText($outputFile, $content, [System.Text.UTF8Encoding]::new($false))
if ([regex]::Matches($content, 'airwing\s*:\s*AddMission\s*\(').Count -ne 1) { throw 'Generated G8C bundle does not contain exactly one operational mission path.' }
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
Write-Host "Built: $outputFile"
Write-Host "SHA256: $hash"
Write-Host "GitCommit: $commit"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'EmbeddedFoundation: TKOT-G7-AIRWING-FOUNDATION-4'
Write-Host 'Gate: G8C_UNIFORM_ROTARY_HOVER_DISPATCH'
Write-Host 'MissionType: AUFTRAG.Type.HOVER'
Write-Host 'DispatchGroups: 5'
Write-Host 'RuntimeAircraft: 7'
Write-Host 'OperationalMissions: 5'
Write-Host 'TaxiInference: disabled'
Write-Host 'OwnerVisualConfirmation: required'
