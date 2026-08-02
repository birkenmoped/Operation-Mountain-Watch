---
document_id: OMW-AIR-SALERNO-MANIFEST
status: BINDING
document_class: AIR_OPERATIONS_MANIFEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Salerno-specific active local aircraft inventory and representation contract
  - Salerno Mission Editor naming and object structure
  - Salerno AIRBASE, AIRWING, SQUADRON, Warehouse, payload and capability contract
  - accepted Salerno AIRWING/SQUADRON/COMMANDER technical baseline
  - Salerno parking-calibration evidence and explicit parking deferral
  - Salerno-specific implementation lessons and unresolved boundaries
not_authoritative_for:
  - project-wide air ORBAT outside FOB Salerno
  - project-wide player limits outside the rules inherited from OMW-AIR-ACTIVE-ORBAT
  - tactical CAS objective completion
  - return, landing, recovery or persistent inventory booking
  - theater-wide production COMMANDER architecture
  - exact runtime parking compliance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Salerno manifests using document numbers 51-53
  - Khost as the presumed DCS airbase binding for airdromeId 23
  - CH-47D as the Mission Editor type for current Salerno CH-47 objects
  - unqualified claims that configured parkingIDs prove realized parking compliance
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_source_branch: agent/salerno-read-only-diagnostics
acceptance_source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
acceptance_builder_version: SAL-COMMANDER-SELECTION-18
acceptance_bundle_sha256: 75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
acceptance_mission: OMW_Template_v5_Salerno.miz
acceptance_mission_sha256: 4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
acceptance_dcs_version: 2.9.28.26385
acceptance_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
acceptance_moose_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# 81 – FOB Salerno Air Operations Manifest

## 1. Zweck, Autorität und Status

Dieses Manifest ist die kanonische Salerno-Baseline für Operation Mountain Watch. Es verbindet vier bewusst getrennte Ebenen:

1. historische und quellenkritische Einordnung;
2. aktive OMW-ORBAT und logischer Bestand;
3. Mission-Editor- und MOOSE-Objektvertrag;
4. exakt abgegrenzte technische DCS-Acceptance.

Vorrangige projektinterne Quellen sind:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md);
- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md).

Technische Acceptance ist ausschließlich für den in der Frontmatter bezeichneten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand gültig. Sie macht die noch offene Parking-, Recovery-, Persistenz- oder Gesamtmissionslogik nicht automatisch produktionsreif.

## 2. Historische Einordnung

Für Juli 2011 sind auf FOB Salerno unter anderem belegt:

```text
TF Duke / 3rd BCT, 1st Infantry Division
TF Centaur / 1-6 Field Artillery
TF Blue Spader / 1-26 Infantry
TF Tigershark / 1-10 Attack Aviation
```

TF Tigershark war TF Falcon / 10th Combat Aviation Brigade unterstellt und unterstützte Khost und Paktya.

B Company, 7-158 Aviation ist ab April 2011 als CH-47-Company-Hauptquartier auf FOB Salerno dokumentiert. Der zugehörige Pool umfasste 25 CH-47 und war auf Bagram, FOB Salerno und FOB Shank verteilt. Die OMW-Aufteilung `13/6/6` ist eine dokumentierte Projektentscheidung und keine Behauptung, die historische Quelle habe diese exakte Aufteilung wörtlich veröffentlicht.

## 3. Verbindlicher logischer Salerno-Bestand

```text
 8 AH-64D
 8 OH-58D
 7 UH-60 Assault
 3 UH-60 MEDEVAC
 6 CH-47
------------
32 Luftfahrzeuge
```

Evidenzstatus:

| Komponente | Wert | Einstufung |
|---|---:|---|
| AH-64D | 8 | `SOURCE_DERIVED / CORROBORATED_PLAUSIBLE` |
| OH-58D | 8 | `SOURCE_DERIVED / CORROBORATED_PLAUSIBLE` |
| UH-60 Assault | 7 | `RECONSTRUCTED_LOCAL_INVENTORY` |
| UH-60 MEDEVAC | 3 | `RECONSTRUCTED_LOCAL_INVENTORY` |
| CH-47 | 6 | `RECONSTRUCTED_POOL_ALLOCATION` |

Diese Werte sind eine quellenbasierte OMW-Kampagnenentscheidung innerhalb des Gesamtzeitraums. Sie sind keine Behauptung einer vollständig veröffentlichten Stichtags-TOE.

## 4. Bestands- und Repräsentationsvertrag

Der logische Bestand ist strikt getrennt von:

- Client-Reservierungen;
- registrierten Warehouse-Assetgruppen;
- aktiven KI-Luftfahrzeugen;
- Late-Activation-Templates;
- sichtbaren Statics;
- virtueller Reserve;
- beschädigten und endgültig verlorenen Luftfahrzeugen.

```text
LOGICAL_INVENTORY
!= STATIC_COUNT
!= CLIENT_COUNT
!= TEMPLATE_COUNT
!= REGISTERED_GROUP_ASSET_COUNT
!= ACTIVE_AI_COUNT
```

Statics, Clients, Templates und aktive Gruppen sind Repräsentationen beziehungsweise Authoring-Objekte desselben Bestands. Sie dürfen ihn nicht mehrfach erhöhen.

Besonders für CH-47 gilt:

```text
4 sichtbare Statics
+ 2 Client-Reservierungen
+ 1 Late-Activation-Template
!= 7 verfügbare CH-47
```

Der logische Bestand bleibt sechs.

## 5. DCS-Airbase- und Warehouse-Vertrag

Historische Ortsbezeichnung:

```text
FOB Salerno, Khost
```

Technische DCS-/MOOSE-Bindung:

```text
AIRBASE.Afghanistan.FOB_Salerno
observed airdromeId = 23
```

Warehouse-Anker:

```text
WH_AIR_US_SALERNO
```

`Khost` bezeichnet in historischen Quellen den geografischen Raum beziehungsweise einen separaten Flugplatz. Für den Salerno-Knoten wird nicht zusätzlich `AIRBASE.Afghanistan.Khost` als zweites paralleles US-AIRWING gebunden.

Der Runtime-Diagnoselauf bestätigte:

```yaml
airbase_found: true
airbase_name: FOB Salerno
airbase_id: 23
warehouse_anchor_found: true
salerno_zone_found: true
```

## 6. MOOSE-Objektstruktur

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

Die Rollenbezeichnungen bleiben dort absichtlich generisch, wo eine exakte historische Company-Zuordnung nicht ausreichend belegt ist. Es werden keine Einheitsnamen erfunden.

## 7. SQUADRON- und Assetvertrag

| SQUADRON | Template | logische Luftfahrzeuge | Einheiten je Template | registrierte Gruppen | Rest |
|---|---|---:|---:|---:|---:|
| `SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK` | `TPL_AIR_US_SAL_AH64D_CAS_2SHIP` | 8 | 2 | 4 | 0 |
| `SQ_US_SAL_OH58D_B_6_6_CAV` | `TPL_AIR_US_SAL_OH58D_RECON_2SHIP` | 8 | 2 | 4 | 0 |
| `SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT` | `TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP` | 7 | 2 | 3 | 1 |
| `SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN` | `TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP` | 3 | 1 | 3 | 0 |
| `SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT` | `TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP` | 6 | 1 | 6 | 0 |

Gesamt:

```text
5 SQUADRONs
20 registrierte Warehouse-Assetgruppen
31 durch die aktuellen Gruppentemplates direkt repräsentierte Luftfahrzeuge
1 zusätzliche logische UH-60-Assault-Reserve
32 logische Luftfahrzeuge
```

Der zweite Parameter von `SQUADRON:New()` zählt Gruppen, nicht einzelne Luftfahrzeuge. Die ungerade Stärke von sieben Assault-UH-60 darf daher nicht durch vier Two-Ship-Gruppen künstlich auf acht erhöht werden.

## 8. Client-Gruppen

Verpflichtende Client-Gruppen der modfreien Kernmission:

```text
CLIENT_US_SAL_AH64D_01
CLIENT_US_SAL_AH64D_02
CLIENT_US_SAL_OH58D_01
CLIENT_US_SAL_OH58D_02
CLIENT_US_SAL_CH47F_01
CLIENT_US_SAL_CH47F_02
```

Optionale UH-60L-Modvariante:

```text
CLIENT_US_SAL_UH60L_01
CLIENT_US_SAL_UH60L_02
```

Für die Kernmission sind nur `0` oder `2` optionale UH-60L-Clientgruppen zulässig. Die modfreie Mission darf nicht von ihnen abhängen.

## 9. KI-Templates und technische Typabbildung

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP          2 AH-64D_BLK_II
TPL_AIR_US_SAL_OH58D_RECON_2SHIP        2 OH58D
TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP       2 UH-60A
TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP       1 UH-60A
TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP     1 CH-47Fbl1
```

Alle Templates sind `Late Activation` und `Uncontrolled = false`. Sie sind Authoring-Seeds und kein Zusatzbestand.

Historische und technische Abbildung:

| Rolle | historische Einordnung | DCS-Typ |
|---|---|---|
| Attack | AH-64D | `AH-64D_BLK_II` |
| Scout/Recon | OH-58D | `OH58D` |
| Assault/MEDEVAC | UH-60-Familie | `UH-60A`; optionale Clients UH-60L-Mod |
| Medium/Heavy Lift | CH-47D im Zeitraum | `CH-47Fbl1` |

Die CH-47-Abweichung bleibt sichtbar:

```text
historisch: CH-47D
DCS-Repräsentation: CH-47Fbl1
```

## 10. Payload- und Capability-Baseline

Der akzeptierte technische Stand registriert die erforderlichen Mission Capabilities und Payloads für:

- AH-64D CAS;
- OH-58D RECON;
- UH-60 Assault/Lift;
- UH-60 MEDEVAC;
- CH-47 Transport/Lift.

Im akzeptierten Lauf waren fünf Capabilities und fünf fachliche Payloadregistrierungen vorhanden; die interne AIRWING-Payloadtabelle enthielt zehn Einträge.

### AH-64D-CAS-Baseline

```text
2 × M261 mit jeweils 19 × M151 HE
2 × AGM-114K gesamt
300 × M789 HEDP / Mission-Editor-Wert 25 Prozent
IAFS/Robbie Tank
```

### OH-58D-Arbeitsbaseline

```text
M3P mit 500 Schuss
M260 mit M151 HE
```

### UH-60 und CH-47

```text
UH-60A: keine Pylonenbeladung
CH-47Fbl1: Port und Starboard M60D
```

Die COMMANDER-Acceptance beweist für AH-64D, dass Capability, Payload und Assetbestand gemeinsam einen CAS-Auftrag als ausführbar erkennen ließen. Sie beweist nicht die vollständige Waffenwirkung am Ziel.

## 11. Sichtbare Statics und Funktionszone

Aktueller Missionsstand:

```text
3 AH-64D-Statics
4 OH-58D-Statics
3 UH-60-Assault-Statics
1 UH-60-MEDEVAC-Static
4 CH-47F-Statics
-------------------
15 Luftfahrzeug-Statics
```

Vorhandene Funktionszone:

```text
ZONE_AIR_US_SAL_CSAR_UNLOAD
```

Zusätzliche Zonen werden nur bei einem konkreten MOOSE- oder Missionsverbraucher angelegt. Zonen ersetzen keine TerminalID- oder Parking-Logik.

## 12. Mission-Editor- zu MOOSE-TerminalID-Kalibrierung

### 12.1 Grundsatz

Mission-Editor-Parkinglabels und MOOSE-`TerminalID` sind nicht identisch. Sie dürfen nicht ohne Kalibrierung austauschbar verwendet werden.

Die Salerno-Kalibrierung lief mit:

```text
BuilderVersion: SAL-ME-TERMINAL-CALIBRATION-1
Runtime nodes: 44
Mappings: 32
Failures: 0
Result: PASS
```

### 12.2 Vollständige bestätigte Zuordnung

```text
ME07 -> T08
ME08 -> T13
ME09 -> T14
ME10 -> T15
ME11 -> T16
ME12 -> T17
ME14 -> T09
ME15 -> T10
ME16 -> T11
ME17 -> T12
ME18 -> T21
ME19 -> T22
ME20 -> T19
ME24 -> T41
ME25 -> T42
ME26 -> T43
ME27 -> T44
ME28 -> T45
ME29 -> T32
ME30 -> T33
ME31 -> T34
ME32 -> T35
ME33 -> T36
ME34 -> T37
ME35 -> T38
ME37 -> T26
ME38 -> T27
ME39 -> T28
ME41 -> T30
ME42 -> T31
ME43 -> T23
ME44 -> T24
```

Besonders relevant:

```text
ME24 -> T41   statische OH-58-Fläche
ME25 -> T42   statische OH-58-Fläche
ME35 -> T38   Zufahrt / CSAR-Unload-Bereich
```

### 12.3 Clientpositionen

```text
ME13 -> T18   CH-47 Client
ME21 -> T20   CH-47 Client
ME36 -> T25   AH-64D Client
ME40 -> T29   AH-64D Client
ME22 -> T39   OH-58D Client
ME23 -> T40   OH-58D Client
```

Diese sechs MOOSE-TerminalIDs dürfen nicht als akzeptierte KI-Parkpositionen behandelt werden.

## 13. Parking-Versuche und Rückschlag

### 13.1 Was korrekt funktionierte

- Runtime-Parkingnodes wurden vollständig ermittelt.
- ME-Labels wurden auf MOOSE-TerminalIDs kalibriert.
- Client-, Static- und Funktionsbereiche konnten geometrisch beziehungsweise über Kalibrierung identifiziert werden.
- Type-spezifische Parkingpools wurden an SQUADRONs gesetzt.
- Bereits registrierte Warehouse-Assets wurden nachträglich auf die jeweiligen Type-Pools synchronisiert.
- Die interne Vertragsprüfung meldete zwanzig synchronisierte Assets und keine Tabellenverletzung.

### 13.2 Type-spezifische Arbeits-Pools

Beispielhaft eingesetzte rechte Rotary-Pools:

```text
AH-64D: ME39, ME41 -> T28, T30
UH-60:  ME30, ME31, ME34 -> T33, T34, T37
OH-58D: ME26, ME27 -> T43, T44
CH-47:  abgetrennter LEFT_HEAVY-Pool
```

### 13.3 Beobachteter Fehler

Trotz korrekter SQUADRON- und Assettabellen wurde visuell mindestens ein Apache auf einem reservierten beziehungsweise geschützten Spielerbereich beobachtet. Bei einer Multi-Unit-Gruppe entsprach die realisierte Platzierung nicht zuverlässig dem erwarteten Type-Pool und der Clienttrennung.

Damit gilt:

```yaml
parking_configuration_tables: CONSISTENT
me_to_terminal_calibration: PASS
actual_multi_unit_spawn_compliance: FAIL_NOT_PROVEN
client_exclusion_runtime_compliance: FAIL_NOT_PROVEN
parking_acceptance: DEFERRED
```

Ein Logeintrag wie `parkingIDs=...`, eine bestandene Tabellenprüfung oder ein SQUADRON-Pool beweist nicht die tatsächlich realisierte DCS-Spawnposition.

### 13.4 MOOSE-Quellcodeerkenntnis

Im verwendeten MOOSE-Stand folgt der Warehouse-Parkingallocator bei vorhandenen `asset.parkingIDs` einem assetbezogenen Prüfpfad. Dieser ist nicht identisch mit dem generischen Airbase-Parking-/Blacklist-/Terminaltyp-Pfad. Deshalb dürfen Clientpositionen niemals in Assetpools gelangen; eine Airbase-Blacklist allein ist bei assetbezogenen IDs kein ausreichender Nachweis.

Die genaue Ursache des beobachteten Multi-Unit-Fehlverhaltens wurde nicht abschließend bewiesen. Mögliche Ursachen bleiben:

- unvollständige oder anders interpretierte `Parkingdata`;
- relative Gruppenoffsets;
- DCS-interne Umplatzierung;
- Fallback nach fehlender geeigneter Gruppenplatzierung;
- Missverständnis zwischen ausgewählter Gruppenposition und realisierten Unitpositionen.

Keine dieser Möglichkeiten wird ohne weitere Telemetrie als bewiesene Ursache festgelegt.

### 13.5 Verbindliche Parking-Entscheidung

```yaml
parking_state: DEFERRED
calibration_retained: true
experimental_scripts_retained: true
operational_parking_mutation: false
parking_gate_for_airwing_start: false
parking_gate_for_commander_dispatch: false
```

Die Dateien `06b`, `06c` und `06d` bleiben als experimentelle beziehungsweise historische Entwicklungsartefakte erhalten, werden aber nicht in das akzeptierte Stage-18-Bundle eingebaut.

## 14. Testchronologie und dokumentierte Rückschläge

### 14.1 Read-only Diagnose

Zunächst wurden ausschließlich Airbase, Warehouse, Clients, Templates, Statics, Zonen und Parkingnodes geprüft. Dieser Schritt bestätigte die Objektbasis und verhinderte, dass sofort mutierende AIRWING- oder Spawnlogik auf unbestätigten Namen aufbaute.

### 14.2 Parking-Kalibrierung

Die Kalibrierung beseitigte die falsche Annahme, Mission-Editor-Parkinglabels seien direkt MOOSE-TerminalIDs. Dieser Teil bleibt belastbar und wird nicht verworfen.

### 14.3 Runtime- und Type-Parking-Verträge

Mehrere Parking-Verträge wurden aufgebaut, inklusive Type-Pools und Asset-Synchronisierung. Die internen Tabellen waren konsistent, die sichtbare Multi-Unit-Platzierung jedoch nicht zuverlässig. Der operative Parkinganspruch wurde deshalb zurückgenommen statt durch Logs künstlich als PASS erklärt.

### 14.4 AIRWING-Direktdispatch bei deaktiviertem Parking

Mit `SAL-PARKING-DEFERRED-15` wurden CAS, RECON und LIFT direkt an das AIRWING gegeben. Alle drei Aufträge wurden angenommen und erreichten Laufzeitfortschritt. Dieser Test bestätigte AIRWING, SQUADRONs, Capabilities und Payloads, war aber wegen paralleler Missionen nicht geeignet, eine einzelne Spawn- oder Parkingentscheidung kausal zu bewerten.

### 14.5 Gemischter COMMANDER-Test – ungültiger PASS

In `SAL-COMMANDER-DISPATCH-16` liefen direkte CAS-/RECON-/LIFT-Aufträge noch, als der COMMANDER-Test begann. Eine Blackhawk erschien direkt in der Luft. Die Zeitachse zeigte, dass sie aus der noch laufenden direkten LIFT-Mission stammte und nicht aus dem COMMANDER-CAS-Auftrag.

Zusätzlich wertete der Test `planned` wegen einer fehlerhaften Groß-/Kleinschreibungsprüfung fälschlich als Fortschritt und gab einen ungültigen PASS-Marker aus.

Lehren:

- keine parallelen unabhängigen Dispatchpfade in einem kausalen Acceptance-Test;
- sichtbare Luftfahrzeuge müssen eindeutig einem Auftrag zugeordnet werden;
- MOOSE-Zustände vor Vergleichen normalisieren;
- `planned` und `unknown` sind kein Fortschritt;
- ein Testmarker darf nicht mehr Autorität erhalten als die zugrunde liegende Zustandsfolge.

### 14.6 Isolierter COMMANDER-Test ohne Start – gültiger FAIL

`SAL-COMMANDER-ISOLATED-17` entfernte die direkten Missionen. Die COMMANDER-Mission blieb jedoch `planned` und erzeugte kein Luftfahrzeug.

Die anschließende Prüfung der OMW-Dokumentation, des akzeptierten Jalalabad-Codes und des exakten MOOSE-Quellcodes zeigte den Testharness-Fehler:

```lua
COMMANDER:New(...)
commander:AddAirwing(airwing)
-- commander:Start() fehlte
commander:AddMission(mission)
```

`COMMANDER:AddAirwing()` bindet die Legion, startet den COMMANDER aber nicht. `COMMANDER:AddMission()` stellt den Auftrag zunächst nur als `PLANNED` in die Queue. Ohne `COMMANDER:Start()` läuft der `Status`-/`CheckMissionQueue()`-Zyklus nicht.

### 14.7 Korrigierter COMMANDER-Auswahltest – PASS

`SAL-COMMANDER-SELECTION-18` setzte die dokumentierte Reihenfolge um:

```text
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:Start()
COMMANDER:CanMission()
COMMANDER:AddMission()
COMMANDER:Status()
```

Beobachtet wurden:

```text
COMMANDER state: NotReadyYet -> OnDuty
COMMANDER:CanMission(): true
selected legion: AW_US_SALERNO
MissionAssign: observed
AIRWING MissionRequest: observed
AH-64 OPSGROUP: SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK_AID-111
OpsOnMission: observed
AUFTRAG: planned -> requested -> scheduled -> started
final harness result: PASS
debrief graveyard: empty
```

Der Auftrag wurde anschließend kontrolliert abgebrochen. Deshalb ist der spätere Done-/Success-Übergang kein Nachweis einer taktisch vollständig erfüllten CAS-Mission.

## 15. Akzeptierter technischer Umfang

```yaml
airbase_resolution: PASS
warehouse_resolution: PASS
mission_editor_object_contract: PASS
airwing_construction: PASS
five_squadrons_constructed: PASS
five_squadrons_registered: PASS
registered_group_assets: 20
capabilities_registered: PASS
payloads_registered: PASS
airwing_start: PASS
commander_construction: PASS
commander_airwing_binding: PASS
commander_start_to_onduty: PASS
commander_canmission_cas: PASS
commander_legion_selection: PASS
airwing_mission_request: PASS
ah64_asset_assignment: PASS
auftrag_progress_to_started: PASS
controlled_cleanup: PASS
recorded_losses: 0
```

## 16. Nicht akzeptierter beziehungsweise aufgeschobener Umfang

```yaml
exact_parking_compliance: DEFERRED
client_space_runtime_protection: NOT_ACCEPTED
cold_ground_spawn_visual_confirmation: NOT_ACCEPTED
tactical_target_engagement: NOT_TESTED
normal_mission_completion: NOT_TESTED
return_landing_recovery: NOT_TESTED
persistent_inventory_booking: NOT_TESTED
permanent_loss_path: NOT_TESTED
opstransport: NOT_TESTED
multiplayer_acceptance: NOT_TESTED
long_duration_acceptance: NOT_TESTED
theater_wide_production_commander: NOT_IMPLEMENTED
```

## 17. Verbindliche technische Lehren für weitere Flugplätze

1. **MOOSE-first ist eine Ausführungsregel, keine nachträgliche Dokumentationsaufgabe.** Vor Codeänderungen müssen Projektdokumentation, exakte MOOSE-Version, Quellcode und passende Demos geprüft werden.
2. **Mission-Editor-Parkinglabels sind keine MOOSE-TerminalIDs.** Jeder Flugplatz benötigt eine eigene Kalibrierung oder Runtime-Ermittlung.
3. **Konfiguration ist nicht Realisierung.** SQUADRON- und Assettabellen, Allow-/Blacklists und PASS-Marker beweisen keine tatsächliche Unitposition.
4. **Registrierte Assets können SQUADRON-Werte kopieren.** Werden Parkingwerte nach Registrierung geändert, müssen vorhandene Assets bei Bedarf nachweislich synchronisiert werden.
5. **Multi-Unit-Spawns brauchen Unit-Telemetrie.** Gruppenname, Asset-UID, konfigurierte IDs, Unitkoordinaten und nächster TerminalID müssen getrennt protokolliert werden.
6. **Acceptance-Tests müssen isoliert sein.** Genau ein Dispatchpfad, ein Auftrag und ein erwarteter Assettyp, sofern die Auswahlentscheidung untersucht wird.
7. **FSM-Zustände müssen normalisiert und semantisch bewertet werden.** `planned` ist kein Fortschritt; Groß-/Kleinschreibung darf keinen PASS erzeugen.
8. **Konstruktion ist nicht Start.** FSM-basierte MOOSE-Objekte müssen entsprechend ihrer dokumentierten Startsequenz aktiviert werden.
9. **Historische FAILs bleiben erhalten.** Fehlversuche werden nicht überschrieben, sondern als reproduzierbare Entwicklungsevidenz dokumentiert.
10. **Lokaler Test-COMMANDER ist nicht Produktionsarchitektur.** Der produktive Stand soll später genau einen theaterweiten BLUE COMMANDER verwenden, der nach den einzelnen AIRWING-Modulen geladen wird.

## 18. Produktionsarchitektur-Folgeentscheidung

Der Salerno-Test verwendet lokal:

```text
CMD_BLUE_AFGHANISTAN_TEST
Legions: 1
```

Das Objekt bleibt ein Acceptance-Harness. Für die produktive Mission gilt als Zielbild:

```text
MOOSE
-> gemeinsame OMW-Basis
-> einzelne AIRWING-Module je Flugplatz
-> genau ein theaterweites BLUE-COMMANDER-Modul
-> Missions-/Tasking-Module
```

Historische Jalalabad- und Salerno-Testfixtures bleiben unverändert reproduzierbar. Der COMMANDER wird nicht rückwirkend aus historischen Acceptance-Dateien entfernt.

## 19. Reproduzierbare Acceptance-Provenienz

```text
OMW branch:
agent/salerno-read-only-diagnostics

Accepted source commit:
dba0465afbff14fb719abdeb1f9b06e24ff24717

BuilderVersion:
SAL-COMMANDER-SELECTION-18

Bundle SHA-256:
75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee

Mission:
OMW_Template_v5_Salerno.miz

Mission SHA-256:
4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf

DCS:
2.9.28.26385

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die bereitgestellte aktuelle `.miz` enthielt exakt die oben gehashte Stage-18-Bundledatei und das seit Beginn verwendete MOOSE-Artefakt.

## 20. Zugehörige Evidenz und Branchdokumentation

Main-fähige Querschnittsdokumente:

- [`Salerno Runtime Acceptance und Lessons Learned`](evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md);
- [`Salerno Abschluss- und Nachfolger-Handoff`](handoffs/2026-08-02-salerno-complete-state-and-next-airfield-handoff.md).

Technische Branchfixtures:

```text
mission/tests/salerno-air-operations/README.md
mission/tests/salerno-air-operations/calibration/01-map-me-parking-to-moose-terminal.lua
mission/tests/salerno-air-operations/results/
mission/tests/salerno-air-operations/src/
tools/build-salerno-air-operations-bundle.ps1
tools/build-salerno-parking-calibration.ps1
```

## 21. Abschlussstatus

```yaml
salerno_airwing_squadron_foundation: ACCEPTED_TECHNICAL_BASELINE
salerno_commander_dispatch: ACCEPTED_TECHNICAL_BASELINE
parking_calibration: PASS
parking_runtime_control: DEFERRED
additional_salerno_runtime_test_before_next_airfield: NOT_REQUIRED
next_airfield_work: UNBLOCKED
pr_merge_state: NOT_DECIDED_BY_THIS_DOCUMENT
```
