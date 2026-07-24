# Jalalabad Phase 1 – Missionseditor-Arbeitsliste

## 1. Ausgangsbasis

Zu verwenden ist eine Kopie der validierten Jalalabad-Testmission. Die bestehenden Clientgruppen, AIRWING-Templates, Statics, Warehouse-Objekte und elf Grundzonen bleiben unverändert.

Insbesondere nicht verändern:

```text
STATIC_AIR_US_JBAD_CH47_01 -> TerminalID 49
STATIC_AIR_US_JBAD_CH47_02 -> TerminalID 37
STATIC_AIR_US_JBAD_CH47_03 -> TerminalID 23
STATIC_AIR_US_JBAD_CH47_04 -> TerminalID 35
```

## 2. Neue RECON-Zonen

Anlegen:

```text
ZONE_TEST_US_JBAD_RECON_01
ZONE_TEST_US_JBAD_RECON_02
ZONE_TEST_US_JBAD_RECON_03
```

Vorgaben:

- außerhalb des Flugplatzbereichs,
- in sinnvoller Reihenfolge entlang einer kurzen Route,
- ungefähr 12 bis 25 km von Jalalabad entfernt,
- keine Überlagerung mit der CAS-Zone,
- Radius ungefähr 500 bis 1000 m,
- keine zufällige Reihenfolge im Skript.

## 3. CAS-Testbereich

Zone:

```text
ZONE_TEST_US_JBAD_CAS
```

Zieltemplate:

```text
Gruppe: TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET
Koalition: RED
Late Activation: aktiviert
Uncontrolled: nicht relevant
```

Empfehlung:

- zwei bis vier ungepanzerte oder leicht gepanzerte Fahrzeuge,
- keine SAM- oder AAA-Einheit,
- Gruppe vollständig innerhalb der CAS-Zone,
- keine anderen RED-Gruppen in der unmittelbaren Umgebung,
- Entfernung ungefähr 15 bis 25 km von Jalalabad.

Das Template wird nicht manuell aktiviert. Das Phase-1-Bundle erzeugt für den Test einen Spawn daraus.

## 4. UH-60-Truppentemplate

Anlegen:

```text
Gruppe: TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS
Koalition: BLUE
Land: USA
Late Activation: aktiviert
```

Empfehlung:

- eine kleine Infanteriegruppe,
- Templateposition vollständig innerhalb von `ZONE_AIR_US_JBAD_LOGISTICS_LOAD`,
- ebener, hindernisfreier Landeplatz,
- ausreichend Abstand zu Statics, Fahrzeugen und Gebäuden.

Das Template wird durch das Bundle gespawnt und anschließend als `TROOPTRANSPORT`-Fracht verwendet.

## 5. CH-47-Cargo

Anlegen:

```text
Static-/Cargoname: TEST_CARGO_BLUE_JBAD_CH47_01
Koalition: BLUE
Cargo: als natives DCS-Slingload-Cargo konfiguriert
```

Position:

```text
innerhalb ZONE_AIR_US_JBAD_SLING_PICKUP
außerhalb ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
```

Vorgaben:

- für CH-47 realistisch transportierbare Masse,
- keine Kollision mit Ramp-, Client-, KI- oder Rollpositionen,
- keine direkte Nähe zu den blackgelisteten CH-47-Statics,
- Drop-Zone muss eine echte Missionseditorzone bleiben, weil der DCS-Cargo-Task deren Zone-ID benötigt.

Das Cargo ist innerhalb eines Missionsstarts nur einmal verwendbar. Nach erfolgreicher Lieferung ist für einen vollständigen Wiederholungslauf ein Missionsneustart erforderlich.

## 6. Bestehende Lade-/Entladezonen prüfen

```text
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
```

Prüfen:

- Radius,
- Gefälle und Bodenbeschaffenheit,
- Rotorfreiheit,
- keine Gebäude oder Leitungen,
- keine Überschneidung mit aktiven Park- oder Rollflächen,
- ausreichender Abstand zwischen Pickup und Dropoff.

## 7. Trigger und Bundle

Keine zusätzliche Kette aus Einzeltriggern anlegen.

Reihenfolge bei `MISSION START`:

```text
1. DO SCRIPT FILE -> Moose.lua
2. DO SCRIPT FILE -> OMW_AirOps_Jalalabad.lua
```

Nach jedem Neubau:

1. `OMW_AirOps_Jalalabad.lua` erneut auswählen,
2. Mission speichern,
3. Buildkopf auf `JBAD-AIR-OPS-PHASE1-1` prüfen,
4. Mission starten,
5. F10-Menü `OMW AirOps Tests -> Jalalabad Phase 1` verwenden.

## 8. Erste Übergabe nach dem Test

Standardmäßig wird nur die neue `dcs.log` benötigt.

Zusätzlich `.miz`, Debrief oder Screenshots nur bei:

- fehlenden Phase-1-Missionseditorobjekten,
- nicht auflösbaren Client-TerminalIDs,
- Parking- oder Spawnproblemen,
- Cargo-/Transportproblemen,
- nicht erklärbaren Laufzeitfehlern,
- finaler Meilensteinabnahme.
