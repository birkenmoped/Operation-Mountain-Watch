# TM01B – automatisches Reveal-Window-Caching

## Verbindlicher Ablauf

TM01B wird genau einmal über `F10 → OMW Tests → TM01B → Start convoy` gestartet.
Danach laufen virtuelle Bewegung, Materialisierung und Dematerialisierung automatisch.

```text
ZONE_TM01_START_BAGRAM
→ virtuelle Bewegung
→ ZONE_TM01_REVEAL_01_ENTRY
→ automatische Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 1
→ ZONE_TM01_REVEAL_01_EXIT
→ automatische Dematerialisierung
→ virtuelle Bewegung
→ ZONE_TM01_REVEAL_02_ENTRY
→ automatische Materialisierung
→ sichtbare Fahrt durch Reveal-Fenster 2
→ ZONE_TM01_REVEAL_02_EXIT
→ automatische Dematerialisierung
→ virtuelle Bewegung
→ ZONE_TM01_TARGET_JALALABAD
```

Es gibt im regulären Testablauf keine manuellen Befehle zum Materialisieren,
Dematerialisieren oder Starten einer physischen Teilroute.

## Route

Die autoritative Route bleibt:

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

Die Entry-Zone ist der genaue Materialisierungspunkt des jeweiligen sichtbaren
Fensters. Die Exit-Zone beendet die physische Teilroute. Start und Ziel bleiben
eigenständige autoritative Routenpunkte.

## Exit-Gate-Semantik

Eine Exit-Zone ist ein Durchfahrtstor, kein Parkplatz.

- Jeder aktuell überlebende Fahrzeugslot muss die Exit-Zone mindestens einmal betreten haben.
- Die Slots dürfen die Zone nacheinander passieren.
- Der gesamte Konvoi muss niemals gleichzeitig in der Zone stehen.
- Ein vor dem Exit zerstörter Slot blockiert den Übergang nicht.
- Sobald alle noch lebenden Slots das Tor passiert haben, startet die automatische Dematerialisierung.

Konfigurationswert:

```text
exitPassageMode = EACH_SURVIVING_SLOT_EVER_INSIDE
```

## Repräsentation

Während `VIRTUAL_MOVING` existiert keine physische DCS-Gruppe. Beim Entry wird
eine neue physische Generation aus den erhaltenen Fahrzeugslots erzeugt. Beim
Exit werden die überlebenden Slots vor dem Destroy-Aufruf übernommen.

Die native Gruppe muss nach `Destroy(false)` über `Group.getByName(...):isExist()`
als entfernt bestätigt werden, bevor der Zustand auf `VIRTUAL` wechselt.

## Abnahmekriterien

1. Konfigurationsversion `TM01B-controlled-caching-4` wird geladen.
2. Bootstrap meldet `READY`.
3. Das F10-Menü enthält `Start convoy`, `Show status` und `Validate configuration`.
4. Ein einziger Startbefehl startet den gesamten Ablauf.
5. Der Konvoi ist zwischen den Reveal-Fenstern virtuell und besitzt keine DCS-Gruppe.
6. Am ersten Entry erfolgt automatisch genau eine Materialisierung.
7. Die erste physische Route endet an `ZONE_TM01_REVEAL_01_EXIT`.
8. Nacheinander durchfahrende Fahrzeugslots werden dauerhaft für das Exit-Gate erfasst.
9. Nach Passage aller überlebenden Slots erfolgt automatisch die Dematerialisierung.
10. Nach nativer Entfernungsbestätigung beginnt automatisch die virtuelle Fahrt zum zweiten Entry.
11. Am zweiten Entry erfolgt automatisch eine neue physische Generation.
12. Verluste aus Fenster 1 bleiben in Generation 2 erhalten.
13. Nach dem zweiten Exit erfolgt automatisch die zweite Dematerialisierung.
14. Die Entität erreicht das Ziel virtuell mit `ARRIVED`.
15. `convoy_route_arrived` wird genau einmal protokolliert.
16. Zu keinem Zeitpunkt existieren zwei physische Generationen gleichzeitig.

## Nicht Bestandteil

- Persistenz über Missions- oder Serverneustart;
- Cargo- und Warehouse-Buchungen;
- Feindkontakte;
- Spielerentfernungs-, Sichtlinien- oder Sensorlogik;
- automatische Recovery, Teleport oder Routenneuberechnung;
- mehrere gleichzeitige Konvois.
