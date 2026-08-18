---
document_id: OMW-ARMY-GROUND-KUNAR-OPERATIONAL-DOMAIN-RECONCILIATION
status: PLANNED
document_class: DOMAIN_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned Kunar/Jalalabad installation classification for the current ARMY Ground Foundation
  - planned separation of CampaignState parentage from physical dispatch origin
  - planned MOOSE operational-domain scope for Fenty, Fortress, Joyce, Wright, Honaker-Miracle and Bostick
  - immediate integration-test site scope after Ground Acceptance 2
not_authoritative_for:
  - final historical garrison strengths
  - final vehicle property books per installation
  - final Mission Editor coordinates
  - accepted DCS runtime behavior for the multi-domain test
  - repository-wide authority before merge to main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - four-BRIGADE-only planning in OMW-ARMY-GROUND-ROLE-PLATOON-BASELINE for the current Kunar integration-test scope
  - root-node-only ACCESS planning in OMW-ARMY-GROUND-RECONSTITUTION-ACCESS-CONTRACT for the current Kunar integration-test scope
  - treatment of Honaker-Miracle as destination-only/no-local-operational-domain in the current working branch
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# ARMY Ground Foundation – Kunar Operational-Domain Reconciliation

## 1. Zweck

Dieses Dokument reconciliiert die aktuelle Ground-Foundation-Topologie vor dem naechsten DCS-Integrationstest.

Ausgangspunkt sind drei getrennte Ebenen, die nicht mehr als dieselbe Beziehung behandelt werden duerfen:

```text
CampaignState installation / strategic ownership
!= MOOSE operational materialization domain
!= physical dispatch origin for a concrete mission
```

Die Trennung ist erforderlich, weil die Geografie und die belegte Nutzung der Forward Sites nicht mit einer starren linearen Parent-Kette identisch sind.

## 2. Quellen- und Evidenzgrenze

### 2.1 Honaker-Miracle

Die offizielle U.S.-Army-Historie `The Afghan Surge: January 2009-August 2011` beschreibt fuer 2011:

- beim Pech Realignment blieb COP Honaker-Miracle als Ausnahme bestehen, um Asadabad gegen Insurgent pressure abzuschirmen;
- nach der Rueckkehr von TF Cacti / 2-35 Infantry in den Pech-Raum wurde Honaker-Miracle als staging ground fuer Operation Hammer Down genutzt;
- Lt. Col. Colin P. Tuley fuehrte die Operation von COP Honaker-Miracle aus und setzte von dort Reservekraefte ein;
- die Operation erforderte mehrere Resupply-Missionen.

Das belegt einen realen lokalen Operations-/Staging-Charakter. Es belegt **nicht** automatisch einen dauerhaft unabhaengigen strategischen Fahrzeug- oder Ressourcenpool.

### 2.2 Fortress

Die Projektquellen belegen die historische Standortbezeichnung `FOB Fortress` mehrfach. Fruehere ORBAT-Snapshots fuehren einen Ground-owning Infantry Battalion node in Chawkay/Chowkay; War-Diary-/MSR-Evidenz beschreibt Combat Logistics Patrols mit Security Halt, Versorgung und Weiterfahrt ueber Fortress.

Einzelne Quellen verwenden auch `COP Fortress`. Fuer OMW gilt deshalb:

```text
canonical OMW installation class: FOB
canonical display name: FOB Fortress
historical source alias: COP Fortress
```

Die Alias-Varianz wird dokumentiert, aber nicht als Grund genutzt, die OMW-Klasse auf `COP` zu reduzieren.

### 2.3 RC-East / Kunar operating environment

Zeitgenoessische RC-East-Unterlagen betonen Key Terrain, Lines of Communication, dezentrale Forward Presence und die starke Wirkung von Terrain auf Freedom of Movement. Daraus folgt fuer OMW keine einzelne historische Parent-Kette, sondern die Notwendigkeit, strategische Ressourcenverantwortung und konkrete physische Dispatch-Entscheidung getrennt abzubilden.

## 3. Reconciliertes Installationsmodell

Fuer den aktuellen Kunar-/Jalalabad-Foundation-Scope werden sechs operative Installationsstandorte gefuehrt:

```text
Jalalabad / FOB Fenty
FOB Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

Abhaengige OPs bleiben davon getrennt:

```text
COP Honaker-Miracle
`-- OP JoJo

FOB Bostick
+-- OP Mustang
+-- OP Clydesdale
`-- OP Stallion
```

Die sechs Standorte sind **keine Behauptung sechs historischer Brigaden** und **keine sechs unabhaengigen CampaignState-Ressourcenautoritaeten**.

## 4. Stabile Installation-IDs

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
BLUE_GROUND_FOB_FORTRESS
BLUE_GROUND_FOB_JOYCE
BLUE_GROUND_FOB_WRIGHT
BLUE_GROUND_COP_HONAKER_MIRACLE
BLUE_GROUND_FOB_BOSTICK
```

Die bisher nicht kanonische Form `BLUE_GROUND_COP_FORTRESS` wird fuer neue Arbeit nicht verwendet.

## 5. Strategische Parent- und Support-Semantik

### 5.1 `parentInstallationId`

`parentInstallationId` beschreibt die strategische/organisatorische CampaignState-Beziehung einer abhaengigen Installation. Es ist **kein** Zwang, dass jeder physische Convoy von diesem Parent abfahren muss.

Aktueller Arbeitsstand:

```text
BLUE_GROUND_HUB_JALALABAD_FENTY
  parentInstallationId = null

BLUE_GROUND_FOB_FORTRESS
  parentInstallationId = null
  regionalSupportParent = BLUE_GROUND_HUB_JALALABAD_FENTY

BLUE_GROUND_FOB_JOYCE
  parentInstallationId = null
  regionalSupportParent = BLUE_GROUND_HUB_JALALABAD_FENTY

BLUE_GROUND_FOB_WRIGHT
  parentInstallationId = null
  regionalSupportParent = BLUE_GROUND_HUB_JALALABAD_FENTY

BLUE_GROUND_COP_HONAKER_MIRACLE
  parentInstallationId = BLUE_GROUND_FOB_JOYCE

BLUE_GROUND_FOB_BOSTICK
  parentInstallationId = null
  regionalSupportParent = BLUE_GROUND_HUB_JALALABAD_FENTY
```

Die Joyce-Parentage von Honaker bleibt vorerst als OMW CampaignState-Arbeitsvertrag erhalten. Die historischen Quellen werden **nicht** so interpretiert, als habe diese Beziehung ueber den gesamten Kampagnenzeitraum unveraendert bestanden.

### 5.2 Physical dispatch origin

Eine konkrete physische Mission darf aus einem anderen geeigneten operativen Standort starten, sofern CampaignState die strategische Reservation vorher korrekt bindet.

```text
strategic owner / obligation
-> reserve resource in CampaignState
-> select validated physical dispatch origin
-> execute MOOSE mission
-> settle arrival/loss/abort exactly once
```

Damit gilt ausdruecklich:

```text
resource owner != physical dispatch origin
```

Fuer Honaker sind als moegliche physische Support-Urspruenge mindestens zu pruefen:

```text
local Honaker operational stock/staging
FOB Wright
FOB Joyce
```

Wright wird wegen der Geografie und der vorhandenen MSR-/QRF-Funktion als naheliegender Forward-Support-Kandidat behandelt. Das macht Wright **nicht** zum strategischen Parent von Honaker.

## 6. MOOSE operational domains

Fuer den naechsten Integrationstest wird folgende operative MOOSE-Topologie geplant:

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

Bedeutung:

- `BRIGADE` ist hier eine MOOSE operative Materialisierungs-/Lifecycle-Domaene;
- der Name behauptet keine historische Brigadeformation;
- `WAREHOUSE` ist ein physischer MOOSE host/mirror und keine strategische Ressourcenautoritaet;
- CampaignState bleibt alleinige Autoritaet fuer strategische Personnel-/Vehicle-/Supply-/Ammo-/Fuel-Vertraege.

### 6.1 Honaker-Grenze

Die eigene Honaker-MOOSE-Domaene ist durch die 2011 belegte Staging-/Reservefunktion technisch und missionsfachlich gerechtfertigt. Sie **beweist keinen neuen additiven Fahrzeugbestand**.

Bis eine separate Property-Book-/Vehicle-Baseline beschlossen ist, duerfen Acceptance-/Integrationstest-Assets fuer Honaker nur als **test-only operational allocation** gefuehrt werden. Sie duerfen die bestehende Joyce- oder Wright-Fahrzeugbaseline nicht stillschweigend erhoehen.

### 6.2 Fortress-Grenze

Dasselbe gilt fuer Fortress: der Standort rechtfertigt eine eigene operative Materialisierungsdomaene. Eine konkrete permanente 2011-Fahrzeugstaerke ist damit nicht bewiesen.

Der erste Multi-Domain-Test darf deshalb ein einzelnes wiederverwendbares Test-Patrol-Asset pro Standort verwenden, ohne daraus eine Produktionsmenge abzuleiten.

## 7. ACCESS- und Zielmarker

Fuer den naechsten Integrationstest werden fuer alle sechs operativen Domains eigene physische Handoff-/ACCESS-Marker benoetigt:

```text
ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS
```

Die ACCESS-Zone ist nicht die Installation selbst. Sie bleibt ausserhalb der aktiven FOB-/COP-Geometrie und soll road-side, pathfinding-plausibel und soweit praktisch nicht beobachtbar liegen.

Fuer den aktuellen Test werden ebenfalls je Domain eigene Ziel-/Observation-Marker verwendet:

```text
ZON_BLUE_GND_FENTY_PATROL_TEST_01
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ZON_BLUE_GND_WRIGHT_PATROL_TEST_01
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
ZON_BLUE_GND_BOSTICK_PATROL_TEST_01
```

Diese Testmarker sind keine Produktions-Patrol-Zones und legen keine spaetere Missionsgeometrie fest.

## 8. Vehicle-/PLATOON-Grenze vor dem Integrationstest

Die existierenden produktionsnahen Vehicle Baselines fuer Fenty, Joyce, Wright und Bostick werden durch diese Reconciliation **nicht erhoeht oder neu verteilt**.

Fuer Fortress und Honaker gilt bis zur separaten Mengenentscheidung:

```text
production vehicle quantity: NOT YET DECIDED
production personnel quantity: NOT YET DECIDED
integration-test patrol asset: allowed as test-only allocation
strategic auto-credit: forbidden
```

Das gemeinsame Testtemplate bleibt:

```text
TPL_BLUE_GND_PATROL_MATV_4
4 x CHAP_MATV
```

Die Verwendung desselben Template-Typs an sechs Standorten bedeutet nicht, dass sechs zusaetzliche Vierergruppen als permanenter CampaignState-Bestand erzeugt werden.

## 9. Bewegungsverhalten fuer den naechsten Test

Ground Acceptance 2 hat den MOOSE-first-Verhaltenspfad fuer eine einzelne Joyce-Gruppe technisch bestaetigt. Fuer den Multi-Domain-Test wird dasselbe Verhalten ohne neue Parallelimplementierung skaliert:

```text
normal road transit
-> ARMOREDGUARD / On Road
-> target ~50 km/h
-> MOOSE mission speed 27 kt

final tactical leg
-> ARMOREDGUARD / Vee
-> 8 kt initial test value

observation position
-> FullStop / stable hold
-> same physical ARMYGROUP
-> SetReturnToLegion(false)
```

`27 kt` ist die technische Annaeherung an die bereits im OMW-TM01M-Konvoi verwendeten `50 km/h` und muss im Multi-Domain-DCS-Lauf visuell/pathfinding-seitig erneut bewertet werden.

## 10. Naechster DCS-Integrationstest

Der naechste Test ist **kein weiterer Single-Site-Tippelschritt**.

Er startet die sechs operativen Domains gemeinsam:

```text
FENTY
FORTRESS
JOYCE
WRIGHT
HONAKER
BOSTICK
```

Zu pruefen sind mindestens:

```text
- six BRIGADE instances resolve and start
- six physical warehouse hosts resolve
- six independent ACCESS materializations
- exactly one test patrol group per domain
- no alias/callback/state collision between domains
- normal road transit at the higher transit speed
- no prolonged spawn-area circling
- final tactical Vee transition
- ARMOREDGUARD stable hold
- same-group lifecycle continuity
- no duplicate materialization
- no visible teleport/despawn
- DCS pathfinding quality at all six sites
```

Der Test ist ein **Integrationstest der operativen Domaenen**, keine Abnahme der finalen Fortress-/Honaker-Property-Books.

## 11. Mission-Editor-Gate

Vor dem Build des Multi-Domain-Testbundles muss die Mission read-only gegen folgende Objektliste geprueft werden:

```text
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK

ZON_BLUE_GND_FENTY_ACCESS
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
ZON_BLUE_GND_HONAKER_ACCESS
ZON_BLUE_GND_BOSTICK_ACCESS

ZON_BLUE_GND_FENTY_PATROL_TEST_01
ZON_BLUE_GND_FORTRESS_PATROL_TEST_01
ZON_BLUE_GND_JOYCE_PATROL_TEST_01
ZON_BLUE_GND_WRIGHT_PATROL_TEST_01
ZON_BLUE_GND_HONAKER_PATROL_TEST_01
ZON_BLUE_GND_BOSTICK_PATROL_TEST_01

TPL_BLUE_GND_PATROL_MATV_4
```

ChatGPT mutiert die `.miz` nicht. Fehlende oder unpassend platzierte Mission-Editor-Objekte werden dem Projektinhaber als konkrete ME-Arbeit gemeldet.

## 12. Offene Punkte nach dem Integrationstest

Erst nach dem sechsfachen Runtime-Test werden folgende Entscheidungen weitergefuehrt:

```text
- permanent Fortress vehicle/property-book quantity
- permanent Honaker mobile vehicle/property-book quantity
- exact CampaignState reservation split for local staging versus reinforcement
- final support-origin selection rules
- production route/observation geometry
- return/handoff acceptance
- cross-session reconstitution
```

Keine dieser Mengen oder Regeln wird aus dem Integrationstest selbst abgeleitet.