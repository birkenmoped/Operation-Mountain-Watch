[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$InputMiz,

  [string]$OutputMiz
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$acceptanceBuilder = Join-Path $repoRoot 'tools\build-air-tasking-aar-vertical-acceptance.ps1'
$acceptanceBundle = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist\OMW_AirTasking_AAR_Vertical_Acceptance.lua'
$distDir = Join-Path $repoRoot 'mission\tests\air-tasking-aar-vertical\dist'

$builderVersion = 'OMW-AIR-TASKING-AAR-VERTICAL-MIZ-1'
$mooseCommit = '73d3ed119cd9e7e3f2cfcabbaa34513d30529b54'
$mooseSha256 = 'e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915'
$mooseEntryName = 'l10n/DEFAULT/Moose.lua'
$aarEntryName = 'l10n/DEFAULT/OMW_AAR_Base.lua'
$mapResourceEntryName = 'l10n/DEFAULT/mapResource'
$aarResourceMarker = '["ResKey_Action_235"] = "OMW_AAR_Base.lua"'

function Get-ZipEntryBytes {
  param(
    [Parameter(Mandatory = $true)]
    [System.IO.Compression.ZipArchive]$Archive,

    [Parameter(Mandatory = $true)]
    [string]$EntryName
  )

  $entry = $Archive.GetEntry($EntryName)
  if ($null -eq $entry) {
    throw "Required MIZ entry not found: $EntryName"
  }

  $stream = $entry.Open()
  try {
    $memory = New-Object System.IO.MemoryStream
    try {
      $stream.CopyTo($memory)
      return $memory.ToArray()
    }
    finally {
      $memory.Dispose()
    }
  }
  finally {
    $stream.Dispose()
  }
}

function Get-Sha256Hex {
  param(
    [Parameter(Mandatory = $true)]
    [byte[]]$Bytes
  )

  $sha = [System.Security.Cryptography.SHA256]::Create()
  try {
    return ([System.BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToLowerInvariant()
  }
  finally {
    $sha.Dispose()
  }
}

if (-not (Test-Path -LiteralPath $InputMiz -PathType Leaf)) {
  throw "Input MIZ not found: $InputMiz"
}
if (-not (Test-Path -LiteralPath $acceptanceBuilder -PathType Leaf)) {
  throw "Acceptance builder not found: $acceptanceBuilder"
}

$inputFullPath = (Resolve-Path -LiteralPath $InputMiz).Path
if ([string]::IsNullOrWhiteSpace($OutputMiz)) {
  New-Item -ItemType Directory -Path $distDir -Force | Out-Null
  $OutputMiz = Join-Path $distDir 'OMW_AirTasking_AAR_Vertical_Acceptance.miz'
}
$outputFullPath = [System.IO.Path]::GetFullPath($OutputMiz)

if ([string]::Equals($inputFullPath, $outputFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
  throw 'InputMiz and OutputMiz must be different files. The source mission is never modified in place.'
}

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

& $acceptanceBuilder
if (-not (Test-Path -LiteralPath $acceptanceBundle -PathType Leaf)) {
  throw "Acceptance bundle was not generated: $acceptanceBundle"
}

$inputMissionHash = (Get-FileHash -LiteralPath $inputFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
$acceptanceBundleHash = (Get-FileHash -LiteralPath $acceptanceBundle -Algorithm SHA256).Hash.ToLowerInvariant()

$inputArchive = [System.IO.Compression.ZipFile]::OpenRead($inputFullPath)
try {
  $inputMooseBytes = Get-ZipEntryBytes -Archive $inputArchive -EntryName $mooseEntryName
  $inputMooseHash = Get-Sha256Hex -Bytes $inputMooseBytes
  if ($inputMooseHash -ne $mooseSha256) {
    throw "Input MIZ Moose.lua hash mismatch expected=$mooseSha256 actual=$inputMooseHash"
  }

  [void](Get-ZipEntryBytes -Archive $inputArchive -EntryName $aarEntryName)
  $mapResourceBytes = Get-ZipEntryBytes -Archive $inputArchive -EntryName $mapResourceEntryName
  $mapResourceText = [System.Text.Encoding]::UTF8.GetString($mapResourceBytes)
  if (-not $mapResourceText.Contains($aarResourceMarker)) {
    throw "Input MIZ does not map ResKey_Action_235 to OMW_AAR_Base.lua"
  }
}
finally {
  $inputArchive.Dispose()
}

$outputDirectory = Split-Path -Parent $outputFullPath
if (-not [string]::IsNullOrWhiteSpace($outputDirectory)) {
  New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
if (Test-Path -LiteralPath $outputFullPath -PathType Leaf) {
  Remove-Item -LiteralPath $outputFullPath -Force
}
Copy-Item -LiteralPath $inputFullPath -Destination $outputFullPath -Force

$acceptanceBytes = [System.IO.File]::ReadAllBytes($acceptanceBundle)
$outputArchive = [System.IO.Compression.ZipFile]::Open($outputFullPath, [System.IO.Compression.ZipArchiveMode]::Update)
try {
  $oldEntry = $outputArchive.GetEntry($aarEntryName)
  if ($null -eq $oldEntry) {
    throw "Output MIZ lost required AAR entry before replacement: $aarEntryName"
  }
  $oldEntry.Delete()

  $newEntry = $outputArchive.CreateEntry($aarEntryName, [System.IO.Compression.CompressionLevel]::Optimal)
  $entryStream = $newEntry.Open()
  try {
    $entryStream.Write($acceptanceBytes, 0, $acceptanceBytes.Length)
  }
  finally {
    $entryStream.Dispose()
  }
}
finally {
  $outputArchive.Dispose()
}

$verifyArchive = [System.IO.Compression.ZipFile]::OpenRead($outputFullPath)
try {
  $embeddedMooseHash = Get-Sha256Hex -Bytes (Get-ZipEntryBytes -Archive $verifyArchive -EntryName $mooseEntryName)
  $embeddedAarHash = Get-Sha256Hex -Bytes (Get-ZipEntryBytes -Archive $verifyArchive -EntryName $aarEntryName)
  $verifyMapResourceText = [System.Text.Encoding]::UTF8.GetString(
    (Get-ZipEntryBytes -Archive $verifyArchive -EntryName $mapResourceEntryName)
  )

  if ($embeddedMooseHash -ne $mooseSha256) {
    throw "Output MIZ Moose.lua hash mismatch expected=$mooseSha256 actual=$embeddedMooseHash"
  }
  if ($embeddedAarHash -ne $acceptanceBundleHash) {
    throw "Output MIZ embedded acceptance hash mismatch expected=$acceptanceBundleHash actual=$embeddedAarHash"
  }
  if (-not $verifyMapResourceText.Contains($aarResourceMarker)) {
    throw 'Output MIZ AAR resource mapping changed unexpectedly.'
  }
}
finally {
  $verifyArchive.Dispose()
}

$outputMissionHash = (Get-FileHash -LiteralPath $outputFullPath -Algorithm SHA256).Hash.ToLowerInvariant()
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()

Write-Host "Built: $outputFullPath"
Write-Host "BuilderVersion: $builderVersion"
Write-Host 'Scope: AIR_TASKING_AAR_VERTICAL_ACCEPTANCE_MIZ'
Write-Host 'SourceMissionModifiedInPlace: false'
Write-Host 'ReplacedResource: l10n/DEFAULT/OMW_AAR_Base.lua'
Write-Host 'ResourceKey: ResKey_Action_235'
Write-Host 'MapResourceChanged: false'
Write-Host 'TriggerChanged: false'
Write-Host "MOOSECommit: $mooseCommit"
Write-Host "MooseLuaSHA256: $embeddedMooseHash"
Write-Host "GitCommit: $commit"
Write-Host "InputMissionSHA256: $inputMissionHash"
Write-Host "AcceptanceBundleSHA256: $acceptanceBundleHash"
Write-Host "EmbeddedAARBaseSHA256: $embeddedAarHash"
Write-Host "OutputMissionSHA256: $outputMissionHash"
