# MOOSE-Events, FSM und Scheduler in Operation Mountain Watch

## 1. Grundsatz

MOOSE-OPS-Klassen sind in weiten Teilen zustandsautomatenbasiert. OMW soll vorhandene FSM-Zustände, Events und Callbacks verwenden, bevor eigene Polling-Schleifen oder parallele Zustandsautomaten eingeführt werden.

Das gilt insbesondere für:

- AIRWING,
- COMMANDER,
- AUFTRAG,
- FLIGHTGROUP,
- ARMYGROUP,
- OPSTRANSPORT,
- WAREHOUSE,
- CTLD und CSAR, soweit diese Klassen passende Events bereitstellen.

## 2. Core.Fsm

### Bedeutung

`Core.Fsm` stellt das MOOSE-Zustandsautomatenmodell bereit. Viele OPS-Klassen erben davon und liefern:

- Zustände,
- synchrone Events,
- verzögerte Events,
- `OnBefore...`-Callbacks,
- `OnAfter...`-Callbacks,
- Event- und Statusübergänge.

### Verbindliche Prüfung

Vor eigener Zustandslogik sind für die konkrete Klasse zu prüfen:

1. vorhandene Zustände,
2. öffentliche Events,
3. verzögerte `__Event()`-Varianten,
4. Callback-Signaturen,
5. Abbruch- und Endzustände,
6. Verhalten bei Verlust oder zerstörten Assets,
7. Reihenfolge mehrfach ausgelöster Events.

### Callback-Regel

Die exakte Schreibweise und Signatur ist aus dem tatsächlich verwendeten MOOSE-Quellcode zu übernehmen. Beispiele in älteren Dokumentationen können bei Groß-/Kleinschreibung oder Parametern abweichen.

Ein typisches Muster ist:

```lua
function object:OnAfter<Event>(From, Event, To, ...)
  -- projektspezifische Reaktion
end
```

Es darf nicht angenommen werden, dass jeder dokumentierte Callback exakt dieses Präfix oder dieselben Zusatzparameter verwendet.

## 3. Core.Event

### Vorgesehener Nutzen

`Core.Event` kapselt DCS-Ereignisse und stellt strukturierte Eventdaten bereit.

Für OMW relevant sind voraussichtlich:

- Birth,
- Engine Startup,
- Takeoff,
- Land,
- Engine Shutdown,
- Dead,
- Crash,
- Unit Lost,
- Ejection,
- Pilot Dead,
- Cargo-/Sling-Ereignisse, soweit vorhanden,
- Player Enter/Leave Unit,
- Mission End.

### Projektstatus

`PLANNED`.

Die aktuelle Jalalabad-Baseline wertet Ereignisse primär über Log- und Debrief-Nachweise aus. Eine zentrale OMW-Event-Schicht ist noch nicht als produktive Architektur validiert.

### Anforderungen

- Ereignisse dürfen nicht ungeprüft mehrfach als derselbe Verlust gebucht werden.
- DCS `Dead`, `Crash`, `Unit Lost` und Ejection können je nach Objekt und Ablauf überlappen.
- Eventdaten müssen auf `nil` und nicht mehr existente Wrapper geprüft werden.
- Verlustbuchung muss idempotent sein.
- Eventhandler dürfen bei Missionsende oder zerstörten Objekten keine fortlaufenden Coordinate-Fehler erzeugen.

## 4. Core.Scheduler

### Aktueller Einsatz

`SCHEDULER` wird in der Jalalabad-Testbaseline für geordnete, verzögerte Initialisierung verwendet:

```lua
SCHEDULER:New(nil, functionReference, arguments, startDelay)
```

Die einzelnen Konstruktor- und Validierungsschritte wurden zeitlich gestaffelt, damit:

- MOOSE vollständig geladen ist,
- Mission-Editor-Objekte registriert sind,
- AIRWING vor SQUADRONs existiert,
- Squadrons vor dem finalen Start existieren,
- die Abschlussvalidierung erst nach vollständiger Konstruktion läuft.

### Validierter Stand

Der Jalalabad-Complete-Node-Test lief ohne relevanten OMW-Timerfehler.

### Einschränkung

Die Verwendung fester Verzögerungen ist keine Garantie für einen fachlichen Zustand. Für produktive Abläufe sind Events, Zustandsprüfungen und begrenzte Retry-Logik einer rein zeitbasierten Verkettung vorzuziehen.

## 5. Direkter DCS-Timer als Fallback

Aktuell existiert in Testquellen ein Fallback:

```lua
timer.scheduleFunction(...)
```

Dieser wird nur verwendet, wenn `SCHEDULER` nicht verfügbar ist.

Bewertung:

- als früher Bootstrap-/Diagnosefallback zulässig,
- nicht als Standard für produktive MOOSE-Logik,
- bei einer fehlenden MOOSE-Klasse muss zusätzlich geloggt werden, warum der Fallback aktiv wurde,
- produktive Abläufe dürfen nicht unbemerkt dauerhaft außerhalb der MOOSE-FSM laufen.

## 6. Polling gegenüber Events

### Events bevorzugen

Ein Event oder FSM-Callback ist zu bevorzugen, wenn er zuverlässig meldet:

- Start oder Abschluss einer Mission,
- Transport geladen oder entladen,
- Asset zerstört,
- Gruppe an Ziel angekommen,
- Warehouse-Zustand geändert,
- Gruppe einer Mission zugewiesen,
- Recovery oder Rückkehr abgeschlossen.

### Polling zulässig

Polling bleibt zulässig, wenn:

- MOOSE kein passendes Event liefert,
- ein DCS-Zustand nur durch periodische Messung erkennbar ist,
- eine Stuck-Erkennung Bewegung über Zeit vergleichen muss,
- der Polling-Intervall begrenzt und performanceverträglich ist,
- Scheduler nach Abschluss oder Zerstörung zuverlässig beendet wird.

### Verbotenes Muster

Nicht zulässig ist ein unbegrenzt laufender Scheduler, der bei einem zerstörten Asset fortlaufend Methoden wie `GetCoordinate()` aufruft und wiederholt Fehler erzeugt.

## 7. Retry- und Watchguard-Zustände

Für Recovery- oder Watchguard-Funktionen ist ein dokumentiertes Zustandsmodell erforderlich, beispielsweise:

```text
MONITORING
├── MOVING
├── SUSPECTED_STUCK
├── RECOVERY_ALLOWED
├── RECOVERY_BLOCKED_CONTACT
├── RECOVERY_ATTEMPT
├── RECOVERED
├── FAILED
└── DESTROYED
```

Zu dokumentieren sind:

- Messintervall,
- Mindestbewegung,
- Distanz zur Rücksetzung des Versuchszählers,
- maximale Versuche,
- Cooldown,
- Feind- und Spielerabstände,
- Aufklärungs- oder Beschusszustand,
- Abbruchbedingungen,
- Behandlung entpackter Gruppen,
- Cleanup von Schedulern und Eventhandlern.

Vor Einführung dieses eigenen Modells sind vorhandene ARMYGROUP-/OPSGROUP-FSM-Zustände und Events zu prüfen.

## 8. Logging

Jeder wesentliche FSM-Übergang soll mit stabilen OMW-Tags protokolliert werden.

Beispiel:

```text
[OMW][Subsystem.Entity] EVENT: <event> from=<from> to=<to> id=<id>
```

Logs müssen ausreichend sein, um:

- Objekt,
- vorherigen Zustand,
- Event,
- neuen Zustand,
- Mission oder Transport,
- Ursache,
- Ergebnis

zu rekonstruieren.

## 9. Validierungsmatrix

Für jede neue FSM- oder Eventintegration sind mindestens zu testen:

| Fall | Erwartung |
|---|---|
| normaler Ablauf | korrekte Zustandsfolge und genau ein Abschluss |
| verzögerter Start | kein verfrühter Zugriff auf nicht vorhandene Objekte |
| Asset zerstört | unmittelbarer End-/Failure-Zustand, Scheduler stoppt |
| Mission abgebrochen | kein hängenbleibender ACTIVE-Zustand |
| Transport nach Entladen zerstört | definierter Abschluss, kein `NOT_RUN`-/`ACTIVE`-Restzustand |
| Objekt bereits entfernt | keine Endlosschleife und kein Coordinate-Spam |
| mehrfaches DCS-Ereignis | Verlust nur einmal buchen |
| Missionsende | sauberes Stoppen oder folgenloses Auslaufen |

## 10. Quellen

- FSM: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Fsm.html>
- EVENT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Event.html>
- SCHEDULER: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Core.Scheduler.html>
- COMMANDER: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Commander.html>
- AUFTRAG: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html>
- OPSTRANSPORT: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.OpsTransport.html>

## 11. Pflegepflicht

Sobald ein konkreter FSM-Callback oder Eventhandler in OMW implementiert wird, sind in `VERIFIED-METHODS.md` zu erfassen:

- Klasse,
- Event-/Callbackname,
- exakte Signatur,
- verwendeter MOOSE-Commit,
- OMW-Quellpfad,
- Testfall,
- beobachtete Zustandsfolge,
- bekannte Besonderheiten.