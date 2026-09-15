---
document_id: OMW-MOOSE-FIRE-SUPPORT-GUARD-INCIDENT-LOCAL-SECURITY
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - production Guard activation semantics for Ground installations
  - Guard versus QRF tactical role separation
  - Guard patrol and target-engagement exclusions
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - persistent production Guard patrol semantics for GROUND_INSTALLATION_STANDARD
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Guard – Incident Local Security Decision

## Owner-Entscheidung 15.09.2026

Der Projektinhaber hat fuer die produktive Ground-Installation-Sicherung festgelegt:

```text
GUARD wird erst physisch eingesetzt, wenn Feinde den Alarmperimeter betreten.
QRF geht aktiv zum Feind.
GUARD bleibt lokale Sicherung des FOB/COP/Flugplatzes und faengt nur Gegner ab,
die in den Nahbereich der Installation gelangen.
```

Damit wird die bisherige produktive Annahme einer dauerhaft materialisierten und dauerhaft um die Installation patrouillierenden Guard fuer `GROUND_INSTALLATION_STANDARD` ersetzt.

## Verbindlicher Rollenvertrag

```text
MOOSE OPSZONE
= Alarm-/Detection-Grenze

Installation Incident
= autoritative Incident-Autoritaet

GUARD
= INCIDENT_LOCAL_SECURITY
= nur bei aktivem Installation-Angriff materialisieren
= lokale ONGUARD-Sicherung
= keine permanente Patrol
= keine proaktive Incident-weite Zielverfolgung
= keine zweite QRF

QRF
= INCIDENT_LOCAL_DEFENSE
= mobile Reaktionskraft
= bestehender A4-8 Direct-Target-QRF-Lifecycle

ARTY / CAS
= separate C2-Eskalation
```

## Normalzustand

Im Normalzustand existiert kein physischer Guard-Demand und keine physische Guard-Gruppe.

`Base:StartSite(siteId)` registriert den Standort, erzeugt aber keinen persistenten Guard-Auftrag.

Der Alarmperimeter bleibt aktiv und wird durch MOOSE `OPSZONE` ausgewertet.

## Alarmzustand

Ein qualifizierter lebender RED-Ground-Teilnehmer im Alarmperimeter erzeugt ueber den bestehenden Evidence-/Incident-Pfad einen Installation-Incident.

Beim **Incident-Start** werden genau die beiden lokalen Reaktionsrollen getrennt angefordert:

```text
GUARD
requestKey = INSTALLATION_ATTACK_LOCAL_GUARD
cancelWhenIncidentClosed = true

QRF
requestKey = INSTALLATION_ATTACK_INITIAL_QRF
cancelWhenIncidentClosed = false
```

Weitere Incident-Evidence darf weder Guard noch QRF duplizieren.

## Guard-Ausfuehrung

Die Guard verwendet weiterhin MOOSE:

```text
AUFTRAG:NewONGUARD(local guard materialization anchor)
SetTeleport(false)
SetRequiredAssets(1, 1)
SetReturnToLegion(true)
```

Der vorhandene, DCS-akzeptierte PATHLINE-Materializer wird nur noch als kompakte validierte Aufstellungsgeometrie wiederverwendet. Der Produktions-Guard-Runtime installiert keinen dauerhaften PATHLINE-RouteAdapter mehr.

Ausdruecklich nicht fuer die Guard verwenden:

```text
AUFTRAG:NewPATROLZONE
HuntingPatrol
SetEngageDetected
ARMYGROUP:EngageTarget als OMW-proaktiver Guard-Target-Cycle
eigener Guard-Scheduler
eigener World-Scan
eigener Guard-Strassenrouter
```

Die Guard darf mit dem normalen DCS/MOOSE-Kampfverhalten reagieren, wenn Gegner bis in ihre tatsaechliche lokale Kontakt-/Waffenreichweite gelangen. OMW schickt sie nicht aktiv zum Incident-Ziel.

## Alarmqualifikation ohne permanenten BLUE Guard

Der gepinnte MOOSE-Source zeigt, dass eine BLUE-owned `OPSZONE` ohne BLUE-Ground-Praesenz bei RED-Praesenz nicht zwingend den `Attacked`-Zustand verwendet. Eine permanente Guard nur zur Erzeugung der `Attacked`-Transition waere daher ein zirkulaerer Vertrag.

Die produktive Alarmqualifikation verwendet deshalb:

```text
MOOSE OPSZONE:Status()
-> MOOSE Scan()
-> MOOSE EvaluateZone()
-> MOOSE Evaluated callback
-> OPSZONE:GetScannedGroupSet()
-> OMW filtert lebende RED Ground Groups
-> PROXIMITY_INTRUSION
```

Das ist MOOSE-first: OMW fuehrt keinen eigenen Scheduler und keinen eigenen World-Scan ein. Es interpretiert nur den bereits von MOOSE erzeugten OPSZONE-Scan entsprechend der OMW-Alarmsemantik.

`OnAfterAttacked` bleibt als idempotenter Fast-Path zulaessig, wenn bereits BLUE-Praesenz im Perimeter existiert.

## Incident-Ende

Die Guard ist incident-scoped. Bei autoritativer Incident-Schliessung wird ihr Demand ueber den vorhandenen LifecycleAdapter gecancelt; `SetReturnToLegion(true)` uebergibt den physischen Rueckkehr-/Warehouse-Lifecycle an MOOSE.

Die QRF bleibt davon unabhaengig. Incident-Close oder Perimeter-Clear allein duerfen die bereits entsandte QRF nicht beenden. Fuer die QRF bleibt die akzeptierte A4-8-Semantik autoritativ: keine lebenden autorisierten Incident-Ziele mehr -> Mission Ende -> ReturnToLegion/RTZ/Returned.

## Performance-Ziel

Die Entscheidung entfernt im Normalbetrieb:

```text
6 permanent materialisierte Guard-Gruppen
+ 6 permanente Guard-PATHLINE-Bewegungslifecycles
```

Die Guard wird nur bei realem Alarm physisch relevant.

## DCS-Validierungsgrenze

Die Quell- und Unit-Test-Seite ist getrennt von der DCS-Akzeptanz. Fuer die neue Semantik ist noch ein gezielter DCS-Nachweis erforderlich:

```text
vor Alarm: kein physischer Guard
RED im Alarmperimeter
-> Incident
-> Guard lokal materialisiert
-> QRF-Demand parallel erzeugt
-> Guard bleibt lokal / keine permanente Patrol
-> autoritative Incident-Schliessung cancelt Guard
-> QRF wird nicht allein durch Incident-Close gecancelt
```

Die alte Gate-5A-DCS-Acceptance bleibt gueltige Evidenz fuer den exakt damals getesteten persistenten Patrol-Guard-Stand, beweist aber nicht die neue Semantik.
