---
document_id: OMW-EVIDENCE-KANDAHAR-A10C-ACTIVE-UNIT-DECISION-2026-07-31
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - active Kandahar A-10C unit selection
  - supersession of active 75th and 107th EFS Kandahar baselines
  - Kandahar A-10C SQUADRON identifier
  - Kandahar A-10C local campaign inventory
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-07-31
source_branch: agent/kandahar-airwing-baseline-contract
source_documents:
  - docs/64-afghanistan-order-of-battle-july-2011.md
  - docs/19-active-air-orbat-decisions.md
  - docs/33-kandahar-air-operations-manifest.md
validated_in_dcs: false
---

# Kandahar A-10C – aktive Einheitsentscheidung vom 31.07.2026

## 1. Verbindliche Entscheidung

Die aktive Kandahar-A-10C-Komponente von Operation Mountain Watch wird mit sofortiger Wirkung auf die im Juli-2011-ORBAT am Kandahar Airfield belegte Einheit umgestellt:

```text
Einheit: 74th Expeditionary Fighter Squadron
Übergeordneter Verband: 451st Air Expeditionary Wing
Standort: Kandahar Airfield
Muster: A-10C
Lokaler logischer Kampagnenbestand: 16 Luftfahrzeuge
```

Verbindliche technische Kennungen:

```text
AIRWING: AW_US_KAF_451_AEW
SQUADRON: SQ_US_KAF_A10C_74_EFS
WAREHOUSE: WH_AIR_US_KANDAHAR
AIRBASE: AIRBASE.Afghanistan.Kandahar
DCS Airbase ID: 7
```

## 2. Historische Grundlage

Der projektintern normalisierte Juli-2011-ORBAT nennt unter dem `451st Air Expeditionary Wing`:

```text
74th Expeditionary Fighter Squadron
A-10C
Kandahar Airfield
Close Air Support
```

Die Quelle dokumentiert außerdem, dass die 74th EFS die 75th EFS im April 2011 ablöste.

## 3. Supersession

Die Entscheidung ersetzt sämtliche aktiven Kandahar-Arbeitsstände für:

```text
75th Expeditionary Fighter Squadron
107th Expeditionary Fighter Squadron
```

Diese Einheiten bleiben ausschließlich als historischer Rotationskontext erhalten. Sie erzeugen keine parallelen aktiven OMW-SQUADRONs und keine zusätzlichen:

```text
A-10C-Bestände
Client-Slots
KI-Templates
Statics
Payload-Pools
CampaignState-Inventories
```

## 4. Bestandsgrenze

Geändert wird die ausgewählte Einheit, nicht der bereits beschlossene lokale Bestand:

```text
vorheriger Bestand: 16 A-10C
neuer Bestand: 16 A-10C
Bestandsänderung: 0
```

Client-Slots, KI-Templates und sichtbare Statics bleiben Repräsentationen dieses einen logischen Bestands und werden nicht addiert.

## 5. Runtime-Regel

Jeder künftige Kandahar-AIRWING-/SQUADRON-Preflight muss fail-closed prüfen:

```text
SQ_US_KAF_A10C_74_EFS vorhanden und eindeutig
SQ_US_KAF_A10C_107_EFS nicht registriert
SQ_75_EFS_A10C nicht registriert
genau eine aktive Kandahar-A-10C-SQUADRON
logischer Bestand exakt 16 A-10C
Bindung an AW_US_KAF_451_AEW
Bindung an WH_AIR_US_KANDAHAR
Bindung an AIRBASE.Afghanistan.Kandahar / ID 7
```

Eine spätere Änderung dieser Auswahl benötigt eine neue ausdrückliche Projektentscheidung.