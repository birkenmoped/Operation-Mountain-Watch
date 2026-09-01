---
document_id: OMW-HANDOFF-STAGE3-FIRE-SUPPORT-RESUPPLY-DEVELOPMENT-2026-09-01
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local handoff of the current Stage 3 Honaker/Wright/Jalalabad response-chain development
  - current development objective, implemented partial results, current failures and remaining work
  - exact local Build 1-12 provenance supplied by the project owner
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-HANDOFF-STAGE3-FIRE-SUPPORT-RESUPPLY-CURRENT-STATE-2026-09-01
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
base_commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
main_checked_commit: 6c9b5530c5524f109e7def739bd2d01e2aa4efc6
branch_head_before_handoff: 142aed16ab3610777c5b2fb88638fa483f729afc
pull_request: 144
---

# Stage 3 Fire Support / Strategic Resupply – Entwicklungsübergabe 2026-09-01

## 1. Zweck dieser Übergabe

Diese Übergabe beschreibt den aktuellen Entwicklungsstand der Stage-3-Kette, die bereits nachgewiesenen Teilfunktionen, den derzeitigen FAIL, die verbleibenden technischen Risiken und die verbindliche Reihenfolge der nächsten Schritte.

Sie ist branch-lokal. Sie ersetzt keine `main`-Governance und stellt ausdrücklich keinen Stage-3-DCS-PASS dar.

## 2. Aktiver Git-/PR-Stand

Aktiver Arbeitsbranch:

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

Branch-HEAD vor Erstellung dieser Übergabe:

```text
142aed16ab3610777c5b2fb88638fa483f729afc
```

Aktuell geprüfter `main`-Stand:

```text
6c9b5530c5524f109e7def739bd2d01e2aa4efc6
```

`main`-Commit:

```text
Generalize BLUE installation alarm, Guard and QRF policy
```

Pull Request:

```text
PR #144
state: OPEN
mode: DRAFT
base: agent/fire-support-strategic-resupply-closure
head: agent/fire-support-strategic-resupply-alarm-evidence
```

PR #144 darf derzeit weder als Ready for Review markiert noch gemergt werden. Stage 3 ist nicht DCS-validiert.

Lokales Arbeitsverzeichnis des Projektinhabers:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

## 3. Verbindliche Arbeitsgrundlage

Vor jeder weiteren fachlichen oder technischen Änderung mindestens auf aktuellem `main` prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Wichtige zusätzliche Dokumente für diesen Scope:

```text
docs/handoffs/2026-09-01-stage3-fire-support-resupply-current-state-handoff.md
docs/handoffs/2026-09-01-stage3-fire-support-resupply-development-handoff.md
docs/moose/STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT.md
docs/moose/STAGE3-BUILD-1-11-RECONCILIATION.md
docs/moose/ISR-FAC-CAS-AAR.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-09-01-CAS-QRF-RESUPPLY.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-08-31-EXECUTION-GAPS.md
```

Bei Widersprüchen gilt ausschließlich die Authority-Hierarchie aus `docs/00-project-governance.md`.

## 4. Gepinnter MOOSE-Stand

Für den aktuellen Stage-3-Scope gilt weiterhin:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Operation Mountain Watch bleibt MOOSE-first. Für den aktuellen Guard-Fix darf insbesondere keine Native-DCS- oder Parallel-Routinglösung eingeführt werden, solange nicht zuerst MOOSE-Dokumentation, die tatsächlich gepinnte `Moose.lua` und relevante offizielle Beispiele geprüft und eine verbleibende Lücke dokumentiert wurden. Eine produktive Ausnahme benötigt weiterhin ausdrückliche Eigentümerfreigabe.

## 5. Ziel der aktuellen Stage-3-Entwicklung

Ziel ist ein vollständiger automatischer End-to-End-Reaktionspfad für einen realen Angriff auf COP Honaker mit lokaler und strategischer Folgereaktion:

```text
RED threat reaches Honaker installation alarm boundary
-> MOOSE OPSZONE attack evidence
-> one deduplicated Honaker attack incident
-> Guard response
-> QRF response
-> Wright fire-support demand
-> real ARTY fire / retarget
-> CAS demand and AH-64D response
-> local M1083 ARTY rearm
-> CampaignState Wright AMMO debit
-> reorder threshold reached
-> exactly one strategic AMMO RESUPPLY demand
-> Jalalabad CH-47 CARGOTRANSPORT
-> physical cargo delivery to Wright
-> CampaignState settlement
-> physical CH-47 return / AIRWING asset recovery
-> tactical incident completion
-> all relevant MissionDemand records complete exactly once
```

Verbindliche Architekturgrenzen:

```text
CampaignState = strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Autorität
MOOSE = primärer physischer Executor und Lifecycle-Lieferant
DCS groups = temporäre physische Repräsentationen
```

Die 1000-m-FOB-/COP-Alarmzone ist nur Trigger-/Threat-Evidence-Grenze und ausdrücklich keine taktische Engagement Area oder Mission-Endbedingung.

## 6. Erfolgreiche bzw. bereits belastbar nachgewiesene Teile

### 6.1 Alarm-/Incident-Semantik

Die Trennung zwischen Installationsalarm und taktischer Incident-Lebensdauer wurde im bisherigen Stage-3-Pfad bereits erreicht:

```text
OPSZONE Attacked
-> proximity/threat evidence
-> attack incident

OPSZONE Defeated
-> perimeter telemetry only
-> does NOT automatically terminate ARTY / QRF / CAS
```

Lebende bekannte Angreifer bleiben für den Incident relevant, auch wenn sie die Alarmzone verlassen.

### 6.2 Wright ARTY / lokaler M1083-Rearm – historisch real nachgewiesen

Der reale Build-1-10-Lauf erreichte und belegte für seine exakte Provenienz:

```text
Wright ARTY real fire / retarget
physical ammunition decrease
M1083 materialization
MOOSE ARTY rearm
CampaignState Wright AMMO 16 -> 15
M1083 return
reorder threshold 15 / 30 reached
```

Diese Ergebnisse bleiben Teilnachweise des exakt dokumentierten Build-1-10-Standes. Sie sind kein Gesamt-Stage-3-PASS.

### 6.3 RESUPPLY-Dedupe-Ursache analysiert und Source-seitig korrigiert

Der Build-1-10-Abbruch im RESUPPLY-Dedupe-Gate beruhte auf einem Acceptance-Fehler: eine Deep Copy des bestehenden MissionDemand wurde fälschlich per Lua-Tabellenidentität verglichen.

Die aktuelle Korrekturrichtung prüft semantisch:

```text
duplicate.id == demand.id
duplicate.dedupeKey == demand.dedupeKey
created == false
reason == active_duplicate
```

Der korrigierte Pfad wurde im jüngsten kurzen DCS-Lauf noch nicht wieder erreicht.

### 6.4 CAS-Korrekturen implementiert / source-reviewed, aber noch DCS-pending

Nach dem Build-1-10-FAIL wurden folgende owner-freigegebene Korrekturen umgesetzt:

```text
PATROLZONE + SetEngageDetected instead of CASENHANCED
native AUFTRAG SetMissionIngressCoord / SetMissionEgressCoord
missionUID-owned owner-authored helicopter corridor
OnAfterUpdateRoute rebind after MOOSE route rebuild
single Stage-3 altitude-control path
PATHLINE suffix contract:
  _R<number> = right offset in meters
  _L<number> = left offset in meters
  no suffix  = centerline
```

Für Stage 3 gilt derzeit:

```text
OMW_FlightPath_R500 -> +500 m right
OMW_FlightPath_WEST -> centerline
```

Diese CAS-/Corridor-Korrekturen sind noch nicht im aktuellen Build-1-12-DCS-Lauf ausgeführt worden, weil der Test vorher im Guard-Preflight abbrach.

### 6.5 Aktueller QRF-Vertrag ist geklärt und im getesteten MIZ-Stand sichtbar

Die frühere falsche Annahme einer separaten 9-Mann-Infanteriegruppe plus zusätzlicher Fahrzeuggruppe ist verworfen.

Owner-approved QRF-Vertrag:

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Composition: 5 infantry + 1 MRAP
Representation: one DCS/MOOSE GROUP
Embark/Disembark: false
Personnel debit: 5 GROUND_PERSONNEL
```

Nicht mehr Teil des Sollvertrags:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
TPL_BLUE_GND_QRF_MIXED_4
separate infantry and vehicle missions
embark/disembark lifecycle
```

Der jüngste reale DCS-/MOOSE-Lauf registrierte `TPL_BLUE_GND_QRF_MIXED_6` und alle sechs Units. Damit ist die Verfügbarkeit des Templates im getesteten Missionsstand bestätigt. QRF-Dispatch und Engagement wurden in diesem Lauf noch nicht getestet.

### 6.6 Build 1-12 – realer lokaler Build-PASS

Der Projektinhaber hat Build 1-12 am 01.09.2026 erfolgreich lokal gebaut.

Verifizierter lokaler Git-Stand beim Build:

```text
203b49e061340b4629bb5e1e3b49f860320d419e
```

Builder:

```text
tools\build-stage3-honaker-wright-full-response-acceptance-1-12.ps1
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-12
```

Bundle:

```text
mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Realer SHA-256:

```text
62C31BFCF877F97C2F3FDECE57A2AF0C596B56F9343FF5DB9B9F6F50F7360826
```

Build-Telemetrie:

```text
QRFTemplate: TPL_BLUE_GND_QRF_MIXED_6
QRFComposition: 5 infantry + 1 MRAP in one DCS/MOOSE GROUP
QRFEmbarkDisembark: false
QRFPersonnelDebit: 5 GROUND_PERSONNEL
MizMutation: false
```

Der unmittelbar vorherige lokale Versuch ist ausdrücklich kein Build-1-12-PASS. Er erzeugte zunächst das alte Build-1-11-Bundle und scheiterte danach am Transform-Marker. Der dabei entstandene Hash `F332BB72...` ist keine gültige Build-1-12-Provenienz.

## 7. Aktueller realer FAIL

Jüngster ausgeführter Missionsstand:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v21_GroundWorks.miz
```

DCS:

```text
DCS/2.9.29.27278 (x86_64; MT; Windows NT 10.0.26200)
```

Stage-3-Ergebnis:

```text
FAIL
validated_in_dcs: false
```

Konkreter aktueller Abbruch:

```text
[STAGE 3][FAIL] missing OMW_RTE_BLUE_GUARD_HONAKER_01
```

Dieser Text beschreibt den wirklichen Fehler jedoch irreführend: die Route fehlt nicht.

Im selben realen MOOSE-Log wurde registriert:

```text
Register PATHLINE: OMW_RTE_BLUE_GUARD_HONAKER_01
Line drawing with 13 points
```

Damit ist belegt:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01
= MOOSE PATHLINE
!= GROUP
```

Die aktuelle Stage-3-Implementierung behandelt diesen Namen dennoch als GROUP und leitete daraus `GROUP:PatrolRoute()` ab. Das ist der unmittelbare technische Blocker.

## 8. Weitere momentan offene / nicht validierte Teile

Der jüngste Build-1-12-DCS-Lauf brach vor der eigentlichen Response-Ausführung ab. Daher sind in diesem Lauf insbesondere nicht nachgewiesen:

```text
physical Guard patrol along OMW_RTE_BLUE_GUARD_HONAKER_01
QRF ArmyOnMission for TPL_BLUE_GND_QRF_MIXED_6
QRF engagement behavior
PATROLZONE CAS dispatch
AH-64D R500 -> WEST corridor execution
AH-64D weapon employment
current-run Wright ARTY / M1083 rearm regression
RESUPPLY semantic dedupe at runtime
strategic AMMO demand uniqueness
CH-47 CARGOTRANSPORT allocation
cargo pickup
Wright delivery / final settlement
CH-47 physical return to Jalalabad
AIRWING asset recovery
combined Stage-3 closure
```

Keiner dieser Punkte darf aus Source-Review oder früherer Teilprovenienz als aktuell validiert dargestellt werden.

## 9. Bekannte Fehler der bisherigen Entwicklung

Für den nächsten Chat ausdrücklich beibehalten:

```text
1. QRF composition was previously inferred instead of using the owner-approved template contract.
2. OMW_RTE_BLUE_GUARD_HONAKER_01 was inferred as a GROUP from its intended use/name although the real mission registers it as PATHLINE.
3. Build 1-12 was initially implemented as an insufficiently checked post-build string-transform wrapper and the first local attempt failed.
4. The current successful Build 1-12 still uses a post-build transform wrapper; the authoritative Stage-3 source and normal builder are therefore not yet normalized to the new QRF contract.
```

Diese Fehler dürfen nicht durch weitere Patch-Kaskaden kaschiert werden.

Verbindliche Arbeitskorrektur:

```text
verify real mission object type / template contract
-> verify matching public MOOSE representation and API
-> change authoritative source directly
-> deterministic builder from source
-> local build/hash
-> DCS acceptance
```

## 10. Aktueller Source-/Builder-Status

Wichtige Stage-3-Source:

```text
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
```

Diese Source enthält noch historische Build-1-11-QRF-Strukturen und ist deshalb nicht die saubere dauerhafte Wahrheit für `TPL_BLUE_GND_QRF_MIXED_6`.

Aktueller unmittelbarer Build-1-12-Builder:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1-12.ps1
```

Er transformiert das bereits von Build 1-11 erzeugte Bundle nachgelagert. Das war eine kurzfristige Korrektur, ist aber technische Schuld.

Zielzustand:

```text
current QRF contract lives in authoritative Stage-3 source
standard builder consumes current source directly
no post-build patch chain
builder gates current QRF/Guard/CAS contracts directly
```

## 11. Guard – verbindlicher nächster MOOSE-first-Prüfpunkt

Für die Route ist aus realem DCS/MOOSE-Log und gepinntem MOOSE-Source bekannt:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01 = PATHLINE
PATHLINE:FindByName(...)
PATHLINE:GetCoordinates()
```

Noch nicht sauber bestimmt ist die physische Ground-Entität, die diese Route patrouillieren soll, sowie der beste öffentliche MOOSE-Routingpfad für diese Entität.

Der nächste Chat darf nicht wieder aus dem Routennamen eine GROUP ableiten.

Zwingende Prüfsequenz:

```text
1. current main Guard/QRF/Ground baselines inspect
2. actual physical Honaker Guard GROUP/template identify from repository/ME evidence
3. confirm OMW_RTE_BLUE_GUARD_HONAKER_01 as PATHLINE
4. inspect pinned Moose.lua for public routing methods applicable to that physical group type
5. inspect relevant official MOOSE examples/tests
6. prefer native MOOSE routing/lifecycle
7. only if a real MOOSE gap remains: document it and ask owner before any fallback
```

`OPSGROUP:Route(...)` or another MOOSE routing method must not be selected merely because it exists; the chosen method has to match the actual Guard representation and lifecycle.

## 12. Noch zu tätigende Schritte – verbindliche Reihenfolge

1. **Startcheck gegen aktuellen Stand**
   - `AGENTS.md`, Governance und MOOSE-first auf aktuellem `main` lesen.
   - `main` auf Änderungen seit `6c9b5530c5524f109e7def739bd2d01e2aa4efc6` prüfen.
   - Arbeitsbranch/HEAD/PR-Status erneut verifizieren.

2. **Guard-Entität eindeutig bestimmen**
   - Ground-/Guard-/ORBAT-/ME-Baselines durchsuchen.
   - echte physische Honaker-Guard-GROUP bzw. Template-ID feststellen.
   - keine Benennung aus `OMW_RTE_*` ableiten.

3. **MOOSE-first Guard-Routing vollständig prüfen**
   - MOOSE-Dokumentation.
   - gepinnte `Moose.lua`.
   - Signaturen/Lifecycle/Waypoints.
   - offizielle Beispiele, soweit relevant.
   - kleinsten öffentlichen Framework-Weg festlegen.

4. **Stage-3-Source normalisieren**
   - `TPL_BLUE_GND_QRF_MIXED_6` direkt in der Acceptance-Source abbilden.
   - 5 `GROUND_PERSONNEL` Debit.
   - eine QRF GROUP/Mission.
   - keine `_MIXED_4`, keine 9-Mann-Zweitgruppe, kein Embark/Disembark.

5. **Guard-Fix direkt in Source implementieren**
   - PATHLINE korrekt via MOOSE auflösen.
   - tatsächliche Guard-GROUP über den geprüften MOOSE-Routingpfad anbinden.
   - Fehler-/Lifecycle-Telemetrie so auslegen, dass Objektart und physische Deployment-Evidence getrennt erkennbar sind.

6. **Builder normalisieren**
   - regulären Stage-3-Builder aus der aktuellen Source erzeugen lassen.
   - Build-1-12-Transform-Kaskade nicht fortsetzen.
   - Gates gegen obsolete Templates/alte Guard-GROUP-Annahme ergänzen.

7. **Dokumentation reconciliieren**
   - `mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md`
   - `docs/moose/STAGE3-BUILD-1-11-RECONCILIATION.md` beziehungsweise Nachfolgedokument
   - `docs/moose/STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT.md`
   - `docs/moose/PROJECT-CLASS-INDEX.md`
   - relevante thematische MOOSE-Dokumente
   - `VERIFIED-METHODS.md` erst bei tatsächlich praktisch bestätigtem Methodenscope erweitern.

8. **Review und verfügbare Tests**
   - vollständigen Diff prüfen.
   - keine unbeabsichtigten CampaignState-/Resource-Authority-Änderungen.
   - keine Native-DCS-Ausnahme ohne Freigabe.
   - Dokumentationsvalidator / CI ausführen beziehungsweise prüfen.

9. **Remote commit/push**
   - ChatGPT committed und veröffentlicht selbst auf `agent/fire-support-strategic-resupply-alarm-evidence`.

10. **Lokaler Owner-Build**
    - erst nach Remote-Commit nummerierte PowerShell-Anweisung liefern.
    - Projektinhaber führt `git pull`, Build und Hashprüfung aus.
    - nur reale Konsole und reale Hashes sind Provenienz.

11. **Mission Editor Integration**
    - neue Stage-3-Lua in den vorhandenen DO-SCRIPT-FILE-Trigger einbetten.
    - keine `.miz`-Mutation durch ChatGPT.
    - aktuelle Guard-/QRF-/PATHLINE-ME-Voraussetzungen prüfen.

12. **Neuer vollständiger DCS-Test**
    - erst nach sauberem Build-/Hash-Gate.
    - nicht nur Preflight, sondern komplette Stage-3-Kette laufen lassen.

13. **Acceptance auswerten**
    - `dcs.log` / `debrief.log` gegen alle PASS-Kriterien prüfen.
    - Mission-/Bundle-/MOOSE-/DCS-/Commit-Provenienz dokumentieren.
    - nur bei vollständigem Erfolg `ACCEPTED_TECHNICAL_BASELINE` bzw. `validated_in_dcs: true` für den exakt getesteten Scope setzen.

14. **PR erst danach zur Entscheidung vorlegen**
    - PR #144 bleibt bis dahin DRAFT.
    - Ready-for-Review und Merge ausschließlich nach ausdrücklicher Eigentümerfreigabe.

## 13. Erwartete Beobachtungen im nächsten vollständigen DCS-Test

Der nächste echte Gesamt-Test soll mindestens sichtbar/telemetrisch nachweisen:

```text
Honaker alarm creates one incident
alarm perimeter clear does not terminate response
Guard physically patrols owner-authored Honaker PATHLINE
one mixed QRF group deploys: 5 infantry + 1 MRAP
QRF is recruited from the intended MOOSE cohort/platoon only
QRF can engage relevant detected hostile ground groups
Wright ARTY fires and retargets real incident participants
AH-64D CAS is dispatched through PATROLZONE + SetEngageDetected
AH-64D follows R500 -> WEST owner-authored corridor without prior lifecycle oscillation
AH-64D performs real weapon employment or produces a clearly diagnosable MOOSE/DCS limitation
M1083 physically rearms Wright ARTY
CampaignState Wright AMMO 16 -> 15 exactly once
exactly one strategic RESUPPLY exists after semantic dedupe
Jalalabad CH-47 is allocated from SQ_US_JBAD_CH47_HEAVYLIFT
physical cargo pickup occurs
Wright receives 15 GROUND_AMMO_PACKAGE
final expected strategic stock: Wright 30, Jalalabad 85
CH-47 physically returns to Jalalabad
AIRWING recovers the asset after physical return
all known attack participants are neutralized / incident closes by its tactical completion rule
no duplicate settlement / no duplicate MissionDemand SUCCESS
```

## 14. Aktuelle Dateien / Artefakte

Wichtigste Runtime-/Source-Dateien:

```text
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterMissionOwnedCorridor.lua
scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
scripts/ground/OMW_GroundInstallationAttackIncident.lua
scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua
scripts/ground/OMW_GroundPersonnelDeploymentLedger.lua
scripts/ground/OMW_GroundAmmoRearmAdapter.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua
scripts/ground/OMW_GroundSupportMaterializer.lua
scripts/campaign/OMW_CampaignState.lua
scripts/campaign/OMW_MissionDemand.lua
scripts/campaign/OMW_ResourceDemandPolicy.lua
scripts/campaign/OMW_ResourceDemandCoordinator.lua
scripts/campaign/OMW_FobAttackDemandPolicy.lua
scripts/campaign/OMW_FobAttackFireSupportDemandPolicy.lua
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
tools/build-stage3-honaker-wright-full-response-acceptance-1-12.ps1
```

Zuletzt real gebautes Stage-3-Bundle:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply\mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
SHA-256: 62C31BFCF877F97C2F3FDECE57A2AF0C596B56F9343FF5DB9B9F6F50F7360826
```

Mission des jüngsten realen DCS-Laufs:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v21_GroundWorks.miz
```

## 15. Upload-/Werkzeuggrenze dieser Sitzung

Die aktuelle `.miz` wurde mehrfach durch den Chat-Upload angekündigt, erschien jedoch nicht im aktiven Runtime-Mount. Daher konnte sie in dieser Sitzung nicht direkt als ZIP geöffnet werden.

Das ist keine Aussage über die Gültigkeit der Mission. Die in dieser Übergabe genannten aktuellen Mission-Editor-Fakten stammen aus dem realen DCS-/MOOSE-Log des ausgeführten Missionsstands.

Im Log bestätigt:

```text
TPL_BLUE_GND_QRF_MIXED_6             GROUP with six registered units
OMW_FlightPath_R500                  PATHLINE with 84 points
OMW_FlightPath_WEST                  PATHLINE with 34 points
OMW_RTE_BLUE_GUARD_HONAKER_01        PATHLINE with 13 points
```

Wenn die `.miz` im nächsten Chat tatsächlich als Datei zugreifbar ist, soll sie als ZIP direkt geprüft werden. Ein angeblicher Missionsinhalt darf nicht aus Upload-Metadaten allein behauptet werden.

## 16. Statusmatrix bei Übergabe

```text
Governance / MOOSE-first baseline             CHECKED against main 6c9b5530...
Stage-3 branch                                ACTIVE
PR #144                                       OPEN / DRAFT
Combined Stage-3 DCS acceptance               FAIL / NOT VALIDATED
Alarm -> incident semantics                   previously DCS evidenced
Wright ARTY fire / retarget                   previously DCS evidenced for older exact scope
M1083 local ARTY rearm                        previously DCS evidenced for older exact scope
CampaignState Wright 16 -> 15                 previously DCS evidenced for older exact scope
Reorder threshold 15 / 30                     previously DCS evidenced for older exact scope
RESUPPLY dedupe source correction             IMPLEMENTED / current-runtime recheck pending
CAS PATROLZONE/corridor corrections           IMPLEMENTED / DCS PENDING
QRF current template availability             CONFIRMED in latest DCS log
QRF current physical dispatch                 NOT REACHED
Guard PATHLINE availability                   CONFIRMED in latest DCS log
Guard physical patrol                         FAIL BLOCKED by wrong object-type assumption
CH-47 strategic CARGOTRANSPORT                NOT REACHED in latest run
Build 1-12 local build/hash                   PASS
Build 1-12 source architecture                TECHNICAL DEBT / normalization required
Direct current MIZ ZIP inspection             BLOCKED by current chat upload/mount issue
Ready for Review                              NOT AUTHORIZED
Merge                                         NOT AUTHORIZED
```

## 17. Startauftrag für den nächsten Chat

Der nächste Chat soll **nicht sofort einen neuen DCS-Test anfordern** und **nicht einfach `GROUP:PatrolRoute()` ersetzen**.

Erster Arbeitsauftrag:

```text
Governance/current main check
-> current branch/PR check
-> identify actual physical Honaker Guard group/template from project evidence
-> verify PATHLINE-to-ground-routing path in pinned MOOSE docs/source/examples
-> normalize Stage-3 source to QRF_MIXED_6
-> implement smallest MOOSE-first Guard routing correction
-> normalize builder
-> update docs/class index
-> review/test/commit/push
-> owner local PowerShell build/hash
-> only then new DCS acceptance
```

Keine MOOSE-Methode, Mission-Editor-Objektart, Hash oder Runtime-Wirkung darf geraten werden.
