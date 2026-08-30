---
document_id: OMW-GROUND-NATIVE-HOMEZONE-RETURN-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local isolated DCS test of native MOOSE Ground return-to-origin using the default Warehouse spawnzone/homezone
  - decision gate before Stage 2B adopts or rejects site ACCESS zones as Ground return-homezone overrides
not_authoritative_for:
  - repository-wide Ground return architecture before merge and acceptance
  - suitability of the native MOOSE homezone at installations other than the tested Joyce geometry
  - removal of ZON_BLUE_GND_*_ACCESS zones
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Ground Native Homezone Return – Acceptance 1

## 1. Zweck

Dieser Test isoliert die vor Stage 2B zu klärende Architekturfrage:

```text
Kann eine mobile OMW-Ground-Gruppe nach einer endlichen MOOSE-Mission
mit dem unveränderten MOOSE-ReturnToLegion-Lifecycle
physisch und plausibel zu ihrer Herkunft zurückkehren,
ohne OMW-ACCESS-Override und ohne expliziten OMW-RTZ-Controller?
```

Der Test ist bewusst **kein** FOB-Attack-, QRF-, CampaignState- oder Combat-Test. Er verhindert, dass eine testlokale Fortress-ACCESS-Lösung versehentlich zur projektweiten Ground-Return-Architektur erklärt wird.

## 2. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der gepinnte Source bestätigt für den getesteten Pfad:

```text
WAREHOUSE default spawnzone
-> center = Warehouse object
-> radius = 250 m

LEGION materialization
-> ARMYGROUP belongs to origin LEGION
-> ARMYGROUP homezone derives from origin spawnzone

MissionDone / _CheckGroupDone
-> if origin LEGION exists and legionReturn is true
-> ARMYGROUP:RTZ(self.legion.spawnzone)

ARMYGROUP:RTZ
-> if outside zone: random coordinate inside zone + physical waypoint
-> if inside zone: Returned

Returned
-> origin legion __AddAsset(...)
-> Warehouse recovery / physical cleanup
```

Wichtige Präzisierung gegenüber der vereinfachten Designformulierung `RTZ(self.homezone)`: Im tatsächlich gepinnten `_CheckGroupDone()` ruft MOOSE für ein Ground-Asset konkret

```lua
self:RTZ(self.legion.spawnzone)
```

auf. Da die Herkunfts-`spawnzone` beim normalen LEGION-Pfad zugleich die Homezone des Assets bestimmt, handelt es sich um dieselbe Herkunftsgeometrie; der Acceptance-Callback erwartet jedoch korrekt einen **explizit übergebenen MOOSE-Legion-spawnzone-Parameter** und nicht `Zone == nil`.

## 3. Testobjekte

Der Test verwendet bereits vorhandene Mission-Editor-Objekte:

```text
Origin Warehouse: WH_BLUE_GND_JOYCE
Ground template: TPL_BLUE_GND_PATROL_MATV_4
Destination zone: ZON_BLUE_GND_JOYCE_PATROL_TEST_01
```

Der bekannte Abstand vom Joyce-ACCESS-Bereich zum Patrol-Testbereich beträgt ungefähr 9,45 km. Der Test erzwingt damit eine reale Auswärtsbewegung deutlich außerhalb der nativen 250-m-Warehouse-Spawnzone.

`ZON_BLUE_GND_JOYCE_ACCESS` wird in diesem Test **nicht** verwendet.

## 4. Verbindliche Negativbedingungen

Der Acceptance-Quellcode darf keine der folgenden Return-Abkürzungen verwenden:

```text
WAREHOUSE:SetSpawnZone(...)
BRIGADE:SetSpawnZone(...)
AUFTRAG:SetReturnToLegion(false)
OPSGROUP:SetReturnToLegion(false)
explicit ARMYGROUP:RTZ(customZone, ...)
custom return-delay scheduler that issues RTZ
native world.addEventHandler
MIST
MissionScripting.lua modification
```

Dadurch wird tatsächlich der native MOOSE-Pfad geprüft.

## 5. Missionsaufbau

```text
WH_BLUE_GND_JOYCE
-> BRIGADE
-> PLATOON with one TPL_BLUE_GND_PATROL_MATV_4 asset
-> AUFTRAG:NewNOTHING(ZON_BLUE_GND_JOYCE_PATROL_TEST_01)
-> OnRoad / 27 kt
-> AUFTRAG:SetDuration(30)
-> normal MOOSE mission completion
-> normal MOOSE _CheckGroupDone
-> RTZ(origin LEGION spawnzone)
-> Returned
-> origin Warehouse AddAsset
```

`SetDuration(30)` ist eine MOOSE-eigene AUFTRAG-Konfiguration. Sie macht den technischen Auftrag nach Erreichen/Ausführen endlich, ohne einen projektspezifischen Rückkehrcontroller einzuführen.

## 6. Erwartete Logsequenz

Der DCS-Lauf soll mindestens folgende Marker in plausibler Reihenfolge zeigen:

```text
READY
BRIGADE_STARTED
MISSION_QUEUED
GROUP_MATERIALIZED
ARMY_ON_MISSION
DESTINATION_ZONE_ENTERED
MISSION_EXECUTE_OBSERVED
MISSION_DONE
NATIVE_RTZ_ACTIVE
RETURNED_HANDOFF
WAREHOUSE_ADD_ASSET
PASS
```

Für `NATIVE_RTZ_ACTIVE` wird erwartet:

```text
zone=Warehouse WH_BLUE_GND_JOYCE spawn zone
source=LEGION_SPAWNZONE
```

Der Test schreibt keine feste Rückkehrkoordinate vor. MOOSE darf innerhalb seiner nativen 250-m-spawnzone den tatsächlichen Rückkehrpunkt bestimmen.

## 7. PASS-Kriterien

Technischer PASS erfordert gleichzeitig:

```text
exactly one Ground materialization
exactly one ARMYGROUP on mission
real destination-zone arrival
exactly one mission execution
exactly one MissionDone
exactly one native RTZ event
RTZ zone is the MOOSE-generated Joyce Warehouse spawnzone
exactly one Returned event
exactly one origin Warehouse AddAsset event
physical group cleaned up after Warehouse recovery
no custom SetSpawnZone override
no SetReturnToLegion(false)
no explicit custom RTZ command
```

Zusätzlich ist eine **visuelle Owner-Beobachtung** erforderlich:

```text
spawn/materialization does not visibly collide with or drive through protected FOB/COP geometry
outbound movement is physically plausible
return route is physically plausible
no observable teleport
return does not force the group through HESCOs/statics/buildings
cleanup occurs only after a plausible physical return into the native homezone
```

Ein rein logistischer Log-PASS bei sichtbar unplausiblem DCS-Pathfinding ist für die Architekturentscheidung **kein** geometrischer PASS.

## 8. FAIL-/Folgeentscheidung

### Test A besteht technisch und visuell

```text
native 250-m MOOSE spawnzone/homezone is sufficient for the tested site
-> prefer native MOOSE return lifecycle
-> no OMW return controller
-> ACCESS zones remain available for other site-specific materialization/pathfinding needs
```

### Test A scheitert an der Warehouse-zentrierten Geometrie

Dann folgt Test B:

```text
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_JOYCE_ACCESS, validated maxdist)
-> normal ReturnToLegion remains enabled
-> no explicit custom RTZ return controller
```

Dabei müssen Spawn/Departure und Return gemeinsam erneut geprüft werden, da MOOSE dieselbe `spawnzone` für mehrere Lifecycle-Teile verwendet.

### Test A und B scheitern

Erst dann darf eine zusätzliche OMW-Lösung als MOOSE-Lücke entworfen werden. Eine produktive Eigenlösung erfordert weiterhin die ausdrückliche Freigabe des Projektinhabers.

## 9. Nachfolgende Pflichtprüfung

Ein Joyce-PASS beweist noch keine projektweite Standortgeneralität. Danach bleibt mindestens erforderlich:

```text
Cross-site origin provenance:
asset originates at site A
-> operates/supports at site B
-> mission ends near B
-> native return goes to A
-> Returned credits A Legion/Warehouse
-> CampaignState settles original A deployment/node
```

Erst danach kann die Return-to-origin-Regel über mehrere Ground-Standorte technisch verallgemeinert werden.

## 10. DCS-only Grenze

Bis zum realen Lauf bleiben insbesondere offen:

```text
actual random spawn position inside Joyce default 250-m spawnzone
actual random RTZ waypoint inside that zone
DCS pathfinding through the Joyce local geometry
visual acceptability of spawn and recovery
whether the mobile group reaches Returned without an ACCESS override
```

Status bis dahin:

```text
PENDING_DCS
```
