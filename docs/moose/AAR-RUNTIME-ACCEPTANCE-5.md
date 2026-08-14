---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-5
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Nelson northern ingress/egress gate candidate based on EGPAN approach
  - post-refuel dwell correction before accelerated FuelLow
  - repeat proof of owner-run AI Boom path after Acceptance-4
not_authoritative_for:
  - final production AAR gate set
  - complete FAST/SLOW dual-tanker production matrix
  - production MissionDemand/CampaignState activation logic
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AAR Runtime Acceptance-5 – EGPAN Gate + Post-Refuel-Dwell

## 1. Anlass

Acceptance-4 bestätigte den MOOSE-/DCS-AAR-Kernpfad einschließlich Y-Band-TACAN, Bagram-F-16-AIRWING-Recruiting, visueller Boom-Nutzung beider F-16 und plausibler Fuel-Zunahme. Zwei Acceptance-Punkte bleiben zu korrigieren:

1. Der Nelson-Gate-Kandidat lag noch deutlich innerhalb des nordöstlichen Afghanistan-Zipfels.
2. Der künstliche 99-%-FuelLow-Trigger wurde unmittelbar nach dem ersten `OnAfterRefueled`-Event aktiviert und konnte dadurch den zweiten Receiver unnötig unter Zeitdruck setzen.

## 2. Nelson-EGPAN-Ingress

Historisch/geografisch dokumentierter Bezugsrahmen:

```text
Northern KC-135 origin model: MANAS / Kyrgyzstan
Transit region: Tajikistan
Kabul FIR entry reference: EGPAN
EGPAN: N38°25'00" E070°44'00"
High airway reference: M881
Low airway reference: V876
```

Acceptance-5 verwendet als Materialisierungs-/Handoff-Kandidaten ungefähr 50 km NNE von EGPAN:

```text
NELSON gate candidate:
N38.83163
E70.95271

Approximate relation:
~50 km NNE of EGPAN
```

Ziel ist eine Materialisierung noch in Tajikistan, vor dem Eintritt in Afghanistan/Kabul FIR. EGPAN bleibt der dokumentierte Navigations-/FIR-Referenzpunkt; der Gate-Kandidat ist eine OMW-Ableitung und bis zum DCS-Lauf nicht `VALIDATED`.

## 3. Runtime-Konfiguration

```text
CLANCY / Shell 1
Gate: N28.90264890 E64.61166667
Track: N31.75441342 E66.82695501
Orbit: FL225 / 220 KIAS
Radio: 241.600 AM
TACAN: 60Y / CLA

NELSON / Texaco 1
Gate: N38.83163 E70.95271
Track: N36.37666667 E71.01833333
Orbit: FL275 / 300 KIAS
Radio: 384.400 AM
TACAN: 47Y / NEL
```

Der Spawn-Heading wird weiterhin mit `COORDINATE:HeadingTo()` berechnet und mit `SPAWN:InitHeading()` gesetzt.

## 4. Post-Refuel-Dwell

Acceptance-5 trennt den ersten dokumentierten Refuel-Abschluss vom künstlichen FuelLow-Test:

```text
AI_BOOM_REFUELED_PASS
-> 60 s post-refuel dwell
-> POST_REFUEL_DWELL_PASS
-> accelerated FuelLow threshold = 99%
-> FuelLow -> Cancel -> Egress
```

Die 60 Sekunden sind ausschließlich ein Acceptance-Testwert. Daraus wird keine produktive Tanker-Abbruchregel abgeleitet.

## 5. Bestehender Receiver-Pfad

Unverändert:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Der test-only Missionsreichweiten-Override bleibt:

```lua
mission:SetMissionRange(250)
```

Die produktive F-16-SQUADRON-Baseline wird nicht geändert.

## 6. Erwartete Marker

```text
TANKER_START_PASS area=CLANCY ... tacan=60Y ...
TANKER_START_PASS area=NELSON gateLat=38.83163000 gateLon=70.95271000 ... tacan=47Y ...
TANKER_EXECUTING_PASS area=CLANCY ... speedKt=220
TANKER_EXECUTING_PASS area=NELSON ... speedKt=300
RECEIVER_MISSION_ADDED_PASS ... missionRangeNm=250
RECEIVER_ASSIGNED_PASS ...
AI_BOOM_REFUEL_ORDER_PASS ...
AI_BOOM_REFUELED_PASS ... postRefuelDwellSec=60
POST_REFUEL_DWELL_PASS elapsedSec=... requiredSec=60
ACCELERATED_FUEL_LOW_ARMED ... postRefuelDwellSec=60
FUEL_LOW_PASS area=CLANCY ...
FUEL_LOW_PASS area=NELSON ...
EGRESS_GATE_PASS area=CLANCY ...
EGRESS_GATE_PASS area=NELSON ...
HARNESS_READY ... nelsonGateReference=50km_NNE_EGPAN postRefuelDwellSec=60 ...
```

## 7. Acceptance-Kriterien

Der Owner-Lauf soll bestätigen:

1. Nelson materialisiert am neuen Gate außerhalb Afghanistans bzw. plausibel in Tajikistan;
2. Nelson zeigt nach Materialisierung plausibel in Richtung seines Tracks;
3. kein offensichtliches Map-Edge-/Terrain-/Routingproblem entsteht;
4. 47Y/NEL und 60Y/CLA bleiben funktionsfähig;
5. F-16-Recruiting und Boom-Refueling bleiben funktionsfähig;
6. nach dem ersten `Refueled`-Event vergehen mindestens 60 Sekunden, bevor der künstliche FuelLow-Pfad scharfgeschaltet wird;
7. beide Tanker können anschließend weiterhin sauber über ihre Gates ausgeblendet werden.

## 8. Grenzen

Acceptance-5 testet weiterhin **nicht**:

```text
- A-10 als tatsächlichen SLOW-Receiver
- zwei Tanker gleichzeitig in derselben AAR-Area mit >=3000 ft Staffelung
- automatische A-10 -> SLOW / F-16 -> FAST Auswahl
- produktive MissionDemand-Logik
```

Diese Punkte bleiben Folgearbeit nach Abschluss des korrigierten Einzel-/Zwei-Area-Kernpfads.
