---
document_id: OMW-FIRE-SUPPORT-GATE5-SIX-SITE-GUARD-RUNTIME-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 six-site Guard runtime acceptance procedure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 - Six-Site Guard Runtime Acceptance 1

## Ziel

Dieser Test ist der naechste funktionale DCS-Schritt nach der Gate-5-Vertragskorrektur. Er prueft ausschliesslich, ob an allen sechs Ground-Foundation-Sites je eine Guard-Gruppe durch MOOSE materialisiert und auf der bereits in der v23-Mission vorhandenen owner-authored Guard-PATHLINE bewegt werden kann.

Sites:

```text
JALALABAD_FENTY
COP_FORTRESS
FOB_JOYCE
FOB_WRIGHT
COP_HONAKER
FOB_BOSTICK
```

## MOOSE-first Pfad

Verwendet werden die bereits im gepinnten MOOSE-Stand vorhandenen und fuer diesen Pfad source-geprueften Klassen/Methoden:

```text
BRIGADE:New
BRIGADE:SetSpawnZone
BRIGADE:AddPlatoon
PLATOON:New
COHORT:AddMissionCapability
AUFTRAG:NewONGUARD
AUFTRAG:SetRequiredAssets
AUFTRAG:AssignCohort
BRIGADE:AddMission
PATHLINE:FindByName
PATHLINE:GetCoordinates
COORDINATE:WaypointGround
CONTROLLABLE:TaskFunction
CONTROLLABLE:SetTaskWaypoint
CONTROLLABLE:Route
SCHEDULER:New
```

Der Guard-Route-Mechanismus entspricht dem bereits praktisch verwendeten Honaker-Stage-3-Muster: owner-authored PATHLINE -> Ground-Waypoints -> letzter Waypoint erhaelt einen `CONTROLLABLE.Route`-Task fuer den erneuten Routendurchlauf.

Keine Native-DCS- oder MIST-Routinglogik wird hinzugefuegt.

## Mission-Editor-Vertrag

Keine neuen Mission-Editor-Objekte sind erforderlich. Verwendet werden die bereits nachgewiesenen sechs Guard-PATHLINEs, sechs bestehenden ACCESS-Zonen, sechs bestehenden Ground-Warehouses und das Guard-Template:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Es werden ausdruecklich keine `ZON_BLUE_GND_<SITE>_ALARM`-Triggerzonen verlangt. Alarm-/Security-Perimeter bleiben runtime-generierte `ZONE_RADIUS`/`OPSZONE`-Objekte und sind nicht Teil dieses Tests.

## Testumfang

Nach `OMW_GROUND_READY=1` startet der Acceptance-Harness sechs getrennte BRIGADE-/PLATOON-Kontexte. Jede Site erhaelt genau einen persistenten `ONGUARD`-Auftrag fuer ihre bestehende PATHLINE.

Beobachtungsfenster:

```text
300 Sekunden
```

Diagnoseintervall:

```text
30 Sekunden
```

Mindestbewegung fuer Acceptance 1:

```text
25 Meter vom Materialisierungspunkt
```

## PASS

PASS wird nur ausgegeben, wenn nach dem Beobachtungsfenster fuer alle sechs Sites gilt:

```text
- Guard wurde materialisiert;
- zugehoerige PATHLINE wurde aufgeloest;
- Route wurde gesetzt;
- Guard-Gruppe lebt;
- mindestens 25 m physische Bewegung wurden gemessen.
```

PASS beweist noch keinen vollstaendigen Rundkurs und noch keine Alarm-/QRF-/ARTY-/CAS-/Resupply-Funktion.

## FAIL

FAIL wird insbesondere ausgegeben bei:

```text
- fehlender Registry-Site;
- fehlender ACCESS-Zone;
- fehlender PATHLINE;
- weniger als zwei PATHLINE-Koordinaten;
- fehlendem MOOSE GROUP wrapper nach Materialisierung;
- nicht gestarteter Route;
- toter/nicht vorhandener Guard-Gruppe;
- weniger als 25 m Bewegung innerhalb von 300 Sekunden.
```

## Ausdrueckliche Exclusions

```text
- kein Feindangriff;
- kein Alarm-/OPSZONE-Acceptance;
- kein QRF;
- keine lokale oder externe ARTY;
- kein CAS;
- kein Ground-/Air-Resupply;
- kein CampaignState-Settlement-Test;
- keine MIZ-Mutation.
```

## Builder

```text
tools/build-fire-support-strategic-resupply-gate5-six-site-guard-runtime.ps1
```

Output:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/OMW_FireSupStratResupply_Gate5_Six_Site_Guard_Runtime.lua
```

Pinned MOOSE:

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Arbeitsablauf-Korrektur

Der Lua-Source darf nicht direkt in PowerShell ausgefuehrt werden. Die vorherige Ausgabe des noch nicht versionierten Lua-Quelltexts fuehrte genau zu diesem vermeidbaren Fehler und ist separat dokumentiert unter:

```text
results/2026-09-12-gate5-lua-pasted-into-powershell-correction.md
```

Der Projektinhaber erhaelt erst nach Remote-Verfuegbarkeit des versionierten Source und Builders einen einzigen PowerShell-Auftrag fuer Pull, Build und Hash. Danach folgt der DCS-Test mit dem erzeugten Bundle.
