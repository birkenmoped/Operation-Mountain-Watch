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
- Custom campaign state, persistence, red-force director, and virtualization modules where MOOSE does not provide the project-specific domain model

## Verbindliche Projekt-Governance

Die höchste projektinterne Entscheidungsinstanz ist:

- [`OMW-GOV-001 – Projekt-Governance`](docs/00-project-governance.md)

Das zentrale Register für Dokumentnummern und stabile IDs ist:

- [`OMW-GOV-DOCUMENT-REGISTRY – Zentrales Dokumentregister`](docs/DOCUMENT-REGISTRY.md)

Bei widersprüchlichen Angaben gelten die dort definierte Quellenhierarchie, die Dokumentstatus und die Supersede-Regeln. Verweise sollen künftig stabile Dokument-IDs und Pfade verwenden und nicht nur Bezeichnungen wie „Dokument 28“.

## Verbindlicher Kampagnenrahmen

```text
Historischer Recherche- und Kampagnenzeitraum:
01.08.2010 bis 31.12.2011

Aktive Missions-ORBAT:
zusammengesetzte, spielbare Auswahl innerhalb dieses Zeitraums
mit besonderer Evidenzbasis aus verfügbaren Satellitenbildern Ende 2011
```

Es wird kein automatischer historischer Staffelwechsel nach Kampagnendatum umgesetzt. Reale Rotationen bleiben als historischer Kontext erhalten; die aktive Missionsbaseline wird ausdrücklich in den zuständigen Entscheidungsdokumenten festgelegt.

## Aktuelle Projektphase

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Zunächst wird das vollständige Missionsgrundgerüst aufgebaut: Flugplätze, Luftoperationsknoten, FOBs, Einheiten, Spielergruppen, KI-Templates, Statics, Warehouses, Naming und grundlegende MOOSE-Strukturen. Darauf setzen anschließend gezielte Funktions-, Integrations- und Acceptance-Tests auf.

Der frühere vertikale Jalalabad–Connolly-Prototyp bleibt als Entwicklungsnachweis erhalten, ist aber nicht mehr die aktuelle Ablaufstrategie.

## Projektweit verbindliche Entwicklungsrichtlinien

Die folgenden Vorgaben gelten für das gesamte Hauptprojekt und alle Unterprojekte, Testmissionen, Feature-Branches, Diagnosezweige und Erweiterungen:

- [`OMW-GOV-001 – Projekt-Governance`](docs/00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST – Verbindliche MOOSE-First-Entwicklungsrichtlinie`](docs/26-moose-first-development-policy.md)
- [`MOOSE-Projektdokumentation und Klassenregister`](docs/moose/README.md)
- [`MOOSE-Version und Quellen`](docs/moose/VERSION-AND-SOURCES.md)

Vor eigener Lua-Logik müssen passende MOOSE-Funktionen, Dokumentation, Quellcode und offizielle Beispiele geprüft werden. Eine technische Begründung allein genehmigt keine Abweichung. Jede produktive Nicht-MOOSE-, Native-DCS- oder projektspezifische Parallelimplementierung benötigt zusätzlich die ausdrückliche Freigabe des Projektinhabers und eine dokumentierte Ausnahme.

## Quellenattribution: Graveyard of Empires

Sämtliche Credits für die zugrunde liegende Recherche, Datensammlung, Zusammenstellung und historische Aufbereitung der von **Graveyard of Empires** übernommenen Afghanistan-/OEF-/ISAF-Unterlagen gehen an:

- **Graveyard of Empires** — <https://www.patreon.com/cw/graveyard4DCS>

Operation Mountain Watch wertet alle frei zugänglichen oder vom Projektinhaber rechtmäßig bereitgestellten Inhalte vollständig für Dokumentation, Datenmodelle, Missionsdesign und DCS-/MOOSE-Umsetzung aus.

Nach Entscheidung des Projektmanagers beziehungsweise Autors dürfen Originaldateien, normalisierte Daten und abgeleitete Projektdateien in das Repository und in Missionspakete aufgenommen werden. Attribution, Quellenlink, konkrete Nutzungsbedingungen und die Trennung zwischen Quellinhalt und OMW-Entscheidung bleiben verpflichtend. Nicht rechtmäßig zugängliche Paywall-Inhalte werden nicht beschafft, umgangen oder rekonstruiert.

Die zentrale Regel ist dokumentiert unter:

- [`OMW-GOV-SOURCE-USE – Graveyard of Empires: Credits, Quellen- und Dateinutzung`](docs/sources/graveyard-of-empires.md)

## Status

Foundation build and controlled technical validation. No gameplay release exists yet.

## Documentation

Project design documents are stored in [`docs/`](docs/).

### Zentrale Entscheidungen und Arbeitsbaselines

- [`Historischer und organisatorischer Rahmen`](docs/09-historical-setting.md)
- [`US Air ORBAT – historische Recherche und Planungsbestand`](docs/us-air-orbat-2010-2011.md)
- [`Luftoperations- und ORBAT-Umsetzung`](docs/18-air-operations-implementation.md)
- [`OMW-AIR-ACTIVE-ORBAT – Verbindliche aktive Luft-ORBAT`](docs/19-active-air-orbat-decisions.md)
- [`Missionseditor-Arbeitsliste für die Luft-ORBAT`](docs/20-air-orbat-mission-editor-worklist.md)
- [`Jalalabad Air Operations Manifest`](docs/21-jalalabad-air-operations-manifest.md)

### Kommunikation, C2 und AAR

- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](docs/moose/ISR-FAC-CAS-AAR.md)
- [`OEF Air/Land C2- und JTAC-Callsign-Referenz`](docs/27-oef-jtac-callsign-reference.md)
- [`Afghanistan TAD- und Color-Net-Frequenzplan`](docs/28-afghanistan-tad-color-nets.md)
- [`ISAF 2009–2013 – Air-to-Air Refuelling und ACO-Referenz`](docs/29-isaf-2009-2013-air-to-air-refueling.md)
- [`ISAF 2009–2013 – AAR Areas: Bildreferenz zu Patreon Teil 2`](docs/30-isaf-2009-2013-aar-part2-figure-reference.md)

### MOOSE

- [`MOOSE-Projektdokumentation`](docs/moose/README.md)
- [`MOOSE-Projektklassenindex`](docs/moose/PROJECT-CLASS-INDEX.md)
- [`MOOSE-Luftoperationen`](docs/moose/AIR-OPERATIONS.md)
- [`Verifizierte MOOSE-Methoden`](docs/moose/VERIFIED-METHODS.md)

Diagnostic mission scripts are stored in [`scripts/diagnostics/`](scripts/diagnostics/). Air-operations bootstrap scripts are stored in [`scripts/air-operations/`](scripts/air-operations/).
