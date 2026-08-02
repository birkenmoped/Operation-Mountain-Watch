---
document_id: OMW-HANDOFF-SALERNO-COMPLETE-2026-08-02
status: BINDING
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - completed Salerno AIRWING/SQUADRON/COMMANDER work state
  - accepted and deferred Salerno scope
  - prerequisites and reusable rules for the next airfield
not_authoritative_for:
  - active ORBAT outside Salerno
  - merge authorization
  - selection of the next airfield unless separately decided by the project owner
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier Salerno implementation handoffs that predate runtime acceptance
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_source_branch: agent/salerno-read-only-diagnostics
acceptance_source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
---

# Salerno abgeschlossen – Übergabe an den nächsten Flugplatz

## 1. Status

```yaml
salerno_airbase_and_warehouse: PASS
salerno_mission_editor_contract: PASS
salerno_airwing: PASS
salerno_squadrons: PASS
salerno_capabilities_and_payloads: PASS
salerno_commander_dispatch: PASS
salerno_auftrag_progress_to_started: PASS
salerno_parking_calibration: PASS
salerno_actual_parking_control: DEFERRED
additional_salerno_runtime_test_before_next_airfield: NOT_REQUIRED
```

## 2. Akzeptierte Provenienz

```text
Branch:                  agent/salerno-read-only-diagnostics
Accepted source commit:  dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:          SAL-COMMANDER-SELECTION-18
Bundle SHA-256:          75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
Mission:                 OMW_Template_v5_Salerno.miz
Mission SHA-256:         4c9670babced44007952a02100de07b42eecdec156046ca7d1497a6a932edfaf
DCS:                     2.9.28.26385
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:       e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 3. Verbindlicher Salerno-Bestand

```text
8 AH-64D
8 OH-58D
7 UH-60 Assault
3 UH-60 MEDEVAC
6 CH-47
```

MOOSE-Struktur:

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

## 4. Was als bestanden gilt

- `AIRBASE.Afghanistan.FOB_Salerno` und Airbase-ID 23;
- `WH_AIR_US_SALERNO`;
- sechs Clients, fünf Templates, fünfzehn Statics und eine Funktionszone;
- fünf SQUADRONs und zwanzig Warehouse-Assetgruppen;
- Capabilities und Payloads;
- AIRWING-Start;
- COMMANDER-Start `NotReadyYet -> OnDuty`;
- `COMMANDER:CanMission()` für CAS;
- Auswahl von `AW_US_SALERNO`;
- `MissionAssign`, `MissionRequest` und `OpsOnMission`;
- AH-64-Assetrekrutierung;
- AUFTRAG-Fortschritt bis `started`;
- kontrollierter Cleanup ohne registrierten Verlust.

## 5. Was nicht als bestanden gilt

- exakte Parking-Compliance;
- sichere Trennung aller KI-Spawns von Clientpositionen;
- visuell bestätigter Cold-Ground-Spawn;
- taktische Zielbekämpfung;
- normaler Missionsabschluss;
- Rückkehr, Landung und Recovery;
- persistente Bestands- und Verlustbuchung;
- OPSTRANSPORT;
- Multiplayer- und Langzeitbetrieb;
- theaterweiter Produktions-COMMANDER.

## 6. Parking-Entscheidung

Die ME->MOOSE-TerminalID-Kalibrierung ist belastbar und bleibt erhalten. Die operative Parkingsteuerung bleibt dennoch `DEFERRED`, weil die realisierte Multi-Unit-Platzierung die konfigurierten Type-Pools und Clienttrennung nicht zuverlässig bewies.

Für den nächsten Flugplatz darf Parking deshalb nicht durch reine Konfigurations- oder Vertragstabellen als bestanden erklärt werden. Erforderlich sind Unitkoordinaten, nächster Runtime-TerminalID und positive Prüfung gegen Client-, Static- und Type-Pools.

## 7. Wichtigste Rückschläge

1. ME-Parkinglabels wurden zunächst zu direkt als MOOSE-TerminalIDs interpretiert.
2. Interne Parking-Vertragsprüfungen wurden zeitweise zu stark als tatsächliche Spawn-Compliance gewertet.
3. Ein gemischter Direkt-/COMMANDER-Test war durch parallele CAS-/RECON-/LIFT-Aufträge verunreinigt.
4. Eine Blackhawk aus der direkten LIFT-Mission wurde zunächst im COMMANDER-Testkontext betrachtet.
5. Ein Zustandsvergleich behandelte `planned` wegen Groß-/Kleinschreibung fälschlich als Fortschritt.
6. Der erste isolierte COMMANDER-Test vergaß `COMMANDER:Start()`.
7. Die korrekte Startsequenz stand bereits in der OMW-Dokumentation und im Jalalabad-Code und hätte vor der Implementierung geprüft werden müssen.

## 8. Verbindliche Arbeitsweise für den nächsten Flugplatz

```text
1. Governance, Hauptdokumentation und relevante offene Branches prüfen.
2. Exakten MOOSE-Commit und tatsächlich geladene Moose.lua prüfen.
3. Read-only Airbase-/Warehouse-/Objektdiagnose.
4. Mission-Editor-Parking gegen Runtime-TerminalIDs kalibrieren.
5. AIRWING und SQUADRONs ohne automatische Missionen aufbauen.
6. Bestands- und Gruppenzählung prüfen.
7. Capabilities und Payloads registrieren.
8. Erst einen direkten isolierten Auftrag testen.
9. COMMANDER nur nach dokumentiertem Start testen.
10. Genau einen Dispatchpfad und einen erwarteten Assettyp je Acceptance-Test.
11. Actual realization separat von Konfiguration bewerten.
12. FAILs und ungültige Tests dokumentiert erhalten.
```

## 9. Produktions-COMMANDER

Der lokale Salerno-COMMANDER ist ein Testharness. Nach Abschluss der Flugplatzknoten soll ein separates Modul genau einen theaterweiten BLUE COMMANDER erzeugen und die vorhandenen AIRWINGs anbinden.

Die historischen Jalalabad- und Salerno-Testfixtures werden nicht rückwirkend umgebaut.

## 10. Relevante Dokumente

- [`FOB Salerno Air Operations Manifest`](../81-salerno-air-operations-manifest.md);
- [`Salerno Runtime Acceptance und Lessons Learned`](../evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md);
- technischer Acceptance-Branch `agent/salerno-read-only-diagnostics`;
- Draft PR #52;
- main-fähiger Dokumentationsbranch `agent/normalize-salerno-air-orbat`;
- Draft PR #51.

## 11. Mergegrenze

Dieses Handoff erteilt keine Merge- oder Ready-for-Review-Freigabe. PR #51 und PR #52 bleiben Draft, bis der Projektinhaber eine separate ausdrückliche Freigabe erteilt.
