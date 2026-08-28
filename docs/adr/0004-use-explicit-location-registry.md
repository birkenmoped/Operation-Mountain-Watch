---
document_id: OMW-ADR-0004-LOCATION-REGISTRY
status: BINDING
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - explicit versioned location registry
  - validation and caching of productive terrain routes
  - use of scenery scans only for bounded discovery
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - implicit semantic interpretation of scenery IDs and F10 labels
superseded_by:
source_branch: design/map-and-unit-catalog
source_commit: fca101b4cf207719941700dd98ec86d92adf1abb
validated_in_dcs: partial
---

# ADR 0004 – Eigenes Ortsregister und validierte Terrainpfade

## Kontext

DCS und MOOSE können Airbases referenzieren, Koordinaten auf Straßen oder Schienen projizieren und Pfade zwischen bekannten Endpunkten berechnen. Sie liefern jedoch keine vollständige semantische Datenbank aller Orte, Rollen, Sektoren und taktischen Eigenschaften.

## Entscheidung

Operation Mountain Watch führt ein eigenes versioniertes Ortsregister und einen eigenen Routengraphen.

- Airbases werden über MOOSE referenziert.
- FOBs, COPs, Dörfer, Pässe, Checkpoints und taktische Zonen erhalten stabile IDs.
- Straßen- und Schienenpfade werden zwischen bekannten Knoten über passende MOOSE-/DCS-Terrainfunktionen erzeugt.
- Jeder produktive Pfad wird praktisch validiert und anschließend versioniert gespeichert.
- Scenery-Scans erzeugen nur Kandidaten in begrenzten Entwicklungszonen.

## Regeln

- Kein flächendeckender Scenery-Scan beim normalen Missionsstart.
- Kein automatisch erzeugter Pfad gilt ohne DCS-Test als produktionsbereit.
- Ein fehlgeschlagener Pfad wird nicht durch eine unmarkierte Luftlinie ersetzt.
- Scenery-Namen oder IDs sind keine semantischen Orts-IDs.
- Infrastruktur ohne passende Routing-API wird nicht als Straße behandelt.
- Freigegebene Routen führen DCS-Version, Länge, Fahrzeugklassen, bekannte Probleme und Validierungsstatus.

## Verweise

- [`OMW-WORLD-DATA-ROUTING`](../16-world-data-and-routing.md)
- [`OMW-ARCH-PATHFINDING-OPTIONS`](../17-pathfinding-options.md)
- [`OMW-MSR-ROUTE-DESIGN`](../49-msr-routendesign-und-infrastrukturmarker.md)
