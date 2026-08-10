---
document_id: OMW-TEST-CAMPAIGNSTATE-STORAGE-SPECIAL-CASES-INDEX
status: PLANNED
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
validated_in_dcs: false
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

Der Harness verwendet ausschließlich öffentliche, im gepinnten MOOSE-Quellstand vorhandene Methoden:

```text
AIRBASE:FindByName()
AIRBASE:GetStorage()
AIRBASE:GetWarehouse()
STORAGE:FindByName()
STORAGE:GetLiquidAmount()
STORAGE:SetLiquid()
STORAGE:IsUnlimitedLiquids()
STORAGE.Liquid.JETFUEL
STORAGE.Liquid.GASOLINE
STORAGE.Liquid.MW50
STORAGE.Liquid.DIESEL
```

Keine `_DATABASE`-Abfrage, kein `world.searchObjects`, keine eigene DCS-Warehouse-Abstraktion und kein CampaignState-Write werden verwendet.

## 3. Testprinzip

Jeder Endpunkt wird über `AIRBASE` und `STORAGE` aufgelöst. Der Test protokolliert:

```text
Airbase-Name
Airbase-ID
JETFUEL
GASOLINE
MW50
DIESEL
MOOSE-STORAGE-Wrapper-Identität
DCS-Warehouse-Objektidentität
```

Wenn ein Paar nicht bereits dieselbe Wrapper- oder DCS-Warehouse-Identität aufweist, wird ein kontrollierter Black-Box-Aliasing-Test ausgeführt:

```text
1. Ausgangsbestand JETFUEL beider Endpunkte lesen
2. sofern der Quell-Storage nicht Unlimited Liquids verwendet:
   Quellbestand temporär um 37 kg erhöhen
3. Quell- und Gegenendpunkt erneut lesen
4. Änderung am Gegenendpunkt klassifizieren
5. Ausgangsbestand sofort wiederherstellen
6. Wiederherstellung auf beiden Endpunkten verifizieren
```

Klassifikationen:

```text
SHARED_IDENTITY
SHARED_BEHAVIOR
INDEPENDENT_BEHAVIOR
INCONCLUSIVE
```

`INCONCLUSIVE` ist insbesondere möglich, wenn beide Seiten Unlimited Liquids verwenden und deshalb kein kontrollierter Schreib-/Readback-Test möglich ist.

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

## 6. Acceptance-Kriterien

Der DCS-Lauf muss für alle sechs benannten Airbase-Endpunkte eine gültige `AIRBASE`-/`STORAGE`-/DCS-Warehouse-Auflösung liefern.

Für jedes Paar muss genau eine `PAIR_RESULT`-Zeile entstehen. Ein belastbarer Abschluss ist erreicht, wenn kein Paar `INCONCLUSIVE` bleibt und jede durchgeführte JETFUEL-Perturbation vollständig wiederhergestellt wurde.

Die tatsächlich beobachtete Topologie wird nicht vorweggenommen. Insbesondere wird für Kandahar und Shindand nicht angenommen, dass Main und Heliport getrennte native Warehouses besitzen.

Für Salerno wird geprüft, dass `FOB Salerno` und `Khost` als getrennte Airbase-Namen auflösbar sind; ob ihre Warehouses technisch getrennt sind, wird ebenfalls aus dem Runtime-Verhalten ermittelt.

Ein Status `ACCEPTED_TECHNICAL_BASELINE` ist erst nach dokumentiertem DCS-Lauf mit Branch-, Commit-, Mission-, Bundle-, DCS- und MOOSE-Provenienz zulässig.
