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

Dokumentierter Branch-Stand:

```text
branch: agent/air-tasking-plan-foundation
branch_head: 7065d687dfdfef1af098275778b082f5e888799d
main_head_at_assessment: 08f679926e5ac059e9853f54ffa7bb634063eaa4
merge_base: d9150f96fac5b546fe515c89fd139851c6e9829b
branch_vs_main: 40 commits ahead / 3 commits behind
```

Die drei neueren `main`-Commits nach dem Merge-Base betreffen die Kunar-Ground-Site-/FOB-Bostick-Reconciliation. Der Foundation-Branch muss vor einem Merge dennoch gegen den aktuellen `main`-Stand reconciliiert und vollständig diff-geprüft werden.

## 2. Gesamtstatus nach Phasen

```text
PHASE 0  Governance / Reconciliation / Contracts          PASS
PHASE 1  Domain Data Model                               PASS
PHASE 2  MOOSE-First Capability Verification            IN PROGRESS
PHASE 3  First Vertical Integration – AAR                BLOCKED BY GATE 2
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

`PASS` für Phase 0 und Phase 1 ist branch-lokal und dokumentiert ausschließlich Architektur-/Datenverträge. Es ist kein DCS-Runtime-Nachweis.

## 3. Phase 0 – abgeschlossen

Gemäß `OMW-AIR-TASKING-PLAN-FOUNDATION-MANIFEST` sind sämtliche Phase-0-Punkte geschlossen.

Ergebnis:

```text
- CampaignState bleibt strategische Zustands-/Ressourcenautorität.
- MissionDemand-Origin/Consumer- und Command-/Tasking-/Request-Authority-Grenzen sind definiert.
- Request-, Mission-, Plan-, Relationship- und Execution-IDs sind stabil getrennt.
- Persistenter Domainzustand ist von MOOSE-/DCS-Runtimeobjekten getrennt.
- Player Views/Briefingprodukte besitzen keine eigene Ressourcen- oder Tasking-Autorität.
- MOOSE-zentriertes Command-Modell ist festgelegt; CHIEF darf keine zweite strategische Autorität bilden.
```

Gate 0:

```text
PASS
scope: architecture/contracts only
validated_in_dcs: false
```

## 4. Phase 1 – abgeschlossen

Alle im Manifest definierten Phase-1-Punkte sind geschlossen:

```text
[x] konkrete Datenverträge / Modulschnittstellen
[x] Pflicht-/Optionalfelder je Missionstyp
[x] getrennte Request-/Mission-Statusautomaten
[x] erlaubte Statusübergänge
[x] Cancellation-/Failure-Semantik
[x] Support-Beziehungen und Zyklusregeln
[x] Player-/AI-Assignment ohne zweite Aircraft-Ressourcentabelle
[x] Snapshot-/Serialisierungsvertrag
[x] Datenvalidierung und Logging mit stabilen IDs
```

Gate 1:

```text
PASS
scope: domain architecture/contracts only
validated_in_dcs: false
```

Damit ist das DCS-/MOOSE-unabhängige Air-Tasking-Domänenmodell branch-lokal vollständig spezifiziert.

## 5. Phase 2 – aktueller Arbeitsstand

Verbindliche MOOSE-Verifikationsbaseline:

```text
MOOSE branch/context: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Manifeststatus:

```text
[x] pinned MOOSE branch/commit/hash übernehmen
[x] CHIEF APIs / Verantwortungsgrenzen prüfen
[x] COMMANDER APIs prüfen
[x] AIRWING / BRIGADE APIs prüfen
[ ] SQUADRON / PLATOON APIs prüfen
[ ] AUFTRAG-Konstruktion und Missionstypen prüfen
[ ] Mission Assignment / Lifecycle / FSM-Callbacks prüfen
[ ] FLIGHTGROUP / ARMYGROUP Status-/Lifecycle-Anbindung prüfen
[ ] offizielle Beispiele für tatsächlich benötigte Kombinationen prüfen
[ ] Authority-/Allocation-Fälle gegen native MOOSE-Fähigkeiten prüfen
[ ] OMW-Planungsdaten vs. an MOOSE übergebene Daten abschließend dokumentieren
[x] PROJECT-CLASS-INDEX fortlaufend aktualisieren
[x] passende MOOSE-Themendokumente fortlaufend pflegen
[x] keine neue Methode ohne DCS-Test als VALIDATED markieren
```

Aktuell source-geprüfte C2-/LEGION-Grenze:

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

`CHIEF` bleibt für den OMW-Air-Tasking-Pfad `REJECTED_FOR_PROJECT_USE`, weil seine Strategy-/INTEL-/Target-/Response-Semantik strategische Verantwortungen von CampaignState/MissionDemand überlappen würde. Es wird keine eigene CHIEF-Nachbildung entwickelt.

`COMMANDER` ist der vorgesehene operative MOOSE-C2-/Mission-Assignment-Layer. `AIRWING` und `BRIGADE` sind aktive LEGION-Layer mit eigener Mission Queue und Asset-/Cohort-Verwaltung. Ihre autonomen Missionsgeneratoren und Ressourcen-Seiteneffekte dürfen den autoritativen OMW-MissionDemand-/CampaignState-Pfad nicht umgehen.

## 6. Gate-2-Restarbeit

Gate 2 bleibt ausdrücklich offen.

Vor `PASS` müssen noch nachgewiesen beziehungsweise abschließend dokumentiert werden:

```text
SQUADRON / PLATOON
→ Capability- und Asset-Grenzen

AUFTRAG
→ benötigte Konstruktoren / Missionstypen
→ Parameter und Rückgaben
→ missionspezifische Preconditions

Mission Lifecycle
→ Assignment
→ Start / Execution
→ Completion / Failure / Cancellation
→ geeignete FSM-Events / Callbacks

FLIGHTGROUP / ARMYGROUP
→ physische Runtime-Korrelation
→ Statusbeobachtung
→ Lifecycle-Rückmeldung

Official MOOSE examples
→ tatsächlich benötigte Klassenkombinationen verifizieren

Authority / Allocation
→ festlegen, welche Fälle COMMANDER/LEGION/COHORT nativ tragen
→ nur verbleibende Domain-Korrelation im kleinen OMW-Adapter behalten

Adapter boundary
→ endgültig festlegen, welche Air-Tasking-Felder Domain-Wahrheit bleiben
→ exakt festlegen, welche Daten in AUFTRAG/MOOSE übersetzt werden
```

Erst danach kann Gate 2 bewertet werden.

## 7. Merge-Readiness

### Aktueller Stand

```text
MERGE TO MAIN NOW: NOT RECOMMENDED
```

Begründung:

1. Der Branch ist aktuell drei Commits hinter `main` und muss vor Integration reconciliiert werden.
2. Phase 2 ist noch nicht abgeschlossen; damit ist die MOOSE-Adaptergrenze noch nicht vollständig verifiziert.
3. Gate 2 ist offen und Phase 3 ist laut Manifest weiterhin gesperrt.
4. Mehrere branch-lokale Dokumente verwenden korrekt `source_commit: PENDING_MERGE`; vor beziehungsweise im Integrationsschritt müssen ihre Provenienz und die Dokumentregister-Regeln für `main` bereinigt werden.
5. Ein Merge jetzt würde eine nur teilweise verifizierte MOOSE-Foundation auf `main` heben und unmittelbar danach weitere grundlegende Phase-2-Änderungen erfordern.

### Empfohlener Merge-Checkpoint

Der fachlich saubere Integrationspunkt ist:

```text
complete Phase 2
→ Gate 2 PASS
→ reconcile branch with current main
→ full diff / documentation / registry / provenance review
→ documentation validator
→ owner merge decision
→ merge Foundation milestone to main
→ begin Phase 3 AAR vertical integration from current main
```

Damit werden Phase 0, Phase 1 und die vollständige MOOSE-First-Verifikation als ein konsistenter Foundation-Meilenstein integriert, bevor produktiver Air-Tasking-Adaptercode entsteht.

## 8. Unveränderte Sperren

Bis Gate 2 abgeschlossen ist:

```text
NO productive Air Tasking adapter runtime
NO Phase-3 AAR integration
NO parallel OMW command/asset dispatcher
NO CHIEF replacement
NO new strategic resource authority outside CampaignState
NO VALIDATED claim without documented DCS evidence
```

## 9. Nächster To-do-Punkt

Der nächste Manifestpunkt ist unverändert:

```text
SQUADRON / PLATOON relevant APIs verify
```

Danach folgen `AUFTRAG`, Mission Assignment/Lifecycle/FSM, `FLIGHTGROUP`/`ARMYGROUP`, offizielle Kombinationen, Authority-/Allocation-Abgleich und die finale Adaptergrenze.
