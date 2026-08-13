# AirOps Warehouse Bootstrap Acceptance

## Ziel

Dieser Test prueft den zentralen produktiven Warehouse-Bootstrap gegen die aktuelle AirOps-Stock-Baseline. Abgeschlossene Bestandsentscheidungen werden nicht neu berechnet.

## Test-ID

```text
AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1
```

## Source / Builder / Dist

```text
mission/tests/air-ops-warehouse-bootstrap/src/01-air-ops-warehouse-bootstrap-acceptance.lua
tools/build-air-ops-warehouse-bootstrap.ps1
mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap_Acceptance.lua
```

`dist/` wird ausschliesslich durch den Builder erzeugt.

## Produktive Module

Der Builder bettet CampaignState, ResourceManifest, InitialStock, AVGAS-Supplement, CampaignState-Initializer, STORAGE-Initializer, Technical-Availability, Fuel-Adapter, Fuel-Sync und Warehouse-Bootstrap ein.

## Fuel-Grenze

JP-8 wird nicht neu berechnet. Kandahar Main uebernimmt fuer dieses Gate den vor Testbeginn vorhandenen JETFUEL-Wert einmalig als Test-Preservation-Fixture. Diese Fixture ist nur Testaufbau und keine produktive Rueckautoritaet.

Der neue AVGAS-Wert bleibt:

```text
KANDAHAR_MAIN / FUEL_AVGAS
Initial/Target: 20,270.13583056 kg
Reorder:        12,065.557042 kg
Critical:        6,032.778521 kg
```

## Erwartete Marker

```text
START
JP8_PRESERVATION_FIXTURE
NEW_PREFLIGHT_PASS
NEW_APPLY_PASS
RESTORE_PASS
RESULT status=PASS
```

`NEW_APPLY_PASS` verlangt verifizierte strategische Item-, Fuel- und Technical-Availability-Readbacks sowie `status=READY`. AVGAS muss auf den freigegebenen Wert geschrieben werden; der erhaltene Kandahar-JP-8-Wert darf sich nicht aendern.

`RESTORE_PASS` verlangt anschliessend:

```text
strategicChanges=0
fuelChanges=0
technicalChanges=0
initialReset=false
status=READY
```

## MIZ-Einbindung

Gemass `docs/22-test-mission-build-transfer-and-validation-workflow.md`:

```text
1. Moose.lua
2. OMW_AirOps_Warehouse_Bootstrap_Acceptance.lua
```

Das Acceptance-Bundle enthaelt alle fuer dieses Gate benoetigten OMW-Module. Vor dem DCS-Lauf muessen Branch/Commit, BuilderVersion, GeneratedUtc, Bundle-Hash, MIZ-Hash, interner mission-Hash, eingebetteter Bundle-Hash, eingebetteter Moose.lua-Hash und der Objektvertrag der sieben AirOps-STORAGE-Endpunkte feststehen.

## Status

```text
Source/Builder: IMPLEMENTED
Local build/hash: PENDING for revised acceptance bundle
DCS runtime: NOT_RUN
Acceptance: NOT_VALIDATED
```
