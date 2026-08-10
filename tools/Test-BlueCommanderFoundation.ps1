[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceFile,
    [string]$GeneratedFile
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-Text([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Input not found: $Path" }
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) -replace "`r`n", "`n"
}

$source = Get-Text $SourceFile

$required = @(
    'COMMANDER:New(coalition.side.BLUE, "OMW BLUE Commander")',
    'commander:AddAirwing(airwing)',
    'commander:Start()',
    'BLUE_COMMANDER_FOUNDATION_ONLY',
    'GeneratedMissions = 0',
    'GeneratedTransports = 0',
    'CampaignStateMutation = false',
    'expectedAirwings=%d',
    'registeredAirwings=%d',
    'skippedAirwings=%d'
)
foreach ($marker in $required) {
    if (-not $source.Contains($marker)) { throw "Missing BLUE COMMANDER foundation marker: $marker" }
}

$registryIds = @(
    'BAGRAM_USAF','BAGRAM_ARMY','JALALABAD','KANDAHAR_MAIN',
    'KANDAHAR_HELIPORT','SALERNO','SHINDAND','TARINKOT'
)
foreach ($id in $registryIds) {
    if (-not $source.Contains('id = "' + $id + '"')) { throw "Missing expected AIRWING registry ID: $id" }
}

$forbidden = @(
    'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(',
    'OPSTRANSPORT\s*:\s*New\s*\(',
    ':\s*AddMission\s*\(',
    'missionCommands',
    'MENU_COALITION',
    'MENU_MISSION',
    '\bCTLD\b',
    '\bCSAR\b',
    'io\.open',
    'lfs\.',
    'CampaignState\s*[\[\.]'
)
foreach ($pattern in $forbidden) {
    if ($source -match $pattern) { throw "Forbidden BLUE COMMANDER foundation pattern found: $pattern" }
}

$newIndex = $source.IndexOf('COMMANDER:New(', [System.StringComparison]::Ordinal)
$addIndex = $source.IndexOf('commander:AddAirwing(', [System.StringComparison]::Ordinal)
$startIndex = $source.IndexOf('commander:Start()', [System.StringComparison]::Ordinal)
if ($newIndex -lt 0 -or $addIndex -lt 0 -or $startIndex -lt 0 -or $newIndex -ge $addIndex -or $addIndex -ge $startIndex) {
    throw 'COMMANDER lifecycle order must be New -> AddAirwing -> Start.'
}

if ($GeneratedFile) {
    $generated = Get-Text $GeneratedFile
    foreach ($pattern in $forbidden) {
        if ($generated -match $pattern) { throw "Generated bundle contains forbidden pattern: $pattern" }
    }
}

Write-Host 'BLUE COMMANDER foundation guard: PASS'
Write-Host 'ExpectedAirwings: 8'
Write-Host 'GeneratedMissions: 0'
Write-Host 'GeneratedTransports: 0'
Write-Host 'CampaignStateMutation: false'
