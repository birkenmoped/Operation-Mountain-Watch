[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = Split-Path -Parent $PSScriptRoot
$baseBuilder = Join-Path $repoRoot 'tools\build-stage3-honaker-wright-full-response-acceptance-1.ps1'
$outputFile = Join-Path $repoRoot 'mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua'

if (-not (Test-Path -LiteralPath $baseBuilder -PathType Leaf)) {
  throw "Base Stage 3 builder not found: $baseBuilder"
}

$baseOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $baseBuilder 2>&1
if ($LASTEXITCODE -ne 0) {
  $baseOutput | ForEach-Object { Write-Host $_ }
  throw "Base Stage 3 builder failed with exit code $LASTEXITCODE"
}
if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
  throw "Base Stage 3 bundle not found: $outputFile"
}

$bundle = Get-Content -LiteralPath $outputFile -Raw -Encoding UTF8
$bundle = $bundle.Replace("`r`n", "`n")

function Replace-Literal([string]$Old, [string]$New, [string]$Label) {
  if (-not $script:bundle.Contains($Old)) {
    throw "Stage 3 Build 1-12 patch marker missing: $Label"
  }
  $script:bundle = $script:bundle.Replace($Old, $New)
}

function Replace-Regex([string]$Pattern, [string]$Replacement, [string]$Label) {
  if (-not [regex]::IsMatch($script:bundle, $Pattern)) {
    throw "Stage 3 Build 1-12 regex marker missing: $Label"
  }
  $script:bundle = [regex]::Replace($script:bundle, $Pattern, $Replacement, 1)
}

$platoonReplacement = @'
  state.qrfInfPlatoon = PLATOON:New(QRF_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_MIXED_6")
  state.qrfInfPlatoon:AddMissionCapability(AUFTRAG.Type.ONGUARD,100)
  state.brigade:AddPlatoon(state.qrfInfPlatoon)
  state.qrfVehiclePlatoon = nil
'@

$deploymentReplacement = @'
        if entry.role=="MIXED" then
          state.qrfInfDeployed=true
          state.qrfVehicleDeployed=true
        end
        state.qrfDeployed = state.qrfInfDeployed and state.qrfVehicleDeployed
'@

Replace-Literal '-- BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-11' '-- BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-12' 'builder version'
Replace-Literal '-- QRF: one rifle-squad GROUP plus one independent TPL_BLUE_GND_QRF_MIXED_4 vehicle GROUP; both use MOOSE ONGUARD + SetEngageDetected against one shared incident picture and each AUFTRAG is pinned to its own PLATOON with AssignCohort().' '-- QRF: one TPL_BLUE_GND_QRF_MIXED_6 GROUP containing 5 infantry + 1 MRAP; MOOSE ONGUARD + SetEngageDetected; no embark/disembark lifecycle.' 'header QRF contract'
Replace-Literal 'local INF_TEMPLATE = "TPL_BLUE_GND_INF_RIFLE_SQUAD_9"' 'local QRF_TEMPLATE = "TPL_BLUE_GND_QRF_MIXED_6"' 'QRF template constant'
Replace-Literal "local QRF_VEHICLE_TEMPLATE = `"TPL_BLUE_GND_QRF_MIXED_4`"`n" '' 'obsolete QRF vehicle template constant'
Replace-Literal 'local QRF_PERSONNEL = 9' 'local QRF_PERSONNEL = 5' 'QRF personnel quantity'

Replace-Regex '(?m)^  if state\.qrfInfPlatoon:CountAssets\(true,AUFTRAG\.Type\.ONGUARD\) < 1 then fail\("Honaker infantry QRF asset unavailable"\) return end\n  if state\.qrfVehiclePlatoon:CountAssets\(true,AUFTRAG\.Type\.ONGUARD\) < 1 then fail\("Honaker vehicle QRF asset unavailable"\) return end$' '  if state.qrfInfPlatoon:CountAssets(true,AUFTRAG.Type.ONGUARD) < 1 then fail("Honaker mixed QRF asset unavailable") return end' 'QRF availability gate'
Replace-Literal '  msg("QRF",string.format("Honaker requests mixed QRF package: one rifle squad + one independent vehicle group in shared %d-NM tactical area",QRF_TACTICAL_RADIUS_NM),12)' '  msg("QRF",string.format("Honaker requests mixed QRF package: 5 infantry + 1 MRAP in one 6-unit GROUP in shared %d-NM tactical area",QRF_TACTICAL_RADIUS_NM),12)' 'QRF request message'
Replace-Literal '    deploymentId="STAGE3-HONAKER-QRF-INF", entityId="HONAKER-QRF-INF", quantity=QRF_PERSONNEL, missionDemandId=TEST_ID,' '    deploymentId="STAGE3-HONAKER-QRF-MIXED-6", entityId="HONAKER-QRF-MIXED-6", quantity=QRF_PERSONNEL, missionDemandId=TEST_ID,' 'QRF deployment identity'
Replace-Regex '(?m)^  addMission\("INFANTRY", state\.qrfInfPlatoon, deployment\)\n  addMission\("VEHICLE", state\.qrfVehiclePlatoon, nil\)$' '  addMission("MIXED", state.qrfInfPlatoon, deployment)' 'single mixed QRF mission'
Replace-Regex '(?ms)^  state\.qrfInfPlatoon = PLATOON:New\(INF_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_INF"\)\n  state\.qrfInfPlatoon:AddMissionCapability\(AUFTRAG\.Type\.ONGUARD,100\)\n  state\.brigade:AddPlatoon\(state\.qrfInfPlatoon\)\n  state\.qrfVehiclePlatoon = PLATOON:New\(QRF_VEHICLE_TEMPLATE,1,"PLT_BLUE_GND_HONAKER_STAGE3_QRF_VEHICLE"\)\n  state\.qrfVehiclePlatoon:AddMissionCapability\(AUFTRAG\.Type\.ONGUARD,100\)\n  state\.brigade:AddPlatoon\(state\.qrfVehiclePlatoon\)$' $platoonReplacement 'single mixed QRF platoon'
Replace-Regex '(?m)^        if entry\.role=="INFANTRY" then state\.qrfInfDeployed=true end\n        if entry\.role=="VEHICLE" then state\.qrfVehicleDeployed=true end\n        state\.qrfDeployed = state\.qrfInfDeployed and state\.qrfVehicleDeployed$' $deploymentReplacement 'mixed QRF deployment gate'
Replace-Regex '(?m)^  need\(GROUP:FindByName\(INF_TEMPLATE\),INF_TEMPLATE\)\n  need\(GROUP:FindByName\(QRF_VEHICLE_TEMPLATE\),QRF_VEHICLE_TEMPLATE\)$' '  need(GROUP:FindByName(QRF_TEMPLATE),QRF_TEMPLATE)' 'QRF preflight gate'
Replace-Literal 'owner PatrolRoute Guard + mixed infantry/vehicle ONGUARD QRF + Wright ARTY' 'owner PatrolRoute Guard + 5-infantry/1-MRAP mixed ONGUARD QRF + Wright ARTY' 'ready message'
Replace-Literal 'owner PatrolRoute Guard + mixed infantry/vehicle QRF + PATROLZONE CAS' 'owner PatrolRoute Guard + 5-infantry/1-MRAP mixed QRF + PATROLZONE CAS' 'pass message'

if ($bundle.Contains('TPL_BLUE_GND_QRF_MIXED_4')) { throw 'Stage 3 Build 1-12 still contains obsolete TPL_BLUE_GND_QRF_MIXED_4.' }
if ($bundle.Contains('TPL_BLUE_GND_INF_RIFLE_SQUAD_9')) { throw 'Stage 3 Build 1-12 still contains obsolete separate 9-man QRF infantry template.' }
if ($bundle.Contains('QRF_VEHICLE_TEMPLATE')) { throw 'Stage 3 Build 1-12 still contains obsolete QRF_VEHICLE_TEMPLATE identifier.' }
if ($bundle.Contains('`n')) { throw 'Stage 3 Build 1-12 contains literal backtick-n text.' }
foreach ($marker in @(
  'TPL_BLUE_GND_QRF_MIXED_6',
  'local QRF_PERSONNEL = 5',
  'addMission("MIXED", state.qrfInfPlatoon, deployment)',
  'PLT_BLUE_GND_HONAKER_STAGE3_QRF_MIXED_6',
  '5 infantry + 1 MRAP',
  'AUFTRAG:NewONGUARD',
  'SetEngageDetected',
  'mission:AssignCohort(platoon)'
)) {
  if (-not $bundle.Contains($marker)) { throw "Stage 3 Build 1-12 missing reconciled marker: $marker" }
}

[System.IO.File]::WriteAllText($outputFile, $bundle, [System.Text.UTF8Encoding]::new($false))
$hash = (Get-FileHash -LiteralPath $outputFile -Algorithm SHA256).Hash.ToUpperInvariant()
$commit = (& git -C $repoRoot rev-parse HEAD).Trim()
$generatedUtc = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

Write-Host "Built: $outputFile"
Write-Host 'BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-12'
Write-Host 'TestId: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1'
Write-Host "GeneratedUtc: $generatedUtc"
Write-Host "GitCommit: $commit"
Write-Host 'QRFTemplate: TPL_BLUE_GND_QRF_MIXED_6'
Write-Host 'QRFComposition: 5 infantry + 1 MRAP in one DCS/MOOSE GROUP'
Write-Host 'QRFEmbarkDisembark: false'
Write-Host 'QRFPersonnelDebit: 5 GROUND_PERSONNEL'
Write-Host "SHA256: $hash"
Write-Host 'MizMutation: false'
