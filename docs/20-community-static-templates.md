# 20 – Community-Static-Templates und fehlende Stützpunkte

## Ziel

Dieses Dokument erfasst verfügbare Community-Static-Templates für die DCS-Afghanistan-Karte und ordnet sie den für Operation Mountain Watch geplanten Standorten zu.

Community-Templates sind Entwicklungsgrundlagen. Sie werden nicht ungeprüft in die Produktionsmission übernommen.

Verbindliche Architekturentscheidung:

- `docs/adr/0007-keep-community-templates-at-historical-sites.md`

Die Basenterminologie und funktionale Klassifikation ist beschrieben in:

- `docs/21-allied-base-classification.md`

## Grundsatz

Ein Stützpunkt benötigt kein zusätzliches Static-Template, wenn die DCS-Karte den relevanten Standort bereits als ausreichend nutzbaren Flugplatz- oder Basenkomplex darstellt.

Static-Templates werden nur verwendet, wenn:

- der Standort in der DCS-3D-Welt fehlt oder unzureichend dargestellt ist;
- die Vorlage keine unzulässigen Pflicht-Mods einführt;
- Objektzahl und Multiplayer-Performance vertretbar sind;
- Position und Ausbauzustand zum Kampagnenzeitraum passen;
- vorhandene Kartengebäude keine kritischen Überschneidungen verursachen;
- die Nutzung und gegebenenfalls Weitergabe lizenzrechtlich geklärt ist.

## Standorttreue

Ein Community-Static-Template gehört zu genau dem historischen Standort, für den es erstellt wurde.

Verbindliche Regeln:

- Das Template bleibt an seinem realen Kartenstandort.
- Es wird nicht an einen anderen Stützpunkt verschoben.
- Es wird nicht unter dem Namen eines anderen realen FOBs, COPs, PBs oder OPs verwendet.
- Ein Template für FOB Joyce bleibt FOB Joyce.
- Ein Template für COP Michigan bleibt COP Michigan.
- Ein Template für OP Restrepo bleibt OP Restrepo.
- Eine technische Positionskorrektur innerhalb des tatsächlichen Standortareals ist nur zur Anpassung an Terrain, Kartenupdates oder Objektkollisionen zulässig.

Die sichtbaren Objekte eines Templates sind kein generischer Bausatz zur Darstellung eines anderen historischen Stützpunkts.

## Kein Template-Ersatz ohne Kampagnenumplanung

Ein anderer realer Stützpunkt kann einen bisher geplanten Standort nur auf Ebene des Campaign Designs ersetzen.

Das bedeutet:

```text
Nicht zulässig:
FOB-Joyce-Template am Standort FOB Blessing platzieren
und als FOB Blessing bezeichnen.

Zulässig:
FOB Blessing aus einer Kampagnenphase entfernen
und eine neue reale Operationsachse um FOB Joyce an dessen
historischem Standort planen.
```

Eine solche Umplanung ist nur zulässig, wenn mindestens geprüft werden:

- tatsächliche Kartenposition;
- Provinz, Tal und Operationsraum;
- Kampagnenzeitraum;
- historische und organisatorische Einordnung;
- operative Funktion;
- übergeordneter Unterstützungs- und Logistikknoten;
- Straßen-, Luft- und Talverbindungen;
- unterstützte COPs, PBs, OPs und Checkpoints;
- Auswirkungen auf Missionstypen, Red Director und Routenmodell.

Ein vorhandenes Template erzeugt damit einen möglichen neuen Kampagnenknoten. Es ist kein austauschbares Ersatzobjekt.

## Vorgehen bei fehlender Vorlage

Fehlt für einen verbindlich geplanten Standort eine passende Vorlage, gilt folgende Reihenfolge:

1. prüfen, ob der native DCS-Standort bereits ausreicht;
2. nach einer standortgetreuen Community-Vorlage suchen;
3. den Ersteller oder andere Community-Autoren nach einer Ergänzung fragen;
4. den Standort selbst im Mission Editor aufbauen;
5. einen vereinfachten, aber standortgetreuen Aufbau erstellen;
6. den Standort bewusst aus dem aktuellen Kampagnenumfang entfernen;
7. den Operationsraum ausdrücklich auf einen anderen realen Standort umplanen.

Die Schritte 6 und 7 sind Campaign-Design-Entscheidungen und keine technischen Template-Entscheidungen.

## Native strategische Standorte

### Bagram Airfield

Bagram ist als großer Flugplatz auf der DCS-Karte vorhanden. Für die Kampagne wird kein vollständiges zusätzliches FOB- oder Airfield-Template benötigt.

Optionale missionsspezifische Static Objects dürfen funktionale Bereiche ergänzen, beispielsweise:

- Lager- oder Entladebereiche;
- Spieler- und AI-Bereitstellungsflächen;
- Wartungs- und Logistikmarker;
- missionsrelevante Schutzstellungen.

Diese Ergänzungen bilden kein eigenständiges Bagram-Gesamttemplate.

### Kabul

Kabul ist als strategischer Flugplatz- und Rückraumknoten vorhanden. Für den geplanten Kampagnenumfang wird kein vollständiges zusätzliches Basentemplate benötigt.

### Jalalabad Airfield und FOB Fenty

Jalalabad Airfield ist als native DCS-Airbase vorhanden.

FOB Fenty wird in Operation Mountain Watch nicht als eigener, neben Jalalabad neu zu errichtender FOB behandelt. Die Bezeichnung beschreibt den militärisch-operativen Bereich des vorhandenen Flugplatzkomplexes.

Daraus folgt:

- der native Jalalabad-Kartenpunkt wird verwendet;
- das native Jalalabad-Warehouse ist die physische Warehouse-Grundlage;
- `WH_BLUE_JALALABAD_FENTY` bleibt die gemeinsame logische CampaignState-ID;
- Fenty-spezifische Zonen und Marker dürfen für Konvois, QRF, Hubschrauberlogistik und C-130J-Entladung angelegt werden;
- optionale Static Objects dürfen einzelne Funktionen oder sichtbare Arbeitsbereiche ergänzen;
- ein separates vollständiges `FOB Fenty`-Static-Template ist nicht erforderlich.

## Community-Pakete

### Kunar und Nuristan

Quelle:

https://forum.dcs.world/topic/369614-static-template-for-kunar-and-nuristan-fobs/

Die veröffentlichte Paketbeschreibung nennt unter anderem:

- FOB Joyce
- FOB Falcon
- COP Fortress
- COP Keating
- COP Korengal
- COP Michigan
- COP Honaker-Miracle
- OP Restrepo
- OP Stallion
- OP Clydesdale
- OP Mace

Das Paket ist für spätere Kunar-, Pech- und Nuristan-Phasen relevant.

Jeder enthaltene Standort bleibt an seiner vom Template vorgesehenen realen Kartenposition. Eine mögliche Aufnahme von Joyce, Michigan, Honaker-Miracle, Korengal oder Restrepo erfordert eine reale Kampagnenplanung um diese Standorte; keiner von ihnen wird als verschobene Darstellung von FOB Blessing verwendet.

FOB Blessing steht nicht in der veröffentlichten Inhaltsliste. Im Forum wurde eine mögliche spätere Ergänzung diskutiert, aber für die Projektplanung gilt Blessing bis zur Prüfung einer tatsächlich veröffentlichten Datei als nicht abgedeckt.

FOB Bostick steht ebenfalls nicht als eigener Standort in der veröffentlichten Liste, obwohl OP Stallion und OP Clydesdale in seiner Nähe enthalten sind.

### Ghazni, Logar und Nangarhar

Quelle:

https://forum.dcs.world/topic/369464-static-template-for-ghazni-logar-and-nangarhar-fobs/

Die veröffentlichte Paketbeschreibung nennt:

- FOB Lane
- FOB Andor
- FOB Miri
- FOP Baraki Barak
- FOB Connolly
- FOB Torkham Gate
- MSS Mad Dog
- MSS Butler
- OP Spur

FOB Connolly ist damit grundsätzlich durch ein standortgetreues Community-Template abgedeckt.

Die Vorlage stellt ungefähr den Ausbauzustand um 2012 dar. Vor einer Nutzung in der Kampagne 2010 bis Frühjahr 2011 müssen daher Gebäude, Mauern, Helipads, Objektzahl und Ausbauzustand geprüft werden.

Die Vorlage enthält keine automatisch passende Garnison oder Kampagnenlogik. Verteidigung, Warehouse-Knoten, Zonen und dynamische Einheiten werden durch Operation Mountain Watch ergänzt.

FOB Torkham Gate und die übrigen Standorte werden nur dann aufgenommen, wenn ihre tatsächlichen Regionen und Funktionen Bestandteil einer geplanten Kampagnenphase werden. Sie ersetzen keine anderen geplanten Standorte durch Umbenennung oder Verschiebung.

### Herat und Farah

Quelle:

https://forum.dcs.world/topic/367394-static-template-for-herat-and-farah-fobs/

Dieses Paket betrifft den aktuellen RC-East-Kernraum nicht. Es wird nur als mögliche Referenz für spätere, räumlich getrennte Kampagnen geführt.

### Helmand und Uruzgan

Quelle:

https://forum.dcs.world/topic/364780-static-template-for-helmand-and-uruzgan-fobs/

Dieses Paket betrifft den aktuellen RC-East-Kernraum nicht. Es wird nicht in den ersten Kampagnenphasen benötigt.

## Abdeckung unserer geplanten Standorte

| Standort | Darstellung | Zusätzliches Static-Template |
|---|---|---|
| Bagram Airfield | native DCS-Airbase | nein; nur optionale Funktionsobjekte |
| Kabul | nativer strategischer Flugplatzknoten | nein; nur optionale Funktionsobjekte |
| Jalalabad Airfield / FOB Fenty | native DCS-Airbase und gemeinsamer logischer Knoten | nein |
| FOB Connolly | Community-Template am realen Connolly-Standort verfügbar | vorhandenes Template prüfen und anpassen |
| FOB Mehtar Lam | keine bestätigte Vorlage in den erfassten Paketen | eigenes Template voraussichtlich erforderlich |
| FOB Blessing | nicht in der veröffentlichten Kunar-/Nuristan-Liste bestätigt | eigenes oder später veröffentlichtes Template erforderlich |
| FOB Bostick | nur benachbarte OPs im Paket erwähnt | optionales eigenes Template bei Aufnahme in den Kampagnenumfang |

## Priorität

### Erster Prototyp

- Jalalabad/Fenty: native Airbase verwenden; kein eigenes vollständiges Template.
- FOB Connolly: Community-Template an der realen Connolly-Position importieren, prüfen und projektspezifisch ergänzen.

Damit fehlt für den ersten Prototyp kein zusätzliches vollständiges Fenty-Template.

### Spätere Erweiterung

- FOB Mehtar Lam: eigenes standortgetreues Template oder geeignete Community-Vorlage suchen.
- FOB Blessing: veröffentlichten Stand erneut prüfen; andernfalls eigenes standortgetreues Template erstellen.
- FOB Bostick: nur bei tatsächlicher Aufnahme in den Operationsraum erstellen.
- vorhandene Kunar-/Nuristan-Templates nur durch reale Erweiterung auf deren tatsächliche Operationsachsen aufnehmen.

## Import- und Prüfprozess

Vor der Übernahme eines Community-Templates:

1. Quelldatei und Forumsbeitrag dokumentieren.
2. Ersteller und Version erfassen.
3. vorgesehenen historischen Standort und Kartenkoordinate bestätigen.
4. prüfen, dass das Template nicht für einen anderen Standort umgedeutet wird.
5. Abhängigkeiten und Mods prüfen.
6. Vorlage in einer isolierten Testmission laden.
7. Konflikte mit nativen Kartengebäuden prüfen.
8. Objektzahl und Serverleistung messen.
9. Ausbauzustand gegen den Kampagnenzeitraum prüfen.
10. nicht benötigte Objekte entfernen.
11. Warehouse-, Logistik-, LZ- und Verteidigungszonen projektspezifisch ergänzen.
12. keine statischen Verteidiger als Ersatz für dynamische CampaignState-Entitäten übernehmen.
13. Auswirkungen auf Routen, Sektoren und Missionsarten dokumentieren.

## Zulässige Anpassungen

Innerhalb des realen Standortareals dürfen vorgenommen werden:

- kleine Höhen- und Positionskorrekturen wegen Terrain-Clipping;
- Entfernung kollidierender oder für den Zeitraum unpassender Objekte;
- Reduktion der Objektzahl für Multiplayer-Performance;
- Ergänzung projektspezifischer Funktionsobjekte;
- Ergänzung von Warehouse-, Logistik-, LZ-, Spawn- und Triggerzonen;
- Anpassung statischer Beleuchtung und nicht kämpfender Dekoration.

Nicht zulässig sind:

- Verlegung zu einem anderen historischen Standort;
- Umbenennung in einen anderen realen Stützpunkt;
- Nutzung als sichtbarer Ersatz für einen fehlenden anderen FOB;
- Beibehaltung einer fremden Standortidentität bei veränderter geografischer Kampagnenrolle.

## Repository-Regel

Eine fremde `.stm`-Datei wird erst in das Repository aufgenommen, wenn ihre Weitergabe und Lizenzierung ausreichend geklärt ist.

Bis dahin werden nur folgende Informationen versioniert:

- Quellverweis;
- Ersteller;
- Paket- und Versionsname;
- historischer Zielstandort;
- abgedeckte Standorte;
- Prüfergebnis;
- lokaler Importstatus;
- erforderliche Anpassungen;
- optionaler Hash der lokal geprüften Datei.
