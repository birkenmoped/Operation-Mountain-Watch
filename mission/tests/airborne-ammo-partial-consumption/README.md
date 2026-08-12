---
document_id: OMW-TEST-AIRBORNE-AMMO-PARTIAL-CONSUMPTION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - targeted airborne cannon/ammunition consumption observation
  - read-only STORAGE correlation after real DCS weapon expenditure
  - current TODO and retest gate for M230, GAU-8 and M3P
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airborne-ammo-partial-consumption
source_commit: PENDING_MERGE
validated_in_dcs: partial
base_branch: agent/airops-storage-fuel-template-census
base_commit: baa92e90ef41ca3a2ec1f99ed278c8a834473c20
merged_to_main: false
---

# Airborne Ammo Partial Consumption

## Urspruengliches Ziel

Der gezielte DCS-Test soll die offenen Bordwaffen- und Partial-Expenditure-Fragen der Warehouse-TODO-Liste klaeren:

```text
AH-64D  -> M230 / M789
A-10C   -> GAU-8
OH-58D  -> M3P
```

Der Test simuliert keinen Verbrauch. Er erzwingt reale DCS-Waffenabgabe gegen testlokal gespawnte RED-Ziele und beobachtet:

```text
onboard ammo at assignment
onboard ammo at Landed / Arrived
actual shell/gun/cannon consumption
STORAGE weapon debit at materialization
STORAGE weapon recredit after native AIRWING return
JETFUEL debit/recredit as secondary telemetry
```

Das Endziel ist nicht, Munitionsrunden kuenstlich auf STORAGE-Items abzubilden, sondern den tatsaechlichen DCS-/MOOSE-Lifecycle zu verstehen, bevor ein CampaignState-Adapter entworfen wird.

## Aktueller Teststand

Branch:

```text
agent/airborne-ammo-partial-consumption
```

Letzter vom Projektinhaber lokal verifizierter Source-/Builder-Stand vor den aktuellen Dokumentationscommits:

```text
Git commit: d0c13cf658db085f10acec43ee8e46fc8165b0da
BuilderVersion: AIRBORNE-AMMO-PARTIAL-CONSUMPTION-2
Bundle SHA-256: 0288ec63c906c7d3fc63759d72d43a8c268eb1ee91c3f1dd8fa2dc6943a3fc68
DCS: 2.9.28.26385
Mission: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256 for these runs: not supplied
```

Damit sind die DCS-Beobachtungen branch- und artefaktgebundene Evidenz, aber wegen des fehlenden MIZ-Hashes keine vollstaendige `ACCEPTED_TECHNICAL_BASELINE`.

## Testfaelle

Drei voneinander unabhaengige STORAGE-Lanes laufen parallel:

```text
Kandahar Main      TPL_AIR_US_KAF_A10C_CAS_2SHIP
Jalalabad          TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Shindand Heliport  TPL_AIR_US_SHND_AH64D_CAS_2SHIP
```

Die produktiven Two-Ship-Gruppierungen bleiben unveraendert. `SetRequiredAssets(1, 1)` fordert eine Assetgruppe an; bei `SQUADRON:SetGrouping(2)` bleibt das ein reales Two-Ship.

## RED-Testziel und V2-Zielplatzierung

Verwendeter Mission-Editor-Seed:

```text
TPL_TEST_RED_VEHICLE_02_01
```

Die Gruppe enthaelt zwei Units vom DCS-Typ `tt_B8M1`.

V2 ersetzt die alte feste `Airbase + 10 km`-Annahme durch:

```text
bevorzugte Distanz/Peilung
-> begrenzte Distanz-/Peilungsvarianten
-> COORDINATE:GetClosestPointToRoad()
-> COORDINATE:IsInFlatArea(35 m, 8 %)
-> erster gueltiger Kandidat
```

Bevorzugte Distanzen:

```text
Kandahar A-10C:      20 km
Jalalabad OH-58D:    12 km
Shindand AH-64D:     12 km
```

Die Suche ist deterministisch. Fuer die A-10 wurde in den beiden ausgewerteten V2-Laeufen derselbe Kandidat auf 20 km / 45 Grad / gemessener Steigung 2 verwendet. Dass ein Lauf reale GAU-8-Abgabe zeigte und ein anderer nicht, ist daher nicht durch eine andere Zielposition erklaert.

## MOOSE-first Angriffspfad

1. Exaktes BLUE-ME-Template testlokal als ORBIT-Payload registrieren.
2. Kurzer ORBIT-Auftrag materialisiert eine produktive Assetgruppe ueber den normalen MOOSE-Warehousepfad.
3. Auf dem zugewiesenen `FLIGHTGROUP` testlokal `SetOptionLandingRestrictPair()` setzen.
4. Dem selben `FLIGHTGROUP` `AUFTRAG:NewSTRAFING()` zuweisen.
5. `SetWeaponType(ENUMS.WeaponFlag.GunPod + ENUMS.WeaponFlag.BuiltInCannon)` begrenzt auf Gun Pod/Built-in Cannon.
6. `SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)` und `SetEngageQuantity(2)` bleiben DCS-AI-Vorgaben; die reale Rundenzahl wird gemessen.
7. Native `Landed -> Arrived -> ReturnToLegion`-Semantik bleibt unangetastet.

Ein `AUFTRAG ... success` allein gilt **nicht** als Verbrauchsnachweis. `GetAmmoTot()` und DCS-Debrief sind fuer reale Waffenabgabe massgeblich.

## Recovery-/Parking-Erfahrung

`SQUADRON:SetParkingIDs(...)` steuert den Materialisierungs-/Spawn-Pool, beweist aber keine individuelle Return-Parking-ID fuer jedes Element eines Two-Ships.

Fruehe Beobachtung ohne Pair-Restriction:

```text
A-10C:
  beide Maschinen landeten
  rollten spaeter in Statics
  beide wurden zerstoert

Helikopter:
  Wingman kreiste lange ueber dem Parking-/Lead-Bereich
  Recovery wirkte wie ein Pair-/Standkonflikt
```

V2 setzt deshalb ausschliesslich:

```text
FLIGHTGROUP:SetOptionLandingRestrictPair()
```

Praktische V2-Beobachtung:

```text
AH-64D: Landed -> Arrived mehrfach erreicht
OH-58D: Landed -> Arrived erreicht
A-10C: Landed erreicht; Arrived bislang nicht verlaesslich erreicht
```

Damit ist die Pair-Restriction fuer den Testzweck bei den Helikoptern ausreichend hilfreich. Sie garantiert **keine** bestimmten oder unterschiedlichen Parking-IDs und ist keine allgemeine Parking-Loesung.

Bewusst ausgeschlossen:

```text
SetDespawnAfterLanding()
SetDespawnAfterHolding()
ReturnToLegion() durch den Test
produktive SQUADRON-Gruppierungs-Aenderung
zweiter testlokaler SQUADRON mit parallelem Bestand
native DCS-Parking-Manipulation
```

## Letzter Test - zweiter V2-Versuch

Harness-Endergebnis:

```text
RESULT
status=COMPLETE_WITH_GAPS
casesTotal=3
casesObserved=2
casesFailed=1
```

### AH-64D / M230

```text
ASSIGNED cannons=600
ARRIVED  cannons=534
consumed=66
Landed -> Arrived
normaler AIRWING return
kein separater M230/M789 STORAGE-Key beobachtet
```

Bewertung: fuer die aktuelle Ressourcenfrage geschlossen. Realer Teilverbrauch und normaler Return sind belegt; interne M230/M789-Runden duerfen nicht als erfundener externer STORAGE-Key gespiegelt werden.

### OH-58D / M3P

```text
ASSIGNED guns=1600
ARRIVED  guns=1433
consumed=167
DCS debrief ammo_consumption sum=167
Landed -> Arrived
OH58D aircraft +2 on return
HYDRA_70_M151 +14 on return
weapons.containers.OH58D_M3P_L500 spawn debit=-2
weapons.containers.OH58D_M3P_L500 return delta=0
JETFUEL recovery=494.484 kg
```

Bewertung: fuer die aktuelle Ressourcenfrage geschlossen. `M3P_L500` ist im beobachteten Lifecycle ein Store-/Container-Item; aus dem Item darf keine Rundenkonversion abgeleitet werden.

### A-10C / GAU-8

```text
ASSIGNED cannons=2300
LANDED   cannons=2300
real gun consumption=0 in this run
AUFTRAG Strafing reported success
Arrived not reached within lifecycle timeout
flightState=Stopped
case result=LIFECYCLE_TIMEOUT
graveyard={}
```

Bewertung: dieser Lauf ist **kein** GAU-8-Verbrauchsnachweis. Ein frueherer V2-Lauf hat reale GAU-8-Abgabe belegt, aber ohne kompletten Arrived-/Return-Snapshot. Der A-10-Fall bleibt deshalb der aktuelle Gate-Fall.

## Aktuelle Warehouse-TODO-Liste

```text
1  STORAGE Fuel Adapter
   DONE

2  STORAGE Special Cases - coupled airbases
   DONE

3  CampaignState -> STORAGE Multi-Node Sync
   FUNCTIONAL DONE

4  CampaignState Resource Transaction Contract
   DONE fuer dokumentierten Scope

5  STORAGE Weapon Item Matrix
   DONE als read-only Discovery

6  AH-64 External-Store Consumption Correlation
   DONE fuer M151 / AGM-114K / IAFS-Beobachtung

7  AH-64 M230 / M789
   CLOSED FOR CURRENT RESOURCE QUESTION

8  AIRWING Weapon Lifecycle / normal return-recredit
   DONE fuer bisher untersuchte externe Stores

9  Controlled Partial Expenditure + Return
   SUBSTANTIALLY CONFIRMED
   offen nur A-10/GAU-8 normal-return correlation

10 Aircraft Loss
   OBSERVED

11 A-10C / GAU-8
   PARTIAL / CURRENT GATE

12 OH-58D / M3P
   CLOSED FOR CURRENT RESOURCE QUESTION

13 weitere OMW-Payloads
   IN PROGRESS

14 CampaignState <-> STORAGE Weapon Adapter
   BLOCKED bis Verbrauchs-/Return-Semantik ausreichend geklaert und fachlich entschieden ist
```

## Bevorstehender Retest

Der bestehende V2-Harness bleibt **unveraendert**. Dadurch laufen weiterhin alle drei Cases. AH-64 und OH-58 sind Regressionsbeobachtungen; der einzige Gate-Fall ist A-10C/GAU-8.

Erforderlicher A-10-Pfad im selben Lauf:

```text
1. TARGET_RESOLVED
2. LANDING_OPTION restrictPair=true
3. ASSIGNED cannons=2300
4. reale GAU-8-Schussabgabe
5. DCS debrief ammo_consumption > 0
6. LANDED mit cannons < 2300
7. ARRIVED
8. 30 s post-return observation
9. finaler STORAGE-Snapshot
10. CASE_RESULT status=OBSERVED gunStatus=CONSUMED
```

Nicht ausreichend:

```text
AUFTRAG success ohne ammo consumption
Landed ohne Arrived
reale Schussabgabe in einem Lauf und Return in einem anderen Lauf
```

Die benoetigte Evidenz muss fuer den A-10-Gate in **einem** vollstaendigen Lauf zusammenkommen.

Wenn die A-10 erneut nicht schiesst, wird nicht automatisch die Zielplatzierung geaendert: derselbe deterministische Zielpunkt hat in einem vorherigen Lauf reale GAU-8-Abgabe ermoeglicht. Ein `NO_GUN_CONSUMPTION` bleibt dann ein DCS-AI-Ausfuehrungsergebnis und kein PASS.

## Build und Code-Uebergabe

Source:

```text
mission/tests/airborne-ammo-partial-consumption/src/01-airborne-ammo-partial-consumption.lua
```

Builder:

```text
tools/build-airborne-ammo-partial-consumption.ps1
```

Bundle:

```text
mission/tests/airborne-ammo-partial-consumption/dist/OMW_Airborne_Ammo_Partial_Consumption.lua
```

Vollstaendiger lokaler Pfad fuer Mission Editor `DO SCRIPT FILE`:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\airborne-ammo-partial-consumption\dist\OMW_Airborne_Ammo_Partial_Consumption.lua
```

Uebergaberegeln:

- Lua-Code immer in fenced `lua` code blocks.
- Lokale Windows-Befehle immer in fenced `powershell` code blocks.
- Keine CODEX-Uebergabe.
- ChatGPT erstellt/prueft/committet/veroeffentlicht Remote-Aenderungen selbst.
- Danach erhaelt der Projektinhaber nur nummerierte PowerShell-Schritte fuer Pull, Build und Hash.
- Nur die reale zurueckgesendete Konsolenausgabe und die realen Hashes gelten als lokaler Nachweis.

### PowerShell Execution Policy auf der lokalen Entwicklungsmaschine

Direkter Aufruf wie

```powershell
& .\tools\build-airborne-ammo-partial-consumption.ps1
```

scheitert auf der lokalen Maschine mit `PSSecurityException`, weil Script Execution deaktiviert ist.

Verbindlicher lokaler Builder-Aufruf:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-airborne-ammo-partial-consumption.ps1
```

Die systemweite oder benutzerspezifische Execution Policy wird nicht fuer OMW geaendert.

Unabhaengige Hash-Pruefung:

```powershell
$Bundle = "P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\airborne-ammo-partial-consumption\dist\OMW_Airborne_Ammo_Partial_Consumption.lua"
Get-FileHash -LiteralPath $Bundle -Algorithm SHA256 | Format-List
```

## Acceptance-Grenze

Ein Fall ist nur dann als realer Partial-Expenditure/Return-Nachweis verwertbar, wenn reale Waffenabgabe und Lifecycle in derselben Ausfuehrung korrelierbar sind.

Fuer A-10 bedeutet das aktuell zwingend:

```text
real GAU-8 ammo consumption
+ Landed
+ Arrived
+ final STORAGE snapshot
```

`VALIDATED` bleibt bis zur vollstaendigen dokumentierten Provenienz einschliesslich exaktem MIZ-Hash gesperrt.
