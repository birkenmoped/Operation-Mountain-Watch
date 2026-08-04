[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceFile,
    [string]$GeneratedFile,
    [string]$PreStartFunctionName = 'constructFoundation',
    [string]$PostStartFunctionName = 'inspectIdleFoundation',
    [switch]$RequirePostStartAssetValidation,
    [switch]$RequireVerticalPolicyBeforeStart,
    [switch]$FoundationScope
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Get-NormalizedText {
    param([Parameter(Mandatory = $true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Lifecycle guard input not found: $Path"
    }
    return (Get-Content -LiteralPath $Path -Raw -Encoding UTF8) -replace "`r`n", "`n"
}

function Get-LocalFunctionBody {
    param(
        [Parameter(Mandatory = $true)][string]$Text,
        [Parameter(Mandatory = $true)][string]$FunctionName
    )
    $escaped = [regex]::Escape($FunctionName)
    $startMatch = [regex]::Match($Text, "(?m)^local\s+function\s+$escaped\s*\([^\r\n]*\)")
    if (-not $startMatch.Success) {
        throw "Required local function not found: $FunctionName"
    }
    $bodyStart = $startMatch.Index + $startMatch.Length
    $remaining = $Text.Substring($bodyStart)
    $nextFunction = [regex]::Match($remaining, "(?m)^local\s+function\s+[A-Za-z0-9_]+\s*\(")
    $bodyLength = if ($nextFunction.Success) { $nextFunction.Index } else { $remaining.Length }
    return $remaining.Substring(0, $bodyLength)
}

function Assert-PatternPresent {
    param([string]$Text, [string]$Pattern, [string]$Label)
    if ($Text -notmatch $Pattern) {
        throw "Lifecycle guard missing required pattern [$Label]: $Pattern"
    }
}

function Assert-PatternAbsent {
    param([string]$Text, [string]$Pattern, [string]$Label)
    if ($Text -match $Pattern) {
        throw "Lifecycle guard matched forbidden pattern [$Label]: $Pattern"
    }
}

$sourceText = Get-NormalizedText -Path $SourceFile
$preStartBody = Get-LocalFunctionBody -Text $sourceText -FunctionName $PreStartFunctionName
$postStartBody = Get-LocalFunctionBody -Text $sourceText -FunctionName $PostStartFunctionName

$forbiddenPreStartPatterns = @(
    'SQUADRON_ASSET_COUNT_MISMATCH',
    'ASSET_PARKING_IDS_MISMATCH',
    'for\s+[^\n]+\s+in\s+pairs\s*\(\s*squadron\.assets',
    'if\s+[^\n]*countTable\s*\(\s*squadron\.assets\s*\)\s*~=\s*contract\.Ngroups',
    'if\s+[^\n]*#\s*squadron\.assets\s*~=\s*contract\.Ngroups'
)
foreach ($pattern in $forbiddenPreStartPatterns) {
    Assert-PatternAbsent -Text $preStartBody -Pattern $pattern -Label 'premature-squadron-asset-acceptance'
}

Assert-PatternPresent -Text $preStartBody -Pattern 'SQUADRON_STOCK_PRESTART' -Label 'pre-start-warehouse-stock'
Assert-PatternPresent -Text $preStartBody -Pattern 'airwing\.stock' -Label 'pre-start-stock-table'

if ($RequirePostStartAssetValidation) {
    Assert-PatternPresent -Text $postStartBody -Pattern 'squadron\.assets' -Label 'post-start-squadron-assets'
    Assert-PatternPresent -Text $postStartBody -Pattern 'expectedAssets|contract\.Ngroups' -Label 'post-start-expected-asset-count'
    Assert-PatternPresent -Text $postStartBody -Pattern 'parkingIDs' -Label 'post-start-inherited-parking'
}

if ($RequireVerticalPolicyBeforeStart) {
    $verticalCall = 'airwing:SetOptionPreferVerticalLanding()'
    $startCall = 'airwing:Start()'
    $verticalIndex = $preStartBody.IndexOf($verticalCall, [System.StringComparison]::Ordinal)
    $startIndex = $preStartBody.IndexOf($startCall, [System.StringComparison]::Ordinal)
    if ($verticalIndex -lt 0) { throw "Lifecycle guard did not find vertical policy call in $PreStartFunctionName" }
    if ($startIndex -lt 0) { throw "Lifecycle guard did not find AIRWING start call in $PreStartFunctionName" }
    if ($verticalIndex -ge $startIndex) { throw 'AIRWING:SetOptionPreferVerticalLanding() must occur before AIRWING:Start().' }
}

if ($FoundationScope) {
    $forbiddenFoundationPatterns = @(
        'COMMANDER\s*:\s*New\s*\(',
        'AUFTRAG\s*:\s*New[A-Za-z0-9_]*\s*\(',
        'OPSTRANSPORT\s*:\s*New\s*\(',
        'SPAWN\s*:',
        'FLIGHTGROUP\s*:\s*New\s*\(',
        ':\s*AddMission\s*\('
    )
    foreach ($pattern in $forbiddenFoundationPatterns) {
        Assert-PatternAbsent -Text $sourceText -Pattern $pattern -Label 'foundation-scope'
    }
}

$observerMaskPatterns = @(
    'activePlayerClientCount\s*=\s*function\s*\(',
    'originalActivePlayerClientCount',
    'ACTIVE_PLAYER_CLIENT_POLICY[^\n]*blocking=0[^\n]*\n[^\n]*return\s+0'
)
foreach ($pattern in $observerMaskPatterns) {
    Assert-PatternAbsent -Text $sourceText -Pattern $pattern -Label 'observer-count-masking'
}

if ($GeneratedFile) {
    $generatedText = Get-NormalizedText -Path $GeneratedFile
    foreach ($pattern in $observerMaskPatterns) {
        Assert-PatternAbsent -Text $generatedText -Pattern $pattern -Label 'generated-observer-count-masking'
    }
}

Write-Host 'AirOps lifecycle guard: PASS'
Write-Host "SourceFile: $SourceFile"
Write-Host "PreStartFunction: $PreStartFunctionName"
Write-Host "PostStartFunction: $PostStartFunctionName"
Write-Host "PostStartAssetValidationRequired: $($RequirePostStartAssetValidation.IsPresent)"
Write-Host "VerticalPolicyBeforeStartRequired: $($RequireVerticalPolicyBeforeStart.IsPresent)"
Write-Host "FoundationScope: $($FoundationScope.IsPresent)"
