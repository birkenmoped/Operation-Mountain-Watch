---
document_id: OMW-MOOSE-FIXED-FIRE-SUPPORT-REARM
status: DRAFT
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first composition for local fixed-fire-support ammunition materialization and rearm
  - support return-to-stock lifecycle for Bostick, Wright, Fortress and Honaker
  - LOCAL REARM CampaignState completion and restart-settlement boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE Fixed Fire Support Rearm

## 1. Zweck und Geltungsgrenze

Dieses Dokument beschreibt den MOOSE-first-Pfad für lokalen Munitionsnachschub der festen BLUE-Feuerunterstützungsstellungen Bostick, Wright, Fortress und Honaker.

```text
BOSTICK   -> L118
WRIGHT    -> L118
FORTRESS  -> L118
HONAKER   -> 2B11
```

Produktionsnaher Supportvertrag:

```text
TPL_BLUE_GND_SUP_M1083
```

Der diagnostische Honaker-M939-Zweig ist keine Produktionsarchitektur.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165FFE64CD26BE154B49E63E001A915
```

Für diesen Scope source- beziehungsweise runtime-belegt relevant:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
BRIGADE / PLATOON materialization
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY OnBeforeRearm
ARTY OnAfterRearmed
SCHEDULER:New(...)
```

Kein eigener OMW-Rearm-FSM und kein FullAmmo-Scanner werden eingeführt.

## 3. Lokale Warehouse-Materialisierung

Für Fixed Fire Support wird pro Standort eine dedizierte Mission-Editor-RESUPPLY-Zone auf freiem Boden innerhalb der FOB/COP-Anlage verwendet.

Verwendeter MOOSE-Pfad:

```lua
WAREHOUSE:SetSpawnZone(Zone, MaxDist)
```

Bewusst ausgeschlossen:

```lua
WAREHOUSE:SetValidateAndRepositionGroundUnits(true)
```

### 3.1 Verifizierter Defekt im gepinnten MOOSE-Stand

Der gepinnte Source enthält in `UTILS.ValidateAndRepositionGroundUnits(...)` den Aufruf:

```lua
Anchor = Anchor or UTILS.GetCenterPoint(units)
```

Für den gepinnten OMW-Stand wurde keine passende Definition von `UTILS.GetCenterPoint(...)` gefunden. Ein realer DCS-Lauf reproduzierte:

```text
attempt to call field 'GetCenterPoint' (a nil value)
ValidateAndRepositionGroundUnits
-> _SpawnAssetGroundNaval
-> _SpawnAssetRequest
-> onafterRequest
```

Folgerung für OMW:

```text
KEEP: WAREHOUSE:SetSpawnZone(...)
DO NOT USE: WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
NO MOOSE patch/override
NO native DCS spawn/reposition fallback
```

Der benötigte Materialisierungsvertrag wird durch owner-kontrollierte freie RESUPPLY-Zonen erfüllt.

## 4. Mission-Editor-Vertrag

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Anforderung:

```text
innerhalb der jeweiligen FOB/COP-Anlage
nahe lokalem Warehouse
freier Boden für M1083
kein Road-/Convoy-Zonenvertrag
Abstand zu HESCOs, Gebäuden, Statics und Ground Units
```

Der private `OMW_GroundRoadSpawnAdapter` gehört nicht zu diesem lokalen Fixed-Fire-Support-Pfad.

## 5. ARTY Rearm und strategisches Commitment

Der OMW-Adapter setzt die öffentliche MOOSE-Konfiguration:

```lua
ARTY:SetRearmingGroup(Group)
ARTY:SetRearmingGroupOnRoad(false)
ARTY:SetRearmingDistance(100)
ARTY:Rearm()
```

Der CampaignState-Verbrauch erfolgt im vorhandenen MOOSE-`OnBeforeRearm`-Hook, nachdem ARTY seinen internen Rearm-Gate passiert hat und eine gültige RearmingGroup beziehungsweise RearmingPlace vorhanden ist.

```text
ARTY accepts physical rearm
-> CampaignState transaction = CONSUMED
-> GROUND_AMMO_PACKAGE -1
```

Damit ist die Ressource nicht mehr strategisch verfügbar, sobald der physische Service tatsächlich beginnt.

## 6. Dauerhafte Completion

Der gepinnte ARTY-FSM besitzt den `Rearmed`-Pfad und den User-Hook `OnAfterRearmed`.

OMW verwendet genau diesen vorhandenen Callback als Completion-Grenze:

```text
ARTY OnAfterRearmed
-> CampaignState:CompleteConsumption(transactionId)
-> transaction = COMPLETED
```

`COMPLETED` bedeutet:

```text
physischer DCS/MOOSE-Rearm wurde bestätigt
strategischer Verbrauch bleibt bestehen
Restart darf diese Transaktion nicht kompensieren
```

Es wird kein paralleler Munitionsscanner aufgebaut.

## 7. Support-Rückkehr und Return-to-stock

`ARTY:onafterRearm(...)` merkt die Ausgangskoordinate der RearmingGroup. Nach `Rearmed` übernimmt ARTY die physische Rückkehr.

OMW erzeugt keinen eigenen Return-Wegpunkt. Ein MOOSE-`SCHEDULER` bestätigt begrenzt die Rückkehrgrenze:

```text
Intervall: 5 s
Timeout: 300 s
Radius: 100 m sofern nicht explizit anders konfiguriert
```

Nach bestätigter Rückkehr:

```lua
WAREHOUSE:AddAsset(Group)
```

Damit bleibt der operative Asset-/Stock-Lifecycle MOOSE-owned. Das Zurücklegen des M1083 in den Warehouse-Assetbestand erstattet **kein** `GROUND_AMMO_PACKAGE`.

## 8. Owner-approved LOCAL REARM Restart-Reconciliation

Owner-Entscheidung 22.08.2026: **Option B**.

Vertrag:

```text
CONSUMED + COMPLETED
-> Verbrauch bleibt bestehen

CONSUMED + not COMPLETED on restored startup
-> exactly-once strategic compensation
-> transaction = COMPENSATED
-> keine physische Mission wird wiederhergestellt
-> neuer Rearm benötigt neue transactionId

RESERVED/LOADING local rearm on restored startup
-> reservation wird storniert
-> kein strategischer Verbrauch
-> keine physische Mission wird wiederhergestellt
```

Korrelation:

```text
reservationId = GROUND-LOCAL-REARM:<transactionId>
restart creditId = GROUND-LOCAL-REARM-RESTART:<transactionId>
```

Der vorhandene `CampaignState:CreditResourceOnce(...)`-Vertrag macht die Restart-Gutschrift idempotent. Der Local-Rearm-Adapter setzt danach den Consumption-Status auf `COMPENSATED`.

Der allgemeine Ground-Return/Loss/Restart-Pfad bleibt davon getrennt und unverändert.

## 9. Strategische Autoritätsgrenze

```text
CampaignState
= einzige strategische Ressourcenautorität

MOOSE WAREHOUSE / BRIGADE / PLATOON
= operative Assetmaterialisierung und Assetbestand

ARTY / DCS ammo state
= physischer Rearm-Lifecycle und Telemetrie
```

Nicht zulässig:

```text
zweiter Ground-CampaignState
Warehouse als zweite GROUND_AMMO_PACKAGE-Autorität
Replay des alten physischen Rearm-Vorgangs nach Restart
Wiederverwendung einer abgeschlossenen/kompensierten transactionId
```

## 10. Runtime-Evidenz

### 10.1 Bostick Baseline

```text
Source: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
Runtime: 300 -> 296 -> 302
GROUND_AMMO_PACKAGE: 52 -> 51
Result: PASS
```

### 10.2 Honaker 2B11 Diagnose

```text
Source: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
Executed mission: OMW_Template_v16.miz
DCS: 2.9.28.26385 MT
```

Beobachtet:

```text
2B11 40 -> 0 -> 40
SITE_REARMED
SITE_SUPPORT_RETURNED
SITE_PASS
aggregate PASS
```

Schlussfolgerung: Kein 2B11-Defekt und keine M1083-Inkompatibilität wurden nachgewiesen. Die M939-/Vollentleerungsvariante war Diagnostik.

### 10.3 Diagnostischer Rückbau

Realer lokaler Build:

```text
Source: 02093710b7feabf3440cb04674f7799207b9da5e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
Bundle SHA-256: 54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B
HonakerSupportTemplate: TPL_BLUE_GND_SUP_M1083
FireShellsPerSite: 4
HonakerM939Diagnostic: false
```

Dies ist Build-/Contract-Evidenz, kein neuer DCS-PASS.

## 11. Aktueller Implementierungsstand

Der Branch enthält jetzt:

```text
CampaignState statuses: CONSUMED / COMPLETED / COMPENSATED
CampaignState:CompleteConsumption(...)
CampaignState:MarkConsumptionCompensated(...)
GroundAmmoRearmAdapter.ReconcileRestore(...)
GroundRuntimeIntegration restored attach -> Local Rearm reconciliation
GroundBase packaging of the Local Rearm reconciliation module
Acceptance-2 successful-path gate on transaction == COMPLETED
```

Aktueller Acceptance-Builder:

```text
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
```

Noch nicht als Runtime-Nachweis vorhanden:

```text
Revision 2-9 local bundle hashes
Revision 2-9 DCS successful COMPLETED branch
realer Server-Crash-/Filesystem-Test
```

Der letzte Punkt ist nicht Voraussetzung für den reinen Reconciliation-Vertrag, solange kein neuer Persistenz-Transport eingeführt wird; ein tatsächlicher Persistenz-Host bleibt ein separater Scope.
