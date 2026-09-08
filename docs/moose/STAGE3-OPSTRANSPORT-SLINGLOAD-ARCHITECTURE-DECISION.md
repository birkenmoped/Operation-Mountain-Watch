---
document_id: OMW-MOOSE-STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION
status: PLANNED
document_class: OWNER_DECISION_RECORD
authoritative_for:
  - branch-local Stage 3 CH-47 Air-AMMO transport architecture
  - suspension of external slingload development
  - required MOOSE-first internal OPSTRANSPORT transport path
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
  - branch-local external slingload target for Stage 3 Air-AMMO
  - branch-local use of AUFTRAG:NewCARGOTRANSPORT for the current Stage 3 Air-AMMO target path
  - branch-local PauseMission/TaskDone/CargoTransportation route handoff architecture
superseded_by:
---

# Stage 3 – OPSTRANSPORT / Slingload Architekturentscheidung

## 1. Zweck

Dieses Dokument hält die ausdrückliche Entscheidung des Projektinhabers vom 08.09.2026 für den aktuellen Stage-3-CH-47-Air-AMMO-Pfad fest.

Die weitere Entwicklung einer sichtbaren externen Slingload-Repräsentation wird **bis auf Weiteres gestoppt**. Für den aktuellen Stage-3-Air-AMMO-Transport wird der bereits funktionierende interne MOOSE-Transport mit CH-47 verwendet.

Diese Entscheidung ist auf dem Arbeitsbranch unmittelbar anzuwenden. Repository-weite normative Wirkung entsteht gemäß `docs/00-project-governance.md` erst durch Merge nach `main` oder eine entsprechende Entscheidung auf `main`.

## 2. Verbindliche aktuelle Entscheidung

Für den aktuellen Stage-3-Air-AMMO-Transport gilt:

```text
Transport lifecycle: MOOSE OPSTRANSPORT
Carrier: Jalalabad CH-47 via MOOSE AIRWING/SQUADRON/FLIGHTGROUP
Cargo representation: internal MOOSE OPSTRANSPORT/STORAGE transport
Pickup: Jalalabad
Delivery: Wright
Outbound route: configured logical OMW_FlightPath route
Return route: same configured route in reverse
Strategic authority: CampaignState
Physical runtime/lifecycle authority: MOOSE
```

Zielablauf:

```text
Jalalabad
-> CH-47 MOOSE OPSTRANSPORT pickup/load
-> configured FlightPath outbound
-> Wright delivery/unload
-> OPSTRANSPORT Delivered
-> configured FlightPath reverse
-> Jalalabad landing
-> AIRWING/LEGION recovery
```

Eine sichtbare externe Slingload-Darstellung ist **kein aktuelles Entwicklungsziel**.

## 3. Gestoppter Slingload-Pfad

Bis zu einer neuen ausdrücklichen Eigentümerentscheidung gilt:

```text
NO further external slingload development
NO new external slingload acceptance mission
NO further patching of AUFTRAG:NewCARGOTRANSPORT slingload handoff
NO PauseMission()/TaskDone() slingload route handoff
NO re-injected DCS CargoTransportation task as lifecycle bridge
NO OMW_SlingloadCorridorHandoff as current Stage 3 target architecture
```

Historische Slingload-Dateien, Tests, Logs und Entscheidungen bleiben als Entwicklungs- und Fehlernachweis erhalten. Sie dürfen nicht als aktueller Zielpfad interpretiert werden.

## 4. Aktuelle MOOSE-first Architektur

Der aktive Zielpfad verwendet den bereits source-geprüften MOOSE-Mechanismus:

```text
OPSTRANSPORT:New(nil, PickupZone, DeployZone)
-> AddCargoStorage(StorageFrom, StorageTo, CargoType, Amount, ItemWeight)
-> SetRequiredCarriers(1,1)
-> CH-47 carrier recruitment from Jalalabad AIRWING/SQUADRON
-> OPSTRANSPORT loading
-> OPSTRANSPORT transport
-> OPSTRANSPORT unloading
-> OPSTRANSPORT Delivered
```

Für den Feld-LZ-Zielpunkt Wright bleibt die kleine MOOSE-nahe Routenintegration zuständig:

```text
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
```

Sie besitzt keine Cargo- oder Delivery-Autorität. Sie nutzt öffentliche `FLIGHTGROUP`-Methoden, um den owner-konfigurierten FlightPath vor beziehungsweise nach dem OPSTRANSPORT-Lifecycle einzufügen.

Aktueller Routing-Vertrag:

```text
OnAfterTransport
-> configured FlightPath outbound
-> FLIGHTGROUP:AddWaypoint(...)
-> FLIGHTGROUP:UpdateRoute()

OnAfterDelivered
-> configured FlightPath reverse
-> FLIGHTGROUP:AddWaypoint(...)
-> FLIGHTGROUP:UpdateRoute()
```

## 5. Relevante offizielle MOOSE-Richtung

Die offizielle MOOSE-Demo

```text
Ops/Transport/Transport - 051 - COMBINED By All Means/
Transport - 051 - COMBINED By All Means.lua
```

bestätigt die grundlegende Richtung:

```text
OPSTRANSPORT
FLIGHTGROUP helicopter carrier
AddOpsTransport()
AddPathTransport()
```

Sie wird nicht mehr als Nachweis für eine externe Slingload-Darstellung interpretiert.

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 6. Bereits vorhandener fokussierter interner OPSTRANSPORT-Pfad

Die aktuelle fokussierte Acceptance implementiert diesen Zielpfad bereits in:

```text
mission/tests/stage3-cas-resupply-focused/src/02-stage3-cas-resupply-opstransport-acceptance.lua
```

Sie verwendet:

```text
OPSTRANSPORT
STORAGE cargo transfer
Jalalabad CH-47 recruitment
OMW_OpsTransportCorridorAdapter
configured logical OMW_FlightPath selection
outbound route installation
Wright Delivered verification
reverse route installation
Jalalabad landing/AIRWING recovery verification
```

Damit ist für die nächste Arbeit **keine neue Slingload-Architektur** zu entwickeln. Die bestehende interne OPSTRANSPORT-Lösung ist zu härten und anschließend exakt zu testen.

## 7. Acceptance-Grenze

Vor einem neuen DCS-Lauf sind statisch/offline mindestens zu prüfen:

```text
active Stage 3 target uses OPSTRANSPORT/STORAGE only
no active Stage 3 target depends on AUFTRAG:NewCARGOTRANSPORT slingload handoff
configured FlightPath selection is logical-name based, not hard-coded to a concrete R/L offset
outbound route is installed for the CH-47 after OPSTRANSPORT transport begins
Wright delivery is confirmed by OPSTRANSPORT/STORAGE state
reverse route is installed on OPSTRANSPORT Delivered
Jalalabad landing and AIRWING/LEGION recovery remain observable acceptance gates
```

Der DCS-Acceptance-Vertrag lautet:

```text
CH-47 departs Jalalabad
-> flies configured FlightPath outbound
-> carries Air-AMMO internally through MOOSE OPSTRANSPORT
-> delivers/unloads at Wright
-> flies the configured FlightPath in reverse
-> lands at Jalalabad
-> is recovered by AIRWING/LEGION
```

Erst ein realer Lauf mit vollständiger Provenienz darf als `VALIDATED` dokumentiert werden.
