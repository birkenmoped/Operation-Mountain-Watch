---
document_id: OMW-MOOSE-STAGE3-OPSTRANSPORT-EXTERNAL-SLINGLOAD-GAP
status: PLANNED
document_class: MOOSE_GAP_ANALYSIS
authoritative_for:
  - branch-local technical gap analysis for Stage 3 OPSTRANSPORT external slingload
  - verified pinned-MOOSE behavior of OPSTRANSPORT AddOpsTransport and AddPathTransport
  - owner approval gate before any non-MOOSE/native-DCS fallback
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# Stage 3 – OPSTRANSPORT External Slingload: MOOSE Gap Analysis

## 1. Anlass und verbindlicher Rahmen

Der aktuelle Stage-3-Zielpfad ist branch-lokal festgelegt in:

```text
docs/moose/STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION.md
```

Verbindliche Richtung:

```text
MOOSE OPSTRANSPORT
+ FLIGHTGROUP helicopter carrier
+ FLIGHTGROUP:AddOpsTransport()
+ OPSTRANSPORT:AddPathTransport()
+ gewünschte physische Repräsentation: externer Slingload
```

Der frühere Pfad

```text
AUFTRAG:NewCARGOTRANSPORT()
PauseMission()
TaskDone()
re-issued CargoTransportation
```

ist verworfen und darf nicht weiter repariert werden.

Diese Analyse folgt `docs/26-moose-first-development-policy.md` und prüft Dokumentation, gepinnten Source und offizielle Demo vor jeder neuen Adapter-/Fallback-Entscheidung.

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

`OPSTRANSPORT` kann von einem `FLIGHTGROUP` als Carrier ausgeführt werden. Der Source verwendet diesen Mechanismus selbst, unter anderem für HELICOPTER-Transportpfade im Warehouse-/LEGION-Lifecycle.

Damit ist bestätigt:

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

Die Implementierung macht daraus ausdrücklich:

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

Wesentliche Konsequenzen:

```text
1. AddPathTransport erwartet eine GROUP beziehungsweise einen Gruppennamen.
2. Die Route stammt aus GROUP:GetTaskRoute().
3. Die GROUP-Kategorie bestimmt, für welche Carrier-Kategorie der Pfad verwendbar ist.
4. Eine MOOSE PATHLINE ist kein dokumentierter oder implementierter Parameter von AddPathTransport.
5. Der Parameter Reversed ist in der gepinnten Implementierung vorhanden, wird dort aber nicht ausgewertet.
```

Damit kann die bestehende Mission-Editor-Linienzeichnung

```text
logical: OMW_FlightPath
configured variant: OMW_FlightPath / OMW_FlightPath_Rnnn / OMW_FlightPath_Lnnn
MOOSE representation: PATHLINE
```

nicht direkt an `OPSTRANSPORT:AddPathTransport()` übergeben werden.

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

Die Demo bestätigt damit den vorgesehenen MOOSE-Grundmechanismus `OPSTRANSPORT + FLIGHTGROUP + AddOpsTransport + AddPathTransport`.

Sie bestätigt jedoch **nicht**, dass eine `PATHLINE` direkt als Transportpfad verwendet werden kann. Ebenso enthält die Demo keinen expliziten Helicopter-`AddPathTransport`-Pfad; die gezeigten Pfadgruppen sind Ground, Naval und Airplane.

## 6. Verifizierter OPSTRANSPORT-Cargo-Typ

Der gepinnte Source dokumentiert für OPSTRANSPORT zwei Cargo-Repräsentationen:

```text
OPSGROUP
STORAGE
```

Für Storage-Transport lautet der öffentliche Pfad:

```lua
local transport=OPSTRANSPORT:New(nil, PickupZone, DeployZone)
transport:AddCargoStorage(StorageFrom, StorageTo, CargoType, CargoAmount, CargoWeight)
carrier:AddOpsTransport(transport)
```

Die Storage-Daten werden im Carrier-Cargobay geführt. Der gepinnte OPSTRANSPORT-/OPSGROUP-Code verwaltet hierfür Cargo-Bay-Gewicht, reservierten/geladenen Storage-Anteil und interne Loading-/Unloading-Zustände.

In der geprüften `OPSTRANSPORT`-Implementierung wurde **kein öffentlicher Mechanismus gefunden**, der einen `STATIC`-Cargo als sichtbaren externen Slingload an einen AI-Helicopter anhängt und diesen physischen Slingload zugleich im OPSTRANSPORT-FSM als Cargo führt.

Insbesondere wurde für OPSTRANSPORT kein Gegenstück gefunden zu:

```text
DCS CargoTransportation task
AUFTRAG:NewCARGOTRANSPORT(STATIC, DropZone)
```

Das ist relevant, weil genau `AUFTRAG:NewCARGOTRANSPORT()` gemäß aktueller Owner-Entscheidung nicht mehr als Transport-Lifecycle verwendet werden darf.

## 7. Verifizierte technische Lücke

Aktueller Nachweisstand:

```text
Requirement:
  OPSTRANSPORT remains the transport lifecycle
  FLIGHTGROUP helicopter remains the carrier
  configured OMW_FlightPath remains the route contract
  cargo must be physically visible as external slingload

MOOSE direct support verified:
  OPSTRANSPORT lifecycle: YES
  FLIGHTGROUP:AddOpsTransport(): YES
  OPSTRANSPORT:AddPathTransport(GROUP): YES
  OPSTRANSPORT storage transfer: YES

MOOSE direct support not verified / absent in pinned implementation:
  OPSTRANSPORT:AddPathTransport(PATHLINE): NO
  public PATHLINE -> AddPathTransport conversion API: NOT FOUND
  OPSTRANSPORT physical STATIC external slingload binding: NOT FOUND
```

Damit bestehen zwei getrennte Integrationslücken:

```text
A. Route representation gap:
   OMW route is a PATHLINE, AddPathTransport consumes GROUP:GetTaskRoute().

B. Physical cargo representation gap:
   OPSTRANSPORT STORAGE is internal cargo-bay accounting;
   no verified public OPSTRANSPORT API attaches a STATIC as external slingload.
```

## 8. Nicht zulässige Schlussfolgerungen

Aus der offiziellen Demo darf nicht abgeleitet werden:

```text
AddPathTransport accepts PATHLINE: FALSE
Transport - 051 demonstrates helicopter path template: FALSE
OPSTRANSPORT natively creates physical external slingload STATIC cargo: NOT PROVEN
```

Ebenso darf die frühere `NewCARGOTRANSPORT`-Ausnahme nicht stillschweigend reaktiviert werden.

## 9. MOOSE-First Konsequenz

Die nächste Implementierung darf nur eine der folgenden Richtungen nehmen:

```text
1. Noch vorhandenen öffentlichen MOOSE-Weg finden, der die beiden Lücken schließt.

oder, falls die Lücken nach vollständiger Prüfung bestehen bleiben:

2. kleinsten Adapter/Fallback entwerfen,
   der OPSTRANSPORT als Lifecycle-Autorität erhält,
   keine parallele Ressourcenhoheit erzeugt,
   keine eigene Transport-FSM baut,
   und nur Route-/Slingload-Repräsentation ergänzt.
```

Für einen nativen DCS-Teil oder Zugriff auf MOOSE-Interna gilt ausdrücklich:

```text
OWNER APPROVAL REQUIRED BEFORE IMPLEMENTATION
```

## 10. Aktueller Entwicklungsstatus

```text
NewCARGOTRANSPORT legacy handoff: REJECTED
OPSTRANSPORT core lifecycle: VERIFIED IN PINNED SOURCE
AddOpsTransport carrier binding: VERIFIED IN PINNED SOURCE
AddPathTransport GROUP route semantics: VERIFIED IN PINNED SOURCE
Transport 051 demo: VERIFIED
PATHLINE direct AddPathTransport support: NOT AVAILABLE IN VERIFIED SIGNATURE
OPSTRANSPORT external STATIC slingload support: NOT FOUND
new fallback approval: NOT YET GRANTED
next DCS test: BLOCKED
```

Vor einem weiteren DCS-Lauf muss die Route-/Slingload-Lücke entweder mit einem nachgewiesenen MOOSE-Weg geschlossen oder eine ausdrücklich genehmigte Minimal-Ausnahme implementiert und offline abgesichert werden.
