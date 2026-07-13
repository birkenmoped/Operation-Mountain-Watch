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

## Hybride Warehouse-Architektur

`CampaignState` bleibt die persistente Quelle der Wahrheit. Native DCS-Warehouses werden an dauerhaften, spielerrelevanten Logistikknoten eingesetzt und über einen `WarehouseAdapter` synchronisiert.

Für den Prototyp gilt:

- Jalalabad/FOB Fenty besitzt eine native Warehouse-Anbindung;
- FOB Connolly besitzt eine native Warehouse-Anbindung oder einen getesteten, als Warehouse nutzbaren Depotknoten;
- Bagram und Kabul bleiben zunächst strategisch abstrahiert und erhalten bei physischer Nutzung eine native Anbindung;
- der afghanische Checkpoint besitzt nur einen abstrakten lokalen Bestand;
- temporäre Landezonen und Drop Zones sind keine eigenen Warehouses;
- rote Camps und Hide Sites besitzen keine blauen DCS-Warehouses.

Native Warehouses bilden nur Ressourcen ab, die DCS tatsächlich verwalten und verbrauchen kann, zum Beispiel Flugzeuge, Waffen, Treibstoffe und geeignete Cargo-Inhalte. Personal, Ingenieurkapazität, Baumaterial, medizinische Kapazität, Intelligence und Moral bleiben strategische Ressourcen.

## Warehouse-Transaktionen

Jede Bestandsänderung an einem nativen Warehouse erhält eine stabile Transaktions-ID.

Ablauf einer Lieferung:

```text
Fracht validieren
→ Transaktion anlegen
→ CampaignState gutschreiben
→ unterstützte native Warehouse-Bestände aktualisieren
→ Bestände zurücklesen
→ Transaktion abschließen
```

Direkter Verbrauch durch Spieler oder AI wird vom `WarehouseAdapter` erkannt und anschließend im `CampaignState` belastet. Unbekannte Differenzen werden als `RECONCILE_REQUIRED` markiert und nicht stillschweigend übernommen.

Der `LogisticsManager` kennt keine internen DCS-Itemnamen und greift nicht direkt auf MOOSE `STORAGE` zu.

## Warehouse- und Übergabezonen

Die physische Lieferung wird über explizite Zonen erkannt. Räumliche Nähe zu einem Depotobjekt allein genügt nicht.

Jalalabad/Fenty benötigt mindestens:

- `ZONE_FENTY_WAREHOUSE`
- `ZONE_FENTY_INTERNAL_UNLOAD`
- `ZONE_FENTY_SLING_DROP`
- `ZONE_FENTY_C130_UNLOAD`
- `ZONE_FENTY_VEHICLE_DELIVERY`

FOB Connolly benötigt mindestens:

- `ZONE_CONNOLLY_WAREHOUSE`
- `ZONE_CONNOLLY_INTERNAL_UNLOAD`
- `ZONE_CONNOLLY_SLING_DROP`
- `ZONE_CONNOLLY_VEHICLE_DELIVERY`
- `ZONE_CONNOLLY_LZ`

Eine Zone kann mehrere physische Darstellungen enthalten, besitzt aber nur eine klar definierte Übergaberegel je Transportmodus.

## Straßenkonvoi

Straßenkonvois transportieren große Mengen an Personal, Munition, Treibstoff, Baumaterial und Fahrzeugen zwischen straßengebundenen Basen. Sie sind langsam, planbar und anfällig für IEDs, RPGs und Hinterhalte.

Entfernte, unbegleitete Konvois dürfen virtualisiert werden. Bei Spielereskorte, Feindkontakt, Annäherung an ein Ziel oder einen Hinterhalt bleiben sie physisch. Große Konvois werden physisch in mehrere kleinere Gruppen aufgeteilt.

Am Ziel wird das Manifest in der Fahrzeug-Übergabezone validiert. Erst danach wird eine Warehouse-Transaktion erzeugt.

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

Dieses Verfahren ist nur für Ziele mit geeigneter Start- und Landebahn, Rollwegen, Parkpositionen und Entladefläche zulässig. Jalalabad Airfield / FOB Fenty ist im Kernoperationsraum die wichtigste Ausnahme gegenüber reinen FOBs. Bagram und Kabul sind grundsätzlich weitere strategische Knoten.

Die C-130J-Entladung wird über `ZONE_FENTY_C130_UNLOAD` erkannt. Der WarehouseAdapter führt anschließend die strategische und, soweit unterstützt, native Buchung aus.

## C-130J-Luftabwurf

Luftabwurf versorgt Ziele ohne geeignete Landebahn oder bei gesperrten Straßen- und Landezonen. DCS simuliert den physischen Abwurf. Die Kampagnenlogik bewertet nur:

1. Das Frachtobjekt ist stabil gelandet.
2. Seine Endposition liegt innerhalb der definierten Drop Zone.
3. Die Cargo-ID wurde noch nicht gutgeschrieben.

Bei Erfolg wird das Manifest dem Ziel-FOB gutgeschrieben. Abwurfhöhe, Geschwindigkeit, Fallschirm und Drift werden nicht doppelt simuliert.

Eine Drop Zone ist kein Warehouse. Die gültige Fracht wird dem zugeordneten Warehouse-Knoten oder abstrakten lokalen Lager gutgeschrieben.

## Hybride Steuerung

Normale Versorgung wird über Spielerauftrag oder F10-Menü angefordert. Automatische Maßnahmen greifen nur bei kritischem Mindestbestand, aktivem Großangriff oder längerer Abwesenheit geeigneter Logistikspieler.

Der Dispatcher berücksichtigt:

- verfügbare Plattformen
- Frachtgewicht und Volumen
- Zielinfrastruktur
- Warehouse-Modus und Capabilities
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
5. Warehouse- oder abstrakten Lagerbetrieb wiederherstellen.
6. volle Einsatzbereitschaft herstellen.

Die Lieferungen können je nach Ziel und Lage per Konvoi, interner Hubschrauberfracht, Außenlast oder Luftabwurf erfolgen. Ein gelandeter C-130J-Transport ist nur an dafür geeigneten Airfields oder großen Basen möglich.

Die Zerstörung eines sichtbaren Depotobjekts vernichtet nicht automatisch den vollständigen strategischen Bestand. Die Wirkung hängt von Depotklasse, Schadensmodell und CampaignState-Regeln ab.

## Noch zu entscheiden und zu testen

- genaue Kapazitäten der FOB-Klassen
- Cargo-Manifeste, Kistentypen und Palettenmodelle
- CH-47F: interne Kisten, interne Paletten, einpunktige Außenlast und Warehouse-Transfer
- UH-1H: interne Fracht, Truppen und Außenlast über die tatsächlich verfügbaren DCS-/CTLD-Pfade
- optionaler UH-60L-Mod: interne Fracht, Außenlast, Multiplayer- und Abhängigkeitsfolgen
- Umschlag zwischen Lager, interner Fracht und Außenlast
- Regeln für verlorene, zerstörte oder außerhalb der Absetzzone gelandete Fracht
- C-130J-Landung, Entladung und Warehouse-Übergabe
- native Warehouse-Sichtbarkeit für Spieler je Warehouse-Typ
- konkrete DCS-Itemnamen und Ressourcen-Mappings
- Erkennung von Spieler- und AI-Verbrauch
- Reconciliation bei Abweichungen und Spielerbeitritt
- Verhalten bei zerstörtem oder fehlendem Depotobjekt
- Umfang automatischer AI-Nachversorgung
