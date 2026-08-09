---
document_id: OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical historical network reference for eastern and southeastern Afghanistan
  - source-derived external-support, infiltration, facilitation, staging and complex-attack models
  - high-complexity behavior profile within the single consolidated OMW RED Commander
not_authoritative_for:
  - separate Haqqani runtime faction or additional RED Commander
  - exact insurgent strength, cell count or spawn quantity
  - automatic target selection against civilian, religious, educational or commercial objects
  - active DCS or MOOSE implementation acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: 33b7b3b84349704456b3764fe8725cf9d5b11f3d
validated_in_dcs: false
---

# 58 – Ostafghanistan: Netzwerkoperationen, Infiltration und komplexe Angriffsplanung

## 1. Zweck und verbindliche Grenze

Dieses Dokument erschließt die zuletzt bereitgestellten Haqqani-, Quetta-Shura- und Netzwerkstudien für Operation Mountain Watch. Es ergänzt:

- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md);
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md);
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-MSR-ROUTE-DESIGN`](49-msr-routendesign-und-infrastrukturmarker.md).

Die technische Grundentscheidung bleibt unverändert:

```text
1 RED Commander
1 REDState
1 gemeinsamer Ressourcenpool
1 gemeinsames Standort-, Routen- und Zellnetz
keine eigenständige Haqqani-Fraktion
```

Historische Haqqani-Merkmale werden ausschließlich als:

```text
SOURCE_PROFILE_HIGH_COMPLEXITY_NETWORK
```

geführt. Das Profil kann später Vorbereitung, Reichweite, Operationssicherheit und Angriffskomplexität beeinflussen. Es erzeugt keine zweite Fraktion, keine eigene Logistik und keine zusätzlichen Bestände.

## 2. Quellenregister und Quellenkritik

| ID | Quelle | Datum | Einstufung | Hauptnutzen | Grenze |
|---|---|---:|---|---|---|
| EAN-01 | Jeffrey A. Dressler, *The Haqqani Network: From Pakistan to Afghanistan* | 10.2010 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Organisation, Reconstitution, Loya Paktia, Expansion nach Ghazni/Wardak/Logar/Kabul, Zell- und Angriffsmuster | analytische Advocacy-Quelle; zahlreiche Angaben aus Presse- und ISAF-Berichten |
| EAN-02 | Jeffrey Dressler, *The Irreconcilables: The Haqqani Network* | 28.06.2010 | `POLICY_BACKGROUNDER_IN_PERIOD` | Verbindungen, Sanctuary, Verhandlungs- und Proxy-Kontext | stark wertend; nicht als alleinige Autorität für Absichten oder Verhandelbarkeit verwenden |
| EAN-03 | Jeffrey Dressler und Reza Jan, *The Haqqani Network in Kurram* | 05.2011 | `SECONDARY_ANALYTICAL_IN_PERIOD` | Kurram als Sanctuary-, Transit- und Ausweichraum; Anpassung an Druck | Aussagen zu Absprachen und pakistanischer Unterstützung teilweise berichtsbasiert |
| EAN-04 | Don Rassler und Vahid Brown, *The Haqqani Nexus and the Evolution of al-Qaida* | 14.07.2011 | `ANALYTICAL_IN_PERIOD_WITH_PRIMARY_MATERIAL` | Netzwerkbroker, Ressourcenaggregation, Mehrfachbeziehungen, Resilienz | Autorenansicht; keine offizielle DoD-Position; Schwerpunkt auch auf transnationaler Geschichte |
| EAN-05 | Jeffrey Dressler, *The Haqqani Network: A Strategic Threat* | 03.2012 | `NEAR_PERIOD_RETROSPECTIVE` | detaillierte 2010/2011-Routen, Safehavens, C2-, Staging- und Angriffsmuster | nach OMW-Zeitraum veröffentlicht; Empfehlungen und 2012-Lage nicht rückprojizieren |
| EAN-06 | Marvin G. Weinbaum und Meher Babbar, *The Tenacious, Toxic Haqqani Network* | 09.2016 | `POST_PERIOD_BACKGROUND_ONLY` | Resilienz, Finanzierung und Allianzen als spätere Kontextprüfung | keine 2010/2011-Istlage oder Stärkeautorität |
| EAN-07 | Devin Lurie, *The Haqqani Network: The Shadow Group Supporting the Taliban's Operations* | 09.2020 | `POST_PERIOD_LEAD_ONLY` | spätere Überblicks- und Quellenhinweise | stark sekundär und zeitfremd; keine Stärke- oder Runtime-Autorität |
| EAN-08 | Jeffrey Dressler und Carl Forsberg, *The Quetta Shura Taliban in Southern Afghanistan* | 21.12.2009 | `PRE_PERIOD_ANALYTICAL_BASELINE` | strategische Führung, lokale Ausführung, Schattenverwaltung und gezielte Einflussoperationen | südlicher Schwerpunkt; weitgehend aus älteren Helmand-/Kandahar-Studien kompiliert |

### 2.1 Zeitliche Verwendungsregel

Für EAN-05 werden einzelne Ereignisse, Routen und Zustände aus 2010/2011 als `IN_PERIOD_EVENT_REPORTED_RETROSPECTIVELY` geführt. Bewertungen, Empfehlungen und Folgerungen für 2012 bleiben `POST_PERIOD_CONTEXT`.

EAN-06 und EAN-07 dürfen nur bereits anderweitig belegte Strukturprinzipien stützen. Sie dürfen keine rückwirkenden Bestände, Einheiten, Standorte oder Absichten für 2010/2011 erzeugen.

## 3. Historisches Operationssystem im Osten

Die Quellen beschreiben kein loses Nebeneinander zufälliger Kämpfer, sondern ein System aus externen Sanctuary-Räumen, Grenzübergängen, Facilitation Nodes, Safehavens, Caches, lokalen Kontakten, Staging Areas und Angriffszellen.

Für OMW wird dieses System abstrahiert als:

```text
EXTERNAL_SANCTUARY
→ BORDER_ENTRY
→ TRANSIT_NODE
→ FACILITATION_NODE
→ SAFEHAVEN_OR_CACHE
→ STAGING_AREA
→ TARGET_AREA
```

Nicht jeder Knoten muss physisch in DCS existieren. Außerhalb der spielbaren Karte liegende Sanctuary- und Support-Räume bleiben virtuelle CampaignState-Objekte.

## 4. Externe Sanctuary- und Support-Räume

### 4.1 North Waziristan / Miramshah

EAN-01, EAN-04 und EAN-05 behandeln North Waziristan und Miramshah als zentralen externen Sanctuary-, Führungs-, Trainings- und Ressourcenraum. Daraus werden keine betretbaren OMW-Basen abgeleitet, sondern virtuelle Außenknoten:

```yaml
external_node:
  type: EXTERNAL_SANCTUARY
  location_scope: OFF_MAP
  leadership_access: 0..100
  training_capacity: 0..100
  finance_access: 0..100
  weapons_access: 0..100
  specialist_access: 0..100
  route_options: []
  pressure: 0..100
  disruption: 0..100
```

### 4.2 Kurram / Parachinar

EAN-03 beschreibt Kurram als strategisch wertvollen Ausweich-, Transit- und Sanctuary-Raum mit kurzen Zugängen nach Ostafghanistan und Kabul. Entscheidend für das Design ist nicht eine behauptete dauerhafte Kontrolle, sondern das Anpassungsmuster:

```text
Druck auf Hauptroute
→ alternative Sanctuary- und Transitoption suchen
→ lokale Konflikte oder Absprachen ausnutzen
→ neue Line of Communication öffnen
→ Führung, Kämpfer und Material auf mehrere Wege verteilen
```

OMW darf externe Unterstützung deshalb nicht über genau einen unveränderlichen Eingangsknoten führen.

## 5. Loya Paktia als operatives Tiefensystem

Die Kernräume Khost, Paktia und Paktika werden in den Quellen als zusammenhängendes System aus:

- Border Entry Points;
- Tälern und Pässen;
- Safehavens;
- Facilitation Routes;
- Command-and-Control-Nodes;
- lokalen Verbindungen;
- Caches und temporären Staging Areas

beschrieben.

Für OMW werden folgende historische Beispielräume als Recherche- und Designanker geführt:

```text
Spera
Terayzai
Bak
Sabari
Musa Khel
Zormat
Khost Bowl
```

Diese Namen erzeugen keine automatische Lage, Einheit oder Stärke. Jede konkrete Umsetzung benötigt Location-Registry-Abgleich, DCS-Terrainprüfung und Quellenqualifizierung.

### 5.1 Mazera-Facilitation Route

EAN-05 beschreibt eine aktive Facilitation Route von Terayzai über Bak nach Sabari, in der Quelle als Mazera bezeichnet. Verwertbar ist das funktionale Muster:

```text
Grenznaher Eintritt
→ Tal-/Straßenkorridor
→ Waypoint
→ Verteilung an nördliche Safehavens
→ Weiterleitung von Personal, Waffen und IED-Material
```

Der Routenname und Verlauf sind historische Quellenangaben, keine ohne Georeferenzierung verwendbare DCS-Route.

### 5.2 Spera und Wiederkehr nach Druckabbau

EAN-05 beschreibt, dass ein zuvor unter Druck gesetzter Korridor nach Reduzierung oder Verlagerung von BLUE-Präsenz erneut genutzt wurde. Dies bestätigt für den RED Commander:

```text
ROUTE_DISRUPTED != ROUTE_DESTROYED
NODE_CLOSED != NETWORK_REMOVED
PRESSURE_REDUCED → REASSESS_AND_REOPEN
```

### 5.3 Sabari und Musa Khel

Die Quellen beschreiben:

- Nutzung zerklüfteter Täler und Gebirgszugänge;
- Ausnutzung lokaler Konflikte und schwacher Schutzfähigkeit;
- Kombination aus Einschüchterung, Bestechung, Vermittlung und Zwang;
- Safehaven-, Trainings- und C2-Funktionen;
- gezielte Gewalt gegen mutmaßliche Informanten.

Für OMW wird daraus kein ethnisches oder stammesbezogenes Feindmodell abgeleitet. Relevant sind ausschließlich beobachtbare Zustände:

```yaml
local_access:
  conflict_exploitation: 0..100
  coercion: 0..100
  purchased_access: 0..100
  voluntary_support: 0..100
  protection_gap: 0..100
  informant_risk: 0..100
```

## 6. Operationsachsen Richtung Kabul

EAN-01 und EAN-05 beschreiben mehrere Funktionsachsen:

### 6.1 Südliche und südwestliche Achse

```text
Loya Paktia
→ Ghazni / Logar / Wardak
→ Kabul approaches
→ Staging und Zielraum
```

Logar und Wardak dienen in den Quellen als Facilitation-, Safehaven- und Staging-Räume für Operationen gegen Kabul. Pul-e Alam wird als wichtiger Bereich der Weiterleitung und Vorbereitung genannt.

### 6.2 Östliche und nordöstliche Achse

```text
Kurram / eastern entry
→ Nangarhar
→ Laghman / Sarobi
→ Kapisa / Tagab
→ Kabul oder Nordafghanistan
```

EAN-05 nennt für westliches Nangarhar insbesondere Hisarak, Sherzad, Chaparhar und den Raum Jalalabad als begrenzte Einfluss- und Facilitation-Räume. Diese Angaben sind keine flächendeckende Kontrolle und keine pauschale Feindmarkierung.

### 6.3 Jalalabad als Ziel- und Transitkontext

EAN-05 berichtet für 2011:

- Festnahmen von mehr als einem Dutzend Kämpfern und Facilitators in westlichem Nangarhar;
- Planungs- und Unterstützungsaktivitäten gegen Regierungs- und Sicherheitsziele im Raum Jalalabad;
- einen berichteten Versuch, Flugabwehrlenkwaffen für einen Angriff auf Jalalabad Airfield zu beschaffen;
- den komplexen Angriff auf eine Kabul-Bank-Filiale in Jalalabad am 19. Februar 2011.

Verwendungsgrenzen:

- die Festnahmewerte sind Ereignisangaben, keine Bestandszahl;
- der Flugabwehrwaffen-Vorgang bleibt `SOURCE_REPORTED_ATTEMPT`, nicht OMW-Grundausstattung;
- der Bankangriff ist ein historisches Angriffsmuster, keine Zielautorisierung;
- zivile und kommerzielle Objekte bleiben NSL-/ROE-geschützt.

## 7. Netzwerkrollen statt Fraktionen

EAN-04 beschreibt die besondere Leistungsfähigkeit als Nexus-Funktion: Ein Akteur verbindet lokale, regionale und globale Ressourcen, Beziehungen und Fähigkeiten. Für den konsolidierten RED Commander werden daraus Rollen, nicht Organisationen:

```text
LEADERSHIP_NODE
FINANCE_BROKER
LOGISTICS_FACILITATOR
RECRUITMENT_CHANNEL
TRAINING_CHANNEL
TECHNICAL_SPECIALIST_CHANNEL
TARGET_SURVEILLANCE_CELL
ATTACK_CELL
MEDIA_EXPLOITATION_CHANNEL
LOCAL_ACCESS_BROKER
```

Ein RED-Netzwerkknoten kann mehrere Rollen besitzen. Die Zerstörung einer physischen Gruppe entfernt nicht automatisch die zugrunde liegende Rolle; sie reduziert eine Kapazität, bis Ersatz, Regeneration oder Umleitung erfolgt.

## 8. Ressourcenaggregation und Redundanz

Das Netzwerk kann Ressourcen aus unterschiedlichen abstrakten Kanälen kombinieren:

```yaml
capability_package:
  manpower_source: local_or_external
  leadership: available_or_missing
  target_intelligence: 0..100
  transport_access: 0..100
  weapons_access: 0..100
  explosives_access: 0..100
  specialist_access: 0..100
  safehouse_access: 0..100
  communications_access: 0..100
  media_access: 0..100
```

Verbindlich:

```text
RESOURCE_SOURCE != RUNTIME_FACTION
```

Externe oder spezialisierte Unterstützung erhöht einen gemeinsamen RED-Bestand beziehungsweise eine Capability. Sie erzeugt keine zusätzliche kämpfende Partei.

## 9. Zellstruktur und Compartmentation

EAN-01 berichtet für Kabul ein zonen- und zellbasiertes, compartmentiertes Modell. Die konkrete Zahl von fünfzehn Zonen bleibt `SOURCE_REPORTED_STRUCTURE` und wird nicht als OMW-Vorgabe übernommen.

Abstrakte Regel:

```yaml
cell_security:
  knows_parent_node: true|false
  knows_peer_cells: false_by_default
  knows_route_segment: limited
  knows_target: phase_dependent
  compromise_scope: local|route|network
```

Auswirkung:

- Festnahme oder Verlust einer Zelle deckt nicht automatisch das Gesamtnetz auf;
- Intelligence-Gewinn ist stufenweise;
- höhere Führung kennt mehr Verbindungen, ist aber seltener physisch exponiert;
- wiederholte Beobachtung und Source Correlation sind für Netzwerkerkenntnis erforderlich.

## 10. Angriffsklassen

### 10.1 Begrenzter taktischer Angriff

```text
Route attack
Checkpoint probe
IED attack
Short ambush
Harassment fire
```

Diese Klasse nutzt wenige Ressourcen, kurze Vorbereitung und lokale Intelligence. Sie gehört zur RED-Grundversion, soweit Dokument 56 dies vorsieht.

### 10.2 High-Profile Complex Attack

EAN-01 und EAN-05 beschreiben für Kabul unter anderem:

- vorangehende Zielaufklärung;
- mehrstufige Planung;
- Zuführung von Personal und Waffen;
- Safehouse- und Cache-Nutzung;
- kleine, bewaffnete Angriffsteams;
- kombinierte Angriffsformen;
- Besetzung oder Nutzung eines Gebäudes zur Verlängerung der Reaktion;
- zentrale oder entfernte taktische Beratung;
- anschließende mediale Auswertung.

Die Quellen schildern konkrete Selbstmord- und Fahrzeugbombenangriffe. OMW dokumentiert diese historisch, entwickelt daraus aber keine technische Herstellung, keine reale Angriffsanleitung und keine automatische Mission gegen zivile Ziele.

## 11. Abstrakte Complex-Attack-Pipeline

```text
IDENTIFY_STRATEGIC_EFFECT
→ NOMINATE_TARGET_CATEGORY
→ VALIDATE_INTELLIGENCE
→ SURVEIL_TARGET
→ BUILD_CAPABILITY_PACKAGE
→ SELECT_ROUTE
→ MOVE_RESOURCES
→ ESTABLISH_STAGING
→ FINAL_AUTHORIZATION
→ EXECUTE_MISSION
→ WITHDRAW_OR_TERMINATE
→ EXPLOIT_INFORMATION_EFFECT
```

Zulässige Zustände:

```text
CONCEPT
INTELLIGENCE_GATHERING
ASSEMBLING
TRAINING_OR_PREPARING
MOVING
STAGING
READY
EXECUTING
DISRUPTED
ABORTED
COMPLETE
```

### 11.1 Voraussetzungen

```yaml
complex_attack_requirements:
  strategic_effect: defined
  target_intelligence: high
  operational_security: high
  leadership_access: sufficient
  attack_cell_capacity: high
  route_available: true
  staging_access: true
  logistics_package_complete: true
  expected_psychological_effect: high
  acceptable_network_risk: true
```

Komplexe Angriffe dürfen nicht zufällig oder ausschließlich aufgrund eines Zeitintervalls entstehen.

### 11.2 Disruption Points

BLUE kann die Pipeline unterbrechen durch:

```text
route surveillance
source development
cache discovery
facilitator identification
communications intelligence
staging-area detection
randomized movement patterns
local-official protection
rapid security reaction
```

Ein Teilerfolg kann:

- die Operation verzögern;
- einen Routenwechsel erzwingen;
- den Angriff vereinfachen;
- zum Abbruch führen;
- Intelligence für weitere Missionen erzeugen.

## 12. Psychologische und mediale Wirkung

EAN-05 beschreibt High-Profile-Angriffe als Strategie, mit begrenzten Kräften eine überproportionale Wahrnehmungswirkung zu erzeugen. Für OMW bedeutet dies:

```text
PHYSICAL_DAMAGE != TOTAL_EFFECT
```

Mögliche abstrakte Folgen:

```yaml
information_effect:
  local_fear: delta
  government_legitimacy: delta
  coalition_confidence: delta
  force_protection_cost: delta
  media_attention: delta
  recruitment_effect: delta
```

Diese Werte sind Kampagnenwirkungen und keine realen Propagandatexte.

## 13. Anpassung an BLUE-Druck

Bei anhaltendem Druck priorisiert das Netzwerk:

```text
PRESERVE_LEADERSHIP
COMPARTMENT_CELLS
REDUCE_EXPOSURE
RELOCATE_CACHE
CHANGE_ROUTE
USE_ALTERNATE_ENTRY
DELAY_COMPLEX_ATTACK
REBUILD_FACILITATION
REINFILTRATE_AFTER_PRESSURE_DROPS
```

Entscheidungsregel:

```yaml
if pressure_high and alternate_route_available:
  prefer: CHANGE_ROUTE
elif pressure_high and route_network_degraded:
  prefer: DISPERSE_UNDER_PRESSURE
elif pressure_falls and support_nodes_survive:
  prefer: REINFILTRATE_SECTOR
```

## 14. Zielauswahl und Schutz ziviler Objekte

Quellen berichten über verdeckte Nutzung von Wohnhäusern, Moscheen, Madrassas, Bazaarkorridoren, zivilen Fahrzeugen und kommerziellen Gebäuden. Daraus folgt ausschließlich:

```text
CIVILIAN_CATEGORY != HOSTILE_SIGNATURE
```

Verbindlich:

- konkrete militärische Nutzung muss ereignis- und intelligencebasiert festgestellt werden;
- Standortkategorie allein erzeugt weder RED-Spawn noch BLUE-Ziel;
- NSL, ROE, PID und Kollateralschadensprüfung bleiben wirksam;
- verdächtige Nutzung erzeugt zunächst Intelligence-, Beobachtungs- oder Schutzaufgaben;
- im Zweifel bleibt das Objekt geschützt.

## 15. Stärke und physische Darstellung

Keine der Quellen liefert eine belastbare, zeitgleiche Gesamtstärke für alle relevanten OMW-Sektoren. Genannte Kämpferzahlen, Festnahmen, Zellen oder Netzwerkschätzungen werden nicht addiert.

OMW verwendet:

```text
NETWORK_CAPACITY
ROUTE_CAPACITY
FACILITATION_CAPACITY
ATTACK_CELL_CAPACITY
SPECIALIST_CAPACITY
```

und materialisiert nur Kräfte, die einen nachvollziehbaren Auftrag, Ursprung, Ressourcenverbrauch und Kampagneneffekt besitzen.

## 16. Konsequenz für den RED-MVP

Die sieben Kernaktionen aus Dokument 56 bleiben unverändert:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

Dokument 58 fügt dem MVP keine zweite Fraktion und keinen sofortigen komplexen Angriffsgenerator hinzu. Für Stufe 1 werden lediglich folgende strategische Zustände vorbereitet:

```text
route_available
alternate_route_available
facilitation_capacity
node_compromise
network_pressure
```

Die Complex-Attack-Pipeline gehört zu Stufe 3 und darf erst nach stabiler, getesteter Grundversion umgesetzt werden.

## 17. MOOSE-First und technische Umsetzung

Vor Eigenentwicklung sind insbesondere zu prüfen:

- MOOSE `INTEL`, `DETECTION` und `SET_*` für Erkenntnis und Netzwerkerkennung;
- `ZONE`, `PATHLINE`, `COORDINATE` und Routingfunktionen für Korridore;
- `FSM`, Events und Scheduler für Node- und Pipelinezustände;
- `SPAWN`, `SPAWNSTATIC`, `OPSGROUP`, `ARMYGROUP` und `AUFTRAG` für physische Aktionen;
- `WAREHOUSE` und logistische Klassen nur dort, wo sie das Modell ohne zweite strategische Wahrheit unterstützen.

CampaignState bleibt autoritativ. MOOSE materialisiert und führt aus.

## 18. Abnahmekriterien

Das Modell gilt erst als technisch integriert, wenn:

- genau ein RED Commander und ein Ressourcenpool bestehen;
- externe Sanctuary-Knoten ausschließlich als zulässige CampaignState-Objekte behandelt werden;
- Routenwechsel und Node-Kompromittierung nachvollziehbar persistieren;
- eine kompromittierte Zelle nicht automatisch das Gesamtnetz offenlegt;
- kein ziviles Objekt aufgrund seiner Kategorie zum Ziel wird;
- physische Gruppen einen Ursprung, Auftrag und Ressourcenverbrauch besitzen;
- Complex Attacks erst nach erfüllten Voraussetzungen entstehen;
- Unterbrechung, Abbruch und Verzögerung reproduzierbar getestet sind;
- MOOSE-First und DCS-Acceptance separat dokumentiert sind.
