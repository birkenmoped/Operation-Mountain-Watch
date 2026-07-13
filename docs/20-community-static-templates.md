# 20 – Community-Static-Templates und fehlende Stützpunkte

## Ziel

Dieses Dokument erfasst verfügbare Community-Static-Templates für die DCS-Afghanistan-Karte und ordnet sie den für Operation Mountain Watch geplanten Standorten zu.

Community-Templates sind Entwicklungsgrundlagen. Sie werden nicht ungeprüft in die Produktionsmission übernommen.

## Grundsatz

Ein Stützpunkt benötigt kein zusätzliches Static-Template, wenn die DCS-Karte den relevanten Standort bereits als ausreichend nutzbaren Flugplatz- oder Basenkomplex darstellt.

Static-Templates werden nur verwendet, wenn:

- der Standort in der DCS-3D-Welt fehlt oder unzureichend dargestellt ist;
- die Vorlage keine unzulässigen Pflicht-Mods einführt;
- Objektzahl und Multiplayer-Performance vertretbar sind;
- Position und Ausbauzustand zum Kampagnenzeitraum passen;
- vorhandene Kartengebäude keine kritischen Überschneidungen verursachen;
- die Nutzung und gegebenenfalls Weitergabe lizenzrechtlich geklärt ist.

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

FOB Connolly ist damit grundsätzlich durch ein Community-Template abgedeckt.

Die Vorlage stellt ungefähr den Ausbauzustand um 2012 dar. Vor einer Nutzung in der Kampagne 2010 bis Frühjahr 2011 müssen daher Gebäude, Mauern, Helipads, Objektzahl und Ausbauzustand geprüft werden.

Die Vorlage enthält keine automatisch passende Garnison oder Kampagnenlogik. Verteidigung, Warehouse-Knoten, Zonen und dynamische Einheiten werden durch Operation Mountain Watch ergänzt.

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
| FOB Connolly | Community-Template verfügbar | vorhandenes Template prüfen und anpassen |
| FOB Mehtar Lam | keine bestätigte Vorlage in den erfassten Paketen | eigenes Template voraussichtlich erforderlich |
| FOB Blessing | nicht in der veröffentlichten Kunar-/Nuristan-Liste bestätigt | eigenes oder später veröffentlichtes Template erforderlich |
| FOB Bostick | nur benachbarte OPs im Paket erwähnt | optionales eigenes Template bei Aufnahme in den Kampagnenumfang |

## Priorität

### Erster Prototyp

- Jalalabad/Fenty: native Airbase verwenden; kein eigenes vollständiges Template.
- FOB Connolly: Community-Template importieren, prüfen und projektspezifisch ergänzen.

Damit fehlt für den ersten Prototyp kein zusätzliches vollständiges Fenty-Template.

### Spätere Erweiterung

- FOB Mehtar Lam: eigenes Template oder geeignete Community-Vorlage suchen.
- FOB Blessing: veröffentlichten Stand erneut prüfen; andernfalls eigenes Template erstellen.
- FOB Bostick: nur bei tatsächlicher Aufnahme in den Operationsraum erstellen.

## Import- und Prüfprozess

Vor der Übernahme eines Community-Templates:

1. Quelldatei und Forumsbeitrag dokumentieren.
2. Ersteller und Version erfassen.
3. Abhängigkeiten und Mods prüfen.
4. Vorlage in einer isolierten Testmission laden.
5. Konflikte mit nativen Kartengebäuden prüfen.
6. Objektzahl und Serverleistung messen.
7. Ausbauzustand gegen den Kampagnenzeitraum prüfen.
8. nicht benötigte Objekte entfernen.
9. Warehouse-, Logistik-, LZ- und Verteidigungszonen projektspezifisch ergänzen.
10. keine statischen Verteidiger als Ersatz für dynamische CampaignState-Entitäten übernehmen.

## Repository-Regel

Eine fremde `.stm`-Datei wird erst in das Repository aufgenommen, wenn ihre Weitergabe und Lizenzierung ausreichend geklärt ist.

Bis dahin werden nur folgende Informationen versioniert:

- Quellverweis;
- Ersteller;
- Paket- und Versionsname;
- abgedeckte Standorte;
- Prüfergebnis;
- lokaler Importstatus;
- erforderliche Anpassungen;
- optionaler Hash der lokal geprüften Datei.
