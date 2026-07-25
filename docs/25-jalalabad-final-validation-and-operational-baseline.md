# 25 – Jalalabad: finale Validierung und operative Grundbaseline

## 1. Status

Jalalabad Airfield / FOB Fenty ist als lokaler Air-Ops-Grundknoten angenommen und validiert.

```text
Status: OPERATIONAL / ACCEPTED
Gesamttest: PASS
PR: #18, weiterhin Draft bis zur ausdrücklichen Freigabe
```

Dieses Dokument ersetzt alle älteren Jalalabad-Abschnitte, die den vollständigen DCS-Abschlusslauf noch als ausstehend bezeichnen.

Autoritatives Endergebnis:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

Detaillierter Ergebnisbericht:

```text
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```

## 2. Validierte Repository- und Bundle-Baseline

```text
Source-Branch:    feature/jalalabad-air-operations-diagnostics
Source-Commit:    6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Builder:          tools/build-jalalabad-air-operations-bundle.ps1
BuilderVersion:   JBAD-AIR-OPS-COMPLETE-5
Eingebettete Datei: l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
Bundlegröße:      50273 Bytes
Bundle SHA-256:   13f6ef2235a8d1abd13924c0e6bc297515039795766e98d7e15572c1f06ea18a
GeneratedUtc:     2026-07-23T22:48:46.2604962Z
```

Die finale Testmission enthielt nachweislich exakt dieses Bundle.

## 3. Validierte Nachweisdateien

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01(6).miz
SHA-256: 16c607a9ffe9157779c09ad0e7557287697f91239c60e53fa33fd91d22396e8f

dcs(57).log
SHA-256: 1460c11af132a29421b091496702f8a1da70636c9303e4c72c82513b4e58a836

debrief(14).log
SHA-256: 2ae6f3e48cd0adea313b5c622226f6e965adf9b1ed51c51abcc33642d4ca12e4
```

Testumgebung:

```text
DCS 2.9.28.26283 MT
DCS: Afghanistan
Missionsdatum: 2. Mai 2011
MOOSE Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

## 4. Validierter logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
-------------------
48 Luftfahrzeuge
```

Logischer Bestand, aktive Luftfahrzeuge, sichtbare Statics und virtuelle Reserve bleiben getrennte Ebenen.

Ein endgültiger Verlust reduziert den logischen Bestand dauerhaft. Eine andere überlebende, bislang virtuelle Bestandsmaschine darf einen späteren Einsatz übernehmen; sie ist kein externer Ersatz.

## 5. Validierte Missionseditor-Baseline

```text
6 verpflichtende Clientgruppen
5 Late-Activation-KI-Templategruppen mit zusammen 7 Luftfahrzeugen
20 sichtbare Luftfahrzeug-Statics
11 Funktionszonen
1 Warehouse-Anker
0 optionale UH-60L-Clientgruppen im modfreien Kernstand
```

Validierte DCS-Typnamen:

```text
OH-58D: OH58D
AH-64D: AH-64D_BLK_II
UH-60A: UH-60A
CH-47F: CH-47Fbl1
```

Validierte UH-60-Livery für Lead und Cover:

```text
standard
```

## 6. Validierte MOOSE-Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Validierte Bestandsabbildung:

```text
OH-58D: 24 Luftfahrzeuge / 12 Two-Ship-Asset-Gruppen / RECON
AH-64D:  8 Luftfahrzeuge /  4 Two-Ship-Asset-Gruppen / CAS
UH-60:   8 Luftfahrzeuge /  8 Single-Ship-Asset-Gruppen / TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE, GROUNDESCORT
CH-47:   8 Luftfahrzeuge /  8 Single-Ship-Asset-Gruppen / TROOPTRANSPORT, CARGOTRANSPORT, LANDATCOORDINATE
```

## 7. Validiertes MEDEVAC-Grundmodell

MEDEVAC wird als zwei unabhängig taskbare Single-Ship-DCS-Gruppen modelliert, die gemeinsam ein logisches Paket bilden:

```text
1 Lead
+
1 Cover
=
1 logisches MEDEVAC-Two-Ship-Paket
```

```text
PackageSize = 2
LeadAircraft = 1
CoverAircraft = 1
AllowSingleShip = false
DCSGroupModel = TWO_INDEPENDENT_SINGLE_SHIP_GROUPS
CoordinationModel = ONE_LOGICAL_MEDEVAC_PACKAGE
```

Die Template-, Payload- und SQUADRON-Grundlage ist validiert. Der spätere Laufzeitkoordinator, der beide Assets atomar reserviert, gemeinsam startet, getrennt taskt und gemeinsam freigibt, bleibt eine eigenständige Folgestufe.

## 8. Validiertes Parkplatzmodell

Kernbedarf zur Laufzeit:

```text
6 reservierte Clientpositionen
4 dynamische KI-Reservepositionen
--------------------------------
10 Runtime-Positionen

+ 2 optionale UH-60L-Clientpositionen
= 12 Positionen mit Modvariante
```

Die sieben Luftfahrzeuge der Late-Activation-Templates sind Authoring-Seeds und werden nicht als dauerhaft belegte Runtime-Parkpositionen gezählt.

### 8.1 Absichtliche CH-47-Reservierungen

Vier sichtbare CH-47-Statics belegen echte DCS-Parking-Nodes:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49 -> 4.1 m
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37 -> 4.4 m
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23 -> 4.7 m
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35 -> 5.4 m
```

MOOSE-Parking-Blacklist:

```text
23,35,37,49
```

`AIRWING:SetSafeParkingOn()` schützt die Clientpositionen.

Der Parking-Validator bestätigte:

```text
intentionalReservationsConfirmed=4
blacklistedTerminalIDs=23,35,37,49
ch47VisualPositionsRemaining=7
unexpectedOverlaps=0
AIRWING_START_BLOCKED=false
```

## 9. Runtime-Abnahme

Die Mission lief laut Debrief:

```text
81.562 Sekunden
```

AIRWING und COMMANDER waren nach der Aktivierung ungefähr 66 Sekunden aktiv.

In diesem Zeitraum wurde für Jalalabad kein ungeplanter KI-Vorgang registriert:

- kein Birth/Spawn,
- kein Engine Start,
- kein Takeoff,
- kein Landing,
- kein Crash,
- kein Dead/Loss.

Der einzige Engine-Start im Debrief gehörte zu einer unabhängigen, bereits vorhandenen OH-58D in Bagram.

Es trat kein relevanter OMW-Jalalabad-Lua- oder Timerfehler auf.

## 10. Externe Meldungen

Der bekannte Shutdown-Fehler:

```text
Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua:168
attempt to index upvalue 'tcp' (a nil value)
```

trat erst nach `Dispatcher Stop` auf und gehört nicht zum Jalalabad-AirOps-Bundle.

Weitere DCS-, Terrain-, Modul-, OH-58D- und CH-47-Warnungen unterbrachen den Test nicht und erzeugten keinen OMW-Fehler.

## 11. Umfang dieser Abnahme

Dieser PASS schließt den lokalen Jalalabad-Air-Ops-Grundaufbau und dessen Startvalidierung ab.

Bestätigt sind:

- Missionseditor-Namen, Anzahlen und Typen,
- Warehouse- und Airbase-Zuordnung,
- SQUADRON-Bestände und Asset-Gruppengrößen,
- Payloadregistrierung,
- Parking-Blacklist,
- Safe Parking,
- AIRWING-Start,
- COMMANDER-Verknüpfung und -Start,
- null eingereihte Missionen,
- keine spontane Jalalabad-KI-Mission.

Noch nicht validiert sind:

- taktische AUFTRAG-Erzeugung und Missionsabschluss,
- OPSTRANSPORT für Fracht und Truppen,
- operative Lade-/Entladezonenlogik,
- der vollständige 1+1-MEDEVAC-Laufzeitkoordinator,
- persistente Verlustrechnung über Missionsneustarts,
- persistente sichtbare Ramp-/Static-Neuverteilung,
- Combat-Damage-, Recovery- und Replacement-State-Integration.

Diese Punkte sind Folgestufen der Kampagne. Sie öffnen den bereits angenommenen Jalalabad-Grundknoten nur bei einer nachgewiesenen Regression erneut.

## 12. Verbindlicher Workflow

Der projektweite Build-, Übertragungs- und Testprozess steht in:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Grundregel:

1. Repository und richtigen Branch aktualisieren.
2. Bundle aus den Repository-Quellen neu bauen.
3. Hash und Buildkopf prüfen.
4. Bundle im Missionseditor erneut über `DO SCRIPT FILE` auswählen.
5. `.miz` speichern.
6. Acceptance-Lauf ausführen.
7. Ergebnis dauerhaft dokumentieren.

Ein externer Neubau ändert eine bereits gespeicherte `.miz` nicht automatisch.

## 13. Autoritative Verweise

```text
docs/21-jalalabad-air-operations-manifest.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/24-jalalabad-ch47-static-parking-reservations.md
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
mission/tests/jalalabad-air-operations/results/2026-07-24-jalalabad-complete-node-pass.md
```
