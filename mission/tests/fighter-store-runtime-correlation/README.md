# Fighter Store Runtime Correlation

Status: `PLANNED_RUNTIME_GATE`

## Ziel

Dieser Test schließt ausschließlich die drei nach der finalisierten Initial-Stock-Entscheidung noch offenen technischen Fighter-Store-Mappings:

```text
F-15E STRIKE GBU-31(V)1/B -> exact STORAGE item
F-15E STRIKE GBU-31(V)3/B -> exact STORAGE item
F-16 deployment AIM-9     -> exact DCS/MOOSE STORAGE item
```

Die strategischen Initialmengen sind bereits abgeschlossen und werden durch diesen Test nicht neu berechnet.

## Basis

```text
Base branch: agent/warehouse-resource-final-acceptance
Base commit: 1c74146641bc8ca21e0f39240754391cf7ce28b7
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## MOOSE-First

Der Gate führt keine neue Warehouse- oder Aircraft-Lifecycle-Implementierung ein. Er kombiniert ausschließlich bereits im Projekt verwendete und source-/runtime-geprüfte Pfade:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
AIRWING:NewPayload()
AUFTRAG:NewORBIT()
AUFTRAG:SetRequiredAssets()
AUFTRAG:AssignSquadrons()
AUFTRAG:AddRequiredPayload()
AUFTRAG:SetTime()
AUFTRAG:SetDuration()
AUFTRAG:SetROE()
AUFTRAG:SetROT()
AIRWING:AddMission()
AIRWING.OnAfterFlightOnMission
SET_CLIENT
CLIENT/UNIT:GetAmmo()
EVENTS.WeaponRearm
SCHEDULER
MESSAGE
```

F-15E wird über die bestehende produktive Bagram-AIRWING/SQUADRON-Foundation materialisiert. Für F-16 wird bewusst der bereits akzeptierte native Ground-Crew-Rearm-Pfad verwendet. Es gibt keine direkte DCS-Warehouse-Mutation und keinen projektspezifischen Spawn-/Return-/Rearm-Controller.

## Phase 1 – F-15E STRIKE

Verwendetes Mission-Editor-Template:

```text
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
```

Der Test registriert das konkrete STRIKE-Template nur testlokal als ORBIT-Payload und lässt genau eine Two-Ship-Assetgruppe über den vorhandenen Bagram-F-15E-SQUADRON-Pfad materialisieren. Die Mission ist `WeaponHold` / `NoReaction`.

Zu prüfende Kandidaten aus dem gepinnten `Moose.lua` und dem Mission-Editor-Payload:

```text
GBU-31(V)1/B -> weapons.bombs.GBU_31
GBU-31(V)3/B -> weapons.bombs.GBU_31_V_3B
```

Da das Template je Aircraft genau eine Bombe jeder Variante trägt und `Grouping=2` gilt, erwartet der Gate:

```text
weapons.bombs.GBU_31      delta = -2
weapons.bombs.GBU_31_V_3B delta = -2
```

Nur wenn beide Deltas beobachtet werden, wird Phase 2 freigegeben.

## Phase 2 – F-16 AIM-9

Nach erfolgreicher F-15E-Korrelation meldet der Gate:

```text
F16_PHASE_READY
```

Dann:

1. einen Bagram-F-16-Client betreten;
2. über das normale DCS-Ground-Crew-Rearm **genau einen AIM-9M auf Station 2 und genau einen AIM-9M auf Station 8 hinzufügen**;
3. alle anderen Stores unverändert lassen;
4. auf Abschluss des Rearm warten.

Der Gate nimmt beim Binden des Clients eine feste STORAGE-/Aircraft-Baseline und beobachtet anschließend mit 2-Sekunden-Intervall. Nach 15 Sekunden ohne weitere Änderung wird die kumulative Differenz ausgewertet.

Ein automatischer `PASS` für diese Phase setzt voraus:

```text
exactly one STORAGE weapon key decreases by 2
AND
exactly one aircraft ammo descriptor increases by 2
```

Der konkrete STORAGE-Key wird als

```text
F16_AIM9_MAPPING_PASS storageItem=...
```

protokolliert. Bei mehreren gleichzeitig veränderten Stores endet der Test als `COMPLETE_WITH_GAPS`; die Rohdeltas bleiben für die Logauswertung vollständig erhalten.

## Grenzen

Der Gate verändert nicht:

```text
CampaignState
STORAGE quantities through Set/Add/Remove methods
productive AIRWING/SQUADRON configuration
Mission Editor templates
initial stock decisions
external-tank policy
```

Der F-15E-ORBIT bleibt während der F-16-Phase bewusst aktiv, damit kein F-15E-Normalreturn dieselbe Bagram-STORAGE-Beobachtungsphase mit Recredits überlagert.

## Builder

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-fighter-store-runtime-correlation.ps1
```

Ausgabe:

```text
mission/tests/fighter-store-runtime-correlation/dist/OMW_Fighter_Store_Runtime_Correlation.lua
```

## Acceptance

`VALIDATED` oder `ACCEPTED_TECHNICAL_BASELINE` ist erst nach Rückgabe der real ausgeführten Mission mit vollständiger Provenienz zulässig:

```text
source/builder commit
BuilderVersion
bundle SHA-256
executed MIZ SHA-256
DCS version
MOOSE commit / Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256
observed F15_STRIKE_MAPPING_PASS
observed F16_AIM9_MAPPING_PASS or documented COMPLETE_WITH_GAPS
```
