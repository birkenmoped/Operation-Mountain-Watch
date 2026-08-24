---
document_id: OMW-MOOSE-AWACS-FUEL-DRIVEN-AAR
status: DRAFT
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS fuel-state driven AAR design on the working branch
  - branch-local AWACS performance engineering baseline after Acceptance 5
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

Dieses Dokument beschreibt den branch-lokalen vollständigen Lifecycle für WIZARD. Es ergänzt `AWACS-EXTERNAL-LIFECYCLE.md` und ersetzt keine auf `main` verbindliche Governance. Die physische Performance-Matrix aus Acceptance 5 ist in DCS vollständig gelaufen; die daraus abgeleiteten Produktionswerte sind jedoch noch nicht im vollständigen AWACS-/LISA-Lifecycle erneut validiert.

## Flugprofil nach Acceptance 5

Die frühere branch-lokale Geschwindigkeitsbaseline `FL350 / 440 kt` für sichtbaren Transit und `FL320 / 300 kt` für den Track wird durch die DCS-Matrix als Engineering-Ziel ersetzt. Wichtig ist die Einheit: Die neuen Werte werden als **KIAS-Zielwerte** betrachtet und müssen im MOOSE-Routing weiterhin mit der verifizierten IAS/TAS-Konvertierung für die jeweilige Höhe umgesetzt werden.

Bevorzugtes Profil:

```text
Al Dhafra off-map departure
-> weight-dependent climb / fuel burnoff / step climb off-map
-> visible handoff at FL350 / 270 KIAS normal transit
-> ROSIE FL350 / 270 KIAS
-> late approach 30 NM before APOC
-> APOC FL320 / 250 KIAS / 017T / 30 NM

Optional fast normal transit:
FL350 / 290 KIAS
```

Acceptance 5 bestätigte:

```text
FL350 / 270 KIAS -> 430.6 KTAS, 4.162 % / 100 NM, 17.318 % / h, STABLE
FL350 / 290 KIAS -> 462.5 KTAS, 4.484 % / 100 NM, 20.049 % / h, STABLE
FL350 / 310 KIAS -> 296.6 KIAS actual average, MARGINAL
FL320 / 250 KIAS -> 386.0 KTAS, 3.984 % / 100 NM, 14.784 % / h, STABLE
```

Der sichtbare frühere Step `FL340 -> FL350 -> FL320` bleibt verworfen. Der Step-Climb gehört in den bereits abstrahierten Off-map-Transit.

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

Acceptance 5 ergänzt diese reale Quellenlage mit DCS-spezifischer, reproduzierbarer Performance-Evidenz. Der Test ersetzt kein reales E-3A-Flughandbuch und beweist keine zertifizierten Stall- oder Gross-Weight-Grenzen.

## Fuel-/AAR-Policy nach Acceptance 4 und Acceptance 5

Der erste vollständige Acceptance-4-Lauf bestätigte die physische MOOSE-AAR-Kette einschließlich LISA, Receiver-Refuel und Rückkehrlogik. Er zeigte zugleich zwei Orchestrierungsprobleme: WIZARD wartete trotz bereits vorausgeschickter LISA bis zum 40-Prozent-Trigger, und LISA erhielt während eines laufenden Receiver-Refuels bereits ihren FuelLow-Egress-Auftrag.

Die korrigierte Engineering-Baseline bleibt:

```text
65 %  LISA pre-dispatch
LISA ready on dedicated rendezvous -> WIZARD begins AAR immediately
40 %  fallback AAR trigger if the planned LISA path is not ready
25 %  critical contingency if no refuel task is established
```

`40 %` ist damit keine geplante normale AAR-Startschwelle mehr, sondern die Rückfallebene.

Acceptance 5 verändert die Fuel-Schwellen noch nicht, liefert aber erstmals eine DCS-basierte Verbrauchsmatrix für die Recovery-/Reserve-Diskussion.

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
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:GetFuelMin()
OPSGROUP:GetAltitude()
POSITIONABLE:GetAirspeedIndicated()
POSITIONABLE:GetAirspeedTrue()
UTILS.IasToTas(...)
FuelLow / FuelCritical / Refueled FSM paths
```

`OPSGROUP:GetAltitude()` liefert im gepinnten Source bereits Feet. Die Acceptance-4-Telemetrie hatte diesen Wert fälschlich noch einmal mit `UTILS.MetersToFeet()` konvertiert und dadurch scheinbare Höhen um 105.000 ft erzeugt. Die Beobachterlogik ist korrigiert; diese alten Telemetriehöhen sind keine realen Flugzustände.

Der Source zeigt außerdem, dass `SetFuelLowRefuel(true)` im `onafterFuelLow`-Pfad fest `FindNearestTanker(50)` verwendet. Diese eingebaute 50-NM-Policy genügt nicht für OMW, weil zuerst der vorausgeschickte Reservetanker LISA berücksichtigt und andernfalls ein weiter entfernter kompatibler Tanker erreichbar sein muss.

Daher lautet die kleinste notwendige OMW-Orchestrierung:

```text
WIZARD <= 65 %
-> LISA pre-dispatch via MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
-> LISA AUFTRAG tanker racetrack establishes dedicated rendezvous
-> WIZARD immediately enters MOOSE Refuel path with LISA once LISA is ready

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

## RTB-/Bingo-Grenze und Reserve

`SetFuelLowRTB(false)` und `SetFuelCriticalRTB(false)` verhindern, dass WIZARD wegen MOOSE-Defaultverhalten zu einem beliebigen afghanischen Flugplatz geschickt wird. Acceptance 2/3 hat gezeigt, dass ein solcher Pfad zur unplausiblen Sharana-Landung beziehungsweise zum Verlustpfad führen kann.

Bei 25 Prozent ohne etablierten Refuel-Task wird daher ein kontrollierter Off-map-Contingency-Egress über ROSIE ausgelöst.

Nach Acceptance 5 wurde die bisherige Annahme eines sehr niedrigen reinen Recovery-Floors ausdrücklich verworfen. Für einen realistischeren Bingo-/RTB-Ansatz müssen mindestens getrennt werden:

```text
fuel to planned recovery point
+ diversion allowance
+ 45 min final reserve
+ landing minimum
= operational bingo / critical recovery requirement
```

Die 45-Minuten-Reserve ist derzeit eine OMW-Arbeitshypothese aus der bereits bei den Tankern verwendeten Planungslogik; sie ist noch nicht als E-3A-spezifische reale Handbuchvorgabe verifiziert.

Acceptance 5 liefert für `FL350 / 270 KIAS`:

```text
17.318 % Fuel / h
```

Daraus folgt rein rechnerisch für 45 Minuten stabilisierten Geradeausflug:

```text
17.318 %/h * 0.75 h ~= 13.0 % fuel fraction
```

Zusätzlich kommen Rückflugstrecke, Climb/Acceleration, Routing-/Diversion-Allowance und Mindestankunfts-/Landing-Fuel hinzu. Deshalb wird die bestehende `25 %` Critical-Egress-Schwelle **nicht nach unten gesetzt**. Eine genaue neue Bingo-Formel bleibt `SOURCE_RECONCILIATION_PENDING` und `DCS_PENDING`.

## Dedicated LISA nach Acceptance 5

LISA bleibt strategisch Teil des bestehenden AAR-Bestands. Der AWACS-Lifecycle nutzt den bereits laufenden AAR-StrategicAdapter für `CanMaterialize`, `OnMaterialized`, `OnHandoff` und `OnLost`. Es entsteht keine zweite Ressourcenautorität.

Die frühere branch-lokale LISA-Baseline `FL320 / 300 kt` wird durch die nach Acceptance 5 diskutierte receiver-spezifische AAR-Baseline ersetzt:

```text
LISA / OMW_AAR_KC135_LISA
AL_UDEID -> DAVER
-> dedicated AWACS rendezvous
33.6233926368 N / 68.6395554105 E

AAR track/contact:
FL250 / 270 KIAS / 340T / 20 NM

WIZARD rendezvous:
FL250 / 290 KIAS

Pre-contact:
290 -> 270 KIAS

Closure margin:
+20 KIAS
```

Der Projektinhaber stellte einen receiver-spezifischen AAR-Tabellenausschnitt für `E-3A/D/F` bereit. Dort wird als Optimum `FL250 / 275 KIAS / M0.66` und als Receiver-Rendezvous-IAS `310 KIAS` angegeben. OMW übernimmt diese Werte nicht blind als Zwang, sondern nutzt die in Acceptance 5 stabil bestätigten konservativeren DCS-Werte `270 KIAS contact` und `290 KIAS rendezvous`.

Acceptance 5 bestätigte beide FL250-Profile als `STABLE`:

```text
FL250 / 270 KIAS -> 384.7 KTAS, 4.352 % / 100 NM, 16.068 % / h
FL250 / 290 KIAS -> 413.2 KTAS, 4.765 % / 100 NM, 19.057 % / h
```

Damit wird das zuvor beobachtete Problem vermieden, dass WIZARD einen zu schnellen LISA-Track nur mit sehr geringer Closure-Margin oder nahe seiner Leistungsgrenze einholen muss.

LISA wird weiterhin bei 65 Prozent WIZARD-Fuel vorausgeschickt. Sobald sie am Rendezvous physisch etabliert ist, beginnt WIZARD AAR unmittelbar. Ist LISA bis 40 Prozent nicht bereit, wird nicht weiter auf sie gewartet, sofern MOOSE einen anderen kompatiblen aktiven Tanker findet.

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

Für den APOC-Racetrack lautet die neue Engineering-Baseline:

```text
FL320 / 250 KIAS / 017T / 30 NM
```

Acceptance 5 bestätigte `FL320 / 250 KIAS` im Geradeausflug als `STABLE` mit `386.0 KTAS`, `3.984 % / 100 NM` und `14.784 % / h`. Die Auswahl von 250 statt 230 KIAS dient als zusätzliche Speed-Margin für Racetrack-Turns und den höheren Gross-Weight-Zustand nach AAR. Acceptance 5 beweist selbst keine konkrete Stall- oder Turn-Margin.

## Acceptance-5 Performance-Matrix – Zusammenfassung

Der vollständige 15-Zellen-Multi-Test lief mit 20 NM Stabilisierung und 200 NM Messstrecke pro Profil. Ergebnis:

```text
15/15 completed
14 STABLE
1 MARGINAL: FL350 / 310 KIAS
```

Die vollständige Matrix einschließlich Fuel Start/End, Fuel / 200 NM, Fuel / 100 NM, Fuel / h und IAS/TAS liegt in `mission/tests/awacs-external-lifecycle/ACCEPTANCE-5.md`.

Die daraus branch-lokal abgeleiteten Zielwerte sind:

```text
NORMAL TRANSIT:     FL350 / 270 KIAS
FAST TRANSIT:       FL350 / 290 KIAS
AWACS TRACK:        FL320 / 250 KIAS
LISA AAR CONTACT:   FL250 / 270 KIAS
WIZARD AAR RV:      FL250 / 290 KIAS
```

Diese Zielwerte sind **noch nicht** als vollständiger Produktions-Lifecycle in DCS validiert.

## Validierungsstatus

```text
pinned MOOSE source review: complete for the methods listed above
Acceptance 4 pre-revision physical AAR: observed in DCS
Acceptance 5 E-3 performance matrix: 15/15 completed in DCS
Acceptance 5 mission hashes for formal promotion: still missing
new FL350/270 + FL320/250 + FL250 AAR production lifecycle: pending
Lua/CI syntax for future production revision: pending
VALIDATED production lifecycle: no
```

Maßgebliche Testpläne:

```text
mission/tests/awacs-external-lifecycle/ACCEPTANCE-4.md
mission/tests/awacs-external-lifecycle/ACCEPTANCE-5.md
```
