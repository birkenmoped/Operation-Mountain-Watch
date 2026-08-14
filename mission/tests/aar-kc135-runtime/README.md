---
document_id: OMW-TEST-AAR-KC135-RUNTIME-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - KC-135 multi-tanker AAR runtime acceptance test layout
  - exact active template set and expected test markers
  - source-reviewed MOOSE paths used by the acceptance harness
not_authoritative_for:
  - DCS runtime acceptance before an owner-run test
  - final ingress-gate airspace clearance
  - historical tanker callsign authenticity
  - production support-concurrency limits
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# KC-135 Multi-Tanker Runtime Acceptance

## Ziel

`AAR-KC135-RUNTIME-ACCEPTANCE-2` ist der kombinierte Retest nach dem methodisch ungeeigneten ersten FuelLow-Lauf. Er prueft in einem DCS-Lauf:

- alle fuenf vorbereiteten KC-135-Boom-Tanker gleichzeitig: `CLANCY`, `HOMER`, `KRUSTY`, `NELSON`, `PATTY`;
- Uebernahme der 90/96-%-Seed-Fuelwerte nach abgeschlossener FLIGHTGROUP-Initialisierung;
- `SPAWN -> FLIGHTGROUP -> AUFTRAG:TANKER` im gepinnten MOOSE-Stand;
- Transit zu allen fuenf AAR-Areas;
- `AUFTRAG:TANKER` muss bei allen fuenf `EXECUTING` erreichen;
- mindestens 180 Sekunden gemeinsame `EXECUTING`-Zeit aller fuenf Tanker vor dem FuelLow-Test;
- gleichzeitige Laufzeit-/Performancebeobachtung mit fuenf Tankern;
- fuenf unterschiedliche Funk-/TACAN-Konfigurationen und Racetrack-Geometrien;
- erst nach dem gemeinsamen Racetrack-Dwell wird `FuelLow` kuenstlich auf 99 Prozent geschaltet;
- `FuelLow -> AUFTRAG:Cancel() -> Mission Egress`;
- Distanz zum Egress-Gate und kontrollierte physische Entfernung am Gate als Test fuer den spaeteren Off-map-Handoff;
- Fuelwerte bei Track-Entry und am Gate als Evidenz fuer die spaetere CampaignState-/Off-map-Fuelbilanz.

Der Harness veraendert keine `.miz` automatisch.

## Test-ID

```text
AAR-KC135-RUNTIME-ACCEPTANCE-2
```

## Owner-Freigabe fuer diesen Test

Am 14.08.2026 hat der Projektinhaber fuer diesen Retest ausdruecklich verlangt, alle vorbereiteten Tanker gleichzeitig zu testen. Diese Freigabe gilt **nur fuer den isolierten Acceptance-/Stress-Test**.

Die produktive Baseline aus `OMW-AIR-IMPLEMENTATION` bleibt unveraendert:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der Fuenf-Tanker-Lauf ist damit eine dokumentierte Testausnahme und **keine** stillschweigende Anhebung der produktiven Concurrency-Grenze.

## Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` wird ausschliesslich durch den Builder erzeugt.

## MOOSE-First-Nachweis

Gepinnter MOOSE-Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsaechlich verwendeten `Moose.lua` source-reviewed und fuer diesen Retest verwendet:

```text
SPAWN:New(template)
SPAWN:SpawnFromCoordinate(coordinate)
FLIGHTGROUP:New(group)
OPSGROUP:AddMission(mission)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:IsExecuting()
AUFTRAG:Cancel()
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP:OnAfterFuelLow(...)
FLIGHTGROUP:GetCoordinate()
COORDINATE:Get2DDistance(...)
OPSGROUP:Despawn(delay, noEventRemoveUnit)
SCHEDULER
```

Der Scheduler laeuft nur alle 30 Sekunden. Er dient Acceptance-Telemetrie, dem einmaligen Umschalten der FuelLow-Schwelle nach nachgewiesenem Racetrack-Dwell und der Erkennung des Egress-Gate-Handoffs. Es gibt keinen eigenen Fuel-Controller und keinen Native-DCS-Eventhandler.

`OPSGROUP:Despawn(1, true)` wird im Retest nur nach Erreichen eines 10-NM-Radius um das zugewiesene Egress-Gate verwendet. `NoEventRemoveUnit=true` verhindert, dass die Testentfernung als normaler Warehouse-/Legion-Ruecklauf interpretiert wird. Eine produktive CampaignState-Abrechnung wird in diesem Test noch nicht geschrieben.

## Mission-Editor-Vertrag

| Area | Template | Callsign | Radio | Fuel | Datalink | STN |
|---|---|---|---:|---:|---|---|
| Clancy | `OMW_AAR_KC135_CLANCY` | Shell 1-1 | 241.600 AM | 90 % / 81630 kg | SH11 | 04461 |
| Homer | `OMW_AAR_KC135_HOMER` | Arco 1-1 | 376.000 AM | 90 % / 81630 kg | AC11 | 04462 |
| Krusty | `OMW_AAR_KC135_KRUSTY` | Arco 2-1 | 258.300 AM | 90 % / 81630 kg | AC21 | 04463 |
| Nelson | `OMW_AAR_KC135_NELSON` | Texaco 1-1 | 384.400 AM | 96 % / 87072 kg | TX11 | 04464 |
| Patty | `OMW_AAR_KC135_PATTY` | Texaco 2-1 | 237.300 AM | 96 % / 87072 kg | TX21 | 04465 |

Alle Templates bleiben Late Activation, `task = Refueling`, ohne ME-Tanker-/TACAN-/Orbit-Waypointaktionen. Die Runtime-Mission kommt aus MOOSE.

## Testwerte

| Area | Track | Altitude | Speed | Heading | Leg | Radio | TACAN | Seed Fuel |
|---|---|---:|---:|---:|---:|---:|---|---:|
| Clancy | N31.75441342 E66.82695501 | FL225 | 300 kt | 225.276 T | 35 NM | 241.600 AM | 60X / CLA | 90 % |
| Homer | N32.93833333 E68.22333333 | FL230 | 300 kt | 317.573 T | 35 NM | 376.000 AM | 54X / HOM | 90 % |
| Krusty | N32.65123012 E68.15946309 | FL260 | 300 kt | 212.350 T | 35 NM | 258.300 AM | 42X / KRU | 90 % |
| Nelson | N36.37666667 E71.01833333 | FL275 | 300 kt | 10.428 T | 35 NM | 384.400 AM | 47X / NEL | 96 % |
| Patty | N34.97134133 E71.47789605 | FL255 | 300 kt | 89.662 T | 35 NM | 237.300 AM | 48X / PAT | 96 % |

Homer und Krusty werden fuer den Stress-/Acceptance-Lauf bewusst gleichzeitig geflogen und vertikal getrennt. Das hebt ihre produktive Rolle als Alternativen nicht auf.

### Ingress / Egress

```text
CLANCY / HOMER / KRUSTY:
OMW_TANKER_GATE_S
N29.9818333333 E64.6116666667

NELSON / PATTY:
OMW_TANKER_GATE_NE
N38.1211666667 E70.3600000000
```

`OMW_TANKER_GATE_NE` bleibt Candidate mit offener Airway-/Map-edge-Pruefung. Ein erfolgreicher technischer Egress macht den Gate-Punkt nicht automatisch `BINDING` oder `VALIDATED`.

## FuelLow-Sequenz

Der Fehler aus Acceptance-1 wird explizit verhindert:

```text
Spawn
-> FuelLow threshold 20 % waehrend Transit
-> alle fuenf AUFTRAG:TANKER muessen EXECUTING erreichen
-> alle fuenf muessen 180 s gleichzeitig EXECUTING bleiben
-> erst dann FuelLow threshold 99 %
-> MOOSE FuelLow Event
-> AUFTRAG:Cancel()
-> Egress-Gate
-> bei <= 10 NM: EGRESS_GATE_PASS + MOOSE Despawn
```

Damit kann `FuelLow` den eigentlichen Tanker-/Racetrack-Test nicht mehr vorzeitig abbrechen.

## Erwartete Logmarker

```text
START simultaneous=CLANCY,HOMER,KRUSTY,NELSON,PATTY
START_AREA_PASS area=<ALL FIVE>
SPAWN_PASS area=<ALL FIVE> ... seedReadback=DEFERRED
SEED_FUEL_PASS area=<ALL FIVE>
MISSION_CONFIG_PASS area=<ALL FIVE>
TANKER_EXECUTING_PASS area=<ALL FIVE>
ALL_TANKERS_EXECUTING_PASS count=5 dwellRequiredSec=180
ACCELERATED_FUEL_LOW_ARMED thresholdPct=99
FUEL_LOW_PASS area=<ALL FIVE> action=CANCEL_TO_EGRESS
EGRESS_GATE_PASS area=<ALL FIVE> action=DESPAWN_OFFMAP_HANDOFF
SUMMARY ...
```

## Acceptance-Kriterien

Ein erfolgreicher gemeinsamer Lauf muss mindestens zeigen:

1. alle fuenf KC-135 werden genau einmal gespawnt;
2. der verzoegerte Fuel-Readback zeigt plausibel 90/90/90/96/96 Prozent und keinen `inf`-PASS;
3. alle fuenf `AUFTRAG:TANKER` erreichen `EXECUTING`;
4. alle fuenf bleiben mindestens 180 Sekunden gleichzeitig `EXECUTING`, bevor FuelLow kuenstlich beschleunigt wird;
5. die Racetrack-Darstellung wird optisch fuer alle fuenf bestaetigt; insbesondere Homer/Krusty duerfen sich trotz gleicher regionaler Rolle nicht gefaehrlich annaehren;
6. fuenf gleichzeitige Tanker erzeugen keine unvertretbaren DCS-/MOOSE-Fehler oder Performanceprobleme im isolierten Test;
7. Funk und TACAN sind mit ihren projektierten Zuordnungen praktisch pruefbar;
8. Boom-Refueling ist mit mindestens einem aktuellen OMW-Boom-Receiver praktisch pruefbar;
9. nach dem Dwell loest die 99-%-Testschwelle bei allen fuenf `FuelLow` aus;
10. `Cancel()` fuehrt alle fuenf aus ihrem AAR-Auftrag in Richtung des zugewiesenen Egress-Gates;
11. der Harness bestaetigt den Gate-Eintritt innerhalb von 10 NM und entfernt die Gruppe danach kontrolliert mit MOOSE `Despawn`;
12. Track-Entry-, FuelLow- und Gate-Fuelwerte sowie die Laufzeiten stehen fuer die folgende Off-map-/CampaignState-Bilanzierung zur Verfuegung;
13. keine produktive Anhebung der Support-Concurrency wird aus diesem Test abgeleitet.

## Befund aus Acceptance-1

Der erste Owner-Lauf am 14.08.2026 mit DCS `2.9.28.26385` zeigte belastbar Spawn, 90/96-%-Fueluebernahme nach Initialisierung, `FuelLow`-Events und die damalige Staging-Logik. Der Test setzte die FuelLow-Schwelle jedoch bereits waehrend des Transits nur einen Prozentpunkt unter den Seed-Wert. Dadurch wurden die Auftraege vor `EXECUTING` abgebrochen. Die Punkte `EXECUTING`, Racetrack und aktiver Tankerbetrieb sind aus diesem Lauf deshalb **INVALID als Negativnachweis** und werden mit Acceptance-2 neu getestet.

`VALIDATED` darf erst nach dokumentiertem Owner-DCS-Lauf mit Branch, Commit, MIZ-Hash, Bundle-Hash, DCS-Version und gepinntem MOOSE-Hash gesetzt werden.
