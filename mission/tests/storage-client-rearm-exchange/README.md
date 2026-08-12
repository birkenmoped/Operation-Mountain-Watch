---
document_id: OMW-TEST-STORAGE-CLIENT-REARM-EXCHANGE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-16 client rearm/loadout exchange observation
  - read-only STORAGE weapon return/debit correlation during player rearm
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-client-rearm-exchange
source_commit: PENDING_MERGE
validated_in_dcs: true
acceptance_branch: agent/storage-client-rearm-exchange
acceptance_commit: f4e5352eba4afb51c365768641c6a456a065b929
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 76735e0ba85634a2f84716b38debab7add411851896cb14b1ba5f23cb7b47181
dcs_version: 2.9.28.26385
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
acceptance_bundle_sha256: 291b8ade7cc59e363f73995dea4f73863aa96068bfe0ee85153a6b6c097dcf62
---

# STORAGE Client Rearm Exchange

## 1. Ziel

Dieser Gate beantwortet gezielt die offene Client-Rearm-Frage fuer den bereits im OMW-AirOps-Bestand vorhandenen Bagram-F-16-Client:

```text
Gibt DCS beim normalen Ground-Crew-Rearm entfernte Stores in das Bagram-Warehouse zurueck?
Werden neu montierte Stores aus dem Warehouse abgebucht?
Bleiben unveraenderte Stores netto inventarneutral?
Wie verhalten sich wiederverwendbare Stores wie Targeting Pods und externe Tanks?
Wird S_EVENT_WEAPON_REARM fuer den Client im getesteten Runtime-Stand geliefert?
```

Der Test ist ausschliesslich beobachtend. Er mutiert weder `STORAGE` noch `CampaignState` und veraendert keine Beladung selbst.

## 2. Testablauf

Der Projektinhaber verwendet einen normalen Bagram-F-16-Client und fuehrt mehrere Ground-Crew-Rearm-Vorgaenge in einem DCS-Lauf durch.

Empfohlene Sequenz:

```text
A. initiales Template-/Startloadout beibehalten, bis READY/CLIENT_BOUND geloggt wurde
B. auf ein deutlich anderes Loadout wechseln
C. erneut wechseln, dabei nach Moeglichkeit TGP oder Tanks beibehalten
D. auf ein reduziertes/nahezu cleanes Loadout wechseln
E. optional wieder auf ein vorheriges Loadout wechseln
```

Es ist nicht erforderlich, exakt diese Waffenfamilien zu waehlen. Sinnvoll sind Kombinationen aus bereits im Census beobachteten F-16-Stores, zum Beispiel GBU-12/GBU-38, AIM-120C, AN/AAQ-33 und 370-gal-Tanks.

Waehrend des Gates soll kein weiterer Bagram-AirOps-Test oder AI-Missionsdispatch Warehouse-Buchungen erzeugen, damit die Deltas eindeutig dem Client-Rearm zugeordnet werden koennen.

## 3. Beobachtung

Der Harness verwendet ausschliesslich oeffentliche, im gepinnten MOOSE-Stand vorhandene Pfade:

```text
AIRBASE:FindByName("Bagram")
AIRBASE:GetStorage()
STORAGE:FindByName("Bagram")
STORAGE:GetInventory()
SET_CLIENT:New()
SET_CLIENT:FilterCategories("plane")
SET_CLIENT:FilterTypes("F-16C_50")
SET_CLIENT:FilterStart()
SET_CLIENT:ForEachClient()
UNIT:GetAmmo() ueber den CLIENT-Wrapper
EVENTHANDLER:New()
BASE:HandleEvent(EVENTS.WeaponRearm, ...)
SCHEDULER:New()
MESSAGE:New(...):ToAll()
```

`UNIT:GetAmmo()` liefert die aktuell von DCS gemeldeten Waffen-/Munitionsdeskriptoren. Nicht-Waffen-Anbauteile wie Targeting Pods oder Drop Tanks muessen nicht zwingend in dieser Aircraft-Ammo-Tabelle erscheinen; fuer deren Rearm-Bilanz ist deshalb der vollstaendige `STORAGE:GetInventory().weapons`-Delta die primaere Evidenz.

Der Harness pollt alle 5 Sekunden und schreibt nur bei einer Aenderung detaillierte Deltas. `EVENTS.WeaponRearm` wird zusaetzlich beobachtet, ist aber bewusst **nicht** die einzige Triggerquelle.

## 4. Erwartete Logmarker

```text
READY
CLIENT_BOUND
SNAPSHOT
DELTA family=STORAGE_WEAPON ...
DELTA family=AIRCRAFT_AMMO ...
WEAPON_REARM_EVENT ...        # falls DCS das Event liefert
RESULT ... status=OBSERVATION_COMPLETE
```

Der Test klassifiziert den Warehouse-Rearm nicht automatisch als PASS/FAIL. Die eigentliche Auswertung erfolgt anhand der beobachteten Sequenz aus Player-Rearm-Schritten, STORAGE-Deltas und Aircraft-Ammo-Deltas.

## 5. Entscheidungsziel fuer CampaignState

Wenn DCS das Exchange-Verhalten sauber liefert, soll OMW keine parallele Rearm-Implementierung erfinden. Der spaetere CampaignState-Adapter kann dann den nativen Vorgang beobachten und gegen den autoritativen strategischen Ledger reconciliieren:

```text
removed physical remainder -> strategic recredit
newly issued stores        -> strategic debit
unchanged returned/reissued store -> net zero
```

Falls DCS fuer einen verifiziert gemappten Store abweichende Warehouse-Deltas erzeugt, bleibt `CampaignState` autoritativ und die Abweichung wird als Reconciliation-Mismatch behandelt. Ein produktiver Workaround wird erst nach dem Runtime-Nachweis und einer separaten Architekturentscheidung umgesetzt.

## 6. MOOSE-First-Nachweis

Gepinnter Runtime-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Direkt gegen die tatsaechlich verwendete `Moose.lua` geprueft:

- `UNIT:GetAmmo()` delegiert read-only an das DCS-Unit-`getAmmo()` und liefert `nil`, wenn kein DCS-Objekt existiert;
- `EVENTS.WeaponRearm` mappt auf `world.event.S_EVENT_WEAPON_REARM` oder `-1`, falls das Event im DCS-Stand nicht existiert;
- `BASE:HandleEvent(EventID, EventFunction)` registriert den generischen Event-Callback ueber den MOOSE-EventDispatcher;
- `EVENTHANDLER:New()` ist der oeffentliche generische Event-Handler;
- `SET_CLIENT` stellt `FilterTypes`, `FilterCategories`, `FilterStart` und `ForEachClient` bereit;
- `STORAGE:GetInventory()` ist der bereits im OMW-Census verwendete read-only Warehouse-Snapshot-Pfad.

Offizielle Demo-/Testmissionen wurden fuer diesen kleinen read-only Diagnosepfad nicht als zusaetzliche Voraussetzung bewertet, weil keine komplexe MOOSE-FSM- oder Missionserzeugung eingefuehrt wird und die verwendeten oeffentlichen Methoden direkt im gepinnten Source geprueft wurden.

## 7. Grenzen

Nicht Bestandteil dieses Gates:

```text
CampaignState-Mutation
STORAGE-Mutation
Rearm-Blockierung bei strategischem Fehlbestand
produktive Reconciliation
AI-Rearm
Weapon expenditure
Fuel-only refuel exchange
DCS- oder MOOSE-Workaround
```

Die Acceptance gilt nur fuer den dokumentierten Bagram-F-16-Client-, DCS-, MOOSE-, MIZ- und Bundle-Stand. Sie ist keine pauschale Garantie fuer andere Flugzeugtypen, Airbases oder DCS-Versionen.

## 8. Build

Source:

```text
mission/tests/storage-client-rearm-exchange/src/01-storage-client-rearm-exchange.lua
```

Builder:

```text
tools/build-storage-client-rearm-exchange.ps1
```

Bundle:

```text
mission/tests/storage-client-rearm-exchange/dist/OMW_Storage_Client_Rearm_Exchange_Test.lua
```

Verifizierter Build fuer den Acceptance-Lauf:

```text
Git commit: f4e5352eba4afb51c365768641c6a456a065b929
Bundle SHA-256: 291b8ade7cc59e363f73995dea4f73863aa96068bfe0ee85153a6b6c097dcf62
```

Das in der getesteten MIZ eingebettete Bundle hatte denselben SHA-256. Das eingebettete `Moose.lua` hatte den gepinnten SHA-256 `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`.

## 9. DCS-Acceptance 2026-08-12

Runtime:

```text
DCS 2.9.28.26385 MT
branch agent/storage-client-rearm-exchange
commit f4e5352eba4afb51c365768641c6a456a065b929
client CLIENT_US_BGRM_F16_01_UNIT_01
node Bagram
mission OMW_Template_v8_AirOps_rdy.miz
mission SHA-256 76735e0ba85634a2f84716b38debab7add411851896cb14b1ba5f23cb7b47181
bundle SHA-256 291b8ade7cc59e363f73995dea4f73863aa96068bfe0ee85153a6b6c097dcf62
Moose.lua SHA-256 e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Evidenzdateien des Laufs:

```text
dcs(20260812-193934).log
SHA-256 5a10483e5be5ffab37e28121b283de7967af20870da1ad4f657b583f63816f7a

debrief(20260812-193934).log
SHA-256 7bd42031d08a9084c54bb1967dfa22cc490f793992e5412b0d4f79bbc06b0d59
```

Der Lauf bestaetigte wiederholt:

```text
new store mounted      -> STORAGE debit
store removed          -> STORAGE recredit
aircraft ammo          -> spiegelbildliche Delta-Korrelation fuer Waffen
370-gal external tanks -> debit und vollstaendige Rueckgabe beobachtet
AN/AAQ-33              -> debit und Rueckgabe beobachtet
AAQ-28 LITENING        -> debit und Rueckgabe beobachtet
ALQ-184                 -> debit und Rueckgabe beobachtet
LAU-88                  -> debit und Rueckgabe beobachtet
EVENTS.WeaponRearm      -> vom Client geliefert
```

Konkrete korrelierte Beispiele:

```text
GBU-12   STORAGE 100 -> 98, AIRCRAFT_AMMO 0 -> 2
GBU-38   STORAGE 100 -> 98, AIRCRAFT_AMMO 0 -> 2
AIM-120C STORAGE 100 -> 98, AIRCRAFT_AMMO 0 -> 2

spaeter:
GBU-12   STORAGE 98 -> 100
GBU-38   STORAGE 98 -> 100
AIM-120C STORAGE 98 -> 100

Mk-82    STORAGE 94 -> 100, AIRCRAFT_AMMO 6 -> 0
370-gal tanks STORAGE 98 -> 100
AN/AAQ-33 STORAGE 99 -> 100
```

Sieben `WEAPON_REARM_EVENT`-Meldungen wurden im Lauf erfasst. Die Mission wurde vor Ablauf des 3600-s-Safety-Timeouts beendet; deshalb wurde kein abschliessender Harness-`RESULT`-Marker geschrieben. Die fuer das Entscheidungsziel erforderlichen Rearm-Debit-/Return-Sequenzen waren zu diesem Zeitpunkt jedoch bereits mehrfach vollstaendig beobachtet.

## 10. Acceptance-Entscheidung

Fuer den exakt dokumentierten Bagram-F-16-Client-Scope gilt:

```text
DCS native client rearm exchange: VALIDATED_FOR_DOCUMENTED_SCOPE
removed stores -> warehouse return: PASS
new stores -> warehouse debit: PASS
reusable external stores -> observable debit/return: PASS
EVENTS.WeaponRearm delivery -> PASS
```

Damit gilt fuer OMW:

```text
do not reimplement client rearm
```

Eine eigene Rearm-Mechanik oder parallele STORE-Buchungslogik ist fuer diesen belegten Scope nicht erforderlich. Der spaetere produktive `CampaignState`-Adapter soll den nativen DCS/STORAGE-Vorgang beobachten, gegen den strategischen Ledger reconciliieren und die strategische Transaktion idempotent committen.

## 11. Naechster Gate

Der naechste offene Runtime-Gate im Ressourcenblock ist **Client Refuel**. Dabei ist zuerst zu pruefen, ob der native DCS/STORAGE-Fuel-Exchange analog ausreichend beobachtbar und korrekt ist. Eine separate Fuel-Rearm-/Refuel-Logik darf nicht vor dem Runtime-Nachweis gebaut werden.
