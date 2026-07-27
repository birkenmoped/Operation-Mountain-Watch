# Afghanistan No-Strike List (NSL)

## 1. Status und Geltungsbereich

**Status:** `SOURCE_IMPORTED` / `SOURCE_SERIES_CAPTURED` / `PLANNED` / noch nicht als Laufzeitfunktion in DCS validiert.

Dieses Dokument übernimmt und bewertet die für **Operation Mountain Watch** bereitgestellte Afghanistan-NSL-Datenbasis. Es dokumentiert außerdem die vollständige dreiteilige Quellenserie von **Graveyard of Empires** und legt die verbindliche Zielschutz-Architektur für Missionsdesign, dynamische Zielgenerierung, Spieleraufträge und AI-Einsätze fest.

Die NSL ist keine optionale Karteninformation. Sie ist eine verpflichtende Ausschluss- und Prüfkomponente vor jeder projektseitigen Zielnominierung oder Angriffserzeugung.

Dieses Dokument ist eine Simulations- und Missionsdesignvorgabe. Es ersetzt keine reale Rechtsberatung, ROE, Freigabekette oder militärische Zielprüfung.

## 2. Credit, Urheberangabe und Quellenhinweis

### 2.1 Verbindliche Attribution

Die Afghanistan-NSL v1.0 und die zugrunde liegende Recherche wurden von **Graveyard of Empires** für die DCS-Afghanistan-Community zusammengestellt und veröffentlicht.

**Sämtliche Credits für den bereitgestellten NSL-Datensatz gehen an:**

- **Graveyard of Empires**
- <https://www.patreon.com/cw/graveyard4DCS>

Diese Attribution ist bei jeder projektinternen oder externen Verwendung der NSL-Daten, abgeleiteter Dateien, Karten, Tabellen oder Dokumentationen beizubehalten.

Operation Mountain Watch beansprucht keine Urheberschaft an der ursprünglichen Recherche, der Zusammenstellung oder den bereitgestellten CombatFlite-/KML-/KMZ-Daten. Projektspezifisch sind ausschließlich die technische Analyse, Normalisierung, DCS-/MOOSE-Integration und darauf aufbauende Missionslogik.

### 2.2 Erklärung des Autors zur Informationsherkunft

Auf der Patreon-Hauptseite erklärt Graveyard of Empires, dass die dort präsentierten Informationen aus offenen Quellen stammen. Diese Quellen seien teilweise leicht zugänglich, aber wenig verstanden, teilweise ungewöhnlicher, jedoch nicht weniger relevant.

Für die Projektdokumentation wird daraus festgehalten:

- Die in den Beiträgen präsentierten Informationen stammen nach ausdrücklicher Angabe des Autors aus **offenen Quellen**.
- Die Recherche, Auswahl und Zusammenführung dieser Informationen ist die Leistung von **Graveyard of Empires**.
- Die NSL ist keine geheime, klassifizierte oder aus nichtöffentlichen militärischen Systemen übernommene Datenbasis.
- Die konkrete ursprüngliche Einzelquelle jedes der 2.954 Datensätze ist in den bereitgestellten Dateien nicht separat hinterlegt.

### 2.3 Projektfreigabe, Veröffentlichung und Lizenzbezeichnung

Die Aussage „open sources“ beschreibt die Herkunft und öffentliche Zugänglichkeit der Informationen. Sie benennt für sich allein keine allgemeine Weiterveröffentlichungslizenz wie Creative Commons, Open Database License oder Public Domain.

Für **Operation Mountain Watch** ist der konkrete Nutzungs- und Veröffentlichungsumfang jedoch bereits verbindlich entschieden durch:

- `OMW-GOV-SOURCE-USE` – `docs/sources/graveyard-of-empires.md`;
- `OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE` – `docs/targeting/afghanistan-nsl-data-use-policy.md`.

Daraus folgt projektweit:

| Verwendung | Verbindliche Projektregel |
|---|---|
| interne Nutzung im Projekt und in Testmissionen | genehmigt; vollständige Attribution und Provenienz bleiben verpflichtend |
| Dokumentation von Struktur, Hashes, Kategorien und Prüfergebnissen | genehmigt; Credit und Quellenverweis sind beizubehalten |
| Normalisierung aller 2.954 Einträge sowie Konvertierung in Lua, JSON, CSV, GeoJSON oder andere Laufzeitformate | genehmigt und vorgesehen |
| Einbindung normalisierter und abgeleiteter Daten in Missionen, Testpakete und veröffentlichte Projektartefakte | genehmigt und vorgesehen |
| Aufnahme der ursprünglichen `.cf`-, `.kml`-/`.kmz`-Dateien in Repository oder Missionspakete | nach dokumentierter Entscheidung des Projektmanagers beziehungsweise Autors zulässig; der konkrete Umfang wird als `PUBLIC`, `INTERNAL` oder `MISSION_PACKAGE_ONLY` festgelegt |

Eine fehlende ausdrückliche Lizenzbezeichnung im Ausgangsmaterial ist innerhalb dieser Projektentscheidung **kein Implementierungs- oder Veröffentlichungsblocker**. Attribution, Quellenlink, Hash- und Provenienznachweis sowie konkrete materialspezifische Nutzungsbedingungen bleiben verpflichtend. Werden später ausdrücklich entgegenstehende Bedingungen bekannt, wird der betroffene Projektbestand geprüft und erforderlichenfalls angepasst.

Diese interne Projektentscheidung behauptet nicht, dass der Datensatz gemeinfrei oder allgemein lizenzfrei ist. Sie legt den für Operation Mountain Watch genehmigten Projekt- und Veröffentlichungsumfang fest.

## 3. Vollständig übernommene Patreon-Quellenserie

| Beitrag | Veröffentlichung | Status im Projekt |
|---|---:|---|
| [No Strike List](https://www.patreon.com/graveyard4DCS/posts/no-strike-list-116305895?collection=833534) | 23. November 2024 | Volltext und Abbildungen vom Projektinhaber bereitgestellt und ausgewertet |
| [Creating our own NSL for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/creating-our-own-116671166?collection=833534) | 25. November 2024 | Volltext und Abbildungen vom Projektinhaber bereitgestellt und ausgewertet |
| [NSL v1.0 for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/nsl-v1-0-for-116676047?collection=833534) | 26. November 2024 | Volltext und Abbildung vom Projektinhaber bereitgestellt und ausgewertet |
| [Graveyard of Empires – Patreon-Hauptseite](https://www.patreon.com/cw/graveyard4DCS) | laufend | relevanter Credit- und Quellenhinweis übernommen |

Damit bestehen für diese dreiteilige NSL-Serie **keine ausstehenden Volltextabrufe mehr**.

Die konkrete technische Datenanalyse basiert zusätzlich auf dem vom Projektinhaber bereitgestellten Archiv `NSL v1.0.zip`.

## 4. Definition, Zweck und Verantwortung

### 4.1 Definition einer No-Strike List

Der Einführungsbeitrag beschreibt die NSL als ein wesentliches Dokument militärischer, insbesondere luftgestützter Kampagnen. Sie erfasst Orte, Einrichtungen, Organisationen oder andere Entitäten, die aufgrund des Völkerrechts oder operativer Erwägungen nicht absichtlich bekämpft werden dürfen.

Typische Schutzbereiche sind:

- kulturelle und religiöse Stätten,
- Zivilpersonen und Nichtkombattanten,
- Schulen, Krankenhäuser und Wohngebiete,
- für das zivile Überleben notwendige Infrastruktur wie Dämme und Stromnetze,
- neutrale oder eigene Kräfte,
- nicht feindliche Organisationen und sonstige geschützte Entitäten.

Zweck der NSL ist insbesondere:

- Einhaltung des Law of Armed Conflict beziehungsweise des humanitären Völkerrechts,
- Schutz von Zivilpersonen und zivilen Objekten,
- Vermeidung unverhältnismäßiger Schäden,
- Schutz humanitärer Hilfe,
- Unterstützung einer rechtmäßigen, legitimen und politisch tragfähigen Operationsführung.

### 4.2 Verantwortliche Stellen

Die Erstellung einer realen NSL ist ein kollaborativer Prozess. Der Quellenbeitrag nennt insbesondere:

- Joint Force Commander als strategisch verantwortliche Ebene,
- Rechtsberater,
- Nachrichtendienst- und Intelligence-Analysten,
- militärische Planer und Targeting-Fachpersonal,
- Vertreter des Gastlandes,
- Koalitionspartner,
- gegebenenfalls Vereinte Nationen und Nichtregierungsorganisationen.

Die Aufgabenverteilung umfasst:

- Identifikation möglicher geschützter Entitäten,
- geographische Verortung,
- Verifikation durch Satellitenbilder, Aufklärung und weitere Berichte,
- rechtliche Bewertung,
- Einbindung in den Targeting-Prozess,
- Abstimmung mit nationalen, politischen und Koalitionsvorgaben,
- fortlaufende Pflege bei veränderter Lage.

### 4.3 No-Strike Entities und No-Strike Facilities

Der Beitrag verweist auf die Unterscheidung in der US-Systematik:

| Begriff | Bedeutung für OMW |
|---|---|
| **No-Strike Entity (NSE)** | nicht zwingend ortsgebundene geschützte Entität, beispielsweise eine NGO und deren Angehörige |
| **No-Strike Facility (NSF)** | physische geschützte Einrichtung, beispielsweise ein Krankenhaus |

Die vorliegende Afghanistan-NSL v1.0 bildet überwiegend **physische Einrichtungen beziehungsweise Punkte** ab. Für OMW ist langfristig zusätzlich ein Modell für nicht ausschließlich geographische NSE erforderlich, beispielsweise geschützte Organisationen, Fahrzeuge, Konvois oder temporäre humanitäre Teams.

### 4.4 Typischer Inhalt und operative Bereitstellung

Eine NSL kann in Tabellenform geführt werden, sollte aber für den Einsatz in GIS- und Missionsplanungssystemen integriert werden. Der Quellenbeitrag nennt als typische Felder:

- geographische Koordinaten oder Grid-Position,
- Name und Beschreibung,
- Funktion,
- Kategorie beziehungsweise Typ,
- Begründung des Schutzstatus,
- Beschränkungen oder Ausnahmen,
- gegebenenfalls zeitliche Gültigkeit.

Als Beispiele taktisch oder operativ genutzter Geoinformationssysteme werden FalconView, NATO Core Geographic Services System sowie Missionsplanungs- und Waffensysteme genannt.

Für OMW folgt daraus: Die NSL darf nicht nur als PDF, Tabelle oder Kartenbild existieren. Sie muss maschinenlesbar in der Missionslogik verfügbar sein.

### 4.5 Doktrinreferenzen aus dem Quellenbeitrag

Graveyard of Empires verweist auf:

- **JP 3-09 – Joint Fire Support**,
- **CJCSI 3160.01** für den US-Prozess und die Unterscheidung NSE/NSF,
- **AJP-3.9 – Allied Joint Doctrine for Joint Targeting** für den NATO-Kontext.

Diese Referenzen werden als vom Autor genannte fachliche Ausgangspunkte dokumentiert. Vor Verwendung konkreter Verfahrensregeln muss die jeweils passende Ausgabe der Primärdokumente geprüft werden.

## 5. Methodik zur Erstellung der Afghanistan-NSL

### 5.1 Schutzkategorien

Der zweite Beitrag legt folgende übergeordnete Kategorien fest:

| Quellkategorie | Beispiele | Abbildung in NSL v1.0 |
|---|---|---|
| religiöse Stätten | Moscheen, Friedhöfe, weitere Gebets- und Kultorte | `MOS`, `CEM` |
| Bildungseinrichtungen | Schulen, Colleges, Universitäten | `EDU` |
| medizinische Einrichtungen | Krankenhäuser, Dispensaries und weitere Versorgungseinrichtungen | `MED` |
| staatliche Einrichtungen | offizielle Gebäude, Polizeistationen und weitere Behörden | `POL`, wahrscheinlich `JUS` |
| geschützte Kulturstätten | unter anderem Welterbestätten | in v1.0 ausdrücklich noch nicht enthalten |
| kritische Infrastruktur | Dämme, Kraftwerke und weitere zivile Schlüsselinfrastruktur | in v1.0 ausdrücklich noch nicht enthalten |

Die Quellmethodik nennt darüber hinaus typische beziehungsweise mögliche Kategorien wie:

- Flüchtlingslager und andere Unterkünfte für Vertriebene,
- Wasseraufbereitungsanlagen,
- Energieanlagen,
- Internetknoten,
- Anlagen erneuerbarer Energien,
- Wohngebiete,
- neutrale oder eigene Kräfte und nicht feindliche Organisationen.

Diese Kategorien sind im vorhandenen v1.0-Koordinatensatz nicht vollständig abgebildet.

### 5.2 Mögliche Datenquellen

Der Beitrag empfiehlt beziehungsweise diskutiert folgende offene und humanitäre Quellen:

- **Humanitarian Data Exchange (HDX)**, beispielsweise für Bildungs- und medizinische Einrichtungen,
- **OpenStreetMap (OSM)**, beispielsweise für Gebäude- und Objektdaten,
- **Datenbanken der Vereinten Nationen**,
- **UNESCO World Heritage Sites**,
- afghanische Regierungsdaten,
- frühere Daten der **National Statistics and Information Authority (NSIA)**,
- **Afghanistan Natural Hazards Data Center (ANHDC)**,
- Satellitenbilder,
- lokale Berichte und weitere Open-Source-Informationen.

Der Autor berichtet, dass viele früher verfügbare afghanische Regierungsdaten seit 2021 nicht mehr erreichbar seien und auch über Internetarchive nicht wiederbeschafft werden konnten. Das betrifft insbesondere als Beispiel genannte NSIA-Daten.

Für OMW gilt daher:

- Herkunft und Abrufdatum sollen bei künftigen Ergänzungen je Datensatz festgehalten werden.
- Mehrere Quellen sollen nach Möglichkeit gegeneinander geprüft werden.
- Ein Punkt ohne nachvollziehbare Einzelquelle erhält keinen hohen Vertrauensstatus.

### 5.3 GIS- und Austauschformat

Die erfassten Daten sollen in GIS-kompatiblen Formaten organisiert werden, insbesondere:

- GeoJSON,
- KML/KMZ.

CombatFlite kann KML verarbeiten. Das erklärt die Wahl einer KML/KMZ-Datei als Austausch- und Darstellungsformat neben der `.cf`-Datei.

### 5.4 Datenvalidierung

Der Beitrag beschreibt drei Validierungsebenen:

1. Koordinaten mit anderen Quellen abgleichen.
2. Prüfen, ob die Einrichtung im relevanten Zeitraum tatsächlich aktiv beziehungsweise existent ist.
3. Für DCS prüfen, ob das reale Objekt oder eine plausible Repräsentation im 3D-Modell vorhanden ist und räumlich ausreichend übereinstimmt.

Als Validierungsmittel werden unter anderem Satellitenbilder und lokale Berichte genannt.

Die DCS-bezogene Validierung wurde vom Autor ausdrücklich **noch nicht durchgeführt**, weil sich die Afghanistan-Karte zum Veröffentlichungszeitpunkt in einem frühen Entwicklungsstand befand. Ein frühzeitiger manueller Abgleich hätte nach dem nächsten Terrain-Update erneut durchgeführt werden müssen.

### 5.5 Lebender Datenbestand

Eine NSL ist laut Quellenbeitrag kein statischer Datensatz. Sie muss bei sich verändernder Konfliktlage regelmäßig geprüft werden.

Genannte Beispiele:

- Ein staatliches Gebäude kann unter eigener Kontrolle geschützt sein und nach einer gegnerischen Übernahme einer neuen Targeting-Bewertung unterliegen.
- Vertriebene Bevölkerung kann bei verschobener Frontlinie neue Unterkünfte und Schutzräume beziehen.
- Temporäre Unterkünfte können dadurch neu geschützte Bereiche werden.

Für OMW wird dieses Konzept nicht als automatische Entschutzung umgesetzt. Eine veränderte Kontrolle oder feindliche Nutzung löst eine **erneute, explizite und protokollierte Prüfung** aus. Die bloße Anwesenheit gegnerischer Kräfte hebt den Schutzstatus nicht automatisch auf.

## 6. Aussagen zur Afghanistan-NSL v1.0

### 6.1 Veröffentlichung

Der Beitrag **„NSL v1.0 for Afghanistan“** vom 26. November 2024 bezeichnet den Datensatz ausdrücklich als **initiale Version**.

Als Anhänge wurden laut Beitrag bereitgestellt:

- eine `.kml`-Datei,
- eine `.cf`-Datei.

Das dem Projekt bereitgestellte Archiv enthält eine `.kmz`- und eine `.cf`-Datei. KMZ ist die komprimierte Variante eines KML-Datensatzes.

### 6.2 Ausdrücklich fehlende Inhalte

Version 1.0 enthält nach Aussage des Autors noch nicht:

- **World Heritage Sites / Welterbestätten**,
- **critical energy infrastructures / kritische Energieinfrastrukturen**.

Eine Folgeversion mit diesen Daten wurde angekündigt.

Damit gilt verbindlich:

1. NSL v1.0 ist keine vollständige Afghanistan-NSL.
2. Welterbestätten und kritische Energieinfrastrukturen sind als bekannte Schutzdatenlücke zu behandeln.
3. Es ist zu prüfen, ob nach dem 26. November 2024 eine aktualisierte NSL-Version veröffentlicht wurde.
4. Bis dahin müssen relevante Objekte separat erfasst oder konservativ als `REVIEW_REQUIRED` behandelt werden.

### 6.3 Räumliche Beispiele aus den Abbildungen

Die vom Projektinhaber bereitgestellten Screenshots und Bildunterschriften zeigen beziehungsweise benennen:

- eine landesweite beziehungsweise regionale NSL-Darstellung für Afghanistan,
- eine hohe NSL-Dichte in besiedelten Gebieten,
- eine Nahansicht von Kandahar,
- den Raum **Sangin / Musa Qaleh / Kajaki** als weiteres Beispiel,
- eine Moschee, die von Aufständischen genutzt wurde, ohne dass anschließend eine offensive Operation gegen das geschützte Objekt erfolgte,
- die Hauptmoschee im Zentrum Kandahars als Beispiel für eine erhebliche Realwelt-/DCS-Abweichung,
- die Mirwais Mina Boys and Girls High School als Beispiel, bei dem vorhandene DCS-Gebäude als plausible Schulrepräsentation gelten können.

### 6.4 Einschluss sämtlicher Moscheen

Der Autor erklärt die hohe Dichte der Schutzpunkte insbesondere damit, dass **jede Moschee** als No-Strike-Ziel aufgenommen wurde. Dieses Vorgehen soll die während OEF, besonders während Stabilisierung und Wiederaufbau, angewendeten Regeln nachbilden.

Dem Beitrag zufolge wurden selbst Innenhöfe beziehungsweise Flächen, die für Freiluftgebete genutzt wurden, als geschützt anerkannt.

Für OMW bedeutet das:

- `MOS` ist nicht auf große oder besonders bekannte Moscheen beschränkt.
- Eine hohe Punktdichte in Städten und Dörfern ist beabsichtigt und kein Importfehler.
- Feindliche Nutzung einer Moschee führt nicht automatisch zu einem offensiven Auftrag.

### 6.5 DCS-Abgleich als notwendiger Folgeschritt

Der Autor fordert ausdrücklich, sämtliche NSL-Koordinaten nach wesentlichen Terrain-Updates gegen die tatsächliche DCS-Karte zu prüfen.

Die Beispiele zeigen zwei mögliche Ergebnisse:

| Beispiel | Realwelt-/DCS-Bewertung |
|---|---|
| Hauptmoschee im Zentrum Kandahars | an der richtigen Position steht in DCS ein Hangar statt einer Moschee; semantisch nicht passend |
| Mirwais Mina Boys and Girls High School | Gebäude sind an der Position vorhanden und können als plausible Schulrepräsentation gelten |

Daraus folgt:

- Eine korrekte WGS84-Koordinate bestätigt noch nicht, dass das Objekt in DCS korrekt dargestellt ist.
- `dcs_alignment_status` muss mindestens Lageübereinstimmung und semantische Repräsentation unterscheiden.
- Ein reales Schutzobjekt bleibt für die Missionslogik relevant, auch wenn das DCS-3D-Modell einen falschen Gebäudetyp zeigt.
- Nach relevanten Kartenupdates ist der Abgleich erneut durchzuführen.

## 7. Bereitgestelltes Archiv und technische Verifikation

### 7.1 Archiv

```text
NSL v1.0.zip
```

| Datei | Zweck | SHA-256 |
|---|---|---|
| `NSL v1.0.cf` | CombatFlite-Missions-/Referenzpunktdatei | `f3ec27c6ea9b2fdc952fa8ea692d8bd60e18b792a60580a2710b421482cd0500` |
| `NSL v1.0.kmz` | KML/KMZ-Geodaten mit den NSL-Punkten | `fc8661e5ea2f1bd54b768aaf342ce14eea6824aa0140be41eb3fdf6332bbc7b0` |

Archiv-Hash:

```text
5dc6062b8aa048401ac25e28c0c64a7de3914639ada016fb3cb3180c736f0be1
```

Zeitstempel der Dateien im ZIP-Archiv: **25. November 2024**. Der zugehörige Veröffentlichungsbeitrag erschien am **26. November 2024**. Der ZIP-Zeitstempel ist kein eigenständiger Nachweis für den fachlichen Datenstand.

### 7.2 Gesamtbestand

Die KMZ-Datei enthält **2.954 eindeutige Placemarks**. Die CombatFlite-Datei enthält **2.954 Referenzpunkte**.

Die beiden Formate stimmen vollständig überein:

- identische NSL-IDs,
- identische WGS84-Koordinaten,
- keine fehlenden oder zusätzlichen Einträge,
- keine exakten Koordinatenduplikate,
- globale Nummernfolge `0001` bis `2954` ohne Lücke oder Wiederholung.

### 7.3 Kategorien im Datensatz

| Präfix | Bedeutung | Anzahl | Anteil | Bewertungsstatus |
|---|---|---:|---:|---|
| `MOS` | Mosque / Moschee | 2.146 | 72,647 % | durch Quellenkategorie bestätigt |
| `EDU` | Education / Bildungseinrichtung | 492 | 16,655 % | durch Quellenkategorie bestätigt |
| `MED` | Medical / medizinische Einrichtung | 208 | 7,041 % | durch Quellenkategorie bestätigt |
| `POL` | Police / Polizeieinrichtung | 69 | 2,336 % | durch Quellenbeispiel bestätigt |
| `CEM` | Cemetery / Friedhof | 36 | 1,219 % | durch Quellenbeispiel bestätigt |
| `JUS` | Justice / Justizeinrichtung | 3 | 0,102 % | im staatlichen Bereich fachlich plausibel; Präfixauflösung weiterhin abgeleitet |
| **Gesamt** |  | **2.954** | **100,000 %** |  |

Beispiel-ID:

```text
NSLEDU0001
```

### 7.4 Geografische Ausdehnung

| Grenze | Wert |
|---|---:|
| nördlichster Breitengrad | `38.4672732` |
| südlichster Breitengrad | `29.4161573` |
| westlichster Längengrad | `60.5421303` |
| östlichster Längengrad | `73.3784438` |

Die Ausdehnung umfasst nahezu ganz Afghanistan und reicht über den jeweils tatsächlich modellierten oder hochdetaillierten DCS-Kartenausschnitt hinaus.

### 7.5 CombatFlite-Metadaten

Die Datei `NSL v1.0.cf` enthält intern:

```text
Theater: PersianGulf
MissionName: NEW MISSION
```

Diese generischen oder nicht bereinigten Container-Metadaten dürfen nicht zur Auswahl des DCS-Theaters oder als Missionsname übernommen werden.

Weitere Eigenschaften:

- Typ: `Other`,
- Farbe: Rot,
- `Enabled=True`,
- `Locked=True`,
- leere Kommentarfelder.

## 8. Einschränkungen und Datenrisiken

### 8.1 Punktdaten statt Objektgeometrien

Jeder Eintrag besteht nur aus einem Mittelpunkt. Es fehlen unter anderem:

- Gebäudegrundriss,
- Grundstücks- oder Campusgrenze,
- validierter Schutzradius,
- Höheninformation,
- Objektname und Adresse,
- ursprüngliche Einzelquellen-ID,
- Erfassungsdatum und Genauigkeitsangabe,
- Verifizierungsstatus und Begründung des Schutzstatus.

Ein Punkt darf nicht mit dem vollständigen räumlichen Umfang der geschützten Entität gleichgesetzt werden.

### 8.2 Keine pauschalen Schutzradien erfinden

Ein einheitlicher Radius für Moschee, Krankenhaus, Schule, Friedhof und Polizeikomplex wäre fachlich nicht belastbar.

Bis überprüfte Geometrien vorliegen:

- bleiben Schutzradien konfigurierbar,
- werden sie als projektseitige Sicherheits- und Gameplay-Parameter dokumentiert,
- dürfen sie nicht als reale rechtliche Standardabstände bezeichnet werden,
- werden wichtige Einrichtungen später möglichst als Polygon abgebildet.

### 8.3 Bekannte Vollständigkeitslücken

Version 1.0 deckt ausdrücklich nicht alle vom Autor vorgesehenen Kategorien ab. Bekannt fehlen mindestens:

- Welterbestätten,
- kritische Energieinfrastrukturen.

Aus der allgemeinen Kategoriedefinition ergeben sich weitere mögliche Lücken, beispielsweise:

- Flüchtlingslager und temporäre Unterkünfte,
- Wasseraufbereitungsanlagen,
- Stromnetze und weitere zivile Versorgungsnetze,
- Wohngebiete,
- neutrale, eigene oder nicht feindliche Entitäten,
- nicht ortsfeste NSE.

Die Abwesenheit eines Objekts in der NSL ist ausdrücklich **keine Angriffserlaubnis**.

## 9. Verbindliches OMW-Datenmodell

| Feld | Zweck |
|---|---|
| `nsl_id` | stabile Projekt-ID |
| `entity_scope` | `NSF`, `NSE` oder projektseitige Unterklasse |
| `category_code` | Quellkategorie wie `MED` |
| `category_label` | bestätigte Klartextkategorie |
| `name` / `function` | Objektname und Funktion, sofern bekannt |
| `source_version` | Quelldatenstand, zum Beispiel `NSL v1.0` |
| `source_creator` | `Graveyard of Empires` |
| `source_reference` | Patreon-Beitrag, Archivdatei und ursprüngliche Einzelquelle |
| `source_retrieved_at` | Abruf- beziehungsweise Importdatum |
| `attribution_text` | verpflichtender Credit-Hinweis |
| `latitude_wgs84` / `longitude_wgs84` | unveränderte Quellkoordinate |
| `dcs_x` / `dcs_y` | versions- und kartenbezogene DCS-Koordinate |
| `geometry_type` | `POINT_RADIUS` oder `POLYGON` |
| `protection_radius_m` | freigegebener projektseitiger Radius |
| `protection_basis` | rechtliche, humanitäre, politische oder operative Begründung |
| `restrictions` / `exceptions` | zusätzliche Beschränkungen und erforderliche Prüfungen |
| `status` | `IMPORTED`, `REVIEW_REQUIRED`, `ACTIVE`, `SUPERSEDED`, `INACTIVE` |
| `confidence` | Qualität und Verifizierungsstand |
| `effective_from` / `effective_to` | zeitliche Gültigkeit |
| `control_status` | relevante Szenario- oder Kampagnenkontrolle ohne automatische Zielentscheidung |
| `dcs_map_version` | Kartenversion des letzten Abgleichs |
| `dcs_alignment_status` | räumliche und semantische Übereinstimmung mit DCS Afghanistan |
| `notes` | Sonderregeln und Prüfnachweise |

Quellwerte und abgeleitete Werte müssen getrennt bleiben. Eine DCS-Koordinate oder DCS-Ersatzposition darf die ursprüngliche WGS84-Quelle nicht überschreiben.

## 10. MOOSE-First-Architektur

### 10.1 Vorgesehene MOOSE-Bausteine

| MOOSE-Baustein | Geplanter Zweck | Status in OMW |
|---|---|---|
| `COORDINATE:NewFromLLDD()` | WGS84 in DCS-/MOOSE-Koordinate überführen | `PLANNED` |
| `ZONE_RADIUS:New()` | vorläufige Schutzfläche um einen Punkt | `PLANNED` |
| `ZONE_BASE:IsCoordinateInZone()` | Zielkoordinate gegen Schutzfläche prüfen | `PLANNED` |
| `ZONE_RADIUS:IsVec2InZone()` | performante 2D-Prüfung | `PLANNED` |
| `ZONE_POLYGON_BASE` | validierte Objekt- oder Grundstücksumrisse | `CANDIDATE` |
| `SET_ZONE` | Verwaltung registrierter Zonen | `CANDIDATE` |

Es wurde keine MOOSE-Spezialklasse gefunden, die eine militärische No-Strike List mit Status-, Quellen-, Freigabe- und Auditlogik vollständig abbildet.

Daher gilt:

- MOOSE übernimmt Koordinaten- und Zonengeometrie.
- Eine kleine projektspezifische **NSL-Policy- und Registry-Schicht** ergänzt Quellenmetadaten, Statuswerte, räumliche Vorfilterung und Freigabeentscheidungen.
- Eine parallele eigene Geometrieimplementierung ist nicht vorgesehen.
- Vor Implementierung müssen Dokumentation, eingebundener MOOSE-Quellstand und offizielle Beispiele geprüft werden.

### 10.2 Geplanter Datenfluss

```text
freigegebene NSL-Quelldaten
→ Schema-, Hash- und Plausibilitätsprüfung
→ Filter auf DCS-Afghanistan-Abdeckung
→ WGS84-Konvertierung
→ Schutzgeometrie und räumlicher Index
→ NSLRegistry
→ CheckTarget(candidate)
     ├── CLEAR
     ├── REVIEW_REQUIRED
     ├── BLOCKED_NSL
     ├── BLOCKED_NO_ENGAGE
     └── RESTRICTED_RTL
→ nur bei positivem Ergebnis: Ziel- und Auftragserzeugung
```

Die spätere Prüffunktion soll einen nachvollziehbaren Prüfbericht liefern:

```text
result.status
result.candidateCoordinate
result.matchedNslIds
result.minimumDistanceMeters
result.appliedGeometry
result.sourceVersion
result.sourceCreator
result.dcsMapVersion
result.reason
result.checkedAt
```

## 11. Verbindliche Einbindung in die Missionsarchitektur

Vor einem offensiven Auftrag muss eine positive NSL-Prüfung erfolgt sein. Das gilt mindestens für:

- MissionGenerator und Kampagnendirektor,
- RedDirector und dynamische Camps,
- `INTEL`-Kontakte und daraus abgeleitete Zielkandidaten,
- Spieleraufträge,
- `COMMANDER`-/`AIRWING`-Zuweisungen,
- offensive `AUFTRAG`-Typen,
- FAC, AFAC, JTAC und `DESIGNATE`,
- bewaffnete UAVs,
- Artillerie und weitere Effector-Pfade.

Erkennung ist nicht gleich Angriffserlaubnis. Eine feindliche Einheit in oder nahe einer geschützten Einrichtung darf erfasst, beobachtet und gemeldet werden, wird dadurch aber nicht automatisch zu einem freigegebenen Ziel.

Mögliche nicht automatisch letale Alternativen sind:

- ISR und Überwachung,
- Absperrung,
- Verfolgung außerhalb des Schutzbereichs,
- Show of Force,
- Evakuierungs- oder Schutzaufträge,
- manuelle Lageprüfung.

## 12. Lebenszyklus und Statusänderungen

```text
IMPORTED
→ REVIEW_REQUIRED
→ ACTIVE
→ SUPERSEDED oder INACTIVE
```

Ein Quellimport wird nicht automatisch `ACTIVE`.

Eine Änderung des Schutzstatus erfordert mindestens:

- positive Identifikation,
- dokumentierte Lageänderung,
- festgelegte Freigabeautorität,
- rechtliche beziehungsweise szenariobezogene Bewertung,
- Begründung,
- zeitliche Gültigkeit,
- Auditprotokoll.

Die im Quellenbeitrag genannte Möglichkeit, ein übernommenes staatliches Gebäude neu zu bewerten, wird in OMW deshalb nicht als automatische Entschutzung umgesetzt.

## 13. Performance- und Skalierungsanforderungen

Eine lineare Prüfung aller 2.954 Einträge bei jedem Scheduler-Tick oder Sensorupdate ist zu vermeiden.

Vorgesehen sind:

1. einmaliges Laden und Validieren beim Missionsstart,
2. Filterung auf den tatsächlichen DCS-Kartenbereich,
3. räumliche Vorindizierung durch Rasterzellen oder Bounding Boxes,
4. genaue Zonenprüfung nur für verbleibende Kandidaten,
5. keine dauernde `Scan()`-Abfrage aller NSL-Zonen,
6. keine automatische Darstellung aller Punkte auf der F10-Karte,
7. Cache für wiederkehrende Prüfungen,
8. Performance-Test unter Multiplayer-Serverlast.

## 14. Qualitätssicherung

### 14.1 Importprüfung

Der Import muss mindestens prüfen:

- erwartete Dateiversion und Hash,
- Pflichtfelder und Datentypen,
- eindeutige IDs,
- gültige Koordinatenbereiche,
- bekannte Kategoriecodes,
- Anzahl je Kategorie,
- vollständige Sequenznummern,
- exakte Koordinatenduplikate,
- Abweichungen zwischen KMZ, CombatFlite und OMW-Datenquelle.

Referenzwerte:

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

### 14.2 DCS-Abgleich

Jeder überprüfte Eintrag soll mindestens einen der folgenden Status erhalten:

| Status | Bedeutung |
|---|---|
| `NOT_CHECKED` | noch kein DCS-Abgleich |
| `POSITION_AND_TYPE_MATCH` | Position und Objekttyp sind plausibel |
| `POSITION_MATCH_TYPE_MISMATCH` | Position stimmt, DCS-Gebäudetyp ist semantisch falsch |
| `POSITION_OFFSET` | DCS-Repräsentation liegt versetzt |
| `NO_DCS_REPRESENTATION` | keine geeignete Darstellung vorhanden |
| `OUTSIDE_SUPPORTED_MAP_AREA` | außerhalb des nutzbaren Kartenbereichs |
| `RECHECK_AFTER_MAP_UPDATE` | nach Kartenupdate erneut prüfen |

### 14.3 DCS-/MOOSE-Testfälle

Mindestens zu testen:

1. WGS84-Konvertierung mehrerer Kartenregionen.
2. Vergleich mit CombatFlite/KMZ und DCS-Karte.
3. Ziel im Mittelpunkt: `BLOCKED_NSL`.
4. Ziel auf der Grenze: definierte Randregel.
5. Ziel knapp außerhalb: `CLEAR` oder `REVIEW_REQUIRED`.
6. Gruppe mit nur teilweise schneidender Geometrie.
7. bewegliches Ziel betritt die Schutzfläche nach Auftragserzeugung.
8. erneute Prüfung unmittelbar vor Wirkung.
9. fehlende oder beschädigte NSL-Datei führt für automatische Angriffe zu Fail-Closed.
10. Multiplayer-Performance und Neustart/Persistenz.
11. Moschee wird von Gegnern genutzt: keine automatische Entschutzung.
12. Position stimmt, DCS-Gebäudetyp ist falsch: Schutzprüfung bleibt wirksam.
13. temporäres Lager für Vertriebene wird als neuer Schutzbereich aktiviert.

### 14.4 Acceptance-Kriterien

Die NSL-Funktion gilt erst als `VALIDATED`, wenn:

- der verwendete MOOSE-Stand dokumentiert ist,
- Signaturen im eingebundenen Quellstand bestätigt sind,
- die Afghanistan-Konvertierung in DCS geprüft wurde,
- die verwendete DCS-Kartenversion dokumentiert ist,
- alle Zielerzeugungspfade die zentrale NSL-Prüfung verwenden,
- positive und negative Testfälle reproduzierbar bestanden sind,
- Fail-Closed-Verhalten und Performance getestet sind,
- ein Acceptance-Bericht und Eintrag in `docs/moose/VERIFIED-METHODS.md` vorliegen.

## 15. Offene Entscheidungen und Quellenaufgaben

Die drei Patreon-Volltexte sind vollständig erfasst. Offen bleiben:

1. konkreten Veröffentlichungsumfang der ursprünglichen `.cf`-, `.kml`-/`.kmz`-Dateien als `PUBLIC`, `INTERNAL` oder `MISSION_PACKAGE_ONLY` dokumentieren,
2. Prüfung, ob Graveyard of Empires eine spätere NSL-Version mit Welterbestätten und Energieinfrastruktur veröffentlicht hat,
3. Ermittlung der ursprünglichen Einzelquelle je Punkt, soweit möglich,
4. abschließende Bestätigung der Bedeutung des Präfixes `JUS`,
5. Filterung auf die tatsächlich nutzbare DCS-Afghanistan-Karte,
6. vollständiger DCS-Abgleich gegen eine dokumentierte Kartenversion,
7. Ergänzung fehlender Schutzkategorien,
8. Kategorie- oder objektspezifische Interimsschutzradien,
9. Auswahl wichtiger Objekte für Polygonerfassung,
10. Modellierung nicht ortsfester No-Strike Entities,
11. Freigabeautorität für Statusänderungen,
12. Darstellung in F10-Menü, Briefing und Rollenansichten,
13. Aktualisierungsintervall, Versionierung und Performancebudget.

## 16. Nächste Arbeitspakete

### NSL-01 – Attribution und Veröffentlichungsumfang

- Credit „Graveyard of Empires“ verbindlich führen.
- Projektmanagerentscheidung zum konkreten Ablage- und Veröffentlichungsumfang der Originaldateien dokumentieren.
- Eine fehlende ausdrückliche Lizenzbezeichnung nicht als Implementierungsblocker behandeln.
- Später bekannt werdende konkrete entgegenstehende Nutzungsbedingungen prüfen und erforderlichenfalls umsetzen.

### NSL-02 – Folgeveröffentlichungen und Quellenregister

- Patreon nach einer aktualisierten NSL-Version durchsuchen,
- World-Heritage- und Energieinfrastruktur-Ergänzungen sichern,
- Quellenregister für HDX, OSM, UN/UNESCO, ANHDC und weitere Datensätze aufbauen,
- Quelllizenz und Abrufdatum je Import dokumentieren.

### NSL-03 – DCS-Kartenabgleich

- Punkte gegen die aktuelle DCS-Afghanistan-Abdeckung prüfen,
- Kandahar-Moschee und Mirwais-Mina-Schule als dokumentierte Referenzfälle verwenden,
- Stichproben in Kandahar und Sangin/Musa Qaleh/Kajaki durchführen,
- Abweichungen und nicht modellierte Orte kennzeichnen,
- Kartenversion und Prüfdatum festhalten.

### NSL-04 – Schutzgeometrien

- Interimsschutzradien fachlich festlegen,
- priorisierte Krankenhäuser, Schulen, religiöse und kulturelle Großobjekte als Polygon erfassen,
- Rand- und Pufferregeln definieren.

### NSL-05 – MOOSE-Prototyp

- eingebundene MOOSE-Version bestimmen,
- `COORDINATE:NewFromLLDD()`, `ZONE_RADIUS:New()` und `IsCoordinateInZone()` verifizieren,
- minimalen Import- und Prüfprototyp erstellen.

### NSL-06 – Architektur-Integration

- zentralen Check in MissionGenerator, Player Tasks und AI-Auftragserzeugung einbauen,
- Auditlogging und Fail-Closed-Verhalten ergänzen,
- Testmission und Acceptance-Bericht erstellen.

## 17. Referenzen

### Primärquelle und Credit

- [Graveyard of Empires](https://www.patreon.com/cw/graveyard4DCS)
- [No Strike List](https://www.patreon.com/graveyard4DCS/posts/no-strike-list-116305895?collection=833534)
- [Creating our own NSL for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/creating-our-own-116671166?collection=833534)
- [NSL v1.0 for Afghanistan](https://www.patreon.com/graveyard4DCS/posts/nsl-v1-0-for-116676047?collection=833534)

### Vom Autor genannte Doktrin- und Datenreferenzen

- JP 3-09 – Joint Fire Support
- CJCSI 3160.01
- AJP-3.9 – Allied Joint Doctrine for Joint Targeting
- Humanitarian Data Exchange
- OpenStreetMap
- Datenbanken der Vereinten Nationen und UNESCO
- National Statistics and Information Authority
- Afghanistan Natural Hazards Data Center

### Projektquellen

- [OMW-GOV-SOURCE-USE – zentrale Quellen-, Datei- und Veröffentlichungsregel](sources/graveyard-of-empires.md)
- [OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE – NSL-spezifische Datenverwendung](targeting/afghanistan-nsl-data-use-policy.md)
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