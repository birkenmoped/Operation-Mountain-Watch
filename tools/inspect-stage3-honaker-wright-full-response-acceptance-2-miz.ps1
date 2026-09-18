[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$MizPath
)

$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest

$repoRoot=Split-Path -Parent $PSScriptRoot
$acceptanceFile=Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_2.lua'
$expectedMooseSha256='E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915'
$acceptanceName='OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_2.lua'
$oldAcceptanceName='OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'

if(-not(Test-Path -LiteralPath $MizPath -PathType Leaf)){throw "Mission file not found: $MizPath"}
if(-not(Test-Path -LiteralPath $acceptanceFile -PathType Leaf)){throw "Local Acceptance-2 bundle not found: $acceptanceFile"}

$expectedAcceptanceHash=(Get-FileHash -LiteralPath $acceptanceFile -Algorithm SHA256).Hash.ToUpperInvariant()
$mizHash=(Get-FileHash -LiteralPath $MizPath -Algorithm SHA256).Hash.ToUpperInvariant()

Add-Type -AssemblyName System.IO.Compression.FileSystem
$resolvedMiz=(Resolve-Path -LiteralPath $MizPath).Path
$zip=[System.IO.Compression.ZipFile]::OpenRead($resolvedMiz)
try {
  function Get-EntryBytes([System.IO.Compression.ZipArchive]$Archive,[string]$EntryName){
    $entry=$Archive.GetEntry($EntryName)
    if(-not $entry){return $null}
    $stream=$entry.Open()
    try {
      $memory=New-Object System.IO.MemoryStream
      try {$stream.CopyTo($memory); return $memory.ToArray()} finally {$memory.Dispose()}
    } finally {$stream.Dispose()}
  }
  function Get-BytesSha256([byte[]]$Bytes){
    $sha=[System.Security.Cryptography.SHA256]::Create()
    try {return ([System.BitConverter]::ToString($sha.ComputeHash($Bytes))).Replace('-','').ToUpperInvariant()} finally {$sha.Dispose()}
  }

  $missionBytes=Get-EntryBytes $zip 'mission'
  if(-not $missionBytes){throw 'MIZ is missing internal mission file.'}
  $missionHash=Get-BytesSha256 $missionBytes
  $missionText=[System.Text.Encoding]::UTF8.GetString($missionBytes)

  $luaEntries=@($zip.Entries | Where-Object {$_.FullName -like 'l10n/DEFAULT/*.lua'} | Sort-Object FullName)
  $mooseEntries=@($luaEntries | Where-Object {$_.Name -ieq 'Moose.lua'})
  if($mooseEntries.Count -ne 1){throw "Expected exactly one embedded Moose.lua, found $($mooseEntries.Count)."}
  $mooseBytes=Get-EntryBytes $zip $mooseEntries[0].FullName
  $mooseHash=Get-BytesSha256 $mooseBytes

  $a2Entries=@($luaEntries | Where-Object {$_.Name -eq $acceptanceName})
  $a1Entries=@($luaEntries | Where-Object {$_.Name -eq $oldAcceptanceName})
  $a2Hash=$null
  if($a2Entries.Count -eq 1){$a2Hash=Get-BytesSha256 (Get-EntryBytes $zip $a2Entries[0].FullName)}

  $resourceMap=@{}
  $resourceRegex=[regex]'\["(?<key>ResKey_Action_[^"]+)"\]\s*=\s*"(?<file>[^"]+\.lua)"'
  foreach($m in $resourceRegex.Matches($missionText)){$resourceMap[$m.Groups['key'].Value]=$m.Groups['file'].Value}

  $actions=@()
  $actionRegex=[regex]'a_do_script_file\s*\(\s*getValueResourceByKey\s*\(\s*"(?<key>ResKey_Action_[^"]+)"\s*\)\s*\)'
  foreach($m in $actionRegex.Matches($missionText)){
    $key=$m.Groups['key'].Value
    $file=if($resourceMap.ContainsKey($key)){$resourceMap[$key]}else{'<UNRESOLVED>'}
    $actions+=[pscustomobject]@{Index=$m.Index;Key=$key;File=$file}
  }
  $actions=@($actions | Sort-Object Index)

  $mooseActionIndex=-1
  $a2ActionIndex=-1
  $a1ActionIndex=-1
  for($i=0;$i -lt $actions.Count;$i++){
    if($actions[$i].File -ieq 'Moose.lua' -and $mooseActionIndex -lt 0){$mooseActionIndex=$i}
    if($actions[$i].File -eq $acceptanceName -and $a2ActionIndex -lt 0){$a2ActionIndex=$i}
    if($actions[$i].File -eq $oldAcceptanceName -and $a1ActionIndex -lt 0){$a1ActionIndex=$i}
  }

  $requiredNames=@(
    'BadGuys_A3_HONAKER','TPL_BLUE_GND_INF_RIFLE_SQUAD_9','TPL_BLUE_GND_QRF_MIXED_6',
    'WH_BLUE_GND_HONAKER','WH_BLUE_GND_WRIGHT','TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2',
    'TPL_BLUE_GND_SUP_M1083','ZON_BLUE_GND_WRIGHT_RESUPPLY','ZON_BLUE_LOG_SLG_JALALABAD_01',
    'OMW_BLUE_LZ_WRIGHT_01','OMW_FlightPath','OMW_FlightPath_WEST',
    'TPL_AIR_US_JBAD_AH64D_CAS_2SHIP','TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP'
  )
  $missing=@()
  foreach($name in $requiredNames){if(-not $missionText.Contains($name)){$missing+=$name}}

  Write-Host 'Stage3Acceptance2MizInspection: COMPLETE'
  Write-Host "Mission: $resolvedMiz"
  Write-Host "MissionSHA256: $mizHash"
  Write-Host "InternalMissionSHA256: $missionHash"
  Write-Host "ExpectedAcceptance2SHA256: $expectedAcceptanceHash"
  Write-Host "EmbeddedMooseSHA256: $mooseHash"
  Write-Host "PinnedMooseMatch: $($mooseHash -eq $expectedMooseSha256)"
  Write-Host "Acceptance2EntryCount: $($a2Entries.Count)"
  Write-Host "Acceptance2EmbeddedSHA256: $a2Hash"
  Write-Host "Acceptance2HashMatch: $($a2Hash -eq $expectedAcceptanceHash)"
  Write-Host "HistoricalAcceptance1EntryCount: $($a1Entries.Count)"
  Write-Host "MooseLoadActionIndexZeroBased: $mooseActionIndex"
  Write-Host "Acceptance2LoadActionIndexZeroBased: $a2ActionIndex"
  Write-Host "HistoricalAcceptance1LoadActionIndexZeroBased: $a1ActionIndex"
  if($a2ActionIndex -ge 0){Write-Host "MooseBeforeAcceptance2: $($mooseActionIndex -ge 0 -and $mooseActionIndex -lt $a2ActionIndex)"}
  Write-Host "RequiredNameSmokeMissingCount: $($missing.Count)"
  if($missing.Count -gt 0){Write-Host ('RequiredNameSmokeMissing: '+($missing -join ', '))}
  Write-Host 'LuaDoScriptFileOrder:'
  for($i=0;$i -lt $actions.Count;$i++){Write-Host ("  [{0}] {1} -> {2}" -f $i,$actions[$i].Key,$actions[$i].File)}
  Write-Host 'MizMutation: false'
} finally {$zip.Dispose()}
