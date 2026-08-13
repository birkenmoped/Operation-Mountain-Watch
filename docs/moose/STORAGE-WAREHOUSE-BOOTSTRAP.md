---
document_id: OMW-MOOSE-AIROPS-WAREHOUSE-BOOTSTRAP
status: BINDING
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - central one-shot assembly of AirOps Warehouse resource initialization
  - ordering between authoritative CampaignState, STORAGE mirrors and AirOps start
  - NEW and RESTORE Warehouse bootstrap semantics
not_authoritative_for:
  - strategic stock recalculation
  - replacement of the closed JP-8 baseline
  - DCS runtime acceptance before a documented run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AirOps Warehouse Bootstrap

## 1. Zweck

Dieser Baustein schließt die bisher getrennten Warehouse-/Resource-Initialisierer zu einem zentralen, einmaligen Startpfad zusammen. Er berechnet keine Bestände neu und eröffnet keine abgeschlossene Fuel- oder Store-Entscheidung erneut.

Produktiver Vertrag:

```text
autoritativer CampaignState (NEW oder RESTORE)
        |
        +-> strategische Item-Preflight
        +-> Fuel-Preflight über bestehenden Fuel-Sync
        +-> technische Availability-Preflight
        |
        v
alle Preflights bestanden
        |
        +-> strategische Item-Mirrors schreiben + Readback
        +-> Fuel-Mirrors schreiben + Readback
        +-> technische Availability schreiben + Readback
        |
        v
WarehouseBootstrap status=READY
        |
        v
AirOps AIRWING-Start darf folgen
```

## 2. Implementierung

Zentraler Koordinator:

```text
scripts/logistics/OMW_AirOpsWarehouseBootstrap.lua
```

Builder:

```text
tools/build-air-ops-warehouse-bootstrap.ps1
```

Generiertes Artefakt:

```text
mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap.lua
```

Der Koordinator verwendet ausschließlich die bereits vorhandenen OMW-Adapter:

```text
OMW_AirOpsStorageInitializer
OMW_CampaignStateStorageSync
OMW_StorageFuelAdapter
OMW_AirOpsTechnicalAvailabilityInitializer
OMW_AirOpsResourceManifest
OMW_AirOpsTechnicalAvailability
```

Es wird keine neue MOOSE-Klasse und keine neue MOOSE-Methode eingeführt.

## 3. Strategische Datenbasis

Nicht-Fuel-Initialbestände bleiben in:

```text
scripts/logistics/OMW_AirOpsInitialStock.lua
```

Die neu ergänzte MQ-1-AVGAS-Baseline bleibt in:

```text
scripts/logistics/OMW_AirOpsInitialFuelSupplement.lua
```

Kandahar AVGAS:

```text
Initial/Target  6,720 US gal = 20,270.13583056 kg
Reorder         4,000 US gal = 12,065.557042 kg
Critical        2,000 US gal =  6,032.778521 kg
```

Der abgeschlossene JP-8-Bestand wird ausdrücklich **nicht** in diesem Branch neu berechnet oder dupliziert. Der Bootstrap konsumiert den bereits autoritativ aufgebauten beziehungsweise wiederhergestellten CampaignState. Damit bedeutet „nicht erneut in PR #86 definiert“ nicht „im Projekt fehlend“.

## 4. Fuel-Vertrag

Der bestehende Pfad bleibt unverändert:

```text
CampaignState
-> OMW_CampaignStateStorageSync
-> OMW_StorageFuelAdapter
-> MOOSE STORAGE
-> DCS Warehouse
```

Mappings:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Der zentrale Bootstrap erhält explizit die Fuel-Node-IDs, für die der autoritative CampaignState einen vollständigen Fuel-Snapshot besitzt. Er erzeugt keine Ersatzwerte und keinen 100000-kg-Fallback.

## 5. NEW und RESTORE

`NEW` bedeutet:

```text
CampaignState wurde aus den freigegebenen Initialdaten aufgebaut
-> WarehouseBootstrap spiegelt diesen Zustand einmalig nach STORAGE
```

`RESTORE` bedeutet:

```text
CampaignState wurde aus einem Snapshot wiederhergestellt
-> WarehouseBootstrap spiegelt den wiederhergestellten Zustand einmalig nach STORAGE
-> Initialwerte werden nicht erneut über den Restore geschrieben
```

Der Koordinator selbst ruft weder `CampaignState.New()` noch `CampaignState.Restore()` auf. Dadurch bleibt die Zustandsentscheidung beim CampaignState-Lifecycle und es entsteht keine zweite Ressourcenhoheit.

## 6. Preflight und Fail-closed

Vor der ersten Mutation werden alle drei Bereiche geplant:

```text
strategische direkte Item-Mirrors
Fuel-Mirrors
TECHNICAL_NON_STRATEGIC Availability
```

Bekannte Blocker der vorhandenen Adapter bleiben wirksam, insbesondere nicht limitierte Weapon-Warehouses und fehlende/inkompatible Resource-Snapshots.

Nach dem Preflight verwenden die bestehenden Adapter weiterhin ihre eigene Validierung und direkten Readbacks. `READY` wird nur zurückgegeben, wenn strategische Item-, Fuel- und technische Writes als `verified=true` zurückkehren.

## 7. Ausdrücklich nicht implementiert

```text
kein Scheduler
kein periodisches Zurücksetzen auf Initialwerte
kein STORAGE -> CampaignState Reverse-Overwrite
keine eigene Ground-Crew-Rearm-/Refuel-Logik
keine erfundene M230-/GAU-8-/M3P-Storage-Konversion
keine automatische Fuel-Neuberechnung
keine automatische Persistenz
keine AIRWING-Missionserzeugung
```

## 8. MOOSE-First

MOOSE-Baseline:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der Koordinator fügt nur eine kleine OMW-Orchestrierungsschicht um bereits geprüfte MOOSE-STORAGE-Adapter hinzu. Er implementiert keine MOOSE-Funktion parallel neu.

## 9. Abschlussgrenze

Mit diesem Baustein ist die **Code-Architektur für die zentrale Initial-Warehouse-Stock-Initialisierung zusammengesetzt**. Für `VALIDATED` fehlt anschließend noch der dokumentierte Build-/Hash-/DCS-Nachweis des exakt erzeugten Bundles und der tatsächlich verwendeten MIZ.

Die Mission-Editor-Einbindung muss die Reihenfolge sicherstellen:

```text
Moose.lua
-> CampaignState und Logistics-Module
-> CampaignState NEW/RESTORE bereit
-> OMW_AirOpsWarehouseBootstrap.Apply(...)
-> nur bei status=READY: AirOps Foundations starten
```

Eine `.miz` wird durch diesen Commit nicht automatisch verändert.
