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

Zur Verifikation des Serialisierungsvertrags wurde zunächst die OMW-Basismission

```text
OMW_Template_v8_AirOps_rdy(20260814-070806).miz
SHA-256: da661d02e381d567640b165f1b8645ff1ad65180e71e99d594a6a7251ac2ed32
```

untersucht. Ihre BLUE-Tabelle `mission["coalition"]["blue"]["nav_points"]` war leer. Bereits von DCS erzeugte Navigationspunkte derselben Mission verwendeten folgenden Objektvertrag:

```text
type = "Default"
comment = ""
callsignStr = <sichtbarer Name>
id = <numerische Nav-Point-ID>
properties = { vnav=3, scale=4, vangle=0, angle=0, steer=3 }
x = <DCS local northing>
y = <DCS local easting>
```

Der anschließend tatsächlich durchgeführte Authoring-Versuch verwendete als Quelle:

```text
OMW_Template_v8_AirOps_rdy(20260814-180638).miz
SHA-256: ac94909ffe85b1711aa82f38f7c78bdad491e6d6fc7508727c29567d5adc48af
```

Erzeugtes Ergebnis:

```text
OMW_Template_v8_AirOps_rdy_BLUE_NAVFIX(20260814-180638).miz
SHA-256: 6272b30cdab8c94a823da6bd3f6e23f2cd4c237246b6678ed65a9dd561b7d21d
```

Der Payload-Vergleich zwischen diesen beiden Dateien ergab:

- identische Dateiliste innerhalb der `.miz`;
- ausschließlich die interne Datei `mission` wurde inhaltlich verändert;
- `warehouses`, `options`, `dictionary`, `mapResource`, `Moose.lua`, `TM01M.lua`, alle OMW-Lua-Dateien und die übrigen Payload-Dateien blieben byte-identisch;
- in `mission` existierte genau ein Änderungsbereich: die zuvor leere BLUE-Tabelle `mission["coalition"]["blue"]["nav_points"]` wurde mit 90 Einträgen befüllt;
- vorhandene Missionsobjekte wurden nicht gelöscht oder überschrieben;
- die neu vergebenen NavPoint-IDs reichen von `2248` bis `2337`.

`tools/build-blue-navigation-initial-points.ps1` schreibt die kanonischen Fixes ausschließlich in eine leere BLUE-`nav_points`-Tabelle und verweigert das Überschreiben einer bereits gefüllten Struktur.

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

Der gepinnte MOOSE-Stand stellt Runtime-Navigationsabstraktionen wie `NAVFIX` und WGS84-Koordinatenumrechnung bereit. Sie werden hier nicht eingesetzt, weil die Anforderung ausdrücklich statische DCS Initial Points verlangt, die bereits beim Laden der Mission vorhanden sind. Der Builder erzeugt und benötigt keine Runtime-Lua-Logik.

## Reversibilität und Rollback

Der produktive Repository-Bestand enthält keine `.miz`-Binärdatei. Für ein byte-exaktes Rollback ist deshalb die unveränderte Ausgangsmission `OMW_Template_v8_AirOps_rdy(20260814-180638).miz` mit dem dokumentierten SHA-256 aufzubewahren.

Für den durchgeführten Versuch wurden zusätzlich ein Unified-Diff und ein Reverse-Diff der extrahierten internen Datei `mission` erzeugt. Der Forward-Diff besitzt den SHA-256:

```text
9eed543a5e71a38b342265f7d02df3e9f2445cddde8960cf41ffb74ab7d47e88
```

Ein Reverse-Diff kann die extrahierte `mission` inhaltlich exakt zurücksetzen. Ein anschließend neu gepacktes `.miz` kann wegen ZIP-Metadaten oder Kompressionsdetails trotzdem einen anderen äußeren SHA-256 besitzen. Für ein vollständig byteidentisches Rollback bleibt daher die Original-`.miz` die maßgebliche Sicherung.

## DCS-Prüfstand vom 14.08.2026

Der Projektinhaber öffnete `OMW_Template_v8_AirOps_rdy_BLUE_NAVFIX(20260814-180638).miz` im DCS Mission Editor. Alle 90 Navigationsfixes wurden auf der Afghanistan-Karte sichtbar dargestellt; die großräumige Lage und Verteilung wurde visuell als plausibel bestätigt.

Dieser Nachweis bestätigt damit den Mission-Editor-Teil der vorgesehenen Prüfung, ist aber noch keine vollständige technische Acceptance. Insbesondere fehlen weiterhin:

- dokumentierter Zugriff und Nutzbarkeit der Fixes im A-10C;
- dokumentierter Zugriff und Nutzbarkeit der Fixes im A-10C II;
- dokumentierte DCS-Version für einen vollständigen Acceptance-Nachweis.

Bis diese Punkte vorliegen, bleibt der Stand unterhalb von `ACCEPTED_TECHNICAL_BASELINE` und wird nicht als vollständig `VALIDATED` bezeichnet.

## Statisch prüfbare Eigenschaften

Der Builder prüft unter anderem:

- exakt 90 kanonische Fixes;
- exakte Fünf-Buchstaben-Namen und Eindeutigkeit;
- WGS84-Wertebereiche;
- Afghanistan-Projektions-Selbsttest;
- BLUE-Serialisierung in `mission.coalition.blue.nav_points`;
- einmaliges Auftreten jedes erzeugten Fixnamens;
- Output-SHA-256;
- Abwesenheit von Runtime-Lua für diesen Funktionsumfang.
