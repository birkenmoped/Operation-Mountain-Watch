---
document_id: OMW-SP-LLM-COMMANDERS-SOURCE-INVENTORY
status: DRAFT_RESEARCH_BASELINE
document_class: SOURCE_INVENTORY_AND_ANALYTICAL_BASELINE
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Quelleninventar und vorläufige Fraktionsbaseline

## 1. Zweck

Dieses Dokument erfasst die bereits vorhandene Quellenbasis für drei getrennte RED Commander und bewertet, welche Inhalte unmittelbar verwendbar, nur als Hintergrund geeignet oder noch zu ergänzen sind.

```text
TALIBAN_COMMANDER
HAQQANI_COMMANDER
HIG_COMMANDER
```

Die Bewertung betrifft historische und simulationsbezogene Eignung. Sie erzeugt noch keine Runtime-Parameter und keine endgültigen Persönlichkeitswerte.

## 2. Gemeinsame Hauptquellen aus dem Repository

| Dokument | Hauptnutzen für das Spezialprojekt |
|---|---|
| `OMW-RED-INSURGENT-FACTIONS-BEHAVIOR` | gemeinsame Grundlogik für Zellen, Caches, Einschüchterung, Rekrutierung, Reinfiltration, Shadow Governance und Ressourcenabstraktion |
| `OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM` | Taliban-Kampagnenlogik im Süden, Support-/Attack-Zonen, Clear-Hold-Reinfiltration, Drogen- und Schattenverwaltungsbezüge |
| `OMW-RED-EASTERN-AFGHANISTAN-NETWORK-OPERATIONS` | Haqqani-Sanctuary-, Facilitation-, Staging-, Compartmentation- und Complex-Attack-Modell |
| `OMW-RED-CONTROL-INTELLIGENCE-TTP-COIN-IPB` | lokale Kontrolle, HUMINT, Pattern Learning, Knowledge Decay, TTP-Auswahl und Capability Gates |
| `OMW-RED-LAYEHA-COMMAND-DISCIPLINE-SHADOW-JUSTICE` | Taliban-Führung, Disziplin, lokale Befehlsabweichung, Rivalität, Kriminalität und Shadow Justice |
| `OMW-RED-SIGACT-PATTERNS-2010-08-10` | zeitlich begrenzte historische Aktivitäts- und Ereignismuster |
| `OMW-HIST-SETTING` | verbindlicher Zeitraum und historischer Gesamtrahmen der Quellenbasis |
| `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | CampaignState-, Virtualisierungs- und Materialisierungsprinzipien als technische Referenz, nicht als Spezialprojektbegrenzung |

## 3. Quellenlage Taliban Commander

### 3.1 Quellenstärke

```text
HISTORICAL_DEPTH: HIGH
ORGANIZATIONAL_DEPTH: HIGH
POLITICAL_GOVERNANCE_DEPTH: HIGH
TACTICAL_BEHAVIOR_DEPTH: HIGH
REGIONAL_COVERAGE: MEDIUM_TO_HIGH
PERSONALITY_PROFILE_DEPTH: MEDIUM
```

### 3.2 Direkt nutzbare Quellenfelder

- Quetta-Shura-orientierte strategische Führung;
- Provinz- und Distriktstrukturen;
- Shadow Governors, Shadow Courts und Besteuerung;
- lokale Zellen mit taktischer Autonomie;
- strategischer Anspruch auf Kohäsion bei tatsächlich schwankender Befolgung;
- Bevölkerungskontrolle durch Kombination aus Zugang, Überwachung, Einschüchterung, Sanktion, selektiven Leistungen und Justiz;
- Trennung von echter Unterstützung, passiver Duldung und erzwungener Compliance;
- Nutzung von Informanten, Route Spotters, Markt-, Behörden- und Sicherheitskontakten;
- Lernen wiederkehrender BLUE-Muster;
- Reinfiltration nach sinkendem Druck;
- Disziplinarmaßnahmen gegen kriminelle oder politisch schädliche lokale Kommandeure;
- Konkurrenz um Beute, Steuern, Routen und persönliche Macht.

### 3.3 Vorläufige Commander-These

Der Taliban Commander ist kein taktischer Gefechtsführer für jede Zelle. Er repräsentiert eine strategisch-politische Führung, die versucht, eine heterogene Bewegung durch Zielvorgaben, Ernennungen, Disziplin, Ressourcenverteilung und Legitimitätsanspruch zusammenzuhalten.

```text
PRIMARY_IDENTITY = ALTERNATIVE_GOVERNING_MOVEMENT
PRIMARY_METHOD = POLITICAL_CONTROL_SUPPORTED_BY_INSURGENT_FORCE
PRIMARY_STRENGTH = TERRITORIAL_AND_SOCIAL_PERSISTENCE
PRIMARY_WEAKNESS = LOCAL_NONCOMPLIANCE_AND_INTERNAL_FRICTION
```

### 3.4 Offene Punkte

- Unterschiede zwischen Quetta-Shura-Vorgabe und regionalen Kommissionen präzisieren;
- Personalisierung des Commanders von der realen Person Mullah Omar trennen;
- regional unterschiedliche Taliban-Netzwerke und Mansour-/Harakat-Kontinuitäten einordnen;
- politische, militärische und religiöse Autorität als getrennte Dimensionen modellieren.

## 4. Quellenlage Haqqani Commander

### 4.1 Quellenstärke

```text
HISTORICAL_DEPTH: HIGH
NETWORK_STRUCTURE_DEPTH: HIGH
EXTERNAL_SUPPORT_DEPTH: HIGH
COMPLEX_OPERATION_DEPTH: HIGH
POLITICAL_GOVERNANCE_DEPTH: MEDIUM
PERSONALITY_PROFILE_DEPTH: MEDIUM_TO_HIGH
```

### 4.2 Direkt nutzbare Quellenfelder

- familien- und beziehungsgebundene Führung;
- eigenständige Command-and-Control- und Operationslinien trotz Taliban-Dachbezug;
- North Waziristan/Miramshah als virtueller Sanctuary- und Führungsraum;
- Loya Paktia als historischer Kernraum;
- Border Entry, Transit, Facilitation, Safehaven, Cache, Staging und Target Area als Netzwerkkette;
- Ressourcenaggregation aus lokalen und externen Kanälen;
- hohe Redundanz und Anpassung bei Routendruck;
- Zellen-Compartmentation und begrenzter Schaden bei Kompromittierung einzelner Elemente;
- Zugriff auf technische Spezialisten und externe Kämpfer als Capability, nicht als unbegrenzte Ressource;
- hohe Bedeutung komplexer, psychologisch wirksamer Angriffe;
- Wiederaufbau und Reinfiltration nach Druckabbau;
- mögliche Spannungen mit Taliban-Vertretern bei territorialer Expansion, Geld, Prestige oder lokaler Kontrolle.

### 4.3 Vorläufige Commander-These

Der Haqqani Commander ist ein Netzwerkunternehmer und Capability-Aggregator. Er bevorzugt nicht zwingend dauerhafte Flächenkontrolle, sondern den Erhalt von Zugängen, Vermittlern, Routen, Spezialisten und Staging-Möglichkeiten, aus denen bei Bedarf hochwertige Operationen zusammengesetzt werden können.

```text
PRIMARY_IDENTITY = FAMILY_NETWORK_AND_OPERATIONAL_BROKER
PRIMARY_METHOD = RESOURCE_AGGREGATION_AND_HIGH_COMPLEXITY_OPERATIONS
PRIMARY_STRENGTH = RESILIENCE_REACH_AND_COMPARTMENTATION
PRIMARY_WEAKNESS = DEPENDENCE_ON_KEY_RELATIONSHIPS_AND_FACILITATION_NODES
```

### 4.4 Offene Punkte

- Jalaluddin-Beraterrolle und Siraj-Führungsrolle im Zeitraum quellenkritisch trennen;
- Familienmitglieder, regionale Kommandeure und externe Partner als Rollen statt starre ORBAT modellieren;
- politische Unterordnung unter die Taliban von realer operativer Autonomie trennen;
- lokale Legitimität, Zwang und gekaufte Unterstützung differenzieren.

## 5. Quellenlage HIG Commander

### 5.1 Quellenstärke

```text
HISTORICAL_DEPTH: MEDIUM
ORGANIZATIONAL_DEPTH: MEDIUM
POLITICAL_NETWORK_DEPTH: HIGH
TACTICAL_BEHAVIOR_DEPTH: LOW_TO_MEDIUM
REGIONAL_COVERAGE: MEDIUM
PERSONALITY_PROFILE_DEPTH: MEDIUM
```

### 5.2 Bereits belegte Kernpunkte

Die International-Crisis-Group-Quelle `The Insurgency in Afghanistan's Heartland` liefert die bislang wichtigste HIG-Basis:

- HIG war im zentral-östlichen Raum historisch stark verankert;
- die militärische Befehlskette war bis 2011 geschwächt;
- zahlreiche frühere Kommandeure oder Parteikader waren in staatliche und politische Strukturen übergegangen;
- die militärische Organisation wurde als landesweite Führung mit regionalen, provinziellen und Distriktkommandos beschrieben;
- lokale Distriktkommandeure verfügten über kleine, begrenzte Gefolgschaften;
- HIG hatte gegenüber Taliban und Haqqani geringere militärische Resilienz, aber größere Fähigkeit zu politischen Absprachen;
- Kooperation mit den Taliban war lokal möglich, während strategisches Misstrauen bestehen blieb;
- in Gebieten eigener Stärke kam es zu bewaffneter Konkurrenz, unter anderem um Routen, Steuern und wirtschaftliche Zugänge;
- Verhandlungen, Teilabkommen, Defektionen und widersprüchliche Vertretungsansprüche schwächten die organisatorische Eindeutigkeit;
- politischer und bewaffneter Flügel dürfen weder vollständig gleichgesetzt noch vollständig getrennt angenommen werden.

Ergänzend belegen zeitgenössische Quellen:

- eine eigenständige Identität gegenüber Quetta-Shura-Taliban und Haqqani;
- eine militärische und politische Doppelstruktur;
- Schwerpunktaktivität im Osten und Zentralosten;
- pragmatische lokale Kooperation trotz Rivalität;
- politische Gesprächs- und Waffenstillstandsangebote im Jahr 2010;
- Konflikte mit Taliban-Kräften in Baghlan und Wardak;
- Konkurrenz um Macht und Autorität als wesentliche Bruchlinie.

### 5.3 Vorläufige Commander-These

Der HIG Commander ist kein schwächerer Taliban-Commander. Sein wesentliches Profil ist die Verbindung aus bewaffnetem Druck, historischer Parteiorganisation, persönlichen Netzwerken und politischer Verhandlungsfähigkeit.

```text
PRIMARY_IDENTITY = POLITICAL_MILITARY_FACTION_NETWORK
PRIMARY_METHOD = LOCAL_POWER_BROKERAGE_AND_OPPORTUNISTIC_COERCION
PRIMARY_STRENGTH = POLITICAL_ACCESS_DEALMAKING_AND_LOCAL_NETWORKS
PRIMARY_WEAKNESS = FRAGMENTED_COMMAND_AND_UNCERTAIN_REPRESENTATION
```

### 5.4 Modellierungsfolgen

Der HIG Commander benötigt gegenüber Taliban und Haqqani zusätzliche Parameter:

```yaml
hig_state:
  armed_wing_cohesion: 0..100
  political_wing_access: 0..100
  commander_defection_risk: 0..100
  government_contact_access: 0..100
  negotiation_credibility: 0..100
  representation_clarity: 0..100
  local_patronage: 0..100
  territorial_access: 0..100
  revenue_access: 0..100
  military_resilience: 0..100
  opportunism: 0..100
```

### 5.5 Offene Punkte

- eigenständige HIG-Quellenakte für 2009-2011 erstellen;
- regionale Präsenz nach Kapisa, Laghman, Wardak, Ghazni, Logar, Baghlan und Kabul-Zugängen differenzieren;
- militärische Schwäche nicht mit politischer Bedeutungslosigkeit gleichsetzen;
- Verhältnis zwischen Hekmatyar, bewaffnetem Flügel, legaler Partei und lokalen Kommandeuren spezifizieren;
- Verhandlungs- und Seitenwechselmechanik quellenkritisch abbilden;
- HIG-spezifische TTP nur übernehmen, wenn sie von allgemeinen insurgenten Mustern unterscheidbar belegt sind.

## 6. Vorläufige Vergleichsmatrix

| Dimension | Taliban | Haqqani | HIG |
|---|---|---|---|
| primärer Charakter | alternative Herrschaftsbewegung | familiengebundenes Operationsnetzwerk | politische-militärische Fraktion |
| strategische Reichweite | landesweit | regionaler Kern, überregionale Wirkung | regional konzentriert, politisch vernetzt |
| territoriale Kontrolle | hoch priorisiert | selektiv und funktional | lokal und umkämpft |
| Shadow Governance | sehr hoch | begrenzt bis mittel | lokal unterschiedlich |
| Netzwerk-Compartmentation | mittel | sehr hoch | mittel |
| komplexe Angriffsfähigkeit | mittel bis hoch | sehr hoch | nicht automatisch hoch |
| externe Spezialisten | verfügbar, aber nicht einheitlich | besonders wichtig | quellenabhängig |
| politische Verhandlungsfähigkeit | strategisch kontrolliert | geringer priorisiert | sehr hoch |
| lokale Kommandeursautonomie | hoch bei formaler Hierarchie | hoch innerhalb des Netzwerkauftrags | sehr hoch und fragmentierungsgefährdet |
| wichtigste interne Reibung | Disziplin und lokale Eigeninteressen | Familien-/Netzwerkinteressen und territoriale Expansion | Defektion, Vertretungsstreit und Opportunismus |

## 7. Vorläufiges Beziehungsmodell 2010-2011

### 7.1 Taliban zu Haqqani

```text
FORMAL_ALIGNMENT: HIGH
OPERATIONAL_AUTONOMY: HIGH
LOCAL_COOPERATION: MEDIUM_TO_HIGH
RESOURCE_SEPARATION: HIGH
TERRITORIAL_FRICTION: VARIABLE
PRESTIGE_COMPETITION: MEDIUM
```

### 7.2 Taliban zu HIG

```text
SHARED_ENEMY: HIGH
STRATEGIC_TRUST: LOW
LOCAL_COOPERATION: VARIABLE
TERRITORIAL_COMPETITION: HIGH_IN_OVERLAP_AREAS
REVENUE_COMPETITION: HIGH_IN_SELECTED_DISTRICTS
ARMED_CONFLICT_RISK: MEDIUM_TO_HIGH
```

### 7.3 Haqqani zu HIG

```text
DIRECT_EVIDENCE_DEPTH: LOW_TO_MEDIUM
LOCAL_OVERLAP: PRESENT_IN_CENTRAL_EAST
COOPERATION: POSSIBLE
COMPETITION: POSSIBLE
DEFAULT_RELATIONSHIP: PRAGMATIC_UNCERTAINTY
```

Für Haqqani-HIG darf ohne weitere Quellen keine feste Allianz oder Feindschaft angenommen werden.

## 8. Gemeinsame Wissens- und Informationsgrundlage

Alle drei Commander dürfen lokale Informationsvorteile besitzen, aber keine Omniszienz.

```text
LOCAL_KNOWLEDGE != GLOBAL_TRUTH
OBSERVED_ACTIVITY != CONFIRMED_INTENT
SHARED_OPERATION != SHARED_DATABASE
CAPTURED_CELL != EXPOSED_NETWORK
```

Mindestzustände je Information:

```yaml
knowledge_item:
  subject:
  source_type:
  source_owner:
  reliability: 0..100
  confidence: 0..100
  first_observed:
  last_verified:
  geographic_scope:
  decay_rate:
  deception_risk:
  sharing_restrictions:
```

## 9. Quellenlücken und nächste Recherche

Priorität 1:

- HIG-spezifische Organisations-, Führungs- und Regionalquellen 2009-2011;
- belastbare Taliban-Haqqani-HIG-Beziehungsereignisse je Region;
- politische und bewaffnete HIG-Strukturen getrennt erfassen;
- weitere Primär- oder institutionelle Quellen zur Commander-Autorität und lokalen Befolgung.

Priorität 2:

- Commander-spezifische Persönlichkeitsableitungen;
- regionale Reichweiten und Ressourcenkanäle;
- Auswirkungen von Verhandlungen, Defektionen und interner Konkurrenz;
- Rollen von al-Qaida, ausländischen Kämpfern, kriminellen Netzwerken und lokalen Powerbrokern.

## 10. Vorläufiger Abschluss

Die Quellenbasis reicht aus, um drei klar unterschiedliche Commander zu entwerfen. Sie reicht noch nicht aus, um alle drei mit identischer Detailtiefe zu parametrisieren.

```text
TALIBAN_DOSSIER_READINESS = HIGH
HAQQANI_DOSSIER_READINESS = HIGH
HIG_DOSSIER_READINESS = MEDIUM
INTER_FACTION_MODEL_READINESS = MEDIUM
RUNTIME_RULEBOOK_READINESS = LOW_TO_MEDIUM
```

Als nächster Schritt folgt das gemeinsame Commander-Datenmodell. Danach werden die drei historischen Dossiers getrennt ausgearbeitet.
