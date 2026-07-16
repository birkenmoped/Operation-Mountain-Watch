# TM01C – DCS-Laufzeiterfahrungen und Lessons Learned

Datum: 16. Juli 2026  
Status: fortlaufender Erfahrungsbericht, noch keine Endabnahme

## Zweck

Dieses Dokument ist das fortlaufende technische Laufzeitprotokoll für TM01C. Es ergänzt die ursprüngliche Entwurfsnotiz `2026-07-15-tm01c-manual-pack-unpack.md` um die tatsächlich im DCS-Lauf beobachteten Effekte, Fehlermodi, Ursachen, Korrekturen und verbleibenden Risiken.

Für jede weitere Änderung an TM01C sind mindestens festzuhalten:

- DCS- und MOOSE-Version;
- verwendete Konfigurationsversion;
- relevante Fahrzeugzusammensetzung;
- beobachtetes Verhalten;
- belastbare Logereignisse;
- technische Ursache;
- zugehöriger Fix-Commit;
- DCS-Abnahmestatus: `PASS`, `FAIL`, `PARTIAL` oder `NOT RETESTED`.

## Laufzeitkontext

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch:     feature/tm01b-convoy-caching
PR:         #8, Draft, nicht mergen
DCS:        2.9.27.25340 Open Beta MT
MOOSE:      statischer Include, gepinnter Projektstand
Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Zuletzt getestete Templatezusammensetzung:

```text
3 × HMMWV
3 × Lkw
```

Die Stable-Slot- und Survivor-Logik darf nicht von homogenen Fahrzeugtypen abhängen. Unterschiedliche Fahrzeuglängen, Wendekreise und Beschleunigungen können jedoch DCS-AI-Manöver und die Dauer der Formierungsphase beeinflussen.

# 1. Bestätigte Architekturgrundsätze

## 1.1 Stabile strategische Identität

Die strategische Entität bleibt:

```text
TEST.TM01.CONVOY.001
```

DCS-Gruppen- und Unit-Namen sind flüchtige Runtime-Identitäten. Nach einem Unpack entsteht eine neue Runtime-Generation. Das ist zulässig, solange folgende Domain-Daten erhalten bleiben:

- geordnete Survivor-Slots;
- aktueller Führungs-Slot;
- Routenfortschritt;
- Schadenszustand pro Stable Slot;
- Repräsentationszustand.

## 1.2 Physische Exklusivität

Zu keinem Zeitpunkt dürfen Proxygruppe und expandierte Gruppe gleichzeitig als gültige Repräsentation bestehen.

Der Unpack-Pfad bleibt deshalb:

```text
Proxyposition erfassen
→ neues Layout validieren
→ Proxygruppe entfernen
→ native Abwesenheit bestätigen
→ neue Survivor-Gruppe erzeugen
```

Das ist fachlich sauber, bleibt in unmittelbarer Sichtweite aber visuell deutlich wahrnehmbar.

## 1.3 Kein stilles Recovery-Verhalten

TM01C darf nach bestätigter Aktivierung keine dauerhafte automatische Unstuck-, Teleport- oder Re-Routing-Logik ausführen.

Begrenzte Wiederholungen sind nur während der initialen Spawn-Aktivierungsphase zulässig und müssen geloggt werden.

# 2. Chronologie der DCS-Erfahrungen

## 2.1 Bootstrap scheiterte an falscher MOOSE-API-Zuordnung

### Beobachtung

Der Bootstrap stoppte mit:

```text
missing=POSITIONABLE.GetTypeName
```

### Ursache

`GetTypeName` ist im verwendeten MOOSE-Stand auf `IDENTIFIABLE` definiert und wird von `UNIT` geerbt. Die Bootstrap-Prüfung validierte die falsche Basisklasse.

### Korrektur

Validierung auf `IDENTIFIABLE.GetTypeName` umgestellt.

### Ergebnis

```text
configuration_valid
bootstrap_outcome=READY
menu_ready
```

### Status

`PASS`

---

## 2.2 Packen scheiterte an einer Same-Tick-Annahme

### Beobachtung

Nach `UNIT:Destroy(false)` waren die fünf Nicht-Führungsfahrzeuge sichtbar entfernt. Die unmittelbar folgende Prüfung meldete jedoch noch nicht exakt eine lebende Unit. Wenige Sekunden später zeigte derselbe Runtimeverband korrekt nur noch das Proxyfahrzeug.

### Ursache

DCS aktualisiert den Gruppenbestand nach dem Entfernen einzelner Units nicht garantiert synchron innerhalb desselben Simulationsticks.

### Korrektur

- Zustand bleibt während der Bestätigung `PACKING`;
- zeitgesteuerte Poll-Abfrage;
- Wechsel auf `COLLAPSED_PROXY` erst nach bestätigter Einzelrepräsentation;
- kontrollierter Timeout und Fehlerzustand.

### Ergebnis

Das Packen ist visuell fließend: Das Führungsfahrzeug bleibt bestehen und fährt weiter, während die übrigen Fahrzeuge verschwinden.

### Status

`PASS`

---

## 2.3 Reduzierter Survivor-Spawn scheiterte im internen MOOSE-Template

### Beobachtung

Nach dem Verlust eines Fahrzeugs wurde die Survivor-Liste korrekt auf fünf Slots reduziert. Beim Unpack brach MOOSE jedoch beim sechsten internen Unit-Eintrag ab.

### Ursache

`SPAWN:NewWithAlias()` hielt intern weiterhin eine vorbereitete Kopie des ursprünglichen Sechs-Fahrzeug-Templates. Nur `spawner.SpawnTemplate.units` zu verkürzen reichte nicht aus.

### Korrektur

- vollständiges Quelltemplate kopieren;
- ausschließlich Survivor-Slots übernehmen;
- neuen Spawner mit `SPAWN:NewFromTemplate()` erzeugen;
- Coalition, Country und Category explizit erhalten;
- exakte Unit-Anzahl nach dem Spawn verifizieren;
- denselben Pfad für den Proxy-Rollback verwenden.

### Ergebnis

Reduzierte Gruppen können mit der korrekten Survivor-Anzahl erzeugt werden. Zerstörte Slots werden nicht wiederhergestellt.

### Status

`PASS`

---

## 2.4 Neu gespawnte Gruppen erhielten ihre Route zu früh

### Beobachtung

Der initial gespawnte Konvoi und neu entpackte Gruppen standen teilweise trotz zugewiesener Route. Ein bereits existierendes Proxyfahrzeug fuhr nach dem Packen dagegen zuverlässig weiter.

### Ursache

Die Route wurde unmittelbar nach `SPAWN:Spawn()` an einen noch nicht vollständig initialisierten DCS-Gruppencontroller übergeben. Der Status `EN_ROUTE` bestätigte nur den API-Aufruf, nicht tatsächliche Bewegung.

### Korrektur

Neue Spawn-Aktivierungsphase:

```text
ACTIVATING_ROUTE
→ kurze Initialisierungswartezeit
→ Route zuweisen
→ tatsächliche Bewegung messen
→ erst danach IDLE / EN_ROUTE
```

Die Route darf während dieser begrenzten Aktivierungsphase erneut zugewiesen werden. Nach erfolgreicher Aktivierung endet diese Sonderbehandlung.

### Status

`PARTIAL`

Die Aktivierungslogik funktioniert grundsätzlich. Weitere Korrekturen an Bewegungsmessung und Heading waren erforderlich.

---

## 2.5 Partielle Schäden gingen beim Unpack verloren

### Beobachtung

Nicht zerstörte, aber beschädigte Fahrzeuge erschienen nach einem Pack-/Unpack-Zyklus wieder mit 100 Prozent Lebenspunkten.

### Ursache

CampaignState enthielt ursprünglich nur die Survivor-Liste. Ein neu erzeugtes DCS-Fahrzeug wurde daher aus dem unbeschädigten Template aufgebaut.

### Korrektur

Domain-Zustand pro Stable Slot:

```lua
vehicleLifePercentByStableSlot = {
  [6] = 100,
  [5] = 100,
  [4] = 100,
  [3] = 100,
  [2] = 100,
  [1] = 100,
}
```

Ablauf:

- `UNIT:GetLifeRelative()` während physischer Darstellung erfassen;
- Lebenswert im CampaignState persistieren;
- nach Spawn mit `UNIT:SetLife(percent)` wiederherstellen;
- Wiederherstellung aus DCS zurücklesen und verifizieren;
- Totalverluste weiterhin ausschließlich über Survivor-Slots abbilden.

### Status

`PARTIAL`

Implementiert und im Logpfad vorhanden. Eine eigenständige abschließende visuelle Schadensabnahme muss weiterhin protokolliert werden.

---

## 2.6 Reale Bewegung wurde durch negative Routenprojektion fälschlich abgelehnt

### Beobachtung

Eine entpackte gemischte Gruppe bewegte sich real ungefähr neun Meter. Gleichzeitig lag die Projektion auf den kompilierten Straßenpfad rund 4,5 Meter hinter dem Ausgangswert. Der Controller meldete deshalb fälschlich einen Aktivierungs-Timeout und hielt an.

### Ursache

Die Aktivierung verlangte gleichzeitig:

```text
positive Straßenfortschreibung
und
reale räumliche Verschiebung
```

Beim Einordnen, Wenden oder kurzen Rückwärtsmanövern kann eine DCS-Gruppe reale Bewegung zeigen, ohne bereits positiven Fortschritt auf dem idealisierten Routenpfad zu erzielen.

### Korrektur

- Aktivierung wird durch maximale reale 2D-Verschiebung bestätigt;
- vorzeichenbehafteter Routenfortschritt bleibt Diagnosewert;
- Survivor-Synchronisierung läuft bereits während `ACTIVATING_ROUTE`;
- bei Führungswechsel wird die Bewegungsbasis auf den neuen Stable Lead gesetzt.

### Ergebnis

Gemischte Fahrzeuggruppen sind zulässig. Unterschiedliche Fahrzeugtypen beeinflussen nur die DCS-Formierungsbewegung, nicht die Domain-Logik.

### Status

`PASS`

---

## 2.7 Fahrzeugausrichtung nach Unpack war entgegengesetzt zur Marschrichtung

### Beobachtung

Nach dem ersten und zweiten Unpack standen alle Fahrzeuge entgegen der Marschrichtung. Die Gruppe musste wenden und sich neu sortieren. Dieses Entwirren verlängerte die Aktivierungsphase und erhöhte das Risiko von Kollisionen und Verlusten.

### Ursache

DCS-`Vec2` verwendet:

```text
x = Nord
 y = Ost
```

Heading muss daher berechnet werden als:

```text
atan2(Ost, Nord)
```

TM01C vertauschte beide Komponenten und verwendete sinngemäß `atan2(Nord, Ost)`.

### Korrektur

```lua
local degrees = math.deg(atan2(
  toVec2.y - fromVec2.y,
  toVec2.x - fromVec2.x
))
```

Konfigurationsversion:

```text
TM01C-manual-proxy-pack-unpack-4
```

Fix-Commits:

```text
114536cc99259a0c238212e333f35fed0f846c1b
ed336b1c6f57ea82f9a7bcbe1593d5cce67a2285
```

### Status

`NOT RETESTED`

Die mathematische Ursache ist eindeutig korrigiert. Die DCS-Abnahme muss noch zeigen, dass initialer Spawn und mehrere Unpack-Zyklen sofort in Marschrichtung ausgerichtet sind.

# 3. Bestätigte DCS-Verhaltensbeobachtungen

## 3.1 Gefechtsreaktion der Boden-KI

TM01C implementiert keine eigene Gefechtsformation. Ausfächern, Anhalten, Zielbekämpfung und späteres Wiederaufnehmen der Route bleiben DCS-AI-Verhalten.

Im bisherigen Verlusttest wurde beobachtet:

- Fahrzeuge reagierten auf Beschuss und verließen teilweise die saubere Marschformation;
- nach Ende des Beschusses setzte die Restgruppe die Fahrt fort;
- die Survivor-Liste wurde nach bestätigtem Totalverlust reduziert;
- Packen und erneutes Unpacken erzeugten nur die verbliebenen Slots.

Dieses Verhalten darf nicht als überall identische feste Wartezeit interpretiert werden. DCS-AI-Reaktionen hängen von Bedrohung, Fahrzeugtyp, Gelände und Gruppenzustand ab.

## 3.2 Straßenaufstellung

Die individuelle Aufstellung aller Fahrzeuge auf der Straße ist eine TM01C-Funktion und kein Zufall.

Pro Stable Slot werden geprüft:

- Position entlang des kompilierten Straßenpfades;
- finale Projektion mit `GetClosestPointToRoad(false)`;
- Straßentoleranz;
- Wasser und flaches Wasser;
- Mindestabstand zum Nachbarfahrzeug;
- lokales Heading entlang der Marschrichtung.

## 3.3 Packen und Unpacken sind visuell asymmetrisch

Packen:

- bestehende DCS-Gruppe bleibt erhalten;
- nur Nicht-Führungsfahrzeuge werden entfernt;
- Führungsfahrzeug fährt mit derselben Runtime-Identität weiter;
- Übergang wirkt fließend.

Unpacken:

- Proxygruppe wird entfernt;
- neue Gruppe wird erzeugt;
- neue Runtime-Namen und neue Generation;
- sichtbarer harter Übergang.

DCS erlaubt über die reguläre Missionsskript-API kein belastbares nachträgliches Hinzufügen mehrerer Fahrzeuge zu einer bestehenden Gruppe. Ein visuell vollständig nahtloses Unpack würde daher ein anderes Repräsentationsmodell erfordern.

# 4. Aktueller Abnahmestand

| Funktion | Status |
|---|---|
| Bootstrap und F10-Menü | PASS |
| Straßenlayout mit individuellen Positionen | PASS |
| Fließendes Packen auf ein Proxyfahrzeug | PASS |
| Asynchrone Pack-Bestätigung | PASS |
| Verlustpersistenz über Pack/Unpack | PASS |
| Reduzierter Survivor-Spawn | PASS |
| Gemischte Fahrzeugtypen | PASS |
| Aktivierung durch reale Bewegung | PASS |
| Teilschadensspeicherung und Wiederherstellung | PARTIAL |
| Korrekte Fahrzeugausrichtung nach Spawn/Unpack | NOT RETESTED |
| Visuell nahtloses Unpack | FAIL / nicht implementiert |
| Angriff auf eingepacktes Proxyfahrzeug | nicht abgenommen |
| Automatische Relevanzsteuerung | außerhalb TM01C |

# 5. Nächster DCS-Test

Mit Konfigurationsversion 4 und unveränderter gemischter Fahrzeugzusammensetzung:

```text
Start convoy
→ initiale Fahrzeugausrichtung prüfen
→ Bewegung bestätigen
→ Pack
→ Unpack
→ Ausrichtung aller Survivor prüfen
→ Bewegung bestätigen
→ Pack
→ zweites Unpack
→ Ausrichtung erneut prüfen
```

Erwartet:

- alle Fahrzeuge stehen längs der Straße;
- alle Fahrzeugfronten zeigen in Richtung des nächsten Routenpunkts;
- keine 180-Grad-Wendemanöver;
- keine Entwirrung durch Gegenverkehrs- oder Querbewegung;
- `convoy_route_activation_confirmed` innerhalb des Aktivierungsfensters;
- kein `convoy_route_activation_timeout`;
- kein Verlust während der Formierungsphase.

Danach separater Schadensnachweis:

```text
Nicht-Führungsfahrzeug leicht beschädigen
→ damage state erfassen
→ Pack
→ Unpack
→ identischen Stable Slot und ungefähr denselben Lebenswert prüfen
```

# 6. Dokumentationsregel für weitere Änderungen

Jeder neue DCS-Test oder Codefix erhält in diesem Dokument einen neuen datierten Eintrag mit folgendem Schema:

```text
Beobachtung
Lognachweis
Ursache
Codeänderung
Commit
DCS-Retest
Abnahmestatus
Offene Folgefragen
```

Ein Codefix ohne dokumentierten DCS-Retest bleibt `NOT RETESTED`. Ein erfolgreicher Mock-Lauf darf niemals als DCS-Abnahme bezeichnet werden.
