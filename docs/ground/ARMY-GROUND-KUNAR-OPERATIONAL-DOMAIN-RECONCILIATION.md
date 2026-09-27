---
document_id: OMW-ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - current Kunar/Jalalabad Ground Foundation installation classification
  - separation of CampaignState strategic ownership from physical dispatch origin
  - six-domain MOOSE operational scope for Fenty, Fortress, Joyce, Wright, Honaker-Miracle and Bostick
not_authoritative_for:
  - exact historical daily garrison strengths
  - exact historical daily vehicle property books
  - final Mission Editor coordinates
  - repository-wide authority before merge to main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier FOB classification of Fortress in this document
  - earlier quantity-open clauses for Fortress and Honaker
  - treatment of Honaker as destination-only/no-local-stock
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 998080da9a7a71dae7f713b9590dfeadb5ae93ba
validated_in_dcs: true
---

# ARMY Ground Foundation – Kunar Operational-Domain Reconciliation

## 1. Zweck

Dieses Dokument beschreibt den reconcilierten Ground-Foundation-Zustand nach Acceptance 9.

Die drei Ebenen bleiben strikt getrennt:

```text
CampaignState strategic installation/resource ownership
!= MOOSE operational materialization domain
!= physical dispatch origin for a concrete mission
```

## 2. Reconciled installation model

Für den aktuellen Kunar-/Jalalabad-Foundation-Scope werden sechs operative Standorte geführt:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Dependent OPs:

```text
COP Honaker-Miracle
`-- OP JoJo

FOB Bostick
+-- OP Mustang
+-- OP Clydesdale
`-- OP Stallion
```

### COP Fortress

```text
canonical display name: COP Fortress
canonical installation class: COP
historical aliases: Combat Outpost Fortress / COP Fortress / FOB Fortress
location: Chawkay/Chowkay District, Kunar
```

The historical source-name variance does not change the current OMW installation class.

### COP Honaker-Miracle

```text
canonical display name: COP Honaker-Miracle
canonical installation class: COP
location: Dara-I-Pech / Pech River Valley, Kunar
```

2011 evidence supports an independent local operational/staging role and local strategic stock.

## 3. Stable installation IDs

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_COP_FORTRESS
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_BOSTICK
```

Any older new-work use of `BLUE_GROUND_FOB_FORTRESS` is superseded by the canonical COP identity above.

## 4. Strategic Ground nodes and support relationships

All six operational domains now have their own CampaignState stock node:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Support-parent contract:

```text
GROUND_NODE_JALALABAD
  supplyParent = OFF_MAP

GROUND_NODE_FORTRESS
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_JOYCE
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_WRIGHT
  supplyParent = GROUND_NODE_JALALABAD

GROUND_NODE_HONAKER
  supplyParent = GROUND_NODE_JOYCE

GROUND_NODE_BOSTICK
  supplyParent = GROUND_NODE_JALALABAD
```

A supply parent is not a second resource authority and does not require every physical mission to dispatch from that node.

```text
resource owner != physical dispatch origin
```

## 5. MOOSE operational domains

Current operational topology:

```text
BLUE COMMANDER
|
+-- BDE_BLUE_GND_JALALABAD
|   `-- WH_BLUE_GND_FENTY
|
+-- BDE_BLUE_GND_FORTRESS
|   `-- WH_BLUE_GND_FORTRESS
|
+-- BDE_BLUE_GND_JOYCE
|   `-- WH_BLUE_GND_JOYCE
|
+-- BDE_BLUE_GND_WRIGHT
|   `-- WH_BLUE_GND_WRIGHT
|
+-- BDE_BLUE_GND_HONAKER
|   `-- WH_BLUE_GND_HONAKER
|
`-- BDE_BLUE_GND_BOSTICK
    `-- WH_BLUE_GND_BOSTICK
```

`BRIGADE` is an operational MOOSE lifecycle domain and does not assert a historical brigade formation. MOOSE `WAREHOUSE` remains operational/mirroring only; CampaignState remains the sole strategic resource authority.

## 6. Six-node stock contract

Order: `PERSONNEL / VEHICLE / SUPPLY / AMMO / FUEL`.

```text
GROUND_NODE_JALALABAD 480 / 48 / 120 / 100 / 120
GROUND_NODE_FORTRESS  160 / 18 / 44  / 48  / 40
GROUND_NODE_JOYCE     180 / 20 / 48  / 44  / 40
GROUND_NODE_WRIGHT    120 / 22 / 36  / 30  / 36
GROUND_NODE_HONAKER   120 / 18 / 40  / 40  / 36
GROUND_NODE_BOSTICK   220 / 26 / 56  / 52  / 48
```

Fortress/Honaker quantities are defined by `OMW-ARMY-GROUND-FORTRESS-HONAKER-2011-RESOURCE-DECISION` and are OMW design quantities, not exact historical daily inventories.

## 7. ACCESS and handoff model

Each operational domain has its own validated/planned handoff identity:

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

The ACCESS zone is not the installation itself. It is the operational materialization/return boundary and must remain road-side, pathfinding-plausible and outside observable spawn/despawn conditions where practical.

## 8. Settlement contract

The validated contract applies to all six Ground nodes:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
confirmed return, including damaged survivor -> immediate one-time availability credit
confirmed loss -> permanent loss
open nonterminal commitment at server stop/crash -> one-time strategic recredit at next startup
no physical DCS/MOOSE continuation or respawn
```

Acceptance 7 is the physical MOOSE Ground lifecycle acceptance. Acceptance 8 validates production-shaped CampaignState integration. Acceptance 9-2 validates Fortress/Honaker stock and the existing settlement adapter on the two new stock nodes.

## 9. Honaker artillery correction

The earlier assumption

```text
2 x M777A2 at Honaker on 30.07.2011
```

is not part of the current Foundation contract.

Current evidence boundary:

```text
2011 Honaker local mortar capability = confirmed
Jan-2010 possible two-gun position = observed; type/continuity unresolved
2012 M777 evidence = outside scenario period
no fixed M777/L118 production requirement
```

## 9.1 Wright fire-support working baseline

Owner decision 27.09.2026: Die beste aktuell vorliegende Evidenz wird fuer die OMW-Arbeitsbaseline verwendet.

```text
Camp Wright / Asadabad as 155-mm artillery firing location in 2010 = CONFIRMED
two-gun 155-mm field-artillery platoon supporting TF No Slack from Asadabad = CONFIRMED by U.S. Army Combat Studies Institute
B Battery / 3-321 Field Artillery, 2nd Platoon, M777 at FOB Wright in 2010 = SUPPORTED by DVIDS
one 155-mm howitzer destroyed at Camp Wright on 15.11.2010 = REPORTED by contemporaneous conflict report
OMW working unit attribution = B Battery / 3-321 Field Artillery, 2nd Platoon
exact July-2011 continuity of the same platoon = NOT independently confirmed
```

Die offene Juli-2011-Kontinuitaet hebt die im OMW-Zeitraum belastbar belegte standortgebundene Wright-Fire-Support-Faehigkeit nicht auf. Fuer die aktuelle OMW-Foundation wird daher `TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2` als site-bound Fire-Support-Repräsentation der Wright-Domaene gefuehrt. `L118_Unit` ist dabei ein DCS-Proxy und keine Behauptung des historischen Wright-Geschuetztyps.

Quellen:

- U.S. Army Combat Studies Institute, *Vanguard of Valor*, Kapitel zu Operation STRONG EAGLE: Team Wolverine/TF No Slack wurde unter anderem durch die aus Camp Wright/Asadabad feuernden 155-mm-Haubitzen unterstuetzt; die Zusammenfassung nennt ein two-gun platoon of 155mm field artillery from nearby Asadabad: <https://www.armyupress.army.mil/Portals/7/combat-studies-institute/csi-books/VanguardOfValor.pdf>
- DVIDS Story 52264, *Top Chi reaches out, touches insurgent forces*, 01.07.2010: B Battery / 3-321 Field Artillery, 2nd Platoon und M777 am FOB Wright; Battery-Platoons auf Wright, Bostick und Blessing verteilt: <https://www.dvidshub.net/news/52264/top-chi-reaches-out-touches-insurgent-forces>
- Global Conflict Maps, 15.11.2010, Bericht zum Angriff auf Camp/FOB Wright mit Zerstoerung einer 155-mm-Haubitze: <https://www.globalconflictmaps.com/2010/11/15/forward-operating-base-wright-in-asadabad-afghanistan-attacked-by-rocket-propelled-grenade/>

## 10. Accepted technical evidence

Acceptance 9-2:

```text
acceptance commit: 45d916217c0085728082c3ef2efcd582d736caae
bundle SHA-256: 35cc922581da980f558733433e487b025e083859b943641276672b6c168b4d6a
MIZ: OMW_Template_v14_ground_test.miz
MIZ SHA-256: 29587060d630d53303d4e858c1fd5a898ea3e09d51dec36ff130d3d0ac6e3ef3
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
result: PASS
```

## 11. Later scope

Not required to close the current GROUNDBASE foundation:

```text
exact July-2011 Joyce company distribution
exact July-2011 Bostick maneuver company/platoon distribution
exact July-2011 continuity of the B/3-321 FA / 2nd Platoon Wright working attribution
Jalalabad exact ground QRF/base-defense formation
Ground-order generation
OPSTRANSPORT
general cross-domain persistence
production patrol/observation geometry beyond the validated Foundation behavior
```
