[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$acceptanceBuilder = Join-Path $repoRoot 'tools\build-air-tasking-aar-vertical-acceptance.ps1'
$acceptanceBundle = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist\OMW_AirTasking_AAR_Vertical_Acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist\miz-insert'
$outputFile = Join-Path $distDir 'OMW_AAR_Base.lua'

$builderVersion = 'OMW-AIR-TASKING-AAR-VERTICAL-TEST-LUA-1'
$testId = 'AIR-TASKING-AAR-VERTICAL-1'
$expectedMissionSha256 = '3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$resourceKey = 'ResKey_Action_235'
$resourceFileName = 'OMW_AAR_Base.lua'

if (-not (Test-Path -LiteralPath $acceptanceBuilder -PathType Leaf)) {
  throw "Acceptance builder not found: $acceptanceBuilder"
}

& $acceptanceBuilder

if (-not (Test-Path -LiteralPath $acceptanceBundle -PathType Leaf)) {
  throw "Acceptance bundle was not generated: $acceptanceBundle"
}

New-Item -ItemType Directory -Path $distDir -Force | Out-Null
Copy-Item -LiteralPath $acceptanceBundle -Destination $outputFile -Force

$acceptanceHash = (Get-FileHash -LiteralPath $acceptanceBundle -Algorithm SHA256).Hash.ToLowerInvariant()
$outputHash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToLowerInvariant()
if ($acceptanceHash -ne $outputHash) {
  throw "Insert artifact hash mismatch source=$acceptanceHash output=$outputHash"
}

$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$sourceCommitUtc = (& git -C $repoRoot show -s --format=%cI HEAD).Trim()
if ([string]::IsNullOrWhiteSpace($sourceCommitUtc)) {
  throw 'Unable to determine source commit timestamp.'
}

Write-Host "Built: $outputFile"
Write-Host "BuilderVersion: $builderVersion"
Write-Host "TestId: $testId"
Write-Host "SourceCommitUtc: $sourceCommitUtc"
Write-Host 'Scope: AIR_TASKING_AAR_VERTICAL_TEST_LUA'
Write-Host 'MizMutation: false'
Write-Host 'MizInspectionOnly: true'
Write-Host "ExpectedSourceMissionSHA256: $expectedMissionSha256"
Write-Host "ExistingMissionResourceKey: $resourceKey"
Write-Host "InsertFileName: $resourceFileName"
Write-Host 'MissionEditorInsertionRequired: true'
Write-Host 'SourceMissionModifiedByBuilder: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $mooseSha256"
Write-Host "GitCommit: $commit"
Write-Host "AcceptanceBundleSHA256: $acceptanceHash"
Write-Host "InsertLuaSHA256: $outputHash"
