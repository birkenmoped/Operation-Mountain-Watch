---
document_id: OMW-TEST-JBAD-FOUNDATION-BUNDLE-CLEANUP-2026-08-09
status: DRAFT
document_class: CHANGE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - Jalalabad foundation-only bundle cleanup on agent/jalalabad-airops-foundation-cleanup
  - removal of Phase-1 F10 mission-control/test-dispatch logic from the rebuilt Jalalabad bundle
  - runtime correction of the Jalalabad generic UH-60 Mission Editor seed
not_authoritative_for:
  - new tactical AUFTRAG acceptance
  - OPSTRANSPORT acceptance
  - branch-independent DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/jalalabad-airops-foundation-cleanup
source_commit: be924be87d261c5b840910c5f75cd29e879bc387
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Jalalabad AirOps – Rückbau auf AIRWING-/SQUADRON-Grundlage

## 1. Anlass

Der Projektinhaber hat am 9. August 2026 angeordnet, die noch im Jalalabad-Phase-1-Bundle enthaltenen F10-Testmissionen und die zugehörige Teststeuerung zurückzubauen. Das neu erzeugte `OMW_AirOps_Jalalabad.lua` soll nur die für den Jalalabad-AIRWING-/SQUADRON-Grundbetrieb erforderliche Konfiguration enthalten.

Die historischen Phase-1-Testquellen und -ergebnisse auf ihren bisherigen Branches bleiben als Entwicklungs- und Acceptance-Evidenz erhalten. Sie werden nicht als Produktionslogik in den neuen Foundation-Build übernommen.

## 2. Beibehaltene Foundation

Die aktuelle `BINDING`-Baseline aus `docs/21-jalalabad-air-operations-manifest.md` bleibt maßgeblich:

```text
AW_US_JALALABAD
SQ_US_JBAD_OH58D_6_6_CAV
SQ_US_JBAD_AH64D_B_1_10_AVN
SQ_US_JBAD_UH60_UTILITY_MEDEVAC
SQ_US_JBAD_CH47_HEAVYLIFT
```

Logischer Bestand:

```text
OH-58D  24 aircraft / 12 two-ship asset groups
AH-64D   8 aircraft /  4 two-ship asset groups
UH-60    8 aircraft /  8 single-ship asset groups
CH-47    8 aircraft /  8 single-ship asset groups
```

Beibehalten werden außerdem die historisch DCS-bestätigten exklusiven SQUADRON-Parking-Pools und die Jalalabad-Static-Parking-Blacklist:

```yaml
OH58D: [19, 43, 6, 5, 48]
AH64D: [26, 51, 11]
UH60:  [10, 8, 1]
CH47:  [28, 44, 0, 41, 9, 25, 18, 42]
blacklist: [23, 35, 37, 49]
```

Die Foundation registriert weiterhin die SQUADRON-Missionsfähigkeiten und AIRWING-Payloads, erzeugt aber selbst keine Mission.

## 3. Entfernte Test-/Dispatch-Schicht

Der neue Builder übernimmt insbesondere nicht mehr die historischen Phase-1-Module für:

```text
runtime observer
test manifest
mission factory
test controller
F10 test and acceptance menu
Phase-1 readiness/routing
Phase-1 MOOSE logistics test orchestration
```

Der generierte Bundle darf insbesondere keine folgenden Laufzeitkonstrukte erzeugen:

```text
F10 mission controls
AUFTRAG:New* test missions
OPSTRANSPORT:New*
COMMANDER:New*
AIRWING:AddMission(...)
ZONE_TEST_US_JBAD_* test-object dependency
```

## 4. MOOSE-First-Abgleich

Verwendeter Projektstand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich gepinnten Quellstand sind die verwendeten Foundation-APIs vorhanden, darunter `SQUADRON:New`, `SQUADRON:SetGrouping`, `SQUADRON:SetParkingIDs`, `SQUADRON:SetTakeoffCold`, SQUADRON-Missionsfähigkeiten sowie AIRWING-/Payload-Funktionen. Die bestehende Jalalabad-Technical-Baseline hatte AIRWING, vier SQUADRONs, Payloadregistrierung, Safe Parking und AIRWING-Start bereits branchgebunden in DCS bestätigt.

Die Änderung führt keine Native-DCS-Parallelimplementierung und keinen MOOSE-Override ein.

## 5. Neue Buildgrenze

Source:

```text
scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua
```

Builder:

```text
tools/build-jalalabad-air-operations-foundation.ps1
```

Generiertes lokales Artefakt:

```text
mission/tests/jalalabad-air-operations/dist/OMW_AirOps_Jalalabad.lua
```

Der Builder besitzt einen statischen Guard gegen die entfernten F10-/Phase-1-/Dispatch-Muster.

## 6. Erster DCS-Lauf des Foundation-Bundles

Der erste Lauf des neuen Foundation-Bundles war **kein PASS**. Der Log zeigte nach erfolgreicher Registrierung der OH-58D- und AH-64D-SQUADRONs:

```text
[OMW][AirOps.JBAD.Foundation] ERROR ... Missing Mission Editor template: TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
```

Root Cause: Die erste Foundation-Fassung hatte die historischen physischen UH-60 Lead-/Cover-Template-Namen wieder eingeführt. Die tatsächlich validierte Jalalabad-Mission verwendet jedoch seit der UH-60-Konsolidierung einen gemeinsamen physischen Seed:

```text
TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP
```

Beide logischen MOOSE-Payloadrollen werden aus diesem Seed erzeugt. Das entspricht der zuvor dokumentierten und in DCS bestätigten Jalalabad-Konsolidierung.

Korrektur:

```text
bf179dda70d32ad0da3b4f465b8b5793e71f6e11
Use generic Jalalabad UH-60 template seed
```

Das verbindliche Jalalabad-Manifest wurde auf denselben physischen Vier-Template-Stand abgeglichen.

## 7. Noch erforderliche Verifikation

Nach der Korrektur muss der Bundle lokal neu gebaut, im Mission Editor erneut über `DO SCRIPT FILE` zugewiesen, gespeichert und in DCS erneut gestartet werden.

Der Wiederholungslauf muss mindestens bestätigen:

```text
AIRWING running
4 SQUADRONs registered
48 logical/warehouse aircraft represented by 32 MOOSE asset groups
5 payload records registered
0 missions created by the Jalalabad foundation bundle
0 transports created
0 F10 Jalalabad Phase-1 test controls
0 spontaneous Jalalabad aircraft launch
```

Bis zu diesem Lauf bleibt `validated_in_dcs: false`.
