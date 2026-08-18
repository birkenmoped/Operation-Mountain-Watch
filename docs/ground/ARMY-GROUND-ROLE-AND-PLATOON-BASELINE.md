---
document_id: OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned assignment of the current Ground Foundation vehicle baseline to operational roles per Ground Node
  - planned four-BRIGADE MOOSE topology for Jalalabad, Joyce, Wright and Bostick
  - planned PLATOON role pools and reusable template multiplicities for the current Ground Foundation
not_authoritative_for:
  - final Mission Editor placement
  - accepted DCS runtime behavior
  - final CampaignState personnel, ammo, fuel or supply quantities
  - accepted MOOSE Ground runtime architecture
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Rollen- und PLATOON-Baseline

## 1. Zweck

Dieses Dokument schließt die Ground-Foundation-Arbeitsschritte

```text
1. offene Fahrzeug-/Proxyentscheidungen für den aktuellen Foundation-Scope,
2. Zuordnung der Working Vehicle Baseline zu operativen Rollen,
3. konkrete geplante MOOSE-BRIGADE-/PLATOON-Struktur pro Ground Node.
```

Die Architekturgrenze bleibt unverändert:

```text
CampaignState
= strategische Ressourcenautorität

MOOSE BRIGADE / PLATOON / ARMYGROUP / WAREHOUSE
= operative Auswahl, Materialisierung und Lifecycle

DCS GROUP / UNIT
= temporäre physische Repräsentation
```

Die hier festgelegten MOOSE-Objekte sind `PLANNED`. Source-Review des gepinnten MOOSE-Stands ist erfolgt; DCS-Runtime-Acceptance steht noch aus.

## 2. MOOSE-Source-Basis

Geprüfter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für die geplante Struktur sind im tatsächlich verwendeten Source insbesondere vorhanden:

```lua
COMMANDER:AddBrigade(...)
BRIGADE:New(WarehouseName, BrigadeName)
BRIGADE:AddPlatoon(...)
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
COHORT:AddMissionCapability(...)
COHORT:SetMissionRange(...)
COHORT:CanMission(...)
AUFTRAG:SetReturnToLegion(false)
AUFTRAG:NewARTY(...)
```

Der Source enthält außerdem `AUFTRAG.Type.PATROLZONE`, `AUFTRAG.Type.ONGUARD`, `AUFTRAG.Type.GROUNDATTACK`, `AUFTRAG.Type.ARTY` und `AUFTRAG.Type.OPSTRANSPORT`. Welche dieser Missionstypen je Rolle produktiv freigegeben werden, bleibt an den späteren DCS-Test gebunden; die Rollenbezeichnung in diesem Dokument ist keine Behauptung, dass bereits jede Mission in DCS akzeptiert ist.

## 3. Topologieentscheidung: vier operative BRIGADEs

Für den aktuellen Foundation-Scope werden die vier Root Ground Nodes als vier getrennte operative MOOSE-`BRIGADE`-Domänen geplant:

```text
BLUE COMMANDER
|
+-- BDE_BLUE_GND_JALALABAD
|   `-- GROUND_NODE_JALALABAD
|
+-- BDE_BLUE_GND_JOYCE
|   `-- GROUND_NODE_JOYCE
|
+-- BDE_BLUE_GND_WRIGHT
|   `-- GROUND_NODE_WRIGHT
|
`-- BDE_BLUE_GND_BOSTICK
    `-- GROUND_NODE_BOSTICK
```

Begründung:

- jeder Root Ground Node besitzt einen eigenen lokalen Fahrzeug-/Ressourcenvertrag;
- lokale Missionen sollen vorrangig aus dem zugehörigen Node bedient werden;
- die Parent-/Support-Hierarchie bleibt CampaignState-Domäne und wird nicht durch eine einzige übergroße MOOSE-BRIGADE ersetzt;
- abhängige COPs/OPs erhalten keine eigene BRIGADE;
- ein MOOSE-`BDE_`-Name behauptet keine historische Brigadeformation.

Geplante Warehouse-Mirror-Namen:

```text
WH_BLUE_GND_JALALABAD
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_BOSTICK
```

Diese WAREHOUSE-Instanzen dürfen keine strategische Ressourcenhoheit erhalten.

## 4. Reusable Template Baseline

Die folgenden wiederverwendbaren Templategruppen werden als Foundation-Satz geplant:

```text
TPL_BLUE_GND_PATROL_MATV_4
  4 x CHAP_MATV

TPL_BLUE_GND_PATROL_MRAP_4
  4 x MaxxPro_MRAP

TPL_BLUE_GND_QRF_MIXED_4
  2 x CHAP_MATV
  2 x MaxxPro_MRAP

TPL_BLUE_GND_SECURITY_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
  2 x MaxxPro_MRAP

TPL_BLUE_GND_LOG_M1083_2
  2 x CHAP_M1083

TPL_BLUE_GND_FUEL_M978_2
  2 x M978 HEMTT Tanker

TPL_BLUE_GND_UTILITY_HMMWV_2
  2 x Hummer

TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3
  3 x MaxxPro_MRAP

TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2
  2 x L118_Unit
```

`TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2` ist ausschließlich die technische Foundation-Abbildung der historisch belegten zwei M777A2 auf Honaker-Miracle. Die historische Bezeichnung bleibt `2 x M777A2`; `L118_Unit` wird nicht als historisch gleichwertiges System dargestellt.

## 5. Jalalabad / FOB Fenty

Working Vehicle Baseline:

```text
48 wheeled vehicles
```

Rollenverteilung:

```text
PATROL / MOBILE SECURITY
  2 x TPL_BLUE_GND_PATROL_MATV_4     = 8 MATV
  1 x TPL_BLUE_GND_PATROL_MRAP_4     = 4 MRAP

QRF
  4 x TPL_BLUE_GND_QRF_MIXED_4       = 8 MATV + 8 MRAP

LOCAL SECURITY RESERVE
  1 x TPL_BLUE_GND_SECURITY_MRAP_2    = 2 MRAP

LOGISTICS
  6 x TPL_BLUE_GND_LOG_M1083_2        = 12 M1083

FUEL SUPPORT
  1 x TPL_BLUE_GND_FUEL_M978_2        = 2 M978 HEMTT Tanker

UTILITY / COMMAND / LOCAL SUPPORT
  2 x TPL_BLUE_GND_UTILITY_HMMWV_2    = 4 HMMWV
```

Kontrollsumme:

```text
16 MATV
14 MRAP
12 M1083
2 M978 HEMTT Tanker
4 HMMWV
= 48 wheeled vehicles
```

Geplante PLATOONs:

```text
PLT_BLUE_GND_JALALABAD_PATROL_MATV
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 2

PLT_BLUE_GND_JALALABAD_PATROL_MRAP
  template: TPL_BLUE_GND_PATROL_MRAP_4
  Ngroups: 1

PLT_BLUE_GND_JALALABAD_QRF
  template: TPL_BLUE_GND_QRF_MIXED_4
  Ngroups: 4

PLT_BLUE_GND_JALALABAD_SECURITY
  template: TPL_BLUE_GND_SECURITY_MRAP_2
  Ngroups: 1

PLT_BLUE_GND_JALALABAD_LOGISTICS
  template: TPL_BLUE_GND_LOG_M1083_2
  Ngroups: 6

PLT_BLUE_GND_JALALABAD_FUEL_SUPPORT
  template: TPL_BLUE_GND_FUEL_M978_2
  Ngroups: 1
```

Die vier HMMWV bleiben zunächst lokaler Utility-/Command-Bestand und werden nicht als eigener Missions-PLATOON freigeschaltet.

`FIRE_SUPPORT` bleibt am Jalalabad-Node als CampaignState-Capability aktiv, erhält in dieser Fahrzeugbaseline aber noch keinen eigenen physischen PLATOON-Bestand. Die TF-Steel-Zuordnung allein rechtfertigt keine erfundene Geschützstückzahl.

## 6. FOB Joyce / Honaker-Miracle

Working Vehicle Baseline Joyce:

```text
20 wheeled vehicles
```

Rollenverteilung:

```text
PATROL
  1 x TPL_BLUE_GND_PATROL_MATV_4      = 4 MATV

QRF
  2 x TPL_BLUE_GND_QRF_MIXED_4        = 4 MATV + 4 MRAP

LOCAL SECURITY
  1 x TPL_BLUE_GND_SECURITY_MRAP_2     = 2 MRAP

LOGISTICS
  2 x TPL_BLUE_GND_LOG_M1083_2         = 4 M1083

UTILITY / COMMAND
  1 x TPL_BLUE_GND_UTILITY_HMMWV_2     = 2 HMMWV
```

Kontrollsumme:

```text
8 MATV
6 MRAP
4 M1083
2 HMMWV
= 20 wheeled vehicles
```

Geplante PLATOONs:

```text
PLT_BLUE_GND_JOYCE_PATROL
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 1

PLT_BLUE_GND_JOYCE_QRF
  template: TPL_BLUE_GND_QRF_MIXED_4
  Ngroups: 2

PLT_BLUE_GND_JOYCE_SECURITY
  template: TPL_BLUE_GND_SECURITY_MRAP_2
  Ngroups: 1

PLT_BLUE_GND_JOYCE_LOGISTICS
  template: TPL_BLUE_GND_LOG_M1083_2
  Ngroups: 2
```

Die zwei HMMWV bleiben zunächst lokaler Utility-/Command-Bestand.

Honaker-Miracle erhält keine eigene BRIGADE. Die historisch belegten zwei M777A2 werden physisch am COP gehalten. Für die technische Foundation wird folgendes Fixed-Fire-Support-Template geplant:

```text
TPL_BLUE_GND_FIRE_SUPPORT_L118_PROXY_2
-> 2 x L118_Unit
-> represents 2 x M777A2 for OMW technical purposes only
```

Eine dynamische `PLATOON`-Warehouse-Materialisierung dieser Geschütze ist ausdrücklich **nicht** vorgesehen. Die Geschütze sollen bei Missionsstart physisch vorhanden sein. Die spätere MOOSE-Anbindung für `AUFTRAG:NewARTY(...)` muss diesen Fixed-Asset-Vertrag respektieren und wird separat in DCS getestet.

## 7. FOB Wright

Working Vehicle Baseline:

```text
22 wheeled vehicles
```

Die bisher offene `engineer / route-support`-Zuordnung wird für die Foundation bewusst **ohne erfundenen Buffalo-/Husky-Proxy** geschlossen. Die zwei spezialisierten Slots werden als geschützte Engineer-/Route-Support-Escortfahrzeuge mit vorhandener MRAP-Familie abgebildet.

Rollenverteilung:

```text
PATROL / SECFOR
  1 x TPL_BLUE_GND_PATROL_MATV_4            = 4 MATV

QRF
  2 x TPL_BLUE_GND_QRF_MIXED_4              = 4 MATV + 4 MRAP

ENGINEER / ROUTE SUPPORT SECURITY
  2 x TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2  = 4 MRAP

LOGISTICS
  2 x TPL_BLUE_GND_LOG_M1083_2              = 4 M1083

UTILITY / COMMAND
  1 x TPL_BLUE_GND_UTILITY_HMMWV_2          = 2 HMMWV
```

Kontrollsumme:

```text
8 MATV
8 MRAP
4 M1083
2 HMMWV
= 22 wheeled vehicles
```

Geplante PLATOONs:

```text
PLT_BLUE_GND_WRIGHT_PATROL
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 1

PLT_BLUE_GND_WRIGHT_QRF
  template: TPL_BLUE_GND_QRF_MIXED_4
  Ngroups: 2

PLT_BLUE_GND_WRIGHT_ENGINEER_SUPPORT
  template: TPL_BLUE_GND_ENGINEER_SUPPORT_MRAP_2
  Ngroups: 2

PLT_BLUE_GND_WRIGHT_LOGISTICS
  template: TPL_BLUE_GND_LOG_M1083_2
  Ngroups: 2
```

Die zwei HMMWV bleiben zunächst lokaler Utility-/Command-Bestand.

Wright erhält in dieser Juli-2011-Baseline **keinen aktiven FIRE_SUPPORT-PLATOON**, solange die exakte Juli-Artilleriezuordnung offen bleibt.

## 8. FOB Bostick

Working Vehicle Baseline:

```text
26 wheeled vehicles
```

Die bisher offene `recovery/support`-Position wird für die Foundation ohne erfundenes Wrecker-DCS-Modell geschlossen. Die Recovery-Funktion bleibt strategisch und missionsfachlich erhalten; physisch wird der Supportslot mit der bestätigten M1083-Familie repräsentiert. DCS-Towing wird nicht behauptet.

Rollenverteilung:

```text
PATROL
  2 x TPL_BLUE_GND_PATROL_MATV_4             = 8 MATV

QRF
  1 x TPL_BLUE_GND_QRF_MIXED_4               = 2 MATV + 2 MRAP

OP REINFORCEMENT / MOBILE SECURITY
  2 x TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3   = 6 MRAP

LOGISTICS / RECOVERY SUPPORT
  3 x TPL_BLUE_GND_LOG_M1083_2               = 6 M1083

UTILITY / COMMAND
  1 x TPL_BLUE_GND_UTILITY_HMMWV_2           = 2 HMMWV
```

Kontrollsumme:

```text
10 MATV
8 MRAP
6 M1083
2 HMMWV
= 26 wheeled vehicles
```

Geplante PLATOONs:

```text
PLT_BLUE_GND_BOSTICK_PATROL
  template: TPL_BLUE_GND_PATROL_MATV_4
  Ngroups: 2

PLT_BLUE_GND_BOSTICK_QRF
  template: TPL_BLUE_GND_QRF_MIXED_4
  Ngroups: 1

PLT_BLUE_GND_BOSTICK_OP_REINFORCEMENT
  template: TPL_BLUE_GND_OP_REINFORCEMENT_MRAP_3
  Ngroups: 2

PLT_BLUE_GND_BOSTICK_LOGISTICS
  template: TPL_BLUE_GND_LOG_M1083_2
  Ngroups: 3
```

Die zwei HMMWV bleiben zunächst lokaler Utility-/Command-Bestand.

Bostick erhält in dieser Juli-2011-Baseline **keinen aktiven FIRE_SUPPORT-PLATOON**, solange die Juli-Artilleriezuordnung offen bleibt.

## 9. PLATOON-Missionsrollen

Die geplanten Mission-Capability-Grenzen sind rollenbasiert und werden im Runtime-Code nur mit source-verifizierten `AUFTRAG.Type`-Werten umgesetzt.

Arbeitszuordnung:

```text
PATROL
-> primary candidate: AUFTRAG.Type.PATROLZONE

QRF
-> primary candidate: AUFTRAG.Type.ONGUARD / GROUNDATTACK depending MissionDemand

SECURITY
-> primary candidate: AUFTRAG.Type.ONGUARD

ENGINEER_SUPPORT
-> no autonomous mine-clearing simulation
-> movement/security mission only

LOGISTICS
-> transport/support role
-> OPSTRANSPORT only after DCS transport acceptance

FUEL_SUPPORT
-> logistics/support role
-> no autonomous strategic fuel authority

FIRE_SUPPORT
-> AUFTRAG.Type.ARTY
-> fixed physical gun contract first
```

`MissionDemand` bleibt die fachliche Auswahl- und Priorisierungsinstanz. `COHORT:AddMissionCapability(...)` begrenzt die MOOSE-Auswahl; es ersetzt keine CampaignState-Verfügbarkeitsprüfung.

## 10. Mission-Range Baseline

Der Source setzt für Ground-COHORTs standardmäßig 75 NM. OMW übernimmt diesen Wert **nicht** pauschal als operative Reichweite.

Für die Foundation gilt:

```text
PLATOON mission range
-> later node-specific bounded value
-> based on validated road routes and support hierarchy
-> never used to skip direct parent/support rules
```

Bis zur Routen-/DCS-Abnahme wird kein eigener numerischer Range-Wert als `VALIDATED` geführt.

## 11. Strategische Buchungsgrenze

Die oben aufgeführten `Ngroups` beschreiben die geplante MOOSE-Assetstruktur. Sie dürfen CampaignState nicht verdoppeln.

```text
CampaignState VEHICLE reservation
-> select eligible PLATOON asset
-> materialize / task through MOOSE
-> observe result
-> settle CampaignState exactly once
```

Ein MOOSE-WAREHOUSE-Asset ist keine zusätzliche strategische Fahrzeugmenge.

## 12. Noch offene Testgates

Nach Abschluss dieser Designschritte sind insbesondere noch offen:

```text
- Mission Editor placement of reusable templates
- exact ACCESS-zone coordinates and road anchors
- M978 HEMTT Tanker presence/behavior in the actual mission environment
- L118_Unit proxy range/behavior versus the M777A2 design requirement
- PLATOON selection behavior with the planned mission capabilities
- road pathfinding for each mobile template
- SetReturnToLegion(false) Ground mission persistence
- physical return/handoff and Warehouse settlement
- OP reinforcement movement and arrival/loss settlement
- CampaignState <-> MOOSE Warehouse anti-double-authority runtime contract
```

Keiner dieser Punkte ist durch dieses Dokument `VALIDATED`.
