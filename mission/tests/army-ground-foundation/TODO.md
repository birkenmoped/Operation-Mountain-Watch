---
document_id: OMW-TEST-ARMY-GROUND-FOUNDATION-TODO
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - working scope and open tasks for the Jalalabad and Kunar ARMY ground foundation
not_authoritative_for:
  - final historical ground-force ORBAT strengths
  - final Mission Editor object state
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Arbeitsstand und To-do

## 1. Ziel und Scope

Aktiver Ground-Foundation-Raum:

```text
Jalalabad / FOB Fenty
FOB Joyce / COP Honaker-Miracle / OP JoJo
FOB Wright / Asadabad
FOB Bostick / OP Mustang / OP Clydesdale / OP Stallion
```

Salerno/Khost und Camp Fiaz sind für diesen Arbeitsstrang nicht Teil des aktiven Ground-Spielfelds.

Verbindlicher Recherche-/Kampagnenzeitraum:

```text
01.08.2010–31.12.2011
```

Aktive Ground-ORBAT-Arbeitsbaseline:

```text
JULY 2011
```

## 2. Historische und operative Baseline

```text
Jalalabad / Fenty
  TF Bronco / 3rd BCT, 25th ID
  TF Steel / 3-7 FA
  HHC / 3rd BSTB MP Platoon as June-2011 local security evidence

Joyce
  TF Cacti / 2-35 Infantry

Honaker-Miracle
  C Battery / 3-321 FA
  2 x M777A2 confirmed on 2011-07-30

Wright
  1-14th Illinois ADT / Security Force Platoon
  2010 M777 presence confirmed; exact July-2011 artillery assignment open

Bostick
  TF No Fear / 2-27 Infantry
```

Exakte Juli-2011-Company-/Platoon-Verteilungen bleiben dort offen, wo die Quellen sie nicht tragen.

Support-Hierarchie:

```text
BAGRAM
-> JALALABAD / FENTY
   -> JOYCE
      -> HONAKER-MIRACLE
         -> JOJO
   -> WRIGHT
   -> BOSTICK
      -> MUSTANG
      -> CLYDESDALE
      -> STALLION
```

Pakistan-Zufluss:

```text
PAKISTAN
-> TORKHAM
-> ROAD CONVOY
-> JALALABAD
```

Keine reguläre Pakistan->Jalalabad-Luftbrücke ohne belastbare Evidenz einer wiederkehrenden/etablierten Luftversorgungsbeziehung.

## 3. Working Vehicle Baseline

```text
Jalalabad / Fenty   48 wheeled vehicles
FOB Joyce           20 wheeled vehicles
FOB Wright          22 wheeled vehicles
FOB Bostick         26 wheeled vehicles
Honaker-Miracle      0 permanent wheeled vehicles
                     2 x M777A2 fixed artillery confirmed
```

Foundation-Type-Mapping:

```text
M-ATV class          -> CHAP_MATV
MaxxPro/MRAP class   -> MaxxPro_MRAP
FMTV/M1083 class     -> CHAP_M1083
utility/HMMWV        -> Hummer
Fenty fuel support   -> M978 HEMTT Tanker
Wright engineer      -> MaxxPro_MRAP abstraction; no fake Buffalo/Husky capability
Bostick recovery     -> CHAP_M1083 abstraction; no DCS towing claim
Honaker M777A2       -> L118_Unit PLANNED_PROXY, 2 pieces
```

## 4. MOOSE-first Planned Topology

Gepinnter Source:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Geplante Topologie:

```text
BLUE COMMANDER
|
+-- BDE_BLUE_GND_JALALABAD
+-- BDE_BLUE_GND_JOYCE
+-- BDE_BLUE_GND_WRIGHT
`-- BDE_BLUE_GND_BOSTICK

BRIGADE
-> PLATOON role pool
-> ARMYGROUP
-> physical DCS GROUP
```

Eine operative MOOSE-BRIGADE je Root Ground Node. Keine historische Brigadeabbildung. Abhängige COPs/OPs erhalten keine eigene BRIGADE.

## 5. CampaignState Working Quantities

Neue Working Baseline:

```text
GROUND_NODE_JALALABAD
  PERSONNEL 480
  VEHICLE    48
  SUPPLY    120
  AMMO      100
  FUEL      120

GROUND_NODE_JOYCE
  PERSONNEL 180
  VEHICLE    20
  SUPPLY     48
  AMMO       44
  FUEL       40

GROUND_NODE_WRIGHT
  PERSONNEL 120
  VEHICLE    22
  SUPPLY     36
  AMMO       30
  FUEL       36

GROUND_NODE_BOSTICK
  PERSONNEL 220
  VEHICLE    26
  SUPPLY     56
  AMMO       52
  FUEL       48
```

Dependent Personnel Commitments:

```text
Honaker-Miracle   40 from Joyce
Mustang           12 from Bostick
Clydesdale        12 from Bostick
Stallion          12 from Bostick
JoJo               0 active; 12 candidate while activation remains PROVISIONAL
```

`SUPPLY`, `AMMO` und `FUEL` werden als normalized logistics units geführt, nicht als unbelegte historische Tonnen-/Literangaben.

Readiness thresholds:

```text
AVAILABLE     >= 60%
CONSTRAINED   >= 35% and < 60%
CRITICAL      > 0% and < 35%
UNAVAILABLE   = 0% or required action minimum cannot be met
```

Protected local defense reserves:

```text
Jalalabad  PERSONNEL 120 | VEHICLE 10 | AMMO 25 | FUEL 20
Joyce      PERSONNEL  48 | VEHICLE  4 | AMMO 12 | FUEL  8
Wright     PERSONNEL  36 | VEHICLE  4 | AMMO 10 | FUEL  8
Bostick    PERSONNEL  60 | VEHICLE  5 | AMMO 14 | FUEL 10
```

Working action costs:

```text
Motorized Patrol
  PERSONNEL 12 | VEHICLE 4 | SUPPLY 1 | AMMO 2 | FUEL 2

Ground QRF
  PERSONNEL 16 | VEHICLE 4 | SUPPLY 1 | AMMO 3 | FUEL 3

Local Logistics / Resupply
  PERSONNEL 6 | VEHICLE 2 | FUEL 2 + payload resources

Honaker Fire Mission
  AMMO 2
  no additional vehicle or personnel materialization
```

Details:

- [`OMW-ARMY-GROUND-RESOURCE-QUANTITY-SETTLEMENT`](../../../docs/ground/ARMY-GROUND-RESOURCE-QUANTITY-AND-SETTLEMENT-BASELINE.md)
- [`OMW-ARMY-GROUND-RESOURCE-READINESS-CONTRACT`](../../../docs/ground/ARMY-GROUND-RESOURCE-READINESS-CONTRACT.md)

## 6. Settlement- und Autoritätsvertrag

Installation damage -> CampaignState:

```text
DCS event
-> stable representation correlation
-> classify strategic effect
-> idempotent settlement record
-> CampaignState mutation exactly once
-> readiness recalculation
```

Settlement classes:

```text
DAMAGE_INFRASTRUCTURE
LOSS_PERSONNEL
LOSS_VEHICLE
LOSS_FIRE_SUPPORT_SYSTEM
LOSS_SUPPLY
LOSS_AMMO
LOSS_FUEL
NO_STRATEGIC_SETTLEMENT
```

CampaignState remains sole authority:

```text
CampaignState
= strategic truth

MOOSE WAREHOUSE / BRIGADE / PLATOON
= operational mirror / selection layer

DCS Warehouse / group / static / cargo
= physical representation / telemetry
```

Explicitly forbidden:

```text
MOOSE AddAsset -> automatic strategic credit
MOOSE Returned -> automatic strategic credit
MOOSE Warehouse count -> overwrite CampaignState
DCS Despawn -> strategic return
DCS Destroy -> unclassified strategic debit
CTLD delivery -> automatic strategic credit
```

Mirror divergence produces reconciliation/error telemetry, not an automatic balancing transaction.

## 7. Phasenstatus

### Phase A – Standortnetz und historische Baseline

- [x] Recherchezeitraum und Juli-2011-Ground-Baseline festgelegt.
- [x] vier Root Ground Nodes festgelegt.
- [x] Wright und Bostick im Scope.
- [x] Bostick-OP-Kette Mustang/Clydesdale/Stallion als OMW-Planung festgelegt.
- [ ] vollständige angekündigte Standortliste später gegen den aktuellen Scope prüfen.
- [ ] prüfen, ob ein weiterer gameplay-relevanter FOB im aktuellen Raum fehlt.

### Phase B – Einheiten, Fahrzeugbaseline und technische Typen

- [x] historische Rollenbasis reconciled.
- [x] Working Vehicle Baseline festgelegt.
- [x] Foundation-Mappings festgelegt.
- [x] Wright Engineer-/Route-Support ohne erfundene spezielle Mine-Clearance-Funktion geschlossen.
- [x] Bostick Recovery-Support ohne erfundene DCS-Towing-Funktion geschlossen.
- [x] Fenty Fuel-Support mit `M978 HEMTT Tanker` als Planned Mapping geschlossen.
- [x] Honaker M777A2 mit `L118_Unit` als Planned Technical Proxy geschlossen.
- [ ] Jalalabad exakte Ground-QRF-/Base-Defense-Formation weiter recherchieren.
- [ ] Joyce exakte Juli-2011-Company-Verteilung weiter recherchieren.
- [ ] Bostick exakte Juli-2011-Maneuver-Company/-Platoons weiter recherchieren.
- [ ] Wright exakte Juli-2011-Artilleriezuordnung weiter recherchieren.

### Phase C – MOOSE-Architektur und Rollenpools

- [x] `COMMANDER -> BRIGADE -> PLATOON -> ARMYGROUP` Source-Review abgeschlossen.
- [x] vier operative MOOSE-BRIGADEs als Planned Foundation-Topologie festgelegt.
- [x] konkrete Fahrzeug-Rollenallokation pro Node festgelegt.
- [x] konkrete PLATOON-Namen, Templates und `Ngroups` pro Node festgelegt.
- [x] Utility-/Command-Fahrzeuge nicht automatisch zu Missions-PLATOONs gemacht.
- [x] Honaker Fixed Fire Support von dynamischer Warehouse-Materialisierung getrennt.
- [ ] DCS-Test: PLATOON Mission-Capability-/Asset-Selektion.
- [ ] DCS-Test: `SetReturnToLegion(false)` Mission-Ende -> physical stay -> Folgeauftrag.
- [ ] DCS-Test: mobile Return-/Handoff-Grenze und Warehouse-Rückgabe.
- [ ] DCS-Test: OPSTRANSPORT Embark/Unload/Disembark vor produktiver Nutzung.
- [ ] Restart/Reconstitution-Vertrag für persistent im Feld verbleibende Gruppen definieren.

### Phase D – CampaignState und Ressourcenvertrag

- [x] stabile Installation-IDs und Parent-Beziehungen definiert.
- [x] PERSONNEL/VEHICLE/SUPPLY/AMMO/FUEL Resource-Class-Verträge definiert.
- [x] OP-PERSONNEL-Reservation und direkter Parent-Nachschub definiert.
- [x] Working CampaignState-Ressourcenmengen pro Node festgelegt.
- [x] Protected Defense Reserves und Working Action Costs festgelegt.
- [x] numerische Readiness-Schwellen festgelegt.
- [x] Installationsangriff -> physischer Schaden -> CampaignState-Settlement definiert.
- [x] CampaignState <-> MOOSE WAREHOUSE Anti-Doppelautoritätsvertrag explizit geschlossen.
- [ ] Runtime-Adapter und exactly-once settlement technisch implementieren und testen.
- [ ] reale Readiness-/Action-Cost-Werte nach DCS-Acceptance bei Bedarf kalibrieren.

### Phase E – Mission Editor Foundation

- [ ] Projektinhaber erstellt/finalisiert die benötigten physischen Templates und Installationen in der `.miz`.
- [ ] Wright-Aufbau abschließen.
- [ ] Bostick-Aufbau abschließen.
- [ ] `ZON_BLUE_GND_<NODE>_ACCESS` je Root Node platzieren.
- [ ] Road Anchors / validierte Routen / Return-Handoff-Grenzen festlegen.
- [ ] geplante Ground-Templates im Mission Editor erzeugen.

### Phase F – Runtime und Acceptance

- [ ] kleinste MOOSE-first Runtime-Foundation implementieren.
- [ ] Lua-Syntax/Tests und Dokumentationsvalidator ausführen.
- [ ] Patrol/QRF/Logistics/OP-Reinforcement testen.
- [ ] Ground-AI-Pathfinding und Return/Recovery-Verhalten testen.
- [ ] M978 und L118-Proxy technisch testen.
- [ ] Settlement/duplicate-event resistance testen.
- [ ] Multiplayer-/Spawn-/Despawn-Sichtbarkeit testen.
- [ ] erst nach dokumentiertem DCS-Test `VALIDATED` setzen.

## 8. Nächster Arbeitsblock

Die rein fachliche Phase-D-Baseline ist jetzt vollständig genug für den nächsten technischen Foundation-Block:

```text
Restart/Reconstitution contract
-> ACCESS-zone / road-anchor Mission Editor contract
-> smallest MOOSE-first runtime adapter design
-> local build / DCS acceptance preparation
```

Mission-Editor-Änderungen bleiben ausschließlich beim Projektinhaber. ChatGPT verändert keine `.miz`.
