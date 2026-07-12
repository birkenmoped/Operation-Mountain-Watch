# 05 – Logistik

## Ziel

Logistik soll spielerisch relevant sein, ohne die Kampagne durch Mikromanagement zu dominieren. Hauptbasen besitzen große strategische Reserven; FOBs sind lokal begrenzt und müssen versorgt, verstärkt und gegebenenfalls neu aufgebaut werden.

## Transportarten

Die Kampagne unterscheidet vier reguläre Lieferverfahren sowie eine automatische Rückfallebene:

1. Straßenkonvoi
2. Hubschraubertransport
3. Transportflugzeug mit Landung und Entladung
4. Transportflugzeug mit Luftabwurf
5. automatische AI-Notversorgung als begrenzte Rückfallebene

Straße, Drehflügler, gelandeter Lufttransport und Luftabwurf sind gleichwertige logistische Werkzeuge mit unterschiedlichen Voraussetzungen, Risiken und Kapazitäten. Kein Verfahren ersetzt grundsätzlich die anderen.

## Straßenkonvoi

Straßenkonvois transportieren große Mengen an Personal, Munition, Treibstoff, Baumaterial und Fahrzeugen zwischen straßengebundenen Basen. Sie sind langsam, planbar und anfällig für IEDs, RPGs und Hinterhalte.

Entfernte, unbegleitete Konvois dürfen virtualisiert werden. Bei Spielereskorte, Feindkontakt, Annäherung an ein Ziel oder einen Hinterhalt bleiben sie physisch. Große Konvois werden physisch in mehrere kleinere Gruppen aufgeteilt.

## Hubschraubertransport

Hubschrauber versorgen FOBs, COPs, Kontrollpunkte und Landezonen ohne geeignete Start- und Landebahn. Sie können Personal, Verwundete, interne Fracht oder Außenlasten transportieren.

Vorgesehene Plattformen:

- `CH-47F`: primärer schwerer taktischer Transport für interne Fracht, Truppen und Außenlasten
- `UH-1H`: leichter Transport, Truppenbewegung und kleinere Lieferungen; die historische Einordnung im gewählten Szenario wird separat entschieden
- `UH-60L Community Mod`: optionale Plattform für Transport, MEDEVAC und Verbindung; keine verpflichtende Projekt- oder Serverabhängigkeit
- AI- oder skriptgesteuerte UH-60-ähnliche Plattformen als modfreie Alternative

Für den Prototyp muss mindestens ein spielbarer Hubschraubertyp eine vollständige Lieferkette vom Lager bis zur Ressourcengutschrift durchlaufen. Interne Fracht und Außenlast werden als getrennte technische Pfade getestet.

## C-130J mit Landung

Die C-130J kann geeignete Flugplätze und größere operative Basen direkt versorgen. Die vorgesehene Lieferkette lautet:

1. Fracht an einer strategischen oder regionalen Basis laden.
2. Flug zum Zielairfield durchführen.
3. sicher landen und einen definierten Entlade- oder Lagerbereich erreichen.
4. Fracht entladen beziehungsweise an das lokale Lager übergeben.
5. Manifest genau einmal dem Zielbestand gutschreiben.

Dieses Verfahren ist nur für Ziele mit geeigneter Start- und Landebahn, Rollwegen, Parkpositionen und Entladefläche zulässig. Jalalabad Airfield / FOB Fenty ist im Kernoperationsraum die wichtigste Ausnahme gegenüber reinen FOBs und soll für gelandete C-130J-Lieferungen geprüft werden. Auch Bagram und Kabul sind grundsätzlich geeignete logistische Knoten.

Die genaue DCS- und Warehouse-Integration für gelandene Entladung muss im Spiel getestet werden; sie wird nicht allein aus der allgemeinen Modulbeschreibung abgeleitet.

## C-130J-Luftabwurf

Luftabwurf versorgt Ziele ohne geeignete Landebahn oder bei gesperrten Straßen- und Landezonen. DCS simuliert den physischen Abwurf. Die Kampagnenlogik bewertet nur:

1. Das Frachtobjekt ist stabil gelandet.
2. Seine Endposition liegt innerhalb der definierten Drop Zone.
3. Die Cargo-ID wurde noch nicht gutgeschrieben.

Bei Erfolg wird das Manifest dem Ziel-FOB gutgeschrieben. Abwurfhöhe, Geschwindigkeit, Fallschirm und Drift werden nicht doppelt simuliert.

## Hybride Steuerung

Normale Versorgung wird über Spielerauftrag oder F10-Menü angefordert. Automatische Maßnahmen greifen nur bei kritischem Mindestbestand, aktivem Großangriff oder längerer Abwesenheit geeigneter Logistikspieler.

Der Dispatcher berücksichtigt:

- verfügbare Plattformen
- Frachtgewicht und Volumen
- Zielinfrastruktur
- Bedrohungslage
- Wetter und Tageszeit
- Dringlichkeit
- verfügbare Eskorte
- Straßen-, Lande- und Drop-Zone-Status

## FOB-Wiederaufbau

Ein zerstörter FOB wird stufenweise aufgebaut:

1. Standort sichern.
2. Baucontainer und Ingenieurgruppe liefern.
3. minimale Infrastruktur erzeugen.
4. Personal, Munition, Treibstoff und Fahrzeuge separat zuführen.
5. volle Einsatzbereitschaft herstellen.

Die Lieferungen können je nach Ziel und Lage per Konvoi, Hubschrauber oder Luftabwurf erfolgen. Ein gelandeter C-130J-Transport ist nur an dafür geeigneten Airfields oder großen Basen möglich.

## Noch zu entscheiden und zu testen

- genaue Kapazitäten der FOB-Klassen
- Cargo-Manifeste und CTLD-Kistentypen
- CH-47F: interne Fracht, Außenlast und Warehouse-Transfer
- UH-1H: unterstützte CTLD- und Frachtpfade
- optionaler UH-60L-Mod: Multiplayer-, Wartungs- und Abhängigkeitsfolgen
- C-130J: gelandete Entladung und Lagerübergabe
- Regeln für verlorene oder außerhalb der Drop Zone gelandete Fracht
- Umfang automatischer AI-Nachversorgung
