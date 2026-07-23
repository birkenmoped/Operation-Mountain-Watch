# Jalalabad AIRWING Anchor Construction – Mission Editor Setup and Acceptance

## Zweck

Diese Stufe prüft ausschließlich, ob ein einzelner benannter Mission-Editor-Static als MOOSE-Warehouse-Anker akzeptiert wird und ob anschließend `AIRWING:New()` mit expliziter Zuordnung zu Jalalabad konstruiert werden kann.

Das AIRWING wird in dieser Stufe nicht gestartet.

## Ausgangsbasis

Verwende weiterhin:

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
```

Das bereits eingebettete Bundle aus Quellcommit

```text
95d7571a4806d1eea1e22bfe5372d26c14426cc9
```

ist für diesen Test unverändert verwendbar. Es ist kein neuer Lua-Build erforderlich, solange die eingebettete Datei nicht entfernt oder ersetzt wurde.

## Einzige Änderung im Mission Editor

Lege genau ein normales statisches Objekt an:

```text
Coalition: BLUE
Country: USA
Object class: Static Object
Unit name: WH_AIR_US_JALALABAD
```

Für diesen Konstruktionsversuch ist das sichtbare Modell nicht fachlich relevant. Verwende ein kleines gewöhnliches Gebäude- oder Containerobjekt.

Nicht verwenden:

- kein statisches Flugzeug oder statischer Hubschrauber,
- kein FARP-/Helipad-Objekt,
- kein Cargo-/Slingload-Objekt,
- keine aktive Fahrzeugeinheit.

Platzierung:

- innerhalb des Jalalabad-Flugplatzbereichs,
- möglichst in einem vorhandenen Logistik-/Versorgungsbereich,
- nicht auf Runway, Taxiway oder operativer Parkposition,
- höchstens ungefähr 3 km vom Flugplatzbezugspunkt entfernt.

Die Mission danach unter demselben Testnamen speichern.

## Unverändert lassen

Noch nicht anlegen:

```text
CLIENT_US_JBAD_...
TPL_AIR_US_JBAD_...
STATIC_AIR_US_JBAD_...
ZONE_AIR_US_JBAD_...
```

Das vorhandene `TM02W2F.lua` darf parallel geladen bleiben.

## Testdurchführung

1. Mission starten.
2. Mindestens 15 Sekunden laufen lassen.
3. Mission beenden.
4. `.miz` und `dcs.log` bereitstellen.

`debrief.log` ist für diesen Schritt nicht erforderlich.

## Erwartete Diagnose

```text
[OMW][ProbeWarehouseAnchor] STATIC found=true
[OMW][ProbeWarehouseAnchor] UNIT found=false
[OMW][ProbeWarehouseAnchor] Airbase found=true name=Jalalabad
[OMW][ProbeWarehouseAnchor] DCS warehouse call successful=true available=true
[OMW][ProbeWarehouseAnchor] MOOSE storage call successful=true available=true
[OMW][ProbeWarehouseAnchor] RESULT: Named anchor exists. AIRWING construction test may proceed.
```

Der Validator muss melden:

```text
[OMW][ValidateMissionTemplates] WAREHOUSE_ANCHOR OK WH_AIR_US_JALALABAD
```

Der Bootstrap muss abschließen mit:

```text
[OMW][AirOps.JBAD] Airbase OK: Jalalabad ID=19
[OMW][AirOps.JBAD] AIRWING constructed and explicitly linked. Not started in validation stage.
```

## PASS-Kriterien

- der Static wird von MOOSE unter exakt `WH_AIR_US_JALALABAD` gefunden;
- das Objekt besitzt BLUE-/USA-Zuordnung;
- Jalalabad bleibt als Airbase ID 19 erkannt;
- `AIRWING:New()` erzeugt keinen Lua-Fehler;
- `SetAirbase()` erzeugt keinen Lua-Fehler;
- das abschließende AIRWING-Erfolgslog erscheint;
- es wird kein Flugzeug gespawnt und kein Auftrag gestartet.

## FAIL-Kriterien

- Static nicht gefunden;
- falscher Objektname oder falsche Coalition;
- `WAREHOUSE:New`, `AIRWING:New` oder `SetAirbase` wirft einen Fehler;
- unbeabsichtigter AIRWING-Start;
- unbeabsichtigter Spawn oder Bestandszugriff.
