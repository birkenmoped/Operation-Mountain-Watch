---
document_id: OMW-AIR-US-ORBAT-RESEARCH
status: BINDING
authoritative_for:
  - historical US aviation research context
  - confidence-qualified planning ranges
  - airfield and unit research backlog
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
superseded_by_for_active_orbat:
  - OMW-AIR-ACTIVE-ORBAT
  - basis-specific current mission-editor baselines
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: HISTORICAL_RESEARCH_REFERENCE
owning_policy: OMW-GOV-001
supersedes:
superseded_by:
source_commit: GIT_HISTORY
---

# US Air Order of Battle – Research and MOOSE Integration Context

## Document status

This document is the historical research and planning context for United States aviation represented in **Operation Mountain Watch**.

It is not the authority for the currently active squadron selection, client count, exact mission-editor object list, or current basis inventory. Those decisions are defined in:

- `OMW-AIR-ACTIVE-ORBAT` – `docs/19-active-air-orbat-decisions.md`;
- the project-wide player-slot policy;
- the current basis-specific Mission Editor baseline.

Binding scope:

- **Research and campaign period:** 1 August 2010 through 31 December 2011;
- **Map:** DCS: Afghanistan;
- **Primary operational area:** Nangarhar, Laghman, Kunar, and Nuristan;
- **Primary local hub:** Jalalabad Airfield / FOB Fenty;
- **Strategic and regional hubs:** Bagram, Kabul, Khost/FOB Salerno, Kandahar, Camp Bastion, Camp Dwyer, Tarinkot, and Shindand.

## Time and evidence model

The period includes real unit rotations and command changes. OMW does not automatically reproduce every historical handover by campaign date. The active ORBAT is a deliberate, playable selection within the period.

Every strength value in this document must retain an evidence class:

- **High confidence:** concrete deployed strength, serial inventory, official unit record, or closely documented local inventory;
- **Medium confidence:** unit and aircraft type are documented; quantity is derived from deployment evidence or a typical deployed squadron, company, or detachment;
- **Low confidence:** local presence or parent formation is plausible or documented, but the exact local strength is not established.

Satellite imagery is strong evidence for visible aircraft and ramp use at the image date, but not by itself for:

- complete administrative strength;
- aircraft in flight, maintenance, shelters, or other parking areas;
- exact unit identity;
- mission-ready rate.

No estimate in this document may silently become a historical fact or override a newer binding decision.

---

## 1. Design and implementation principles

1. Historically plausible units are assigned to documented or most plausible bases.
2. Active squadron selection is separated from historical rotation research.
3. DCS player modules may be represented by client slots, subject to the binding limit of two aircraft per type and base.
4. Aircraft without a player module may be represented as AI assets when the DCS type and MOOSE behavior are validated.
5. RAT is restricted to optional background or administrative traffic; tactical missions use MOOSE OPS classes.
6. Static aircraft, client reservations, active AI aircraft, templates, virtual reserve, damaged aircraft, and destroyed aircraft are separate layers.
7. Detachments are deducted from parent formations and are never counted twice.
8. A static object is a visual representation, not an additional aircraft.
9. Active local inventories remain correctable without redesigning the AIRWING/SQUADRON architecture.

## 2. MOOSE architecture

Primary military tasking uses:

- `AIRWING` for base- or organization-level aviation resources;
- `SQUADRON` for aircraft pools, templates, payloads, and capabilities;
- `AUFTRAG` for CAS, CAP, reconnaissance, transport, rescue, escort, and related missions;
- `COMMANDER` or `CHIEF` for task allocation;
- `WAREHOUSE` or AIRWING stock management for limited aircraft, payloads, and replacement resources.

RAT may be used only for controlled background activity such as:

- C-130/C-17 logistics movements;
- administrative fixed-wing traffic;
- limited helicopter repositioning;
- training or liaison flights.

Requested CAS, MEDEVAC, escort, armed reconnaissance, CSAR, and tactical lift are not RAT responsibilities.

### Airframe registry

A conceptual airframe persists across static, client, AI, maintenance, damage, and loss representations.

Minimum fields:

```lua
Airframe = {
  id = "BAGRAM_F15E_335EFS_01",
  unit = "335th EFS",
  aircraftType = "F-15ESE",
  homebase = "Bagram",
  parking = 42,
  state = "STATIC",
  available = true,
  missionReady = true,
  damaged = false,
  playerSlot = "CLIENT_US_BGRM_F15E_01"
}
```

Required states include:

- `RESERVE`;
- `STATIC`;
- `PLAYER_RESERVED`;
- `PLAYER_ACTIVE`;
- `AI_RESERVED`;
- `AI_ACTIVE`;
- `MAINTENANCE`;
- `DAMAGED`;
- `DESTROYED`.

---

## 3. Historical and planning context by airfield

## 3.1 Bagram Airfield

### Fighter rotations and late-2011 evidence

| Period | Unit | Aircraft | Research strength / evidence | Confidence |
|---|---|---|---:|---|
| August 2010 transition | 494th Expeditionary Fighter Squadron | F-15E | 12–18 typical deployment range | Medium |
| late August 2010 into early 2011 | 336th Expeditionary Fighter Squadron | F-15E | 12–18 typical deployment range | Medium |
| November/December 2011 | 335th Expeditionary Fighter Squadron | F-15E | at least 13 visible / documented local working inventory | High for presence; medium-high for exact local inventory |
| October 2011 onward | 121st Expeditionary Fighter Squadron | F-16C Block 30 | 13 serials documented; at least 11 visible | High |
| 2010–2011 | 774th Expeditionary Airlift Squadron | C-130H/J | 6–10 planning range | Medium |
| 2010–2011 | 83rd Expeditionary Rescue Squadron | HH-60G | 4–6 planning range | Medium |
| from autumn 2010 | Task Force Phoenix / 3-10 Aviation and attached elements | UH-60 family | 12–16 regional planning range | Low-Medium |
| from autumn 2010 | attached or rotating heavy-lift element | CH-47 | 2–4 planning range | Low |

Active fighter selection is no longer ambiguous:

```text
335th EFS – 13 F-15E
121st EFS – 13 F-16C Block 30
DCS substitution: F-16C Block 50
```

The 494th and 336th EFS remain historical rotation context only.

### Bagram support-aircraft research ranges

| Aircraft | Research inventory range | Notes |
|---|---:|---|
| C-130H/J | 6–10 | exact current ME baseline is basis-specific |
| HH-60G | 4–6 | CSAR node; active templates require separate validation |
| UH-60 family | 12–16 | regional/attached pool; local split requires research |
| CH-47 | 2–4 | rotating or attached heavy lift |

Client counts are not taken from older ranges in this document. The project-wide limit is two client aircraft per type and base.

## 3.2 Jalalabad Airfield / FOB Fenty

Jalalabad is the primary Army aviation hub for the campaign core area.

Historical rotation context:

| Period | Unit / element | Aircraft | Research strength | Confidence |
|---|---|---|---:|---|
| until approximately November 2010 | Task Force Lighthorse | OH-58D | 16–24 | Low-Medium |
| until approximately November 2010 | attached attack element | AH-64D | 6–8 | Low-Medium |
| until approximately November 2010 | utility / MEDEVAC | UH-60 family | 4–8 | Low |
| from approximately November 2010 | 6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters | OH-58D | 24–30 | Medium |
| from approximately November 2010 | B Company, 1-10 Aviation | AH-64D | 6–8 | Medium |
| later campaign baseline | utility / MEDEVAC | UH-60 | 8 | sufficiently confirmed for OMW baseline |
| later campaign baseline | heavy lift | CH-47 | 8 | sufficiently confirmed for OMW baseline |

Binding active inventory:

```text
24 OH-58D
 8 AH-64D
 8 UH-60
 8 CH-47
```

The `24/8/8/8` inventory is authoritative for OMW. Older `24/8/6` values are superseded.

## 3.3 Khost Airfield / FOB Salerno

Khost/FOB Salerno is a regional aviation node. DCS parking compatibility does not itself prove permanent historical basing.

| Unit / element | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| Task Force Tigershark / 1-10 Aviation | AH-64D | 12–16 | Medium |
| attached cavalry element | OH-58D | 4–8 | Medium |
| utility / MEDEVAC detachment | UH-60 family | 2–4 | Low |
| rotating heavy-lift support | CH-47 | 0–2 permanently present | Low |

These values remain research ranges until a binding Khost basis manifest is adopted.

## 3.4 Kandahar Airfield

Historical A-10 rotation context:

| Period | Unit | Aircraft | Research strength | Confidence |
|---|---|---|---:|---|
| August 2010 transition | 81st Expeditionary Fighter Squadron | A-10C | 12–18 | Medium |
| later 2010 / 2011 rotation context | 74th or 75th Expeditionary Fighter Squadron | A-10C | 12–18 | time-specific; retain as research context |
| late-2011 active OMW selection | 107th Expeditionary Fighter Squadron | A-10C | 16 | binding OMW inventory |
| 2010–2011 | 772nd Expeditionary Airlift Squadron | C-130J | 6–10 | Medium |

Binding active selection:

```text
107th Expeditionary Fighter Squadron
16 A-10C
```

Task Force Destiny / 101st Combat Aviation Brigade regional research pool:

| Aircraft | Estimated regional pool | Estimated normally at Kandahar | Confidence |
|---|---:|---:|---|
| AH-64D | 18–24 | 8–12 | Low-Medium |
| OH-58D | 18–24 | 8–12 | Low-Medium |
| UH-60 family | 20–30 | 10–16 | Low-Medium |
| CH-47D/F | 8–12 | 4–8 | Low-Medium |
| MEDEVAC UH-60 | 6–12 | 4–6 | Low-Medium |

Aircraft assigned to Tarinkot or other forward sites are deducted from the parent regional pool.

## 3.5 Camp Bastion

Historical research context:

| Period | Unit | Aircraft | Strength / range | Confidence |
|---|---|---|---:|---|
| until early September 2010 | HMH-363 | CH-53D | approximately 12 | Medium |
| from 1 August 2010 | HMH-361 (-) Reinforced | CH-53E | 17 | High |
| until 14 November 2010 | HMLA-369 | AH-1W | 8–12 | Medium |
| until 14 November 2010 | HMLA-369 | UH-1Y | 4–6 | Medium |
| from 14 November 2010 | HMLA-169 | AH-1W | 8–12 | Medium |
| from 14 November 2010 | HMLA-169 | UH-1Y | 4–6 | Medium |
| until 10 January 2011 | VMM-365 | MV-22B | 10–12 | Medium |
| from 10 January 2011 | VMM-264 | MV-22B | 10–12 | Medium |

Binding active OMW selection remains:

```text
HMLA-169: 10 AH-1W and 5 UH-1Y
HMH-361 (-) Reinforced: 17 CH-53E
MV-22B: no active implementation
```

CH-53D and alternative HMLA/VMM rotations remain historical context and are not added in parallel.

## 3.6 Camp Dwyer

Camp Dwyer is modeled as a forward operating, refueling, rearming, MEDEVAC, and detachment location rather than a second complete Marine aircraft group.

| Unit or role | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| HMLA detachment | AH-1W | 4–6 | Medium |
| HMLA detachment | UH-1Y | 2–4 | Low-Medium |
| Army DUSTOFF detachment | UH-60 MEDEVAC | 2–4 | Medium |
| temporary Harrier detachment | AV-8B | 2–4 when present | Medium |

Detachments must be deducted from parent inventories.

## 3.7 Tarinkot Airfield

Tarinkot is a forward detachment location using aircraft from the Kandahar regional inventory.

| Aircraft | Estimated local strength | Confidence |
|---|---:|---|
| CH-47 | 2–4 | Medium |
| UH-60 family | 2–4 | Low-Medium |
| AH-64D | 2–4 | Low |
| OH-58D | 2–4 | Low |

These are not additional theater aircraft.

## 3.8 Shindand Air Base

| Unit / element | Aircraft | Estimated local strength | Confidence |
|---|---|---:|---|
| Task Force Comanche / 4th CAB | AH-64D | 8–12 | Medium |
| Task Force Comanche / 4th CAB | CH-47 | 4–8 | Medium |
| other 4th CAB components | UH-60 family | 4–8 | Low-Medium |
| F Company, 2-135 Aviation MEDEVAC detachment | UH-60 MEDEVAC | 3–4 | Medium |

A binding Shindand basis manifest must resolve the exact active inventory before implementation.

---

## 4. Locations without a confirmed permanent US flying unit

The following locations may support logistics, transit, refueling, MEDEVAC pickup, temporary staging, detachments, or FARPs. No permanent US flying unit is created solely from traffic volume or parking capability.

| Location | Default mission role |
|---|---|
| Kabul | transport, VIP, liaison, transit |
| Herat | coalition and transport traffic |
| Farah | forward logistics and helicopter destination |
| Zaranj | austere transport destination |
| Bost | transport destination |
| Bamyan | liaison and transport destination |
| Gardez | helicopter destination or temporary detachment |
| Sharana | Army aviation destination or temporary detachment |
| Ghazni Heliport | MEDEVAC and utility destination |
| Urgoon Heliport | forward detachment or FARP |
| Qala-i-Naw | coalition transit |
| Chaghcharan | coalition transit |
| Maymana | coalition transit |
| FOB Thunder | FARP and helicopter destination |
| FOB Masum Ghar | FARP and helicopter destination |
| FOB Pasab | FARP and helicopter destination |
| FOB Howz-e-Madad | FARP and helicopter destination |

---

## 5. DCS representation mapping

| Historical aircraft | DCS representation | Planned use / limitation |
|---|---|---|
| F-15E | official player module | Bagram player and AI; `THIRD_PARTY_AT_RISK` |
| F-16C Block 30 | F-16C Block 50 | explicit historical substitution |
| A-10C | official player module | Kandahar player and AI CAS |
| AH-64D | official player module | regional Army aviation |
| OH-58D | official player module | reconnaissance and light attack |
| CH-47D/F | CH-47F | documented period/model limitation |
| C-130H/J | player or AI representation | transport and logistics |
| UH-60 family | community module or AI | utility, transport, MEDEVAC |
| HH-60G | AI | CSAR and rescue |
| AH-1W | AI | Bastion and Dwyer |
| UH-1Y | AI or explicitly approved substitute | no silent UH-1H equivalence |
| CH-53D/E | AI | Bastion heavy lift |
| MV-22B | no active OMW implementation | historical context only |
| AV-8B | official player module | only with date-correct parent/detachment decision |
| F/A-18C | external or carrier support | not a default local squadron |
| F-15C | not appropriate for the documented local F-15 role | excluded |

Substitutions are always labeled and never presented as historically exact.

---

## 6. Current project build sequence

The former phase order in this document is superseded by `COMPLETE_FOUNDATION_BUILD_PHASE`.

Current sequence:

1. establish all required airfield, FOB, ORBAT, player, AI-template, static, warehouse, parking, and naming baselines;
2. create the fundamental MOOSE AIRWING/SQUADRON and logistics structures;
3. validate basis startup, parking, inventory separation, and client protection;
4. add AUFTRAG, OPSTRANSPORT, logistics, CSAR, persistence, and director behavior in isolated increments;
5. perform integration and load tests across the complete foundation.

---

## 7. Open research items

1. complete Bagram rotation chronology across the full extended period;
2. complete attached-unit structure of Task Force Six Shooters;
3. exact local split of Task Force Tigershark and other 1-10 Aviation elements;
4. exact Task Force Destiny distribution among Kandahar, Tarinkot, and forward sites;
5. CH-53 handover and overlap chronology at Camp Bastion;
6. date-correct Harrier detachments after VMA-231;
7. permanent versus transient aviation at Kabul, Herat, Sharana, Gardez, and smaller sites;
8. exact DCS parking capacities and aircraft-size compatibility in the current Afghanistan map version;
9. exact DCS type names, liveries, parking identifiers, and suitable templates;
10. source-backed static placement and visible ramp inventories for the full foundation build.

## 8. Data-quality rule

Every estimated unit record retains explicit provenance:

```lua
sourceConfidence = "medium"
strengthBasis = "documented deployment plus planning estimate"
researchStatus = "requires additional source confirmation"
activeDecisionSource = "OMW-AIR-ACTIVE-ORBAT"
```

When stronger evidence is found, the research record and the binding active decision are reviewed separately. New evidence does not silently change the active mission inventory.
