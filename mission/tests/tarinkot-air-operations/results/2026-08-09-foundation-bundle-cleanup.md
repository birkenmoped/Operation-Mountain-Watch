---
document_id: OMW-TEST-TKOT-FOUNDATION-BUNDLE-CLEANUP-2026-08-09
status: DRAFT
document_class: CHANGE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot foundation-only bundle cleanup on agent/tarinkot-airops-foundation-cleanup
  - removal of G8C/G8D test-dispatch logic from the active Tarinkot AirOps bundle
not_authoritative_for:
  - tactical AUFTRAG acceptance
  - deterministic vertical departure or recovery
  - branch-independent DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-airops-foundation-cleanup
source_commit: 585f3c46d4ff0a4b167c984d427bcdb356138e69
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot AirOps – Rückbau auf AIRWING-/SQUADRON-Grundlage

## 1. Anlass

Nach Abschluss der Tarinkot-AirOps-Diagnostik blieb in der aktuellen Mission weiterhin der G8D-AH-64-Testdispatch aktiv. Der DCS-Lauf vom 9. August 2026 zeigte neben dem G7-Foundation-Bundle weiterhin:

```text
[OMW][AirOps.TKOT.G8D.AH64JalalabadProfileAB] MISSION_ADDED ...
[OMW][AirOps.TKOT.G8D.AH64JalalabadProfileAB] FLIGHT_ON_MISSION ...
```

Damit wurden weiterhin Tarinkot-Testeinheiten für den abgeschlossenen Diagnoseversuch erzeugt. Der Projektinhaber hat angeordnet, diesen Zustand nach dem Jalalabad-Cleanup ebenfalls zurückzubauen.

## 2. Beibehaltene Foundation

Der neue Foundation-Build behält ausschließlich die für den Tarinkot-AIRWING-/SQUADRON-Grundbetrieb benötigten Informationen:

```text
AW_US_TKOT_TF_ATTACK_3_101_AVN
SQ_US_TKOT_AH64D_3_101_AVN
SQ_US_TKOT_UH60_TF_ATTACK
SQ_US_TKOT_CH47_B_1_52_AVN
```

Registrierter MOOSE-Bestand:

```text
AH-64D  2 Gruppen x 2 Luftfahrzeuge = 4
UH-60    2 Gruppen x 1 Luftfahrzeug  = 2
CH-47    1 Gruppe  x 1 Luftfahrzeug  = 1
-----------------------------------------
5 Gruppen / 7 Luftfahrzeuge
```

Die Trennung zu Statics, Clients und logischem Gesamtbestand bleibt unverändert bestehen.

## 3. Verbindlicher Parking-Vertrag

Der neue Foundation-Build übernimmt ausschließlich die auf `main` verbindliche Zuordnung aus `OMW-AIR-TKOT-PARKING-LAYOUT`:

```yaml
AH64: [20, 19]
UH60: [23, 27, 30]
CH47: [32, 29, 10]
```

Die Client-Terminals `21`, `8` und `3` werden nicht als KI-Parking verwendet.

## 4. Entfernte Test-/Diagnostikschicht

Der neue produktionsnahe Foundation-Build übernimmt keine G7-Acceptance-Diagnostik und keinen späteren Testdispatch. Insbesondere werden nicht erzeugt:

```text
G8C/G8D test missions
AUFTRAG:New* test missions
AIRWING:AddMission(...)
OPSTRANSPORT:New*
COMMANDER:New*
MISSION_ADDED / FLIGHT_ON_MISSION test harness
TAKEOFF_TIMEOUT test result logic
```

Die historischen G5-G8D-Quellen und Ergebnisberichte bleiben als `HISTORICAL_TEST_FIXTURE` beziehungsweise branchgebundene Evidenz erhalten. Sie werden nicht gelöscht.

## 5. MOOSE-First-Abgleich

Verwendeter Projektstand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Foundation verwendet ausschließlich die bereits im Projekt verifizierten MOOSE-AIRWING-/SQUADRON-/Payload-APIs. Es wird keine Native-DCS-Parallelimplementierung und kein MOOSE-Override eingeführt.

## 6. Buildgrenze

Source:

```text
scripts/air-operations/OMW_AirOps_Tarinkot_Bootstrap.lua
```

Builder:

```text
tools/build-tarinkot-air-operations-foundation.ps1
```

Generiertes lokales Artefakt:

```text
mission/tests/tarinkot-air-operations/dist/OMW_AirOps_Tarinkot.lua
```

## 7. Noch erforderliche Verifikation

Vor einem Merge muss der lokale Builder ausgeführt und der erzeugte SHA-256-Wert dokumentiert werden. Anschließend muss im Mission Editor der bisherige Tarinkot-G7/G8D-Testaufbau durch genau ein Foundation-`DO SCRIPT FILE` ersetzt werden.

Der DCS-Lauf muss mindestens bestätigen:

```text
AIRWING running
3 SQUADRONs registered
5 MOOSE asset groups / 7 registered aircraft
3 role payload registrations
0 missions created by the Tarinkot foundation bundle
0 transports created
0 F10 controls
0 G8C/G8D test-dispatch markers
0 spontaneous Tarinkot test launch
```

Bis zu diesem Lauf bleibt `validated_in_dcs: false`.
