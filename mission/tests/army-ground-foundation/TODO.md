---
document_id: OMW-TEST-ARMY-GROUND-FOUNDATION-TODO
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - working scope and open tasks for the Jalalabad and Kunar ARMY ground foundation
not_authoritative_for:
  - final ground-force ORBAT strengths
  - final MOOSE BRIGADE topology
  - final Mission Editor object state
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: 35d9f7402fbd22372a68f377016453213693871a
validated_in_dcs: false
---

# ARMY Ground Foundation – Arbeitsstand und To-do

## 1. Ziel

Für den engeren Jalalabad-/Kunar-Einsatzraum wird eine belastbare BLUE-Ground-Foundation aufgebaut, die historische Installationen, eine einheitliche Juli-2011-Einheitenbaseline, CampaignState-Ressourcenhoheit und eine MOOSE-first Runtime-Struktur zusammenführt.

Die Ground-Foundation soll insbesondere folgende spätere Kampagnenfunktionen tragen:

- Schutz und Angriff auf FOBs, COPs und OPs;
- lokale Patrouillen und QRF;
- Sicherung und Interdiction von Nachschubwegen;
- materielle Versorgung und Verstärkung abhängiger Außenstellungen;
- Artillerie-/Fire-Support-Verfügbarkeit;
- physische Verluste mit Rückwirkung auf CampaignState;
- RED-Druck auf Route Control, Hold Strength und Reinfiltration Access.

## 2. Verbindliche Arbeitsgrenzen

### 2.1 Historischer Zeitraum

Der verbindliche Recherche- und Kampagnenzeitraum bleibt:

```text
01.08.2010–31.12.2011
```

Installationsstatus, Schließungen, Übergaben und Standortrelevanz werden über den gesamten Zeitraum bewertet.

### 2.2 Aktive Ground-ORBAT-Baseline

Für aktive BLUE-Ground-Einheiten wird als einheitlicher Referenzstand festgelegt:

```text
JULY 2011
```

Frühere und spätere Rotationen innerhalb des OMW-Zeitraums bleiben historischer Kontext, werden aber nicht gleichzeitig als aktive Missionseinheiten materialisiert.

### 2.3 Aktuelles Spielfeld

Salerno/Khost und angrenzende Ground-Installationen gehören nicht zum aktuellen ARMY-Spielfeld. Die Reaktions- und Versorgungswege wären für den Jalalabad-/Kunar-Raum zu lang.

Aktueller Operationsraum:

```text
Jalalabad / FOB Fenty
        +
Nangarhar / Kunar
        +
Asadabad / central Kunar
        +
northern Kunar / Bostick sector
```

Eine vollständigere historische Installationsliste kann später ergänzt werden. Zusätzliche Standorte werden nur aufgenommen, wenn sie historisch relevant und für das operative Netz tatsächlich notwendig beziehungsweise sinnvoll darstellbar sind.

## 3. Aktuelle vier Ground Nodes

Die folgende Gliederung ist das derzeitige Arbeitsmodell. `BRIGADE_*` bezeichnet noch keine endgültig genehmigte MOOSE-Topologie, sondern einen zu prüfenden operativen Ground Node.

```text
BLUE COMMANDER
|
+-- BRIGADE_JALALABAD          [TO_VERIFY]
|   +-- Jalalabad / FOB Fenty
|   +-- local Nangarhar assets
|
+-- BRIGADE_JOYCE              [TO_VERIFY]
|   +-- FOB Joyce
|   +-- COP Honaker-Miracle
|   +-- OP JoJo
|
+-- BRIGADE_WRIGHT             [STRONG_CANDIDATE]
|   +-- FOB Wright
|   +-- local Asadabad assets
|
+-- BRIGADE_BOSTICK            [STRONG_CANDIDATE]
    +-- FOB Bostick
    +-- OP Mustang
    +-- OP Clydesdale
    +-- OP Stallion
```

### 3.1 Jalalabad / FOB Fenty

Jalalabad/Fenty ist der regionale übergeordnete Hub. Für Juli 2011 ist `TF Bronco / 3rd BCT, 25th Infantry Division` der maßgebliche Higher-HQ-Kontext. `TF Steel / 3-7 Field Artillery` ist im Juli-2011-ORBAT für Jalalabad belegt.

Der Node benötigt in der späteren Ground-Foundation mindestens die Rollen lokale Sicherung, QRF/Reserve, Logistik und regionalen Fire-Support-Bezug. Die konkrete PLATOON-/Template-Struktur ist noch offen.

### 3.2 Joyce-Komplex

Juli-2011-Baseline:

```text
TF Cacti
2nd Battalion, 35th Infantry Regiment
FOB Joyce
southern Kunar
```

Aktueller Installationsverbund:

```text
FOB Joyce
└── COP Honaker-Miracle
    └── OP JoJo
```

FOB Joyce ist als aktiver regionaler Ground- und Logistikknoten vorgesehen. Für 2011 sind CH-47-/Sling-Load-Resupply und Fuel-Handling gestützt. Honaker-Miracle ist als aktiver COP belegt; für 2011 ist dort ein eigener Fuel Point dokumentiert. Für den 30.07.2011 sind zwei M777A2 von Battery C / 3-321 Field Artillery am COP Honaker-Miracle belegt.

OP JoJo bleibt historisch hinsichtlich der konkreten 2010/11-Besetzung offen. Als Installation ist seine Lage oberhalb von Honaker-Miracle gestützt. Eine aktive OMW-Besetzung darf erst nach Owner-Entscheidung beziehungsweise ausreichender Evidenz festgeschrieben werden.

### 3.3 Wright / Asadabad

FOB Wright wird ausdrücklich in die Ground-Foundation aufgenommen. Camp Fiaz wird nicht physisch in OMW aufgenommen.

Wright ist 2011 als aktiver, dauerhaft ausgebauter Support-/Security-/Fire-Support-Knoten belegt. Für Juli 2011 ist kein äquivalentes Maneuver-Battalion-HQ wie bei Bostick oder Joyce aus dem Juli-2011-ORBAT abgeleitet. Stattdessen wird Wright aus ergänzenden Juli-2011-nahen Quellen aufgebaut.

Belastbarer Arbeitsstand:

```text
1-14th Illinois Agribusiness Development Team
└── Security Force Platoon
```

Das SECFOR-Platoon ist im Juli 2011 auf FOB Wright für mehrere Sicherungsrollen und externe Missionssicherung belegt.

Zusätzliche bestätigte beziehungsweise stark gestützte Wright-Capabilities im OMW-Zeitraum:

- Kunar PRT / provincial support;
- 102nd Forward Surgical Team;
- FARP / aviation support;
- Fuel storage und Tanker-Logistik;
- größere MRAP-/Fahrzeugpräsenz;
- M777-/3-321-Field-Artillery-Präsenz für 2010;
- direkte Angriffe auf den Standort und verwundbare Fuel-/Vehicle-Infrastruktur;
- Incinerators und dauerhafte Support-Infrastruktur.

Offen bleibt die exakte M777-Battery-/Platoon-Zuordnung auf Wright im Juli 2011. Historische M777-Fähigkeit darf deshalb nicht stillschweigend als exakt identische Juli-2011-Stationierung interpretiert werden.

### 3.4 Bostick-Komplex

Juli-2011-Baseline:

```text
TF Wolfhound
2nd Battalion, 27th Infantry Regiment
FOB Bostick / Naray
northern Kunar
```

Aktueller OMW-Installationsverbund:

```text
FOB Bostick
├── OP Mustang
├── OP Clydesdale
└── OP Stallion
```

FOB Bostick wird manuell durch den Projektinhaber aufgebaut.

`OP Mustang` ist als realer Standort und als aktiv besetzte Stellung im Februar 2011 durch C Troop / 1-32 Cavalry / TF Bandit bestätigt. `OP Clydesdale` ist durch DoD-POEMS als realer Standort bestätigt. `OP Stallion` ist durch OEF Base Tracker beziehungsweise ergänzende historische Hinweise gestützt.

Für OMW werden Mustang, Clydesdale und Stallion als funktionale Overwatch-Kette des Bostick-Komplexes geplant:

```text
OP Mustang       -> northern overwatch
OP Clydesdale    -> central overwatch
OP Stallion      -> southern overwatch
```

Die OMW-Aktivierung von Clydesdale und Stallion ist eine bewusste Missionsdesignentscheidung aufgrund ihrer taktisch sinnvollen Höhenlage und Schutzfunktion für Bostick; sie ist nicht als behaupteter Nachweis einer exakt gleichartigen Juli-2011-Besetzung zu formulieren.

## 4. Installationen und Formation strikt trennen

Folgende Ebenen dürfen nicht vermischt werden:

```text
Installation
= FOB / COP / OP / Site

Historical formation
= TF / Battalion / Company / Troop usw.

MOOSE operational pool
= BRIGADE / PLATOON / ARMYGROUP

Physical DCS representation
= DCS GROUP / UNIT / STATIC
```

Beispiel:

```text
FOB_BOSTICK
!= TF_WOLFHOUND_2_27
!= BRIGADE_BOSTICK
!= a physical ARMYGROUP
```

CampaignState bleibt alleinige strategische Autorität für Personal, Fahrzeuge, Bestände, Verluste und Installationszustände.

## 5. OP-Parent-Regel

Ein OP ist in OMW keine autonome Ressourcenorganisation.

```text
OP active only if:
- assigned parent FOB/COP is active
  OR
- an explicit replacement parent is documented
```

Ohne aktiven Parent besitzt ein OP insbesondere nicht:

```text
independent personnel pool
independent warehouse
QRF origin
patrol origin
```

Die Besatzung eines OP stammt aus der Parent-Formation beziehungsweise dem Parent-Ground-Node. Besetzung, Verstärkung, Ablösung und Versorgung müssen daher auf die Ressourcen des Parents zurückwirken.

Diese Regel schließt für den Korengal-Komplex eine aktive OMW-Besetzung aus, weil der Parent-Komplex bereits vor Beginn des OMW-Zeitraums aufgegeben wurde. Eine offene historische Namensfrage wie bei `OP 2` ändert daran nichts.

## 6. MOOSE-first Arbeitsmodell

Der gepinnte OMW-MOOSE-Stand enthält die vorgesehenen Ground-OPS-Klassen `COMMANDER`, `BRIGADE`, `PLATOON`, `ARMYGROUP` und `OPSTRANSPORT`.

Aktuelles Kandidatenmodell:

```text
COMMANDER
    |
    +-- BRIGADE / Ground Node
            |
            +-- PLATOON role pool
                    |
                    +-- ARMYGROUP
                            |
                            +-- physical DCS GROUP
```

Eine MOOSE `BRIGADE` wird nicht automatisch mit einer realen historischen Brigade gleichgesetzt. Die aktuelle Arbeitshypothese ist eine BRIGADE je operativ kohärentem Ground Node, nicht je OP und nicht eine einzige BRIGADE für ganz RC-East.

MOOSE-Quellprüfung hat bereits gezeigt:

- `BRIGADE` verwaltet `PLATOON`-/Asset-Pools über ein WAREHOUSE-/LEGION-Modell;
- `PLATOON`/`COHORT` kann Mission Capabilities und Mission Range begrenzen;
- `ARMYGROUP` bildet die physisch agierende Ground Group;
- Assets derselben Brigade können grundsätzlich im Feld geführt werden;
- bestimmte Return-/RTZ-Pfade können bei nicht mobilen Gruppen Teleport-Verhalten enthalten und sind deshalb für OMW nicht ungeprüft zulässig;
- `OPSTRANSPORT` ist als taktischer Transportbaustein zu prüfen.

Noch nicht entschieden ist, ob die vier Ground Nodes technisch tatsächlich exakt vier MOOSE-BRIGADEs werden.

## 7. Physische Installationsdarstellung

Eine aktive und angreifbare BLUE-Installation benötigt eine glaubwürdige physische Kampfdarstellung. Eine rein symbolische Minimaldarstellung aus wenigen Zelten und einem Helipad ist für aktive FOBs/COPs kein OMW-Standard.

Zu berücksichtigen sind je nach Standort insbesondere:

- Perimeter und Schutzbauwerke;
- kontrollierte Zufahrt;
- Fighting Positions / Towers;
- interne Verkehrs- und Fahrzeugbereiche;
- Logistik-/Fuel-Bereiche;
- Artillerie-/Mörserstellungen, wenn belegt oder genehmigt;
- Helipad/FARP/LZ, wenn belegt;
- medizinische und Support-Bereiche;
- Gelände, Höhenzüge und Anmarschsektoren.

Die physische Ausgestaltung wird vom Projektinhaber im Mission Editor beziehungsweise über von ihm ausgewählte Templates umgesetzt. ChatGPT verändert keine `.miz`-Dateien.

## 8. Quellenstand

Wichtige bereits ausgewertete Referenzen:

- `OMW-HIST-AFGHANISTAN-ORBAT-2011-07` für die Juli-2011-Kampfverbände;
- DoD `Wright and vicinity, Afghanistan (2003-2014)` POEMS für reale Standortnamen und Infrastrukturhinweise;
- U.S. Army Combat Studies Institute, `Vanguard of Valor: Small Unit Actions in Afghanistan` für Kunar-/Nuristan-Operations-, OP-, QRF-, Logistik- und Fire-Support-Kontext;
- DVIDS-Primärquellen zu Bostick, Joyce, Honaker-Miracle und Wright;
- OEF Base Tracker für Lage-/Namensabgleich von Außenstellungen;
- ergänzende Bild-/Videoquellen nur dort, wo Datum, Ort und Aussage ausreichend belastbar sind.

Sekundärquellen dienen als Research Index und überschreiben keine Primärquelle oder OMW-Designentscheidung.

## 9. Aktueller To-do-Stand

### Phase A – Standortnetz und historische Baseline

- [x] OMW-Recherchezeitraum 01.08.2010–31.12.2011 festgelegt.
- [x] Juli 2011 als einheitliche aktive Ground-ORBAT-Baseline festgelegt.
- [x] Salerno/Khost aus dem aktuellen ARMY-Spielfeld ausgeschlossen.
- [x] vier aktuelle Ground Nodes Jalalabad, Joyce, Wright und Bostick festgelegt.
- [x] FOB Bostick zusätzlich in den Scope aufgenommen.
- [x] FOB Wright zusätzlich in den Scope aufgenommen.
- [x] Camp Fiaz bewusst nicht aufgenommen.
- [x] Bostick-Overwatch-Kette Mustang/Clydesdale/Stallion als OMW-Planung festgelegt.
- [x] Korengal und Keating als vor OMW geschlossene Systeme behandelt.
- [ ] vollständige vom Projektinhaber angekündigte Standortliste später gegen den aktuellen Scope prüfen.
- [ ] prüfen, ob im aktuellen Operationsraum noch ein wirklich bedeutender, für das Gameplay notwendiger FOB fehlt.

### Phase B – Juli-2011-Einheiten und Fähigkeiten

- [x] Bostick: TF Wolfhound / 2-27 Infantry als Juli-2011-Baseline.
- [x] Joyce: TF Cacti / 2-35 Infantry als Juli-2011-Baseline.
- [x] Jalalabad: TF Bronco Higher-HQ-Kontext und TF Steel / 3-7 FA berücksichtigt.
- [x] Wright: 1-14th Illinois ADT / SECFOR als konkret belegter Juli-2011-Ground-Ansatz.
- [ ] Jalalabad/Fenty Ground-/Security-/QRF-Teilverbände auf Juli-2011-Stand weiter präzisieren.
- [ ] Joyce/Honaker konkrete Company-/Platoon-Zuordnungen soweit belastbar präzisieren.
- [ ] Bostick konkrete Company-/Platoon-Zuordnungen für Juli 2011 soweit belastbar präzisieren.
- [ ] Wright exakte Juli-2011-Artilleriezuordnung prüfen; 2010er M777-Nachweis nicht automatisch übertragen.
- [ ] verfügbare DCS-Ground-Unit-Typen gegen historische Rollen und notwendige technische Proxies abgleichen.

### Phase C – MOOSE-Architektur

- [x] `COMMANDER -> BRIGADE -> PLATOON -> ARMYGROUP` als zentrale Ground-OPS-Kandidatenhierarchie identifiziert.
- [x] BRIGADE nicht automatisch mit realer historischer Brigade gleichgesetzt.
- [x] OPs als abhängige Installationen ohne eigene strategische Ressourcenhoheit festgelegt.
- [ ] offizielle MOOSE-Demos/Tests für BRIGADE/PLATOON/ARMYGROUP/OPSTRANSPORT vollständig gegen gepinnten Stand prüfen.
- [ ] Mission-Capability-/Range-Selektion je PLATOON verifizieren.
- [ ] Verhalten dauerhaft im Feld stehender Assets, Rückkehr, Reinforcement und Reconstitution verifizieren.
- [ ] Teleport-/Despawn-Pfade identifizieren und für sichtbare OMW-Bereiche ausschließen.
- [ ] entscheiden, ob vier Ground Nodes exakt vier MOOSE-BRIGADEs werden.
- [ ] konkrete PLATOON-Rollen pro Node festlegen, mindestens Infantry/Patrol, QRF, OP Security, Logistics und Fire Support soweit lokal benötigt.
- [ ] `docs/moose/PROJECT-CLASS-INDEX.md` und passende Ground-OPS-Themendokumentation im selben Entwicklungsstand aktualisieren.

### Phase D – CampaignState und Ressourcenvertrag

- [ ] stabile Installation-IDs für alle aktiven FOB/COP/OP definieren.
- [ ] Parent-Beziehungen und Formation Assignments abbilden.
- [ ] Personnel/Vehicle/Supply/Ammo/Fuel-Verträge je Ground Node definieren.
- [ ] OP-Besatzung als Ressourcenbindung des Parent-Nodes modellieren.
- [ ] Nachschubverlust -> Readiness/Patrol/QRF/Defense-Auswirkungen definieren.
- [ ] Installationsangriff -> physischer Schaden -> CampaignState-Settlement definieren.
- [ ] keine doppelte Ressourcenhoheit zwischen CampaignState und MOOSE WAREHOUSE zulassen.

### Phase E – Mission Editor Foundation

- [ ] Projektinhaber finalisiert die benötigten physischen Installationen/Templates in der `.miz`.
- [ ] Wright-Aufbau abschließen.
- [ ] Bostick-Aufbau abschließen.
- [ ] Zufahrten, Road Anchors, Assembly Areas und Withdrawal Points validieren.
- [ ] aktive Ground-Gruppen und Template-Gruppen im Mission Editor definieren.
- [ ] DCS-Parking-/Pathfinding-/Terrain-Probleme für Ground-Routen dokumentieren.

### Phase F – Runtime und Acceptance

- [ ] kleinste MOOSE-first Runtime-Foundation implementieren.
- [ ] Lua-Syntax und Dokumentationsvalidator ausführen.
- [ ] MissionDemand-/COMMANDER-/BRIGADE-Asset-Selektion testen.
- [ ] Patrol/QRF/Resupply/OP-Reinforcement testen.
- [ ] Ground-AI-Pathfinding und Recovery-/Withdrawal-Verhalten testen.
- [ ] Multiplayer-Synchronisation und sichtbare Spawn-/Despawn-Grenzen testen.
- [ ] erst nach dokumentiertem DCS-Test betroffene Methoden/Klassen als `VALIDATED` markieren.

## 10. Aktueller Entscheidungsstand

Bereits beschlossen:

```text
- active Ground ORBAT uses July 2011 as unit baseline
- current ARMY field = Jalalabad + Joyce + Wright + Bostick sectors
- Salerno/Khost is outside current field
- Camp Fiaz is intentionally omitted
- Bostick includes Mustang/Clydesdale/Stallion as planned dependent OP chain
- CampaignState remains strategic resource authority
- active OPs consume parent-node personnel/resources
- active attackable installations require credible physical representation
```

Noch nicht beschlossen:

```text
- exact BRIGADE count and boundaries
- exact PLATOON composition
- exact DCS ground templates and strengths
- exact July-2011 Wright artillery detachment
- final artillery proxy decisions where DCS lacks the historical system
- runtime implementation details and acceptance criteria
```
