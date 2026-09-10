---
document_id: OMW-HANDOFF-STAGE3-BUILD-1-17-CURRENT-STATE-2026-09-04
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local current state of Stage 3 Honaker/Wright/Jalalabad full-response work after Build 1-16 failure
  - exact known failure causes and Build 1-17 remediation
  - current offline regression coverage
  - next permitted verification sequence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
base_commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
pull_request: 144
supersedes:
  - OMW-HANDOFF-STAGE3-FIRE-SUPPORT-RESUPPLY-CURRENT-STATE-2026-09-01
superseded_by:
---

# Stage 3 Honaker / Wright / Jalalabad – vollständiger aktueller Stand nach Build 1-16

## 1. Status

Der Stage-3-Gesamtverbund ist weiterhin **nicht DCS-validiert**. Build 1-16 war ein realer Fehltest. Die drei im Lauf belegten Ursachen – Guard/QRF-Spawnlimit, CAS-Closure-Kopplung an Shot-Telemetrie und fehlende CH-47-Drop-Referenz im post-pickup Handoff – sind für Build 1-17 im Source korrigiert und durch zusätzliche Offline-Regressionen abgesichert. Ein neuer lokaler Build und ein neuer DCS-Lauf stehen noch aus.

## 2. Git-/PR-Provenienz

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch: agent/fire-support-strategic-resupply-alarm-evidence
Implementation/regression HEAD before current status-document commits:
  b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
Pull Request: #144
PR state: OPEN
PR mode: DRAFT
Base: agent/fire-support-strategic-resupply-closure
Base commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
Validated in DCS: false
```

Die nachfolgenden Dokumentationscommits liegen auf demselben Branch. Der exakte aktuelle Branch-HEAD wird absichtlich nicht selbstreferenziell in diese Datei geschrieben; vor lokalem Build ist er mit `git rev-parse HEAD` gegen den dann aktuellen Remote-Stand zu verifizieren.

GitHub-Checks auf dem Implementierungs-/Regression-HEAD `b7a3c1bdae45f9460053feee52cab7ffd09ef7f1`:

```text
Documentation validation #1547: PASS
MissionDemand validation #335: PASS
```

PR #144 bleibt DRAFT. Kein Ready-for-Review, kein Merge und keine technische Baseline ohne neuen exakten DCS-Nachweis und ausdrückliche Owner-Freigabe.

## 3. Governance und MOOSE-Provenienz

Maßgeblich:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Grundsatz für diesen Stand:

```text
MOOSE-first
CampaignState = strategische Autorität
MOOSE/DCS = physische Laufzeitrepräsentation
keine doppelte Ressourcenhoheit
keine erfundene API
VALIDATED nur nach exakter DCS-Provenienz
reproduzierbare Fehler zuerst offline regressionssichern
```

## 4. Verbindlicher Stage-3-Sollverbund

```text
RED attack at Honaker
-> MOOSE OPSZONE qualification
-> GroundInstallationAttackIncident
-> Guard
-> mixed QRF
-> AH-64D CAS
-> Wright L118 ARTY
-> local M1083 rearm
-> CampaignState AMMO 16 -> 15
-> exactly one strategic RESUPPLY
-> Jalalabad CH-47 external SlingLoad pickup
-> R500 outbound
-> Wright physical delivery
-> Wright 30/30
-> R500 reverse
-> Jalalabad landing / AIRWING recovery
```

## 5. Guard-Vertrag

```text
Template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Spawn/access zone: ZON_BLUE_GND_HONAKER_ACCESS
PATHLINE: OMW_RTE_BLUE_GUARD_HONAKER_01
Physical source: PLATOON under Honaker BRIGADE/WAREHOUSE
Routing: PATHLINE:GetCoordinates
         -> COORDINATE:WaypointGround
         -> GROUP:TaskFunction
         -> GROUP:SetTaskWaypoint
         -> GROUP:Route
Behavior: repeated circuit
```

`OMW_RTE_BLUE_GUARD_HONAKER_01` ist eine Mission-Editor-Linienzeichnung und MOOSE-PATHLINE, keine GROUP.

## 6. QRF-Vertrag

Owner-approved:

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
One DCS/MOOSE GROUP
5 infantry + 1 CHAP_MATV
No embark/disembark
5 GROUND_PERSONNEL reserved while deployed
Mission: AUFTRAG:NewONGUARD
Tactical area: 5 NM Honaker response area
Recovery: SetReturnToLegion(true) + AUFTRAG Cancel
Settlement: only on physical ARMYGROUP:Returned
```

Mission cancellation alone is not physical return and must not settle personnel.

## 7. CAS-Sollablauf

```text
1. CAS demand
2. AH-64D spawn Jalalabad
3. common-route entry
4. R500 outbound at 500 ft AGL
5. WEST outbound at 2500 ft AGL
6. leave WEST in AO
7. real CAS / S&D
8. tactical completion -> PATROLZONE closure immediately
9. rejoin WEST
10. WEST reverse at 2500 ft AGL
11. R500 reverse at 500 ft AGL
12. Jalalabad
13. land
14. AIRWING recovery
```

No direct initial AO shortcut and no fuel-triggered direct RTB is acceptable.

## 8. CH-47 Air-AMMO Sollablauf

```text
Pickup zone: ZON_BLUE_LOG_SLG_JALALABAD_01
Drop zone: OMW_BLUE_LZ_WRIGHT_01
Route: OMW_FlightPath_R500
```

```text
1. strategic RESUPPLY demand
2. CH-47 + external SlingLoad spawn
3. physical SlingLoad pickup first
4. only after pickup install R500 outbound
5. fly R500 to Wright-side exit
6. re-issue CargoTransportation for same cargo/drop zone
7. physical delivery
8. R500 reverse
9. Jalalabad landing
10. AIRWING recovery
```

Slingload spawn is at the exact ME pickup-zone center; automatic static repositioning is disabled.

## 9. Build 1-16 exact local provenance

Owner-supplied real build:

```text
GitCommit: 4a5b39bccbe80f597632f595a147afaa9ceadb36
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-16
TestId: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
GeneratedUtc: 2026-09-03T21:58:54Z
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Bundle SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
Independent SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
MizMutation: false
```

Build provenance was correct; runtime result was not.

## 10. Build 1-16 real DCS result

```text
Overall: FAIL
validated_in_dcs: false
DCS: 2.9.29.27468 MT
```

### Guard / QRF

Observed:

```text
No Guard materialized.
No QRF materialized.
```

Runtime evidence:

```text
Request denied! Not close enough to spawn zone. Distance = 200 m.
We need to be at least within 100 m range to spawn.
```

Cause in OMW source:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

This 100-m limit was an assistant implementation error, not an owner decision.

### CAS

Owner observation:

```text
- AH-64D flew R500 and WEST.
- It left WEST in the AO area.
- It then waited/extended far back toward Asadabad before attack.
- DCS-AI attack behavior itself was acceptable.
- After all RED targets were destroyed, the helicopter continued orbiting/loitering.
- It did not receive timely operational recovery.
- Later return appeared fuel/Bingo driven.
- Return was direct rather than WEST reverse -> R500 reverse.
- It did not safely make Jalalabad and crashed in/near the city on approach.
```

### CH-47

Owner observation:

```text
- Physical cargo transport occurred.
- Outbound flight was again direct line rather than R500.
- Return was again direct line rather than R500 reverse.
```

Runtime failure:

```text
CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
```

Therefore the intended post-pickup route chain was not installed and the original CARGOTRANSPORT direct routing remained active.

## 11. Build 1-17 Guard/QRF correction

Faulty:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

Pinned MOOSE source:

```lua
function WAREHOUSE:SetSpawnZone(zone, maxdist)
  self.spawnzone = zone
  self.spawnzonemaxdist = maxdist or 5000
  return self
end
```

Build 1-17:

```lua
state.brigade:SetSpawnZone(accessZone)
```

Resulting contract:

```text
same ME access zone
public MOOSE default max distance = 5000 m
no custom spawn algorithm
no native DCS spawn fallback
```

## 12. Build 1-17 CAS correction

Previous conceptual error:

```text
operational tactical closure depended additionally on state.casFired
```

Correct split:

```text
Operational:
zero living known incident participants
-> close incident
-> request PATROLZONE mission closure immediately
-> recovery route becomes authoritative

Acceptance:
EVENTS.Shot
-> remains required for final Stage-3 PASS
-> does not block RTB
```

Stage 3 CAS adapter now uses:

```lua
requireExecutionEvidence = false
```

`OMW_FobAttackCasPatrolClosure.lua` Schema 2 only enforces execution evidence when an adapter explicitly requires it.

## 13. CAS regression test

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
```

Primary regression case:

```text
PATROLZONE active
tacticalComplete = true
executionEvidenceConfirmed = false
requireExecutionEvidence = false
```

Required outcome:

```text
Cancel exactly once
closure = CLOSED
demand = SUCCESS
missing shot evidence recorded but does not block closure
```

Counter-case:

```text
requireExecutionEvidence = true
executionEvidenceConfirmed = false
-> EXECUTION_EVIDENCE_REQUIRED
-> no Cancel
-> demand stays ACTIVE
```

## 14. Build 1-17 CH-47 correction

Invalid prior assumption:

```text
mission.DCStask.params.cargo / zone / groupId / zoneId
would remain reliably available after pickup
```

Pinned MOOSE proves those fields at `AUFTRAG:NewCARGOTRANSPORT()` construction time, but Build 1-16 runtime disproved their reliable later availability for this handoff.

Authoritative runtime objects already available to Stage 3:

```text
state.cargo
ZONE:FindByName(OMW_BLUE_LZ_WRIGHT_01)
```

Build 1-17 passes them explicitly after confirmed pickup:

```lua
{
  cargo = state.cargo,
  dropZone = dropZone,
}
```

Handoff resolves:

```text
cargoId = cargo:GetID()
zoneId = dropZone.ZoneID
```

`mission.DCStask.params` is fallback only.

## 15. CH-47 regression test

```text
tests/mission-demand/test_slingload_corridor_handoff.lua
```

The test deliberately removes constructor-time references:

```lua
mission.DCStask = { params = {} }
```

Explicit context:

```text
cargo:GetID() = 7001
dropZone.ZoneID = 8002
```

Required outcome:

```text
handoff success
mode = APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF
referenceSource = EXPLICIT_ACCEPTANCE_CONTEXT
2 outbound waypoints
2 return waypoints
exactly one UpdateRoute()
CargoTransportation task recreated
groupId = 7001
zoneId = 8002
original cargo corridor not used for cargo mission
```

Non-cargo missions are also checked to delegate to the original corridor implementation.

## 16. Approved slingload exception boundary

Unchanged owner-approved narrow boundary:

```text
MOOSE CARGOTRANSPORT owns spawn/pickup/cargo identity/AIRWING lifecycle.
After confirmed physical pickup only:
  public MOOSE FLIGHTGROUP waypoint/task APIs build route.
At Wright-side exit:
  one DCS CargoTransportation waypoint task is re-issued for same cargo and drop zone.
After physical delivery:
  AUFTRAG:Success() returns ownership to normal MOOSE lifecycle.
```

Not allowed/added:

```text
raw Controller:setTask route ownership
native coalition spawning
teleport
parallel AIRWING implementation
parallel CampaignState ownership
```

## 17. Offline regression suite and CI

Both new tests are included in:

```text
tests/mission-demand/run.lua
```

Implementation/regression HEAD:

```text
b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
```

CI:

```text
Documentation validation #1547: PASS
MissionDemand validation #335: PASS
```

This proves the branch's offline contracts only. It does not prove DCS AI or CargoTransportation runtime behavior.

## 18. Relevant current files

```text
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundInstallationAttackIncident.lua
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
tests/mission-demand/test_slingload_corridor_handoff.lua
tests/mission-demand/run.lua
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
docs/moose/STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT.md
```

## 19. Known assistant implementation errors now recorded as regression boundaries

```text
1. SetSpawnZone(accessZone, 100)
   -> prevented Guard/QRF materialization.

2. Operational CAS closure tied to state.casFired
   -> acceptance telemetry could delay safe RTB.

3. Late reliance on mission.DCStask.params for CH-47 handoff
   -> post-pickup drop reference unavailable in real DCS run.

4. Earlier fixes were sent to DCS without dedicated offline regression for each reproduced error state
   -> caused avoidable repeated long DCS tests.
```

These are implementation errors, not owner decisions and not shared authorship decisions.

## 20. Still unproven for Build 1-17

There is not yet a real local Build-1-17 provenance. Missing:

```text
exact local HEAD after pull
BuilderVersion
GeneratedUtc
bundle SHA256
independent Get-FileHash SHA256
MizMutation result
```

There is not yet a Build-1-17 DCS runtime test.

Therefore:

```text
validated_in_dcs: false
```

## 21. Next DCS test – only after exact local build gate

### Guard

```text
materializes via ZON_BLUE_GND_HONAKER_ACCESS
no 100-m rejection
routes onto OMW_RTE_BLUE_GUARD_HONAKER_01
repeated patrol observable
```

### QRF

```text
TPL_BLUE_GND_QRF_MIXED_6 materializes
5 infantry + 1 CHAP_MATV remain one group
reacts to incident
ReturnToLegion requested after tactical completion
physical return occurs
PersonnelLedger settlement occurs only on Returned
```

### CAS

```text
Jalalabad -> R500 -> WEST -> AO
actual weapon employment
tactical completion releases PATROLZONE promptly
no loiter until fuel/Bingo
WEST reverse -> R500 reverse
no direct RTB shortcut
safe Jalalabad landing and AIRWING recovery
```

### CH-47

```text
physical SlingLoad pickup first
no CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
R500 outbound physically flown
CargoTransportation task resumes at Wright-side route exit
physical delivery
R500 reverse physically flown
no direct return shortcut
Jalalabad landing / AIRWING recovery
```

### Strategic chain

```text
Wright 16 -> 15 after local rearm
one strategic RESUPPLY only
semantic duplicate suppression
physical delivery restores Wright 30/30
source stock reaches expected final state
```

### Performance

```text
no severe post-combat/RTB main-thread degradation
no endless post-task orbit/recovery loop
no unnecessary scheduler left running after completion
```

## 22. What DCS alone must still decide

Offline tests cannot prove:

```text
DCS helicopter path execution through terrain
AI behavior leaving/returning to WEST
priority between recovery waypoints and DCS fuel logic
actual Jalalabad landing path
DCS acceptance of post-pickup CargoTransportation waypoint task
physical external-load continuity through handoff
actual reverse-route execution after physical delivery
```

Those are the legitimate reasons for the next DCS acceptance run.

## 23. Development gate from now on

```text
reproducible failure
-> MOOSE/source review
-> offline regression
-> CI PASS
-> remote commit
-> owner git pull
-> exact local build
-> independent hash
-> provenance verification
-> only then DCS
```

No further 30-minute DCS run should be used to discover a condition already reproducible in Lua/unit-level state.

## 24. Handoff instruction

```text
Continue OMW Stage 3 on branch agent/fire-support-strategic-resupply-alarm-evidence.
Read AGENTS.md, docs/00-project-governance.md, docs/26-moose-first-development-policy.md,
docs/moose/STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT.md and
this handoff before changes.
PR #144 remains OPEN/DRAFT and validated_in_dcs=false.
Implementation/regression HEAD b7a3c1bdae45f9460053feee52cab7ffd09ef7f1 has PASS for Documentation validation #1547 and MissionDemand validation #335.
Later commits are documentation-only; obtain the current branch HEAD before local build.
Build 1-16 failed because of assistant-authored 100-m Ground spawn limit, CAS tactical closure tied to shot telemetry, and CH-47 post-pickup CARGOTRANSPORT reference loss.
Build 1-17 source fixes all three and adds dedicated offline regressions for the CAS and CH-47 failure states.
Do not request another DCS run until exact local Build-1-17 provenance and independent bundle SHA256 are supplied and checked.
```
