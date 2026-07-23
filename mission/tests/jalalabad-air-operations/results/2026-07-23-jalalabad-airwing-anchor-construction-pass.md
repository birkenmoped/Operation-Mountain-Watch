# Jalalabad AIRWING Anchor Construction – PASS

## Testlauf

```text
Datum: 2026-07-23
DCS: 2.9.28.26283 MT
Testfenster im dcs.log: 18:41:43 bis 18:42:20 UTC
Warehouse-Anker: WH_AIR_US_JALALABAD
AIRWING: AW_US_JALALABAD
```

## Ergebnis

Der zuvor fehlende Mission-Editor-Static wurde unter dem exakten Namen `WH_AIR_US_JALALABAD` gespeichert und von MOOSE gefunden.

```text
[OMW][ProbeWarehouseAnchor] STATIC found=true
[OMW][ProbeWarehouseAnchor] UNIT found=false
[OMW][ProbeWarehouseAnchor] STATIC coalition=Blue country=USA x=72538.9 y=561.0 z=389998.0
[OMW][ProbeWarehouseAnchor] Airbase found=true name=Jalalabad
[OMW][ProbeWarehouseAnchor] DCS warehouse call successful=true available=true
[OMW][ProbeWarehouseAnchor] MOOSE storage call successful=true available=true
[OMW][ProbeWarehouseAnchor] RESULT: Named anchor exists. AIRWING construction test may proceed.
```

Der Missionsobjekt-Validator bestätigte den Anker:

```text
[OMW][ValidateMissionTemplates] WAREHOUSE_ANCHOR OK WH_AIR_US_JALALABAD
```

Anschließend wurde das AIRWING ohne Lua-Fehler konstruiert und explizit Jalalabad zugeordnet:

```text
WAREHOUSE AW_US_JALALABAD | Adding warehouse v2.0.0 for structure WH_AIR_US_JALALABAD [isUnit=false, isShip=false]
[OMW][AirOps.JBAD] Airbase OK: Jalalabad ID=19
[OMW][AirOps.JBAD] AIRWING constructed and explicitly linked. Not started in validation stage.
```

## Abnahme

```text
Static unter exaktem Namen gefunden:         PASS
Coalition BLUE / Country USA:                PASS
Jalalabad als Airbase ID 19 erkannt:         PASS
DCS-Warehouse erreichbar:                    PASS
MOOSE-Storage erreichbar:                    PASS
AIRWING:New ohne Fehler:                     PASS
SetAirbase ohne Fehler:                      PASS
AIRWING nicht gestartet:                     PASS
Unbeabsichtigter Flugzeugspawn:              keiner
Gesamt:                                      PASS
```

Der beim Beenden gemeldete Fehler aus `Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua` betrifft einen externen DCS-Hook und nicht das Jalalabad-AirOps-Bundle.

## Freigabe des nächsten Schritts

Als nächste isolierte Stufe wird genau ein zweischiffiges, spät aktiviertes OH-58D-KI-Template angelegt. Das Bundle konstruiert daraus ein `SQUADRON` für den Gesamtbestand von 24 OH-58D.

Da `SQUADRON:New()` die Anzahl der **Asset-Gruppen** erwartet, entsprechen bei einem 2-Ship-Template:

```text
24 Luftfahrzeuge / 2 Luftfahrzeuge je Asset-Gruppe = 12 Asset-Gruppen
```

Noch nicht Bestandteil der nächsten Stufe:

- kein `AIRWING:Start()`,
- kein `COMMANDER`,
- keine `AUFTRAG`-Mission,
- kein Payload-Pool,
- keine Spieler-Slots,
- keine statischen Luftfahrzeuge,
- kein tatsächlicher Spawn.
