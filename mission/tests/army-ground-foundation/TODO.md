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

## 1. Ziel

Für Jalalabad/Kunar wird eine belastbare BLUE-Ground-Foundation aufgebaut, die historische Installationen, Juli-2011-Einheitenbaseline, CampaignState-Ressourcenhoheit und eine MOOSE-first Runtime-Struktur zusammenführt.

Aktueller Operationsraum:

```text
Jalalabad / FOB Fenty
FOB Joyce / COP Honaker-Miracle / OP JoJo
FOB Wright / Asadabad
FOB Bostick / OP Mustang / OP Clydesdale / OP Stallion
```

Salerno/Khost und Camp Fiaz sind für diesen Arbeitsstrang nicht Teil des aktiven Ground-Spielfelds.

## 2. Historische und Domain-Baselines

Verbindlicher Recherche-/Kampagnenzeitraum:

```text
01.08.2010–31.12.2011
```

Aktive Ground-ORBAT-Arbeitsbaseline:

```text
JULY 2011
```

Aktueller belastbarer Formation-/Standortstand:

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

## 3. Ground-Node- und Support-Hierarchie

Root Ground Nodes:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_BOSTICK
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

Pakistan-Zufluss:

```text
PAKISTAN
-> TORKHAM
-> ROAD CONVOY
-> JALALABAD
```

Keine reguläre Pakistan->Jalalabad-Luftbrücke ohne belastbare Evidenz einer wiederkehrenden/etablierten Luftversorgungsbeziehung.

OPs besitzen keinen unabhängigen strategischen Stock, kein Warehouse und keine normale AIR-Sustainment-Kette. Explizite OP-Auffüllung ist PERSONNEL-only und erfolgt über den direkten Parent.

## 4. Working Vehicle Baseline

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

Details:

- [`OMW-ARMY-GROUND-VEHICLE-BASELINE`](../../../docs/ground/ARMY-GROUND-VEHICLE-BASELINE.md)
- [`OMW-ARMY-GROUND-TEMPLATE-NAMING-TYPE-MAPPING`](../../../docs/ground/ARMY-GROUND-TEMPLATE-NAMING-AND-DCS-TYPE-MAPPING.md)

## 5. MOOSE-first geplante Topologie

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

Damit ist für den aktuellen Foundation-Scope **eine operative MOOSE-BRIGADE je Root Ground Node** geplant. Das ist keine historische Brigadeabbildung.

Abhängige COPs/OPs erhalten keine eigene BRIGADE.

Konkrete Rollen-/Template-/Ngroups-Zuordnungen stehen in:

- [`OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE`](../../../docs/ground/ARMY-GROUND-ROLE-AND-PLATOON-BASELINE.md)

Source-verifiziert sind insbesondere:

```text
COMMANDER:AddBrigade(...)
BRIGADE:New(...)
BRIGADE:AddPlatoon(...)
PLATOON:New(...)
COHORT:AddMissionCapability(...)
COHORT:SetMissionRange(...)
COHORT:CanMission(...)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:NewARTY(...)
```

DCS-Selektions-/Lifecycle-Acceptance bleibt offen.

## 6. Phasenstatus

### Phase A – Standortnetz und historische Baseline

- [x] Recherchezeitraum und Juli-2011-Ground-Baseline festgelegt.
- [x] vier Root Ground Nodes festgelegt.
- [x] Wright und Bostick im Scope.
- [x] Camp Fiaz, Salerno/Khost für diesen Ground-Foundation-Scope ausgeschlossen.
- [x] Bostick-OP-Kette Mustang/Clydesdale/Stallion als OMW-Planung festgelegt.
- [ ] vollständige angekündigte Standortliste später gegen den aktuellen Scope prüfen.
- [ ] prüfen, ob ein weiterer gameplay-relevanter FOB im aktuellen Raum fehlt.

### Phase B – Einheiten, Fahrzeugbaseline und technische Typen

- [x] Jalalabad, Joyce, Wright und Bostick historische Rollenbasis reconciled.
- [x] Honaker: 2 x M777A2 am 30.07.2011 belegt.
- [x] Working Vehicle Baseline für Fenty/Joyce/Wright/Bostick festgelegt.
- [x] M-ATV/MaxxPro/M1083/HMMWV Foundation-Mappings festgelegt.
- [x] Wright Engineer-/Route-Support ohne erfundenen Buffalo-/Husky-Proxy geschlossen.
- [x] Bostick Recovery-Support ohne erfundenes Wrecker-DCS-Modell geschlossen.
- [x] Fenty Fuel-Support mit `M978 HEMTT Tanker` als Planned Mapping geschlossen.
- [x] Honaker M777A2 mit `L118_Unit` als explizitem Planned Technical Proxy geschlossen.
- [ ] Jalalabad exakte Ground-QRF-/Base-Defense-Formation weiter recherchieren.
- [ ] Joyce exakte Juli-2011-Company-Verteilung weiter recherchieren.
- [ ] Bostick exakte Juli-2011-Maneuver-Company/-Platoons weiter recherchieren.
- [ ] Wright exakte Juli-2011-Artilleriezuordnung weiter recherchieren.

### Phase C – MOOSE-Architektur und Rollenpools

- [x] `COMMANDER -> BRIGADE -> PLATOON -> ARMYGROUP` Source-Review abgeschlossen.
- [x] vier operative MOOSE-BRIGADEs als Planned Foundation-Topologie festgelegt.
- [x] konkrete Fahrzeug-Rollenallokation pro Node festgelegt.
- [x] konkrete PLATOON-Namen, Templates und `Ngroups` pro Node festgelegt.
- [x] Utility-/Command-Fahrzeuge bewusst nicht automatisch zu Missions-PLATOONs gemacht.
- [x] Honaker Fixed Fire Support von dynamischer Warehouse-Materialisierung getrennt.
- [x] `SetReturnToLegion(false)` Source-Review für Ground field persistence abgeschlossen.
- [x] sichtbare Teleport-/Respawn-/Returned->Warehouse-Risikopfade identifiziert.
- [ ] DCS-Test: PLATOON Mission-Capability-/Asset-Selektion.
- [ ] DCS-Test: `SetReturnToLegion(false)` Mission-Ende -> physical stay -> Folgeauftrag.
- [ ] DCS-Test: mobile Return-/Handoff-Grenze und Warehouse-Rückgabe.
- [ ] DCS-Test: OPSTRANSPORT Embark/Unload/Disembark vor produktiver Nutzung.
- [ ] Restart/Reconstitution-Vertrag für persistent im Feld verbleibende Gruppen definieren.

### Phase D – CampaignState und Ressourcenvertrag

- [x] stabile Installation-IDs und Parent-Beziehungen definiert.
- [x] PERSONNEL/VEHICLE/SUPPLY/AMMO/FUEL Resource-Class-Verträge definiert.
- [x] OP-PERSONNEL-Reservation und direkter Parent-Nachschub definiert.
- [x] Readiness-/Nachschubverlust-Semantik definiert.
- [ ] exakte CampaignState-Ressourcenmengen pro Node festlegen.
- [ ] numerische Readiness-Schwellen festlegen.
- [ ] Installationsangriff -> physischer Schaden -> CampaignState-Settlement definieren.
- [ ] CampaignState <-> MOOSE WAREHOUSE Anti-Doppelautoritätsvertrag für Runtime explizit schließen.

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
- [ ] Multiplayer-/Spawn-/Despawn-Sichtbarkeit testen.
- [ ] erst nach dokumentiertem DCS-Test `VALIDATED` setzen.

## 7. Nächster Arbeitsblock

Nach Abschluss der bisherigen Punkte 1–3 ist der nächste geplante Designblock:

```text
CampaignState exact quantities
-> readiness thresholds
-> installation damage settlement
-> CampaignState / MOOSE Warehouse anti-double-authority runtime contract
```

Mission-Editor- und DCS-Acceptance-Arbeit bleibt davon getrennt und erfordert reale lokale Builds/Tests.
