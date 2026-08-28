---
document_id: OMW-PHASE-VERTICAL-PROTOTYPE
status: SUPERSEDED
owning_policy: OMW-GOV-001
authoritative_for:
  - historical record of the original vertical prototype
scenario_period: 2010-08-01/2011-12-31
project_phase: HISTORICAL_VERTICAL_PROTOTYPE
superseded_by:
  - OMW-GOV-001 section 9
  - COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: HISTORICAL_PHASE_BASELINE
source_commit: GIT_HISTORY
supersedes:
---

# 14 – Vertikaler Prototyp

## Status

```text
SUPERSEDED_PROJECT_PHASE
```

Dieses Dokument bleibt als Entwicklungs- und Planungsnachweis erhalten. Es ist nicht mehr die verbindliche Reihenfolge für den weiteren Projektaufbau.

Die frühere Strategie konzentrierte sich auf einen kleinen vertikalen Jalalabad–FOB-Connolly-Ausschnitt und wollte dort CampaignState, Virtualisierung, RED Director, Logistik und CSAR vollständig nacheinander validieren.

Die Strategie wurde ersetzt, weil:

- die Tests zu kleinteilig und zeitaufwendig wurden;
- mehrere frühe Tests vor Einführung der verbindlichen MOOSE-First-Regel entstanden;
- isolierte Eigenentwicklungen und spätere Neubauten vermeidbare Wiederholungen erzeugten;
- wichtige Basen-, ORBAT-, Naming- und Missionseditorgrundlagen noch nicht als gemeinsames Gerüst vorlagen;
- gestapelte Testzweige die Projektwahrheit und den Integrationsstand schwer nachvollziehbar machten.

## Neue verbindliche Projektphase

Die aktuelle Phase ist:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Zunächst wird das vollständige Missionsgrundgerüst aufgebaut:

- relevante Flugplätze und Luftoperationsknoten;
- FOBs, COPs, OPs, afghanische Kontrollpunkte und Infrastruktur;
- aktive ORBAT-Arbeitsbestände;
- Spielergruppen;
- KI-Templates;
- Statics und Parking-Baselines;
- Warehouses und Logistikknoten;
- Triggerzonen nur bei konkreter technischer Funktion;
- Naming, stabile Dokument-IDs und zentrale Dokumentnummern;
- grundlegende MOOSE-AIRWING-, SQUADRON-, AUFTRAG-, OPSTRANSPORT- und Warehouse-Strukturen.

Erst auf diesem gemeinsamen Grundgerüst folgen gezielte Funktions-, Integrations-, Last- und Acceptance-Tests.

## Weiterhin gültige fachliche Inhalte des früheren Prototyps

Die folgenden Anforderungen bleiben als fachlicher Backlog gültig, aber nicht mehr als vorgeschriebene erste Implementierungsreihenfolge.

### Operationsraum und Kernknoten

- Jalalabad Airfield / FOB Fenty;
- FOB Connolly;
- Straßenverbindung und alternative Routen;
- angrenzende Siedlungen, Hinterhalträume und rote Operationssektoren;
- Bagram, Kabul und Kandahar als physisch vorzubereitende strategische beziehungsweise operative Knoten.

### Blaue Infrastruktur

- operative Haupt- und Regionalbasen;
- vorgeschobene FOBs und afghanische Kontrollpunkte;
- Ressourcenlager und Warehouse-Anker;
- Konvoi-Start- und Zielbereiche;
- C-130J-Entlade- und Übergabezonen;
- Hubschrauber-Landezonen;
- getrennte interne Fracht- und Außenlastpfade;
- Drop Zones für Luftabwurfversuche.

### Rote Infrastruktur

- regionale Zellen;
- mehrere mögliche Camp- und Strongpoint-Sites;
- Hinterhalt-, Assembly-, Rückzugs- und Zerstreuungsräume;
- gewichtete Bewegungs- und Versorgungsnetze;
- dynamische Besetzung statt starrer Relais- und Mindestgarnisonsarchitektur.

### Missionsarten

- Konvoieskorte und Hinterhalt;
- QRF;
- interne Hubschrauberfracht;
- Außenlast;
- Truppen- und Ingenieurtransport;
- Verwundeten- und Personalrücktransport;
- gelandete C-130J-Anlieferung;
- C-130J-Luftabwurf;
- Aufklärung und Angriff auf bestätigte Camps;
- FOB-Nachversorgung;
- CSAR mit möglichem gegnerischem Capture-Team.

### CampaignState und Persistenz

- stabile Entity-IDs;
- Ressourcen-, Verlust- und Lieferbuchungen;
- versionierte Snapshots und Wiederherstellung;
- Trennung von logischem Zustand und physischer DCS-/MOOSE-Repräsentation;
- genau einmalige Transaktionen und Gutschriften.

### Virtualisierung

- kanonischer Routenfortschritt;
- Materialisierung vor relevanter Spieler- oder Feindnähe;
- Erhaltung von Zusammensetzung, Schaden, Fracht und Auftrag;
- sichere Dematerialisierung;
- keine Teleportation oder Zustandskorrektur während erkannter beziehungsweise angegriffener Gruppen, sofern nicht ausdrücklich als genehmigte Recovery-Funktion definiert.

### Logistik

- gemeinsames Manifestmodell für Straße, interne Fracht, Außenlast, Landung und Airdrop;
- Cargo-ID niemals gleichzeitig in mehreren Repräsentationen;
- genau einmalige Gutschrift;
- Verlust- und Teilverlustbehandlung;
- Spielerlogistik als primärer Weg;
- automatische Notversorgung nur als begrenzte Rückfallebene.

### CSAR

- Erzeugung eines Rettungsfalls;
- verzögerter Informationsgewinn;
- konkurrierendes gegnerisches Capture-Team;
- Abschluss erst nach Rücktransport zu einer geeigneten Einrichtung.

## Historische Abnahmekriterien

Die ursprünglichen Abnahmekriterien bleiben als späterer Integrations-Backlog erhalten:

1. physische und virtuelle Konvois behalten Identität, Zusammensetzung, Schaden und Fracht;
2. Spieler können eskortieren, eingreifen und auf Angriffe reagieren;
3. interne CH-47F- und UH-1H-Fracht wird korrekt geladen, verloren oder genau einmal gutgeschrieben;
4. CH-47F- und UH-1H-Außenlasten werden separat behandelt;
5. C-130J-Landung und Airdrop verwenden dasselbe Manifest- und Ressourcenmodell;
6. rote Kräfte greifen an, ziehen sich zurück und regenerieren nachvollziehbar über das Produktionsnetz;
7. FOBs reagieren auf Versorgung und Ausfälle;
8. CSAR kann von Blau und Rot beeinflusst werden;
9. Speichern und Laden stellt den strategischen Zustand reproduzierbar wieder her;
10. Serverleistung bleibt bei mehreren parallelen Aktivitäten stabil.

Diese Kriterien werden künftig in fachlich getrennte MOOSE-First-Testpakete zerlegt, nachdem die benötigten Basen, Templates, Datenmodelle und Schnittstellen im Foundation Build vorhanden sind.

## Autoritätsregel

Kein Abschnitt dieses historischen Dokuments darf verwendet werden, um die aktuelle Foundation-Build-Phase, die aktive ORBAT, die MOOSE-First-Governance oder neuere basisbezogene Missionseditor-Baselines zu überschreiben.
