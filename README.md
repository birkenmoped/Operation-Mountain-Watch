# Operation Mountain Watch

Dynamic persistent COIN multiplayer campaign for DCS World on the Afghanistan map.

## Binding project governance

Operation Mountain Watch is a **MOOSE-first project**. All available and applicable MOOSE capabilities must be evaluated and used as the implementation foundation. Native DCS scripting, custom project implementations, or hybrid fallbacks may be proposed only after the relevant MOOSE limitation has been documented, and may be adopted only with explicit approval from the project owner.

The complete binding rule and exception process are defined in [`docs/00-project-governance.md`](docs/00-project-governance.md). This rule takes precedence over older or more specific documentation.

## Project goals

- Replayable multiplayer COIN operations inspired by Operation Enduring Freedom
- Persistent blue airbases and forward operating bases with logistics and rebuild mechanics
- Dynamic red insurgent cells, camps, attacks, withdrawal, and regeneration
- Virtualized remote formations to reduce server load
- Player-driven logistics, CSAR, reconnaissance, convoy escort, and strike missions

## Planned technology

- DCS World Mission Editor
- MOOSE as the mandatory implementation foundation
- MOOSE CTLD
- MOOSE CSAR
- Project-specific campaign state, persistence, red-force director, and virtualization modules only where MOOSE does not completely satisfy the approved requirement or where an explicit project-owner exception has been granted

## Status

Early design and prototyping. No gameplay release exists yet.

## Documentation

Project design documents are stored in [`docs/`](docs/).

The binding MOOSE-first governance and owner-controlled exception process are documented in [`docs/00-project-governance.md`](docs/00-project-governance.md).

The current consolidation of TM01A test results, DCS routing findings, virtualization design, persistence rules, and the revised logistics hierarchy is documented in [`docs/25-tm01a-findings-virtualization-persistence-and-logistics.md`](docs/25-tm01a-findings-virtualization-persistence-and-logistics.md).

The accepted target architecture for the red personnel network, bounded commander decisions, delayed HUMINT-based knowledge, dynamic scenery sites, destruction, and replacement occupation is documented in [`docs/26-red-force-network-command-intelligence-and-sites.md`](docs/26-red-force-network-command-intelligence-and-sites.md).
