---
document_id: OMW-ARMY-GROUND-VEHICLE-BASELINE
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - working OMW design quantities for physically represented ground vehicles at the current Jalalabad/Kunar Ground Foundation nodes
  - evidence-to-design reconstruction method used where exact July-2011 local inventories are unavailable
  - separation between historical minimum evidence, inferred quantity range and explicit OMW design value
  - current family-level composition after role allocation and Foundation type decisions
not_authoritative_for:
  - exact historical July-2011 property-book inventories
  - final Mission Editor object state
  - accepted DCS runtime behavior
  - final CampaignState personnel, ammo, fuel or supply quantities
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Working Vehicle Baseline

## 1. Zweck

Für FOB Fenty/Jalalabad, FOB Joyce, FOB Wright und FOB Bostick liegen keine vollständigen lokalen Juli-2011-Property-Book-Listen vor. OMW benötigt dennoch konkrete Mengen.

Daher gilt:

```text
historical evidence
-> confirmed minimum / confirmed capability
-> role and formation demand
-> site capacity and operational demand
-> inferred range
-> explicit OMW design value
```

`OMW_DESIGN_VALUE` ist eine bewusste Kampagnendesignentscheidung und keine Behauptung eines historisch exakt gezählten Tagesbestands.

## 2. Evidenzklassen

```text
CONFIRMED_MINIMUM
  directly counted, explicitly reported or physically documented minimum

STRONGLY_SUPPORTED
  repeated direct evidence for the local capability or vehicle family

INFERRED_RANGE
  bounded reconstruction from site role, formation context, physical capacity and operational demand

OMW_DESIGN_VALUE
  explicit working project quantity selected inside the supported range
```

Ältere In-Period- oder Pre-Period-Evidenz darf Capability und Größenordnung stützen, wird aber nicht stillschweigend als Juli-2011-Inventar fortgeschrieben.

## 3. Rekonstruktionsanker

### Jalalabad / FOB Fenty

Gestützt sind regionaler Brigade-/HQ- und Logistikhub, kontinuierlicher Cargo-Umschlag und erheblicher militärischer Ground-Logistics-Verkehr. Durchfahrende Konvois werden nicht als lokaler organischer Bestand gezählt.

### FOB Joyce

Gestützt sind TF-Cacti-/2-35-Kontext, lokale Patrol/QRF-Anforderung, Fuel-/Resupply-Handling sowie ältere site-bound MRAP-, EOD-/CIED- und Recovery-Aktivität.

### FOB Wright

Gestützt sind Juli-2011-SECFOR, PRT-/Security-/FARP-/Support-Rolle, erhebliche protected-vehicle activity und ältere konkrete Recovery-/MRAP-Schadensereignisse. Die 2010er M777-Evidenz wird nicht als Juli-2011-Artilleriebestand fortgeschrieben.

### FOB Bostick

Gestützt sind Battalion-/Task-Force-Node, lokale Patrol/QRF- und OP-Support-Anforderung sowie ältere Bostick-origin Recovery-/Support-Aktivität mit Wrecker-/Truck-Bezug.

### COP Honaker-Miracle

Direkt bestätigt sind am 30.07.2011 zwei M777A2 von C Battery / 3-321 FA. Ein eigener permanenter Juli-2011-Motorpool ist nicht belegt.

## 4. Working Quantity Baseline

| Installation | Inferred wheeled range | OMW working wheeled value | Fixed artillery | Status |
|---|---:|---:|---:|---|
| Jalalabad / FOB Fenty | 40–55 | **48** | separate fire-support contract | `OMW_DESIGN_VALUE` |
| FOB Joyce | 16–24 | **20** | none at Joyce by this contract | `OMW_DESIGN_VALUE` |
| FOB Wright | 18–26 | **22** | July assignment open | `OMW_DESIGN_VALUE` |
| FOB Bostick | 22–30 | **26** | July assignment open | `OMW_DESIGN_VALUE` |
| COP Honaker-Miracle | 0–2 permanent wheeled | **0** | **2 x M777A2** | wheeled `OMW_DESIGN_VALUE`; artillery `CONFIRMED_MINIMUM` |

## 5. Beschlossene Fahrzeugfamilien pro Node

### 5.1 Joyce – 20

```text
8  protected light mobility / M-ATV class
6  protected MRAP / MaxxPro class
4  medium logistics / FMTV-M1083 class
2  utility / HMMWV class
--
20 total
```

Foundation-Mapping:

```text
8  CHAP_MATV
6  MaxxPro_MRAP
4  CHAP_M1083
2  Hummer
```

### 5.2 Wright – 22

Die zuvor offenen zwei Engineer-/Route-Support-Slots werden nicht mit einem erfundenen Buffalo-/Husky-Typ belegt. Für die Foundation werden sie in die geschützte MRAP-Familie integriert.

```text
8  protected light mobility / M-ATV class
8  protected MRAP / MaxxPro class
4  medium logistics / FMTV-M1083 class
2  utility / HMMWV class
--
22 total
```

Foundation-Mapping:

```text
8  CHAP_MATV
8  MaxxPro_MRAP
4  CHAP_M1083
2  Hummer
```

Davon sind vier MaxxPro als `ENGINEER / ROUTE SUPPORT SECURITY` reserviert. Das ist keine DCS-Mine-Clearing-Funktion.

### 5.3 Bostick – 26

Die zuvor offene Recovery-/Support-Position wird für die Foundation mit der M1083-Familie abgebildet. Die strategische Recovery-Rolle bleibt erhalten; DCS-Towing wird nicht behauptet.

```text
10 protected light mobility / M-ATV class
8  protected MRAP / MaxxPro class
6  medium logistics / FMTV-M1083 class
2  utility / HMMWV class
--
26 total
```

Foundation-Mapping:

```text
10 CHAP_MATV
8  MaxxPro_MRAP
6  CHAP_M1083
2  Hummer
```

### 5.4 Jalalabad / FOB Fenty – 48

Die frühere offene Heavy-Logistics/Fuel-Allokation wird geteilt in zusätzliche M1083-Logistik und M978-Fuel-Support.

```text
16 protected light mobility / M-ATV class
14 protected MRAP / MaxxPro class
12 medium logistics / FMTV-M1083 class
2  M978 HEMTT fuel-support
4  utility / HMMWV class
--
48 total
```

Foundation-Mapping:

```text
16 CHAP_MATV
14 MaxxPro_MRAP
12 CHAP_M1083
2  M978 HEMTT Tanker
4  Hummer
```

`M978 HEMTT Tanker` ist im gepinnten MOOSE-Source als exakter DCS-Type-String enthalten; die tatsächliche OMW-Mission-Verfügbarkeit und das Verhalten sind noch DCS-testpflichtig.

### 5.5 COP Honaker-Miracle

```text
0 permanent wheeled vehicles in the working baseline
2 M777A2 fixed artillery pieces historically confirmed
```

Technische Foundation-Abbildung:

```text
2 x L118_Unit as PLANNED_PROXY
```

`L118_Unit` wird nicht als historisch identisches M777A2-System dargestellt. Der Proxy benötigt DCS-Acceptance.

## 6. Rollenallokation

Die gleiche strategische Fahrzeugmenge wird nicht mehrfach für verschiedene Rollen gezählt. Die aktuelle Rollenaufteilung steht verbindlich für diesen Planned-Stand in `OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE`.

Kurzfassung:

```text
JALALABAD
  patrol/mobile security
  QRF
  local security reserve
  logistics
  fuel support
  utility/command

JOYCE
  patrol
  QRF
  local security
  logistics
  utility/command

WRIGHT
  patrol/SECFOR
  QRF
  engineer/route-support security
  logistics
  utility/command

BOSTICK
  patrol
  QRF
  OP reinforcement/mobile security
  logistics/recovery support
  utility/command
```

## 7. HMMWV-Grenze

Die aktuelle Evidenz trägt keine pauschale Aussage, dass HMMWV auf diesen Installationen im Juli 2011 vollständig ausgeschlossen waren. OMW behält daher kleine Utility-/Command-Anteile, während externe Hochrisiko-Patrol-/QRF-Rollen auf MRAP-/M-ATV-Klassen konzentriert werden.

## 8. Strategisch versus physisch

```text
CampaignState VEHICLE stock
!= all vehicles visible simultaneously
!= parked decorative vehicles
!= MOOSE Warehouse asset count
```

Ein Node-Bestand kann in der späteren Runtime aufgeteilt werden in:

```text
fixed/local physical representation
operational reserve
active mission commitment
maintenance/unavailable fraction
virtual strategic reserve
```

Keine Kategorie darf zusätzliche strategische Fahrzeuge außerhalb `CampaignState` erzeugen.

## 9. Transiente Konvois

Ein ankommender Parent-/Theater-Konvoi wird nicht automatisch Teil des lokalen organischen Fahrzeugpools.

```text
transient transport vehicle
-> remains bound to transfer / parent contract
-> delivers cargo
-> returns or is explicitly reassigned
```

Nur ein explizites CampaignState-Settlement ändert strategische Fahrzeugzugehörigkeit.

## 10. Offene Acceptance-Punkte

```text
- Mission Editor template creation and placement
- M978 HEMTT Tanker availability/behavior in the actual OMW mission
- L118 proxy range/fire behavior for the Honaker M777A2 role
- road-side ACCESS zones and validated routes
- PLATOON selection/tasking behavior
- spawn/return visibility boundary
- CampaignState <-> MOOSE Warehouse runtime settlement
```

Kein Punkt dieses Dokuments ist `VALIDATED` ohne dokumentierten DCS-Test.
