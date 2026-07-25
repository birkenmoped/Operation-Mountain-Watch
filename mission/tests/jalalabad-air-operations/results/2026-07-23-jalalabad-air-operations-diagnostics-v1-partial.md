# Jalalabad Air Operations Diagnostics v1 – PARTIAL / RETEST REQUIRED

## Teststand

```text
Datum: 2026-07-23
DCS: 2.9.28.26283 MT
Quellcommit des eingebetteten Bundles: 69c037beb94bc38befb3eff78021e42da2f51d5c
Bundle-SHA-256: 7b754cd8f964a868b65b95c62b01c5c1891abf01160ebc72f5d20e0d3995036a
Missions-SHA-256: b92f70b5ac1e2506ee05e6a30a0321db08cc088b2ae84a022cef6dc7316cc81f
DCS-Log-SHA-256: 35bc0cd7746aa438774e7b9ec1b62a0bc8757551e3432738c04146a34f07e176
```

Die in der `.miz` eingebettete Datei `l10n/DEFAULT/OMW_AirOps_Jalalabad.lua` hatte exakt den erwarteten Bundle-Hash.

## Erfolgreiche Prüfpunkte

### Jalalabad-Airbase

MOOSE erkannte den Flugplatz eindeutig:

```text
Airbase=Jalalabad
ID=19
Category=Airdrome
```

Der Air-Ops-Bootstrap bestätigte ebenfalls `Jalalabad ID=19`.

### Parking-Dump

`AIRBASE:GetParkingSpotsTable()` lieferte 50 Einträge. Alle waren zum Testzeitpunkt als frei gemeldet.

Verteilung der von MOOSE gemeldeten Terminaltypen:

```text
TerminalType 40:  28 Einträge
TerminalType 72:   6 Einträge
TerminalType 104: 16 Einträge
Gesamt:            50 Einträge
```

Die Terminal-IDs lagen zwischen 0 und 51; die IDs 7 und 34 waren nicht Bestandteil der zurückgegebenen Parking-Tabelle.

### Erwarteter leerer Ausgangszustand

Der Validator bestätigte den noch nicht aufgebauten Air-Ops-Zustand:

```text
GROUP  present=0 missing=16
STATIC present=0 missing=3
ZONE   present=0 missing=8
```

`DumpAircraftTypes.lua` fand erwartungsgemäß noch keine passenden Template-Gruppen:

```text
Matching template groups=0
```

## Fehlerbild

Der Lauf ist kein vollständiger PASS, weil drei erwartete Abfragen nach dem noch nicht vorhandenen Warehouse-Static einen MOOSE-Fehler auslösten:

```text
STATIC not found for: WH_AIR_US_JALALABAD
```

Betroffene Bundle-Zeilen beziehungsweise Quellen:

```text
01-jalalabad-bootstrap.lua
03-probe-warehouse-anchor.lua
05-validate-mission-templates.lua
```

Ursache: `STATIC:FindByName(name)` verwendet in der festgeschriebenen MOOSE-Version standardmäßig `RaiseError=true`. Das Fehlen des Warehouse-Ankers ist in Stufe 1 jedoch ein normaler und erwarteter Zustand.

Dadurch wurden folgende erwartete Diagnoseausgaben nicht vollständig erreicht:

- kontrolliertes `WAITING: Warehouse anchor missing`,
- vollständige Warehouse-/Storage-Abfrage,
- abschließendes `WAREHOUSE_ANCHOR MISSING` ohne Timer-Fehler.

## Korrektur

Die drei Static-Abfragen wurden auf den von MOOSE vorgesehenen nichtfehlerwerfenden Modus geändert:

```lua
STATIC:FindByName(name, false)
```

Korrigierter Branchstand nach der letzten Änderung:

```text
65aeed2473d609db2b75e7ede46139df5fa01590
```

## Abnahmebewertung

```text
Bundle korrekt eingebettet:                  PASS
Jalalabad-Airbase erkannt:                   PASS
Parking-Dump vollständig ausgeführt:         PASS
Leerer Gruppen-/Static-/Zonenstand erkannt:  PASS
Warehouse-Probe ohne Lua-Fehler:             FAIL
Bootstrap-Wartezustand ohne Lua-Fehler:       FAIL
Gesamt:                                      PARTIAL / RETEST REQUIRED
```

## Nächster Lauf

1. Branch auf den aktuellen Stand aktualisieren.
2. Bundle lokal neu bauen.
3. `OMW_AirOps_Jalalabad.lua` im Mission Editor erneut auswählen.
4. `.miz` speichern.
5. Noch keinen Warehouse-Anker und keine Air-Ops-Gruppen anlegen.
6. Mission mindestens 15 Sekunden laufen lassen.

Erwartetes Retest-Ergebnis:

```text
[OMW][ProbeWarehouseAnchor] STATIC found=false
[OMW][ProbeWarehouseAnchor] UNIT found=false
[OMW][ProbeWarehouseAnchor] Airbase found=true name=Jalalabad
[OMW][ProbeWarehouseAnchor] RESULT: No named MOOSE warehouse anchor ...
[OMW][ValidateMissionTemplates] WAREHOUSE_ANCHOR MISSING WH_AIR_US_JALALABAD
[OMW][AirOps.JBAD] WAITING: Warehouse anchor missing: WH_AIR_US_JALALABAD
```

Es darf dabei kein `Error in timer function` mit Bezug auf `WH_AIR_US_JALALABAD` mehr auftreten.
