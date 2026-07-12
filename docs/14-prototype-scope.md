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
- ein regionales Ressourcenlager
- ein Konvoi-Startbereich
- eine Hubschrauber-Landezone am FOB
- eine C-130J-Test-Drop-Zone im Raum Jalalabad

## Rote Infrastruktur

- eine regionale Zelle
- drei mögliche Camp-Slots
- drei bis sechs Hinterhaltstellungen
- zwei Rückzugs- oder Zerstreuungsräume
- mindestens eine virtuelle Nachschubverbindung
- ein Sammel- oder Assembly Area für größere Angriffe

## Logistik

Der Prototyp enthält:

- einen leichten Straßenkonvoi
- eine primäre Route
- nach Möglichkeit eine alternative Route
- Versorgung per Transporthubschrauber
- einen C-130J-Testabwurf
- Ressourcenübergabe an FOB Connolly
- automatische Notversorgung nur als begrenzte Rückfallebene

## Missionsarten

Mindestens folgende Missionsabläufe werden abgebildet:

- Konvoieskorte
- Hinterhalt auf einen Konvoi
- QRF für einen angegriffenen Konvoi oder FOB
- Aufklärung eines vermuteten Camps
- Angriff auf ein bestätigtes Camp
- FOB-Nachversorgung
- CSAR mit möglichem roten Capture-Team

## Zu validierende Kernsysteme

### CampaignState

- Ressourcenbestände an Jalalabad und FOB Connolly
- stabile Entity-IDs
- Verlust- und Lieferbuchungen
- Speichern und Laden eines kleinen Kampagnenzustands

### Virtualisierung

- virtueller Konvoi entlang einer gespeicherten Route
- Materialisierung vor Spieler- oder Feindkontakt
- Erhaltung von Zusammensetzung und Fracht
- sichere Dematerialisierung nach Ende des Kontakts

### Red Director

- Zielauswahl aus mehreren Möglichkeiten
- Reservierung einer roten Gruppe
- Vorbereitung, Angriff, Rückzug und Wiederaufbau
- verzögerte HUMINT-Meldung über Konvoibewegungen
- Regeneration über eine Nachschubverbindung statt über einen einfachen Respawn

### Logistik

- Gutschrift einer erfolgreichen Lieferung
- Umgang mit verlorener Fracht
- C-130J-Paket nur einmal gutschreiben
- Endposition innerhalb der Drop Zone auswerten

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
- C-130J-Drop-Zone
- Hubschrauber-Landezonen

## Abnahmekriterien

Der Prototyp gilt als erfolgreich, wenn:

1. Ein Konvoi virtuell starten und ohne sichtbaren Übergang physisch werden kann.
2. Spieler den Konvoi eskortieren oder auf einen Angriff reagieren können.
3. Verluste und Fracht korrekt in den Kampagnenzustand übernommen werden.
4. Eine rote Zelle angreifen, sich zurückziehen und später nachvollziehbar regenerieren kann.
5. FOB Connolly auf erfolgreiche oder ausgefallene Versorgung reagiert.
6. Ein CSAR-Fall sowohl von Blau als auch von Rot beeinflusst werden kann.
7. Speichern und Laden den strategischen Zustand reproduzierbar wiederherstellt.
8. Die Serverleistung während mehrerer paralleler Aktivitäten stabil bleibt.

## Nicht Bestandteil des ersten Prototyps

- vollständige Darstellung von Kunar und Nuristan
- FOB Blessing und Pech Valley
- komplette multinationale RC-East-Struktur
- vollständige historische Order of Battle
- alle DCS-Einheiten und Luftfahrzeuge
- komplexe zivile Simulation
- strategischer HVT-Endzustand
