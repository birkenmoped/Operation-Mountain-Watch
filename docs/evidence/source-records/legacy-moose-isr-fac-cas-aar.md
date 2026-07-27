# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status und Geltungsbereich

**Status:** `PLANNED` / Architekturentscheidung, noch nicht in DCS validiert.

Dieses Dokument beschreibt die verbindlich geplante MOOSE-basierte Architektur für:

- spielergestützte Aufklärung,
- AI-gestützte Aufklärung durch UAVs,
- Fog-of-War und Kontaktverwaltung,
- FAC-, FAC(A)-, AFAC- und JTAC-Abläufe,
- Spieler- und AI-CAS-Anforderungen,
- bewaffnete UAV-Einsätze,
- gezielte Strike-Einsätze,
- CAS-Bereitschaft und Loitering,
- Waffen- und Treibstoffbewertung,
- Air-to-Air Refuelling (AAR),
- Battle Damage Assessment (BDA).

Die hier genannten MOOSE-Klassen und Methoden sind vor einer Implementierung gegen den tatsächlich geladenen MOOSE-Stand, den zugehörigen Quellcode und offizielle Demo-/Testmissionen zu prüfen. Eine Dokumentationsfundstelle allein gilt nicht als DCS-Nachweis.

## 2. Verbindlicher Architekturgrundsatz

Aufklärung, Kontaktverwaltung, Zielentscheidung, Spielerauftrag, AI-Auftrag, Markierung, Wirkung und BDA werden als getrennte Funktionsschichten behandelt.

```text
Aufklärungssensor
├── Spieler: OH-58D oder anderes Aufklärungsasset
├── AI-UAV
├── Bodenpatrouille mit JTAC
└── sonstige ISR-Assets
        ↓
Kontakt- und Lagebild
├── INTEL-Kontakt oder Cluster
├── letzte bekannte Position
├── Erkennungszeit
├── Identifikationsqualität
├── Bedrohungsstufe
└── Track-Status
        ↓
Entscheidungs- und Auftragsvermittlung
├── Spielerauftrag
├── AI-Auftrag
├── Eigenbekämpfung des Sensors
└── keine Bekämpfung / weitere Beobachtung
        ↓
Zielmarkierung
├── Laser
├── Rauch
├── IR-Markierung
├── Beleuchtung
└── reine Koordinatenübergabe
        ↓
Wirkung und BDA
```

Ein einzelner FAC-, FACA- oder CAS-Auftrag bildet diese Gesamtkette nicht vollständig ab.

## 3. Primär vorgesehene MOOSE-Bausteine

| Aufgabe | MOOSE-Baustein | Planungsstatus |
|---|---|---|
| gemeinsames Lagebild und erkannte Kontakte | `INTEL` | `PLANNED` |
| standardisierte Ziele | `TARGET` | `PLANNED` |
| Spieleraufträge | `PLAYERTASKCONTROLLER` / Player-Task-Klassen | `PLANNED` |
| AI-Aufträge | `AUFTRAG` | `IN_USE_PARTIAL`, operative Nutzung offen |
| Ressourcen- und Asset-Auswahl | `COMMANDER`, `AIRWING`, `SQUADRON` | Grundbetrieb teilweise validiert |
| Laufzeitsteuerung eines Fluges | `FLIGHTGROUP` | `PLANNED` |
| Erkennung und Markierung | `DESIGNATE` und Detection-Klassen | `PLANNED` |
| FAC-Gebietsauftrag | `AUFTRAG:NewFAC()` | `PLANNED` |
| FAC(A) gegen konkrete Gruppe | `AUFTRAG:NewFACA()` | `PLANNED` |
| Aufklärung | `AUFTRAG:NewRECON()` | `PLANNED` |
| CAS-Bereitschaft | `AUFTRAG:NewCAS()` / `NewCASENHANCED()` | `PLANNED` |
| geplanter Zielangriff | BAI-, BOMBING-, PRECISIONBOMBING- oder AUTO-Auftrag | `PLANNED` |
| Tanker-/Refuelling-Unterstützung | `COMMANDER`-Tanker-/Refuelling-Zonen und `FLIGHTGROUP`-Fuel-Logik | `PLANNED` |

## 4. Kontakt- und Fog-of-War-Modell

### 4.1 Grundsatz

Eine einmal erkannte Einheit bleibt nicht unbegrenzt als exakter Live-Kontakt bekannt. Das Projekt unterscheidet mindestens:

```text
UNKNOWN
→ DETECTED
→ TRACKED
→ IDENTIFIED
→ LOST
→ STALE
→ REACQUIRED
```

### 4.2 Qualitätsstufen

| Status | Bedeutung |
|---|---|
| `UNKNOWN` | Kein verwertbarer Kontakt vorhanden. |
| `DETECTED` | Kontakt erkannt, Typ oder Stärke noch unsicher. |
| `TRACKED` | Kontakt wird aktuell beobachtet. |
| `IDENTIFIED` | Typ, Stärke oder Zusammensetzung ausreichend bestimmt. |
| `LOST` | Sichtkontakt oder Sensortrack ist abgerissen. |
| `STALE` | Letzte Position ist veraltet und nur noch Suchhinweis. |
| `REACQUIRED` | Kontakt wurde nach Verlust erneut erkannt. |

### 4.3 Zu speichernde Kontaktinformationen

- eindeutige Kontakt-ID,
- erkannte Gruppe oder Cluster,
- letzte bekannte Koordinate,
- Zeitpunkt der letzten Beobachtung,
- erkennendes Asset,
- Track-Status,
- Identifikationsqualität,
- geschätzte Stärke,
- Kategorie und Typ,
- Bewegungsrichtung und Geschwindigkeit, soweit verfügbar,
- Bedrohungsstufe,
- Freundnähe,
- aktuelle Auftragszuordnung,
- Markierungsstatus,
- BDA-Status.

### 4.4 INTEL

`INTEL` ist als primäres MOOSE-Lagebild für AI-Sensoren vorgesehen. Es soll Kontakte und Cluster verwalten und Ereignisse für neue, aktualisierte, verlorene oder wiedererkannte Kontakte liefern.

Vor Implementierung ist zu prüfen:

- tatsächliche Kontakt- und Cluster-Datenstruktur,
- Timeout- und Vergessensverhalten,
- Erkennungsmodell für UAVs und Bodeneinheiten,
- FSM-Events und Callbacks,
- Abgrenzung zu `CampaignState`, `MissionGenerator` und `RedDirector`,
- Persistenzgrenzen,
- Performance bei vielen Kontakten.

`INTEL` ersetzt nicht die langfristige Kampagnenpersistenz. Es liefert das taktische Lagebild; persistente Kampagnenzustände bleiben projektspezifisch.

## 5. Setting 1: Spieler-OH-58D entdeckt Gegner

### 5.1 Eingang in das HQ-Lagebild

MOOSE kann nicht automatisch erkennen, was ein menschlicher Spieler auf seinem Sensor oder Bildschirm identifiziert hat. Der Spieler benötigt deshalb eine definierte Übergabehandlung.

Vorgesehene Eingänge:

- F10-Menü „Kontakt an HQ melden“,
- Auswahl einer Einheit oder Gruppe in begrenztem Radius,
- F10-Kartenmarker mit definierter Syntax,
- Modul- oder DCS-Ereignis, sofern zuverlässig verfügbar,
- Laser- oder Markierungsereignis, sofern technisch eindeutig auswertbar.

Eine automatische Meldung allein aufgrund der Nähe des Spielers ist nicht vorgesehen.

### 5.2 Variante 1: Spieler greift selbst an

```text
Spieler erkennt Ziel
→ optionaler Kontaktbericht an HQ
→ Spieler bekämpft Ziel mit eigenen Waffen
→ Treffer- und Verlustereignisse aktualisieren Zielstatus
→ BDA oder erneute Aufklärung
```

Soll der Angriff kampagnenwirksam bewertet werden, muss der Kontakt einem standardisierten `TARGET` oder einem Spielerauftrag zugeordnet werden.

### 5.3 Variante 2: Spieler als AFAC fordert AI-Unterstützung an

```text
OH-58D meldet und bestätigt Ziel
→ Ziel wird im Lagebild registriert
→ Spieler fordert Unterstützungsart an
→ COMMANDER prüft geeignete verfügbare Assets
→ AI-Auftrag wird erzeugt
→ OH-58D übermittelt Koordinaten und markiert bei Bedarf
→ AI-Flug bekämpft Ziel
→ BDA und Rückkehr zur Bereitschaft
```

Mögliche Unterstützungsarten:

- CAS,
- bewaffnete UAV,
- Kampfhubschrauber,
- BAI,
- Präzisionsangriff,
- Bombardierung,
- Boden-QRF oder Artillerie, sofern später umgesetzt.

Die AI-Zielzuweisung darf nicht ausschließlich von einem Spielerlaser abhängen. DCS-AI-Erkennung von Laserquelle, Code, Sichtlinie, Waffenprofil und Angriffsausführung muss separat validiert werden. Die technische Zielzuweisung soll vorzugsweise direkt auf `GROUP`, `UNIT`, `TARGET`, `ZONE` oder `COORDINATE` erfolgen; Laser und Rauch ergänzen die taktische Darstellung.

### 5.4 Variante 3: Spieler markiert für einen anderen Spieler

```text
OH-58D meldet Ziel
→ Spielerauftrag wird angeboten
→ CAS-Spieler übernimmt Auftrag
→ AFAC übermittelt Koordinaten, Beschreibung und Laser-Code
→ AFAC markiert mit Laser, Rauch oder IR
→ CAS-Spieler greift an
→ AFAC oder UAV führt BDA durch
```

Die Informationsausgabe wird nach Kontaktqualität abgestuft. Ein unsicherer Kontakt erhält keine exakte Einheitenliste.

## 6. Setting 2: UAV entdeckt Feind oder Camp

### 6.1 AI-UAV als Sensor

Die UAV-Gruppe wird als Detection-/INTEL-Agent geführt. Neue Kontakte oder Cluster lösen eine projektseitige Entscheidungslogik aus.

```text
UAV auf RECON- oder FAC-Mission
→ Sensor erkennt Kontakt
→ INTEL erzeugt oder aktualisiert Kontakt/Cluster
→ HQ bewertet Track, Bedrohung und Zielwert
→ Spieler- oder AI-Auftrag wird angeboten
```

### 6.2 Variante 1: UAV übermittelt nur Koordinaten

Der Auftrag enthält abhängig von der Kontaktqualität:

- letzte bekannte Koordinate,
- Zeitpunkt der Beobachtung,
- geschätzten Zieltyp,
- geschätzte Stärke,
- Bewegungsrichtung,
- Bedrohungsstufe,
- Track-Qualität,
- erwartete Markierungsunterstützung.

Bei veraltetem Track wird ein Suchgebiet statt eines exakten Zielpunkts ausgegeben.

### 6.3 Variante 2: Bewaffnete UAV greift selbst an

```text
UAV erkennt Kontakt
→ ROE- und Zielprüfung
→ Freigabe durch HQ oder definierte Automatik
→ UAV erhält gezielten Angriffauftrag
→ Angriff
→ erneute Aufklärung und BDA
→ Fortsetzung ISR oder RTB
```

Automatische Bekämpfung jedes erkannten Kontakts ist verboten. Vor einer Freigabe sind mindestens zu prüfen:

- Zielklassifikation,
- Kontaktqualität,
- ROE,
- Freundnähe,
- No-Strike- und No-Engage-Zonen,
- zivile oder neutrale Objekte,
- geeignete Bewaffnung,
- Bedrohung für die UAV,
- Kollateralschadensrisiko.

### 6.4 Variante 3: UAV fordert CAS-Spieler an und markiert

```text
UAV erkennt Ziel
→ Spielerauftrag wird erzeugt
→ Spieler nimmt Auftrag an
→ UAV hält Track
→ Spieler fordert Markierung an
→ UAV lasert, raucht oder beleuchtet Ziel
→ Spieler greift an
→ UAV führt BDA durch
```

Vorgesehene Trennung:

- `INTEL`: strategisch-taktisches Kontaktbild,
- `PLAYERTASKCONTROLLER`: Spielerauftrag,
- `DESIGNATE` oder validierte Laserfunktion: Markierung,
- `FLIGHTGROUP`: UAV-Laufzeitsteuerung.

### 6.5 Variante 4: Kein Spieler übernimmt, AI greift an

```text
UAV erkennt Ziel
→ Spielerauftrag wird angeboten
→ Annahmefenster und Dringlichkeit werden bewertet
→ kein geeigneter Spieler übernimmt
→ COMMANDER prüft AI-Assets
→ AI-CAS-, Strike- oder UAV-Auftrag
→ UAV markiert oder liefert Koordinaten
```

Die Umschaltung auf AI berücksichtigt zusätzlich:

- Dringlichkeit,
- Bedrohung eigener Kräfte,
- Alter des Tracks,
- Entfernung und ETA,
- Asset-Verfügbarkeit,
- Zielwert,
- Wetter und Tageszeit,
- Kollateralschadensrisiko.

## 7. Setting 3: Patrouille oder FOB hat Feindkontakt

### 7.1 Troops-in-Contact-Ereignis

```text
Patrouille erkennt Gegner oder wird beschossen
→ TIC-Ereignis
→ eigene Position und Zielkontakt an HQ
→ dringlicher Unterstützungsbedarf
→ Spieler und AI-Assets werden bewertet
→ bestgeeignetes Asset reagiert
```

Mögliche Reaktionskräfte:

- geeigneter Spielerflug,
- bereits fliegender AI-CAS-Flug,
- bewaffnete UAV,
- Kampfhubschrauber,
- Boden-QRF,
- Artillerie,
- später MEDEVAC oder CASEVAC.

### 7.2 Asset-Auswahl

Das nächste Asset ist nicht automatisch das beste Asset. Die Auswahl bewertet mindestens:

```text
Eignung =
  Missionsfähigkeit
  + ETA / Entfernung
  + verbleibende geeignete Bewaffnung
  + verbleibender Treibstoff
  + aktuelle Aufgabe und Priorität
  + Bedrohungsverträglichkeit
  + Markierungs- und Sensorfähigkeit
  + Spielerstatus
```

`COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP` liefern die MOOSE-Grundlage. Eine kleine projektspezifische Scoring- und Eskalationsschicht ist voraussichtlich erforderlich.

### 7.3 Boden-JTAC

Eine Patrouille mit JTAC kann als Boden-Sensor und Markierer dienen.

Mögliche Markierungen:

- Laser,
- Rauch,
- IR-Pointer,
- Beleuchtung,
- Koordinatenmeldung.

Eine Markierung wird nur zugelassen, wenn:

- die JTAC-Einheit lebt,
- Sichtlinie besteht,
- Zielreichweite plausibel ist,
- Zieltrack aktuell ist,
- keine Friendly-Fire- oder No-Strike-Bedingung verletzt wird.

## 8. FAC-, FAC(A)- und DESIGNATE-Verwendung

### 8.1 AUFTRAG:NewFAC()

Geplante Verwendung für eine gebietsbezogene FAC-Mission:

```lua
local mission = AUFTRAG:NewFAC(
  facZone,
  speed,
  altitude,
  frequency,
  modulation
)
```

Einsatz:

- UAV oder anderes Asset patrouilliert in einer FAC-Zone,
- erkennt Ziele im Gebiet,
- unterstützt Folgekräfte.

Vor Einsatz sind Signatur, Einheitenanforderungen, Erkennungsverhalten, Funkverhalten und Abschlussbedingungen im verwendeten MOOSE-Stand zu prüfen.

### 8.2 AUFTRAG:NewFACA()

Geplante Verwendung für eine luftgestützte FAC(A)-Mission gegen eine konkrete Zielgruppe:

```lua
local mission = AUFTRAG:NewFACA(
  targetGroup,
  designation,
  datalink,
  frequency,
  modulation
)
```

Einsatz:

- bestätigte konkrete Zielgruppe,
- AFAC-Asset wird gezielt zugewiesen,
- Markierung und Koordination für Folgekräfte.

### 8.3 DESIGNATE

`DESIGNATE` ist als taktischer Markierungsbaustein vorgesehen, nicht als alleinige strategische Kontaktverwaltung.

Geplanter Funktionsumfang:

- Laser,
- Rauch,
- Beleuchtung,
- automatische Markierung,
- Laser-Code-Verwaltung,
- Begrenzung paralleler Designationen,
- Bedrohungspriorisierung,
- Spieler-Menüs.

Vor Einführung ist insbesondere zu prüfen, ob `DESIGNATE` im tatsächlich verwendeten MOOSE-Stand mit `INTEL`, den vorgesehenen Detection-Klassen und der Multiplayer-Auftragsarchitektur sauber kombiniert werden kann.

## 9. Spieleraufträge

`PLAYERTASKCONTROLLER` beziehungsweise die passenden Player-Task-Klassen sollen als Vermittlung zwischen Lagebild und Spielern dienen.

Ein Spielerauftrag kann sich auf folgende Zielarten beziehen:

- konkrete Gruppe,
- einzelne Einheit,
- statisches Objekt,
- Zone,
- Koordinate oder Suchgebiet.

Erforderliche Funktionen:

- Auftrag anbieten,
- Annahme und Ablehnung,
- mehrere Spieler pro Auftrag, soweit vorgesehen,
- Dringlichkeit und Ablaufzeit,
- Kontaktqualität im Briefing,
- Markierungsanforderung,
- Abschluss, Fehlschlag und Abbruch,
- Übergabe an AI bei Nichtannahme,
- BDA und Kampagnenwirkung.

## 10. AI-CAS als Bereitschaft, nicht als Einwegangriff

### 10.1 Grundsatz

Ein CAS-Flug endet nicht automatisch mit der Zerstörung eines einzelnen Ziels. Er bleibt bis zu einer Abbruchbedingung im Einsatzraum verfügbar.

```text
CAS-Flug startet
→ erreicht Station
→ hält CAS-Orbit oder patrouilliert
→ erhält taktische Zielzuweisung
→ bekämpft Ziel
→ kehrt zur Station zurück
→ bleibt für weitere Aufgaben verfügbar
```

### 10.2 Geplante MOOSE-Aufträge

Zu vergleichen und in DCS zu testen:

- `AUFTRAG:NewCAS()`,
- `AUFTRAG:NewCASENHANCED()`.

Ein reiner `BOMBING`-, `BAI`- oder anderer zielgebundener Auftrag ist für dauerhafte CAS-Bereitschaft nicht ausreichend, da er nach Zielerfüllung abgeschlossen sein kann.

### 10.3 Zweiphasiges Modell

```text
Phase 1: CAS ON STATION
- Orbit oder Patrouille
- Bereitschaft und Sensorüberwachung

Phase 2: TACTICAL TARGET ASSIGNMENT
- konkretes Ziel
- Markierer oder Koordinate
- Angriff
- Rückkehr zu Phase 1
```

Falls `CAS` oder `CASENHANCED` dieses Verhalten nicht zuverlässig selbst abbildet, wird nur eine dünne Orchestrierungsschicht ergänzt, die nach einer Zielbekämpfung die Station-Mission wiederherstellt.

### 10.4 Abbruchbedingungen

- Bingo oder Critical Fuel,
- keine für die aktuelle Zielart geeignete A/G-Bewaffnung,
- schwere Beschädigung,
- Missionszeit abgelaufen,
- Ablösung eingetroffen,
- Einsatzraum nicht mehr zulässig,
- übergeordneter Abbruchbefehl.

## 11. Waffenstatus

`Winchester` wird missionsabhängig bewertet. Nicht die Gesamtzahl aller Waffen ist entscheidend, sondern die verbleibende Eignung für die aktuelle Aufgabe.

Beispiele:

- nur Luft-Luft-Waffen verbleiben: keine CAS-Fähigkeit,
- nur Kanone verbleibt: eventuell gegen Infanterie oder leichtes Fahrzeug geeignet,
- nur ungelenkte Bomben verbleiben: ungeeignet bei enger Freundnähe,
- Präzisionswaffen verbraucht: kein Angriff unter restriktiven ROE,
- Hellfire verbleiben: weiterhin gegen einzelne Fahrzeuge geeignet.

Vor Implementierung sind die verfügbaren `FLIGHTGROUP`-Munitionsabfragen und Events im tatsächlichen MOOSE-Stand zu prüfen.

## 12. Air-to-Air Refuelling

### 12.1 Ziel

AAR kann die Station-Zeit geeigneter CAS- und Strike-Flugzeuge verlängern. Es ist kein Ersatz für Ablösung, sondern eine zusätzliche Option.

### 12.2 Geplanter Ablauf

```text
CAS-Flug auf Station
→ Fuel-Low-Schwelle erreicht
→ geeigneter Tanker verfügbar?
├── ja
│   → Station-Mission pausieren oder verlassen
│   → Tanker aufsuchen
│   → AAR durchführen
│   → CAS-Station wieder aufnehmen
└── nein
    → Bingo / RTB
    → Ersatzflug anfordern
```

### 12.3 Zu prüfende MOOSE-Funktionen

- Tanker- und Refuelling-Zonen des `COMMANDER`,
- Tanker-Missionen über `AUFTRAG` und `AIRWING`,
- `FLIGHTGROUP`-Fuel-Low- und Fuel-Critical-Schwellen,
- automatische Refuelling- und RTB-Optionen,
- Mission Resume nach erfolgreicher Betankung.

### 12.4 DCS-Einschränkungen

Die eigentliche AAR-Ausführung bleibt DCS-AI. Deshalb sind Flugzeug-/Tanker-Kombinationen einzeln zu testen. Zu prüfen sind mindestens:

- Erreichen und Einreihen am Tanker,
- erfolgreiche Kraftstoffübernahme,
- Verhalten bei belegtem Tanker,
- Abbruch und Recovery,
- Rückkehr zum CAS-Auftrag,
- Multiplayer- und Funkverhalten.

AAR ist für typische Hubschrauber und viele UAVs des Szenarios nicht relevant oder in DCS nicht verfügbar.

## 13. BDA und Auftragsabschluss

Nach jedem Angriff ist zwischen Zielwirkung und Auftragserfüllung zu unterscheiden.

Mögliche BDA-Zustände:

```text
NOT_ASSESSED
→ PARTIAL
→ EFFECTIVE
→ DESTROYED
→ INCONCLUSIVE
→ REATTACK_REQUIRED
```

Ein Zielauftrag kann beendet werden, während der CAS-Flug weiterhin auf Station bleibt. Umgekehrt darf ein Flug nicht allein wegen fehlender Sicht auf ein Ziel als erfolgreich gewertet werden.

BDA-Quellen:

- UAV-Track,
- AFAC-Spieler,
- JTAC-Patrouille,
- Treffer- und Verlustereignisse,
- erneute Aufklärung,
- Missions- oder Ziel-FSM.

## 14. ROE- und Sicherheitsregeln

Vor jeder automatischen oder angeforderten Bekämpfung sind zu prüfen:

- Ziel gehört zur feindlichen Koalition,
- Ziel ist ausreichend identifiziert,
- keine No-Strike-Zone,
- keine unzulässige Friendly-Nähe,
- Markierung entspricht dem beauftragten Ziel,
- Track ist nicht zu alt,
- verwendete Waffe ist für ROE und Zielumfeld geeignet,
- Auftrag besitzt Freigabestatus,
- das ausführende Asset ist einsatzfähig.

## 15. Projektspezifische Orchestrierung

MOOSE soll die vorhandenen Kernfunktionen übernehmen. Eigene Logik ist nur für die projektspezifische Vermittlung vorgesehen:

- Kontaktqualitäts- und Track-Modell,
- ROE und Freigabestatus,
- Spieler-zu-AI-Eskalation,
- Asset-Scoring,
- Prioritäten und Annahmefenster,
- Missionsübergabe und Ablösung,
- BDA und Kampagnenwirkung,
- Persistenz,
- Verbindung zu `CampaignState`, `MissionGenerator` und `RedDirector`.

Eine eigene parallele Implementierung von Laser-, FAC-, CAS-, Tanker- oder grundlegender Detection-Funktion ist ohne dokumentierten Nachweis einer MOOSE-Lücke nicht zulässig.

## 16. Verbindlicher Testplan

Die Architektur wird in getrennten Teststufen validiert:

1. Spieler meldet Ziel über definierten Eingang an HQ.
2. `INTEL` erkennt Kontakt über AI-UAV.
3. Kontaktverlust, Stale-Track und Wiedererkennung.
4. Spielerauftrag aus Gruppe, Zone und Koordinate.
5. Spieler-AFAC markiert für Spieler.
6. Spieler-AFAC markiert für AI-Angriff.
7. UAV markiert für Spieler.
8. UAV markiert für AI-Angriff.
9. Boden-JTAC markiert für Spieler und AI.
10. `NewFAC()` als gebietsbezogener Auftrag.
11. `NewFACA()` gegen konkrete Gruppe.
12. `NewCAS()` und `NewCASENHANCED()` im Vergleich.
13. Rückkehr eines CAS-Fluges zur Station nach Angriff.
14. missionsabhängige Waffenbewertung.
15. Fuel-Low, Bingo und RTB.
16. Tankerbereitstellung und AAR.
17. Fortsetzung des CAS-Auftrags nach AAR.
18. BDA und erneuter Angriff.
19. Verlust von Sensor, Markierer, Ziel oder ausführendem Asset.
20. Multiplayer-Test mit mehreren angebotenen und angenommenen Aufträgen.

Jeder Test benötigt:

- dokumentierten MOOSE-Stand,
- Mission-Editor-Voraussetzungen,
- verwendete Templates und Zonen,
- erwartete Logereignisse,
- PASS-/FAIL-Kriterien,
- DCS-Log und Ergebnisbericht.

## 17. Offene technische Entscheidungen

- exakter Spieler-Meldeweg für OH-58D und andere Aufklärer,
- konkrete Detection-Klasse neben `INTEL`,
- genaue Integration von `DESIGNATE` und `INTEL`,
- Player-Task-Klasse und Menümodell,
- Ziel- und Kontaktpersistenz,
- Stale-Track-Zeiten je Zielart,
- Asset-Scoring und Eskalationslogik,
- AI-Laser-Verwendung durch unterschiedliche Flugzeuge und Waffen,
- CAS-Station-Resume nach taktischer Zielzuweisung,
- missionsabhängige Munitionsbewertung,
- AAR-Kompatibilitätsmatrix,
- BDA-Kriterien je Zieltyp.

## 18. Quellen

- INTEL: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Intel.html>
- TARGET: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Target.html>
- AUFTRAG: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html>
- COMMANDER: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Commander.html>
- AIRWING: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Airwing.html>
- FLIGHTGROUP: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.FlightGroup.html>
- DESIGNATE: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Functional.Designate.html>
- Player Tasks: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.PlayerTask.html>

Die konkreten Signaturen und Verhaltensannahmen sind vor Implementierung im tatsächlich eingebundenen MOOSE-Quellstand zu verifizieren.
