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
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - incomplete campaign architecture descriptions in legacy foundation documents
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 37 – Kampagnenarchitektur und dynamisches Missionsdesign

## 1. Zweck und Autorität

Dieses Dokument ist die verbindliche fachliche Produktionsarchitektur für die persistente COIN-Kampagne **Operation Mountain Watch**.

Maßgebliche übergeordnete Regeln:

- [`OMW-GOV-001`](00-project-governance.md) – höchste Projekt-Governance;
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) – vollständiges MOOSE-First- und Ausnahmeverfahren;
- [`OMW-ARCH-SYSTEM`](03-system-architecture.md) – übergeordnete Systemgrenzen.

Der vollständige frühere Architekturtext bleibt unverändert erhalten:

- [`Legacy-Fassung vor Governance-Migration`](evidence/source-records/legacy-37-campaign-architecture-pre-governance.md)

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
- Ortschaftsunterstützung und HUMINT-Zugang;
- Persistenz über Missionsneustarts.

MOOSE und DCS bilden diesen Zustand operativ ab. Sie dürfen nicht parallel einen unabhängigen strategischen Bestand führen.

> CampaignState entscheidet, was existiert, verfügbar ist und strategisch geschieht. MOOSE setzt diese Entscheidungen in der laufenden DCS-Mission um.

## 4. Keine zwecklosen Spawns

Jede physisch erzeugte Gruppe benötigt:

- einen definierten Ursprung;
- ein definiertes Ziel;
- einen realen Auftrag;
- eine transportierte oder eingesetzte Ressource;
- eine strategische Folge bei Erfolg, Verlust oder Abbruch;
- eine stabile CampaignState- oder MissionDemand-Identität.

Zufällige Gruppen ohne strategische Herkunft oder Rückwirkung sind unzulässig.

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

## 6. BLUE-Struktur

### 6.1 Luftoperationen

- `COMMANDER` für übergeordnete Zuweisung;
- `AIRWING` pro relevantem Flugplatz oder Luftoperationsknoten;
- `SQUADRON` pro Muster, Rolle oder Bestand;
- `AUFTRAG` für KI-Missionen;
- `PLAYERTASK` beziehungsweise MissionDemand-Zuordnung für Spieler;
- `WAREHOUSE` für operative Bestandsabbildung, nicht als zweite strategische Wahrheit.

Aktive ORBAT und Client-Grenzen stehen ausschließlich in Dokument 19.

### 6.2 FOBs und Bodentruppen

FOBs sind persistente Kampagnenobjekte mit Personal, Fahrzeugen, Warehouse, Treibstoff, Munition, Bereitschaft, Fähigkeiten und zugeordneten Verbänden.

Die operative Abbildung erfolgt vorrangig über:

- `BRIGADE`;
- `PLATOON`;
- `ARMYGROUP`;
- `OPSGROUP`;
- `OPSTRANSPORT`;
- `CTLD`.

### 6.3 CSAR

Für jeden Vorfall existiert genau ein autoritatives `CSARIncident`-Objekt. Spieler und `AICSAR` dürfen nicht denselben Vorfall doppelt retten. Die CSAR-Quellen und Missionsanforderungen stehen unter [`docs/csar/`](csar/README.md).

## 7. RED-Struktur

RED bildet ein insurgentes Netzwerk mit unterschiedlichen Standorttypen:

- Hauptquartier;
- Verteilerdepots;
- Hide Sites;
- Forward Caches;
- temporäre Transferpunkte.

Standorte durchlaufen nachvollziehbare Zustände von `UNKNOWN` beziehungsweise `CANDIDATE` bis `OPERATIONAL`, `COMPROMISED`, `EVACUATING`, `ABANDONED` oder `DESTROYED`.

Neue Standorte entstehen nur durch reale oder nachvollziehbar virtualisierte Prozesse: Auswahl, Anmarsch, Einrichtung, Aktivierung und Versorgung.

## 8. Adaptive Materialisierung

Physische Darstellung wird nicht durch ein starres Verhältnis gesteuert.

```text
RepresentationPriority
= ExposureScore
+ ExposureDebt
+ MissionCriticality
```

Eine Gruppe bleibt physisch, solange sie beobachtet, verfolgt, bekämpft oder spielernah ist. Teleportation oder Dematerialisierung während nachvollziehbarer Beobachtung ist unzulässig.

## 9. Aufklärung und Erkenntnisstufen

Vorgesehene Erkenntnisstufen:

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

## 10. Settlement Support und HUMINT

Ausgewählte Ortschaften können begrenzte Support- und HUMINT-Stufen erhalten. Das System ist kein vollständiges politisches Loyalitätsmodell. Lieferungen und Unterstützung erzeugen nur dann Informationen, wenn lokal tatsächlich verwertbares Wissen vorhanden ist.

## 11. Projektphase und Umsetzung

Die aktuelle Phase ist:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Der Missionsgrundbau darf nach fachlich getrennten Arbeitspaketen parallel entstehen. Technische Acceptance bleibt stets an den exakt getesteten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand gebunden.

## 12. Abnahmekriterien

Eine Kampagnenfunktion gilt erst als integriert, wenn:

- MOOSE-Prüfung und Eigentümerentscheidung dokumentiert sind;
- CampaignState- und MOOSE-Verantwortung eindeutig getrennt sind;
- keine zwecklosen Spawns oder Doppelbestände entstehen;
- Erfolg, Verlust und Abbruch strategische Folgen besitzen;
- Spieler und KI keine Doppelaufträge erzeugen;
- Beobachtung und Verfolgung respektiert werden;
- Persistenz reproduzierbar arbeitet;
- ein DCS-Testfall mit erwarteten Logmeldungen vorliegt.
