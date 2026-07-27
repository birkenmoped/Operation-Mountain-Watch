# Operation Mountain Watch – Kampagnenarchitektur und dynamisches Missionsdesign

## 1. Zweck und Geltungsbereich

Dieses Dokument fasst die projektweit verbindlichen Ziele, Architekturentscheidungen und Planungen für die persistente COIN-Kampagne **Operation Mountain Watch** zusammen. Es ergänzt die MOOSE-First-Richtlinie und dient als fachliche Grundlage für die Überarbeitung von TM01, TM02 und späteren Teilmodulen.

Die Kampagne soll keine zufällige Aneinanderreihung geskripteter Ereignisse sein. Jede physisch erzeugte Gruppe, jede Lieferung, jede Aufklärungsinformation und jeder Auftrag muss einen nachvollziehbaren Ursprung, ein Ziel, einen Zweck und eine strategische Folge besitzen.

## 2. Verbindliche Architekturgrundsätze

### 2.1 MOOSE zuerst

Vor jeder Eigenentwicklung ist zu prüfen, ob MOOSE die benötigte Funktion bereits vollständig oder teilweise bereitstellt. Vorhandene MOOSE-Klassen und -Methoden sind vorrangig zu verwenden. Eigenlogik ist nur dort zulässig, wo MOOSE die projektbezogene Persistenz-, Kampagnen- oder Entscheidungslogik nicht abbildet.

Besonders relevant sind derzeit:

- `COMMANDER`
- `AIRWING`
- `SQUADRON`
- `AUFTRAG`
- `PLAYERTASK`
- `OPERATION`
- `BRIGADE`
- `PLATOON`
- `OPSGROUP`
- `ARMYGROUP`
- `WAREHOUSE`
- `OPSTRANSPORT`
- `CTLD`
- `CSAR`
- `AICSAR`
- `ARTY`
- `AMMOTRUCK`
- `INTEL`
- `DETECTION`
- `TARGET`
- `PLAYERRECCE`
- `DESIGNATE`
- `FLIGHTCONTROL`
- `ATIS`
- `Core.Astar`
- `SCHEDULER`
- `SPAWN`
- `SET_GROUP` und weitere SET-Klassen

### 2.2 CampaignState ist autoritativ

Der projektbezogene `CampaignState` ist die strategische Wahrheit. Er verwaltet insbesondere:

- Personal
- Fahrzeuge und Luftfahrzeuge
- Treibstoff
- Munition
- Versorgungsgüter
- Warehouse-Bestände
- Verluste
- CSAR-Vorfälle
- MissionDemand-Objekte
- RED-Standorte und Logistiknetz
- Ortschaftsunterstützung und HUMINT-Zugang
- Persistenz über Missionsneustarts

MOOSE übernimmt die operative Ausführung in DCS:

- Gruppen und Verbände
- Aufträge
- Transport
- Feuerunterstützung
- Aufklärung
- Zielobjekte
- Spieleraufgaben
- Flugplatzbetrieb

Grundsatz:

> CampaignState entscheidet, was existiert, verfügbar ist und strategisch geschieht. MOOSE setzt diese Entscheidungen in der laufenden DCS-Mission um.

### 2.3 Keine zwecklosen Spawns

Für jede physische Gruppe gelten zwingend:

- definierter Ursprung
- definiertes Ziel
- definierter Auftrag
- definierte transportierte oder eingesetzte Ressource
- definierte strategische Folge bei Erfolg oder Verlust

Unzulässig sind zufällig gespawnte Gruppen ohne reale Aufgabe oder ohne Rückwirkung auf den CampaignState.

## 3. BLUE-Kampagnenstruktur

### 3.1 Luftoperationen

Die bereits geplanten und festgelegten ORBATs werden mit MOOSE-Strukturen umgesetzt:

- `COMMANDER` für übergeordnete Zuweisung
- `AIRWING` pro relevantem Flugplatz oder Luftoperationsstandort
- `SQUADRON` pro Muster, Rolle oder Verband
- `AUFTRAG` für KI-Missionen
- `PLAYERTASK` beziehungsweise projektbezogene MissionDemand-Zuordnung für Spieler

Spieler erhalten bei geeigneten Missionen Vorrang. Nicht angenommene oder abgelaufene Aufträge können, sofern ausdrücklich vorgesehen, von KI übernommen werden.

### 3.2 FOBs und Bodentruppen

FOBs sind persistente Kampagnenobjekte mit:

- Personalbestand
- Fahrzeugbestand
- Warehouse
- Treibstoff
- Munition
- Bereitschaft
- lokalen Fähigkeiten
- zugeordneten Verbänden

Die operative Abbildung erfolgt grundsätzlich über:

- `BRIGADE`
- `PLATOON`
- `ARMYGROUP`
- `OPSGROUP`

Personal wird getrennt betrachtet als:

- zugewiesen
- einsatzbereit
- aktuell physisch materialisiert

### 3.3 Patrouillen

Patrouillen entstehen nicht zufällig. Sie werden aus verfügbaren FOB- oder Brigade-Ressourcen erzeugt und besitzen einen echten Auftrag.

Ihre Verfügbarkeit hängt mindestens ab von:

- Personal
- Fahrzeugen
- Treibstoff
- Bedrohungslage
- Bereitschaft
- laufenden anderen Aufträgen

### 3.4 Artillerie und Munitionsversorgung

Artillerie an FOBs und Basen wird bevorzugt mit `ARTY` umgesetzt.

Feueraufträge können entstehen durch:

- Spieleranforderung
- Aufklärung
- bestätigte Ziele
- taktische KI-Entscheidung

Jeder Feuerauftrag verbraucht Kampagnenmunition.

Die Nachversorgung erfolgt nach folgendem Modell:

1. Artillerie meldet Munitionsbedarf.
2. CampaignState prüft das zugeordnete Warehouse.
3. Munition wird reserviert.
4. `AMMOTRUCK` führt die taktische Lieferung aus.
5. Nach erfolgreicher Übergabe werden Warehouse und Artilleriebestand aktualisiert.
6. Ist das Warehouse leer, entsteht ein strategischer Nachschubbedarf.

`AMMOTRUCK` ersetzt nicht die strategische Bestandsführung.

### 3.5 CSAR

Für jeden CSAR-Vorfall existiert genau ein autoritatives `CSARIncident`-Objekt.

Vorgesehene Zustände:

- `AVAILABLE`
- `PLAYER_RESERVED`
- `PLAYER_EN_ROUTE`
- `AI_RESERVED`
- `AI_EN_ROUTE`
- `RECOVERED`
- `CAPTURED`
- `KIA`
- `EXPIRED`

Ablauf:

1. Spieler erhalten zuerst die CSAR-Mission.
2. Während einer Reservierungsfrist darf keine KI denselben Vorfall übernehmen.
3. Wird der Auftrag nicht angenommen, kann `AICSAR` als Fallback eingesetzt werden.
4. Spieler- und KI-System arbeiten immer auf demselben Vorfall und dürfen keine Doppelrettung erzeugen.

### 3.6 Flugplatzbetrieb

Für größere Basen sind zu prüfen und vorzugsweise einzusetzen:

- `FLIGHTCONTROL`
- `ATIS`

Für kleine FARPs und abgelegene FOB-Landezonen reicht eine reduzierte, projektspezifische Verfahrenslogik.

## 4. Einheitliches MissionDemand-System

Dynamische Aufträge werden fachlich als persistente MissionDemand-Objekte modelliert.

Ein MissionDemand enthält mindestens:

- Auftragstyp
- Quelle des Bedarfs
- Ziel
- Priorität
- Spielerfähigkeit
- KI-Fähigkeit
- Reservierungsstatus
- Ablaufzeit
- Erfolgskriterien
- Folgen bei Erfolg oder Fehlschlag

Vorgesehene Zustände:

- `OPEN`
- `PLAYER_ASSIGNED`
- `AI_ASSIGNED`
- `ACTIVE`
- `SUCCESS`
- `FAILED`
- `EXPIRED`

Ein Bedarf kann durch `PLAYERTASK` für Spieler oder durch `AUFTRAG` für KI ausgeführt werden. Nicht jede Mission muss KI-fähig sein.

## 5. RED-Kampagnenstruktur

### 5.1 Zielsetzung

RED bildet ein insurgentes Netzwerk ab, dessen strategisches Ziel darin besteht, BLUE zu schwächen, Verluste zu verursachen, Versorgung zu stören und die eigene Handlungsfähigkeit zu erhalten.

### 5.2 Standorttypen

RED-Standorte sind keine spiegelbildlichen BLUE-FOBs. Vorgesehen sind:

- Hauptquartier
- 2 bis 3 initiale Verteilerdepots
- Hide Sites
- Forward Caches
- temporäre Transferpunkte

Viele Standorte sind Infrastruktur und nicht dauerhaft bemannte Garnisonen.

### 5.3 Standortzustände

Vorgesehene Zustände:

- `UNKNOWN`
- `CANDIDATE`
- `SURVEYED`
- `APPROVED`
- `UNDER_CONSTRUCTION`
- `OPERATIONAL`
- `COMPROMISED`
- `EVACUATING`
- `DORMANT`
- `ABANDONED`
- `DESTROYED`

### 5.4 Errichtung neuer Unterschlüpfe und Caches

Ein neuer Standort entsteht nur durch einen realen Prozess:

1. RED entscheidet sich für einen vorbereiteten Kandidatenstandort.
2. Eine kleine Infanteriegruppe erhält den Auftrag, diesen Standort zu erreichen.
3. Nach Ankunft beginnt eine definierte Bau- oder Einrichtungszeit.
4. Ein statisches Template beziehungsweise eine geeignete Standortdarstellung wird aktiviert.
5. Das zugehörige Warehouse startet leer.
6. Ressourcen müssen anschließend tatsächlich angeliefert werden.

Ein Standort benötigt nicht zwingend eine permanente Garnison.

### 5.5 Kandidatenstandorte statt unrealistischer Terrain-KI

Der RED-Commander soll keine vermeintliche Sichtbarkeit, Deckung oder komplexe Geländeeignung selbst berechnen. Der Missionsdesigner legt geprüfte Kandidatenstandorte mit Metadaten an.

Mögliche Metadaten:

- Standorttyp
- Kapazität
- Straßenzugang
- Infanteriezugang
- zulässige Anmarscharten
- Geländeklasse
- Urbanitätsklasse
- Mindestabstand zu BLUE
- zulässige Warehouse-Größe
- Flucht- oder Alternativrouten

### 5.6 RED-Logistiknetz

Das RED-Netz wird als gerichteter Graph betrachtet:

- HQ
- Verteilerdepots
- Hide Sites
- Forward Caches

Kanten enthalten mindestens:

- Distanz
- Risiko
- Kapazität
- Transportart
- BLUE-Exposition

Jeder Transport verschiebt reale Bestände zwischen Warehouses.

### 5.7 DCS-gerechte Transportarten

Aufgrund der DCS-Beschränkungen gelten:

- Fahrzeuge nur auf geeigneten Straßen und Wegen
- keine Motorräder
- keine Pferde oder Maultiere
- keine unrealistischen Offroad-Fahrten durch Wald oder steile Hänge
- Infanterietransport für abgelegene Standorte
- hybride Transporte: Fahrzeug bis Transferpunkt, danach Infanterie für die letzte Strecke

## 6. Adaptive Materialisierung von RED-Bewegungen

Ein festes Verhältnis wie 50 Prozent virtuell und 50 Prozent physisch ist nicht ausreichend. Die Darstellung wird adaptiv gewählt.

Jede Bewegung besitzt einen `ExposureScore`, der unter anderem beeinflusst wird durch:

- Nähe zu BLUE
- Nähe zu Spielern
- Straßennutzung
- strategische Bedeutung
- wiederholte Routennutzung
- Tageszeit
- vorherige Beobachtung
- aktive Aufklärungsmissionen

Zusätzlich wird eine `ExposureDebt` geführt. Sie verhindert, dass dieselben Bewegungen dauerhaft virtuell bleiben.

Priorität für physische Darstellung:

`RepresentationPriority = ExposureScore + ExposureDebt + MissionCriticality`

### 6.1 Mindestmaß physischer Präsenz

Als Ausgangspunkt gilt:

- 1 bis 2 aktive RED-Bewegungen: mindestens 1 physisch
- 3 bis 5 aktive RED-Bewegungen: mindestens 2 physisch
- 6 bis 10 aktive RED-Bewegungen: mindestens 3 physisch
- über 10 aktive RED-Bewegungen: etwa 30 Prozent physisch, abhängig von Serverlast und Exposition

Die letzte verbleibende relevante RED-Bewegung darf nicht dauerhaft vollständig virtuell bleiben.

### 6.2 Exposure Windows

Jede aktive Bewegung muss mindestens eine echte Entdeckungsmöglichkeit besitzen.

Beispiel:

- virtuell im abgelegenen Abschnitt
- physisch an Straßenquerung oder Engstelle
- wieder virtuell nach Verlust des Kontakts
- physisch im Zielanflug oder in der Nähe des Zielstandorts

Nähert sich ein Spieler, kann die Gruppe vorzeitig materialisiert werden.

### 6.3 Regeln gegen unfaire Dematerialisierung

Eine physische Gruppe bleibt physisch:

- während sie beobachtet wird
- während sie verfolgt wird
- während sie kämpft
- während sie nahe an Spielern ist
- während einer Mindestzeit
- bis sie eine Mindestdistanz zurückgelegt hat

Vorgesehene Tracking-Zustände:

- `UNOBSERVED`
- `POSSIBLY_OBSERVED`
- `TRACKED`
- `TRACK_LOST`
- `IDENTIFIED`

## 7. Aufklärung und Entdeckung von RED-Standorten

### 7.1 Mehrstufige Erkenntnis

Ein RED-Standort springt nicht direkt von unbekannt zu bestätigt.

Vorgesehene BLUE-Erkenntnisstufen:

- `UNKNOWN`
- `INDICATION`
- `AREA_OF_INTEREST`
- `SUSPECTED_LOCATION`
- `PROBABLE_LOCATION`
- `CONFIRMED`
- `COMPROMISED`
- `DESTROYED`

Mögliche Folgeaufträge:

- Hinweis: Patrouille oder allgemeine Aufklärung
- Area of Interest: UAV, OH-58D, Bodenspähtrupp
- suspected: Überwachung, Tracken, Cordon and Search
- probable: Armed Reconnaissance oder Raid-Vorbereitung
- confirmed: Raid, Seize, Destroy oder bei passenden ROE Strike

### 7.2 Nutzung erzeugt Intelligence Exposure

Jeder RED-Standort sammelt durch Nutzung eine nachrichtendienstliche Signatur.

Teilwerte können sein:

- HUMINT Exposure
- SIGINT Exposure
- Visual Exposure

Steigernde Ereignisse:

- Personalbewegungen
- Versorgungstransporte
- Fahrzeugverkehr
- Funkverkehr
- Rückkehr von Kampfgruppen
- Verwundetentransport
- wiederholte Nutzung gleicher Routen
- beobachtete An- und Abmärsche
- gefangene Kämpfer
- erbeutete Dokumente

Unbenutzte, funkarme Standorte dürfen nicht zufällig ohne Indizien entdeckt werden.

### 7.3 Unterschiedliche Halbwertszeiten

- visuelle Kontakte veralten schnell
- SIGINT bleibt mittelfristig relevant
- HUMINT kann über längere Zeit bestehen bleiben

Ein zeitweise aufgegebener Standort kann daher weiterhin als verdächtig bekannt sein.

### 7.4 Spieleraufklärung

Für aktive Spieleraufklärung ist `PLAYERRECCE` besonders zu prüfen.

Zielkette:

`PLAYERRECCE -> INTEL/DETECTION -> TARGET -> MissionDemand -> PLAYERTASK oder AUFTRAG`

Das Verfolgen einer RED-Gruppe bis zum Ziel kann einen Standort aufdecken, auch wenn dieser ein normales DCS-Szeneriegebäude nutzt.

## 8. Settlement Support & HUMINT Sidequests

### 8.1 Begrenzter Zweck

Es wird keine vollständige politische Loyalitäts-, Hearts-and-Minds- oder Zivilverwaltungssimulation entwickelt.

Ausgewählte Städte und Dörfer erhalten stattdessen ein begrenztes Support- und HUMINT-System. Es dient ausschließlich dazu, freiwillige Transportaufträge für Spieler und daraus resultierende lokale Informationen zu erzeugen.

### 8.2 Keine KI-Ausführung

Civil-Support-Lieferungen sind reine Spieler-Sidequests.

Nicht zulässig:

- KI-Transport
- Bodenversorgungskonvoi
- automatische Erledigung

Zulässige Luftfahrzeuge:

- UH-1H Huey
- festgelegte UH-60-Variante
- festgelegte CH-47-Variante
- C-130J

Zulässige Verfahren:

- interne Hubschrauberfracht
- Slingload
- C-130J-Abwurf

### 8.3 Unterstützungsstufen

Es gelten drei Support-Level:

- Level 0: kein verwertbarer HUMINT-Zugang
- Level 1: allgemeiner Hinweis auf RED-Aktivität im lokalen Umkreis
- Level 2: grobe Richtung, Entfernung oder mehrere mögliche Bereiche
- Level 3: deutlich präzisere Suchzone, Aktivitätsangaben und möglicher Standorttyp

Eine Ortschaft mit bestehendem BLUE-FOB startet grundsätzlich mit **Level 1 Vorschuss**.

Normale Ortschaft:

`0 -> 1 -> 2 -> 3`

Ortschaft mit BLUE-FOB:

`1 -> 2 -> 3`

Als Ausgangsregel erhöht eine erfolgreiche wertende Lieferung den Support um eine Stufe. Zur Vermeidung von Farming dürfen mehrere Lieferungen nicht unmittelbar hintereinander denselben Fortschritt erzeugen. Dafür sind Zeitfenster, Bedarfsaufträge oder Missionszyklen vorzusehen.

### 8.4 Support und tatsächliches Wissen trennen

Support-Level bedeutet Bereitschaft zur Informationsweitergabe.

Davon getrennt wird geführt, was die Bevölkerung tatsächlich über einen Standort wissen kann.

Hoher Support ohne RED-Aktivität erzeugt keine Meldung.

Hohe RED-Aktivität bei niedrigem Support bedeutet, dass Wissen vorhanden sein kann, aber nicht weitergegeben wird.

Hohe RED-Aktivität und hoher Support erzeugen präzise HUMINT-Meldungen.

### 8.5 Lokaler Wissensradius

Jede ausgewählte Ortschaft besitzt einen definierten HUMINT-Radius. Die Größe wird missionsdesignerisch festgelegt und kann sich nach Siedlungsgröße und Gelände richten.

Innerhalb dieses Radius können Informationen entstehen über:

- RED-Unterschlüpfe
- Caches
- wiederkehrende Bewegungen
- Lieferwege
- letzte bekannte Aktivität

### 8.6 HUMINT-Folgeaufträge

Mögliche Kette:

1. Spieler liefert Humanitarian Supplies.
2. Support-Level steigt.
3. Vorhandenes lokales Wissen wird entsprechend der Stufe freigegeben.
4. Es entsteht ein RECON-, SURVEILLANCE- oder PATROL-Auftrag.
5. Spieler bestätigt oder widerlegt den Standort.
6. Bei ausreichender Bestätigung entsteht ein RAID-, SEIZE-, DESTROY- oder STRIKE-Auftrag.

In bebauten Gebieten führt reine HUMINT- oder SIGINT-Information nicht automatisch zu einem Luftangriff. ROE, Zielbestätigung und ziviles Umfeld sind zu berücksichtigen.

### 8.7 Lieferpunkte

Jede teilnehmende Stadt beziehungsweise jedes Dorf erhält mindestens einen missionsdesignerisch geprüften Zustellpunkt.

Je nach vorgesehenem Verfahren können getrennte Punkte nötig sein für:

- Hubschrauberlandung und interne Entladung
- Slingload-Absetzpunkt
- C-130J-Abwurfzone

Nicht jeder Ort muss alle Verfahren unterstützen.

Die Punkte müssen geprüft werden auf:

- freie Fläche
- Geländeneigung
- Hindernisse
- Gebäude
- Stromleitungen
- Anflugwege
- Abwurfgeometrie
- sichere Aktivierungs- und Prüfzone

### 8.8 Begrenzung des Umfangs

Die erste Ausbaustufe umfasst nur ausgewählte strategisch sinnvolle Ortschaften, nicht jede Siedlung der Afghanistan-Karte.

Auswahlkriterien:

- Nähe zu RED-Netzwerken
- Nähe zu MSR/ASR
- Nähe zu FOBs
- spielerisch interessanter Raum
- geeignete Lande- oder Abwurfzone
- geografische Verteilung

## 9. TM01 – Zielrichtung der Überarbeitung

TM01 muss vollständig gegen die MOOSE-First-Richtlinie geprüft werden.

Vorrangige Prüf- und Umbaupunkte:

- `timer.scheduleFunction` durch `SCHEDULER` ersetzen
- `SPAWN` weiterverwenden, sofern passend
- gespawnte Konvois als `ARMYGROUP` beziehungsweise geeignete OPSGROUP-Ableitung führen
- `GROUP:FindByName()` statt direkter DCS-Gruppensuche verwenden
- geeignete SET-Klassen zur Verwaltung von Gruppen und Zuständen einsetzen
- Pack/Unpack nicht als isolierte Teleportlogik behandeln, sondern an Mission, Beobachtung und CampaignState binden
- Watchguard auch für entpackte Gruppen wirksam halten
- keine Rücksetzung oder Teleportation während Aufklärung, Verfolgung oder Kampf
- Routenfindung und Wiederaufnahme gegen vorhandene MOOSE-Funktionen prüfen

Die OMW-eigene strategische Virtualisierung bleibt bestehen. MOOSE TIRESIAS ersetzt diese nicht automatisch.

## 10. TM02 – Zielrichtung der Überarbeitung

TM02 ist nach den neuen RED-Architekturentscheidungen vollständig neu zu bewerten.

Insbesondere müssen bisherige Annahmen über statische Unterschlüpfe und zufällige Bewegungen ersetzt werden durch:

- vorbereitete Candidate Sites mit Metadaten
- reale Errichtungsmissionen
- leere Warehouses bei Aktivierung
- reale Versorgungsketten
- adaptiv physische und virtuelle Transporte
- Exposure Windows
- Tracking und Nicht-Dematerialisierung bei Beobachtung
- gestufte Standortentdeckung
- HUMINT-, SIGINT- und Visual-Exposure
- Verknüpfung mit Settlement-HUMINT
- MissionDemand für Aufklärung, Raid und Strike

`Core.Astar` ist als vorrangiger Kandidat für Routen- und Netzwerkplanung zu prüfen. Eine Eigenimplementierung darf erst nach dokumentierter Prüfung der MOOSE-Möglichkeiten erfolgen.

## 11. Noch offene Entscheidungen

Die folgenden Punkte benötigen weitere Festlegung oder Tests:

- genaue Support-Cooldowns und Lieferfrequenzen
- genaue HUMINT-Radien je Siedlung
- genaue Informationsqualität je Support-Level
- zulässige Transporthubschrauber und deren konkrete DCS-Typnamen
- konkrete C-130J-Abwurferkennung
- Umfang und Form der Warehouse-Güterklassen
- Balance der adaptiven Materialisierung
- Definition von ExposureScore und ExposureDebt
- Regeln zur RED-Evakuierung kompromittierter Standorte
- ROE für STRIKE versus RAID in bebautem Gebiet
- Persistenzformat und Migrationsregeln

## 12. Abnahmekriterien für spätere Implementierung

Eine Funktion gilt erst als integriert, wenn:

- die passende MOOSE-Funktion geprüft und dokumentiert wurde
- CampaignState und MOOSE-Verantwortung klar getrennt sind
- keine zwecklosen Spawns entstehen
- Erfolg und Verlust strategische Folgen besitzen
- Spieler und KI keine Doppelaufträge erzeugen
- Beobachtung und Verfolgung respektiert werden
- Persistenzdaten reproduzierbar geschrieben und gelesen werden
- ein DCS-Testfall mit erwarteten Logmeldungen vorliegt
