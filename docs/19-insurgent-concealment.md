# 19 – Verdeckte rote Kräfte, Hide Sites und Strongpoints

## Ziel

Rote Zellen sollen sich glaubwürdig in Dörfern, Compounds, Wadis, Baumreihen und Gebirgsräumen verbergen können, ohne dauerhaft sichtbar auf offenem Gelände zu stehen. DCS wird dabei nur für die physische Kampf- und Bewegungsebene verwendet. Aufenthalt, Tarnung, Durchsuchung und Aufdeckung werden durch den `CampaignState`, den `RedDirector` und einen eigenen `ConcealmentManager` modelliert.

## Technische Ausgangslage

Für beliebige Terraingebäude wird keine allgemeine DCS-Funktion vorausgesetzt, mit der Infanterie automatisch ein Gebäude betritt, Räume besetzt oder aus Fenstern kämpft.

Reguläre DCS-Bodenaufgaben unterstützen unter anderem:

- Bewegung zu Punkten, Zonen oder entlang einer Route;
- Halten;
- Ein- und Aussteigen in Transportmittel;
- Feueraufträge;
- Rules of Engagement;
- Alarmzustände.

Eine generische, für beliebige Scenery-Häuser belastbare Gebäudeinnenraum-Navigation ist nicht Teil der Projektannahmen. Einzelne Einheiten dürfen optisch in geeigneten Compounds oder nahe Gebäuden platziert werden, dies gilt aber nur nach praktischer Validierung der konkreten Position.

## Verbindlicher Grundsatz

Ruhende, nicht beobachtete rote Kräfte werden überwiegend virtualisiert. Ein Dorf oder eine Stadt enthält daher nicht dauerhaft sichtbare Infanteriegruppen, sondern:

- eine oder mehrere virtuelle rote Zellen;
- vorbereitete Hide Sites;
- mögliche Materialisierungspositionen;
- vorbereitete Fluchtwege;
- optionale Strongpoints;
- Intelligence- und Durchsuchungszustände.

Bei relevanter Spielerannäherung, Aufklärung, Kontaktwahrscheinlichkeit oder Missionsaktivierung wird eine passende physische Repräsentation an einer geprüften Position erzeugt.

## Zwei getrennte Zustandsmodelle

### Operativer Zellzustand

Der bestehende operative Lebenszyklus bleibt erhalten:

```text
DORMANT
→ SELECT_TARGET
→ PREPARE
→ ASSEMBLE
→ MOVE
→ ATTACK
→ WITHDRAW
→ DISPERSED
→ REBUILDING
```

### Concealment-Zustand

Zusätzlich besitzt jede betroffene Entität einen Verbergungszustand:

- `VIRTUAL_HIDDEN`
- `VIRTUAL_ALERTED`
- `MATERIALIZING`
- `PHYSICAL_CONCEALED`
- `PHYSICAL_OBSERVING`
- `PHYSICAL_ENGAGED`
- `PHYSICAL_DISPLACING`
- `VIRTUAL_DISPERSED`
- `CAPTURED`
- `DESTROYED`

Beide Zustandsmodelle werden getrennt gespeichert. Eine Zelle kann beispielsweise operativ `PREPARE` und gleichzeitig `VIRTUAL_HIDDEN` sein.

## Hide Sites

Eine Hide Site ist eine geprüfte taktische Position, an der eine kleine Gruppe plausibel verborgen oder gedeckt materialisiert werden kann.

Geeignete Kategorien:

- `COMPOUND`
- `COURTYARD`
- `WALL`
- `BUILDING_REAR`
- `TREELINE`
- `ORCHARD`
- `WADI`
- `DITCH`
- `ROCKS`
- `RIDGELINE_REVERSE_SLOPE`
- `CAVE_APPROACH`
- `URBAN_ALLEY`
- `ROOFTOP_PROXY`, nur bei konkret getesteter Platzierung

Nicht geeignete Positionen:

- Straßenmitte;
- offene Dorfplätze;
- ungeschützte Felder;
- unmittelbar sichtbare Kartenränder oder Spawnflächen;
- Positionen innerhalb nicht begehbarer Geometrie;
- Punkte ohne getesteten Ausweg;
- Positionen, an denen AI-Einheiten dauerhaft feststecken.

## Hide-Site-Datensatz

```yaml
id: HIDE_DARUNTA_COMPOUND_03
location_id: LOC_DARUNTA
sector_id: SECTOR_NANGARHAR_EAST
cover_type: COMPOUND
zone_name: ZONE_HIDE_DARUNTA_COMPOUND_03
capacity: 8
allowed_roles:
  - INFANTRY_CELL
  - RPG_TEAM
  - COURIER
supports_ambush: true
supports_mortar: false
supports_strongpoint: false
egress_routes:
  - ROUTE_HIDE_DARUNTA_03_EGRESS_A
  - ROUTE_HIDE_DARUNTA_03_EGRESS_B
visibility:
  ground: LOW
  air: LOW
validated: false
```

Jede produktive Hide Site wird im Mission Editor und in einer Testmission geprüft.

## Auswahl einer Hide Site

Der `ConcealmentManager` bewertet mindestens:

- Kapazität und erlaubte Rollen;
- Entfernung zur aktuellen virtuellen Position;
- Entfernung und Sichtlinie zu Spielern;
- bekannte Aufklärung;
- Tageszeit;
- Gelände- und Deckungstyp;
- verfügbare Fluchtwege;
- aktuelle Belegung;
- Nähe zu Zivil- oder Missionszielen;
- Eignung für den geplanten Auftrag;
- Risiko sichtbaren Pop-ins;
- Serverlast und Anzahl bereits materialisierter Gruppen.

Eine Hide Site kann reserviert werden, damit nicht mehrere Zellen dieselbe Position gleichzeitig verwenden.

## Materialisierung

Eine Gruppe wird nicht erst unmittelbar vor dem Spieler erzeugt. Die Materialisierung erfolgt gestuft.

Beispielhafte Logik:

```text
Spieler oder Aufklärung innerhalb Vorbereitungsradius
→ Kandidaten und Sichtlinien prüfen

geeignete verdeckte Position verfügbar
→ Gruppe materialisieren
→ Alarmzustand Green
→ ROE Return Fire oder Hold Fire
→ Gruppe halten

Kontakt- oder Missionsbedingung erfüllt
→ Alarmzustand Red
→ ROE Open Fire
→ Angriff, Beobachtung oder Flucht auslösen
```

Die tatsächlichen Radien werden nach Sensortyp, Gelände, Tageszeit und Performance festgelegt. Ein Starrwert für alle Einheiten ist nicht zulässig.

## Vermeidung von Pop-in

Vor einer Materialisierung werden mindestens geprüft:

- keine direkte Sichtlinie eines nahen Spielers auf den Spawnpunkt;
- keine unmittelbare Nähe zu einer blauen Einheit;
- keine aktive Waffe oder Sensoransicht, die den Punkt eindeutig beobachtet;
- ausreichende Deckung oder Geländemaskierung;
- plausible Verbindung zur vorherigen virtuellen Position;
- freier Platz für alle Units des Templates;
- erreichbarer Rückzugs- oder Angriffsweg.

Kann keine sichere Position gefunden werden, bleibt die Einheit virtuell oder wird weiter entfernt materialisiert. Sichtbares Erscheinen in offenem Gelände wird nicht als normaler Fallback verwendet.

## Physisches Verhalten

Nach der Materialisierung kann eine verdeckte Gruppe zunächst:

- halten;
- Alarmzustand Green verwenden;
- ROE Return Fire oder Hold Fire verwenden;
- einen Beobachter oder Spotter absetzen;
- eine kurze vorbereitete Route zu einer Feuerstellung erhalten;
- bei Aufdeckung fliehen;
- sich aufteilen, sofern dafür getestete Templates existieren.

Bei Angriffsbeginn:

- Alarmzustand auf Red;
- passende ROE setzen;
- vorbereiteten Auftrag aktivieren;
- Rückzugsschwelle überwachen;
- Überlebende nach erfolgreichem Absetzen wieder virtualisieren.

## Dörfer und Städte

Eine Siedlung ist kein einzelner Spawnpunkt. Für spielrelevante Siedlungen werden mehrere Funktionsbereiche definiert:

```text
LOCATION_ZONE
HIDE_SITE_ZONES
SEARCH_SECTORS
EGRESS_ROUTES
ASSEMBLY_AREA
OPTIONAL_STRONGPOINT
OPTIONAL_CACHE_SITES
```

Eine rote Zelle kann einer Siedlung zugeordnet sein, ohne an einem exakten Haus sichtbar zu existieren. Der CampaignState speichert Aufenthaltsort, Hide-Site-Reservierung, Alarmzustand und Aufklärungsgrad.

## Strongpoints und bewaffnete Häuser

Bewaffnete Häuser oder vergleichbare Assets werden nur für vorbereitete, dauerhaft verteidigte Stellungen eingesetzt.

Geeignete Rollen:

- befestigter Kommandoposten;
- Waffenlager;
- HVT-Versteck;
- vorbereitete Hinterhalt-Hauptstellung;
- verteidigter Compound;
- dauerhafte Mörser- oder Beobachtungsstellung.

Nicht zulässig:

- jedes Dorf standardmäßig mit bewaffneten Häusern zu versehen;
- jede ruhende rote Zelle durch ein bewaffnetes Gebäude zu repräsentieren;
- das besondere Asset automatisch als sichtbaren Hinweis auf einen Gegner zu verwenden;
- einen Strongpoint ohne CampaignState-Verknüpfung als unabhängige Ressource zu behandeln.

Datensatz:

```yaml
id: STRONGPOINT_DARUNTA_01
location_id: LOC_DARUNTA
representation: ARMED_HOUSE
zone_name: ZONE_STRONGPOINT_DARUNTA_01
prepared_defense: true
personnel_capacity: 12
ammo_capacity: 20
linked_cell_id: RED_CELL_NANGARHAR_004
destroyed_effects:
  personnel_loss: 4
  ammunition_loss: 20
  influence_delta: -0.15
validated: false
```

Der physische Strongpoint ist eine Repräsentation. Personal, Munition und strategische Wirkung bleiben im CampaignState.

## Durchsuchung und Aufklärung

Da beliebige Häuser nicht zuverlässig begehbar sind, wird eine Durchsuchung als kontrollierter Kampagnenprozess modelliert.

Mögliche Ergebnisse:

- keine relevante Aktivität;
- rote Zelle bleibt unentdeckt;
- verdächtige Hinweise werden gefunden;
- Waffenlager wird entdeckt;
- Kurier oder Unterstützer wird festgenommen;
- Zelle beginnt verdeckte Flucht;
- Zelle eröffnet das Feuer;
- vorbereiteter Hinterhalt wird ausgelöst;
- Fehlinformation oder leeres Ziel;
- Strongpoint wird identifiziert.

Einflussfaktoren:

- aktuelle Intelligence;
- Suchintensität;
- Beteiligung von ANA, ANP oder Spezialkräften;
- lokale Unterstützung;
- Tageszeit;
- Alarmzustand der Zelle;
- Qualität der Hide Site;
- verfügbare Fluchtwege;
- Dauer der Durchsuchung;
- vorherige Aufklärung und Überwachung.

## Suchsektoren

Eine größere Siedlung wird in Suchsektoren zerlegt. Ein Suchauftrag bezieht sich nicht auf jedes einzelne Gebäude, sondern auf einen oder mehrere Sektoren.

```yaml
id: SEARCH_DARUNTA_SECTOR_B
location_id: LOC_DARUNTA
zone_name: ZONE_SEARCH_DARUNTA_B
search_difficulty: 0.65
hide_sites:
  - HIDE_DARUNTA_COMPOUND_03
  - HIDE_DARUNTA_WADI_01
cache_sites:
  - CACHE_DARUNTA_02
```

Die Kampagnenlogik berechnet das Ergebnis. Physische Gegner werden nur erzeugt, wenn daraus eine beobachtbare Interaktion entsteht.

## Intelligence und Aufdeckungsgrad

Mögliche Stufen:

- `UNKNOWN`
- `POSSIBLE_ACTIVITY`
- `LIKELY_PRESENCE`
- `HIDE_SITE_NARROWED`
- `CONFIRMED_POSITION`
- `CONTACT`

Eine hohe Intelligence-Stufe kann:

- den Materialisierungsbereich verkleinern;
- Hide Sites ausschließen;
- Suchdauer reduzieren;
- Fluchtwahrscheinlichkeit senken;
- einen Strongpoint oder Cache als Ziel freigeben.

## Persistenz

Gespeichert werden:

- Zell-ID und operativer Zustand;
- Concealment-Zustand;
- aktueller logischer Ort;
- reservierte Hide Site;
- bekannte und ausgeschlossene Hide Sites;
- Aufklärungsgrad je Koalition;
- Alarmzustand;
- vorbereitete Fluchtwege;
- Verlust- und Munitionsstand;
- Strongpoint- und Cache-Zustände;
- letzter physischer Kontakt.

Flüchtige DCS-Gruppennamen und Controllerzustände werden nicht persistiert.

## Performance

- keine dauerhaft aktive Infanterie in jedem Dorf;
- keine flächendeckende Materialisierung aller möglichen Hide Sites;
- physische Gruppen nur bei relevanter Beobachtung, Mission oder Kontaktwahrscheinlichkeit;
- Scenery- und Sichtlinienprüfungen räumlich und zeitlich begrenzen;
- vorberechnete Hide Sites statt zufälliger Vollkartensuche;
- Dematerialisierung erst nach Kontaktende, ausreichender Entfernung und fehlender Beobachtung.

## Prototypumfang

Der erste Prototyp benötigt:

- mindestens eine spielrelevante Siedlung oder Compound-Zone;
- drei bis fünf geprüfte Hide Sites;
- zwei vorbereitete Fluchtwege;
- eine virtuelle rote Zelle mit Concealment-Zustand;
- Materialisierung ohne sichtbares Pop-in;
- mindestens einen Such- oder Aufklärungsauftrag;
- mindestens ein Ergebnis mit Flucht oder Kampf;
- einen vorbereiteten Strongpoint-Slot;
- ein bewaffnetes Haus nur dann, wenn ein geeignetes Core-Asset und stabiles Verhalten bestätigt wurden.

## Abnahmekriterien

- eine virtuelle Zelle kann einer Siedlung und Hide Site zugeordnet werden;
- eine nicht beobachtete Gruppe wird an einer geprüften Deckungsposition materialisiert;
- direkt beobachtete Spawnpunkte werden verworfen;
- die Gruppe beginnt nicht automatisch mit offenem Feuer;
- Aufdeckung kann Kampf, Flucht oder unentdecktes Verbleiben auslösen;
- Überlebende können sich absetzen und wieder virtualisiert werden;
- Suchaufträge funktionieren ohne begehbare Gebäude;
- Strongpoint und Mannschaft bleiben strategisch verknüpft;
- Persistenz stellt Ort, Aufklärungsgrad und Zustand reproduzierbar wieder her;
- die Serverleistung bleibt bei mehreren virtuellen Siedlungszellen stabil.

## Nicht Bestandteil des ersten Prototyps

- echte Innenraumnavigation;
- Raum-für-Raum-Kampf;
- vollständige zivile Bevölkerungssimulation;
- jedes Gebäude als individuelles Suchziel;
- dynamische Gebäudebesetzung beliebiger Scenery-Objekte;
- bewaffnete Häuser als Standardersatz für Infanterie;
- vollständig autonome urbane AI ohne vorbereitete Slots und Routen.
