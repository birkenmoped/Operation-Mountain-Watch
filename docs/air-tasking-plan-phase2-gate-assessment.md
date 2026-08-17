---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-GATE-ASSESSMENT
status: DRAFT
document_class: GATE_ASSESSMENT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Gate 2 assessment for the Air Tasking Plan foundation
  - branch-local readiness decision to proceed from MOOSE capability verification to Phase 3 design/integration work
not_authoritative_for:
  - repository-wide architecture beyond merged BINDING documents on main
  - DCS runtime acceptance
  - owner approval to merge or to mutate mission files
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan Foundation – Phase 2 Gate Assessment

## 1. Gate-Zweck

Gate 2 bewertet ausschließlich, ob die für den geplanten OMW-Air-Tasking-Adapter benötigten MOOSE-Fähigkeiten am tatsächlich verwendeten MOOSE-Stand hinreichend geprüft und die Architekturgrenzen ausreichend eindeutig sind, um anschließend einen ersten vertikalen Integrationspfad zu entwerfen.

Gate 2 ist **kein DCS-Runtime-Acceptance-Test**.

## 2. Tatsächlich verwendete Baseline

Die vom Projektinhaber bereitgestellte aktuelle Missionsdatei wurde direkt geprüft:

```text
mission artifact: OMW_Template_v12_groundworks.miz
mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
embedded source: l10n/DEFAULT/Moose.lua
embedded MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE context: develop
```

Damit ist die Phase-2-Prüfung nicht nur an eine abstrakte Dokumentationsversion, sondern an die tatsächlich in der aktuellen `.miz` eingebettete MOOSE-Datei gebunden.

## 3. Gate-2-Kriterien

Manifestkriterien:

```text
PASS wenn:
- jede geplante MOOSE-Verwendung quellengeprüft ist;
- Adaptergrenze explizit ist;
- keine MOOSE-Funktion unnötig nachgebaut wird;
- keine parallele OMW-Command-/Asset-Dispatcher-Engine entsteht;
- eventuelle echte Framework-Lücken dokumentiert sind.
```

## 4. Prüfergebnisse

### 4.1 MOOSE-Baseline

```text
PASS
```

Branch/Commit/Hash sind gepinnt und gegen die aktuell eingebettete `Moose.lua` bestätigt.

### 4.2 CHIEF

```text
PASS
project decision: REJECTED_FOR_PROJECT_USE
```

`CHIEF` überschneidet mit CampaignState/MissionDemand/Air-Tasking-Autorität und ist für diesen Pfad nicht erforderlich. Es wird keine CHIEF-Nachbildung entwickelt.

### 4.3 COMMANDER

```text
PASS_FOR_SOURCE_REVIEW
```

`COMMANDER` trägt native LEGION-Anbindung, Mission Queue, Capability-Prüfung, Asset-Rekrutierung, Assignment, Cancellation und `OpsOnMission`-Rückmeldung.

### 4.4 AIRWING / BRIGADE

```text
PASS_FOR_SOURCE_REVIEW
```

Beide tragen den gemeinsamen LEGION-Unterbau mit Cohorts, Missionsqueues und Runtime-Dispatch. Bekannte autonome Missionsgeneratoren und Ressourcen-Seiteneffekte sind dokumentierte Integrationsgrenzen und dürfen OMW-Authority nicht umgehen.

### 4.5 SQUADRON / PLATOON / COHORT

```text
PASS_FOR_SOURCE_AND_OFFICIAL_EXAMPLE_REVIEW
```

`COHORT:AddMissionCapability(...)` und Performance sind die nativen Capability-Mechanismen. OMW benötigt keine zweite Squadron-/Platoon-Capability-Scoring-Engine.

### 4.6 AUFTRAG construction / mission types

```text
PASS_FOR_SOURCE_REVIEW
```

Für die profilierten OMW-Missionstypen existieren tragfähige native Pfade:

```text
AAR     -> NewTANKER
CAS     -> NewCAS / NewCASENHANCED
ISR     -> NewRECON for physical recon execution
CSAR    -> dedicated MOOSE CSAR/AICSAR path; NewRESCUEHELO is not generic CSAR
AIRLIFT -> NewTROOPTRANSPORT / NewCARGOTRANSPORT / NewFREIGHTTRANSPORT by cargo semantics
ESCORT  -> NewESCORT
```

Wichtige negative Feststellung:

```text
AUFTRAG:NewOPSTRANSPORT(...)
= implementation commented out in the embedded Moose.lua
= not callable
```

### 4.7 Assignment / Lifecycle / FSM

```text
PASS_FOR_SOURCE_REVIEW
```

MOOSE stellt die erforderlichen Assignment-, `OpsOnMission`-, Flight-/Army-Dispatch-, AUFTRAG-Lifecycle-, Cancellation-, Loss- und Repeat-Hooks bereit.

Wichtig:

```text
MOOSE DONE != OMW mission success
```

Kampagneneffekt und Settlement bleiben missionsspezifische OMW-Domain-Entscheidungen.

### 4.8 FLIGHTGROUP / ARMYGROUP / OPSGROUP

```text
PASS_FOR_SOURCE_REVIEW
```

Der gemeinsame `OPSGROUP`-Unterbau trägt Mission Queue, Current-Mission-Korrelation und MissionStart/Execute/Cancel/Done. FLIGHTGROUP und ARMYGROUP liefern zusätzliche missionsartspezifische Lifecycle-Ereignisse.

### 4.9 Offizielle MOOSE-Beispiele

```text
PASS
```

Im offiziellen `MOOSE_MISSIONS_UNPACKED`-Repository auf `develop` wurden die tatsächlich benötigten Framework-Kombinationen bestätigt:

```text
SQUADRON -> AIRWING -> AUFTRAG -> FLIGHTGROUP
PLATOON -> BRIGADE -> AUFTRAG -> ARMYGROUP
COMMANDER -> multiple AIRWINGs -> AUFTRAG -> OPSGROUP
```

### 4.10 Authority / Allocation

```text
PASS_FOR_ARCHITECTURE_AND_SOURCE_REVIEW
```

Die Trennung ist eindeutig:

```text
OMW / CampaignState
= strategic authority / availability / reservation / settlement / persistence

MOOSE
= operational capability / recruitment / assignment / physical execution
```

### 4.11 Finale Adaptergrenze

```text
PASS_FOR_ARCHITECTURE_AND_SOURCE_REVIEW
```

Die projektspezifische Ergänzung ist auf eine kleine Übersetzungs-/Korrelationsschicht begrenzt. MOOSE-/DCS-Objekte werden nicht persistiert und nicht als OMW-Identität verwendet.

## 5. Framework-Lücken

Für den Foundation-Scope wurde **keine technische Lücke gefunden, die eine produktive Nicht-MOOSE- oder Native-DCS-Parallelimplementierung erfordert**.

Festgestellte Einschränkungen werden innerhalb von MOOSE getragen:

```text
- generic CSAR is not mapped through NewRESCUEHELO; dedicated MOOSE CSAR/AICSAR remains the correct family.
- NewOPSTRANSPORT is not callable at the pinned embedded source; supported transport constructors remain available for troop/cargo/freight semantics.
- mission-specific outcome evaluation and CampaignState settlement are intentionally OMW-domain responsibilities, not missing MOOSE functionality.
```

Damit ist **keine Ausnahmegenehmigung** erforderlich.

## 6. Nicht als DCS-validiert zu interpretieren

Folgende Aussagen bleiben ausdrücklich **nicht** durch diesen Gate-2-Abschluss neu in DCS validiert:

```text
CAS end-to-end Air Tasking integration
ISR end-to-end Air Tasking integration
CSAR end-to-end Air Tasking integration
AIRLIFT end-to-end Air Tasking integration
ESCORT end-to-end Air Tasking integration
generic COMMANDER multi-mission OMW adapter behavior
final player/AI assignment behavior
multiplayer synchronization of the future Air Tasking adapter
```

Bestehende frühere DCS-Acceptance gilt nur für deren exakt dokumentierten Scope, insbesondere den vorhandenen AAR-Pfad.

## 7. Gate-Entscheidung

```text
GATE 2: PASS
scope: MOOSE-first source / official-example / architecture verification
validated_in_dcs: false
```

Damit ist Phase 2 branch-lokal abgeschlossen.

## 8. Freigabegrenze für Phase 3

Gate 2 beseitigt die technische Foundation-Sperre für die **Planung und Implementierung** des ersten vertikalen AAR-Integrationspfads auf diesem Branch. Es ist keine automatische Runtime-Acceptance und keine Merge-Freigabe.

Für Phase 3 bleibt verbindlich:

```text
use existing AAR baseline
→ do not replace existing AAR strategic adapter
→ preserve CampaignState exact-once resource authority
→ implement smallest Air Tasking correlation layer
→ static/syntax verification
→ owner local build/hash verification where required
→ real DCS test
→ only then acceptance status
```

## 9. Nächster Arbeitspunkt

Nach Aktualisierung von Manifest, Current Status, MOOSE-Projektdokumentation und Handover lautet der nächste fachliche Schritt:

```text
PHASE 3 – First Vertical Integration: AAR
```

Vor produktivem Runtime-Code ist die aktuelle AAR-Schnittstelle gegen die verbindliche `main`-Baseline zu prüfen und die kleinste konkrete Adapteränderung festzulegen.
