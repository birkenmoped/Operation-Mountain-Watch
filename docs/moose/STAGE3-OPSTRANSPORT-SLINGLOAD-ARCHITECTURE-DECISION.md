---
document_id: OMW-MOOSE-STAGE3-OPSTRANSPORT-SLINGLOAD-ARCHITECTURE-DECISION
status: PLANNED
document_class: OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 3 CH-47 Air-AMMO transport architecture
  - suspension of external slingload development
  - required MOOSE-first internal OPSTRANSPORT transport path
  - branch-local CH-47 full-response transit speed and lead-turn acceptance profile
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

Dieses Dokument hält die ausdrücklichen Entscheidungen des Projektinhabers vom 08.09.2026 für den aktuellen Stage-3-CH-47-Air-AMMO-Pfad fest.

Die weitere Entwicklung einer sichtbaren externen Slingload-Repräsentation wird **bis auf Weiteres gestoppt**. Für den aktuellen Stage-3-Air-AMMO-Transport wird der funktionierende interne MOOSE-Transport mit CH-47 verwendet.

Zusätzlich wird für den nächsten Full-Response-Acceptance-Lauf ein explizites CH-47-Transitprofil mit 125 kt und eine bounded Lead-Turn-/Fly-by-Approximation von 250 m getestet.

## 2. Verbindliche aktuelle Entscheidung

```text
Transport lifecycle: MOOSE OPSTRANSPORT
Carrier: Jalalabad CH-47 via MOOSE AIRWING/SQUADRON/FLIGHTGROUP
Cargo representation: internal MOOSE OPSTRANSPORT/STORAGE transport
Pickup: Jalalabad
Delivery: Wright
Outbound route: configured logical OMW_FlightPath route
Return route: same configured route in reverse
Full-response CH-47 transit speed: 125 kt
Full-response lead-turn test distance: 250 m, bounded by route geometry
Strategic authority: CampaignState
Physical runtime/lifecycle authority: MOOSE
```

Zielablauf:

```text
Jalalabad
-> CH-47 MOOSE OPSTRANSPORT pickup/load
-> configured FlightPath outbound at 125 kt with bounded lead-turn geometry
-> Wright delivery/unload
-> OPSTRANSPORT Delivered
-> configured FlightPath reverse at same profile
-> Jalalabad landing
-> AIRWING/LEGION recovery
```

Eine sichtbare externe Slingload-Darstellung ist kein aktuelles Entwicklungsziel.

## 3. Gestoppter Slingload-Pfad

```text
NO further external slingload development
NO new external slingload acceptance mission
NO further patching of AUFTRAG:NewCARGOTRANSPORT slingload handoff
NO PauseMission()/TaskDone() slingload route handoff
NO re-injected DCS CargoTransportation task as lifecycle bridge
NO OMW_SlingloadCorridorHandoff as current Stage 3 target architecture
```

Historische Slingload-Dateien, Tests, Logs und Entscheidungen bleiben Evidenz, aber nicht aktueller Zielpfad.

## 4. Aktuelle MOOSE-first Architektur

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

Für Wright als Feld-LZ bleibt die kleine MOOSE-nahe Routenintegration zuständig:

```text
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
```

Sie besitzt keine Cargo- oder Delivery-Autorität und nutzt ausschließlich öffentliche MOOSE-`COORDINATE`-/`FLIGHTGROUP`-Methoden.

## 5. Relevante MOOSE-Quellenlage

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Source-verifiziert:

```text
FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)
Speed parameter: knots
Speed=nil: FLIGHTGROUP:GetSpeedCruise()
added air waypoint type/action: TurningPoint / TurningPoint
COORDINATE:GetIntermediateCoordinate(...)
COORDINATE:Get2DDistance(...)
COORDINATE:HeadingTo(...)
```

Der generische MOOSE-Rotary-Wing-Cruise-Default erklärt den bisherigen Transit nahe 100–110 kt. Der kommende Acceptance-Lauf setzt deshalb den Speed ausdrücklich am Waypoint, ohne den globalen MOOSE-Default zu verändern.

Für eine öffentliche FLIGHTGROUP-API im Sinn von

```text
SetLeadTurnDistance(...)
SetFlyByDistance(...)
SetTurnAnticipation(...)
```

wurde im gepinnten MOOSE-Stand kein belegter öffentlicher Pfad gefunden.

MOOSE verwendet an anderer Stelle selbst zusätzliche Zwischenkoordinaten zur Glättung einer Kurvengeometrie. Der OMW-Adapter folgt deshalb der MOOSE-first-Richtung, indem er die Geometrie mit öffentlichen `COORDINATE`-Methoden vorbereitet und anschließend normale MOOSE-TurningPoint-Waypoints verwendet.

## 6. CH-47 Transitgeschwindigkeit

Für den nächsten Full-Response-Lauf gilt:

```text
CH47_TRANSIT_SPEED_KTS = 125
```

Begründung der Projektentscheidung:

- der bisherige `nil`-Speed ließ MOOSE den generischen Hubschrauber-Cruise-Default wählen;
- 125 kt ist die Owner-gewählte Baseline für einen gemeinsamen taktischen CH-47/AH-64-Verband;
- der Wert wird nur für diesen OMW-Transportkorridor explizit gesetzt;
- keine globale MOOSE-Speed-Konfiguration wird verändert.

Diese Geschwindigkeit ist bis zum realen DCS-Test **STAGED**, nicht `VALIDATED`.

## 7. Lead-Turn-/Fly-by-Approximation

Der Projektinhaber wünscht ein weniger eckiges Abfliegen der owner-authored FlightPath-Punkte. Da `FLIGHTGROUP:AddWaypoint()` bereits Turning Points erzeugt, aber keine öffentliche Lead-Turn-Distance-Option nachgewiesen ist, verwendet `OMW_OpsTransportCorridorAdapter.lua` Schema 2 eine bounded Geometrie-Approximation.

Für einen Innenpunkt `B` zwischen `A` und `C`:

```text
A ---- B ---- C
```

wird bei relevantem Richtungswechsel erzeugt:

```text
A ---- B_before
          \
           
            B_after ---- C
```

mit öffentlichen MOOSE-Aufrufen:

```text
B:GetIntermediateCoordinate(A, trimM)
B:GetIntermediateCoordinate(C, trimM)
```

Der exakte Eckpunkt `B` wird für diese Kurve nicht als zusätzlicher Waypoint ausgegeben. DCS erhält dadurch einen chord-basierten TurningPoint-Verlauf, der den Kurswechsel vor dem alten Vertex beginnen kann.

Acceptance-Parameter:

```text
requested lead-turn distance: 250 m
minimum applied trim: 50 m
maximum trim: 25% of each adjacent leg
minimum heading change: 5 deg
first route point: exact
last route point: exact
speed: 125 kt
```

Diese Logik verändert **nur die Waypoint-Geometrie**. OPSTRANSPORT-Lifecycle, Cargo, Delivered, CampaignState und AIRWING-Recovery bleiben unverändert.

## 8. Routing-Vertrag

Outbound:

```text
OnAfterTransport
-> configured FlightPath outbound
-> bounded lead-turn geometry
-> FLIGHTGROUP:AddWaypoint(..., 125 kt, ...)
-> FLIGHTGROUP:UpdateRoute()
```

Return:

```text
OnAfterDelivered
-> configured FlightPath reverse
-> bounded lead-turn geometry
-> FLIGHTGROUP:AddWaypoint(..., 125 kt, ...)
-> FLIGHTGROUP:UpdateRoute()
```

Der Adapter protokolliert pro Richtung:

```text
sourcePoints
routePoints
smoothedCorners
speedKts
leadTurnM
```

Damit ist der nächste DCS-Lauf auswertbar, ohne die Route visuell erraten zu müssen.

## 9. Bereits vorhandener interner OPSTRANSPORT-Nachweis

Der fokussierte interne OPSTRANSPORT-Test hat bereits bestätigt:

```text
OPSTRANSPORT Delivered
configured FlightPath outbound
configured FlightPath reverse after Delivered
MOOSE STORAGE transfer
Jalalabad CH-47 lifecycle
```

Dieser Nachweis gilt nur für den exakt dokumentierten früheren Stand. Die neue 125-kt-/Lead-Turn-Geometrie ist eine neue Acceptance-Variable und muss separat im Full-Response-Lauf geprüft werden.

## 10. Acceptance-Grenze

Vor DCS:

```text
active Stage 3 target uses OPSTRANSPORT/STORAGE only
no NewCARGOTRANSPORT/PauseMission/CargoTransportation handoff
configured FlightPath is logical-name based
adapter schema = OMW-OPSTRANSPORT-CORRIDOR-ADAPTER-2
explicit speed = 125 kt
lead-turn distance = 250 m
only public MOOSE COORDINATE/FLIGHTGROUP route APIs used
Lua syntax/build/static gates PASS
```

DCS-Acceptance:

```text
CH-47 departs Jalalabad
-> flies configured FlightPath outbound with materially faster transit near commanded 125-kt profile
-> route corners appear smoother without invalid shortcut/path loss
-> carries Air-AMMO internally through MOOSE OPSTRANSPORT
-> delivers/unloads at Wright
-> flies configured FlightPath in reverse with same profile
-> lands at Jalalabad
-> is recovered by AIRWING/LEGION
```

Erst ein realer Lauf mit vollständiger Provenienz darf die neue Route-/Speed-Konfiguration als `VALIDATED` dokumentieren.
