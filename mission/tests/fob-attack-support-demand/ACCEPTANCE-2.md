---
document_id: OMW-STAGE-2B-FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2B Fortress automatic response acceptance planning
  - Fortress threat-to-real-CAS execution and completion
  - local infantry counterattack and return/recovery proof
  - post-combat personnel settlement and resupply reevaluation proof
not_authoritative_for:
  - production CAS source-selection policy
  - production CAS altitude/speed policy
  - final guard rotation duration
  - final installation-specific recovery radius
  - installations other than Fortress
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2B – FOB/COP automatic response Acceptance 2

## Ziel

Acceptance 2 schließt den in Acceptance 1 real bestätigten Stage-2A-Pfad an die vorhandenen MOOSE-AirOps- und Ground-Foundations an und erweitert die Abnahme ausdrücklich über den bloßen CAS-Start hinaus.

Gesamtziel:

```text
Fortress RED perimeter threat
-> MOOSE OPSZONE Attacked(RED)
-> CAS_IMMEDIATE MissionDemand
-> real CAS execution
-> local infantry counterattack
-> threat elimination
-> CAS clean mission closure + RTB/recovery
-> infantry RTZ/recovery handoff
-> survivor/loss settlement
-> personnel threshold reevaluation
-> existing PERSONNEL RESUPPLY path if threshold crossed
```

Die ausführliche Designgrenze steht in:

```text
docs/moose/FOB-ATTACK-AUTOMATIC-RESPONSE-STAGE-2B.md
```

## MOOSE-first-Basis

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Bereits source-verifiziert für den vorhandenen Dispatch-Slice:

```lua
AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)
LEGION:AddMission(Mission) -- inherited by AIRWING
AIRWING OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
AUFTRAG OnAfterExecuting(From, Event, To)
COHORT:AddMissionCapability(MissionTypes, Performance)
```

Vor der Erweiterungsimplementierung müssen zusätzlich der konkrete MOOSE-native CAS-Abschluss-/RTB-Pfad, ARMYGROUP-RTZ-/Returned-/OutOfAmmo-Pfad und die geeignete AUFTRAG-Art für den lokalen Gegenangriff gegen Dokumentation, gepinnten Source und offizielle Beispiele verifiziert werden.

## Vorbedingungen

Die Mission muss vor dem Acceptance-Bundle bereits den bestehenden OMW-Stack geladen haben, insbesondere:

```text
OMW AirOps Warehouse Base
OMW Ground Base + GroundBase.Attach(...)
OMW_AirOps_Jalalabad_Bootstrap.lua
```

`OMW.AirOps.Jalalabad.Status` muss `RUNNING` sein. Die bestehende Jalalabad-Foundation stellt `SQ_US_JBAD_AH64D_B_1_10_AVN` mit `AUFTRAG.Type.CAS` und CAS-Payload bereit.

## CAS-Profil des technischen Nachweises

Nur für diesen technischen DCS-Nachweis:

```text
Airwing:  AW_US_JBAD_TF_SHOOTER_6_6_CAV
Squadron: SQ_US_JBAD_AH64D_B_1_10_AVN
Target:   dieselbe runtime ZONE_RADIUS des Fortress-Sicherheitsperimeters
```

Höhe, Geschwindigkeit und weitere Flugparameter bleiben Acceptance-spezifisch und sind keine Produktionsbaseline.

Für den AH-64-CAS-Flug gilt zusätzlich:

```text
reuse existing OMW helicopter valley/transit corridor
no direct mountain-overflight shortcut
no duplicated hard-coded corridor copy
```

Vor Implementierung ist die aktuell maßgebliche, bereits für Lufttransport verwendete OMW-Tal-/Korridorroute im Repository eindeutig zu identifizieren und über einen gemeinsamen OMW-Pfad wiederzuverwenden.

## Lokale Gegenangriffsgrenze

Für Fortress gilt mit aktuellem PERSONNEL-Target 160:

```text
Defence reserve floor: 80 personnel
Counterattack maximum: 80 personnel
```

Der tatsächliche Gegenangriff darf kleiner sein. Die 50-%-Grenze ist nur das obere Commitment-Limit.

Bereits gebundene Guard-/Sentry-Personen sind nicht erneut verfügbar. Die physische Response wird über CampaignState -> vorhandenes Ground Warehouse / BRIGADE / PLATOON / ARMYGROUP materialisiert; kein direkter `SPAWN:`-Shortcut.

## Rückkehr-/Recovery-Vertrag

Die Infanterie muss nicht bis an das eigentliche Warehouse-Gebäude laufen. Für Fortress wird ein validierter Recovery-Handoff benötigt, bevor dieser Teil als PASS gelten kann:

```text
mission end / guard rotation / OutOfAmmo
-> MOOSE RTZ toward recovery handoff
-> group physically reaches plausible FOB return area
-> Returned / Warehouse AddAsset
-> CampaignState settlement
```

Der konkrete Handoff-Punkt beziehungsweise Radius ist noch zu bestimmen und in DCS gegen HESCO-/Static-/Gebäudehindernisse zu prüfen.

Ein nacktes `Destroy()` als Rückgabe ist nicht zulässig.

## Guard-Lifecycle

Der vorhandene `ONGUARD`-Sentry braucht einen endlichen Lifecycle. Acceptance 2 beziehungsweise ein unmittelbar zugehöriger Folge-Slice muss mindestens nachweisen:

```text
ONGUARD
-> rotation condition OR OutOfAmmo OR explicit relief
-> mission closure
-> RTZ
-> recovery handoff
-> Returned / Warehouse
-> survivor/loss settlement
```

Die Rotationsdauer wird in diesem Acceptance-Dokument nicht festgelegt.

## Post-combat PERSONNEL settlement

Materialisierte PERSONNEL werden beim Deployment bereits gebunden beziehungsweise aus dem verfügbaren Pool genommen. Gefallene Soldaten werden nicht nochmals vom verfügbaren Bestand abgezogen.

Zu beweisen ist:

```text
survivors returned -> credited back exactly once
confirmed losses -> remain unavailable and loss-audited exactly once
post-combat available stock -> existing reorder rule reevaluated
```

Wenn der vorhandene PERSONNEL-Reorder-Schwellenwert unterschritten wird, muss der bereits vorhandene PERSONNEL-RESUPPLY-Pfad reagieren. Acceptance 2 führt keinen neuen Resupply-Mechanismus ein.

## PASS-Kriterien – CAS

Der reale DCS-Lauf muss mindestens folgende Reihenfolge belegen:

```text
SENTRY_ON_MISSION
SENTRY_ONGUARD_EXECUTING
READY ... detection=OPSZONE_ATTACKED
QUALIFIED_THREAT
DEMAND_RESULT ... created=true
CAS_DISPATCHED
CAS_FLIGHT_ON_MISSION
CAS_EXECUTING
THREAT_CLEARED or equivalent verified MOOSE/OMW evidence
CAS_MISSION_CLOSURE
CAS_RTB_OR_RECOVERY
```

Zusätzlich:

```text
exactly one dispatch for the created demand
MissionDemand assignedTo = AIRWING:AW_US_JBAD_TF_SHOOTER_6_6_CAV
MissionDemand reaches ACTIVE on AUFTRAG Executing
real FLIGHTGROUP observed through AIRWING OnAfterFlightOnMission
no direct SPAWN
no native world.addEventHandler
no MIST
no .miz mutation by ChatGPT
```

Ein PASS nur aufgrund von `AUFTRAG:NewCAS()`, `AIRWING:AddMission()` oder `CAS_EXECUTING` ist nicht mehr ausreichend.

## PASS-Kriterien – lokale Gegenwehr

Der DCS-Nachweis muss belegen:

```text
personnel availability evaluated before commitment
50 % defence reserve floor not violated
response force committed exactly once
real MOOSE ARMYGROUP materialized
counterattack mission starts
mission end or OutOfAmmo causes return path
RTZ physically approaches/enters approved recovery handoff
Returned observed
Warehouse AddAsset observed
```

Die konkrete Gegenangriffs-AUFTRAG-Art wird erst nach abgeschlossener MOOSE-first-Source-/Demo-Prüfung in den Builder übernommen.

## PASS-Kriterien – Settlement/Resupply

Mindestens ein reproduzierbarer Testfall muss die Folgebehandlung beweisen:

```text
returned survivors settled exactly once
confirmed losses settled exactly once
no double deduction of already committed personnel
personnel stock reevaluated after settlement
RESUPPLY demand appears when and only when existing reorder threshold is crossed
existing PERSONNEL resupply orchestration is reused
```

Der Nachweis darf in einen separaten Acceptance-2-Unterlauf aufgeteilt werden, damit ein einzelner DCS-Lauf nicht unnötig lang und diagnostisch unklar wird.

## Verifizierter lokaler Build-Checkpoint 2026-08-29

Der Projektinhaber hat nach Pull auf den dokumentierten Branch-HEAD den vorhandenen Stage-2B-CAS-Dispatch-Bundle lokal gebaut und den SHA-256 separat verifiziert.

```text
Branch: agent/fob-attack-support-demand
Git HEAD: a590c23126c8bb666ffea581e805b3e9b8f4776b
BuilderVersion: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-1
TestId: FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2
GeneratedUtc: 2026-08-29T21:14:05Z
Bundle: mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_CAS_Dispatch_Acceptance_2.lua
Bundle SHA-256: 9ADB5C601A1F30C748C747835FA62B191F485AEC002106020B34EC9D0844CCD8
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
RequiresGroundBaseAttached: true
RequiresJalalabadAirOpsRunning: true
CASAirwing: AW_US_JBAD_TF_SHOOTER_6_6_CAV
CASSquadron: SQ_US_JBAD_AH64D_B_1_10_AVN
CASMissionType: AUFTRAG.Type.CAS
CASAltitudeFt: 10000 (acceptance-only)
CASSpeedKts: 120 (acceptance-only)
DirectSpawn: false
CommanderCreated: false
MizMutation: false
```

Builder-source hashes:

```text
scripts/campaign/OMW_MissionDemand.lua
E348E75B87135B99D780E07CA6B6FB7C3C530E048E9C6DE790328D147DE32848

scripts/campaign/OMW_FobAttackDemandPolicy.lua
F1BB5041382823B8B4DD6EE2EA6418B38C834C3347FBAAD633F8F24DA1A07FF5

scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
C53BE08B5F0ABCEA8DF3FADDA9EA41E2FEBAACA34FED1B3D1D195F63E0D6650D

scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
823189650CF984C7FDE2280AAD097F4F70A7670BEBD4D304D3FA34F0A15EC363

mission/tests/fob-attack-support-demand/src/02-fob-attack-cas-dispatch-acceptance-2.lua
9D1F457A3935854A9A2C21888ABE542B13B66ADE0C16EC9B8F3440512C3C00B8
```

Die separate `Get-FileHash`-Ausgabe stimmt exakt mit dem vom Builder ausgegebenen Bundle-Hash überein. Der lokale Git-Status zeigte nur die bereits bekannten untracked Verzeichnisse `mission/ground-operations/` und `mission/tests/fob-attack-support-demand/dist/`.

Dieser Build-Checkpoint ist **kein DCS-PASS**. Außerdem bildet `FOB-ATTACK-CAS-DISPATCH-ACCEPTANCE-2-1` nur den bereits implementierten CAS-Dispatch-Slice ab. Die nachträglich beschlossene Erweiterung um CAS-Abschluss/RTB, lokale Gegenwehr, Guard-Rotation/Recovery, Verlust-Settlement und Resupply-Reevaluation ist in diesem Bundle noch nicht implementiert und darf mit diesem Bundle nicht als getestet gelten.

## Nicht durch Acceptance 2 entschieden

Offen bleiben bewusst:

```text
production CAS source selection between multiple origins
final CAS altitude/speed profiles
final guard rotation duration
final installation-specific recovery radii
counterattack force-sizing algorithm below the 50 % maximum
maximum simultaneous response groups
production OPSZONE cadence
restart/restore idempotency beyond separately accepted contracts
```

Diese Werte dürfen aus einem PASS nicht automatisch als Produktionsbaseline abgeleitet werden.
