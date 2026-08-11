---
document_id: OMW-MOOSE-STORAGE-AIRWING-WEAPON-LIFECYCLE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed MOOSE lifecycle used by STORAGE-AIRWING-WEAPON-LIFECYCLE-4
  - distinction between Landed, Arrived, ReturnToLegion and STORAGE weapon/droptank telemetry
  - exact STORAGE:GetInventory return contract for the lifecycle gate
  - MOOSE squadron-restricted AUFTRAG dispatch for AH-64D and F-16C comparison
  - MOOSE MESSAGE status output for manual DCS lifecycle testing
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

## 2. Exakter STORAGE:GetInventory-Vertrag

Im tatsaechlich verwendeten `Moose.lua` lautet der relevante Pfad:

```lua
function STORAGE:GetInventory(Item)
  local inventory=self.warehouse:getInventory(Item)
  return inventory.aircraft, inventory.liquids, inventory.weapon
end
```

Damit sind drei Rueckgabewerte zu behandeln:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

Eine Interpretation als einzelne Tabelle mit `inventory.weapon` oder `inventory.weapons` ist fuer diesen MOOSE-Stand falsch. Der V1-Lifecycle-Harness machte genau diesen Fehler; V2 und alle Nachfolger erzwingen deshalb den Drei-Rueckgabewert-Vertrag und nichtleere Weapon-Inventories.

## 3. Source-reviewed Lifecycle

### 3.1 FLIGHTGROUP Landed

`FLIGHTGROUP:onafterLanded(From, Event, To, airbase)` protokolliert die Landung und aktualisiert bei vorhandenem FLIGHTCONTROL dessen Status. Dieser Callback fuehrt selbst keine OMW-STORAGE-Buchung aus.

Im realen AH-64-Lifecycle wurde der benutzerdefinierte `OnAfterLanded`-Callback nicht verlaesslich beobachtet. `Landed` bleibt deshalb zusaetzliche Telemetrie und ist kein PASS-Anker dieses Warehouse-Gates.

### 3.2 FLIGHTGROUP Arrived und nativer ReturnToLegion-Pfad

`FLIGHTGROUP:onafterArrived(From, Event, To)` behandelt das vollstaendige Ankommen. Fuer AI-Fluege mit zugeordnetem AIRWING und ohne Pickup-/Transportzustand fuehrt der gepinnte Source-Pfad zu:

```text
GetAirwing()
-> ReturnToLegion(1)
```

Der Test beobachtet diesen Lifecycle und ruft `ReturnToLegion()` nicht selbst auf. Fuer die konkrete Warehouse-Fragestellung ist ein realistisch langer Anlass-/Taxi-/Flugablauf kein Acceptance-Kriterium; relevant sind reale AIRWING-Materialisierung, DCS-Warehouse-Debit und der native MOOSE-Return-Pfad.

### 3.3 Read-only STORAGE-Telemetrie

V4 liest ausschliesslich ueber:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory() -> aircraft, liquids, weapons
```

und beobachtet die resultierenden DCS-Warehouse-Weapon-/Equipment-Keys. Keine STORAGE-Mutationsmethode wird aufgerufen.

## 4. AH-64D Kontrollpfad

Der gueltige Lauf vom 11.08.2026 bestaetigte fuer einen Shindand-AH-64D-TwoShip bei Materialisierung:

```text
weapons.nurs.HYDRA_70_M151: -76
weapons.missiles.AGM_114K: -4
weapons.droptanks.{IAFS_ComboPak_100}: -2
```

und beim nativen Return:

```text
HYDRA_70_M151: +76
AGM_114K: +4
IAFS_ComboPak_100: no recredit observed
```

V4 behaelt den ersten Debit als Fail-Fast-Kontrollsignal bei und beobachtet zwei AH-64-TwoShips, bevor der F-16-Vergleich beginnt.

Der MOOSE-Enum klassifiziert `IAFS_ComboPak_100` unter `weapons.droptanks`. Das ist nur eine Key-/Kategorieevidenz; Ursache und beabsichtigte DCS-Rueckgabesemantik werden daraus nicht abgeleitet.

## 5. F-16C Droptank-Vergleich

### 5.1 Verbindlicher Bagram-Foundation-Pfad

Die Branch-Foundation stellt fuer den Vergleich bereit:

```text
OMW.AirOps.Bagram.Airwings.USAF
  -> AW_US_BGRM_455_AEW

OMW.AirOps.Bagram.Squadrons.F16C
  -> SQ_US_BGRM_F16C_121_EFS
  -> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
  -> Grouping 2
```

Ein MOOSE-Asset dieser SQUADRON materialisiert damit den OMW-F-16-TwoShip-Seed.

### 5.2 AUFTRAG:AssignSquadrons

Im gepinnten `Moose.lua` ist die oeffentliche Methode vorhanden:

```lua
function AUFTRAG:AssignSquadrons(Squadrons)
  for _, _squad in pairs(Squadrons) do
    local squadron = _squad
    self:AssignCohort(squadron)
  end
  return self
end
```

Der Parameter muss eine Tabelle sein, auch bei nur einer SQUADRON. V4 verwendet daher:

```lua
mission:AssignSquadrons({ shindand.Squadrons.AH64D })
mission:AssignSquadrons({ bagram.Squadrons.F16C })
```

Damit werden fuer die jeweilige Testmission nur die angegebenen SQUADRONs betrachtet; es ist keine eigene Dispatch- oder Auswahl-FSM erforderlich.

### 5.3 AUFTRAG:SetROE

Der gepinnte Source stellt bereit:

```lua
function AUFTRAG:SetROE(roe)
  self.optionROE = roe
  return self
end
```

V4 setzt fuer die Testmissionen:

```lua
mission:SetROE(ENUMS.ROE.WeaponHold)
```

um die Materialisierungs-/Return-Beobachtung ohne beabsichtigten Waffenverbrauch durchzufuehren.

### 5.4 Keine Vorannahme des konkreten F-16-Tank-Keys

Der gepinnte Enum-Bestand enthaelt unter anderem:

```text
weapons.droptanks.fuel_tank_370gal
weapons.droptanks.F-16-PTB-N2
```

Die Existenz dieser Enums beweist nicht, welchen Key DCS fuer das konkrete OMW-F-16-Template abbucht. V4 hardcodiert deshalb keinen Tank-Key. Direkt vor dem F-16-Dispatch wird der komplette Bagram-Weapon-Bestand gespeichert; direkt nach Materialisierung werden alle positiven Debits unter

```text
weapons.droptanks.
```

ermittelt und mit den tatsaechlichen Keys protokolliert.

Nach Projektinhaberangabe traegt jedes Flugzeug des OMW-F-16-TwoShip-Templates zwei externe Tanks. Der Gate erwartet daher fuer den TwoShip eine Droptank-Debit-Summe von exakt `4`. Ein anderes Ergebnis wird als nicht bestaetigte Template-/Warehouse-Semantik behandelt und beendet den Gate mit FAIL, statt einen Key oder Mengenumrechnungsfaktor zu erfinden.

## 6. F-16 Return-Klassifikation

Nach `Arrived` und dem nativen Return-Fenster wird fuer jeden beim Spawn entdeckten Droptank-Key berechnet:

```text
pre-dispatch
post-materialization
debit
post-return
recovered
```

Gesamtstatus:

```text
FULL    recovered == debited
NONE    recovered == 0
PARTIAL 0 < recovered < debited
```

`FULL`, `NONE` und `PARTIAL` sind zulaessige **Beobachtungsergebnisse**. Die Klassifikation entscheidet nicht selbst ueber Harness-PASS; PASS verlangt, dass der Vergleich vollstaendig und mit validem `-4`-Kontrolldebit durchlaufen wurde.

Eine fehlende Tank-Rueckgabe autorisiert keine automatische OMW-Recredit-Korrektur. Eine produktive Mutation oder Parallelbuchung waere ein eigener, durch Governance und Projektinhaberfreigabe zu entscheidender Adapter-Scope.

## 7. AIRWING Wiederverwendung und Missionserzeugung

Die Lifecycle-Legs werden ueber vorhandene MOOSE-Funktionen angefordert:

```text
AUFTRAG:NewCAS()
AUFTRAG:AssignSquadrons()
AUFTRAG:SetROE()
AIRWING:AddMission()
AIRWING:OnAfterFlightOnMission
FLIGHTGROUP:OnAfterArrived
```

Keine Gruppe wird durch OMW direkt gespawnt, zerstoert oder manuell zum AIRWING zurueckgebucht.

## 8. Ammo-Telemetrie

`FLIGHTGROUP:GetAmmoTot()` ist im gepinnten Source vorhanden. V4 protokolliert `MissilesAG`, `Rockets`, `Bombs` und `Guns` bei Assignment und Arrived; Landed bleibt optional. Die Werte muessen je Lifecycle-Leg unveraendert bleiben, damit der Gate die jeweilige Strecke als no-fire klassifiziert.

Diese Summen sind keine Einzelkey- oder Rundenzuordnung. Insbesondere folgt daraus weiterhin **keine** direkte M230/M789-STORAGE-Spiegelung.

## 9. MOOSE MESSAGE fuer Teststatus

Der gepinnte `Moose.lua` stellt bereit:

```lua
MESSAGE:New(text, duration, category):ToAll()
```

V4 verwendet diesen MOOSE-Pfad fuer Start-, Phasen-, Heartbeat-, PASS- und FAIL-Meldungen. Ein direkter `trigger.action.outText`-Aufruf ist im Harness nicht erforderlich und wird durch den Builder ausgeschlossen.

## 10. V4 Fail-Fast-Grenzen

Vor einem gueltigen PASS muessen mindestens gelten:

```text
GetInventory() three-return contract valid
all seven weapon inventories non-empty
required Shindand keys numeric and sufficiently stocked
first AH-64 debit exactly -76 / -4 / -2
two AH-64 assignments and Arrived events observed
both AH-64 legs no-fire by GetAmmoTot comparison
Bagram F-16C mission restricted to SQ_US_BGRM_F16C_121_EFS
F-16 droptank debit discovered from runtime inventory delta
droptank debit total exactly 4
F-16 Arrived/native return observed
F-16 no-fire by GetAmmoTot comparison
F-16 recredit classified FULL/NONE/PARTIAL
final STORAGE read succeeds
```

## 11. Noch nicht validiert

Bis zum V4-DCS-Lauf bleiben insbesondere offen:

```text
welcher konkrete DCS STORAGE key vom OMW-F-16-Template fuer die externen Tanks verwendet wird
ob vier externe F-16-Tanks beim nativen AIRWING-Return voll, teilweise oder gar nicht zurueckgebucht werden
ob der AH-64-IAFS-Befund damit als systemspezifischer oder allgemeinerer droptank-Sonderfall einzuordnen ist
```

Controlled Partial Expenditure, absichtlicher Aircraft Loss, M230/M789, GAU-8 und M3P bleiben nachgelagerte, moeglichst gebuendelt zu testende Scopes.
