---
document_id: OMW-MOOSE-FOG-OF-WAR-RECCE
status: PLANNED
authoritative_for:
  - MOOSE fog-of-war research basis
  - MOOSE reconnaissance capability assessment
  - INTEL, RECCE and player-recon integration constraints
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 40a6de25b36a821dd1cc37523620c82890ad3f3b
validated_in_dcs: false
document_class: MOOSE_CAPABILITY_ASSESSMENT
owning_policy: OMW-GOV-001
---

# MOOSE Fog of War, INTEL und RECCE/Aufklärung

## 1. Status und Abgrenzung

Dieses Dokument ergänzt die übergeordnete Architektur in:

- [`ISR-FAC-CAS-AAR.md`](ISR-FAC-CAS-AAR.md)
- [`PROJECT-CLASS-INDEX.md`](PROJECT-CLASS-INDEX.md)
- [`VERSION-AND-SOURCES.md`](VERSION-AND-SOURCES.md)

Die hier beschriebenen Fähigkeiten wurden am **27.07.2026** gegen die aktuelle offizielle MOOSE-Develop-Dokumentation geprüft. Sie sind **noch nicht als Laufzeitverhalten der in Operation Mountain Watch eingebundenen `Moose.lua` validiert**.

Es gelten daher zwei strikt getrennte Aussagen:

1. **In der MOOSE-Develop-Dokumentation vorhanden:** Die Klasse oder Methode ist im aktuellen Develop-Referenzstand dokumentiert.
2. **Für OMW verfügbar und verwendbar:** Erst nach Nachweis im tatsächlich geladenen MOOSE-Commit, Quellcodeprüfung und reproduzierbarem DCS-Test.

Der für bisherige Jalalabad-Tests rekonstruierte MOOSE-Stand ist in [`VERSION-AND-SOURCES.md`](VERSION-AND-SOURCES.md) dokumentiert. Aus der bloßen Existenz einer Develop-Seite darf keine Verfügbarkeit in diesem Commit abgeleitet werden.

## 2. Kernerkenntnis: kein einzelnes MOOSE-„Fog-of-War-Modul“

MOOSE besitzt keinen einzelnen Schalter oder eine einzelne Klasse, welche die DCS-F10-Karteneinstellung „Fog of War“ ersetzt.

Für OMW sind drei Ebenen zu trennen:

```text
DCS-Sichtbarkeit
- F10-Karteneinstellungen
- Koalitions- und Einheitenanzeige
- DCS-Sensor- und Erkennungsmodell

MOOSE-Lagebild
- erkannte Kontakte und Cluster
- letzte bekannte Positionen
- Sensor-/Agentennetz
- Ereignisse, Berichte und Marker

OMW-Kampagnenwissen
- langfristige Persistenz
- HUMINT und Missionsereignisse
- Zielprüfung, ROE und No-Strike-Regeln
- CampaignState, MissionGenerator und RedDirector
```

Die DCS-F10-Einstellung bleibt eine separate Missionsoption. MOOSE kann darauf aufbauend ein kontrolliertes missionslogisches Lagebild erzeugen, Berichte und Marker nur nach erkannter oder anderweitig freigegebener Information ausgeben und Folgemissionen auslösen.

Verbindliches Architekturprinzip:

```text
Eine gegnerische Einheit kann technisch in der Mission existieren,
ohne dass BLUE ihre Position, Identität oder Stärke kennt.
```

Direkte Skriptabfragen, Zonenscans, Marker, Aufgabenbriefings und automatische Zielzuweisungen dürfen dieses Prinzip nicht unbeabsichtigt umgehen.

## 3. `INTEL` als primäre taktische Lagebildklasse

### 3.1 Zweck

`INTEL` ist in der MOOSE-Develop-Dokumentation als leichtgewichtiger Nachfolger der älteren `DETECTION`-Architektur beschrieben. Die Klasse erkennt und verfolgt:

- einzelne Kontakte;
- räumliche Kontaktcluster;
- neue und verlorene Kontakte;
- neue und verlorene Cluster;
- erkannte Positionen und Bewegungsinformationen;
- Bedrohungsinformationen, soweit durch die Kontaktstruktur bereitgestellt;
- mit Kontakten oder Clustern verknüpfte MOOSE-Aufträge.

Die Aufklärungseinheiten werden als Agenten über ein `SET_GROUP` oder zur Laufzeit über `INTEL:AddAgent()` eingebunden.

### 3.2 Erkennungsarten

`INTEL:SetDetectionTypes()` erlaubt laut Develop-Dokumentation die getrennte Konfiguration folgender DCS-Erkennungsarten:

- visuell;
- optisch;
- Radar;
- IRST;
- RWR;
- Datalink.

Alle Parameter sind laut Dokumentation standardmäßig aktiviert. Für OMW darf diese Standardeinstellung nicht ungeprüft übernommen werden. Ein UAV, ein Bodenbeobachter, ein EWR und ein AWACS besitzen unterschiedliche Sensorrollen und müssen getrennt konfiguriert werden.

Zusätzlich dokumentiert sind:

- `INTEL:SetDetectStatics()` für statische Objekte;
- `INTEL:SetAccousticDetectionOn()` und `SetAccousticDetectionOff()` für eine ergänzende akustische Näherungserkennung.

Die akustische Erkennung ist eine abstrahierte MOOSE-Funktion und kein Ersatz für eine nachgewiesene reale Sensorsignatur. Radius, Einheitenkategorien und Gameplaywirkung sind in DCS zu testen.

### 3.3 Räumliche Begrenzung

Dokumentierte Begrenzungs- und Priorisierungsfunktionen umfassen:

- `SetAcceptRange()` – maximale akzeptierte Entfernung in Kilometern zu einem RECCE-Agenten;
- Accept Zones – nur Kontakte innerhalb definierter Zonen berücksichtigen;
- Reject Zones – Kontakte in definierten Zonen ausschließen;
- Conflict Zones – Konflikträume für die INTEL-Verarbeitung;
- Corridor Zones – definierte Korridore mit zusätzlichen Höhenbegrenzungen.

Mögliche OMW-Nutzung:

```text
UAV-Auftrag über Kunar
→ Agent erkennt technisch mehrere Objekte
→ akzeptiert werden nur Kontakte
  innerhalb der zugewiesenen NAI-/Recon-Zonen
  und innerhalb einer plausiblen Sensorreichweite
```

Damit lässt sich verhindern, dass ein einzelnes ISR-Asset aufgrund des DCS-Erkennungsmodells ein unrealistisch großes Gesamtgebiet aufklärt.

### 3.4 Kontakte, Cluster und Ereignisse

`INTEL` stellt FSM-Ereignisse und Callbacks für die Integration in OMW bereit. Besonders relevant sind:

- `NewContact`;
- `LostContact`;
- `NewCluster`;
- `LostCluster`.

Clusteranalyse wird über `SetClusterAnalysis()` aktiviert. Der Clusterradius kann angepasst werden.

Für OMW sind Cluster besonders für COIN-Lagen geeignet, in denen nicht jede einzelne gegnerische Einheit als exaktes Symbol ausgegeben werden soll. Ein Bericht kann stattdessen beispielsweise lauten:

```text
Verdächtige Fahrzeug-/Infanteriegruppe
ungefähre Stärke: klein
letzte Beobachtung: 14:32
Bewegung: südwestlich
Position: Suchgebiet, keine exakte Live-Markierung
```

### 3.5 Kontaktgedächtnis und veraltete Informationen

Die aktuelle Develop-Dokumentation nennt folgende interne Nachverfolgungszeiten für erkannte und noch lebende Objekte:

| Kategorie | dokumentierte Nachverfolgungszeit |
|---|---:|
| Flugzeuge | 10 Minuten |
| Hubschrauber | 20 Minuten |
| Schiffe und Züge | 1 Stunde |
| Bodeneinheiten | 2 Stunden |

Diese Werte sind MOOSE-Verhalten, keine automatisch geeigneten OMW-Gameplaywerte.

Wichtige Einschränkung:

`INTEL:SetForgetTime()` ist in der aktuellen Develop-Dokumentation ausdrücklich als **obsolete und nicht funktionsfähig** gekennzeichnet. OMW darf daher keine Architektur auf der Annahme aufbauen, dass sich die Kontaktvergessenszeit damit frei konfigurieren lässt.

Für das geplante OMW-Modell

```text
DETECTED → TRACKED → LOST → STALE → REACQUIRED
```

ist voraussichtlich eine dünne projektspezifische Schicht erforderlich, welche:

- den Zeitpunkt der letzten bestätigten Beobachtung speichert;
- die Informationsqualität reduziert;
- exakte Marker in Suchgebiete umwandelt;
- alte Kontakte aus Spieleraufträgen entfernt oder neu verifizieren lässt.

Diese Ergänzung darf nicht die grundlegende MOOSE-Erkennung parallel neu implementieren.

### 3.6 Extern eingespeiste Informationen und HUMINT

`INTEL:KnowObject(Positionable, RecceName, Tdetected)` kann laut Dokumentation ein noch nicht regulär erkanntes Objekt in das INTEL-Lagebild aufnehmen und dabei ein `NewContact`-Ereignis auslösen.

Mögliche OMW-Nutzung:

- Meldung einer Patrouille;
- Checkpoint-Bericht;
- Informanten-/HUMINT-Ereignis;
- gemeldeter IED- oder Camp-Verdacht;
- Sichtmeldung aus einem Dorf;
- missionsseitig bestätigter F10-Kontaktbericht.

`KnowObject()` darf nicht als pauschales Allwissen verwendet werden. Jede Einspeisung benötigt eine nachvollziehbare Informationsquelle, einen Zeitstempel und eine definierte Qualitätsstufe.

## 4. `INTEL_DLINK` als Aggregator getrennter Netze

Die Develop-Dokumentation enthält `INTEL_DLINK` als Datenaggregator für mehrere INTEL-Quellen.

Für OMW ist folgende Trennung als **Architekturkandidat** sinnvoll:

```text
AIR_SURVEILLANCE_INTEL
- AWACS
- EWR
- gegebenenfalls Kampfflugzeuge
- Radar, RWR und Datalink

GROUND_SURVEILLANCE_INTEL
- UAV
- OH-58D
- JTAC/FAC
- Beobachtungsposten
- optische, visuelle und begrenzte akustische Erkennung

HUMINT_INTEL
- Patrouillenberichte
- Informanten
- Dorf-/Checkpoint-Meldungen
- missionsseitig freigegebene Kontakte

           ↓
      INTEL_DLINK
           ↓
 freigegebenes BLUE-Lagebild
```

Vorteile:

- Sensorarten und Reichweiten bleiben getrennt;
- ein EWR wird nicht versehentlich zum Bodensensor;
- UAV-Berichte können andere Aktualitätsregeln erhalten als AWACS-Tracks;
- HUMINT kann als eigene, weniger genaue Informationsquelle behandelt werden;
- eine gemeinsame Ausgabeschicht kann Kontakte normalisieren.

Vor Übernahme in die verbindliche OMW-Architektur sind mindestens zu prüfen:

- Vorhandensein von `INTEL_DLINK` im eingebundenen MOOSE-Commit;
- genaue Cache- und Ablaufzeitsemantik;
- Kontakt-/Cluster-Deduplizierung;
- Verhalten bei widersprüchlichen Quellen;
- Performance und Multiplayer-Ausgabe.

## 5. `AUFTRAG:NewRECON()`

### 5.1 Dokumentierte Funktion

`AUFTRAG:NewRECON(ZoneSet, Speed, Altitude, Adinfinitum, Randomly, Formation)` erzeugt laut Develop-Dokumentation einen RECON-Auftrag für:

- Luftgruppen;
- Bodengruppen;
- Marinegruppen.

Konfigurierbar sind unter anderem:

- Aufklärungszonen;
- Geschwindigkeit;
- Flughöhe für Luftgruppen;
- wiederholtes Durchlaufen der Zonen;
- zufällige Reihenfolge;
- Formation.

### 5.2 Wichtige Architekturgrenze

`NewRECON()` ist zunächst ein **Bewegungs- und Missionsauftrag**. Aus der Erstellung eines RECON-Auftrags folgt nicht automatisch, dass die eingesetzte Gruppe Bestandteil des gewünschten OMW-INTEL-Netzes wird.

Erforderliche Kette:

```text
AIRWING / SQUADRON
→ AUFTRAG:NewRECON()
→ erzeugte oder gebundene FLIGHTGROUP
→ explizite Aufnahme als INTEL-Agent
→ Kontakt-/Clusterereignisse
→ OMW-Lagebild und Folgemissionen
```

Vor Implementierung ist zu klären, an welchem Lifecycle-Ereignis die tatsächlich eingesetzte Gruppe sicher als INTEL-Agent registriert und nach Verlust, Despawn oder Rückkehr wieder entfernt wird.

## 6. `PLAYERRECCE` für spielergeführte Aufklärung

### 6.1 Dokumentierte Fähigkeiten

`PLAYERRECCE` ist für spielergeführte Aufklärung und Zielmarkierung vorgesehen. Die aktuelle Develop-Dokumentation enthält unter anderem:

- Ermittlung sichtbarer Ziele über Kamera-/Blick- und Laserbereiche;
- Zielberichte an definierte Angriffs-Clients;
- Laser-Code-Verwaltung;
- Rauch- und weitere Markierungsfunktionen;
- BULLS-/Koordinatenmeldungen;
- SRS-/TTS-Ausgabe;
- Übergabe von Zielberichten an einen `PLAYERTASKCONTROLLER`;
- daraus resultierende Aufgaben für andere Spieler.

Für die OH-58D ist ausdrücklich `PLAYERRECCE:EnableKiowaAutolase()` dokumentiert. Die Klasse enthält außerdem Kiowa-spezifische MMS-/Sichtlogik.

### 6.2 Korrektur einer zu pauschalen Annahme

Die Aussage

```text
„MOOSE kann nicht erkennen, was ein Spieler sieht.“
```

ist zu pauschal.

Präziser gilt:

- MOOSE kann nicht die menschliche Interpretation des Bildschirminhalts oder Sensors „lesen“.
- `PLAYERRECCE` kann jedoch anhand der Spielerplattform, Kamera-/Sichtgeometrie, Laserzone und bekannter Zielobjekte ein eigenes Aufklärungsmodell bereitstellen.
- Dieses Modell muss für jedes verwendete Modul und den Multiplayerbetrieb validiert werden.

Für OMW ist `PLAYERRECCE` daher ein **ernsthafter Architekturkandidat** für OH-58D-gestützte Aufklärung und Zielübergabe, aber noch keine validierte oder verbindlich implementierte Funktion.

### 6.3 Möglicher OMW-Ablauf

```text
OH-58D-Spieler erkennt Ziel über PLAYERRECCE
→ Zielbericht wird erzeugt
→ Bericht an PLAYERTASKCONTROLLER
→ CAS-/Strike-Auftrag für andere Spieler
→ optional Laser-/Rauchmarkierung
→ BDA oder erneute Aufklärung
```

Zu testen sind insbesondere:

- OH-58D-MMS-Erkennung und Sichtfeld;
- Reichweite, LOS und Geländeverdeckung;
- Verhalten bei ausgeschaltetem oder bewegtem Sensor;
- Laser-Code und Auto-Lase;
- Mehrspieler-Menüs und Sichtbarkeit;
- versehentliche Erkennung außerhalb des tatsächlichen Sensorbereichs;
- Übergabe an `PLAYERTASKCONTROLLER`;
- Verhältnis zu INTEL: direkter INTEL-Eintrag, Player Task oder beides.

## 7. `TARS` für verzögerte Foto-/IMINT-Aufklärung

`TARS` simuliert laut Develop-Dokumentation Fotoaufklärung und visuelle Beobachtungsmissionen.

Dokumentierter Grundablauf:

```text
Spieler startet in zugelassenem Aufklärungsflugzeug/-hubschrauber
→ Film über F10-Menü aktivieren
→ Ziele innerhalb des Sensorprofils überfliegen
→ Aufnahme beenden oder Filmzeit ablaufen lassen
→ an verbündetem Flugplatz/FARP landen
→ Debrief und Datenverarbeitung
→ koalitionsbezogene F10-Marker
→ optional MOOSE-Scoring
```

Die Intel-Ausgabe erfolgt damit nicht sofort während des Überflugs, sondern nach gültiger Rückkehr und Debrief. Das eignet sich für:

- geplante Fotoaufklärungsmissionen;
- verzögerte IMINT-Auswertung;
- Bestätigung von Camps, Fahrzeugansammlungen oder Infrastruktur;
- BDA-Missionen;
- Aufklärung ohne permanentes Live-Datalink-Lagebild.

`TARS` ist für OMW zunächst **CANDIDATE**. Vor einer Architekturentscheidung sind zu prüfen:

- Existenz im eingebundenen MOOSE-Commit;
- unterstützte DCS-Module und Sensorprofile;
- Validierung von Loadout, Höhe und Flugprofil;
- Markerpräzision und Lebensdauer;
- Multiplayer- und Reconnect-Verhalten;
- Verbindung der TARS-Ergebnisse zu INTEL, TARGET und CampaignState;
- Eignung für den Afghanistan-Kampagnenzeitraum und das gewünschte Gameplay.

## 8. Ältere `DETECTION`-Klassen und `DESIGNATE`

Die MOOSE-Dokumentation bezeichnet `INTEL` als leichtgewichtigen Nachfolger der älteren `DETECTION`-Architektur.

Für neue OMW-Lagebildlogik gilt daher:

- `INTEL` ist die primäre geplante Kontaktverwaltung;
- `DETECTION_*` wird nicht parallel als zweites strategisches Lagebild aufgebaut;
- ältere Detection-Klassen werden nur dort eingesetzt, wo eine benötigte MOOSE-Funktion – insbesondere `DESIGNATE` – sie technisch voraussetzt oder wo ein DCS-Test einen konkreten Vorteil belegt.

`DESIGNATE` bleibt ein taktischer Markierungsbaustein für:

- Laser;
- Rauch;
- Beleuchtung;
- Zielberichte und Spieler-Menüs;
- priorisierte beziehungsweise automatische Designation.

`DESIGNATE` ersetzt weder INTEL noch die OMW-Kontaktqualität, ROE-, NSL- oder Kampagnenlogik.

## 9. `CHIEF` und die Grenze des echten Fog of War

`CHIEF` erweitert laut Develop-Dokumentation die INTEL-Architektur und kann erkannte Ziele, Bedrohungen, strategische Zonen und Folgeaufträge verwalten.

Für OMW bleibt `CHIEF` derzeit gemäß [`PROJECT-CLASS-INDEX.md`](PROJECT-CLASS-INDEX.md) **NOT_USED**. Zielauswahl, Kampagnenlogik und Auftragserzeugung verbleiben zunächst bei:

- `CampaignState`;
- `MissionGenerator`;
- `RedDirector`;
- den jeweiligen MOOSE-Adaptern.

Wichtige dokumentierte Einschränkung:

Der Besitz strategischer Zonen wird in `CHIEF` über Zonenscans und nicht über das Detection-Netz bestimmt. Die MOOSE-Dokumentation bezeichnet dies sinngemäß als „all knowing eye“ und schlägt die lokale Bevölkerung als spielerische Erklärung vor.

Falls `CHIEF` später erneut bewertet wird, muss OMW ausdrücklich entscheiden:

1. Wird der Zonenscan als HUMINT akzeptiert?
2. Welche Informationen dürfen daraus an Spieler oder automatische Auftragserzeuger gelangen?
3. Müssen CHIEF-Reaktionen zusätzlich durch bestätigte INTEL-Kontakte gesperrt werden?
4. Darf ein Zonenbesitzwechsel ohne Sensor- oder HUMINT-Ereignis bekannt werden?

Ohne diese Entscheidung kann `CHIEF` ein ansonsten kontrolliertes Fog-of-War-Modell umgehen.

## 10. Vorläufige OMW-Einordnung

| Baustein | OMW-Status | Einordnung |
|---|---|---|
| `INTEL` | `PLANNED` | Primäre taktische Kontakt- und Clusterverwaltung. |
| `AUFTRAG:NewRECON()` | `PLANNED` | RECON-Bewegungsauftrag; INTEL-Agentenbindung zusätzlich erforderlich. |
| `DETECTION_*` | `PLANNED`, eingeschränkt | Nur für abhängige Funktionen oder nachgewiesene Lücken; kein paralleles Hauptlagebild. |
| `DESIGNATE` | `PLANNED` | Taktische Markierung, nicht strategische Kontaktverwaltung. |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Sensor-/Informationsnetze. |
| `PLAYERRECCE` | `CANDIDATE` | Spielergeführte Aufklärung, besonders OH-58D. |
| `TARS` | `CANDIDATE` | Verzögerte Foto-/IMINT-Aufklärung nach Rückkehr. |
| `CHIEF` | `NOT_USED` | Derzeit keine OMW-Kampagnen- oder Auftragserzeugungsinstanz. |
| DCS-F10-Fog-of-War | Missionsoption | Separat von MOOSE; darf das OMW-Lagebild nicht durch Vollanzeige umgehen. |

## 11. Empfohlene Zielarchitektur zur weiteren Prüfung

```text
DCS-Sensoren / Spieler / HUMINT
              ↓
 getrennte INTEL-Quellen
              ↓
 optional INTEL_DLINK
              ↓
 OMW-Kontaktqualität und Track-Alter
              ↓
 TARGET / PLAYERTASKCONTROLLER / AUFTRAG
              ↓
 DESIGNATE / FAC / FACA / CAS / STRIKE
              ↓
 BDA und CampaignState
```

Dabei gelten folgende Regeln:

- Keine exakte Feindmarkierung ohne freigegebene Informationsquelle.
- Ein verlorener Track wird nicht als Live-Position weitergeführt.
- RECON-Mission und Sensor-/INTEL-Registrierung sind getrennte Schritte.
- Spieleraufklärung soll zuerst gegen `PLAYERRECCE` geprüft werden, bevor eine eigene parallele Sicht-/Laserlogik entsteht.
- Fotoaufklärung soll zuerst gegen `TARS` geprüft werden, bevor ein eigenes Film-/Debriefsystem entsteht.
- Automatische Folgemissionen benötigen weiterhin ROE-, NSL-, Freundnähe- und Kollateralschadensprüfung.
- `OPSZONE`-/`CHIEF`-Zonenscans dürfen nicht ungeprüft als sichtbares BLUE-Wissen ausgegeben werden.

## 12. Verbindlicher Prüf- und Testbedarf

Vor produktiver Nutzung sind mindestens folgende Tests erforderlich:

1. Vorhandensein aller verwendeten Klassen und Methoden im eingebundenen MOOSE-Commit.
2. `INTEL` mit getrennten visuellen, optischen, Radar-, IRST-, RWR- und Datalink-Konfigurationen.
3. Accept Range, Accept/Reject/Conflict/Corridor Zones.
4. Erkennung statischer Objekte.
5. Akustische Erkennung mit plausiblen Kategorien und Radien.
6. Kontakt-, Cluster-, Lost- und Reacquired-Ereignisse.
7. Tatsächliche Nachverfolgungszeiten je Objektkategorie.
8. OMW-Stale-Modell ohne Verwendung des obsoleten `SetForgetTime()`.
9. `KnowObject()` für kontrollierte HUMINT-/Patrouillenmeldungen.
10. `AUFTRAG:NewRECON()` mit dynamisch erzeugter AIRWING-/SQUADRON-Gruppe.
11. Sichere Registrierung und Entfernung der RECON-Gruppe als INTEL-Agent.
12. `PLAYERRECCE` mit OH-58D, MMS, Laser, SRS und Player Tasks.
13. `TARS` mit Start, Aufnahme, Landung, Debrief und Marker-Ausgabe.
14. `DESIGNATE` mit der tatsächlich benötigten Detection-Klasse.
15. Nachweis, dass F10-, Marker-, Aufgaben- und Zonenausgaben keine unbekannten Einheiten offenlegen.

Jeder Test muss die Nachweise aus [`VERSION-AND-SOURCES.md`](VERSION-AND-SOURCES.md) enthalten.

## 13. Offizielle Quellen

Abrufdatum: **27.07.2026**

- MOOSE `INTEL` und `INTEL_DLINK`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Intel.html>
- MOOSE `PLAYERRECCE`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.PlayerRecce.html>
- MOOSE `TARS`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.TARS.html>
- MOOSE `AUFTRAG`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html>
- MOOSE `CHIEF`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Chief.html>
- MOOSE `DETECTION`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Detection.html>
- MOOSE `DESIGNATE`: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Designate.html>

Die Quellen belegen die dokumentierte Develop-API. Sie ersetzen weder Quellcodeprüfung noch einen Laufzeittest mit der tatsächlich eingebundenen `Moose.lua`.