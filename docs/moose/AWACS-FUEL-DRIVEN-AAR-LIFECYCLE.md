---
document_id: OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR
status: DRAFT
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS fuel-state driven AAR design on the working branch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# AWACS Fuel-Driven AAR Lifecycle

## Ziel

Dieses Dokument beschreibt den branch-lokalen, noch nicht abschließend DCS-validierten vollständigen Lifecycle für WIZARD. Es ergänzt `AWACS-EXTERNAL-LIFECYCLE.md` und ersetzt keine auf `main` verbindliche Governance.

## Flugprofil

```text
Al Dhafra off-map departure
-> weight-dependent climb / fuel burnoff / step climb
-> visible handoff at FL350 / 440 kt
-> ROSIE FL350 / 440 kt
-> late approach 30 NM before APOC
-> APOC FL320 / 300 kt / 017T / 30 NM
```

Der sichtbare frühere Step `FL340 -> FL350 -> FL320` wird verworfen. Der Step-Climb gehört in den bereits abstrahierten Off-map-Transit.

## Spawn-Fuel

Der aktuelle DCS-E-3A-Templatewert beträgt ungefähr 65.000 kg bei 100 Prozent. Für Al Dhafra bis zum sichtbaren Spawn wurde branch-lokal ein Off-map-Verbrauch in der Größenordnung von 15.000 kg angesetzt. Daraus folgt als Engineering-Baseline:

```text
visible spawn fuel ~= 50,000 kg ~= 77 percent
```

Das ist keine exakte T.O.-Performanceberechnung. Der Wert wird bewusst als Engineering Estimate geführt und muss gegen DCS-Verbrauch und spätere bessere Performance-Quellen reconciliert werden.

Der gepinnte öffentliche MOOSE-SPAWN-Source bietet keinen verifizierten `InitFuel`-Pfad. Deshalb wird der Fuel-Wert im Mission-Editor-Template gesetzt und zur Laufzeit nur über `FLIGHTGROUP:GetFuelMin()` geprüft.

## T.O.-Evidenz

Vom Projektbesitzer bereitgestellte Seiten aus `T.O. 1E-3A-1` belegen für den Normalbetrieb unter anderem:

```text
Enroute climb:
250 KIAS to 10,000 ft
then accelerate to 280 KIAS
then Mach 0.70 +/- 0.01

Cruise:
if desired Mach cannot be maintained because of gross weight/temperature,
select lower altitude/lower Mach or accept speed loss until fuel burnoff permits it.

On-station:
best endurance airspeed
bank angles below 15 degrees
```

Damit ist ein bereits leichter gewordenes Flugzeug am sichtbaren FL350-Handoff plausibler als ein unmittelbar zuvor vollgetankter FL350-Spawn.

## Fuel-/AAR-Policy nach Acceptance-4-Lauf vom 23./24.08.2026

Der erste vollständige Acceptance-4-Lauf bestätigte die physische MOOSE-AAR-Kette einschließlich LISA, Receiver-Refuel und Rückkehrlogik. Er zeigte zugleich zwei Orchestrierungsprobleme: WIZARD wartete trotz bereits vorausgeschickter LISA bis zum 40-Prozent-Trigger, und LISA erhielt während eines laufenden Receiver-Refuels bereits ihren FuelLow-Egress-Auftrag.

Die korrigierte Engineering-Baseline lautet deshalb:

```text
65 %  LISA pre-dispatch
LISA ready on dedicated rendezvous -> WIZARD begins AAR immediately
40 %  fallback AAR trigger if the planned LISA path is not ready
25 %  critical contingency if no refuel task is established
```

`40 %` ist damit keine geplante normale AAR-Startschwelle mehr, sondern die Rückfallebene. Die revidierte Policy muss erneut in DCS geprüft werden.

## MOOSE-First

Im tatsächlich gepinnten `Moose.lua` wurden source-seitig geprüft:

```text
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(...)
FLIGHTGROUP:SetFuelLowRefuel(...)
FLIGHTGROUP:SetFuelCriticalThreshold(...)
FLIGHTGROUP:SetFuelCriticalRTB(...)
FLIGHTGROUP:FindNearestTanker(...)
FLIGHTGROUP:Refuel(...)
OPSGROUP:GetAltitude()
POSITIONABLE:GetVelocityKNOTS()
FuelLow / FuelCritical / Refueled FSM paths
```

`OPSGROUP:GetAltitude()` liefert im gepinnten Source bereits Feet. Die Acceptance-4-Telemetrie hatte diesen Wert fälschlich noch einmal mit `UTILS.MetersToFeet()` konvertiert und dadurch scheinbare Höhen um 105.000 ft erzeugt. Die Beobachterlogik ist korrigiert; diese alten Telemetriehöhen sind keine realen Flugzustände.

Der Source zeigt außerdem, dass `SetFuelLowRefuel(true)` im `onafterFuelLow`-Pfad fest `FindNearestTanker(50)` verwendet. Diese eingebaute 50-NM-Policy genügt nicht für OMW, weil zuerst der vorausgeschickte Reservetanker LISA berücksichtigt und andernfalls ein weiter entfernter kompatibler Tanker erreichbar sein muss.

Daher lautet die kleinste notwendige OMW-Orchestrierung:

```text
WIZARD <= 65 %
-> LISA pre-dispatch via MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
-> LISA AUFTRAG tanker racetrack establishes dedicated rendezvous
-> readiness gate: within 5 NM and within +/-1000 ft of FL320
-> WIZARD immediately enters MOOSE Refuel path with LISA

Fallback:
WIZARD <= 40 % and no established AAR path
-> MOOSE FindNearestTanker(500)
-> MOOSE Refuel(coordinate)

Completion:
MOOSE Refueled
-> persistent APOC mission resumes
-> sensor service only after physical APOC rejoin
```

Die eigentliche Fuel-Erkennung, Tanker-Kompatibilität und Receiver-Refuel-Ausführung bleiben damit MOOSE-Funktionen. `SetFuelLowRefuel(false)` verhindert ausschließlich die unpassende eingebaute 50-NM-Automatik.

## RTB-Grenze

`SetFuelLowRTB(false)` und `SetFuelCriticalRTB(false)` verhindern, dass WIZARD wegen MOOSE-Defaultverhalten zu einem beliebigen afghanischen Flugplatz geschickt wird. Acceptance 2/3 hat gezeigt, dass ein solcher Pfad zur unplausiblen Sharana-Landung beziehungsweise zum Verlustpfad führen kann.

Bei 25 Prozent ohne etablierten Refuel-Task wird daher ein kontrollierter Off-map-Contingency-Egress über ROSIE ausgelöst. Diese Schwelle ist weiterhin DCS-pending.

## Dedicated LISA

LISA bleibt strategisch Teil des bestehenden AAR-Bestands. Der AWACS-Lifecycle nutzt den bereits laufenden AAR-StrategicAdapter für `CanMaterialize`, `OnMaterialized`, `OnHandoff` und `OnLost`. Es entsteht keine zweite Ressourcenautorität.

Revidierter physischer AWACS-Rendezvous-Pfad:

```text
LISA / OMW_AAR_KC135_LISA
AL_UDEID -> DAVER
-> dedicated AWACS rendezvous
33.6233926368 N / 68.6395554105 E
FL320 / 300 kt / 340T / 20 NM
```

Die Höhe entspricht jetzt der WIZARD-Trackhöhe. `300 kt` bleibt bewusst das bestehende OMW-FAST-Profil; die SLOW-Profile für langsamere Receiver liegen bei 220 kt und werden für diesen AWACS-Rendezvous nicht verwendet.

LISA wird weiterhin bei 65 Prozent WIZARD-Fuel vorausgeschickt. Sobald sie am Rendezvous physisch etabliert ist und die FL320-Toleranz erfüllt, beginnt WIZARD AAR unmittelbar. Ist LISA bis 40 Prozent nicht bereit, wird nicht weiter auf sie gewartet, sofern MOOSE einen anderen kompatiblen aktiven Tanker findet.

### FuelLow während aktiver Betankung

Der Acceptance-4-Lauf zeigte, dass LISA während des laufenden Refuels bereits ihren `FuelLow`-Event auslösen kann. Das sofortige Canceln ihrer Tanker-Mission ist während eines etablierten WIZARD-Receiver-Tasks unerwünscht.

Die revidierte Regel lautet:

```text
LISA FuelLow + WIZARD currently refuelling from LISA
-> mark LISA egress pending
-> do not cancel tanker mission yet
-> finish MOOSE receiver refuel
-> on WIZARD Refueled: order LISA egress

LISA FuelLow without active WIZARD receiver
-> order LISA egress immediately
```

Damit wird kein neuer eigener Refuel-Mechanismus eingeführt; die Änderung koordiniert ausschließlich MOOSE-FSM-Zustände und den vorhandenen AUFTRAG-Lifecycle.

## Persistenter APOC-Orbit

Der Service-State ist vom physischen Orbit getrennt:

```text
before 15:30: persistent orbit / sensor standby
15:30:       sensor/service active, no mission replacement, no APOC position gate
AAR:         MOOSE Refuel pauses persistent mission
post-AAR:    mission resumes; sensor active only once back on APOC
23:30:       true egress; only here is the persistent orbit cancelled
```

Die Missionsuhr wird über `UTILS.SecondsOfToday()` ausgewertet. Der frühere 5-NM-APOC-Gate für den planmäßigen 15:30-Wechsel ist entfernt; der 5-NM-Radius bleibt nur für die physische Rejoin-Bestätigung nach AAR. Damit darf eine reine Statusänderung keinen ROSIE-Detour und keine mehrminütige Aktivierungsverzögerung mehr auslösen.

## Validierungsstatus

```text
pinned MOOSE source review: complete for the methods listed above
Acceptance 4 pre-revision physical AAR: observed in DCS
Acceptance 4 revised LISA-ready / FL320 / deferred-egress behavior: pending
Lua/CI syntax for current revision: pending remote/local verification
VALIDATED: no
```

Maßgeblicher Testplan: `mission/tests/awacs-external-lifecycle/ACCEPTANCE-4.md`.
