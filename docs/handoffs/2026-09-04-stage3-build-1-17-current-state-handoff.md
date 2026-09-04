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

## 1. Status in einem Satz

Der Stage-3-Gesamtverbund ist weiterhin **nicht DCS-validiert**. Build 1-16 war ein realer Fehltest. Die drei im Lauf belegten Ursachen – Guard/QRF-Spawnlimit, CAS-Closure-Kopplung an Shot-Telemetrie und fehlende CH-47-Drop-Referenz im post-pickup Handoff – sind für Build 1-17 im Source korrigiert und durch zusätzliche Offline-Regressionen abgesichert. Ein neuer lokaler Build und ein neuer DCS-Lauf stehen noch aus.

## 2. Aktiver Git-/PR-Stand

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch: agent/fire-support-strategic-resupply-alarm-evidence
Current remote HEAD: b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
Pull Request: #144
PR state: OPEN
PR mode: DRAFT
Base: agent/fire-support-strategic-resupply-closure
Base commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
Validated in DCS: false
```

Aktuelle GitHub-Checks auf `b7a3c1bdae45f9460053feee52cab7ffd09ef7f1`:

```text
Documentation validation: PASS
MissionDemand validation: PASS
```

Der Branch darf weder als `VALIDATED` noch als `ACCEPTED_TECHNICAL_BASELINE` bezeichnet werden. PR #144 bleibt DRAFT und darf vor einem erfolgreichen exakten Lauf nicht Ready for Review oder gemerged werden.

## 3. Verbindliche Governance

Mindestens maßgeblich:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Zentrale Regeln für diesen Teilstand:

```text
MOOSE-first.
Keine erfundenen MOOSE-/DCS-APIs.
Keine parallele Ressourcenhoheit.
CampaignState bleibt strategisch autoritativ.
DCS-/MOOSE-Gruppen sind physische Laufzeitrepräsentationen.
VALIDATED nur nach dokumentiertem DCS-Lauf mit exakter Provenienz.
Keine weitere 30-Minuten-DCS-Schleife für Fehler, die offline reproduzierbar und testbar sind.
```

## 4. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Für die aktuellen Änderungen relevante öffentliche Pfade:

```text
WAREHOUSE:SetSpawnZone
PATHLINE:FindByName
PATHLINE:GetCoordinates
COORDINATE:WaypointGround
GROUP:TaskFunction
GROUP:SetTaskWaypoint
GROUP:Route
AUFTRAG:NewONGUARD
AUFTRAG:SetEngageDetected
AUFTRAG:SetReturnToLegion
AUFTRAG:Cancel
ARMYGROUP:Returned / OnAfterReturned
AUFTRAG:NewPATROLZONE
AUFTRAG:NewCARGOTRANSPORT
AUFTRAG:Success
FLIGHTGROUP:GetWaypointCurrentUID
FLIGHTGROUP:AddWaypoint
FLIGHTGROUP:AddTaskWaypoint
FLIGHTGROUP:UpdateRoute
```

## 5. Verbindlicher Stage-3-Sollverbund

```text
RED attack at Honaker
-> MOOSE OPSZONE attack qualification
-> GroundInstallationAttackIncident
-> Guard
-> mixed QRF
-> AH-64D CAS
-> Wright L118 ARTY
-> local M1083 rearm
-> CampaignState AMMO debit 16 -> 15
-> exactly one strategic RESUPPLY demand
-> Jalalabad CH-47 external slingload pickup
-> R500 routed flight to Wright
-> physical slingload delivery
-> Wright strategic AMMO restored to 30/30
-> CH-47 return via R500
-> Jalalabad landing / AIRWING recovery
```

Die Teilketten dürfen nicht gegenseitig Ressourcenhoheit duplizieren.

## 6. Guard – verbindlicher Vertrag

```text
Physical template: TPL_BLUE_GND_INF_RIFLE_SQUAD_9
Patrol pathline: OMW_RTE_BLUE_GUARD_HONAKER_01
Spawn/access zone: ZON_BLUE_GND_HONAKER_ACCESS
Physical source: MOOSE PLATOON under Honaker BRIGADE/WAREHOUSE
Patrol: PATHLINE:GetCoordinates -> WaypointGround -> TaskFunction/SetTaskWaypoint -> GROUP:Route
Patrol behavior: repeated circuit
```

Wichtig: `OMW_RTE_BLUE_GUARD_HONAKER_01` ist eine Mission-Editor-Linienzeichnung und wird von MOOSE als `PATHLINE` registriert, nicht als GROUP.

## 7. QRF – owner-approved Vertrag

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Representation: one DCS/MOOSE GROUP
Composition: 5 infantry + 1 CHAP_MATV
Embark/disembark: none
Personnel reservation/debit: 5 GROUND_PERSONNEL
Mission: MOOSE AUFTRAG ONGUARD
Tactical area: shared 5-NM Honaker response area
Recovery: AUFTRAG Cancel + SetReturnToLegion(true)
Settlement gate: physical ARMYGROUP:Returned
```

Personnel wird während des Einsatzes über `OMW_GroundPersonnelDeploymentLedger.lua` reserviert. Eine Auftragsstornierung allein ist keine physische Rückkehr und darf die strategische Ressource nicht freigeben.

## 8. CAS – owner-required physischer Ablauf

Verbindlicher Ablauf:

```text
1. CAS demand
2. AH-64D spawn at Jalalabad
3. fly to common-route entry
4. follow OMW_FlightPath_R500
5. transition to OMW_FlightPath_WEST
6. leave WEST near AO
7. execute real CAS / S&D
8. after tactical completion, release PATROLZONE mission immediately
9. rejoin WEST near AO
10. follow WEST reverse
11. transition to R500 reverse
12. follow common route to Jalalabad
13. land
14. AIRWING recovery
```

Altitude policy:

```text
R500 outbound/return: 500 ft AGL
WEST outbound/return: 2500 ft AGL
CAS tactical area: 2500 ft AGL nominal combat height
```

## 9. CH-47 Air-AMMO – owner-required physischer Ablauf

Verbindlicher Ablauf:

```text
1. strategic RESUPPLY demand
2. CH-47 and external SlingLoad spawn
3. CH-47 physically picks up SlingLoad first
4. only after confirmed pickup: R500 outbound route is installed
5. follow R500 toward Wright
6. at Wright-side route exit re-issue CargoTransportation task for same physical cargo and drop zone
7. physical SlingLoad delivery in OMW_BLUE_LZ_WRIGHT_01
8. rejoin R500
9. follow R500 reverse to Jalalabad
10. land
11. AIRWING recovery
```

Pickup zone:

```text
ZON_BLUE_LOG_SLG_JALALABAD_01
```

Drop zone:

```text
OMW_BLUE_LZ_WRIGHT_01
```

Der Slingload-Spawn wird exakt am Mission-Editor-Zonenzentrum erzeugt; automatische Static-Repositionierung ist deaktiviert.

## 10. Build 1-16 – exakte lokale Build-Provenienz

Vom Projektinhaber real lokal erzeugt:

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

Damit ist die Build-Provenienz für Build 1-16 sauber. Sie macht den Lauf jedoch nicht erfolgreich.

## 11. Build 1-16 – reale DCS-Beobachtung und Ergebnis

Gesamtergebnis:

```text
FAIL
validated_in_dcs: false
```

Beobachtung des Projektinhabers:

### Guard / QRF

```text
Keine Guard-Einheit materialisiert.
Keine QRF materialisiert.
```

Runtime-Ursache aus Log:

```text
Request denied! Not close enough to spawn zone. Distance = 200 m.
We need to be at least within 100 m range to spawn.
```

Das war durch OMW-Code selbst verursacht:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

Diese 100-m-Grenze war keine vom Projektinhaber gesetzte Vorgabe, sondern ein Implementierungsfehler des Assistenten.

### CAS

Reale Beobachtung:

```text
- AH-64D flog zunächst den vorgesehenen Korridor R500 -> WEST.
- Er klinkte sich im AO-Bereich aus der Route aus.
- Er wartete danach längere Zeit und flog weit zurück in Richtung Asadabad, bevor er den Angriff begann.
- Der eigentliche DCS-AI-Angriff war technisch grundsätzlich brauchbar.
- Nach Vernichtung aller roten Ziele blieb der AH-64D in größerem Umfeld der AO und kreiste weiter.
- Er erhielt keine rechtzeitige operative RTB-Freigabe.
- Erst später, offensichtlich im Low-Fuel/Bingo-Kontext, flog er zurück.
- Dieser Rückflug erfolgte direkt und nicht sauber über WEST reverse -> R500 reverse.
- Der AH-64D erreichte Jalalabad nicht mehr sicher und stürzte im Anflug/Stadtbereich ab.
```

Das Kernproblem ist nicht die Waffenwirkung, sondern die verspätete Missionsbeendigung und der daraus folgende falsche Recovery-Lifecycle.

### CH-47 Resupply

Reale Beobachtung:

```text
- Slingload/CARGOTRANSPORT wurde ausgeführt.
- Der CH-47 flog erneut direkte Luftlinie statt R500 outbound.
- Der Rückflug war ebenfalls direkte Luftlinie.
```

Runtime-Fehler:

```text
CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
```

Damit wurde die geplante post-pickup R500-Wegpunktkette gar nicht installiert. Der originale MOOSE-CARGOTRANSPORT blieb aktiv und führte seinen Direktflug aus.

## 12. Fehlerursache Guard/QRF und Build-1-17-Korrektur

Fehlerhafter Build-1-16-Code:

```lua
state.brigade:SetSpawnZone(accessZone, 100)
```

Gepinnter MOOSE-Source bestätigt:

```lua
function WAREHOUSE:SetSpawnZone(zone, maxdist)
  self.spawnzone = zone
  self.spawnzonemaxdist = maxdist or 5000
  return self
end
```

Build 1-17 verwendet daher:

```lua
state.brigade:SetSpawnZone(accessZone)
```

Damit bleibt die exakt gewünschte Zone `ZON_BLUE_GND_HONAKER_ACCESS` aktiv, aber der öffentliche MOOSE-Default von 5000 m verhindert die künstliche 100-m-Blockade.

Es wurde keine neue Spawnlogik geschrieben und kein Native-DCS-Spawn eingeführt.

## 13. Fehlerursache CAS und Build-1-17-Korrektur

Die operative Closure hing zusätzlich an einer Acceptance-Telemetrie:

```text
state.casFired
```

Das war konzeptionell falsch. `EVENTS.Shot` darf belegen, dass tatsächlich Waffen eingesetzt wurden, aber die sichere operative Beendigung eines bereits taktisch abgeschlossenen PATROLZONE-Auftrags nicht blockieren.

Build 1-17 trennt jetzt:

```text
Operational mission completion:
attack incident has zero living known participants
-> attack incident closes
-> PATROLZONE AUFTRAG closes/cancels immediately
-> recovery route must become authoritative

Acceptance evidence:
EVENTS.Shot
-> still required for final Stage-3 PASS
-> does not block RTB/recovery
```

Stage 3 konfiguriert den CAS-Adapter deshalb mit:

```lua
requireExecutionEvidence = false
```

`OMW_FobAttackCasPatrolClosure.lua` Schema 2 blockiert nur dann auf fehlende Execution Evidence, wenn der jeweilige Adapter ausdrücklich `requireExecutionEvidence=true` setzt.

## 14. Neue CAS-Regression

Datei:

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
```

Der Test reproduziert exakt den bisher gefährlichen Zustand:

```text
PATROLZONE active
tacticalComplete = true
executionEvidenceConfirmed = false
requireExecutionEvidence = false
```

Erwartung und geprüfter Vertrag:

```text
mission Cancel exactly once
closure result = CLOSED
demand status = SUCCESS
recorded executionEvidenceConfirmed = false
```

Zusätzlich wird der Gegenfall geprüft:

```text
requireExecutionEvidence = true
executionEvidenceConfirmed = false
-> closure rejected with EXECUTION_EVIDENCE_REQUIRED
-> no Cancel
-> demand remains ACTIVE
```

Damit ist die operative/telemetrische Trennung offline regressionsgesichert.

## 15. Fehlerursache CH-47 und Build-1-17-Korrektur

Die frühere Handoff-Implementierung ging davon aus, dass nach physischem Pickup noch zuverlässig folgende constructor-time Felder im laufenden Missionsobjekt verfügbar sind:

```text
mission.DCStask.params.cargo
mission.DCStask.params.zone
mission.DCStask.params.groupId
mission.DCStask.params.zoneId
```

Der reale Build-1-16-Lauf hat diese Annahme widerlegt. Die post-pickup Handoff-Logik erhielt keine vollständige Drop-Referenz und brach mit `CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE` ab.

Diese Felder sind nicht länger die alleinige operative Quelle.

Die Acceptance besitzt die realen Objekte bereits selbst:

```text
state.cargo
ZONE:FindByName(OMW_BLUE_LZ_WRIGHT_01)
```

Build 1-17 übergibt deshalb nach bestätigtem physischem Pickup explizit:

```lua
{
  cargo = state.cargo,
  dropZone = dropZone,
}
```

an `OMW_SlingloadCorridorHandoff.lua`.

Der Handoff löst daraus:

```text
cargoId = cargo:GetID()
zoneId = dropZone.ZoneID
```

und verwendet `mission.DCStask.params` nur noch als Fallback.

## 16. Genehmigte CH-47-Ausnahmegrenze bleibt unverändert

Die bereits dokumentierte Eigentümerfreigabe gilt nur für:

```text
physical external slingload has been picked up
-> public MOOSE FLIGHTGROUP waypoint/task APIs
-> one DCS CargoTransportation waypoint task at Wright-side route exit
```

Nicht Teil der Ausnahme:

```text
raw Controller:setTask route ownership
native coalition spawn
teleport
custom AIRWING lifecycle
custom CARGOTRANSPORT replacement
parallel CampaignState ownership
```

MOOSE bleibt Eigentümer von:

```text
AUFTRAG CARGOTRANSPORT
AIRWING / SQUADRON dispatch
physical aircraft lifecycle
mission success/failure lifecycle
```

## 17. Neue CH-47-Handoff-Regression

Datei:

```text
tests/mission-demand/test_slingload_corridor_handoff.lua
```

Der Test löscht absichtlich die constructor-time MOOSE-Taskreferenzen:

```lua
mission.DCStask = { params = {} }
```

und übergibt ausschließlich die expliziten Runtime-Objekte:

```text
cargo object with GetID() = 7001
dropZone with ZoneID = 8002
```

Geprüfter Vertrag:

```text
handoff succeeds
mode = APPROVED_EXTERNAL_SLINGLOAD_CORRIDOR_HANDOFF
referenceSource = EXPLICIT_ACCEPTANCE_CONTEXT
outbound waypoint count = 2
return waypoint count = 2
exactly one UpdateRoute()
CargoTransportation task recreated
CargoTransportation.params.groupId = 7001
CargoTransportation.params.zoneId = 8002
original cargo corridor is not used for CARGOTRANSPORT
```

Außerdem wird geprüft, dass Nicht-CARGOTRANSPORT-Missionen weiterhin an die ursprüngliche Corridor-Implementierung delegiert werden.

## 18. Aktuelle Source-Dateien

Für Build 1-17 zentral:

```text
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_SlingloadCorridorHandoff.lua
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/ground/OMW_GroundInstallationAttackIncident.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Neue Regressionen:

```text
tests/mission-demand/test_fob_attack_cas_patrol_closure.lua
tests/mission-demand/test_slingload_corridor_handoff.lua
```

Beide sind in:

```text
tests/mission-demand/run.lua
```

eingebunden.

## 19. Aktuelle CI-Lage

Aktueller Remote-HEAD:

```text
b7a3c1bdae45f9460053feee52cab7ffd09ef7f1
```

GitHub Actions:

```text
Documentation validation #1547: PASS
MissionDemand validation #335: PASS
```

Damit ist für den aktuellen Branchstand nachgewiesen:

```text
- Dokumentationsvalidator akzeptiert den Stand.
- MissionDemand-Testlauf akzeptiert die aktuelle Lua-/Adapter-Regressionsbasis.
- Die beiden neuen Fehlerpfade sind in der regulären Offline-Suite enthalten.
```

Nicht nachgewiesen ist dadurch reales DCS-Verhalten.

## 20. Noch nicht durch Build 1-17 bewiesen

Es existiert noch **keine reale lokale Build-1-17-Provenienz**. Insbesondere fehlen aktuell noch:

```text
local HEAD after git pull
BuilderVersion for Build 1-17
GeneratedUtc
bundle SHA256
independent Get-FileHash SHA256
MizMutation result for the new build
```

Es existiert außerdem noch **kein DCS-Lauf für Build 1-17**.

Daher weiterhin:

```text
validated_in_dcs: false
```

## 21. Was der nächste DCS-Lauf tatsächlich noch beweisen muss

Erst nach erfolgreichem lokalen Build mit übereinstimmenden Hashes.

### Guard

```text
- physical materialization succeeds at/through ZON_BLUE_GND_HONAKER_ACCESS
- no 100-m rejection remains
- Guard is routed onto OMW_RTE_BLUE_GUARD_HONAKER_01
- repeated circuit is physically observable
```

### QRF

```text
- TPL_BLUE_GND_QRF_MIXED_6 materializes
- exact 5 infantry + 1 CHAP_MATV composition remains one group
- reacts to Honaker incident
- after incident closure mission Cancel/ReturnToLegion is issued
- physical return occurs
- PersonnelLedger settles only on ARMYGROUP:Returned
```

### CAS

```text
- AH-64D first enters the owner corridor, no direct AO shortcut
- R500 -> WEST order is physically flown
- aircraft leaves WEST only in AO area
- actual weapon employment occurs
- after all known attack participants are dead, PATROLZONE is released promptly
- aircraft does not loiter until low fuel
- WEST reverse -> R500 reverse remains available after mission closure
- no direct RTB shortcut
- Jalalabad landing and AIRWING recovery occur before fuel exhaustion
```

### CH-47

```text
- external SlingLoad pickup physically occurs before corridor installation
- explicit cargo/drop references prevent CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE
- R500 outbound waypoints are physically flown
- CargoTransportation task is re-issued at Wright-side route exit
- physical delivery occurs in OMW_BLUE_LZ_WRIGHT_01
- R500 reverse is physically flown
- no direct Wright -> Jalalabad shortcut
- Jalalabad landing and AIRWING recovery occur
```

### Strategic logistics

```text
- Wright local rearm consumes exactly one CampaignState AMMO package
- Wright goes 16 -> 15
- exactly one RESUPPLY demand is created
- duplicate demand is suppressed semantically
- successful physical delivery restores Wright to 30/30
- Jalalabad source stock reaches the expected final quantity
```

### Performance

```text
- no recurrence of severe RTB/post-combat main-thread degradation
- no persistent high-frequency scheduler remains active unnecessarily after completion
- no flight remains stuck in an endless post-task route/lifecycle loop
```

## 22. Bekannte technische Risiken, die erst DCS entscheiden kann

### CAS AI behavior

Die Wegpunkt-/Taskkette kann offline strukturell geprüft werden. Nicht offline beweisbar sind:

```text
- konkrete DCS-AI-Kurvenführung beim Übergang WEST -> AO
- tatsächliche Reaktion auf AUFTRAG Cancel während/kurz nach Engagement
- Priorität von recovery waypoints gegenüber DCS-internem fuel/RTB behavior
- Terrain clearance und finaler Jalalabad-Anflug
```

### CH-47 CargoTransportation task handoff

Offline ist jetzt abgesichert, dass die notwendigen IDs aus expliziten Runtime-Objekten erzeugt werden. Nicht offline beweisbar ist:

```text
- DCS akzeptiert den neu gesetzten CargoTransportation waypoint task im realen post-pickup Zustand
- externe Last bleibt physisch korrekt angehängt
- Delivery wird am Wright exit korrekt fortgesetzt
- anschließende R500-reverse-Wegpunkte werden von der realen DCS AI abgeflogen
```

Dafür bleibt der DCS-Acceptance-Lauf zwingend.

## 23. Explizit dokumentierte Implementierungsfehler des Assistenten

Die folgenden Fehler stammen aus der Entwicklung und dürfen nicht als Nutzerentscheidungen oder gemeinschaftliche Entscheidungen beschrieben werden:

```text
1. SetSpawnZone(accessZone, 100)
   - künstlich zu enger Spawnradius
   - verhinderte Guard/QRF-Materialisierung

2. operative CAS-Closure zusätzlich an state.casFired gekoppelt
   - Acceptance-Telemetrie beeinflusste sicheren RTB-Lifecycle
   - AH-64 blieb unnötig lange im AO und verbrauchte Treibstoff

3. CH-47-Handoff verließ sich zu spät im Lifecycle auf mission.DCStask.params
   - constructor-time Felder wurden als dauerhaft verfügbar angenommen
   - realer Lauf zeigte CARGOTRANSPORT_DROP_REFERENCE_UNAVAILABLE

4. mehrere vorherige Korrekturen wurden ohne jeweils eigenen Regressionstest für den konkreten Fehlerzustand weitergegeben
   - dadurch entstanden wiederholte lange DCS-Tests mit vermeidbaren Fehlern
```

Ab Build 1-17 gilt deshalb für diesen Branch:

```text
reproduzierbarer Fehler
-> offline Regression zuerst
-> CI muss PASS sein
-> lokaler Build + realer Hash
-> erst dann DCS-Lauf
```

## 24. Was ausdrücklich nicht erneut geändert werden soll

Ohne neue Evidenz nicht erneut umbauen:

```text
- CampaignState resource authority
- QRF composition contract
- Guard PATHLINE identity
- MOOSE-first architecture
- Wright ARTY + M1083 strategic debit chain
- external-slingload owner exception scope
- exact pickup zone ZON_BLUE_LOG_SLG_JALALABAD_01
- owner-required CAS and CH-47 route order
```

Build 1-17 ist eine gezielte Korrektur der belegten Fehler und keine Einladung für eine weitere Architektur-Neuerfindung.

## 25. Nächster zulässiger Arbeitsschritt

Noch **kein DCS-Test**, solange kein exakter lokaler Build-1-17-Nachweis vorliegt.

Nächste Reihenfolge:

```text
1. Owner pulls current branch HEAD.
2. Owner confirms exact local HEAD.
3. Owner runs Stage-3 builder.
4. Owner supplies complete console output.
5. Owner supplies independent SHA256 of generated bundle.
6. Assistant verifies BuilderVersion / commit / MOOSE hash / bundle hash / MizMutation.
7. Only if all provenance is consistent: one new full DCS run.
8. Owner returns real dcs.log plus observations/screenshots as needed.
9. Assistant evaluates exact runtime evidence.
10. Only after success: acceptance/status documentation may be promoted.
```

## 26. Übergabe-Kurzform

Für eine neue Chat-/Arbeitsübergabe reicht als Einstieg:

```text
Continue OMW Stage 3 on branch agent/fire-support-strategic-resupply-alarm-evidence.
Read AGENTS.md, docs/00-project-governance.md, docs/26-moose-first-development-policy.md and docs/handoffs/2026-09-04-stage3-build-1-17-current-state-handoff.md first.
Current remote HEAD is b7a3c1bdae45f9460053feee52cab7ffd09ef7f1.
PR #144 is OPEN/DRAFT and validated_in_dcs=false.
Build 1-16 failed in DCS because of assistant-authored 100-m Guard/QRF spawn limit, CAS tactical closure coupled to shot telemetry, and CH-47 post-pickup CARGOTRANSPORT drop-reference loss.
Build 1-17 source fixes all three and adds dedicated offline regressions for CAS closure without shot evidence and slingload handoff with empty mission.DCStask.params.
Documentation validation and MissionDemand validation pass on current HEAD.
Do not request another DCS run until local Build 1-17 provenance and independent bundle SHA256 are supplied and checked.
```
