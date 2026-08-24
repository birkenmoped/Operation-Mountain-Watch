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
source_commit: PENDING_MERGE
supersedes:
superseded_by:
validated_in_dcs: false
---

# AWACS Fuel-Driven AAR Lifecycle

## 1. Geltungsbereich

Dieses Dokument beschreibt den final reconcilierten branch-lokalen WIZARD-/LISA-Lifecycle vor dem abschließenden integrierten DCS-Lauf. Es ersetzt keine Governance auf `main` und erklärt die neue Runtime noch nicht für DCS-validiert.

Maßgeblich bleiben:

```text
CampaignState = strategische Ressourcenautorität
DCS-Gruppen = temporäre physische Repräsentationen
MOOSE = primäres Framework
kein eigener Native-DCS-Refuel-Controller
```

Gepinnter Framework-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. Acceptance-5-Engineering-Baseline

Acceptance 5 flog 15 E-3A-Profile mit jeweils 20 NM Stabilisierung und 200 NM Messstrecke. Der vollständige Test erreichte `ALL_COMPLETE profiles=15`; 14 Profile waren `STABLE`, `FL350 / 310 KIAS` war `MARGINAL`.

Für die Runtime werden daraus folgende Zielwerte übernommen:

```text
WIZARD normal transit:       FL350 / 270 KIAS
WIZARD optional fast:        FL350 / 290 KIAS
WIZARD APOC racetrack:       FL320 / 250 KIAS
LISA AAR track/contact:      FL250 / 270 KIAS
WIZARD dedicated-LISA RV:    FL250 / 290 KIAS
```

Gemessene Referenzwerte:

```text
FL350 / 270 KIAS -> 430.6 KTAS, 4.162 % / 100 NM, 17.318 % / h, STABLE
FL350 / 290 KIAS -> 462.5 KTAS, 4.484 % / 100 NM, 20.049 % / h, STABLE
FL320 / 250 KIAS -> 386.0 KTAS, 3.984 % / 100 NM, 14.784 % / h, STABLE
FL250 / 270 KIAS -> 384.7 KTAS, 4.352 % / 100 NM, 16.068 % / h, STABLE
FL250 / 290 KIAS -> 413.2 KTAS, 4.765 % / 100 NM, 19.057 % / h, STABLE
```

Diese Messwerte sind DCS-Evidenz für den dokumentierten Acceptance-5-Teststand. Die Verwendung derselben Profile im vollständigen AWACS-/LISA-Lifecycle ist bis zum finalen integrierten Lauf `DCS_PENDING`.

## 3. MOOSE-Speed-Vertrag

Der gepinnte Source bestätigt für `FLIGHTGROUP:AddWaypoint(...)` einen Speed-Parameter in knots. Acceptance 5 hat den gewünschten KIAS-Wert vor Übergabe an SPAWN/Routing mit `UTILS.IasToTas(...)` in den MOOSE-Routenwert umgerechnet und die tatsächlich geflogene IAS anschließend unabhängig gemessen.

Daher gilt für WIZARD-Routing:

```text
KIAS engineering target
-> UTILS.IasToTas(targetKIAS, altitudeMeters)
-> SPAWN:InitSpeedKnots(routeSpeedKt)
-> FLIGHTGROUP:SetDefaultSpeed(routeSpeedKt)
-> FLIGHTGROUP:AddWaypoint(... routeSpeedKt ...)
```

Für AUFTRAG-Racetracks werden die Missionswerte direkt als Track-IAS geführt:

```text
APOC: FL320 / 250 KIAS
LISA: FL250 / 270 KIAS
```

## 4. Gepinnter `FLIGHTGROUP:Refuel()`-Pfad

Der Source-Review des tatsächlich verwendeten `Moose.lua` bestätigt:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> receiver route to supplied Coordinate
-> route speed from self.speedCruise
-> normal Refueled FSM path
```

Die öffentliche Refuel-Signatur bietet keine getrennten Parameter für Rendezvous-Höhe, Rendezvous-IAS oder Contact-IAS.

`OPSGROUP:SetDefaultSpeed(Speed)` ist öffentlich und setzt den von `Refuel()` verwendeten Cruise-Speed. Deshalb wird beim geplanten LISA-Pfad unmittelbar vor `Refuel()` der auf `FL250 / 290 KIAS` umgerechnete Route-Speed als Default gesetzt. Die übergebene LISA-Koordinate liefert die aktuelle Tankergeometrie am FL250-Racetrack.

Nach `Refueled` wird der normale WIZARD-Transit-Route-Speed wiederhergestellt. Die pausierte APOC-Mission bleibt MOOSE-Autorität und wird über den vorhandenen Mission-Lifecycle fortgesetzt.

Wichtig:

```text
290 -> 270 KIAS near contact
```

wird nicht durch einen eigenen OMW-Contact-Controller erzwungen. Nach Aktivierung des DCS-Refuelling-Tasks liegen finaler Join und Contact beim DCS-AI-Task. Das konkrete Verhalten wird im finalen DCS-Lauf beobachtet.

Für einen Fallback-Tanker wird kein künstliches FL250-/290-KIAS-Profil aufgezwungen. Dessen tatsächliche Tankergeometrie bleibt maßgeblich; die Receiver-Ausführung bleibt `FLIGHTGROUP:Refuel()`.

## 5. Fuel-/AAR-Orchestrierung

Die branch-lokale Policy bleibt nach Acceptance 4/5:

```text
65 %  -> LISA pre-dispatch
LISA ready -> geplanter WIZARD-AAR beginnt sofort
40 %  -> fallback AAR trigger, falls der geplante LISA-Pfad nicht bereit ist
25 %  -> sichtbarer off-map contingency egress, falls kein Refuel-Pfad etabliert ist
```

`40 %` ist ausdrücklich keine normale geplante AAR-Startschwelle.

LISA FuelLow bleibt:

```text
38 %
```

Wenn LISA FuelLow während eines aktiven WIZARD-Refuels auslöst:

```text
-> egress pending
-> Tankermission nicht unter dem Receiver abbrechen
-> nach WIZARD Refueled LISA-Egress anordnen
```

## 6. Reserve-/Bingo-Reconciliation

Die auf `main` akzeptierte Tanker-Fuelplanung in `AAR-LRC-TRANSIT.md` verwendet für direkt kalibrierte Tanker:

```text
FuelLow =
  measured TRACK_DEPARTURE -> EXTERNAL_HANDOFF burn
+ virtual EXTERNAL_HANDOFF -> source-base burn
+ 45-minute reserve
```

Zusätzlich ist dort ein geplanter Landing Floor von 13,000 lb dokumentiert. Für die sechs Tankerprofile lag die berechnete 45-Minuten-Reserve über diesem Floor und war deshalb die kontrollierende Reservekomponente.

Eine eigenständige zusätzliche `diversion allowance` ist in dieser akzeptierten Tankerformel nicht als separater Term dokumentiert. Sie wird daher für WIZARD nicht erfunden.

Acceptance 5 misst für `FL350 / 270 KIAS`:

```text
17.318 % fuel / h
```

Eine rein rechnerische 45-Minuten-Menge unter denselben stabilisierten Testbedingungen beträgt damit ungefähr:

```text
17.318 * 0.75 ~= 13.0 %
```

Das ist keine vollständige E-3A-Bingo-Berechnung. Für WIZARD fehlt eine entsprechend kalibrierte physische `APOC -> ROSIE -> external handoff`-Recovery-Rechnung sowie eine reale E-3-spezifische Landing-/Reservevorgabe.

Die vorhandene `25 %` Critical-Grenze wird deshalb **nicht abgesenkt**. Ihre Bedeutung wird begrenzt auf:

```text
visible DCS contingency floor
-> kontrollierter Egress über ROSIE
-> external handoff
```

Der anschließende abstrakte Rückweg vom external handoff zur strategischen Quelle `OFFMAP_AL_DHAFRA` ist keine physisch in DCS geflogene Strecke. Er darf deshalb nicht mit einer ungeprüften DCS-Landing-Fuel-Aussage vermischt werden.

## 7. Persistenter APOC-Orbit und Service

Der physische Orbit und der Service-/Sensorstatus bleiben getrennt:

```text
vor 15:30 local: persistent APOC orbit / sensor standby
15:30 local:     sensor/service active, kein Missionstausch
AAR:             MOOSE Refuel pausiert die persistente Mission
post-AAR:        APOC-Mission wird fortgesetzt; Sensor erst nach physischem Rejoin aktiv
23:30 local:     Service-Ende, echter Egress über ROSIE
```

APOC:

```text
FL320 / 250 KIAS / 017T / 30 NM
```

## 8. LISA-ready-Vertrag

LISA wird nach dem akzeptierten AAR-Ingressmuster zunächst über DAVER und den 60-NM-Late-Approach geführt. Erst danach wird der Tanker-AUFTRAG hinzugefügt und die Transition auf den AAR-Track begonnen.

Ready gilt branch-lokal bei:

```text
<= 5 NM vom LISA rendezvous anchor
und
innerhalb +/- 1000 ft um FL250
```

Es wird bewusst kein neuer, ungeprüfter Speed-Gate erfunden. Die Acceptance protokolliert tatsächliche LISA-IAS/TAS beim Ready-Zeitpunkt.

## 9. Runtime-Implementierung

Finaler branch-lokaler Controller:

```text
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
```

Der frühere `OMW_AWACS_Controller_FullLifecycle_V2.lua` bleibt als Branch-Entwicklungshistorie erhalten, wird vom finalen Foundation-Builder aber nicht mehr eingebunden.

Produktionsbundle:

```text
tools/build-awacs-foundation.ps1
-> mission/runtime/air-operations/OMW_AWACS_Foundation.lua
```

Finaler observer-only Lifecycle-Test:

```text
tools/build-awacs-acceptance-4.ps1
-> mission/tests/awacs-external-lifecycle/dist/OMW_AWACS_Acceptance_4.lua
```

Acceptance 4 steuert keine physische Aktion. Sie beobachtet unter anderem WIZARD- und LISA-Höhe, IAS/TAS, Fuel, Service-State, AAR-Phase, LISA-ready, Refuel, Rejoin und Egress.

## 10. MOOSE-First-Grenze

Verwendet werden weiterhin öffentliche beziehungsweise source-verifizierte MOOSE-Pfade:

```text
SPAWN
FLIGHTGROUP
AUFTRAG
COORDINATE
SCHEDULER
UTILS.IasToTas
FLIGHTGROUP:SetDefaultSpeed
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:SetFuelLowThreshold
FLIGHTGROUP:SetFuelCriticalThreshold
FLIGHTGROUP:FindNearestTanker
FLIGHTGROUP:Refuel
FuelLow / FuelCritical / Refueled FSM callbacks
PauseMission / UnpauseMission lifecycle
```

Nicht eingeführt werden:

```text
MIST
Native-DCS-Refuel-Ersatz
Parallel-Contact-Controller
MissionScripting.lua-Änderung
undokumentierte SPAWN-Fuel-Mutation
```

## 11. Offene Acceptance-Grenze

Vor technischer Abnahme des finalen Branch-Standes ist ein integrierter DCS-Lauf erforderlich. Zu beobachten sind mindestens:

```text
external spawn / ROSIE ingress
FL350 / 270 KIAS normal transit
APOC FL320 / 250 KIAS
15:30 service state without detour
65 % LISA pre-dispatch
LISA FL250 / 270 KIAS ready
WIZARD dedicated-LISA rendezvous / DCS final join
MOOSE Refueled
APOC rejoin and sensor restore
LISA deferred egress if FuelLow occurs during active receiver refuel
23:30 or controlled requested egress
ROSIE outbound / external handoff / exact-once strategic recredit
```

Bis dieser Lauf mit realer MIZ-, Bundle-, DCS-, MOOSE- und Log-Provenienz dokumentiert ist, bleibt die final reconciliierte Runtime `DCS_PENDING` und dieses Dokument `DRAFT`.
