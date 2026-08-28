---
document_id: OMW-EVIDENCE-KANDAHAR-FOUNDATION-INVENTORY-2026-08-10
status: BINDING
document_class: DECISION_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar foundation inventory contract
  - Kandahar registered physical airframe counts
  - Tarinkot forward-detachment separation from Kandahar
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Kandahar inventory decision from 2026-08-01 for foundation implementation purposes
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: 66b37d31c715882e910305169906400304a826c0
validated_in_dcs: false
---

# Kandahar Foundation – Bestands-Reconciliation

## Grundlage

Die organisatorische Struktur folgt ADR `OMW-ADR-0005-KANDAHAR-JULY-2011-ORBAT` und damit der Juli-2011-ORBAT.

Die lokalen OMW-Bestände werden aus der bereits projektinhaberseitig genehmigten Kandahar-Bestandsentscheidung übernommen. Diese Werte sind Kampagnenentscheidungen aus Juli-2011-ORBAT, Satelliten-Sichtbestand vom 19.10.2011 und konservativer Reserve; sie sind keine Behauptung einer exakten historischen Sollstärke.

## 451st Air Expeditionary Wing

```text
SQ_US_KAF_A10C_74_EFS       16 A-10C
SQ_US_KAF_HH60G_26_ERQS      6 HH-60G
SQ_US_KAF_C130_772_EAS      12 C-130
SQ_US_KAF_MQ1_361_ERS        4 MQ-1
SQ_US_KAF_MQ9_361_ERS        2 MQ-9
```

Zusätzlich historisch/logisch geführt, aber in dieser Foundation nicht als SQUADRON registriert:

```text
361st ERS MC-12 component     6 MC-12
```

Grund: DCS-Repräsentation und technischer SQUADRON-/Template-Vertrag sind weiterhin nicht freigegeben.

## Task Force Thunder / 159th CAB

```text
SQ_US_KAF_AH64_4_227_AVN     8 AH-64D
SQ_US_KAF_OH58D_7_17_CAV    16 OH-58D
SQ_US_KAF_CH47_7_101_GSAB   16 CH-47
SQ_US_KAF_UH60_7_101_GSAB   32 UH-60
```

## Tarinkot-Abgrenzung

Tarinkot bleibt ein eigener vorgeschobener RC-South-Knoten mit:

```text
14 AH-64D
 6 UH-60
 2 CH-47
 0 OH-58D
```

Diese Luftfahrzeuge werden nicht zusätzlich in Kandahar gezählt.

Die daraus verwendeten Verwaltungswerte sind:

| Muster | Kandahar | Tarinkot | RC-South-Verwaltungswert |
|---|---:|---:|---:|
| AH-64D | 8 | 14 | 22 |
| OH-58D | 16 | 0 | 16 |
| CH-47 | 16 | 2 | 18 |
| UH-60 | 32 | 6 | 38 |

## Foundation-Gesamtvertrag

In neun MOOSE-SQUADRONs registrierte physische Airframes:

```text
A-10C    16
HH-60G    6
C-130    12
MQ-1      4
MQ-9      2
AH-64D    8
OH-58D   16
CH-47    16
UH-60    32
--------------
Total   112
```

Separat deferred:

```text
MC-12      6
```

Damit gilt für den neuen Foundation-Build:

```text
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
```

Clients, Late-Activation-Templates und Statics sind Repräsentationen dieser Bestände und erhöhen den logischen Bestand nicht.

## Foundation-Grenze

Dieser Vertrag autorisiert keine Missionsorchestrierung, keinen COMMANDER, keinen OPSTRANSPORT, keine Persistenz- oder Recovery-Logik und keine automatische Ersatzbeschaffung.

Die bekannten UAV-Rückkehr-/Parking-Grenzen aus der alten Kandahar-Testlinie bleiben historische technische Evidenz und werden durch diesen Bestandsvertrag nicht als gelöst betrachtet.
