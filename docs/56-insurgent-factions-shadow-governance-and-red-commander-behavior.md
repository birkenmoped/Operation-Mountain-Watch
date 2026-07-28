---
document_id: OMW-RED-INSURGENT-FACTIONS-BEHAVIOR
status: BINDING
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical insurgent faction model for OMW mission and campaign design
  - historically grounded RED commander goals, action types, constraints and metrics
  - separation of Taliban, Haqqani network, Hizb-e Islami and criminal or local power networks
  - use of shadow governance, intimidation, recruitment and route influence as campaign effects
not_authoritative_for:
  - exact nationwide insurgent strength
  - deterministic behavior based on ethnicity, religion or province alone
  - target authorization against religious, educational or civilian locations
  - active runtime implementation or DCS/MOOSE acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-RED-DIRECTOR as current behavioral design authority
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Insurgentengruppen, Schattenherrschaft und Verhalten des RED Commanders

## 1. Zweck

Dieses Dokument überführt die neu bereitgestellten Afghanistan-Quellen in ein quellenkritisches Verhaltensmodell für die rote Seite. Es beantwortet nicht nur die Frage, **welche bewaffneten Gruppen vorhanden waren**, sondern vor allem:

- welche Ziele sie verfolgten;
- wie sie Einfluss aufbauten und erhielten;
- wann sie offen kämpften und wann sie auswichen;
- wie sie Bevölkerung, Verwaltung, Verkehrswege und Sicherheitskräfte beeinflussten;
- wie Kooperation, Konkurrenz und persönliche Rivalitäten zwischen Gruppen wirkten;
- welche Effekte ein dynamischer OMW-RED-Commander statt bloßer zufälliger Spawns abbilden sollte.

Der frühere [`OMW-RED-DIRECTOR`](06-red-director.md) bleibt als ersetzter historischer Entwurf erhalten. Die technische Umsetzung muss aus dieser Designreferenz, [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md), MOOSE-First und gesonderter DCS-Acceptance abgeleitet werden.

## 2. Quellen und quellenkritische Einordnung

### 2.1 International Crisis Group – *The Insurgency in Afghanistan's Heartland*, 2011

**Datei:** `Group-STATEPLAY-2011.pdf`

**Wert:** höchste Relevanz für RED-Verhalten innerhalb des OMW-Zeitraums.

Die Studie untersucht sieben zentral-östliche Provinzen und beschreibt Taliban, Haqqani-Netzwerk und Hekmatyars Hizb-e Islami als getrennte, teilweise kooperierende und teilweise konkurrierende Akteure. Sie behandelt Schattenverwaltungen, Rekrutierung, Mobilisierung, Finanzierung, territoriale Rivalitäten, Infiltration und Anschlagsmuster.

**Grenzen:**

- regionaler Fokus; keine landesweite ORBAT;
- viele Aussagen beruhen auf Interviews mit Regierungs-, Sicherheits- und ehemaligen Aufständischen;
- lokale Schätzungen dürfen nicht auf ganz Afghanistan hochgerechnet werden;
- benannte Personen, Netzwerke und Zustände sind zeitgebunden.

### 2.2 Exum/Fick/Humayun/Kilcullen – *Triage*, 2009

**Datei:** `Exum-Triage-2009.pdf`

**Wert:** strategische Vorperiodenreferenz für Bevölkerungskontrolle, Momentum, „ink blot/oil spot“, Priorisierung und die Taliban-Strategie der Erschöpfung.

**Grenzen:**

- Juni 2009, also vor dem OMW-Hauptzeitraum;
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

**Grenzen:** Sekundäranalyse mit teils pauschalen oder schwer nachprüfbaren Zahlen. Die genannte Schätzung von ungefähr 35.000 Taliban-Fußkämpfern und 900 Kommandeuren ist als `SECONDARY_ESTIMATE` zu führen, nicht als exakter OMW-Gesamtbestand.

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

## 3. Grundentscheidung: RED ist kein einheitlicher Gegner

Ein einzelner allwissender „Taliban Commander“ wäre historisch und spielmechanisch falsch. Der RED Commander muss mindestens drei Hauptfraktionen und zusätzliche lokale Netzwerke getrennt führen:

```text
TALIBAN_QUETTA_ALIGNED
HAQQANI_NETWORK
HIZB_E_ISLAMI_GULBUDDIN
LOCAL_INSURGENT_OR_CRIMINAL_NETWORK
```

Optional können regionale Untertypen angelegt werden, aber nur wenn Quellen oder Missionsdesign einen konkreten Unterschied rechtfertigen.

Jede Fraktion besitzt eigene Zustände:

```yaml
faction_state:
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
  relations:
    TALIBAN_QUETTA_ALIGNED: -100..100
    HAQQANI_NETWORK: -100..100
    HIZB_E_ISLAMI_GULBUDDIN: -100..100
```

Die Relationen sind dynamisch. Kooperation gegen gemeinsame Ziele kann gleichzeitig mit Konkurrenz um Straßen, Entführungs- oder Finanzierungsräume bestehen.

## 4. Historisch belegte regionale Organisationsmuster

### 4.1 Zentral-östlicher Raum

Die Crisis Group beschreibt im Umfeld Kabuls drei parallel wirksame Hauptakteure:

- Taliban;
- Haqqani-Netzwerk;
- Hizb-e Islami Gulbuddin.

Im Mai 2011 bestanden in 35 von 62 untersuchten Distrikten durch die Quetta Shura eingesetzte Taliban-Schatten-Gouverneure. Diese Strukturen erhoben Abgaben, schlichteten Streitigkeiten und setzten lokale militärische Kommandeure ein.

Daraus folgt: **Einfluss ist nicht gleich physische Besetzung.** Ein Distrikt kann tagsüber von Regierungskräften patrouilliert werden und zugleich nachts oder sozial durch eine Schattenverwaltung beeinflusst sein.

### 4.2 Laghman als lokales Größenbeispiel

Für Laghman nennt die Quelle eine Schätzung von ungefähr 23 kleinen Taliban-Gruppen mit jeweils etwa zehn bis dreißig Kämpfern und insgesamt ungefähr 400 Männern. Dies ist ein brauchbares Beispiel für ein zellulares Regionalmodell.

Es ist ausdrücklich **keine** landesweite Standardstärke. Für OMW darf daraus lediglich abgeleitet werden:

```text
mehrere kleine, örtlich gebundene Gruppen
+ gemeinsame politische/militärische Koordination
+ begrenzte, aber kombinierbare Kräfte
```

### 4.3 Kabul und hochrangige Ziele

In und um Kabul waren Aufständische zahlen- und feuerkraftmäßig unterlegen. Die Crisis Group beschreibt deshalb ein Ziel, die Hauptstadt nicht zwingend physisch zu erobern, sondern psychologisch unhaltbar erscheinen zu lassen.

Der RED Commander benötigt folglich einen Unterschied zwischen:

```text
TERRITORIAL_CAPTURE
PSYCHOLOGICAL_EFFECT
```

Ein komplexer Anschlag, der zeitweise Medienwirkung, Unsicherheit und politische Kosten erzeugt, kann aus RED-Sicht erfolgreicher sein als ein verlustreicher Versuch, Gelände zu halten.

## 5. Fraktionsprofile

### 5.1 Taliban / Quetta-Shura-nahe Strukturen

Typische Fähigkeiten und Schwerpunkte:

- robustere politische und militärische Befehlskette als viele lokale Gruppen;
- Schatten-Gouverneure, Schatten-Gerichte und lokale Kommandeursbestellung;
- Einbindung lokaler religiöser, sozialer und früherer Mudschaheddin-Netzwerke;
- Rekrutierung über lokale Konflikte, Schutzversprechen, Ideologie und Zwang;
- territoriale Einflussbildung vom Dorf bis zum Distrikt;
- Kampagnenrahmen und Propaganda, beispielsweise Al-Faath/Victory 2010 und Badr 2011;
- IED, Hinterhalt, Einschüchterung, gezielte Tötung und zeitweilige größere Angriffe.

### 5.2 Haqqani-Netzwerk

Typische Fähigkeiten und Schwerpunkte:

- größere Reichweite und Penetration im zentral-östlichen Raum;
- gut ausgebildete Kämpfer und Zugang zu grenzüberschreitenden Rückzugs- und Unterstützungsräumen;
- hochrangige, komplexe und koordinierte Anschläge;
- Nutzung von Safehouses, Waffenlagern und lokalen Unterstützern;
- Bereitstellung von Einrichtungen oder Fähigkeiten für andere Gruppen;
- flexible Verlegung unter Druck, unter anderem über Khost in Richtung Logar/Kabul;
- stärkere Eignung für mehrere Angriffsteile, Selbstmordattentäter, Fahrzeugbomben und vorbereitete Angriffszellen.

Haqqani darf im Spiel nicht einfach als „stärkere Taliban-Infanterie“ abgebildet werden. Der Unterschied liegt vor allem in Netzwerkzugang, Operationssicherheit, Zielauswahl, Komplexität und Reichweite.

### 5.3 Hizb-e Islami Gulbuddin

Typische Fähigkeiten und Schwerpunkte:

- historische lokale Verwurzelung und frühere Dominanz in Teilen des Zentral- und Ostens;
- lokale Kommandeure mit politischen, wirtschaftlichen und persönlichen Netzwerken;
- Kontrolle oder Einfluss auf wichtige Straßenabschnitte;
- wechselnde lokale Kooperationen, auch mit ungewöhnlichen Partnern;
- Konkurrenz mit Taliban und Haqqani um Autorität, Ressourcen und Einfluss;
- Verbindungen in politische oder staatliche Strukturen können je nach Region relevant sein.

### 5.4 Lokale bewaffnete, kriminelle und Macht-Netzwerke

Die Quellen zeigen eine Überlagerung von Aufstand, Korruption, Schmuggel, Entführung, Drogenökonomie und lokalen Machtkämpfen. Nicht jede feindliche Aktivität ist zentral ideologisch gesteuert.

Ein lokales Netzwerk kann:

- zeitweise für Taliban oder HiG arbeiten;
- Informationen verkaufen;
- Schutzgeld erheben;
- Entführungen durchführen;
- eine Straße oder Ressource kontrollieren;
- mit Regierungsvertretern kolludieren;
- sich bei Druck neutral stellen oder die Seite wechseln.

## 6. Einfluss- statt Frontlinienmodell

Jeder relevante Distrikt, Ort oder Routensektor sollte getrennte Einflusswerte besitzen:

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

Diese Werte dürfen nicht auf einen einzigen „control“-Wert reduziert werden. Insbesondere sind zu trennen:

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

## 7. Ziele des RED Commanders

Der RED Commander priorisiert nicht ausschließlich Vernichtung oder Geländegewinn. Historisch plausible Zielklassen sind:

1. **Überleben und Operationssicherheit**
   - Führung und Kader erhalten;
   - Zellen auflösen oder verlegen;
   - Cache- und Safehouse-Netz schützen;
   - bei Überlegenheit des Gegners Kontakt vermeiden.

2. **Einfluss und Schattenherrschaft**
   - lokale Streitbeilegung anbieten oder erzwingen;
   - Schattenfunktionäre einsetzen;
   - Abgaben erheben;
   - staatliche Autorität verdrängen oder delegitimieren.

3. **Bevölkerung kontrollieren**
   - Zustimmung gewinnen;
   - Passivität durch Einschüchterung erzeugen;
   - Informanten bestrafen;
   - lokale Beschwerden instrumentalisieren.

4. **Koalition und Regierung erschöpfen**
   - dauerhafte Unsicherheit erzeugen;
   - politische und mediale Kosten erhöhen;
   - Reaktionskräfte binden;
   - westliche öffentliche Unterstützung schwächen.

5. **Bewegungsfreiheit begrenzen**
   - MSR/ASR mit IED, Hinterhalten oder Beobachtung bedrohen;
   - Checkpoints und Außenposten isolieren;
   - Nachtbewegung und lokale Logistik dominieren.

6. **Ressourcen sichern**
   - Schutzgeld, Steuern, Entführung, Schmuggel und lokale Wirtschaftszugänge;
   - Kontrolle von Straßen, Grenzräumen oder wertvollen Gütern;
   - externe Unterstützung und Rückzugsräume erhalten.

7. **Hochwertige psychologische Effekte**
   - sichtbare Regierungs-, Sicherheits- oder internationale Ziele angreifen;
   - spektakuläre, aber zeitlich begrenzte Wirkung erzeugen;
   - Unsicherheit in vermeintlich sicheren Räumen demonstrieren.

## 8. Aktionsportfolio

Der RED Commander wählt aus einem Portfolio, nicht aus einer einzigen Spawnroutine:

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
CONDUCT_IED_ATTACK
CONDUCT_COMPLEX_AMBUSH
CONDUCT_TARGETED_ASSASSINATION
CONDUCT_KIDNAPPING
CONDUCT_HIGH_PROFILE_COMPLEX_ATTACK
PROBE_CHECKPOINT
DISRUPT_ROUTE
DEFEND_RESOURCE_OR_ROUTE
COOPERATE_WITH_FACTION
COMPETE_WITH_FACTION
ATTACK_RIVAL_FACTION
DISPERSE_UNDER_PRESSURE
CROSS_BORDER_OR_REMOTE_REGROUP
PROPAGANDA_EXPLOIT_EVENT
NEGOTIATE_OR_FEIGN_RECONCILIATION
```

Nicht jede Aktion benötigt eine physische DCS-Gruppe. Schattenverwaltung, Rekrutierung, Finanzierung, Propaganda, Infiltration und Kollusion sind CampaignState-Ereignisse. Erst wenn eine Aktion in die physische Welt übergeht, wird eine passende Gruppe, Route oder Mission erzeugt.

## 9. Prioritätslogik

### 9.1 Schwache Regierung und fehlende Justiz

Wenn `government_legitimacy` und `government_security_presence` niedrig sind:

```text
SHADOW_COURT
SHADOW_OFFICIAL
TAX_OR_EXTORTION
RECRUIT_LOCAL_CELL
```

werden wahrscheinlicher als ein sofortiger Großangriff.

### 9.2 Hoher Verkehrs- oder Logistikwert

Wenn eine Route stark genutzt und nur begrenzt gesichert ist:

```text
OBSERVE_ROUTE
BUILD_CACHE
IED_ATTACK
AMBUSH
KIDNAPPING_OR_EXTORTION
```

werden priorisiert. Der Erfolg ist nicht nur ein zerstörter Konvoi, sondern auch Verzögerung, Routenwechsel, zusätzliche Sicherungskräfte oder sinkende lokale Bewegungsfreiheit.

### 9.3 Hoher militärischer Druck

Bei hoher ISR-, SOF-, Ground- und Air-Presence:

- Zellen verkleinern;
- Führung verlegen;
- offene Sammelpunkte vermeiden;
- Waffen in Caches lagern;
- Informanten suchen;
- indirekte oder psychologische Ziele wählen;
- auf eine spätere Gelegenheit warten.

Der Gegner darf nicht unrealistisch immer bis zur Vernichtung kämpfen.

### 9.4 Zivile Schäden oder fehlerhafte Operationen

Erleidet die Bevölkerung zivile Schäden, ungerechtfertigte Festnahmen oder wiederholte Eingriffe:

```text
recruitment_access += effect
population_passivity += effect
propaganda_opportunity += effect
intelligence_access += possible_effect
```

Die Wirkung ist nicht automatisch echte Unterstützung. Angst, Wut, Opportunismus und Schutzsuche müssen getrennt bleiben.

### 9.5 Fraktionsrivalität

Bei wertvollen Straßen, Entführungsräumen, Finanzierung oder persönlichen Konflikten:

- Kooperation kann sinken;
- konkurrierende Schattenfunktionäre können auftreten;
- Ressourcen können doppelt besteuert werden;
- gezielte Gewalt gegen Rivalen ist möglich;
- gemeinsame Angriffe bleiben dennoch möglich, wenn ein übergeordnetes Ziel attraktiv ist.

### 9.6 Hochwertiges Ziel und Haqqani-Zugang

Ein komplexer Angriff wird nur erwogen, wenn mehrere Voraussetzungen erfüllt sind:

```yaml
requirements:
  intelligence_access: high
  cache_or_safehouse: available
  trained_attack_cell: available
  operational_security: sufficient
  target_value: high
  expected_psychological_effect: high
  exfiltration_required: false|optional
```

Damit wird verhindert, dass hochkomplexe Anschläge zufällig und ohne Vorbereitung erscheinen.

## 10. Rekrutierungs- und Mobilisierungsfaktoren

Die Crisis Group nennt keine einzige universelle Motivation. Für OMW sind mindestens folgende Faktoren zu modellieren:

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

Daraus folgt eine verbindliche Modellregel:

> Ethnie, Religion oder Wohnort allein erzeugen keine feindliche Zugehörigkeit.

Sie können Kontext liefern, dürfen aber niemals als deterministischer Rekrutierungs- oder Zielparameter dienen.

## 11. Moscheen, Mullahs und Madrasas

Die Quellen beschreiben religiöse Netzwerke als mögliche Räume für Rekrutierung, Nachrichtenzugang, Mobilisierung und in einzelnen belegten Fällen Waffenlagerung.

Für OMW gilt dennoch:

- Moscheen und Bildungseinrichtungen bleiben grundsätzlich zivile beziehungsweise geschützte Objekte;
- ihre bloße Existenz oder Kategorie ist keine feindliche Signatur;
- eine militärische Nutzung muss ereignis- und nachrichtenbasiert festgestellt werden;
- No-Strike-List, ROE, Positive Identification und Kollateralschadensprüfung bleiben vollständig wirksam;
- verdeckte Nutzung kann als Intelligence-/Investigation-Problem modelliert werden, nicht als pauschale Zielklasse.

## 12. Infiltration, Kollusion und Informationskrieg

Die Quellen zeigen, dass erfolgreiche Angriffe teilweise durch:

- korrupte Funktionäre;
- kolludierende Sicherheitskräfte;
- eingeschleuste Personen;
- lokale Informanten;
- falsche oder manipulierte Zielinformationen;
- Waffenlager und Safehouses in urbanen Räumen

erleichtert wurden.

Der RED Commander benötigt deshalb eine nichtphysische Fähigkeit `SECURITY_PENETRATION`. Sie kann folgende Effekte auslösen:

```text
checkpoint_warning
patrol_route_leak
false_target_report
insider_access
weapons_cache_survival
attack_timing_bonus
prisoner_or_detainee_information
```

Gleichzeitig muss BLUE/ANSF eine Gegenlinie besitzen:

```text
vetting
counterintelligence
source_validation
randomized_routes
cache_search
force_protection
```

## 13. Taktische Muster

### 13.1 IED und Hinterhalt

Historisch plausible Kombination:

1. Beobachtung und Routinenlernen;
2. Vorbereitung eines Cache oder IED;
3. Auslösung gegen ausgewähltes Ziel;
4. kleine direkte Feuerkomponente oder Beobachter;
5. rasches Lösen vom Feind;
6. Propaganda oder Ausnutzung der Reaktion.

Nicht jede IED-Aktion benötigt einen anschließend bis zum Tod kämpfenden Trupp.

### 13.2 Komplexer Angriff

Komplexe Angriffe können kombinieren:

- mehrere Angreifer;
- Selbstmordkomponente;
- Fahrzeugbombe oder ferngezündete Bombe;
- vorbereitete Waffenlager;
- Angriff auf Sicherheitskräfte, Regierungsstellen oder symbolische Ziele;
- zeitliche Staffelung, um Reaktionskräfte zu binden.

Diese Aktionsklasse ist selten, vorbereitungsintensiv und fraktionsabhängig.

### 13.3 Gezielte Tötung und Einschüchterung

Ziele können sein:

- lokale Regierungsvertreter;
- Polizei- oder NDS-Personal;
- Informanten;
- religiöse oder gesellschaftliche Gegner;
- rivalisierende Kommandeure.

Der Effekt ist häufig größer als der unmittelbare materielle Schaden, weil er Kooperation mit Regierung und Koalition abschrecken soll.

### 13.4 Dispersal und Rückzug

Bei gegnerischer Überlegenheit:

- Kontakt abbrechen;
- Kräfte in Kleingruppen teilen;
- Waffen verstecken;
- zivile Räume nicht automatisch als Deckung missbrauchen, sondern nur bei konkret modellierter Netzwerkfähigkeit;
- in benachbarte Distrikte oder externe Rückzugsräume verlegen;
- später mit neuer Zusammensetzung zurückkehren.

## 14. BLUE- und ANSF-Gegenwirkungen aus den Quellen

### 14.1 Bevölkerungsschutz und Legitimität

Exum et al. argumentieren, dass Bevölkerungsschutz Vorrang vor reinem Terrain- oder Kill-Count-Denken besitzt. Für die Kampagne bedeutet dies:

```text
BLUE_KILLS != BLUE_SUCCESS
TERRAIN_OCCUPIED != LEGITIMATE_CONTROL
```

Erfolg misst sich unter anderem an wahrgenommener Sicherheit, Bewegungsfreiheit, funktionierender Verwaltung und freiwilliger Informationsweitergabe.

### 14.2 Intelligence

Glatz fordert im COIN-Umfeld:

- mehr HUMINT und lokale Informationsgewinnung;
- zeitnahe Analyse auf taktischer Ebene;
- Sprach-, Regional-, Sozial-, Wirtschafts-, Rechts- und Politikkompetenz;
- bessere Verbindung zwischen Collectors, Analysten, Targeting und Operators;
- Verlagerung geeigneter Intelligence-Fähigkeiten bis auf Bataillonsebene;
- organisationsübergreifendes Information Sharing.

Für OMW folgt daraus, dass ISR-Sensoren allein den RED Commander nicht vollständig aufdecken. Technische Aufklärung muss mit RECCE, HUMINT, Pattern-of-Life und Quellenvalidierung verbunden werden.

### 14.3 ANSF-Kampfkraft

Dubik trennt nominelle Stärke von nutzbarer Kampfkraft. Relevante Faktoren sind:

- ausreichende Zahl;
- Ausbildung und Ausrüstung;
- Führung;
- Kohäsion und Vertrauen;
- Partnerschaft mit Koalitionskräften;
- Zugang zu Artillerie, Luftunterstützung, MEDEVAC, Transport und weiteren Combat Multipliers;
- funktionierende Ministerien und Hauptquartiere.

Ein ANSF-Verband darf deshalb nicht nur über eine Anzahl von Gruppen definiert werden. Er benötigt mindestens:

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

## 15. Messgrößen des RED Commanders

Der RED Commander bewertet Erfolg nicht nur anhand vernichteter Einheiten.

### 15.1 Primäre RED-Metriken

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
- Fraktionsführung und externe Unterstützung bleiben funktionsfähig.

### 15.2 Primäre BLUE-/Campaign-Metriken

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

## 16. Jahreszeit, Kampagnen und Momentum

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

Ein Fraktionskommandeur kann in einem Distrikt `OFFENSIVE` und gleichzeitig in einem anderen `DISPERSE` sein.

## 17. Nicht zulässige Vereinfachungen

Folgende Modelle sind ausdrücklich zu vermeiden:

- jeder Paschtune oder jeder konservative Distrikt ist Taliban;
- jede Moschee oder Madrasa ist ein feindliches Objekt;
- Taliban, Haqqani und HiG sind austauschbare Skins derselben KI;
- hohe Kill-Zahl reduziert automatisch Aufstandsunterstützung;
- ein eroberter Ort bleibt ohne dauerhafte Sicherheit und Governance unter BLUE-Kontrolle;
- jede entdeckte RED-Gruppe kämpft bis zur Vernichtung;
- landesweite Kämpferzahlen werden unmittelbar in DCS-Spawns übersetzt;
- Korruption oder Kriminalität ist immer zentral von der Talibanführung gesteuert;
- ein ziviler Schaden erzeugt stets denselben linearen Effekt;
- ein erfolgreicher Angriff beweist automatisch breite lokale Unterstützung.

## 18. Technische Zielarchitektur

Die Implementierung soll MOOSE-First und CampaignState-basiert erfolgen:

```text
FactionState
  -> AreaInfluenceState
  -> RED strategic planner
  -> action selection
  -> virtual effect or physical mission
  -> MOOSE-native tasking/spawn where available
  -> DCS event collection
  -> campaign consequence
```

Vor eigener Lua-Logik ist zu prüfen, welche MOOSE-FSM-, OPS-, AUFTRAG-, INTEL-, DETECTION-, ZONE-, SPAWN- und Event-Funktionen die jeweilige Teilaufgabe bereits abbilden.

Die Quellen begründen das Verhalten und Datenmodell. Sie liefern keine technische Acceptance für eine konkrete MOOSE-Klasse oder Implementierung.

## 19. Priorisierte Umsetzungsschritte

1. `FactionState` und dynamische Beziehungen zwischen Taliban, Haqqani, HiG und lokalen Netzwerken definieren;
2. mehrdimensionale `AreaInfluenceState`-Werte in CampaignState aufnehmen;
3. Aktionsportfolio in virtuelle und physische Aktionen trennen;
4. Route-Control-, Shadow-Governance-, Recruitment- und Intelligence-Penetration-Effekte modellieren;
5. RED-Aktionswahl anhand lokaler Zustände statt reinem Zufall implementieren;
6. seltene komplexe Angriffe an Vorbedingungen und Vorbereitung koppeln;
7. BLUE-/ANSF-Aktionen mit Legitimitäts-, Sicherheits-, Intelligence- und Civilian-Harm-Effekten verbinden;
8. MOOSE-Dokumentation auf vorhandene Klassen/Funktionen prüfen;
9. separaten Teststrang für jede Aktionsklasse anlegen;
10. keine Änderung der aktiven ORBAT und kein Produktionsstatus ohne Projektinhaberfreigabe und DCS-Test.
