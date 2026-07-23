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

## Status

Early design and prototyping. No gameplay release exists yet.

## Verbindlicher Testmissions-Workflow

Für Branchwechsel, Repository-Aktualisierung, Bundle-Build, Hashprüfung, Einbettung in eine `.miz`, Testlauf und Logübergabe gilt projektweit:

- [`Verbindlicher Workflow für DCS-Testmissionen`](docs/22-test-mission-build-transfer-and-validation-workflow.md)
- [`Einstiegspunkt für Testmissionen`](mission/tests/README.md)

Der Workflow muss bei späteren Testaufträgen nicht erneut vom Projektinhaber erklärt werden.

## Documentation

Project design documents are stored in [`docs/`](docs/).

Current air-operations planning documents:

- [`US Air Order of Battle 2010–2011`](docs/us-air-orbat-2010-2011.md)
- [`Luftoperations- und ORBAT-Umsetzung`](docs/18-air-operations-implementation.md)
- [`Verbindliche Entscheidungen zur aktiven Luft-ORBAT`](docs/19-active-air-orbat-decisions.md)
- [`Allgemeine Missionseditor-Arbeitsliste für die Luft-ORBAT`](docs/20-air-orbat-mission-editor-worklist.md)
- [`Jalalabad: Manifest, Testchronik und Abschlussstand`](docs/21-jalalabad-air-operations-manifest.md)
- [`Build-, Übertragungs- und Validierungsworkflow`](docs/22-test-mission-build-transfer-and-validation-workflow.md)

Für Jalalabad sind die konkreten Werte in Dokument 21 und im zugehörigen `expected/`-Dokument autoritativ. Ältere allgemeine Werte wie vier Spielerplätze je Typ werden dadurch ausdrücklich überschrieben.

Diagnostic mission scripts are stored in [`scripts/diagnostics/`](scripts/diagnostics/). Air-operations bootstrap scripts are stored in [`scripts/air-operations/`](scripts/air-operations/).
