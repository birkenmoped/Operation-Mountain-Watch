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

## Documentation

Project design documents are stored in [`docs/`](docs/).

Current air-operations planning documents:

- [`US Air Order of Battle 2010–2011`](docs/us-air-orbat-2010-2011.md)
- [`Luftoperations- und ORBAT-Umsetzung`](docs/18-air-operations-implementation.md)
- [`Verbindliche Entscheidungen zur aktiven Luft-ORBAT`](docs/19-active-air-orbat-decisions.md)
- [`Missionseditor-Arbeitsliste für die Luft-ORBAT`](docs/20-air-orbat-mission-editor-worklist.md)
- [`Jalalabad Air Operations Manifest`](docs/21-jalalabad-air-operations-manifest.md)

Project-wide MOOSE documentation:

- [`MOOSE-Projektdokumentation`](docs/moose/README.md)
- [`MOOSE-Projektklassenindex`](docs/moose/PROJECT-CLASS-INDEX.md)
- [`Verifizierte MOOSE-Methoden`](docs/moose/VERIFIED-METHODS.md)

Diagnostic mission scripts are stored in [`scripts/diagnostics/`](scripts/diagnostics/). Air-operations bootstrap scripts are stored in [`scripts/air-operations/`](scripts/air-operations/).
