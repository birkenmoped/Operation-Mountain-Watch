---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-INDEX
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - combined STORAGE special-case topology test scope
  - Kandahar main versus heliport warehouse aliasing test
  - Shindand main versus heliport warehouse aliasing test
  - FOB Salerno versus Khost warehouse separation test
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/campaignstate-storage-special-cases
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/campaignstate-storage-special-cases
acceptance_commit: b8f3c8328bfae08033a3f304ad2e9d92b5a3bc83
acceptance_mission: OMW_Template_v8_AirOps_rdy(4).miz
acceptance_mission_sha256: 66bcf79696985a9a60c961b1078e7f36915ff5a83cd315f6c049d388981fc730
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
base_branch: agent/campaignstate-storage-sync-foundation
base_commit: 6087e389824a82d01ba735ba8e8f63951840cb08
base_status: ACCEPTED_TECHNICAL_BASELINE
merged_to_main: false
inherited_risk:
  - parent branch may still be revised
---

# Gemeinsamer STORAGE-Sonderfalltest

## 1. Ziel

Dieser Test bündelt die drei für die spätere Multi-Node-Synchronisation relevanten Warehouse-Sonderfälle in einem DCS-Lauf. Er testet nicht Flugplatz für Flugplatz, sondern die gemeinsame Frage, welche nativen DCS-Warehouse-/MOOSE-STORAGE-Endpunkte tatsächlich voneinander unabhängig sind.

Geprüfte Paare:

```text
Kandahar            <-> Kandahar Heliport
Shindand             <-> Shindand Heliport
FOB Salerno          <-> Khost
```

Für OMW gilt dabei bereits:

- Kandahar besitzt zwei getrennte AirOps-Domänen und zwei getrennte MOOSE-AIRWING-Warehouse-Statics;
- für Shindand ist nur `Shindand Heliport` als OMW-AirOps-Knoten relevant;
- Salerno ist als `FOB Salerno` zu behandeln, nicht als Khost Airport.

Der Test klärt ausschließlich, ob die jeweils zugehörigen nativen DCS-Warehouses getrennte oder gekoppelte Liquid-Bestände darstellen.

## 2. MOOSE-First-Pfad

Der Harness bleibt auf den bereits für den OMW-STORAGE-Pfad source-reviewed beziehungsweise praktisch bestätigten öffentlichen Methoden:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
STORAGE.Liquid.MW50
STORAGE.Liquid.DIESEL
```

Keine `_DATABASE`-Abfrage, kein `world.searchObjects`, keine neue Native-DCS-Warehouse-Abstraktion und kein CampaignState-Write werden verwendet.

## 3. Testprinzip

Jeder Endpunkt wird sowohl über `AIRBASE:GetStorage()` als auch über `STORAGE:FindByName()` aufgelöst. Beide Auflösungen müssen dasselbe MOOSE-STORAGE-Objekt ergeben. Der Test protokolliert:

```text
Airbase-Name
Airbase-ID
JETFUEL
GASOLINE
MW50
DIESEL
MOOSE-STORAGE-Wrapper-Identität innerhalb des jeweiligen Paars
```

Wenn ein Paar nicht bereits denselben STORAGE-Wrapper verwendet, wird ein kontrollierter Black-Box-Aliasing-Test ausgeführt:

```text
1. Ausgangsbestand JETFUEL beider Endpunkte lesen
2. Quellbestand temporär um 37 kg erhöhen
3. Quell- und Gegenendpunkt erneut lesen
4. wenn der Quellwert den Sollwert nicht annimmt:
   Quelle als nicht schreibbar behandeln und Gegenrichtung versuchen
5. andernfalls Änderung am Gegenendpunkt klassifizieren
6. Ausgangsbestand sofort wiederherstellen
7. Wiederherstellung auf beiden Endpunkten verifizieren
```

Klassifikationen:

```text
SHARED_IDENTITY
SHARED_BEHAVIOR
INDEPENDENT_BEHAVIOR
INCONCLUSIVE
```

`INCONCLUSIVE` entsteht, wenn keine der beiden Richtungen einen kontrollierten Sollwert-Readback erlaubt, etwa bei Unlimited Liquids.

## 4. Schutzgrenzen

Der Test verändert keinen strategischen CampaignState und führt keine persistente Ressourcenbuchung aus.

Ausgeschlossen:

```text
CampaignState mutation
CampaignState -> STORAGE production sync
reverse DCS -> CampaignState overwrite
persistence
scheduler-based continuous sync
AIRWING stock mutation
weapon/item synchronization
CTLD
OPSTRANSPORT
```

Die einzige beabsichtigte Runtime-Mutation ist der temporäre `37 kg`-JETFUEL-Probeimpuls. Jede erfolgreiche Probe muss mit `RESTORE_PASS` enden. Ein Restore-Fehler erzeugt `status=FAIL`.

## 5. Source- und Build-Pfade

```text
mission/tests/campaignstate-storage-special-cases/src/01-storage-special-cases.lua
tools/build-campaignstate-storage-special-cases.ps1
mission/tests/campaignstate-storage-special-cases/dist/OMW_CampaignState_Storage_Special_Cases_Test.lua
mission/tests/campaignstate-storage-special-cases/expected/campaignstate-storage-special-cases-acceptance.md
```

Builder-Version:

```text
CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1
```

MOOSE-Baseline:

```text
Release: 2.9.18
Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## 6. DCS-Acceptance

Der kombinierte Lauf vom 2026-08-10 endete mit:

```text
RESULT testId=CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-1 status=PASS pairs=3 inconclusive=0 campaignStateMutation=false reverseOverwrite=false persistentMutation=false
```

Bestätigte Topologie:

```text
Kandahar            <-> Kandahar Heliport : INDEPENDENT_BEHAVIOR
Shindand             <-> Shindand Heliport: INDEPENDENT_BEHAVIOR
FOB Salerno          <-> Khost             : INDEPENDENT_BEHAVIOR
```

Alle drei `37 kg`-JETFUEL-Proben wurden am jeweiligen Quell-Storage exakt gelesen, beeinflussten den Gegenendpunkt nicht und wurden mit `RESTORE_PASS` vollständig zurückgesetzt.

Für die OMW-Topologie folgt daraus:

```text
Kandahar            -> eigener Fuel-Storage
Kandahar Heliport   -> eigener Fuel-Storage
Shindand Heliport   -> eigener Fuel-Storage; Shindand Main bleibt außerhalb des OMW-AirOps-Fuel-Scopes
FOB Salerno          -> eigener Fuel-Storage; Khost ist kein Ersatzknoten
```

Acceptance-Provenienz:

```text
Source/Builder commit: b8f3c8328bfae08033a3f304ad2e9d92b5a3bc83
Bundle SHA-256: 3b5a373752419fd1596a387b0af4256c1e99168c20ffa7d4b4b476d3775b4f92
Mission: OMW_Template_v8_AirOps_rdy(4).miz
Mission SHA-256: 66bcf79696985a9a60c961b1078e7f36915ff5a83cd315f6c049d388981fc730
DCS log SHA-256: d096c8f398ba1c2fa1ae62a28b264461429cf35842d3697e1ac16746b661ade9
Debrief SHA-256: f1b8c867be49bcbc95e5705c726467b3c94567f580fadaa9b62cb4e3b8f4e65e
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Das eingebettete Testbundle in der hochgeladenen MIZ besitzt denselben SHA-256 wie der zuvor lokal gebaute Bundle-Stand.

Der vollständige Nachweis steht in `expected/campaignstate-storage-special-cases-acceptance.md`.

## 7. Acceptance-Grenze

Der Status `ACCEPTED_TECHNICAL_BASELINE` gilt ausschließlich für die dokumentierte STORAGE-Topologie und das kontrollierte JETFUEL-Aliasing-/Restore-Verhalten dieses exakten Branch-/Commit-/MIZ-/DCS-/MOOSE-Stands.

Nicht belegt bleiben:

```text
CampaignState multi-node synchronization
continuous reconciliation
persistence/restart behavior
multiplayer reconciliation
automatic aircraft fuel debit
weapon/item synchronization
CTLD or OPSTRANSPORT resource accounting
```
