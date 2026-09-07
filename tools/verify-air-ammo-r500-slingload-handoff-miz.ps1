[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MizPath
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$foundationFile = Join-Path $repoRoot 'mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua'
$acceptanceFile = Join-Path $repoRoot 'mission\tests\air-ammo-resupply\dist\OMW_Air_AMMO_R500_Slingload_Handoff_Acceptance_1.lua'
$expectedMooseSha256 = 'E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'
$foundationEntryName = 'l10n/DEFAULT/OMW_AirOps_Jalalabad.lua'
$acceptanceEntryName = 'l10n/DEFAULT/OMW_Air_AMMO_R500_Slingload_Handoff_Acceptance_1.lua'
$mooseEntryName = 'l10n/DEFAULT/Moose.lua'

foreach ($file in @($foundationFile, $acceptanceFile)) {
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
        throw "Required local build artifact not found: $file"
    }
}
if (-not (Test-Path -LiteralPath $MizPath -PathType Leaf)) {
    throw "Mission file not found: $MizPath"
}

$foundationText = Get-Content -LiteralPath $foundationFile -Raw -Encoding UTF8
$acceptanceText = Get-Content -LiteralPath $acceptanceFile -Raw -Encoding UTF8
if (-not $foundationText.Contains('BuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-6')) {
    throw 'Local Jalalabad foundation is not BuilderVersion JBAD-AIR-OPS-FOUNDATION-ONLY-6.'
}
if (-not $foundationText.Contains('VERTICAL_POLICY_APPLIED')) {
    throw 'Local Jalalabad foundation is missing transport-path vertical policy propagation.'
}
if (-not $acceptanceText.Contains('BuilderVersion: AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-2')) {
    throw 'Local isolated slingload acceptance is not BuilderVersion AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-2.'
}
foreach ($marker in @('AUFTRAG:NewCARGOTRANSPORT','Physical slingload pickup confirmed','APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF','MOOSE_FSM_ONBEFORE_UNPAUSEMISSION')) {
    if (-not $acceptanceText.Contains($marker)) {
        throw "Local isolated slingload acceptance is missing required marker: $marker"
    }
}

$foundationHash = (Get-FileHash -LiteralPath $foundationFile -Algorithm SHA256).Hash.ToUpperInvariant()
$acceptanceHash = (Get-FileHash -LiteralPath $acceptanceFile -Algorithm SHA256).Hash.ToUpperInvariant()
$missionHash = (Get-FileHash -LiteralPath $MizPath -Algorithm SHA256).Hash.ToUpperInvariant()

Add-Type -AssemblyName System.IO.Compression.FileSystem
$resolvedMiz = (Resolve-Path -LiteralPath $MizPath).Path
$zip = [System.IO.Compression.ZipFile]::OpenRead($resolvedMiz)
try {
    function Get-EntryBytes([System.IO.Compression.ZipArchive]$Archive, [string]$EntryName) {
        $entry = $Archive.GetEntry($EntryName)
        if (-not $entry) {
            throw "Mission is missing embedded file: $EntryName"
        }
        $stream = $entry.Open()
        try {
            $memory = New-Object System.IO.MemoryStream
            try {
                $stream.CopyTo($memory)
                return $memory.ToArray()
            } finally {
                $memory.Dispose()
            }
        } finally {
            $stream.Dispose()
        }
    }

    function Get-BytesSha256([byte[]]$Bytes) {
        $sha = [System.Security.Cryptography.SHA256]::Create()
        try {
            return ([System.BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-', '').ToUpperInvariant()
        } finally {
            $sha.Dispose()
        }
    }

    $embeddedFoundationBytes = Get-EntryBytes $zip $foundationEntryName
    $embeddedAcceptanceBytes = Get-EntryBytes $zip $acceptanceEntryName
    $embeddedMooseBytes = Get-EntryBytes $zip $mooseEntryName

    $embeddedFoundationHash = Get-BytesSha256 $embeddedFoundationBytes
    $embeddedAcceptanceHash = Get-BytesSha256 $embeddedAcceptanceBytes
    $embeddedMooseHash = Get-BytesSha256 $embeddedMooseBytes

    $embeddedFoundationText = [System.Text.Encoding]::UTF8.GetString($embeddedFoundationBytes)
    $embeddedAcceptanceText = [System.Text.Encoding]::UTF8.GetString($embeddedAcceptanceBytes)

    if (-not $embeddedFoundationText.Contains('BuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-6')) {
        throw "STALE_JALALABAD_FOUNDATION: mission does not embed JBAD-AIR-OPS-FOUNDATION-ONLY-6 (embedded SHA256=$embeddedFoundationHash)."
    }
    if (-not $embeddedFoundationText.Contains('VERTICAL_POLICY_APPLIED')) {
        throw "STALE_JALALABAD_FOUNDATION: embedded foundation lacks vertical transport-path propagation (embedded SHA256=$embeddedFoundationHash)."
    }
    if (-not $embeddedAcceptanceText.Contains('BuilderVersion: AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-2')) {
        throw "STALE_SLINGLOAD_ACCEPTANCE: mission does not embed AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-2 (embedded SHA256=$embeddedAcceptanceHash)."
    }
    if ($embeddedFoundationHash -ne $foundationHash) {
        throw "Jalalabad foundation hash mismatch. Local=$foundationHash Embedded=$embeddedFoundationHash"
    }
    if ($embeddedAcceptanceHash -ne $acceptanceHash) {
        throw "Slingload acceptance hash mismatch. Local=$acceptanceHash Embedded=$embeddedAcceptanceHash"
    }
    if ($embeddedMooseHash -ne $expectedMooseSha256) {
        throw "Pinned Moose.lua hash mismatch. Expected=$expectedMooseSha256 Embedded=$embeddedMooseHash"
    }

    Write-Host 'AirAmmoR500SlingloadMizPreflight: PASS'
    Write-Host "Mission: $resolvedMiz"
    Write-Host "MissionSHA256: $missionHash"
    Write-Host "JalalabadFoundationSHA256: $embeddedFoundationHash"
    Write-Host 'JalalabadFoundationBuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-6'
    Write-Host 'JalalabadVerticalTransportPolicy: PRESENT'
    Write-Host "SlingloadAcceptanceSHA256: $embeddedAcceptanceHash"
    Write-Host 'SlingloadAcceptanceBuilderVersion: AIR-AMMO-R500-SLINGLOAD-HANDOFF-ACCEPTANCE-1-2'
    Write-Host 'PhysicalExternalSlingloadContract: PRESENT'
    Write-Host "MooseLuaSHA256: $embeddedMooseHash"
    Write-Host 'MizMutation: false'
} finally {
    $zip.Dispose()
}
