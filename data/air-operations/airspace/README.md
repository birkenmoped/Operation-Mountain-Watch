# Afghanistan 2011 – Navigationsfixes

## Zweck

Dieses Verzeichnis enthält das kanonische OMW-Register der Navigationsfixes, aus dem BLUE DCS Initial Points in die Basismission geschrieben werden. Der produktive Datensatz enthält bewusst ausschließlich:

```text
name,lat_dd,lon_dd
```

Die Airway-Zugehörigkeit ist nicht Bestandteil des Initial-Point-Datenmodells. Ein Fix wird genau einmal geführt, auch wenn er auf mehreren ATS-Routen liegt.

## Primärquelle

Das Register ist abgeleitet aus:

- Republic of Afghanistan, Aeronautical Information Publication, Forty Fifth Edition, effective 05 May 2011;
- ENR 3.1 `LOWER ATS ROUTES`;
- ENR 3.2 `UPPER ATS ROUTES`;
- ENR 4.3, wonach die Significant Points des Kabul FIR in den Routentabellen ENR 3.1 und ENR 3.2 aufgeführt sind.

Die Vereinigung der benannten Fixes aus ENR 3.1 und ENR 3.2 wird anhand des exakten Fünf-Buchstaben-Designators dedupliziert und nach WGS84 Decimal Degrees normalisiert.

## Quellenkonflikte und Normalisierung

Wiederholt die AIP denselben Fix mit abweichender Präzision oder widersprüchlichen Koordinaten, wird die Abweichung nicht stillschweigend geglättet, sondern anhand des jeweiligen AIP-Kontexts aufgelöst und hier dokumentiert.

### SERKA

Mehrere Routentabellen runden die Position auf:

```text
N29 51 00 E066 15 00
```

ENR 1.10 und die B466-Angabe in ENR 3.2 führen dagegen:

```text
N29 51 00 E066 15 01.02
```

Da ENR 1.10 `SERKA` ausdrücklich als FIR-Reporting-Point führt und ENR 3.2 dieselbe präzisere Position bestätigt, verwendet OMW:

```text
SERKA,29.85000000,66.25028333
```

### DAVER

Für `DAVER` besteht ein größerer interner Quellenkonflikt innerhalb der 2011er AIP:

```text
ENR 3.1 / M375: N29 34 18 E064 40 36
ENR 1.10:        N29 08 00 E064 25 01.02
```

Die zweite Position wurde in der AIP 2008 an derselben Stelle als Reporting Point `SOKIR` geführt. Zusätzlich liegt `DAVER` auf der 2011er Low-Airways-Darstellung bei der ENR-3.1-Routenposition. OMW verwendet deshalb für den Navigationsfix `DAVER` die konsistente ENR-3.1-Routenkoordinate:

```text
DAVER,29.57166667,64.67666667
```

Das ist eine dokumentierte Quellenreconciliation: Die ENR-1.10-Zeile wird für `DAVER` nicht als maßgebliche Fixkoordinate übernommen, weil sie mit der eigentlichen M375-Routentabelle und der kartografischen Lage kollidiert und die Position historisch `SOKIR` zugeordnet war.

## DCS-Repräsentation

Zur Verifikation des Serialisierungsvertrags wurde die aktuelle OMW-Basismission verwendet:

```text
OMW_Template_v8_AirOps_rdy(20260814-070806).miz
SHA-256: da661d02e381d567640b165f1b8645ff1ad65180e71e99d594a6a7251ac2ed32
```

Ihre BLUE-Tabelle `mission["coalition"]["blue"]["nav_points"]` ist leer. Bereits von DCS erzeugte Navigationspunkte derselben Mission verwenden folgenden Objektvertrag:

```text
type = "Default"
comment = ""
callsignStr = <sichtbarer Name>
id = <numerische Nav-Point-ID>
properties = { vnav=3, scale=4, vangle=0, angle=0, steer=3 }
x = <DCS local northing>
y = <DCS local easting>
```

`tools/build-blue-navigation-initial-points.ps1` schreibt die kanonischen Fixes in diese BLUE-Tabelle und verweigert das Überschreiben einer bereits gefüllten BLUE-`nav_points`-Struktur.

## Afghanistan-Koordinatenprojektion

Der Builder verwendet für das Afghanistan-Terrain folgende Transverse-Mercator-Projektion:

```text
central_meridian = 63
scale_factor = 0.9996
false_easting = -300150.0000226601
false_northing = -3759657.0000381926
datum = WGS84
```

Die Konstanten stammen aus einer veröffentlichten In-Sim-Projektionsermittlung für DCS Afghanistan in:

- `robgrady/DCS-Mission-Starter`, `missiongen/terrains/afghanistan/projection.py`.

Sie wurden zusätzlich statisch gegen die aktuelle OMW-Mission und AIP-Referenzpunkte abgeglichen. Der Jalalabad-AIP-ARP (`N34 24 02 E070 29 50`) projiziert auf ungefähr DCS `x=72497.9463`, `y=389650.1928` und ist damit konsistent mit der aktuellen OMW-Jalalabad-Geometrie.

## MOOSE-First-Abgrenzung

Der gepinnte MOOSE-Stand stellt Runtime-Navigationsabstraktionen wie `NAVFIX` und WGS84-Koordinatenumrechnung bereit. Sie werden hier nicht eingesetzt, weil die Anforderung ausdrücklich DCS Initial Points verlangt, die bereits beim Laden der Mission vorhanden sind. Der Builder erzeugt und benötigt keine Runtime-Lua-Logik.

## Validierungsgrenze

Der Builder kann statisch insbesondere prüfen:

- exakt 90 kanonische Fixes;
- exakte Fünf-Buchstaben-Namen und Eindeutigkeit;
- WGS84-Wertebereiche;
- Afghanistan-Projektions-Selbsttest;
- BLUE-Serialisierung in `mission.coalition.blue.nav_points`;
- einmaliges Auftreten jedes erzeugten Fixnamens;
- Output-SHA-256;
- Abwesenheit von Runtime-Lua für diesen Funktionsumfang.

Erst der dokumentierte DCS-Test darf bestätigen:

- Sichtbarkeit im Mission Editor;
- BLUE-Zuordnung im DCS-Laufzeitstand;
- korrekte Positionen in der DCS-Karte;
- Zugriff aus A-10C und A-10C II wie vorgesehen.

Vor diesem Test bleibt der Stand technisch vorbereitet, aber nicht `VALIDATED`.
