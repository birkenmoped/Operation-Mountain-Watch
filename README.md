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

## Verbindliche MOOSE-First-Entwicklungsrichtlinie

Vor der Entwicklung eigener Lua-Funktionen muss zuerst geprüft werden, ob MOOSE die benötigte Funktionalität bereits bereitstellt. Vorhandene MOOSE-Funktionen sind vorrangig zu verwenden; eine Eigenentwicklung muss technisch begründet und dokumentiert werden.

- [`Verbindliche MOOSE-First-Entwicklungsrichtlinie`](docs/26-moose-first-development-policy.md)
- [`MOOSE-Projektdokumentation und Klassenregister`](docs/moose/README.md)

Der verbindliche Rechercheweg umfasst:

1. passende MOOSE-Klassendokumentation,
2. Kontrolle des tatsächlichen MOOSE-Quellcodes,
3. Prüfung offizieller Demo- und Testmissionen,
4. erst danach gegebenenfalls projektspezifischen Lua-Code,
5. Dokumentation von Klasse, Methode, MOOSE-Stand, Einschränkungen und Testnachweis.

Diese Prüfung ist ein verpflichtender Bestandteil jeder Lua-Implementierung und jedes Code-Reviews im Projekt. Neue verwendete oder relevante MOOSE-Module werden fortlaufend unter `docs/moose/` ergänzt.

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
- [`Verbindliche MOOSE-First-Entwicklungsrichtlinie`](docs/26-moose-first-development-policy.md)
- [`Hubschrauberformationen und AH-64D-Konfiguration im Afghanistan-COIN-Szenario`](docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md)

MOOSE project reference:

- [`MOOSE documentation index`](docs/moose/README.md)
- [`MOOSE version and source traceability`](docs/moose/VERSION-AND-SOURCES.md)
- [`MOOSE project class registry`](docs/moose/PROJECT-CLASS-INDEX.md)
- [`MOOSE air operations`](docs/moose/AIR-OPERATIONS.md)
- [`MOOSE ground operations`](docs/moose/GROUND-OPERATIONS.md)
- [`MOOSE logistics and transport`](docs/moose/LOGISTICS-AND-TRANSPORT.md)
- [`MOOSE events and FSM`](docs/moose/EVENTS-AND-FSM.md)
- [`Verified MOOSE methods`](docs/moose/VERIFIED-METHODS.md)

Für taktische Hubschrauberformationen sowie FCR-, IAFS- und 30-mm-Konfigurationen des AH-64D gilt Dokument 27 projektweit. Die Jalalabad-spezifische Ableitung steht unter [`mission/tests/jalalabad-air-operations/expected/jalalabad-helicopter-doctrine-and-ah64-loadout.md`](mission/tests/jalalabad-air-operations/expected/jalalabad-helicopter-doctrine-and-ah64-loadout.md).

Für Jalalabad sind Dokumente 21, 23, 24 und 25 sowie die zugehörigen `expected/`- und `results/`-Dateien autoritativ. Ältere allgemeine Zwischenwerte wie vier Spielerplätze je Typ, sechs UH-60, kein CH-47, 13/15 Runtime-Parkplätze oder eine pauschale Ablehnung von Statics auf Parking-Nodes sind aufgehoben.

Test- und Implementierungsdateien:

- [`mission/tests/`](mission/tests/)
- [`scripts/diagnostics/`](scripts/diagnostics/)
- [`scripts/air-operations/`](scripts/air-operations/)
