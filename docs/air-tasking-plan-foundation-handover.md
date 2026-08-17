---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION-HANDOVER
status: DRAFT
document_class: HANDOVER_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local handover state for agent/air-tasking-plan-foundation
  - immediate continuation order for the Air Tasking Plan foundation work
  - known local/remote divergence requiring inspection before further local integration
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - unknown local commits not present on the remote branch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Handover

## 1. Zweck

Diese Datei dient der Übergabe der weiteren Arbeit am Branch `agent/air-tasking-plan-foundation` an einen neuen Chat. Sie fasst den verifizierten Projektstand, die verbindlichen Arbeitsgrenzen, die offenen Phase-2-Punkte und die aktuell festgestellte lokale Git-Divergenz zusammen.

Vor jeder weiteren Umsetzung gelten unverändert:

```text
AGENTS.md
→ docs/00-project-governance.md
→ docs/26-moose-first-development-policy.md
→ zuständige Air-Tasking-/CampaignState-/MOOSE-Dokumente
→ tatsächlicher Branch-/Commit-Ist-Stand
```

Keine MOOSE-API, kein DCS-Verhalten, kein Commit, kein Hash und kein Testergebnis darf geraten werden.

## 2. Repository- und Branch-Kontext

```text
repository: birkenmoped/Operation-Mountain-Watch
working branch: agent/air-tasking-plan-foundation
main head at last merge-readiness assessment: 08f679926e5ac059e9853f54ffa7bb634063eaa4
merge base at that assessment: d9150f96fac5b546fe515c89fd139851c6e9829b
```

Der Foundation-Branch war beim letzten Merge-Readiness-Vergleich:

```text
40 commits ahead of main
3 commits behind main
```

Die drei damals neueren `main`-Commits betrafen Kunar/FOB-Bostick-Reconciliation. Ein Merge auf `main` wurde bewusst noch nicht empfohlen, weil Phase 2 / Gate 2 noch offen ist und der Branch vor Integration ohnehin erneut gegen den dann aktuellen `main` reconciliiert werden muss.

## 3. Kritischer aktueller Git-Zustand

Der letzte lokale Versuch des Projektinhabers, den Remote-Stand per Fast-Forward zu übernehmen, ist fehlgeschlagen:

```text
git pull --ff-only origin agent/air-tasking-plan-foundation

remote update observed:
b2fd8b6..a9e643c

result:
fatal: Not possible to fast-forward, aborting.
```

Danach meldete die lokale Arbeitskopie:

```text
local HEAD:
e6e0bdeea991f51745c05ed214bf4176e5abbd11

remote branch included at least:
a9e643cf734a7f2e641e8ae152e8a06fad6683fd
```

Damit gilt verbindlich:

```text
LOCAL AND REMOTE HAVE DIVERGED
```

Der Inhalt des lokalen Commits beziehungsweise der lokalen nur dort vorhandenen Commits ist in diesem Handover **nicht bekannt** und darf nicht geraten werden.

### Sperre bis zur Klärung

Vor lokalem Merge, Rebase, Reset, Force-Push oder sonstiger History-Umschreibung muss zuerst exakt ermittelt werden:

```text
welche Commits nur lokal vorhanden sind
welche Commits nur auf origin vorhanden sind
welche Dateien der lokale Commit e6e0bde... verändert
ob es Überschneidungen mit den neuen Phase-2-Dokumenten gibt
```

Keine lokale Arbeit darf verworfen werden.

## 4. Bekannte lokale untracked Artefakte

Die folgenden Dateien/Verzeichnisse sind bereits vorhandene lokale Build-/Testartefakte und **nicht** Teil der Air-Tasking-Arbeit. Nicht löschen, nicht hinzufügen, nicht bereinigen:

```text
airborne-ammo-partial-consumption-build.txt
airops-storage-fuel-template-census-v2-build.txt
bullseye-documentation-validation.txt
mission/tests/aar-fuel-telemetry/
mission/tests/aar-kc135-runtime/dist/
mission/tests/aar-production-integration/AAR-PRODUCTION-FINAL-ACCEPTANCE-6-build.txt
mission/tests/aar-production-integration/AAR-PRODUCTION-FINAL-ACCEPTANCE-7-build.txt
mission/tests/aar-production-integration/AAR-PRODUCTION-FINAL-ACCEPTANCE-7-ingress-fix-build.txt
mission/tests/aar-production-integration/dist/
mission/tests/air-ops-warehouse-bootstrap/dist/
mission/tests/airborne-ammo-parking-correlation/
mission/tests/airborne-ammo-partial-consumption/
mission/tests/airops-storage-fuel-template-census/
mission/tests/bagram-air-operations/dist/
mission/tests/campaignstate-recovery-settlement/
mission/tests/campaignstate-resource-transactions/
mission/tests/campaignstate-storage-multinode-sync/
mission/tests/campaignstate-storage-special-cases/
mission/tests/campaignstate-storage-sync/
mission/tests/cree-bullseye-coordinate/
mission/tests/fighter-store-runtime-correlation/
mission/tests/jalalabad-air-operations/dist/
mission/tests/kandahar-air-operations/
mission/tests/salerno-air-operations/
mission/tests/shindand-air-operations/dist/
mission/tests/storage-airwing-weapon-lifecycle/
mission/tests/storage-client-fuel-exchange/
mission/tests/storage-client-rearm-exchange/
mission/tests/storage-forced-landing-recovery-v1/
mission/tests/storage-fuel-adapter/
mission/tests/storage-physical-loss-recovery/
mission/tests/storage-resource-integration-final/
mission/tests/storage-weapon-consumption-correlation/
mission/tests/storage-weapon-item-matrix/
mission/tests/tarinkot-air-operations/dist/
mission/tests/warehouse-resource-final-acceptance/
storage-airwing-weapon-lifecycle-v5-build.txt
storage-airwing-weapon-lifecycle-v6-build.txt
```

## 5. Verbindliche Entwicklungsphasen

Der festgelegte Arbeitsplan bleibt:

```text
PHASE 0  Governance / Reconciliation / Contracts
PHASE 1  Domain Data Model
PHASE 2  MOOSE-First Capability Verification
PHASE 3  First Vertical Integration – AAR
PHASE 4  Player-Facing Mission Products
PHASE 5  Ground Alert / CAS Request Lifecycle
PHASE 6  Dynamic Planning / Retasking / Persistence
```

Aktueller fachlicher Status:

```text
PHASE 0  PASS
PHASE 1  PASS
PHASE 2  IN PROGRESS
PHASE 3  BLOCKED BY GATE 2
PHASE 4  NOT STARTED
PHASE 5  NOT STARTED
PHASE 6  NOT STARTED
```

Die Phase-0-/Phase-1-PASS-Werte gelten branch-lokal für Architektur und Contracts. Sie sind kein DCS-Runtime-Nachweis.

## 6. Architekturgrenzen

### Strategische Autorität

```text
CampaignState
= strategischer Zustand
= Ressourcenautorität
= Reservation / Settlement / Persistence authority
```

`MissionDemand` bleibt die autoritative kampagnenweite Auftrags-/Bedarfsidentität.

### Air-Tasking-Domain

```text
MissionDemand
    ├── direct tasking innerhalb verifizierter Tasking Authority
    │
    └── AIR_SUPPORT_REQUEST über Authority-Grenze
            ↓
        AIR_TASKING_MISSION / AIR_TASKING_PLAN
```

`AIR_TASKING_MISSION != MOOSE AUFTRAG`.

### MOOSE-Ausführung

Der bisher source-geprüfte Zielpfad lautet:

```text
CampaignState / MissionDemand
        ↓
Air Tasking Domain
        ↓
small OMW adapter
        ↓
COMMANDER
        ↓
AIRWING / BRIGADE
        ↓
SQUADRON / PLATOON
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
```

Keine parallele OMW-Command-/Asset-Dispatcher-Engine aufbauen.

## 7. CHIEF-Entscheidung

Für diesen Air-Tasking-Pfad gilt:

```text
CHIEF = REJECTED_FOR_PROJECT_USE
```

Grund:

```text
CHIEF
= INTEL-basierte strategische Ziel-/Strategie-/Response-Schicht
= erzeugt/verwendet eigenen COMMANDER
= würde CampaignState/MissionDemand/Air-Tasking-Autorität überlappen
```

Es wird **keine eigene CHIEF-Nachbildung** erstellt.

## 8. COMMANDER-Entscheidung

`COMMANDER` ist der vorgesehene operative MOOSE-C2-/Mission-Assignment-Layer unterhalb der OMW-Domain.

Source-geprüft am gepinnten MOOSE-Stand sind unter anderem:

```text
COMMANDER:New(...)
COMMANDER:AddLegion(...)
COMMANDER:AddMission(...)
COMMANDER:CanMission(...)
COMMANDER:RecruitAssetsForMission(...)
COMMANDER:MissionAssign(...)
COMMANDER:MissionCancel(...)
OpsOnMission FSM event
```

`COMMANDER:CanMission(...)` bedeutet nur, dass MOOSE grundsätzlich geeignete Cohorts besitzt. Es ist **kein** Ersatz für CampaignState-Verfügbarkeit oder strategische Reservation.

## 9. AIRWING / BRIGADE

Beide sind aktive `LEGION`-Layer und keine bloßen Container.

```text
AIRWING -> SQUADRON
BRIGADE -> PLATOON
```

Source-geprüft sind Mission Queue, Cohort-/Asset-Verwaltung und direkte `AddMission(...)`-Pfade.

Wichtige Grenze:

```text
MOOSE autonomous mission generation
!= OMW MissionDemand authority
```

Autonome AIRWING-/BRIGADE-Funktionen dürfen den autoritativen MissionDemand-/CampaignState-Pfad nicht stillschweigend umgehen.

Zusätzlich ist bei AIRWING auf Ressourcen-Seiteneffekte des MOOSE-/STORAGE-Unterbaus zu achten; diese dürfen niemals als strategische Ressourcenerzeugung interpretiert werden.

## 10. SQUADRON / PLATOON – letzter Remote-Arbeitsschritt

Der letzte von ChatGPT auf den Remote-Branch veröffentlichte fachliche Arbeitsschritt war:

```text
commit:
a9e643cf734a7f2e641e8ae152e8a06fad6683fd

message:
docs: verify SQUADRON and PLATOON Air Tasking boundary

file:
docs/air-tasking-plan-phase2-squadron-platoon-capability-verification.md
```

Geprüft wurde der gemeinsame `COHORT`-Unterbau sowie `SQUADRON` und `PLATOON`.

Source-geprüfte Kernaussagen:

```text
SQUADRON extends COHORT
PLATOON extends COHORT

COHORT:AddMissionCapability(...)
= native Mission-Capability-/Performance-Abbildung
```

Damit bleibt die Grenze:

```text
OMW domain
= strategische Verfügbarkeit / MissionDemand / Authority / Reservation

MOOSE COHORT
= Mission Capability / Performance / operative Cohort-Eignung
```

Keine parallele OMW-Capability-/Scoring-Engine entwickeln.

Wichtig: Wegen der anschließend festgestellten lokalen Git-Divergenz wurden Manifest, Current-Status und PROJECT-CLASS-INDEX nach diesem neuen SQUADRON-/PLATOON-Dokument **noch nicht weitergeschaltet**. Der neue Chat muss nach Klärung der Git-Divergenz prüfen, ob und wie diese Nachpflege vorgenommen wird.

## 11. Gepinnter MOOSE-Stand

Verbindlich für Phase 2:

```text
MOOSE context/branch: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Jede API-Nutzung muss gegen diesen tatsächlichen Stand geprüft werden:

```text
MOOSE documentation
→ pinned Moose.lua / source
→ signatures / returns / side effects / FSM
→ official MOOSE demos/tests where relevant
```

Dokumentation allein beweist keine Verfügbarkeit.

## 12. Phase-2-To-do

Stand nach Veröffentlichung des SQUADRON-/PLATOON-Reviews:

```text
[x] pinned MOOSE branch/commit/hash
[x] CHIEF APIs / boundaries
[x] COMMANDER APIs
[x] AIRWING / BRIGADE APIs
[x] SQUADRON / PLATOON APIs   [fachlich remote vorhanden; Manifest-Haken nach Divergenz noch prüfen]
[ ] AUFTRAG construction and mission types
[ ] Mission Assignment / Lifecycle / FSM callbacks
[ ] FLIGHTGROUP / ARMYGROUP status/lifecycle integration
[ ] official examples for required class combinations
[ ] Authority / Allocation cases against native MOOSE capability
[ ] final OMW-plan vs MOOSE handoff boundary
[ ] Gate 2 assessment
```

## 13. Nächster fachlicher Arbeitspunkt

Nach Git-Klärung und erforderlicher Dokumentnachpflege folgt:

```text
AUFTRAG construction and mission types
```

Dabei mindestens prüfen:

```text
- die für OMW profilierten Missionstypen CAS / AAR / ISR / CSAR / AIRLIFT / ESCORT;
- die tatsächlich vorhandenen AUFTRAG-Konstruktoren am gepinnten Commit;
- Signaturen und Rückgaben;
- Pflichtparameter / Preconditions;
- Target-/Zone-/Coordinate-Anforderungen;
- Mission timing / duration / repeat / cancellation semantics soweit für den Foundation-Scope relevant;
- welche AIR_TASKING_MISSION-Felder Domain-Wahrheit bleiben;
- welche Felder nur in AUFTRAG übersetzt werden;
- keine neue Mission-Art oder eigener Missions-FSM, wenn MOOSE bereits trägt.
```

Danach:

```text
AUFTRAG
→ Mission Assignment / Lifecycle / FSM
→ FLIGHTGROUP / ARMYGROUP
→ official combination examples
→ Authority / Allocation
→ final adapter boundary
→ Gate 2
```

## 14. Merge auf main

Aktuell weiterhin:

```text
MERGE TO MAIN NOW: NOT RECOMMENDED
```

Begründung:

```text
Phase 2 incomplete
Gate 2 open
local/remote branch divergence unresolved
branch must be reconciled against current main before integration
branch-local PENDING_MERGE provenance must be cleaned for main
```

Empfohlener Integrationspunkt:

```text
complete Phase 2
→ Gate 2 PASS
→ reconcile with current main
→ full diff
→ metadata / registry / provenance review
→ documentation validation where available
→ owner merge decision
→ merge Foundation milestone to main
→ begin Phase 3 AAR vertical integration
```

## 15. Lokale Werkzeug-/Workflow-Regeln

Für lokale Anweisungen an den Projektinhaber:

```text
NO Python
PowerShell commands only
commands always in code blocks
one concrete verification step at a time
```

ChatGPT ändert keine `.miz`-Dateien. Für erforderliche Mission-Builds erhält der Projektinhaber eine Build-Anweisung und liefert die reale Konsolenausgabe sowie reale Hashes zurück.

## 16. GitHub-Workflow

ChatGPT verwendet die verfügbare GitHub-App und führt Repository-Arbeit selbst aus:

```text
inspect governance / repo
→ implement
→ review diff / docs / MOOSE-first
→ commit
→ publish remote branch
→ local PowerShell verification by owner
→ real console output returned to ChatGPT
```

Kein CODEX. Keine CODEX-CLI-Übergabe.

## 17. Erster Schritt im neuen Chat

Der neue Chat soll **nicht** sofort AUFTRAG weiterbearbeiten.

Zuerst muss die lokale Git-Divergenz ohne Mutation analysiert werden. Der Projektinhaber soll genau **einen** read-only Schritt ausführen und die Ausgabe zurücksenden:

```powershell
git log --oneline --decorate --graph --left-right HEAD...origin/agent/air-tasking-plan-foundation
```

Danach ist festzustellen:

```text
local-only commits
remote-only commits
Inhalt/Ursprung von e6e0bdeea991f51745c05ed214bf4176e5abbd11
sichere Reconciliation-Strategie
```

Erst danach dürfen Merge/Rebase/Reset oder weitere lokale Pull-Schritte angeordnet werden.

## 18. Abschlussregel

Der neue Chat setzt die Arbeit nach folgendem Prinzip fort:

```text
Governance
→ exact Git state
→ MOOSE pinned source
→ smallest necessary documentation/change
→ remote commit
→ real local verification
→ next To-do
```

Keine ungeprüfte Aussage als `VALIDATED` darstellen. Keine strategische Ressourcenhoheit neben CampaignState. Keine unnötige Framework-Nachbildung.
