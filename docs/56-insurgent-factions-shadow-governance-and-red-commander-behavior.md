---
document_id: OMW-RED-INSURGENT-FACTIONS-BEHAVIOR
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical insurgent behavior model for OMW mission and campaign design
  - consolidated single-opponent RED Commander baseline for the initial implementation
  - historically grounded RED goals, action types, constraints and campaign metrics
  - use of route influence, caches, intimidation, recruitment and shadow governance as campaign effects
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

# Insurgentisches Verhalten und konsolidierter RED Commander

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

## 2. Zweck

Dieses Dokument beschreibt:

- Ziele und Prioritäten des Gegners;
- Aufbau und Nutzung von Caches, Hide Sites und lokalen Zellen;
- Verhalten unter BLUE-Druck;
- Auswahl virtueller und physischer Aktionen;
- Einfluss auf Bevölkerung, Verwaltung und Verkehrswege;
- geeignete CampaignState-Zustände und Messgrößen;
- einen stufenweisen, bewusst einfachen Implementierungsplan.

Der frühere [`OMW-RED-DIRECTOR`](06-red-director.md) bleibt als ersetzter historischer Entwurf erhalten. Die technische Umsetzung muss aus dieser Designreferenz, [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md), MOOSE-First und gesonderter DCS-Acceptance abgeleitet werden.

## 3. Quellen und Grenzen

### 3.1 International Crisis Group – *The Insurgency in Afghanistan's Heartland*, 2011

**Datei:** `Group-STATEPLAY-2011.pdf`

Höchste Relevanz für den zentral-östlichen Raum. Die Studie behandelt:

- Schattenverwaltungen;
- lokale Zellen und Kommandeure;
- Rekrutierung und Einschüchterung;
- Finanzierung und Besteuerung;
- Safehouses und Waffenlager;
- Infiltration;
- IED-, Hinterhalts- und komplexe Angriffsmuster;
- historische Unterschiede und Konkurrenz zwischen insurgenten Organisationen.

Grenzen:

- regionaler Fokus;
- viele interviewbasierte Aussagen;
- lokale Schätzungen sind nicht landesweit übertragbar;
- die historische Existenz mehrerer Gruppen verpflichtet OMW nicht zu einer Mehrfraktionssimulation.

### 3.2 Exum/Fick/Humayun/Kilcullen – *Triage*, 2009

Vorperiodische Strategie- und COIN-Referenz zu Bevölkerungsschutz, Momentum, Priorisierung und Erschöpfungsstrategie. Keine neutrale Ereignischronik und keine Ist-ORBAT für 2010/2011.

### 3.3 Rainer Glatz – *ISAF Lessons Learned: A German Perspective*, 2011

Zeitgenössische Fachperspektive auf HUMINT, Comprehensive Approach, nationale Caveats, Endstate und Messgrößen. Keine vollständige amtliche ISAF-Doktrin.

### 3.4 James M. Dubik – *Accelerating Combat Power in Afghanistan*, 2009

Vorperiodische Referenz für ANSF-Kampfkraft, Ausbildung, Führung, Partnerschaft und Abhängigkeit von Combat Multipliers. Zielgrößen sind keine automatisch erreichten Iststärken.

### 3.5 Khalatbari/Kazim – *Afghanistan and Pakistan – A Paradigm Shift?*, 2010

Sekundäranalyse zu Sicherheitslage, Korruption, Drogenökonomie und Pakistanbezug. Die genannte Schätzung von ungefähr 35.000 Taliban-Fußkämpfern und 900 Kommandeuren ist nur `SECONDARY_ESTIMATE`, keine Spawnzahl oder Bestandsbaseline.

### 3.6 Weitere Hintergrundquellen

Armajani 2021, Berdal 2016 und Noev/Ullman 2010 liefern historischen beziehungsweise strategischen Kontext, aber keine taktische ORBAT oder Runtime-Autorität.

## 4. Historische Vielfalt als optionale Verhaltensprofile

Die Grundversion verwendet keine getrennten Fraktionen. Quellenunterschiede dürfen nur als optionale Aktionsprofile gespeichert werden:

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

Für Laghman nennt die Crisis Group als lokales Beispiel ungefähr 23 kleine Gruppen mit jeweils etwa zehn bis dreißig Kämpfern und insgesamt ungefähr 400 Männern.

Für OMW folgt daraus nur:

```text
mehrere kleine örtliche Zellen
+ begrenzte gemeinsame Koordination
+ temporäre Zusammenfassung für ausgewählte Aktionen
```

Die Zahlen sind keine allgemeine Provinzformel.

## 6. AreaInfluenceState

Jeder relevante Ort, Distrikt oder Routensektor kann getrennte Einflusswerte besitzen:

```yaml
area_state:
  armed_presence: 0..100
  intimidation: 0..100
  population_support: 0..100
  population_passivity: 0..100
  government_legitimacy: 0..100
  government_security_presence: 0..100
  route_control: 0..100
  recruitment_access: 0..100
  intelligence_penetration: 0..100
  cache_network: 0..100
  shadow_governance: 0..100
```

Nicht auf einen einzigen `control`-Wert reduzieren. Zu trennen sind insbesondere:

- Zustimmung;
- Duldung aus Angst;
- bewaffnete Präsenz;
- Nachtbewegungsfreiheit;
- Cache- und Informantenzugang;
- Einfluss auf Verwaltung oder Justiz.

Sichtbare Zusammenfassung:

```text
ABSENT
LATENT
INFLUENCING
CONTESTED
SHADOW_GOVERNANCE
DOMINANT
```

Für das erste lauffähige System dürfen zunächst nur `armed_presence`, `route_control`, `cache_network` und `pressure_level` umgesetzt werden.

## 7. Ziele des RED Commanders

### 7.1 Überleben

- Führung und Kader erhalten;
- Kräfte bei Überlegenheit des Gegners aufteilen;
- Caches und Hide Sites schützen;
- Kontakt abbrechen statt bis zur Vernichtung zu kämpfen.

### 7.2 Bewegungsfreiheit begrenzen

- Routen beobachten;
- IEDs und Hinterhalte vorbereiten;
- Checkpoints und Außenposten binden;
- Convoys verzögern oder zu Umwegen zwingen.

### 7.3 Ressourcen sichern

- Caches und Nachschubwege erhalten;
- Rekrutierungs- und Finanzierungsmöglichkeiten schützen;
- Verluste regenerieren.

### 7.4 Bevölkerung und Regierung beeinflussen

- Informanten einschüchtern;
- staatliche Legitimität schwächen;
- lokale Beschwerden ausnutzen;
- später optional Schattenjustiz und Abgabenerhebung simulieren.

### 7.5 Koalition erschöpfen

- Reaktionskräfte binden;
- dauerhafte Unsicherheit erzeugen;
- politische und psychologische Kosten erhöhen;
- nicht zwingend Gelände dauerhaft halten.

## 8. Aktionsportfolio

Gesamtes quellenbasiertes Portfolio:

```text
RECRUIT_LOCAL_CELL
INTIMIDATE_COMMUNITY
PUNISH_INFORMANT
BUILD_CACHE
ESTABLISH_HIDE_SITE
MOVE_CADRE
OBSERVE_ROUTE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
CONDUCT_COMPLEX_AMBUSH
PROBE_CHECKPOINT
DISRUPT_ROUTE
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

Nicht jede Aktion benötigt eine physische DCS-Gruppe. Rekrutierung, Einschüchterung, Infiltration, Propaganda und Schattenherrschaft sind primär CampaignState-Ereignisse.

## 9. Prioritätslogik

### 9.1 Route mit hohem Nutzwert

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

- Zellen verkleinern;
- Führungs- und Cache-Standorte verlegen;
- offene Sammelpunkte vermeiden;
- Kontakt abbrechen;
- später regenerieren.

### 9.3 Schwache lokale Regierung

Später können priorisiert werden:

```text
RECRUIT_LOCAL_CELL
INTIMIDATE_COMMUNITY
ESTABLISH_SHADOW_OFFICIAL
RUN_SHADOW_COURT
COLLECT_TAX_OR_EXTORTION
```

Diese Funktionen sind keine Voraussetzung für die erste RED-Version.

### 9.4 Komplexer Angriff

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

## 10. Taktische Muster

### 10.1 IED und Hinterhalt

1. Route beobachten;
2. Routine erkennen;
3. Cache oder IED vorbereiten;
4. ausgewähltes Ziel angreifen;
5. kleine Feuer- oder Beobachtungskomponente einsetzen;
6. rasch lösen;
7. Reaktion auswerten.

Nicht jede IED-Aktion benötigt einen bis zum Tod kämpfenden Trupp.

### 10.2 Checkpoint Probe

- Annäherungswege testen;
- Reaktionszeit messen;
- Feuerpositionen oder tote Winkel erkennen;
- ohne unnötige Verluste abbrechen;
- Informationen für spätere Aktion speichern.

### 10.3 Dispersal

Bei gegnerischer Überlegenheit:

- Kräfte teilen;
- Waffen verstecken;
- Cache oder Hide Site wechseln;
- benachbarte Sektoren nutzen;
- später in neuer Zusammensetzung zurückkehren.

### 10.4 Komplexer Angriff

Mögliche Elemente:

- mehrere Angriffsteile;
- IED oder Fahrzeugbombe;
- vorbereitete Waffenlager;
- zeitliche Staffelung;
- Angriff auf symbolische oder hochwertige Ziele.

Diese Aktionsklasse ist selten und wird erst nach Stabilisierung der Kernfunktionen umgesetzt.

## 11. Rekrutierung und Bevölkerung

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

> Ethnie, Religion oder Wohnort allein erzeugen keine feindliche Zugehörigkeit.

## 12. Geschützte zivile Objekte

Moscheen, Schulen, medizinische Einrichtungen und andere zivile Objekte bleiben grundsätzlich geschützt.

- Kategorie oder Standort allein ist keine feindliche Signatur;
- militärische Nutzung muss nachrichten- und ereignisbasiert festgestellt werden;
- NSL, ROE, Positive Identification und Kollateralschadensprüfung bleiben vollständig wirksam;
- verdeckte Nutzung ist ein Intelligence-Problem, keine pauschale Zielklasse.

## 13. Infiltration und Intelligence

Mögliche RED-Effekte:

```text
checkpoint_warning
patrol_route_leak
false_target_report
insider_access
weapons_cache_survival
attack_timing_bonus
```

Mögliche BLUE-Gegenmaßnahmen:

```text
vetting
counterintelligence
source_validation
randomized_routes
cache_search
force_protection
```

Technische ISR-Sensoren allein decken das Netzwerk nicht vollständig auf. RECCE, HUMINT, Pattern-of-Life und Quellenvalidierung bleiben erforderlich.

## 14. Erfolgsmessung

RED-Erfolg ist nicht nur zerstörtes BLUE-Material.

Mögliche RED-Metriken:

- Routen nur unter höherem Aufwand nutzbar;
- Cache-Netz überlebt;
- lokale Zellen können regenerieren;
- Informanten werden eingeschüchtert;
- BLUE bindet überproportional viele Kräfte;
- psychologische Wirkung wird erzielt;
- Führung und externe Unterstützung bleiben funktionsfähig.

BLUE-/Campaign-Metriken:

- sichere Straßennutzung;
- freiwillige Meldungen;
- sinkende Einschüchterung;
- stabile lokale Verwaltung;
- dauerhafte Sicherheit statt kurzfristiger Präsenz;
- ANSF-Readiness;
- zivile Schäden und Fehlidentifikationen.

```text
BLUE_KILLS != BLUE_SUCCESS
TERRAIN_OCCUPIED != LEGITIMATE_CONTROL
```

## 15. Kampagnenphasen

```text
PREPARE
INFILTRATE
SHAPE
OFFENSIVE
EXPLOIT
DISPERSE
RECOVER
```

Der eine RED Commander kann in unterschiedlichen Sektoren gleichzeitig verschiedene Phasen führen. Dafür sind keine getrennten Fraktionen nötig.

## 16. Technische Zielarchitektur

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

## 17. Priorisierte Umsetzung

### Stufe 1 – einfaches Grundkonzept

1. einen `REDState` definieren;
2. HQ, Depots, Hide Sites und Forward Caches führen;
3. kleine lokale Zellen aus einem gemeinsamen Pool erzeugen;
4. ausschließlich folgende Kernaktionen umsetzen:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
```

5. Erfolg, Verlust, Rückzug und Ressourcenverbrauch zurückschreiben;
6. keine zwecklosen Spawns;
7. jede Aktion isoliert testen.

### Stufe 2 – einfache Einflusswirkungen

- Route Influence;
- Cache-Regeneration;
- begrenzte Rekrutierung;
- begrenzte HUMINT-/Informanteneffekte;
- lokaler Druck und Passivität.

### Stufe 3 – erweiterte Aktionen

- gezielte Tötung;
- Infiltration;
- Entführung;
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

## 18. Abnahmekriterien

Die RED-Grundversion gilt erst als integriert, wenn:

- genau ein RED Commander existiert;
- genau ein gemeinsamer Ressourcenpool existiert;
- keine verdeckten Fraktionspools vorhanden sind;
- jeder physische Spawn Ursprung, Auftrag und Ressourcenverbrauch besitzt;
- Rückzug und Dispersal funktionieren;
- IED-, Hinterhalt- und Probe-Aktionen reproduzierbar getestet sind;
- keine pauschale Zielauswahl nach Ethnie, Religion oder ziviler Objektkategorie erfolgt;
- MOOSE-First dokumentiert ist;
- DCS-Testfälle und erwartete Logmeldungen vorliegen;
- Mehrfraktionsfunktionen nur nach neuer ausdrücklicher Freigabe eingeführt werden.
