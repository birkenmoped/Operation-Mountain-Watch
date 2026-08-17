---
document_id: OMW-AIR-TASKING-PLAN-FOUNDATION-HANDOVER
status: DRAFT
document_class: HANDOVER_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local handover state for agent/air-tasking-plan-foundation
  - immediate continuation order for the Air Tasking Plan foundation work
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - owner merge approval
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Handover

## 1. Verbindliche Arbeitsgrundlage

Vor jeder weiteren Umsetzung gelten:

```text
AGENTS.md on main
→ docs/00-project-governance.md on main
→ docs/26-moose-first-development-policy.md on main
→ zuständige Air-Tasking-/CampaignState-/AAR-/MOOSE-Dokumente
→ tatsächlicher Branch-/Commit-/Missionsstand
```

Keine MOOSE-API, kein DCS-Verhalten, kein Commit, kein Hash und kein Testergebnis darf geraten werden.

## 2. Repository / Branch

```text
repository: birkenmoped/Operation-Mountain-Watch
working branch: agent/air-tasking-plan-foundation
```

Die früher im Handover dokumentierte vermeintliche lokale/remote Divergenz ist **aufgelöst**.

Der damals als lokaler Air-Tasking-Commit interpretierte Stand

```text
e6e0bdeea991f51745c05ed214bf4176e5abbd11
```

gehörte tatsächlich zu:

```text
agent/army-ground-foundation-reconciliation
```

Der lokale Air-Tasking-Branch wurde anschließend sauber per Fast-Forward von `b2fd8b6` auf den damaligen Remote-Handover-Head

```text
bfcd3e13248f528a697cd01cca6acebc0e0c9e8e
```

synchronisiert. Die frühere Git-Sperre wegen vermeintlicher Divergenz gilt nicht mehr.

Seitdem wurde Phase 2 durch ChatGPT auf dem Remote-Branch weitergeführt. Der Projektinhaber muss vor weiterer lokaler Arbeit den neuen Remote-Stand per Fast-Forward übernehmen und den realen HEAD zurückmelden.

Die bekannten lokalen untracked Build-/Testartefakte bleiben unverändert zu erhalten: nicht löschen, nicht hinzufügen, nicht bereinigen.

## 3. Gesamtstatus

```text
PHASE 0  Governance / Reconciliation / Contracts          PASS
PHASE 1  Domain Data Model                               PASS
PHASE 2  MOOSE-First Capability Verification            PASS
PHASE 3  First Vertical Integration – AAR                NOT STARTED
PHASE 4  Player-Facing Mission Products                  NOT STARTED
PHASE 5  Ground Alert / CAS Request Lifecycle            NOT STARTED
PHASE 6  Dynamic Planning / Retasking / Persistence      NOT STARTED
```

Phase 0/1 sind branch-lokale Architektur-/Contract-Gates. Phase 2 ist branch-lokale Source-/Official-Example-/Architekturverifikation. Keiner dieser PASS-Werte ist ein neuer DCS-Runtime-Nachweis.

## 4. Tatsächlich verwendeter MOOSE-Stand

Die vom Projektinhaber bereitgestellte aktuelle Missionsdatei wurde direkt geprüft:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
MOOSE context: develop
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Damit entspricht die tatsächlich in der aktuellen `.miz` enthaltene `Moose.lua` exakt der Phase-2-Baseline.

Verbindlicher Prüfweg bleibt:

```text
MOOSE documentation
→ actual embedded Moose.lua
→ signatures / returns / FSM / preconditions / side effects
→ official MOOSE demos/tests where relevant
```

## 5. Architekturgrenze

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
AUFTRAG
        ↓
FLIGHTGROUP / ARMYGROUP
        ↓
DCS
```

### OMW / CampaignState

```text
strategic authority
strategic availability
reservation
exact-once settlement
persistent request/mission identity
command/tasking/request authority
persistent support relationships and result history
```

### MOOSE

```text
COHORT capability / performance
runtime payload / asset suitability
COMMANDER / LEGION recruitment and assignment
AUFTRAG mission execution
FLIGHTGROUP / ARMYGROUP physical execution
runtime lifecycle callbacks
```

`CHIEF` bleibt für diesen Pfad:

```text
REJECTED_FOR_PROJECT_USE
```

Es wird keine CHIEF-Nachbildung und keine parallele OMW-Command-/Capability-/Asset-Dispatcher-Engine erstellt.

## 6. Phase-2-Ergebnis

Abgeschlossen sind:

```text
[x] MOOSE version / commit / embedded hash
[x] CHIEF
[x] COMMANDER
[x] AIRWING / BRIGADE
[x] SQUADRON / PLATOON / COHORT
[x] AUFTRAG construction / mission types
[x] Mission Assignment / Lifecycle / FSM
[x] FLIGHTGROUP / ARMYGROUP / OPSGROUP integration
[x] official MOOSE examples
[x] Authority / Allocation
[x] final OMW-to-MOOSE adapter boundary
[x] MOOSE topic documentation / class index alignment
```

Gate:

```text
GATE 2: PASS
scope: MOOSE-first source / official-example / architecture verification
validated_in_dcs: false
```

Es wurde keine Framework-Lücke festgestellt, die für diesen Foundation-Scope eine produktive Nicht-MOOSE- oder Native-DCS-Ausnahme erfordert.

## 7. AUFTRAG-Mapping

```text
AAR
→ AUFTRAG:NewTANKER(...)

CAS
→ AUFTRAG:NewCAS(...)
  or NewCASENHANCED(...)

ISR
→ AUFTRAG:NewRECON(...)
  for physical recon execution

CSAR
→ dedicated MOOSE CSAR / AICSAR family

AIRLIFT
→ NewTROOPTRANSPORT(...)
→ NewCARGOTRANSPORT(...)
→ NewFREIGHTTRANSPORT(...)
  according to actual cargo semantics

ESCORT
→ AUFTRAG:NewESCORT(...)
```

Wichtige negative API-Feststellung:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= source text present
= implementation commented out
= not callable at the embedded/pinned baseline
= MUST NOT USE
```

`AUFTRAG:NewRESCUEHELO(Carrier)` ist carrier-spezifisch und **keine** generische Downed-Aircrew-CSAR-Mission.

## 8. Mission Lifecycle

Source-geprüfte MOOSE-Kette umfasst:

```text
COMMANDER / LEGION assignment
→ OpsOnMission / FlightOnMission / ArmyOnMission
→ AUFTRAG STARTED
→ AUFTRAG EXECUTING
→ DONE / SUCCESS / FAILED / CANCELLED
→ OPSGROUP MissionStart / Execute / Cancel / Done
```

Wichtige Grenzen:

```text
MOOSE DONE != OMW mission success
MOOSE cancellation != CampaignState settlement
MOOSE runtime UID != OMW mission_id
```

Bevorzugt werden Events/Callbacks statt globalem Polling oder Frame-Scans.

## 9. Offizielle MOOSE-Demos

Auf `FlightControl-Master/MOOSE_MISSIONS_UNPACKED`, Branch `develop`, wurden geprüft:

```text
OPS - Airwing/Airwing - 010 - Fighter Wing
OPS - Brigade/Brigade - 010 - Patrol Mission
OPS - Commander/Commander - 020 - Bombing with Airwings
```

Sie bestätigen die benötigten Kombinationen:

```text
SQUADRON -> AIRWING -> AUFTRAG -> FLIGHTGROUP
PLATOON -> BRIGADE -> AUFTRAG -> ARMYGROUP
COMMANDER -> multiple AIRWINGs -> AUFTRAG -> OPSGROUP
```

## 10. Neue Phase-2-Dokumente

```text
docs/air-tasking-plan-phase2-auftrag-construction-verification.md
docs/air-tasking-plan-phase2-mission-lifecycle-verification.md
docs/air-tasking-plan-phase2-opsgroup-integration-verification.md
docs/air-tasking-plan-phase2-official-examples-verification.md
docs/air-tasking-plan-phase2-authority-allocation-verification.md
docs/air-tasking-plan-phase2-adapter-boundary.md
docs/air-tasking-plan-phase2-gate-assessment.md
docs/moose/AIR-TASKING-C2-LIFECYCLE.md
```

Zusätzlich wurden aktualisiert:

```text
docs/air-tasking-plan-foundation-manifest.md
docs/air-tasking-plan-foundation-current-status.md
docs/moose/PROJECT-CLASS-INDEX.md
```

## 11. Phase 3 – nächster fachlicher Schritt

```text
PHASE 3 – First Vertical Integration: AAR
```

Vor produktivem Runtime-Code:

```text
current main / AAR baseline prüfen
→ bestehende AAR-Schnittstelle exakt feststellen
→ kleinste Air-Tasking-Korrelationsschicht entwerfen
→ bestehenden AAR strategic adapter anbinden, nicht ersetzen
```

Unverändert verboten:

```text
recompute MissionDemand / AAR Area / Profile in Air Tasking
replace existing AAR FuelLow / Relief / Egress lifecycle
create a second tanker inventory
bypass CampaignState exact-once settlement
persist MOOSE/DCS runtime objects as campaign truth
```

## 12. Merge auf main

Aktuell:

```text
MERGE TO MAIN NOW: NOT YET RECOMMENDED
```

Vor einer Integrationsentscheidung noch erforderlich:

```text
reconcile branch against current main
full branch diff review
document metadata / registry / provenance review
documentation validator
owner merge decision
```

`source_commit: PENDING_MERGE` ist auf diesem ungemergten Branch zulässig, darf aber nicht unverändert auf `main` verbleiben.

## 13. Lokaler Workflow

ChatGPT ändert keine `.miz`-Dateien.

Nach Remote-Änderungen erhält der Projektinhaber ausschließlich PowerShell-Anweisungen für die lokal erforderlichen Schritte. Der Projektinhaber liefert die reale Konsolenausgabe einschließlich realer HEAD-/Hash-Werte zurück.

Keine lokalen Resultate, Builds, Hashes oder DCS-Verhalten werden angenommen oder simuliert.

Kein CODEX.
