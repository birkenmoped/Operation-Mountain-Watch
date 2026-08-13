---
document_id: OMW-MOOSE-STORAGE-WAREHOUSE-RESOURCE-FOUNDATION
status: BINDING
document_class: MOOSE_TECHNICAL_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE STORAGE role in the AirOps Warehouse resource foundation
  - source-reviewed and DCS-confirmed STORAGE method usage
  - AIRWING/WAREHOUSE versus CampaignState ownership boundary
  - client fuel/rearm and AI store lifecycle observations
  - direct-mirror limitations for gun ammunition
  - selective initial CampaignState to STORAGE item mirroring
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Warehouse MOOSE topic summaries for the same closed foundation scope
superseded_by:
source_branch: agent/air-ops-initial-stock-runtime-data
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE STORAGE / Warehouse Resource Foundation

## 1. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Dokumentation allein wurde nicht als API-Nachweis verwendet. Signaturen und Laufzeitpfade wurden gegen die tatsächlich geladene `Moose.lua` und die dokumentierten DCS-Läufe abgeglichen.

## 2. Verwendete öffentliche MOOSE-Pfade

Für den Warehouse-/Resource-Scope wurden insbesondere praktisch oder quellseitig bestätigt:

```text
AIRBASE:GetStorage()
STORAGE:FindByName()
STORAGE:GetInventory()
STORAGE:GetItemAmount()
STORAGE:GetLiquidAmount()
STORAGE:IsLimitedWeapons()
STORAGE:SetItem()
STORAGE:AddItem()
STORAGE:RemoveItem()
STORAGE:SetLiquid()
AIRWING:NewPayload()
AIRWING:AddMission()
FLIGHTGROUP:GetAmmoTot()
FLIGHTGROUP:SetOptionLandingRestrictPair()
AIRBASE:GetParkingSpotsTable()
AIRBASE:GetParkingData()
AUFTRAG:NewORBIT()
AUFTRAG:NewSTRAFING()
COORDINATE:GetClosestPointToRoad()
COORDINATE:IsInFlatArea()
```

Die Verwendung bedeutet nicht, dass jede Methode für jede Resource-Klasse oder jede Mission allgemein validiert ist. Es gilt immer der dokumentierte Scope.

## 3. Rollenabgrenzung

```text
CampaignState
  = strategische Resource-ID, Menge, Reservation, Transfer, Verbrauch, Verlust, Gutschrift

MOOSE STORAGE / DCS Warehouse
  = operative Liquid-/Item-Repräsentation und native Ground-Crew-/Materialization-Transaktion

MOOSE WAREHOUSE / AIRWING / SQUADRON
  = Aircraft-/Asset-/Payload-/Missions-Lifecycle
```

MOOSE WAREHOUSE/AIRWING ist keine zweite strategische Munitionshoheit. STORAGE darf CampaignState nicht rückwärts überschreiben.

## 4. Fuel

Bestätigte Abbildung:

```text
FUEL_JP8   -> STORAGE.Liquid.JETFUEL
FUEL_AVGAS -> STORAGE.Liquid.GASOLINE
```

Die CampaignState->STORAGE-Foundation ist einseitig: CampaignState liefert den autoritativen Sollwert; der Adapter plant/anwendet und prüft die operative Darstellung. Ein hochfrequenter Scheduler, der laufend DCS-Verbrauch überschreibt, ist nicht zulässig.

Der Bagram-F-16-Client-Test bestätigte native 1:1 Fuel-Massentransfers zwischen Aircraft und STORAGE beim Bodencrew-Refuel/Defuel. Konsequenz: Client-Refuel wird nicht parallel neu implementiert.

## 5. Client Rearm

Der Bagram-F-16-Client-Test bestätigte, dass Ground-Crew-Rearm neu montierte Stores aus STORAGE debitiert und entfernte Stores zurückgibt. `EVENTS.WeaponRearm` wurde beobachtet, der Architekturvertrag hängt aber nicht ausschließlich von diesem Event ab.

Konsequenz:

```text
do not reimplement client rearm
```

CampaignState muss später die strategische Wirkung der nativen DCS/STORAGE-Transaktion reconciliieren, nicht die Bodencrew-Mechanik ersetzen.

## 6. AI Store Materialization und Return

Für die dokumentierten AIRWING/SQUADRON-Payloads wurden externe Store-Debits beim Materialisieren und bei normalem unbenutztem Return native Recredits beobachtet. Die Projektlogik implementiert keinen parallelen Spawn-/Return-Controller.

Belegte Beispiele:

```text
AH-64D two-ship:
HYDRA_70_M151 -76
AGM_114K -4
IAFS_ComboPak_100 -2

F-16C CAS two-ship:
GBU_12 -4
GBU_38 -4
AN_AAQ_33 -2
fuel_tank_370gal -4
AIM_120C -4

F-15E CAS two-ship:
GBU_38 -6
GBU_54_V_1B -6
AAQ-13 -2
AAQ-14 -2
F-15E_Drop_Tank -4
AIM_120C -2
AIM_9 -2
```

F-16/F-15E external tanks und AH-64 IAFS sind für CampaignState `TECHNICAL_NON_STRATEGIC`; fehlender AI-Normalreturn-Recredit wird nicht künstlich gefälscht.

## 7. Exakte Fighter-Store-Korrelation

Letzter geschlossener Mapping-Gate:

```text
AMMUNITION_GBU31_V1 -> weapons.bombs.GBU_31
AMMUNITION_GBU31_V3 -> weapons.bombs.GBU_31_V_3B
AMMUNITION_AIM9     -> weapons.missiles.AIM_9
```

Provenienz:

```text
DCS: 2.9.28.26385 MT
Source/Builder: d95a15275f148cba02a9a2728dfbf825c274e366
BuilderVersion: FIGHTER-STORE-RUNTIME-CORRELATION-1
Bundle SHA-256: c8a19305c6c15b222233283612c0f2780b156c1e49f2c8fc1d2287a26d4e776b
Executed MIZ SHA-256: 4ede299ae1bee8d030c9d1109ce7b827b4441da374976f2e261f7676e265e7de
Result: PASS
```

## 8. Gun-Ammunition-Grenzen

M230 und GAU-8 besitzen im dokumentierten STORAGE-Pfad keinen belastbaren direkten Round-Mirror. `FLIGHTGROUP:GetAmmoTot()`/Aircraft-Ammo und DCS-Debrief dienen als Telemetrie; es wird kein erfundener `STORAGE`-Round-Key verwendet.

OH-58 M3P zeigt einen Containerpfad, aber keine genehmigte Container-zu-Round-Konversion. CH-47 M60D ist ebenfalls Container-/Telemetry-Sonderfall. Diese Grenzen sind absichtlich Teil der finalen Architektur und kein offener Testauftrag.

## 9. Physical loss / Recovery

Forced-Landing- und Recovery-Module nutzen MOOSE-Wrapper/Event-/Coordinate-Pfade zur Beobachtung und halten CampaignState als strategische Buchungsinstanz. Settlement wird über stabile IDs idempotent ausgeführt; ein Restore darf keine doppelte Gutschrift erzeugen.

Die Foundation aktiviert keinen parallelen MOOSE-WAREHOUSE-Return-Mechanismus und keine nicht genehmigte Native-DCS-Produktionslogik.

## 10. Selektive Initialisierung der Item-Mirrors

Nach Abschluss der strategischen Stock-Planung wird `scripts/logistics/OMW_AirOpsStorageInitializer.lua` als einmaliger Initialisierungsadapter verwendet. Er liest die autoritative aktuelle Menge aus dem vom AirOps-Initializer erzeugten `CampaignState` und schreibt nur dann in MOOSE `STORAGE`, wenn für die Resource-ID genau **ein** validierter direkter Item-Key ableitbar ist.

Der geprüfte MOOSE-Quellstand bestätigt dafür die öffentlichen Methoden:

```text
STORAGE:FindByName(airbaseName)
AIRBASE:GetStorage()
STORAGE:IsLimitedWeapons()
STORAGE:GetItemAmount(itemName)
STORAGE:SetItem(itemName, amount)
```

Der Adapter ist fail-closed:

- mehrere validierte Item-Keys für dieselbe strategische Resource-ID werden nicht automatisch verteilt;
- fehlende direkte Item-Mappings werden nicht erfunden;
- `TELEMETRY_ONLY`, `STORE_WITHOUT_ROUND_CONVERSION` und nicht gemappte Countermeasure-Ressourcen werden nicht geschrieben;
- `TECHNICAL_NON_STRATEGIC`-Items besitzen keinen strategischen Initialbestand und werden nicht aus CampaignState materialisiert;
- ein operatives Warehouse mit nicht limitierten Weapons blockiert die schreibende Initialisierung statt einen Erfolg vorzutäuschen;
- nach `SetItem()` erfolgt ein direkter `GetItemAmount()`-Readback;
- es gibt keinen Scheduler und keine fortlaufende Sollwertüberschreibung des nativen DCS-Verbrauchs.

`AMMUNITION_ROCKETS_70MM` bleibt absichtlich **nicht** automatisch schreibbar, solange dieselbe strategische Resource-ID auf die validierten DCS-Items `HYDRA_70_M151` und `HYDRA_70_M156` verteilt werden müsste. Dafür existiert im geschlossenen Stock-Vertrag keine genehmigte Startverteilungsregel je DCS-Untertyp.

Fuel bleibt außerhalb dieses Item-Adapters und wird weiterhin über `OMW_StorageFuelAdapter.lua` / `OMW_CampaignStateStorageSync.lua` behandelt.

Statusgrenze dieses neuen Adapters: Quellcode/API gegen den gepinnten MOOSE-Stand geprüft; DCS-Write-/Readback-Acceptance für die produktive Missionsintegration noch ausstehend. Deshalb wird dieser neue Schreibpfad durch die bestehende ältere STORAGE-Acceptance nicht automatisch als `VALIDATED` eingestuft.
