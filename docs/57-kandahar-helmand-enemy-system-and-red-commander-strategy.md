---
document_id: OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical historical enemy-system reference for Kandahar and Helmand
  - source-derived strategic behavior rules for the consolidated OMW RED Commander
  - source-qualified coalition, ANSF, terrain, support-zone, logistics and governance context from the listed studies
not_authoritative_for:
  - active BLUE or RED ORBAT
  - exact local insurgent strength or spawn counts
  - separate runtime factions or faction diplomacy
  - automatic target selection against civilian, religious or educational objects
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 57 – Kandahar und Helmand: Enemy System und Strategie des konsolidierten RED Commanders

## 1. Zweck

Dieses Dokument wertet die zuletzt bereitgestellten ISW- und New-America-Studien zu Marjah, Helmand und Kandahar vollständig quellenkritisch für Operation Mountain Watch aus.

Es ergänzt:

- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md);
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md);
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md);
- [`OMW-HIST-MONTHLY-COALITION-ORBAT-BASING`](55-monthly-coalition-orbat-and-basing-2010-2011.md).

Die verbindliche Grundentscheidung bleibt:

```text
1 konsolidierter RED Commander
1 gemeinsamer REDState
1 gemeinsamer Ressourcenpool
keine getrennten Runtime-Fraktionen
```

Die Quellen beschreiben Taliban-Strukturen und regionale Netzwerke. OMW übernimmt daraus Strategie, Verhalten, Zustände und Missionsmuster, nicht mehrere technische Gegner.

## 2. Quellenregister und Bewertung

| ID | Quelle | Datum | Einstufung | Hauptnutzen | Grenze |
|---|---|---:|---|---|---|
| KHE-01 | Jeffrey Dressler, *Operation Moshtarak: Preparing for the Battle of Marjah* | 11.02.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Marjah als C2-, Drogen-, IED-, Finanz- und Schattenverwaltungszentrum; erwartete Kräfte und Operationsraum | vor Beginn der Hauptoperation; zahlreiche Angaben aus Presse- und Interviewquellen |
| KHE-02 | Jeffrey Dressler, *Marjah's Lessons for Kandahar* | 09.07.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Clear-Hold-Probleme, Reinfiltration, Einschüchterung, Polizeigrenzen, Governance Delivery | Zwischenstand vier Monate nach Operationsbeginn |
| KHE-03 | Anand Gopal, *The Battle for Afghanistan: Militancy and Conflict in Kandahar* | 11.2010 | `SECONDARY_FIELD_RESEARCH_IN_PERIOD` | Aufbau, Finanzierung, Schattenverwaltung, lokale Führung, Taktiken, Distriktverteilung und Stärkenschätzungen | interviewbasiert; anonyme Quellen; Kandahar-spezifisch |
| KHE-04 | Carl Forsberg, *Politics and Power in Kandahar* | 04.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | informelle Macht, Patronage, private Sicherheitskräfte, Vertragsökonomie, Governance-Legitimität | keine taktische ORBAT; personenzentrierte politische Analyse |
| KHE-05 | Carl Forsberg, *Counterinsurgency in Kandahar: Evaluating the 2010 Hamkari Campaign* | 12.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Enemy System, Hamkari, Kräfteverteilung, Shaping, Clearing, Support Zones, ANSF und Reaktion des Gegners | zeitgenössischer Zwischenstand; einzelne Zahlen aus Sekundärquellen |
| KHE-06 | Carl Forsberg, *The Taliban's Campaign for Kandahar* | 12.2009 | `PRE_PERIOD_ANALYTICAL_BASELINE` | mehrjährige Kampagnenlogik, Kandahar-Ring, Lines of Communication, Intimidation und schrittweise Annäherung an Kandahar City | endet vor OMW-Zeitraum |
| KHE-07 | Jeffrey Dressler, *Securing Helmand: Understanding and Responding to the Enemy* | 09.2009 | `PRE_PERIOD_ANALYTICAL_BASELINE` | südliches, zentrales und nördliches Helmand-System; Barham Chah; Supply-, Attack- und Support-Zonen; Taktiken | vor OMW-Zeitraum; Führungsnamen und Einzelstrukturen nicht automatisch 2010/2011 gültig |
| KHE-08 | Aprajita Kashyap, *Af-Pak Strategy: A Survey of Literature* | 07.2009 | `BACKGROUND_ONLY` | strategischer Pakistan-/Safe-Haven-/Logistikrahmen und zeitgenössische Debatte | Literaturübersicht; keine lokale ORBAT oder taktische Primärquelle |
| KHE-09 | Jeffrey Dressler, *Counterinsurgency in Helmand: Progress and Remaining Challenges* | 01.2011 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Wirkung der Operationen 2009/2010, Reinfiltration, ANSF, Drogenfinanzierung, Governance, Entwicklung und Restgefahren | Bewertung aus Januar 2011; spätere Entwicklung nicht enthalten |

## 3. Quellenqualifizierte Kräfte und Stärken

### 3.1 Operation Moshtarak

KHE-01 nennt für die geplante Gesamtoperation bis zu:

```text
15.000 US-amerikanische, Koalitions- und afghanische Kräfte
```

Diese Zahl umfasst die gesamte Operation und ist keine gleichzeitig innerhalb Marjahs eingesetzte Kampftruppenstärke.

KHE-02 nennt als Hauptkräfte im unmittelbaren Operationsraum:

- 1st Battalion, 6th Marines;
- 3rd Battalion, 6th Marines;
- mehrere hundert ANA-Soldaten;
- Special Forces;
- ein US-Army-Bataillon als nordöstlichen Cordon;
- weitere afghanische und Koalitionselemente außerhalb des Stadtkerns.

Verwendungsregel:

```text
formation_identity != local_effective_strength
operation_total != simultaneous_assault_strength
planned_strength != mission_ready_strength
```

### 3.2 ANSF und Polizeikräfte

Die Quellen belegen stark unterschiedliche Leistungsstände:

- ANA-Verbände konnten mit enger Partnerschaft deutlich leistungsfähiger werden;
- einzelne ANA-Einheiten führten eigenständigere Operationen durch;
- neu aufgestellte oder unerfahrene Verbände litten unter Führungs-, Disziplin- und Ausbildungsproblemen;
- ANCOP und ANP wurden teilweise in Aufgaben eingesetzt, die ihre Ausbildung überforderten;
- Polizeikräfte waren für Ordnungssicherung geeigneter als für die kampfintensive erste Clear-Phase;
- lokale Polizei konnte repräsentativer und wirksamer sein, wenn Rekrutierung, Führung und Legitimität funktionierten.

Für OMW werden daher getrennt:

```yaml
ansf_state:
  nominal_strength: unknown_or_documented
  present_strength: 0..100
  leadership_quality: 0..100
  training: 0..100
  discipline: 0..100
  local_legitimacy: 0..100
  partner_support: 0..100
  combat_multiplier_access: 0..100
```

Eine Bataillons- oder Kandak-Bezeichnung erzeugt keine automatische Vollstärke.

### 3.3 Insurgentenschätzungen

Die Studien nennen je nach Raum, Zeitpunkt und Methodik unterschiedliche Schätzungen. Diese sind:

- nicht miteinander direkt addierbar;
- saisonal und durch kurzfristige Mobilisierung veränderlich;
- teilweise auf aktive Kämpfer, teilweise auf Unterstützer, Führung, IED-Fachleute oder Drogenakteure bezogen;
- keine geeigneten Spawnzahlen.

OMW nutzt solche Werte nur als:

```text
LOW_CAPACITY
MEDIUM_CAPACITY
HIGH_CAPACITY
SURGE_CAPACITY
```

und niemals als direkte Zahl physischer DCS-Gruppen.

## 4. Raum- und Systemmodell

## 4.1 Marjah

Marjah wird als Enemy-System-Knoten beschrieben mit:

- zwei zentralen Bazaarknoten;
- Command-and-Control-Funktion;
- IED-Produktion und vorbereiteten Sperren;
- Drogenverarbeitung und -handel;
- Besteuerung und Finanzierung;
- Schattenjustiz und lokalen Funktionären;
- befestigten Compounds, Kanälen und schwer kontrollierbaren landwirtschaftlichen Flächen;
- Verbindungen nach Nad Ali, Lashkar Gah und Nawa.

Daraus folgt:

```yaml
marjah_enemy_system:
  command_node: true
  finance_node: true
  cache_network: dense
  ied_capacity: high
  terrain_concealment: high
  population_coercion: high
  reinfiltration_access: high
```

Die in KHE-01 genannten Angaben zu 187 Verarbeitungsstätten und monatlichen Einnahmen über 200.000 US-Dollar bleiben `SOURCE_REPORTED_ESTIMATE`; sie werden nicht als fester CampaignState-Wirtschaftswert übernommen.

## 4.2 Kandahar-Ring

Die Quellen beschreiben keinen unmittelbaren Sturm auf Kandahar City als primäre Strategie. Der Gegner versuchte über Jahre, den äußeren Ring und die Zufahrten zu kontrollieren oder zu beeinflussen.

Besonders relevante Räume:

- Zhari;
- Panjwai;
- Arghandab;
- Dand;
- Khakrez;
- Shah Wali Kot;
- Maiwand;
- nördliche und westliche Zufahrten;
- Highway One;
- Zugänge nach Uruzgan, Helmand und Pakistan.

Funktion des Rings:

- Rückzugs- und Bereitstellungsraum;
- Cache- und IED-Netz;
- Infiltration nach Kandahar City;
- Angriff auf Hauptverkehrsachsen;
- Einschüchterung und Kontrolle der Bevölkerung;
- Schutz von Führung und Logistik;
- Verteilung kleiner Zellen auf mehrere Distrikte.

## 4.3 Helmand-System

### Südliches Helmand

Hauptfunktion:

- Zuführung von Kämpfern, Waffen und IED-Komponenten;
- Schmuggel und Ausfuhr von Drogen;
- Verbindung zu Rückzugs- und Unterstützungsräumen in Pakistan;
- geringe sichtbare Aktivität dort, wo wenige BLUE-Kräfte und geringe Bevölkerung vorhanden sind.

Barham Chah wird als wichtiger Grenz- und Umschlagknoten beschrieben. Für OMW ist dies ein historischer Beispielsfall für:

```text
EXTERNAL_ENTRY_NODE
TRANSIT_NODE
FINANCE_EXPORT_NODE
SUPPLY_ALLOCATION_NODE
```

### Zentrales Helmand

Hauptfunktion:

- Bevölkerungsschwerpunkt;
- Führungs-, Finanz- und Operationsknoten;
- Angriffszonen um Lashkar Gah und Gereshk;
- Safe Havens und Support Zones in Marjah, Nad Ali, Nawa und Nahri Sarraj;
- Bazaare als wirtschaftliche, logistische und politische Schlüsselräume.

### Nördliches Helmand

Hauptfunktion:

- Opiumproduktion;
- IED-Herstellung;
- Rückzugs- und Unterstützungsräume;
- Verbindung nach Kandahar und Uruzgan;
- Bindung und Abnutzung von Koalitionskräften in schwer zugänglichen Räumen.

## 5. Strategische Zielhierarchie des RED Commanders

Der konsolidierte RED Commander verfolgt nicht primär die Vernichtung sämtlicher BLUE-Kräfte. Seine Prioritäten sind:

### Priorität 1 – Netzwerk erhalten

- Führung, Fachpersonal und lokale Verbindungen schützen;
- offene Gefechte gegen deutlich überlegene Kräfte vermeiden;
- Waffen und Material in Caches verbergen;
- bei Druck in benachbarte Sektoren ausweichen;
- später zurückkehren.

### Priorität 2 – Bewegungsfreiheit von BLUE begrenzen

- Route und Routine beobachten;
- IEDs, Minen und Hinterhalte vorbereiten;
- Checkpoints und Außenposten testen;
- Convoys verzögern oder zu zusätzlichem Schutz zwingen;
- EOD-, QRF-, ISR- und Route-Clearance-Kapazität binden.

### Priorität 3 – Bevölkerung und Informationsraum beeinflussen

- Informanten abschrecken;
- Zusammenarbeit mit Regierung und Koalition verteuern;
- Nachtbewegungsfreiheit nutzen;
- gezielte Drohungen, Nachtbriefe und selektive Gewalt einsetzen;
- staatliche und lokale Schutzversprechen unglaubwürdig machen.

### Priorität 4 – Logistik und Finanzierung sichern

- externe Zuführung aufrechterhalten;
- lokale Besteuerung und Erpressung nutzen;
- Drogen-, Schmuggel- und Handelsnetzwerke ausnutzen;
- Caches und Umschlagpunkte regenerieren;
- Operationsressourcen dezentral beschaffen.

### Priorität 5 – politische und psychologische Wirkung

- sichtbare Sicherheitslücken demonstrieren;
- symbolische Ziele angreifen;
- lokale Verwaltung und Polizei diskreditieren;
- BLUE zur dauerhaften Kräftebindung zwingen;
- kurzfristige Geländeverluste akzeptieren, wenn das Netzwerk überlebt.

## 6. Kernentscheidung: Clear ist nicht Hold

Die Marjah-Studien zeigen einen wiederkehrenden Ablauf:

```text
BLUE_CLEAR
→ RED_WITHDRAW_OR_MELT_INTO_POPULATION
→ BLUE_SECURES_KEY_NODES
→ RED_RETURNS_AT_NIGHT
→ INTIMIDATION_AND_TARGETED_VIOLENCE
→ CACHE_AND_OBSERVER_NETWORK_REBUILT
→ SMALL_ATTACKS_RESUME
→ AREA_CONTESTED_AGAIN
```

Daraus folgt verbindlich:

```text
AREA_CLEARED != AREA_SECURED
AREA_SECURED != POPULATION_CONTROLLED
TACTICAL_VICTORY != CAMPAIGN_SUCCESS
```

Ein Sektor bleibt nur dann nachhaltig gesichert, wenn ausreichend vorhanden sind:

- dauerhafte Präsenz;
- Route Security;
- lokale Partnerfähigkeit;
- HUMINT und freiwillige Meldungen;
- Schutz lokaler Funktionsträger;
- funktionsfähige Verwaltung und Streitbeilegung;
- wiederholte Cache- und IED-Netzstörung.

## 7. Sektorzustände

Für das einfache Grundsystem werden folgende Zustände verwendet:

```text
RED_ABSENT
RED_LATENT
RED_ESTABLISHING
RED_ACTIVE
RED_DISRUPTED
BLUE_CLEARED_NOT_HELD
BLUE_HELD
RED_REINFILTRATING
RED_RECONSTITUTED
```

### Übergänge

```text
RED_ACTIVE
  --successful BLUE clear-->
RED_DISRUPTED

RED_DISRUPTED
  --BLUE leaves insufficient hold force-->
BLUE_CLEARED_NOT_HELD

BLUE_CLEARED_NOT_HELD
  --night access + surviving observers + population intimidation-->
RED_REINFILTRATING

RED_REINFILTRATING
  --cache rebuilt + local freedom of movement-->
RED_RECONSTITUTED

RED_RECONSTITUTED
  --new attacks-->
RED_ACTIVE
```

`BLUE_HELD` senkt die Reinfiltrationswahrscheinlichkeit, verhindert sie aber nicht automatisch.

## 8. Aktionsmodell

## 8.1 Verbindliche MVP-Aktionen

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

`REINFILTRATE_SECTOR` wird aufgrund der Marjah- und Kandahar-Erfahrungen Bestandteil der Grundversion und nicht auf eine späte Ausbauphase verschoben.

## 8.2 Spätere Einflussaktionen

```text
INTIMIDATE_LOCAL_CONTACT
PUNISH_INFORMANT
TARGET_LOCAL_OFFICIAL
DISTRIBUTE_NIGHT_LETTERS
ESTABLISH_SHADOW_OFFICIAL
RUN_SHADOW_COURT
COLLECT_TAX_OR_EXTORTION
PROPAGANDA_EXPLOIT_EVENT
```

Diese Aktionen sind primär virtuelle CampaignState-Ereignisse.

## 8.3 Spätere taktische Erweiterungen

```text
FEINT_ATTACK
MULTI_DIRECTION_ATTACK
SECONDARY_ATTACK_ON_RESPONDERS
MOTORCYCLE_IED
SVBIED_ATTACK
HIGH_PROFILE_COMPLEX_ATTACK
```

Quellenbezug:

- KHE-07 beschreibt gestaffelte Angriffe aus mehreren Richtungen;
- KHE-07 beschreibt mehrstufige Angriffe auf eintreffende Reaktionskräfte;
- KHE-05/KHE-06 beschreiben Infiltration, Angriffe auf Stadt und Hauptverkehrsachsen;
- KHE-02/KHE-09 beschreiben kleine Teams, Nachtaktivität und Reinfiltration.

Diese Muster sind nicht Bestandteil des ersten Tests, solange IED, Hinterhalt, Probe, Rückzug und Reinfiltration nicht stabil funktionieren.

## 9. Lokale Zellautonomie

Der eine RED Commander entscheidet strategisch:

```text
welcher Sektor
welcher Zweck
welches Ressourcenbudget
welche Eskalationsgrenze
welcher gewünschte Kampagneneffekt
```

Eine lokale Zelle entscheidet innerhalb des Auftrags:

```text
konkreter Zeitpunkt
konkreter Angriffspunkt
Abbruch bei Überlegenheit
Rückzugsrichtung
Nutzung eines vorbereiteten Cache
```

Dadurch wird keine zweite Kommandostruktur erzeugt. Es handelt sich um delegierte taktische Ausführung innerhalb eines gemeinsamen REDState.

## 10. Entscheidungslogik

### 10.1 Bewertungsgrößen

```yaml
sector_assessment:
  strategic_value: 0..100
  route_value: 0..100
  population_access: 0..100
  cache_access: 0..100
  concealment: 0..100
  blue_presence: 0..100
  blue_pattern_predictability: 0..100
  ansf_reliability: 0..100
  local_government_legitimacy: 0..100
  red_intelligence: 0..100
  red_pressure: 0..100
  recent_losses: 0..100
```

### 10.2 Auswahlregeln

Bei hohem BLUE-Druck:

```text
DISPERSE_UNDER_PRESSURE
MOVE_CADRE
HIDE_WEAPONS
REDUCE_GROUP_SIZE
AVOID_DECISIVE_ENGAGEMENT
```

Bei geringer Hold-Präsenz nach einem BLUE-Erfolg:

```text
REINFILTRATE_SECTOR
RESTORE_OBSERVERS
REBUILD_CACHE
INTIMIDATE_LOCAL_CONTACT
RESUME_SMALL_ATTACKS
```

Bei wertvoller und vorhersehbarer Route:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
```

Bei schwacher Polizei und Verwaltung:

```text
PROBE_CHECKPOINT
INTIMIDATE_LOCAL_CONTACT
PUNISH_INFORMANT
ESTABLISH_SHADOW_INFLUENCE
```

Bei verlorener Logistik:

```text
AVOID_COMPLEX_ATTACK
REBUILD_SUPPLY_LINK
RELOCATE_CACHE
REDUCE_OPERATIONAL_TEMPO
```

## 11. Taktische Verhaltensregeln

### 11.1 Nicht bis zur Vernichtung kämpfen

Eine lokale Zelle löst sich, wenn:

- BLUE-Überlegenheit deutlich ist;
- Luftunterstützung oder QRF eintrifft;
- der eigentliche Effekt bereits erreicht ist;
- weitere Verluste den Netzwerkwert übersteigen;
- ein Rückzugsweg verfügbar ist.

### 11.2 Kleine Teams unter Druck

Bei anhaltenden Raids, ISR und Führungsausfällen:

- größere Gruppen werden vermieden;
- Beobachter, IED-Teams und kleine Feuertrupps werden getrennt;
- Caches ersetzen dauerhaft mitgeführte Bewaffnung;
- einzelne Zellen kennen nur Teile des Netzes;
- Aktivität verlagert sich in Nacht- und Übergangszeiten.

### 11.3 Feint und mehrstufiger Angriff

Spätere Implementierung:

1. Ablenkung oder Feint;
2. Feuer aus zweiter Richtung;
3. Hauptangriff oder IED;
4. optional Angriff auf eintreffende Reaktionskräfte;
5. schneller Abbruch.

Diese Taktik benötigt eigene Schutzregeln, damit die KI nicht jeden BLUE-Responder automatisch in unrealistische Fallen führt.

## 12. Finanzierung und Ressourcen

Der RED-Ressourcenpool darf gespeist werden durch:

```text
LOCAL_TAXATION
EXTORTION
NARCOTICS_REVENUE
SMUGGLING
EXTERNAL_SUPPORT
CAPTURED_MATERIEL
LOCAL_DONATIONS_OR_COERCION
```

Quellenkritische Regel:

- konkrete Dollarbeträge aus Einzelquellen werden nicht direkt übernommen;
- Finanzierung ist regional und zeitlich unterschiedlich;
- nicht jeder Kämpfer erhält ein regelmäßiges Gehalt;
- lokale Kommandeure beziehungsweise Zellen können selbst Ressourcen beschaffen;
- zentrale Unterstützung und lokale Selbstfinanzierung können gleichzeitig bestehen.

Technische Vereinfachung für das MVP:

```yaml
red_resources:
  manpower: 0..100
  explosives: 0..100
  weapons: 0..100
  finance: 0..100
  intelligence: 0..100
  cache_capacity: 0..100
```

## 13. Governance- und Bevölkerungseffekte

Die Quellen zeigen, dass militärische Sicherheit allein nicht ausreicht. Wichtige Faktoren:

- Schutz lokaler Funktionsträger;
- funktionierende Streitbeilegung;
- wahrgenommene Fairness der Polizei;
- Abwesenheit predatory governance;
- Verlässlichkeit staatlicher Dienstleistungen;
- Schutz vor Vergeltung;
- Zugang zu Arbeit und Märkten;
- Vertrags- und Patronagenetzwerke;
- Land- und Wasserstreitigkeiten.

Für die Grundversion genügen:

```yaml
civil_state:
  government_legitimacy: 0..100
  local_security_reliability: 0..100
  informant_willingness: 0..100
  population_cooperation: 0..100
  intimidation: 0..100
```

Ethnie, Stamm, Religion oder zivile Objektkategorie erzeugen keine automatische Feindzugehörigkeit.

## 14. BLUE- und RED-Erfolgsmessung

### RED-Erfolg

- BLUE bindet zusätzliche Kräfte;
- Route ist nur mit höherem Aufwand nutzbar;
- Caches überleben;
- Beobachter und lokale Kontakte bleiben aktiv;
- ein geräumter Sektor wird erneut infiltriert;
- lokale Funktionsträger schränken ihre Tätigkeit ein;
- RED vermeidet unverhältnismäßige Verluste.

### BLUE-Erfolg

- Route bleibt über längere Zeit nutzbar;
- Reinfiltration wird erkannt und unterbrochen;
- Caches und IED-Netze werden dauerhaft reduziert;
- lokale Meldungen nehmen freiwillig zu;
- Funktionsträger können sich bewegen und arbeiten;
- ANSF übernimmt Aufgaben mit sinkender externer Unterstützung;
- zivile Schäden und Fehlidentifikationen bleiben gering.

```text
RED_KILLS != RED_SUCCESS
BLUE_KILLS != BLUE_SUCCESS
CLEAR_COMPLETE != CAMPAIGN_COMPLETE
```

## 15. Missionsvorlagen

### 15.1 Clear-Hold-Reinfiltration

- BLUE räumt einen Sektor;
- RED zieht sich zurück oder bleibt latent;
- BLUE verlegt Kräfte;
- RED kehrt nachts mit Beobachtern und kleinen Teams zurück;
- Einschüchterung senkt HUMINT;
- Cache wird aufgebaut;
- IED- oder Hinterhaltsmission folgt.

### 15.2 Route Boxing

- RED beobachtet mehrere Nebenwege;
- IEDs werden hinter und neben einer BLUE-Bewegung vorbereitet;
- Ziel ist nicht zwingend Vernichtung, sondern Bindung und Bewegungshemmung;
- BLUE muss Route Clearance, ISR und Sicherung umverteilen.

### 15.3 Bazaar-/District-Centre Pressure

- wirtschaftlicher und politischer Knoten bleibt formal unter Regierungskontrolle;
- RED greift Checkpoints, lokale Funktionäre oder Verkehrsströme an;
- Ziel ist Diskreditierung und Einschränkung der Regierungsfunktion;
- komplexe Angriffe bleiben seltene Eskalation.

### 15.4 Support-Zone Disruption

- BLUE greift Cache-, Finanz- oder Transferknoten außerhalb des unmittelbaren Angriffsraums an;
- RED verliert nicht zwingend sichtbares Gelände, aber Operationskapazität;
- Folgeeffekt ist sinkende IED-, Rekrutierungs- oder Angriffskapazität.

## 16. Karten- und Geodatenverwendung

Die Quellen enthalten Karten zu:

- Helmand- und Kandahar-Provinz;
- Enemy Safe Havens;
- Supply-, Support- und Attack-Zonen;
- ISAF-/ANSF-Kräfteverteilung;
- Marjah, Nad Ali, Lashkar Gah und Nawa;
- Arghandab, Zhari und Panjwai;
- nördlichen und südlichen Bewegungsachsen.

Diese Karten sind:

```text
HISTORICAL_ORIENTATION_REFERENCE
```

und nicht automatisch:

```text
GEODETIC_MISSION_EDITOR_SOURCE
```

Koordinaten, Zonen und Routen werden vor Nutzung gegen moderne Geodaten, DCS-Terrain und vorhandene OMW-Location-Registry geprüft.

## 17. Nicht ableitbar

Die Quellen belegen nicht zuverlässig:

- exakte tägliche Kämpferzahlen je Distrikt;
- vollständige lokale Waffenbestände;
- genaue Zahl aller Caches und IED-Werkstätten;
- permanente Anwesenheit jeder genannten Einheit;
- automatische Loyalität einer Bevölkerungsgruppe;
- identische Gegnerstruktur in allen OMW-Provinzen;
- eine lineare Beziehung zwischen Geld und Spawnzahl;
- eine sichere Geoposition jedes Kartensymbols.

## 18. Implementierungsreihenfolge

### Stufe 1 – RED-Netzwerk-MVP

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

### Stufe 2 – einfache Kampagneneffekte

- Hold-Präsenz;
- Reinfiltrationswahrscheinlichkeit;
- lokale Einschüchterung;
- HUMINT;
- Cache-Regeneration;
- ANSF-Zuverlässigkeit.

### Stufe 3 – erweiterte Taktiken

- Feint;
- mehrstufiger Angriff;
- Angriff auf Reaktionskräfte;
- gezielte Einschüchterung;
- lokale Schatteneinflüsse.

### Stufe 4 – optionale spätere Erweiterungen

- detaillierte Governance;
- komplexe Finanzierung;
- zusätzliche Verhaltensprofile;
- Mehrfraktionssimulation nur nach neuer ausdrücklicher Freigabe.

## 19. Acceptance-Anforderungen

Vor technischer Integration müssen mindestens reproduzierbar getestet sein:

1. genau ein RED Commander und ein Ressourcenpool;
2. Rückzug ohne unplausiblen Kampf bis zur Vernichtung;
3. Dispersal und erneute Zusammenstellung;
4. `REINFILTRATE_SECTOR` nach unzureichendem Hold;
5. Cache-Aufbau und Ressourcenverbrauch;
6. IED- und Hinterhaltsmissionen mit Abbruchkriterien;
7. keine automatische Zielauswahl nach Ethnie, Religion oder ziviler Objektkategorie;
8. MOOSE-First-Prüfung für FSM, INTEL, DETECTION, OPS, AUFTRAG, ZONE, SPAWN und Events;
9. DCS-Testprotokoll mit Missions-, Commit-, DCS- und MOOSE-Provenienz;
10. CampaignState-Rückschreibung für Erfolg, Verlust, Rückzug und Reinfiltration.
