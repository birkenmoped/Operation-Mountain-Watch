---
document_id: OMW-TEST-TKOT-G5-READ-ONLY-ACCEPTANCE
status: BINDING
document_class: TEST_ACCEPTANCE_SPECIFICATION
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot G5 diagnostic test procedure
  - expected evidence and PASS or FAIL criteria
  - local build, mission embedding and result handoff
not_authoritative_for:
  - parking calibration
  - operational MOOSE-object acceptance
  - merge approval or Ready-for-Review approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: true
supersedes: []
superseded_by: []
---

# Tarinkot G5 – Read-only Diagnostics Acceptance

## Testziel

G5 erfasst ausschließlich den aktuellen Tarinkot-Mission-Editor- und MOOSE-Runtime-Datensatz. Der Test erzeugt keine operativen MOOSE-Objekte und verändert keinen CampaignState.

Zu ermitteln sind:

- die MOOSE-Airbase für DCS-Airbase-ID 9;
- normale und eindeutige Airbase-ID;
- interne Parking-Terminalwerte und Terminaltypen;
- tatsächliche Datentypen der drei Client-Parking-Werte;
- Vollständigkeit und Eindeutigkeit von Warehouse, Clients, AI-Seeds und Statics;
- vorhandene und fehlende Funktionszonen.

## Provenienz

```text
Mission: OMW_Template_v5_Salerno.miz
Mission SHA-256: 203c99ffa6e025a2d9f00dc899439b0167ed9d81981b612f3a8d4fd078c458f5
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Builder version: TKOT-G5-READONLY-2
Bundle: mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot_G5_ReadOnly.lua
```

## Build

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch
git fetch origin
git switch agent/tarinkot-object-contract-reconciliation
git pull --ff-only
git status -sb
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-tarinkot-air-operations-g5-diagnostics.ps1"

Get-FileHash `
  ".\mission\tests\tarinkot-air-operations\dist\OMW_AirOps_Tarinkot_G5_ReadOnly.lua" `
  -Algorithm SHA256
```

Builder-Hash und `Get-FileHash` müssen übereinstimmen. Erwartet werden außerdem:

```text
BuilderVersion: TKOT-G5-READONLY-2
ReadOnlyGuardPatternsChecked: 13
```

## Missionseinbindung

`OMW_Template_v5_Salerno.miz` im Missionseditor öffnen. Das Diagnosebundle wird als letzte `DO SCRIPT FILE`-Aktion nach `Moose.lua` und den bereits vorhandenen Projektbundles eingebunden. Danach Mission speichern.

Für den initialen G5-Lauf werden keine Gruppen, Statics, Zonen, Parking-Werte oder Warehouse-Einstellungen geändert. Eine im initialen Lauf erkannte einzelne Static-Typabweichung durfte für den Retest unter einem eigenen Ergebnisvertrag korrigiert werden.

## Lauf

- Mission mindestens 25 Sekunden ausführen.
- Durch G5 dürfen keine Luftfahrzeuge aktiviert oder gespawnt werden.
- Mission regulär beenden.
- Vor einem weiteren DCS-Start die aktuelle `dcs.log` sichern.

## Erwartete Nachweise

Start und Sperre:

```text
BEGIN Tarinkot G5 read-only diagnostics
version=TKOT-G5-READONLY-2 gitCommit=<ERWARTETER_COMMIT>
READ_ONLY_LOCK AIRWING=0 SQUADRON=0 PAYLOAD=0 SPAWN=0 AUFTRAG=0 COMMANDER=0 OPSTRANSPORT=0 CAMPAIGNSTATE_MUTATION=0 MIZ_MUTATION=0
```

Airbase und Parking:

```text
AIRBASE idRequested=9 name=<RUNTIME-NAME>
AIRBASE_ID_CANDIDATE_COUNT=1
PARKING_COUNT=<ZAHL_GRÖSSER_NULL>
```

Jeder Parking-Eintrag muss Terminal-ID, Null-basierte ID, Terminaltyp, Frei-Status, TOAC, Belegung, Koordinaten und die Lua-Datentypen der zentralen Werte ausgeben.

Client-Templates:

```text
CLIENT_US_TKOT_AH64D_01: unitParking value=20 luaType=string
CLIENT_US_TKOT_AH64D_02: unitParking value=8 luaType=number
CLIENT_US_TKOT_CH47F_01: unitParking value=3 luaType=number
```

Alle drei müssen Airbase-ID 9 als Zahl ausweisen.

AI-Seeds:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP: 2 x AH-64D_BLK_II
TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP: 1 x UH-60A
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP: 1 x CH-47Fbl1
```

Warehouse, Statics und Zonen:

```text
WAREHOUSE_ANCHOR name=WH_AIR_US_TARINKOT staticFound=true unitFound=false wrapperCount=1
WAREHOUSE_DETAILS type=container_20ft
STATIC_SUMMARY expected=12 missing=0
ZONE_SUMMARY expected=11 present=1 missing=10
CONTRACT_NAME_DUPLICATE_COUNT=0
```

Erwartete Abschlusszeile:

```text
RESULT G5_READ_ONLY_DIAGNOSTICS_COMPLETE status=PASS_STRUCTURE coreMissing=0 zonesMissing=10 mutationCount=0
```

## FAIL-Kriterien

Der Lauf ist FAIL bei mindestens einem der folgenden Punkte:

- falscher Commit oder falsche Builder-Version;
- Lua-, Scheduler- oder Timerfehler aus dem G5-Bundle;
- Airbase-ID 9 nicht auflösbar;
- kein Parking-Datensatz;
- Warehouse fehlt oder ist doppelt auflösbar;
- Client, Seed oder Static fehlt;
- Vertragsname doppelt;
- Abschlussstatus `FAIL_STRUCTURE`;
- `mutationCount` ungleich null;
- durch G5 ausgelöste Aktivierung oder Spawn-Aktivität.

Eine von zehn abweichende Zahl fehlender Zonen muss geprüft werden, ist aber nicht automatisch FAIL.

## Abnahmegrenze

Ein G5-PASS bestätigt nur die erfolgreiche read-only Datenerfassung. Nicht bestätigt werden Parking-Eignung, Rotorfreiheit, Start/Taxi, AIRWING/SQUADRON, Payloads, Missionen, Transport, COMMANDER oder Lifecycle.

Standardübergabe ist die aktuelle `dcs.log`. Die `.miz` wird zusätzlich benötigt, wenn Einbettung, Commit-Provenienz, Objektbestand oder Zonenbild unklar sind.

## Dokumentiertes Ergebnis

Initialer Lauf:

```text
mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-initial-fail.md
```

Maßgeblicher Retest-PASS:

```text
mission/tests/tarinkot-air-operations/results/2026-08-03-g5-read-only-diagnostics-retest-pass.md
```

Der Retest bestätigte den erwarteten Abschlussstatus auf Commit `8b2e62878f2421ba894a7abff7c12d526f4cea3d`. G5 ist damit `PASS_DCS`; G6 Parking-Kalibrierung ist freigegeben.
