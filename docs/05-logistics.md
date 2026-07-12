# 05 – Logistik

## Ziel

Logistik soll spielerisch relevant sein, ohne die Kampagne durch Mikromanagement zu dominieren. Hauptbasen besitzen große strategische Reserven; FOBs sind lokal begrenzt und müssen versorgt, verstärkt und gegebenenfalls neu aufgebaut werden.

## Versorgungswege

- Straßenkonvoi
- Transporthubschrauber
- Transportflugzeug mit Landung
- C-130J-Luftabwurf
- automatische AI-Notversorgung als Rückfallebene

## Hybride Steuerung

Normale Versorgung wird über Spielerauftrag oder F10-Menü angefordert. Automatische Maßnahmen greifen nur bei kritischem Mindestbestand, aktivem Großangriff oder längerer Abwesenheit geeigneter Logistikspieler.

## C-130J-Abwurf

DCS simuliert den physischen Abwurf. Die Kampagnenlogik bewertet nur:

1. Das Frachtobjekt ist stabil gelandet.
2. Seine Endposition liegt innerhalb der definierten Drop Zone.
3. Die Cargo-ID wurde noch nicht gutgeschrieben.

Bei Erfolg wird das Manifest dem Ziel-FOB gutgeschrieben. Abwurfhöhe, Geschwindigkeit, Fallschirm und Drift werden nicht doppelt simuliert.

## FOB-Wiederaufbau

Ein zerstörter FOB wird stufenweise aufgebaut:

1. Standort sichern.
2. Baucontainer und Ingenieurgruppe liefern.
3. minimale Infrastruktur erzeugen.
4. Personal, Munition, Treibstoff und Fahrzeuge separat zuführen.
5. volle Einsatzbereitschaft herstellen.

## Konvois

Entfernte, unbegleitete Konvois dürfen virtualisiert werden. Bei Spielereskorte, Feindkontakt, Annäherung an ein Ziel oder einen Hinterhalt bleiben sie physisch. Große Konvois werden physisch in mehrere kleinere Gruppen aufgeteilt.

## Noch zu entscheiden

- genaue Kapazitäten der FOB-Klassen
- Cargo-Manifeste und CTLD-Kistentypen
- Regeln für verlorene oder außerhalb der Drop Zone gelandete Fracht
- Umfang automatischer AI-Nachversorgung
