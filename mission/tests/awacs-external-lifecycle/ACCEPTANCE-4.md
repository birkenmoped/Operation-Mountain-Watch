---
document_id: OMW-AWACS-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS full fuel-driven AAR acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# AWACS Acceptance 4 – vollständiger Fuel-/AAR-Lifecycle

## 1. Ziel

Acceptance 4 prüft den vollständigen sichtbaren E-3A-WIZARD-Lifecycle mit fuel-state-gesteuerter Luftbetankung. Der Test ist kein verkürzter Einzeltest: WIZARD soll den realen Missionsablauf vom externen Spawn bis zum externen Handoff durchlaufen.

Der Lauf vom 23./24.08.2026 bestätigte die physische MOOSE-Refuel-Kette, führte aber zu einer gezielten Revision der LISA-Rendezvous-Policy. Diese Revision ist noch nicht DCS-validiert und ist Gegenstand des nächsten Laufs.

## 2. Verbindlicher Teststand

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
AWACS task: not used
Physical station: persistent AUFTRAG racetrack
CampaignState: sole strategic aircraft authority
```

Die realen lokalen Build- und MIZ-Hashes werden erst nach Owner-Build beziehungsweise Owner-Mission-Editor-Speicherung eingetragen. Ohne diese Provenienz ist kein `VALIDATED` zulässig.

## 3. Mission-Editor-Vertrag

Der Projektbesitzer ändert die MIZ. ChatGPT mutiert keine `.miz`.

`OMW_C2_E3A_WIZARD`:

```text
Late Activation: yes
Internal fuel: approximately 77 percent
Equivalent engineering target with the current 65,000 kg DCS template capacity: approximately 50,000 kg
```

Der Fuel-Wert ist eine OMW-Engineering-Abschätzung für den bereits absolvierten Off-map-Transit Al Dhafra -> sichtbarer Spawn. Er ist kein behaupteter exakter T.O.-Performance-Wert. Der gepinnte öffentliche MOOSE-SPAWN-Pfad enthält keinen für OMW verifizierten `InitFuel`-Setter; deshalb wird der Fuel-State im ME-Template gesetzt und zur Laufzeit nur geprüft/logged.

## 4. Flugprofil

```text
Off-map provenance:
Al Dhafra -> heavy climb -> fuel burnoff / step climb -> visible handoff

Visible spawn:
FL350 / 440 kt / approximately 77 percent fuel

Ingress:
visible spawn -> ROSIE at FL350 / 440 kt
ROSIE -> 30 NM late approach at FL350 / 440 kt
late approach -> APOC FL320 / 300 kt

APOC:
017T / 30 NM racetrack
one persistent physical AUFTRAG orbit

Service window:
15:30 local -> ACTIVE / EMITTING
23:30 local -> CLOSED / SILENT / true egress
```

Der frühere sichtbare FL340->FL350-Step entfällt vollständig.

## 5. Service-/Sensor-Timing

`15:30` ist eine Missionsuhrzeit und wird mit `UTILS.SecondsOfToday()` ausgewertet. Sie ist **nicht** als Zeit seit Missionsstart modelliert.

Verbindliches Soll:

```text
STANDBY + persistent racetrack before 15:30
15:30 local (+ max. scheduler cadence): sensor/radar -> EMITTING
no mission replacement
no ROSIE detour
no APOC-position gate for scheduled activation
```

Der 5-NM-APOC-Radius bleibt ausschließlich für **physische Rejoin-Bestätigung nach AAR** relevant. Nach AAR wird der Sensor erst wieder aktiviert, wenn WIZARD APOC tatsächlich erreicht hat.

## 6. Revidierte Fuel-/AAR-Policy

```text
<= 65 percent WIZARD fuel:
pre-dispatch dedicated reserve tanker LISA toward the AWACS rendezvous

LISA ready:
within 5 NM of the dedicated rendezvous
and within +/-1000 ft of FL320
-> WIZARD immediately begins the MOOSE refuel path with LISA
-> do not deliberately wait for 40 percent

<= 40 percent WIZARD fuel:
fallback AAR trigger if the planned LISA path is not ready
1. prefer LISA if ready
2. otherwise MOOSE FindNearestTanker() selects the nearest compatible active tanker
3. MOOSE FLIGHTGROUP:Refuel(...) executes receiver refuelling

<= 25 percent:
if no refuel task is established, controlled off-map fuel contingency via ROSIE
```

Die E-3A darf bei FuelLow/FuelCritical nicht durch die normale MOOSE-RTB-Automatik nach Sharana oder zu einem anderen beliebigen afghanischen Flugplatz geschickt werden.

## 7. MOOSE-First-Begründung

Im gepinnten `Moose.lua` sind bestätigt:

```text
SetFuelLowThreshold(...)
SetFuelLowRTB(...)
SetFuelLowRefuel(...)
SetFuelCriticalThreshold(...)
SetFuelCriticalRTB(...)
FuelLow / FuelCritical FSM events
FindNearestTanker(...)
Refuel(...)
Refueled FSM event
OPSGROUP:GetAltitude()
POSITIONABLE:GetVelocityKNOTS()
```

Die eingebaute `SetFuelLowRefuel(true)`-Policy wird **nicht** aktiviert, weil der gepinnte Source darin fest mit `FindNearestTanker(50)` arbeitet. Das genügt nicht für den OMW-Vertrag `LISA first, otherwise reachable compatible fallback`. OMW orchestriert daher nur die Auswahl; Fuel-Events, Kompatibilitätssuche und Refuel-Ausführung bleiben MOOSE-Funktionen.

## 8. Dedicated LISA

LISA verwendet den bestehenden strategischen AAR-Adapter und erzeugt keine zweite Ressourcenautorität.

```text
Template: OMW_AAR_KC135_LISA
Source: AL_UDEID via DAVER
Rendezvous: 33.6233926368 N / 68.6395554105 E
Track: FL320 / 300 kt / 340T / 20 NM
FuelLow: 38 percent
```

`300 kt` bleibt das bestehende OMW-FAST-Profil. Für diesen AWACS-Rendezvous wird nicht auf das 220-kt-SLOW-Profil gewechselt.

Wenn LISA `FuelLow` während eines bereits laufenden WIZARD-Refuels erreicht, darf die Tanker-Mission nicht sofort gecancelt werden:

```text
active WIZARD refuel from LISA + LISA FuelLow
-> LISA egress pending
-> refuel continues
-> after WIZARD Refueled: LISA egress
```

Ohne aktiven WIZARD-Receiver bleibt `LISA FuelLow -> immediate egress` gültig.

## 9. Acceptance-Observer

`OMW_AWACS_Acceptance_4.lua` ist read-only/observer-only. Es darf keine Gruppe spawnen, routen, betanken oder zerstören.

Es protokolliert alle 30 Sekunden mindestens:

```text
serviceState
sensorState
aarPhase
designated tanker
altitude in feet
speed in knots
heading
fuelPct
position
egress state
LISA appearance
LISA ready state
```

Wichtige Korrektur nach dem Lauf vom 23./24.08.2026: `FLIGHTGROUP:GetAltitude()` liefert im gepinnten MOOSE-Source bereits Feet. Die frühere zusätzliche `UTILS.MetersToFeet()`-Konvertierung war falsch und erzeugte scheinbare Höhen um 105.000 ft. Diese Werte waren ein Observer-Bug, kein reales DCS-Flugprofil. Acceptance 4 gibt den MOOSE-Wert nun direkt als Feet aus.

## 10. PASS-Kriterien

Ein PASS der revidierten Acceptance 4 erfordert mindestens:

1. sichtbarer Spawn nahe FL350/440 kt und Fuel im vereinbarten Template-Toleranzbereich;
2. ROSIE ohne sichtbaren FL340->FL350-Step;
3. APOC wird erreicht und stabil bei FL320/300 kt geflogen;
4. 15:30 aktiviert Sensor/Radar ohne APOC-Positionsgate, ROSIE-Detour oder Missionsersatz;
5. RWR-SILENT/EMITTING vor/nach 15:30 wird, soweit mit dem gewählten Client prüfbar, manuell dokumentiert;
6. LISA wird nach Unterschreiten der 65-Prozent-Schwelle materialisiert oder ein nachvollziehbarer strategischer Ablehnungsgrund geloggt;
7. LISA etabliert ihren AWACS-Rendezvous auf FL320 mit 300-kt-FAST-Profil;
8. sobald `LISA_READY` erreicht wird, beginnt WIZARD AAR ohne künstliches Warten auf 40 Prozent;
9. falls LISA bis 40 Prozent nicht bereit ist, beginnt der Fallback-AAR-Pfad und kein Afghanistan-RTB;
10. LISA wird bevorzugt, wenn sie bereit ist; sonst wird ein kompatibler aktiver Fallback-Tanker gewählt;
11. WIZARD betankt sichtbar und kehrt anschließend zum persistenten APOC-Racetrack zurück, sofern 23:30 noch nicht erreicht ist;
12. löst LISA während aktiver WIZARD-Betankung `FuelLow` aus, wird ihr Egress bis zum Receiver-Refuel-Abschluss zurückgestellt;
13. kein ungewollter ROSIE-Detour beim AAR-Beginn oder bei der Rückkehr;
14. bei 23:30 wird der Dienst beendet und WIZARD verlässt den Track kontrolliert über ROSIE;
15. externer Handoff/Despawn und strategische Rückbuchung erfolgen exakt einmal;
16. keine E-3A-Notlandung in Sharana und kein fuel-bedingter Crash;
17. LISA führt nach abgeschlossener Unterstützung ihren eigenen Egress/Handoff aus;
18. Observer-Höhen entsprechen dem real sichtbaren Flugniveau und zeigen keinen doppelten Feet-Umrechnungsfehler;
19. `dcs.log`, `debrief.log`, MIZ-Hash, internal-mission-Hash und Bundle-Hashes werden dokumentiert.

## 11. Bisherige DCS-Evidenz und offene Punkte

Der Lauf vom 23./24.08.2026 belegt für den **vorherigen** Controllerstand:

```text
- LISA was physically materialized and used as WIZARD tanker
- WIZARD entered the MOOSE Refuel path and eventually reached a Refueled event
- persistent-mission rejoin path was entered after AAR
- nearest-compatible fallback path was observed in a later fuel cycle
- old logic waited until approximately 40 percent before first AAR even though LISA had been pre-dispatched
- LISA FuelLow occurred during the running receiver-refuel sequence
```

Diese Evidenz validiert nicht automatisch die revidierte LISA-ready-Policy. Noch offen und deshalb DCS-pending:

```text
- immediate WIZARD AAR initiation after revised LISA_READY
- LISA FL320 racetrack behavior
- practical FAST-profile rendezvous/catch-up behavior at 300 kt
- deferred LISA FuelLow egress during an active receiver refuel
- corrected observer altitude output
- 65/40/25 thresholds after the changed normal AAR start point
```
