---
document_id: OMW-MOOSE-AIRBORNE-AMMO-PARTIAL-CONSUMPTION
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-MOOSE-FIRST
authoritative_for:
  - source-reviewed MOOSE path for targeted airborne cannon expenditure tests
  - test-local RED target spawning and placement boundary
  - test-local landing-pair restriction boundary
  - branch-local DCS observations for M230, M3P and GAU-8 partial expenditure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/airborne-ammo-partial-consumption
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE Airborne Ammo Partial Consumption

## Zweck

Diese Notiz dokumentiert den source-reviewten und inzwischen teilweise praktisch beobachteten MOOSE-Pfad fuer den gezielten Verbrauchstest der offenen Bordwaffenfamilien M230/M789, GAU-8 und M3P. Sie dokumentiert ausserdem die Korrekturen fuer Zielplatzierung und Two-Ship-Recovery sowie den aktuellen Warehouse-TODO-Stand.

## Gepinnter Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Letzter lokal vom Projektinhaber verifizierter Build vor den dokumentarischen Folgecommits:

```text
Git commit: d0c13cf658db085f10acec43ee8e46fc8165b0da
BuilderVersion: AIRBORNE-AMMO-PARTIAL-CONSUMPTION-2
Bundle: mission/tests/airborne-ammo-partial-consumption/dist/OMW_Airborne_Ammo_Partial_Consumption.lua
Bundle SHA-256: 0288ec63c906c7d3fc63759d72d43a8c268eb1ee91c3f1dd8fa2dc6943a3fc68
DCS: 2.9.28.26385
Mission: OMW_Template_v8_AirOps_rdy.miz
MIZ hash for the cited runs: not supplied
```

Wegen des fehlenden exakten MIZ-Hashes duerfen die folgenden Laufzeitbeobachtungen nicht als vollstaendige `ACCEPTED_TECHNICAL_BASELINE` oder projektweites `VALIDATED` hochgestuft werden. Sie sind branchgebundene DCS-Evidenz.

## Source-reviewed APIs

```text
SPAWN:NewWithAlias(template, alias)
SPAWN:SpawnFromCoordinate(coordinate)
COORDINATE:GetClosestPointToRoad()
COORDINATE:IsInFlatArea(radius, maxSteepnessPercent)
AIRWING:NewPayload(...)
AUFTRAG:NewORBIT(...)
AUFTRAG:SetRequiredAssets(min, max)
AUFTRAG:NewSTRAFING(Target, Altitude, Length)
AUFTRAG:SetWeaponType(WeaponType)
AUFTRAG:SetWeaponExpend(WeaponExpend)
AUFTRAG:SetEngageQuantity(Quantity)
OPSGROUP:AddMission(Mission)
OPSGROUP:GetAmmoTot()
FLIGHTGROUP:SetOptionLandingRestrictPair()
STORAGE:GetInventory()
STORAGE.Liquid.JETFUEL
```

`AUFTRAG:NewSTRAFING()` setzt im gepinnten Source standardmaessig Guns/Cannons plus Rockets. Fuer den OMW-Kanonentest wird danach mit `SetWeaponType()` auf die MOOSE-Enums

```text
ENUMS.WeaponFlag.GunPod         = 268435456
ENUMS.WeaponFlag.BuiltInCannon = 536870912
```

beschraenkt. Die Summe entspricht dem im MOOSE-TaskStrafing-Beispiel dokumentierten Cannon-Flag `805306368`.

`SetWeaponExpend(AI.Task.WeaponExpend.QUARTER)` ist nur eine DCS-AI-Vorgabe. OMW interpretiert sie nicht als garantierte Rundenzahl. Der reale Verbrauch wird aus `GetAmmoTot()` und fuer Acceptance zusaetzlich aus dem DCS-Debrief abgeleitet.

## Gruppierungsgrenze

Der gepinnte Source bestaetigt:

1. `SQUADRON:SetGrouping(n)` bestimmt die Unit-Anzahl jeder MOOSE-Assetgruppe der SQUADRON.
2. `AUFTRAG:SetRequiredAssets(min, max)` fordert Assetgruppen, nicht einzelne Luftfahrzeuge.

Damit gilt bei den produktiven A-10C-, OH-58D- und AH-64D-SQUADRONs mit `Grouping=2`:

```text
SetRequiredAssets(1, 1)
= eine MOOSE-Assetgruppe
= ein produktives Two-Ship
```

Der Test aendert diese produktive Gruppierung nicht. Ein testlokaler zweiter SQUADRON mit `Grouping=1` wuerde eine parallele Bestandsrepraesentation riskieren und ist fuer diesen Warehouse-Test nicht zulaessig.

## Zielplatzierung

Die V1-Annahme `Airbase + 10 km + feste Peilung` war unzureichend. V2 verwendet ausschliesslich vorhandene MOOSE-Funktionen:

```text
bevorzugte Entfernung/Peilung je Fall
-> bounded distance/bearing search
-> COORDINATE:GetClosestPointToRoad()
-> COORDINATE:IsInFlatArea(35 m, 8 %)
-> erster gueltiger Kandidat
-> sonst fail closed
```

Bevorzugte Distanzen:

```text
A-10C:  20 km
OH-58D: 12 km
AH-64D: 12 km
```

Die Suche ist deterministisch. Bei unveraenderter Mission, Karte und Airbase-Koordinate werden dieselben Kandidaten in derselben Reihenfolge geprueft. In den beiden ausgewerteten V2-Laeufen wurde fuer die A-10 derselbe Kandidat verwendet:

```text
preferredDistanceM=20000
actualDistanceM=20000
preferredBearing=45
actualBearing=45
measuredSteepness=2
```

Der Unterschied zwischen einem A-10-Lauf mit realer GAU-8-Abgabe und einem Lauf ohne GAU-8-Abgabe ist damit nicht durch eine andere Zielposition erklaert.

## Two-Ship-Recovery

`SQUADRON:SetParkingIDs()` ist eine Spawn-Parking-Einschraenkung fuer SQUADRON-Assets. Daraus folgt keine belegte individuelle Return-Parking-Garantie fuer jedes Element eines Two-Ships.

Der Test setzt deshalb auf genau den zugewiesenen Test-FLIGHTGROUPs:

```text
FLIGHTGROUP:SetOptionLandingRestrictPair()
```

Das ist eine oeffentliche MOOSE-/DCS-Landing-Option und kein Parking-Override. Die produktive AIRWING-/SQUADRON-Konfiguration bleibt unveraendert.

Praktische V2-Erfahrung:

```text
AH-64D:
  Landed -> Arrived in wiederholten Laeufen erreicht
  native AIRWING-Return-Snapshots vorhanden

OH-58D:
  Landed -> Arrived erreicht
  native AIRWING-Return-Snapshot vorhanden

A-10C:
  Landed erreicht
  Arrived bislang nicht reproduzierbar erreicht
  frueherer Lauf: beide A-10 rollten in Statics und wurden zerstoert
  spaeterer Lauf: graveyard leer, aber Lifecycle blieb vor Arrived stehen
```

Damit ist `SetOptionLandingRestrictPair()` fuer den dokumentierten Test als brauchbare Pair-Recovery-Massnahme fuer die beiden Helikoptertypen praktisch beobachtet, aber **keine Garantie fuer individuelle Parking-IDs oder generell fehlerfreie Recovery**. A-10-Taxi-/Parking-Verhalten bleibt eine offene DCS-/Mission-Interaktion, wird im Warehouse-TODO aber nur soweit behandelt, wie es die Return-Evidenz blockiert.

Bewusst nicht verwendet:

```text
SetDespawnAfterLanding()
SetDespawnAfterHolding()
ReturnToLegion() durch den Test
produktive SQUADRON-Gruppierungs-Aenderung
native DCS-Parking-Manipulation
```

## Letzte zwei DCS-Laeufe

### Lauf A - vorzeitig beendeter DCS-Lauf

Der erste V2-Lauf zeigte optisch brauchbare Zielplatzierung und Recovery. DCS wurde jedoch waehrend beziehungsweise nach der Landung der zweiten OH-58/A-10 unresponsive und musste per Taskmanager beendet werden.

Belastbare Harness-Evidenz vor dem Abbruch:

```text
AH-64D M230:
  assigned cannons=600
  arrived cannons=549
  consumed=51
  aircraft return +2
  AGM-114K return +4
  M151 return +76
  kein separater M230/M789 STORAGE-Key beobachtet

OH-58D M3P:
  assigned guns=1600
  arrived guns=1464
  consumed=136
  Landed und Arrived erreicht
  finaler Return-Snapshot wegen Laufende nicht mehr geschrieben

A-10C GAU-8:
  assigned cannons=2300
  landed cannons=1764
  realer Verbrauch vorhanden
  kein finaler Arrived-/Return-Snapshot
```

Dieser Lauf war fuer AH-64 vollstaendig genug, fuer OH-58 und A-10 nicht.

### Lauf B - zweiter Versuch / aktueller Referenzlauf

Der zweite V2-Lauf endete im Harness regulär mit:

```text
status=COMPLETE_WITH_GAPS
casesTotal=3
casesObserved=2
casesFailed=1
```

Ergebnisse:

```text
SHND_AH64D_M230
  assigned cannons=600
  arrived cannons=534
  consumedCannons=66
  Landed -> Arrived
  aircraft +2 on return
  external stores returned
  kein separater M230/M789 STORAGE-Pfad beobachtet

JBAD_OH58D_M3P
  assigned guns=1600
  arrived guns=1433
  consumedGuns=167
  DCS debrief ammo_consumption sum=167
  Landed -> Arrived
  OH58D aircraft +2 on return
  HYDRA_70_M151 +14 on return
  JETFUEL recovery=494.484 kg
  weapons.containers.OH58D_M3P_L500 spawn debit=-2
  weapons.containers.OH58D_M3P_L500 return delta=0

KAF_A10C_GAU8
  assigned cannons=2300
  landed cannons=2300
  gun consumption=0 in this run
  Strafing AUFTRAG reported success, but no real GAU-8 expenditure
  Landed reached
  Arrived not reached within 3600 s
  flightState=Stopped
  case result=LIFECYCLE_TIMEOUT
  graveyard empty in debrief
```

Wichtige Schlussfolgerungen:

1. Ein `AUFTRAG`-Status `success` beweist **keine** reale Waffenabgabe. Ammo-Telemetrie und DCS-Debrief bleiben autoritativ.
2. M3P ist im beobachteten DCS-STORAGE-Pfad ein Store-/Container-Lifecycle, kein nachgewiesener Rundenzahlspeicher. Aus `M3P_L500 -2/+0` darf keine Round-Conversion abgeleitet werden.
3. M230/M789 zeigt trotz normalem Return keinen separaten beobachteten STORAGE-Weapon-Key. Interne Kanonenmunition darf deshalb nicht als externer Store gespiegelt werden.
4. Zielplatzierung ist fuer den aktuellen Harness ausreichend. Die A-10-Abweichung zwischen realer Schussabgabe und `NO_GUN_CONSUMPTION` trat am selben deterministischen Zielkandidaten auf.
5. Two-Ship-Recovery ist fuer AH-64 und OH-58 im Test ausreichend verbessert; A-10 bleibt der einzige Gate-Fall.

## Aktueller Warehouse-TODO-Stand

```text
1  STORAGE Fuel Adapter
   DONE / technisch akzeptierter Scope vorhanden

2  STORAGE Special Cases - coupled airbases
   DONE

3  CampaignState -> STORAGE Multi-Node Sync
   FUNCTIONAL DONE; formale Provenienz getrennt zu beachten

4  CampaignState Resource Transaction Contract
   DONE fuer den dokumentierten Scope

5  STORAGE Weapon Item Matrix
   DONE als read-only Discovery

6  AH-64 External-Store Consumption Correlation
   DONE fuer M151 / AGM-114K / IAFS-Beobachtung

7  AH-64 M230 / M789
   CLOSED FOR CURRENT RESOURCE QUESTION
   - realer Teilverbrauch mehrfach bestaetigt
   - onboard delta + DCS expenditure belegt
   - normaler Arrived/Return belegt
   - kein separater M230/M789 STORAGE-Key beobachtet

8  AIRWING Weapon Lifecycle / normal return-recredit
   DONE fuer die bisher untersuchten externen Stores
   - M151/Hellfire recredit
   - F-16 370-gal tank recredit
   - IAFS Sonderfall bleibt dokumentiert

9  Controlled Partial Expenditure + Return
   SUBSTANTIALLY CONFIRMED
   - AH-64/M230 abgeschlossen
   - OH-58/M3P abgeschlossen
   - A-10/GAU-8 Return-Korrelation noch offen

10 Aircraft Loss
   OBSERVED; keine identische Wiederholung im aktuellen Ammo-Test erforderlich

11 A-10C / GAU-8
   PARTIAL / CURRENT GATE
   - realer GAU-8-Verbrauch in frueherem Lauf belegt
   - onboard telemetry belegt
   - aktueller Lauf ohne Schussabgabe
   - Arrived/finaler normal-return STORAGE-Snapshot fehlt

12 OH-58D / M3P
   CLOSED FOR CURRENT RESOURCE QUESTION
   - real expenditure 167 rounds
   - onboard 1600 -> 1433
   - DCS debrief sum=167
   - Landed -> Arrived
   - aircraft +2
   - Hydra +14
   - M3P_L500 -2 at spawn / +0 at return
   - keine Round-Conversion ableiten

13 weitere OMW-Payloads
   IN PROGRESS ueber Census/weitere gezielte Korrelation

14 CampaignState <-> STORAGE Weapon Adapter
   BLOCKED
   - nicht implementieren, bis die benoetigten Verbrauchs-/Return-Semantiken ausreichend geklaert und fachlich entschieden sind
```

## Bevorstehender Retest - exakte Zielsetzung

Der **naechste Lauf verwendet den bestehenden V2-Harness unveraendert**. Alle drei Cases laufen weiter, weil der aktuelle Builder keine Single-Case-Selektion besitzt. AH-64 und OH-58 liefern dabei Regressionsbeobachtung; **A-10 ist der einzige Gate-Fall**.

Erforderliche A-10-Sequenz:

```text
KAF_A10C_GAU8
1. TARGET_RESOLVED am deterministischen Road-/Flat-Kandidaten
2. LANDING_OPTION restrictPair=true
3. ASSIGNED cannons=2300 als Ausgangstelemetrie
4. echter GAU-8 STRAFING-Angriff
5. DCS debrief mit ammo_consumption > 0
6. LANDED mit kleinerem Cannon-Bestand als ASSIGNED
7. ARRIVED
8. 30 s post-return observation
9. finaler STORAGE-Snapshot
10. CASE_RESULT status=OBSERVED gunStatus=CONSUMED
```

Der Retest ist **nicht** bestanden, wenn nur `AUFTRAG ... success` erscheint. Fuer den A-10-Gate muessen reale GAU-8-Schuesse und ein vollstaendiger `Landed -> Arrived -> final STORAGE`-Pfad zusammen im selben Lauf vorliegen.

Nicht Teil des Retests:

```text
allgemeine A-10-Taxi-/Parking-Reparatur
produktive Parking-Pool-Aenderung
Single-Ship-Umbau produktiver Two-Ships
Despawn-Workaround
CampaignState weapon adapter
Round-to-container conversion
```

Wenn A-10 erneut nicht schiesst, der STRAFING-Auftrag aber `success` meldet, wird zunaechst **kein** Zielplatzierungs-Umbau vorgenommen, weil derselbe Zielpunkt bereits reale GAU-8-Abgabe erzeugt hat. Dann ist das Verhalten als DCS-AI-Ausfuehrungsvarianz zu behandeln und der Lauf wird nicht als Consumption-Acceptance gewertet.

## Operator-/Code-Uebergabe fuer diesen Test

Lua-Quellcode zur Uebergabe immer in einem `lua`-Codeblock darstellen. Lokale Befehle fuer den Projektinhaber immer in einem `powershell`-Codeblock darstellen.

Auf der lokalen Windows-Entwicklungsmaschine blockiert die PowerShell Execution Policy direkte Repository-Skriptaufrufe wie:

```powershell
& .\tools\build-airborne-ammo-partial-consumption.ps1
```

Der offizielle Builder ist deshalb lokal ueber einen Child-Prozess mit process-lokalem Bypass auszufuehren:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\build-airborne-ammo-partial-consumption.ps1
```

Die systemweite oder benutzerspezifische Execution Policy wird fuer OMW **nicht** geaendert.

Mission-Editor-Bundle:

```text
P:\DCS-DEV\Operation-Mountain-Watch\mission\tests\airborne-ammo-partial-consumption\dist\OMW_Airborne_Ammo_Partial_Consumption.lua
```

Nach jedem Source-/Builder-aendernden Remote-Commit gilt:

```text
ChatGPT remote commit
-> owner git pull
-> official builder via ExecutionPolicy Bypass
-> independent Get-FileHash SHA256
-> owner sends real console output/hash
-> Mission Editor DO SCRIPT FILE reselect
-> save mission
-> DCS run
-> return dcs.log + debrief.log
```

Reine Dokumentationscommits aendern den generierten Lua-Inhalt nicht automatisch. Ein Build-/Hash-Nachweis darf trotzdem nicht erfunden oder aus einem frueheren Commit als neuer Nachweis ausgegeben werden.

## Testgrenze

Der Test darf:

- vorhandene RED-ME-Seeds mit MOOSE `SPAWN` testlokal klonen;
- Zielkoordinaten mit einem bounded MOOSE Road-/Flatness-Suchlauf bestimmen;
- einen echten MOOSE-STRAFING-Auftrag in die Queue eines ueber AIRWING materialisierten `FLIGHTGROUP` stellen;
- auf genau diesen Test-FLIGHTGROUPs `SetOptionLandingRestrictPair()` setzen;
- Ammo-, STORAGE- und Fuel-Telemetrie read-only erfassen.

Der Test darf nicht:

- CampaignState veraendern;
- STORAGE-Bestaende direkt veraendern;
- `coalition.addGroup()` direkt verwenden;
- `ReturnToLegion()` selbst aufrufen;
- Landing-/Holding-Despawn als Recovery-Workaround aktivieren;
- produktive SQUADRON-Gruppierung veraendern;
- eine kuenstliche Munitionsmenge als realen Verbrauch buchen.
