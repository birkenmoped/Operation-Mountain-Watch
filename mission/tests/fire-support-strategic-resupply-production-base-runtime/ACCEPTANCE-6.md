---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-6
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - compact production Base command-chain validation
  - runtime C2 CAS provider selection without Acceptance provider hardcoding
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - rejected Stage 3 Acceptance 2 as a provider-selection test
superseded_by:
---

# Production Base Acceptance 6 - C2 Provider Selection

## Ziel

Dieser Lauf kehrt zum eigentlichen fire-support-strategic-resupply_base-Ziel zurueck. Er prueft keine historische Honaker-End-to-End-Fixture und keinen strategischen Resupply.

Die zu pruefende Kette ist:

```text
physical RED attack at FOB Joyce
-> production MOOSE perimeter
-> authoritative installation incident
-> production QRF
-> concrete incident UNIT engagement

same incident
-> explicit C2 CAS escalation
-> Base:RequestIncidentSupport(..., CAS)
-> ExternalSupportRuntime
-> CommanderBridge
-> MOOSE COMMANDER
-> MOOSE selects/recruits provider and operational CAS asset
-> OPSGROUP on mission
```

## Warum Joyce

FOB_JOYCE ist im aktuellen SiteRegistry fuer localSupport mit NOT_ESTABLISHED_BY_CURRENT_BASELINE gekennzeichnet. Damit vermeiden wir die bekannte Honaker-Regression, bei der lokale autonome Feuerunterstuetzung die RED-Fixture vor der eigentlichen Acceptance vernichtete.

Die RED-Fixture BadGuys_A3_JOYCE wird nur aktiviert. Die Acceptance schreibt ihre Mission-Editor-Route nicht um.

## C2-Pool

Die Acceptance nennt keinen Provider und keinen Flugzeugtyp.

Sie liest ausschliesslich die bereits laufenden OMW-AirOps-Grundknoten aus:

```text
OMW.AirOps
-> every node with Status == RUNNING
-> Airwing / Airwings
-> COMMANDER:AddAirwing(...)
```

Vor Testbeginn muessen mindestens zwei unterschiedliche laufende AIRWINGs mit einer CAS-faehigen Cohort vorhanden sein. Die Diagnose verwendet den gepinnten MOOSE-Vertrag AUFTRAG.CheckMissionCapability(AUFTRAG.Type.CAS, cohort.missiontypes).

Verboten in dieser Acceptance:

```text
hardcoded Jalalabad/Bagram/Kandahar/Salerno/Tarinkot/Shindand provider
hardcoded AH-64/A-10/F-15/F-16 selection
specialLegions / specialCohorts
AIRWING:AddMission()
SQUADRON binding
Acceptance-owned asset choice
Stage-3 CAS corridor
strategic resupply
ARTY provider binding
```

## CAS-Geometrie

Die Acceptance erzeugt nur die fuer AUFTRAG:NewCAS() erforderliche taktische Testzone um die aktuelle physische RED-Fixture. Diese Zone ist ausdruecklich Testgeometrie fuer die Provider-Auswahl:

```text
CAS test zone != alarm perimeter
CAS test zone != production tactical doctrine
```

Es werden keine Ingress-/Egress-Wegpunkte, keine Corridors und keine Providerparameter gesetzt.

## PASS

PASS erfordert positive Runtime-Evidenz fuer:

```text
1. physical Joyce RED fixture activates on existing ME route
2. production perimeter qualifies the attack
3. authoritative installation incident exists
4. production QRF reaches ARMYGROUP:OnAfterEngageTarget against a concrete incident target
5. exactly one CAS escalation is requested through Base:RequestIncidentSupport()
6. at least two CAS-capable running AIRWING candidates were registered with COMMANDER
7. COMMANDER OnAfterMissionAssign identifies the provider selected by MOOSE
8. COMMANDER OnAfterOpsOnMission confirms a physical CAS OPSGROUP on mission
9. Acceptance contains no AIRWING/SQUADRON/provider/aircraft selection
```

Nicht Bestandteil dieses Runs:

```text
CAS weapon employment
CAS route doctrine
CAS RTB
ARTY
rearm
strategic resupply
CampaignState delivery settlement
```

Diese Begrenzung ist absichtlich. Erst die Befehls-/Auswahlkette wird positiv bewiesen; danach werden weitere Ausfuehrungspfade auf derselben Base ergaenzt.

## Timeout

Der Test wartet maximal 600 Sekunden nach Aktivierung der RED-Fixture. Damit wird ein weiterer 30-Minuten-Lauf ohne Provider-Auswahl-Evidenz ausgeschlossen.
