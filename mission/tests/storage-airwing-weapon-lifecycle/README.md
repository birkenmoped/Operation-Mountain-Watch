---
document_id: OMW-TEST-STORAGE-AIRWING-WEAPON-LIFECYCLE-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - read-only STORAGE/AIRWING weapon lifecycle correlation scope
  - Shindand AH-64D repeated debit and native return observation
  - Bagram F-16C external-tank debit and return comparison
  - interpretation boundary for IAFS, droptanks, landing, arrival, ReturnToLegion and warehouse recredit evidence
  - user-visible DCS test progress and completion protocol
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

## 1. Ziel

`STORAGE-AIRWING-WEAPON-LIFECYCLE-4` buendelt die noch unmittelbar zusammenhaengenden Warehouse-Lifecycle-Fragen in **einen** DCS-Lauf. Der Gate bleibt ein read-only Beobachter und erzeugt keine zweite Ressourcenhoheit neben `CampaignState`.

Der Lauf untersucht:

```text
7 STORAGE baselines
-> Shindand AH-64D TwoShip #1 materialization
-> known debit control: -76 M151 / -4 AGM-114K / -2 IAFS ComboPak
-> native Arrived / ReturnToLegion path
-> AH-64 post-return STORAGE observation
-> Shindand AH-64D TwoShip #2 materialization and native return
-> repeated AH-64 debit/recredit observation
-> Bagram F-16C TwoShip materialization
-> runtime discovery of the actual droptank STORAGE key(s)
-> exactly four external-tank items expected from the OMW TwoShip template configuration
-> native F-16 Arrived / ReturnToLegion path
-> FULL / NONE / PARTIAL tank-recredit classification
-> final STORAGE state
```

Der Test mutiert weder STORAGE noch CampaignState und implementiert keine eigene Recovery-, Warehouse- oder Asset-FSM.

## 2. Evidenz vor V4

### 2.1 Verworfener V1-Lauf

`STORAGE-AIRWING-WEAPON-LIFECYCLE-1` ist **keine gueltige STORAGE-Lifecycle-Evidenz**. Der Harness behandelte `STORAGE:GetInventory()` faelschlich wie eine einzelne strukturierte Tabelle. Im gepinnten MOOSE-Stand liefert die Methode exakt drei Rueckgabewerte:

```lua
local aircraft, liquids, weapons = storage:GetInventory()
```

V1 verlor dadurch die Weapon-Tabelle, protokollierte `weaponKeys=0` und konnte trotzdem PASS melden. Dieser Lauf bleibt nur als AIRWING-/FLIGHTGROUP-Telemetrie historisch informativ.

### 2.2 Gueltiger V2-Lauf vom 11.08.2026

Der korrigierte Lauf verwendete den Drei-Rueckgabewert-Vertrag und beobachtete bei beiden Shindand-AH-64D-TwoShips reproduzierbar:

```text
materialization:
  HYDRA_70_M151        -76
  AGM_114K              -4
  IAFS_ComboPak_100     -2

native return:
  HYDRA_70_M151        +76
  AGM_114K              +4
  IAFS_ComboPak_100       0
```

Nach zwei TwoShips blieb `IAFS_ComboPak_100` damit netto bei `-4`, waehrend M151 und AGM-114K jeweils wieder den Ausgangsbestand erreichten.

Der Mission Editor zeigt das IAFS im verwendeten AH-64D-Template als internen 100-Gal-Treibstofftank. Im gepinnten MOOSE-Enum liegt `IAFS_ComboPak_100` unter `weapons.droptanks`. Der bisherige Befund darf daher nicht als M230-/M789-Munitionsverbrauch interpretiert werden.

## 3. Warum V4 zusaetzlich einen F-16-TwoShip prueft

Die fehlende IAFS-Rueckgabe kann ein AH-64-spezifischer Sonderfall oder Teil einer allgemeineren DCS-Warehouse-Semantik fuer Tanks sein. Ein separater weiterer Tank-Test ist nicht vorgesehen; der F-16-Vergleich wird in denselben Lifecycle-Gate integriert.

Die verbindliche Bagram-Foundation stellt bereit:

```text
AW_US_BGRM_455_AEW
SQ_US_BGRM_F16C_121_EFS
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
Grouping: 2
```

Nach Projektinhaberangabe traegt jedes Flugzeug dieses OMW-Templates zwei externe Tanks. Der erwartete physische Vergleichsfall ist deshalb:

```text
2 F-16 x 2 external tanks = 4 tank items
```

V4 **hardcodiert keinen konkreten F-16-Warehouse-Key**. Der gepinnte MOOSE-Stand enthaelt mehrere Droptank-Enums, darunter `fuel_tank_370gal` und `F-16-PTB-N2`; Enum-Existenz beweist aber nicht, welchen Key DCS fuer das reale OMW-Template abbucht. V4 ermittelt deshalb alle positiven Debits mit dem Prefix:

```text
weapons.droptanks.
```

unmittelbar aus dem Bagram-STORAGE-Delta der F-16-Materialisierung.

## 4. MOOSE-First

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed fuer V4:

```text
STORAGE:GetInventory() -> aircraft, liquids, weapons
STORAGE:FindByName()
AIRBASE:GetStorage()
AIRWING:AddMission()
AUFTRAG:NewCAS()
AUFTRAG:AssignSquadrons({ SQUADRON })
AUFTRAG:SetROE(ENUMS.ROE.WeaponHold)
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP OnAfterLanded callback
FLIGHTGROUP OnAfterArrived callback
FLIGHTGROUP internal onafterArrived -> ReturnToLegion(1) for AI AIRWING assets
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`AUFTRAG:AssignSquadrons()` erwartet im gepinnten Source eine Tabelle und schraenkt die fuer die Mission betrachteten Airwing-Squadrons auf diese Eintraege ein. V4 verwendet dies fuer AH-64D und F-16C, damit kein anderes geeignetes Airwing-Asset den Testfall uebernimmt.

`AUFTRAG:SetROE(ENUMS.ROE.WeaponHold)` wird verwendet, um die drei Lifecycle-Legs als no-fire Vergleich zu halten. Der Test ruft `ReturnToLegion()` nicht selbst auf; Recovery bleibt der native MOOSE-AIRWING-/FLIGHTGROUP-Pfad.

## 5. Testbedingungen

- Shindand- und Bagram-Foundation muessen geladen und `RUNNING` sein.
- `OMW.AirOps.Shindand.Squadrons.AH64D` muss vorhanden sein.
- `OMW.AirOps.Bagram.Squadrons.F16C` und `OMW.AirOps.Bagram.Airwings.USAF` muessen vorhanden sein.
- Keine Client-/Rearm-/weitere AI-Payload-Aktion an den sieben beobachteten STORAGE-Endpunkten waehrend des Gates.
- Die F-16-Templatekonfiguration bleibt fuer diesen Lauf bei zwei externen Tanks je Flugzeug.
- Keine STORAGE- oder CampaignState-Mutation durch den Harness.

Ein realistischer Anlass-, Taxi-, Takeoff- oder Missionsflug ist **kein Acceptance-Kriterium dieses Gates**. Die Fragestellung ist die DCS-Warehouse-Buchung bei realer MOOSE-AIRWING-Materialisierung und beim nativen ReturnToLegion-Lifecycle. `Landed` bleibt optionale Telemetrie; `Arrived` ist der source-reviewte Recovery-Anker des hier beobachteten Pfads.

## 6. Fail-Fast-Kontrollen

Vor dem ersten Dispatch muessen gelten:

```text
all seven AIRBASE/STORAGE wrappers resolve
AIRBASE:GetStorage() == STORAGE:FindByName()
GetInventory() returns three tables
weapon inventory is non-empty at every observed node
Shindand baseline contains numeric:
  weapons.nurs.HYDRA_70_M151
  weapons.missiles.AGM_114K
  weapons.droptanks.{IAFS_ComboPak_100}
```

Der erste AH-64-TwoShip muss exakt reproduzieren:

```text
HYDRA_70_M151: -76
AGM_114K: -4
IAFS_ComboPak_100: -2
```

Vor dem F-16-Dispatch wird ein neuer Bagram-Waffen-Snapshot genommen. Nach der F-16-Zuweisung muss die Summe aller neu beobachteten positiven Debits unter `weapons.droptanks.*` exakt `4` betragen. Die konkreten Keys werden protokolliert.

Ein von `4` abweichender Gesamtdebit ist ein harter FAIL fuer die geplante Template-/Warehouse-Korrelation und wird nicht stillschweigend als Tank-Semantik interpretiert.

## 7. F-16-Tank-Recredit-Klassifikation

Nach dem nativen F-16-Return vergleicht V4 fuer jeden beim Spawn entdeckten Tank-Key:

```text
pre-dispatch stock
spawn stock
debit
post-return stock
recovered amount
```

Der beobachtete Gesamtpfad wird klassifiziert als:

```text
FULL    recovered == debited
NONE    recovered == 0
PARTIAL 0 < recovered < debited
```

Diese Klassifikation ist **das Messergebnis** und kein vorweggenommenes PASS-Kriterium. Der Gate darf bei `FULL`, `NONE` oder `PARTIAL` PASS liefern, wenn Materialisierung, `-4`-Kontrollsumme, native Recovery und gueltige STORAGE-Auswertung vollstaendig beobachtet wurden.

Eine fehlende oder teilweise Tank-Rueckgabe autorisiert noch keine produktive Fake-Recredit-Logik. Erst nach Auswertung entscheidet der Projektinhaber, ob DCS-Droptanks nicht strategisch gespiegelt beziehungsweise unbegrenzt bereitgestellt werden oder ob eine ausdruecklich genehmigte Korrekturschicht erforderlich ist.

## 8. Beobachtung und Teststatus

Alle sieben STORAGE-Endpunkte werden weiterhin read-only gepollt:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

Weapon-Deltas werden vollstaendig mit Node, Item-Key, Before, After, Delta, Phase und Elapsed-Time protokolliert. Zusaetzlich protokolliert V4 die bekannten AH-64-Keys und die dynamisch erkannten F-16-Droptank-Deltas.

MOOSE `MESSAGE` zeigt Start, Phasenwechsel, Heartbeat, FAIL und Abschluss. Bei erfolgreichem Abschluss wird die F-16-Tankklassifikation direkt angezeigt:

```text
F-16 tank recredit: FULL|NONE|PARTIAL (recovered/debited)
```

Der Lauf darf beendet werden, sobald `TEST COMPLETE - PASS` oder `TEST FAILED` angezeigt wird. Ohne Abschlussmeldung gilt er als unvollstaendig. Safety-Timeout: 1800 Sekunden.

## 9. PASS-Semantik

Harness-PASS bedeutet ausschliesslich:

```text
7 STORAGE endpoints resolved
three-return GetInventory contract valid
non-empty weapon inventories observed
known AH-64 first debit exactly validated
AH-64 TwoShip #1 assigned and Arrived
AH-64 TwoShip #2 assigned and Arrived
both AH-64 legs no-fire by GetAmmoTot assignment/arrival comparison
Bagram F-16C TwoShip assigned through the requested Squadron
runtime droptank debit discovered
F-16 droptank debit total exactly 4
F-16 Arrived/native return observed
F-16 no-fire by GetAmmoTot assignment/arrival comparison
F-16 tank recredit classified FULL/NONE/PARTIAL
final STORAGE observation completed
no STORAGE mutation
no CampaignState mutation
no custom ReturnToLegion call
no direct spawn
```

Der konkrete fachliche Warehouse-Befund wird erst nach Auswertung des realen DCS-Logs akzeptiert.

## 10. Nicht Teil dieses Gates

```text
controlled partial weapon expenditure
intentional aircraft destruction / loss accounting
M230 / M789 direct STORAGE mapping
A-10C / GAU-8 mapping
OH-58D / M3P mapping
CampaignState weapon adapter
STORAGE mutation adapter
OPSTRANSPORT
CTLD
persistence
restart/multiplayer reconciliation
parking acceptance
```

Diese Punkte werden nicht durch weitere isolierte Vorabtests zerlegt. Die naechsten DCS-Laeufe sollen offene Lifecycle-Fragen soweit technisch sinnvoll gebuendelt behandeln.

## 11. Build

```text
mission/tests/storage-airwing-weapon-lifecycle/src/01-storage-airwing-weapon-lifecycle.lua
tools/build-storage-airwing-weapon-lifecycle.ps1
mission/tests/storage-airwing-weapon-lifecycle/dist/OMW_Storage_Airwing_Weapon_Lifecycle_Test.lua
```

BuilderVersion:

```text
STORAGE-AIRWING-WEAPON-LIFECYCLE-4
```

Der Builder erzwingt insbesondere:

```text
correct three-return GetInventory call
seven-node observer markers
AH-64 known debit control
F-16 dynamic droptank-key discovery
F-16 expected tank total = 4
AssignSquadrons restriction
WeaponHold no-fire configuration
MOOSE MESSAGE status
no STORAGE/CampaignState mutation
no ReturnToLegion call by test
no direct SPAWN / coalition.addGroup
```
