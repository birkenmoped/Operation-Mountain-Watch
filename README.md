# Operation Mountain Watch

Dynamic persistent COIN multiplayer campaign for DCS World on the Afghanistan map.

## Project goals

- Replayable multiplayer COIN operations inspired by Operation Enduring Freedom
- Persistent blue airbases and forward operating bases with logistics and rebuild mechanics
- Dynamic red insurgent cells, camps, attacks, withdrawal, and regeneration
- Virtualized remote formations to reduce server load
- Player-driven logistics, CSAR, reconnaissance, convoy escort, and strike missions

## Planned technology

- DCS World Mission Editor
- MOOSE
- MOOSE CTLD
- MOOSE CSAR
- Custom campaign state, persistence, red-force director, and virtualization modules

## Projektweit verbindliche Entwicklungsrichtlinien

Die folgenden Vorgaben gelten für das gesamte Hauptprojekt **Operation Mountain Watch** und damit für alle Teilbereiche, Testmissionen, Feature-Branches, Diagnosezweige und späteren Erweiterungen. Sie sind nicht auf Jalalabad, PR #18 oder ein einzelnes Unterprojekt beschränkt.

- [`Verbindliche MOOSE-First-Entwicklungsrichtlinie`](docs/26-moose-first-development-policy.md)
- [`MOOSE-Projektdokumentation und Klassenregister`](docs/moose/README.md)

Vor der Entwicklung eigener Lua-Funktionen müssen die passende MOOSE-Dokumentation, der tatsächlich verwendete MOOSE-Quellstand und die offiziellen Demo- beziehungsweise Testmissionen geprüft werden. Vorhandene MOOSE-Funktionalität ist vorrangig zu verwenden. Abweichungen und Eigenentwicklungen müssen technisch begründet, versionsbezogen dokumentiert und durch reproduzierbare DCS-Tests abgesichert werden.

## Status

Early design and prototyping. No gameplay release exists yet.

The local Jalalabad / FOB Fenty Air Operations basic node is fully assembled and validated as the first operational technical reference baseline.

```text
Jalalabad status: OPERATIONAL / ACCEPTED
Validated source commit: 6cee9a5db7abf1934d0f86bf9fdf91a0446374d0
Validated builder: JBAD-AIR-OPS-COMPLETE-5
```

This does not yet include tactical AUFTRAG generation, OPSTRANSPORT, persistent losses or full runtime MEDEVAC coordination.

## Verbindlicher Testmissions-Workflow

Für Branchwechsel, Repository-Aktualisierung, Bundle-Build, Hashprüfung, Einbettung in eine `.miz`, Testlauf und Logübergabe gilt projektweit:

- [`Verbindlicher Workflow für DCS-Testmissionen`](docs/22-test-mission-build-transfer-and-validation-workflow.md)
- [`Einstiegspunkt für Testmissionen`](mission/tests/README.md)

Der Workflow muss bei späteren Testaufträgen nicht erneut vom Projektinhaber erklärt werden.

## Documentation

Project design documents are stored in [`docs/`](docs/).

Current air-operations documents:

- [`US Air Order of Battle 2010–2011`](docs/us-air-orbat-2010-2011.md)
- [`Luftoperations- und ORBAT-Umsetzung`](docs/18-air-operations-implementation.md)
- [`Verbindliche Entscheidungen zur aktiven Luft-ORBAT`](docs/19-active-air-orbat-decisions.md)
- [`Allgemeine Missionseditor-Arbeitsliste für die Luft-ORBAT`](docs/20-air-orbat-mission-editor-worklist.md)
- [`Jalalabad: Manifest, Testchronik und validierter Abschlussstand`](docs/21-jalalabad-air-operations-manifest.md)
- [`Build-, Übertragungs- und Validierungsworkflow`](docs/22-test-mission-build-transfer-and-validation-workflow.md)
- [`Jalalabad: Parking-, Template-, Static- und MEDEVAC-Modell`](docs/23-jalalabad-parking-template-and-medevac-model.md)
- [`Jalalabad: validierte CH-47-Static-Parkplatzreservierungen`](docs/24-jalalabad-ch47-static-parking-reservations.md)
- [`Jalalabad: finale Validierung und operative Grundbaseline`](docs/25-jalalabad-final-validation-and-operational-baseline.md)

Für Jalalabad sind Dokumente 21, 23, 24 und 25 sowie die zugehörigen `expected/`- und `results/`-Dateien autoritativ. Ältere allgemeine Zwischenwerte wie vier Spielerplätze je Typ, sechs UH-60, kein CH-47, 13/15 Runtime-Parkplätze oder eine pauschale Ablehnung von Statics auf Parking-Nodes sind aufgehoben.

Project-wide MOOSE documentation:

- [`MOOSE-Projektdokumentation`](docs/moose/README.md)
- [`MOOSE-Projektklassenindex`](docs/moose/PROJECT-CLASS-INDEX.md)
- [`Verifizierte MOOSE-Methoden`](docs/moose/VERIFIED-METHODS.md)

Test- und Implementierungsdateien:

- [`mission/tests/`](mission/tests/)
- [`scripts/diagnostics/`](scripts/diagnostics/)
- [`scripts/air-operations/`](scripts/air-operations/)
