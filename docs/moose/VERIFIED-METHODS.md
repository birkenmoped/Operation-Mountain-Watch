---
document_id: OMW-MOOSE-VERIFIED-METHODS
status: BINDING
document_class: TECHNICAL_EVIDENCE_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project method-level MOOSE evidence
  - documented validation scope and limitations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified verified-method register
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: partial
branch_local_addendum:
  branch: docs/optional-llm-commanders
  baseline_commit: 7be3ed28757f8036a43184a6c774df4701bec98c
  audit_document: ../special-projects/llm-commanders/moose-operation-plan-adapter-interface-audit.md
  authority: DRAFT_ONLY_UNTIL_MERGED
---

# Verifizierte MOOSE-Methoden

## 1. Zweck

Dieses Register führt praktisch geprüfte MOOSE-Aufrufe und den jeweils belegten OMW-Einsatzumfang.

Der vollständige frühere Methodenindex bleibt unverändert erhalten:

- [`Legacy-Methodenregister`](../evidence/source-records/legacy-moose-verified-methods.md)

Ein Eintrag belegt ausschließlich die angegebene Methode im dokumentierten Teststand. Er validiert weder die gesamte Klasse noch andere Basen, Missionen oder MOOSE-Versionen.

## 2. Nachweisgrenze

Für den historischen Jalalabad-Complete-Node-PASS gilt:

```yaml
omw_runtime_behavior: validated_for_documented_scope
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
evidence_type: RECONSTRUCTED_FROM_IDENTICAL_ARTIFACT
original_report_contained_full_hash: false
pr: 18
merged_to_main: false
```

Diese Einordnung ersetzt keine erneute Signatur- und Verhaltenprüfung auf einem neuen MOOSE-Stand.

## 3. Belegte Methodengruppen

### AIRBASE

- `AIRBASE:FindByName()`;
- `GetName()`;
- `GetID()`;
- `SetParkingSpotBlacklist()`.

### AIRWING

- `AIRWING:New()`;
- `SetAirbase()`;
- `SetTakeoffCold()`;
- `SetSafeParkingOn()`;
- `AddSquadron()`;
- `NewPayload()`;
- `GetSquadron()`;
- `Start()` für den dokumentierten Grundstart.

### SQUADRON, COMMANDER und Wrapper

- Konstruktion und Anbindung der dokumentierten Jalalabad-Squadrons;
- COMMANDER-Erstellung und AIRWING-Anbindung;
- `GROUP`, `UNIT`, `STATIC` und `ZONE` für Template- und Missionsvalidierung;
- `SCHEDULER` für die dokumentierte Konstruktionsreihenfolge.

## 4. Nicht durch den Jalalabad-Grundtest belegt

- vollständige taktische `AUFTRAG`-Ausführung;
- `COMMANDER:AddMission()` als OperationPlan-Adapterpfad;
- Mission-Queueing, Asset-Auswahl, Cancel-Weiterleitung und Adapter-Callbacks;
- `OPERATION` als taktischer Phasencontainer;
- `TARGET`-Resolver und Target-Lebenszyklus;
- `OPSTRANSPORT`;
- direkter `OPSGROUP`-Dispatch aus einem externen Adapter;
- CampaignState-Persistenz;
- Verlust-/Rückkehr- und Ramp-Neuverteilung;
- vollständige MEDEVAC- und CSAR-Koordination;
- andere Airbases, Kartenversionen oder MOOSE-Stände.

## 5. Branch-lokale Source-Review-Kandidaten

Das folgende Audit dokumentiert Quellcode-Fundstellen und Kandidatenschnittstellen, aber keine praktische DCS-Verifikation:

- [`OMW-SP-LLM-COMMANDERS-MOOSE-ADAPTER-AUDIT`](../special-projects/llm-commanders/moose-operation-plan-adapter-interface-audit.md)

Geprüfter Source-Kandidat:

```yaml
moose_repository: FlightControl-Master/MOOSE
moose_source_commit: 23112c99545d8b052f850fe0680d77272d24433b
actual_omw_moose_lua_equivalence_proven: false
official_demo_missions_checked: false
dcs_runtime_tested: false
```

Source-level beobachtete Kandidaten umfassen:

### COMMANDER

- `COMMANDER:New(Coalition, Alias)`;
- `AddLegion()` sowie die typisierten Airwing-, Brigade- und Fleet-Pfade;
- `AddMission()` für AUFTRAG-Zuweisungen;
- `AddOpsTransport()` für getrennte Transportzuweisungen;
- `MissionCancel()`;
- `OnAfterMissionAssign`;
- `OnAfterMissionCancel`;
- `OnAfterOpsOnMission`;
- Transport-Assign- und Transport-Cancel-Callbacks.

### AUFTRAG

- missionstypspezifische Konstruktoren als Capability-Profile-Kandidaten, darunter `NewCAS()`, `NewCASENHANCED()`, `NewBAI()`, `NewSTRIKE()`, `NewCAP()`, `NewRECON()`, `NewSEAD()`, `NewESCORT()` und `NewGROUNDESCORT()`;
- `SetTime(ClockStart, ClockStop)`;
- `SetPriority(Prio, Urgent, Importance)`;
- Erfolgs-, Fehler-, Cancel- und weitere FSM-Callbacks.

### OPERATION

- `OPERATION:New(Name)`;
- `AddPhase()`;
- `SetTime()`;
- Start-, Phasen-, Over- und Stop-Ereignisse.

Diese Methoden sind in diesem Abschnitt ausdrücklich nicht als praktisch verifiziert eingetragen. Vor Verwendung sind Signatur, Seiteneffekte, offizielles Beispiel und tatsächliche Verfügbarkeit in der eingebundenen `Moose.lua` erneut zu prüfen.

## 6. Adapter-Nachweisgrenze

Für den optionalen Multi-Commander-Adapter gilt:

```text
SOURCE_METHOD_FOUND != PROJECT_METHOD_VERIFIED
MOOSE_CALLBACK_OBSERVED != CAMPAIGN_EFFECT_ADJUDICATED
MOOSE_OPERATION != OMW_OPERATION_PLAN
```

Ein neuer Methodennachweis benötigt mindestens:

```yaml
method:
signature:
moose_version:
moose_source_commit:
moose_lua_sha256:
omw_branch:
omw_commit:
mission_file:
mission_sha256:
bundle_sha256:
dcs_build:
test_conditions:
observed_result:
known_limitations:
acceptance_status:
```

## 7. Neue Einträge

Jeder neue praktisch bestätigte Eintrag enthält Methode, Signatur, MOOSE-Version, OMW-Commit, Mission, Hashes, Testbedingung, beobachtetes Ergebnis und bekannte Einschränkungen.
