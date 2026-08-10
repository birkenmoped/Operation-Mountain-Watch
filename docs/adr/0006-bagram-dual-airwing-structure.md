---
document_id: OMW-ADR-0006-BAGRAM-DUAL-AIRWING
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram AirOps organizational split
  - supersession of the single AW_US_BAGRAM runtime structure
  - assignment of the six existing Bagram SQUADRON pools to USAF and Army Aviation AIRWINGs
not_authoritative_for:
  - Mission Editor parking acceptance
  - DCS runtime acceptance
  - tactical tasking, COMMANDER, AUFTRAG or OPSTRANSPORT acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - single-AIRWING Bagram runtime structure AW_US_BAGRAM
superseded_by: []
source_branch: agent/bagram-dual-airwing-foundation-rebuild
source_commit: ffdc52c40a9fe83123dc25f369cd81581f293069
validated_in_dcs: false
---

# ADR 0006 – Bagram in USAF- und Army-Aviation-AIRWING trennen

## Entscheidung

Der Projektinhaber hat am 10.08.2026 ausdrücklich entschieden, die bisherige technische Bagram-Struktur `AW_US_BAGRAM` zu superseden.

Bagram wird künftig in zwei getrennte MOOSE-AIRWING-Domänen abgebildet:

```text
AW_US_BGRM_455_AEW
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_C130_774_EAS
└── SQ_US_BGRM_HH60G_83_ERQS

AW_US_BGRM_TF_FALCON_10_CAB
├── SQ_US_BGRM_UH60_A_1_169
└── SQ_US_BGRM_CH47_B_7_158
```

Die sechs SQUADRON-Pools bleiben dieselben fachlichen Bestandsdomänen, die bereits im historischen Bagram-Testzweig getrennt geführt wurden. Die Änderung betrifft ihre organisatorische AIRWING-Zuordnung und ersetzt die frühere Vermischung von USAF und Army Aviation unter einem einzigen `AW_US_BAGRAM`.

## Bestände

Für den Foundation-Neubau werden die bereits dokumentierten logischen OMW-Bestände unverändert übernommen:

```text
13 F-15E   | SQ_US_BGRM_F15E_335_EFS
13 F-16C   | SQ_US_BGRM_F16C_121_EFS
20 C-130   | SQ_US_BGRM_C130_774_EAS
 6 HH-60G  | SQ_US_BGRM_HH60G_83_ERQS
10 UH-60   | SQ_US_BGRM_UH60_A_1_169
13 CH-47   | SQ_US_BGRM_CH47_B_7_158
------------------------------------
75 logische Luftfahrzeuge
```

Client-Slots, Statics und Mission-Editor-Templates bleiben Repräsentationen dieses Bestands und erhöhen ihn nicht.

## MOOSE-First-Folge

Der gepinnte MOOSE-Stand erzeugt je `AIRWING:New(warehouseName, airwingName)` eine eigene LEGION/WAREHOUSE-Instanz. Deshalb werden die beiden AIRWINGs nicht auf denselben physischen Warehouse-Anker gelegt.

Foundation-Vertrag:

```text
AW_US_BGRM_455_AEW
  Warehouse: WH_AIR_US_BAGRAM
  Airbase:   Bagram

AW_US_BGRM_TF_FALCON_10_CAB
  Warehouse: WH_AIR_US_BAGRAM_ARMY
  Airbase:   Bagram
```

`WH_AIR_US_BAGRAM` bleibt als bestehender USAF-/Hauptanker erhalten. `WH_AIR_US_BAGRAM_ARMY` ist als zweiter Mission-Editor-Anker anzulegen. Die Missionsdatei wird nicht automatisiert verändert.

## Ungerade Fighter-Bestände

`SQUADRON:New(template, Ngroups, name)` zählt Assetgruppen und `SetGrouping(n)` setzt eine einheitliche Gruppengröße. Für die beiden 13er-Fighterbestände bleibt daher im Foundation-Schritt das bereits getestete Modell maßgeblich:

```text
je Fighter-SQUADRON:
  6 Two-Ship-Assetgruppen = 12 MOOSE-repräsentierbare Airframes
  1 logischer Reserve-Airframe
```

Damit registriert MOOSE im Foundation-Lauf 73 physisch repräsentierbare Airframes; zwei Fighter-Airframes bleiben logische Reserve. Eine spätere CampaignState-/Reserve-Materialisierung benötigt eine eigene Acceptance und darf nicht stillschweigend eingeführt werden.

## Foundation-Grenze

Der neue Bagram-Bundle darf zunächst ausschließlich enthalten:

- zwei AIRWINGs;
- sechs SQUADRONs;
- Mission-Capabilities;
- Role-Payload-Registrierung;
- Warehouse-/Airbase-Bindung;
- AIRWING-Start;
- Idle-/Bestandsdiagnose.

Ausdrücklich ausgeschlossen:

- COMMANDER;
- konkrete AUFTRAG-Instanzen;
- OPSTRANSPORT-Instanzen;
- F10-Teststeuerung;
- Bagram→Jalalabad-Testbewegung;
- erzwungene Spawns/Despawns;
- Parking-Override;
- Persistenz- oder CampaignState-Mutation.

## Acceptance

`validated_in_dcs: false` bleibt bestehen, bis ein exakt dokumentierter DCS-Lauf beide AIRWINGs gleichzeitig als `Running` bestätigt und dabei mindestens folgende Foundation-Grenzen einhält:

```text
airwings=2
squadrons=6
logicalAirframes=75
representedAirframes=73
logicalReserve=2
missionsCreated=0
transportsCreated=0
commanderCreated=false
f10Controls=false
```
