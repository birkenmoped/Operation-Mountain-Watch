---
document_id: OMW-STAGE-2-FOB-ATTACK-SUPPORT-DEMAND
status: PLANNED
document_class: DOMAIN_AND_MOOSE_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 2 qualified FOB/COP attack to MissionDemand contract
  - separation of attack qualification from MissionDemand creation
  - active-demand dedupe boundary for repeated attack evidence
not_authoritative_for:
  - DCS runtime acceptance of MOOSE Hit event qualification
  - CAS aircraft dispatch or BLUE COMMANDER execution
  - final attack severity or priority classification
  - arbitrary time-based attack cooldowns
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 2 – FOB/COP attacked -> support demand

## 1. Scope

Stage 1D-V ist durch die Owner-Entscheidung `OMW-ARMY-GROUND-VEHICLE-REPLENISHMENT-DECISION` geschlossen. Der nächste Automatic-Response-Scope ist damit:

```text
qualified BLUE FOB/COP attack incident
-> MissionDemand CAS_IMMEDIATE
```

Stage 2 erzeugt **noch keinen** MOOSE-CAS-Auftrag und disponiert kein Flugzeug. Der spätere BLUE/CAS-Adapter bleibt ein eigener Entwicklungsschritt.

## 2. Bestehende MissionDemand-Baseline

`scripts/campaign/OMW_MissionDemand.lua` besitzt bereits:

```text
MissionDemand.Type.CAS_IMMEDIATE
MissionDemand Registry:Create(...)
activeByDedupeKey
idempotent_existing
active_duplicate
terminal release of dedupeKey
snapshot/restore of active demands
```

Daher wird kein zweites Support-Request-Register und kein paralleler CAS-Lifecycle eingeführt.

Der neue Domain-Adapter liegt in:

```text
scripts/campaign/OMW_FobAttackDemandPolicy.lua
```

Er besitzt keine MOOSE-/DCS-Abhängigkeit und nimmt nur einen **bereits qualifizierten** Angriffsvorfall entgegen.

## 3. Qualifizierter Incident-Vertrag

Stage 2 setzt für die Domain-Grenze mindestens voraus:

```text
incidentId       stable, non-empty
installationId   stable CampaignState installation ID
priority         finite number supplied by the incident classifier
```

Optional dürfen operative Hinweise mitgeführt werden:

```text
position
reportedTarget
```

Die Policy erfindet bewusst keine Prioritätszahl und keinen Schweregrad. Diese Klassifikation gehört zur späteren Incident-Qualification und benötigt einen eigenen fachlichen beziehungsweise Runtime-Vertrag.

## 4. Dedupe ohne erfundenen Timer

Ein einzelner Treffer darf nicht eine eigene CAS-Mission erzeugen.

Die Stage-2-Policy verwendet deshalb zwei bestehende MissionDemand-Mechanismen:

```text
same incidentId
-> same MissionDemand id
-> idempotent_existing

new incidentId at same installation while CAS demand nonterminal
-> same installation dedupeKey
-> active_duplicate
```

Dedupe-Key:

```text
CAS_IMMEDIATE|FOB_ATTACK|<installationId>
```

Wenn der bestehende Demand terminal ist, gibt MissionDemand den Dedupe-Key frei. Erst dann kann ein neuer qualifizierter Incident an derselben Installation einen neuen Demand erzeugen.

Damit wird **kein** willkürlicher 5-/10-/15-Minuten-Cooldown eingeführt.

## 5. Demand-Spezifikation

Ein qualifizierter Incident erzeugt:

```text
missionType       CAS_IMMEDIATE
origin            attacked installationId
objective         Defend attacked BLUE Ground installation
playerCapable     true
aiCapable         true
reservationState  NOT_APPLICABLE
createdReason     FOB_ATTACK_QUALIFIED
resourceReservation nil
```

Das strategische Ressourcenledger bleibt unberührt. Der Demand beschreibt Unterstützungsbedarf, keine neue Ressource.

## 6. MOOSE-first: Event-Erfassung

Der bereits auf `main` vorhandene Source-Review `OMW-MOOSE-MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW` hat für den gepinnten MOOSE-Stand bestätigt:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der tatsächlich verwendete `Moose.lua` enthält den öffentlichen Event-Pfad für `EVENTS.Hit`. Die Eventdaten führen unter anderem Initiator-/Target-Felder wie:

```text
IniCoalition
TgtCoalition
TgtUnitName
TgtGroupName
TgtUnit
TgtGroup
```

Folgerung:

```text
MOOSE Hit event
-> OMW adapter resolves target to known BLUE runtime/installation mapping
-> hostile/valid event qualification
-> stable incidentId
-> OMW_FobAttackDemandPolicy
-> MissionDemand CAS_IMMEDIATE
```

Für diesen Standardfall wird kein paralleles `world.addEventHandler` geplant.

## 7. Was Stage 2 bewusst noch nicht behauptet

Dieser Commit validiert **nicht**:

```text
- dass jeder EVENTS.Hit ein strategischer FOB/COP-Angriff ist;
- welche Units/Statics innerhalb einer Installation den Trigger tragen;
- wie die Attack-Priorität aus Art, Anzahl oder Dauer der Angriffe berechnet wird;
- wie ein MOOSE EventData-Target in jeder DCS-Situation aussieht;
- dass CAS tatsächlich dispatched oder erfolgreich geflogen wird;
- einen festen Attack-Cooldown.
```

Die DCS-seitige Hit-Qualification benötigt einen gezielten Acceptance-Lauf. CAS-Execution bleibt beim späteren BLUE/CAS-Automatic-Response-Adapter.

## 8. Contract-Test

`tests/mission-demand/test_fob_attack_demand_policy.lua` prüft mindestens:

```text
qualified incident -> CAS_IMMEDIATE OPEN demand
same incident -> idempotent
second incident same site while active -> active_duplicate
different site -> parallel demand allowed
terminal demand -> new incident at same site allowed
missing/invalid required incident fields -> rejected
```

Die Tests laufen über die bestehende `MissionDemand validation` GitHub Action.

## 9. Nächster Stage-2-Schritt

Nach erfolgreichem Domain-/CI-Gate folgt als kleinster MOOSE-first Runtime-Slice:

```text
one explicitly registered BLUE installation target set
-> MOOSE EVENTS.Hit
-> qualification adapter
-> stable test incident
-> CAS_IMMEDIATE MissionDemand
-> repeated hit does not create second active demand
```

Dieser nächste Slice benötigt einen dokumentierten DCS-Acceptance-Lauf, bevor der MOOSE-Hit-Adapter als `VALIDATED_FOR_DOCUMENTED_SCOPE` geführt werden darf.
