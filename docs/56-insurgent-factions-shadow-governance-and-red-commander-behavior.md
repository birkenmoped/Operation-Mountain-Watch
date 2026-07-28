---
document_id: OMW-RED-INSURGENT-FECTIONS-BEHAVIOR
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical insurgent behavior model for OMW mission and campaign design
  - consolidated single-opponent RED Commander baseline for the initial implementation
  - historically grounded RED Commander goals, action types, constraints and metrics
  - use of shadow governance, intimidation, recruitment and route influence as campaign effects
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

## 1. Zweck und verbindliche Grundentscheidung

Dieses Dokument überführt die Afghanistan-Quellen in ein quellenkritisches Verhaltensmodell für die rote Seite. Es beschreibt:

- welche Ziele der Gegner verfolgt;
- wie er Einfluss aufbaut und erhält;
- wann er offen kämpft und wann er ausweicht;
- wie er Bevölkerung, Verwaltung, Verkehrswege und Sicherheitskräfte beeinflusst;
- welche virtuellen und physischen Aktionen ein dynamischer RED Commander erzeugen darf;
- welche Zustände und Messgrößen für die persistente Kampagne benötigt werden.

### 1.1 MVP-Entscheidung: ein Gegner, ein Commander

Für die erste funktionsfähige Kampagnenbaseline gilt verbindlich:

```text
1 konsolidierter RED Commander
1 gemeinsamer RED-Ressourcenpool
1 gemeinsames Einfluss- und Netzwerkmodell
keine getrennten Fraktionskommandeure
keine Fraktionsbeziehungen
keine parallelen Taliban-/Haqqani-/HiG-Bestände
```

Der technische und spielmechanische Gegner wird zunächst als:

```text
INSURGENT_NETWORK
```

geführt.

Historische Unterschiede zwischen Taliban, Haqqani-Netzwerk, Hizb-e Islami und lokalen bewaffneten oder kriminellen Netzwerken bleiben als **Quellenwissen und optionale Verhaltensprofile** erhalten. Sie erzeugen in der Grundversion jedoch keine eigenständigen Gegner, Ressourcenpools, Führungsstrukturen oder Spawnlogiken.

Die Mehrfraktionssimulation ist:

```text
DEFERRED_MULTIFACTION_EXTENSION
```

und darf erst nach einer ausdrücklich genehmigten späteren Projektphase eingeführt werden, wenn der einfache RED Commander stabil funktioniert und reproduzierbar getestet ist.

### 1.2 Autoritätsgrenze

Der frühere [`OMW-RED-DIRECTOR`](06-red-director.md) bleibt als ersetzter historischer Entwurf erhalten. Die technische Umsetzung muss aus dieser Designreferenz, [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md), MOOSE-First und gesonderter DCS-Acceptance abgeleitet werden.

Dieses Dokument begründet Verhalten und Datenmodell. Es ist keine technische Acceptance und keine Freigabe für eine sofortige Vollsimulation aller beschriebenen Effekte.

## 2. Quellen und quellenkritische Einordnung

### 2.1 International Crisis Group – *The Insurgency in Afghanistan's Heartland*, 2011

**Datei:** `Group-STATEPLAY-2011.pdf`

**Wert:** höchste Relevanz für RED-Verhalten innerhalb des OMW-Zeitraums.

Die Studie untersucht sieben zentral-östliche Provinzen und beschreibt Taliban, Haqqani-Netzwerk und Hekmatyars Hizb-e Islami als getrennte, teilweise kooperierende und teilweise konkurrierende Akteure. Sie behandelt Schattenverwaltungen, Rekrutierung, Mobilisierung, Finanzierung, territoriale Rivalitäten, Infiltration und Anschlagsmuster.

**Grenzen:**

- regionaler Fokus; keine landesweite ORBAT;
- viele Aussagen beruhen auf Interviews mit Regierungs-, Sicherheits- und ehemaligen Aufständischen;
- lokale Schätzungen dürfen nicht auf ganz Afghanistan hochgerechnet werden;
- benannte Personen, Netzwerke und Zustände sind zeitgebunden;
- die historische Existenz mehrerer Gruppen verpflichtet OMW nicht zu einer Mehrfraktionssimulation in der Grundversion.

### 2.2 Exum/Fick/Humayun/Kilcullen – *Triage*, 2009

**Datei:** `Exum-Triage-2009.pdf`

**Wert:** strategische Vorperiodenreferenz für Bevölkerungskontrolle, Momentum, Priorisierung und die Aufstandsstrategie der Erschöpfung.

**Grenzen:**

- Juni 2009, vor dem OMW-Hauptzeitraum;
- policy-orientierte Empfehlung, keine neutrale Ereignischronik;
- Truppen- und ANSF-Zahlen gelten nur für den jeweils genannten Stichtag.

### 2.3 Rainer Glatz – *ISAF Lessons Learned: A German Perspective*, 2011

**Datei:** `GLATZ-ISAFLessonsLearned-2011.pdf`

**Wert:** zeitgenössische professionelle Perspektive auf Comprehensive Approach, COIN-Intelligence, HUMINT, nationale Caveats, Momentum, Endstate und Messgrößen.

**Grenzen:** persönliche fachliche Auffassung des Autors; keine vollständige amtliche ISAF-Doktrin oder ORBAT.

### 2.4 James M. Dubik – *Accelerating Combat Power in Afghanistan*, 2009

**Datei:** `Dubik-ACCELERATINGCOMBATPOWER-2009.pdf`

**Wert:** Aufbau von ANSF-Kampfkraft, Training Throughput, Partnerschaft, Vertrauen, Minimum-Essential-Equipment und Abhängigkeit von NATO-Combat-Multipliers.

**Grenzen:** Empfehlung vor dem OMW-Zeitraum; teilweise aus Irak-Erfahrungen übertragen; Zielgrößen sind Planungsannahmen, keine automatisch erreichten Iststärken.

### 2.5 Khalatbari/Kazim – *Afghanistan and Pakistan – A Paradigm Shift?*, 2010

**Datei:** `Khalatbari-AfghanistanPakistan-2010.pdf`

**Wert:** zeitgenössischer Überblick über Sicherheitsverschlechterung, Korruption, Drogenökonomie, regionale Spannungen und Pakistanbezug.

**Grenzen:** Sekundäranalyse mit teils pauschalen oder schwer nachprüfbaren Zahlen. Die genannte Schätzung von ungefähr 35.000 Taliban-Fußkämpfern und 900 Kommandeuren ist als `SECONDARY_ESTIMATE` zu führen, nicht als exakter OMW-Gesamtbestand oder Spawnzahl.

### 2.6 Jon Armajani – *The Taliban*, 2021

**Datei:** `Armajani-Taliban-2021.pdf`

**Wert:** historische Entwicklung, Pakistan/ISI, Madrasah-Netzwerke, Proxy-Politik, Hizb-e Islami und langfristige organisatorisch-ideologische Hintergründe.

**Grenzen:** retrospektiv, thematisch breit und deutlich post-periodisch; keine Stichtagsquelle für 2010/2011, keine taktische ORBAT.

### 2.7 Berdal – *A Mission Too Far?*, 2016

**Datei:** `Berdal-MissionFar-2016.pdf`

**Wert:** kritische Rückschau auf Strategie, Surge, Transition, politische Zeitvorgaben, Bündnisfragmentierung und begrenzte Wirksamkeit intensiver Kill/Capture-Kampagnen.

**Grenzen:** post-periodische strategische Interpretation, keine taktische Einheiten- oder Basenreferenz.

### 2.8 Noev/Ullman – *Afghanistan, Pakistan and NATO's Strategic Concept*, 2010

**Datei:** `Noev-AfghanistanPakistanNATOs-2010.pdf`

**Wert:** Hintergrund zu NATO-Kohäsion, expeditionärer Fähigkeit, hybriden Bedrohungen und politischem Risiko eines Scheiterns.

**Grenzen:** strategischer Policy Brief; kaum direkt verwertbare Einheiten-, Basen- oder Taktikdaten.

## 3. Historische Vielfalt ohne Mehrfraktionssimulation

Die Quellen zeigen unterschiedliche insurgente Organisationen und lokale Netzwerke. Für die Grundversion werden diese Unterschiede nicht als getrennte Gegner simuliert, sondern als optionale Herkunfts- oder Fähigkeitsmerkmale einzelner Operationen.

Zulässige Quellen-Tags ohne eigene Runtime-Autorität:

```text
SOURCE_PROFILE_GENERAL_TALIBAN_STYLE
SOURCE_PROFILE_HIGH_COMPLEXITY_NETWORK
SOURCE_PROFILE_LOCAL_INSURGENT_OR_CRIMINAL
SOURCE_PROFILE_HIZB_E_ISLAMI_CONTEXT
```

Diese Tags dürfen beeinflussen:

- zulässige Aktionskomplexität;
- erforderliche Vorbereitung;
- Reichweite einer Zelle;
- Operationssicherheit;
- Fähigkeit zu Safehouse-, Cache- oder Infiltrationsnutzung;
- erwartete psychologische Wirkung.

Sie dürfen in der Grundversion **nicht** erzeugen:

- getrennte Commander;
- getrennte Bestände;
- Fraktionskrieg;
- Diplomatie- oder Relationssimulation;
- Doppelbesteuerung oder Konkurrenzereignisse als eigenes Subsystem;
- zusätzliche RED-Spawns ohne CampaignState-Herkunft.

## 4. Konsolidierter RED-Zustand

Der RED Commander besitzt zunächst einen gemeinsamen Zustand:

```yaml
red_state:
  leadership_cohesion: 0..100
  manpower_pool: 0..100
  finance: 0..100
  local_legitimacy: 0..100
  fear_imposed: 0..100
  intelligence_access: 0..100
  cache_capacity: 0..100
  mobility: 0..100
  external_support: 0..100
  operational_security: 0..100
  attack_cell_capacity: 0..100
  logistics_capacity: 0..100
  pressure_level: 0..100
```

Diese Werte sind abstrakte Kampagnenkapazitäten. Sie entsprechen keiner landesweiten Kopfzahl und werden nicht direkt in DCS-Gruppen umgerechnet.

### 4.1 Lokale Zellstruktur

Für Laghman nennt die Crisis Group als lokale Schätzung ungefähr 23 kleine Taliban-Gruppen mit jeweils etwa zehn bis dreißig Kämpfern und insgesamt ungefähr 400 Männern.

Für OMW folgt daraus nur das Strukturprinzip:

```text
mehrere kleine, örtlich gebundene Gruppen
+ begrenzte gemeinsame Koordination
+ temporäre Zusammenfassung für ausgewählte Aktionen
```

Die Zahl 400 ist keine allgemeine Distrikt- oder Provinzformel und keine automatische Spawnstärke.

## 5. Einfluss- statt Frontlinienmodell

Jeder relevante Distrikt, Ort oder Routensektor kann getrennte Einflusswerte besitzen:

```yaml
area_state:
  armed_presence: 0..100
  shadow_governance: 0..100
  intimidation: 0..100
  population_support: 0..100
  population_passivity: 0..100
  government_legitimacy: 0..100
  government_security_presence: 0..100
  route_control: 0..100
  finance_access: 0..100
  recruitment_access: 0..100
  intelligence_penetration: 0..100
  cache_network: 0..100
```

Diese Werte dürfen nicht auf einen einzigen `control`-Wert reduziert werden. Insbesondere sind zu trennen:

- echte Zustimmung;
- passive Duldung aus Angst;
- bewaffnete Präsenz;
- Fähigkeit, nachts zu handeln;
- Fähigkeit, Streit zu schlichten oder Abgaben einzuziehen;
- Fähigkeit, Regierung oder Sicherheitskräfte zu infiltrieren.

Eine mögliche sichtbare Zustandsleiter lautet:

```text
ABSENT
LATENT
INFLUENCING
CONTESTED
SHADOW_GOVERNANCE
DOMINANT
```

Der sichtbare Zustand ist nur eine Zusammenfassung; die einzelnen Dimensionen bleiben erhalten.

## 6. Ziele des RED Commanders

Der RED Commander priorisiert nicht ausschließlich Vernichtung oder Geländegewinn.

### 6.1 Überleben und Operationssicherheit

- Führung und Kader erhalten;
- Zellen auflösen oder verlegen;
- Cache- und Safehouse-Netz schützen;
- bei Überlegenheit des Gegners Kontakt vermeiden;
- nach Verlusten regenerieren statt sofort erneut anzugreifen.

### 6.2 Einfluss und Schattenherrschaft

- Schattenfunktionäre einsetzen;
- Streitigkeiten schlichten oder kontrollieren;
- Abgaben erheben;
- staatliche Autorität verdrängen oder delegitimieren.

### 6.3 Bevölkerung kontrollieren

- Zustimmung gewinnen;
- Passivität durch Einschüchterung erzeugen;
- Informanten bestrafen;
- lokale Beschwerden instrumentalisieren.

### 6.4 Koalition und Regierung erschöpfen

- dauerhafte Unsicherheit erzeugen;
- politische und mediale Kosten erhöhen;
- Reaktionskräfte binden;
- westliche öffentliche Unterstützung schwächen.

### 6.5 Bewegungsfreiheit begrenzen

- MSR/ASR mit IED, Hinterhalten oder Beobachtung bedrohen;
- Checkpoints und Außenposten isolieren;
- Nachtbewegung und lokale Logistik dominieren.

### 6.6 Ressourcen sichern

- Schutzgeld, Steuern, Entführung, Schmuggel und lokale Wirtschaftszugänge;
- Kontrolle von Straßen, Grenzräumen oder wertvollen Gütern;
- externe Unterstützung und Rückzugsräume erhalten.

### 6.7 Hochwertige psychologische Effekte

- sichtbare Regierungs-, Sicherheits- oder internationale Ziele angreifen;
- spektakuläre, aber zeitlich begrenzte Wirkung erzeugen;
- Unsicherheit in vermeintlich sicheren Räumen demonstrieren.

## 7. Aktionsportfolio der Grundversion

Der RED Commander wählt aus einem gemeinsamen Portfolio:

```text
RECRUIT_LOCAL_CELL
INTIMIDATE_COMMUNITY
PUNISH_INFORMANT
ESTABLISH_SHADOW_OFFICIAL
RUN_SHADOW_COURT
COLLECT_TAX_OR_EXTORTION
BUILD_CACHE
ESTABLISH_SAFEHOUSE
MOVE_CADRE
INFILTRATE_SECURITY_OR_GOVERNMENT
COLLUDE_WITH_OFFICIAL
OBSERVE_ROUTE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
CONDUCT_COMPLEX_AMBUSH
CONDUCT_TARGETED_ASSASSINATION
CONDUCT_KIDNAPPING
CONDUCT_HIGH_PROFILE_COMPLEX_ATTACK
PROBE_CHECKPOINT
DISRUPT_ROUTE
DEFEND_RESOURCE_OR_ROUTE
DISPERSE_UNDER_PRESSURE
REMOTE_REGROUP
PROPAGANDA_EXPLOIT_EVENT
NEGOTIATE_OR_FEIGN_RECONCILIATION
```

Nicht jede Aktion benötigt eine physische DCS-Gruppe. Schattenverwaltung, Rekrutierung, Finanzierung, Propaganda, Infiltration und Kollusion sind CampaignState-Ereignisse. Erst wenn eine Aktion in die physische Welt übergeht, wird eine passende Gruppe, Route oder Mission erzeugt.

Für die MVP-Implementierung müssen nicht alle Aktionen gleichzeitig umgesetzt werden. Der priorisierte Kernumfang steht in Abschnitt 17.

## 8. Prioritätslogik

### 8.1 Schwache Regierung und fehlende Justiz

Wenn `government_legitimacy` und `government_security_presence` niedrig sind, werden wahrscheinlicher:

```text
RUN_SHADOW_COURT
ESTABLISH_SHADOW_OFFICIAL
COLLECT_TAX_OR_EXTORTION
RECRUIT_LOCAL_CELL
```

Ein sofortiger Großangriff ist in diesem Zustand nicht automatisch die beste RED-Entscheidung.

### 8.2 Hoher Verkehrs- oder Logistikwert

Wenn eine Route stark genutzt und nur begrenzt gesichert ist, werden priorisiert:

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
CONDUCT_KIDNAPPING
COLLECT_TAX_OR_EXTORTION
```

Der Erfolg ist nicht nur ein zerstörter Konvoi, sondern auch:

- Verzögerung;
- Routenwechsel;
- zusätzliche Sicherungskräfte;
- sinkende lokale Bewegungsfreiheit;
- höherer logistischer Aufwand.

### 8.3 Hoher militärischer Druck

Bei hoher ISR-, SOF-, Ground- und Air-Presence:

- Zellen verkleinern;
- Führung verlegen;
- offene Sammelpunkte vermeiden;
- Waffen in Caches lagern;
- Informanten suchen;
- indirekte oder psychologische Ziele wählen;
- auf eine spätere Gelegenheit warten.

Der Gegner darf nicht unrealistisch immer bis zur Vernichtung kämpfen.

### 8.4 Zivile Schäden oder fehlerhafte Operationen

Erleidet die Bevölkerung zivile Schäden, ungerechtfertigte Festnahmen oder wiederholte Eingriffe, können steigen:

```text
recruitment_access
population_passivity
propaganda_opportunity
intelligence_access
```

Die Wirkung ist nicht automatisch echte Unterstützung. Angst, Wut, Opportunismus und Schutzsuche bleiben getrennt.

### 8.5 Hochwertiges Ziel und komplexe Angriffsfähigkeit

Ein hochkomplexer Angriff wird nur erwogen, wenn mehrere Voraussetzungen erfüllt sind:

```yaml
requirements:
  intelligence_access: high
  cache_or_safehouse: available
  trained_attack_cell: available
  operational_security: sufficient
  target_value: high
  expected_psychological_effect: high
  pressure_level: acceptable
```

Damit wird verhindert, dass komplexe Anschläge zufällig und ohne Vorbereitung erscheinen.

Die Herkunft einer solchen Fähigkeit kann in Quellenmetadaten mit einem historischen Profil versehen werden. Runtime-seitig bleibt es jedoch eine Aktion desselben konsolidierten RED Commanders.

## 9. Rekrutierungs- und Mobilisierungsfaktoren

Die Quellen nennen keine einzige universelle Motivation. Für OMW sind mindestens folgende Faktoren zu berücksichtigen:

- fehlende Sicherheit und schwache staatliche Präsenz;
- Korruption und Straflosigkeit;
- politische oder wirtschaftliche Ausgrenzung;
- Arbeitslosigkeit und fehlende soziale Perspektiven;
- lokale Land- und Wasserstreitigkeiten;
- gebrochene Amnestie-, Sicherheits- oder Landversprechen;
- Belästigung oder Erpressung durch staatliche Stellen;
- zivile Opfer und als ungerecht empfundene Nachtoperationen;
- persönliche Rache und Ehrverletzung;
- lokale Fraktions- und Stammeskonflikte;
- religiöse Mobilisierung und Propaganda;
- Zwang, Drohung und Schutzsuche.

Verbindliche Modellregel:

> Ethnie, Religion oder Wohnort allein erzeugen keine feindliche Zugehörigkeit.

Sie können Kontext liefern, dürfen aber niemals als deterministischer Rekrutierungs- oder Zielparameter dienen.

## 10. Moscheen, Mullahs und Madrasas

Die Quellen beschreiben religiöse Netzwerke als mögliche Räume für Rekrutierung, Nachrichtenzugang, Mobilisierung und in einzelnen belegten Fällen Waffenlagerung.

Für OMW gilt dennoch:

- Moscheen und Bildungseinrichtungen bleiben grundsätzlich zivile beziehungsweise geschützte Objekte;
- ihre bloße Existenz oder Kategorie ist keine feindliche Signatur;
- eine militärische Nutzung muss ereignis- und nachrichtenbasiert festgestellt werden;
- No-Strike-List, ROE, Positive Identification und Kollateralschadensprüfung bleiben vollständig wirksam;
- verdeckte Nutzung kann als Intelligence-/Investigation-Problem modelliert werden, nicht als pauschale Zielklasse.

## 11. Infiltration, Kollusion und Informationskrieg

Die Quellen zeigen, dass erfolgreiche Angriffe teilweise erleichtert wurden durch:

- korrupte Funktionäre;
- kolludierende Sicherheitskräfte;
- eingeschleuste Personen;
- lokale Informanten;
- falsche oder manipulierte Zielinformationen;
- Waffenlager und Safehouses in urbanen Räumen.

Der RED Commander kann deshalb eine nichtphysische Fähigkeit `SECURITY_PENETRATION` besitzen. Mögliche Effekte:

```text
checkpoint_warning
patrol_route_leak
false_target_report
insider_access
weapons_cache_survival
attack_timing_bonus
prisoner_or_detainee_information
```

BLUE/ANSF benötigt eine Gegenlinie:

```text
vetting
counterintelligence
source_validation
randomized_routes
cache_search
force_protection
```

## 12. Taktische Muster

### 12.1 IED und Hinterhalt

Historisch plausible Kombination:

1. Beobachtung und Routinenlernen;
2. Vorbereitung eines Cache oder IED;
3. Auslösung gegen ausgewähltes Ziel;
4. kleine direkte Feuerkomponente oder Beobachter;
5. rasches Lösen vom Feind;
6. Propaganda oder Ausnutzung der Reaktion.

Nicht jede IED-Aktion benötigt einen anschließend bis zum Tod kämpfenden Trupp.

### 12.2 Komplexer Angriff

Komplexe Angriffe können kombinieren:

- mehrere Angreifer;
- Selbstmordkomponente;
- Fahrzeugbombe oder ferngezündete Bombe;
- vorbereitete Waffenlager;
- Angriff auf Sicherheitskräfte, Regierungsstellen oder symbolische Ziele;
- zeitliche Staffelung, um Reaktionskräfte zu binden.

Diese Aktionsklasse ist selten, vorbereitungsintensiv und für die Grundversion nicht zwingend erforderlich. Sie kann nach Stabilisierung der Kernaktionen ergänzt werden.

### 12.3 Gezielte Tötung und Einschüchterung

Ziele können sein:

- lokale Regierungsvertreter;
- Polizei- oder NDS-Personal;
- Informanten;
- religiöse oder gesellschaftliche Gegner;
- lokale Machtkonkurrenten.

Der Effekt ist häufig größer als der unmittelbare materielle Schaden, weil er Kooperation mit Regierung und Koalition abschrecken soll.

### 12.4 Dispersal und Rückzug

Bei gegnerischer Überlegenheit:

- Kontakt abbrechen;
- Kräfte in Kleingruppen teilen;
- Waffen verstecken;
- in benachbarte Distrikte oder externe Rückzugsräume verlegen;
- später mit neuer Zusammensetzung zurückkehren.

Zivile Räume werden nicht automatisch als Deckung missbraucht. Eine solche Nutzung darf nur bei konkret modellierter Netzwerkfähigkeit und unter vollständiger ROE-/NSL-Beachtung dargestellt werden.

## 13. BLUE- und ANSF-Gegenwirkungen

### 13.1 Bevölkerungsschutz und Legitimität

Für die Kampagne gilt:

```text
BLUE_KILLS != BLUE_SUCCESS
TERRAIN_OCCUPIED != LEGITIMATE_CONTROL
```

Erfolg misst sich unter anderem an:

- wahrgenommener Sicherheit;
- Bewegungsfreiheit;
- funktionierender Verwaltung;
- freiwilliger Informationsweitergabe;
- sinkender Einschüchterung;
- dauerhaft nutzbaren Verkehrswegen.

### 13.2 Intelligence

Im COIN-Umfeld sind erforderlich:

- HUMINT und lokale Informationsgewinnung;
- zeitnahe Analyse auf taktischer Ebene;
- Sprach-, Regional-, Sozial-, Wirtschafts-, Rechts- und Politikkompetenz;
- Verbindung zwischen Collectors, Analysten, Targeting und Operators;
- organisationsübergreifendes Information Sharing.

ISR-Sensoren allein decken den RED Commander nicht vollständig auf. Technische Aufklärung muss mit RECCE, HUMINT, Pattern-of-Life und Quellenvalidierung verbunden werden.

### 13.3 ANSF-Kampfkraft

Nominelle Stärke ist nicht identisch mit nutzbarer Kampfkraft. Relevante Faktoren:

```yaml
ansf_readiness:
  present_strength: 0..100
  training: 0..100
  leadership: 0..100
  cohesion: 0..100
  logistics: 0..100
  coalition_partner_access: 0..100
  medevac_access: 0..100
  fire_support_access: 0..100
  corruption_risk: 0..100
  infiltration_risk: 0..100
```

Dieses Modell ist unabhängig von der Entscheidung, RED zunächst als einen konsolidierten Gegner zu führen.

## 14. Messgrößen des RED Commanders

Der RED Commander bewertet Erfolg nicht nur anhand vernichteter Einheiten.

### 14.1 Primäre RED-Metriken

- Bevölkerung hat Angst, mit Regierung/ISAF zusammenzuarbeiten;
- Schattenjustiz wird häufiger genutzt;
- Abgaben können eingezogen werden;
- Nachtbewegung und lokale Bewegungsfreiheit bleiben erhalten;
- wichtige Routen werden verzögert oder nur unter hohem Aufwand genutzt;
- Informanten- und Cache-Netz überlebt;
- Rekrutierungszugang bleibt erhalten;
- Regierung verliert Legitimität;
- Koalition bindet überproportional viele Kräfte;
- hochrangige Anschläge erzeugen psychologische oder politische Wirkung;
- Führung und externe Unterstützung bleiben funktionsfähig.

### 14.2 Primäre BLUE-/Campaign-Metriken

- subjektive Sicherheit der Bevölkerung;
- freiwillige Meldungen und Hinweise;
- sichere Nutzung von Straßen und Märkten;
- funktionsfähige lokale Verwaltung und Justiz;
- reduzierte Einschüchterung;
- ANSF-Fähigkeit, Aufgaben mit sinkender Unterstützung zu übernehmen;
- geringere Infiltration und Korruption;
- dauerhafte statt nur kurzfristige Präsenz;
- zivile Schäden und Fehlidentifikationen;
- klare, messbare Endstates statt bloßer Aktivitätszahlen.

## 15. Jahreszeit, Kampagnen und Momentum

Die Quellen belegen saisonal benannte Offensiven und eine starke Bedeutung von Momentum. Daraus darf kein starrer Kalenderautomat entstehen. Wetter, Gelände, lokale Ernte- und Bewegungsbedingungen, Führungslage, Verluste, Finanzierung und BLUE-Druck müssen einbezogen werden.

Eine mögliche Kampagnenphase lautet:

```text
PREPARE
INFILTRATE
SHAPE
OFFENSIVE
EXPLOIT
DISPERSE
RECOVER
```

Der konsolidierte RED Commander kann in einem Distrikt `OFFENSIVE` und gleichzeitig in einem anderen `DISPERSE` sein. Dafür sind keine getrennten Fraktionen erforderlich.

## 16. Nicht zulässige Vereinfachungen

Folgende Modelle sind ausdrücklich zu vermeiden:

- jeder Paschtune oder jeder konservative Distrikt ist Taliban;
- jede Moschee oder Madrasa ist ein feindliches Objekt;
- hohe Kill-Zahl reduziert automatisch Aufstandsunterstützung;
- ein eroberter Ort bleibt ohne dauerhafte Sicherheit und Governance unter BLUE-Kontrolle;
- jede entdeckte RED-Gruppe kämpft bis zur Vernichtung;
- landesweite Kämpferzahlen werden unmittelbar in DCS-Spawns übersetzt;
- Korruption oder Kriminalität ist immer zentral vom RED Commander gesteuert;
- ein ziviler Schaden erzeugt stets denselben linearen Effekt;
- ein erfolgreicher Angriff beweist automatisch breite lokale Unterstützung;
- historische Organisationsvielfalt wird ohne operativen Nutzen sofort als komplexe Mehrfraktionssimulation umgesetzt.

## 17. Technische Zielarchitektur der Grundversion

Die Implementierung soll MOOSE-First und CampaignState-basiert erfolgen:

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

Vor eigener Lua-Logik ist zu prüfen, welche MOOSE-FSM-, OPS-, AUFTRAG-, INTEL-, DETECTION-, ZONE-, SPAWN- und Event-Funktionen die jeweilige Teilaufgabe bereits abbilden.

## 18. Priorisierte MVP-Umsetzung

### Stufe 1 – einfaches funktionsfähiges Grundkonzept

1. einen `REDState` definieren;
2. RED-Hauptquartier, Depots, Hide Sites und Forward Caches als Netzwerk führen;
3. kleine lokale Zellen aus einem gemeinsamen Ressourcenpool erzeugen;
4. zunächst nur folgende physische Kernaktionen umsetzen:
   - `OBSERVE_ROUTE`;
   - `BUILD_CACHE`;
   - `CONDUCT_IED_ATTACK`;
   - `CONDUCT_AMBUSH`;
   - `PROBE_CHECKPOINT`;
   - `DISPERSE_UNDER_PRESSURE`;
5. Erfolg, Verlust, Rückzug und Ressourcenverbrauch in CampaignState zurückschreiben;
6. keine zufälligen oder zwecklosen Spawns;
7. jede Aktionsklasse isoliert in DCS testen.

### Stufe 2 – einfache virtuelle Einflusswirkungen

Nach stabiler Stufe 1:

- Rekrutierung;
- Einschüchterung;
- Cache-Regeneration;
- Route Influence;
- begrenzte HUMINT-/Informanteneffekte;
- lokale Legitimitäts- und Passivitätswerte.

### Stufe 3 – erweiterte Aktionen

Erst nach stabiler Stufe 2:

- gezielte Tötung;
- Infiltration;
- Entführung;
- komplexe Angriffe;
- Schattenjustiz und Abgabenerhebung;
- Propaganda- und psychologische Effekte.

### Stufe 4 – optionale Mehrfraktionssimulation

Die historische Trennung von Taliban, Haqqani, Hizb-e Islami und lokalen Netzwerken kann später als Zusatzsimulation geprüft werden. Voraussetzungen:

- Grundsystem läuft stabil;
- CampaignState und Persistenz sind belastbar;
- RED-Kernaktionen sind getestet;
- klare spielmechanische Vorteile gegenüber zusätzlicher Komplexität sind nachgewiesen;
- ausdrückliche Freigabe des Projektinhabers liegt vor;
- eigener Architektur-, MOOSE-First- und Acceptance-Strang wird angelegt.

Bis dahin bleibt Stufe 4 zurückgestellt.

## 19. Abnahmekriterien

Die RED-Grundversion gilt erst als integriert, wenn:

- genau ein konsolidierter RED Commander existiert;
- keine verdeckte Doppelzählung durch Fraktionspools entsteht;
- jeder physische Spawn einen Ursprung, Auftrag und Ressourcenverbrauch besitzt;
- Rückzug statt Vernichtung möglich und getestet ist;
- IED-, Hinterhalt- und Dispersal-Aktionen reproduzierbar funktionieren;
- virtuelle Effekte keine unerklärten physischen Kräfte erzeugen;
- NSL, ROE und zivile Schutzregeln eingehalten werden;
- MOOSE-First-Prüfung dokumentiert ist;
- DCS-Testfälle mit erwarteten Logmeldungen vorliegen;
- keine Änderung der aktiven ORBAT oder Produktionsfreigabe ohne Projektinhaberentscheidung erfolgt.
