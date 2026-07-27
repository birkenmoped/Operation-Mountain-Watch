# Air C2 und Close Air Support in Afghanistan

## 1. Status, Zweck und Quellenlage

**Dokumentstatus:** `SOURCE_CAPTURE_COMPLETE`

**Primärquellenstatus:** `GOE_POST_VERIFIED` für Teil 1, Teil 2 und Teil 3

Dieses Dokument übernimmt und strukturiert die dreiteilige Patreon-Reihe **Who's in Charge? Air C2 and Close Air Support in Afghanistan** von **Graveyard of Empires**. Es beschreibt die in der Reihe dargestellten Rollen, Führungsstellen, Kommunikationswege, CAS-Anforderungsverfahren, Reibungsverluste, Lehren aus Operation ANACONDA und die vom Autor vorgeschlagenen Ansätze für DCS-World-Missionen.

Die drei Beiträge liegen als vollständige Druck-PDFs vor und wurden einschließlich der enthaltenen Abbildungen, Diagramme, Bildunterschriften, Verweise und Anlagenhinweise ausgewertet.

| Teil | Datum | Umfang | Status |
|---|---:|---:|---|
| [1/3](https://www.patreon.com/graveyard4DCS/posts/whos-in-charge-1-127794463?collection=1451906) | 6. Mai 2025 | 10 PDF-Seiten | `GOE_POST_VERIFIED` |
| [2/3](https://www.patreon.com/graveyard4DCS/posts/whos-in-charge-2-127798624?collection=1451906) | 10. Mai 2025 | 8 PDF-Seiten | `GOE_POST_VERIFIED` |
| [3/3](https://www.patreon.com/graveyard4DCS/posts/whos-in-charge-3-128190337?collection=1451906) | 15. Mai 2025 | 8 PDF-Seiten | `GOE_POST_VERIFIED` |

Die in den Druck-PDFs nach dem eigentlichen Beitrag folgenden Patreon-Empfehlungen, Produktwerbung, Kommentare und Seitennavigation sind nicht Bestandteil der fachlichen Auswertung.

---

## 2. Credits und Urheberschaft

**Sämtliche Credits für Themenauswahl, Quellenerschließung, Zusammenstellung, Einordnung und ursprüngliche Aufbereitung gehen an:**

[**Graveyard of Empires**](https://www.patreon.com/cw/graveyard4DCS)

Das Projekt **Operation Mountain Watch** beansprucht keine Urheberschaft an der von *Graveyard of Empires* geleisteten Recherche- und Aufbereitungsarbeit.

Der Autor beschreibt den eigenen Ansatz ausdrücklich als Open-Source-Recherche:

> **All the information presented here come from open sources.**

Daraus folgt für dieses Projekt:

- Die Patreon-Beiträge sind als kuratierte Primärdarstellung von *Graveyard of Empires* zu behandeln.
- Die darin genannten oder verlinkten offenen Originalquellen dürfen zusätzlich geprüft und dokumentiert werden.
- Eine eigenständige Quellenprüfung ersetzt nicht den Credit an *Graveyard of Empires* für Auswahl und Zusammenstellung.
- Patreon-Inhalt, Originalquelle, unabhängige Recherche und eigene Projektableitung bleiben getrennt gekennzeichnet.

---

## 3. Verbindliche Quellenkategorien

| Kennzeichnung | Bedeutung |
|---|---|
| `GOE_POST_VERIFIED` | Aussage oder Darstellung wurde direkt in einem der drei vollständigen Patreon-Beiträge geprüft. |
| `ORIGINAL_SOURCE_VERIFIED` | Eine vom Beitrag verwendete oder verlinkte offene Originalquelle wurde eindeutig identifiziert und inhaltlich geprüft. |
| `INDEPENDENT_RESEARCH` | Relevante offene Quelle, deren konkrete Verwendung im Patreon-Beitrag nicht belegt ist. |
| `PROJECT_INFERENCE` | Eigene Schlussfolgerung oder Umsetzungsidee für **Operation Mountain Watch**. |
| `PENDING` | Inhalt, Zuordnung oder externe Quelle ist noch nicht vollständig geprüft. |

Die Abschnitte 4 bis 11 sind, soweit nicht anders gekennzeichnet, `GOE_POST_VERIFIED`.

---

## 4. Grundthese der Reihe: CAS ist ein Führungs- und Koordinationsproblem

Die Reihe stellt Close Air Support im afghanischen COIN-Umfeld nicht primär als Frage verfügbarer Feuerkraft dar. Entscheidend sind:

- der richtige Luftfahrzeugtyp,
- am richtigen Ort,
- zum richtigen Zeitpunkt,
- mit einer belastbaren Freund- und Feindlage,
- unter klarer Luftraumkontrolle,
- mit funktionierenden Kommunikations- und Entscheidungswegen.

Die sichtbare Endphase einer CAS-Mission - Check-in, 9-Line, Zielansprache und `CLEARED HOT` - ist nur das letzte Glied einer längeren Kette. Hinter dem einzelnen Angriff stehen Planung, Anforderung, Validierung, Priorisierung, Asset-Auswahl, Luftraumdekonfliktion, Routing und Übergaben.

Die Reihe nutzt Operation ANACONDA als frühes Gegenbeispiel: Zahlreiche Luftfahrzeuge waren verfügbar, aber eine belastbare taktische C2-Struktur, ein gemeinsamer Luftraumplan und eindeutig zugewiesene Kommunikationswege fehlten teilweise. Dadurch mussten einzelne Besatzungen Aufgaben übernehmen, die nicht ihrer vorgesehenen Rolle entsprachen.

---

## 5. Die wesentlichen Akteure und ihre Aufgaben

### 5.1 Funktionskette

Die in der Reihe dargestellte CAS-Kette lässt sich funktional wie folgt zusammenfassen:

```text
Bodeneinheit / Troops in Contact
        ↓
JTAC / TACP
        ↓
TOC - Tactical Operations Center
        ↓
ASOC - Air Support Operations Center / Fighter Duty Officer
        ↓
CRC oder AWACS
        ↓
Aircrew
        ↓
Übergabe an JTAC zur Terminal Control
        ↓
9-Line, Freigabe, Angriff, Wirkungskontrolle
```

Das **CAOC** bildet den übergeordneten Planungs- und Genehmigungsrahmen für ATO, ACO und Änderungen außerhalb der laufenden taktischen Zuweisung.

### 5.2 JTAC - Joint Terminal Attack Controller

Der JTAC ist die bodengebundene Stelle, die direkt mit dem CAS-Luftfahrzeug spricht und die terminale Angriffskontrolle ausübt.

Die Reihe ordnet dem JTAC insbesondere folgende Aufgaben zu:

- Zielinformationen bereitstellen,
- Positionen eigener Kräfte bestätigen,
- den Angriff mit der 9-Line strukturieren,
- die finale Waffenfreigabe `CLEARED HOT` erteilen,
- als Bestandteil einer TACP oder eingebettet bei einer Bodeneinheit arbeiten,
- alternativ von einer befestigten Stellung oder einem FOB aus operieren.

Der JTAC ist damit die Spitze der Luftunterstützungskette, aber nicht die Stelle, die theaterweit Luftfahrzeuge disponiert oder den gesamten Luftraum verwaltet.

### 5.3 TACP - Tactical Air Control Party

JTACs sind häufig Teil einer TACP. Die TACP stellt die Verbindung zwischen Bodenführung und Luftunterstützung her. Die Reihe behandelt sie als das fachliche Luft-Boden-Element innerhalb oder in unmittelbarer Nähe der Bodenorganisation.

### 5.4 TOC - Tactical Operations Center

Das TOC ist der Gefechtsstand eines Bataillons, einer Brigade oder einer höheren Heeresformation. Es führt und koordiniert den Bodenkampf und hält das taktische Lagebild.

Aufgaben im Zusammenhang mit CAS:

- Unterstützungsbedarf aus der Bodenoperation erfassen,
- JTAR beziehungsweise ASR entgegennehmen,
- Anforderung validieren und priorisieren,
- Freundlage, Zielraum und Operationsabsicht einordnen,
- CAS-Anforderung an das ASOC weitergeben,
- Statusinformationen an JTAC und Bodenführung zurückmelden,
- Feuerunterstützung, Logistik und Bodenbewegungen mitbetrachten.

Das TOC führt die Bodenoperation. Es verwaltet Luftfahrzeuge nicht unmittelbar.

### 5.5 ASOC - Air Support Operations Center

Das ASOC ist der taktische C2-Knoten zur Verknüpfung der Anforderungen des Bodenkommandeurs mit den verfügbaren Luftstreitkräften. Es befindet sich typischerweise beim höheren Heeresgefechtsstand auf Korps- oder Divisionsebene.

Für die spätere OEF-Struktur beschreibt die Reihe ein ASOC in Kabul, das zusammen mit dem Combined Joint Task Force Headquarters die CAS-Unterstützung über Afghanistan koordinierte.

Aufgaben:

- Anforderungen aus TOCs beziehungsweise von JTACs übernehmen,
- gleichzeitige Anforderungen priorisieren,
- geeignete Luftfahrzeuge auswählen,
- verbleibende Einsatzzeit beziehungsweise `playtime`, Kraftstoff und Bewaffnung berücksichtigen,
- laufende ATO-Aufträge und Re-Tasking-Möglichkeiten bewerten,
- mit dem CAOC koordinieren,
- CRC oder AWACS mit der Zuführung des ausgewählten Luftfahrzeugs beauftragen.

### 5.6 FDO - Fighter Duty Officer

Der Fighter Duty Officer arbeitet im ASOC und disponiert die verfügbaren Luftfahrzeuge in Echtzeit.

Zu den in der Reihe genannten Bewertungsfaktoren gehören:

- Priorität der Anforderung,
- Gefahr für eigene Kräfte,
- Position und Entfernung geeigneter Assets,
- Kraftstoff,
- Bewaffnung,
- verbleibende Einsatzzeit,
- aktuelle Mission,
- Möglichkeiten zur Umleitung,
- Luftraumkonflikte.

### 5.7 CRC - Control and Reporting Center

Ein CRC ist ein bodengebundener Radar- und Air-Battle-Management-Knoten. Es verwaltet einen definierten Luftraumsektor beziehungsweise eine Battle Management Area.

Aufgaben:

- Luftfahrzeuge erfassen und identifizieren,
- taktische Kontrolle übernehmen,
- Luftraum staffeln und dekonfliktieren,
- No-Fly Areas und Restricted Fire Areas berücksichtigen,
- Tasking-Informationen vom ASOC an die Aircrew weitergeben,
- Luftfahrzeuge an weitere Controller oder den JTAC übergeben.

Als Beispiele für OEF nennt die Reihe:

- `CROWBAR` - RAF, westliches Afghanistan,
- `TAIPAN` - RAAF, zentrales und östliches Afghanistan.

Die auf PDF-Seite 6 von Teil 1 gezeigte BMA-Karte unterscheidet eine Western BMA unter `CROWBAR`, eine Central BMA unter `TAIPAN` und eine Northeastern BMA unter `TAIPAN`, zeitweise ergänzt durch `WIZARD`.

### 5.8 AWACS - Airborne Warning and Control System

Das AWACS wird als fliegendes Gegenstück zum CRC beschrieben. Als Beispiel dient die E-3 Sentry mit dem Rufzeichen `WIZARD`.

Funktionen:

- weiträumige Radarüberwachung,
- Funkrelais über schwierigem Gelände,
- Führung und Staffelung von Luftfahrzeugen,
- Verwaltung von Stacks und Killbox-Zuführungen,
- Übergabe an JTACs,
- Ergänzung bodengebundener Radar- und Funkabdeckung.

Die Reihe nennt als beispielhaftes tägliches Einsatzfenster für `WIZARD` `1100-1900Z`. Außerhalb einer AWACS-Abdeckung übernahmen die CRCs die Luftkontrolle.

### 5.9 Aircrews - Kampfflugzeuge, Hubschrauber, UAV und ISR

Die Aircrews führen die eigentliche Mission aus. Genannt werden:

- Strike Fighter,
- A-10,
- Kampfhubschrauber,
- UAV,
- ISR-Plattformen,
- AC-130 Gunships,
- Bomber in den ANACONDA-Beispielen.

Vor dem Zielraum erfolgt der Check-in bei CRC oder AWACS. Danach wird das Luftfahrzeug an den JTAC übergeben. Bestimmte Luftfahrzeuge und Besatzungen - insbesondere A-10 - können FAC(A)-Aufgaben übernehmen, wenn JTACs überlastet oder nicht verfügbar sind.

### 5.10 CAOC - Combined Air Operations Center

Das CAOC führt die übergeordnete Luftkampagne.

In der Reihe genannte Aufgaben:

- Air Tasking Order erstellen,
- Airspace Control Order erstellen,
- theaterweite Luftoperationen planen,
- Luftfahrzeuge, Zeiten und Bewaffnung in der ATO festlegen,
- größere Änderungen und Re-Taskings außerhalb des laufenden ATO-Rahmens genehmigen,
- mit dem ASOC zusammenarbeiten.

Teil 1 beschreibt das CAOC der späteren OEF-Struktur in **Al Udeid, Katar**. Teil 3 beschreibt für die frühe Operation ANACONDA im März 2002 die direkte Weiterleitung von CAS-Anforderungen an ein CAOC in **Saudi-Arabien**. Diese Angaben werden als unterschiedliche zeitliche Phasen der OEF-C2-Struktur dokumentiert und nicht miteinander vermischt.

---

## 6. CAS-Anforderungsverfahren

### 6.1 JTAR beziehungsweise ASR

Der `Joint Tactical Air Request (JTAR)` beziehungsweise `Air Support Request (ASR)` transportiert den Unterstützungsbedarf durch die Führungsorganisation.

Die Reihe unterscheidet zwei Arten:

1. **Pre-Planned Request**
2. **Immediate Request**

Der JTAR ist nicht mit der späteren 9-Line gleichzusetzen:

- Der JTAR fordert Luftunterstützung an und bewegt die Anforderung durch TOC, ASOC und übergeordnete Planung.
- Die 9-Line dient der terminalen Angriffskontrolle zwischen JTAC und bereits zugewiesenem Luftfahrzeug.

Auf PDF-Seite 2 von Teil 2 wird ein leeres `Joint Tactical Air Strike Request`-Formular gezeigt.

### 6.2 Pre-Planned CAS

Vorab geplante CAS-Unterstützung wird während der Missionsplanung vorbereitet, etwa für:

- Raids,
- Patrouillen mit erhöhtem Risiko,
- Konvois durch bekannte Feindräume,
- andere Operationen mit erwartetem Unterstützungsbedarf.

Der beschriebene Ablauf:

- JTAC beziehungsweise Planungsstab trägt erwarteten Zielraum, Zeit und gewünschte Wirkung ein.
- Der Antrag wird über taktische Kommunikationssysteme an das TOC weitergegeben.
- Die Anforderung fließt in die übergeordnete Luftplanung ein.
- Das CAOC kann im ATO ein CAS-Zeitfenster vorsehen und Luftfahrzeuge für eine bestimmte Station-Zeit reservieren.

Pre-Planned CAS ist planbar und in die Bodenoperation integriert, bleibt aber hinsichtlich der konkreten Zielzuweisung flexibel.

### 6.3 Immediate CAS und TIC

Immediate CAS entsteht bei einer unerwarteten Gefährdung, häufig zusammen mit einer `Troops in Contact (TIC)`-Meldung.

Der in Teil 2 beschriebene Ablauf:

```text
JTAC meldet TIC über Funk
        ↓
JTAC erstellt parallel den Immediate JTAR
        ↓
Koordinaten und Priorität werden präzisiert
        ↓
TOC übermittelt den Antrag über taktischen Chat
        ↓
ASOC sucht verfügbare oder umleitbare Luftfahrzeuge
        ↓
FDO weist ein geeignetes Asset zu
```

Bei hoher Priorität kann ein bereits im Gebiet befindliches oder auf einer anderen Mission eingesetztes Luftfahrzeug innerhalb weniger Minuten umgeleitet werden.

### 6.4 Validierung im TOC

Vor der Weitergabe müssen insbesondere geklärt sein:

- präzise Zielkoordinaten,
- bestätigte Positionen eigener Kräfte,
- Priorität,
- Zielbeschreibung,
- gewünschte Wirkung,
- betroffene Luftraummaßnahmen.

Ein unvollständiger oder unklarer JTAR kann selbst während eines TIC angehalten werden, bis die fehlenden Angaben geklärt sind.

### 6.5 Auswahl eines Luftfahrzeugs im ASOC

Teil 2 nennt drei wesentliche Asset-Quellen:

1. **X-CAS / Air-Alert CAS**  
   Bereits fliegende Luftfahrzeuge mit ausreichendem Kraftstoff und geeigneter Bewaffnung.

2. **G-CAS / Ground-Alert CAS**  
   Flugzeuge oder Hubschrauber in Bodenbereitschaft, beispielsweise in Kandahar oder Bagram.

3. **Re-Tasking**  
   Luftfahrzeuge auf weniger priorisierten Missionen, die zur dringenderen CAS-Anforderung umgeleitet werden können.

Das ASOC in Kabul wird als Stelle mit Echtzeitübersicht über Luftfahrzeuge auf Station und deren ATO-Aufträge beschrieben. Für Änderungen außerhalb des bestehenden ATO konnte eine Abstimmung mit dem CAOC erforderlich sein.

### 6.6 Zuführung durch CRC oder AWACS

Nach der Asset-Auswahl übergibt das ASOC das Tasking an die zuständige Kontrollstelle.

CRC oder AWACS übermitteln der Aircrew:

- Routing zum Einsatzraum,
- JTAC-Rufzeichen,
- Check-in-Frequenz,
- Killbox- oder Sektorgrenzen,
- weitere Airspace Control Measures,
- gegebenenfalls CGRS-Bezug,
- Vorgaben zur sicheren Kommunikation.

### 6.7 Übergabe an den JTAC

Erst beim Erreichen des Terminal Area wird das Luftfahrzeug an den JTAC übergeben. Dann beginnt die sichtbare CAS-Endphase:

```text
CAS Check-in
→ Lageabgleich
→ 9-Line
→ Remarks und Restrictions
→ Readback
→ Talk-on oder Markierung
→ Angriffsfreigabe
→ Waffenwirkung
→ BDA oder Re-Attack
```

---

## 7. Kommunikation und Informationsaustausch

### 7.1 Sprache und taktischer Chat

Während OEF wurden Sprache und Text parallel verwendet.

**Sprachverbindungen:**

- VHF,
- UHF,
- Ground Net,
- Controller-to-Aircraft,
- JTAC-to-Aircraft,
- Check-in und 9-Line.

**Taktische Chat-Systeme:**

- mIRC-basierte Räume,
- CENTRIX,
- JADOCS.

Über Chat wurden insbesondere JTARs, Koordinaten, Prioritäten und Strike-Details formal weitergegeben. Teil 2 zitiert dazu AFCEA SIGNAL mit der Kernaussage:

> **Chat was everything in Afghanistan.**

### 7.2 Typische Teilnehmer eines Chat-Verbunds

- JTAC,
- TOC Battle Captain,
- ASOC Fighter Duty Officer,
- CRC- beziehungsweise AWACS-Besatzung,
- Intelligence Officers.

Dadurch konnten mehrere Stellen denselben Vorgang nahezu in Echtzeit verfolgen, auch über große Entfernungen innerhalb Afghanistans.

Auf PDF-Seite 3 von Teil 2 zeigt die Reihe ein Diagramm der ISAF-Netze mit Verbindungen zwischen FOC-, NATO-, CENTRIX-ISAF- und UK-Overtask-Strukturen.

### 7.3 Secure Voice

Für sensible Missionsdaten wurden verschlüsselte Sprachverbindungen verwendet. Die Reihe nennt die Aufforderungen:

- `GO SECURE`,
- `GO GREEN`.

Als Gerätebeispiel wird das `KY-58 Secure Voice Module` gezeigt. Die Bildunterschrift erläutert:

- `P` = Plain beziehungsweise Red,
- `C` = Ciphered beziehungsweise Green/Secure,
- Schalterstellungen 1 bis 6 = Auswahl des Schlüssels.

### 7.4 Kommunikation als Hauptquelle operativer Reibung

Die Reihe betont, dass Reibung häufig nicht durch fehlende Luftfahrzeuge, sondern durch Kommunikationsprobleme entsteht:

- schlechte Relais,
- unklare Prioritäten,
- unterbrochene Führungswege,
- fehlende oder falsche Frequenzzuweisungen,
- Geländeabschattung,
- fehlendes gemeinsames Lagebild.

---

## 8. Typische Reibungsverluste im CAS-Prozess

### 8.1 Unvollständige Anforderung

Verzögerungsgründe:

- ungenaue Koordinaten,
- unklare Freundpositionen,
- fehlende Priorität,
- unklare Zielbeschreibung,
- fehlende gewünschte Wirkung.

### 8.2 Mehrere gleichzeitige CAS-Anforderungen

Bei konkurrierenden TICs muss das ASOC triagieren. Die Reihe nennt als Kriterien:

- wer unmittelbar gefährdet ist,
- Nähe eigener Kräfte zum Ziel,
- Sicht- und Identifikationsbedingungen,
- verfügbare geeignete Assets,
- erwartete Reaktionszeit.

Nicht jede Einheit erhält deshalb sofort Unterstützung.

### 8.3 Fehlende Luftfachkompetenz im TOC

TOCs ohne erfahrenes Luftpersonal beziehungsweise Air Liaison Officer können übersehen:

- Luftraumkonflikte,
- Restricted Operating Zones,
- andere Airspace Control Measures,
- ungeeignete Frequenzen,
- nicht passende Bewaffnung.

Auch ein formal guter JTAR kann dadurch abgelehnt oder verzögert werden.

### 8.4 Bewährte Anpassungen erfahrener JTACs

- JTARs für wahrscheinliche Zielräume oder Killboxes vorbereiten,
- Chat-Templates verwenden,
- Koordinaten und Freundlagen vorab eintragen,
- Ground-FM, Aircraft-UHF und Chat gleichzeitig überwachen,
- Statusmeldungen laufend aktualisieren.

---

## 9. Operation ANACONDA als C2-Fallstudie

### 9.1 Operationsraum und Kräfte

Operation ANACONDA fand im März 2002 im Shah-i-Kot Valley nahe der pakistanischen Grenze statt. Der Raum lag abseits großer Straßen und enthielt nach der dargestellten Feindlage eine erhebliche Konzentration von Al-Qaida- und Taliban-Kräften.

Beteiligt waren laut Reihe:

- konventionelle Kräfte der 10th Mountain Division,
- 101st Airborne Division,
- Special Operations Forces,
- afghanische Kräfte,
- zahlreiche Luftfahrzeugtypen.

Die auf PDF-Seite 2 von Teil 3 gezeigte Karte markiert unter anderem:

- Lower Shah-i-Kot Valley,
- Upper Shah-i-Kot Valley,
- `THE WHALE`,
- `GINGER`,
- Gardez und Zurmat,
- Höhen- und Entfernungsangaben im Einsatzraum.

### 9.2 Fehlende taktische C2-Struktur

Die schnelle Entwicklung von SOF-geführten Einsätzen zu einer größeren konventionellen Operation überholte nach Darstellung der Reihe den Aufbau robuster C2-Strukturen.

Besonders schwerwiegend:

- kein einsatzbereites ASOC zu Beginn der Operation,
- CAS-Anforderungen mussten direkt an das weit entfernte CAOC in Saudi-Arabien geleitet werden,
- Verzögerungen und Kommunikationsabbrüche,
- kein einheitlicher Luftraumkontrollplan,
- überlasteter und unübersichtlicher Luftraum,
- erhöhtes Fratricide- und Kollisionsrisiko.

### 9.3 Erfahrungen von Capt. Scott Campbell

Die Reihe gibt einen längeren Erfahrungsbericht des A-10-Piloten Capt. Scott Campbell wieder. Die wesentlichen Punkte:

- AWACS konnte keine ausreichende Lageinformation liefern.
- Es gab kein ASOC als Ansprechpartner.
- Die ausgegebenen Frequenzlisten enthielten zahlreiche TAD-Frequenzen, aber keine eindeutige Zuordnung.
- Die Besatzung suchte nacheinander Frequenzen ab.
- Auf einer Frequenz forderten drei Stellen gleichzeitig CAS an.
- Niemand hatte eine Priorität festgelegt.
- Campbell musste selbst entscheiden, wen er zuerst unterstützte.

Die Piloten übernahmen dadurch faktisch FAC(A)- und Airspace-Management-Aufgaben, obwohl dies nicht ihr ursprünglicher Auftrag war.

### 9.4 Gefährliche Luftraumkonflikte

Die Reihe beschreibt einen weiteren Vorfall:

- `SPARTAN`, ein britisches AWACS, meldete einen eingehenden B-52-TST-Angriff.
- Die B-52 mit dem Rufzeichen `CUJO` war ungefähr zehn Minuten vor dem Ziel und sollte eine Folge von 2.000-lb-JDAMs abwerfen.
- Die geplante Bomb Fall Line verlief durch den Orbit einer darunter fliegenden AC-130.
- Die A-10-Besatzung ließ den Bomber den Angriff abbrechen beziehungsweise neu ausrichten und verlegte das Gunship, um den Angriff zu dekonfliktieren.

Die Reihe nennt außerdem Situationen, in denen ein A-10-Pilot mehreren Luftfahrzeugen und fallenden Bomben ausweichen musste.

### 9.5 Eingesetzte Luftmittel

Genannt werden:

- A-10,
- F-15E,
- AC-130,
- B-52,
- Kampfhubschrauber,
- UAV und weitere Luftmittel.

Trotz erheblicher C2-Probleme trugen Anpassungsfähigkeit und Professionalität der Besatzungen wesentlich zum Ausgang der Operation bei.

### 9.6 Lehren aus ANACONDA

Die Reihe leitet drei zentrale Lehren ab:

1. **Dauerhaftes ASOC etablieren**  
   Die fehlende ASOC-Funktion verursachte wesentliche Koordinationsprobleme. Für spätere Operationen wurde eine permanente ASOC-Struktur geschaffen.

2. **Einheitliches Airspace Management**  
   Ein kohärenter Luftraumkontrollplan ist erforderlich, um Überlastung, Konflikte und Fratricide-Risiko zu reduzieren.

3. **Zuverlässige und redundante Kommunikation**  
   Gemeinsame taktische Chat-Systeme, die alle C2-Akteure verbinden, erwiesen sich gegenüber einer Kette isolierter Funk- und Telefonverbindungen als entscheidende Verbesserung.

---

## 10. Vom Autor vorgeschlagene Umsetzung in DCS World

Dieser Abschnitt dokumentiert die in Teil 3 ausdrücklich genannten Vorschläge von *Graveyard of Empires*. Es handelt sich noch nicht automatisch um verbindliche technische Entscheidungen für **Operation Mountain Watch**.

### 10.1 Nicht jede reale Führungsebene vollständig nachbilden

Der Autor empfiehlt, nicht jede reale Ebene eins zu eins zu simulieren. Stattdessen sollen die Elemente übernommen werden, die:

- Struktur vermitteln,
- Reibung erzeugen,
- Entscheidungen erfordern,
- CAS als erarbeitete Unterstützung erscheinen lassen,
- Spieler nicht mit unnötiger Komplexität überlasten.

### 10.2 Boden-C2 mit JTAC, TOC und ASOC

Vorgeschlagen werden:

- JTAR als Beschreibung der taktischen Lage bei Pre-Planned CAS,
- zusätzliche Koordinationsschicht zwischen Spieler und JTAC,
- simulierte TOCs, beispielsweise:
  - `WIDOW TOC` - britische Kräfte in Helmand,
  - `SLAYER TOC` - kanadische Kräfte in Kandahar.

Das simulierte TOC soll:

- die Bodenlage zusammenfassen,
- Prioritäten des Bodenkommandeurs mitteilen,
- den Spieler an einen zuständigen JTAC übergeben.

Als weitergehendes Skriptbeispiel nennt der Autor eine ASOC-Funktion, die:

- Ereignisse beziehungsweise Feinde in der Nähe vorhandener freundlicher JTACs erzeugt,
- in einer Multiplayer-Umgebung das geeignetste Asset auswählt,
- dabei Entfernung, Kraftstoff und Waffenstatus berücksichtigt.

### 10.3 CRC und Battle Management Areas

Vorschläge zur CRC-Simulation:

- BMA-Sektoren mit Zonen und Triggern abbilden,
- einfache Funksprüche für CRC-Handoffs vorbereiten,
- detailliertere Taskings zusätzlich als Textmeldung ausgeben,
- CGRS-Grids für realistischere Aufgabenübermittlung verwenden,
- Hintergrundfunk auf CRC-Frequenzen einsetzen.

Die BMA-Karte aus Teil 1 kann dabei als konzeptionelle Vorlage dienen.

### 10.4 Verantwortlichkeit bei fehlendem CRC oder AWACS

Ist weder CRC noch AWACS verfügbar, muss die Luftraumdekonfliktion ausdrücklich einer Stelle zugewiesen werden.

Die Reihe nennt:

- normalerweise den JTAC,
- alternativ einen erfahrenen Multiplayer-Spieler.

Die Verantwortung darf nicht implizit unbesetzt bleiben.

### 10.5 Funkreichweite, Gelände und Relais

DCS-Missionen können Geländeabschattung und eingeschränkte Reichweiten simulieren, indem Luftfahrzeuge Informationen über andere Assets weiterleiten müssen.

Als reales Beispiel nennt die Reihe Westafghanistan, insbesondere Farah und Herat. Dort sei die Funkabdeckung teilweise so schlecht gewesen, dass Luftfahrzeuge mehr als 150 NM zurückfliegen mussten, um wieder Kontakt zur C2-Struktur herzustellen.

### 10.6 Verzögerungen

Der Autor empfiehlt, nicht jedes Ereignis sofort in ein Tasking umzusetzen.

Mögliche Verzögerungen:

- mehrere Minuten zwischen einem TIC und der tatsächlichen Zuweisung,
- in manchen Fällen Verzögerungen im Bereich von mehreren zehn Minuten,
- Wartezeit trotz sichtbarem legitimen Ziel,
- zusätzliche Zeit bis zur 9-Line und Angriffsfreigabe.

Der Spieler kann frühzeitig über ein Ereignis informiert werden, das eigentliche Tasking aber erst nach realistischer Bearbeitungszeit erhalten.

### 10.7 Re-Tasking

Auch ein bereits mit einem JTAC arbeitendes Luftfahrzeug kann zu einem dringenderen Ereignis umgeleitet werden. Dies soll die realen Prioritätskonflikte, Knappheit und operative Dringlichkeit abbilden.

### 10.8 Ziel der simulierten Reibung

Die Mission soll nicht absichtlich schwerfällig oder bürokratisch werden. Die Reibung soll den Spielern vermitteln:

- Dringlichkeit,
- begrenzte Ressourcen,
- konkurrierende Anforderungen,
- Verantwortung für Kommunikation und Luftraum,
- Bedeutung einer funktionierenden C2-Kette.

---

## 11. Abbildungen und visuelle Quellenbestandteile

### 11.1 Teil 1

| PDF-Seite | Abbildung | Aussage für die Dokumentation |
|---:|---|---|
| 1 | eingebettetes A-10-Video | Einleitung in eine typische CAS-Lage. |
| 2 | A-10 in Kandahar, November 2009 | Visueller Bezug zur CAS-Plattform in Afghanistan. |
| 3 | Titelblatt *Operation Anaconda Case Study* | Offene Quelle zur Analyse der C2-Probleme. |
| 4 | Akteursdiagramm nach JP 3-30 | Einordnung von JTAC/TACP/ASOC, JFACC/AOC und Air-C2-Elementen. |
| 5 | USAF-JTAC und TOC-Aufnahme | Darstellung der bodengebundenen C2-Ebene. |
| 6 | CRC Battle Management Areas | `CROWBAR`, `TAIPAN`, `WIZARD` und geografische Verantwortungsräume. |
| 7 | USAF AWACS über Afghanistan | AWACS als fliegender Radar-, Relay- und Kontrollknoten. |
| 8 | CAOC in Al Udeid | Strategische Luftoperationsführung im CENTCOM-AOR. |

### 11.2 Teil 2

| PDF-Seite | Abbildung | Aussage für die Dokumentation |
|---:|---|---|
| 2 | leeres JTAR-Formular | Standardisierte Anforderung von Luftunterstützung. |
| 3 | Overview of the ISAF Networks | Vernetzung der taktischen Informationsräume. |
| 5 | Echtzeitdarstellung der Luftlage | Entscheidungsgrundlage des FDO für Asset-Zuweisungen. |
| 6 | KY-58 Secure Voice Module | Plain/Secure-Umschaltung und Schlüsselwahl. |

### 11.3 Teil 3

| PDF-Seite | Abbildung | Aussage für die Dokumentation |
|---:|---|---|
| 1 | Titelbild *A Different Kind of War* | Als Anlage beigefügte historische Quelle. |
| 2 | Shah-i-Kot Area of Operations | Gelände, Teilräume, Höhen und markante Punkte der Fallstudie. |
| 3 | B-52 bei Luftbetankung über Afghanistan | Bezug zum beschriebenen B-52-/AC-130-Deconfliction-Fall. |
| 5 | CGRS Grid of Afghanistan | Rasterbasierte Aufgabenübermittlung als DCS-Vorschlag. |
| 6 | Anlagenliste | *A Different Kind of War.pdf* und *Shah i Kot Valley.pdf*. |

---

## 12. Verknüpfte und genannte offene Quellen

Die folgenden Quellen oder Querverweise sind in den drei Beiträgen direkt verlinkt oder namentlich genannt. Die Linkbeziehung zum Patreon-Beitrag ist verifiziert; eine vollständige inhaltliche Einzelprüfung ist, soweit nicht separat dokumentiert, noch `PENDING`.

| Quelle | Bezug in der Reihe | Status |
|---|---|---|
| *Operation Anaconda Case Study*, CADRE/Air University, 13. November 2003 | Titelblatt in Teil 1, PDF-S. 3 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| Capt. Seth Spidahl, *The Once and Future ASOC* | Zitat und Link in Teil 1, PDF-S. 3 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| [JP 3-30, Joint Air Operations](https://irp.fas.org/doddir/dod/jp3_30.pdf) | Akteursdiagramm in Teil 1, PDF-S. 4 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| Chris Westwood, *Air Operations Control and Reporting Centre* | CRC/BMA-Darstellung in Teil 1, PDF-S. 6-7 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| [AFCEA SIGNAL: Military Treats Outbreak With Chat Rooms in Afghanistan](https://www.afcea.org/signal-media/military-treats-outbreak-chat-rooms-afghanistan) | Chat-Nutzung in Teil 2, PDF-S. 3 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| [Key.Aero: Part One - A-10 Front Line, Operation Anaconda](https://www.key.aero/article/part-one-10-front-line-operation-anaconda) | Erfahrungsbericht in Teil 3, PDF-S. 2-3 | `LINK_IDENTIFIED` / `PENDING_REVIEW` |
| Graveyard of Empires, früherer JTAR/ASR-Beitrag, Post 115305541 | Querverweis in Teil 2, PDF-S. 1 | `GOE_CROSS_REFERENCE` / `PENDING` |
| Graveyard of Empires, Post 114498665 | Querverweis zur Echtzeit-Luftlage in Teil 2, PDF-S. 5 | `GOE_CROSS_REFERENCE` / `PENDING` |
| Graveyard of Empires, *Building CGRS*, Post 114653359 | CGRS-Querverweis in Teil 3, PDF-S. 5 | `GOE_CROSS_REFERENCE` / `PENDING` |

### 12.1 Direkt beigefügte Anlagen

Teil 3 führt ausdrücklich folgende Dateien als Anlagen auf:

- *A Different Kind of War.pdf*
- *Shah i Kot Valley.pdf*

Die Beziehung dieser Dateien zur Reihe ist damit direkt verifiziert. Eine vertiefte Auswertung der Anlagen muss als `ORIGINAL_SOURCE_VERIFIED` getrennt von der Zusammenfassung der Patreon-Beiträge dokumentiert werden.

---

## 13. Projektübernahme für Operation Mountain Watch

### 13.1 Aus der Reihe unmittelbar zu übernehmende Anforderungen

Die folgenden Anforderungen ergeben sich direkt aus den in Teil 3 formulierten DCS-Vorschlägen und werden deshalb als quellenbasierte Designanforderungen vorgemerkt:

- CAS-Anforderungen nicht direkt in einen Angriff umwandeln.
- Pre-Planned und Immediate CAS unterscheiden.
- Bodenlage und Priorität über eine TOC-Funktion vermitteln.
- Asset-Auswahl nach Eignung, Entfernung, Kraftstoff und Bewaffnung ermöglichen.
- gleichzeitige Anforderungen priorisieren.
- BMA-/CRC-Sektoren und Handoffs abbilden.
- Zuständigkeit für Deconfliction ausdrücklich festlegen.
- Funkreichweiten, Geländeabschattung und Relais berücksichtigen.
- Verzögerungen und Re-Tasking als glaubwürdige Reibung einsetzen.
- Funkmeldungen und detailliertere Textinformationen kombinieren.
- CGRS als mögliches Tasking-System vorsehen.
- die Simulation verständlich halten und nicht jede reale Führungsebene vollständig duplizieren.

### 13.2 Technische Abgrenzung

`PROJECT_INFERENCE`

Dieses Dokument beschreibt das operative Sollbild und die DCS-Empfehlungen der Quelle. Es legt noch keine konkrete Lua- oder MOOSE-Implementierung fest.

Für die technische Umsetzung gelten weiterhin:

- [`Verbindliche MOOSE-First-Entwicklungsrichtlinie`](26-moose-first-development-policy.md)
- [`ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur`](moose/ISR-FAC-CAS-AAR.md)
- [`Luftoperations- und ORBAT-Umsetzung`](18-air-operations-implementation.md)

Vor eigener Skriptlogik ist zu prüfen, welche Anforderungen bereits durch den verwendeten MOOSE-Stand abgedeckt werden. Erst danach darf eine projektspezifische Vermittlungs- oder C2-Schicht entworfen werden.

---

## 14. Noch ausstehende Quellenarbeit

Die **direkte Erfassung der drei Patreon-Beiträge ist abgeschlossen**.

Noch ausstehend ist nur die vertiefte Provenienz- und Originalquellenprüfung:

1. verlinkte Open-Source-Dokumente vollständig abrufen,
2. relevante Passagen mit den Patreon-Aussagen abgleichen,
3. Abbildungen und Zitate ihren Originalfundstellen zuordnen,
4. die beiden beigefügten Anlagen separat auswerten,
5. die drei verlinkten Graveyard-of-Empires-Querverweise erfassen,
6. Ergebnisse als `ORIGINAL_SOURCE_VERIFIED` oder weiterhin `PENDING` kennzeichnen.

Diese Folgearbeit erweitert die Quellenbasis, ändert aber nichts daran, dass Teil 1, Teil 2 und Teil 3 selbst jetzt vollständig als `GOE_POST_VERIFIED` vorliegen.

---

## 15. Glossar

| Kürzel | Bedeutung |
|---|---|
| ACO | Airspace Control Order |
| ASOC | Air Support Operations Center |
| ASR | Air Support Request |
| ATO | Air Tasking Order |
| AWACS | Airborne Warning and Control System |
| BMA | Battle Management Area |
| CAOC | Combined Air Operations Center |
| CAS | Close Air Support |
| C2 | Command and Control |
| CGRS | Common Geographic Reference System |
| CJTF | Combined Joint Task Force |
| CRC | Control and Reporting Center |
| FAC(A) | Forward Air Controller (Airborne) |
| FDO | Fighter Duty Officer |
| G-CAS | Ground-Alert Close Air Support |
| ISR | Intelligence, Surveillance and Reconnaissance |
| JADOCS | Joint Automated Deep Operations Coordination System |
| JTAC | Joint Terminal Attack Controller |
| JTAR | Joint Tactical Air Request |
| OEF | Operation Enduring Freedom |
| RFA | Restricted Fire Area |
| ROZ | Restricted Operating Zone |
| SOF | Special Operations Forces |
| TACP | Tactical Air Control Party |
| TAD | Tactical Air Direction |
| TIC | Troops in Contact |
| TOC | Tactical Operations Center |
| TST | Time-Sensitive Target |
| X-CAS | Air-Alert beziehungsweise bereits airborne verfügbare CAS-Kräfte |

---

## 16. Primärquellen

1. Graveyard of Empires, *Who's in Charge? Air C2 and Close Air Support in Afghanistan (1/3)*, Patreon, 6. Mai 2025, Post 127794463.
2. Graveyard of Empires, *Who's in Charge? Air C2 and Close Air Support in Afghanistan (2/3)*, Patreon, 10. Mai 2025, Post 127798624.
3. Graveyard of Empires, *Who's in Charge? Air C2 and Close Air Support in Afghanistan (3/3)*, Patreon, 15. Mai 2025, Post 128190337.
4. Als Anlagen zu Teil 3: *A Different Kind of War.pdf* und *Shah i Kot Valley.pdf*.
