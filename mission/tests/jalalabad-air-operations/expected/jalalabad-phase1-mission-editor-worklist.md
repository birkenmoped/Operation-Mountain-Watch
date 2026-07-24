# Jalalabad Phase 1 – Missionseditor-Arbeitsliste

## 1. Aktuelle Testmission

Weiterzuverwenden ist:

```text
OMW_Jalalabad_AirOps_Phase1_ParkingPools_Test.miz
```

Die Datei wird für den nächsten Lauf nicht erneut umbenannt.

## 2. Technische AIRWING-Templates

Diese fünf Gruppen bleiben mit unveränderten Namen, Typen, Gruppengrößen, Liveries und Payloads erhalten:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Verbindlich:

- Late Activation bleibt aktiviert;
- die Templates stehen auf einer technischen Fläche außerhalb aller funktionalen DCS-Parkpositionen;
- sie erhalten keine operativen Parkplätze;
- der tatsächliche KI-Startzustand wird durch `SQUADRON:SetTakeoffCold()` festgelegt;
- die tatsächlichen Spawnplätze werden ausschließlich durch `SQUADRON:SetParkingIDs()` festgelegt.

Der Validator verlangt mindestens 100 Meter Abstand jeder Templateeinheit zum nächsten DCS-Parking-Node.

## 3. Exklusive KI-Parkplatzpools

### OH-58D

```text
G01 -> TerminalID 19
G02 -> TerminalID 43
G03 -> TerminalID 6
G04 -> TerminalID 5
G05 -> TerminalID 48
```

### AH-64D

```text
F04 -> TerminalID 26
F05 -> TerminalID 51
F06 -> TerminalID 11
```

### UH-60A

```text
F01 -> TerminalID 10
F02 -> TerminalID 8
F03 -> TerminalID 1
```

### CH-47F

```text
C03 -> TerminalID 28
C04 -> TerminalID 44
C05 -> TerminalID 0
C06 -> TerminalID 41
C07 -> TerminalID 9
C08 -> TerminalID 25
C09 -> TerminalID 18
C10 -> TerminalID 42
```

Diese Pools sind typgebunden und überschneiden sich nicht. Ein SQUADRON darf nicht auf einen allgemeinen Jalalabad-Parkplatz ausweichen. Ist sein Pool nicht ausreichend verfügbar, muss der Auftrag warten oder kontrolliert fehlschlagen.

## 4. Unverändert gesperrte CH-47-Staticpositionen

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

Diese vier TerminalIDs bleiben blacklisted und dürfen in keinem SQUADRON-Pool auftauchen.

F04 beziehungsweise TerminalID 26 ist in der aktuellen Testmission frei und gehört zum AH-64D-Pool.

## 5. Entfernte Grundzonen

Folgende früheren Darstellungs- oder Templatezonen sind nicht mehr Bestandteil der Mission und dürfen nicht wieder angelegt werden:

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
```

## 6. Verbleibende Funktionszonen

```text
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Zusätzlich bleiben die vier Phase-1-Testzonen bestehen:

```text
ZONE_TEST_US_JBAD_RECON_01
ZONE_TEST_US_JBAD_RECON_02
ZONE_TEST_US_JBAD_RECON_03
ZONE_TEST_US_JBAD_CAS
```

## 7. Phase-1-Testobjekte

Unverändert erforderlich:

```text
TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET
TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS
TEST_CARGO_BLUE_JBAD_CH47_01
```

Dabei gilt:

- CAS-Zieltemplate: RED, Late Activation, leichte Fahrzeuge, innerhalb der CAS-Zone;
- UH-60-Truppentemplate: BLUE/USA, Late Activation, innerhalb der Logistik-Ladezone;
- CH-47-Cargo: natives DCS-Slingload-Cargo innerhalb der Pickup-Zone und außerhalb der Entladezone.

Das CH-47-Cargo ist pro Missionsstart nur einmal vollständig verwendbar.

## 8. Trigger und Bundle

Reihenfolge bei `MISSION START`:

```text
1. DO SCRIPT FILE -> Moose.lua
2. DO SCRIPT FILE -> OMW_AirOps_Jalalabad.lua
```

Nach jedem Neubau:

1. `OMW_AirOps_Jalalabad.lua` erneut auswählen;
2. Mission speichern;
3. Buildkopf auf `JBAD-AIR-OPS-PHASE1-2` prüfen;
4. Mission starten;
5. zuerst den F10-Status anzeigen;
6. danach den angeordneten Einzel- oder Gesamttest starten.

## 9. Erwartete Parkplatzvorprüfung

Vor dem AIRWING-Start wird erwartet:

```text
[OMW][AirOps.JBAD.PARKING-POOLS] RESULT: PASS pools=OH58D:5/AH64D:3/UH60:3/CH47:8 templatesOffParking=true poolOverlap=0 clientOverlap=0 blacklistOverlap=0 staticClearance=PASS
```

Ein Spawn außerhalb des zum SQUADRON gehörenden Pools ist ein harter Testfehler.

## 10. Übergabe nach dem Test

Standardmäßig genügt die neue `dcs.log`.

Die `.miz` ist zusätzlich erforderlich bei:

- nicht auflösbaren TerminalIDs;
- Parking-Pool- oder Static-Abstandsfehlern;
- fehlenden Missionseditorobjekten;
- Cargo-/Transportproblemen;
- nicht erklärbaren Laufzeitfehlern;
- finaler Meilensteinabnahme.
