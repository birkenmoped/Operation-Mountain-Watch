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

Verbindlicher Recherche-/Kampagnenzeitraum: `01.08.2010–31.12.2011`.
Aktive Ground-ORBAT-Arbeitsbaseline: `JULY 2011`.

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

Pakistan-Zufluss bleibt ROAD-only via Torkham zum Jalalabad-Hub.

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
Wright engineer      -> MaxxPro_MRAP abstraction
Bostick recovery     -> CHAP_M1083 abstraction
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

```text
GROUND_NODE_JALALABAD  PERSONNEL 480 | VEHICLE 48 | SUPPLY 120 | AMMO 100 | FUEL 120
GROUND_NODE_JOYCE      PERSONNEL 180 | VEHICLE 20 | SUPPLY  48 | AMMO  44 | FUEL  40
GROUND_NODE_WRIGHT     PERSONNEL 120 | VEHICLE 22 | SUPPLY  36 | AMMO  30 | FUEL  36
GROUND_NODE_BOSTICK    PERSONNEL 220 | VEHICLE 26 | SUPPLY  56 | AMMO  52 | FUEL  48
```

Dependent Personnel Commitments:

```text
Honaker-Miracle   40 from Joyce
Mustang           12 from Bostick
Clydesdale        12 from Bostick
Stallion          12 from Bostick
JoJo               0 active; 12 candidate while PROVISIONAL
```

Readiness thresholds:

```text
AVAILABLE     >= 60%
CONSTRAINED   >= 35% and < 60%
CRITICAL      > 0% and < 35%
UNAVAILABLE   = 0% or required action minimum cannot be met
```

## 6. Settlement- und Autoritätsvertrag

```text
DCS event
-> stable representation correlation
-> classify strategic effect
-> idempotent settlement record
-> CampaignState mutation exactly once
-> readiness recalculation
```

CampaignState remains sole authority. MOOSE WAREHOUSE / BRIGADE / PLATOON are operational mirrors only; DCS objects are physical representation/telemetry only.

## 7. Restart / Reconstitution / ACCESS boundary

Vertrag:

- [`OMW-ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT`](../../../docs/ground/ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT.md)

Getrennte Fälle:

```text
FIXED MISSION-START ASSET
LIVE-SESSION FIELD-PERSISTENT ASSET
CROSS-SESSION RECONSTITUTION
```

Für live-session field persistence ist `AUFTRAG:SetReturnToLegion(false)` der primäre MOOSE-first Testpfad. Cross-session reconstitution bleibt nicht akzeptiert.

## 8. Phasenstatus

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
- [x] Wright Engineer-/Route-Support geschlossen.
- [x] Bostick Recovery-Support geschlossen.
- [x] Fenty Fuel-Support mit `M978 HEMTT Tanker` Planned Mapping geschlossen.
- [x] Honaker M777A2 mit `L118_Unit` Planned Technical Proxy geschlossen.
- [ ] Jalalabad exakte Ground-QRF-/Base-Defense-Formation weiter recherchieren.
- [ ] Joyce exakte Juli-2011-Company-Verteilung weiter recherchieren.
- [ ] Bostick exakte Juli-2011-Maneuver-Company/-Platoons weiter recherchieren.
- [ ] Wright exakte Juli-2011-Artilleriezuordnung weiter recherchieren.

### Phase C – MOOSE-Architektur und Rollenpools

- [x] `COMMANDER -> BRIGADE -> PLATOON -> ARMYGROUP` Source-Review abgeschlossen.
- [x] vier operative MOOSE-BRIGADEs als Planned Foundation-Topologie festgelegt.
- [x] konkrete Fahrzeug-Rollenallokation pro Node festgelegt.
- [x] konkrete PLATOON-Namen, Templates und `Ngroups` pro Node festgelegt.
- [x] Restart/Reconstitution-Vertrag definiert; Runtime-Acceptance offen.
- [x] ACCESS-/Road-/Return-Handoff-Vertrag definiert.
- [x] `WAREHOUSE:SetSpawnZone`, `COHORT:CountAssets`, `AUFTRAG:__Cancel` für Acceptance 1 gegen gepinnten Source geprüft.
- [ ] DCS-Test: PLATOON Mission-Capability-/Asset-Selektion.
- [ ] DCS-Test: `SetReturnToLegion(false)` Mission-Ende -> physical stay -> Folgeauftrag.
- [ ] DCS-Test: mobile Return-/Handoff-Grenze und Warehouse-Rückgabe.
- [ ] DCS-Test: OPSTRANSPORT Embark/Unload/Disembark vor produktiver Nutzung.

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

### Phase E – Mission Editor Foundation

- [ ] Projektinhaber erstellt/finalisiert die vollständigen physischen Templates und Installationen in der Production-`.miz`.
- [ ] Wright-Aufbau abschließen.
- [ ] Bostick-Aufbau abschließen.
- [ ] Root-Node ACCESS-Zonen und validierte Routen für den Production-Scope vervollständigen.
- [x] Acceptance-1-Prerequisites auf Joyce in `OMW_Template_v13_ground_test.miz` erstellt.
- [x] Read-only Objektvertrag gegen exakten v13-Hash geprüft: Warehouse host, 4x CHAP_MATV late-activated template, ACCESS zone und PATROL_TEST_01 vorhanden.
- [ ] Acceptance-1-Testbundle nach lokalem Build in die Owner-MIZ einbinden und MIZ-/Embedded-Hashkette neu prüfen.

### Phase F – Runtime und Acceptance

- [x] Acceptance-1-Testplan erstellt: [`OMW-TEST-ARMY-GROUND-ACCEPTANCE-1`](ACCEPTANCE-1.md).
- [x] kleinste Acceptance-1-Test-Runtime implementiert: `src/01-army-ground-acceptance-1.lua`.
- [x] deterministischer PowerShell-Builder erstellt: `tools/build-army-ground-acceptance-1.ps1`.
- [x] MOOSE-first Source-Review für die im Harness verwendeten Ground-Pfade aktualisiert.
- [ ] lokaler Builder-Lauf und Bundle-SHA-256 erfassen.
- [ ] Dokumentationsvalidator/Lua-Syntaxprüfung im lokalen Repository ausführen, soweit Werkzeuge vorhanden.
- [ ] Bundle in Test-MIZ nach Moose.lua einbinden; finalen MIZ-, internal-mission-, embedded-Bundle- und embedded-Moose-Hash erfassen.
- [ ] Acceptance 1 real in DCS ausführen.
- [ ] dcs.log-Marker und visuelle Beobachtung zu Pathfinding, MissionDone, Persistenz und Dublettenfreiheit auswerten.
- [ ] danach Patrol/QRF/Logistics/OP-Reinforcement stufenweise testen.
- [ ] erst nach dokumentiertem DCS-Test betroffene Ground-Methoden/Klassen als `VALIDATED` markieren.

## 9. Aktueller Gate

Die Owner-Testmission und der Remote-Testcode liegen jetzt vor.

```text
Owner mission:
OMW_Template_v13_ground_test.miz
pre-embed MIZ SHA-256:
6d12a55affc971de1de4d5e463c956fcb2e08a0d2de478ff13419747a825e7e8

remote source:
mission/tests/army-ground-foundation/src/01-army-ground-acceptance-1.lua

builder:
tools/build-army-ground-acceptance-1.ps1

BuilderVersion:
ARMY-GROUND-ACCEPTANCE-1-1
```

Nächster Gate:

```text
owner git pull
-> local builder / hash
-> owner embeds generated bundle in test .miz after Moose.lua
-> re-hash final MIZ and embedded resources
-> real DCS Acceptance 1
-> return real console/log/hash evidence
```

ChatGPT verändert keine `.miz`.
