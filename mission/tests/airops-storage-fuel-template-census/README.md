---
document_id: OMW-TEST-AIROPS-STORAGE-FUEL-TEMPLATE-CENSUS
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AIROPS-wide physical AI template STORAGE lifecycle census
  - read-only aircraft, JETFUEL and weapon materialization/return observation
  - onboard fuel telemetry correlation for AIROPS templates
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airops-storage-fuel-template-census
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-airwing-weapon-lifecycle
base_commit: 718e2e770f1594b205e429b2b898f73b26352c13
base_status: DCS_TESTED_PARENT_BRANCH
merged_to_main: false
inherited_risk:
  - parent lifecycle branch remains unmerged
---

# AIROPS STORAGE / Fuel Template Census

## 1. Ziel

Der Test erweitert den bisherigen einzelnen AH-64/F-16-Lifecycle-Nachweis zu einem systematischen Census der derzeit produktiven AIROPS-Foundations.

Ein einzelner DCS-Lauf soll fuer **alle 32 unterschiedlichen physischen AI-Templates** beobachten:

```text
DCS STORAGE aircraft inventory
DCS STORAGE JETFUEL liquid inventory
DCS STORAGE weapon inventory
AIRWING materialization
onboard fuel at assignment
native mission lifecycle / Landed / Arrived / ReturnToLegion
onboard fuel at Landed und, soweit noch messbar, Arrived
post-return STORAGE recredit
```

Der Test veraendert weder STORAGE noch CampaignState. Er ruft `ReturnToLegion()` nicht selbst auf und verwendet weder direkten `SPAWN`, OPSTRANSPORT noch CTLD.

## 2. Warum ein ORBIT-Testpayload verwendet wird

Die produktiven SQUADRONs besitzen unterschiedliche operative Mission-Capabilities. Transport- und Rescue-Missionen brauchen reale Cargo-/Carrier-/Zielobjekte und waeren als kuenstliche Testauftraege eine neue Fehlerquelle.

Der gepinnte MOOSE-Stand bietet eine kleinere MOOSE-first-Loesung:

- `SQUADRON:New()` gibt SQUADRONs standardmaessig ORBIT-Capability;
- `AIRWING:NewPayload()` kann den Payload eines exakten Mission-Editor-Templates registrieren und fuegt ORBIT als Payload-Capability hinzu;
- `AUFTRAG:NewORBIT()` erzeugt einen echten AIRWING-Lifecycle;
- `AUFTRAG:AddRequiredPayload()` pinnt fuer den Test genau den aus dem physischen Template kopierten Payload;
- `AUFTRAG:AssignSquadrons()` beschraenkt den Auftrag auf die zustaendige SQUADRON.

Damit muessen fuer den Census **keine produktiven SQUADRON-Capabilities veraendert** werden. `ALERT5` wird absichtlich nicht verwendet, weil der source-reviewte Recruit-Pfad `Mission.type == ALERT5` gegen die Cohort-Capabilities prueft und die aktuellen OMW-SQUADRONs keine ALERT5-Capability deklarieren.

Die zusaetzlichen ORBIT-Payload-Registrierungen sind reine Testkoordination innerhalb des AIRWINGs. Sie stellen keine neue Produktions-Payload-Baseline dar.

## 3. Abdeckung

### Bagram

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

### Jalalabad

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

### Kandahar Main

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
TPL_AIR_US_KAF_HH60G_CSAR_1SHIP
TPL_AIR_US_KAF_C130_TRANSPORT_1SHIP
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
```

Die produktive Kandahar-Foundation fuehrt MQ-1/MQ-9-Rollenpayloads weiterhin als deferred. Der Census erzeugt fuer diese physischen Templates nur den testlokalen ORBIT-Payload, damit ihr DCS-STORAGE-/Fuel-Verhalten trotzdem beobachtet werden kann. Das hebt den produktiven Deferred-Status nicht auf.

### Kandahar Heliport

```text
TPL_AIR_US_KAF_AH64D_CAS_2SHIP
TPL_AIR_US_KAF_OH58D_RECON_2SHIP
TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP
TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
```

### FOB Salerno

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP
TPL_AIR_US_SAL_OH58D_RECON_2SHIP
TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP
TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP
TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP
```

### Shindand Heliport

```text
TPL_AIR_US_SHND_AH64D_CAS_2SHIP
TPL_AIR_US_SHND_UH60_UTILITY_1SHIP
TPL_AIR_US_SHND_CH47_HEAVYLIFT_1SHIP
```

### Tarinkot

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_1SHIP
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
```

Gesamt: **32 physische AI-Template-Faelle**.

## 4. Laufzeitmodell

Die sieben DCS-STORAGE-Endpunkte bilden unabhaengige Test-Lanes:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Shindand Heliport
Tarinkot
```

Innerhalb einer STORAGE-Lane laeuft immer nur **ein** Template-Fall gleichzeitig, damit Inventory-Deltas eindeutig zugeordnet werden koennen. Verschiedene STORAGE-Lanes duerfen parallel laufen. Dadurch wird der Lauf gegenueber 32 global seriellen Flugzyklen deutlich verkuerzt, ohne Debits desselben Warehouses zu vermischen.

Ein Fall erhaelt bis zu 900 Sekunden fuer Materialisierung und den nativen Return-Lifecycle. Wenn ein noch nicht materialisierter Fall nicht zugewiesen werden kann, wird er per oeffentlichem `AUFTRAG:Cancel()` beendet und die Lane faehrt mit dem naechsten Fall fort. Wenn ein **bereits materialisierter** Fall nicht bis `Arrived` kommt, wird seine Lane blockiert und nicht mit dem naechsten Template kontaminiert. Andere Lanes laufen weiter. Der globale Sicherheitszeitraum betraegt 3600 Sekunden.

Ein einzelnes semantisch unerwartetes Fuel-/Store-Ergebnis beendet den Gesamtlauf nicht.

## 5. Stores

Pro Fall wird das komplette Weapon-Inventar vor Materialisierung, nach Materialisierung und nach native Return verglichen. Es wird kein Store-Key vorausgesetzt.

Ausgegeben werden unter anderem:

```text
MAP_DELTA ... family=WEAPON
SPAWN_SUMMARY ... weaponDebitTotal=...
STORE_RECOVERY ...
STORE_RESULT ... status=NOT_DEBITED|FULL|PARTIAL|NONE|OVER_RECREDIT
```

Damit werden unter anderem die bereits bekannten IAFS-, F-16-Droptank-, Hellfire- und Hydra-Faelle erneut im breiteren Template-Kontext sichtbar, ohne sie im Census hart zu codieren.

## 6. Fuel

`STORAGE:GetInventory()` wird weiterhin entsprechend dem gepinnten Drei-Rueckgabe-Vertrag verwendet:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

JETFUEL wird separat aus

```lua
liquids[STORAGE.Liquid.JETFUEL]
```

in kg beobachtet.

Zusaetzlich erfasst der Test am zugewiesenen `FLIGHTGROUP`:

```text
FLIGHTGROUP:GetFuelMin()       -- relative Mindestfuelmenge der Gruppe in Prozent
UNIT:GetCurrentFuelKgs()       -- aktuelle Fuelmasse je lebender Unit
```

Die Onboard-Telemetrie wird bei Assignment, `Landed` und `Arrived` versucht. Fuer die Korrelation mit der spaeteren STORAGE-Recovery wird bevorzugt der letzte brauchbare `Landed`-Wert verwendet; falls dort keine lebenden Units messbar waren, wird ein noch verfuegbarer `Arrived`-Wert verwendet. Ist beides nicht mehr messbar, bleibt die Referenz `UNAVAILABLE`, ohne den restlichen Census abzubrechen.

Damit kann nach dem Lauf nicht nur festgestellt werden, ob Fuel voll/teilweise/nicht zurueckgebucht wird. Die STORAGE-Recovery kann auch gegen die unmittelbar vor dem nativen Return beobachtbare Fuelmasse korreliert werden.

Diese Korrelation wird als Evidenz protokolliert; sie ist **kein harter Equality-Assert**, weil externe Tanks und DCS-Fuelmodellierung separat bewertet werden muessen.

## 7. Aircraft inventory

Auch die `aircraft`-Rueckgabe von `STORAGE:GetInventory()` wird read-only verglichen. Sie dient als zusaetzliche Lifecycle-Telemetrie, ohne CampaignState-Airframehoheit zu veraendern.

## 8. Nicht Bestandteil

`Controlled Partial Expenditure + Return` wird in diesem Census weiterhin nicht erzwungen. Der aktuell gepinnte Stand liefert fuer die unterschiedlichen Waffensysteme keinen allgemein deterministischen, source-reviewten Mechanismus, der eine exakt definierte Teilabgabe garantiert.

Der Census beantwortet deshalb zuerst flaechendeckend:

```text
welches Template bucht welche Stores?
wie viel JETFUEL wird bei Materialisierung gebucht?
welche Stores kommen bei No-Fire-Return zurueck?
welcher Fuelbestand kommt nach dem Flug zurueck?
entspricht die Fuel-Recovery plausibel dem unmittelbar vor Return verbleibenden Onboard-Fuel?
```

Danach bleiben nur noch gezielte Verbrauchsluecken wie M230/M789, GAU-8/Munition, M3P sowie ein deterministischer Partial-Expenditure-Pfad.

## 9. MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed fuer diesen Census:

```text
STORAGE:GetInventory()
STORAGE.Liquid.JETFUEL
AIRBASE:GetStorage()
STORAGE:FindByName()
AIRWING:NewPayload()
AUFTRAG:NewORBIT()
AUFTRAG:AddRequiredPayload()
AUFTRAG:AssignSquadrons()
AUFTRAG:SetRequiredAssets()
AUFTRAG:SetTime()
AUFTRAG:SetDuration()
AUFTRAG:SetROE()
AUFTRAG:SetROT()
AUFTRAG:Cancel()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
OPSGROUP:GetGroup()
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:OnAfterLanded
FLIGHTGROUP:OnAfterArrived
UNIT:GetCurrentFuelKgs()
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

Der Harness verwendet fuer die Census-Logik keine nicht dokumentierten MOOSE-Felder wie `squadron.ngrouping` oder Payload-interne IDs.

## 10. Build

Source:

```text
mission/tests/airops-storage-fuel-template-census/src/01-airops-storage-fuel-template-census.lua
```

Builder:

```text
tools/build-airops-storage-fuel-template-census.ps1
```

Generiertes Bundle:

```text
mission/tests/airops-storage-fuel-template-census/dist/OMW_AirOps_Storage_Fuel_Template_Census.lua
```

BuilderVersion:

```text
AIROPS-STORAGE-FUEL-TEMPLATE-CENSUS-1
```

## 11. Acceptance-Grenze

Ein finales `status=COMPLETE` bedeutet nur, dass alle 32 Template-Faelle strukturell beobachtet wurden. `COMPLETE_WITH_GAPS` bedeutet, dass der Lauf beendet wurde, aber einzelne Faelle oder Lanes nicht vollstaendig beobachtet werden konnten.

Die fachliche Interpretation erfolgt erst aus dem realen `dcs.log` und Debrief des exakt dokumentierten Branch-/Commit-/Bundle-/MOOSE-/DCS-Stands. `VALIDATED` wird vor diesem DCS-Nachweis nicht vergeben.
