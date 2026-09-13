[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$repoRoot=Split-Path -Parent $PSScriptRoot
$prodBuilder=Join-Path $repoRoot 'tools\build-fire-support-strategic-resupply-production-base.ps1'
$prodBundle=Join-Path $repoRoot 'mission\fire-support-strategic-resupply\dist\OMW_FireSupStratResupply_Base.lua'
$src=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\src\03-production-base-six-site-physical-alarm-qrf-acceptance.lua'
$out=Join-Path $repoRoot 'mission\tests\fire-support-strategic-resupply-production-base-runtime\dist\OMW_FireSupStratResupply_Production_Base_Acceptance_3.lua'
$version='OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-1'
foreach($f in @($prodBuilder,$src)){if(-not(Test-Path -LiteralPath $f -PathType Leaf)){throw "Required file not found: $f"}}
& $prodBuilder
if(-not(Test-Path -LiteralPath $prodBundle -PathType Leaf)){throw "Production bundle missing: $prodBundle"}
$p=Get-Content -LiteralPath $prodBundle -Raw -Encoding UTF8
$t=Get-Content -LiteralPath $src -Raw -Encoding UTF8
$c=$p+"`n"+$t
foreach($m in @('OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8','OMW-GROUND-INSTALLATION-ALARM-EVIDENCE-3','StartAlarmEvidence','BadGuys_A3_FENTY','BadGuys_A3_BOSTICK','ZON_TEST_A3_FENTY_ALARM','ZON_TEST_A3_BOSTICK_ALARM','GROUP.Attribute.GROUND_INFANTRY','GROUP.Attribute.GROUND_APC')){if(-not $c.Contains($m)){throw "Acceptance 3 marker missing: $m"}}
if($t -match 'ZON_BLUE_GND_[A-Z_]+_ACCESS'){throw 'Acceptance 3 must not use ACCESS zones.'}
if($t -match 'ReportInstallationEvidence\s*\('){throw 'Acceptance 3 must not inject evidence directly.'}
$commit=(& git -C $repoRoot rev-parse HEAD).Trim()
$header="-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY.`n-- BuilderVersion: $version`n-- GitCommit: $commit`n-- MOOSE release: 2.9.18`n-- MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`n-- Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`n-- Acceptance-only six-site physical alarm/QRF fixture.`n`n"
New-Item -ItemType Directory -Path (Split-Path -Parent $out) -Force|Out-Null
[System.IO.File]::WriteAllText($out,$header+$p+"`n`n"+$t,[System.Text.UTF8Encoding]::new($false))
Write-Host "Built: $out"
Write-Host "BuilderVersion: $version"
Write-Host "GitCommit: $commit"
Write-Host "ProductionBuilderSHA256: $((Get-FileHash -LiteralPath $prodBuilder -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "ProductionBundleSHA256: $((Get-FileHash -LiteralPath $prodBundle -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceSourceSHA256: $((Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBuilderSHA256: $((Get-FileHash -LiteralPath $PSCommandPath -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host "AcceptanceBundleSHA256: $((Get-FileHash -LiteralPath $out -Algorithm SHA256).Hash.ToUpperInvariant())"
Write-Host 'MizMutation: false'
