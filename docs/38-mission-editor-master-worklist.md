# Operation Mountain Watch – Missionseditor-Masterarbeitsliste

## 1. Zweck

Diese Arbeitsliste enthält alle Objekte, Zonen, Marker, Templates und Metadaten, die im DCS-Missionseditor vorbereitet werden müssen, damit die geplante Kampagnenarchitektur später sauber durch MOOSE und den CampaignState genutzt werden kann.

Die Liste ist bewusst als **Missionsdesigner-Arbeitsgrundlage** formuliert. Sie wird während des Codereviews von TM01 und TM02 weiter präzisiert.

## 2. Verbindliche Benennungsregeln

Vor dem Setzen größerer Objektmengen ist ein einheitliches Namensschema festzulegen.

Empfohlene Präfixe:

- `OMW_BLUE_AIRBASE_...`
- `OMW_BLUE_FOB_...`
- `OMW_BLUE_FARP_...`
- `OMW_BLUE_WH_...`
- `OMW_BLUE_ARTY_...`
- `OMW_BLUE_AMMO_...`
- `OMW_BLUE_PATROL_...`
- `OMW_RED_HQ_...`
- `OMW_RED_DIST_...`
- `OMW_RED_HIDE_...`
- `OMW_RED_CACHE_...`
- `OMW_RED_TRANSFER_...`
- `OMW_RED_ROUTE_...`
- `OMW_SETTLEMENT_...`
- `OMW_DELIVERY_...`
- `OMW_HUMINT_...`
- `OMW_TM01_...`
- `OMW_TM02_...`

Jeder Name muss eindeutig, stabil und ohne nachträgliche automatische Umnummerierung nutzbar sein.

## 3. Flugplätze und Luft-ORBAT

Für jeden bereits festgelegten Flugplatz und jedes dort geplante ORBAT sind folgende Arbeiten durchzuführen.

### 3.1 Flugplatz-Stammdaten

- [ ] Flugplatzname und DCS-Airbase-ID dokumentieren
- [ ] Koalition festlegen
- [ ] AIRWING-Name festlegen
- [ ] COMMANDER-Zuordnung festlegen
- [ ] Warehouse-Zuordnung festlegen
- [ ] verfügbare Parkpositionen prüfen
- [ ] große Muster wie C-130J auf geeignete Slots prüfen
- [ ] Hubschrauberparkplätze prüfen
- [ ] Taxiwege und bekannte AI-Probleme dokumentieren
- [ ] Spawn- und Recovery-Verfahren pro Muster testen

### 3.2 Squadron-Templates

Für jedes festgelegte Muster:

- [ ] eine oder mehrere korrekt benannte Late-Activated-Gruppen als Squadron-Template setzen
- [ ] Land- oder Ramp-Start korrekt festlegen
- [ ] Funkfrequenz festlegen
- [ ] Callsign-Konzept festlegen
- [ ] Livery festlegen
- [ ] Nutzlastvarianten definieren
- [ ] Treibstoffmenge definieren
- [ ] Startpositionen gegen gegenseitige Blockierung testen
- [ ] `SetOptionPreferVertical()`-Eignung für Hubschrauber dokumentieren
- [ ] Nacht- und Schlechtwettertauglichkeit prüfen, sofern vorgesehen

### 3.3 Rollen pro Squadron

Pro Squadron dokumentieren und im späteren Code abbilden:

- [ ] CAP
- [ ] CAS
- [ ] Armed Reconnaissance
- [ ] Strike
- [ ] Escort
- [ ] SEAD/DEAD, sofern vorhanden
- [ ] Transport
- [ ] CSAR
- [ ] Reconnaissance
- [ ] Logistics

### 3.4 Flugplatzunterstützung

- [ ] ATIS-Frequenz und Textdaten vorbereiten
- [ ] FLIGHTCONTROL-Verfahren definieren
- [ ] Tanker-Orbits als Zonen oder Wegpunkte setzen
- [ ] AWACS-Orbits als Zonen oder Wegpunkte setzen
- [ ] Holding Areas vorbereiten
- [ ] An- und Abflugkorridore dokumentieren
- [ ] Notfall- und Alternate-Airfields festlegen

## 4. BLUE-FOBs und FARPs

Für jeden FOB beziehungsweise FARP:

### 4.1 Grundobjekte

- [ ] eindeutigen Mittelpunkt beziehungsweise Referenzpunkt setzen
- [ ] FOB-Zone setzen
- [ ] Perimeter-Zone setzen
- [ ] Spawn-/Assembly-Zone für Bodengruppen setzen
- [ ] Fahrzeugausfahrt definieren
- [ ] Hubschrauber-Landezonen definieren
- [ ] FARP-Pads und Parkpositionen prüfen
- [ ] statische Basisausstattung setzen
- [ ] Beleuchtung und Nachtbetrieb prüfen

### 4.2 Einheiten und Verbandsstruktur

- [ ] Brigade-Zuordnung festlegen
- [ ] Platoon-Templates für Infanterie setzen
- [ ] Platoon-Templates für Patrouillenfahrzeuge setzen
- [ ] Quick Reaction Force definieren
- [ ] Base-Defense-Gruppen setzen
- [ ] Artilleriegruppe setzen, sofern vorgesehen
- [ ] AmmoTruck-Template setzen
- [ ] Logistikfahrzeuge setzen
- [ ] CSAR-Assets zuordnen
- [ ] Transporthubschrauber oder Abstellbereiche zuordnen

### 4.3 Warehouse

- [ ] Warehouse-Objekt beziehungsweise DCS-Lagerreferenz festlegen
- [ ] Warehouse-Zone setzen
- [ ] Ladezone setzen
- [ ] Entladezone setzen
- [ ] initiale Bestände definieren
- [ ] Treibstoffkapazität festlegen
- [ ] Munitionskapazität festlegen
- [ ] Fahrzeugreserve festlegen
- [ ] Personalreserve festlegen
- [ ] Wiederaufbau- und Verlustregeln dokumentieren

### 4.4 Patrouillenräume

- [ ] lokale Patrouillenrouten setzen
- [ ] Kontrollpunkte setzen
- [ ] Wendepunkte prüfen
- [ ] problematische Straßenstellen markieren
- [ ] alternative Routen definieren
- [ ] Sperrzonen und No-Go-Bereiche definieren
- [ ] Reaktionsräume für QRF festlegen

## 5. Artillerie und Munitionslogistik

Für jede BLUE-Artilleriestellung:

- [ ] Artilleriegruppe eindeutig benennen
- [ ] Feuerstellungszone definieren
- [ ] Mindest- und Maximalreichweite dokumentieren
- [ ] zugeordnetes FOB/Warehouse festlegen
- [ ] AmmoTruck-Startpunkt festlegen
- [ ] Übergabepunkt für taktische Munitionsversorgung setzen
- [ ] sichere Anfahrt testen
- [ ] Ausweichstellung vorbereiten, sofern vorgesehen
- [ ] Friendly-Fire- und No-Fire-Zonen setzen
- [ ] zivile Schutzbereiche markieren

## 6. CSAR-Infrastruktur

- [ ] CSAR-fähige Spieler-Slots kennzeichnen
- [ ] AI-CSAR-Assets als Templates setzen
- [ ] Start- und Bereitschaftsorte definieren
- [ ] medizinische Übergabepunkte festlegen
- [ ] Hospital- oder FOB-Recovery-Zonen setzen
- [ ] Capture-Räume beziehungsweise RED-Einflussräume definieren
- [ ] problematische Hochgebirgsbereiche dokumentieren
- [ ] Nacht-CSAR-Verfahren prüfen

## 7. TM01 – BLUE-Konvoi- und Virtualisierungstestbereich

### 7.1 Konvoi-Templates

- [ ] alle TM01-Konvoi-Templates eindeutig benennen
- [ ] Fahrzeugreihenfolge prüfen
- [ ] maximale Gruppengröße dokumentieren
- [ ] Startzonen setzen
- [ ] Zielzonen setzen
- [ ] echte Warehouse-Quellen und -Ziele zuordnen
- [ ] transportierte Güter je Template definieren

### 7.2 Routen

- [ ] Hauptrouten im Missionseditor setzen
- [ ] alternative Routen setzen
- [ ] kritische Engstellen markieren
- [ ] Brücken markieren
- [ ] enge Ortsdurchfahrten markieren
- [ ] bekannte AI-Staupunkte markieren
- [ ] Recovery-/Reset-Punkte setzen
- [ ] Pack-/Unpack-Korridore festlegen

### 7.3 Beobachtungs- und Schutzbereiche

- [ ] Spieler-Näherungszonen definieren
- [ ] Feind-Näherungszonen definieren
- [ ] No-Teleport-Zonen definieren
- [ ] Kampf- und Aufklärungszustände testbar machen
- [ ] Testmarker für Watchguard-Zustände setzen

## 8. TM02 – RED-Netzwerk, Unterschlüpfe und Caches

TM02 muss nach der neuen Architektur umfassend neu vorbereitet werden.

### 8.1 Initiale RED-Knoten

- [ ] ein RED-HQ festlegen
- [ ] 2 bis 3 initiale Verteilerdepots festlegen
- [ ] Warehouse- oder Bestandsreferenzen definieren
- [ ] initiale RED-Bestände festlegen
- [ ] zulässige Ausgangsrouten definieren
- [ ] BLUE-Abstände und Missionsraum prüfen

### 8.2 Candidate Sites

Für jeden potenziellen Standort:

- [ ] eindeutige Candidate-Site-ID setzen
- [ ] Mittelpunkt setzen
- [ ] Standortzone setzen
- [ ] Standorttyp festlegen
- [ ] urban, ländlich oder abgelegen klassifizieren
- [ ] Straßenzugang ja/nein festlegen
- [ ] Infanteriezugang festlegen
- [ ] zulässige Transportart festlegen
- [ ] Kapazität festlegen
- [ ] mögliche statische Darstellung auswählen
- [ ] Bau-/Aktivierungszone setzen
- [ ] Flucht- oder Evakuierungsrichtung dokumentieren
- [ ] Abstand zu anderen RED-Standorten prüfen
- [ ] Abstand zu BLUE prüfen
- [ ] Eignung bei Nacht und Tag prüfen

### 8.3 Statische Standort-Templates

Für jeden Standorttyp:

- [ ] unauffälliges Urban-Safe-House-Template
- [ ] ländliches Hide-Site-Template
- [ ] Forward-Cache-Template
- [ ] Waffenlager-Template
- [ ] Munitionslager-Template
- [ ] medizinisches Lager, sofern vorgesehen
- [ ] Transferpunkt-Template
- [ ] zerstörte oder geräumte Variante

Die Darstellung darf bestehende Szeneriegebäude nutzen, muss aber über stabile Triggerzonen und Referenzpunkte auswertbar bleiben.

### 8.4 RED-Transport-Templates

- [ ] leichte Infanterieträgergruppe
- [ ] größere Trägergruppe
- [ ] Pickup-/Truck-Transport nur für geeignete Straßen
- [ ] Eskorte, sofern strategisch begründet
- [ ] Hybridtransport mit Fahrzeug-Transferpunkt und Infanterie-Endstrecke
- [ ] Rückkehr- oder Evakuierungsgruppe

Jedes Template erhält definierte Kapazität und zulässige Frachtarten.

### 8.5 RED-Routen und Transferpunkte

- [ ] Straßennetze für Fahrzeugtransporte setzen
- [ ] Transferpunkte Fahrzeug zu Infanterie setzen
- [ ] Infanteriekorridore setzen
- [ ] Engstellen und Beobachtungspunkte markieren
- [ ] Exposure Windows setzen
- [ ] alternative Routen definieren
- [ ] wiederholte Routennutzung auswertbar machen
- [ ] Zielnähe-Zonen für physische Materialisierung setzen

### 8.6 Aufklärung und Tracking

- [ ] Zonen für mögliche Area-of-Interest-Markierungen vorbereiten
- [ ] Suchzonen unterschiedlicher Größe definieren
- [ ] PLAYERRECCE-Testbereiche vorbereiten
- [ ] Beobachtungspunkte für Boden- und Luftaufklärung setzen
- [ ] Follow-to-destination-Testfälle vorbereiten
- [ ] No-Dematerialization-Zonen und -Situationen testen

## 9. Städte und Dörfer für Civil Support & HUMINT

Die erste Ausbaustufe soll nur ausgewählte Orte umfassen.

### 9.1 Auswahl je Ortschaft

- [ ] Name und eindeutige ID festlegen
- [ ] Mittelpunkt setzen
- [ ] Settlement-Zone setzen
- [ ] Größe klassifizieren: Dorf, größere Ortschaft, Stadt
- [ ] HUMINT-Radius festlegen
- [ ] Nähe zu RED-Kandidaten prüfen
- [ ] Nähe zu MSR/ASR prüfen
- [ ] Nähe zu BLUE-FOB prüfen
- [ ] Start-Support-Level festlegen
- [ ] bei vorhandenem BLUE-FOB Level 1 als Vorschuss setzen

### 9.2 Zustellpunkte

Je Ortschaft prüfen und nur geeignete Verfahren freigeben:

- [ ] Hubschrauber-Lande- und interne Entladezone
- [ ] Slingload-Absetzpunkt
- [ ] C-130J-Abwurfzone
- [ ] Anflugrichtung dokumentieren
- [ ] Abflugrichtung dokumentieren
- [ ] Geländeneigung prüfen
- [ ] Gebäude und Stromleitungen prüfen
- [ ] ausreichend freie Fläche prüfen
- [ ] sichtbare Marker oder statische Orientierungspunkte setzen
- [ ] Triggerzone zur Lieferbestätigung setzen
- [ ] Fallback nur dann setzen, wenn zwingend erforderlich

Nicht jeder Ort muss C-130J-Abwurf und Hubschrauberzustellung gleichzeitig erlauben.

### 9.3 Zugelassene Spielerluftfahrzeuge

- [ ] UH-1H Huey für interne Fracht und Slingload vorsehen
- [ ] festgelegte UH-60-Variante vorsehen
- [ ] festgelegte CH-47-Variante vorsehen
- [ ] C-130J für Abwurf vorsehen
- [ ] zulässige Cargo-Objekte je Muster testen
- [ ] maximale Frachtmengen festlegen
- [ ] Entlade- und Abwurferkennung testen

Keine KI-Transporte und keine Bodenkonvois für diese Sidequests.

### 9.4 HUMINT-Ausgabe

Für jede Ortschaft vorbereiten:

- [ ] Level-1-Meldungstexte
- [ ] Level-2-Meldungstexte
- [ ] Level-3-Meldungstexte
- [ ] grobe Richtungssektoren
- [ ] mögliche Suchradien
- [ ] passende Kartenmarker
- [ ] Ablauf- und Veraltungszeit der Information
- [ ] Folgeauftragstypen

## 10. Missionsmarker und Debug-Hilfen

Für Entwicklung und Test:

- [ ] Marker für alle Warehouses
- [ ] Marker für Candidate Sites
- [ ] Marker für aktive RED-Standorte
- [ ] Marker für virtuelle und physische Bewegungen
- [ ] Marker für ExposureScore und ExposureDebt
- [ ] Marker für Tracking-Zustand
- [ ] Marker für Settlement-Support
- [ ] Marker für HUMINT-Radius
- [ ] Marker für MissionDemand-Zustand
- [ ] schaltbares Debug-Menü vorbereiten

Produktive Missionen dürfen geheime RED-Daten natürlich nicht für normale Spieler anzeigen.

## 11. Datenexport für den Code

Alle im Editor gesetzten Objekte müssen in einer maschinenlesbaren Masterliste dokumentiert werden.

Pro Eintrag mindestens:

- ID
- DCS-Name
- Typ
- Koordinate
- Zone
- Koalition
- Parent-Objekt
- CampaignState-Zuordnung
- erlaubte Rollen
- relevante Metadaten
- Teststatus

Empfohlene Tabellen beziehungsweise Dateien:

- Airbases
- Squadrons
- FOBs
- Warehouses
- Brigades und Platoons
- Artillery Sites
- CSAR Sites
- TM01 Routes
- RED Candidate Sites
- RED Distribution Network
- Settlements
- Delivery Points
- HUMINT Profiles

## 12. Empfohlene Bearbeitungsreihenfolge

1. Benennungsstandard endgültig festlegen.
2. Alle bereits beschlossenen Flugplätze und ORBATs vollständig setzen.
3. FOBs, FARPs, Einheiten und Warehouses setzen.
4. TM01-Routen und Konvoiobjekte bereinigen.
5. TM02-HQ, Verteilerdepots und Candidate Sites setzen.
6. RED-Transport- und Standorttemplates erstellen.
7. ausgewählte Settlements festlegen.
8. Zustell- und Abwurfzonen setzen.
9. HUMINT-Radien und Suchräume setzen.
10. Debug-Marker und Testfälle ergänzen.
11. alle Namen und Koordinaten in die Projektdokumentation exportieren.
12. erst danach produktiven Implementierungscode auf die finalen Namen binden.

## 13. Noch zu ergänzende konkrete Listen

Nach dem vollständigen Codereview von TM01 und TM02 werden folgende Tabellen ergänzt:

- vollständige Flugplatzliste mit ORBAT-Zuordnung
- vollständige FOB-Liste mit Einheiten und Warehouse-Anfangsbeständen
- vollständige Candidate-Site-Liste
- vollständige Settlement-Liste
- konkrete Zustellpunktnamen
- konkrete C-130J-Abwurfzonen
- konkrete TM01- und TM02-Editorobjekte
- verbindliche Template-Namen
- verbindliche Triggerzonen-Namen
