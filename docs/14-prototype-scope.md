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

Der Prototyp bildet mehrere voneinander unabhängige Lieferverfahren mit einem gemeinsamen Manifest- und Cargo-Unit-Modell ab.

### Cargo-Unit-Modell

```text
1 CU = 1.000 kg nominale Transportmasse
```

Der Prototyp verwendet:

| Plattform | Standardkapazität |
|---|---:|
| schwerer Transport-Lkw | 2 CU |
| UH-1H intern | 1 CU |
| UH-1H Außenlast | 1 CU |
| UH-60L intern | 2 CU, optional und vorläufig |
| UH-60L Außenlast | 3 CU, optional und vorläufig |
| CH-47F intern | 5 CU |
| CH-47F Außenlast | 4 CU |
| C-130J gelandet | 12 CU |
| C-130J Luftabwurf | 8 CU |

CU ist ein Kampagnenstandard und ersetzt keine tatsächliche Gewichts-, Volumen-, Schwerpunkt- oder Performanceprüfung.

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

Der Standardkonvoi Fenty–Connolly besteht aus fünf bis sechs Fahrzeugen:

```text
1 Lead-Sicherungsfahrzeug
1 vorderes Sicherungsfahrzeug oder Gun Truck
2 schwere Transport-Lkw mit je 2 CU
1 optionales Führungs-, Berge-, Sanitäts- oder Sicherungsfahrzeug
1 rückwärtiges Sicherungsfahrzeug
```

Prototypregeln:

- bevorzugte DCS-Gruppengröße: vier bis sechs Fahrzeuge;
- harte Obergrenze: acht Fahrzeuge;
- ab neun Fahrzeugen Aufteilung in mehrere Serials;
- Standardfracht: 4 CU;
- eindeutige CU-Zuordnung zu den beiden Fracht-Lkw;
- Teilverlust nur für die Fracht des tatsächlich verlorenen Lkw;
- eine primäre Route;
- nach Möglichkeit eine alternative Route;
- Ressourcenübergabe an FOB Connolly;
- einmalige Warehouse-Transaktion in der Fahrzeug-Übergabezone.

Für mehrere Serials werden 60–120 Sekunden Startabstand oder ungefähr 500–1.000 Meter Marschabstand geprüft.

### Hubschrauber mit interner Fracht

- CH-47F mit 5 CU Standardladung oder Personal
- UH-1H mit 1 CU Standardladung oder Personal
- optionaler UH-60L Community Mod mit vorläufig 2 CU
- Aufnahme an einer definierten Ladezone
- Zuordnung der Cargo-ID zum Luftfahrzeug
- Entladung an einer definierten Übergabezone
- genau einmalige Gutschrift des Manifests
- Warehouse-Buchung nur über den WarehouseAdapter
- reale Gewichts- und Volumenprüfung zusätzlich zu CU

### Hubschrauber mit Außenlast

- CH-47F mit einpunktiger Außenlast bis 4 CU als Kampagnenstandard
- UH-1H mit Außenlast bis 1 CU als Kampagnenstandard
- optionaler UH-60L Community Mod mit vorläufig bis 3 CU
- Aufnahme an einer Außenlastzone
- Erkennung von Hook-, Abwurf- und Verlustzustand
- Ablage innerhalb einer gültigen Absetzzone
- stabile Endposition vor der Ressourcengutschrift
- Warehouse-Buchung nur über den WarehouseAdapter
- keine CH-47F-Mehrpunkt-Außenlast im Prototyp

Interne Fracht und Außenlast sind zwei getrennte technische Pfade. Dieselbe Cargo-ID darf nicht gleichzeitig intern und extern geführt werden.

### C-130J mit Landung

- Transport von einer strategischen oder simulierten Quelle nach Jalalabad/Fenty
- reguläres Kampagnenpaket von 12 CU
- Landung, Rollen und Erreichen einer definierten Entladezone
- Entladung oder Warehouse-Übergabe
- einmalige Gutschrift des Manifests an das regionale Lager
- native Warehouse-Aktualisierung, soweit der Ressourcentyp unterstützt wird
- Weight-and-Balance-, Start-, Lande-, Treibstoff- und Schwerpunktprüfung
- Erfassung der tatsächlichen Cargo- und Loadmaster-Oberfläche
- Roll-on/Roll-off-Fahrzeugtypen zunächst nur als Testkatalog

Die 12 CU sind keine technische Maximalzuladung.

### C-130J-Luftabwurf

- reguläres Kampagnenpaket von 8 CU
- ein Testabwurf in eine definierte Drop Zone
- eindeutige Cargo-ID je Einzelpaket
- Paketaufteilung beispielsweise als `4 × 2 CU`
- Prüfung der stabilen Endposition
- einmalige Gutschrift gültiger Pakete
- Behandlung verlorener oder außerhalb der Drop Zone gelandeter Fracht
- Zuordnung der Drop Zone zu einem Warehouse-Knoten oder abstrakten lokalen Lager
- Prüfung der Handbuchklassen `PER`, `CDS`, `HE` und `BDL_OTHER`
- Prüfung von `TOWPLATE` und `EXTRACTION_CHUTE`, soweit im installierten Modul verfügbar
- kein Fahrzeugabwurf im Prototyp

Die 8 CU sind ein Kampagnenstandard und keine technische Maximalzuladung.

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
- stabile Entity-, Cargo- und Warehouse-IDs
- CU, reales Gewicht, Volumen und Handling-Modus
- Frachtzuordnung je Fahrzeug oder Einzelpaket
- Verlust- und Lieferbuchungen
- Warehouse-Transaktionen und Reconciliation-Status
- operativer und Concealment-Zustand der roten Zelle
- Hide-Site-Reservierung und Aufklärungsgrad
- Speichern und Laden eines kleinen Kampagnenzustands

### Virtualisierung

- virtueller Konvoi entlang einer gespeicherten Route
- Materialisierung vor Spieler- oder Feindkontakt
- Erhaltung von Zusammensetzung und Fracht
- mehrere Serials als gemeinsame strategische Mission
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
- 1 CU als 1.000 kg nominale Planungsgröße
- Gutschrift einer erfolgreichen Lieferung unabhängig vom Transportweg
- Umgang mit verlorener, zerstörter oder doppelt gemeldeter Fracht
- 5- und 6-Fahrzeug-Standardkonvoi
- 8-Fahrzeug-Obergrenze
- mehrere Konvoi-Serials bei neun oder mehr Fahrzeugen
- 4-CU-Konvoimanifest mit je 2 CU pro Fracht-Lkw
- CH-47F mit 5 CU interner Fracht
- CH-47F mit 4 CU Außenlast
- UH-1H mit 1 CU interner Fracht
- UH-1H mit 1 CU Außenlast
- optionalen UH-60L-Mod nur als Zusatzpfad mit vorläufigen Werten behandeln
- Umschlag zwischen Lager, interner Fracht und Außenlast prüfen
- C-130J-Landung mit 12-CU-Standardpaket
- C-130J-Entladezone und Lagerübergabe
- C-130J-Abwurf mit 8-CU-Standardpaket und individuellen Cargo-IDs
- C-130J-Handbuchdaten und Weight and Balance gegen installierte Version prüfen
- C-130J-RORO-Fahrzeugtypen katalogisieren, aber nicht ungeprüft freigeben
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
- Konvoi-Templates mit fünf, sechs und acht Fahrzeugen
- Start- und Sammelzonen für mehrere Serials
- vier bis acht Materialisierungsanker
- drei bis sechs Hinterhaltzonen
- Camp-, Assembly- und Rückzugszonen
- vorhandene Jalalabad/Fenty-Funktionszonen und FOB-Connolly-Infrastruktur
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
- Testfrachtobjekte für `0.5`, `1`, `2`, `3`, `4` und `5 CU`
- C-130J-Testpakete für insgesamt 8 und 12 CU
- Testfahrzeuge für den C-130J-RORO-Katalog
- eine Siedlungs- oder Compound-Zone
- drei bis fünf Hide-Site-Zonen
- zwei Fluchtrouten
- mindestens ein Suchsektor
- ein Strongpoint-Slot

## Abnahmekriterien

Der Prototyp gilt als erfolgreich, wenn:

1. Ein Konvoi virtuell starten und ohne sichtbaren Übergang physisch werden kann.
2. Spieler den Konvoi eskortieren oder auf einen Angriff reagieren können.
3. Ein Standardkonvoi aus fünf oder sechs Fahrzeugen 4 CU transportiert.
4. Die beiden Fracht-Lkw jeweils eindeutig 2 CU tragen.
5. Der Verlust eines Fracht-Lkw nur dessen 2 CU entfernt.
6. Ein Konvoi mit acht Fahrzeugen die geprüfte Route reproduzierbar bewältigt.
7. Eine größere Kolonne in mindestens zwei Serials aufgeteilt werden kann.
8. Die Serials getrennte DCS-Gruppen, aber einen gemeinsamen strategischen Auftrag besitzen.
9. Eine CH-47F 5 CU interne Fracht von Jalalabad/Fenty nach FOB Connolly liefern kann.
10. Eine CH-47F eine 4-CU-Außenlast aufnehmen, transportieren und gültig absetzen kann.
11. Eine UH-1H 1 CU interne Fracht oder Personal korrekt liefern kann.
12. Eine UH-1H eine 1-CU-Außenlast aufnehmen, transportieren und gültig absetzen kann.
13. Für jede Hubschrauberkombination Laden, Verlustfall und genau einmalige Gutschrift geprüft wurden oder eine reproduzierbare DCS-/MOOSE-Einschränkung dokumentiert ist.
14. Dieselbe Cargo-ID niemals gleichzeitig intern und als Außenlast verbucht wird.
15. Eine C-130J nach Landung in Jalalabad/Fenty ein 12-CU-Standardmanifest genau einmal an das regionale Lager übergeben kann.
16. Das 12-CU-Manifest zusätzlich gegen tatsächliches Gewicht, Volumen, Schwerpunkt und Modulgrenzen validiert wird.
17. Ein C-130J-Luftabwurf ein 8-CU-Manifest in Einzelpakete aufteilt.
18. Jedes C-130J-Abwurfpaket eine eigene Cargo-ID besitzt.
19. Gültige Pakete einzeln gutgeschrieben und verlorene Pakete nicht gutgeschrieben werden.
20. RORO-Fahrzeugtypen nur nach dokumentiertem Modultest freigegeben werden.
21. Alle Lieferwege dasselbe Ressourcen-, Manifest- und CU-Modell verwenden.
22. Jalalabad/Fenty als nativer Warehouse-Knoten gefunden, gelesen und kontrolliert initialisiert werden kann.
23. FOB Connolly als nativer Warehouse-Knoten funktioniert oder reproduzierbar auf abstrakten Lagerbetrieb zurückfällt.
24. Eine Lieferung CampaignState und natives Warehouse über genau eine Transaktion aktualisiert.
25. Direkter bestätigter DCS-Verbrauch im CampaignState verbucht wird.
26. Eine unbekannte Bestandsabweichung erkannt und nicht stillschweigend überschrieben wird.
27. Verluste und Fracht korrekt in den Kampagnenzustand übernommen werden.
28. Eine virtuelle rote Zelle einer Siedlung und Hide Site zugeordnet werden kann.
29. Direkt beobachtete oder offene Materialisierungspunkte verworfen werden.
30. Eine rote Gruppe verdeckt materialisiert und zunächst mit defensivem Verhalten aktiviert wird.
31. Eine Such- oder Aufklärungsaktion zu unentdecktem Verbleiben, Flucht oder Kampf führen kann.
32. Überlebende sich zurückziehen und später ohne sichtbaren Übergang virtualisiert werden können.
33. Ein optionaler Strongpoint mit Personal, Munition und Wirkung im CampaignState verknüpft bleibt.
34. Eine rote Zelle angreifen, sich zurückziehen und später nachvollziehbar regenerieren kann.
35. FOB Connolly auf erfolgreiche oder ausgefallene Versorgung reagiert.
36. Ein CSAR-Fall sowohl von Blau als auch von Rot beeinflusst werden kann.
37. Speichern und Laden strategische Bestände, Cargo-Zuordnungen, Warehouse-Transaktionen, Zellort, Hide Site und Aufklärungsgrad reproduzierbar wiederherstellt.
38. Die Serverleistung während mehrerer paralleler Aktivitäten stabil bleibt.

## Nicht Bestandteil des ersten Prototyps

- vollständige Darstellung von Kunar und Nuristan
- FOB Blessing und Pech Valley
- komplette multinationale RC-East-Struktur
- vollständige historische Order of Battle
- alle DCS-Einheiten und Luftfahrzeuge
- verpflichtende Community-Mods
- CH-47F-Mehrpunkt-Außenlast
- verbindlich freigegebene UH-60L-Kapazitäten ohne Versionstest
- ungeprüfte C-130J-RORO-Konfigurationen
- C-130J-Fahrzeugabwurf
- technische Maximalzuladung als Missionsstandard
- komplexe zivile Simulation
- echte Gebäudeinnenraum-Navigation
- Raum-für-Raum-Kampf
- jedes Gebäude als individuelles Suchziel
- bewaffnete Häuser als Standardersatz für Infanterie
- natives Warehouse an jedem OP, COP oder Checkpoint
- strategischer HVT-Endzustand
