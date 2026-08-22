---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - Mission Editor target- and local resupply-zone contract for that combined run
  - exact runtime evidence and limits of the Honaker 2B11 diagnosis
  - successful LOCAL REARM completion branch after the owner-approved restart decision
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: b2b741fd2b0bd0c86d5cfd4268b042db2883e2a8
validated_in_dcs: partial
---

# Ground Fire Support Acceptance 2 – kombinierter Vier-Consumer-Lauf

## 1. Ziel und aktueller Vertrag

Der kombinierte Lauf bewertet vier getrennte Rearm-Legs mit demselben produktionsnahen Fixed-Fire-Support-Vertrag:

```text
BOSTICK   L118  -> TPL_BLUE_GND_SUP_M1083 -> 4 Schuss
WRIGHT    L118  -> TPL_BLUE_GND_SUP_M1083 -> 4 Schuss
FORTRESS  L118  -> TPL_BLUE_GND_SUP_M1083 -> 4 Schuss
HONAKER   2B11  -> TPL_BLUE_GND_SUP_M1083 -> 4 Schuss
```

Der frühere Honaker-Sonderfall mit `TPL_BLUE_GND_SUP_M939`, `fireShells = 40` und erzwungener Vollentleerung war ausschließlich Diagnostik. Er ist aus Harness und Builder entfernt; die reale Diagnoseevidenz bleibt unten dokumentiert.

Aktueller Lifecycle:

```text
fire
-> DCS ammunition decreases
-> local M1083 materializes through MOOSE WAREHOUSE / BRIGADE / PLATOON
-> MOOSE ARTY accepts Rearm
-> CampaignState GROUND_AMMO_PACKAGE = CONSUMED
-> DCS/MOOSE performs physical rearm
-> ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED
-> ARTY-owned physical support return
-> bounded MOOSE SCHEDULER return confirmation
-> WAREHOUSE:AddAsset(group)
-> physical support removed / Warehouse stock restored
```

`CampaignState` bleibt einzige strategische Ressourcenautorität.

## 2. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete öffentliche MOOSE-Verträge:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
BRIGADE:New(...)
PLATOON:New(...)
ARTY:New(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY OnBeforeRearm
ARTY OnAfterRearmed
SCHEDULER:New(...)
```

Nicht verwendet:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
MOOSE patch/override
native DCS spawn/reposition fallback
private RoadSpawnAdapter for this local support path
```

Der Ausschluss von `SetValidateAndRepositionGroundUnits(...)` ist durch den real reproduzierten gepinnten-MOOSE-Fehler `UTILS.GetCenterPoint` begründet. `WAREHOUSE:SetSpawnZone(...)` mit owner-kontrollierten freien RESUPPLY-Zonen ist der bestätigte MOOSE-first-Pfad.

## 3. Reale Acceptance-Evidenz vor dem Diagnose-Rückbau

### 3.1 Bostick Acceptance 1 – geschlossene Baseline

```text
Source: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Builder/Test-ID: GROUND-AMMO-REARM-ACCEPTANCE-1
Bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
internal mission SHA-256: 2378F38E9B07365D25ACE38E45A23D87E2CC76F185A062FB2A46CA8EE31C1A53
```

Runtime:

```text
initialAmmo = 300
postFireAmmo = 296
finalAmmo = 302
GROUND_AMMO_PACKAGE = 52 -> 51
support = M1083
PASS
```

### 3.2 Acceptance 2 – gepinnter Reposition-Defekt

Revision 3 reproduzierte:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
-> UTILS.ValidateAndRepositionGroundUnits(...)
-> UTILS.GetCenterPoint(units)
-> attempt to call field 'GetCenterPoint' (a nil value)
```

Für den gepinnten Source wurde keine passende Definition von `UTILS.GetCenterPoint(...)` gefunden. Deshalb bleibt dieser Pfad ausgeschlossen.

### 3.3 Generalisierter Lifecycle und Return-to-stock

Nach Umstellung auf `WAREHOUSE:SetSpawnZone(...)` wurden Bostick, Wright und Fortress mit lokalem M1083, CampaignState-Debit, ARTY-Rearm, physischer Rückkehr und `WAREHOUSE:AddAsset(...)` erfolgreich beobachtet.

## 4. Honaker / 2B11 – Diagnoseevidenz

Teilmunitionierung `40 -> 36` führte weder mit M1083 noch mit dem diagnostischen M939 zu einer sofortigen Auffüllung. Das belegt keine Support-Inkompatibilität.

Der entscheidende Diagnose-Lauf verwendete vollständige Entleerung:

```text
2B11 40 -> 0
-> support request
-> 0 -> 40
-> SITE_REARMED
-> SITE_SUPPORT_RETURNED
-> SITE_PASS
-> aggregate PASS
```

Exakte Provenienz:

```text
Source commit: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
Executed mission: OMW_Template_v16.miz
DCS: 2.9.28.26385 MT
dcs(20260822-115128).log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief(20260822-115128).log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Zulässige Schlussfolgerung:

```text
kein 2B11-Rearm-Defekt nachgewiesen
keine M1083-Inkompatibilität nachgewiesen
DCS bestimmt den tatsächlichen Auffüllzeitpunkt seines internen Munitions-/Ladesystems
keine 2B11-Sonderimplementierung erforderlich
```

## 5. Diagnostischer Rückbau – Revision 2-8

Der Rückbau wurde source- und builderseitig abgeschlossen und lokal real gebaut.

```text
Source / Git HEAD: 02093710b7feabf3440cb04674f7799207b9da5e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
GeneratedUtc: 2026-08-22T12:49:12Z
Bundle SHA-256: 54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B
```

Der reale Builder-Output bestätigte:

```text
BostickSupportTemplate: TPL_BLUE_GND_SUP_M1083
WrightSupportTemplate: TPL_BLUE_GND_SUP_M1083
FortressSupportTemplate: TPL_BLUE_GND_SUP_M1083
HonakerSupportTemplate: TPL_BLUE_GND_SUP_M1083
FireShellsPerSite: 4
ValidateAndRepositionGroundUnits: false
PinnedMooseRepositionDefectGuard: true
SupportReturnToStock: true
HonakerM939Diagnostic: false
MizMutation: false
```

Revision 2-8 wurde nicht als neuer DCS-Runtime-PASS ausgegeben. Ihr Nachweis ist Build-/Contract-Evidenz.

## 6. Owner-approved LOCAL REARM Restart-Vertrag

Owner-Entscheidung vom 22.08.2026: **Option B genehmigt**.

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE transaction = CONSUMED

ARTY OnAfterRearmed
-> transaction = COMPLETED

server stop/crash while CONSUMED but not COMPLETED
-> exactly-once restart compensation
-> transaction = COMPENSATED
-> old transaction remains historical/closed
-> no physical replay
-> later rearm requires a new transaction ID
```

Implementierungsgrenzen:

```text
CampaignState = einzige strategische Autorität
kein zweiter Warehouse-Ressourcenledger
kein eigener Rearm-FSM
kein FullAmmo-Scanner
kein MOOSE-Patch
allgemeiner Ground Return/Loss/Restart-Pfad bleibt unverändert
```

Die Local-Rearm-Transaktionen werden durch einen deterministischen Reservation-ID-Präfix korreliert:

```text
GROUND-LOCAL-REARM:<transactionId>
```

Restart-Kompensation verwendet einen deterministischen Credit-ID-Präfix:

```text
GROUND-LOCAL-REARM-RESTART:<transactionId>
```

Damit ist die Kompensation über den vorhandenen CampaignState-Snapshot-/Credit-Vertrag idempotent.

## 7. Revision 2-9 – aktueller Kandidat

Revision 2-9 erweitert den erfolgreichen Pfad um den dauerhaften Completion-Nachweis:

```text
ARTY OnAfterRearmed
-> CampaignState:CompleteConsumption(transactionId)
-> transaction status COMPLETED
-> erst danach Acceptance-Marker SITE_REARM_COMPLETED / SITE_REARMED
-> Support Return-to-stock
```

Der Ground-Produktionspfad wurde zugleich erweitert:

```text
GroundBase restored attach
-> existing general Ground ReconcileRestore()
-> GroundAmmoRearmAdapter.ReconcileRestore()
-> CONSUMED local rearm => exactly-once strategic compensation
-> COMPLETED local rearm => preserved consumed resource
-> RESERVED/LOADING local rearm => cancel reservation, no physical replay
```

Aktueller Builder:

```text
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
```

Für Revision 2-9 sind lokale Builds/Hashes der betroffenen Produktions- und Acceptance-Bundles noch erforderlich. Es wird vor dieser realen Ausgabe kein Hash behauptet.

## 8. Mission-Editor-Vertrag

RESUPPLY-Zonen:

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
ausreichend Abstand zu HESCOs, Gebäuden, Statics und Ground Units
```

Zielzonen:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

## 9. PASS-Kriterien Revision 2-9

Pflichtmarker pro Standort:

```text
SITE_START
SITE_FIRE_COMPLETE
SITE_REARM_REQUEST
SITE_SUPPORT_MATERIALIZED
SITE_CONSUMPTION_COMMITTED
SITE_REARM_COMPLETED
SITE_REARMED
SITE_SUPPORT_RETURNED
SITE_PASS
```

Zusätzlicher strategischer Gate:

```text
CampaignState transaction status == COMPLETED
GROUND_AMMO_PACKAGE available == before - 1
```

Aggregate PASS:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4
```

## 10. Nicht Teil dieses DCS-Laufs

```text
realer Server-Crash
Filesystem-Persistenztransport
physisches Replay einer abgebrochenen Rearm-Mission
OP reinforcement lifecycle
automatische Fire-Mission-Generierung
taktische Zielzuweisung
MOOSE patch / GetCenterPoint-Ersatz
```

Die Restart-Kompensation ist ein CampaignState-/Restore-Vertrag und nutzt den bereits vorhandenen externen Snapshot-/Restore-Transport. Ein neuer Persistenz-Host wird in PR #112 nicht eingeführt.

## 11. Status

```text
Bostick Acceptance-1: VALIDATED exact documented scope
Acceptance-2 generalized materialization/rearm/return evidence: PARTIAL/REAL DCS EVIDENCE
Honaker 2B11 40 -> 0 -> 40 diagnostic: PASS exact diagnostic provenance
M939 production contract: REMOVED
SetValidateAndRepositionGroundUnits: EXCLUDED for pinned MOOSE
Revision 2-8 rollback build/hash: COMPLETE
LOCAL REARM Option B: OWNER APPROVED / SOURCE IMPLEMENTED
Revision 2-9 build/hash: PENDING
Revision 2-9 DCS runtime: NOT_RUN
PR #112: DRAFT / NOT MERGED
```
