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
  - future strategic stock recalculation beyond approved baselines
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

Dieser Baustein schließt die Warehouse-/Resource-Initialisierer zu einem zentralen, einmaligen Startpfad zusammen. Er berechnet keine Bestände zur Laufzeit neu. Freigegebene Initialdaten werden von CampaignState übernommen und einmalig nach MOOSE/DCS STORAGE gespiegelt.

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

Verwendete OMW-Adapter:

```text
OMW_AirOpsStorageInitializer
OMW_CampaignStateStorageSync
OMW_StorageFuelAdapter
OMW_AirOpsTechnicalAvailabilityInitializer
OMW_AirOpsResourceManifest
OMW_AirOpsTechnicalAvailability
```

Es wird keine neue MOOSE-Klasse und keine neue MOOSE-Methode eingeführt.

Historische Acceptance-Infrastruktur:

```text
tools/build-air-ops-warehouse-bootstrap.ps1
-> mission/tests/air-ops-warehouse-bootstrap/dist/OMW_AirOps_Warehouse_Bootstrap.lua
```

Produktives Packaging:

```text
tools/build-air-ops-warehouse-production-base.ps1
-> mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
```

Details: `docs/moose/STORAGE-WAREHOUSE-PRODUCTION-BASE.md`.

## 3. Strategische Datenbasis

Nicht-Fuel-Initialbestände:

```text
scripts/logistics/OMW_AirOpsInitialStock.lua
```

Owner-approved JP-8-Baseline `v0.3-RELEASE` vom 16.08.2026:

```text
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
```

Verbindliche JP-8-Werte:

| Node | Initial/Target kg | Reorder kg | Critical kg | Supply Parent |
|---|---:|---:|---:|---|
| BAGRAM | 5,000,000 | 2,140,000 | 750,000 | OFF_MAP |
| KANDAHAR_MAIN | 3,500,000 | 1,500,000 | 525,000 | OFF_MAP |
| JALALABAD | 575,000 | 320,000 | 120,000 | BAGRAM |
| KANDAHAR_HELI | 180,000 | 90,000 | 45,000 | KANDAHAR_MAIN |
| SALERNO | 1,200,000 | 640,000 | 240,000 | KANDAHAR_MAIN |
| TARINKOT | 950,000 | 540,000 | 202,500 | KANDAHAR_MAIN |
| SHINDAND_HELI | 450,000 | 195,000 | 65,000 | KANDAHAR_MAIN |

Gesamt-Initial-/Targetbestand: `11,855,000 kg FUEL_JP8`.

Die Werte sind `PROJECT_DESIGN_VALUE` und je Node in der Datenquelle nach Evidenzklasse differenziert. Historische Kapazitäts-/Durchsatzdaten dienen als Sizing-Evidenz; sie werden nicht als eigene CampaignState-Property eingeführt.

MQ-1-AVGAS-Baseline:

```text
scripts/logistics/OMW_AirOpsInitialFuelSupplement.lua
```

Kandahar AVGAS:

```text
Initial/Target  6,720 US gal = 20,270.13583056 kg
Reorder         4,000 US gal = 12,065.557042 kg
Critical        2,000 US gal =  6,032.778521 kg
```

Der künstliche historische `100000 kg`-JP-8-Preservation-Wert bleibt ausschließlich Test-Fixture und ist kein Bestandteil der Produktion.

Für den normalen Start vor der AAR Production Base enthält derselbe `OMW.AirOps.CampaignContext` zusätzlich `OMW_AARStrategicStock`. Diese Off-map-Ressourcen bleiben CampaignState-only und werden nicht nach STORAGE gespiegelt.

## 4. Fuel-Vertrag

Pfad:

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

Die Production Base spiegelt JP-8 an allen sieben produktiven AirOps-Fuel-Nodes. `KANDAHAR_MAIN` spiegelt zusätzlich die genehmigte AVGAS-Ressource. Andere Nodes erhalten keinen künstlichen AVGAS-Nullbestand.

Dafür kann `OMW_CampaignStateStorageSync` node-spezifisch eine Teilmenge der im CampaignState vorhandenen Fuel-Ressourcen spiegeln. Die Quelle bleibt ausschließlich `CampaignState:GetResource(...)`; der Adapter importiert keine STORAGE-Werte zurück in CampaignState. Ohne node-spezifische Konfiguration bleibt der bestehende vollständige `GetFuelSnapshot(...)`-Pfad kompatibel.

Die bestehende Fuel-Readback-Toleranz bleibt `0.5 kg`.

## 5. NEW und RESTORE

`NEW`:

```text
CampaignState aus freigegebenen Initialdaten aufbauen
-> WarehouseBootstrap spiegelt diesen Zustand einmalig nach STORAGE
```

`RESTORE`:

```text
CampaignState aus Snapshot wiederherstellen
-> WarehouseBootstrap spiegelt den wiederhergestellten Zustand einmalig nach STORAGE
-> Initialwerte werden nicht erneut über Restore geschrieben
```

`OMW_AirOpsWarehouseBootstrap` ruft weder `CampaignState.New()` noch `CampaignState.Restore()` auf. Die Production-Orchestrierung erzeugt genau einen NEW-Context, wenn noch keiner existiert, oder verwendet einen bereitgestellten NEW-/RESTORE-Kontext wieder.

## 6. Preflight und Fail-closed

Vor der ersten Mutation werden geplant:

```text
strategische direkte Item-Mirrors
Fuel-Mirrors
TECHNICAL_NON_STRATEGIC Availability
```

Bekannte Blocker bleiben wirksam. Nach Apply erfolgen direkte Readbacks. `READY` wird nur zurückgegeben, wenn Item-, Fuel- und Technical-Writes verifiziert sind.

Produktives Userflag:

```text
OMW_WAREHOUSE_READY = 0
-> Bootstrap erfolgreich und verifiziert
-> OMW_WAREHOUSE_READY = 1
```

Bei Fehlern bleibt beziehungsweise wird das Flag `0`.

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

Die Production-Orchestrierung verwendet weiterhin die bereits geprüften MOOSE-STORAGE- und USERFLAG-Pfade. Die neue JP-8-Datenbaseline und die node-spezifische Auswahl der zu spiegelnden Fuel-Ressource sind OMW-Domain-/Adapterlogik und implementieren keine MOOSE-Funktion parallel neu.

## 9. Abschlussgrenze

Die zugrunde liegende Warehouse-/STORAGE-Architektur besitzt historische Acceptance-Evidenz für den exakt getesteten Stand. Die neue JP-8-Baseline und das dauerhafte Production-Packaging benötigen einen neuen dokumentierten Smoke-Test.

Bis dahin:

```text
validated_in_dcs: false
```

Mission-Editor-Reihenfolge:

```text
Moose.lua
-> OMW_AirOps_Warehouse_Base.lua
-> OMW_WAREHOUSE_READY == 1
-> OMW_AAR_Base.lua
-> AIR-OPS Foundations
```

Eine `.miz` wird durch diesen Entwicklungsblock nicht automatisch verändert.
