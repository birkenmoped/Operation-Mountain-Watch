# 05 – Logistik

## Ziel

Logistik soll spielerisch relevant sein, ohne die Kampagne durch Mikromanagement zu dominieren. Hauptbasen besitzen große strategische Reserven; FOBs sind lokal begrenzt und müssen versorgt, verstärkt und gegebenenfalls neu aufgebaut werden.

## Transportarten

Die Kampagne unterscheidet fünf reguläre Lieferverfahren sowie eine automatische Rückfallebene:

1. Straßenkonvoi
2. Hubschraubertransport mit interner Fracht
3. Hubschraubertransport mit Außenlast
4. Transportflugzeug mit Landung und Entladung
5. Transportflugzeug mit Luftabwurf
6. automatische AI-Notversorgung als begrenzte Rückfallebene

Straße, interne Drehflüglerfracht, Außenlast, gelandeter Lufttransport und Luftabwurf sind gleichwertige logistische Werkzeuge mit unterschiedlichen Voraussetzungen, Risiken und Kapazitäten. Kein Verfahren ersetzt grundsätzlich die anderen.

## Gemeinsames Manifestmodell

Jede Lieferung besitzt unabhängig vom Transportweg eine eindeutige Cargo-ID und ein Manifest. Das Manifest beschreibt Ressourcenart, Menge, Gewicht, Volumen, Herkunft, Ziel und aktuellen Status.

Mögliche Statuswerte:

- `AVAILABLE`
- `LOADING`
- `INTERNAL`
- `SLING`
- `IN_TRANSIT`
- `DELIVERED`
- `LOST`
- `DESTROYED`

Eine Cargo-ID darf genau einmal einem Zielbestand gutgeschrieben werden. Ein Wechsel zwischen interner Fracht, Außenlast, Zwischenlager und Weitertransport erzeugt keine neue Ressource.

## Straßenkonvoi

Straßenkonvois transportieren große Mengen an Personal, Munition, Treibstoff, Baumaterial und Fahrzeugen zwischen straßengebundenen Basen. Sie sind langsam, planbar und anfällig für IEDs, RPGs und Hinterhalte.

Entfernte, unbegleitete Konvois dürfen virtualisiert werden. Bei Spielereskorte, Feindkontakt, Annäherung an ein Ziel oder einen Hinterhalt bleiben sie physisch. Große Konvois werden physisch in mehrere kleinere Gruppen aufgeteilt.

## Hubschraubertransport mit interner Fracht

Interne Fracht wird im Laderaum transportiert. Dazu zählen je nach Plattform und technischer Integration:

- Kisten und Behälter
- Paletten oder palletisierte Versorgungsgüter
- Munition, Treibstoff und Baumaterial als Manifest
- Personal, Ingenieurgruppen und Verwundete

Die Kampagnenlogik prüft:

1. Die Fracht ist an einer gültigen Ladezone verfügbar.
2. Gewicht und Volumen liegen innerhalb des Plattformprofils.
3. Die Cargo-ID wird dem Luftfahrzeug zugeordnet.
4. Das Luftfahrzeug erreicht eine gültige Entlade- oder Übergabezone.
5. Die Cargo-ID wird genau einmal an das Ziel übergeben.

Interne Fracht kann nativ durch das DCS-Modul, über MOOSE CTLD oder durch einen projektspezifischen Adapter repräsentiert werden. Der strategische Zustand bleibt davon unabhängig.

## Hubschraubertransport mit Außenlast

Außenlasten werden als physische Frachtobjekte am Lasthaken transportiert. Dieser Pfad ist technisch von interner Fracht getrennt.

Die Kampagnenlogik berücksichtigt:

- Aufnahme an einer gültigen Außenlastzone
- erfolgreichen Hook- oder Sling-Zustand
- Gewichtslimit der Plattform
- Verlust, Zerstörung oder Notabwurf
- Ablage innerhalb einer gültigen Absetzzone
- stabile Endposition vor der Ressourcengutschrift

Eine zuvor intern transportierte Fracht darf nur über einen expliziten Umschlagprozess zur Außenlast werden. Dieselbe Cargo-ID darf nicht gleichzeitig intern und extern geführt werden.

## Hubschrauberplattformen

### CH-47F

Die CH-47F ist die primäre schwere taktische Transportplattform. Für sie werden getrennt unterstützt und getestet:

- interne Kisten und Paletten
- Truppentransport
- interne Frachtentladung
- einpunktige Außenlast
- spätere Mehrpunkt-Außenlast, sobald im verwendeten DCS-Stand verfügbar

### UH-1H

Die UH-1H ist die leichte Transportplattform. Für sie werden ebenfalls getrennt unterstützt und getestet:

- interne Kisten oder kleine Paletten über den verfügbaren DCS-, CTLD- oder Adapterpfad
- Truppentransport
- kleinere Außenlasten
- CSAR- und MEDEVAC-Transport

Die genaue technische Schnittstelle für interne Fracht und Außenlast wird in der Testmission gegen die installierte DCS- und MOOSE-Version geprüft.

### UH-60L Community Mod

Der UH-60L Community Mod ist eine optionale Plattform für interne Fracht, Außenlast, Transport, MEDEVAC und Verbindung. Er wird nicht zur verpflichtenden Projekt- oder Serverabhängigkeit. Unterstützte Frachtarten werden versionsbezogen dokumentiert.

## C-130J mit Landung

Die C-130J kann geeignete Flugplätze und größere operative Basen direkt versorgen. Die vorgesehene Lieferkette lautet:

1. Fracht an einer strategischen oder regionalen Basis laden.
2. Flug zum Zielairfield durchführen.
3. sicher landen und einen definierten Entlade- oder Lagerbereich erreichen.
4. Fracht entladen beziehungsweise an das lokale Lager übergeben.
5. Manifest genau einmal dem Zielbestand gutschreiben.

Dieses Verfahren ist nur für Ziele mit geeigneter Start- und Landebahn, Rollwegen, Parkpositionen und Entladefläche zulässig. Jalalabad Airfield / FOB Fenty ist im Kernoperationsraum die wichtigste Ausnahme gegenüber reinen FOBs und soll für gelandete C-130J-Lieferungen geprüft werden. Auch Bagram und Kabul sind grundsätzlich geeignete logistische Knoten.

Die genaue DCS- und Warehouse-Integration für gelandete Entladung muss im Spiel getestet werden; sie wird nicht allein aus der allgemeinen Modulbeschreibung abgeleitet.

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
- Straßen-, Lande-, Absetz- und Drop-Zone-Status

## FOB-Wiederaufbau

Ein zerstörter FOB wird stufenweise aufgebaut:

1. Standort sichern.
2. Baucontainer und Ingenieurgruppe liefern.
3. minimale Infrastruktur erzeugen.
4. Personal, Munition, Treibstoff und Fahrzeuge separat zuführen.
5. volle Einsatzbereitschaft herstellen.

Die Lieferungen können je nach Ziel und Lage per Konvoi, interner Hubschrauberfracht, Außenlast oder Luftabwurf erfolgen. Ein gelandeter C-130J-Transport ist nur an dafür geeigneten Airfields oder großen Basen möglich.

## Noch zu entscheiden und zu testen

- genaue Kapazitäten der FOB-Klassen
- Cargo-Manifeste, Kistentypen und Palettenmodelle
- CH-47F: interne Kisten, interne Paletten, einpunktige Außenlast und Warehouse-Transfer
- UH-1H: interne Fracht, Truppen und Außenlast über die tatsächlich verfügbaren DCS-/CTLD-Pfade
- optionaler UH-60L-Mod: interne Fracht, Außenlast, Multiplayer- und Abhängigkeitsfolgen
- Umschlag zwischen Lager, interner Fracht und Außenlast
- Regeln für verlorene, zerstörte oder außerhalb der Absetzzone gelandete Fracht
- C-130J-Landung, Entladung und Warehouse-Übergabe
- Umfang automatischer AI-Nachversorgung
