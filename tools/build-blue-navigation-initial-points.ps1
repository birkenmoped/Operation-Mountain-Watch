[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$InputMiz,

    [Parameter(Mandatory = $true)]
    [string]$OutputMiz,

    [string]$FixRegister
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
if (-not $FixRegister) {
    $FixRegister = Join-Path $repoRoot 'data\air-operations\airspace\afghanistan-2011-navigation-fixes.csv'
}

$inputPath = (Resolve-Path -LiteralPath $InputMiz).Path
$fixPath = (Resolve-Path -LiteralPath $FixRegister).Path
$outputPath = [System.IO.Path]::GetFullPath($OutputMiz)

if ([string]::Equals($inputPath, $outputPath, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'InputMiz and OutputMiz must be different paths. The builder never mutates the source mission in place.'
}

$rows = @(Import-Csv -LiteralPath $fixPath)
if ($rows.Count -eq 0) {
    throw "Navigation fix register is empty: $fixPath"
}

$headers = @($rows[0].PSObject.Properties.Name)
$expectedHeaders = @('name', 'lat_dd', 'lon_dd')
if (($headers.Count -ne $expectedHeaders.Count) -or (Compare-Object -ReferenceObject $expectedHeaders -DifferenceObject $headers)) {
    throw "Navigation fix register must contain exactly: $($expectedHeaders -join ',')"
}

$names = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
$culture = [System.Globalization.CultureInfo]::InvariantCulture
foreach ($row in $rows) {
    $name = [string]$row.name
    if ($name -notmatch '^[A-Z]{5}$') {
        throw "Invalid AIP fix name '$name'. Expected the exact five-letter uppercase designator."
    }
    if (-not $names.Add($name)) {
        throw "Duplicate navigation fix name: $name"
    }

    $lat = 0.0
    $lon = 0.0
    if (-not [double]::TryParse([string]$row.lat_dd, [System.Globalization.NumberStyles]::Float, $culture, [ref]$lat)) {
        throw "Invalid latitude for $name: $($row.lat_dd)"
    }
    if (-not [double]::TryParse([string]$row.lon_dd, [System.Globalization.NumberStyles]::Float, $culture, [ref]$lon)) {
        throw "Invalid longitude for $name: $($row.lon_dd)"
    }
    if ($lat -lt -90.0 -or $lat -gt 90.0 -or $lon -lt -180.0 -or $lon -gt 180.0) {
        throw "Out-of-range WGS84 coordinate for $name: $lat,$lon"
    }
}

# Afghanistan terrain projection. The constants come from an in-sim projection
# probe and were independently cross-checked against the uploaded current OMW
# base mission using the 2011 AIP Jalalabad/Bagram/Kabul ARPs.
$semiMajor = 6378137.0
$flattening = 1.0 / 298.257223563
$eccentricitySquared = $flattening * (2.0 - $flattening)
$secondEccentricitySquared = $eccentricitySquared / (1.0 - $eccentricitySquared)
$centralMeridianRad = 63.0 * [math]::PI / 180.0
$scaleFactor = 0.9996
$falseEasting = -300150.0000226601
$falseNorthing = -3759657.0000381926

function Convert-Wgs84ToDcsAfghanistan {
    param(
        [Parameter(Mandatory = $true)][double]$Latitude,
        [Parameter(Mandatory = $true)][double]$Longitude
    )

    $lat = $Latitude * [math]::PI / 180.0
    $lon = $Longitude * [math]::PI / 180.0

    $sinLat = [math]::Sin($lat)
    $cosLat = [math]::Cos($lat)
    $tanLat = [math]::Tan($lat)

    $n = $semiMajor / [math]::Sqrt(1.0 - $eccentricitySquared * $sinLat * $sinLat)
    $t = $tanLat * $tanLat
    $c = $secondEccentricitySquared * $cosLat * $cosLat
    $aTerm = $cosLat * ($lon - $centralMeridianRad)

    $e4 = $eccentricitySquared * $eccentricitySquared
    $e6 = $e4 * $eccentricitySquared
    $e8 = $e4 * $e4

    $m = $semiMajor * (
        (1.0 - $eccentricitySquared / 4.0 - 3.0 * $e4 / 64.0 - 5.0 * $e6 / 256.0 - 175.0 * $e8 / 16384.0) * $lat -
        (3.0 * $eccentricitySquared / 8.0 + 3.0 * $e4 / 32.0 + 45.0 * $e6 / 1024.0 + 105.0 * $e8 / 4096.0) * [math]::Sin(2.0 * $lat) +
        (15.0 * $e4 / 256.0 + 45.0 * $e6 / 1024.0 + 525.0 * $e8 / 16384.0) * [math]::Sin(4.0 * $lat) -
        (35.0 * $e6 / 3072.0 + 175.0 * $e8 / 12288.0) * [math]::Sin(6.0 * $lat) +
        (315.0 * $e8 / 131072.0) * [math]::Sin(8.0 * $lat)
    )

    $easting = $falseEasting + $scaleFactor * $n * (
        $aTerm +
        (1.0 - $t + $c) * [math]::Pow($aTerm, 3) / 6.0 +
        (5.0 - 18.0 * $t + $t * $t + 72.0 * $c - 58.0 * $secondEccentricitySquared) * [math]::Pow($aTerm, 5) / 120.0 +
        (61.0 - 479.0 * $t + 179.0 * $t * $t - $t * $t * $t) * [math]::Pow($aTerm, 7) / 5040.0
    )

    $northing = $falseNorthing + $scaleFactor * (
        $m + $n * $tanLat * (
            [math]::Pow($aTerm, 2) / 2.0 +
            (5.0 - $t + 9.0 * $c + 4.0 * $c * $c) * [math]::Pow($aTerm, 4) / 24.0 +
            (61.0 - 58.0 * $t + $t * $t + 600.0 * $c - 330.0 * $secondEccentricitySquared) * [math]::Pow($aTerm, 6) / 720.0 +
            (1385.0 - 3111.0 * $t + 543.0 * $t * $t - $t * $t * $t) * [math]::Pow($aTerm, 8) / 40320.0
        )
    )

    # DCS mission files store local northing as x and local easting as y.
    return [pscustomobject]@{
        X = $northing
        Y = $easting
    }
}

# Fail closed on projection regressions. These are expected local coordinates for
# the 2011 AIP Jalalabad ARP N34 24 02 E070 29 50.
$projectionProbe = Convert-Wgs84ToDcsAfghanistan -Latitude 34.4005555555556 -Longitude 70.4972222222222
if ([math]::Abs($projectionProbe.X - 72497.9463) -gt 0.05 -or [math]::Abs($projectionProbe.Y - 389650.1928) -gt 0.05) {
    throw "Afghanistan projection self-check failed: x=$($projectionProbe.X) y=$($projectionProbe.Y)"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('omw-navfix-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($inputPath, $tempRoot)
    $missionPath = Join-Path $tempRoot 'mission'
    if (-not (Test-Path -LiteralPath $missionPath -PathType Leaf)) {
        throw "MIZ does not contain a mission file: $inputPath"
    }

    $mission = [System.IO.File]::ReadAllText($missionPath, [System.Text.Encoding]::UTF8)
    $coalitionIndex = $mission.IndexOf('["coalition"] =', [System.StringComparison]::Ordinal)
    if ($coalitionIndex -lt 0) {
        throw 'DCS mission coalition table was not found.'
    }

    $blueIndex = $mission.IndexOf('["blue"] =', $coalitionIndex, [System.StringComparison]::Ordinal)
    if ($blueIndex -lt 0) {
        throw 'DCS BLUE coalition table was not found.'
    }

    $blueNavMarker = '["nav_points"] = {}'
    $blueNavIndex = $mission.IndexOf($blueNavMarker, $blueIndex, [System.StringComparison]::Ordinal)
    if ($blueNavIndex -lt 0) {
        throw 'Expected an empty BLUE nav_points table. Refusing to overwrite an unknown or already populated structure.'
    }

    $blueNameIndex = $mission.IndexOf('["name"] = "blue"', $blueNavIndex, [System.StringComparison]::Ordinal)
    if ($blueNameIndex -lt 0 -or ($blueNameIndex - $blueNavIndex) -gt 250) {
        throw 'BLUE nav_points structure validation failed.'
    }

    $existingNavIds = @(
        [regex]::Matches(
            $mission,
            '(?s)\["callsignStr"\]\s*=\s*"[^"]*".{0,600}?\["id"\]\s*=\s*(\d+)'
        ) | ForEach-Object { [int]$_.Groups[1].Value }
    )
    $nextId = if ($existingNavIds.Count -gt 0) {
        (($existingNavIds | Measure-Object -Maximum).Maximum + 1)
    }
    else {
        1
    }

    $orderedRows = @($rows | Sort-Object -Property name)
    $entryText = [System.Text.StringBuilder]::new()
    [void]$entryText.AppendLine('["nav_points"] = ')
    [void]$entryText.AppendLine("`t`t`t{")

    $index = 1
    foreach ($row in $orderedRows) {
        $lat = [double]::Parse([string]$row.lat_dd, $culture)
        $lon = [double]::Parse([string]$row.lon_dd, $culture)
        $point = Convert-Wgs84ToDcsAfghanistan -Latitude $lat -Longitude $lon
        $name = [string]$row.name
        $x = $point.X.ToString('0.00000000', $culture)
        $y = $point.Y.ToString('0.00000000', $culture)

        [void]$entryText.AppendLine("`t`t`t`t[$index] = ")
        [void]$entryText.AppendLine("`t`t`t`t{")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"type`"] = `"Default`",")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"comment`"] = `"`",")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"callsignStr`"] = `"$name`",")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"id`"] = $nextId,")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"properties`"] = ")
        [void]$entryText.AppendLine("`t`t`t`t`t{")
        [void]$entryText.AppendLine("`t`t`t`t`t`t[`"vnav`"] = 3,")
        [void]$entryText.AppendLine("`t`t`t`t`t`t[`"scale`"] = 4,")
        [void]$entryText.AppendLine("`t`t`t`t`t`t[`"vangle`"] = 0,")
        [void]$entryText.AppendLine("`t`t`t`t`t`t[`"angle`"] = 0,")
        [void]$entryText.AppendLine("`t`t`t`t`t`t[`"steer`"] = 3,")
        [void]$entryText.AppendLine("`t`t`t`t`t}, -- end of [`"properties`"]")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"y`"] = $y,")
        [void]$entryText.AppendLine("`t`t`t`t`t[`"x`"] = $x,")
        [void]$entryText.AppendLine("`t`t`t`t}, -- end of [$index]")

        $index++
        $nextId++
    }
    [void]$entryText.Append("`t`t`t}")

    $replacement = $entryText.ToString()
    $mission = $mission.Substring(0, $blueNavIndex) + $replacement + $mission.Substring($blueNavIndex + $blueNavMarker.Length)

    foreach ($name in $names) {
        $needle = '["callsignStr"] = "' + $name + '"'
        if ([regex]::Matches($replacement, [regex]::Escape($needle)).Count -ne 1) {
            throw "Generated BLUE nav-point set is missing or duplicates $name."
        }
    }

    [System.IO.File]::WriteAllText($missionPath, $mission, [System.Text.UTF8Encoding]::new($false))

    $outputDir = Split-Path -Parent $outputPath
    if ($outputDir -and -not (Test-Path -LiteralPath $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }
    if (Test-Path -LiteralPath $outputPath) {
        Remove-Item -LiteralPath $outputPath -Force
    }

    [System.IO.Compression.ZipFile]::CreateFromDirectory(
        $tempRoot,
        $outputPath,
        [System.IO.Compression.CompressionLevel]::Optimal,
        $false
    )

    $hash = (Get-FileHash -LiteralPath $outputPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Host "Built: $outputPath"
    Write-Host "Input: $inputPath"
    Write-Host "FixRegister: $fixPath"
    Write-Host "Coalition: BLUE"
    Write-Host "DcsNavPointType: Default"
    Write-Host "NavigationFixes: $($orderedRows.Count)"
    Write-Host "DuplicateFixNames: 0"
    Write-Host "ProjectionSelfCheck: PASS"
    Write-Host "RuntimeLua: ABSENT"
    Write-Host "SHA256: $hash"
}
finally {
    if (Test-Path -LiteralPath $tempRoot) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
}
