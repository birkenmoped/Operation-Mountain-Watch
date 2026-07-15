# TM01C – Manueller Proxy-Pack/Unpack-Test

Datum: 15. Juli 2026

## Entscheidung

TM01C ersetzt für den nächsten Kernnachweis die gescheiterte Reveal-Fenster-Automation durch zwei explizite F10-Befehle:

```text
Pack convoy
Unpack convoy
```

Die Befehle simulieren ausschließlich die spätere Relevanzentscheidung. Die Straßenfahrt selbst bleibt vollständig physisch:

```text
EXPANDED
alle aktuell überlebenden Fahrzeuge fahren

Pack convoy
nur das aktuelle Führungsfahrzeug fährt weiter

Unpack convoy
alle gespeicherten Überlebenden erscheinen wieder hinter dem Führungsfahrzeug
```

Es gibt keine Reveal-, Entry-, Exit- oder Socket-Punkte.

## Fachliche Identität

Der Konvoi ist die strategische Entität `TEST.TM01.CONVOY.001`.

- Es gibt kein festes Proxyfahrzeug.
- Proxy ist die Rolle des aktuell vordersten überlebenden Fahrzeugs.
- Verluste verkleinern die Gruppe dauerhaft.
- Die Ursprungsstärke wird nie wiederhergestellt.
- Gespeichert wird die konkrete geordnete Überlebendenliste, nicht nur eine Zahl.

Konfigurierte ursprüngliche Reihenfolge von hinten nach vorne:

```text
stable slots: 6,5,4,3,2,1 ->
```

Damit ist Slot 1 zu Beginn der Führungs-Slot. Fällt er aus, wird der letzte verbleibende Slot der geordneten Überlebendenliste zum neuen Führungs-Slot.

## Technischer Aufbau

Neue Dateien:

```text
mission/tests/tm01-blue-convoy/config-tm01c.lua
mission/tests/tm01-blue-convoy/src/proxy_campaign_state.lua
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/01-core.lua
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/02-road-spawn.lua
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/03-state-transitions.lua
mission/tests/tm01-blue-convoy/src/convoy_proxy_controller/04-commands-runtime.lua
mission/tests/tm01-blue-convoy/src/tm01c.lua
mission/tests/tm01-blue-convoy/dist/TM01C.lua (generierter Build-Output)
tools/build-tm01c-bundle.ps1
```

Build:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools\build-tm01c-bundle.ps1
```

Ladefolge:

```text
1. vendor/moose/Moose.lua
2. mission/tests/tm01-blue-convoy/dist/TM01C.lua (generierter Build-Output)
```

Die bestehende Test-`.miz` kann weiterverwendet werden. Reveal-Zonen dürfen vorhanden bleiben, werden von TM01C aber nicht gelesen. Im Mission Editor muss der zweite `DO SCRIPT FILE` auf das neu gebaute `TM01C.lua` zeigen; danach Mission speichern und vollständig neu starten.

## F10-Bedienung

```text
F10
└── OMW Tests
    └── TM01C
        ├── Start convoy
        ├── Pack convoy
        ├── Unpack convoy
        ├── Show status
        └── Validate configuration
```

## Straßenmodell

Beim Start wird einmalig ein globaler Straßenpfad durch folgende Punkte kompiliert:

```text
ZONE_TM01_START_BAGRAM
→ ZONE_TM01_ROUTE_01
→ ZONE_TM01_ROUTE_02
→ ZONE_TM01_ROUTE_03
→ ZONE_TM01_ROUTE_04
→ ZONE_TM01_ROUTE_05
→ ZONE_TM01_ROUTE_06
→ ZONE_TM01_ROUTE_07
→ ZONE_TM01_TARGET_JALALABAD
```

Der Pfad dient nur für:

- aktuelle Routenprojektion beim Pack/Unpack;
- individuelle Spawnpositionen;
- individuelle Fahrzeug-Headings;
- Ermittlung der noch vor dem Konvoi liegenden Route.

Es findet keine Straßenpfadberechnung pro Fahrzeug und keine fortlaufende Spawnplatzsuche im Scheduler statt.

## Start

Der Start erzeugt die sechs Templatefahrzeuge mit individuellen Positionen auf dem kompilierten Straßenpfad. Die finale Position jedes Fahrzeugs ist die von `GetClosestPointToRoad()` zurückgegebene Koordinate, nicht nur ein Punkt in Straßennähe.

Für jede Position werden geprüft:

- maximale Straßensnap-Abweichung;
- Wasser und flaches Wasser;
- Mindestabstand zum Nachbarfahrzeug.

Danach erhält die Gruppe die verbleibende `On Road`-Route.

## Pack

Beim Pack:

1. lebende Runtime-Units werden über die Runtime-Index-zu-Stable-Slot-Zuordnung erfasst;
2. bestätigte Verluste werden aus der Überlebendenliste entfernt;
3. der vorderste verbleibende Stable Slot wird Führungs-Slot;
4. der aktuelle Routenfortschritt des Führungsfahrzeugs wird berechnet;
5. die verbleibende Route wird dem bestehenden DCS-Verband neu zugewiesen;
6. alle anderen überlebenden Units werden absichtlich entfernt und im CampaignState gespeichert;
7. exakt das Führungsfahrzeug bleibt physisch.

Dieser Teststand verwendet für das Einpacken `UNIT:Destroy(false)` auf den gespeicherten Nicht-Führungsfahrzeugen. Das ist ein technischer Repräsentationswechsel, kein strategischer Verlust. Eine spätere Gesamtkampagne muss externe Death-Event-Verarbeitung während `PACKING` entsprechend unterdrücken oder klassifizieren.

## Unpack

Beim Unpack:

1. Proxyposition wird auf den globalen Straßenpfad projiziert;
2. der exakte aktuelle Fortschritt wird zuerst getestet;
3. nur wenn dort kein gültiges Layout existiert, werden kleine konfigurierte Vorwärtsversätze getestet;
4. jede finale Fahrzeugposition wird erneut auf die Straße projiziert und gegen Oberfläche und Abstand geprüft;
5. der alte Proxyverband wird entfernt;
6. seine native Abwesenheit wird bestätigt;
7. eine neue DCS-Gruppe wird aus ausschließlich den überlebenden Template-Slots gebaut;
8. die aktuelle Führungsrolle steht vorne, die übrigen Überlebenden folgen dahinter;
9. die verbleibende Straßenroute wird zugewiesen.

Der Controller ist aus vier Quellfragmenten aufgebaut, die das Buildskript in ein einzelnes Lua-Modul zusammensetzt. Die dynamische Restgruppe wird durch eine testbezogene Filterung von `SPAWN.SpawnTemplate.units` erzeugt. Dadurch existieren zerstörte Slots auch nicht kurzzeitig in der neuen DCS-Gruppe. Diese konkrete Nutzung der vendorten MOOSE-Struktur muss im DCS-Lauf bestätigt werden.

Scheitert der Vollgruppenspawn nach bestätigter Entfernung des Proxyverbands, versucht der Controller, denselben Führungs-Slot als Einzelfahrzeug-Proxy wiederherzustellen.

## BLUE-Lagebild

Ein BLUE-Marker folgt in beiden Repräsentationen der aktuellen Führungsrolle:

```text
EXPANDED:        Marker am Führungsfahrzeug der Restgruppe
COLLAPSED_PROXY: Marker am allein fahrenden Führungsfahrzeug
```

Der Marker zeigt Repräsentationszustand, Reststärke und Führungs-Slot.

## Zielankunft

- Eine expandierte Gruppe gilt als angekommen, sobald die gesamte aktuelle Restgruppe in der Zielzone liegt.
- Erreicht der Proxy die Zielzone, wird automatisch ein Unpack ausgelöst.
- Die Restgruppe kommt damit in ihrer tatsächlichen verbliebenen Stärke an.

## Vorprüfungen

Durchgeführt:

- Lua-Syntaxprüfung aller neuen Quellen mit `texlua/loadfile`;
- Syntaxprüfung des erzeugten Bundles;
- gemockter Bootstrap bis `READY`;
- gemockter Start mit sechs Fahrzeugen;
- Pack auf ein Führungsfahrzeug;
- Unpack zurück auf sechs Fahrzeuge;
- Verlust von vorderstem und hinterstem Fahrzeug;
- erneuter Pack/Unpack-Zyklus mit exakt vier Überlebenden;
- Prüfung der Logereignisse `convoy_packed`, `convoy_unpacked` und `convoy_losses_observed`.

Mock-Ergebnis:

```text
PASS – final live survivors=4
```

Diese Prüfungen ersetzen keinen DCS-Lauf.

## Offene technische Risiken

1. DCS-Verhalten beim absichtlichen Entfernen einzelner Units während der Fahrt.
2. Stabilität der verbleibenden Einzelfahrzeuggruppe nach neuer Routenzuweisung.
3. Tatsächliches Verhalten der gefilterten `SPAWN.SpawnTemplate.units` in MOOSE 2.9.18.
4. Sichtbares Übergangsverhalten bei manuellem Unpack in unmittelbarer Beobachtungsnähe.
5. Verhalten auf Brücken, engen Kurven und problematischen Afghanistan-Straßenabschnitten.
6. Partielle Schäden werden derzeit nicht auf neu erzeugte Units übertragen; bestätigte Totalverluste dagegen schon.

## Nächster DCS-Test

Zuerst ohne Beschuss:

```text
Start
→ mehrere Minuten fahren
→ Pack
→ Proxyfahrt beobachten
→ Unpack
→ Vollgruppenfahrt beobachten
→ an mehreren Straßenabschnitten wiederholen
```

Danach Verlusttest gemäß `expected/proxy-pack-unpack-acceptance.md`.
