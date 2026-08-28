---
document_id: OMW-MOOSE-ALERT5-AIRWING-CAPABILITY-CONTRACT
status: PLANNED
document_class: TECHNICAL_SOURCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - source-verified ALERT5 recruitment prerequisites in the pinned MOOSE artifact
  - OMW AirOps test-harness rule for ALERT5 materialization
not_authoritative_for:
  - automatic production use of ALERT5 at every airbase
  - tactical alert policy
  - parking acceptance before DCS validation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/bagram-parking-policy-integration
source_commit: GIT_HISTORY
validated_in_dcs: false
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# ALERT5 – AIRWING/SQUADRON Capability Contract

## Zweck

Dieses Dokument hält eine wiederkehrende AirOps-Fehlerklasse zentral fest: `AUFTRAG:NewALERT5(...)` allein reicht nicht aus, um einen AIRWING-Stock-Asset zu materialisieren.

## Source-verifizierter Pfad

Der gepinnte MOOSE-Stand führt für einen AIRWING-Auftrag aus:

```text
LEGION:RecruitAssetsForMission(Mission)
-> LEGION.RecruitCohortAssets(
     Cohorts,
     Mission.type,
     Mission.alert5MissionType,
     ...)
```

Bei `AUFTRAG:NewALERT5(X)` gilt:

```text
Mission.type = AUFTRAG.Type.ALERT5
Mission.alert5MissionType = X
```

`LEGION.RecruitCohortAssets()` prüft zuerst:

```text
LEGION._CohortCan(cohort, MissionTypeRecruit, ...)
```

Damit muss der betreffende SQUADRON/COHORT `AUFTRAG.Type.ALERT5` als Mission-Capability besitzen. Anschließend werden Stock-Assets über `cohort:RecruitAssets(MissionTypeRecruit, ...)` rekrutiert; dafür muss ein geeigneter Payload für ALERT5 verfügbar sein.

Der gepinnte MOOSE-Source zeigt in seinen eigenen Beispielen dieselbe Doppelregistrierung:

```lua
Squadron:AddMissionCapability({ AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, ... })
Airwing:NewPayload(Template, -1, { AUFTRAG.Type.ALERT5, AUFTRAG.Type.CAP, ... }, 100)
```

Auch `EASYA2G` registriert ALERT5 sowohl am SQUADRON als auch am Payload.

## Verbindliche OMW-Prüfregel

Vor jedem OMW-AirOps-Test, der `AUFTRAG:NewALERT5(...)` zur physischen Materialisierung verwendet, ist explizit zu prüfen:

```text
1. SQUADRON kann AUFTRAG.Type.ALERT5.
2. Ein passender AIRWING-Payload kann AUFTRAG.Type.ALERT5.
3. Der Payload kann zusätzlich den vorgesehenen alert5MissionType, sofern dieser für Auswahl/Optimierung relevant ist.
4. Erst danach wird die ALERT5-Mission dem AIRWING hinzugefügt.
```

Fehlt Punkt 1 oder 2, ist das typische Laufbild:

```text
Mission queued
kein recruitbares Stock-Asset
kein OpsOnMission
keine Materialisierung
Timeout
```

Dieser Zustand darf nicht als Parking-, Warehouse- oder Spawn-Engine-Fehler fehlklassifiziert werden.

## Produktions- versus Test-Scope

ALERT5 darf nicht stillschweigend als Produktionsfähigkeit jeder SQUADRON hinzugefügt werden. Es gibt zwei zulässige Fälle:

```text
Produktiv:
  ALERT5 ist Teil der genehmigten AirOps-Architektur der SQUADRON.
  -> SQUADRON- und Payload-Capability produktiv registrieren.

Test-only:
  ALERT5 wird nur als kontrollierter MOOSE-Materialisierungspfad benötigt.
  -> Capability und Payload ausschließlich im Acceptance-Harness ergänzen.
```

Der Bagram-Parking-Retest verwendet ausdrücklich den zweiten Fall und verändert die produktive Bagram-Foundation nicht.

## Bagram-Evidenz 28.08.2026

Der erste finale Bagram-Parking-Materialisierungstest bestätigte vor dem Timeout:

```text
Parking propagation: 69/69 PASS
Runtime TerminalIDs: 187/187 PASS
Object contract: PASS
ALERT5 missions queued: 7/7
Materialized groups: 0
Final result: FAIL / TIMEOUT_120S
```

Der Harness hatte ALERT5 weder am SQUADRON noch am Payload ergänzt. Der Wiederholungstest korrigiert ausschließlich diese Harness-Voraussetzung.

## Review-Checkliste für künftige AirOps-Entwicklungen

```text
NewALERT5 used?                -> yes/no
SQUADRON ALERT5 capability?    -> verified
Payload ALERT5 capability?     -> verified
alert5MissionType capability?  -> verified
Assignment restricted?         -> verified if required
OpsOnMission observed?         -> required for positive dispatch proof
```

Diese Checkliste ist vor jedem neuen ALERT5-Acceptance-Lauf abzuarbeiten, damit dieselbe Fehlerklasse nicht an einem weiteren AirOps-Knoten erneut entsteht.
