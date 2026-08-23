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
validated_in_dcs: false
---

# AWACS Acceptance 4 – vollständiger Fuel-/AAR-Lifecycle

## 1. Ziel

Acceptance 4 prüft den vollständigen sichtbaren E-3A-WIZARD-Lifecycle mit fuel-state-gesteuerter Luftbetankung. Der Test ist kein verkürzter Einzeltest: WIZARD soll den realen Missionsablauf vom externen Spawn bis zum externen Handoff durchlaufen.

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

Acceptance 3 zeigte, dass die frühere zusätzliche `<=5 NM APOC`-Bedingung die Aktivierung um mehrere Minuten verzögern konnte, wenn WIZARD sich um 15:30 auf dem entfernten Teil des Racetracks befand. Diese Kopplung ist entfernt.

Verbindliches Soll für Acceptance 4:

```text
STANDBY + persistent racetrack before 15:30
15:30 local (+ max. scheduler cadence): sensor/radar -> EMITTING
no mission replacement
no ROSIE detour
no APOC-position gate for scheduled activation
```

Der 5-NM-APOC-Radius bleibt ausschließlich für **physische Rejoin-Bestätigung nach AAR** relevant. Nach AAR wird der Sensor erst wieder aktiviert, wenn WIZARD APOC tatsächlich erreicht hat.

Der manuelle RWR-Gegencheck aus Acceptance 3 belegt für den getesteten Stand qualitativ:

```text
before activation: E-3 emitter absent on F-16 RWR
once controller activation occurred: E-3 emitter visible on F-16 RWR
```

Der damalige verspätete Aktivierungszeitpunkt war Controller-Logik, kein belegter fünfminütiger DCS-Radar-Warm-up.

## 6. Fuel-/AAR-Policy

Die Schwellen sind zunächst **Engineering Baseline / DCS pending**:

```text
<= 65 percent:
pre-dispatch dedicated reserve tanker LISA toward the AWACS rendezvous

<= 40 percent:
AAR required
1. prefer LISA if established at the dedicated rendezvous
2. otherwise MOOSE FindNearestTanker() selects the nearest compatible active tanker within the configured search radius
3. MOOSE FLIGHTGROUP:Refuel(...) executes receiver refuelling

<= 25 percent:
if no refuel task is established, controlled off-map fuel contingency via ROSIE
```

Die E-3A darf bei FuelLow/FuelCritical nicht durch die normale MOOSE-RTB-Automatik nach Sharana oder zu einem anderen beliebigen afghanischen Flugplatz geschickt werden.

## 7. MOOSE-First-Begründung

Im gepinnten `FlightGroup.lua` sind bestätigt:

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
```

Die eingebaute `SetFuelLowRefuel(true)`-Policy wird **nicht** aktiviert, weil der gepinnte Source darin fest mit `FindNearestTanker(50)` arbeitet. Das genügt nicht für den OMW-Vertrag `LISA first, otherwise reachable compatible fallback`. OMW orchestriert daher nur die Auswahl; Fuel-Events, Kompatibilitätssuche und Refuel-Ausführung bleiben MOOSE-Funktionen.

## 8. Dedicated LISA

LISA verwendet den bestehenden strategischen AAR-Adapter und erzeugt keine zweite Ressourcenautorität.

```text
Template: OMW_AAR_KC135_LISA
Source: AL_UDEID via DAVER
Rendezvous: 33.6233926368 N / 68.6395554105 E
Track: FL250 / 300 kt / 340T / 20 NM
FuelLow: 38 percent
```

LISA wird bei <=65 Prozent WIZARD-Fuel vorausgeschickt. Wenn sie bei <=40 Prozent noch nicht am Rendezvous verfügbar ist, darf WIZARD einen anderen kompatiblen aktiven Tanker verwenden.

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
```

Die Telemetrie verwendet nur im gepinnten MOOSE-Pfad vorhandene Methoden. Der bekannte Acceptance-3-Fehler mit `GetCurrentFuelKgs()`/`GetFuelMassMax()` ist entfernt. `GetAltitude()` wird vor der Ausgabe von Metern in Fuß konvertiert.

## 10. PASS-Kriterien

Ein PASS erfordert mindestens:

1. sichtbarer Spawn nahe FL350/440 kt und Fuel im vereinbarten Template-Toleranzbereich;
2. ROSIE ohne sichtbaren FL340->FL350-Step;
3. APOC wird erreicht und stabil bei FL320/300 kt geflogen;
4. 15:30 aktiviert Sensor/Radar ohne APOC-Positionsgate, ROSIE-Detour oder Missionsersatz;
5. RWR-SILENT/EMITTING vor/nach 15:30 wird, soweit mit dem gewählten Client prüfbar, manuell dokumentiert;
6. LISA wird spätestens nach Unterschreiten der 65-Prozent-Schwelle materialisiert oder ein nachvollziehbarer strategischer Ablehnungsgrund geloggt;
7. bei <=40 Prozent beginnt AAR, nicht Afghanistan-RTB;
8. LISA wird bevorzugt, wenn sie am Rendezvous bereit ist; sonst wird ein kompatibler aktiver Fallback-Tanker gewählt;
9. WIZARD betankt sichtbar und kehrt anschließend zum persistenten APOC-Racetrack zurück, sofern 23:30 noch nicht erreicht ist;
10. kein ungewollter ROSIE-Detour beim AAR-Beginn oder bei der Rückkehr;
11. bei 23:30 wird der Dienst beendet und WIZARD verlässt den Track kontrolliert über ROSIE;
12. externer Handoff/Despawn und strategische Rückbuchung erfolgen exakt einmal;
13. keine E-3A-Notlandung in Sharana und kein fuel-bedingter Crash;
14. LISA führt nach abgeschlossener Unterstützung ihren eigenen Egress/Handoff aus;
15. `dcs.log`, `debrief.log`, MIZ-Hash, internal-mission-Hash und Bundle-Hashes werden dokumentiert.

## 11. Offene DCS-Fragen

Bis Acceptance 4 real ausgeführt wurde, bleiben insbesondere offen:

```text
- tatsächlicher Fuel-Burn der E-3A bei FL320 / 300 kt
- Eignung der 65/40/25-Prozent-Schwellen
- tatsächliches FLIGHTGROUP Refuel-/Resume-Verhalten der DCS-E-3A
- LISA timing from AL_UDEID to the dedicated rendezvous
- fallback-tanker selection in the live tanker picture
- exakter RWR activation timestamp after the position-gate correction
```

Diese Punkte dürfen vor dem realen Lauf nicht als validiert bezeichnet werden.