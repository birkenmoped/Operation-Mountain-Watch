---
document_id: OMW-MOOSE-STAGE3-OPSTRANSPORT-EXTERNAL-SLINGLOAD-GAP
status: SUPERSEDED
document_class: MOOSE_GAP_ANALYSIS
owning_policy: OMW-GOV-001
authoritative_for:
  - historical branch-local technical gap analysis for Stage 3 OPSTRANSPORT external slingload
  - verified pinned-MOOSE behavior of OPSTRANSPORT AddOpsTransport and AddPathTransport
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
  - OMW-MOOSE-STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION
---

# Stage 3 – OPSTRANSPORT External Slingload: historische MOOSE Gap Analysis

> **SUPERSEDED:** Der Projektinhaber hat am 08.09.2026 die weitere Entwicklung externer Slingload-Fracht bis auf Weiteres gestoppt. Aktueller Stage-3-Air-AMMO-Pfad ist CH-47 + MOOSE OPSTRANSPORT + interne STORAGE-Fracht + konfigurierte `OMW_FlightPath`-Hin-/Rückroute. Diese Datei bleibt ausschließlich als technischer Recherche- und Fehlernachweis erhalten.

## 1. Anlass und damaliger Rahmen

Diese Analyse entstand während der inzwischen gestoppten Untersuchung, ob eine sichtbare externe Slingload-Repräsentation in den OPSTRANSPORT-Lifecycle eingebunden werden kann.

Der bereits damals verworfene Pfad

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()
TaskDone()
re-issued CargoTransportation
```

bleibt verworfen und darf nicht weiter repariert werden.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. Verifizierter OPSTRANSPORT-Grundpfad

Der gepinnte Source bestätigt den öffentlichen Carrier-Pfad:

```lua
myopsgroup:AddOpsTransport(opstransport)
```

`OPSTRANSPORT` kann von einem `FLIGHTGROUP` als Carrier ausgeführt werden.

```text
OPSTRANSPORT lifecycle: AVAILABLE
FLIGHTGROUP helicopter carrier: AVAILABLE
FLIGHTGROUP:AddOpsTransport(OPSTRANSPORT): AVAILABLE
```

## 4. Verifizierte AddPathTransport-Signatur und Semantik

Der gepinnte Source enthält:

```lua
function OPSTRANSPORT:AddPathTransport(PathGroup, Reversed, Radius, TransportZoneCombo)
```

Die Implementierung verwendet:

```lua
if type(PathGroup)=="string" then
  PathGroup=GROUP:FindByName(PathGroup)
end

local path={}
path.category=PathGroup:GetCategory()
path.radius=Radius or 0
path.waypoints=PathGroup:GetTaskRoute()
table.insert(TransportZoneCombo.TransportPaths, path)
```

Daraus folgt:

```text
1. AddPathTransport erwartet eine GROUP beziehungsweise einen Gruppennamen.
2. Die Route stammt aus GROUP:GetTaskRoute().
3. Die GROUP-Kategorie bestimmt die Carrier-Kategorie des Pfads.
4. Eine MOOSE PATHLINE ist kein dokumentierter oder implementierter Parameter von AddPathTransport.
5. Der Parameter Reversed ist in der gepinnten Implementierung vorhanden, wird dort aber nicht ausgewertet.
```

Die OMW-Mission verwendet dagegen den logischen Routevertrag:

```text
logical: OMW_FlightPath
configured variant: OMW_FlightPath / OMW_FlightPath_Rnnn / OMW_FlightPath_Lnnn
MOOSE representation: PATHLINE
```

Für Wright als Feld-LZ wird diese Repräsentationslücke im aktuellen internen OPSTRANSPORT-Pfad durch `scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua` geschlossen. Der Adapter ergänzt ausschließlich öffentliche FLIGHTGROUP-Waypoints und übernimmt keine Transport-FSM- oder Cargo-Autorität.

## 5. Offizielle Demo `Transport - 051 - COMBINED By All Means`

Geprüfte offizielle Demo:

```text
FlightControl-Master/MOOSE_MISSIONS
Ops/Transport/Transport - 051 - COMBINED By All Means/
Transport - 051 - COMBINED By All Means.lua
```

Die Demo bestätigt:

```lua
local transport=OPSTRANSPORT:New(CargoSet, zonePickup, zoneDeploy)

transport:AddPathTransport(GROUP:FindByName("Path Novorossiysk-Gelendzhik Ground"))
transport:AddPathTransport(GROUP:FindByName("Path Novorossiysk-Gelendzhik Naval"))
transport:AddPathTransport(GROUP:FindByName("Path Novorossiysk-Gelendzhik Airplane"))

local Mi26=FLIGHTGROUP:New("Mi-26 Alpha-1")
Mi26:Activate()
Mi26:AddOpsTransport(transport)
```

Damit ist der MOOSE-Grundmechanismus `OPSTRANSPORT + FLIGHTGROUP + AddOpsTransport + AddPathTransport` bestätigt. Die Demo beweist weder eine direkte PATHLINE-Übergabe an `AddPathTransport()` noch eine externe Slingload-Darstellung innerhalb von OPSTRANSPORT.

## 6. Verifizierte OPSTRANSPORT-Cargo-Typen

Der gepinnte Source dokumentiert für OPSTRANSPORT:

```text
OPSGROUP
STORAGE
```

Für STORAGE lautet der öffentliche Pfad:

```lua
local transport=OPSTRANSPORT:New(nil, PickupZone, DeployZone)
transport:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight)
carrier:AddOpsTransport(transport)
```

Die STORAGE-Daten werden im Carrier-Cargobay und über den OPSTRANSPORT Loading-/Transporting-/Unloading-/Delivered-Lifecycle geführt.

Während der damaligen Slingload-Untersuchung wurde in der geprüften OPSTRANSPORT-Implementierung kein öffentlicher Mechanismus nachgewiesen, der einen STATIC-Cargo als sichtbaren externen Slingload an einen AI-Helikopter bindet und zugleich im OPSTRANSPORT-FSM als Cargo führt. Diese offene Untersuchung wird aufgrund der späteren Owner-Entscheidung nicht fortgesetzt.

## 7. Historischer Nachweisstand

```text
MOOSE direct support verified:
  OPSTRANSPORT lifecycle: YES
  FLIGHTGROUP:AddOpsTransport(): YES
  OPSTRANSPORT:AddPathTransport(GROUP): YES
  OPSTRANSPORT STORAGE transfer: YES

Verified route limitation:
  OPSTRANSPORT:AddPathTransport(PATHLINE): NO
  public PATHLINE -> AddPathTransport conversion API: NOT FOUND

External slingload question:
  further investigation: SUSPENDED BY OWNER DECISION
```

## 8. Nicht zulässige Schlussfolgerungen

Aus der offiziellen Demo darf nicht abgeleitet werden:

```text
AddPathTransport accepts PATHLINE: FALSE
Transport - 051 demonstrates helicopter path template: FALSE
Transport - 051 proves external slingload inside OPSTRANSPORT: FALSE
```

Ebenso darf die frühere `NewCARGOTRANSPORT`-Ausnahme nicht reaktiviert werden.

## 9. Aktuelle Konsequenz

Die frühere Ausnahme-/Fallback-Untersuchung ist beendet. Eine Owner-Freigabe für eine neue Slingload-Lösung wird aktuell weder benötigt noch beantragt.

Der aktive Zielpfad lautet:

```text
Jalalabad
-> CH-47
-> MOOSE OPSTRANSPORT internal STORAGE
-> configured OMW_FlightPath outbound
-> Wright delivery / OPSTRANSPORT Delivered
-> configured OMW_FlightPath reverse
-> Jalalabad landing
-> AIRWING/LEGION recovery
```

## 10. Status

```text
NewCARGOTRANSPORT legacy handoff: REJECTED
external slingload development: SUSPENDED BY OWNER
OPSTRANSPORT core lifecycle: VERIFIED IN PINNED SOURCE
AddOpsTransport carrier binding: VERIFIED IN PINNED SOURCE
AddPathTransport GROUP route semantics: VERIFIED IN PINNED SOURCE
Transport 051 demo: VERIFIED
current Stage 3 Air-AMMO target: INTERNAL OPSTRANSPORT/STORAGE
DCS validation of reconciled full-response path: PENDING
```
