---
document_id: OMW-MOOSE-STAGE3-CAS-TACTICAL-CORRIDOR
status: BINDING
document_class: TECHNICAL_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 Honaker AH-64 CAS ingress, battle-position and egress geometry
  - MOOSE AUFTRAG waypoint-method semantics for that CAS scope
  - OMW and MOOSE responsibility boundary
  - prohibited CAS route substitutions and regression prevention
  - required static and DCS acceptance evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Stage 3 assumptions that a PATHLINE endpoint or arbitrary MOOSE point is a tactical CAS ingress or egress
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 Honaker – Dynamischer CAS-Taktikkorridor und MOOSE-Waypoint-Semantik

## 1. Verbindliche Entscheidung

Für jeden AH-64-CAS-Auftrag nach Honaker bestimmt OMW die vollständige taktische Geometrie. Die drei Begriffe sind **dynamische Knoten je Allocation**, nicht statische Mission-Editor-Marker und nicht beliebige Punkte innerhalb der AO:

```text
Jalalabad -> R500 -> WEST
-> CAS_INGRESS
-> taktischer Ingress-/Terrain-Masking-Korridor
-> CAS_MISSION_POINT / Battle Position (BP)
-> PATROLZONE working area
-> taktischer Egress-Korridor
-> CAS_EGRESS
-> WEST reverse -> R500 reverse -> Jalalabad
```

`WEST` ist ein sicherer Transitkorridor. Er führt nicht bis in das Gefecht. Der Übergang in den Gefechtsraum erfolgt rund 3–4 NM vor Honaker über den berechneten `CAS_INGRESS`. `CAS_EGRESS` ist ein räumlich getrennter, bewusst berechneter Rückkehrknoten zum WEST-Rückkorridor; er ist weder der Ingress noch der erste/letzte PATHLINE-Punkt.

OMW berechnet pro Auftrag mindestens:

| Wert | Zweck | Muss in der Runtime-Evidenz stehen |
|---|---|---|
| `CAS_INGRESS` | Eintritt vom WEST-Transit in den taktischen Anflug | Position, Höhe, Achse, Entfernung/Bezug zu Honaker und WEST |
| `CAS_MISSION_POINT/BP` | Owner-bestimmter Missions-Waypoint/Battle Position | Position, Höhe, Angriffsachse, Bezug zur supported-element geometry |
| `CAS_EGRESS` | Ausflug aus der Gefechtszone zum WEST-Rückkorridor | Position, Höhe, Achse, Abstand zu Ingress und WEST-Wiedereintritt |
| taktische Ingress-/Egress-Segmente | die dazwischenliegenden bewusst gewählten Routenpunkte | Reihenfolge, Höhe, Geschwindigkeit und Anschluss-UIDs |

Die ausgewählte Geometrie muss eigene Kräfte nicht überfliegen und darf keinen willkürlichen Gebirgs- oder PATHLINE-Endpunkt als taktischen Knoten ausgeben. Taktische Eignung – Terrain Masking, sichere Achse, Abstand zu eigenen Kräften und Trennung von An- und Ausflug – bleibt Owner-Planungsentscheidung; sie wird nicht als Fähigkeit von MOOSE oder DCS behauptet.

## 2. Exakte MOOSE-Semantik im gepinnten Stand

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

| Öffentliche Methode | Tatsächliche Wirkung im geprüften Source | Darf nicht als |
|---|---|---|
| `AUFTRAG:SetMissionIngressCoord(c, alt, speed)` | speichert einen einzelnen Ingress-Knoten; beim FLIGHTGROUP-Missionsaufbau wird vor dem Missions-Waypoint ein Waypoint eingefügt | vollständige Ingress-Route, Terrain-Masking oder PATROLZONE-Definition |
| `AUFTRAG:SetMissionWaypointCoord(c)` | setzt den Owner-Missions-Waypoint; der Source verwendet ihn auch im FLIGHTGROUP-Pfad | Ersatz für die PATROLZONE-Arbeitszone oder für eine mehrpunktige BP-Route |
| `AUFTRAG:SetMissionEgressCoord(c, alt, speed)` | fügt nach dem Missions-Waypoint einen einzelnen Egress-Waypoint ein | vollständige Egress-Route oder automatische Rückkehr über WEST/R500 |
| `AUFTRAG:NewPATROLZONE(zone, speed, altitude)` | definiert die MOOSE-CAS/PATROLZONE-Arbeitszone und ihre Task-Parameter | taktische Ingress-/BP-/Egress-Geometrie |
| `FLIGHTGROUP:AddWaypoint(...)` + `OnAfterUpdateRoute` | öffentliche MOOSE-Schnittstelle für die vollständigen owner-authored Segmente und route-ready-Evidenz | Native-DCS-Controller-Task oder Ersatz der MOOSE-Mission-FSM |

```text
AUFTRAG:SetMissionWaypointCoord      Moose.lua:181095
AUFTRAG:SetMissionIngressCoord       Moose.lua:181146
AUFTRAG:SetMissionEgressCoord        Moose.lua:181121
FLIGHTGROUP mission-waypoint build   Moose.lua:225202–225207
FLIGHTGROUP egress-waypoint build    Moose.lua:225240–225252
AUFTRAG:NewPATROLZONE                Moose.lua:177448–177475
```

Die korrekte MOOSE-Konfiguration für die bereits von OMW berechneten Knoten:

```lua
mission:SetMissionIngressCoord(casIngress, ingressAltitudeFt, casSpeedKts)
mission:SetMissionWaypointCoord(casMissionPoint)
mission:SetMissionEgressCoord(casEgress, egressAltitudeFt, casSpeedKts)
```

Danach – nicht anstelle davon – installiert OMW die vollständigen dynamischen Korridorsegmente über öffentliche `FLIGHTGROUP`-Routenmethoden. Route readiness wird über `FLIGHTGROUP:OnAfterUpdateRoute` belegt; ein timer-only Retry ist kein akzeptabler Ersatz.

## 3. MOOSE-first-Prüfung und zulässige kleine Ergänzung

```yaml
requirement: Vollständiger, je Honaker-CAS-Allocation dynamischer taktischer Korridor
moose_version: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_documentation_checked: MOOSE Develop-Dokumentation im bereitgestellten Projektbestand
moose_classes_and_methods_evaluated:
  - AUFTRAG:NewPATROLZONE
  - AUFTRAG:SetMissionIngressCoord
  - AUFTRAG:SetMissionWaypointCoord
  - AUFTRAG:SetMissionEgressCoord
  - FLIGHTGROUP:AddWaypoint
  - FLIGHTGROUP:UpdateRoute
  - FLIGHTGROUP:OnAfterUpdateRoute
moose_source_locations:
  - Moose.lua:177448-177475
  - Moose.lua:181095-181162
  - Moose.lua:225202-225252
official_examples_checked: MOOSE_MISSIONS_UNPACKED master code search; kein Beispiel mit SetMissionIngressCoord gefunden
verified_limitation: MOOSE akzeptiert einzelne Missionsknoten und Routenwaypoints, erzeugt aber keine COIN-spezifische Terrain-Masking-, BP- oder Split-Egress-Geometrie.
smallest_required_fallback: kleine OMW-Geometrie-/Routenadapter-Schicht, die ausschließlich die drei Owner-Knoten und ihre Zwischenpunkte bestimmt und über öffentliche MOOSE-APIs einfügt
integration_with_moose: AUFTRAG, PATROLZONE, SetEngageDetected, FLIGHTGROUP, AIRWING/LEGION und Recovery bleiben MOOSE-owned
owner_approval: Projektinhaber bestätigte den WEST -> dynamischer Ingress -> BP/working area -> dynamischer Egress -> WEST-Vertrag.
approved_scope: nur dynamische OMW-Geometrie und öffentliche MOOSE-Routenintegration; keine Native-DCS-Controller-Tasks, keine parallele Missions-FSM
conditions:
  - keine statischen ME-Marker als Ersatz
  - keine Resolver-Endpunkte als taktische Knoten
  - keine timer-only route readiness
  - keine CAS-Completion aus OPSZONE, attackIncident, raw RED oder 5-NM-Diagnose
required_regressions:
  - UID=3 darf nicht als künstlicher Gebirgseinstieg entstehen
  - CAS muss nach supported-element release die geplante Egress-/WEST-/R500-Rückroute nutzen
  - MOOSE PATROLZONE plus SetEngageDetected bleibt der Engagement-Pfad
planned_acceptance_test: vollständiger Stage-3-Honaker-Wright-Full-Response-Lauf nach statischer Prüfung
```

## 4. Explizit verworfene Fehlmuster

```text
SetMissionIngressCoord(resolved.outbound[1])
SetMissionEgressCoord(resolved.returnRoute[#resolved.returnRoute])
PATHLINE-Endpunkt == taktischer Ingress/Egress
MOOSE-generierter oder zufällig gewählter Ersatzpunkt
statischer Mission-Editor-Marker als Ersatz für allocation-spezifische Geometrie
Timer als Ersatz für OnAfterUpdateRoute-Readiness
direkter FuelLow/Bingo-Rückflug als reguläre CAS-Recovery
CAS-Abschluss durch OPSZONE Defeated, attackIncident, raw RED,
TACTICAL_RED_GROUND_GROUPS_DIAGNOSTIC oder 5-NM-C2-Observation
```

Die reale Build-1-21-Regression ist als Negativnachweis festgehalten: `resolved.outbound[1]` erzeugte UID=3 in ungeeignetem Berggelände. Anschließend verharrte CAS im PATROLZONE-Lauf bis FuelLow/Bingo und nutzte eine direkte statt der kontrollierten Rückroute. Das ist kein akzeptierter Verlauf.

## 5. CAS-Lifecycle bleibt getrennt

Diese Geometrieentscheidung ändert nicht die bereits verbindliche CAS-Entscheidungsautorität:

```text
HONAKER_NO_KNOWN_ATTACKERS
+ CAS on station
+ 30 Sekunden stabile eigene AH-64 detected-groups no-contact Lage
-> SUPPORTED_ELEMENT_RELEASE_NO_KNOWN_ATTACKERS_CAS_NO_CONTACT
-> kontrollierter owner-authored Egress/WEST/R500-Rückweg
```

Ein erkannter engagement-eligible Kontakt aus `state.casFlight:GetDetectedGroups()` hält CAS aktiv. Die lokale Honaker-, QRF-, OPSZONE-, ARTY- oder CampaignState-Lage beendet CAS nicht direkt.

## 6. Abnahme und Nichtbehauptungen

Vor einem neuen DCS-Lauf müssen Source und Bundle nachweisen:

```text
drei dynamische Knoten mit vollständigen Evidenzfeldern geloggt
MOOSE-Missionssetter erhalten genau diese drei Knoten
vollständige Anflug-, BP- und Ausflugsegmente in korrekter Reihenfolge
Anschluss an WEST/R500 outbound und reverse
OnAfterUpdateRoute-Readiness bestätigt
kein verworfenes Fehlmuster im Source oder Bundle
```

Der reale DCS-Lauf muss zusätzlich zeigen:

```text
AH-64 fliegt die konfigurierte Transit- und taktische Ingress-Geometrie
PATROLZONE + SetEngageDetected bleibt ausführbar
supported-element release löst kontrollierten Egress aus
AH-64 fliegt Egress -> WEST -> R500 -> Jalalabad statt FuelLow-direct-RTB
Jalalabad-Landung und AIRWING/LEGION-Recovery sind beobachtet
```

Bis dahin gelten nur Source-Semantik und dokumentierte Planung als geprüft. Weder Terrain-Masking noch Flugprofil, Routenbefolgung, Freigabe oder Recovery sind für den neuen Korridor in DCS validiert.
