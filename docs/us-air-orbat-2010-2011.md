# US Air Order of Battle and MOOSE Integration Plan

## Document status

This document defines the current planning baseline for United States flying units represented in **Operation Mountain Watch**.

- **Simulation period:** 1 August 2010 through 20 May 2011
- **Map:** DCS: Afghanistan
- **Primary operational area:** Nangarhar, Laghman, Kunar, and Nuristan
- **Primary local hub:** Jalalabad Airfield / FOB Fenty
- **Strategic and regional hubs:** Bagram, Kabul, Khost/FOB Salerno, Kandahar, Camp Bastion, Camp Dwyer, Tarinkot, and Shindand

The force figures below are a **mission-design ORBAT**, not a claim that every aircraft was simultaneously present, serviceable, or visible on the ramp. Public sources often document unit presence and aircraft type but not exact deployed aircraft counts. Each number must therefore be treated as one of the following:

- **High confidence:** a concrete deployed strength or closely documented unit inventory.
- **Medium confidence:** unit and aircraft type are documented; quantity is derived from a typical deployed squadron, company, or detachment.
- **Low confidence:** unit presence or parent formation is documented, but the local detachment strength is not publicly established.

The implementation must preserve these confidence levels and permit later correction without redesigning the mission.

---

## 1. Design objectives

The campaign shall represent the American aviation presence on all relevant DCS Afghanistan airfields during the selected period.

The intended behavior is:

1. Historically plausible flying units are assigned to their documented or most plausible operating bases.
2. Aircraft available as DCS player modules are provided as player slots at the corresponding bases.
3. Aircraft without a player module are available as AI support assets.
4. A configurable MOOSE RAT layer may generate non-combat background traffic at historically plausible frequency and strength.
5. Parked static aircraft visually represent part of the local inventory.
6. A static aircraft may be removed when the associated airframe is used by a player or AI flight and restored after the airframe returns to the available pool.
7. Detachments must be subtracted from their parent formation and must never be counted twice.
8. Total inventory, mission-ready inventory, visible statics, player reservations, and active AI aircraft are separate values.

---

## 2. MOOSE feasibility and architecture

### 2.1 Primary operational framework

Military tasking should use MOOSE OPS classes rather than RAT:

- `AIRWING` for the aviation organization or airbase-level resource manager.
- `SQUADRON` for aircraft pools, templates, payloads, and capabilities.
- `AUFTRAG` for CAS, CAP, reconnaissance, transport, rescue, escort, and related missions.
- `COMMANDER` or `CHIEF` for task allocation.
- `WAREHOUSE` or AIRWING stock management for limited aircraft, payloads, and replacement resources.

RAT should not control requested CAS, MEDEVAC, escort, armed reconnaissance, CSAR, or tactical lift missions.

### 2.2 Optional RAT traffic

RAT is suitable for optional background activity such as:

- C-130 and C-17 logistics movements.
- Administrative fixed-wing traffic.
- UH-60 or CH-47 repositioning flights.
- Limited training and liaison flights.

RAT routes, airports, maximum concurrent aircraft, spawn intervals, and aircraft types must be explicitly restricted. Combat aircraft should normally fly scheduled or tasked OPS missions rather than arbitrary RAT routes.

Recommended mission option:

```lua
ENABLE_US_RAT_TRAFFIC = true
```

Initial maximum concurrent background traffic:

| Aircraft category | Recommended concurrent flights |
|---|---:|
| C-130 | 2-4 |
| C-17 | 1-2 |
| CH-47 | 1-3 |
| UH-60 | 2-4 |
| KC-135 or other tanker | 0-1 |
| Administrative fixed-wing | 1-2 |

### 2.3 Airframe registry

DCS does not convert a static object into the same active unit. The mission must remove the static and spawn a separate active group. A persistent registry must track the conceptual airframe across those representations.

Minimum record:

```lua
Airframe = {
  id = "336EFS_F15E_01",
  unit = "336th EFS",
  aircraftType = "F-15ESE",
  homebase = "Bagram",
  parking = 42,
  state = "STATIC",
  available = true,
  missionReady = true,
  damaged = false,
  playerSlot = "336EFS_Dodge11"
}
```

Required states should include at least:

- `RESERVE`
- `STATIC`
- `PLAYER_RESERVED`
- `PLAYER_ACTIVE`
- `AI_RESERVED`
- `AI_ACTIVE`
- `MAINTENANCE`
- `DAMAGED`
- `DESTROYED`

### 2.4 Inventory fields

Each unit entry should contain:

| Field | Meaning |
|---|---|
| `authorizedStrength` | Nominal or estimated deployed inventory |
| `missionReady` | Aircraft currently usable for missions |
| `staticVisible` | Aircraft currently displayed as statics |
| `playerReserved` | Aircraft reserved for client slots |
| `maxAIActive` | Maximum simultaneous AI aircraft |
| `ratActiveMax` | Maximum simultaneous RAT aircraft |
| `reserve` | Available but neither visible nor active |
| `sourceConfidence` | High, medium, or low |
| `parentUnit` | Parent formation for detachments |
| `detachmentOf` | Parent inventory from which the aircraft are deducted |
| `countIncludesDetachments` | Prevents double counting |

---

## 3. Consolidated planning ORBAT

## 3.1 Bagram Airfield

### Unit rotations and aircraft

| Period | Unit | Aircraft | Estimated local strength | Confidence |
|---|---|---|---:|---|
| August 2010 transition period | 494th Expeditionary Fighter Squadron | F-15E | 12-18 | Medium |
| Approximately late August 2010 into early 2011 | 336th Expeditionary Fighter Squadron | F-15E | 12-18 | Medium |
| 2010-2011 | 774th Expeditionary Airlift Squadron | C-130H/J | 6-10 | Medium |
| 2010-2011 | 83rd Expeditionary Rescue Squadron | HH-60G | 4-6 | Medium |
| From autumn 2010 | Task Force Phoenix / 3-10 Aviation and attached elements | UH-60 family | 12-16 | Low-Medium |
| From autumn 2010 | Attached or rotating heavy-lift element | CH-47 | 2-4 | Low |

### Recommended MOOSE inventory

| Aircraft | Inventory | Visible statics | Maximum active AI | Player slots |
|---|---:|---:|---:|---:|
| F-15E | 16 | 6-8 | 4-6 | 4-8 |
| C-130H/J | 8 | 2-3 | 2-3 | 2-4 where supported |
| HH-60G | 6 | 2-3 | 2-4 | AI only |
| UH-60 family | 12-16 | 4-6 | 4-6 | Optional community module |
| CH-47 | 4 | 2 | 2 | 2-4 |

### Rotation decision

The campaign begins during an F-15E unit transition. The implementation should support either:

- an early-campaign 494th EFS followed by the 336th EFS; or
- a fixed 336th EFS baseline when a simplified ORBAT is desired.

The exact handover date remains a research item and must not be presented as confirmed until supported by a primary source.

---

## 3.2 Jalalabad Airfield / FOB Fenty

Jalalabad is the primary Army aviation hub for the campaign's core area.

### Until approximately November 2010

| Unit | Aircraft | Estimated strength | Confidence |
|---|---|---:|---|
| Task Force Lighthorse | OH-58D | 16-24 | Low-Medium |
| Task Force Lighthorse attached attack element | AH-64D | 6-8 | Low-Medium |
| Utility and MEDEVAC element | UH-60 family | 4-8 | Low |

### From approximately November 2010

| Unit | Aircraft | Estimated strength | Confidence |
|---|---|---:|---|
| 6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters | OH-58D | 24-30 | Medium |
| B Company, 1-10 Aviation attached to TF Six Shooters | AH-64D | 6-8 | Medium |
| Attached utility and MEDEVAC elements | UH-60 family | 4-8 | Low |

### Recommended MOOSE inventory after the handover

| Aircraft | Inventory | Visible statics | Maximum active AI | Player slots |
|---|---:|---:|---:|---:|
| OH-58D | 24 | 8-12 | 4-8 | 4-8 |
| AH-64D | 8 | 4-6 | 2-4 | 4-8 |
| UH-60 family | 6 | 2-4 | 2-4 | Optional community module |

The AH-64 force is an attached company-sized element, not a full attack battalion. The OH-58D is the dominant locally based armed reconnaissance platform.

---

## 3.3 Khost Airfield / FOB Salerno

DCS Khost and the FOB Salerno area should form one regional aviation node. The map update adding CH-47- and C-130-capable parking improves its suitability as a secondary hub, but parking capability does not itself prove permanent historical basing.

| Unit | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| Task Force Tigershark / 1-10 Aviation | AH-64D | 12-16 | Medium |
| Attached cavalry element | OH-58D | 4-8 | Medium |
| Utility and MEDEVAC detachment | UH-60 family | 2-4 | Low |
| Rotating heavy-lift support | CH-47 | 0-2 permanently present | Low |

### Recommended MOOSE inventory

| Aircraft | Inventory | Visible statics | Maximum active AI | Player slots |
|---|---:|---:|---:|---:|
| AH-64D | 16 | 6-8 | 4-6 | 4-8 |
| OH-58D | 6 | 3-4 | 2-4 | 2-4 |
| UH-60 family | 4 | 2 | 2 | Optional |
| CH-47 | 0-2 local; drawn from parent pool | 0-1 | Mission dependent | 2 optional |

---

## 3.4 Kandahar Airfield

### Fixed-wing units

| Period | Unit | Aircraft | Estimated strength | Confidence |
|---|---|---|---:|---|
| August 2010 transition period | 81st Expeditionary Fighter Squadron | A-10C | 12-18 | Medium |
| Approximately September 2010 onward | 75th Expeditionary Fighter Squadron | A-10C | 12-18 | Medium |
| 2010-2011 | 772nd Expeditionary Airlift Squadron | C-130J | 6-10 | Medium |

VMA-231 with ten AV-8B aircraft belongs to spring 2010 and was preparing to leave before the campaign start. It must not be included in the default August 2010 ORBAT unless the campaign period is expanded earlier.

### Task Force Destiny / 101st Combat Aviation Brigade regional pool

| Aircraft | Estimated regional pool | Estimated aircraft normally at Kandahar | Confidence |
|---|---:|---:|---|
| AH-64D | 18-24 | 8-12 | Low-Medium |
| OH-58D | 18-24 | 8-12 | Low-Medium |
| UH-60 family | 20-30 | 10-16 | Low-Medium |
| CH-47D/F | 8-12 | 4-8 | Low-Medium |
| MEDEVAC UH-60 | 6-12 | 4-6 | Low-Medium |

Aircraft assigned to Tarinkot or other forward locations are part of this regional pool and must be deducted from Kandahar's available inventory.

### Recommended MOOSE inventory at Kandahar

| Aircraft | Inventory at base | Visible statics | Maximum active AI | Player slots |
|---|---:|---:|---:|---:|
| A-10C | 16 | 6-8 | 4-6 | 4-8 |
| C-130J | 8 | 2-3 | 2-3 | 2-4 |
| AH-64D | 12 | 4-6 | 4 | 4-8 |
| OH-58D | 12 | 4-6 | 4 | 4-8 |
| UH-60 family | 16 | 6-8 | 4-6 | Optional |
| CH-47 | 8 | 3-4 | 2-4 | 4 |

---

## 3.5 Camp Bastion

Camp Bastion represents a substantial US Marine aviation presence in addition to British forces.

### Heavy lift

| Period | Unit | Aircraft | Estimated or documented strength | Confidence |
|---|---|---|---:|---|
| Until early September 2010 | HMH-363 | CH-53D | Approximately 12 | Medium |
| From 1 August 2010 | HMH-361 (-) Reinforced | CH-53E | 17 | High |

The overlap and exact division of responsibility among rotating CH-53 units require further source validation before a date-specific handover is scripted.

### Light attack and utility

| Period | Unit | Aircraft | Estimated strength | Confidence |
|---|---|---|---:|---|
| Until 14 November 2010 | HMLA-369 | AH-1W | 8-12 | Medium |
| Until 14 November 2010 | HMLA-369 | UH-1Y | 4-6 | Medium |
| 14 November 2010 to 19 May 2011 | HMLA-169 | AH-1W | 8-12 | Medium |
| 14 November 2010 to 19 May 2011 | HMLA-169 | UH-1Y | 4-6 | Medium |

### Tiltrotor

| Period | Unit | Aircraft | Estimated strength | Confidence |
|---|---|---|---:|---|
| Until 10 January 2011 | VMM-365 | MV-22B | 10-12 | Medium |
| From 10 January 2011 | VMM-264 | MV-22B | 10-12 | Medium |

### Recommended MOOSE inventory

| Aircraft | Inventory | Visible statics | Maximum active AI | Player use |
|---|---:|---:|---:|---|
| CH-53D/E | 17-24 combined planning pool | 8-10 | 4-6 | AI |
| AH-1W | 10 | 4-6 | 4 | AI |
| UH-1Y | 5 | 2-3 | 2-4 | AI; UH-1H only as an acknowledged substitute |
| MV-22B | 12 | 4-6 | 4-6 | AI |

---

## 3.6 Camp Dwyer

Camp Dwyer should be modeled as a forward operating, refueling, rearming, MEDEVAC, and detachment location rather than as a second complete Marine aircraft group.

| Unit or role | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| HMLA-169 or HMLA-369 detachment | AH-1W | 4-6 | Medium |
| HMLA detachment | UH-1Y | 2-4 | Low-Medium |
| Army DUSTOFF detachment | UH-60A/L MEDEVAC | 2-4 | Medium |
| Temporary Harrier forward detachment | AV-8B | 2-4 when present | Medium |

Harriers at Dwyer are a forward detachment or transient force and must not be added to the default campaign inventory unless the parent squadron and date are validated for the selected scenario.

---

## 3.7 Tarinkot Airfield

Tarinkot is a forward detachment location using aircraft drawn from Task Force Destiny's Kandahar regional inventory.

| Aircraft | Estimated local strength | Confidence |
|---|---:|---|
| CH-47 | 2-4 | Medium |
| UH-60 family | 2-4 | Low-Medium |
| AH-64D | 2-4 | Low |
| OH-58D | 2-4 | Low |

These aircraft are not additional theater inventory. The registry must use `detachmentOf = "TF_DESTINY_KANDAHAR"` or an equivalent parent reference.

---

## 3.8 Shindand Air Base

| Unit | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| Task Force Comanche / 4th CAB | AH-64D | 8-12 | Medium |
| Task Force Comanche / 4th CAB | CH-47 | 4-8 | Medium |
| Other 4th CAB components | UH-60 family | 4-8 | Low-Medium |
| F Company, 2-135 Aviation MEDEVAC detachment | UH-60 MEDEVAC | 3-4 | Medium |

### Recommended MOOSE inventory

| Aircraft | Inventory | Visible statics | Maximum active AI | Player slots |
|---|---:|---:|---:|---:|
| AH-64D | 10 | 4-6 | 4 | 4-8 |
| CH-47 | 6 | 2-3 | 2-4 | 2-4 |
| UH-60 family including MEDEVAC | 6 | 2-4 | 2-4 | Optional |

---

## 4. Airfields without a confirmed permanent US flying unit

The following DCS locations may be used for logistics, transit, refueling, MEDEVAC pickup, forward staging, or temporary detachments. No permanent US flying unit should be created there until supported by a stronger source.

| Location | Default mission role |
|---|---|
| Kabul | Transport, VIP, liaison, and transit traffic |
| Herat | Coalition and transport traffic |
| Farah | Forward logistics and helicopter destination |
| Zaranj | Austere transport destination |
| Bost | Transport destination |
| Bamyan | Liaison and transport destination |
| Gardez | Helicopter destination or temporary detachment |
| Sharana | Army aviation destination or temporary detachment |
| Ghazni Heliport | MEDEVAC and utility destination |
| Urgoon Heliport | Forward detachment or FARP |
| Qala-i-Naw | Coalition transit |
| Chaghcharan | Coalition transit |
| Maymana | Coalition transit |
| FOB Thunder | FARP and helicopter destination |
| FOB Masum Ghar | FARP and helicopter destination |
| FOB Pasab | FARP and helicopter destination |
| FOB Howz-e-Madad | FARP and helicopter destination |

A high number of movements at an airfield does not by itself demonstrate that a US squadron was based there.

---

## 5. DCS module mapping

| Historical aircraft | DCS representation | Planned use |
|---|---|---|
| F-15E | Official player module | Bagram player and AI combat flights |
| A-10C | Official player module | Kandahar player and AI CAS flights |
| AH-64D | Official player module | Jalalabad, Khost/Salerno, Kandahar, Tarinkot, and Shindand |
| OH-58D | Official player module | Jalalabad, Khost/Salerno, Kandahar, and Tarinkot |
| CH-47F | Official player module | Heavy lift; may represent D/F-period operations with documented limitation |
| C-130J | Player or AI representation depending on installed DCS product and mission requirements | Bagram and Kandahar transport |
| UH-60 family | Community module or AI | Utility, transport, and MEDEVAC |
| HH-60G | AI | CSAR and rescue |
| AH-1W | AI | Bastion and Dwyer attack support |
| UH-1Y | AI; UH-1H only as explicit substitute | Bastion and Dwyer utility support |
| CH-53D/E | AI | Bastion heavy lift |
| MV-22B | AI | Bastion assault support |
| AV-8B | Official player module | Only when a date-correct squadron or detachment is included |
| F-16C | External theater support, not a default locally based unit | Optional off-map or reinforcement flights |
| F/A-18C | Carrier or external expeditionary support | Optional off-map support, not a local default squadron |
| F-15C | Not appropriate for the documented local F-15 role | Excluded from default ORBAT |

Substitute aircraft must be labeled as substitutions and must not be presented as historically exact.

---

## 6. Aggregated planning inventory

The following totals are planning ranges for all relevant DCS-map bases. Detachments are included in parent totals and must not be added again.

| Aircraft | Estimated US inventory represented on map | Recommended visible statics | Recommended maximum simultaneously active |
|---|---:|---:|---:|
| F-15E | 16 | 6-8 | 4-6 |
| A-10C | 16 | 6-8 | 4-6 |
| C-130H/J | 16 | 5-7 | 4-6 |
| AH-64D | 50-64 | 18-26 | 12-20 |
| OH-58D | 50-70 | 20-30 | 12-20 |
| UH-60 family | 50-70 | 20-30 | 12-20 |
| HH-60G | 4-6 | 2-3 | 2-4 |
| CH-47 | 18-28 | 8-12 | 6-10 |
| CH-53D/E | 17-29 | 8-12 | 4-8 |
| AH-1W | 8-12 | 4-6 | 2-4 |
| UH-1Y | 4-6 | 2-3 | 2-4 |
| MV-22B | 10-12 | 4-6 | 4-6 |
| AV-8B | 0 by default for the selected start date | 0 | 0 |

These totals are not simultaneous mission-ready counts. The active limits are deliberately much lower than total inventory.

---

## 7. Recommended implementation phases

### Phase 1: Core eastern operating area

1. Bagram: F-15E, C-130, HH-60G, and selected Army aviation support.
2. Jalalabad: OH-58D, AH-64D, and UH-60 elements.
3. Khost/FOB Salerno: AH-64D, OH-58D, and small utility component.
4. Player-slot/static-airframe synchronization.
5. Requested CAS, armed reconnaissance, CSAR, MEDEVAC, and transport missions.

### Phase 2: Southern theater

1. Kandahar A-10C and C-130J units.
2. Task Force Destiny aircraft pools.
3. Tarinkot detachments deducted from Kandahar inventory.
4. Camp Bastion Marine aviation.
5. Camp Dwyer forward detachments.

### Phase 3: Western theater and background traffic

1. Shindand Army aviation.
2. Optional logistics RAT network.
3. Transit-only and FARP locations.
4. Campaign persistence for losses, maintenance, and replacements.

---

## 8. Open research items

The following points must be verified before the ORBAT is considered final:

1. Exact 494th EFS to 336th EFS handover date at Bagram.
2. Unit succeeding the 336th EFS before 20 May 2011, if the rotation occurred inside the campaign window.
3. Exact 81st EFS to 75th EFS handover date at Kandahar.
4. Full aircraft composition and local strength of Task Force Lighthorse.
5. Complete attached-unit structure of Task Force Six Shooters.
6. Exact aircraft split between Task Force Tigershark and other 1-10 Aviation locations.
7. Exact Task Force Destiny distribution among Kandahar, Tarinkot, and other forward sites.
8. CH-53 unit overlap and handover chronology at Camp Bastion.
9. Date-correct Harrier unit presence after VMA-231.
10. Permanent versus transient US aviation elements at Kabul, Herat, Sharana, Gardez, and other smaller airfields.
11. Exact DCS parking capacities and aircraft-size compatibility after the latest Afghanistan map update.
12. Exact DCS type names, liveries, parking identifiers, and suitable templates for every unit.

---

## 9. Data quality rule

No estimated number may silently become a historical fact in code or documentation. Every unit record must retain:

```lua
sourceConfidence = "medium"
strengthBasis = "typical deployed squadron estimate"
researchStatus = "requires primary-source confirmation"
```

When stronger evidence is found, the data record and this document must be updated together.
