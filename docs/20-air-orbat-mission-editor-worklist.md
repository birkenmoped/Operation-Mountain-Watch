# 20 – Missionseditor-Arbeitsliste für die Luft-ORBAT

## 1. Zweck und Autorität

Dieses Dokument trennt verbindlich:

1. Arbeiten des Missionsdesigners im DCS Mission Editor,
2. Aufgaben der Entwicklung und MOOSE-Integration,
3. basisbezogene Manifest- und Testanforderungen,
4. die Übertragung des validierten Jalalabad-Schemas auf weitere Basen.

Verbindliche Bezugsdokumente:

```text
docs/18-air-operations-implementation.md
docs/19-active-air-orbat-decisions.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Für jeden Flugplatz ist zusätzlich dessen eigenes Air Operations Manifest autoritativ.

Jalalabad:

```text
docs/21-jalalabad-air-operations-manifest.md
docs/23-jalalabad-parking-template-and-medevac-model.md
docs/24-jalalabad-ch47-static-parking-reservations.md
docs/25-jalalabad-final-validation-and-operational-baseline.md
```

Basisbezogene Manifeste dürfen strengere Limits als die globalen technischen Obergrenzen festlegen.

## 2. Aktueller Umsetzungsstatus

```text
Jalalabad / FOB Fenty:
Grundknoten vollständig aufgebaut und validiert

Bagram, Kandahar, Camp Bastion, Camp Dwyer, Khost, Tarinkot, Shindand:
basisbezogene Umsetzung noch ausstehend
```

Jalalabad dient als technischer Referenzknoten für:

- Warehouse-/Airbase-Verknüpfung,
- AIRWING-/SQUADRON-Grundaufbau,
- Missionseditor-Templatevalidierung,
- Spieler- und KI-Parkmodell,
- sichtbare Statics und virtuelle Reserve,
- absichtliche Static-Parking-Reservierungen,
- Parking-Blacklist,
- Safe Parking,
- fail-safe Abschlussgate,
- reproduzierbaren Build- und Testworkflow.

Nicht ungeprüft auf andere Basen übertragen werden:

- Bestandszahlen,
- Spielerlimits,
- Templategrößen,
- Static-Obergrenzen,
- Zonen,
- Parking-IDs,
- Liveries,
- Warehouse-Namen.

## 3. Verbindliche Umsetzungsreihenfolge

1. historische und missionsgestalterische ORBAT der Basis abschließen,
2. DCS-Kapazität und vorhandene Infrastruktur diagnostizieren,
3. basisbezogenes Manifest erstellen,
4. vollständige Namen und Mengen festlegen,
5. Missionseditor-Grundbestand in einem zusammenhängenden Arbeitsgang platzieren,
6. Diagnose-/Validator-Bundle bauen und einbetten,
7. vollständigen DCS-Acceptance-Lauf durchführen,
8. PASS-, PARTIAL- oder FAIL-Ergebnis dauerhaft dokumentieren,
9. erst nach Grundknoten-PASS taktische Missionen und Persistenz ergänzen.

Atmosphärischer RAT-Verkehr wird erst nach den operativen Knoten ergänzt.

## 4. Aufgabenteilung

### 4.1 Missionsdesigner

Verantwortlich für:

- physische Platzierung,
- Spieler- und Template-Parkpositionen,
- Clientgruppen,
- Late-Activation-Templates,
- Static-Objekte,
- Liveries und sichtbare Markierungen,
- Trigger- und Funktionszonen,
- FARP-, Helipad- und Warehouse-Infrastruktur,
- Rollwege und Abflugrichtungen,
- Rotor-, Flügel- und Objektabstände,
- erneute Auswahl gebauter Lua-Dateien in `DO SCRIPT FILE`,
- Speicherung der `.miz`,
- visuellen Testlauf.

### 4.2 Entwicklung

Verantwortlich für:

- historische und aktive ORBAT-Entscheidungen,
- verbindliche Gruppen-, Einheiten-, Static- und Zonennamen,
- CampaignState-/Inventarkonfiguration,
- Template-, Rollen- und Payload-Matrix,
- AIRWING-/SQUADRON-Konfiguration,
- Aktivitätsgrenzen,
- Verlust- und Reservelogik,
- Parking-Blacklist und Safe-Parking-Konfiguration,
- Diagnose- und Validierungsskripte,
- Builder,
- Acceptance-Kriterien,
- Ergebnisdokumentation,
- Persistenzanbindung.

Der Missionsdesigner soll keine eigenen MOOSE-Strukturen, Bestandsregeln oder Benennungssysteme erfinden müssen.

## 5. Vor jeder Missionseditor-Platzierung bereitzustellen

Für jede Basis wird ein Manifest erstellt mit:

| Bereich | Verbindlicher Inhalt |
|---|---|
| aktive Einheiten | Verband, Typ und logischer Bestand |
| historische Evidenz | Quellen, Momentaufnahmen und Unsicherheiten |
| DCS-Typ | bestätigt oder gezielt zu ermitteln |
| Darstellung | aktive Assets, Statics, virtuelle Reserve |
| Spieler-Slots | Anzahl und vollständige Namen |
| KI-Templates | Anzahl, Gruppengröße, Rolle und Namen |
| MOOSE-Bestand | SQUADRON-Asset-Gruppen und Gruppierung |
| Payloads | Rollen und Template-Zuordnung |
| Statics | Obergrenzen und zulässige Flächen |
| Warehouse | Anker und Airbase-Bezug |
| Parking | Kapazität, reservierte Flächen und Blacklist |
| Zonen | Namen und Zwecke |
| Verluste | Abzug, Nachrücken und Ramp-Aktualisierung |
| Testfälle | erwartete Logzeilen und PASS-Kriterien |

Zusätzliche Artefakte:

```text
mission/tests/<TEST>/src/
mission/tests/<TEST>/expected/
mission/tests/<TEST>/results/
tools/<BUILDER>.ps1
```

Die verwendete MOOSE-Version wird mit Commit und SHA-256 festgeschrieben.

## 6. Projektweiter Repository- und Buildablauf

Der vollständige Workflow steht in Dokument 22.

Standard:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch <TESTBRANCH>
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\<BUILDER>.ps1"
```

Danach:

1. Buildkopf und Bundlehash prüfen.
2. Bundle im Missionseditor erneut über `DO SCRIPT FILE` auswählen.
3. `.miz` speichern.
4. Acceptance-Test ausführen.
5. standardmäßig nur die neue `dcs.log` bereitstellen.
6. `.miz` zusätzlich bei Einbettungs-, Parking- oder Missionseditor-Unklarheiten.

Ein extern neu gebautes Bundle aktualisiert eine bereits gespeicherte `.miz` nicht automatisch.

## 7. Allgemeine Missionseditor-Regeln

### 7.1 Warehouse und Airbase

- pro AIRWING genau ein eindeutig benannter Warehouse-Anker,
- Warehouse, Airbase, Koalition und Storage vor AIRWING-Start validieren,
- technische Anker dürfen keine Roll-, Lande- oder Parkflächen blockieren,
- zusätzliche Tanks und Lagerobjekte nur als tatsächlich gewünschte Kampagneninfrastruktur.

### 7.2 Spieler-Slots

- grundsätzlich ein Spielerluftfahrzeug je DCS-Gruppe,
- Multicrew-Sitze sind keine zusätzlichen Luftfahrzeuge,
- Clientgruppen werden nicht als KI-Templates wiederverwendet,
- lokale Slotzahl folgt Manifest und Parkkapazität,
- optionale Community-Mod-Slots müssen vollständig deaktivierbar sein,
- unbesetzte Clientgruppen über Mission-Template-Datenbank validieren,
- MOOSE Safe Parking verwenden, wenn dynamische KI dieselbe Basis nutzt.

### 7.3 KI-Templates

- BLUE/RED und Land gemäß Manifest,
- eindeutige Gruppen- und Einheitennamen,
- Late Activation,
- nicht `Uncontrolled`, sofern nicht ausdrücklich anders festgelegt,
- typgerechter Startmodus,
- Gruppengröße muss zur SQUADRON-Bestandsrechnung passen,
- Template ist technische Vorlage und kein zusätzlicher Bestand,
- Payload und Rolle über AIRWING/SQUADRON registrieren.

### 7.4 Bestandsdarstellung

Verbindlich getrennt:

```text
logischer Bestand
aktive Spieler und KI
sichtbare Statics
virtuelle Reserve
```

Nicht jedes Bestandsflugzeug muss sichtbar oder auf einem eigenen Parking-Node stehen.

Ein endgültiger Verlust reduziert den logischen Bestand. Eine andere virtuelle Bestandsmaschine darf später nachrücken, stellt aber keinen externen Ersatz dar.

### 7.5 Statics

Regelfall:

- frei und plausibel auf Apronflächen,
- ausreichender Rotor-/Flügelabstand,
- keine unbeabsichtigte Blockade von Spawn-, Rückkehr- oder Rollflächen.

Zulässige Ausnahme:

Ein Static darf einen echten DCS-Parking-Node dauerhaft belegen, wenn:

1. die Belegung missionsgestalterisch erforderlich ist,
2. Static und TerminalID dokumentiert sind,
3. TerminalID technisch blacklisted wird,
4. verbleibende Kapazität ausreicht,
5. ein Validator die Reservierung bestätigt.

Jalalabad nutzt diese Ausnahme für vier CH-47-Statics auf TerminalIDs `23,35,37,49`.

### 7.6 Zonen

- vollständige Namen und Funktion vor Platzierung festlegen,
- keine doppelten Parallelzonen für dieselbe Funktion,
- Radius so klein wie möglich und so groß wie erforderlich,
- statische Darstellungszonen von operativen Lade-, Entlade- und Bereitschaftszonen trennen,
- reine Existenzprüfung und spätere operative Funktionsprüfung unterscheiden.

## 8. Validierter Jalalabad-Referenzstand

```text
logischer Bestand: 24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47
Clientgruppen: 6
KI-Templates: 5 Gruppen / 7 Luftfahrzeuge
Statics: 20
Zonen: 11
Warehouse: WH_AIR_US_JALALABAD
SQUADRONs: 4
Runtime-Parking: 10 oder 12 mit optionalem UH-60L
```

Technische Struktur:

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Final bestätigt:

```text
[OMW][AirOps.JBAD.PARKING] RESULT: PASS ...
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. ...
```

Der Jalalabad-Referenzstand ist in Dokumenten 21, 23, 24 und 25 vollständig beschrieben.

## 9. Test- und Freigaberegeln

Jeder basisbezogene Abschlusslauf muss mindestens prüfen:

- alle verpflichtenden ME-Objekte,
- exakte DCS-Typen,
- Templategrößen,
- SQUADRON-Bestandsberechnung,
- Warehouse-/Airbase-Zuordnung,
- Parking-Blacklist und Safe Parking,
- Zonen,
- AIRWING-/COMMANDER-Start,
- keine spontane KI-Mission ohne Auftrag,
- keine relevanten Lua-/Timerfehler.

Ergebnisse werden klassifiziert als:

```text
PASS
PARTIAL
FAIL
```

Jeder Lauf erhält einen eigenen Bericht unter `results/`. Fehlerhafte Zwischenstände werden nicht gelöscht, sondern mit Ursache, Korrektur und Nachtest dokumentiert.

## 10. Folgeentwicklung nach einem Grundknoten-PASS

Ein validierter Grundknoten ist noch keine vollständige Kampagnenfunktion.

Separat zu implementieren und zu testen sind:

- taktische AUFTRAG-Erzeugung,
- OPSTRANSPORT,
- Lade-/Entladezonenlogik,
- MEDEVAC-Laufzeitkoordination,
- persistente Bestands- und Verlustrechnung,
- persistente Ramp-/Static-Neuverteilung,
- Combat Damage, Recovery und Ersatzstatus.

Diese Folgestufen sollen einen validierten Grundknoten nur bei einer nachgewiesenen Regression wieder öffnen.
