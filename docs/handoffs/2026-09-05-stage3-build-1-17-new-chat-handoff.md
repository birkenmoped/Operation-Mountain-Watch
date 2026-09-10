---
document_id: OMW-HANDOFF-STAGE3-BUILD-1-17-NEW-CHAT-2026-09-05
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local new-chat handoff for Stage 3 Honaker/Wright/Jalalabad full-response work
  - exact current failure history, remediation state, test gates, and continuation instructions
  - current main/branch divergence warning before further work
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
base_commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
pull_request: 144
supersedes:
  - OMW-HANDOFF-STAGE3-BUILD-1-17-CURRENT-STATE-2026-09-04
superseded_by:
---

# Vollumfängliche Übergabe – Stage 3 Honaker / Wright / Jalalabad – 05.09.2026

## 1. Zweck dieser Übergabe

Diese Datei ist die vollständige Übergabe des aktuell offenen Arbeitsstands für einen neuen Chat. Sie soll verhindern, dass frühere Fehlannahmen, veraltete Build-Stände oder branchfremde Baselines erneut als aktuell behandelt werden.

Der neue Chat soll **nicht** aus früheren Gesprächserinnerungen weiterarbeiten, sondern zuerst die in dieser Datei genannten Projektdateien und den aktuellen GitHub-Stand prüfen.

Der Stage-3-Gesamtverbund ist weiterhin:

```text
PLANNED / validated_in_dcs=false
```

Build 1-16 war ein realer DCS-Fehltest. Build 1-17 ist source-seitig vorbereitet und offline regressionsgesichert, aber noch nicht lokal gebaut und noch nicht in DCS getestet.

## 2. Sofort zu prüfender Git-/PR-Stand

Repository:

```text
birkenmoped/Operation-Mountain-Watch
```

Arbeitsbranch:

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

Branch-HEAD unmittelbar vor Erstellung dieser Übergabe:

```text
c7cca4c453b5f06259479e98682bff65638a90d3
```

Dieser SHA ist nur der dokumentierte Ausgangspunkt vor dem Handoff-Commit. Vor jeder Fortsetzung ist der reale aktuelle Remote-HEAD erneut zu lesen.

Pull Request:

```text
#144
state: OPEN
mode: DRAFT
base: agent/fire-support-strategic-resupply-closure
base commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
```

Der PR darf nicht auf Ready for Review gesetzt und nicht gemergt werden, bevor ein erfolgreicher exakter DCS-Acceptance-Lauf vorliegt und der Projektinhaber dies ausdrücklich freigibt.

## 3. Aktueller main-Stand und Divergenz – vor jeder weiteren Arbeit beachten

Am 05.09.2026 wurde `main` erneut geprüft.

Aktueller `main`-HEAD:

```text
a4a99a384e6c4ee9297226af6f0a0dd697ecc4e6
```

GitHub-Compare zwischen Arbeitsbranch und `main` meldet:

```text
status: diverged
merge base: 10789637d009a664a6e65b633d3df8a35f8d5117
main has 11 commits not on this branch
this branch has 174 commits not on main
```

Unter den seit der Divergenz auf `main` veränderten bzw. hinzugekommenen relevanten Dateien befinden sich:

```text
docs/00-project-governance.md
docs/45-air-c2-cas-afghanistan.md
docs/77-arsof-sof-aviation-and-early-oef-operational-models.md
docs/ground/ARMY-GROUND-INSTALLATION-ALARM-MULTI-EVIDENCE-DECISION.md
```

Folgerung für den neuen Chat:

```text
Vor weiterer Implementierung zuerst aktuellen main-Stand gegen den Arbeitsbranch prüfen.
Nicht blind rebasen oder mergen.
Keine neue Architekturentscheidung aus einem alten branchlokalen Dokument ableiten, wenn main inzwischen eine neuere BINDING/BINDING_PROJECT_DECISION enthält.
```

## 4. Verbindliche Governance

Vor jeder relevanten Änderung mindestens lesen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Zusätzlich für diesen Stage-3-Stand:

```text
docs/handoffs/2026-09-05-stage3-build-1-17-new-chat-handoff.md
docs/moose/STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-09-03-BUILD-1-15-ROUTE-CHAIN.md
```

Bei Widersprüchen gilt ausschließlich die Hierarchie aus `docs/00-project-governance.md`.

Wichtige Arbeitsregeln:

```text
MOOSE-first.
Keine MIST-Einführung ohne genehmigte Ausnahme.
CampaignState ist strategische Ressourcenautorität.
MOOSE/DCS bilden die physische Laufzeitrepräsentation.
Keine doppelte Ressourcenhoheit.
Keine MOOSE-API erfinden.
Dokumentation allein beweist keine Verfügbarkeit; gepinnte Moose.lua ist maßgeblich.
VALIDATED nur nach exaktem DCS-Test.
Keine .miz automatisch mutieren.
Keine MissionScripting.lua automatisch ändern.
Keine Teleports/Spawns/Despawns in beobachtbaren Situationen.
Keine unnötigen High-Frequency-Scheduler oder Frame-Scans.
```

## 5. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Dieser Stand ist für alle hier beschriebenen MOOSE-Signaturen, Events und Lifecycle-Aussagen maßgeblich.

## 6. Entwicklungsziel – vollständiger Stage-3-Verbund

Der zu validierende Gesamtverbund lautet:

```text
RED attack at Honaker
-> MOOSE OPSZONE qualification
-> GroundInstallationAttackIncident
-> Guard response
-> mixed QRF response
-> AH-64D CAS
-> Wright L118 ARTY
-> local M1083 rearm
-> CampaignState Wright AMMO 16 -> 15
-> exactly one strategic RESUPPLY
-> Jalalabad CH-47 external SlingLoad
-> physical pickup
-> R500 outbound
-> Wright physical delivery
-> Wright 30/30
-> R500 reverse
-> Jalalabad landing / AIRWING recovery
```

Der Gesamtstatus bleibt FAIL, solange irgendein physischer Pflichtabschnitt nicht real nachgewiesen ist.

## 7. Owner-required CAS-Vertrag

Der Projektinhaber hat für CAS den physischen Ablauf eindeutig vorgegeben:

```text
1. CAS request.
2. AH-64D spawn at Jalalabad.
3. Fly to beginning of common route.
4. Follow R500 / common route.
5. Turn onto Route WEST.
6. Follow WEST toward AO.
7. Leave WEST near AO.
8. Execute real CAS / search-and-destroy against the incident targets.
9. When the incident is tactically complete, terminate the CAS/PATROLZONE mission promptly.
10. Rejoin WEST near AO.
11. Fly WEST reverse.
12. Fly R500/common route reverse.
13. Return to Jalalabad.
14. Land.
15. AIRWING recovery / mission complete.
```

Altitude contract currently encoded for Stage 3:

```text
R500: 500 ft AGL
WEST: 2500 ft AGL
```

Nicht akzeptabel:

```text
direct initial Jalalabad -> AO shortcut
direct fuel/Bingo RTB outside WEST/R500 recovery
loiter until fuel/Bingo after all incident targets are dead
```

## 8. Owner-required CH-47 Air-AMMO-Vertrag

```text
1. Strategic RESUPPLY request.
2. CH-47 and external SlingLoad spawn.
3. CH-47 physically picks up SlingLoad first.
4. Only after pickup: route handoff begins.
5. Fly R500 outbound.
6. Leave R500 at Wright-side exit.
7. Re-issue CargoTransportation for same physical cargo and Wright drop zone.
8. Deliver SlingLoad physically.
9. Rejoin R500.
10. Fly R500 reverse.
11. Land at Jalalabad.
12. AIRWING recovery / mission complete.
```

Pickup zone:

```text
ZON_BLUE_LOG_SLG_JALALABAD_01
```

Drop zone:

```text
OMW_BLUE_LZ_WRIGHT_01
```

Die Außenlast wird am exakten Mission-Editor-Zonenmittelpunkt erzeugt. Die frühere automatische Repositionierung um bis zu 120 m ist entfernt.

## 9. Logistik-Marker-/Zonen-Namensschema – Owner-Entscheidung

Für künftige blaue Airports/Heliports ist die physische Frachtbereitstellung zu trennen:

```text
ZON_BLUE_LOG_SLG_<LOCATION>_01
```

für externe Slingloads mit notwendiger Freifläche.

Separat vorgesehen:

```text
ZON_BLUE_LOG_ACG_<LOCATION>_01
```

für normale Air Cargo wie Paletten, Kisten und Fahrzeuge, z. B. für C-130J oder ggf. interne CH-47-Fracht.

Optional für späteren Airdrop getrennt:

```text
ZON_BLUE_LOG_ADZ_<LOCATION>_01
```

`SLG` und `ACG` sollen räumlich nicht automatisch identisch sein.

Aktuell Stage-3-implementiert ist nur:

```text
ZON_BLUE_LOG_SLG_JALALABAD_01
```

ACG/ADZ sind noch kein implementierter Stage-3-Runtime-Vertrag.

## 10. Guard-Vertrag

Guard source/template:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Physical source:

```text
PLATOON under Honaker BRIGADE/WAREHOUSE
```

Spawn/access zone:

```text
ZON_BLUE_GND_HONAKER_ACCESS
```

Patrol PATHLINE:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
```

Wichtig:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01 is a Mission Editor line drawing / MOOSE PATHLINE, not a GROUP.
```

MOOSE-first route construction:

```text
PATHLINE:FindByName
-> PATHLINE:GetCoordinates
-> COORDINATE:WaypointGround
-> GROUP:TaskFunction / GROUP:SetTaskWaypoint
-> GROUP:Route
-> repeated patrol circuit
```

Ground pathfinding bleibt DCS-seitig unsicher; die Access-Zone soll verhindern, dass die Guard erst aus dem ummauerten COP herauspathfinden muss.

## 11. QRF-Vertrag

Owner-approved composition:

```text
TPL_BLUE_GND_QRF_MIXED_6
one DCS/MOOSE GROUP
5 infantry + 1 CHAP_MATV
no embark/disembark
5 GROUND_PERSONNEL reserved while deployed
```

Mission/Lifecycle:

```text
AUFTRAG:NewONGUARD
SetReturnToLegion(true)
incident/tactical completion -> mission Cancel
physical ARMYGROUP:Returned -> PersonnelLedger settlement
```

Wichtig:

```text
AUFTRAG Cancel != physical return.
Personnel may only be settled after ARMYGROUP:Returned.
```

## 12. Strategische Ressourcen-/Fire-Support-Kette

Bereits in früheren exakten DCS-Läufen beobachtet, aber für Build 1-17 erneut im Gesamtverbund zu prüfen:

```text
Wright L118 ARTY fires.
M1083 performs local rearm.
CampaignState Wright ammo drops 16 -> 15.
Reorder threshold triggers exactly one strategic RESUPPLY.
Jalalabad physical air delivery restores Wright to 30/30.
No duplicate strategic RESUPPLY.
```

CampaignState bleibt strategische Autorität. Physische MOOSE/DCS-Aktionen dürfen keinen zweiten unabhängigen Bestand erzeugen.

## 13. Historischer Build-1-13-Stand – wichtige Vergleichsbasis

Build 1-13 exact DCS provenance:

```text
Git commit: 08cebb9835936b30079ce0b387864f2bf44bad52
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-13
Bundle SHA256: 9C0C425E52C0E5B0E4E9941C6FE568FAD855C85BB8920F70DC38C6221861AE61
MizMutation: false
DCS: 2.9.29.27468 MT
```

Observed partial successes:

```text
Guard physical materialization
QRF physical materialization
Wright ARTY
M1083 local rearm
CampaignState 16 -> 15
exactly one strategic RESUPPLY
CH-47 physical pickup/delivery
Wright 30/30
CH-47 return/AIRWING recovery
AH-64 physical weapons employment
```

But overall FAIL because CAS/CH-47 route order and QRF return/recovery were wrong and severe post-combat/return performance degradation occurred.

This old run is evidence only for its exact provenance, not for current Build 1-17.

## 14. Build 1-15 failure – why architecture was simplified

Build 1-15 still used a complicated dynamic route/lifecycle model. Real DCS observation showed:

```text
AH-64 ingress via route/WEST worked.
After all relevant targets were gone, AH-64 continued large loops.
Fuel/Bingo later caused direct RTB behavior.
Aircraft did not safely make Jalalabad.
CH-47 pickup/delivery worked physically but outbound and return routing were direct.
Slingload had previously been spawned from OMW_LOG_NODE_JALALABAD rather than a dedicated slingload zone.
Guard spawned in/near COP and had difficulty leaving.
```

This led to the decision to simplify CAS and CH-47 to a one-shot waypoint/task chain instead of persistent route reinstallation.

## 15. Build 1-16 exact local provenance

Owner-supplied real local build:

```text
GitCommit: 4a5b39bccbe80f597632f595a147afaa9ceadb36
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-16
TestId: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
GeneratedUtc: 2026-09-03T21:58:54Z
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
Builder SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
Independent SHA256: 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
MizMutation: false
```

Build provenance was valid. Runtime result was FAIL.

## 16. Build 1-16 real DCS failure – Guard/QRF

Observed:

```text
No Guard materialized.
No QRF materialized.
```

Runtime log:

```text
Request denied! Not close enough to spawn zone. Distance = 200 m.
We need to be at least within 100 m range to spawn.
```

Actual OMW cause:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

This was an assistant-authored implementation error. It was not an owner decision and must not be described as shared authorship.

Pinned MOOSE source confirms:

```lua
function WAREHOUSE:SetSpawnZone(zone, maxdist)
  self.spawnzone = zone
  self.spawnzonemaxdist = maxdist or 5000
  return self
end
```

Build 1-17 source correction:

```lua
state.brigade:SetSpawnZone(accessZone)
```

Expected effect:

```text
exact same ME access zone
public MOOSE default max distance 5000 m
no custom spawn algorithm
no native-DCS spawn fallback
```

Still DCS-pending.

## 17. Build 1-16 real DCS failure – CAS

Observed by owner:

```text
AH-64D flew R500 and WEST correctly on ingress.
It left WEST near the AO.
It then extended/waited far back toward Asadabad before attack.
The actual DCS-AI attack run was acceptable.
After all RED targets were destroyed it continued orbiting/loitering.
It did not receive timely recovery.
Later return appeared to be fuel/Bingo-driven and direct rather than WEST reverse -> R500 reverse.
It did not safely recover at Jalalabad and crashed in/near the city on approach.
```

Runtime evidence showed that the known attack incident itself was already tactically complete and the Honaker OPSZONE response scan had stopped.

OMW conceptual error:

```text
operational PATROLZONE closure was additionally coupled to acceptance telemetry state.casFired
```

This meant missing/non-confirmed `EVENTS.Shot` evidence could keep the operational mission alive even when there was no tactical reason to remain in the AO.

Correct separation for Build 1-17:

```text
Operational decision:
zero living known attack-incident participants
-> close incident
-> close/cancel PATROLZONE immediately
-> allow planned recovery route

Acceptance evidence:
EVENTS.Shot
-> still required for final Stage-3 acceptance PASS
-> must not block safe RTB
```

Stage-3 CAS adapter now uses:

```lua
requireExecutionEvidence = false
```

## 18. CAS regression added for Build 1-17

Regression file:

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
```

Primary case:

```text
PATROLZONE active
tacticalComplete = true
executionEvidenceConfirmed = false
requireExecutionEvidence = false
```

Required result:

```text
mission Cancel exactly once
closure = CLOSED
demand = SUCCESS
executionEvidenceConfirmed=false recorded as evidence state only
```

Counter-case:

```text
requireExecutionEvidence = true
executionEvidenceConfirmed = false
-> closure blocked with EXECUTION_EVIDENCE_REQUIRED
-> mission remains active
```

This regression exists specifically because the previous error must not recur unnoticed.

## 19. Build 1-16 real DCS failure – CH-47

Observed:

```text
Physical SlingLoad transport occurred.
Outbound CH-47 route was direct rather than R500.
Return was direct rather than R500 reverse.
```

Runtime failure:

```text
CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
```

The intended route handoff therefore was not installed and the original MOOSE/DCS CARGOTRANSPORT task continued to route directly.

Incorrect prior implementation assumption:

```text
mission.DCStask.params.cargo
mission.DCStask.params.zone
mission.DCStask.params.groupId
mission.DCStask.params.zoneId
would still be reliable post-pickup runtime references
```

Pinned MOOSE source proves those fields at `AUFTRAG:NewCARGOTRANSPORT()` construction time, but not their guaranteed later availability after the lifecycle has progressed.

Build 1-17 correction:

```text
Use explicit runtime objects already owned by Stage 3:
state.cargo
ZONE:FindByName(OMW_BLUE_LZ_WRIGHT_01)
```

Passed into the approved handoff after confirmed pickup:

```lua
{
  cargo = state.cargo,
  dropZone = dropZone,
}
```

The handoff derives:

```text
cargoId = cargo:GetID()
zoneId = dropZone.ZoneID
```

`mission.DCStask.params` remains fallback only.

## 20. CH-47 regression added for Build 1-17

Regression file:

```text
tests/mission-demand/test_slingload_corridor_handoff.lua
```

The regression deliberately simulates the previous runtime failure condition:

```lua
mission.DCStask = { params = {} }
```

Explicit context supplies:

```text
cargo:GetID() = 7001
dropZone.ZoneID = 8002
```

Required result:

```text
handoff success
mode = APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF
referenceSource = EXPLICIT_ACCEPTANCE_CONTEXT
outbound waypoints added
return waypoints added
exactly one UpdateRoute()
CargoTransportation task recreated
groupId = 7001
zoneId = 8002
no fallback to original cargo corridor for the cargo mission
```

Non-cargo missions must still delegate to the original corridor implementation.

## 21. Approved CH-47 Slingload exception boundary

Owner approval already exists for one narrow capability gap:

```text
MOOSE CARGOTRANSPORT owns aircraft dispatch, physical cargo identity, pickup, AIRWING/SQUADRON and mission lifecycle.
After confirmed physical pickup only, public FLIGHTGROUP waypoint/task APIs build the owner-authored route.
At the Wright-side route exit, one DCS CargoTransportation waypoint task is re-issued for the same cargo/drop zone.
After physical delivery, AUFTRAG:Success() returns the lifecycle to normal MOOSE ownership.
```

Not authorized / not added:

```text
raw Controller:setTask route ownership
native coalition spawning
native static spawning outside existing approved boundary
teleport
parallel AIRWING implementation
parallel CampaignState ownership
```

The exception must not silently expand.

## 22. Current Build-1-17 implementation/regression state

Implementation/regression HEAD before later documentation-only commits:

```text
b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
```

The current branch contains later documentation commits but no later runtime implementation change at the time this handoff was prepared.

Regression/CI on implementation head:

```text
Documentation validation #1547: PASS
MissionDemand validation #335: PASS
```

Current documentation head before this handoff also passed:

```text
Documentation validation #1550: PASS
MissionDemand validation #338: PASS
```

These results prove only the repository-level/offline contracts. They do not prove DCS AI routing or CargoTransportation runtime behavior.

## 23. Relevant code and tests

Primary Stage-3 source:

```text
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
```

CAS:

```text
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
```

CH-47 / Slingload:

```text
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
```

Ground response:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundInstallationAttackIncident.lua
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
```

Regression tests:

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
tests/mission-demand/test_slingload_corridor_handoff.lua
tests/mission-demand/run.lua
```

Builder:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Generated local bundle path:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Owner local worktree:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

## 24. Current Builder target

The next builder is expected to identify:

```text
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-17
```

No real local Build-1-17 provenance has yet been supplied in this chat.

Therefore no Build-1-17 bundle SHA256 may be invented or assumed.

## 25. Known assistant implementation errors that must remain explicit

These errors are not owner decisions and must not be described as shared authorship:

```text
1. SetSpawnZone(accessZone, 100)
   -> blocked Guard/QRF materialization.

2. Operational CAS closure tied to state.casFired
   -> acceptance telemetry could keep PATROLZONE alive after tactical completion.

3. Post-pickup CH-47 handoff relied on mission.DCStask.params being stable
   -> CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE in DCS.

4. Earlier corrections were sent into long DCS tests without dedicated offline regressions for each reproducible state
   -> caused avoidable repeated 30-minute tests.

5. Earlier dynamic routing design became overcomplicated compared with the required simple route/task chain
   -> persistent hooks and mission ownership interactions made failure analysis harder.
```

New development discipline:

```text
reproducible bug
-> source/MOOSE review
-> dedicated offline regression
-> CI PASS
-> only then owner local build/hash
-> only then DCS
```

## 26. What is actually fixed in source for Build 1-17

Source-level corrections present:

```text
Guard/QRF:
- remove assistant-authored 100-m SetSpawnZone limit
- continue using ZON_BLUE_GND_HONAKER_ACCESS
- rely on public MOOSE SetSpawnZone default max distance

CAS:
- tactical completion no longer depends on Shot telemetry
- Shot evidence remains acceptance-only
- dedicated regression guards this boundary

CH-47:
- explicit cargo/drop runtime objects passed to post-pickup handoff
- mission.DCStask.params becomes fallback only
- dedicated regression explicitly removes DCStask cargo/drop references
```

No claim is made that this already works in DCS.

## 27. What remains unproven

### Guard

```text
real materialization at/near ZON_BLUE_GND_HONAKER_ACCESS
successful route acquisition onto OMW_RTE_BLUE_GUARD_HONAKER_01
stable repeated patrol in actual terrain
```

### QRF

```text
real materialization with one mixed group
reaction to incident
movement to intended response area
ReturnToLegion behavior after tactical completion
physical return to Honaker
PersonnelLedger settlement only after Returned
```

### CAS

```text
prompt AUFTRAG/PATROLZONE release immediately after last known incident participant is dead
no extended post-combat loiter
WEST reverse physically flown
R500 reverse physically flown
no fuel/Bingo direct-route takeover before recovery
safe Jalalabad landing and AIRWING recovery
```

### CH-47

```text
explicit cargo/drop references survive into real handoff call
no CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
R500 outbound physically flown after pickup
CargoTransportation task accepted at Wright-side route exit
external load continuity maintained
physical delivery occurs
R500 reverse physically flown
safe Jalalabad landing and AIRWING recovery
```

### Performance

```text
no recurrence of severe post-combat/RTB main-thread degradation
no endless route-update or mission-state oscillation
no unnecessary scheduler surviving after completion
```

## 28. Next allowed verification sequence

Do not start with DCS.

First the new chat must:

```text
1. Read current branch HEAD.
2. Read current main HEAD.
3. Re-check AGENTS.md, governance, MOOSE-first policy.
4. Review new main changes that are absent from this branch, especially governance and Ground installation alarm decision.
5. Confirm no new branch implementation has superseded Build 1-17 source.
6. Review the complete branch diff relevant to Stage 3.
7. Confirm both regression tests are still in tests/mission-demand/run.lua.
8. Confirm GitHub CI on current HEAD.
9. Only then ask owner for local pull/build/hash.
```

Owner local build gate, when appropriate:

```powershell
Set-Location 'P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply'

git pull

git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-stage3-honaker-wright-full-response-acceptance-1.ps1

Get-FileHash -Algorithm SHA256 .\mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Only the owner's real console output establishes:

```text
exact local HEAD
BuilderVersion
GeneratedUtc
GitCommit
MOOSECommit
MooseLuaSHA256
bundle SHA256
independent SHA256
MizMutation
```

No local result may be simulated.

## 29. Next DCS Acceptance – exact observations required

Only after exact Build-1-17 provenance is verified.

### Guard

```text
- visible materialization
- no 100-m rejection
- starts from access area, not trapped inside COP
- follows Guard PATHLINE
```

### QRF

```text
- visible materialization
- exactly 5 infantry + 1 CHAP_MATV in one group
- reacts to attack
- survives/returns according to actual losses
- physical return confirmed
- PersonnelLedger settlement confirmed only on Returned
```

### CAS

```text
- spawn Jalalabad
- common-route entry
- R500 outbound
- WEST outbound
- leave WEST near AO
- actual attack
- after last incident target is gone, prompt mission closure
- no large post-combat orbit until Bingo
- WEST reverse
- R500 reverse
- Jalalabad landing
- AIRWING recovery
```

### CH-47

```text
- SlingLoad at ZON_BLUE_LOG_SLG_JALALABAD_01
- pickup before outbound routing
- R500 outbound physically flown
- Wright-side CargoTransportation task executes
- physical SlingLoad delivery
- R500 reverse physically flown
- Jalalabad landing
- AIRWING recovery
```

### Strategic chain

```text
- Wright 16 -> 15
- exactly one strategic RESUPPLY
- no duplicate
- physical delivery restores target stock to 30/30
- expected source stock debit
```

### Performance

```text
- monitor FPS/main-thread behavior during post-combat and both aircraft recovery phases
- collect dcs.log and mission logs for the entire run
```

## 30. Evidence handling for next test

The new chat must not accept screenshots alone for lifecycle conclusions if the log can prove or disprove them.

Required after DCS run:

```text
full relevant dcs.log
mission log / debrief where available
owner observation notes
screenshots for visible route/materialization behavior
exact bundle provenance from prior local build
```

A script-internal PASS is not sufficient if physical behavior contradicts it.

## 31. Current status matrix

```text
Area / capability                         Current status
---------------------------------------------------------------
Governance checked on branch              YES
Pinned MOOSE identified                    YES
Build 1-16 local provenance                CONFIRMED
Build 1-16 DCS result                      FAIL
Guard 1-16                                 FAIL - not materialized
QRF 1-16                                   FAIL - not materialized
CAS ingress R500/WEST 1-16                 OBSERVED WORKING
CAS attack employment 1-16                 OBSERVED WORKING
CAS tactical release 1-16                  FAIL
CAS WEST/R500 recovery 1-16                FAIL
CAS safe Jalalabad recovery 1-16           FAIL
CH-47 physical pickup/delivery 1-16        OBSERVED
CH-47 R500 outbound 1-16                   FAIL
CH-47 R500 reverse 1-16                    FAIL
Build 1-17 Guard/QRF source correction     IMPLEMENTED / DCS-PENDING
Build 1-17 CAS closure correction          IMPLEMENTED / regression PASS / DCS-PENDING
Build 1-17 CH-47 context correction        IMPLEMENTED / regression PASS / DCS-PENDING
Build 1-17 local bundle provenance         NOT YET SUPPLIED
Build 1-17 DCS acceptance                  NOT RUN
PR #144                                    OPEN / DRAFT
validated_in_dcs                           false
```

## 32. Do not do these things in the new chat

```text
Do not assume Build 1-17 works because unit tests pass.
Do not request a DCS run before exact local build/hash provenance.
Do not reintroduce the 5-NM RED-group count as tactical completion gate; it is diagnostics only.
Do not re-couple safe CAS recovery to Shot telemetry.
Do not rely solely on mission.DCStask.params after pickup.
Do not introduce native-DCS routing for CAS.
Do not expand the owner-approved Slingload exception without new approval.
Do not treat mission cancellation as physical QRF return.
Do not merge/rebase blindly against the now-changed main branch.
Do not mutate the .miz automatically.
Do not use CODEX.
```

## 33. Minimum reading order for the new chat

```text
1. AGENTS.md
2. docs/00-project-governance.md
3. docs/26-moose-first-development-policy.md
4. docs/handoffs/2026-09-05-stage3-build-1-17-new-chat-handoff.md
5. docs/moose/STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT.md
6. current Stage-3 acceptance source
7. current CAS closure adapter
8. current Slingload handoff adapter
9. both new regression tests
10. current main changes absent from this branch
```

## 34. New-chat bootstrap prompt

The following text may be pasted into a fresh chat:

```text
Wir setzen Operation Mountain Watch Stage 3 fort.

Arbeite ausschließlich auf dem bestehenden Branch:
agent/fire-support-strategic-resupply-alarm-evidence

Repository:
birkenmoped/Operation-Mountain-Watch

Lies zuerst vollständig:
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/handoffs/2026-09-05-stage3-build-1-17-new-chat-handoff.md
docs/moose/STAGE3-BUILD-1-17-TACTICAL-RELEASE-AND-SLINGLOAD-CONTEXT.md

Prüfe vor jeder Änderung den aktuellen Remote-HEAD dieses Branches und den aktuellen main-HEAD. Main war am 05.09.2026 bereits auf a4a99a384e6c4ee9297226af6f0a0dd697ecc4e6 weitergelaufen; der Branch ist gegenüber main diverged. Insbesondere governance und Ground-installation-alarm Änderungen auf main müssen gegen den Branch geprüft werden. Nicht blind rebasen oder mergen.

PR #144 bleibt OPEN/DRAFT und validated_in_dcs=false.

Build 1-16 hatte exakte lokale Provenienz:
GitCommit 4a5b39bccbe80f597632f595a147afaa9ceadb36
BuilderVersion STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-16
Bundle SHA256 75138CAD6890947139919C6751C28A4E0E4DDD3ECE5A415E8CECB25E377975D2
MOOSE commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS result FAIL.

Die drei belegten Build-1-16-Ursachen waren:
1. assistant-authored SetSpawnZone(accessZone,100) blockierte Guard und QRF;
2. operative CAS-Closure war fälschlich zusätzlich an state.casFired gekoppelt und ließ den AH-64 nach taktischem Ende weiter loitern;
3. CH-47 post-pickup handoff vertraute auf spätes mission.DCStask.params und lief in CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE, daher direkter Flug statt R500.

Build 1-17 korrigiert source-seitig:
- Guard/QRF SetSpawnZone(accessZone) ohne 100-m-Limit;
- CAS tactical completion schließt PATROLZONE unabhängig von Shot-Telemetrie;
- CH-47 handoff bekommt state.cargo und Wright drop zone explizit;
- dedicated regressions für CAS closure und Slingload handoff sind in tests/mission-demand/run.lua.

Implementation/regression head vor späteren reinen Doku-Commits:
b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
Documentation validation #1547 PASS
MissionDemand validation #335 PASS
Späterer Doku-Head c7cca4c453b5f06259479e98682bff65638a90d3 hatte Documentation #1550 PASS und MissionDemand #338 PASS.

Es gibt noch KEINEN realen lokalen Build-1-17-Hash und KEINEN Build-1-17-DCS-Test.
Fordere keinen DCS-Test an, bevor du aktuellen Branch/main geprüft, Diff und Regressionen kontrolliert und danach einen exakten lokalen Pull/Build/Hash vom Projektinhaber erhalten hast.

CAS-Soll:
Jalalabad -> R500 -> WEST -> AO/CAS -> tactical complete -> WEST reverse -> R500 reverse -> Jalalabad -> land/AIRWING recovery.
Kein fuel/Bingo direct RTB.

CH-47-Soll:
SlingLoad pickup at ZON_BLUE_LOG_SLG_JALALABAD_01 -> R500 outbound -> Wright CargoTransportation delivery -> R500 reverse -> Jalalabad -> land/AIRWING recovery.

Guard:
TPL_BLUE_GND_INF_RIFLE_SQUAD_9, spawn via ZON_BLUE_GND_HONAKER_ACCESS, patrol OMW_RTE_BLUE_GUARD_HONAKER_01 PATHLINE.

QRF:
TPL_BLUE_GND_QRF_MIXED_6 = one group = 5 infantry + 1 CHAP_MATV, no embark/disembark, 5 GROUND_PERSONNEL, physical ARMYGROUP:Returned required before settlement.

MOOSE-first strikt einhalten. Keine API erfinden, keine .miz automatisch mutieren, kein CODEX, keine ungeprüfte Aussage als VALIDATED darstellen.
```

## 35. Schlussstatus

```text
Branch is prepared for continuation.
Current design intent is documented.
Known Build-1-16 causes are identified.
Build-1-17 source corrections exist.
Offline regressions exist and passed on the implementation head.
Current pre-handoff documentation head also had both GitHub checks PASS.
Main has advanced and must be re-checked before any new implementation.
No local Build-1-17 provenance exists yet.
No Build-1-17 DCS result exists yet.
Overall Stage 3 remains FAIL / validated_in_dcs=false.
```
