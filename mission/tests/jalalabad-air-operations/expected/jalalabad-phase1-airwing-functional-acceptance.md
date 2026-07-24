# Jalalabad Phase 1 – AIRWING-/SQUADRON-Funktionsabnahme

## 1. Status

```text
Testpaket: IMPLEMENTED
DCS-Acceptance: PENDING
BuilderVersion: JBAD-AIR-OPS-PHASE1-1
```

Diese Abnahme ergänzt den bereits akzeptierten Jalalabad-Grundknoten. Sie validiert erstmals echte, direkt an `AW_US_JALALABAD` übergebene AUFTRAG-Missionen.

## 2. Teststeuerung

F10-Menü für BLUE:

```text
OMW AirOps Tests
└── Jalalabad Phase 1
    ├── Status anzeigen
    ├── Gesamtablauf starten
    ├── OH-58D RECON starten
    ├── AH-64D CAS starten
    ├── UH-60A Transport starten
    ├── CH-47F Cargo starten
    ├── Aktiven Auftrag abbrechen
    └── Testcontroller zuruecksetzen
```

Deterministische Lua-Schnittstelle:

```lua
OMW.AirOps.Jalalabad.Phase1.API.StartSequence()
OMW.AirOps.Jalalabad.Phase1.API.StartTest("OH58D_RECON")
OMW.AirOps.Jalalabad.Phase1.API.AbortActive()
OMW.AirOps.Jalalabad.Phase1.API.Status()
```

Es darf immer nur ein Phase-1-Auftrag aktiv sein.

## 3. Testfälle

### OH-58D RECON

```text
SQUADRON: SQ_US_JBAD_OH58D_6_6_CAV
Payload: OH58DRecon
Asset-Gruppen: 1
Luftfahrzeuge: 2
DCS-Typ: OH58D
AUFTRAG: RECON
```

Der Auftrag führt deterministisch durch drei Missionseditorzonen und darf nicht endlos oder zufällig wiederholt werden.

### AH-64D CAS

```text
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
Payload: AH64DCAS
Asset-Gruppen: 1
Luftfahrzeuge: 2
DCS-Typ: AH-64D_BLK_II
AUFTRAG: CAS
```

Das Testziel wird aus einem Late-Activation-Template gespawnt. Erfolg setzt die Vernichtung der Testzielgruppe voraus.

### UH-60A TROOPTRANSPORT

```text
SQUADRON: SQ_US_JBAD_UH60_UTILITY_MEDEVAC
Payload: UH60MedevacLead
Asset-Gruppen: 1
Luftfahrzeuge: 1
DCS-Typ: UH-60A
AUFTRAG: TROOPTRANSPORT
```

Die Truppengruppe wird in der Ladezone erzeugt und muss nachweislich die Entladezone erreichen. Der MEDEVAC-Cover-Payload wird nicht verwendet.

### CH-47F CARGOTRANSPORT

```text
SQUADRON: SQ_US_JBAD_CH47_HEAVYLIFT
Payload: CH47HeavyLift
Asset-Gruppen: 1
Luftfahrzeuge: 1
DCS-Typ: CH-47Fbl1
AUFTRAG: CARGOTRANSPORT
```

Der Auftrag verwendet ein natives DCS-Slingload-Cargo und eine im Missionseditor definierte Drop-Zone. Das Cargo muss vor dem Test in der Pickup-Zone und nach dem Test in der Drop-Zone liegen.

### UH-60A Abbruchtest

Ein zweiter UH-60A-TROOPTRANSPORT wird nach dem ersten bestätigten Birth-Ereignis automatisch abgebrochen. Das Luftfahrzeug darf nicht starten. Auftrag, Queueeintrag und Assetreservierung müssen vollständig freigegeben werden.

## 4. Bestandsprüfung

Erwartete MOOSE-Asset-Gruppen:

```text
OH-58D: 12
AH-64D: 4
UH-60A: 8
CH-47F: 8
```

Vor jedem Test müssen alle Asset-Gruppen frei sein und die AIRWING-Queue muss leer sein. Während eines Tests darf genau eine Asset-Gruppe des festgelegten SQUADRONs beschäftigt sein. Nach dem Test müssen drei aufeinanderfolgende Polls bestätigen:

```text
Queue = 0
requested = 0
spawned = 0
isReserved = 0
Bestand entspricht dem Vorher-Snapshot
```

## 5. Parking-Prüfung

Beim Birth-Ereignis wird für jedes Luftfahrzeug der nächstgelegene Jalalabad-Terminal ermittelt.

Unzulässig:

```text
23,35,37,49
```

Zusätzlich werden die sechs Clientpositionen aus `_DATABASE.Templates.Groups` geometrisch den DCS-Terminals zugeordnet. Kein dynamisches KI-Luftfahrzeug darf eine dieser Positionen verwenden.

Mindestabstand zum nächsten sichtbaren Aircraft-Static beim Spawn:

```text
12 Meter
```

## 6. Lebenszyklus

Ein regulärer Test ist nur PASS, wenn vollständig erkannt wurden:

```text
QUEUED
REQUESTED
SCHEDULED
Birth/Spawn
EngineStartup
Takeoff
STARTED
EXECUTING
fachliches Missionsziel
SUCCESS
RTB
Land in Jalalabad
Asset release
```

Die Events werden pro Einheit dedupliziert. Ein Two-Ship-Test benötigt jeweils zwei eindeutige Birth-, Engine-, Takeoff- und Landing-Ereignisse.

## 7. Gesamt-PASS

Erwartete Abschlussmeldung:

```text
[OMW][AirOps.JBAD.PH1] RESULT: PASS testsPassed=5/5 abortRelease=PASS unexpectedSpawns=0 parkingViolations=0 losses=0 blockedAssets=0 finalInventoryRestored=true
```

Zusätzliche Bedingungen:

- Grundknoten bleibt `OPERATIONAL`;
- Parking-Grundvalidator bleibt PASS;
- keine spontane oder zusätzliche KI-Gruppe;
- keine falsche Gruppengröße oder falscher DCS-Typ;
- kein relevanter OMW-Lua-/Timerfehler;
- kein dauerhaft blockiertes Asset.

## 8. Klassifikation

```text
PASS:
alle fünf Tests vollständig bestanden

PARTIAL:
Testlauf verwertbar, aber mindestens ein nicht sicher bewertbarer Teil

FAIL:
falscher Typ, falsches SQUADRON, Parking-Verstoß, Verlust, Lua-Fehler,
unbeabsichtigter Spawn, Mission FAIL/CANCEL oder nicht freigegebener Bestand
```

Jeder DCS-Lauf erhält einen eigenen Bericht unter `results/`.
