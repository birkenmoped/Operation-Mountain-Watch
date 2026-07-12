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

### Kabul

Kampagnenfunktion:

- politischer und logistischer Rückraum
- Personal- und Materialtransport
- Regierungs- und ISAF-Infrastruktur
- alternative strategische Drehscheibe

Kabul ist kein taktisches Hauptquartier der Kernkampagne, kann aber strategische Transporte, Verstärkungen und besondere Missionen unterstützen.

### Jalalabad Airfield / FOB Fenty

Kampagnenfunktion:

- operatives Hauptquartier von Task Force Bastogne
- regionales Lager für Nangarhar, Laghman, Kunar und Nuristan
- Zusammenstellung von Konvois
- Hubschrauber- und QRF-Bereitschaft
- Aufnahme gelandeter taktischer Lufttransporte
- Vorbereitung von Aufklärungs-, HVT- und CSAR-Einsätzen
- Verstärkung und Wiederaufbau vorgeschobener Außenposten

Jalalabad ist die native DCS-Airbase. FOB Fenty wird als missionsspezifische Infrastruktur am oder neben dem Flugplatz aufgebaut und logisch mit Jalalabad verbunden.

Jalalabad/Fenty ist im taktischen Kernraum ein besonderer Logistikknoten, weil dort sowohl Straßenkonvois und Hubschrauber als auch gelandete C-130J-Transporte zusammengeführt werden können. Der genaue Ablauf für Entladung, Parkposition und Warehouse-Übergabe muss in DCS geprüft werden.

## Vorgeschobene Standorte

### FOB Connolly

Vorgesehene Rolle im ersten Prototyp:

- Ziel einer regionalen Combat Logistics Patrol
- begrenzte lokale Vorräte
- QRF- und Patrouillenstützpunkt
- Hubschrauber-Landezone für Personal und Fracht
- möglicher Empfang kleiner Außenlasten oder abgesetzter CTLD-Fracht
- möglicher Angriffspunkt für Hinterhalte, indirektes Feuer und Versorgungsausfälle

FOB Connolly besitzt keine reguläre C-130J-Landefähigkeit. Seine Versorgung erfolgt primär per Straße und Hubschrauber; Luftabwurf ist nur bei geeigneter Drop Zone und entsprechender Missionslage vorgesehen.

### FOB Mehtar Lam

Vorgesehene spätere Rolle:

- Stützpunkt in Laghman
- PRT- und Stabilitätsmissionen
- regionale Versorgung und Verbindung zwischen Jalalabad und nördlicheren Sektoren

### FOB Blessing

Vorgesehene spätere Rolle:

- abgelegener Außenposten in Kunar
- hubschrauberabhängige Versorgung
- Mörser- und Belagerungsdruck
- Ausgangspunkt für Operationen im Kunar River Valley und Pech Valley

### Afghanische Kontrollpunkte und COPs

Kleinere ANA-, ANP- und Grenzpolizeiposten sichern Straßen, Täler, Übergänge und Siedlungen. Sie verfügen über geringe Vorräte und begrenzte Verteidigungsfähigkeit, können aber lokale Aufklärung, Vorwarnung und Routenpräsenz erzeugen.

Ihre Versorgung erfolgt mit kleinen Straßenfahrzeugen, leichten Hubschraubern oder einzelnen Frachtpaketen. Direkter Fixed-Wing-Betrieb ist nicht vorgesehen.

## Logisches Basenmodell

Jede Base oder jeder FOB erhält:

- stabile ID
- Anzeigename und historische Rolle
- Basenklasse
- Missionseditor-Zonen und physische Vorlagen
- Ressourcenbestände und Kapazitäten
- Garnison und Verteidigungsfähigkeit
- Straßen- und Luftanbindung
- Landezonen, Drop Zones und Lagerbereiche
- Reparatur-, Sanitäts- und CSAR-Fähigkeiten
- Ausbau-, Schadens- und Wiederaufbaustufe

Zusätzlich werden die zulässigen Lieferverfahren explizit erfasst:

- `ROAD_CONVOY`
- `HELICOPTER_INTERNAL`
- `HELICOPTER_SLING`
- `FIXED_WING_LANDED`
- `FIXED_WING_AIRDROP`

FOBs werden aus statischen Objekten, FARP-Komponenten, Helipads, Lagerobjekten, Verteidigungsstellungen und Ressourcenpunkten aufgebaut. Sie müssen keine nativen DCS-Airbases sein.

## Ressourcenfluss

- Bagram erzeugt oder erhält strategische Theaterreserven.
- Kabul unterstützt Personal- und Materialbewegung im Rückraum.
- Jalalabad/Fenty hält einen regionalen Vorrat und verteilt ihn per Straße, Hubschrauber oder taktischem Lufttransport weiter.
- Lokale FOBs und COPs besitzen begrenzte Bestände.
- Unterbrochene Verkehrswege, verlorene Konvois, fehlende Hubschrauberkapazität oder gesperrte Flugplätze reduzieren die tatsächliche Verfügbarkeit.

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
- C-130J-Start, Landung, Rangieren, Entladung und Warehouse-Übergabe
- CH-47F-Abstellplätze, interne Fracht und Außenlast
- UH-1H-CTLD- und Frachtpfade
- Multiplayer-Folgen eines optionalen UH-60L Community Mods
- Spieler-Slots und Konflikte mit statischer Infrastruktur
- Konvoi-Ausfahrten aus Jalalabad/Fenty
- geeignete Flächen für FOB-Vorlagen und Wiederaufbaustufen
