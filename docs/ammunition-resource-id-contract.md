---
document_id: OMW-ARCH-AMMUNITION-RESOURCE-ID-CONTRACT
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - strategic CampaignState ammunition resource identifiers
  - separation of M230, GAU-8 and OH-58 M3P ammunition ownership
  - Bagram fighter AIM-120 and AIM-9 strategic resource identifiers
  - fixed-wing bomb, missile and illumination-store strategic resource identifiers
  - strategic mission-equipment resource identifiers used by AirOps stock planning
  - migration boundary for superseded generic ammunition identifiers
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - generic AMMUNITION_30MM resource interpretation
  - generic AMMUNITION_50CAL resource interpretation for the OH-58 M3P path
  - AMMUNITION_GBU31 planning label
  - AMMUNITION_GBU31_PEN planning label
  - AMMUNITION_ILLUMINATION planning label for the OMW LUU-2B path
superseded_by:
source_branch: agent/warehouse-resource-final-acceptance
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-weapon-item-matrix
base_commit: acb8955c6256bcaf1107227ec5869151d3cb4542
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
---

# Ammunition Resource-ID Contract

## 1. Owner-Entscheidungen

Der Projektinhaber hat am 11.08.2026 die systemspezifische Trennung der zuvor generischen 30-mm- und .50-cal-Ressourcen beschlossen. Am 13.08.2026 wurden die endlichen Bagram-Fighter-A/A-Ressourcen sowie die Fixed-Wing-Store-IDs und strategischen Mission-Equipment-IDs für die finalisierte Initial-Stock-Planung bestätigt.

Verbindliche strategische Munitions-Resource-IDs:

```text
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
AMMUNITION_50CAL_M3P
AMMUNITION_HELLFIRE
AMMUNITION_ROCKETS_70MM
AMMUNITION_AIM120
AMMUNITION_AIM9
AMMUNITION_GBU12
AMMUNITION_GBU38
AMMUNITION_GBU54
AMMUNITION_GBU31_V1
AMMUNITION_GBU31_V3
AMMUNITION_AGM65D
AMMUNITION_LUU2B
FLARES_CHAFF
```

Verbindliche strategische Mission-Equipment-IDs:

```text
EQUIPMENT_AAQ13
EQUIPMENT_AAQ14
EQUIPMENT_AAQ33
EQUIPMENT_AAQ28
```

Zusätzlich bestehende strategische Nicht-Munitionsressourcen bleiben unverändert:

```text
FUEL_JP8
FUEL_AVGAS
MAINTENANCE_PARTS_LIGHT
MAINTENANCE_PARTS_HEAVY
AIRCRAFT_ENGINE_MODULE
```

## 2. Systemspezifische Bedeutung

```text
AMMUNITION_30MM_M230
  -> AH-64/M230-Munition

AMMUNITION_30MM_GAU8
  -> A-10/GAU-8-Munition

AMMUNITION_50CAL_M3P
  -> OH-58/M3P-.50-cal-Pfad

AMMUNITION_AIM120
  -> endlicher Bagram-Fighter-AIM-120-Theaterbestand

AMMUNITION_AIM9
  -> endlicher Bagram-Fighter-AIM-9-Theaterbestand

AMMUNITION_GBU31_V1
  -> GBU-31(V)1/B

AMMUNITION_GBU31_V3
  -> GBU-31(V)3/B / BLU-109 penetrator variant

AMMUNITION_LUU2B
  -> LUU-2B illumination flare store
```

Die Resource IDs sind nicht gegeneinander austauschbar. Ein technisch oder taktisch verwandter Store erzeugt keine automatische strategische Konvertierung.

## 3. Superseded Generic IDs

Für neue AirOps-Ressourcenbuchungen gilt:

```text
AMMUNITION_30MM
  -> SUPERSEDED_AS_INTERCHANGEABLE_AIROPS_RESOURCE

AMMUNITION_50CAL
  -> SUPERSEDED_FOR_OH58_M3P_AIROPS_RESOURCE

AMMUNITION_GBU31
  -> SUPERSEDED_BY_AMMUNITION_GBU31_V1

AMMUNITION_GBU31_PEN
  -> SUPERSEDED_BY_AMMUNITION_GBU31_V3

AMMUNITION_ILLUMINATION
  -> SUPERSEDED_FOR_CURRENT_A10_PATH_BY_AMMUNITION_LUU2B
```

Historische Fixtures dürfen alte Bezeichnungen als historischen Stand enthalten. Eine produktive Migration muss explizit erfolgen; stille Zusammenlegung oder Aufteilung ist nicht zulässig.

## 4. Bagram Fighter A/A

Für `AMMUNITION_AIM120` und `AMMUNITION_AIM9` gilt `OMW-LOG-BAGRAM-FIGHTER-AA-DEPLOYMENT-STOCK`:

```text
initial stock source = deployment inventory only
normal campaign resupply = none
DoS stock sizing = not applicable
reserve-factor stock sizing = not applicable
```

Verbindliche Bagram-Anfangsmengen:

```text
BAGRAM / AMMUNITION_AIM120 = 52 warehouse
BAGRAM / AMMUNITION_AIM9   = 26 warehouse
```

Fitted und Warehouse Inventory bilden gemeinsam einen endlichen Theaterbestand. Der F-16-Deployment-AIM-9-Item-Key bleibt bis zum Runtime-Gate unaufgelöst.

## 5. Fixed-Wing Mapping-Grenze

Bereits praktisch beobachtete konkrete Stores dürfen payload-/variantenspezifisch auf die dokumentierten DCS/MOOSE-Items abgebildet werden. Für die F-15E-STRIKE-Varianten gilt ausdrücklich:

```text
AMMUNITION_GBU31_V1
candidate = weapons.bombs.GBU_31
status = UNVALIDATED_RUNTIME_MAPPING

AMMUNITION_GBU31_V3
candidate = weapons.bombs.GBU_31_V_3B
status = UNVALIDATED_RUNTIME_MAPPING
```

Die strategischen Bestände sind trotzdem finalisiert. Eine Source-/Enum-Fundstelle allein wird nicht als DCS-Runtime-Acceptance ausgegeben.

## 6. Strategisches Mission Equipment

Die vier Pod-Ressourcen sind `RETURNABLE_STRATEGIC_EQUIPMENT` und werden nodeweit gepoolt:

```text
EQUIPMENT_AAQ13 -> weapons.containers.F-15E_AAQ-13_LANTIRN
EQUIPMENT_AAQ14 -> weapons.containers.F-15E_AAQ-14_LANTIRN
EQUIPMENT_AAQ33 -> weapons.containers.AN_AAQ_33
EQUIPMENT_AAQ28 -> weapons.containers.AAQ-28_LITENING
```

Bestands- und Lifecycle-Regeln stehen verbindlich in `OMW-LOG-AIROPS-INITIAL-STOCK-FINALIZATION-2026-08-13`.

## 7. Technische Non-Strategic Stores

F-15E-/F-16-Außentanks erhalten bewusst **keine** strategische Resource ID:

```text
F-15E external tank = TECHNICAL_NON_STRATEGIC
F-16 370-gal tank   = TECHNICAL_NON_STRATEGIC
```

Der DCS/STORAGE-Bestand ist eine operative technische Voraussetzung, aber keine zweite CampaignState-Ressourcenhoheit. Es wird kein künstlicher AI-Normalreturn-Recredit eingeführt.

## 8. MOOSE-First und Mapping-Grenze

```text
CampaignState resource ID
  -> strategische Eigentums-, Verfügbarkeits- und Reservierungslogik

MOOSE STORAGE / DCS warehouse item
  -> operative Warehouse-Repräsentation

AIRWING payload
  -> operative Missions-/Payload-Verfügbarkeit
```

Ein Adapter darf eine strategische Resource ID nur auf belegte oder ausdrücklich als unvalidiert gekennzeichnete Item-Varianten abbilden. Ein DCS-Item darf nicht stillschweigend mehrere strategisch getrennte Ressourcen zusammenfassen.

## 9. Initial-Stock-Abschluss

Die finalisierte Node-/Resource-Matrix ist in folgenden Artefakten dokumentiert:

```text
data/logistics/air-operations-initial-store-stock-v20.csv
docs/evidence/air-operations-initial-stock-finalization-2026-08-13.md
OMW_AirOps_Logistics_Planning_v20.xlsx (planning workbook artifact, SHA-256 346f2f8547133b62f7f3980a324c08432897b8cc7a2d22eda90c4fe359cf6b46)
```

Der fachliche Initial-Stock-Entscheidungsblock ist `CLOSED`. Die noch offenen Runtime-Mapping-Gates blockieren die strategischen Initialmengen nicht.

## 10. Weiterhin technische Folgearbeit

Noch nicht automatisch freigegeben sind:

```text
CampaignState-to-STORAGE mutation for newly added resource families
strategic equipment reservation/result adapter implementation
F-15E STRIKE exact GBU-31 runtime correlation
F-16 deployment AIM-9 exact runtime correlation
combined DCS initialization/acceptance of the final stock matrix
```

Eine produktive Implementierung muss MOOSE-first bleiben und die bereits akzeptierten AIRWING-/WAREHOUSE-/FLIGHTGROUP-/STORAGE-Lifecycle-Pfade verwenden.
