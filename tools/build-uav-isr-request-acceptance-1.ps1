[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$builderVersion = 'OMW-UAV-ISR-REQUEST-ACCEPTANCE-1-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceFiles = @(
  (Join-Path $repoRoot 'scripts/campaign/OMW_ISR_RequestCoordinator.lua'),
  (Join-Path $repoRoot 'scripts/air-operations/OMW_ISR_RequestMenu.lua'),
  (Join-Path $repoRoot 'mission/tests/uav-isr-request/src/01-uav-isr-request-acceptance-1.lua')
)
$outputDirectory = Join-Path $repoRoot 'mission/tests/uav-isr-request/dist'
$outputFile = Join-Path $outputDirectory 'OMW_UAV_ISR_Request_Acceptance_1.lua'

$forbiddenPatterns = @(
  'SPAWN\\s*:',
  'AUFTRAG\\s*:',
  'AIRWING\\s*:',
  'SQUADRON\\s*:',
  'missionCommands\\.',
  'world\\.addEventHandler',
  'timer\\.scheduleFunction',
  'trigger\\.action',
  'coalition\\.',
  'Group\\.getByName',
  'mist\\.',
  'MissionScripting\\.lua',
  '\\bio\\.',
  '\\blfs\\.',
  '\\bos\\.execute'
)

foreach ($sourceFile in $sourceFiles) {
  if (-not (Test-Path -LiteralPath $sourceFile)) {
    throw "Required acceptance source is missing: $sourceFile"
  }

  $sourceText = Get-Content -LiteralPath $sourceFile -Raw
  foreach ($pattern in $forbiddenPatterns) {
    if ($sourceText -match $pattern) {
      throw "Forbidden physical-UAV or native-DCS API pattern '$pattern' in $sourceFile"
    }
  }
}

New-Item -ItemType Directory -Force -Path $outputDirectory | Out-Null
$coordinatorSource = Get-Content -LiteralPath $sourceFiles[0] -Raw
$menuSource = Get-Content -LiteralPath $sourceFiles[1] -Raw
$acceptanceSource = Get-Content -LiteralPath $sourceFiles[2] -Raw

$bundle = @"
-- Generated file. Do not edit.
-- BuilderVersion: $builderVersion
-- MOOSE commit: $mooseCommit
-- Moose.lua SHA-256: $mooseSha256
-- Scope: Acceptance 1 marker/menu only; no physical UAV dispatch or CampaignState reservation.

local Coordinator = (function()
$coordinatorSource
end)()

local RequestMenu = (function()
$menuSource
end)()

local Acceptance = (function()
$acceptanceSource
end)()

local runtime = Acceptance.Start({
  coordinatorModule = Coordinator,
  menuModule = RequestMenu,
  moose = {
    MARKEROPS_BASE = MARKEROPS_BASE,
    MENU_GROUP = MENU_GROUP,
    MENU_GROUP_COMMAND = MENU_GROUP_COMMAND,
    SET_CLIENT = SET_CLIENT,
    MESSAGE = MESSAGE
  }
})

return runtime
"@

Set-Content -LiteralPath $outputFile -Value $bundle -Encoding utf8NoBOM -NoNewline
$bundleHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()

Write-Host "BuilderVersion: $builderVersion"
Write-Host "Output: $outputFile"
Write-Host "Bundle SHA-256: $bundleHash"
Write-Host 'MIZ mutation: false'
Write-Host 'Physical UAV dispatch: false'
Write-Host 'CampaignState reservation: false'
Write-Host 'Acceptance-only submit radius: 10000 meters'
