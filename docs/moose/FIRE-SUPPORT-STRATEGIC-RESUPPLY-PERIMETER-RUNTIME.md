---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic six-site perimeter runtime assembly source contract
  - MOOSE OPSZONE perimeter evidence integration boundary
  - owner-approved current six-site alarm anchor and radius contract
  - incident-local Guard activation contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Fire Support / Strategic Resupply – generische Perimeter-Runtime

Status: SOURCE_REVIEWED / NICHT DCS-VALIDIERT

## Zweck

`OMW_FireSupStratResupply_PerimeterRuntime.lua` verdrahtet den MOOSE-`OPSZONE`-Perimeter fuer die registrierten Ground-Installationen. Das Modul fuehrt keine eigene Missionsauswahl, Ressourcenlogik, Weltabfrage oder eigenen Scheduler ein.

Der Perimeter ist **nicht** die Incident-Autoritaet. Er ist die fruehe Alarm-/Response-Grenze. Ein durch den MOOSE-`OPSZONE`-Scan festgestellter lebender RED-Ground-Teilnehmer innerhalb des Perimeters wird lediglich als `PROXIMITY_INTRUSION`-Evidence an den bestehenden Installation-Attack-Incident-Layer uebergeben.

Der aktuelle Laufzeitpfad lautet:

```text
SiteRegistry
-> site-spezifischer Installationsanker + Alarmradius
-> OMW_FobThreatOpsZoneAdapter
-> MOOSE ZONE_RADIUS / OPSZONE
-> MOOSE OPSZONE scan + Evaluated callback
-> living RED ground presence inside alarm perimeter
-> OMW_FireSupStratResupply_PerimeterBridge
-> PROXIMITY_INTRUSION evidence
-> OMW_FireSupStratResupply_InstallationIncidentRuntime
-> OMW_GroundInstallationAttackIncident
-> OMW_FireSupStratResupply_InstallationIncidentBridge
-> OMW_FireSupStratResupply_Base
   -> GUARD as INCIDENT_LOCAL_SECURITY
   -> QRF as INCIDENT_LOCAL_DEFENSE
```

Weitere MOOSE-basierte Evidenzkanaele (`Hit`, `Shot`, `ShootingStart`, gefiltertes `WEAPON`-Impact-Tracking) koennen ueber `OMW_GroundInstallationAlarmEvidenceAdapter` denselben Installation-Incident speisen.

## Owner-Entscheidung 15.09.2026 – GUARD nur bei Alarm

Der Projektinhaber hat die bisherige produktive Zielsemantik der permanent materialisierten und permanent patrouillierenden Guard geaendert:

```text
NORMAL
-> kein physischer Guard
-> OPSZONE ueberwacht den Alarmperimeter

RED im Alarmperimeter
-> Installation Incident
-> GUARD wird lokal materialisiert
-> QRF wird zum Incident-Ziel entsandt

GUARD
-> lokale Installation Security
-> AUFTRAG:NewONGUARD(local materialization anchor)
-> keine permanente PATHLINE-Patrouille
-> kein SetEngageDetected-Zyklus
-> keine proaktive Zielverfolgung ausserhalb der lokalen Sicherung
-> kein zweites QRF-System

QRF
-> mobile Incident Response
-> bestehender A4-8 Direct-Target-Lifecycle bleibt unveraendert

Incident-Schliessung
-> Guard-Demand cancelWhenIncidentClosed=true
-> MOOSE SetReturnToLegion(true) / Legion-Lifecycle
-> QRF bleibt cancelWhenIncidentClosed=false und beendet nach seinem autorisierten Target-Lifecycle
```

Die vorhandenen Guard-PATHLINEs bleiben bestehen. Sie werden im aktuellen Produktionsdesign nur noch durch den akzeptierten Guard-Materializer als validierte kompakte Aufstellungsgeometrie verwendet. Ein kontinuierlicher PATHLINE-Router wird fuer die produktive Guard nicht mehr installiert.

Die alte Gate-5A-Acceptance bleibt Evidenz fuer den exakt damals getesteten persistenten Patrol-Guard-Stand. Sie validiert **nicht** die neue incident-lokale Guard-Semantik.

## MOOSE-First-Nachweis fuer die neue Alarmkopplung

Der gepinnte MOOSE-Stand enthaelt:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Quellseitig bestaetigt:

```text
AUFTRAG:NewONGUARD(Coordinate)
-> ground/naval mission
-> OpenFire
-> AlarmState Auto
-> stand guard at coordinate

OPSZONE:Status()
-> Scan()
-> EvaluateZone()
-> Evaluated()

OPSZONE:GetScannedGroupSet()
-> MOOSE SET_GROUP des aktuellen OPSZONE-Scans
```

Die native `OPSZONE:Attacked`-Transition kann bei BLUE-owned Zone davon abhaengen, dass gleichzeitig BLUE-Kraefte im Gebiet vorhanden sind. Eine permanent materialisierte Guard nur als Voraussetzung fuer den Alarm waere damit zirkulaer zu der Owner-Entscheidung "Guard erst bei Alarm".

Deshalb qualifiziert `OMW_FobThreatOpsZoneAdapter` die Alarmbedingung nun im MOOSE-`OnAfterEvaluated`-Callback aus dem von `OPSZONE` selbst erzeugten `GetScannedGroupSet()`. Das ist **kein eigener World-Scan und kein eigener Scheduler**. Scan, Intervall und FSM-Auswertung bleiben MOOSE-eigen. OMW filtert aus dem bereits vorhandenen MOOSE-Scan lediglich lebende RED-Ground-Gruppen als projektspezifische Alarmsemantik.

`OnAfterAttacked` bleibt als kompatibler MOOSE-Fast-Path erhalten, falls bereits BLUE-Kraefte im Perimeter vorhanden sind. Die aktive Incident-Deduplizierung verhindert eine doppelte Evidence-Erzeugung.

## Autoritaetsgrenzen

```text
OPSZONE scan
= physische Perimeterbeobachtung

OMW_FobThreatOpsZoneAdapter
= kleine Semantikschicht: lebende RED Ground presence -> Alarmstimulus

OMW_GroundInstallationAttackIncident
= autoritative Installation-Incident-Autoritaet

GUARD
= lokale physische Sicherung, incident-scoped

QRF
= mobile physische Incident-Reaktion
```

ARTY und CAS werden durch Perimeter oder Incident-Start nicht automatisch ausgeloest. Sie bleiben explizite C2-Eskalationsanforderungen.

Perimeter-Clear schliesst weiterhin weder Installation-Incident noch Base-Incident. Die autoritative Incident-Schliessung erfolgt separat. Diese Trennung ist besonders wichtig fuer die QRF, deren Mission nicht allein wegen Perimeter-Clear oder Incident-Close beendet werden darf.

## Konfigurationsgrenze

Pro Site werden injiziert:

- `anchorCoordinate`
- `radiusM`
- `priority`
- optional `zoneName`
- optional `updateSeconds`
- optional `captureThreatlevel`
- optional `captureNunits`

Coalition-IDs werden runtimeweit injiziert.

### Owner-Entscheidung 14.09.2026 – Six-Site-Anker und Radien

```text
JALALABAD_FENTY   2438.4 m   8000 ft
COP_FORTRESS      1524.0 m   5000 ft
FOB_JOYCE         2743.2 m   9000 ft
FOB_WRIGHT        1219.2 m   4000 ft
COP_HONAKER       2743.2 m   9000 ft
FOB_BOSTICK       1524.0 m   5000 ft
```

Fuer kompakte FOB-/COP-Installationen ist der Warehouse-Anker die regulaere Regel. Fuer grosse Flugplaetze duerfen bewusst abweichende, flugplatzweite Anker verwendet werden.

Jalalabad/Fenty bleibt die bestaetigte Ausnahme:

```text
JALALABAD_FENTY
-> MOOSE zone anchor: OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT
-> runtime ZONE_RADIUS: 2438.4 m / 8000 ft
```

Weitere aktuelle Warehouse-Anker:

```text
COP_FORTRESS -> WH_BLUE_GND_FORTRESS
FOB_JOYCE    -> WH_BLUE_GND_JOYCE
FOB_WRIGHT   -> WH_BLUE_GND_WRIGHT
COP_HONAKER  -> WH_BLUE_GND_HONAKER
FOB_BOSTICK  -> WH_BLUE_GND_BOSTICK
```

## ACCESS-Zonen

`ZON_BLUE_GND_*_ACCESS` gehoeren ausschliesslich zum Convoy-/Access-Vertrag. Sie sind weder Alarmanchor noch Alarmradiusquelle noch Guard-Nahbereich. Die bestehende QRF-Materialisierung ueber ACCESS bleibt unveraendert.

## Verifikation

Quellseitig relevant:

```text
tests/mission-demand/test_fob_threat_opszone_adapter.lua
tests/mission-demand/test_fob_threat_opszone_raw_incident.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_perimeter_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_installation_incident_bridge.lua
tests/mission-demand/test_fire_support_strategic_resupply_guard_mission_factory.lua
tests/mission-demand/test_fire_support_strategic_resupply_guard_runtime.lua
tests/mission-demand/test_fire_support_strategic_resupply_gate2.lua
tests/mission-demand/test_fire_support_strategic_resupply_gate3.lua
```

Die neue Semantik ist erst dann DCS-validiert, wenn ein Lauf nachweist:

```text
vor Alarm: kein physischer Guard
RED betritt Alarmperimeter
-> MOOSE OPSZONE scan erkennt RED
-> PROXIMITY_INTRUSION / Installation Incident
-> genau ein incident-local Guard-Demand
-> Guard materialisiert lokal mit ONGUARD
-> genau ein initialer QRF-Demand nach bestehendem Vertrag
-> Guard erhaelt keine permanente PATHLINE-Patrouille und keinen proaktiven EngageTarget-Zyklus
-> autoritative Incident-Schliessung cancelt Guard
-> QRF wird durch diese Schliessung nicht automatisch abgebrochen
```

Die bisherige Gate-5B-Acceptance, die vor Perimeterstart sechs permanente Guards voraussetzte und anschliessend sechs QRF-Demands erzwang, ist fuer diese neue Owner-Semantik nicht mehr der passende Acceptance-Nachweis. Sie bleibt historische Testevidenz fuer ihren exakten Quellstand.
