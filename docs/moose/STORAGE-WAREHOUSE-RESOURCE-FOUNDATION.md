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
source_commit: 9e1184781b8bf37687e92eb16464a8902042924e
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
USERFLAG:New()
USERFLAG:Set()
USERFLAG:Get()
SCHEDULER:New()
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

Der zentrale AirOps-Warehouse-Bootstrap-Acceptance-Lauf vom 13.08.2026 bestätigte zusätzlich den produktionsnahen Fuel-Mirror für Kandahar im NEW-/RESTORE-Pfad. DCS repräsentierte den angeforderten AVGAS-Wert `20270.13583056 kg` als `20270.13671875 kg`. Der produktive Adapter verwendet deshalb für Plan, Write-Entscheidung, Readback und Idempotenz eine einheitliche Toleranz von `0.5 kg`. Diese Toleranz verändert den CampaignState-Sollwert nicht; Abweichungen über `0.5 kg` bleiben fail-closed.

Acceptance-Provenienz:

```text
Branch: agent/air-ops-initial-stock-runtime-data
Acceptance commit: 2502516fe130b908e500117142399b3e2ca74007
BuilderVersion/TestId: AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE-1
Bundle SHA-256: 025855c07896ee396b545ae2b131c2f4181e6eed88c412580288d644f4d311ac
MIZ SHA-256: dd25f68a7361c36fa121a581022a9535f55372ad1f32a7992d4013e9c6f0c0d8
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Vollständiger Acceptance-Bericht:

- [`OMW-TEST-AIROPS-WAREHOUSE-BOOTSTRAP-ACCEPTANCE`](../../mission/tests/air-ops-warehouse-bootstrap/expected/air-ops-warehouse-bootstrap-acceptance-2026-08-13.md)

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

Wichtig: Das bedeutet **nicht**, dass diese strategischen Ressourcen keinen Bestand besitzen. Ihre Mengen liegen in `CampaignState`/`OMW_AirOpsInitialStock.lua`; lediglich ein direkter DCS-STORAGE-Round-Mirror ist nicht belastbar vorhanden. Die spätere Missionsreservation und Ergebnisbuchung verwendet deshalb CampaignState und die bestätigte Ammo-/Debrief-Telemetrie, statt einen nicht existierenden STORAGE-Key zu erfinden.

## 9. Physical loss / Recovery

Forced-Landing- und Recovery-Module nutzen MOOSE-Wrapper/Event-/Coordinate-Pfade zur Beobachtung und halten CampaignState als strategische Buchungsinstanz. Settlement wird über stabile IDs idempotent ausgeführt; ein Restore darf keine doppelte Gutschrift erzeugen.

Die Foundation aktiviert keinen parallelen MOOSE-WAREHOUSE-Return-Mechanismus und keine nicht genehmigte Native-DCS-Produktionslogik.

## 10. Selektive Initialisierung der Item-Mirrors

Nach Abschluss der strategischen Stock-Planung wird `scripts/logistics/OMW_AirOpsStorageInitializer.lua` als einmaliger Initialisierungsadapter verwendet. Er liest die autoritative aktuelle Menge aus dem vom AirOps-Initializer erzeugten `CampaignState` und schreibt nur validierte operative MOOSE-STORAGE-Items.

Der geprüfte MOOSE-Quellstand bestätigt dafür die öffentlichen Methoden:

```text
STORAGE:FindByName(airbaseName)
AIRBASE:GetStorage()
STORAGE:IsLimitedWeapons()
STORAGE:GetItemAmount(itemName)
STORAGE:SetItem(itemName, amount)
```

Der Adapter ist fail-closed:

- fehlende direkte Item-Mappings werden nicht erfunden;
- `TELEMETRY_ONLY`, `STORE_WITHOUT_ROUND_CONVERSION` und nicht gemappte Countermeasure-Ressourcen werden nicht geschrieben;
- `TECHNICAL_NON_STRATEGIC`-Items besitzen keinen strategischen Initialbestand und werden nicht aus CampaignState materialisiert;
- ein operatives Warehouse mit nicht limitierten Weapons blockiert die schreibende Initialisierung statt einen Erfolg vorzutäuschen;
- nach `SetItem()` erfolgt ein direkter `GetItemAmount()`-Readback;
- es gibt keinen Scheduler und keine fortlaufende Sollwertüberschreibung des nativen DCS-Verbrauchs.

### 10.1 70-mm-Raketen

Die strategische Resource-ID `AMMUNITION_ROCKETS_70MM` besitzt sehr wohl verbindliche Bestände. Die zwei validierten physischen DCS-Items gehören in der aktuellen OMW-Payload-Baseline jedoch zu unterschiedlichen AirOps-Knoten. Dadurch ist keine willkürliche globale Aufteilung erforderlich.

Der Initializer verwendet deshalb eine node-spezifische, aus den genehmigten Payloads abgeleitete Abbildung:

```text
JALALABAD      -> weapons.nurs.HYDRA_70_M151
KANDAHAR_HELI  -> weapons.nurs.HYDRA_70_M151
SALERNO        -> weapons.nurs.HYDRA_70_M151
SHINDAND_HELI  -> weapons.nurs.HYDRA_70_M151
TARINKOT       -> weapons.nurs.HYDRA_70_M151

KANDAHAR_MAIN  -> weapons.nurs.HYDRA_70_M156
```

Damit wird pro Node genau **ein** physischer 70-mm-Item-Mirror aus dem dortigen strategischen `AMMUNITION_ROCKETS_70MM`-Bestand initialisiert. Es wird kein Bestand verdoppelt und kein strategischer Pool auf zwei DCS-Items am selben Node kopiert.

### 10.2 Countermeasures und technische Items

`FLARES_CHAFF` besitzt einen strategischen Planbestand, derzeit aber keinen belastbaren direkten DCS-STORAGE-Item-Vertrag. Der Bestand fehlt also nicht; nur die operative DCS-Mirror-Abbildung ist noch nicht vorhanden.

F-16/F-15E-Außentanks und AH-64-IAFS sind dagegen ausdrücklich `TECHNICAL_NON_STRATEGIC`. Für sie existiert absichtlich **kein** CampaignState-Strategiebestand. Ihre notwendige operative DCS-Verfügbarkeit ist eine technische Warehouse-Konfiguration und darf nicht als strategische Ressource gebucht oder künstlich zurückgeschrieben werden.

Fuel bleibt außerhalb dieses Item-Adapters und wird weiterhin über `OMW_StorageFuelAdapter.lua` / `OMW_CampaignStateStorageSync.lua` behandelt.

Der zentrale AirOps-Warehouse-Bootstrap-Acceptance-Lauf vom 13.08.2026 hat den selektiven Item-Write-/Readback-Pfad gemeinsam mit Fuel und Technical Availability im zentralen NEW-/RESTORE-Gate DCS-validiert. Der dokumentierte Lauf meldete `strategicChanges=27`, anschließend verifizierten Apply/Readback und beim RESTORE `strategicChanges=0`.

### 10.3 Technische Availability-Initialisierung

`scripts/logistics/OMW_AirOpsTechnicalAvailabilityInitializer.lua` trennt die operativen `TECHNICAL_NON_STRATEGIC`-Items jetzt auch im Runtime-Pfad ausdrücklich von CampaignState.

Der Adapter verwendet ausschließlich die bereits für STORAGE geprüften öffentlichen MOOSE-Pfade:

```text
STORAGE:FindByName(airbaseName)
AIRBASE:GetStorage()
STORAGE:IsLimitedWeapons()
STORAGE:GetItemAmount(itemName)
STORAGE:SetItem(itemName, amount)
```

Zulässig sind ausschließlich Manifest-Einträge der Klasse `TECHNICAL_NON_STRATEGIC` mit direktem `ITEM`-Mapping und ohne `resourceId`. Der aktuelle Manifest-Scope umfasst:

```text
AH64_IAFS_COMBOPAK_100 -> weapons.droptanks.{IAFS_ComboPak_100}
F16_370GAL_TANK        -> weapons.droptanks.fuel_tank_370gal
F15E_EXTERNAL_TANK     -> weapons.droptanks.F-15E_Drop_Tank
```

Die produktive technische Availability-Baseline ist jetzt owner-seitig festgelegt und liegt in `scripts/logistics/OMW_AirOpsTechnicalAvailability.lua`. Pro relevantem Node und Store werden 1000 Stück einmalig als operative Anfangsverfügbarkeit gesetzt. Die genaue Node-Zuordnung und die strategische Abgrenzung sind zusätzlich in `docs/moose/STORAGE-TECHNICAL-AVAILABILITY.md` dokumentiert.

Der Adapter leitet weiterhin **keine** Menge aus CampaignState oder strategischen Stocks ab. Die 1000 Stück sind eine separate technische Missionskonfiguration und eröffnen die abgeschlossene strategische Stockplanung nicht erneut.

Der Adapter ist one-shot und fail-closed:

- unbekannte oder nicht technische Keys werden abgewiesen;
- negative, nicht-ganzzahlige oder nicht-endliche Mengen werden abgewiesen;
- nicht limitierte Weapon-Warehouses blockieren die Anwendung;
- jeder Schreibvorgang wird unmittelbar mit `GetItemAmount()` gelesen und geprüft;
- es gibt keine CampaignState-Buchung, keine Consumption und keine Return-Gutschrift;
- es gibt keinen Scheduler und keine automatische Wiederauffüllung nach Missionsbeginn.

Der zentrale Acceptance-Lauf vom 13.08.2026 hat diesen technischen Write-/Readback-Pfad im gemeinsamen Bootstrap-Gate DCS-validiert. Der Lauf meldete `technicalChanges=7`, verifizierte die Anwendung und bestätigte beim RESTORE `technicalChanges=0`.

## 11. READY-Gate mit `USERFLAG`

Für die zentrale AirOps-Warehouse-Acceptance wird der öffentliche MOOSE-Wrapper `USERFLAG` verwendet:

```lua
local readyFlag = USERFLAG:New("OMW_WAREHOUSE_READY")
readyFlag:Set(0)
-- NEW + readback + RESTORE
readyFlag:Set(1)
```

Der DCS-Lauf vom 13.08.2026 bestätigte `USERFLAG:New()`, `Set()` und `Get()` im dokumentierten MOOSE-Stand sowie den gespeicherten DCS-Flagzustand `OMW_WAREHOUSE_READY = 1`. Alle sechs AirOps-Trigger waren zusätzlich zur Zeitbedingung auf dieses Flag gegatet. Damit bleibt der Startpfad bei einem Bootstrap-Fehler fail-closed.
