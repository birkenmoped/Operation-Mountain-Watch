---
document_id: OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION
status: BINDING
document_class: ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState authority and domain boundaries
  - MissionDemand architecture
  - BLUE and RED campaign object model
  - adaptive materialization and intelligence progression
  - single-opponent RED Commander baseline for the initial implementation
  - RED clear-hold-reinfiltration campaign-state transitions
  - persistent-server AI autonomy and player-fallback principles
  - basic settlement influence, support and RED regeneration model
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - incomplete campaign architecture descriptions in legacy foundation documents
superseded_by:
source_branch: agent/campaign-autonomy-influence-balancing
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 37 – Kampagnenarchitektur und dynamisches Missionsdesign

## 1. Zweck und Autorität

Dieses Dokument ist die verbindliche fachliche Produktionsarchitektur für die persistente COIN-Kampagne **Operation Mountain Watch**.

Maßgebliche übergeordnete Regeln:

- [`OMW-GOV-001`](00-project-governance.md) – höchste Projekt-Governance;
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) – vollständiges MOOSE-First- und Ausnahmeverfahren;
- [`OMW-ARCH-SYSTEM`](03-system-architecture.md) – übergeordnete Systemgrenzen;
- [`OMW-RED-INSURGENT-FACTIONS-BEHAVIOR`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md) – RED-Verhaltensreferenz und MVP-Abgrenzung;
- [`OMW-RED-KANDAHAR-HELMAND-ENEMY-SYSTEM`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md) – quellenbasierte Enemy-System-, Clear-Hold- und Reinfiltrationsreferenz.

Der vollständige frühere Architekturtext bleibt unverändert erhalten:

- [`Legacy-Fassung vor Governance-Migration`](evidence/source-records/legacy-37-campaign-architecture-pre-governance.md)

Operation Mountain Watch ist nicht als endliches Szenario mit einem einmalig leerbaren RED-Bestand konzipiert. Für den persistenten Serverbetrieb muss der Konflikt über lange Zeiträume weiterlaufen können. Dauerhaftigkeit entsteht durch nachvollziehbare Ressourcenflüsse, lokale und externe RED-Regeneration, Reinfiltration, wechselnde Schwerpunkte, Versorgung, Einfluss und begrenzte KI-Autonomie. Dauerhaftigkeit darf nicht durch unkausale Respawns, zufällige Angriffe oder das sofortige Rücksetzen von Spielererfolgen erzeugt werden.

## 2. MOOSE-First ist ausschließlich in Dokument 26 definiert

Dieses Dokument formuliert keine verkürzte Parallelregel.

Für jede neue Funktion gilt:

1. passende MOOSE-Klassen, Methoden, FSMs, Events, Sets, Wrapper, OPS-, Routing-, Spawn-, Detection-, Zone-, Warehouse-, AIRWING-, SQUADRON-, AUFTRAG- und Transportfunktionen prüfen;
2. verwendeten MOOSE-Stand und Quellen dokumentieren;
3. eine technische Lücke reproduzierbar nachweisen;
4. nur die kleinstmögliche projektspezifische Ergänzung entwerfen;
5. ausdrückliche Freigabe des Projektinhabers einholen;
6. Ausnahme als ADR oder Acceptance-Entscheidung dokumentieren;
7. Lösung reproduzierbar in DCS testen.

Ohne ausdrückliche Eigentümerfreigabe bleibt eine Nicht-MOOSE- oder Native-DCS-Parallelimplementierung `DRAFT`, `EXPLORATORY` oder `HISTORICAL_TEST_FIXTURE`.

Die in diesem Dokument beschriebenen Einfluss-, Regenerations-, Demand- und Persistenzregeln sind CampaignState-Domänenlogik. Die physische DCS-Ausführung bleibt MOOSE-first.

## 3. CampaignState ist die strategische Wahrheit

`CampaignState` verwaltet insbesondere:

- Basen, FOBs und Standorte;
- Personal, Fahrzeuge und Luftfahrzeuge;
- Treibstoff, Munition und Versorgungsgüter;
- Warehouse-Bestände;
- Verluste, Schäden und Reparaturzustände;
- CSAR-Vorfälle;
- MissionDemand-Objekte;
- RED-Standorte und Logistiknetze;
- Routeneinfluss und Cache-Netze;
- Hold-Präsenz und Reinfiltrationszugang;
- Ortschaftsunterstützung und HUMINT-Zugang;
- lokale Sicherheits-, Kooperations-, Einschüchterungs- und Legitimationswerte;
- RED-Regenerations- und Zuführungsvoraussetzungen;
- Persistenz über Missionsneustarts.

MOOSE und DCS bilden diesen Zustand operativ ab. Sie dürfen nicht parallel einen unabhängigen strategischen Bestand führen.

> CampaignState entscheidet, was existiert, verfügbar ist und strategisch geschieht. MOOSE setzt diese Entscheidungen in der laufenden DCS-Mission um.

Zivile Bevölkerung wird nicht als Daily-Life-Verkehr oder flächendeckende DCS-Zivilpräsenz materialisiert. Gesellschaftliche Größen sind strategische Abstraktionen und werden aus definierten Kampagnenereignissen und Zuständen fortgeschrieben, nicht aus einem permanenten Scan nicht vorhandener Zivilobjekte.

## 4. Keine zwecklosen Spawns

Jede physisch erzeugte Gruppe benötigt:

- einen definierten Ursprung;
- ein definiertes Ziel;
- einen realen Auftrag;
- eine transportierte oder eingesetzte Ressource;
- eine strategische Folge bei Erfolg, Verlust oder Abbruch;
- eine stabile CampaignState- oder MissionDemand-Identität.

Zufällige Gruppen ohne strategische Herkunft oder Rückwirkung sind unzulässig.

Insbesondere unzulässig sind:

```text
player login -> RED attack spawn
fixed timer -> attack without preparation/resources
no combat mission -> artificial resupply mission without demand
CampaignState knows RED site -> BLUE AI attacks without valid intelligence
```

## 5. MissionDemand als einheitliche Auftragsautorität

Ein `MissionDemand` enthält mindestens:

```text
id
missionType
origin
objective
target
priority
playerCapable
aiCapable
reservationState
expiresAt
successCriteria
failureConsequences
resourceReservation
```

Für die spätere Autonomieentscheidung sind zusätzlich mindestens vorzusehen:

```text
autonomyClass
playerOpportunityUntil
aiEligibleAt
```

Vorgesehene Zustände:

```text
OPEN
PLAYER_ASSIGNED
AI_ASSIGNED
ACTIVE
SUCCESS
FAILED
EXPIRED
```

Spieleraufgaben und KI-`AUFTRAG`-Objekte arbeiten auf demselben Bedarf. Eine doppelte Ausführung desselben Bedarfs ist unzulässig.

### 5.1 Spielerpriorität und KI-Fallback

Geeignete MissionDemand-Objekte werden zunächst als Spieleroption angeboten. Bleibt eine zeitkritische oder betriebsnotwendige Aufgabe unbelegt, darf nach der für den Demand definierten Frist KI übernehmen.

Mindestens drei Autonomieklassen sind vorgesehen:

```text
ESSENTIAL
OPERATIONAL
PLAYER_OPPORTUNITY
```

Semantik:

- `ESSENTIAL`: eine KI-Lösung muss bei ausbleibender Spielerübernahme möglich sein, sofern Ressourcen vorhanden sind;
- `OPERATIONAL`: KI darf nach Lage, Priorität und Ressourcen übernehmen;
- `PLAYER_OPPORTUNITY`: bevorzugter Spielerinhalt; KI übernimmt nur bei ausdrücklich definierter Notwendigkeit oder der Bedarf darf verfallen und neu bewertet werden.

Die konkrete Zuordnung von Missionstypen und Fristen ist eine eigene Fachentscheidung und darf nicht stillschweigend aus dieser Architektur abgeleitet werden.

### 5.2 Bedarf vor Mission

MissionDemand entsteht aus einer Ursache. Beispiele:

```text
resource consumption -> reorder threshold -> RESUPPLY demand
RED attack -> defensive support need -> CAS/QRF demand
intelligence indication -> uncertainty -> RECON demand
HUMINT lead -> target development -> SURVEILLANCE/PATROL demand
isolated FOB -> sustainment risk -> convoy/airlift demand
```

Ein fehlender aktueller Kampfauftrag ist kein ausreichender Grund für die Erzeugung eines beliebigen Auftrags.

## 6. BLUE-Struktur

### 6.1 Luftoperationen

- `COMMANDER` für übergeordnete Zuweisung;
- `AIRWING` pro relevantem Flugplatz oder Luftoperationsknoten;
- `SQUADRON` pro Muster, Rolle oder Bestand;
- `AUFTRAG` für KI-Missionen;
- `PLAYERTASK` beziehungsweise MissionDemand-Zuordnung für Spieler;
- `WAREHOUSE` für operative Bestandsabbildung, nicht als zweite strategische Wahrheit.

Aktive ORBAT und Client-Grenzen stehen ausschließlich in Dokument 19.

Der BLUE-CHIEF/COMMANDER ist für persistenten Serverbetrieb ausdrücklich als Fallback erforderlich. Seine Autonomie dient dem Aufrechterhalten des Betriebs, nicht dem autonomen Gewinnen der Kampagne.

Ohne Spieler darf BLUE insbesondere notwendige Verteidigung, QRF, CAS bei realem Bedarf, ISR, CSAR-Fallbacks, Patrouillen, Route Security sowie bedarfsgetriebene Logistik ausführen, soweit die jeweilige Fach- und MOOSE-Baseline dies zulässt.

BLUE-KI darf keine RED-Ziele allein aus CampaignState-Meta-Wissen angreifen. Offensive Zielentwicklung bleibt an gültige BLUE-Intelligence-Stufen, ROE und MissionDemand gebunden.

### 6.2 FOBs und Bodentruppen

FOBs sind persistente Kampagnenobjekte mit Personal, Fahrzeugen, Warehouse, Treibstoff, Munition, Bereitschaft, Fähigkeiten und zugeordneten Verbänden.

Die operative Abbildung erfolgt vorrangig über:

- `BRIGADE`;
- `PLATOON`;
- `ARMYGROUP`;
- `OPSGROUP`;
- `OPSTRANSPORT`;
- `CTLD`.

Strategisch relevante nicht unmittelbar von DCS abgebildete Verbrauchsgüter dürfen als abstrahierte CampaignState-Ressourcen geführt werden, wenn sie echte Folgen besitzen. Dazu können beispielsweise allgemeine Versorgung, Lebensmittel/Wasser oder medizinische Güter gehören. Verbrauchswerte und konkrete Ressourcenklassen benötigen eine separate Datenentscheidung.

### 6.3 CSAR

Für jeden Vorfall existiert genau ein autoritatives `CSARIncident`-Objekt. Spieler und `AICSAR` dürfen nicht denselben Vorfall doppelt retten. Die CSAR-Quellen und Missionsanforderungen stehen unter [`docs/csar/`](csar/README.md).

## 7. RED-Struktur – persistente Grundversion

### 7.1 Ein konsolidierter Gegner

Die erste produktive RED-Baseline verwendet genau:

```text
1 RED Commander
1 REDState
1 gemeinsamen Ressourcenpool
1 gemeinsames Netzwerk aus Standorten und lokalen Zellen
```

Historische Unterschiede zwischen Taliban, Haqqani-Netzwerk, Hizb-e Islami und lokalen bewaffneten oder kriminellen Netzwerken werden zunächst nur als Quellen- und Verhaltenskontext geführt. Sie erzeugen keine getrennten Runtime-Fraktionen, Beziehungen, Logistikpools oder Commander.

Die Mehrfraktionssimulation bleibt bis auf ausdrückliche spätere Freigabe zurückgestellt.

### 7.2 RED-Netzwerk

RED bildet ein insurgentes Netzwerk mit:

- Hauptquartier;
- Verteilerdepots;
- Hide Sites;
- Forward Caches;
- temporären Transferpunkten;
- lokalen Beobachtern und Zellen;
- abstrakten externen Zuführungswegen.

Standorte durchlaufen nachvollziehbare Zustände von `UNKNOWN` beziehungsweise `CANDIDATE` bis `OPERATIONAL`, `COMPROMISED`, `EVACUATING`, `ABANDONED` oder `DESTROYED`.

Neue Standorte entstehen nur durch reale oder nachvollziehbar virtualisierte Prozesse: Auswahl, Anmarsch, Einrichtung, Aktivierung und Versorgung.

### 7.3 RED-MVP-Aktionen

```text
OBSERVE_ROUTE
BUILD_CACHE
CONDUCT_IED_ATTACK
CONDUCT_AMBUSH
PROBE_CHECKPOINT
DISPERSE_UNDER_PRESSURE
REINFILTRATE_SECTOR
```

`REINFILTRATE_SECTOR` gehört zur Grundversion, weil historische Clear-Hold-Verläufe zeigen, dass taktisch geräumte Räume ohne ausreichendes Hold erneut durch Beobachter, kleine Zellen und Caches erschlossen wurden.

RED-Angriffe dürfen nicht als reine Zufalls- oder Login-Ereignisse entstehen. Vor einer größeren physischen Operation müssen die notwendigen strategischen Voraussetzungen erfüllt sein: Information, Personal, Waffen/Material, Versorgungszugang, gegebenenfalls Cache-Infrastruktur, Sammlung und Verlegung. Diese Vorbereitung kann selbst Exposure und Intelligence erzeugen.

### 7.4 AreaInfluenceState

Die Grundarchitektur benötigt mindestens:

```yaml
area_state:
  armed_presence: 0..100
  route_control: 0..100
  cache_network: 0..100
  pressure_level: 0..100
  hold_strength: 0..100
  reinfiltration_access: 0..100
```

Für die persistente Einfluss- und Regenerationssimulation werden als ergänzende Domänenwerte vorgesehen:

```text
intimidation
population_cooperation
government_legitimacy
local_security_reliability
informant_willingness
intelligence_penetration
```

Später optional ergänzbar:

```text
population_passivity
shadow_governance
humanitarian_need
material_wellbeing
```

Es gibt bewusst keinen einzigen universellen `loyalty`-Wert. Eine Bevölkerung kann beispielsweise die Regierung grundsätzlich unterstützen und gleichzeitig wegen hoher Einschüchterung kaum HUMINT liefern.

### 7.5 RED-Regeneration statt Respawn

RED besitzt keinen unbegrenzten Respawn-Timer. Verluste werden nur durch nachvollziehbare Regeneration ersetzt.

Die Regenerationsfähigkeit kann mindestens abhängen von:

```text
available RED manpower
network integrity
local recruitment potential
external inflow/access
material and weapons availability
population cooperation/passivity
intimidation
BLUE hold/security pressure
```

Zu unterscheiden sind mindestens:

```text
LOCAL_RECRUITMENT
NETWORK_TRANSFER
EXTERNAL_INFLOW
```

`LOCAL_RECRUITMENT` erhöht den verfügbaren RED-Personalpool nur im Rahmen lokaler Kapazität und Einflussbedingungen. `NETWORK_TRANSFER` verschiebt bereits vorhandene RED-Ressourcen. `EXTERNAL_INFLOW` bildet plausible Zuführung von außerhalb des lokal simulierten Raums ab und benötigt definierte Zugänge und Kapazitäten.

Ein Gebiet kann dadurch strategisch stark beruhigt werden, ohne RED für die gesamte Kampagne endgültig zu löschen. Erfolgreiches BLUE-Handeln darf die Regenerationsrate real senken und RED zu Schwerpunktverlagerung oder längeren Erholungszeiten zwingen.

Konkrete Tickdauer, Kapazitäten und Koeffizienten bleiben eine separate Balancing- und Datenentscheidung.

### 7.6 Clear-Hold-Reinfiltration

```text
RED_ACTIVE
  --successful BLUE clear-->
RED_DISRUPTED

RED_DISRUPTED
  --insufficient hold-->
BLUE_CLEARED_NOT_HELD

BLUE_CLEARED_NOT_HELD
  --surviving network + access-->
RED_REINFILTRATING

RED_REINFILTRATING
  --cache and observation restored-->
RED_RECONSTITUTED

RED_RECONSTITUTED
  --new attack-->
RED_ACTIVE
```

Verbindliche Semantik:

```text
AREA_CLEARED != AREA_SECURED
TACTICAL_VICTORY != CAMPAIGN_SUCCESS
```

Ein Clear-Ereignis darf deshalb keinen dauerhaften Nullzustand für RED erzeugen. Umgekehrt darf Reinfiltration einen erfolgreichen Clear nicht sofort neutralisieren; sie benötigt Zeit, Zugang, Netzwerk- und Ressourcenstatus.

## 8. Adaptive Materialisierung und Spielerpräsenz

Physische Darstellung wird nicht durch ein starres Verhältnis gesteuert.

```text
RepresentationPriority
= ExposureScore
+ ExposureDebt
+ MissionCriticality
```

Eine Gruppe bleibt physisch, solange sie beobachtet, verfolgt, bekämpft oder spielernah ist. Teleportation oder Dematerialisierung während nachvollziehbarer Beobachtung ist unzulässig.

Reinfiltration erfolgt:

- zeitverzögert;
- aus plausiblen Zuführungsräumen;
- nicht im Sicht- oder Sensorsbereich der Spieler;
- nur bei vorhandenem Ressourcen- und Zugangsstatus.

Spielerpräsenz darf die Auswahl und physische Darstellung bereits plausibler Aktivitäten beeinflussen, aber keine strategischen Ressourcen oder unvorbereiteten Angriffe erzeugen.

Zulässig:

```text
several plausible RED activities exist
-> player online
-> expose/materialize the operationally interesting one where consistent with state
```

Nicht zulässig:

```text
player online
-> create additional RED manpower
-> create attack without preparation
```

Ohne Spieler dürfen strategische Bewegungen und Zustandsänderungen kontrolliert virtualisiert weiterlaufen, soweit keine physische Darstellung für eine vorhandene DCS-Interaktion erforderlich ist.

## 9. Aufklärung und Erkenntnisstufen

```text
UNKNOWN
INDICATION
AREA_OF_INTEREST
SUSPECTED_LOCATION
PROBABLE_LOCATION
CONFIRMED
COMPROMISED
DESTROYED
```

HUMINT, SIGINT und visuelle Erkenntnisse besitzen unterschiedliche Quellen, Genauigkeiten und Halbwertszeiten. Eine Erkenntnis darf nur Missionen erzeugen, die zu ihrer Qualität und zu den geltenden ROE passen.

Beobachter-, Cache- und Reinfiltrationszustände bleiben verborgen, solange keine ausreichende Erkenntnis vorliegt.

CampaignState-internes Wissen ist nicht automatisch BLUE-Wissen. Dieser Informationsschutz gilt auch für BLUE-KI und ist eine wesentliche Begrenzung ihrer autonomen Schlagkraft.

## 10. Settlement Influence, Support und HUMINT

### 10.1 Abstraktion statt Zivilverkehr

Es wird keine flächendeckende Daily-Life-Simulation ziviler Fahrzeuge oder Personen eingeführt. DCS besitzt für OMW keine ausreichende belastbare Zivilpopulation, um zivile Verluste, Alltagsverkehr oder flächendeckende Gebäudenutzung als primäre Kampagnenmessgröße zu verwenden.

Normale Kartenhäuser werden nicht pauschal als freundlich, feindlich oder neutral klassifiziert. Nur ausdrücklich registrierte strategische Infrastruktur oder NSL-Objekte dürfen eigene Kampagnenwirkung besitzen.

### 10.2 SettlementSupportState

Ausgewählte Ortschaften erhalten einen begrenzten, persistenten Einflusszustand. Mindestens vorgesehen:

```text
government_legitimacy
local_security_reliability
informant_willingness
population_cooperation
intimidation
```

Optional, nach Datenentscheidung:

```text
humanitarian_need
material_wellbeing
```

Diese Werte sind voneinander getrennt. `informant_willingness` ist beispielsweise nicht identisch mit `government_legitimacy`.

### 10.3 Humanitarian/Civil Support

Die bereits geplanten Civil-Support-Lieferungen bleiben bedarfsgetriebene Spieler-Sidequests. Geeignete Ortschaften besitzen missionsdesignerisch geprüfte Lande-, Slingload- oder C-130J-Abwurfpunkte. Eine erfolgreiche wertende Lieferung darf Settlement-Zustände beeinflussen und damit nicht nur HUMINT-Zugang, sondern auch die Hintergrundsimulation.

Mögliche Wirkungsrichtung:

```text
successful support delivery
-> humanitarian_need decreases, if modeled
-> government_legitimacy may increase
-> population_cooperation may increase
-> informant_willingness may increase
-> RED local recruitment effectiveness may decrease indirectly
```

Die konkrete Stärke, Cooldowns, Bedarfsentstehung und Anti-Farming-Regeln bleiben gesondert festzulegen.

Humanitarian Support erzeugt keine automatische Loyalität und keine Informationen aus dem Nichts. Hoher Support ohne tatsächliche RED-Aktivität erzeugt keine erfundene HUMINT-Meldung.

### 10.4 Security und Intimidation

BLUE- und RED-Wirkungen greifen auf dieselben Settlement-Zustände, ohne einen simplen Punktekampf zu bilden.

Beispiele für plausible Wirkungsrichtungen:

```text
persistent BLUE/ANSF security
-> local_security_reliability up
-> intimidation pressure down over time
-> cooperation/informant willingness may recover

RED network dominance / intimidation
-> intimidation up
-> informant willingness down
-> RED freedom of movement and recruitment conditions improve

successful BLUE cache/network disruption
-> RED network capability down
-> no automatic population-loyalty bonus
```

Konkrete Formeln sind nicht Teil dieser Baseline.

### 10.5 HUMINT bleibt wissensgebunden

Support-Level oder hohe Kooperation bedeuten Bereitschaft zur Informationsweitergabe, nicht allwissende Bevölkerung.

```text
high support + no local RED knowledge
-> no report

low support + local RED knowledge
-> knowledge may remain undisclosed

high support + local RED knowledge
-> better HUMINT quality
```

HUMINT kann weiterhin Folgeaufträge wie RECON, SURVEILLANCE, PATROL und bei ausreichender Bestätigung RAID/SEIZE/DESTROY/STRIKE auslösen.

## 11. Strategische Zeit und Berechnung

Die Hintergrundsimulation wird nicht als hochfrequenter Welt-Scan ausgeführt. Ereignisse werden unmittelbar als CampaignState-Änderung oder Event-Akkumulator erfasst; langsamere Prozesse werden periodisch verarbeitet.

Vorgesehene Trennung:

```text
EVENT-DRIVEN
losses, deliveries, mission results, site state changes, attacks

SHORT STRATEGIC TICK
security, intimidation decay/growth, readiness, local pressure

LONG STRATEGIC TICK / DAY TURN
recruitment, regeneration, external inflow, long-term influence and sustainment
```

Die genauen Intervalle bleiben offen. Die Architektur bevorzugt Tabellen-/CampaignState-Berechnung gegenüber wiederholten DCS-Welt-Scans.

## 12. Persistenter Serverbetrieb und Autonomie-Balance

### 12.1 Grundsatz

Spieler können über lange Zeiträume vollständig abwesend sein. Die Kampagne muss trotzdem weiterlaufen und glaubwürdige lokale Ergebnisse erzeugen.

Verbindlich gilt:

```text
NO_PLAYERS != FREE_RED_ADVANCE
NO_PLAYERS != BLUE_AI_VICTORY
```

BLUE und RED dürfen ohne Spieler Erfolge und Verluste erzielen, aber ihre Autonomie muss so begrenzt sein, dass der persistente Konflikt weder durch einen unbeaufsichtigten Snowball noch durch allwissende KI beendet wird.

### 12.2 BLUE-Fallback

Der BLUE-CHIEF/COMMANDER darf betriebsnotwendige offene Demands übernehmen oder zuweisen. Dies umfasst insbesondere Versorgung, Verteidigung, QRF und andere zeitkritische Aufgaben. Nicht zeitkritische interessante Spieleraufgaben sollen, soweit strategisch vertretbar, für menschliche Übernahme offen bleiben.

### 12.3 RED-Fortsetzung

RED darf auch ohne Spieler sein Netzwerk versorgen, verlegen, beobachten, Caches errichten, reinfiltrieren und Angriffe vorbereiten. Die Operationsrate und -größe bleiben an Ressourcen, Readiness, Information und Infrastruktur gebunden.

### 12.4 Kein künstlicher Stillstand

Die Kampagne soll Spielern beim Einstieg laufende, kausal entstandene Möglichkeiten bieten. Wenn keine Kampfmission offen ist, können unter anderem bedarfsgetriebene Logistik, Recon, Show of Force, Route Security, HUMINT-Folgeaufträge oder CAS-Standby relevant sein. Diese Inhalte müssen aus dem bestehenden Zustand entstehen und dürfen nicht nur wegen eines Spieler-Logins erzeugt werden.

## 13. Balancing-Ebenen

Drei Ebenen bleiben getrennt:

```text
STRATEGIC BALANCE
RED/BLUE resources, regeneration, logistics, influence, security

AUTONOMY BALANCE
what BLUE and RED AI may achieve without players

GAMEPLAY PACING
which plausible operations are exposed/materialized for active players
```

Spielbarkeit darf Gameplay-Pacing beeinflussen, aber keine unkausale Ressourcenentstehung oder Teleport-/Spawn-Lösung legitimieren.

Ein langfristig erfolgreich stabilisierter Raum darf deutlich ruhiger werden. Neue Aktivität entsteht dann eher durch Schwerpunktverlagerung, externe Zuführung, Netzwerkneubildung oder langsame Reinfiltration als durch sofortiges künstliches Hochskalieren desselben Gebiets.

## 14. Projektphase und Umsetzung

Die aktuelle Phase ist:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Für RED gilt:

```text
STAGE_1_SINGLE_RED_CORE
STAGE_2_BASIC_INFLUENCE
STAGE_3_ADVANCED_ACTIONS
STAGE_4_OPTIONAL_MULTIFACTION
```

`STAGE_4_OPTIONAL_MULTIFACTION` ist bis auf Weiteres zurückgestellt.

Der Missionsgrundbau darf nach fachlich getrennten Arbeitspaketen parallel entstehen. Technische Acceptance bleibt stets an den exakt getesteten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand gebunden.

Diese Architekturentscheidung verlangt noch keine sofortige vollständige Influence-/Recruitment-Implementierung. Sie definiert jedoch die Zielgrenzen, damit spätere Einzelmodule nicht erneut von einem endlichen RED-Pool oder rein spielerabhängigen Spawnmodell ausgehen.

## 15. Abnahmekriterien

Eine Kampagnenfunktion gilt erst als integriert, wenn:

- MOOSE-Prüfung und Eigentümerentscheidung dokumentiert sind;
- CampaignState- und MOOSE-Verantwortung eindeutig getrennt sind;
- keine zwecklosen Spawns oder Doppelbestände entstehen;
- Erfolg, Verlust und Abbruch strategische Folgen besitzen;
- Spieler und KI keine Doppelaufträge erzeugen;
- Beobachtung und Verfolgung respektiert werden;
- Persistenz reproduzierbar arbeitet;
- ein DCS-Testfall mit erwarteten Logmeldungen vorliegt.

Für die RED-Grundversion gilt zusätzlich:

- genau ein konsolidierter RED Commander;
- genau ein gemeinsamer RED-Ressourcenpool;
- keine versteckten Fraktionspools oder Relationslogik;
- getestete Kernaktionen vor jeder Erweiterung;
- Rückzug und Dispersal statt obligatorischem Kampf bis zur Vernichtung;
- reproduzierbare Reinfiltration nach unzureichendem Hold;
- keine Reinfiltrationsspawns in Sicht- oder Sensorreichweite der Spieler;
- RED-Regeneration nur aus dokumentierten lokalen, Netzwerk- oder externen Quellen;
- kein direkter Spielerzahl-zu-RED-Manpower-Multiplikator;
- keine RED-Angriffe ohne strategische Vorbereitung und Ressourcen;
- Mehrfraktionsfunktionen nur nach gesonderter Projektinhaberfreigabe.

Für den persistenten Serverbetrieb gilt zusätzlich:

- ESSENTIAL-Demands besitzen einen dokumentierten KI-Fallback;
- BLUE-KI darf keine CampaignState-Metainformation als BLUE-Intelligence behandeln;
- Spielerabwesenheit allein darf weder RED-Snowball noch BLUE-Autowin erzeugen;
- Gameplay-Pacing und strategische Ressourcenrechnung bleiben getrennt;
- Hintergrundsimulation darf keine unbegründeten hochfrequenten DCS-Welt-Scans benötigen.
