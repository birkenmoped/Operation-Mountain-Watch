---
document_id: OMW-HANDOFF-FSSR-FINAL-BASE-PREPARATION-20260920
status: PLANNED
document_class: CHAT_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current Fire Support / Strategic Resupply branch status handoff
  - preparation state for final _base reconciliation
  - preservation of accepted lifecycle knowledge between chats
not_authoritative_for:
  - repository-wide governance before merge to main
  - new owner decisions
  - DCS validation outside explicitly cited acceptance provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-HANDOFF-FSSR-STATUS-APPENDIX-20260913
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – vollständige Übergabe zur finalen `_base`-Vorbereitung

## 1. Zweck

Diese Übergabe ist der verbindliche Arbeitskontext für den nächsten Chat auf

```text
agent/fire-support-strategic-resupply-base-gate0
PR #149
```

Sie fasst den aktuellen Entwicklungsstand, die realen DCS-Acceptances, die festgefrorenen Lifecycle-Regeln, die noch offenen Grenzen und die Reihenfolge bis zur finalen allgemeinen Fire-Support-/Strategic-Resupply-`_base` zusammen.

Sie ist **keine neue Governance-Autorität**. Bei Widersprüchen gilt ausschließlich die Autoritätshierarchie aus `main:docs/00-project-governance.md`.

## 2. Pflicht-Lesereihenfolge des Folgechats

Vor jeder weiteren Analyse oder Änderung muss der Folgechat zuerst vollständig die aktuellen `main`-Fassungen lesen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
```

Danach auf diesem Branch mindestens:

```text
docs/adr/0008-fire-support-strategic-resupply-resource-authority.md
docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-ASSEMBLY.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GUARD-PRODUCTION-INTEGRATION.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME.md
docs/moose/VERIFIED-METHODS.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-9.md
```

Für ARTY/Rearm vor jeder Implementierung zusätzlich die vorhandenen Stage-3-/Functional-ARTY-/Ground-Ammo-Rearm-Entscheidungen und Acceptance-Dokumente lesen. Für Strategic Resupply zusätzlich die aktuellen OPSTRANSPORT-/STORAGE-/Settlement-Dokumente.

## 3. Arbeitsanweisungen aus `main`

Die folgenden Regeln sind keine Empfehlung, sondern Arbeitsvoraussetzung.

### 3.1 Autorität

Bei Widerspruch gilt:

```text
1. ausdrückliche Owner-Entscheidung in Governance/ADR auf main
2. BINDING_PROJECT_DECISION / BINDING auf main
3. exakte DCS-Acceptance-Provenienz
4. Fachmanifest / aktuelle Arbeitsliste
5. ältere Handoffs / Tests / PRs
6. externe historische Evidenz
```

Branch-lokale Dokumente können einen technisch validierten exakten Stand dokumentieren, überschreiben aber `main` nicht automatisch.

### 3.2 MOOSE first

Verbindlicher Entwicklungsweg:

```text
passende MOOSE-Dokumentation
-> tatsächlich gepinnte Moose.lua
-> Signaturen / Rückgaben / FSM / Events / Voraussetzungen
-> offizielle MOOSE-Demos/Tests soweit relevant

MOOSE direkt
-> konfigurieren/kombinieren
-> Events / Callbacks / FSM
-> kleiner Adapter
-> Native DCS / eigene Parallelimplementierung nur nach dokumentierter Lücke + Owner-Freigabe
```

Keine MOOSE-Klasse, Methode, Event-Signatur oder Rückgabe erfinden.

Kein MIST ohne genehmigte Ausnahme.

### 3.3 Ressourcenautorität

Für diesen FSSR-Scope gilt ADR 0008:

```text
fachlicher Bedarf / MissionDemand / Incident
-> MOOSE organisation / public mission or transport
-> MOOSE selects/recruits operational provider/assets
-> MOOSE/DCS physical lifecycle
-> confirmed physical lifecycle event
-> idempotent CampaignState strategic booking
```

CampaignState ist strategische Persistenz-/Rechtsautorität, aber kein zweiter operativer Asset-Selector und keine zweite MOOSE-Queue.

### 3.4 DCS-/Lua-Regeln

- globale Variablen vermeiden; Module als Tables zurückgeben;
- stabile Entity-/Resource-IDs statt DCS-Gruppennamen als strategische Identität;
- DCS-Objekte vor Zugriff validieren;
- Zustandswechsel/Fehler mit IDs loggen;
- keine unbegründeten High-Frequency-Scheduler oder Frame-Scans;
- Ground-AI-Pathfinding nicht als deterministisch behandeln;
- keine beobachtbaren Teleports/Spawns/Despawns;
- `MissionScripting.lua` nicht automatisch ändern;
- keine Schreibzugriffe außerhalb des vorgesehenen Persistenzbereichs.

### 3.5 Verifikation

Nach jeder relevanten Änderung:

```text
syntax
-> unit/contract tests
-> full diff review
-> MOOSE source/docs check
-> documentation validator
-> explicit statement of what still needs DCS
```

`VALIDATED` als technische Behauptung nur nach realem DCS-Test. Für Frontmatter ausschließlich die in `DOCUMENT-METADATA-POLICY.md` zugelassenen Governance-Statuswerte verwenden.

### 3.6 GitHub-Workflow

ChatGPT:

```text
inspect
-> implement
-> review diff/tests/docs/MOOSE-first
-> commit
-> push to the designated remote branch
```

Erst danach erhält der Projektinhaber eine nummerierte PowerShell-Anweisung für:

```text
git pull
build
hash verification
```

Lokale Builds, Hashes oder DCS-Verhalten niemals simulieren oder annehmen.

PR #149 bleibt Draft, bis der Projektinhaber ausdrücklich etwas anderes entscheidet.

Kein CODEX.

### 3.7 MIZ-Grenze

Der Projektinhaber ist allein für Mission-Editor-/`.miz`-Arbeit zuständig.

ChatGPT:

```text
does NOT search for .miz
does NOT request .miz
does NOT inspect .miz
does NOT mutate/repack .miz
does NOT provide .miz-discovery tooling
```

ChatGPT liefert Source/Builder/Bundle/Docs; der Owner integriert die gebaute LUA selbst in seinen Teststand.

## 4. Repository-/Branch-Zustand

Bei Erstellung dieser Übergabe:

```text
repository:
birkenmoped/Operation-Mountain-Watch

main:
980340c9225a81921aed8995aa8f50cad7d1c215

working branch:
agent/fire-support-strategic-resupply-base-gate0

PR:
#149
Draft

branch relation before this handoff documentation series:
ahead of main, behind main = 0
```

Der Branch enthält den vollständigen FSSR-Entwicklungsverlauf seit Gate 0. Nicht aus der hohen Commit-Anzahl ableiten, dass alle Branch-Dokumente `main`-Autorität besitzen.

## 5. Gepinnter MOOSE-Stand

```text
release:
2.9.18

commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Relevante, für den aktuellen CAS-Pfad source-geprüfte bzw. A9-praktisch belegte Verträge stehen in `docs/moose/VERIFIED-METHODS.md`.

## 6. Aktuelle FSSR-Architektur

```text
Installation evidence / MOOSE OPSZONE
-> authoritative GroundInstallationAttackIncident
-> Base / Incident bridge
-> local Guard + QRF
-> explicit C2 escalation for external support

CAS:
Base demand
-> CasMissionFactory
-> CommanderBridge
-> MOOSE COMMANDER / LEGION selection
-> CasLifecycleRuntime
-> owner route / tactical corridor
-> own FLIGHTGROUP detection
-> profile-specific release
-> shared mission closure
-> reverse owner route
-> home landing
-> exact LegionAssetReturned

ARTY:
Base demand
-> generic target handoff / COMMANDER / AUFTRAG path is source-reviewed
-> integration with accepted Functional ARTY + M1083 rearm remains unresolved

Strategic Resupply:
CampaignState strategic demand
-> OPSTRANSPORT/STORAGE production components are source/contract-tested
-> concrete physical full lifecycle + settlement remains to be DCS-accepted
```

## 7. Festgefrorene Lifecycle-Gesetze

### 7.1 Lifecycle-Preservation Law

Jeder bereits akzeptierte oder bindend festgelegte Lifecycle muss:

```text
inherit
-> reuse
-> minimally adapt
-> preserve invariants
-> test only the changed boundary
```

Nicht zulässig:

```text
copy concepts
-> rebuild state machine in Acceptance
-> assume equivalence
```

Wenn ein Acceptance-Harness Routing, Targeting, Release, RTB/Recovery, ReturnToLegion oder Settlement selbst implementieren müsste, ist die Funktion zuerst in gemeinsamen Production-Code zu extrahieren.

### 7.2 Acceptance-Harness-Gesetz

Acceptance darf:

```text
activate fixture
observe events
collect evidence
assert invariants
PASS / FAIL
```

Acceptance darf nicht zweite Autorität werden für:

```text
routing
target selection
mission completion
CAS release
RTB/recovery
ReturnToLegion
asset settlement
strategic resources
```

### 7.3 Watchdog-Gesetz

```text
watchdog elapsed
-> WARN
-> continue observing production lifecycle
```

Watchdog darf nicht Mission, Release, RTB, Settlement oder Lifecycle-Monitoring beenden.

A7 ist Negativ-Evidenz: ein terminaler Acceptance-Timeout stoppte das eigene Monitoring, während MOOSE weiterflog.

### 7.4 Alarmzonen-Gesetz

```text
FOB/COP/OP alarm zone
= threat-detection / response-trigger boundary
!= tactical battlespace
!= WEZ
!= ARTY target area
!= CAS engagement area
!= mission-end condition
```

Perimeter clear oder `OPSZONE:Defeated` beendet QRF/ARTY/CAS nicht automatisch.

### 7.5 QRF-Lifecycle

Akzeptierte A4-8-Baseline:

```text
ONGUARD recruitment/materialization anchor
-> same physical ARMYGROUP
-> authoritative incident participants
-> nearest living authorized UNIT
-> EngageTarget(..., "On Road")
-> Disengage -> reacquire
-> no living authorized targets
-> Cancel
-> SetReturnToLegion(true)
-> RTZ / Returned
```

Kein `GROUNDATTACK`, kein eigener World-Scan, kein eigener Target-Scheduler, kein eigener Straßenrouter, kein Release nur wegen Perimeter-Clear.

### 7.6 Guard-Lifecycle

```text
NORMAL
-> no physical Guard

qualified installation incident
-> incident-local ONGUARD
-> local security only
-> no permanent PATHLINE patrol
-> no proactive chase

authoritative incident close
-> Cancel
-> MOOSE ReturnToLegion
```

### 7.7 CAS-Lifecycle – A9 validierte Reuse-Baseline

Exakte Validation:

```text
source commit:
c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2

Acceptance bundle SHA-256:
D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0

DCS:
2.9.29.27468

MOOSE:
2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

result:
PASS
```

Validierte Kette:

```text
MOOSE provider/asset selection
-> selected-provider owner profile
-> owner-authored outbound route
-> tactical ingress / mission / distinct egress
-> AUFTRAG executing
-> own FLIGHTGROUP detection
-> profile-specific supported-element/no-contact release
-> controlled mission closure
-> reverse owner route
-> physical home landing
-> exact LegionAssetReturned
-> lifecycle complete
-> PASS
```

Verbindliche Invarianten:

```text
MOOSE selects operational provider and asset.
OMW does not preselect the concrete CAS asset.
Unknown selected-provider profile -> fail closed.
No direct-line fallback.
OpsOnMission != PASS.
MissionDone != physical recovery.
FuelLow/Bingo != normal completion.
Release policy is explicit and profile-specific.
nil detection != no contact.
Home landing required.
Exact asset return required.
```

### 7.8 A9 Release-Policy-Grenze

Die 30 Sekunden aus A9 sind **keine globale Base-Regel**.

A9-Testprofil:

```text
SUPPORTED_ELEMENT_STABLE_NO_CONTACT
stableNoContactSec = 30
```

Ein anderer CAS-Typ/Provider darf eine andere genehmigte Release-Policy besitzen. Die konkrete Policy muss explizit injiziert werden.

### 7.9 Post-return-Despawn-Gesetz

Aus dem ersten A9-Lauf:

```text
exact LegionAssetReturned
-> authoritative return confirmation
-> later physical DCS group removal/despawn is cleanup
-> CountAliveUnits()==0 after return is NOT asset loss
```

Loss-Monitoring auf der temporären physischen Repräsentation endet nach bestätigtem exact asset return.

Landing allein ersetzt den Return-Event nicht.

### 7.10 ARTY-Lifecycle-Gesetz

Akzeptierte Functional-ARTY-/M1083-Rearm-Evidenz darf nicht durch einen zweiten Owner zerstört werden.

```text
same battery
-> one Functional ARTY FSM owner
-> Winchester / Rearm / Rearming / Rearmed
-> physical M1083 rearm
```

Nicht zulässig:

```text
same battery
-> Functional ARTY FSM
AND
-> independent AUFTRAG:NewARTY mission owner
```

Die generische Base muss diese Grenze zuerst reconciliieren; kein deterministischer Testprovider darf sie umgehen.

## 8. Acceptance-Verlauf und wichtige Irrwege

### A6 – REJECTED

MOOSE-Selektion funktionierte. Der Fehler war:

```text
selected provider
-> no owner execution profile bound
-> direct route
-> PASS too early at OpsOnMission
-> later FuelLow/direct RTB/loss
```

Lehre: globale COMMANDER-Auswahl ist nicht das Problem. Fehlende provider-spezifische Ausführungsbindung war das Problem.

### A7 – REJECTED

Owner-Route funktionierte. Der Fehler war:

```text
Acceptance timeout
-> state.failed
-> Acceptance stopped CAS lifecycle monitoring
-> MOOSE mission continued
-> regular release never happened
-> FuelLow path
```

Lehre: Acceptance-Timeout darf niemals Production-Lifecycle-Authority werden.

### A8 – nicht freigegeben

A8 korrigierte Teile der A7-State-Machine, blieb aber noch zu stark Acceptance-eigener Lifecycle. Nach Einführung des Lifecycle-Preservation-Gesetzes wurde A8 nicht als DCS-Kandidat weitergeführt.

### A9 – PASS

A9 extrahierte Lifecycle-Ownership in Production-Code und machte den Harness observer-only.

Erster A9-Lauf:

```text
route/release/recovery chain succeeded
-> post-return physical despawn
-> diagnostic CountAliveUnits falsely classified asset as lost
-> false terminal FAIL
```

Korrektur:

```text
asset-loss monitoring only before exact asset return
```

Finaler A9-Lauf:

```text
CAS_PROVIDER_PROFILE_BOUND
CAS_MISSION_ASSIGNED
CAS_OWNER_CORRIDOR_INSTALLED
CAS_EXECUTING
CAS_SUPPORTED_ELEMENT_CLEAR
CAS_NO_CONTACT_REPORTED
CAS_CONTROLLED_RELEASE
CAS_HOME_LANDED
CAS_LEGION_ASSET_RETURNED
CAS_LIFECYCLE_COMPLETE
[PRODUCTION BASE A9][PASS]
```

Kein FuelLow vor Release. Kein falscher post-return Assetverlust.

## 9. Aktueller produktiver CAS-Code

```text
scripts/campaign/OMW_FireSupStratResupply_CasMissionFactory.lua
scripts/campaign/OMW_FireSupStratResupply_CommanderBridge.lua
scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua
scripts/campaign/OMW_FireSupStratResupply_CasReleasePolicy.lua
scripts/air-operations/OMW_FobAttackCasPatrolClosure.lua
scripts/air-operations/OMW_FlightPathNameContract.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterCasTacticalCorridor.lua
```

A9-Harness:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/09-production-cas-lifecycle-acceptance.lua
```

Dieser Harness darf kein Production-Lifecycle-Owner werden.

## 10. Final-`_base`-Vorbereitungsstatus

### Bereits tragfähig / eingefroren

```text
Governance / MOOSE-first / lifecycle preservation
ADR 0008 resource/selection authority
installation alarm semantics
incident-local Guard contract
QRF direct-target / On Road / ReturnToLegion contract
generic COMMANDER bridge
CAS MOOSE selection
CAS owner-route binding
CAS own-detection
CAS profile-specific release
CAS controlled closure
CAS reverse recovery
CAS home landing
CAS exact asset return
post-return cleanup semantics
```

### Noch offen vor einer finalen Full-Response-`_base`

```text
A. ARTY reconciliation
   generic COMMANDER/AUFTRAG handoff
   <-> accepted Functional ARTY + M1083 rearm lifecycle

B. Strategic Resupply physical lifecycle
   pickup/deploy/STORAGE descriptors
   OPSTRANSPORT execution
   delivery/loss evidence
   idempotent CampaignState settlement

C. PARTIAL resupply only if truly required
   no implicit full delivery

D. Combined full-response integration
   reuse frozen Ground/Guard/QRF/CAS lifecycles
   test only new ARTY/Resupply/orchestration boundaries

E. Final _base reconciliation
   source/docs/builders/acceptance matrix
   remove/reject obsolete test-only lifecycle ownership
   preserve exact provenance
```

Not automatically covered by A9:

```text
fixed-wing CAS
other CAS provider profiles
other site-specific execution profiles
ARTY
ARTY rearm
Strategic Resupply
combined end-to-end response
```

## 11. Nächster technischer Arbeitsblock

Der nächste Chat darf **nicht** wieder CAS anfassen, nur weil ein neuer Full-Response-Test vorbereitet wird.

Vor neuem Code:

```text
1. read main governance + MOOSE-first
2. read lifecycle preservation law + implementation matrix
3. identify accepted Functional ARTY/rearm source and exact DCS evidence
4. inspect pinned MOOSE ARTY/COMMANDER/Warehouse APIs actually needed
5. create lifecycle-inheritance table for ARTY
6. determine whether generic CommanderBridge can hand off into the existing Functional ARTY owner
7. if no public MOOSE path exists, document the exact gap
8. do not implement a non-MOOSE bridge without owner approval
```

Erst wenn ARTY einen eindeutigen Single-Owner-Lifecycle besitzt, den Strategic-Resupply-Block separat weiterführen.

## 12. Final-`_base` Acceptance-Grundsatz

Die finale `_base` darf nicht wieder zu einem monolithischen Acceptance-Harness werden.

Soll:

```text
frozen production lifecycles
+ smallest new composition glue
+ observer-only acceptance
```

Nicht:

```text
one giant harness
-> reimplements QRF
-> reimplements CAS
-> reimplements ARTY
-> reimplements resupply
```

PASS einer späteren Combined Acceptance darf erst aus den jeweiligen produktiven Lifecycle-Evidenzen entstehen.

## 13. CI-/Dokumentations-Grenze

Vor Übergabe/Build:

```text
MissionDemand validation = green
Documentation validation = green
```

Die Dokumentationsvalidierung ist besonders wichtig, weil Frontmatter-Statuswerte Governance-konform sein müssen. `VALIDATED` ist kein zulässiger Frontmatter-`status`; DCS-Validierung wird über `validated_in_dcs: true` und einen separaten Validation-Status/Resultatabschnitt dokumentiert.

## 14. Git-/Merge-Grenze

PR #149 bleibt Draft.

Der Branch ist die Arbeits- und Evidenzbasis für die weitere Final-`_base`-Vorbereitung.

Kein Ready-for-Review, kein Merge nach `main`, keine Architektur-Ausnahme ohne ausdrückliche Owner-Freigabe.

Vor einem späteren Merge müssen insbesondere:

```text
PENDING_MERGE metadata
document registry
subproject registry where applicable
supersession state
final source_commit provenance
documentation validation --main
```

sauber reconciliert werden.

## 15. Kurztext für einen neuen Chat

Dem Folgechat kann als Startanweisung gegeben werden:

```text
Arbeite auf agent/fire-support-strategic-resupply-base-gate0 weiter und halte PR #149 Draft. Lies zuerst vollständig main:AGENTS.md, main:docs/00-project-governance.md, main:docs/26-moose-first-development-policy.md und main:docs/DOCUMENT-METADATA-POLICY.md. Lies danach docs/handoffs/2026-09-20-fssr-final-base-preparation-handoff.md, docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md, docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md und ADR 0008. Der Rotary-Wing-CAS-Base-Lifecycle aus Acceptance 9 ist für seine exakte Provenienz real DCS-validiert und darf nicht neu implementiert werden. Beginne mit der ARTY-Reconciliation gegen den bereits akzeptierten Functional-ARTY/M1083-Rearm-Lifecycle. Kein neuer ARTY-Owner, keine parallele Lifecycle-State-Machine, keine Nicht-MOOSE-Lösung ohne Owner-Freigabe. Danach Strategic Resupply separat, erst anschließend Combined Full Response und finale _base-Reconciliation. Keine .miz-Arbeit durch ChatGPT. Kein CODEX.
```

## 16. Kernregel

```text
Governance
-> accepted lifecycle
-> exact production source
-> MOOSE-first
-> smallest new boundary
-> static/unit/CI
-> owner-local build/hash
-> real DCS evidence
-> only then acceptance

Never:
working behavior
-> rewrite inside next harness
```
