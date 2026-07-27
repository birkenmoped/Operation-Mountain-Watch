---
document_id: OMW-AIR-ME-WORKLIST
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - air-operations Mission Editor workflow
  - division of work between mission design and development
  - per-base authoring and validation sequence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Jalalabad-first vertical-prototype implementation sequence
superseded_by:
source_branch: agent/resolve-document-number-collisions
source_commit:
validated_in_dcs: false
document_class: MISSION_EDITOR_WORKLIST
---

# 20 – Missionseditor-Arbeitsliste für die Luft-ORBAT

## 1. Zweck und verbindliche Grundlagen

Dieses Dokument trennt:

1. die im DCS Mission Editor auszuführenden Arbeiten;
2. die durch Entwicklung und Dokumentation bereitzustellenden Vorgaben;
3. die Reihenfolge von Foundation Build, Knotenprüfung und technischer Acceptance.

Maßgeblich sind:

- [`OMW-GOV-001`](00-project-governance.md) für Projektphase und Autorität;
- [`OMW-AIR-ACTIVE-ORBAT – Dokument 19`](19-active-air-orbat-decisions.md) für Verbände, Bestände und Client-Grenzen;
- [`OMW-AIR-IMPLEMENTATION – Dokument 18`](18-air-operations-implementation.md) für gemeinsame technische Regeln;
- [`OMW-ME-MASTER-WORKLIST – Dokument 38`](38-mission-editor-master-worklist.md) für die vollständige Foundation-Build-Arbeitsliste.

Der vollständige frühere Jalalabad-first-Arbeitsstand bleibt unverändert erhalten unter:

- [`legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md`](evidence/source-records/legacy-20-air-orbat-mission-editor-worklist-vertical-prototype.md).

## 2. Projektphase und Umsetzungsreihenfolge

Aktuelle Projektphase:

```text
COMPLETE_FOUNDATION_BUILD_PHASE
```

Der Missionsgrundbau wird nach fachlich getrennten Arbeitspaketen vollständig aufgebaut. Daraus folgen diese Regeln:

1. Relevante Flugplätze, Luftoperationsknoten, FOBs und gemeinsame Namenskonventionen dürfen parallel vorbereitet werden.
2. Jeder Knoten erhält ein eigenes Manifest, einen dokumentierten Missionseditor-Stand und definierte Testfälle.
3. Teilprüfungen dürfen früh stattfinden, blockieren aber nicht pauschal die Bearbeitung anderer Knoten.
4. Eine technische Acceptance gilt nur für den exakt getesteten Branch-, Commit-, Missions-, Bundle- und MOOSE-Stand.
5. Eine Basis darf erst produktiv aktiviert werden, wenn ihre eigenen Abnahmekriterien erfüllt sind.
6. Atmosphärischer RAT-Verkehr wird erst ergänzt, wenn operative Park-, Spawn- und Performancegrenzen des betroffenen Knotens stabil sind.

Jalalabad/Fenty bleibt ein wertvoller technischer Test- und Regressionsknoten. Es ist jedoch **keine verpflichtende Eingangsschranke** mehr, vor der Bagram, Kandahar oder andere Basen nicht aufgebaut werden dürfen.

## 3. Aufgabenteilung

### 3.1 Missionsdesigner

Der Missionsdesigner verantwortet Objekte und Eigenschaften, die im DCS Mission Editor angelegt oder visuell geprüft werden müssen:

- physische Platzierung;
- Parkpositionen und Rollwege;
- Client-Gruppen;
- Late-Activation-Templates;
- Static-Objekte;
- Liveries und sichtbare Markierungen;
- Zonen und Triggerzonen;
- FARP-, Helipad- und Warehouse-Infrastruktur;
- Rotor-, Flügel- und Sicherheitsabstände;
- Kollisions- und Spawnprüfung;
- Speicherung und Bereitstellung der `.miz`-Arbeits- und Testmission.

### 3.2 Entwicklung und Dokumentation

Die Entwicklung stellt vor oder parallel zur Platzierung bereit:

- verbindliche Gruppen-, Einheiten-, Static- und Zonennamen;
- aktive ORBAT-Konfiguration aus Dokument 19;
- Template- und Rollenmatrix;
- Payload- und Fähigkeitsmatrix;
- AIRWING- und SQUADRON-Konfiguration;
- Diagnose- und Validierungsskripte;
- Bestands-, Static-, Verlust- und Reservierungslogik;
- MEDEVAC-Paketkoordination;
- globale KI-Auftragsbegrenzung;
- CampaignState-, Persistenz- und Logging-Anbindung.

Der Missionsdesigner soll keine eigenen MOOSE-Strukturen, Bestandsregeln oder Benennungssysteme erfinden müssen.

## 4. Erforderliches Air Operations Manifest je Knoten

Vor der verbindlichen ME-Platzierung muss je Flugplatz oder Luftoperationsknoten ein Manifest mindestens enthalten:

| Bereich | Erforderlicher Inhalt |
|---|---|
| Autorität | Dokument-ID, Status, owning policy und gültige Projektphase |
| aktive Einheiten | Verband, Typ und lokaler Kampagnenbestand nach Dokument 19 |
| DCS-Typ | bestätigter interner Typname und Modulabhängigkeit |
| Client-Slots | Zahl gemäß Dokument 19 und vollständige Gruppen-/Einheitennamen |
| KI-Templates | Zahl, Gruppengröße, Rolle, Late Activation und vollständige Namen |
| Payloads | Rollen, Loadouts und Payload-Template-Namen |
| Statics | Zielzahl, Livery, Abstellbereich und Bestandsbezug |
| Warehouse | vorhandener oder technischer MOOSE-Anker |
| Parking | Kategorien, IDs, Blacklists und Sicherheitsabstände |
| Zonen | vollständige Zonenliste mit Zweck und Benennung |
| Tests | Diagnose-, Konstruktions-, Integrations- und Acceptance-Fälle |
| Provenienz | OMW-Branch/Commit, Mission/Hash, Bundle/Hash und MOOSE/Hash |

## 5. Gemeinsame Diagnosewerkzeuge

Je nach Knoten werden mindestens folgende Funktionen benötigt:

```text
DumpAircraftTypes.lua
DumpAirbaseParking.lua
ProbeWarehouseAnchor.lua
ValidateMissionTemplates.lua
```

Sie prüfen beziehungsweise ermitteln:

- tatsächliche DCS-Typnamen;
- Airbase- und Parking-IDs;
- Größe und Eignung von Parkpositionen;
- Erkennbarkeit benannter Warehouse-Anker;
- vorhandene Gruppen, Einheiten, Statics und Zonen;
- doppelte oder falsch benannte Missionsobjekte.

Die verwendete MOOSE-Version wird mit Commit und Dateihash festgeschrieben.

## 6. Gemeinsamer Missionseditor-Arbeitsablauf

### 6.1 Baseline sichern

1. Arbeitskopie der aktuellen Hauptmission oder des zuständigen Testharness erstellen.
2. Dateiname, Ausgangscommit und Hash dokumentieren.
3. Unbeteiligte Missionsobjekte unverändert lassen.
4. Änderungen ausschließlich für das definierte Arbeitspaket vornehmen.

### 6.2 Airbase, Warehouse und Parking

1. Airbase-ID und MOOSE-Name bestätigen.
2. Vorhandene Missionsobjekte auf Eignung als Warehouse-Anker prüfen.
3. Reine Kartenszenerie nicht als benanntes MOOSE-Objekt voraussetzen.
4. Bei Bedarf genau einen technischen Warehouse-Anker im Lagerbereich setzen.
5. Client-, KI-, Static-, Bereitschafts-, Logistik- und Entladeflächen trennen.
6. Parkpositionen und Blacklists dokumentieren.
7. Rollwege, Startflächen und Sicherheitsabstände freihalten.

### 6.3 Client-Gruppen

Die Zahl der Client-Luftfahrzeuge wird ausschließlich aus Dokument 19 übernommen und nicht in dieser Arbeitsliste dupliziert.

Verbindliche technische Regeln:

- ein Luftfahrzeug je Client-Gruppe;
- vollständige, eindeutige Gruppen- und Einheitennamen;
- keine Wiederverwendung als KI-Template;
- Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge;
- Modabhängigkeiten müssen sichtbar und deaktivierbar sein.

### 6.4 KI-Templates

KI-Templates werden grundsätzlich als `Late Activation` angelegt.

Zu dokumentieren sind:

- Rolle;
- Gruppengröße;
- Anzahl der MOOSE-Asset-Gruppen;
- Payload- und Fähigkeitszuordnung;
- Start- und Rückkehrverfahren;
- zulässige Parking-IDs und Blacklists;
- lokale und globale KI-Grenzen aus Dokument 18.

### 6.5 Statics

- Statics sind Teil des logischen Bestands und kein zusätzlicher Bestand;
- Staticflächen werden von operativen Spawn- und Parkpositionen getrennt;
- Statics werden nicht dauerhaft einem bestimmten Client oder Template zugeordnet;
- Zerstörung muss eindeutig erkannt und dem CampaignState gemeldet werden;
- sichtbare Zielzahlen stammen aus dem zuständigen Manifest und dürfen Dokument 19 nicht widersprechen.

### 6.6 Zonen

Zonen werden funktionsbezogen benannt und dokumentiert. Typische Bereiche:

- Static-Abstellung;
- KI-Spawn und Rückkehr;
- MEDEVAC-Bereitschaft;
- Logistik laden/entladen;
- Slingload;
- C-130-Entladung oder Abwurf;
- Test- und Sicherheitszonen.

Doppelte Zonen für denselben Zweck sind zu vermeiden.

## 7. Nach jedem ME-Arbeitsstand bereitzustellen

- aktuelle `.miz` mit Hash;
- zugehörige `dcs.log` eines kontrollierten Testlaufs;
- Screenshots der betroffenen Park-, Roll-, Spawn- und Static-Bereiche;
- Liste nicht verfügbarer Typen oder Liveries;
- dokumentierte Spawn-, Taxi-, Rotor-, Kollisions- oder Rückkehrprobleme;
- aktualisiertes Manifest beziehungsweise Acceptance-Protokoll.

## 8. Mindesttest je Luftoperationsknoten

1. Missionsstart ohne relevante Lua-Fehler.
2. Airbase und Warehouse-Anker werden erkannt.
3. Erwartete Gruppen, Einheiten, Statics und Zonen sind vorhanden.
4. Client-Gruppen entsprechen Dokument 19.
5. Jedes KI-Template kann kontrolliert erzeugt werden.
6. Multi-Ship-Gruppen erscheinen kollisionsfrei.
7. Parking-Blacklist und sichere Parkpositionen wirken.
8. AIRWING und SQUADRONs werden ohne ungewollte Missionen gestartet.
9. Rückkehr, Freigabe und Verlust verändern Bestände nicht doppelt.
10. Testnachweis enthält Branch, Commit, Mission, Bundle, DCS- und MOOSE-Version.

## 9. Jalalabad als technischer Teststand

Die Jalalabad-Testmission und ihre Acceptance-Berichte bleiben als technische Evidenz erhalten. Sie beweisen ausschließlich den jeweils dokumentierten Teststand.

Der technische Branch ist weiterhin Draft:

- [PR #18 – Validate Jalalabad / FOB Fenty Air Operations baseline](https://github.com/birkenmoped/Operation-Mountain-Watch/pull/18)

Nicht auf `main` vorhandene Dokumente oder Testergebnisse aus PR #18 dürfen nur als branchgebundene technische Evidenz zitiert werden, nicht als vorhandene `main`-Dateien.

## 10. Übertragung und Parallelisierung

Gemeinsame Muster, Namenskonventionen und validierte MOOSE-Verfahren dürfen wiederverwendet werden. Ungeprüft übernommen werden dürfen jedoch nicht:

- Parking-IDs;
- Blacklists;
- Warehouse-Anker;
- DCS-Typen und Liveries;
- Template-Gruppengrößen;
- Static-Zahlen;
- lokale Bestände;
- Zonenlagen;
- Acceptance-Status.

Jeder Knoten erhält eine eigene Prüfung. Parallelisierung im Foundation Build ändert nichts an dieser lokalen Abnahmepflicht.

## 11. Unmittelbare Arbeitsgrundlage

Die nächste ME-Arbeit richtet sich nicht mehr nach einer exklusiven Jalalabad-first-Folge, sondern nach:

- Dokument 38 als Master-Worklist;
- Dokument 19 für aktive Luft-ORBAT und Client-Grenzen;
- Dokument 18 für gemeinsame technische Regeln;
- den jeweils vorhandenen oder als Draft gekennzeichneten Basenmanifesten.

Arbeitspakete dürfen parallel vorbereitet werden. Produktive Aktivierung erfolgt je Knoten erst nach dessen eigener Acceptance.