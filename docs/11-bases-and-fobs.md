# 11 – Basen, FOBs und Luftstützpunkte

## Basenhierarchie

### Bagram Airfield

Kampagnenfunktion:

- strategisches Hauptquartier
- zentrale Lufttransportkapazität
- große Reserven
- schwere Wartung und Reparatur
- Kampfflugzeuge und größere Unterstützungsverbände

Bagram besitzt umfangreiche Reserven, diese sind jedoch nicht automatisch an vorgeschobenen Basen verfügbar. Material muss priorisiert und per Luft- oder Straßenverbindung in den Operationsraum transportiert werden.

Bagram wird strategisch als Warehouse-Knoten geführt. Eine native DCS-Warehouse-Anbindung wird aktiviert, sobald Bagram im Kampagnenabschnitt physisch und spielerisch genutzt wird. Im ersten Prototyp darf der Bestand noch vollständig abstrahiert sein.

### Kabul

Kampagnenfunktion:

- politischer und logistischer Rückraum
- Personal- und Materialtransport
- Regierungs- und ISAF-Infrastruktur
- alternative strategische Drehscheibe

Kabul ist kein taktisches Hauptquartier der Kernkampagne, kann aber strategische Transporte, Verstärkungen und besondere Missionen unterstützen.

Kabul wird wie Bagram als strategischer Warehouse-Knoten geführt und erhält erst bei physischer Nutzung eine native Anbindung.

### Jalalabad Airfield / FOB Fenty

Kampagnenfunktion:

- operatives Hauptquartier von Task Force Bastogne
- regionales Lager für Nangarhar, Laghman, Kunar und Nuristan
- Zusammenstellung von Konvois
- Hubschrauber- und QRF-Bereitschaft
- Aufnahme gelandeter taktischer Lufttransporte
- Vorbereitung von Aufklärungs-, HVT- und CSAR-Einsätzen
- Verstärkung und Wiederaufbau vorgeschobener Außenposten

Jalalabad ist die native DCS-Airbase. FOB Fenty bezeichnet für Operation Mountain Watch den militärisch-operativen Bereich des vorhandenen Flugplatzkomplexes und wird nicht als separate Airbase oder als eigenständiger, vollständig neu aufzubauender FOB modelliert.

Der vorhandene Jalalabad-Kartenpunkt, die 3D-Airbase und ihr natives Warehouse bilden die physische Grundlage. Missionsspezifisch ergänzt werden nur Zonen, logische Marker und bei Bedarf einzelne funktionale Static Objects für Bereitstellung, Lagerübergabe, Hubschrauberlogistik, QRF und C-130J-Abfertigung. Ein separates vollständiges Static-Template für FOB Fenty ist nicht erforderlich.

Jalalabad/Fenty ist im taktischen Kernraum ein besonderer Logistikknoten, weil dort Straßenkonvois, Hubschrauber, gelandete C-130J-Transporte und Luftabwürfe zusammengeführt werden können.

Für den Prototyp gilt:

- native DCS-Warehouse-Anbindung ist erforderlich;
- CampaignState-Warehouse-ID: `WH_BLUE_JALALABAD_FENTY`;
- native Bestände und strategische Bestände werden über den WarehouseAdapter synchronisiert;
- C-130J-Entladung, interne Fracht, Außenlast und Fahrzeuge besitzen getrennte Übergabezonen;
- Spielerzugriff und sichtbare Bestände werden in einer Multiplayer-Testmission geprüft;
- es wird kein eigenes vollständiges FOB-Fenty-Static-Template benötigt.

## Vorgeschobene Standorte

### FOB Connolly

Vorgesehene Rolle im ersten Prototyp:

- Ziel einer regionalen Combat Logistics Patrol
- begrenzte lokale Vorräte
- QRF- und Patrouillenstützpunkt
- Hubschrauber-Landezone für Personal und Fracht
- Empfang interner Fracht und Außenlasten
- möglicher Empfang eines Luftabwurfs über eine zugeordnete Drop Zone
- Angriffspunkt für Hinterhalte, indirektes Feuer und Versorgungsausfälle

FOB Connolly besitzt keine reguläre C-130J-Landefähigkeit. Seine Versorgung erfolgt primär per Straße und Hubschrauber; Luftabwurf ist nur bei geeigneter Drop Zone und entsprechender Missionslage vorgesehen.

FOB Connolly erhält im Prototyp:

- CampaignState-Warehouse-ID `WH_BLUE_FOB_CONNOLLY`;
- ein natives DCS-Warehouse oder einen getesteten, als Warehouse nutzbaren Depotknoten;
- ein eindeutig benanntes Depotobjekt, beispielsweise `DEPOT_BLUE_FOB_CONNOLLY`;
- explizite Warehouse-, Fahrzeug-, interne Fracht-, Außenlast- und LZ-Zonen;
- begrenzte Kapazitäten;
- einen kontrollierten Fallback auf abstrakten Lagerbetrieb, falls die native Anbindung in der verwendeten DCS-Version nicht zuverlässig funktioniert.

Für die physische Darstellung wird zunächst das verfügbare Community-Static-Template für FOB Connolly geprüft und anschließend an Zeitraum, Objektzahl, native Kartengebäude und Projektlogik angepasst.

### FOB Mehtar Lam

Vorgesehene spätere Rolle:

- Stützpunkt in Laghman
- PRT- und Stabilitätsmissionen
- regionale Versorgung und Verbindung zwischen Jalalabad und nördlicheren Sektoren

Ob Mehtar Lam ein natives Warehouse erhält, hängt von dauerhafter Spielerinteraktion, Logistikvolumen und technischer Eignung des Depotknotens ab.

Für Mehtar Lam ist in den bisher erfassten Community-Paketen keine bestätigte Vorlage vorhanden. Bei Aufnahme in den Kampagnenumfang wird eine eigene oder neu verfügbare Vorlage benötigt.

### FOB Blessing

Vorgesehene spätere Rolle:

- abgelegener Außenposten in Kunar
- hubschrauberabhängige Versorgung
- Mörser- und Belagerungsdruck
- Ausgangspunkt für Operationen im Kunar River Valley und Pech Valley

FOB Blessing ist ein Kandidat für ein begrenztes natives FOB-Warehouse, falls der Standort dauerhaft spielerrelevant ist. Die Entscheidung erfolgt nach den Erfahrungen mit FOB Connolly.

FOB Blessing ist in der veröffentlichten Inhaltsliste des erfassten Kunar-/Nuristan-Community-Pakets nicht bestätigt. Bis zur Prüfung einer tatsächlich veröffentlichten Ergänzung gilt der Standort als nicht durch ein Static-Template abgedeckt.

### Afghanische Kontrollpunkte, COPs und OPs

Kleinere ANA-, ANP- und Grenzpolizeiposten sichern Straßen, Täler, Übergänge und Siedlungen. Sie verfügen über geringe Vorräte und begrenzte Verteidigungsfähigkeit, können aber lokale Aufklärung, Vorwarnung und Routenpräsenz erzeugen.

Ihre Versorgung erfolgt mit kleinen Straßenfahrzeugen, leichten Hubschraubern oder einzelnen Frachtpaketen. Direkter Fixed-Wing-Betrieb ist nicht vorgesehen.

Diese kleinen Posten erhalten standardmäßig kein natives DCS-Warehouse. Sie führen abstrahierte lokale Bestände im CampaignState. Eine Landezone oder ein Helipad erzeugt nicht automatisch ein Warehouse.

## Warehouse-Klassen

### `STRATEGIC_NATIVE`

Große Airbases oder strategische Knoten mit nativer Warehouse-Nutzung.

### `STRATEGIC_ABSTRACT`

Strategische Knoten, die im aktuellen Kampagnenabschnitt nicht physisch oder spielerisch genutzt werden.

### `FOB_NATIVE`

Permanente, spielerrelevante FOBs mit begrenztem nativen Warehouse und vollständiger CampaignState-Anbindung.

### `LOCAL_ABSTRACT`

Kleine COPs, OPs, Checkpoints und temporäre Basen mit ausschließlich abstrahiertem Bestand.

### `NO_STORAGE`

Temporäre Landezonen, Drop Zones, reine Patrouillenpunkte und andere Orte ohne eigenen Bestand.

## Logisches Basenmodell

Jede Base oder jeder FOB erhält:

- stabile ID
- Anzeigename und historische Rolle
- Basenklasse
- Missionseditor-Zonen und physische Vorlagen, sofern eine eigene physische Vorlage erforderlich ist
- Ressourcenbestände und Kapazitäten
- Garnison und Verteidigungsfähigkeit
- Straßen- und Luftanbindung
- Landezonen, Drop Zones und Lagerbereiche
- Reparatur-, Sanitäts- und CSAR-Fähigkeiten
- Ausbau-, Schadens- und Wiederaufbaustufe
- `warehouse_mode`
- optionale `warehouse_id`
- optionale native Warehouse- oder Depotreferenz
- Warehouse-Capabilities
- Übergabezonen je Transportmodus
- Verhalten bei beschädigtem oder fehlendem Depot

Zusätzlich werden die zulässigen Lieferverfahren explizit erfasst:

- `ROAD_CONVOY`
- `HELICOPTER_INTERNAL`
- `HELICOPTER_SLING`
- `FIXED_WING_LANDED`
- `FIXED_WING_AIRDROP`

FOBs können aus statischen Objekten, FARP-Komponenten, Helipads, Lagerobjekten, Verteidigungsstellungen und Ressourcenpunkten aufgebaut werden. Sie müssen keine nativen DCS-Airbases sein. Bereits ausreichend dargestellte native Airbases werden jedoch nicht ohne funktionalen Grund vollständig durch zusätzliche Static-Templates überbaut.

## Warehouse- und Übergabezonen

Jalalabad/Fenty:

```text
ZONE_FENTY_WAREHOUSE
ZONE_FENTY_INTERNAL_UNLOAD
ZONE_FENTY_SLING_DROP
ZONE_FENTY_C130_UNLOAD
ZONE_FENTY_VEHICLE_DELIVERY
```

Der Präfix `FENTY` ist eine logische Bezeichnung für den militärisch-operativen Teil von Jalalabad Airfield. Er bezeichnet keinen getrennten Kartenstützpunkt und keine separate Airbase.

FOB Connolly:

```text
ZONE_CONNOLLY_WAREHOUSE
ZONE_CONNOLLY_INTERNAL_UNLOAD
ZONE_CONNOLLY_SLING_DROP
ZONE_CONNOLLY_VEHICLE_DELIVERY
ZONE_CONNOLLY_LZ
```

Die Zonen erkennen eine physische Übergabe. Die eigentliche Ressourcenbuchung erfolgt anschließend transaktionsbasiert über CampaignState und WarehouseAdapter.

## Ressourcenfluss

- Bagram erzeugt oder erhält strategische Theaterreserven.
- Kabul unterstützt Personal- und Materialbewegung im Rückraum.
- Jalalabad/Fenty hält einen regionalen Vorrat und verteilt ihn per Straße, Hubschrauber oder taktischem Lufttransport weiter.
- FOB Connolly besitzt einen begrenzten lokalen Bestand und verbraucht Ressourcen für Garnison, Spieler und AI.
- Kleine COPs und Checkpoints besitzen nur abstrakte Bestände.
- Unterbrochene Verkehrswege, verlorene Konvois, fehlende Hubschrauberkapazität, beschädigte Depots oder gesperrte Flugplätze reduzieren die tatsächliche Verfügbarkeit.

## Depotzerstörung und Wiederaufbau

Ein sichtbares Depotobjekt repräsentiert Warehouse-Zugriff und Kapazität, aber nicht zwingend den gesamten strategischen Bestand.

Mögliche Auswirkungen der Zerstörung:

- Spielerzugriff sperren;
- native Warehouse-Anbindung deaktivieren;
- lokale Kapazität reduzieren;
- einen definierten Teil der Bestände vernichten;
- Lieferungen blockieren oder verzögern;
- Wiederaufbauauftrag erzeugen.

Die Auswirkungen werden durch Depotklasse und CampaignState-Regeln bestimmt.

## Funktionale Luftstreitkräfte

### Bagram

- A-10C für CAS und Armed Overwatch
- F-16C für CAS, Präzisionsangriffe und Air Presence
- F-15E für größere Präzisions- und Nachtangriffe
- C-130J für regionalen Lufttransport, gelandete Lieferungen und Luftabwurf
- größere Hubschrauber- und MEDEVAC-Kapazität

### Jalalabad/Fenty

- AH-64D
- OH-58D
- CH-47F als primärer schwerer taktischer Transport
- UH-1H als spielbare leichte Transportoption; historische Einordnung separat prüfen
- UH-60 als AI- oder Skriptplattform
- optionaler UH-60L Community Mod, sofern die Serverpolitik dies zulässt
- C-130J für gelandete Anlieferung und Abholung, sofern Park- und Entladeabläufe funktionieren
- kleinere ISR- und Verbindungsflugzeuge
- zeitweise vorgeschobene Fixed-Wing-Unterstützung, sofern für die konkrete Mission plausibel

### Externe Theaterunterstützung

F/A-18C-Einsätze können von einem Trägerverband im Arabischen Meer kommen. Wegen Entfernung und Tankerbedarf gelten sie nicht als unmittelbar verfügbare Standard-QRF.

Diese Zuordnung ist eine funktionale Kampagnenplanung, keine vollständige historische Order of Battle. Konkrete Staffeln, Stationierungen und Verfügbarkeiten werden vor einer historischen Veröffentlichung separat geprüft.

## Noch zu testen

- Parkpositionen und Größenklassen an Bagram, Kabul und Jalalabad
- Jalalabad-Warehouse finden, lesen und kontrolliert initialisieren
- funktionale Fenty-Zonen auf der vorhandenen Jalalabad-Airbase platzieren, ohne ein separates Volltemplate zu erzeugen
- FOB-Connolly-Community-Template importieren und auf Zeitraum, Abhängigkeiten, Objektzahl und Kartenüberschneidungen prüfen
- FOB-Connolly-Depot als natives Warehouse anbinden
- Spieleranzeige und Zugriffsverhalten je Warehouse-Typ
- Flugzeugbewaffnung und Betankung gegen Bestände
- C-130J-Start, Landung, Rangieren, Entladung und Warehouse-Übergabe
- CH-47F-Abstellplätze, interne Fracht und Außenlast
- UH-1H-CTLD- und Frachtpfade
- Multiplayer-Folgen eines optionalen UH-60L Community Mods
- Spieler-Slots und Konflikte mit statischer Infrastruktur
- Konvoi-Ausfahrten aus Jalalabad/Fenty
- geeignete Flächen für Connolly und spätere FOB-Vorlagen sowie Wiederaufbaustufen
- Verhalten bei zerstörtem Depot und abstraktem Fallback
- Reconciliation nach Neustart und Spielerbeitritt
