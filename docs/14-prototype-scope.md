# 14 – Vertikaler Prototyp

## Ziel

Der erste Prototyp soll eine kleine, zusammenhängende Kampagnenstrecke vollständig abbilden. Er dient nicht der flächendeckenden Darstellung von RC-East, sondern der technischen Validierung der Kernsysteme.

## Operationsraum

Der Prototyp konzentriert sich auf:

- Jalalabad Airfield / FOB Fenty
- die Straßenverbindung zu FOB Connolly
- angrenzende Siedlungen und Hinterhalträume
- einen begrenzten roten Operationssektor in Nangarhar

Bagram und Kabul existieren zunächst als strategischer Hintergrund und als Quelle übergeordneter Reserven. Sie müssen in der ersten Mission noch nicht vollständig physisch ausgebaut sein.

## Blaue Infrastruktur

- eine operative Hauptbasis: Jalalabad / FOB Fenty
- ein vorgeschobener FOB: FOB Connolly
- ein afghanischer Kontrollpunkt
- ein natives Warehouse an Jalalabad/Fenty
- ein natives oder kontrolliert abstrahierbares Warehouse-Depot an FOB Connolly
- abstrakter lokaler Bestand am afghanischen Kontrollpunkt
- ein Konvoi-Startbereich
- eine C-130J-Entlade- und Lagerübergabezone an Jalalabad/Fenty
- mindestens eine Hubschrauber-Landezone an Jalalabad/Fenty und FOB Connolly
- eine interne Fracht-Ladezone und eine interne Fracht-Entladezone
- eine getrennte Außenlast-Aufnahmezone und Außenlast-Absetzzone
- eine C-130J-Test-Drop-Zone im Raum Jalalabad
- getrennte Warehouse-, Fahrzeug-, interne Fracht-, Außenlast- und C-130J-Übergabezonen

## Rote Infrastruktur

- eine regionale Zelle
- drei mögliche Camp-Slots
- drei bis sechs Hinterhaltstellungen
- zwei Rückzugs- oder Zerstreuungsräume
- mindestens eine virtuelle Nachschubverbindung
- ein Sammel- oder Assembly Area für größere Angriffe
- mindestens eine spielrelevante Siedlung oder Compound-Zone
- drei bis fünf geprüfte Hide Sites
- zwei vorbereitete Fluchtwege
- mindestens ein Suchsektor
- ein vorbereiteter Strongpoint-Slot
- ein bewaffnetes Haus nur dann, wenn ein geeignetes Core-Asset und stabiles Verhalten bestätigt wurden

## Logistik

Der Prototyp bildet mehrere voneinander unabhängige Lieferverfahren ab.

### Warehouse-System

- `CampaignState` als persistente Autorität
- `WarehouseAdapter` als einzige native DCS-/MOOSE-Zugriffsschicht
- Warehouse-Knoten `WH_BLUE_JALALABAD_FENTY`
- Warehouse-Knoten `WH_BLUE_FOB_CONNOLLY`
- idempotente Warehouse-Transaktionen
- Mapping zwischen strategischen Ressourcen und unterstützten DCS-Items oder Flüssigkeiten
- Erkennung bestätigten Spieler- oder AI-Verbrauchs
- Reconciliation bei Abweichungen
- kontrollierter Fallback auf abstrakten Lagerbetrieb

### Straße

- ein leichter Straßenkonvoi
- eine primäre Route
- nach Möglichkeit eine alternative Route
- Ressourcenübergabe an FOB Connolly
- einmalige Warehouse-Transaktion in der Fahrzeug-Übergabezone

### Hubschrauber mit interner Fracht

- CH-47F mit internen Kisten, Paletten oder Personal
- UH-1H mit internen Kisten, kleiner Fracht oder Personal
- optionaler UH-60L Community Mod ohne Pflichtabhängigkeit
- Aufnahme an einer definierten Ladezone
- Zuordnung der Cargo-ID zum Luftfahrzeug
- Entladung an einer definierten Übergabezone
- genau einmalige Gutschrift des Manifests
- Warehouse-Buchung nur über den WarehouseAdapter

### Hubschrauber mit Außenlast

- CH-47F mit physischer Außenlast
- UH-1H mit physischer Außenlast
- optionaler UH-60L Community Mod
- Aufnahme an einer Außenlastzone
- Erkennung von Hook-, Abwurf- und Verlustzustand
- Ablage innerhalb einer gültigen Absetzzone
- stabile Endposition vor der Ressourcengutschrift
- Warehouse-Buchung nur über den WarehouseAdapter

Interne Fracht und Außenlast sind zwei getrennte technische Pfade. Dieselbe Cargo-ID darf nicht gleichzeitig intern und extern geführt werden.

### C-130J mit Landung

- Transport von einer strategischen oder simulierten Quelle nach Jalalabad/Fenty
- Landung, Rollen und Erreichen einer definierten Entladezone
- Entladung oder Warehouse-Übergabe
- einmalige Gutschrift des Manifests an das regionale Lager
- native Warehouse-Aktualisierung, soweit der Ressourcentyp unterstützt wird

### C-130J-Luftabwurf

- ein Testabwurf in eine definierte Drop Zone
- Prüfung der stabilen Endposition
- einmalige Gutschrift gültiger Pakete
- Behandlung verlorener oder außerhalb der Drop Zone gelandeter Fracht
- Zuordnung der Drop Zone zu einem Warehouse-Knoten oder abstrakten lokalen Lager

Automatische Notversorgung bleibt nur eine begrenzte Rückfallebene und ersetzt keine Spielerlogistik.

## Verdeckte rote Präsenz

Der Prototyp bildet eine virtuelle rote Zelle in einer Siedlung oder Compound-Zone ab.

Erforderlich:

- getrennter operativer Zellzustand und Concealment-Zustand
- Zuordnung zu einem logischen Ort und einer Hide Site
- Reservierung der Hide Site
- Materialisierung an einer geprüften Deckungsposition
- Sichtlinien- und Spielerentfernungsprüfung
- defensiver Anfangszustand ohne sofortiges offenes Feuer
- Aktivierung von Beobachtung, Flucht oder Kampf durch eine definierte Bedingung
- Übernahme von Verlusten und Munitionsstand
- Rückzug und spätere Virtualisierung ohne sichtbaren Übergang

Beliebige Scenery-Häuser gelten nicht als automatisch begehbar oder garnisonierbar.

## Missionsarten

Mindestens folgende Missionsabläufe werden abgebildet:

- Konvoieskorte
- Hinterhalt auf einen Konvoi
- QRF für einen angegriffenen Konvoi oder FOB
- Hubschrauber-Nachversorgung mit interner Fracht
- Hubschrauber-Nachversorgung mit Außenlast
- Truppen- oder Ingenieurtransport
- Rücktransport von Personal oder Verwundeten
- gelandete C-130J-Anlieferung nach Jalalabad/Fenty
- C-130J-Luftabwurf
- Aufklärung eines vermuteten Camps
- Aufklärung oder Durchsuchung einer Siedlung
- Eingrenzung einer Hide Site
- Flucht oder Feuerkontakt bei Aufdeckung
- Angriff auf ein bestätigtes Camp
- optionaler Angriff auf einen vorbereiteten Strongpoint
- FOB-Nachversorgung
- CSAR mit möglichem roten Capture-Team

## Zu validierende Kernsysteme

### CampaignState

- Ressourcenbestände an Jalalabad und FOB Connolly
- stabile Entity- und Warehouse-IDs
- Verlust- und Lieferbuchungen
- Warehouse-Transaktionen und Reconciliation-Status
- operativer und Concealment-Zustand der roten Zelle
- Hide-Site-Reservierung und Aufklärungsgrad
- Speichern und Laden eines kleinen Kampagnenzustands

### Virtualisierung

- virtueller Konvoi entlang einer gespeicherten Route
- Materialisierung vor Spieler- oder Feindkontakt
- Erhaltung von Zusammensetzung und Fracht
- sichere Dematerialisierung nach Ende des Kontakts
- virtuelle rote Zelle in einer Siedlung
- verdeckte Materialisierung ohne direkt beobachteten Spawnpunkt
- sichere Revirtualisierung nach Rückzug

### Red Director und ConcealmentManager

- Zielauswahl aus mehreren Möglichkeiten
- Reservierung einer roten Gruppe
- Vorbereitung, Angriff, Rückzug und Wiederaufbau
- verzögerte HUMINT-Meldung über Konvoibewegungen
- Regeneration über eine Nachschubverbindung statt über einen einfachen Respawn
- Auswahl und Reservierung einer geeigneten Hide Site
- Materialisierung mit defensivem Anfangsverhalten
- Suchergebnis: unentdeckt, Flucht oder Kampf
- Strongpoint-Verknüpfung ohne doppelte Ressourcen

### Logistik und WarehouseAdapter

- gemeinsames Manifestmodell für alle Transportwege
- Gutschrift einer erfolgreichen Lieferung unabhängig vom Transportweg
- Umgang mit verlorener, zerstörter oder doppelt gemeldeter Fracht
- CH-47F-interne Fracht separat testen
- CH-47F-Außenlast separat testen
- UH-1H-interne Fracht separat testen
- UH-1H-Außenlast separat testen
- Umschlag zwischen Lager, interner Fracht und Außenlast prüfen
- optionalen UH-60L-Mod nur als Zusatzpfad behandeln
- C-130J-Landung, Entladezone und Lagerübergabe prüfen
- C-130J-Paket nur einmal gutschreiben
- Endposition innerhalb der Drop Zone auswerten
- native Warehouse-Bestände lesen und aktualisieren
- direkten Verbrauch erkennen und strategisch verbuchen
- unbekannte Differenz als `RECONCILE_REQUIRED` markieren
- fehlende Warehouse-Funktion kontrolliert behandeln

### CSAR

- Erzeugung eines Rettungsfalls
- verzögerter Informationsgewinn für Rot
- konkurrierendes Capture-Team
- Abschluss erst nach Rücktransport zu einer geeigneten Einrichtung

## Mission-Editor-Daten

Vor der Implementierung werden benötigt:

- getestete Straßenroute Fenty–Connolly
- vier bis acht Materialisierungsanker
- drei bis sechs Hinterhaltzonen
- Camp-, Assembly- und Rückzugszonen
- FOB-Fenty- und FOB-Connolly-Infrastruktur
- Einheiten-Templates für alle benötigten Rollen
- Spieler-Slots und AI-Startplätze
- Jalalabad-Warehouse-Referenz und Capabilities
- Connolly-Depotobjekt und Warehouse-Testkonfiguration
- Warehouse- und Übergabezonen für beide Knoten
- C-130J-Park-, Roll- und Entladezone an Jalalabad/Fenty
- C-130J-Drop-Zone
- Hubschrauber-Landezonen
- interne Fracht-Lade- und Entladezonen
- Außenlast-Aufnahme- und Absetzzonen
- eine Siedlungs- oder Compound-Zone
- drei bis fünf Hide-Site-Zonen
- zwei Fluchtrouten
- mindestens ein Suchsektor
- ein Strongpoint-Slot

## Abnahmekriterien

Der Prototyp gilt als erfolgreich, wenn:

1. Ein Konvoi virtuell starten und ohne sichtbaren Übergang physisch werden kann.
2. Spieler den Konvoi eskortieren oder auf einen Angriff reagieren können.
3. Eine CH-47F interne Fracht von Jalalabad/Fenty nach FOB Connolly liefern kann.
4. Eine CH-47F eine Außenlast aufnehmen, transportieren und gültig absetzen kann.
5. Eine UH-1H interne Fracht oder Personal korrekt liefern kann.
6. Eine UH-1H eine Außenlast aufnehmen, transportieren und gültig absetzen kann.
7. Für jede der vier Hubschrauberkombinationen Laden, Verlustfall und genau einmalige Gutschrift geprüft wurden oder eine reproduzierbare DCS-/MOOSE-Einschränkung dokumentiert ist.
8. Dieselbe Cargo-ID niemals gleichzeitig intern und als Außenlast verbucht wird.
9. Eine C-130J nach Landung in Jalalabad/Fenty ein Manifest genau einmal an das regionale Lager übergeben kann.
10. Ein C-130J-Luftabwurf gültige Pakete erkennt und verlorene Pakete nicht gutschreibt.
11. Alle Lieferwege dasselbe Ressourcen- und Manifestmodell verwenden.
12. Jalalabad/Fenty als nativer Warehouse-Knoten gefunden, gelesen und kontrolliert initialisiert werden kann.
13. FOB Connolly als nativer Warehouse-Knoten funktioniert oder reproduzierbar auf abstrakten Lagerbetrieb zurückfällt.
14. Eine Lieferung CampaignState und natives Warehouse über genau eine Transaktion aktualisiert.
15. Direkter bestätigter DCS-Verbrauch im CampaignState verbucht wird.
16. Eine unbekannte Bestandsabweichung erkannt und nicht stillschweigend überschrieben wird.
17. Verluste und Fracht korrekt in den Kampagnenzustand übernommen werden.
18. Eine virtuelle rote Zelle einer Siedlung und Hide Site zugeordnet werden kann.
19. Direkt beobachtete oder offene Materialisierungspunkte verworfen werden.
20. Eine rote Gruppe verdeckt materialisiert und zunächst mit defensivem Verhalten aktiviert wird.
21. Eine Such- oder Aufklärungsaktion zu unentdecktem Verbleiben, Flucht oder Kampf führen kann.
22. Überlebende sich zurückziehen und später ohne sichtbaren Übergang virtualisiert werden können.
23. Ein optionaler Strongpoint mit Personal, Munition und Wirkung im CampaignState verknüpft bleibt.
24. Eine rote Zelle angreifen, sich zurückziehen und später nachvollziehbar regenerieren kann.
25. FOB Connolly auf erfolgreiche oder ausgefallene Versorgung reagiert.
26. Ein CSAR-Fall sowohl von Blau als auch von Rot beeinflusst werden kann.
27. Speichern und Laden strategische Bestände, Warehouse-Transaktionen, Zellort, Hide Site und Aufklärungsgrad reproduzierbar wiederherstellt.
28. Die Serverleistung während mehrerer paralleler Aktivitäten stabil bleibt.

## Nicht Bestandteil des ersten Prototyps

- vollständige Darstellung von Kunar und Nuristan
- FOB Blessing und Pech Valley
- komplette multinationale RC-East-Struktur
- vollständige historische Order of Battle
- alle DCS-Einheiten und Luftfahrzeuge
- verpflichtende Community-Mods
- komplexe zivile Simulation
- echte Gebäudeinnenraum-Navigation
- Raum-für-Raum-Kampf
- jedes Gebäude als individuelles Suchziel
- bewaffnete Häuser als Standardersatz für Infanterie
- natives Warehouse an jedem OP, COP oder Checkpoint
- strategischer HVT-Endzustand
