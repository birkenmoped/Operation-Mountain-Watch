---
document_id: OMW-HANDOFF-SALERNO-COMPLETE-2026-08-02
status: ACCEPTED_TECHNICAL_BASELINE
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - completed Salerno technical work state on this branch
  - accepted and deferred Salerno scope
  - reusable rules for the next airfield implementation
not_authoritative_for:
  - selection of the next airfield
  - merge authorization
  - project-wide production COMMANDER implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Salerno handoffs predating Stage-18 runtime acceptance
superseded_by:
source_branch: agent/salerno-read-only-diagnostics
source_commit: dba0465afbff14fb719abdeb1f9b06e24ff24717
validated_in_dcs: true
---

# Salerno abgeschlossen – Übergabe an den nächsten Flugplatz

## 1. Abschlussstatus

```yaml
airbase_and_warehouse: PASS
mission_editor_object_contract: PASS
airwing: PASS
five_squadrons: PASS
capabilities_and_payloads: PASS
commander_dispatch: PASS
auftrag_progress_to_started: PASS
parking_calibration: PASS
actual_parking_control: DEFERRED
additional_salerno_runtime_test_before_next_airfield: NOT_REQUIRED
```

## 2. Reproduzierbarer Acceptance-Stand

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

## 3. Bestand und Struktur

```text
8 AH-64D
8 OH-58D
7 UH-60 Assault
3 UH-60 MEDEVAC
6 CH-47
```

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

## 4. Bestandene Kette

```text
FOB Salerno ID 23
-> WH_AIR_US_SALERNO
-> AW_US_SALERNO Running
-> 5 SQUADRONs / 20 Assetgruppen
-> COMMANDER NotReadyYet -> OnDuty
-> CanMission(CAS)=true
-> MissionAssign AW_US_SALERNO
-> AIRWING MissionRequest
-> AH-64 AID-111 OpsOnMission
-> AUFTRAG started
-> kontrollierter Cleanup
-> graveyard={}
```

## 5. Weiterhin offen

```text
exact parking compliance
client-space runtime protection
cold-ground-spawn visual confirmation
tactical target engagement
normal mission completion
return, landing and recovery
persistent inventory/loss accounting
OPSTRANSPORT
multiplayer and endurance testing
theater-wide production COMMANDER
```

## 6. Parking-Entscheidung

Die ME->MOOSE-TerminalID-Kalibrierung ist bestanden und bleibt erhalten. Die operative Parkingsteuerung bleibt `DEFERRED`, weil die realisierte Multi-Unit-Platzierung nicht zuverlässig den konfigurierten Type-Pools und Clientausschlüssen folgte.

Für einen späteren Parking-Retest sind Unitkoordinaten, nächster Runtime-TerminalID, konfigurierte Asset-/SQUADRON-IDs und positive Pool-/Ausschlussprüfung zwingend.

## 7. Wichtigste Rückschläge

1. ME-Parkinglabels wurden zunächst zu direkt als MOOSE-TerminalIDs behandelt.
2. Interne Vertragskonsistenz wurde zeitweise zu stark als tatsächliche Spawn-Compliance interpretiert.
3. Stage 16 vermischte direkte CAS-/RECON-/LIFT-Missionen mit COMMANDER-Dispatch.
4. Eine Blackhawk aus dem direkten LIFT-Test wurde zunächst im COMMANDER-Kontext betrachtet.
5. Ein case-sensitiver Vergleich erzeugte für `planned` einen falschen PASS.
6. Stage 17 isolierte den Test korrekt, vergaß aber `COMMANDER:Start()`.
7. Die richtige Startsequenz war bereits in der OMW-Dokumentation und im Jalalabad-Code vorhanden.

## 8. Arbeitsregeln für den nächsten Flugplatz

```text
1. Governance, Hauptdokumentation und relevante Branches vollständig prüfen.
2. Tatsächlich eingebundene MOOSE-Version und Quellen prüfen.
3. Read-only Airbase-/Warehouse-/Objektdiagnose vor Mutationen.
4. Parkinglabels gegen Runtime-TerminalIDs kalibrieren.
5. AIRWING/SQUADRON-Grundlage ohne automatische Missionen aufbauen.
6. Gruppen- und Luftfahrzeugzahlen getrennt prüfen.
7. Capabilities/Payloads registrieren.
8. Direkten Dispatch isoliert testen.
9. COMMANDER nach dokumentierter FSM-Sequenz starten.
10. Pro Acceptance-Test genau ein Dispatchpfad und ein erwarteter Assettyp.
11. Konfiguration, interne Konsistenz und tatsächliche DCS-Realisierung getrennt bewerten.
12. FAILs und ungültige Läufe dauerhaft dokumentieren.
```

## 9. COMMANDER-Zielarchitektur

Der Salerno-COMMANDER ist ein lokaler Acceptance-Harness. Später soll genau ein theaterweiter BLUE COMMANDER als separates Modul nach den einzelnen AIRWING-Modulen geladen werden.

Die historischen Jalalabad- und Salerno-Testfixtures werden nicht rückwirkend verändert.

## 10. Dokumente

- [`Salerno Manifest`](../81-salerno-air-operations-manifest.md)
- [`Runtime Acceptance und Lessons Learned`](../evidence/salerno-air-operations-runtime-acceptance-and-lessons-2026-08-02.md)
- [`Technisches README`](../../mission/tests/salerno-air-operations/README.md)
- Ergebnisberichte unter `mission/tests/salerno-air-operations/results/`

## 11. Mergegrenze

Dieses Handoff erteilt keine Merge- oder Ready-for-Review-Freigabe. PR #52 bleibt Draft und ungemergt, bis der Projektinhaber dies ausdrücklich anders entscheidet.
