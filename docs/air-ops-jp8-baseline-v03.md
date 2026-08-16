---
document_id: OMW-AIROPS-JP8-BASELINE-V03
status: BINDING_PROJECT_DECISION
document_class: RESOURCE_DESIGN_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - productive on-map AirOps JP-8 initial, target, reorder and critical stocks
  - JP-8 node-specific Days-of-Supply sizing assumptions
  - evidence classes and source boundaries for JP-8 v0.3-RELEASE
  - Issue #105 JP-8 owner decision
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - exploratory JP-8 sizing values used during Issue #105 analysis
superseded_by:
source_branch: agent/warehouse-production-base
source_commit: PENDING_MERGE
acceptance_branch: agent/warehouse-production-base
acceptance_commit: e869bc6a31ccaf3d85ff0a5d43d3db861cbf31f3
acceptance_mission: OMW_Template_v11_AirOps_rdy(3).miz
acceptance_mission_sha256: 6de39607c5cfb058331e7eb0fefe4c18972fcbf7cba416d36b6cd6a676c76dfb
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
validated_in_dcs: true
---

# AirOps JP-8 Baseline v0.3-RELEASE

## 1. Verbindliche Projektentscheidung

Der Projektinhaber hat am 16.08.2026 die folgende produktive JP-8-Baseline für Issue #105 freigegeben. Alle Mengen sind `PROJECT_DESIGN_VALUE` in `kg`; historische Quellen begrenzen oder kalibrieren die Sizing-Entscheidung, sind aber nicht mit dem strategischen CampaignState-Bestand gleichzusetzen.

```text
resourceId    = FUEL_JP8
resourceClass = CONSUMABLE_STRATEGIC
unit          = kg
mapping       = STORAGE.Liquid.JETFUEL
release       = v0.3-RELEASE
```

| Node | Initial kg | Target kg | Reorder kg | Critical kg | Supply Parent | Designklasse |
|---|---:|---:|---:|---:|---|---|
| `BAGRAM` | 5,000,000 | 5,000,000 | 2,140,000 | 750,000 | `OFF_MAP` | `PROJECT_DESIGN_VALUE_CAPACITY_THROUGHPUT_CONSTRAINED` |
| `KANDAHAR_MAIN` | 3,500,000 | 3,500,000 | 1,500,000 | 525,000 | `OFF_MAP` | `PROJECT_DESIGN_VALUE_HUB_RELATION_INTERPOLATED` |
| `JALALABAD` | 575,000 | 575,000 | 320,000 | 120,000 | `BAGRAM` | `PROJECT_DESIGN_VALUE_CAPACITY_CONSTRAINED` |
| `KANDAHAR_HELI` | 180,000 | 180,000 | 90,000 | 45,000 | `KANDAHAR_MAIN` | `PROJECT_DESIGN_VALUE_THROUGHPUT_CONSTRAINED` |
| `SALERNO` | 1,200,000 | 1,200,000 | 640,000 | 240,000 | `KANDAHAR_MAIN` | `PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED` |
| `TARINKOT` | 950,000 | 950,000 | 540,000 | 202,500 | `KANDAHAR_MAIN` | `PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED` |
| `SHINDAND_HELI` | 450,000 | 450,000 | 195,000 | 65,000 | `KANDAHAR_MAIN` | `PROJECT_DESIGN_VALUE_OPERATIONAL_INTERPOLATED` |

Gesamt:

```text
Initial = Target = 11,855,000 kg FUEL_JP8
```

Maschinenlesbare Quelle:

```text
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
```

## 2. Strategische und physische Größen bleiben getrennt

Die Baseline unterscheidet zwingend:

```text
storageCapacityKg
  = physische Anlagenobergrenze / historische Sizing-Evidence

initialStockKg / targetStockKg
  = strategischer CampaignState-Bestand

reorderStockKg / criticalStockKg
  = strategische Schwellenwerte

issueCapacityKgPerDay
  = operative Ausgabe-/Durchsatzleistung
```

`storageCapacityKg` und `issueCapacityKgPerDay` werden mit v0.3 nicht als neue CampaignState-Ressourceneigenschaften eingeführt. CampaignState bleibt alleinige strategische Ressourcenautorität. DCS/MOOSE STORAGE bleibt operativer Spiegel und darf CampaignState nicht rückwärts überschreiben.

## 3. Days-of-Supply-Sizing

| Node | Daily sizing kg/d | Target DoS | Reorder DoS | Critical DoS | Herkunft des Daily-Werts |
|---|---:|---:|---:|---:|---|
| `BAGRAM` | 713,900 | ~7.0 | ~3.0 | ~1.05 | historischer Bagram-Verbrauchsanker, gerundet |
| `KANDAHAR_MAIN` | 500,000 | 7.0 | 3.0 | 1.05 | OMW-Hub-Relation / Interpolation |
| `JALALABAD` | 80,000 | ~7.19 | 4.0 | 1.5 | OMW-Subhub-Interpolation |
| `KANDAHAR_HELI` | 45,425 | ~3.96 | ~2.0 | ~1.0 | aus dokumentierter max. FARP-Ausgabekapazität kalibriert |
| `SALERNO` | 160,000 | 7.5 | 4.0 | 1.5 | OMW-Infrastruktur-/Hub-Interpolation |
| `TARINKOT` | 135,000 | ~7.04 | 4.0 | 1.5 | OMW-Infrastruktur-/FARP-Interpolation |
| `SHINDAND_HELI` | 65,000 | ~6.92 | 3.0 | 1.0 | OMW-Operational-Interpolation |

Die Daily-Werte für Kandahar Main, Jalalabad, Salerno, Tarinkot und Shindand sind ausdrücklich **keine historischen Messdaten**.

Schwellenlogik:

```text
Tier-1-Hubs:
  Reorder  ~3 Tage Restreichweite
  Critical ~1 Tag Restreichweite

verletzliche Regionalnodes:
  Reorder  4 Tage Restreichweite
  Critical 1.5 Tage Restreichweite

Kandahar Heli:
  Reorder  ~2 Tage
  Critical ~1 Tag

Shindand Heli:
  Reorder  3 Tage
  Critical 1 Tag
```

Die Schwellen sind node-spezifische OMW-Fuel-Designwerte und keine allgemeine 40/15-Prozentregel.

## 4. Historische Anker und Quellen

### 4.1 Bagram

Primär-/amtliche Quellen:

- U.S. Army, *Bagram Airfield receives new aircraft fueling system*, 13.01.2011: https://www.army.mil/article-amp/50342/bagram_airfield_receives_new_aircraft_fueling_system
- U.S. GAO, `GAO-09-300`, *Defense Management: DOD Needs to Increase Attention on Fuel Demand Management at Forward-Deployed Locations*: https://www.gao.gov/products/gao-09-300

Bestätigte Infrastruktur:

```text
2 x 1.1 million US gal permanent storage tanks
= 2.2 million US gal nominal storage
```

OMW-Rechenreferenz bei `0.800 kg/L`:

```text
2,200,000 US gal ~= 6,662,325 kg
```

GAO berichtet für Juni 2008:

```text
total Bagram fuel consumption = 7,072,136 US gal/month
air + ground operations       = 6,155,225 US gal/month
base support                  =   916,911 US gal/month
```

Für das OMW-Sizing wurde daraus eine Tagesreferenz von rund `235,738 US gal/day` bzw. rund `713,900 kg/day` verwendet. Der freigegebene strategische Target-Bestand `5,000,000 kg` entspricht damit ungefähr sieben Referenztagen und rund 75 Prozent der dokumentierten nominalen 2.2-Mio.-gal-Anlagenkapazität. Der Target-Wert selbst bleibt `PROJECT_DESIGN_VALUE`.

### 4.2 Kandahar Heli / Mustang Ramp

Primärquelle:

- U.S. Army / USACE, *Forward area refueling point at Mustang Ramp is operational*, 22.08.2011: https://www.army.mil/article-amp/63968/forward_area_refueling_point_at_mustang_ramp_is_operational

Bestätigt:

```text
6 rotary-wing fueling points
10,000-15,000 US gal/day maximum dispensing capability
50,000-US-gal JP-8 bladder type
```

Die Gesamtzahl der Bladders und damit die gesamte lokale Speicherkapazität ist aus dieser Quelle nicht ableitbar. `45,425 kg/day` ist eine OMW-Kalibrierung an der dokumentierten Maximal-Ausgabekapazität von 15,000 US gal/day, kein historisch gemessener Tagesverbrauch.

### 4.3 Jalalabad / FOB Fenty

Primärquelle:

- U.S. Army, *Soldiers of 173rd Airborne Brigade fuel point team keeping Afghanistan task force on the move*, 11.02.2008: https://www.army.mil/article/7392/soldiers_of_173rd_airborne_brigade_fuel_point_team_keeping_afghanistan_task_force_on_the_move

Bestätigt ist eine Fuel-Point-Gesamtkapazität von `210,000 US gal`. Die Quelle verwendet dafür die Bezeichnung `diesel`; sie wird daher nicht als Beweis einer `210,000 gal JP-8-only capacity` interpretiert. Der Wert dient als Infrastrukturanker für den OMW-Target-Wert `575,000 kg`.

### 4.4 Salerno

Amtliche Budgetquelle:

- U.S. Congress, H. Rept. 111-188 / FY2010 Military Construction: https://www.congress.gov/committee-report/111th-congress/house-report/188/1

Bestätigt:

```text
SALERNO - Fuel System, Phase 1 - $12.8M
```

Die Budgetsumme beweist erhebliche Fuel-Infrastruktur, aber keine konkrete Gallonenkapazität. `1,200,000 kg` ist daher `PROJECT_DESIGN_VALUE_INFRASTRUCTURE_INTERPOLATED`.

### 4.5 Tarinkot / Tarin Kowt

Amtliche Budgetquellen:

- U.S. Congress, H. Rept. 111-188 / FY2010 Military Construction: https://www.congress.gov/committee-report/111th-congress/house-report/188/1
- U.S. Congress, H. Rept. 111-151 / 2009 supplemental military construction: https://www.congress.gov/committee-report/111th-congress/house-report/151

Bestätigt sind ein mehrphasiger Fuel-Infrastrukturausbau, darunter:

```text
Fuel Distribution System - earlier phase/funding line
Fuel System, Phase 2 - $11.8M
```

Die Projektkosten werden nicht proportional in Gallonenkapazität umgerechnet. `950,000 kg` ist ein OMW-Designwert, keine historisch gemessene Lagermenge.

### 4.6 Shindand Heli

Primärquellen:

- U.S. Army / USACE, *New rotary wing apron at Shindand complete*, 23.08.2011: https://www.army.mil/article/63965/new_rotary_wing_apron_at_shindand_complete
- U.S. Army, *TF Spearhead 'will pump you up'...with fuel*, 08.10.2011: https://www.army.mil/article/66977/tf_spearhead-will-pump-you-up-with-fuel

Bestätigt sind die 2011er Aviation-Erweiterung, `fuels operations` als Ausbaukomponente sowie operativer Petroleum-Support. Eine konkrete historische Tankkapazität ist nicht belegt. `450,000 kg` ist deshalb `PROJECT_DESIGN_VALUE_OPERATIONAL_INTERPOLATED`.

### 4.7 Kandahar Main

Die Rolle als großer RC-South-Air-/Logistikhub ist historisch stark belegt. Eine während Issue #105 zunächst behauptete pauschale `1,000,000 US gal` Bulk-Kapazität wurde **nicht** als ausreichend quellenfest bestätigt und wird nicht als Baseline verwendet. `3,500,000 kg` ist eine explizite OMW-Hub-Relation zum Bagram-Designwert und keine historische Kapazitätsmessung.

## 5. Verworfene oder nicht produktive Werte

Nicht Bestandteil der Baseline:

```text
historischer Acceptance-Testwert 100,000 kg JP-8
unbestätigte Tarinkot 150,000-gal-Kapazität
unbestätigte Tarinkot 12,000 gal/day Winter-Grundlast
unbestätigte 40% Winter-Flugausfallquote
unbestätigte allgemeine 10%-Critical-Regel
unbestätigte Kandahar-Main 1,000,000-gal-Bulk-Kapazität
pauschale C-130 3,000-gal-per-flight-Annahme
```

Diese Werte dürfen weder als historische Messung noch als produktive CampaignState-Baseline wieder eingeführt werden, solange kein neuer owner-genehmigter, quellengeprüfter Reconciliation-Schritt erfolgt.

## 6. Supply-Parent-Vertrag

Die v0.3-Baseline ändert keine bestehende Warehouse-Topologie:

```text
BAGRAM          -> OFF_MAP
JALALABAD       -> BAGRAM
KANDAHAR_MAIN   -> OFF_MAP
KANDAHAR_HELI   -> KANDAHAR_MAIN
SALERNO         -> KANDAHAR_MAIN
TARINKOT        -> KANDAHAR_MAIN
SHINDAND_HELI   -> KANDAHAR_MAIN
```

NDN-, Pakistan-/Chaman- oder andere historische Theater-Ingress-Routen werden nicht als neue `supplyParent`-IDs eingeführt. Eine spätere dynamische Supply-Chain-Simulation ist ein eigener Architekturentscheid.

## 7. Runtime-Implementierung

Produktive Datenquelle:

```text
scripts/logistics/OMW_AirOpsInitialJP8Stock.lua
SchemaVersion = OMW-AIROPS-INITIAL-JP8-STOCK-1
Release       = v0.3-RELEASE
SourceDecision = OMW owner decision 2026-08-16
```

Der Warehouse-Produktionspfad materialisiert die sieben JP-8-Ressourcen einseitig aus CampaignState nach MOOSE/DCS STORAGE. Kandahar Main führt zusätzlich den bereits genehmigten MQ-1-AVGAS-Bestand aus `OMW_AirOpsInitialFuelSupplement.lua`.

## 8. DCS-Verifikation 16.08.2026

Finaler deterministischer Owner-run Build auf dem getesteten Runtime-Commit `e869bc6a31ccaf3d85ff0a5d43d3db861cbf31f3`:

```text
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-2
InitialJP8StockSHA256: a49465ab24fed33df975651f8ba79735449228fde6064d74e87c541f31018dca
BundleSHA256 build 1: fa95807247811fbfb5efb64dcfe8a9c8dd28718ef159b58bd389406e89e59934
BundleSHA256 build 2: fa95807247811fbfb5efb64dcfe8a9c8dd28718ef159b58bd389406e89e59934
Deterministic: true
```

Acceptance-Provenienz:

```text
Branch: agent/warehouse-production-base
Runtime commit: e869bc6a31ccaf3d85ff0a5d43d3db861cbf31f3
Mission artifact: OMW_Template_v11_AirOps_rdy(3).miz
Mission SHA256: 6de39607c5cfb058331e7eb0fefe4c18972fcbf7cba416d36b6cd6a676c76dfb
Debrief executed path: C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v11_AirOps_rdy.miz
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Der finale DCS-Lauf ab `15:06:38` bestätigt:

```text
StorageInitializer PLAN blockers=0
StorageInitializer APPLY verified=true
StorageFuelAdapter APPLY verified=true for:
  BAGRAM
  JALALABAD
  KANDAHAR_HELI
  KANDAHAR_MAIN (JP-8 + AVGAS; 2 entries)
  SALERNO
  SHINDAND_HELI
  TARINKOT
TechnicalAvailabilityInitializer APPLY verified=true
AirOpsWarehouseProduction READY mode=NEW readyFlag=1
AAR production controller loaded afterwards
Bagram/Kandahar/Jalalabad/Salerno/Tarinkot/Shindand foundations reached RUNNING afterwards
```

Das zusammengeführte `dcs.log` enthält außerdem einen **früheren** Lauf um `13:08` mit dem bekannten fail-closed Fehler `KANDAHAR_MAIN/FUEL_JP8 unavailable`. Dieser frühere Eintrag gehört zum alten Produktionsstand und wird nicht als Fehler des finalen Acceptance-Laufs interpretiert.

Im finalen Lauf ist kein OMW-Lua-, Warehouse- oder Fuel-Bootstrapfehler erkennbar. Unabhängige DCS-/Modulwarnungen wie `INVALID ATC`, `Corrupt damage model` oder fehlende Texturen liegen außerhalb des Issue-#105-Scope und werden durch diesen Test nicht als behoben dargestellt.

**Verifikationsergebnis: PASS.** `validated_in_dcs: true` gilt ausschließlich für die oben dokumentierte Branch-/Commit-/Mission-/Bundle-/DCS-/MOOSE-Provenienz.