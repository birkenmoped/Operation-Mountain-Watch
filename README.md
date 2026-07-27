# Operation Mountain Watch

Dynamic persistent COIN multiplayer campaign for DCS World on the Afghanistan map.

## Project goals

- replayable multiplayer COIN operations inspired by Operation Enduring Freedom;
- persistent airbases, FOBs, logistics and rebuild mechanics;
- dynamic insurgent networks, camps, attacks, withdrawal and regeneration;
- adaptive virtualization of remote formations;
- player-driven logistics, CSAR, reconnaissance, convoy escort and strike missions.

## Current project frame

```text
Scenario period: 01.08.2010–31.12.2011
Project phase:   COMPLETE_FOUNDATION_BUILD_PHASE
Release status:  no gameplay release yet
```

The former Jalalabad–Connolly vertical prototype remains historical development evidence. It is no longer the mandatory production sequence.

## Technology and development policy

- DCS World Mission Editor;
- MOOSE as the primary DCS scripting framework;
- MOOSE CTLD and MOOSE CSAR where suitable;
- CampaignState for strategic state and persistence;
- project-specific Lua only after the complete MOOSE-first review and explicit project-owner approval.

Binding policies:

- [`OMW-GOV-001 – Project Governance`](docs/00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST – MOOSE-First Development Policy`](docs/26-moose-first-development-policy.md)
- [`OMW-GOV-MOOSE-VERSION – MOOSE Version and Sources`](docs/moose/VERSION-AND-SOURCES.md)

## Documentation

The complete documentation entry point is:

- [`OMW-GOV-DOCUMENTATION-INDEX – Documentation Index and Source-of-Truth Matrix`](docs/README.md)

Document numbers and stable IDs are maintained in:

- [`OMW-GOV-DOCUMENT-REGISTRY – Central Document Registry`](docs/DOCUMENT-REGISTRY.md)

The root README intentionally does not duplicate the full document list. Topic ownership, document status, supersede relationships, branch scope and validation evidence are maintained in `docs/README.md`.

## Core authoritative documents

- [`OMW-GOV-001`](docs/00-project-governance.md) – governance and authority hierarchy;
- [`OMW-HIST-SETTING`](docs/09-historical-setting.md) – historical campaign frame;
- [`OMW-ARCH-SYSTEM`](docs/03-system-architecture.md) – high-level system boundaries;
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](docs/37-campaign-architecture-and-dynamic-mission-design.md) – CampaignState and dynamic campaign architecture;
- [`OMW-AIR-ACTIVE-ORBAT`](docs/19-active-air-orbat-decisions.md) – active air ORBAT and client limits;
- [`OMW-ME-MASTER-WORKLIST`](docs/38-mission-editor-master-worklist.md) – complete Mission Editor foundation-build worklist.

## Source attribution

Research and source material derived from **Graveyard of Empires** remains fully attributed:

- <https://www.patreon.com/cw/graveyard4DCS>
- [`OMW-GOV-SOURCE-USE – Credits, Source and File Use Policy`](docs/sources/graveyard-of-empires.md)

Project use, normalization and publication scope are governed by the project-owner decisions documented in the source-use and data-use policies. Missing generic license wording is not automatically an implementation blocker; attribution, provenance and concrete material-specific restrictions remain binding.

## Repository areas

- `docs/` – governance, architecture, design references and evidence;
- `mission/tests/` – test harnesses and branch-scoped acceptance evidence;
- `scripts/diagnostics/` – diagnostic mission scripts;
- `scripts/air-operations/` – air-operations bootstrap and support scripts;
- `tools/` – build and validation helpers.
