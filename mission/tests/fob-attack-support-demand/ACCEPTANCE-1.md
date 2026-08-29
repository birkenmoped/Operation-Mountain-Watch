---
document_id: OMW-STAGE-2-FOB-ATTACK-HIT-ACCEPTANCE-1
status: PLANNED
document_class: DCS_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 DCS acceptance plan for MOOSE EVENTS.Hit qualification
  - exact Fortress test target identity and PASS criteria
not_authoritative_for:
  - runtime validation before the documented DCS run
  - CAS aircraft dispatch
  - general attack severity classification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB Attack Hit Acceptance 1

## 1. Ziel

Der Test soll ausschließlich den kleinsten noch offenen Stage-2-Runtime-Pfad bestätigen:

```text
real RED weapon hit on explicitly registered BLUE Fortress test group
-> MOOSE EVENTS.Hit
-> OMW_FobAttackHitAdapter
-> BLUE/RED + registered-target qualification
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
-> repeated real hit at same installation
-> active_duplicate
-> exactly one active CAS demand
```

Nicht Bestandteil dieses Tests:

```text
AUFTRAG:NewCAS(...)
COMMANDER:AddMission(...)
AIRWING/SQUADRON dispatch
CAS success/failure
attack severity model
CampaignState resource mutation
native world.addEventHandler
```

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendeter Framework-Pfad:

```text
BASE:New()
BASE:HandleEvent(EVENTS.Hit, callback)
BASE:UnHandleEvent(EVENTS.Hit)
SCHEDULER:New(...)
```

Der produktive Adapter verwendet keinen parallelen DCS-World-Eventhandler.

## 3. Mission-Editor-Gate

ChatGPT verändert die `.miz` nicht. Für den Acceptance-Lauf muss in einer Kopie der aktuellen OMW-Testmission genau ein dediziertes BLUE-Testziel vorhanden sein:

```text
Group name: TST_BLUE_GND_FORTRESS_HIT_TARGET
Coalition: BLUE
Category: ground
Location: innerhalb bzw. unmittelbar am sichtbaren COP-Fortress-Testbereich
Start state: active
```

Der konkrete Unit-Typ ist für diesen Eventvertrag nicht fachlich relevant. Er muss lediglich echte DCS-`Hit`-Events überleben beziehungsweise in schneller Folge mindestens zwei Treffer empfangen können.

Zusätzlich wird ein RED-Angreifer benötigt, der dieses Ziel real beschießt. Der Angreifer darf AI oder vom Tester kontrolliert sein; für die Acceptance zählt ausschließlich, dass mindestens zwei reale RED-on-BLUE `EVENTS.Hit`-Ereignisse am registrierten Ziel eintreffen. Es ist keine bestimmte RED-Assetklasse Teil des Vertrags.

Keine Trigger-Explosion, kein künstlicher Event-Aufruf und kein Native-DCS-Testhandler ersetzt die realen Treffer.

## 4. Bundle

Builder:

```text
tools/build-fob-attack-hit-acceptance-1.ps1
```

Output:

```text
mission/tests/fob-attack-support-demand/dist/OMW_FOB_Attack_Hit_Acceptance_1.lua
```

Eingebettet werden:

```text
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_FobAttackDemandPolicy.lua
scripts/ground/OMW_FobAttackHitAdapter.lua
mission/tests/fob-attack-support-demand/src/01-fob-attack-hit-acceptance-1.lua
```

## 5. Runtime-Ablauf

Nach Laden des Bundles muss im `dcs.log` erscheinen:

```text
[OMW][FOB-ATTACK-HIT-ACCEPTANCE-1] READY
```

Nach dem ersten qualifizierten Treffer:

```text
QUALIFIED_HIT count=1
DEMAND_RESULT ... created=true reason=nil
```

Nach einem zweiten realen Treffer am selben Ziel, solange der erste Demand aktiv ist:

```text
QUALIFIED_HIT count=2
DEMAND_RESULT ... created=false reason=active_duplicate
```

Anschließend muss der Harness genau einen aktiven Demand bestätigen und ausgeben:

```text
PASS qualifiedHits=<n>=2 activeDemands=1 ... missionType=CAS_IMMEDIATE installationId=BLUE_GROUND_COP_FORTRESS
```

Der Listener wird nach PASS über MOOSE `UnHandleEvent` beendet.

## 6. PASS-Kriterien

Alle Kriterien müssen gleichzeitig erfüllt sein:

```text
1. Bundle lädt ohne Lua-/MOOSE-Fehler.
2. MOOSE EVENTS.Hit liefert mindestens zwei reale RED-on-BLUE Treffer am registrierten Testziel.
3. Beide Treffer werden als BLUE_GROUND_COP_FORTRESS qualifiziert.
4. Erster Treffer erzeugt genau einen CAS_IMMEDIATE Demand.
5. Zweiter Treffer erzeugt keinen zweiten Demand und liefert active_duplicate.
6. MissionDemand führt danach genau einen aktiven Demand für Fortress.
7. Kein CampaignState-Ressourcenbestand wird verändert.
8. Kein AUFTRAG/COMMANDER/AIRWING/SQUADRON-Dispatch wird ausgeführt.
9. Kein world.addEventHandler/MIST/MissionScripting.lua-Pfad wird verwendet.
10. dcs.log enthält den expliziten PASS-Eintrag.
```

## 7. Acceptance-Provenienz

Erst nach dem realen Lauf werden eingetragen:

```text
Git commit
BuilderVersion
Bundle SHA-256
MIZ filename
MIZ SHA-256
internal mission SHA-256, soweit nach Workflow erhoben
DCS version
MOOSE commit
Moose.lua SHA-256
dcs.log SHA-256
debrief.log SHA-256, soweit erzeugt
Result
```

Bis dahin bleibt dieser Stand `PLANNED` / `validated_in_dcs: false`.
