---
document_id: OMW-RED-INSURGENT-FACTIONS-BEHAVIOR
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical insurgent behavior model for OMW mission and campaign design
  - consolidated single-opponent RED Commander baseline for the initial implementation
  - historically grounded RED goals, action types, constraints and campaign metrics
  - use of route influence, caches, intimidation, recruitment, reinfiltration and shadow governance as campaign effects
not_authoritative_for:
  - exact nationwide insurgent strength
  - separate runtime factions, commanders or resource pools
  - deterministic behavior based on ethnicity, religion or province alone
  - target authorization against religious, educational or civilian locations
  - active runtime implementation or DCS/MOOSE acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-RED-DIRECTOR as current behavioral design authority
  - mandatory multi-faction RED architecture from the initial version of this document
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 56 – Insurgentisches Verhalten und konsolidierter RED Commander

## 1. Verbindliche Grundentscheidung

Für die erste funktionsfähige Kampagnenbaseline gilt:

```text
1 konsolidierter RED Commander
1 gemeinsamer RED-Ressourcenpool
1 gemeinsames Netzwerkmodell
keine getrennten Fraktionskommandeure
keine Fraktionsbeziehungen
keine parallelen Taliban-/Haqqani-/HiG-Bestände
```

Der Gegner wird technisch zunächst als:

```text
INSURGENT_NETWORK
```

geführt.

Historische Unterschiede zwischen Taliban, Haqqani-Netzwerk, Hizb-e Islami und lokalen bewaffneten oder kriminellen Netzwerken bleiben als Quellenwissen erhalten. Sie dürfen später als optionale Verhaltensprofile genutzt werden, erzeugen in der Grundversion jedoch keine eigenständigen Gegner, Ressourcenpools, Führungsstrukturen oder Spawnlogiken.

Die Mehrfraktionssimulation ist:

```text
DEFERRED_MULTIFACTION_EXTENSION
```

und bleibt bis auf ausdrückliche spätere Freigabe zurückgestellt.

## 2. Zweck und Fachreferenzen

Dieses Dokument beschreibt:

- Ziele und Prioritäten des Gegners;
- Aufbau und Nutzung von Caches, Hide Sites und lokalen Zellen;
- Verhalten unter BLUE-Druck;
- Auswahl virtueller und physischer Aktionen;
- Reinfiltration nach unzureichendem Hold;
- Einfluss auf Bevölkerung, Verwaltung und Verkehrswege;
- geeignete CampaignState-Zustände und Messgrößen;
- einen stufenweisen, bewusst einfachen Implementierungsplan.

Der frühere [`OMW-RED-DIRECTOR`](06-red-director.md) bleibt als ersetzter historischer Entwurf erhalten.

Detaillierte regionale Quellen- und Systemanalyse:

- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md).

Technische Einordnung:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- MOOSE-Dokumentation und gesonderte DCS-Acceptance.

## 3. Quellen und Grenzen

### 3.1 International Crisis Group – *The Insurgency in Afghanistan's Heartland*, 2011

Stärkste Quelle für den zentral-östlichen Raum:

- Schattenverwaltungen;
- lokale Zellen und Kommandeure;
- Rekrutierung und Einschüchterung;
- Finanzierung und Besteuerung;
- Safehouses und Waffenlager;
- Infiltration;
- IED-, Hinterhalts- und komplexe Angriffsmuster.

Grenzen:

- regionaler Fokus;
- viele interviewbasierte Aussagen;
- lokale Schätzungen sind nicht landesweit übertragbar;
- mehrere historische Gruppen verpflichten OMW nicht zu einer Mehrfraktionssimulation.

### 3.2 Kandahar-/Helmand-Studien 2009–2011

Dokument 57 erschließt neun zusätzliche Studien zu:

- Marjah und Operation Moshtarak;
- Hamkari und dem Kandahar-Ring;
- Helmand Supply-, Support- und Attack-Zonen;
- Clear-Hold-Reinfiltration;
- Nachtaktivität und Einschüchterung;
- Finanzierung, Drogenwirtschaft und Schattenverwaltung;
- lokale Zellautonomie;
- ANSF- und Governance-Grenzen.

Hauptableitung:

```text
CLEAR_COMPLETE != AREA_SECURED
AREA_SECURED != POPULATION_CONTROLLED
```

### 3.3 Weitere Quellen

- Exum/Fick/Humayun/Kilcullen, *Triage* – Bevölkerungsschutz, Momentum, Priorisierung und Erschöpfungsstrategie;
- Rainer Glatz – HUMINT, Comprehensive Approach, Caveats und Endstate;
- James M. Dubik – ANSF-Kampfkraft, Ausbildung, Führung und Combat Multipliers;
- Khalatbari/Kazim – sekundäre Stärke-, Finanzierungs- und Pakistanangaben;
- Armajani, Berdal und Noev/Ullman – Hintergrund, keine taktische Runtime-Autorität.

## 4. Historische Vielfalt als optionale Profile

```text
SOURCE_PROFILE_GENERAL_INSURGENT
SOURCE_PROFILE_HIGH_COMPLEXITY_NETWORK
SOURCE_PROFILE_LOCAL_CRIMINAL_SUPPORT
SOURCE_PROFILE_POLITICAL_NETWORK
```

Diese Profile dürfen später beeinflussen:

- erforderliche Vorbereitung;
- Operationssicherheit;
- Reichweite;
- Safehouse- und Cache-Nutzung;
- Angriffskomplexität;
- erwartete psychologische Wirkung.

Sie dürfen zunächst nicht erzeugen:

- getrennte Commander;
- getrennte Logistik;
- Fraktionsdiplomatie;
- Fraktionskrieg;
- zusätzliche Kräfte außerhalb des gemeinsamen RED-Pools.

## 5. Konsolidierter REDState

```yaml
red_state:
  leadership_cohesion: 0..100
  manpower_pool: 0..100
  finance: 0..100
  explosives: 0..100
  weapons: 0..100
  intelligence_access: 0..100
  cache_capacity: 0..100
  mobility: 0..100
  external_support: 0..100
  operational_security: 0..100
  attack_cell_capacity: 0..100
  logistics_capacity: 0..100
  pressure_level: 0..100
```

Diese Werte sind abstrakte Kampagnenkapazitäten. Sie entsprechen keiner exakten landesweiten Kopfzahl und werden nicht direkt in DCS-Gruppen umgerechnet.

### 5.1 Lokale Zellstruktur

Quellenbeispiele zeigen:

```text
mehrere kleine örtliche Zellen
+ begrenzte gemeinsame Koordination
+ temporäre Zusammenfassung für ausgewählte Aktionen
+ taktische Handlungsfreiheit innerhalb eines strategischen Auftrags
```

Regionale Zahlen sind keine allgemeine Provinzformel und keine Spawnvorgabe.

## 6. AreaInfluenceState

```yaml
area_state:
  armed_presence: 0..100
  intimidation: 0..100
  population_support: 0..100
  population_passivity: 0..100
  government_legitimacy: 0..100
  government_security_presence: 0..100
  hold_strength: 0..100
  route_control: 0..100
  recruitment_access: 0..100
  intelligence_penetration: 0..100
  cache_network: 0..100
  shadow_governance: 0..100
  reinfiltration_access: 0..100
```

Nicht auf einen einzigen `control`-Wert reduzieren. Zu trennen sind:

- Zustimmung;
- Duldung aus Angst;
- bewaffnete Präsenz;
- Nachtbewegungsfreiheit;
- Cache- und Informantenzugang;
- Einfluss auf Verwaltung oder Justiz;
- physische Hold-Präsenz von BLUE/ANSF.

Sichtbare Zusammenfassung:

```text
ABSENT
LATENT
ESTABLISHING
ACTIVE
DISRUPTED
BLUE_CLEARED_NOT_HELD
BLUE_HELD
REINFILTRATING
RECONSTITUTED
```

Für das erste lauffähige System werden umgesetzt:

```text
armed_presence
route_control
cache_network
pressure_level
hold_strength
reinfiltration_access
```

## 7. Ziele des RED Commanders

### 7.1 Netzwerk überleben lassen

- Führung und Kader erhalten;
- Kräfte bei Überlegenheit aufteilen;
- Caches und Hide Sites schützen;
- Kontakt abbrechen statt bis zur Vernichtung zu kämpfen;
- kurzfristige Geländeverluste akzeptieren, wenn das Netzwerk erhalten bleibt.

### 7.2 Bewegungsfreiheit begrenzen

- Routen beobachten;
- IEDs und Hinterhalte vorbereiten;
- Checkpoints und Außenposten binden;
- Convoys verzögern oder zu Umwegen zwingen;
- EOD-, ISR-, QRF- und Route-Clearance-Kapazität binden.

### 7.3 Ressourcen sichern

- Caches und Nachschubwege erhalten;
- Rekrutierungs- und Finanzierungsmöglichkeiten schützen;
- Verluste regenerieren;
- externe und lokale Versorgung kombinieren.

### 7.4 Bevölkerung und Regierung beeinflussen

- Informanten einschüchtern;
- staatliche Legitimität schwächen;
- lokale Beschwerden ausnutzen;
- Schutzversprechen von BLUE und Regierung unglaubwürdig machen;
- später optional Schattenjustiz und Abgabenerhebung simulieren.

### 7.5 Koalition erschöpfen

- Reaktionskräfte binden;
- dauerhafte Unsicherheit erzeugen;
- politische und psychologische Kosten erhöhen;
- nicht zwingend Gelände dauerhaft halten.

## 8. Aktionsportfolio

### 8.1 MVP

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

`REINFILTRATE_SECTOR` ist aufgrund der Marjah- und Kandahar-Erfahrungen Bestandteil der Grundversion.

### 8.2 Vollständiges quellenbasiertes Portfolio

```text
RECRUIT_LOCAL_CELL
INTIMIDATE_COMMUNITY
INTIMIDATE_LOCAL_CONTACT
PUNISH_INFORMANT
DISTRIBUTE_NIGHT_LETTERS
BUILD_CACHE
ESTABLISH_HIDE_SITE
MOVE_CADRE
OBSERVE_ROUTE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
CONDUCT_COMPLEX_AMBUSH
FEINT_ATTACK
MULTI_DIRECTION_ATTACK
SECONDARY_ATTACK_ON_RESPONDERS
PROBE_CHECKPOINT
DISRUPT_ROUTE
REINFILTRATE_SECTOR
CONDUCT_TARGETED_ASSASSINATION
CONDUCT_KIDNAPPING
CONDUCT_HIGH_PROFILE_COMPLEX_ATTACK
INFILTRATE_SECURITY_OR_GOVERNMENT
DISPERSE_UNDER_PRESSURE
REMOTE_REGROUP
PROPAGANDA_EXPLOIT_EVENT
ESTABLISH_SHADOW_OFFICIAL
RUN_SHADOW_COURT
COLLECT_TAX_OR_EXTORTION
```

Nicht jede Aktion benötigt eine physische DCS-Gruppe. Rekrutierung, Einschüchterung, Infiltration, Propaganda, Reinfiltrationsvorbereitung und Schattenherrschaft sind primär CampaignState-Ereignisse.

## 9. Strategische Prioritätslogik

### 9.1 Wertvolle und vorhersehbare Route

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
DISRUPT_ROUTE
```

Erfolg kann bedeuten:

- Verzögerung;
- Umleitung;
- zusätzliche Sicherungskräfte;
- sinkende Bewegungsfreiheit;
- höheren Logistikaufwand.

### 9.2 Hoher BLUE-Druck

```text
REDUCE_GROUP_SIZE
MOVE_CADRE
HIDE_WEAPONS
DISPERSE_UNDER_PRESSURE
AVOID_DECISIVE_ENGAGEMENT
REMOTE_REGROUP
```

### 9.3 Unzureichendes Hold nach BLUE-Clear

```text
REINFILTRATE_SECTOR
RESTORE_OBSERVERS
REBUILD_CACHE
INTIMIDATE_LOCAL_CONTACT
RESUME_SMALL_ATTACKS
```

### 9.4 Schwache Regierung oder Polizei

Später priorisierbar:

```text
RECRUIT_LOCAL_CELL
INTIMIDATE_COMMUNITY
PUNISH_INFORMANT
ESTABLISH_SHADOW_OFFICIAL
RUN_SHADOW_COURT
COLLECT_TAX_OR_EXTORTION
```

### 9.5 Komplexer Angriff

Nur bei erfüllten Voraussetzungen:

```yaml
requirements:
  intelligence_access: high
  cache_or_hide_site: available
  attack_cell_capacity: high
  operational_security: sufficient
  target_value: high
  expected_psychological_effect: high
```

Komplexe Angriffe werden nicht zufällig erzeugt.

## 10. Clear-Hold-Reinfiltration

```text
BLUE_CLEAR
→ RED_WITHDRAW_OR_MELT_INTO_POPULATION
→ RED_DISRUPTED
→ BLUE_SECURES_KEY_NODES
→ BLUE_REDUCES_HOLD_PRESENCE
→ RED_RETURNS_AT_NIGHT
→ OBSERVERS_AND_INTIMIDATION
→ CACHE_REBUILT
→ SMALL_ATTACKS_RESUME
→ RED_RECONSTITUTED
```

Verbindlich:

```text
AREA_CLEARED != AREA_SECURED
AREA_SECURED != POPULATION_CONTROLLED
TACTICAL_VICTORY != CAMPAIGN_SUCCESS
```

### 10.1 Zustandsübergänge

```text
ACTIVE
  --successful clear-->
DISRUPTED

DISRUPTED
  --insufficient hold-->
BLUE_CLEARED_NOT_HELD

BLUE_CLEARED_NOT_HELD
  --night access + surviving network-->
REINFILTRATING

REINFILTRATING
  --cache and local access restored-->
RECONSTITUTED

RECONSTITUTED
  --new attack-->
ACTIVE
```

`BLUE_HELD` reduziert Reinfiltration, verhindert sie aber nicht automatisch.

## 11. Taktische Muster

### 11.1 IED und Hinterhalt

1. Route beobachten;
2. Routine erkennen;
3. Cache oder IED vorbereiten;
4. ausgewähltes Ziel angreifen;
5. kleine Feuer- oder Beobachtungskomponente einsetzen;
6. rasch lösen;
7. Reaktion auswerten.

Nicht jede IED-Aktion benötigt einen bis zum Tod kämpfenden Trupp.

### 11.2 Checkpoint Probe

- Annäherungswege testen;
- Reaktionszeit messen;
- Feuerpositionen oder tote Winkel erkennen;
- ohne unnötige Verluste abbrechen;
- Informationen für spätere Aktionen speichern.

### 11.3 Dispersal

Bei gegnerischer Überlegenheit:

- Kräfte teilen;
- Waffen verstecken;
- Cache oder Hide Site wechseln;
- benachbarte Sektoren nutzen;
- später in neuer Zusammensetzung zurückkehren.

### 11.4 Kleine Teams unter Druck

- Beobachter, IED-Teams und Feuertrupps trennen;
- größere Sammelpunkte vermeiden;
- Nacht- und Übergangszeiten nutzen;
- Caches statt dauerhaft mitgeführter Waffen nutzen;
- lokale Zellen nur begrenzt über das Gesamtnetz informieren.

### 11.5 Feint und mehrstufiger Angriff

Spätere Erweiterung:

1. Ablenkung oder Feint;
2. Feuer aus zweiter Richtung;
3. Hauptangriff oder IED;
4. optionaler Angriff auf eintreffende Reaktionskräfte;
5. schneller Abbruch.

Diese Aktionsklasse wird erst nach Stabilisierung der MVP-Funktionen umgesetzt.

## 12. Lokale Zellautonomie

Der RED Commander entscheidet:

```text
Sektor
Zweck
Ressourcenbudget
Eskalationsgrenze
gewünschter Kampagneneffekt
```

Die lokale Zelle entscheidet innerhalb dieses Auftrags:

```text
Zeitpunkt
Angriffspunkt
Abbruch
Rückzugsrichtung
Cache-Nutzung
```

Dies ist delegierte taktische Ausführung innerhalb eines gemeinsamen REDState, keine zweite Fraktion oder ein zweiter strategischer Commander.

## 13. Rekrutierung und Bevölkerung

Mögliche Einflussfaktoren:

- fehlende Sicherheit;
- Korruption und Straflosigkeit;
- wirtschaftliche Ausgrenzung;
- Arbeitslosigkeit;
- Land- und Wasserstreitigkeiten;
- zivile Opfer;
- ungerecht empfundene Festnahmen oder Nachtoperationen;
- Rache;
- Zwang und Einschüchterung;
- lokale Machtkonflikte.

Verbindlich:

> Ethnie, Religion, Stamm oder Wohnort allein erzeugen keine feindliche Zugehörigkeit.

## 14. Geschützte zivile Objekte

Moscheen, Schulen, medizinische Einrichtungen, Bazaare und andere zivile Objekte bleiben grundsätzlich geschützt.

- Kategorie oder Standort allein ist keine feindliche Signatur;
- militärische Nutzung muss nachrichten- und ereignisbasiert festgestellt werden;
- NSL, ROE, Positive Identification und Kollateralschadensprüfung bleiben vollständig wirksam;
- verdeckte Nutzung ist ein Intelligence-Problem, keine pauschale Zielklasse.

## 15. Infiltration und Intelligence

Mögliche RED-Effekte:

```text
checkpoint_warning
patrol_route_leak
false_target_report
insider_access
weapons_cache_survival
attack_timing_bonus
night_reinfiltration_access
```

Mögliche BLUE-Gegenmaßnahmen:

```text
vetting
counterintelligence
source_validation
randomized_routes
cache_search
force_protection
persistent_patrolling
local_official_protection
```

Technische ISR-Sensoren allein decken das Netzwerk nicht vollständig auf. RECCE, HUMINT, Pattern-of-Life und Quellenvalidierung bleiben erforderlich.

## 16. Finanzierung

Zulässige abstrakte Quellen:

```text
LOCAL_TAXATION
EXTORTION
NARCOTICS_REVENUE
SMUGGLING
EXTERNAL_SUPPORT
CAPTURED_MATERIEL
LOCAL_DONATIONS_OR_COERCION
```

Konkrete Dollarbeträge aus Einzelquellen werden nicht direkt als CampaignState-Balance übernommen. Lokale Selbstfinanzierung und zentrale Unterstützung können gleichzeitig bestehen.

## 17. Erfolgsmessung

### RED

- Routen nur unter höherem Aufwand nutzbar;
- Cache-Netz überlebt;
- lokale Zellen können regenerieren;
- ein geräumter Sektor wird erneut infiltriert;
- Informanten und Funktionsträger werden eingeschüchtert;
- BLUE bindet überproportional viele Kräfte;
- Führung und externe Unterstützung bleiben funktionsfähig.

### BLUE/Campaign

- sichere Straßennutzung über längere Zeit;
- freiwillige Meldungen;
- sinkende Einschüchterung;
- stabile lokale Verwaltung;
- wirksames Hold statt kurzfristiger Präsenz;
- erkannte und unterbrochene Reinfiltration;
- ANSF-Readiness;
- zivile Schäden und Fehlidentifikationen.

```text
BLUE_KILLS != BLUE_SUCCESS
TERRAIN_OCCUPIED != LEGITIMATE_CONTROL
CLEAR_COMPLETE != CAMPAIGN_COMPLETE
```

## 18. Kampagnenphasen

```text
PREPARE
INFILTRATE
SHAPE
OFFENSIVE
EXPLOIT
DISPERSE
REINFILTRATE
RECOVER
```

Der eine RED Commander kann in unterschiedlichen Sektoren gleichzeitig verschiedene Phasen führen. Dafür sind keine getrennten Fraktionen nötig.

## 19. Technische Zielarchitektur

```text
REDState
  -> AreaInfluenceState
  -> RED strategic planner
  -> action selection
  -> virtual effect or physical mission
  -> MOOSE-native tasking/spawn where available
  -> DCS event collection
  -> campaign consequence
```

Nicht Bestandteil der Grundversion:

```text
FactionState[]
FactionRelations
FactionDiplomacy
FactionConflict
separate faction logistics
separate faction commanders
```

Vor eigener Lua-Logik sind passende MOOSE-FSM-, OPS-, AUFTRAG-, INTEL-, DETECTION-, ZONE-, SPAWN- und Event-Funktionen zu prüfen.

## 20. Priorisierte Umsetzung

### Stufe 1 – einfaches Grundkonzept

1. einen `REDState` definieren;
2. HQ, Depots, Hide Sites und Forward Caches führen;
3. kleine lokale Zellen aus einem gemeinsamen Pool erzeugen;
4. folgende Kernaktionen umsetzen:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

5. Erfolg, Verlust, Rückzug und Ressourcenverbrauch zurückschreiben;
6. keine zwecklosen Spawns;
7. jede Aktion isoliert testen.

### Stufe 2 – einfache Einflusswirkungen

- Hold-Präsenz;
- Reinfiltrationswahrscheinlichkeit;
- Route Influence;
- Cache-Regeneration;
- begrenzte Rekrutierung;
- begrenzte HUMINT-/Informanteneffekte;
- lokaler Druck und Passivität.

### Stufe 3 – erweiterte Aktionen

- gezielte Tötung;
- Infiltration;
- Entführung;
- Feint und mehrstufiger Angriff;
- komplexe Angriffe;
- Schattenjustiz;
- Propaganda.

### Stufe 4 – optionale Mehrfraktionssimulation

Nur nach:

- stabiler Grundversion;
- belastbarer Persistenz;
- getesteten Kernaktionen;
- nachgewiesenem spielmechanischem Mehrwert;
- ausdrücklicher Projektinhaberfreigabe;
- eigenem Architektur- und Acceptance-Strang.

Bis dahin bleibt Stufe 4 zurückgestellt.

## 21. Abnahmekriterien

Die RED-Grundversion gilt erst als integriert, wenn:

- genau ein RED Commander existiert;
- genau ein gemeinsamer Ressourcenpool existiert;
- keine verdeckten Fraktionspools vorhanden sind;
- jeder physische Spawn Ursprung, Auftrag und Ressourcenverbrauch besitzt;
- Rückzug und Dispersal funktionieren;
- `REINFILTRATE_SECTOR` nach unzureichendem Hold reproduzierbar funktioniert;
- IED-, Hinterhalt- und Probe-Aktionen reproduzierbar getestet sind;
- keine pauschale Zielauswahl nach Ethnie, Religion oder ziviler Objektkategorie erfolgt;
- MOOSE-First dokumentiert ist;
- DCS-Testfälle und erwartete Logmeldungen vorliegen;
- Mehrfraktionsfunktionen nur nach neuer ausdrücklicher Freigabe eingeführt werden.
