---
document_id: OMW-ADR-0005-KANDAHAR-JULY-2011-ORBAT
status: BINDING_PROJECT_DECISION
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar AirOps organizational structure
  - Kandahar active July 2011 squadron identities
  - Kandahar dual AIRWING organization
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Kandahar 107th EFS active structure in OMW-GOV-001
  - Kandahar 107th EFS active structure in OMW-AIR-ACTIVE-ORBAT
  - generic single AIRWING Kandahar structure
superseded_by:
source_branch: agent/kandahar-foundation-july-2011-rebuild
source_commit: ff0a0868640111f8b67a82201253f0ab6d608d8f
validated_in_dcs: true
---

# ADR 0005 – Kandahar-Struktur aus der Juli-2011-ORBAT

## Entscheidung

Für die organisatorische Struktur des Air-Ops-Knotens Kandahar ist die Juli-2011-ORBAT die entscheidende Strukturreferenz.

Die aktive OMW-Struktur lautet:

```text
451st Air Expeditionary Wing
├── 26th Expeditionary Rescue Squadron
│   └── HH-60G
├── 46th Expeditionary Rescue Squadron
│   └── Guardian-Angel-Personal; kein eigener Aircraft-Pool
├── 74th Expeditionary Fighter Squadron
│   └── A-10C
├── 361st Expeditionary Reconnaissance Squadron
│   ├── MC-12
│   ├── MQ-1
│   └── MQ-9
└── 772nd Expeditionary Airlift Squadron
    └── C-130

Task Force Thunder / 159th Combat Aviation Brigade
├── Task Force Guns / 4-227 Attack Aviation
├── Task Force Palehorse / 7-17 Air Cavalry
└── Task Force Lift / 7-101 General Support Aviation
```

Die Juli-2011-ORBAT führt `Task Force Attack / 3-101 Attack Aviation` in Tarin Kowt und `Task Force Wings / 4-101 Assault Aviation` bei FOB Wolverine. Beide werden deshalb nicht als Kandahar-SQUADRONs geführt.

## Technische MOOSE-Abbildung

DCS modelliert Kandahar Main und Kandahar Heliport als getrennte native Airbases. Der technisch bestätigte Dual-Airbase-Vertrag wird deshalb beibehalten:

```text
AW_US_KAF_451_AEW
WH_AIR_US_KANDAHAR
AIRBASE.Afghanistan.Kandahar
DCS ID 7

AW_US_KAF_159_CAB_TF_THUNDER
WH_AIR_US_KANDAHAR_HELI
AIRBASE.Afghanistan.Kandahar_Heliport
DCS ID 15
```

Die neun technischen SQUADRON-Pools sind:

```text
AW_US_KAF_451_AEW
├── SQ_US_KAF_A10C_74_EFS
├── SQ_US_KAF_HH60G_26_ERQS
├── SQ_US_KAF_C130_772_EAS
├── SQ_US_KAF_MQ1_361_ERS
└── SQ_US_KAF_MQ9_361_ERS

AW_US_KAF_159_CAB_TF_THUNDER
├── SQ_US_KAF_AH64_4_227_AVN
├── SQ_US_KAF_OH58D_7_17_CAV
├── SQ_US_KAF_CH47_7_101_GSAB
└── SQ_US_KAF_UH60_7_101_GSAB
```

CH-47 und UH-60 bleiben typreine technische Pools unter dem belegten Parent `TF Lift / 7-101 General Support Aviation`. Eine nicht belegte Company-Bezeichnung wird nicht erfunden.

Die 46th ERQS erzeugt keine zehnte Aircraft-SQUADRON, weil die Juli-2011-ORBAT sie als Guardian-Angel-Personal beschreibt.

## Reconciliation

`docs/00-project-governance.md` und `docs/19-active-air-orbat-decisions.md` wurden auf demselben Foundation-Branch auf diese Entscheidung synchronisiert. Die frühere aktive Kandahar-Auswahl der 107th EFS ist damit fachlich ersetzt und bleibt nur historischer Rotationskontext.

## DCS-Nachweis

Die technische Abbildung wurde für den exakt dokumentierten Foundation-Stand in DCS bestätigt:

```text
Branch: agent/kandahar-foundation-july-2011-rebuild
Source commit: 578816472c53279290ff6b64296ed8d49982bc72
MIZ: OMW_Template_v6_Tarinkot(6).miz
DCS: 2.9.28.26385
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Result:
airwings=2
squadrons=9
registeredAirframes=112
deferredMC12=6
mainRunning=true
heliportRunning=true
```

Der Nachweis validiert die Foundation-Struktur, nicht taktische Dispatch-, Recovery-, Parking-, Persistenz- oder Multiplayer-Funktionen.

## MOOSE-First-Grenze

Die Foundation verwendet ausschließlich vorhandene MOOSE-Klassen und öffentliche Methoden für AIRWING/SQUADRON, Warehouse-Bindung, Gruppierung, Turnover, Mission Capabilities, Payload-Registrierung und AIRWING-Start. Keine Native-DCS- oder parallele Ressourcenlogik wird durch diese Entscheidung genehmigt.
