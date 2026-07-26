# Übergabe – Start der RED-Seiten-Entwicklung

Datum: 17. Juli 2026  
Status: Vorbereitung für einen getrennten Entwicklungs-Chat  
Repository: `birkenmoped/Operation-Mountain-Watch`

## 1. Zweck dieser Übergabe

Die weitere Entwicklung der roten Kampagnenseite wird nicht in der laufenden TM01C-Konversation fortgesetzt. Sie beginnt in einem neuen Chat und erhält einen eigenen Branch sowie einen eigenen Draft-PR.

Der neue Arbeitsstrang soll die bereits entworfene rote Kampagnenarchitektur schrittweise in ausführbare, DCS-getestete Komponenten überführen. Der Einstiegspunkt ist die bestehende Testreihe `TM02 – rote Relaisbewegung`, nicht ein sofort vollständig autonomer Red Director.

## 2. Ausgangsstand

Der vor dem Handoff bestätigte TM01C-Code- und Dokumentationsstand war:

```text
Branch:        feature/tm01b-convoy-caching
Code-Baseline: b716f5caf494d7b0b938017dac6ce6d36e2e38ea
PR:            #8, Draft, offen, ungemergt
```

Das Handoff-Dokument selbst liegt in nachfolgenden Dokumentationscommits auf demselben Branch. Für den neuen RED-Branch ist deshalb nicht der ältere Code-SHA, sondern der bei Arbeitsbeginn aktuelle Head des Branch-Refs `feature/tm01b-convoy-caching` maßgeblich.

TM01C hat für die rote Seite nur einen begrenzten technischen Nachweis geliefert:

```text
isolierte RED-Gegnernähe erzwingt Unpack: PASS
mehrere Enemy-Pack-/Unpack-Zyklen:        PASS
Enemy-Hysterese und Timerabbruch:         PASS
vollständige RED-Kampagnenlogik:           NICHT IMPLEMENTIERT
```

Die zehn Infanterieposten aus TM01C sind Testauslöser für die blaue Konvoirepräsentation. Sie sind keine produktive rote Entität, kein Red Director und kein Ersatz für TM02.

## 3. Bereits vorhandene RED-Grundlage

Das Repository enthält bereits den Entwurf `mission/tests/tm02-red-relay/`.

Der bestehende TM02-Vertrag sieht vor:

```text
- Hauptquartier und Zwischenknoten behalten feste Mindestbesatzungen.
- Nur Überschüsse dürfen verlegt werden.
- Ein erstes Marschpaket besteht aus sechs Kämpfern.
- Ein Paket darf nur zum direkten Nachfolgeknoten gehen.
- Knoten dürfen nicht übersprungen werden.
- Höchstens drei Marschgruppen dürfen gleichzeitig aktiv sein.
- Stufe A bleibt vollständig physisch.
- Stufe B virtualisiert nur Marschgruppen.
```

Zusätzlich gelten die vorhandenen Architekturentscheidungen zu:

```text
- roten Hide Sites und vorbereiteten Strongpoints;
- CampaignState als autoritativer Domainzustand;
- persistenten roten Knoten-, Bestands- und Bewegungsdaten;
- MOOSE 2.9.18 als gepinnter Orchestrierungsbaseline;
- begrenzten physischen Gruppen und expliziter Virtualisierung;
- idempotenten Zustandsübergängen und Transaktionen.
```

## 4. Verbindliche Architekturregeln

### 4.1 CampaignState ist autoritativ

DCS-Gruppennamen, Unit-Namen und MOOSE-Wrapper sind Laufzeitreferenzen. Die strategische rote Entität besitzt eine stabile Domain-ID im CampaignState.

Mindestens zu unterscheiden sind:

```text
RED_NODE
RED_FORCE_PACKAGE
RED_MARCH_GROUP
RED_CONTACT_RECORD
```

Ein physisches DCS-Objekt ist eine Repräsentation einer Domainentität, nicht die Entität selbst.

### 4.2 Keine doppelte Repräsentation

Für eine rote Marschgruppe gilt jederzeit genau eine Darstellung:

```text
STAGED
VIRTUAL
PHYSICAL
ARRIVED
DESTROYED
FAILED
```

`VIRTUAL` und `PHYSICAL` dürfen niemals gleichzeitig gelten. Zerstörte Kämpfer oder Gruppen dürfen durch Materialisierung nicht wiederauferstehen.

### 4.3 Keine allwissende rote Seite

Der Red Director darf keine verborgene BLUE-Warehouse-, Triggerzonen- oder Missionseditorgeometrie als Abkürzung benutzen.

Zulässige Wissensquellen sind:

```text
- persistente rote Domaindaten;
- eigene bekannte Knoten und Routen;
- aktuelle oder gespeicherte Kontaktmeldungen;
- explizit modellierte Aufklärungsergebnisse;
- kampagnenweit definierte öffentliche Geodaten.
```

Nicht zulässig sind versteckte BLUE-Daten, nur weil sie im Missionsskript technisch erreichbar wären.

### 4.4 Keine automatische Fehlerkaschierung

Nicht ergänzen:

```text
- Teleport als stilles Recovery;
- automatisches Unstuck;
- permanente spontane Neuroutenberechnung;
- Wiederherstellung zerstörter Kräfte;
- stilles Überspringen eines Relaisknotens;
- nicht protokollierte Zustandskorrekturen.
```

Fehler führen zu einem sichtbaren, strukturiert geloggten Zustand.

### 4.5 Gepinnte technische Basis

```text
MOOSE:           2.9.18
Runtime-Datei:   vendor/moose/Moose.lua
Ladereihenfolge: MOOSE vor OMW-Projektcode
```

Neue MOOSE-APIs müssen gegen die vendorte Fassung geprüft werden. Develop-only-Funktionen werden nicht vorausgesetzt.

## 5. Branch- und PR-Strategie

Die RED-Entwicklung wird nicht weiter direkt in PR #8 geschrieben.

Im neuen Chat ist zuerst ein gestapelter Entwicklungsbranch anzulegen:

```text
Ausgangsref:  feature/tm01b-convoy-caching
Neuer Branch: feature/tm02-red-side-foundation
PR-Base:      feature/tm01b-convoy-caching
PR-Status:    Draft
```

Vor dem Abzweigen muss der neue Chat den aktuellen Remote-Head von `feature/tm01b-convoy-caching` verifizieren und sicherstellen, dass diese Datei vorhanden ist:

```text
docs/handoffs/2026-07-17-red-side-development-handoff.md
```

Begründung:

- der neue Arbeitsbereich erhält den vollständigen aktuellen Architektur-, Test- und Handoff-Stand;
- RED-Änderungen bleiben von der bereits großen TM01C-Änderungsmenge getrennt;
- PR #8 bleibt Draft und ungemergt;
- der RED-PR kann später nach Bereinigung der Branch-Kette neu basiert oder umgezielt werden.

Keine Merge-Aktion ohne ausdrückliche Freigabe.

## 6. Erstes Entwicklungsziel: TM02A RED Relay Foundation

Der erste ausführbare Meilenstein ist bewusst klein:

```text
TM02A
Ein kontrollierter Transfer von sechs roten Kämpfern
von einem bekannten RED-Knoten
zum direkten Nachfolgeknoten
vollständig physisch und manuell ausgelöst.
```

### 6.1 Noch vor der Implementierung prüfen

Der neue Chat muss zunächst den tatsächlichen Repository-Inhalt von `mission/tests/tm02-red-relay/` vollständig lesen und gegen diese Übergabe abgleichen.

Zu inventarisieren sind:

```text
- vorhandenes README und Konfiguration;
- vorhandene Lua-Quellen und Buildskripte;
- erwartete Mission-Editor-Objekte;
- vorhandene Ergebnis- und Abnahmedokumente;
- historischer DCS-Nachweis und dessen Einschränkungen;
- verwendete Koalition, Nation und Templates.
```

Kein vorhandener TM02-Stand darf anhand alter Zusammenfassungen überschrieben werden.

### 6.2 Minimaler Domainzustand

Für den ersten Transfer werden mindestens benötigt:

```text
RED_NODE
- nodeId
- nodeType
- garrisonAlive
- minimumGarrison
- availableSurplus
- successorNodeId
- representationState

RED_MARCH_GROUP
- movementId
- sourceNodeId
- destinationNodeId
- fighterCount
- survivorCount
- movementState
- representationState
- runtimeGroupName optional
- routeProgress optional
```

Der CampaignState muss vor jedem Spawn die Übertragung fachlich reservieren. Ein wiederholter Befehl darf nicht dieselben sechs Kämpfer erneut erzeugen.

### 6.3 Kontrollierter Ablauf

```text
1. Konfiguration und Mission-Editor-Objekte validieren.
2. RED-Ausgangsknoten und direkten Nachfolger registrieren.
3. Mindestbesatzung und verfügbaren Überschuss prüfen.
4. Genau sechs Kämpfer atomar für einen Transfer reservieren.
5. Eine physische DCS-Gruppe aus einem Late-Activation-Template erzeugen.
6. Laufzeitgruppe, Unit-Zahl und Startbereich validieren.
7. Route ausschließlich zum direkten Nachfolgeknoten zuweisen.
8. Ankunft explizit feststellen.
9. Überlebende dem Zielknoten gutschreiben.
10. Verluste dauerhaft im Domainzustand belassen.
11. Transfer genau einmal abschließen.
```

### 6.4 Bedienung im ersten Test

Das erste TM02A-Bundle soll nur kontrollierte F10-Kommandos anbieten:

```text
OMW Tests
└── TM02A
    ├── Validate configuration
    ├── Show RED relay status
    ├── Start one relay transfer
    └── Show active movement
```

Keine autonome periodische Directorentscheidung im ersten Meilenstein.

## 7. Abnahmekriterien für TM02A

Ein DCS-Lauf gilt erst als bestanden, wenn nachgewiesen ist:

```text
- genau ein Transfer wird angelegt;
- genau sechs Kämpfer werden aus dem Überschuss reserviert;
- die Mindestbesatzung des Ausgangsknotens bleibt erhalten;
- genau eine physische Marschgruppe entsteht;
- ein wiederholter Startbefehl erzeugt keine Duplikate;
- kein Relaisknoten wird übersprungen;
- die Gruppe erreicht den direkten Nachfolger;
- nur Überlebende werden dem Ziel gutgeschrieben;
- Verluste werden nicht wiederhergestellt;
- der Transfer wird genau einmal abgeschlossen;
- CampaignState und physische Darstellung widersprechen sich nicht;
- keine automatische Recovery-, Teleport- oder Unstuck-Logik läuft;
- strukturierte Logs ermöglichen eine vollständige Rekonstruktion.
```

## 8. Explizite Nichtziele des ersten RED-Meilensteins

Noch nicht implementieren:

```text
- vollständiger autonomer Red Director;
- Rekrutierung und Verstärkungsproduktion;
- IED- oder Hinterhaltsgenerator;
- Angriffszielauswahl gegen BLUE;
- Sichtlinien-, Sensor- oder Hostile-Intent-Modell;
- adaptive Tarnung und Exposure-Auswertung;
- mehrere gleichzeitige Marschgruppen;
- Virtualisierung oder Relevanzmaterialisierung;
- persistenter Missionsneustart;
- Cargo Units, Warehouses oder Wirtschaftstransaktionen;
- strategische Reaktion auf TM01C;
- dynamische globale Wegfindung.
```

Diese Funktionen folgen erst nach einer akzeptierten physischen TM02A-Baseline.

## 9. Geplante Folgemeilensteine

```text
TM02A – ein manueller physischer Relaistransfer
TM02B – Verluste, Survivor-Synchronisierung und robuste Ankunft
TM02C – mehrere Transfers mit Kapazitäts- und Gleichzeitigkeitsgrenzen
TM02D – Virtualisierung ausschließlich der Marschgruppen
TM02E – Spieler-/Kontaktrelevanz für Materialisierung
TM02F – erste deterministische Red-Director-Entscheidung
```

Die Bezeichnungen sind Arbeitsnamen. Der neue Chat muss sie gegen die vorhandene TM02-Struktur prüfen, bevor Dateien umbenannt oder neue Stufen festgeschrieben werden.

## 10. Startauftrag für den neuen Chat

Den folgenden Text vollständig in einen neuen Chat im Projekt `DCS - Missionsdesign` kopieren:

```text
Wir starten jetzt die getrennte Entwicklung der roten Kampagnenseite für Operation Mountain Watch.

Repository:
birkenmoped/Operation-Mountain-Watch

Lokaler Pfad:
P:\DCS-DEV\Operation-Mountain-Watch

Lies zuerst vollständig:
- docs/handoffs/2026-07-17-red-side-development-handoff.md
- mission/tests/tm02-red-relay/README.md
- alle Dateien unter mission/tests/tm02-red-relay/
- die relevanten RED-, CampaignState-, Virtualisierungs-, Warehouse- und Persistenzdokumente
- den aktuellen Status von PR #8

Verbindlicher Ausgangsstand:
- Ausgangsref ist feature/tm01b-convoy-caching
- ermittle und dokumentiere dessen aktuellen Remote-Head
- verifiziere, dass das Handoff-Dokument in diesem Head vorhanden ist
- PR #8 bleibt Draft, offen und ungemergt

Arbeite für die RED-Seite auf einem neuen Branch:
feature/tm02-red-side-foundation

Der neue Draft-PR soll zunächst auf feature/tm01b-convoy-caching basieren. Keine RED-Implementierung direkt in PR #8 und kein Merge ohne meine ausdrückliche Freigabe.

Erster Auftrag:
1. Inventarisiere den vorhandenen TM02-Stand vollständig.
2. Vergleiche ihn mit der Übergabe und dokumentiere Abweichungen.
3. Definiere den kleinsten sicheren TM02A-Meilenstein für einen manuell ausgelösten, vollständig physischen Relaistransfer von sechs roten Kämpfern zwischen zwei direkt benachbarten RED-Knoten.
4. CampaignState bleibt autoritativ; keine doppelte physische/virtuelle Repräsentation, keine Wiederauferstehung, kein Teleport, kein Unstuck und keine allwissende Nutzung verborgener BLUE-Daten.
5. Implementiere erst nach der Bestandsaufnahme die minimale Baseline samt Build, strukturiertem Logging, F10-Diagnose und DCS-Abnahmevertrag.
6. MOOSE bleibt auf 2.9.18 gepinnt.

Beginne mit Repository- und Architekturprüfung. Nenne danach den exakten Implementierungsplan, die betroffenen Dateien, die erforderlichen Mission-Editor-Objekte und die erste DCS-Abnahme. Führe die GitHub-Arbeit selbst aus und lasse mich nur die lokalen DCS-/Mission-Editor-Schritte ausführen, die du nicht erreichen kannst.
```

## 11. Übergabestatus

```text
Handoff vorbereitet: JA
RED-Code in diesem Chat begonnen: NEIN
Neuer RED-Branch erstellt: NEIN – Aufgabe des neuen Chats
Neuer RED-Draft-PR erstellt: NEIN – nach Bestandsaufnahme im neuen Chat
PR #8 gemergt: NEIN
```
