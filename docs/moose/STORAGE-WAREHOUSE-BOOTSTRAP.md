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

## 2. Implementierung und Packaging-Grenze

Zentraler Koordinator:

```text
scripts/logistics/OMW_AirOpsWarehouseBootstrap.lua
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

Der historische Acceptance-Builder bleibt ausschließlich Testinfrastruktur:

```text
tools/build-air-ops-warehouse-bootstrap.ps1
-> mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap.lua
```

Der normale Missionsstart darf dieses Acceptance-Artefakt nicht dauerhaft verwenden. Das separate Production-Packaging ist dokumentiert in:

```text
docs/moose/STORAGE-WAREHOUSE-PRODUCTION-BASE.md
```

mit:

```text
tools/build-air-ops-warehouse-production-base.ps1
-> mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
```

## 3. Strategische Datenbasis

Nicht-Fuel-Initialbestände bleiben in:

```text
scripts/logistics/OMW_AirOpsInitialStock.lua
```

Die MQ-1-AVGAS-Baseline bleibt in:

```text
scripts/logistics/OMW_AirOpsInitialFuelSupplement.lua
```

Kandahar AVGAS:

```text
Initial/Target  6,720 US gal = 20,270.13583056 kg
Reorder         4,000 US gal = 12,065.557042 kg
Critical        2,000 US gal =  6,032.778521 kg
```

Der abgeschlossene JP-8-Bestand wird ausdrücklich **nicht** neu berechnet oder dupliziert. Der produktive NEW-Pfad spiegelt nur Fuel-Ressourcen, die im autoritativen CampaignState tatsächlich vorhanden sind; ein künstlicher JP-8-Preservation-Wert bleibt auf die historische Acceptance-Fixture beschränkt.

Für den normalen Start vor der AAR Production Base muss derselbe einzelne `OMW.AirOps.CampaignContext` außerdem die bereits genehmigten `OMW_AARStrategicStock`-Off-map-Ressourcen enthalten. Diese sind reine CampaignState-Domänenressourcen und werden nicht nach STORAGE gespiegelt. Details stehen in `STORAGE-WAREHOUSE-PRODUCTION-BASE.md` und `OMW-ARCH-CAMPAIGN-STATE`.

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

Der zentrale Bootstrap erhält explizit die Fuel-Node-IDs, für die der autoritative CampaignState einen Fuel-Snapshot besitzt. Er erzeugt keine Ersatzwerte und keinen 100000-kg-Fallback.

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

Der zentrale Koordinator `OMW_AirOpsWarehouseBootstrap` ruft weder `CampaignState.New()` noch `CampaignState.Restore()` auf. Die Production-Orchestrierung darf genau einen neuen CampaignContext erzeugen, wenn beim Missionsstart noch keiner existiert, oder einen bereits bereitgestellten NEW-/RESTORE-Kontext wiederverwenden. Dadurch bleibt die Zustandsentscheidung eindeutig und es entsteht keine zweite Ressourcenhoheit.

## 6. Preflight und Fail-closed

Vor der ersten Mutation werden alle drei Bereiche geplant:

```text
strategische direkte Item-Mirrors
Fuel-Mirrors
TECHNICAL_NON_STRATEGIC Availability
```

Bekannte Blocker der vorhandenen Adapter bleiben wirksam, insbesondere nicht limitierte Weapon-Warehouses und fehlende/inkompatible Resource-Snapshots.

Nach dem Preflight verwenden die bestehenden Adapter weiterhin ihre eigene Validierung und direkten Readbacks. `READY` wird nur zurückgegeben, wenn strategische Item-, Fuel- und technische Writes als `verified=true` zurückkehren.

Für den dauerhaften Missionsstart ergänzt die Production Base das separate fail-closed Userflag:

```text
OMW_WAREHOUSE_READY = 0
-> Bootstrap erfolgreich und verifiziert
-> OMW_WAREHOUSE_READY = 1
```

Bei Bootstrap-/Readback-Fehler bleibt beziehungsweise wird das Flag `0`.

## 7. Ausdrücklich nicht implementiert

```text
kein produktiver Scheduler
kein periodisches Zurücksetzen auf Initialwerte
kein STORAGE -> CampaignState Reverse-Overwrite
keine eigene Ground-Crew-Rearm-/Refuel-Logik
keine erfundene M230-/GAU-8-/M3P-Storage-Konversion
keine automatische Fuel-Neuberechnung
keine automatische Persistenz
keine AIRWING-Missionserzeugung
kein Acceptance-Harness im Production-Bundle
```

## 8. MOOSE-First

MOOSE-Baseline:

```text
MOOSE 2.9.18
commit 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der Koordinator und die Production-Orchestrierung bilden nur eine kleine OMW-Schicht um bereits geprüfte MOOSE-STORAGE- und USERFLAG-Pfade. Sie implementieren keine MOOSE-Funktion parallel neu.

## 9. Abschlussgrenze

Die zugrunde liegende Warehouse-/STORAGE-Architektur besitzt dokumentierte Acceptance-Evidenz für den exakt getesteten historischen Stand. Das neue dauerhafte Production-Packaging ist davon getrennt zu verifizieren.

Für den neuen Production-Pfad gilt bis zum dokumentierten Smoke-Test:

```text
validated_in_dcs: false
```

Die Mission-Editor-Einbindung muss die Reihenfolge sicherstellen:

```text
Moose.lua
-> OMW_AirOps_Warehouse_Base.lua
-> OMW_WAREHOUSE_READY == 1
-> OMW_AAR_Base.lua
-> AIR-OPS Foundations
```

Eine `.miz` wird durch diesen Entwicklungsblock nicht automatisch verändert.
