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
validated_in_dcs: false
---

# AWACS Fuel-Driven AAR Lifecycle

## Ziel

Dieses Dokument beschreibt den branch-lokalen, noch nicht DCS-validierten vollständigen Lifecycle für WIZARD. Es ergänzt `AWACS-EXTERNAL-LIFECYCLE.md` und ersetzt keine auf `main` verbindliche Governance.

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

## Fuel-/AAR-Schwellen

Die initiale OMW-Engineering-Baseline lautet:

```text
65 %  LISA pre-dispatch
40 %  AAR required
25 %  critical contingency if no refuel task is established
```

Die Werte sind noch nicht DCS-validiert und werden nach Acceptance 4 anhand realer Fuel-Telemetrie nachkalibriert.

## MOOSE-First

Im tatsächlich gepinnten `FlightGroup.lua` wurden source-seitig geprüft:

```text
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(...)
FLIGHTGROUP:SetFuelLowRefuel(...)
FLIGHTGROUP:SetFuelCriticalThreshold(...)
FLIGHTGROUP:SetFuelCriticalRTB(...)
FLIGHTGROUP:FindNearestTanker(...)
FLIGHTGROUP:Refuel(...)
FuelLow / FuelCritical / Refueled FSM paths
```

Der Source zeigt außerdem, dass `SetFuelLowRefuel(true)` im `onafterFuelLow`-Pfad fest `FindNearestTanker(50)` verwendet. Diese eingebaute 50-NM-Policy genügt nicht für OMW, weil zuerst der vorausgeschickte Reservetanker LISA berücksichtigt und andernfalls ein weiter entfernter kompatibler Tanker erreichbar sein muss.

Daher lautet die kleinste notwendige OMW-Orchestrierung:

```text
MOOSE FuelLow event
-> OMW policy chooses tanker
   1. LISA if established at dedicated rendezvous
   2. otherwise MOOSE FindNearestTanker(500)
-> MOOSE Refuel(coordinate)
-> MOOSE Refueled lifecycle resumes paused mission
```

Die eigentliche Fuel-Erkennung, Tanker-Kompatibilität und Receiver-Refuel-Ausführung bleiben damit MOOSE-Funktionen. `SetFuelLowRefuel(false)` verhindert ausschließlich die unpassende eingebaute 50-NM-Automatik.

## RTB-Grenze

`SetFuelLowRTB(false)` und `SetFuelCriticalRTB(false)` verhindern, dass WIZARD wegen MOOSE-Defaultverhalten zu einem beliebigen afghanischen Flugplatz geschickt wird. Acceptance 2/3 hat gezeigt, dass ein solcher Pfad zur unplausiblen Sharana-Landung beziehungsweise zum Verlustpfad führen kann.

Bei 25 Prozent ohne etablierten Refuel-Task wird daher ein kontrollierter Off-map-Contingency-Egress über ROSIE ausgelöst. Diese Schwelle ist DCS-pending.

## Dedicated LISA

LISA bleibt strategisch Teil des bestehenden AAR-Bestands. Der AWACS-Lifecycle nutzt den bereits laufenden AAR-StrategicAdapter für `CanMaterialize`, `OnMaterialized`, `OnHandoff` und `OnLost`. Es entsteht keine zweite Ressourcenautorität.

Physischer AWACS-Rendezvous-Pfad:

```text
LISA / OMW_AAR_KC135_LISA
AL_UDEID -> DAVER
-> dedicated AWACS rendezvous
33.6233926368 N / 68.6395554105 E
FL250 / 300 kt / 340T / 20 NM
```

LISA wird bei 65 Prozent WIZARD-Fuel vorausgeschickt. Ist sie bei 40 Prozent nicht am Rendezvous verfügbar, wird nicht auf sie gewartet, wenn ein anderer kompatibler aktiver Tanker gefunden wird.

## Persistenter APOC-Orbit

Der Service-State ist vom physischen Orbit getrennt:

```text
before 15:30: persistent orbit / sensor standby
15:30:       sensor/service active, no mission replacement
AAR:         MOOSE Refuel pauses persistent mission
post-AAR:    mission resumes; sensor active only once back on APOC
23:30:       true egress; only here is the persistent orbit cancelled
```

Damit darf eine reine Statusänderung keinen ROSIE-Detour mehr auslösen.

## Validierungsstatus

```text
source review: complete for the listed pinned MOOSE methods
Lua/CI syntax: pending final branch CI
DCS Acceptance 4: pending
VALIDATED: no
```

Maßgeblicher Testplan: `mission/tests/awacs-external-lifecycle/ACCEPTANCE-4.md`.
