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
- Custom campaign state, persistence, red-force director, and virtualization modules only where MOOSE does not provide the required project-specific domain model

## Governance and MOOSE-first

The project-wide authority model, stable document IDs, document-number reservations, branch acceptance states and owner-approval requirement for non-MOOSE fallbacks are defined by:

- `OMW-GOV-001` – `docs/00-project-governance.md` after integration of the governance reconciliation branch;
- `OMW-GOV-DOCUMENT-REGISTRY` – `docs/DOCUMENT-REGISTRY.md`;
- `OMW-GOV-MOOSE-FIRST` – `docs/26-moose-first-development-policy.md`.

Before custom Lua is implemented, the matching MOOSE documentation, source code and official examples must be checked. A technical justification alone does not approve a non-MOOSE implementation; explicit project-owner approval is required.

## Campaign and ORBAT baseline

```text
Campaign and research period: 01.08.2010–31.12.2011
Active ORBAT model: composed playable baseline within that period
Automatic historical squadron rotation: not implemented
```

Active core decisions represented on this branch:

```text
Bagram:
335th EFS – 13 F-15E
121st EFS – 13 historical F-16C Block 30
DCS substitution – F-16C Block 50

Kandahar:
107th EFS – 16 A-10C

Jalalabad:
24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47
```

Project-wide client limit:

```text
maximum 2 client aircraft per type and base
maximum 2 client groups per type and base
1 aircraft per client group
```

## Branch status

Jalalabad is an `ACCEPTED_TECHNICAL_BASELINE` for the documented draft-branch commit, mission, bundle and MOOSE version. It is not automatically a merged repository-wide normative baseline.

Bagram is assembled in the shared Mission Editor test mission. Historical Fighter ORBAT, project-wide client rules and the current Mission Editor object state are separated into three documents so that planning values cannot overwrite the actual `.miz` baseline.

Kandahar construction includes:

- 107th EFS / 16 A-10C as the active OMW A-10C baseline;
- C-130J;
- HH-60G/CSAR represented by UH-60A;
- restricted MQ-1/MQ-9 ISR assets;
- the 159th Combat Aviation Brigade / Task Force Thunder Mustang Ramp node;
- clients, AI templates, statics and warehouse anchors.

Tactical AUFTRAG generation, OPSTRANSPORT, persistent losses and full runtime coordination remain later MOOSE-first stages.

## Test mission workflow

- [`Verbindlicher Workflow für DCS-Testmissionen`](docs/22-test-mission-build-transfer-and-validation-workflow.md)
- [`Einstiegspunkt für Testmissionen`](mission/tests/README.md)

## Documentation

### Existing foundation documents

- [`US Air Order of Battle – research context`](docs/us-air-orbat-2010-2011.md)
- [`Luftoperations- und ORBAT-Umsetzung`](docs/18-air-operations-implementation.md)
- [`Verbindliche aktive Luft-ORBAT`](docs/19-active-air-orbat-decisions.md)
- [`Allgemeine Missionseditor-Arbeitsliste`](docs/20-air-orbat-mission-editor-worklist.md)
- [`Jalalabad Manifest`](docs/21-jalalabad-air-operations-manifest.md)
- [`Build-, Übertragungs- und Validierungsworkflow`](docs/22-test-mission-build-transfer-and-validation-workflow.md)
- [`Jalalabad Parking-, Template-, Static- und MEDEVAC-Modell`](docs/23-jalalabad-parking-template-and-medevac-model.md)
- [`Jalalabad CH-47-Static-Parkplatzreservierungen`](docs/24-jalalabad-ch47-static-parking-reservations.md)
- [`Jalalabad technische Acceptance-Baseline`](docs/25-jalalabad-final-validation-and-operational-baseline.md)
- [`MOOSE-First-Entwicklungsrichtlinie`](docs/26-moose-first-development-policy.md)
- [`Hubschrauberformationen und AH-64D-Konfiguration`](docs/27-helicopter-formations-and-ah64-afghanistan-configuration.md)

### Centrally reserved Bagram and Kandahar documents

- [`OMW-AIR-BAGRAM-MANIFEST – Bagram Fighter-ORBAT und Implementierungsrahmen`](docs/31-bagram-air-operations-manifest.md)
- [`OMW-AIR-PLAYER-SLOT-POLICY – Projektweite Spielerluftfahrzeug-Obergrenze`](docs/32-player-aircraft-slot-policy.md)
- [`OMW-AIR-KANDAHAR-MANIFEST – Kandahar USAF-Grundaufbau und Evidenzregeln`](docs/33-kandahar-air-operations-manifest.md)
- [`OMW-AIR-BAGRAM-ME-BASELINE – Tatsächlich gesetzter Bagram-Missionseditorstand`](docs/34-bagram-current-mission-editor-baseline.md)
- [`OMW-AIR-KANDAHAR-ISR-POLICY – Eingeschränkte ISR-Drohnen-Assets`](docs/35-kandahar-isr-asset-policy.md)
- [`OMW-AIR-KANDAHAR-MUSTANG-RAMP – Army Aviation Baseline`](docs/36-kandahar-mustang-ramp-army-aviation-baseline.md)
- [`OMW-AIR-KANDAHAR-OH58D-ARMAMENT-DECISION – OH-58D Bewaffnungs- und Payload-Baseline`](docs/evidence/kandahar-oh58d-armament-loadout-decision-2026-08-01.md)

## Authority by subject

### Bagram

- `OMW-AIR-BAGRAM-MANIFEST`: historical evidence and active 335th/121st Fighter ORBAT.
- `OMW-AIR-PLAYER-SLOT-POLICY`: maximum two clients, no F-16 armed-recon template, no artificial grouping zones.
- `OMW-AIR-BAGRAM-ME-BASELINE`: actual clients, templates, 26 statics, warehouse and current parking data.

### Kandahar

- `OMW-AIR-KANDAHAR-MANIFEST`: 107th EFS / 16 A-10C, USAF baseline and evidence classes.
- `OMW-AIR-KANDAHAR-ISR-POLICY`: restricted MQ-1/MQ-9 use.
- `OMW-AIR-KANDAHAR-MUSTANG-RAMP`: AH-64D, OH-58D, CH-47 and Army UH-60 node.
- `OMW-AIR-KANDAHAR-OH58D-ARMAMENT-DECISION`: `H10 Rockets, Gun` as the OH-58D default, H17 and Hellfire as task-specific alternatives, APKWS excluded from 2010–2011, and 60% internal fuel as the provisional weight-compliant DCS value pending hot-and-high validation.

### Jalalabad

The technical acceptance report is authoritative only for its documented branch/commit/test artifact. The inventory `24/8/8/8` is separately adopted as the binding campaign baseline through project governance.

## MOOSE reference

- [`MOOSE documentation index`](docs/moose/README.md)
- [`MOOSE version and source traceability`](docs/moose/VERSION-AND-SOURCES.md)
- [`MOOSE project class registry`](docs/moose/PROJECT-CLASS-INDEX.md)
- [`MOOSE air operations`](docs/moose/AIR-OPERATIONS.md)
- [`MOOSE ground operations`](docs/moose/GROUND-OPERATIONS.md)
- [`MOOSE logistics and transport`](docs/moose/LOGISTICS-AND-TRANSPORT.md)
- [`MOOSE events and FSM`](docs/moose/EVENTS-AND-FSM.md)
- [`Verified MOOSE methods`](docs/moose/VERIFIED-METHODS.md)

Test and implementation files:

- [`mission/tests/`](mission/tests/)
- [`scripts/diagnostics/`](scripts/diagnostics/)
- [`scripts/air-operations/`](scripts/air-operations/)
