# Jalalabad Phase 1 – Missionseditor-Arbeitsliste

## 1. Testmissionsdatei

Der fehlgeschlagene Lauf bleibt unverändert erhalten. Für den nächsten Lauf ist eine neue Arbeitskopie zu verwenden:

```text
OMW_Jalalabad_AirOps_Phase1_ExactNames_Recovery_Test.miz
```

An den Missionseditorobjekten sind keine weiteren Änderungen erforderlich. Die neue Datei unterscheidet sich durch das eingebettete Bundle `JBAD-AIR-OPS-PHASE1-3`.

## 2. Technische AIRWING-Templates

Diese Gruppen bleiben unverändert:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Verbindlich:

- Late Activation bleibt aktiviert;
- die Templates stehen außerhalb aller operativen DCS-Parkpositionen;
- Gruppennamen und Namen jeder Templateeinheit bleiben eindeutig;
- die Two-Ship-Templates liefern weiterhin Typ, Payload und Livery;
- MOOSE erzeugt daraus bei OH-58D und AH-64D zwei unabhängige Single-Ship-DCS-Gruppen.

## 3. Exklusive KI-Parkplatzpools

```text
OH-58D: G01-G05 / TerminalIDs 19,43,6,5,48
AH-64D: F04-F06 / TerminalIDs 26,51,11
UH-60A: F01-F03 / TerminalIDs 10,8,1
CH-47F: C03-C10 / TerminalIDs 28,44,0,41,9,25,18,42
```

F04 beziehungsweise TerminalID 26 ist frei und Bestandteil des AH-64D-Pools.

## 4. Weiterhin gesperrte Staticpositionen

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

## 5. Vorhandene Funktions- und Testzonen

Funktionszonen:

```text
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Testzonen:

```text
ZONE_TEST_US_JBAD_RECON_01
ZONE_TEST_US_JBAD_RECON_02
ZONE_TEST_US_JBAD_RECON_03
ZONE_TEST_US_JBAD_CAS
```

## 6. Phase-1-Testobjekte

Unverändert erforderlich:

```text
TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET
TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS
TEST_CARGO_BLUE_JBAD_CH47_01
```

## 7. Eindeutige Namen

Die Teststeuerung identifiziert Runtimeeinheiten nicht mehr allein über den Luftfahrzeugtyp.

Verbindliches MOOSE-Laufzeitformat:

```text
Gruppe:  <SQUADRON-NAME>_AID-<Nummer>
Einheit: <GRUPPENNAME>-01
```

Client-, Player-, Template- und sonstige Missionseditorgruppen werden über ihre festen Namen ausgeschlossen. Diese Testgruppe bleibt insbesondere ausgeschlossen:

```text
TEST_TM01A_CLIENT_01
```

## 8. Eingebettete Skripte

Ladereihenfolge bei `MISSION START`:

```text
1. Moose.lua
2. OMW_AirOps_Jalalabad.lua
```

Erwarteter Bundlekopf:

```text
BuilderVersion: JBAD-AIR-OPS-PHASE1-3
```

## 9. Testreihenfolge

Nicht sofort den Gesamtablauf starten. Zunächst getrennte Validierung:

```text
1. Status anzeigen
2. OH-58D RECON als Einzeltest
3. Mission neu starten und Log prüfen
4. AH-64D CAS als Einzeltest
5. Mission neu starten und Log prüfen
6. erst nach beiden Einzel-PASS Gesamtablauf starten
```

Der CH-47-Cargotest bleibt pro Missionsstart einmalig verwendbar.

## 10. Erwartete Änderungen gegenüber dem fehlgeschlagenen Lauf

- `TEST_TM01A_CLIENT_01` wird nicht als AIRWING-Gruppe registriert;
- OH-58D und AH-64D spawnen als zwei voneinander unabhängige Single-Ship-Gruppen;
- beide Gruppen landen unabhängig;
- jede Gruppe despawnt nach ihrem eigenen Land-Ereignis;
- die Landefläche wird nicht durch einen wartenden Lead dauerhaft blockiert;
- Spawn-, Ausführungs-, Recovery- und Freigabe-Timeouts werden getrennt ausgewertet.
