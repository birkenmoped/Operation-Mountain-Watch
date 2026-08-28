# ISAF 2009–2013 – ACO Building – Bullseye List (9/x) – Quellenakte

## 1. Zweck und Einordnung

Diese Quellenakte dokumentiert den vom Projektinhaber bereitgestellten Beitrag **„ISAF 2009-2013 - ACO Building - Bullseye List (9/x)”** von **Graveyard of Empires** einschließlich des bereitgestellten Kneeboard-PDF/PNG und der CombatFlite-Datei.

Die Aufnahme folgt `OMW-GOV-SOURCE-USE`. Sämtliche Credits für Recherche, Zusammenstellung und ursprüngliche DCS-Aufbereitung gehen an **Graveyard of Empires**.

Quelle:

- Graveyard of Empires, Patreon: `https://www.patreon.com/graveyard4DCS/posts/isaf-2009-2013-9-151781031?collection=833534`

Bereitgestellte Dateien:

- `Bullseye List - Afghanistan.pdf`
- `Bullseye List - Afghanistan.png`
- `Bullseye List - Afghanistan.cf`
- `ACO-Bullseye.pdf` – bereitgestellter Ausdruck/Screenshot des Patreon-Beitrags

Quellenstatus:

```yaml
source_creator: Graveyard of Empires
source_type: SECONDARY_DCS_INTERPRETATION_AND_DESIGN_PROPOSAL
series: ISAF 2009-2013 - ACO Building
series_part: 9/x
patreon_date_display: 1 March
patreon_year_visible_in_capture: false
attachment_version: v1.0
attachment_version_date: 2026-02-13
access_status: PROVIDED_LAWFULLY
source_capture_status: COMPLETE_FOR_PROVIDED_MATERIAL
historical_status: NOT_A_HISTORICAL_ACO_OR_SPINS_RECORD
omw_status: SOURCE_EVIDENCE_ONLY
validated_in_dcs: false
```

Die Quelle beschreibt eine **für DCS entworfene Bullseye-Struktur** für das Afghanistan-Theater. Sie belegt nicht, dass die fünf Namen oder Koordinaten im realen ISAF-/OEF-Betrieb 2010/2011 als operative Bullseyes verwendet wurden.

## 2. Kernaussage der Quelle

Der Beitrag begründet mehrere Bullseyes mit dem Fehlerwachstum polarer Positionsangaben bei zunehmender Entfernung vom Bezugspunkt.

Die dargestellte Beziehung lautet sinngemäß:

```text
position error = sqrt(radial_error^2 + angular_error^2 * range^2)
```

Die praktische Aussage der Quelle ist entscheidend: Ein identischer Winkelfehler erzeugt mit wachsender Entfernung vom Bullseye einen zunehmend größeren Ortsfehler. Als Beispiel nennt der Beitrag ungefähr:

```text
1 degree angular error at 100 NM -> about 2 NM position error
5 degree angular precision at 100 NM -> about 9 NM position error
```

Daraus leitet Graveyard of Empires für ein großes Theater wie Afghanistan die Verwendung mehrerer Bullseyes ab.

## 3. Vorgeschlagene Afghanistan-Bullseyes

Der bereitgestellte Kneeboard-Datensatz definiert fünf Bullseyes:

| Geografische Zuordnung | Bullseye | WGS84-Koordinate | Dezimalgrad |
|---|---|---|---|
| Capital | `CREE` | N35°17.00' E070°16.00' | 35.2833333333, 70.2666666667 |
| North | `NAVAJO` | N35°48.00' E066°27.00' | 35.8000000000, 66.4500000000 |
| East | `ESKIMO` | N32°39.00' E067°38.00' | 32.6500000000, 67.6333333333 |
| South | `SEMINOLE` | N30°51.00' E064°24.00' | 30.8500000000, 64.4000000000 |
| West | `WARRIOR` | N33°46.00' E062°50.00' | 33.7666666667, 62.8333333333 |

Die Namenswahl ist laut Beitrag bewusst geografisch leicht merkbar:

```text
North   -> NAVAJO
South   -> SEMINOLE
East    -> ESKIMO
West    -> WARRIOR
Capital -> CREE
```

## 4. Abdeckung und Spider Charts

Der Beitrag beschreibt das Fünfer-Setup als Entwurf, bei dem die meisten Punkte des Theaters innerhalb von ungefähr **150 NM** eines Bullseyes liegen sollen. Für Zentralafghanistan wird bewusst eine geringere Abdeckung akzeptiert, da dort laut Quelle weniger Kampfoperationen stattfanden.

Das Kneeboard verwendet für die dargestellten Spider Charts:

```text
spoke interval: 30 degrees
ring interval: 20 NM
shown maximum range: 100 NM
```

Die CombatFlite-Datei bestätigt technisch für das konfigurierte Bullseye-Symbol:

```text
OuterRing = 100
Rings = 5
Spokes = 12
```

Das entspricht fünf 20-NM-Ringen und zwölf 30-Grad-Sektoren.

## 5. Beziehung zu BMA – nicht zu RC gleichsetzen

Wichtig für OMW: Der Beitrag formuliert die Zuordnung ausdrücklich in Bezug auf **Battle Management Areas (BMA)**, nicht auf die ISAF-Regional-Command-Struktur.

Die Quelle sagt, dass in dieser Konfiguration jede BMA ein primäres Bullseye besitzt. Explizit genannt werden lediglich folgende Beispiele:

```text
CROWBAR (SW)    -> SEMINOLE
TRUMP CARD (E)  -> ESKIMO
```

Daraus darf **nicht** ohne weitere Quelle eine vollständige historische Tabelle `RC -> Bullseye` abgeleitet werden.

Insbesondere sind folgende Aussagen getrennt zu halten:

- `Capital / North / East / South / West` sind die geografischen Kategorien der vorgeschlagenen Bullseyes;
- eine BMA kann ein primäres Bullseye besitzen;
- BMA und ISAF Regional Command sind unterschiedliche Organisations-/Luftraumbegriffe;
- die Quelle enthält in den bereitgestellten Materialien keine vollständige explizite Mapping-Tabelle aller BMAs zu allen fünf Bullseyes;
- die fünf Bullseyes sind ein DCS-/ACO-Designvorschlag und kein Nachweis historischer ISAF-Bullseyes.

## 6. Verfahren und Phraseologie der Quelle

### 6.1 POSIT

Die Quelle verwendet `POSIT` für die Meldung der Position einer freundlichen Plattform relativ zum genannten Bullseye.

Format:

```text
[NAME] [MAGNETIC BEARING FROM BE] / [RANGE IN NM FROM BE]
```

Beispiel der Quelle:

```text
(FRIENDLY) POSIT SEMINOLE 0-4-5 / 65
```

### 6.2 ALPHA CHECK

`ALPHA CHECK` wird als Anfrage zur Bestätigung von Peilung und Entfernung vom Luftfahrzeug zum beschriebenen Bezugspunkt dargestellt.

Format:

```text
[NAME] [MAGNETIC BEARING FROM ACFT TO BE] / [RANGE IN NM FROM ACFT TO BE]
```

Beispiel der Quelle:

```text
ALPHA CHECK SEMINOLE 2-2-5 / 65
```

### 6.3 Mehrere Bullseyes gleichzeitig

Bei mehreren aktiven Bullseyes muss nach Darstellung der Quelle der konkrete Name genannt werden.

Korrektes Schema in dieser Mehr-Bullseye-Konfiguration:

```text
SEMINOLE 2-7-0 / 90
```

Nicht zu verwenden:

```text
BULLSEYE SEMINOLE 2-7-0 / 90
```

Die Quelle reserviert den Präfix `BULLSEYE` für den Fall eines einzelnen etablierten Theater-Bullseyes, beispielsweise:

```text
BULLSEYE 2-7-0 / 90
```

Diese Phraseologie wird zunächst als **Quellenaussage** dokumentiert. Eine OMW-weite Spieler-/Funkstandardisierung daraus ist eine gesonderte Projektentscheidung.

## 7. Technische Prüfung der bereitgestellten CombatFlite-Datei

Die Datei `Bullseye List - Afghanistan.cf` ist ein ZIP-basierter CombatFlite-Container. In `mission.xml` sind fünf gesperrte Reference Points vorhanden:

```text
WARRIOR  33.7666666666667 / 62.8333333333333
NAVAJO   35.8000000000000 / 66.4500000000000
SEMINOLE 30.8500000000000 / 64.4000000000000
ESKIMO   32.6500000000000 / 67.6333333333333
CREE     35.2833333333333 / 70.2666666666667
```

Diese Werte stimmen mit dem bereitgestellten Kneeboard überein.

Quellenkritische technische Auffälligkeit der `.cf`-Datei:

```text
<Theater>PersianGulf</Theater>
<Year>1980</Year>
```

Diese Felder widersprechen dem dargestellten Afghanistan-/ISAF-Kontext. Deshalb wird die `.cf`-Datei für OMW ausschließlich als **Träger der RefPoint-Geometrie und Spider-Chart-Konfiguration** ausgewertet. Ihre Theater-/Missionsmetadaten werden nicht als fachliche Aussage übernommen.

Außerdem enthält CombatFlite nur je einen technischen `BlueBullseye`, `RedBullseye` und `NeutralBullseye`; die fünf Afghanistan-Punkte liegen separat als `RefPoint`-Objekte vor. Daraus folgt für OMW keine automatische 1:1-Aussage über die spätere DCS-Mission-Editor-Repräsentation mehrerer Bullseyes.

## 8. OMW-relevante Ableitung

Aus der Quelle kann belastbar übernommen werden:

1. ein großes Afghanistan-Theater profitiert bei polarer Positionsmeldung von mehreren regionalen Referenzpunkten;
2. Graveyard of Empires schlägt genau fünf benannte Punkte mit reproduzierbaren WGS84-Koordinaten vor;
3. die fünf Punkte sind im PDF/PNG und in der CombatFlite-Geometrie konsistent;
4. BMA-spezifische primäre Bullseyes sind Teil des vorgeschlagenen ACO-Designs;
5. `SEMINOLE` für `CROWBAR (SW)` und `ESKIMO` für `TRUMP CARD (E)` sind im Beitrag ausdrücklich genannte Beispiele;
6. die Quelle liefert eine konkrete Mehr-Bullseye-Phraseologie für `POSIT` und `ALPHA CHECK`.

Nicht aus der Quelle abzuleiten:

- historische Nutzung genau dieser fünf Bullseyes durch ISAF/OEF 2010/2011;
- eine vollständige Zuordnung `Regional Command -> Bullseye`;
- reale klassifizierte ACO-/SPINS-Inhalte;
- automatische DCS-Mission-Editor- oder Avionik-Unterstützung für fünf gleichzeitig aktive Bullseyes;
- technische MOOSE- oder DCS-Runtime-Funktionalität.

## 9. Projektstatus und nächste Entscheidungsgrenze

Diese Quellenaufnahme **ändert noch keine bestehende OMW-Missionsbaseline** und erzeugt keine Runtime-Implementierung.

Für eine produktive Übernahme wären getrennt zu entscheiden beziehungsweise zu prüfen:

```text
1. Übernahme der fünf Graveyard-Punkte als OMW-Bullseye-Baseline?
2. BMA-zu-Bullseye-Mapping für alle OMW-BMAs.
3. Darstellung in Mission Editor, Briefing und Kneeboard.
4. Avionik-/Modulgrenzen bei mehreren Bullseyes.
5. Nutzung für BRAA/POSIT/ALPHA-CHECK-Spielerkommunikation.
6. gegebenenfalls maschinenlesbarer Datensatz für ACO-/Air-C2-Produkte.
```

Eine spätere technische Umsetzung muss gegen die tatsächlich verwendete DCS-Version und – falls Runtime-Logik erforderlich wird – gemäß `OMW-GOV-MOOSE-FIRST` gegen die verwendete MOOSE-Version geprüft werden.
