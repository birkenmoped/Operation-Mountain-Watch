---
document_id: OMW-TEST-STORAGE-AIRWING-WEAPON-LIFECYCLE-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - combined STORAGE/AIRWING return, loss and droptank lifecycle correlation
  - Shindand AH-64D normal-return control and deliberate asset-loss observation
  - Bagram F-16C external-tank debit and return comparison
  - interpretation boundary for IAFS, droptanks, ReturnToLegion and aircraft loss
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-airwing-weapon-lifecycle
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-weapon-consumption-correlation
base_commit: 503467665e9810398b0c9f20c29019bf958a589b
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
inherited_risk:
  - parent ammunition mapping and resource-ID branches remain unmerged
---

# STORAGE / AIRWING Weapon Lifecycle

## 1. Aktueller Gate

`STORAGE-AIRWING-WEAPON-LIFECYCLE-6` buendelt drei zusammenhaengende Fragen in **einen** manuellen DCS-Lauf:

```text
7 STORAGE baselines
-> AH-64D TwoShip normal-return control
   -> exact debit -76 M151 / -4 AGM-114K / -2 IAFS
   -> native Arrived -> ReturnToLegion
   -> recredit classification
-> AH-64D TwoShip deliberate loss
   -> same materialization debit
   -> public MOOSE OPSGROUP:Destroy()
   -> generated UnitLost events
   -> SQUADRON asset-count observation
   -> store-recovery classification
-> Bagram F-16C TwoShip
   -> runtime droptank-key discovery
   -> expected template quantity: 4 tanks total
   -> native Arrived -> ReturnToLegion
   -> droptank recredit classification
-> final STORAGE state
```

Der Harness veraendert weder STORAGE noch CampaignState. Die einzige absichtliche Runtime-Mutation ist `OPSGROUP:Destroy()` im Loss-Teil; sie dient gerade der Untersuchung des nativen MOOSE-Aircraft-Loss-Pfads.

## 2. Bereits vorhandene Evidenz

### V1 verworfen

V1 behandelte `STORAGE:GetInventory()` faelschlich als Einzelrueckgabe und verlor dadurch die Weapon-Tabelle. Der Lauf mit `weaponKeys=0` ist keine STORAGE-Lifecycle-Evidenz.

Der gepinnte Vertrag lautet:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

### V2 gueltig

Der korrigierte Lauf vom 11.08.2026 beobachtete zweimal reproduzierbar:

```text
AH-64D TwoShip materialization:
  HYDRA_70_M151        -76
  AGM_114K              -4
  IAFS_ComboPak_100     -2

native return:
  HYDRA_70_M151        +76
  AGM_114K              +4
  IAFS_ComboPak_100       0
```

Nach zwei TwoShips standen M151 und AGM-114K wieder auf Baseline, IAFS dagegen netto bei `-4`.

Der Mission Editor bezeichnet das verwendete IAFS als internen 100-Gal-Treibstofftank. Der gepinnte MOOSE-Enum fuehrt `IAFS_ComboPak_100` unter `weapons.droptanks`. Das beobachtete `-1` pro AH-64 wird daher nicht als M230-/M789-Rundenverbrauch interpretiert.

### V5 Harness-Precondition-Fail

Der V5-Lauf vom 11.08.2026 erreichte keine Lifecycle-Phase. Die Baseline-Pruefung verlangte faelschlich fuer **alle** bekannten AH-64-Stores den zweifachen TwoShip-Debit und brach deshalb bei `M151 amount=100 required=152` ab.

Das war ein Testharness-Fehler, kein DCS-/MOOSE-Ergebnis. Die beiden AH-64-Legs laufen sequenziell und V2 hatte bereits gezeigt, dass M151 und AGM-114K nach dem normalen No-Fire-Return vollstaendig recreditiert werden. Nur IAFS wurde nicht recreditiert.

V6 verwendet deshalb item-spezifische Mindestbestaende:

```text
M151 minimum:              76
AGM-114K minimum:           4
IAFS_ComboPak_100 minimum:  4
```

Der Builder blockiert zusaetzlich eine erneute pauschale `required * 2`-Precondition und prueft diese drei Mindestwerte statisch.

## 3. Warum V6 den Loss-Pfad mitnimmt

Ein weiterer isolierter DCS-Lauf nur fuer Aircraft Loss waere vermeidbarer Testaufwand. Der gepinnte MOOSE-Stand stellt mit `OPSGROUP:Destroy()` einen oeffentlichen Pfad bereit, der bei Aircraft-Gruppen fuer jede aktuelle Unit ein `UnitLost`-Event erzeugt und anschliessend die Unit entfernt.

Der anschliessende `OPSGROUP:onafterDead()`-Pfad:

```text
all elements destroyed
-> cohort:DelGroup(groupname)
-> legion:GetAssetByName(groupname)
-> legion:AssetDead(asset, request)
```

ist damit fuer den gezielten Loss-Test der passende MOOSE-first-Pfad. V6 misst vor und nach dem Loss mit `SQUADRON:CountAssets()` / `CountAssets(true)`, ob die Assetgruppe aus dem Cohortbestand verschwindet.

Das **beobachtete Ergebnis** wird als `CONFIRMED` oder `NOT_CONFIRMED` protokolliert. Eine unerwartete Semantik beendet den restlichen manuellen DCS-Lauf nicht vorzeitig.

## 4. F-16-Droptank-Vergleich

Die Bagram-Foundation liefert:

```text
AW_US_BGRM_455_AEW
SQ_US_BGRM_F16C_121_EFS
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
Grouping: 2
```

Nach Projektinhaberangabe traegt jedes Flugzeug dieses Templates zwei externe Tanks:

```text
2 F-16 x 2 tanks = 4 tank items expected
```

V6 hardcodiert **keinen** konkreten F-16-Warehouse-Key. Der reale Key wird aus allen positiven Bagram-Debits mit Prefix

```text
weapons.droptanks.
```

direkt nach Materialisierung ermittelt.

Ein Debit ungleich `4` ist bewusst **kein Early-Abort**. `tankDebitExpectedMatched=false` wird protokolliert und der Return-Pfad trotzdem bis zum Ende beobachtet.

Recredit-Klassen:

```text
FULL
NONE
PARTIAL
NOT_OBSERVED
```

Keine dieser Klassen implementiert automatisch eine produktive Tankregel. Ob Tanks spaeter unbegrenzt gefuehrt, nicht strategisch gespiegelt oder durch einen genehmigten Adapter korrigiert werden, bleibt eine Eigentuemerentscheidung nach der realen Evidenz.

## 5. MOOSE-First-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed fuer V6:

```text
STORAGE:GetInventory() -> aircraft, liquids, weapons
AIRBASE:GetStorage()
STORAGE:FindByName()
AUFTRAG:NewCAS()
AUFTRAG:AssignSquadrons({ SQUADRON })
AUFTRAG:SetROE(ENUMS.ROE.WeaponHold)
AIRWING:AddMission()
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP OnAfterLanded / OnAfterArrived
FLIGHTGROUP onafterArrived -> ReturnToLegion(1)
COHORT/SQUADRON:CountAssets()
OPSGROUP:Destroy()
OPSGROUP:onafterDead() -> cohort removal / Legion AssetDead
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

Der Test ruft `ReturnToLegion()` nie selbst auf. Normal-return bleibt der native AIRWING-/FLIGHTGROUP-Pfad.

## 6. Acceptance- und Ergebnislogik

Fail-fast bleibt fuer **ungueltige Testgrundlagen** bestehen:

```text
Foundation fehlt
STORAGE wrapper fehlt/inkonsistent
GetInventory contract ungueltig
Weapon inventory leer
item-spezifischer AH-64 Mindestbestand nicht vorhanden
bekannter AH-64 control debit nicht reproduzierbar
Lua/runtime exception
Safety timeout
```

Nicht fail-fast sind **die eigentlich zu messenden DCS-Semantiken**:

```text
AH-64 loss asset removed or not removed
AH-64 stores after loss recovered or not recovered
F-16 droptank debit exactly 4 or another value
F-16 tanks fully / partly / not recredited
```

Harness-`PASS` bedeutet deshalb: alle drei Testphasen wurden technisch vollstaendig beobachtet. Die fachliche Acceptance entsteht erst aus der anschliessenden Logauswertung.

Ein realistischer Anlass-/Taxi-/Takeoff-/Flugablauf ist fuer diesen Warehouse-Materialization/Return/Loss-Gate kein Acceptance-Kriterium. `Landed` bleibt optionale Telemetrie; `Arrived` ist fuer die normalen Return-Legs der source-reviewte Recovery-Anker.

## 7. Noch nicht Bestandteil

`Controlled Partial Expenditure + Return` bleibt offen. Es wird **nicht** spekulativ in V6 eingebaut, weil auf diesem Branch noch kein deterministischer, source-reviewter Ziel-/Task-Pfad vorliegt, der exakt eine definierte AGM-/Rocket-Abgabe des AH-64 garantiert.

Weiter offen:

```text
M230 / M789 direct STORAGE mapping
A-10C / GAU-8 mapping
OH-58D / M3P mapping
CampaignState weapon adapter
OPSTRANSPORT / CTLD reconciliation
```

## 8. Build

```text
mission/tests/storage-airwing-weapon-lifecycle/src/01-storage-airwing-weapon-lifecycle.lua
tools/build-storage-airwing-weapon-lifecycle.ps1
mission/tests/storage-airwing-weapon-lifecycle/dist/OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua
```

BuilderVersion:

```text
STORAGE-AIRWING-WEAPON-LIFECYCLE-6
```
