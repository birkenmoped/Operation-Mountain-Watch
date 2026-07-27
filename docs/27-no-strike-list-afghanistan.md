# Afghanistan No-Strike List (NSL)

## 1. Status und Geltungsbereich

**Status:** `SOURCE_IMPORTED` / `PLANNED` / noch nicht als Laufzeitfunktion in DCS validiert.

Dieses Dokument übernimmt und bewertet die für **Operation Mountain Watch** bereitgestellte Afghanistan-NSL-Datenbasis und legt die verbindliche Zielschutz-Architektur für Missionsdesign, dynamische Zielgenerierung, Spieleraufträge und AI-Einsätze fest.

Die NSL ist für das Projekt keine optionale Karteninformation. Sie ist eine verpflichtende Ausschluss- und Prüfkomponente vor jeder projektseitigen Zielnominierung oder Angriffserzeugung.

Dieses Dokument ist eine Simulations- und Missionsdesignvorgabe. Es ersetzt keine reale Rechtsberatung, ROE, Freigabekette oder militärische Zielprüfung.

## 2. Verbindliche Projektentscheidung

Für **Operation Mountain Watch** gilt:

> Kein durch die Mission erzeugtes Ziel, kein Spielerauftrag und kein AI-Angriffsauftrag darf freigegeben werden, bevor eine positive NSL-Prüfung erfolgt ist.

Die Prüfung muss mindestens für folgende Pfade gelten:

- dynamische Ziel- und Camp-Erzeugung,
- Missionsgenerator und Kampagnendirektor,
- `INTEL`-Kontakte und daraus abgeleitete Zielkandidaten,
- Spieleraufträge,
- `COMMANDER`-/`AIRWING`-Assetzuweisung,
- `AUFTRAG` für CAS, BAI, Bombing, Precision Bombing, Armed Reconnaissance und bewaffnete UAVs,
- automatische oder halbautomatische FAC-/AFAC-/JTAC-Unterstützung,
- F10-Marker oder sonstige Spieleranforderungen, aus denen Angriffsaufträge entstehen,
- Artillerie-, Boden- oder spätere Non-Lethal-/Effects-Aufträge, sofern deren Wirkung geschützte Objekte beeinträchtigen kann.

Ein NSL-Treffer ist standardmäßig ein **Hard Block**. Eine Aufhebung darf nicht stillschweigend, nicht allein durch Feindnähe und nicht allein durch ein DCS-Erkennungsergebnis erfolgen.

## 3. Fachlicher Hintergrund

### 3.1 NSL ist keine Zielliste

Eine No-Strike List enthält Objekte oder Entitäten, die aufgrund von Völkerrecht, Rules of Engagement, politischer Vorgaben, Schutzstatus, freundlicher beziehungsweise neutraler Funktion oder strategischer Sensibilität vor den Wirkungen militärischer Operationen geschützt werden sollen.

Sie ist von anderen Listen zu unterscheiden:

| Liste / Prüfung | Bedeutung für OMW |
|---|---|
| **NSL** | Geschützte Entität; standardmäßig kein Ziel und keine Wirkung innerhalb des festgelegten Schutzbereichs. |
| **RTL** | Gültiges militärisches Ziel mit spezifischen Beschränkungen oder zusätzlicher Freigabepflicht. |
| **JTL/JIPTL bzw. projektseitige Zielliste** | Validierte beziehungsweise priorisierte Zielkandidaten. Ein Eintrag dort ersetzt keine NSL-Prüfung. |
| **CDE/CDM** | Abschätzung und Begrenzung erwartbarer Kollateralschäden bei einem grundsätzlich zulässigen Ziel. |
| **No-Engage-/No-Fire-Zone** | Taktische oder temporäre Wirkungsbeschränkung; kann ergänzend zur NSL bestehen. |

Die Reihenfolge im Projekt lautet daher:

```text
Kontakt oder Zielkandidat
→ Identifikation und Gültigkeitsprüfung
→ NSL-/Schutzprüfung
→ gegebenenfalls RTL-/Freigabeprüfung
→ Kollateralschadens- und Waffenprüfung
→ Auftragserzeugung
→ Wirkung
→ BDA und Ereignisprotokoll
```

### 3.2 Relevanz für das Afghanistan-Szenario

Der Angriff auf das geschützte Trauma Center in Kunduz am 3. Oktober 2015 zeigt, dass eine vorhandene NSL allein nicht genügt. In der offiziellen Untersuchung wurden unter anderem fehlende beziehungsweise nicht verfügbare No-Strike-Informationen, Koordinaten- und Identifikationsfehler, Kommunikationsausfälle sowie unzureichende Gegenprüfung als beitragende Faktoren festgestellt.

Für OMW folgt daraus:

- Die NSL muss **vor Missionsbeginn lokal verfügbar** sein.
- Sie darf nicht von einer einzelnen Funk-, Datalink- oder Menüverbindung abhängen.
- Eine Koordinate muss automatisiert gegen den Schutzbestand geprüft werden.
- Der Treffer muss für den Auftragserzeuger eindeutig und nicht nur als Kartenmarkierung sichtbar sein.
- Fehlende Daten oder eine fehlerhafte Konvertierung müssen zu `REVIEW_REQUIRED` beziehungsweise `BLOCKED` führen, nicht zu einer stillen Freigabe.

## 4. Übernommene Quellen

### 4.1 Patreon-Serie „Graveyard of Empires“

Referenzierte Beiträge:

1. [No Strike List](https://www.patreon.com/graveyard4DCS/posts/no-strike-list-116305895?collection=833534)
2. [Creating our own NSL for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/creating-our-own-116671166?collection=833534)
3. [NSL v1.0 for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/nsl-v1-0-for-116676047?collection=833534)

Die Patreon-Seiten waren über den automatisierten Abruf nicht vollständig lesbar. Deshalb werden keine nicht nachprüfbaren Detailaussagen aus den Beiträgen behauptet. Die konkrete Datenanalyse basiert auf dem vom Projektinhaber bereitgestellten Archiv.

### 4.2 Bereitgestelltes Archiv

Quelldatei:

```text
NSL v1.0.zip
```

Enthalten:

| Datei | Zweck | SHA-256 |
|---|---|---|
| `NSL v1.0.cf` | CombatFlite-Missions-/Referenzpunktdatei | `f3ec27c6ea9b2fdc952fa8ea692d8bd60e18b792a60580a2710b421482cd0500` |
| `NSL v1.0.kmz` | KML/KMZ-Geodaten mit den NSL-Punkten | `fc8661e5ea2f1bd54b768aaf342ce14eea6824aa0140be41eb3fdf6332bbc7b0` |

Archiv-Hash:

```text
5dc6062b8aa048401ac25e28c0c64a7de3914639ada016fb3cb3180c736f0be1
```

Zeitstempel der Dateien im ZIP-Archiv: **25. November 2024**. Dieser ZIP-Zeitstempel ist kein gesicherter fachlicher Datenstand und kein Nachweis für die Aktualität der zugrunde liegenden Geodaten.

### 4.3 Ergänzende Referenzen

- U.S. Army Operational Law Handbook, Zielbeschränkungen und Target Lists
- Joint-/Air-Targeting-Doktrin als Begriffsrahmen
- offizielle DoD-Veröffentlichungen zur Kunduz-Untersuchung
- MOOSE Develop Documentation für `COORDINATE`, `ZONE_BASE`, `ZONE_RADIUS` und Polygonzonen

## 5. Verifizierter Datenbestand von NSL v1.0

### 5.1 Gesamtbestand

Die KMZ-Datei enthält **2.954 eindeutige Placemarks**. Die CombatFlite-Datei enthält **2.954 Referenzpunkte**.

Die beiden Formate stimmen vollständig überein:

- identische NSL-IDs,
- identische WGS84-Koordinaten,
- keine fehlenden Einträge,
- keine zusätzlichen Einträge,
- keine exakten Koordinatenduplikate,
- globale Nummernfolge `0001` bis `2954` ohne Lücke und ohne Wiederholung.

### 5.2 Kategorien

Die Kategorien sind in den IDs als dreistellige Präfixe codiert. Die ausgeschriebenen Bedeutungen sind aus den Präfixen abgeleitet und müssen gegen die ursprüngliche Erzeugungsquelle beziehungsweise den Patreon-Volltext bestätigt werden.

| Präfix | Abgeleitete Bedeutung | Anzahl | Anteil |
|---|---|---:|---:|
| `MOS` | Mosque / Moschee | 2.146 | 72,647 % |
| `EDU` | Education / Bildungseinrichtung | 492 | 16,655 % |
| `MED` | Medical / medizinische Einrichtung | 208 | 7,041 % |
| `POL` | Police / Polizeieinrichtung | 69 | 2,336 % |
| `CEM` | Cemetery / Friedhof | 36 | 1,219 % |
| `JUS` | Justice / Justizeinrichtung | 3 | 0,102 % |
| **Gesamt** |  | **2.954** | **100,000 %** |

Beispiel-ID:

```text
NSLEDU0001
```

Struktur:

```text
NSL + Kategoriepräfix + vierstellige globale Sequenznummer
```

### 5.3 Geografische Ausdehnung

WGS84-Grenzen des Datensatzes:

| Grenze | Wert |
|---|---:|
| nördlichster Breitengrad | `38.4672732` |
| südlichster Breitengrad | `29.4161573` |
| westlichster Längengrad | `60.5421303` |
| östlichster Längengrad | `73.3784438` |

Die Ausdehnung umfasst nahezu ganz Afghanistan und reicht damit deutlich über den jeweils tatsächlich modellierten beziehungsweise hochdetaillierten DCS-Kartenausschnitt hinaus.

## 6. Festgestellte Einschränkungen und Datenrisiken

### 6.1 Punktdaten statt Objektgeometrien

Jeder Eintrag besteht nur aus einem Mittelpunkt. Es fehlen:

- Gebäudegrundriss,
- Grundstücksgrenze,
- Campus- oder Anlagenumfang,
- validierter Schutzradius,
- Höheninformation,
- Objektname,
- Adresse,
- Ursprungsdaten-ID,
- Erfassungsdatum,
- Genauigkeitsangabe,
- Vertrauens- oder Verifizierungsstatus,
- Begründung des Schutzstatus.

Ein Punkt darf daher nicht mit dem vollständigen räumlichen Umfang der geschützten Entität gleichgesetzt werden.

### 6.2 Keine pauschalen Schutzradien erfinden

Ein einheitlicher Radius für Moschee, Krankenhaus, Schule, Friedhof und Polizeikomplex wäre fachlich nicht belastbar. Eine kleine Dorfmoschee und ein Krankenhauscampus haben unterschiedliche Flächen und Kollateralschadensrisiken.

Bis zur Festlegung überprüfter Geometrien gilt:

- Schutzradien sind konfigurierbar,
- sie werden als **projektseitige Sicherheits- und Gameplay-Parameter** dokumentiert,
- sie dürfen nicht als reale rechtliche Standardabstände bezeichnet werden,
- konservative Unsicherheitsbehandlung ist einer stillen Freigabe vorzuziehen,
- wichtige Einrichtungen sollen später als Polygon statt als Punkt abgebildet werden.

### 6.3 Herkunft und Lizenz

Die dem Archiv zugrunde liegende Primärdatenquelle und deren Lizenz sind im Archiv nicht dokumentiert. Eine OpenStreetMap-Herkunft ist anhand des Datensatzes nicht gesichert nachweisbar und darf deshalb nicht als Tatsache behauptet werden.

Folge:

- Die vollständige normalisierte Punktdatenbank wird nicht ohne Herkunfts- und Lizenzprüfung in das öffentliche GitHub-Repository übernommen.
- Hashes, Struktur, Prüfergebnisse und Integrationsanforderungen werden dokumentiert.
- Vor einer Veröffentlichung der Koordinaten sind Quelle, Lizenz, Attribution und etwaige Share-Alike-Pflichten zu klären.

### 6.4 CombatFlite-Metadaten

Die Datei `NSL v1.0.cf` enthält intern:

```text
Theater: PersianGulf
MissionName: NEW MISSION
```

Diese Werte widersprechen dem Afghanistan-Verwendungszweck und sind als generische beziehungsweise nicht bereinigte Container-Metadaten zu behandeln. Sie dürfen nicht zur Auswahl des DCS-Theaters oder als Missionsname übernommen werden.

Weitere Eigenschaften der CombatFlite-Punkte:

- Typ: `Other`,
- Farbe: Rot,
- `Enabled=True`,
- `Locked=True`,
- leere Kommentarfelder.

### 6.5 Datenalter und Vollständigkeit

Der Bestand ist eine **Version 1.0** und kein dauerhaft gültiges Lagebild. Einrichtungen können:

- fehlen,
- verschoben oder falsch verortet sein,
- umbenannt oder geschlossen worden sein,
- neu hinzugekommen sein,
- in DCS an einer abweichenden Position modelliert sein,
- außerhalb des spielbaren beziehungsweise hochdetaillierten DCS-Bereichs liegen.

Die Abwesenheit eines Objekts in der NSL ist ausdrücklich **keine Angriffserlaubnis**.

## 7. Verbindliches OMW-Datenmodell

Ein operativ nutzbarer Datensatz soll mindestens folgende Felder besitzen:

| Feld | Zweck |
|---|---|
| `nsl_id` | Stabile Projekt-ID, zum Beispiel `NSLMED0123`. |
| `category_code` | Quellkategorie wie `MED`. |
| `category_label` | Bestätigte Klartextkategorie. |
| `source_version` | Quelldatenstand, zum Beispiel `NSL v1.0`. |
| `source_reference` | Herkunft, Lizenz und gegebenenfalls externe Objekt-ID. |
| `latitude_wgs84` / `longitude_wgs84` | unveränderte Quellkoordinate. |
| `dcs_x` / `dcs_y` | versions- und kartenbezogene DCS-Koordinate, sofern vorab erzeugt. |
| `geometry_type` | `POINT_RADIUS` oder `POLYGON`. |
| `protection_radius_m` | freigegebener projektseitiger Radius bei Punktgeometrien. |
| `status` | `ACTIVE`, `REVIEW_REQUIRED`, `SUPERSEDED`, `INACTIVE`. |
| `confidence` | Qualität und Verifizierungsstand. |
| `effective_from` / `effective_to` | Gültigkeitszeitraum für Kampagnenstand oder Mission. |
| `dcs_alignment_status` | Abgleich mit der DCS-Afghanistan-Karte. |
| `notes` | Begründung, Sonderregeln und Prüfnachweise. |

Quellwerte und abgeleitete Werte müssen getrennt bleiben. Insbesondere darf eine DCS-Koordinate nicht die ursprüngliche WGS84-Koordinate überschreiben.

## 8. MOOSE-First-Architektur

### 8.1 Geprüfte MOOSE-Bausteine

Die aktuelle Develop-Dokumentation weist folgende grundsätzlich geeignete Funktionen aus:

| MOOSE-Baustein | Geplanter Zweck | Status in OMW |
|---|---|---|
| `COORDINATE:NewFromLLDD(latitude, longitude, altitude)` | WGS84-Koordinate in eine DCS-/MOOSE-Koordinate überführen | `PLANNED`; gegen eingebundene `Moose.lua` und Afghanistan testen |
| `ZONE_RADIUS:New(name, vec2, radius, doNotRegisterZone)` | Interimistische Schutzfläche um einen Punkt | `PLANNED`; Radien und Registrierungsstrategie offen |
| `ZONE_BASE:IsCoordinateInZone()` | Zielkoordinate gegen Schutzfläche prüfen | `PLANNED`; konkreter Laufzeitpfad nicht validiert |
| `ZONE_RADIUS:IsVec2InZone()` | performante 2D-Prüfung einer Zielposition | `PLANNED`; konkreter Laufzeitpfad nicht validiert |
| `ZONE_POLYGON_BASE` / Polygonzonen | validierte Grundstücks- oder Objektumrisse | `CANDIDATE`; Datenquelle und Konstruktor prüfen |
| `SET_ZONE` | Gruppenweise Verwaltung bereits registrierter Zonen | `CANDIDATE`; für 2.954 dynamische Einträge nicht automatisch die beste Datenstruktur |

Es wurde keine belastbare MOOSE-Spezialklasse gefunden, die eine militärische No-Strike List mit Status-, Quellen-, Freigabe- und Auditlogik vollständig abbildet.

Daraus folgt gemäß der MOOSE-First-Richtlinie:

- MOOSE übernimmt Koordinaten- und Zonengeometrie.
- Eine kleine projektspezifische **NSL-Policy- und Registry-Schicht** darf die fachlichen Regeln, Quellenmetadaten, Statuswerte, räumliche Vorfilterung und Freigabeentscheidungen ergänzen.
- Eine vollständige parallele Geometrieimplementierung ist nicht vorgesehen.
- Vor Implementierung sind Dokumentation, tatsächlich eingebundener MOOSE-Quellstand und offizielle Demo-/Testmissionen zu prüfen.

### 8.2 Geplanter Datenfluss

```text
freigegebene NSL-Quelldaten
→ Schema-, Hash- und Plausibilitätsprüfung
→ Filter auf DCS-Afghanistan-Abdeckung
→ WGS84-Konvertierung mit COORDINATE:NewFromLLDD()
→ Schutzgeometrie / räumlicher Index
→ NSLRegistry
→ CheckTarget(candidate)
     ├── CLEAR
     ├── REVIEW_REQUIRED
     ├── BLOCKED_NSL
     ├── BLOCKED_NO_ENGAGE
     └── RESTRICTED_RTL
→ nur bei positivem Ergebnis: Ziel-/Auftragserzeugung
```

### 8.3 Vorgesehene Schnittstelle

Die spätere Projektfunktion soll nicht nur `true` oder `false` liefern, sondern einen nachvollziehbaren Prüfbericht:

```text
result.status
result.candidateCoordinate
result.matchedNslIds
result.minimumDistanceMeters
result.appliedGeometry
result.sourceVersion
result.reason
result.checkedAt
```

Dies ist ein Architekturvertrag, noch kein freigegebener Lua-Code.

## 9. Performance- und Skalierungsanforderungen

Eine lineare Prüfung aller 2.954 Einträge bei jedem Scheduler-Tick, jedem Sensorupdate und jedem Zielkandidaten ist zu vermeiden.

Vorgesehen ist:

1. einmaliges Laden und Validieren beim Missionsstart,
2. Filterung auf den tatsächlichen DCS-Kartenbereich,
3. räumliche Vorindizierung, beispielsweise Rasterzellen oder Bounding Boxes,
4. Grobprüfung nur gegen benachbarte Indexzellen,
5. genaue MOOSE-Zonenprüfung nur für verbleibende Kandidaten,
6. keine dauernde `Scan()`-Abfrage aller NSL-Zonen,
7. keine automatische Darstellung aller NSL-Punkte auf der F10-Karte,
8. Cache für wiederkehrende Prüfungen identischer Zielkoordinaten,
9. messbarer Performance-Test unter Multiplayer-Serverlast.

`ZONE_RADIUS:Scan()` ist für die NSL-Koordinatenprüfung nicht erforderlich. Die NSL soll Zielkoordinaten gegen Geometrien prüfen und nicht fortlaufend Einheiten in allen Schutzflächen suchen.

## 10. Einbindung in die Missionsarchitektur

### 10.1 Missionsgenerator und RedDirector

- Spawn- und Zielzonen dürfen keine aktive NSL-Geometrie schneiden.
- Feindliche Camps, Waffenlager, Führungsstellen oder IED-Zellen dürfen nicht innerhalb einer NSL-Schutzfläche erzeugt werden.
- Ein nachträglich bewegtes Ziel innerhalb einer NSL-Zone wird nicht automatisch zum zulässigen Angriffsziel.
- Der Konflikt wird als Szenarioereignis beziehungsweise `REVIEW_REQUIRED` behandelt.

### 10.2 INTEL, FAC, AFAC und UAV

- `INTEL` darf Kontakte in oder nahe einer NSL erfassen.
- Erkennung ist nicht gleich Angriffserlaubnis.
- `DESIGNATE`, FAC(A), UAV-Laser und Rauch dürfen einen geschützten Kontakt nicht automatisch in einen Angriffspfad überführen.
- Ein bewaffnetes UAV darf keinen Auto-Engage-Auftrag erhalten, wenn die NSL-Prüfung fehlt oder negativ ist.

### 10.3 Spieleraufträge

- Spieler erhalten keinen normalen Strike-/CAS-Auftrag auf einen blockierten Zielkandidaten.
- Bei einem Feindkontakt in einem geschützten Bereich kann stattdessen ein Aufklärungs-, Überwachungs-, Absperr-, Show-of-Force- oder anderer nicht automatisch letaler Auftrag angeboten werden.
- Ein Warnhinweis ersetzt die technische Sperre der projektseitigen Auftragserzeugung nicht.

### 10.4 AI-Aufträge

Vor Konstruktion eines offensiven `AUFTRAG` muss der Zieladapter einen positiven NSL-Status liefern. Dies gilt auch dann, wenn MOOSE oder DCS die Zielgruppe technisch als feindlich erkennt.

### 10.5 Direkte Spielerwirkung

Eine DCS-Mission kann einen menschlichen Spieler nicht in jedem Fall technisch am Waffenabwurf hindern. Deshalb sind zusätzlich vorzusehen:

- Briefing und SPINS,
- sichtbare ROE-/NSL-Hinweise nur im benötigten Umfang,
- Ereignisprotokoll bei Wirkung in einer Schutzfläche,
- Missionsbewertung und Kampagnenfolgen,
- gegebenenfalls serverseitige Sanktionen,
- eindeutige Unterscheidung zwischen versehentlichem Randtreffer, Kollateralschaden und bewusstem Angriff.

Die konkrete Bewertungs- und Sanktionslogik ist separat festzulegen.

## 11. Lebenszyklus und Freigaben

### 11.1 Statusmodell

```text
IMPORTED
→ REVIEW_REQUIRED
→ ACTIVE
→ SUPERSEDED oder INACTIVE
```

Ein Quellimport wird nicht automatisch `ACTIVE`.

### 11.2 Änderungen des Schutzstatus

Ein NSL-Eintrag bleibt standardmäßig geschützt. Ein Szenario kann einen geänderten Status nur über einen expliziten, protokollierten Vorgang abbilden:

- positive Identifikation,
- definierte Szenario- beziehungsweise Kampagnenbedingung,
- festgelegte Freigabeautorität,
- dokumentierte Begründung,
- zeitliche Gültigkeit,
- aktualisierte Schutz- oder Wirkungsregeln.

Eine bloße Anwesenheit feindlicher Einheiten reicht nicht für eine automatische Statusänderung.

## 12. Verbindliche Qualitätssicherung

### 12.1 Importprüfung

Der Import muss mindestens prüfen:

- erwartete Dateiversion und Hash,
- Pflichtfelder und Datentypen,
- eindeutige IDs,
- gültige Koordinatenbereiche,
- bekannte Kategoriecodes,
- Anzahl je Kategorie,
- vollständige Sequenznummern,
- exakte Koordinatenduplikate,
- Abweichungen zwischen KMZ-, CombatFlite- und späterer OMW-Datenquelle.

Referenzwerte für NSL v1.0:

```text
Gesamt: 2954
CEM: 36
EDU: 492
JUS: 3
MED: 208
MOS: 2146
POL: 69
Sequenz: 0001..2954 ohne Lücke
Exakte Koordinatenduplikate: 0
```

### 12.2 DCS-/MOOSE-Testfälle

Mindestens zu testen:

1. WGS84-Konvertierung mehrerer Punkte in verschiedenen Kartenregionen.
2. Vergleich der erzeugten DCS-Position mit CombatFlite/KMZ und DCS-Karte.
3. Ziel exakt im Mittelpunkt einer NSL-Geometrie: `BLOCKED_NSL`.
4. Ziel exakt auf der Grenze: definierte und getestete Randregel.
5. Ziel knapp außerhalb: `CLEAR` oder `REVIEW_REQUIRED` gemäß Pufferregel.
6. Zielgruppe mit mehreren Einheiten, von denen nur eine die Schutzfläche schneidet.
7. bewegliches Ziel betritt eine Schutzfläche nach Auftragserzeugung.
8. Auftrag wird vor Wirkung erneut geprüft.
9. fehlende oder beschädigte NSL-Datei führt zu Fail-Closed für automatische Angriffe.
10. Multiplayer-Performance mit realistischem Kontakt- und Auftragsvolumen.
11. Neustart und Persistenz mit identischem Datenstand.
12. Versionswechsel erzeugt einen nachvollziehbaren Änderungsbericht.

### 12.3 Acceptance-Kriterien

Die NSL-Funktion darf erst als `VALIDATED` gelten, wenn:

- der verwendete MOOSE-Stand dokumentiert ist,
- die konkreten Signaturen im eingebundenen Quellstand bestätigt sind,
- die Afghanistan-Konvertierung in DCS geprüft wurde,
- alle relevanten Zielerzeugungspfade die zentrale NSL-Prüfung verwenden,
- negative und positive Testfälle reproduzierbar bestanden sind,
- Fail-Closed-Verhalten getestet ist,
- Performance unter Missionslast akzeptabel ist,
- ein Acceptance-Bericht und Eintrag in `docs/moose/VERIFIED-METHODS.md` vorliegen.

## 13. Offene Entscheidungen

Vor Implementierung müssen festgelegt werden:

1. Primärdatenquelle, Lizenz und Attribution der 2.954 Punkte.
2. Bestätigung der sechs Kategoriebezeichnungen.
3. Welche Einträge innerhalb der tatsächlich nutzbaren DCS-Afghanistan-Karte liegen.
4. Kategorie- oder objektspezifische Interimsschutzradien.
5. Welche wichtigen Objekte manuell als Polygone erfasst werden.
6. Zuständige projektinterne Freigabeautorität für Statusänderungen.
7. Verhalten bei Feindkontakt innerhalb einer Schutzfläche.
8. Regeln für Non-Lethal Effects, Show of Force und ISR in NSL-Bereichen.
9. Darstellung im F10-Menü, Briefing und für verschiedene Rollen.
10. Konsequenzen bei direkter Spielerwirkung gegen geschützte Entitäten.
11. Aktualisierungsintervall und Versionsmanagement.
12. Räumlicher Index und Performancebudget.

## 14. Nächste Arbeitspakete

### NSL-01 – Quellen- und Lizenzklärung

- Primärquelle der Geodaten ermitteln.
- Lizenz und notwendige Attribution dokumentieren.
- Kategoriecodes bestätigen.

### NSL-02 – DCS-Kartenabgleich

- alle Punkte gegen die aktuelle DCS-Afghanistan-Abdeckung prüfen,
- repräsentative Stichproben visuell abgleichen,
- Abweichungen und nicht modellierte Orte kennzeichnen.

### NSL-03 – Schutzgeometrien

- Interimsschutzradien fachlich festlegen,
- priorisierte Krankenhäuser, Schulen, religiöse und kulturelle Großobjekte als Polygon erfassen,
- Rand- und Pufferregeln definieren.

### NSL-04 – MOOSE-Prototyp

- eingebundene MOOSE-Version bestimmen,
- `COORDINATE:NewFromLLDD()`, `ZONE_RADIUS:New()` und `IsCoordinateInZone()` im Quellstand verifizieren,
- minimalen Import- und Prüfprototyp erstellen,
- keine Auftragserzeugung integrieren, bevor der Prototyp bestanden ist.

### NSL-05 – Architektur-Integration

- zentralen Check in MissionGenerator, Player Tasks und AI-Auftragserzeugung einbauen,
- Auditlogging und Fail-Closed-Verhalten ergänzen,
- Testmission und Acceptance-Bericht erstellen.

## 15. Referenzen

### Projektquellen

- [Verbindliche MOOSE-First-Entwicklungsrichtlinie](26-moose-first-development-policy.md)
- [MOOSE-Projektdokumentation](moose/README.md)
- [ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur](moose/ISR-FAC-CAS-AAR.md)

### MOOSE

- [Core.Point / COORDINATE](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Point.html)
- [Core.Zone](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Zone.html)
- [MOOSE Source Repository](https://github.com/FlightControl-Master/MOOSE)

### Militärische und rechtliche Hintergrundquellen

- [U.S. Army Operational Law Handbook](https://tjaglcs.army.mil/Periodicals/Deskbooks-Handbooks/Operational-Law-Handbook)
- [U.S. Department of Defense: Kunduz investigation summary, 25 November 2015](https://www.defense.gov/News/News-Stories/Article/Article/631304/campbell-kunduz-hospital-attack-tragic-avoidable-accident/)
- [U.S. Department of Defense: CENTCOM investigation findings, 29 April 2016](https://www.defense.gov/News/News-Stories/Article/Article/746393/centcom-commander-communications-breakdowns-human-errors-led-to-attack-on-afgha/)
- [U.S. Department of Defense press briefing, 29 April 2016](https://www.defense.gov/News/Transcripts/Transcript/Article/746686/department-of-defense-press-briefing-by-army-general-joseph-votel-commander-us/)
