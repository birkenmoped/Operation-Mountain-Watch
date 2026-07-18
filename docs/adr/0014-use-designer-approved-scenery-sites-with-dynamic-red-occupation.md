# ADR 0014 – Designerfreigegebene Landschaftsstandorte mit dynamischer roter Belegung verwenden

- Status: Accepted
- Date: 2026-07-18

## Context

Rote Standorte sollen sich glaubwürdig in die Afghanistan-Szenerie einfügen. Die aktuell im Mission Editor setzbaren statischen Objekte passen dafür häufig nicht und würden als künstliche Missionsobjekte auffallen.

DCS-Landschaftsgebäude können als Standortanker verwendet werden. MOOSE kann zugewiesene oder räumlich gescannte `SCENERY`-Objekte finden und unter anderem deren Koordinate, Eigenschaften und Lebenszustand abfragen. Diese Schnittstellen sind jedoch nicht bei jedem Landschaftsobjekt gleich zuverlässig; einige Objekte liefern unbrauchbare Lebenswerte, und Landschaftsobjekte sollen nicht per Skript zerstört werden.

Eine vollständig freie automatische Gebäudesuche über die gesamte Karte wäre deshalb schwer kontrollierbar. Der Missionsdesigner muss weiterhin Spielbarkeit, Erreichbarkeit, Zerstörbarkeit und zivile Plausibilität sicherstellen.

## Decision

### Hybridmodell

Der Missionsdesigner definiert den zulässigen Standort- und Bewegungsraum. Der rote Kommandeur entscheidet innerhalb dieses Raumes über Belegung, Aufgabe und Ersatz.

Der Designer setzt:

- feste Haupt-HQs;
- optionale Unter-HQs;
- geprüfte konkrete Landschaftsstandorte;
- optionale Kandidatengebiete für spätere automatische Suche;
- geprüfte Routen und Bewegungskorridore;
- narrativ zwingende Schlüsselstellungen.

Der Kommandeur entscheidet:

- welcher freie Standort besetzt wird;
- welche Rolle ein Standort aktuell übernimmt;
- wann ein Knoten verstärkt, geschwächt oder aufgegeben wird;
- welcher Ersatzstandort nach Neutralisierung oder Zerstörung gewählt wird.

### Namenskonvention

```text
OMW_RED_HQ_<freier Name>
OMW_RED_SUBHQ_<freier Name>
OMW_RED_SITE_<freier Name>
OMW_RED_NODEAREA_<freier Name>
OMW_RED_ROUTE_<freier Name>
```

Der Präfix bestimmt den Objekttyp. Der freie Namensrest dient dem Missionsdesigner und muss nicht global nummeriert werden. DCS-seitig automatisch ergänzte Suffixe bleiben zulässig; der vollständige tatsächliche Name ist der Laufzeitschlüssel.

### Standort und Knoten sind getrennt

```text
Site = physischer Ort und möglicher Anker
Node = aktuell dort betriebene rote Einrichtung
```

Ein Site kann verfügbar, besetzt, kompromittiert, aufgegeben oder zerstört sein. Ein Node kann eingerichtet, aktiv, geschwächt, neutralisiert oder zerstört sein.

### Erste produktive Stufe

Der Missionsdesigner weist geeignete Landschaftsgebäude explizit als `OMW_RED_SITE_*` aus. Der Kommandeur wählt nur zwischen diesen geprüften Sites.

### Spätere optionale Stufe

Innerhalb eines `OMW_RED_NODEAREA_*` darf das System nach Landschaftsobjekten suchen und einen gefilterten Kandidatenpool bilden. Automatisch gefundene Objekte werden nicht ungeprüft global verwendet.

### Zerstörung

Ein bestätigter zerstörter Standort erhält einen dauerhaften Kampagnenstatus:

```text
SITE_DESTROYED
```

Er darf nicht automatisch repariert oder erneut aktiviert werden. Die Zerstörungserkennung kombiniert soweit verfügbar DCS-Ereignisse, Lebenszustand, Ankerkoordinate, Objekttyp, Garnisonsverlust und einen missionsinternen Destroyed-Latch.

### Neutralisierung ohne Gebäudeverlust

Wird nur die Garnison vernichtet oder vertrieben, kann gelten:

```text
NODE_NEUTRALIZED
SITE_COMPROMISED
```

Ein kompromittierter Standort bleibt physisch vorhanden, wird aber stark abgewertet oder zeitweise gesperrt.

### Ersatzstandort

Rot darf nach Entscheidungs-, Melde- und Aufbauverzögerung einen anderen verfügbaren Site mit neuer Node-Identität besetzen.

```text
SELECTED
→ OCCUPYING
→ ESTABLISHING
→ ACTIVE
```

Vorläufige Testwerte:

```text
Mindestabstand zum zerstörten Site: 1 bis 2 km
regionale Sperrzeit:                10 bis 30 Minuten
Aufbauzeit:                          5 bis 15 Minuten
```

### Blue-Aufklärung

Ein Landschaftsgebäude ist nicht allein aufgrund seiner Existenz oder Kandidatenrolle ein legitimes rotes Ziel. Die rote Nutzung muss durch sichtbare Kräfte, Bewegungen, Versorgung, Beobachtung, HUMINT, SIGINT oder andere missionsspezifische Hinweise erkannt werden.

## Consequences

### Positive

- rote Standorte fügen sich in die vorhandene Afghanistan-Szenerie ein;
- der Missionsdesigner behält Kontrolle über Spielbarkeit und zivile Plausibilität;
- der rote Kommandeur kann dennoch dynamisch besetzen, aufgeben und ausweichen;
- zerstörte Standorte haben dauerhafte Kampagnenwirkung;
- neue rote Positionen entstehen an anderen glaubwürdigen Orten statt durch Wiederbelebung desselben Gebäudes;
- globale fortlaufende Nummerierung entfällt.

### Negative

- geeignete Landschaftsobjekte müssen zunächst praktisch geprüft werden;
- DCS-Ereignisse und Lebenswerte sind nicht für alle `SCENERY`-Objekte zuverlässig;
- Materialisierungspositionen um Gebäude benötigen eigene Sicherheits- und Geometrieprüfungen;
- zusätzliche Routen oder Korridore müssen durch den Missionsdesigner angelegt und validiert werden;
- automatische Kandidatensuche bleibt bis zu einem eigenen DCS-Test experimentell.

## Rejected alternatives

### Alle roten Knoten vollständig fest verdrahten

Verworfen, weil dadurch Aufgabe, Verlagerung und Ersatz nur über vorbereitete Skriptfälle möglich wären.

### Kommandeur sucht frei auf der gesamten Karte nach Gebäuden

Verworfen, weil Gebäudetyp, Erreichbarkeit, Zerstörungszustand und zivile Plausibilität nicht zuverlässig automatisch garantiert werden können.

### Sichtbare statische Missionsobjekte als Standardunterkunft

Verworfen, sofern sie nicht zur Afghanistan-Szenerie passen und dadurch rote Standorte künstlich markieren.

### Zerstörte Sites wieder aktivieren

Verworfen. Ein bestätigter zerstörter Standort bleibt zerstört; Rot muss eine neue Position beziehen.

## Required validation

- Mission-Editor-Zuweisung eines Afghanistan-Landschaftsgebäudes;
- Wiederfinden per MOOSE `SCENERY` und gespeicherter Koordinate;
- stabile Identität über Missionsneustarts und Kartenstand prüfen;
- DCS-Todesereignis und Lebenswert an mehreren Gebäudetypen testen;
- Garnison plausibel um den Anker materialisieren;
- zerstörten Site dauerhaft sperren;
- Ersatz-Site nach Melde-, Entscheidungs- und Aufbauzeit wählen;
- keine Neubesetzung desselben zerstörten Sites;
- Blue muss rote Nutzung erkennen können, ohne dass jedes zivile Gebäude automatisch als Ziel gilt.