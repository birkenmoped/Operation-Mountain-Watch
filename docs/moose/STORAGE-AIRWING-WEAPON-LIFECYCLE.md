---
document_id: OMW-MOOSE-STORAGE-AIRWING-WEAPON-LIFECYCLE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE lifecycle used by STORAGE-AIRWING-WEAPON-LIFECYCLE-5
  - normal AIRWING return versus deliberate OPSGROUP aircraft-loss path
  - exact STORAGE:GetInventory return contract
  - F-16 droptank runtime correlation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-airwing-weapon-lifecycle
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# STORAGE / AIRWING Weapon Lifecycle - MOOSE-Stand

## 1. Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 2. STORAGE:GetInventory

Im gepinnten Source:

```lua
function STORAGE:GetInventory(Item)
  local inventory=self.warehouse:getInventory(Item)
  return inventory.aircraft, inventory.liquids, inventory.weapon
end
```

Der korrekte Aufruf ist deshalb:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

V1 verletzte diesen Vertrag und ist als STORAGE-Evidenz verworfen. V5 erzwingt drei Tabellen und nichtleere Weapon-Inventories an allen sieben Endpunkten.

## 3. Normaler AIRWING-Return

Fuer AI-`FLIGHTGROUP` mit AIRWING fuehrt der source-reviewte `onafterArrived`-Pfad zum nativen:

```text
ReturnToLegion(1)
```

`OPSGROUP:ReturnToLegion()` ruft bei vorhandenem Legion/AIRWING `legion:AddAsset(self.group, 1)` auf. Der Test ruft `ReturnToLegion()` selbst nicht auf.

Der V2-Lauf vom 11.08.2026 bestaetigte fuer den Shindand-AH-64D-TwoShip:

```text
spawn:
  M151                 -76
  AGM-114K              -4
  IAFS_ComboPak_100     -2

native return:
  M151                 +76
  AGM-114K              +4
  IAFS_ComboPak_100       0
```

V5 wiederholt **nur einen** normalen AH-64-Kontrollreturn, um den aktuellen Lauf gegen diesen bekannten Debit zu verankern; eine zweite identische No-Fire-Wiederholung wird nicht erneut bezahlt.

## 4. Deliberater Aircraft-Loss: MOOSE-first

Der gepinnte `OPSGROUP` stellt einen oeffentlichen Loss-Pfad bereit:

```lua
function OPSGROUP:Destroy(Delay)
  ...
  for _,unit in pairs(units) do
    if unit then
      self:DestroyUnit(unit:getName())
    end
  end
  ...
end
```

`OPSGROUP:DestroyUnit()` erzeugt fuer Flightgroups vor dem Entfernen der DCS-Unit ein `UnitLost`-Event:

```text
IsFlightgroup()
-> CreateEventUnitLost(...)
-> unit:destroy()
```

Der anschliessende `OPSGROUP:onafterDead()`-Pfad ist fuer den Assetverlust relevant:

```text
all elements destroyed
-> cohort:DelGroup(groupname)

legion present
-> legion:GetAssetByName(groupname)
-> legion:AssetDead(asset, request)
```

V5 verwendet deshalb fuer den Loss-Teil **`FlightGroup:Destroy()`**, nicht native `Unit.destroy()`, nicht `GROUP:Destroy()` und keine selbst erfundene Loss-FSM.

Der Test misst davor und danach ueber die geerbte oeffentliche `COHORT:CountAssets()`-Methode der SQUADRON:

```lua
squadron:CountAssets(true) -- only in stock
squadron:CountAssets()     -- all cohort assets
```

`CountAssets()` zaehlt Assetgruppen, nicht einzelne Luftfahrzeuge. Bei einem verlorenen AH-64D-TwoShip wird daher fuer den Cohort-Gesamtbestand eine Abnahme um **eine Assetgruppe** erwartet. `CONFIRMED`/`NOT_CONFIRMED` ist Messergebnis, kein Early-Abort-Kriterium.

Auch die STORAGE-Waffen nach dem Loss werden klassifiziert (`NONE`, `PARTIAL`, `FULL`). Damit zeigt derselbe Lauf, ob DCS nach einem verlorenen Asset dennoch Material zurueckbucht.

## 5. F-16C Droptank-Korrelation

Die Bagram-Foundation liefert:

```text
OMW.AirOps.Bagram.Airwings.USAF
OMW.AirOps.Bagram.Squadrons.F16C
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

`AUFTRAG:AssignSquadrons({ bagram.Squadrons.F16C })` beschraenkt die Testmission auf diese SQUADRON. `AUFTRAG:SetROE(ENUMS.ROE.WeaponHold)` verhindert beabsichtigten Waffenverbrauch.

Obwohl der gepinnte Enum-Bestand mehrere F-16-/Fuel-Tank-Keys enthaelt, wird **kein** konkreter Key vorausgesetzt. V5 bildet unmittelbar vor und nach der Materialisierung das Bagram-Weapon-Inventar ab und sucht positive Debits unter:

```text
weapons.droptanks.
```

Nach Eigentuemerangabe traegt jedes Flugzeug des OMW-F-16-TwoShip-Templates zwei externe Tanks. Erwartungswert:

```text
4 tank items
```

Ein anderer beobachteter Wert wird als `tankDebitExpectedMatched=false` protokolliert, beendet aber nicht den restlichen Return-Test. Das verhindert einen unnoetigen weiteren manuellen DCS-Lauf nur wegen einer unerwarteten DCS-Key-/Mengensemantik.

Return-Klassen:

```text
FULL
NONE
PARTIAL
NOT_OBSERVED
```

## 6. Weitere verwendete MOOSE-Pfade

Source-reviewed im gepinnten Stand:

```text
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
AUFTRAG:NewCAS()
AUFTRAG:AssignSquadrons(table)
AUFTRAG:SetROE()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP:OnAfterLanded
FLIGHTGROUP:OnAfterArrived
COHORT:CountAssets()
OPSGROUP:Destroy()
OPSGROUP:onafterDead()
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`Landed` bleibt optionale Telemetrie. Ein realistischer Anlass-/Taxi-/Takeoff-/Flugablauf ist fuer die Materialization/Return/Loss-Warehousefrage kein Acceptance-Kriterium.

## 7. Grenzen

V5 testet nicht spekulativ `Controlled Partial Expenditure`. Zwar existieren DCS-/MOOSE-Angriffstasks und WeaponExpend-Parameter, aber auf diesem Branch ist noch kein deterministischer Zielpfad belegt, der fuer den AH-64 exakt eine definierte AGM-/Rocket-Abgabe garantiert. Dieser Punkt wird mit spaeteren Waffenverbrauchs-Mappings gebuendelt statt durch einen fragilen Angriff in diesen Lauf eingebaut.

Eine fehlende Tank-Rueckgabe autorisiert weiterhin **keine** produktive Fake-Recredit-Logik. Eine solche Mutation waere ein eigener, explizit zu genehmigender Adapter-Scope.
