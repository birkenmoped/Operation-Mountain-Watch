# Jalalabad Air Operations Phase 1: Fehleranalyse, verbindliche Architektur und Schutzregeln

Stand: 2026-07-25  
Geltungsbereich: Jalalabad / FOB Fenty AIRWING Phase 1 und alle daraus abgeleiteten Air-Operations-Knoten  
Status: verbindliche Projektregel; die korrigierte Laufzeitarchitektur ist bis zum erneuten DCS-Test noch nicht abgenommen

## 1. Zweck dieses Dokuments

Dieses Dokument hält die Fehlannahmen, Fehlentscheidungen, Testbefunde, Korrekturen und verbindlichen Absprachen aus der Jalalabad-Phase-1-Entwicklung fest.

Es ist ausdrücklich kein unverbindlicher Erfahrungsbericht. Die hier definierten Trennungen, Paketverträge, Prüfregeln und Arbeitsgrenzen gelten für alle weiteren Flugplätze. Eine spätere Implementierung darf diese Regeln nicht stillschweigend verändern oder durch nachgelagerte Lua-Korrekturschichten umgehen.

Das zentrale Problem der bisherigen Entwicklung war nicht ein einzelner DCS- oder MOOSE-Fehler. Mehrere fachlich unterschiedliche Ebenen wurden vermischt und anschließend mit lokalen Workarounds korrigiert. Dadurch entstanden technisch lauffähige, aber operationell falsche Zustände.

## 2. Die Ebenen, die strikt getrennt bleiben müssen

### 2.1 Logischer Gesamtbestand

Der logische Bestand beschreibt, wie viele Luftfahrzeuge die Einheit in der Kampagne besitzt.

Für Jalalabad gilt:

```text
OH-58D: 24 Luftfahrzeuge
AH-64D:  8 Luftfahrzeuge
UH-60:   8 Luftfahrzeuge
CH-47:   8 Luftfahrzeuge
```

Dieser Bestand ist weder die Zahl sichtbarer Statics noch automatisch die Zahl der MOOSE-Assets oder gleichzeitig aktiver Gruppen.

### 2.2 MOOSE-Templates als technische Kopiervorlage

Ein Late-Activation-Template im Missionseditor ist eine technische Vorlage für MOOSE. Es definiert unter anderem:

- DCS-Flugzeugtyp;
- Anzahl der Einheiten in einer physischen DCS-Gruppe;
- Livery und Ausrüstung;
- interne Gruppen- und Einheitenstruktur;
- Ausgangswerte für von MOOSE erzeugte Laufzeitgruppen.

Das Template ist keine dauerhaft aktive Bestandsmaschine und keine sichtbare Ramp-Darstellung. Es ist auch kein zusätzlicher kampagnenlogischer Bestand.

### 2.3 Dynamische AIRWING-Spawns

AIRWING und SQUADRON erzeugen zur Laufzeit DCS-Gruppen aus den Templates. Entscheidend ist die physische Gruppengröße:

```text
Template mit 2 Einheiten + SetGrouping(2)
= eine physische DCS-Gruppe mit Lead und Wingman

Template mit 1 Einheit + SetGrouping(1)
= eine physische Single-Ship-DCS-Gruppe
```

`SetGrouping(...)` ist kein kosmetischer Parameter. Er bestimmt die tatsächliche Laufzeitstruktur. Zwei getrennte Single-Ship-Assets sind kein physisches Two-Ship und besitzen keinen gemeinsamen DCS-Gruppenführer.

### 2.4 Sichtbare statische Bestandsmaschinen

Statics stellen einen sichtbaren Teil des Bestands auf der Ramp dar. Sie sind keine AIRWING-Assets, werden nicht durch taktische AUFTRAG-Missionen beauftragt und dürfen nicht in die dynamische Asset-Zählung eingerechnet werden.

Sie können reale DCS-Parkknoten belegen. Solche Positionen müssen explizit als beabsichtigte Reservierungen dokumentiert und für dynamische Spawns gesperrt werden.

### 2.5 Client-Gruppen

Client-Gruppen sind Spielerplätze. Sie sind weder technische MOOSE-Templates noch automatisch verfügbare KI-Assets. Ihre Parkpositionen müssen vor dynamischen Spawns geschützt werden.

### 2.6 Taktisches Paket

Ein taktisches Paket beschreibt die operationelle Zusammenarbeit mehrerer Luftfahrzeuge oder Gruppen. Es ist von der physischen DCS-Gruppenstruktur zu unterscheiden.

Beispiele:

- OH-58D RECON: ein physisches Two-Ship;
- AH-64D CAS: ein physisches Two-Ship;
- UH-60 MEDEVAC: zwei physische Single-Ships, aber ein koordiniertes Lead-/Guard-Paket;
- CH-47 Cargo: ein physisches Single-Ship und zugleich ein Ein-Luftfahrzeug-Paket.

## 3. Verbindlicher Paketvertrag

Die Paketstruktur darf nicht mehr ad hoc in SQUADRON-, Factory- oder Testdateien erfunden werden. Sie wird zentral definiert und von allen Komponenten gelesen.

| Rolle | ME-Template | DCS-Gruppenmodell | MOOSE-Gruppierung | Auftrag | Asset-Gruppen |
|---|---:|---|---:|---|---:|
| OH-58D RECON | 2 Einheiten | eine physische Two-Ship-Gruppe | 2 | 1 Gruppe / 2 Luftfahrzeuge | 12 |
| AH-64D CAS | 2 Einheiten | eine physische Two-Ship-Gruppe | 2 | 1 Gruppe / 2 Luftfahrzeuge | 4 |
| UH-60 Utility | 1 Einheit je Template | unabhängige Single-Ships | 1 | je nach Auftrag | 8 |
| UH-60 MEDEVAC | Lead 1 + Guard 1 | zwei Single-Ship-Gruppen | 1 + 1 | ein koordiniertes Paket | aus UH-60-Bestand |
| CH-47 Cargo | 1 Einheit | eine Single-Ship-Gruppe | 1 | 1 Gruppe / 1 Luftfahrzeug | 8 |

Zwingende Rechenregeln:

```text
AssetGroups × Grouping = InventoryAircraft
RequiredGroups × Grouping = RequiredAircraft
```

Für ein koordiniertes Mehrgruppenpaket wie UH-60 MEDEVAC wird die zweite Regel durch einen Paketkoordinator ergänzt. Der Koordinator muss beide Gruppen atomar reservieren, getrennte Rollen vergeben und den gemeinsamen Lifecycle überwachen.

## 4. Fehlerchronik und Ursachen

### 4.1 Type-only-Matching beanspruchte fremde Client-Ereignisse

Ein früher Observer ordnete Ereignisse anhand des Luftfahrzeugtyps provisorisch der aktiven Mission zu. Dadurch konnte eine vorhandene Client-OH-58 als Missionsmaschine gezählt werden, während die tatsächlich von MOOSE erzeugte Gruppe als unerwartet behandelt wurde.

Ursache:

- Typgleichheit wurde mit Missionszugehörigkeit verwechselt;
- die exakten MOOSE-AID-Gruppennamen waren noch nicht registriert;
- ein Fallback akzeptierte Ereignisse, bevor die Identität sicher war.

Verbindliche Korrektur:

- keine typbasierte Zuordnung;
- exakter SQUADRON-/AID-Gruppenpräfix;
- exakte Einheitenregel `<group>-01`, bei physischen Two-Ships zusätzlich `<group>-02`;
- Authoring- und Client-Namen sind explizit ausgeschlossen;
- ein Ereignis ohne belegte exakte Identität wird nicht gezählt.

### 4.2 Two-Ship-Templates wurden durch `SetGrouping(1)` zerstört

OH-58D und AH-64D waren im Missionseditor korrekt als Two-Ship-Templates angelegt. Der Code prüfte teilweise sogar, dass zwei Einheiten vorhanden waren. Anschließend wurde jedoch `SetGrouping(1)` gesetzt.

Folge:

- MOOSE erzeugte zwei unabhängige Single-Ship-Gruppen;
- DCS hatte keinen gemeinsamen Lead/Wingman-Verband;
- Maschinen starteten und flogen zeitlich sowie räumlich auseinander;
- ein sogenanntes „logical Two-Ship aus zwei Assets“ besaß nicht die taktischen Eigenschaften eines Two-Ships.

Fehlannahme:

Ein operationelles Two-Ship könne durch zwei getrennt beauftragte Single-Ships ersetzt werden, solange der Test insgesamt zwei Luftfahrzeuge zählt.

Diese Annahme ist verworfen. Für OH-58D und AH-64D gilt ein physisches Two-Ship als eine DCS-Gruppe.

### 4.3 Ein AH-64D-Landeproblem wurde auf der falschen Ebene gelöst

Im ersten AH-64D-Two-Ship-Test landete der Lead, während der Wingman weiter kreiste. Statt die Rückkehr-, Lande-, Despawn- oder Lifecycle-Logik zu analysieren, wurde die physische Gruppe in zwei Single-Ships aufgeteilt.

Damit wurde das Symptom umgangen, aber die operationelle Formation zerstört.

Verbindliche Regel:

Ein Lifecycle- oder DCS-AI-Problem darf nicht durch eine fachlich falsche Änderung des Paketmodells gelöst werden. Formation, Auftrag, Routing, Landung, Despawn und Testauswertung sind getrennte Problemfelder.

### 4.4 OH-58D-Auftrag war operationell ungeeignet

Beobachtete Fehler:

- RECON-Zonen lagen zu weit entfernt beziehungsweise in ungeeignetem Gebirgsgelände;
- der Hinflug erfolgte teilweise auf gleichmäßiger Höhe;
- der Rückflug ging vom letzten Punkt direkt nach Jalalabad;
- DCS flog den Rückweg im Konturenflug;
- starke Steigungen und Gebirgskämme führten zu problematischem Flugverhalten;
- am Ziel traten enge Drehbewegungen beziehungsweise „Pirouetten“ auf;
- die Maschinen verbrauchten zu viel Zeit und Kraftstoff und landeten außerhalb des Flugplatzes.

Technische Fehlannahmen:

- ein einziger RECON-Höhenwert sei für alle Strecken ausreichend;
- `4000 ft` sei eine sichere Geländeüberhöhung, obwohl der MOOSE-Parameter ASL und nicht AGL bezeichnet;
- MOOSE oder DCS würden automatisch einen operationell sicheren Rückkorridor wählen;
- die letzte RECON-Zone könne ohne explizite Egress-Route direkt mit dem Flugplatz verbunden werden.

Verbindliche Korrektur:

- Hin- und Rückroute werden als vollständiger Korridor betrachtet;
- der Rückflug darf nicht automatisch als direkte Linie vom letzten Zielpunkt zum Flugplatz entstehen;
- für den aktuellen Test ist der Rückkorridor `RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad` vorgesehen;
- Missionshöhe muss gegen tatsächliche Geländehöhen geprüft werden;
- operationelle Eignung wird in DCS visuell und über Logs geprüft, nicht allein aus erfolgreicher AUFTRAG-Erzeugung abgeleitet.

### 4.5 Erfundenes Entfernungs- und Kraftstoff-Gate

Nach dem operationellen OH-58D-Fehlschlag wurden harte Grenzen eingeführt:

- 18.000 m maximale Entfernung einer Zone;
- 11.000 m maximale Teilstrecke;
- 42.000 m maximale Gesamtroute;
- 1.300 m maximale Geländehöhe;
- 6.500 ft maximale Missionshöhe.

Diese Werte waren heuristisch und nicht aus DCS-Verbrauchsdaten, Flugleistungsdaten oder einer belastbaren Missionszeitberechnung abgeleitet. Eine Zone wurde wegen 1.438 m Überschreitung blockiert, ohne dass daraus ein realer Kraftstoff- oder Flugleistungsfehler folgte.

Verbindliche Regel:

- frei gesetzte Sicherheitswerte dürfen nicht als physikalisch begründete Grenzwerte dargestellt werden;
- geometrische Werte dürfen zunächst Telemetrie oder Warnungen erzeugen;
- Kraftstoffgrenzen erfordern empirische DCS-Messungen oder ein dokumentiertes Leistungsmodell;
- blockiert werden nur objektive Konfigurationsfehler, etwa fehlende Zonen, nicht lesbare Koordinaten oder nicht erzeugbare Routen.

Erforderliche Fuel-Telemetrie:

- Spawn;
- Engine Start;
- Takeoff;
- Eintritt in jede RECON-Zone;
- Beginn RTB;
- Landung;
- Simulationszeit, Fuel-Prozent, MSL-Höhe und Gelände-MSL.

### 4.6 Ein RECON-Fehler blockierte alle anderen Tests

Die erste Safety-Implementierung führte eine gemeinsame Vorprüfung für das gesamte Testpaket aus. Ein OH-58D-Routenfehler verhinderte dadurch auch AH-64D, UH-60 und CH-47.

Zusätzlich wurde der konkrete Fehlertext verworfen und pauschal als `mission-editor-objects-missing` gemeldet, obwohl die ME-Objekte vorhanden waren.

Verbindliche Korrektur:

- globales Gate nur für gemeinsame Basisbedingungen;
- auftragsspezifische Readiness pro Test;
- exakter Blockgrund wird bis F10 und Log weitergereicht;
- ein Fehler eines Auftrags darf unabhängige Testfälle nicht sperren.

### 4.7 UH-60-TROOPTRANSPORT meldete Erfolg ohne Transportflug

Beobachtung:

- UH-60 spawnte, flog aber nicht;
- Infanterie bewegte sich vom Startort weg;
- die Mission meldete nach wenigen Sekunden Erfolg beziehungsweise wurde beendet;
- Engine Start, Takeoff und Landing standen auf null.

Ursache:

- Erfolg wurde im Wesentlichen aus „Infanterie befindet sich in der Entladezone“ abgeleitet;
- es fehlte der nachgewiesene Pickup-/Transport-/Dropoff-Lifecycle;
- eine eigenständige Bewegung oder ungünstige Zonenlage konnte das Ziel erfüllen;
- der Transporttest wurde sprachlich mit dem späteren MEDEVAC-Paket vermischt.

Verbindliche Korrektur:

- dedizierte, getrennte Load- und Drop-Zonen;
- Infanterietemplate ohne eigene Marschroute;
- Takeoff muss vor Zielerfüllung nachgewiesen sein;
- Pickup muss beobachtet werden;
- Dropoff muss nach Pickup in der Zielzone beobachtet werden;
- Rückkehr und Landung werden separat ausgewertet;
- `UH60_TROOP` ist ein Single-Ship-Transporttest und kein vollständiger MEDEVAC-Test.

### 4.8 UH-60 MEDEVAC ist ein Paket, kein einzelner Auftrag

Die vorhandenen Templates sind absichtlich getrennt:

```text
MEDEVAC Lead:  1 UH-60
MEDEVAC Guard: 1 UH-60
```

Das ist fachlich korrekt, weil Lead und Guard verschiedene Rollen und möglicherweise verschiedene AUFTRAG-Typen besitzen. Es fehlt noch der Runtime-Koordinator, der aus beiden Single-Ships ein gemeinsames Paket bildet.

Verbindliche Anforderungen an den späteren Koordinator:

- atomare Reservierung von Lead und Guard;
- kein Start eines unvollständigen Pakets;
- gemeinsame Package-ID;
- getrennte Rollen und Payloads;
- koordinierter Start;
- Guard bleibt beim Lead beziehungsweise schützt dessen Route und Einsatz;
- gemeinsamer RTB-/Abbruchentscheid;
- getrennte Verlustzählung, aber gemeinsamer Paketstatus;
- vollständige Freigabe erst nach Abschluss beider Gruppen.

### 4.9 CH-47 erfüllte den Auftrag, der Testcontroller wertete ihn falsch

Der CH-47 führte den Frachttransport operationell korrekt aus. MOOSE meldete jedoch nach Zielerfüllung zusätzliche Terminalzustände wie `CANCELLED`, `DONE` oder `FAILED`. Der Controller behandelte diese Zustände zunächst als Auftragsscheitern.

Fehlannahme:

Der native MOOSE-Terminalstatus sei alleinige Wahrheit, obwohl das physische Ziel bereits nachweislich erfüllt war.

Verbindliche Korrektur:

- physische Zielerfüllung und MOOSE-Zustand werden getrennt erfasst;
- Terminalzustände dürfen nur normalisiert werden, wenn die physische Zielerfüllung eindeutig belegt ist;
- ohne belegte Cargo-Zustellung bleibt ein `FAILED` oder `CANCELLED` ein Fehler;
- Tests dürfen MOOSE-Semantik nicht pauschal überstimmen.

### 4.10 Landungen wurden gezählt, aber ein veraltetes Pending-Kriterium blieb sichtbar

In einem Lauf wurden beide OH-58D-Landungen korrekt gezählt, während der Status weiterhin `landing-count-mismatch` anzeigte.

Ursache:

Ein älteres Pending-Kriterium wurde nicht aktualisiert, nachdem die Bedingung erfüllt war.

Verbindliche Regel:

- Statusausgaben sind abgeleitete Momentaufnahmen und müssen bei jedem Poll aus dem aktuellen Zustand neu berechnet werden;
- ein erfülltes Kriterium darf nicht als stale text erhalten bleiben;
- nach vollständiger Landung, aber vor Bestandsfreigabe lautet der Zustand beispielsweise `awaiting-inventory-release`.

### 4.11 Flugzeugzahl, DCS-Gruppen und MOOSE-Assets wurden verwechselt

Die Werte `24/8/8/8` wurden zeitweise als Zahl der Asset-Gruppen verwendet. Bei physischen Two-Ships ist das falsch.

Korrekt:

```text
Luftfahrzeuge:  OH58D 24 / AH64D 8 / UH60 8 / CH47 8
Asset-Gruppen:  OH58D 12 / AH64D 4 / UH60 8 / CH47 8
```

Diese Unterscheidung beeinflusst:

- SQUADRON-Bestand;
- `SetRequiredAssets`;
- Reservation Bounds;
- Runtime-Gruppenzählung;
- Inventarfreigabe;
- Parallelitätsgrenzen;
- Verlustbuchung.

### 4.12 Zu viele nachgelagerte Override-Dateien erzeugten eine versteckte Wahrheit

Die Dateien `17`, `18`, `19` und `19a` überschrieben schrittweise bereits definierte Werte und Funktionen. Die effektive Konfiguration hing damit von der Bundle-Reihenfolge ab.

Folgen:

- Manifest und Laufzeit konnten unterschiedliche Gruppenmodelle enthalten;
- ältere Kommentare und Logmeldungen beschrieben bereits verworfene Zustände;
- Observer, Factory und Controller besaßen unterschiedliche Erwartungen;
- eine weitere Korrektur konnte eine frühere Korrektur unbemerkt neutralisieren.

Verbindliche Regel:

- Paketmodell, Grouping, ExpectedGroups, ExpectedAircraft, Suffixe und Asset-Bestand haben genau eine kanonische Quelle;
- nachgelagerte Dateien dürfen keine grundlegenden Architekturwerte still überschreiben;
- temporäre Kompatibilitätsschichten müssen eng begrenzt, dokumentiert und später entfernt werden;
- Builder-Reihenfolge darf nicht als Konfigurationsmechanismus missbraucht werden.

## 5. Mission Editor, Repository und Zuständigkeiten

### 5.1 Zuständigkeit des Assistenten

Der Assistent bearbeitet:

- Lua-Quellen;
- Builder;
- statische Prüfungen;
- GitHub-Dokumentation;
- Branch-Commits;
- Auswertung bereitgestellter DCS-Logs.

### 5.2 Zuständigkeit des Projektinhabers

Der Projektinhaber bearbeitet:

- lokale Repository-Aktualisierung;
- lokalen Bundle-Build;
- Einbindung des Bundles über `DO SCRIPT FILE`;
- Änderungen an `.miz` und Missionseditorobjekten;
- Speichern oder Umbenennen der Mission;
- DCS-Testlauf;
- Bereitstellung von `dcs.log`, Debrief und Beobachtungen.

### 5.3 Verbindliche Grenze

Ohne ausdrückliche Anforderung darf der Assistent keine `.miz` erstellen, verändern, vorbereiten oder unter einem neuen Namen ausgeben.

Jede Missionseditor-Anweisung beginnt mit einer eindeutigen Aussage:

- bestehende Mission unverändert weiterverwenden;
- unter neuem Namen speichern;
- oder noch nicht im Missionseditor arbeiten.

Diese Grenze wurde zuvor verletzt, als ohne Auftrag eine neue `.miz` vorbereitet wurde. Das führte zu unnötiger Verzögerung und ist nicht zu wiederholen.

## 6. Test- und Abnahmeregeln

### 6.1 Keine Laufzeitbehauptung ohne DCS-Nachweis

Erlaubte Statusklassen:

```text
IMPLEMENTED
STATIC CHECK PASS
DCS VALIDATION PENDING
DCS PASS
DCS FAIL
```

Ein erfolgreicher Lua-Build, ein syntaktisch gültiges Bundle oder eine plausible MOOSE-Dokumentation ist kein DCS-PASS.

### 6.2 Ein Pakettyp nach dem anderen

Reihenfolge:

1. OH-58D physisches Two-Ship;
2. AH-64D physisches Two-Ship;
3. UH-60 Single-Ship-TROOPTRANSPORT;
4. CH-47 Single-Ship-CARGOTRANSPORT;
5. UH-60-Abbruchtest;
6. erst danach Gesamtablauf;
7. MEDEVAC-Lead-/Guard-Paket als eigener späterer Meilenstein.

### 6.3 Operationeller Erfolg ist mehr als ein technischer Lifecycle

Ein Test gilt nur dann als fachlich bestanden, wenn zusätzlich zu Spawn, Takeoff, Ziel, Landung und Freigabe auch das beobachtete Verhalten sinnvoll ist.

Beispiele für operationelle FAIL-Kriterien:

- Two-Ship fliegt über längere Zeit mehrere Meilen auseinander;
- Rückroute führt unkontrolliert direkt über ungeeignetes Gebirge;
- Aufklärer kreisen ohne nachvollziehbare Aufgabe;
- Transporthubschrauber erfüllt das Ziel ohne Pickup-/Transportflug;
- Guard ist nicht beim Lead;
- Maschine rollt oder fliegt in einer für die Rolle unplausiblen Weise, sofern eine geeignete MOOSE-/DCS-Option vorhanden ist.

### 6.4 Jede Behauptung muss einer Ebene zugeordnet sein

Bei Fehleranalyse und Dokumentation ist anzugeben, ob eine Aussage betrifft:

- logischen Bestand;
- ME-Template;
- physische DCS-Gruppe;
- MOOSE-Asset;
- taktisches Paket;
- sichtbares Static;
- Client-Slot;
- AUFTRAG-Zustand;
- physischen Zielzustand;
- Testcontroller-Zustand.

Unpräzise Aussagen wie „zwei Assets sind ein Two-Ship“ sind unzulässig.

## 7. Pflichtprüfungen vor jedem weiteren Flugplatz

Ein weiterer Air-Operations-Knoten darf erst begonnen werden, wenn für Jalalabad mindestens Folgendes in DCS nachgewiesen ist:

- Paketvertrag lädt ohne Fehler;
- OH-58D: eine Gruppe, zwei Einheiten, Formation, sichere Rückroute, zwei Landungen, Freigabe;
- AH-64D: eine Gruppe, zwei Einheiten, gemeinsamer Einsatz, zwei Landungen, Freigabe;
- UH-60-TROOP: echter Pickup, Transport, Dropoff, RTB, Landung, Freigabe;
- CH-47: physische Cargo-Zustellung, RTB, Landung, korrekte Terminalnormalisierung, Freigabe;
- Client-Parking bleibt frei;
- Statics werden nicht als AIRWING-Bestand gezählt;
- Template-Gruppen bleiben technische Authoring-Seeds und belegen keine dynamischen Slots;
- keine typbasierte Ereigniszuordnung;
- keine stale Pending-Meldungen;
- kein globales Blockieren unabhängiger Tests durch einen auftragsspezifischen Fehler;
- keine harte Fuel-/Range-Grenze ohne dokumentierte Berechnungsgrundlage;
- keine grundlegende Architekturdefinition in einer späten Override-Datei.

## 8. Voraussetzungen für dynamische Spieleranforderungen

Die dynamische, spielergesteuerte Auftragsschicht darf erst auf den deterministisch getesteten Paketverträgen aufbauen.

Geplanter Ablauf:

```text
Spieleranfrage
-> Auftragstyp und Ziel validieren
-> Paketvertrag auswählen
-> vollständigen Bestand atomar reservieren
-> physische Gruppe oder koordiniertes Paket erzeugen
-> Route und Rolle konfigurieren
-> Lifecycle und physisches Ziel überwachen
-> RTB/Abbruch/Verlust auswerten
-> Bestand korrekt freigeben oder Verlust buchen
```

Der spätere Planner darf Grouping, TemplateUnits oder Paketmodell nicht ändern. Er wählt einen vorhandenen Vertrag aus.

Für Mehrgruppenpakete gilt:

- keine Teilreservierung;
- keine unbegleitete Lead-Mission, wenn der angeforderte Vertrag Guard verlangt;
- gemeinsame Package-ID;
- klarer Gesamtstatus und separate Gruppenstatus;
- Paketverlust und Einzelverlust müssen unterscheidbar sein.

## 9. Verbindliche Arbeitsweise bei Änderungen

Vor jeder Änderung:

1. Ist das Problem fachlich, MOOSE-semantisch, DCS-AI-bezogen, Routing-bezogen oder nur Testcontroller-bezogen?
2. Welche Ebene ist tatsächlich fehlerhaft?
3. Verändert der geplante Fix das Paketmodell?
4. Widerspricht der Fix dem ME-Template oder dem zentralen Vertrag?
5. Gibt es eine MOOSE-Funktion, die zuerst geprüft werden muss?
6. Welche konkrete Log- oder DCS-Beobachtung belegt die Ursache?
7. Welche Regressionstests verhindern die Wiederholung?

Nicht zulässig:

- Architekturänderung als schneller Workaround;
- erfundene physikalische Grenzwerte ohne Kennzeichnung;
- globaler Validator für unabhängige Aufträge;
- Aufsummieren von Flugzeugen, Gruppen und Assets in einer gemeinsamen Zahl;
- neue Override-Schicht statt Konsolidierung;
- DCS-PASS ohne DCS-Lauf;
- Änderung oder Erzeugung der `.miz` ohne Auftrag.

## 10. Aktueller Stand

Vor dieser Dokumentation wurde der Code auf einen zentralen Paketvertrag umgestellt:

```text
OH58D: 1 x 2
AH64D: 1 x 2
UH60:  unabhängige 1 x 1 Assets
CH47:  1 x 1
Asset-Gruppen: 12 / 4 / 8 / 8
```

Der korrigierte Stand ist implementiert. Er ist noch nicht durch einen neuen DCS-Lauf abgenommen. Die nächste belastbare Aussage entsteht erst aus dem OH-58D-Einzeltest und anschließend dem AH-64D-Einzeltest.

## 11. Kernaussage

Die technische Vorlage, der dynamische Spawn, die sichtbare Ramp-Darstellung, der logische Bestand und das taktische Paket sind fünf verschiedene Dinge.

Eine Änderung auf einer Ebene darf nicht still die Bedeutung einer anderen Ebene verändern. Genau diese Vermischung hat die bisherigen vermeidbaren Fehler erzeugt. Der zentrale Paketvertrag und die in diesem Dokument festgeschriebenen Prüfregeln sind deshalb für alle weiteren Flugplätze verbindlich.
