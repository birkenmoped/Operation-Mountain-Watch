---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION-CURRENT-STATUS
status: DRAFT
document_class: PROJECT_STATUS_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local current implementation status of agent/air-tasking-plan-foundation
  - branch-local mapping of completed and open items against the Air Tasking Plan foundation manifest
  - branch-local merge-readiness assessment
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - final owner decision to merge the branch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Aktueller Stand

## 1. Referenzstand

```text
branch: agent/air-tasking-plan-foundation
phase 0: PASS
phase 1: PASS
phase 2: PASS
phase 3: IN PROGRESS
validated_in_dcs for Phase 3: false
```

Die lokale/remote Branch-Synchronisation ist geklärt. Bekannte lokale untracked Build-/Testartefakte bleiben unangetastet. Vor einem Merge nach `main` bleibt eine erneute Reconciliation gegen den dann aktuellen `main`-Stand erforderlich.

## 2. Gesamtstatus

```text
PHASE 0  Governance / Reconciliation / Contracts          PASS
PHASE 1  Domain Data Model                               PASS
PHASE 2  MOOSE-First Capability Verification            PASS
PHASE 3  First Vertical Integration – AAR                IN PROGRESS
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

Die PASS-Werte für Phase 0 bis 2 sind branch-lokal. Phase 3 hat Adapter-/Bootstrap-Code, Build-Evidenz und einen vorbereiteten DCS-Acceptance-Pfad, aber noch keinen DCS-Runtime-PASS.

## 3. Tatsächlich geprüfte MOOSE-/Missionsbaseline

Die vom Projektinhaber am 18.08.2026 bereitgestellte aktuelle Mission wurde ausschließlich lesend geprüft:

```text
mission artifact: OMW_Template_v12_groundworks(2).miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
MOOSE context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
existing AAR resource: l10n/DEFAULT/OMW_AAR_Base.lua
existing resource key: ResKey_Action_235
trigger comment: LOAD_AAR_BASE
trigger precondition: time > 5 and OMW_WAREHOUSE_READY == 1
```

`l10n/DEFAULT/mapResource` ordnet `ResKey_Action_235` bereits `OMW_AAR_Base.lua` zu. Diese Prüfung dient ausschließlich der Vorbereitung des manuellen Mission-Editor-Einfügens; ChatGPT verändert keine `.miz`-Datei.

## 4. Phase 0 / 1

Unverändert abgeschlossen:

```text
CampaignState
= strategische Zustands-/Ressourcenautorität

MissionDemand
= autoritative kampagnenweite Bedarfsidentität

Air Tasking Domain
= Request-/Mission-/Planungs-/Authority-/Persistenzmodell

MOOSE
= operative Capability-/Asset-/Missionsausführung innerhalb der OMW-Grenzen
```

Stabile Request-, Mission-, Relationship- und Execution-IDs bleiben von DCS-/MOOSE-Runtimeobjekten getrennt.

## 5. Phase 2 – abgeschlossen

```text
[x] pinned MOOSE branch/commit/hash
[x] CHIEF APIs / Verantwortungsgrenzen
[x] COMMANDER APIs
[x] AIRWING / BRIGADE APIs
[x] SQUADRON / PLATOON APIs
[x] AUFTRAG-Konstruktion und Missionstypen
[x] Mission Assignment / Lifecycle / FSM-Callbacks
[x] FLIGHTGROUP / ARMYGROUP / OPSGROUP Status-/Lifecycle-Anbindung
[x] offizielle Beispiele für tatsächlich benötigte Kombinationen
[x] Authority-/Allocation-Fälle gegen native MOOSE-Fähigkeiten
[x] finale OMW-Planungsdaten-vs.-MOOSE-Adaptergrenze
[x] PROJECT-CLASS-INDEX / thematische MOOSE-Dokumentation nachpflegen
[x] keine source-only Methode als neu DCS-VALIDATED markieren
```

Gate:

```text
GATE 2: PASS
scope: MOOSE-first source / official-example / architecture verification
validated_in_dcs: false
```

## 6. Phase 3 – aktueller Implementierungsstand

Die aktuelle `main`-AAR-Baseline und Acceptance-7-Provenienz wurden erneut geprüft. Der bestehende Controller-/CampaignState-Pfad wird weiterverwendet und nicht ersetzt.

Neu auf dem Branch:

```text
scripts/air-operations/OMW_AirTasking_AARBridge.lua
scripts/air-operations/OMW_AirTasking_AARBootstrap.lua
tools/build-air-tasking-aar-vertical-base.ps1
tools/build-air-tasking-aar-vertical-acceptance.ps1
tools/build-air-tasking-aar-vertical-test-lua.ps1
mission/tests/air-tasking-aar-vertical/
```

Der zuvor angelegte `.miz`-Mutationsbuilder wurde entfernt. Der zulässige lokale Workflow erzeugt ausschließlich die Lua-Datei `OMW_AAR_Base.lua`, die der Projektinhaber anschließend selbst im DCS Mission Editor in die bestehende Mission einfügt.

Vertikaler Pfad:

```text
MissionDemand
-> approved AIR_SUPPORT_REQUEST
-> AIR_TASKING_MISSION
-> existing AAR Controller.SelectArea / SubmitDemand / EndDemand
-> existing AAR CampaignState adapter
-> stable EXECUTION_ATTEMPT correlation
-> existing MOOSE SPAWN / FLIGHTGROUP / AUFTRAG lifecycle
```

Die Air-Tasking-Schicht erzeugt keine zweite Tanker-Ressourcenhoheit und berechnet Area/Profile/MissionDemand nicht erneut. `ATM-*`/`EXE-*` bleiben von AAR-runtimeId und MOOSE-/DCS-Objekten getrennt.

## 7. Lokal bestätigte Build-Evidenz

Der Projektinhaber hat am 18.08.2026 auf Commit

```text
3aea46a1cbfa1f62136bd932f0f48e67d332d680
```

den Vertical-Base- und Acceptance-Build erfolgreich ausgeführt.

Reale Hashes:

```text
Vertical Base Bundle:
87ba3dcae93c242090502d6176ff6e0308ada7392e6e78578862fadf55c4a17a

Acceptance Harness:
fa6432d20aa17cd3af3aa006f4030f6dbbe6d6c9d585e6fbd81e645de6e32006

Acceptance Bundle:
42bb4846be27ae2cff4d6f2634ebca6ff7d0628de7541071bb38ff2d940e7079
```

Der vorgeschaltete AAR-Produktionsgate meldete `PASS`. Dies ist Build-/Source-Gate-Evidenz und kein DCS-Runtime-PASS.

## 8. Offene Phase-3-Grenze

Der nächste reale Schritt ist der lokale Build der einzufügenden Lua-Datei und danach die manuelle Einfügung durch den Projektinhaber in die bestehende `.miz`.

```text
ChatGPT mutiert keine .miz-Datei.
ChatGPT erzeugt keinen .miz-Builder.
Der Projektinhaber führt den lokalen Lua-Builder aus.
Der Projektinhaber fügt OMW_AAR_Base.lua selbst im Mission Editor in die bestehende Ressource ResKey_Action_235 ein.
Die Quellmission bleibt bis zu dieser manuellen Aktion unverändert.
```

Vor dem DCS-Lauf müssen mindestens vorliegen:

```text
GitCommit
AcceptanceBundleSHA256
InsertLuaSHA256
Mission SHA-256 nach manueller Mission-Editor-Aktualisierung
Moose.lua SHA-256 der getesteten Mission
```

## 9. DCS-Acceptance-Ziel

Der vorbereitete Testfall verwendet einen einzelnen Reserve-Bedarf für LISA:

```text
MD-000001
-> ASR-000001 APPROVED
-> ATM-000001 AAR
-> WEST / FAST / SUPPORT
-> LISA / AL_UDEID / DAVER
-> EXE-* correlation
-> natural FIR ingress
-> natural 60-NM late approach
-> natural LISA track arrival
-> EndAAR(COMPLETE)
-> FIR egress
-> external handoff
-> exact-once CampaignState recredit
-> ATM COMPLETED
-> ASR FULFILLED
```

Gate 3 bleibt offen, bis dieser Pfad mit vollständiger Mission-/Bundle-/DCS-/MOOSE-Provenienz real in DCS bestätigt ist.

## 10. Merge-Readiness

```text
MERGE TO MAIN NOW: NOT YET RECOMMENDED
```

Vor Integration noch erforderlich:

```text
Gate-3 DCS vertical acceptance
current-main reconciliation
full branch diff review
document metadata / registry / provenance review
documentation validator
owner merge decision
```

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulässig, darf aber nicht unverändert auf `main` verbleiben.
