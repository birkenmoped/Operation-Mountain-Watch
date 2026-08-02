---
document_id: OMW-AIR-SALERNO-MANIFEST
status: ACCEPTED_TECHNICAL_BASELINE
document_class: AIR_OPERATIONS_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - exact Salerno technical baseline accepted on this branch
  - Salerno AIRBASE, Warehouse, AIRWING, SQUADRON, payload and capability contract
  - Salerno Mission Editor object contract
  - Salerno parking calibration and parking deferral
  - accepted COMMANDER selection and dispatch path
not_authoritative_for:
  - repository-wide authority before integration to main
  - project-wide ORBAT outside Salerno
  - tactical CAS completion
  - return, recovery, persistence or OPSTRANSPORT
  - exact runtime parking compliance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier branch-local Salerno working manifests
  - unqualified claims that configured parkingIDs prove realized parking compliance
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
validated_in_dcs: true
acceptance_builder_version: SAL-COMMANDER-SELECTION-18
acceptance_bundle_sha256: 75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
acceptance_mission: OMW_Template_v5_Salerno.miz
acceptance_mission_sha256: 4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
acceptance_dcs_version: 2.9.28.26385
acceptance_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
acceptance_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# 81 – FOB Salerno Air Operations Manifest

## 1. Geltungsbereich

Dieses Manifest beschreibt den auf diesem Branch technisch akzeptierten Salerno-Knoten. Historische Evidenz, aktive OMW-ORBAT, Mission-Editor-Repräsentation, MOOSE-Konfiguration und beobachtete DCS-Laufzeit bleiben getrennte Ebenen.

Die main-fähige kanonische Fassung wird auf `agent/normalize-salerno-air-orbat` / PR #51 geführt. Dieser Branch bewahrt den vollständigen technischen Teststand und seine reproduzierbaren Entwicklungsartefakte.

## 2. Verbindlicher lokaler Bestand

```text
 8 AH-64D
 8 OH-58D
 7 UH-60 Assault
 3 UH-60 MEDEVAC
 6 CH-47
------------
32 Luftfahrzeuge
```

Der Bestand ist eine quellenbasierte OMW-Rekonstruktion. Er ist kein durch eine einzelne Quelle vollständig veröffentlichter Stichtags-TOE.

Bestandsinvariante:

```text
logical inventory
!= clients
!= statics
!= templates
!= registered asset groups
!= active AI aircraft
```

Besonders die vier CH-47-Statics, zwei CH-47-Clients und das CH-47-Template erhöhen den logischen Bestand von sechs nicht.

## 3. DCS- und MOOSE-Bindung

```text
DCS/MOOSE airbase: AIRBASE.Afghanistan.FOB_Salerno
observed airdromeId: 23
Warehouse: WH_AIR_US_SALERNO
AIRWING: AW_US_SALERNO
Zone: ZONE_AIR_US_SAL_CSAR_UNLOAD
```

`Khost` ist historischer Raumbezug beziehungsweise ein separater Flugplatz und wird nicht als zweites paralleles US-AIRWING für denselben Salerno-Knoten erzeugt.

## 4. SQUADRON-Vertrag

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

| SQUADRON | Template | logisch | Templategröße | registrierte Gruppen | Rest |
|---|---|---:|---:|---:|---:|
| AH-64D | `TPL_AIR_US_SAL_AH64D_CAS_2SHIP` | 8 | 2 | 4 | 0 |
| OH-58D | `TPL_AIR_US_SAL_OH58D_RECON_2SHIP` | 8 | 2 | 4 | 0 |
| UH-60 Assault | `TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP` | 7 | 2 | 3 | 1 |
| UH-60 MEDEVAC | `TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP` | 3 | 1 | 3 | 0 |
| CH-47 | `TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP` | 6 | 1 | 6 | 0 |

Gesamt:

```text
5 SQUADRONs
20 registrierte Warehouse-Assetgruppen
31 direkt durch Gruppentemplates repräsentierte Luftfahrzeuge
1 logische UH-60-Assault-Reserve
```

`SQUADRON:New()` zählt Gruppen, nicht Luftfahrzeuge. Die sieben Assault-UH-60 dürfen nicht als vier Two-Ship-Gruppen und damit acht Maschinen registriert werden.

## 5. Mission-Editor-Objektvertrag

Clients:

```text
CLIENT_US_SAL_AH64D_01
CLIENT_US_SAL_AH64D_02
CLIENT_US_SAL_OH58D_01
CLIENT_US_SAL_OH58D_02
CLIENT_US_SAL_CH47F_01
CLIENT_US_SAL_CH47F_02
```

Optionale UH-60L-Modclients:

```text
CLIENT_US_SAL_UH60L_01
CLIENT_US_SAL_UH60L_02
```

Templates:

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP
TPL_AIR_US_SAL_OH58D_RECON_2SHIP
TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP
TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP
TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP
```

Statics:

```text
3 AH-64D
4 OH-58D
3 UH-60 Assault
1 UH-60 MEDEVAC
4 CH-47F
15 gesamt
```

Alle KI-Templates sind `Late Activation` und `Uncontrolled = false`.

## 6. Technische Typabbildung

| Rolle | historisch | DCS |
|---|---|---|
| Attack | AH-64D | `AH-64D_BLK_II` |
| Scout/Recon | OH-58D | `OH58D` |
| Assault/MEDEVAC | UH-60-Familie | `UH-60A`; optionale UH-60L-Clients |
| Medium Lift | CH-47D | `CH-47Fbl1` |

Die Abweichung `CH-47D historisch -> CH-47Fbl1 in DCS` bleibt sichtbar dokumentiert.

## 7. Capability- und Payload-Baseline

Der akzeptierte Stand registriert die erforderlichen Capabilities und Payloads für:

- AH-64D CAS;
- OH-58D RECON;
- UH-60 Assault/Lift;
- UH-60 MEDEVAC;
- CH-47 Transport/Lift.

Im akzeptierten Lauf waren fünf fachliche Capability-/Payloadbereiche und zehn interne AIRWING-Payloadtabelleneinträge vorhanden.

AH-64D-CAS-Arbeitsbaseline:

```text
2 × M261 mit je 19 × M151 HE
2 × AGM-114K gesamt
300 × M789 HEDP / Mission-Editor-Wert 25 Prozent
IAFS/Robbie Tank
```

OH-58D-Arbeitsbaseline:

```text
M3P mit 500 Schuss
M260 mit M151 HE
```

## 8. Parking-Kalibrierung

Builder:

```text
SAL-ME-TERMINAL-CALIBRATION-1
```

Ergebnis:

```text
Runtime nodes: 44
Mappings: 32
Failures: 0
Result: PASS
```

Bestätigte ME->MOOSE-Zuordnung:

```text
ME07=T08, ME08=T13, ME09=T14, ME10=T15, ME11=T16, ME12=T17,
ME14=T09, ME15=T10, ME16=T11, ME17=T12,
ME18=T21, ME19=T22, ME20=T19,
ME24=T41, ME25=T42, ME26=T43, ME27=T44, ME28=T45,
ME29=T32, ME30=T33, ME31=T34, ME32=T35, ME33=T36,
ME34=T37, ME35=T38,
ME37=T26, ME38=T27, ME39=T28,
ME41=T30, ME42=T31, ME43=T23, ME44=T24
```

Client-TerminalIDs:

```text
T18 = ME13 CH-47 Client
T20 = ME21 CH-47 Client
T25 = ME36 AH-64D Client
T29 = ME40 AH-64D Client
T39 = ME22 OH-58D Client
T40 = ME23 OH-58D Client
```

Besondere Ausschlüsse:

```text
ME24 -> T41 statische OH-58-Fläche
ME25 -> T42 statische OH-58-Fläche
ME35 -> T38 Zufahrt / CSAR-Unload-Bereich
```

## 9. Parking-Vertrag und Rücknahme

Type-spezifische Arbeits-Pools wurden an SQUADRONs und an bereits registrierte Assets synchronisiert. Beispiel:

```text
AH-64D: T28,T30
UH-60:  T33,T34,T37
OH-58D: T43,T44
CH-47:  LEFT_HEAVY-Pool
```

Die interne Prüfung meldete:

```text
syncedAssets=20
violations=0
```

Trotzdem wurde visuell mindestens ein Apache auf einem reservierten beziehungsweise geschützten Spielerbereich beobachtet. Multi-Unit-Platzierung folgte dem erwarteten Type-Pool und der Clienttrennung nicht zuverlässig.

Daher gilt verbindlich:

```yaml
parking_calibration: PASS
parking_table_consistency: PASS
actual_multi_unit_spawn_compliance: NOT_ACCEPTED
client_exclusion_runtime_compliance: NOT_ACCEPTED
parking_state: DEFERRED
operational_parking_mutation: false
parking_gate_for_airwing_or_commander: false
```

Konfigurierte `parkingIDs`, eine bestandene Tabellenprüfung oder Safe-Parking-Konfiguration beweisen keine realisierte DCS-Unitposition.

## 10. Testchronologie

### Stage 15 – Parking deferred, direkter AIRWING-Dispatch

```text
SAL-PARKING-DEFERRED-15
```

CAS, RECON und LIFT wurden direkt an das AIRWING gegeben und erreichten Fortschritt. Dies bestätigte AIRWING, SQUADRONs, Capabilities und Payloads. Durch parallele Missionen war der Lauf jedoch nicht für eine kausale Spawn- oder Parkingbewertung geeignet.

### Stage 16 – gemischter COMMANDER-Test, ungültig

```text
SAL-COMMANDER-DISPATCH-16
```

Direkte CAS-/RECON-/LIFT-Aufträge liefen noch, als der COMMANDER-Test begann. Eine direkt in der Luft sichtbare Blackhawk stammte aus der direkten LIFT-Mission, nicht aus dem COMMANDER-CAS-Auftrag.

Zusätzlich wurde `planned` wegen eines fehlerhaften Groß-/Kleinschreibungsvergleichs nicht als Stillstand erkannt. Der ausgegebene PASS-Marker war ungültig.

### Stage 17 – isoliert, aber COMMANDER nicht gestartet

```text
SAL-COMMANDER-ISOLATED-17
```

Die direkten Missionen waren entfernt. Der Auftrag blieb korrekt als FAIL auf `planned`. Die Ursache lag im Testharness: `commander:Start()` fehlte.

### Stage 18 – korrigierte COMMANDER-Auswahl

```text
SAL-COMMANDER-SELECTION-18
```

Korrekte Sequenz:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

Beobachtet:

```text
NotReadyYet -> OnDuty
CanMission=true
AW_US_SALERNO ausgewählt
MissionAssign
AIRWING MissionRequest
AH-64 asset SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK_AID-111
OpsOnMission
planned -> requested -> scheduled -> started
FINAL status=PASS
graveyard={}
```

## 11. Akzeptierter Umfang

```yaml
airbase_resolution: PASS
warehouse_resolution: PASS
mission_editor_object_contract: PASS
airwing_construction_and_start: PASS
squadron_construction_and_registration: PASS
registered_asset_groups: 20
capabilities_and_payloads: PASS
commander_construction_and_start: PASS
commander_canmission_cas: PASS
commander_legion_selection: PASS
ah64_asset_assignment: PASS
auftrag_progress_to_started: PASS
controlled_cleanup: PASS
recorded_losses: 0
```

## 12. Nicht akzeptierter Umfang

```yaml
exact_parking_compliance: DEFERRED
cold_ground_spawn_visual_confirmation: NOT_ACCEPTED
tactical_target_engagement: NOT_TESTED
normal_mission_completion: NOT_TESTED
return_landing_recovery: NOT_TESTED
persistent_inventory_and_loss_booking: NOT_TESTED
opstransport: NOT_TESTED
multiplayer_and_long_duration: NOT_TESTED
theater_wide_production_commander: NOT_IMPLEMENTED
```

## 13. Verbindliche Lehren

1. Projektdokumentation und exakter MOOSE-Quellcode werden vor Codeänderungen geprüft.
2. Mission-Editor-Parkinglabels sind keine MOOSE-TerminalIDs.
3. Interne Konfiguration und tatsächliche DCS-Realisierung werden getrennt bewertet.
4. Nach SQUADRON-Änderungen sind bereits registrierte Assetkopien ausdrücklich zu prüfen.
5. Multi-Unit-Spawns benötigen Unitkoordinaten und nächsten Runtime-TerminalID.
6. Acceptance-Tests verwenden genau einen Dispatchpfad und einen erwarteten Assettyp.
7. FSM-Zustände werden normalisiert; `planned` und `unknown` sind kein Fortschritt.
8. Konstruktion ersetzt bei FSM-Klassen nicht den dokumentierten `Start()`.
9. Fehlversuche und ungültige Tests bleiben als historische Fixtures erhalten.
10. Der lokale Test-COMMANDER ist keine theaterweite Produktionsarchitektur.

## 14. Produktionsfolge

Die spätere produktive Mission soll genau einen theaterweiten BLUE COMMANDER in einem separaten Modul verwenden. Einzelne Flugplatzmodule stellen ihre AIRWINGs bereit; das COMMANDER-Modul wird danach geladen und bindet sie zentral.

Historische Jalalabad- und Salerno-Acceptance-Fixtures bleiben unverändert reproduzierbar.

## 15. Zugehörige Branch-Evidenz

- [`Runtime Acceptance und Lessons Learned`](evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md);
- [`Abschluss-/Nachfolger-Handoff`](handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md);
- [`Salerno Test README`](../mission/tests/salerno-air-operations/README.md);
- Parking-, Direct-Dispatch-, Stage-16-, Stage-17- und Stage-18-Ergebnisberichte unter `mission/tests/salerno-air-operations/results/`.
