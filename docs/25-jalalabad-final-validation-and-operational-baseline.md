---
document_id: OMW-AIR-JBAD-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
authoritative_for:
  - tested Jalalabad branch and commit
  - tested Mission Editor object baseline
  - tested AIRWING and COMMANDER startup
scenario_period: 2010-08-01/2011-12-31
project_phase: TECHNICAL_ACCEPTANCE
source_branch: feature/jalalabad-air-operations-diagnostics
source_commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
validated_in_dcs: true
merged_to_main: false
repository_wide_normative_authority: false
---

# 25 – Jalalabad: finale Validierung und operative Grundbaseline

## 1. Status

Jalalabad Airfield / FOB Fenty ist für den exakt dokumentierten Branch-, Commit-, Missions- und Bundle-Stand technisch angenommen.

```text
Status: ACCEPTED_TECHNICAL_BASELINE
Gesamttest: PASS
PR: #18, weiterhin Draft
Merged to main: nein
```

Bedeutung:

- Der konkrete Stand wurde in DCS erfolgreich getestet.
- Die beobachtete technische Funktion ist nachgewiesen.
- Der Draft-Branch ersetzt nicht automatisch die Repository-Wahrheit auf `main`.
- Projektweit normative ORBAT- und Governance-Wirkung entsteht durch Merge oder ausdrückliche Projektinhaberentscheidung.
- Die Bestandsentscheidung `24/8/8/8` ist inzwischen separat als verbindliche Projektentscheidung festgelegt.

Autoritatives Testergebnis:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Detaillierter Ergebnisbericht:

```text
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```

## 2. Validierte Repository- und Bundle-Baseline

```text
Source-Branch:      feature/jalalabad-air-operations-diagnostics
Source-Commit:      6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Builder:            tools/build-jalalabad-air-operations-bundle.ps1
BuilderVersion:     JBAD-AIR-OPS-COMPLETE-5
Embedded file:      l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
Bundle size:        50273 bytes
Bundle SHA-256:     13f6ef2235a8d1abd13924c0e6bc297515039795766e98d7e15572c1f06ea18a
GeneratedUtc:       2026-07-23T22:48:46.2604962Z
```

Die finale Testmission enthielt nachweislich dieses Bundle.

## 3. Nachweisdateien

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA-256: 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f

dcs(57).log
SHA-256: 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA-256: 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

## 4. Testumgebung und MOOSE-Nachweis

```text
DCS:                  2.9.28.26283 MT
Map:                  DCS: Afghanistan
Mission date:         2 May 2011
MOOSE commit:         73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:    e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE evidence type:  RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
Moose.lua modified:   no
```

Der Hash war im ursprünglichen Testbericht nicht zeitgleich vollständig protokolliert. Die im Projekt verwendete `Moose.lua` wurde jedoch nicht verändert und ist durch identische, in anderen Tests gehashte Artefakte nachvollziehbar. Die Rekonstruktion wird deshalb transparent von einem zeitgleich protokollierten Nachweis getrennt.

## 5. Validierter logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60 family
 8 CH-47 heavy lift
-------------------
48 aircraft
```

Der Bestand `24/8/8/8` ist zusätzlich als historisch ausreichend bestätigte aktive Kampagnenbaseline beschlossen.

Logischer Bestand, aktive Luftfahrzeuge, sichtbare Statics, Client-Reservierungen und virtuelle Reserve bleiben getrennte Ebenen. Ein endgültiger Verlust reduziert den logischen Bestand. Eine überlebende Reserveairframe ist kein externer Ersatz.

## 6. Validierte Missionseditor-Baseline

```text
6 required Client groups
5 Late-Activation AI template groups / 7 template aircraft
20 visible aircraft statics
11 functional zones
1 warehouse anchor
0 optional UH-60L Client groups in the mod-free baseline
```

Validierte DCS-Typnamen:

```text
OH-58D: OH58D
AH-64D: AH-64D_BLK_II
UH-60A: UH-60A
CH-47F: CH-47Fbl1
```

UH-60 Lead und Cover verwenden die Livery:

```text
standard
```

## 7. Validierte MOOSE-Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
│   24 aircraft / 12 two-ship asset groups / RECON
├── SQ_US_JBAD_AH64D_B_1_10_AVN
│   8 aircraft / 4 two-ship asset groups / CAS
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
│   8 aircraft / 8 single-ship asset groups
└── SQ_US_JBAD_CH47_HEAVYLIFT
    8 aircraft / 8 single-ship asset groups
```

Validierte Rollen:

```text
OH-58D: RECON
AH-64D: CAS
UH-60: TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT
CH-47: TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE
```

## 8. MEDEVAC-Grundmodell

MEDEVAC wird als zwei unabhängig taskbare Single-Ship-DCS-Gruppen modelliert, die ein gemeinsames logisches Paket bilden:

```text
1 Lead + 1 Cover = 1 logical MEDEVAC two-ship package
```

```text
PackageSize = 2
LeadAircraft = 1
CoverAircraft = 1
AllowSingleShip = false
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Template-, Payload- und SQUADRON-Grundlage sind validiert. Der atomare Laufzeitkoordinator bleibt eine Folgestufe.

## 9. Parkplatzmodell

Runtime-Bedarf:

```text
6 reserved Client positions
4 dynamic AI reserve positions
= 10 runtime positions

+ 2 optional UH-60L Client positions
= 12 positions with the optional mod variant
```

Late-Activation-Templateflugzeuge sind Authoring-Seeds und keine dauerhaft belegten Runtime-Positionen.

Vier CH-47-Statics belegen absichtlich echte Parking-Nodes:

```text
CH47_01 -> TerminalID 49 -> 4.1 m
CH47_02 -> TerminalID 37 -> 4.4 m
CH47_03 -> TerminalID 23 -> 4.7 m
CH47_04 -> TerminalID 35 -> 5.4 m
```

MOOSE-Parking-Blacklist:

```text
23,35,37,49
```

`AIRWING:SetSafeParkingOn()` schützt Clientpositionen.

Validator-Ergebnis:

```text
intentionalReservationsConfirmed=4
blacklistedTerminalIDs=23,35,37,49
ch47VisualPositionsRemaining=7
unexpectedOverlaps=0
AIRWING_START_BLOCKED=false
```

## 10. Runtime-Abnahme

Debrief-Dauer:

```text
81.562 seconds
```

AIRWING und COMMANDER waren nach Aktivierung ungefähr 66 Sekunden aktiv. Für Jalalabad wurden keine ungeplanten Birth-, Engine-Start-, Takeoff-, Landing-, Crash- oder Loss-Ereignisse registriert. Der einzige Engine Start gehörte zu einer unabhängigen OH-58D in Bagram.

Es trat kein relevanter OMW-Jalalabad-Lua- oder Timerfehler auf. Der bekannte `bhHook.lua:168`-Fehler trat erst nach `Dispatcher Stop` auf und gehört nicht zum Bundle.

## 11. Umfang der Abnahme

Bestätigt:

- Missionseditor-Namen, Anzahlen und Typen;
- Warehouse- und Airbase-Zuordnung;
- SQUADRON-Bestände und Asset-Gruppengrößen;
- Payloadregistrierung;
- Parking-Blacklist und Safe Parking;
- AIRWING-Start;
- COMMANDER-Verknüpfung und -Start;
- null eingereihte Missionen;
- keine spontane Jalalabad-KI-Mission.

Nicht validiert:

- taktische AUFTRAG-Erzeugung und Missionsabschluss;
- OPSTRANSPORT für Fracht und Truppen;
- operative Lade-/Entladezonenlogik;
- vollständiger 1+1-MEDEVAC-Koordinator;
- persistente Verlustrechnung;
- persistente Ramp-/Static-Neuverteilung;
- Combat-Damage-, Recovery- und Replacement-State-Integration.

Diese Folgestufen ändern den akzeptierten Grundknoten nur bei einer nachgewiesenen Regression.

## 12. Workflow und Verweise

Build- und Testworkflow:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Autoritative technische Verweise:

```text
docs/21-jalalabad-air-operations-manifest.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/24-jalalabad-ch47-static-parking-reservations.md
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```
