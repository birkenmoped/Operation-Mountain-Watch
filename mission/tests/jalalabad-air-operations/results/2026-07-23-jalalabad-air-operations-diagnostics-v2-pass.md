# Jalalabad Air Operations Diagnostics v2 – PASS

## Teststand

```text
Datum: 2026-07-23
DCS: 2.9.28.26283 MT
Quellcommit des eingebetteten Bundles: 95d7571a4806d1eea1e22bfe5372d26c14426cc9
Bundle-SHA-256: 396b52c35a9796dbfbcb9cbc9881d48d139effbadcdb3dd364e34cd31ddc5ac3
Missions-SHA-256: 618a07a5848cf47b991c8acebc0294f099551c83ccad53a632134a4e8ca44ad1
DCS-Log-SHA-256: 2b7d7e2cb46afc26da87a2708329a7fc109ea645bad823eab8eecd5902448769
Debrief-Log-SHA-256: ed92609fd23fa9a87d05b2341f269818e3d55c068544cdd23cd1c1bc3980f5eb
```

Die `.miz` enthielt `l10n/DEFAULT/OMW_AirOps_Jalalabad.lua` mit exakt dem oben genannten Bundle-Hash und dem erwarteten Quellcommit.

## Abgrenzung der zwei Läufe im selben `dcs.log`

Das hochgeladene `dcs.log` enthält zwei Missionsstarts derselben DCS-Sitzung:

```text
18:07 – Diagnostics v1; erwartete frühere STATIC-Fehler
18:20 – Diagnostics v2; korrigierter Retest
```

Die drei `Error in timer function`-Einträge um 18:07 gehören ausschließlich zum vorherigen v1-Lauf. Nach dem zweiten Missionsstart um 18:20 trat kein neuer Timerfehler mit Bezug auf `WH_AIR_US_JALALABAD` auf.

## Erfolgreiche Prüfpunkte

### Jalalabad und Parking

```text
Airbase=Jalalabad
ID=19
Category=Airdrome
Parking count=50
```

Alle 50 Parking-Einträge wurden im Retest als frei gemeldet.

### Warehouse- und Storage-API

Der erwartete leere Ausgangszustand wurde ohne Lua-Fehler verarbeitet:

```text
[OMW][ProbeWarehouseAnchor] STATIC found=false
[OMW][ProbeWarehouseAnchor] UNIT found=false
[OMW][ProbeWarehouseAnchor] Airbase found=true name=Jalalabad
[OMW][ProbeWarehouseAnchor] DCS warehouse call successful=true available=true
[OMW][ProbeWarehouseAnchor] MOOSE storage call successful=true available=true
[OMW][ProbeWarehouseAnchor] RESULT: No named MOOSE warehouse anchor. Place one mission-editor static named WH_AIR_US_JALALABAD
```

Damit sind sowohl das native DCS-Warehouse als auch der MOOSE-Storage für Jalalabad erreichbar. Für `AIRWING:New()` fehlt erwartungsgemäß nur noch ein benannter Mission-Editor-STATIC-/UNIT-Anker.

### Missionsobjekt-Validator

```text
GROUP  present=0 missing=16
STATIC present=0 missing=3
ZONE   present=0 missing=8
WAREHOUSE_ANCHOR MISSING WH_AIR_US_JALALABAD
```

Der Bootstrap beendete die Stufe kontrolliert:

```text
[OMW][AirOps.JBAD] Airbase OK: Jalalabad ID=19
[OMW][AirOps.JBAD] WAITING: Warehouse anchor missing: WH_AIR_US_JALALABAD
```

## Abnahmebewertung

```text
Bundle korrekt eingebettet:                  PASS
Jalalabad-Airbase erkannt:                   PASS
Parking-Dump vollständig ausgeführt:         PASS
DCS-Warehouse verfügbar:                     PASS
MOOSE-Storage verfügbar:                     PASS
Fehlender Warehouse-Anker ohne Lua-Fehler:   PASS
Bootstrap-Wartezustand ohne Lua-Fehler:       PASS
Gesamt:                                      PASS
```

## Freigabe des nächsten Testschritts

Die reine Diagnose des leeren Ausgangszustands ist abgeschlossen. Als nächste isolierte Stufe wird genau ein Mission-Editor-Static mit dem Namen `WH_AIR_US_JALALABAD` angelegt. Das vorhandene Bundle soll anschließend ausschließlich die AIRWING-Konstruktion und explizite Airbase-Zuordnung prüfen.

Noch nicht Bestandteil der nächsten Stufe:

- keine SQUADRON-Objekte,
- keine Flugzeugtemplates,
- keine Spieler-Slots,
- keine Statics des Luftfahrzeugbestands,
- keine AUFTRAG-Mission,
- kein AIRWING-Start,
- keine Bestands- oder Persistenzänderung.
