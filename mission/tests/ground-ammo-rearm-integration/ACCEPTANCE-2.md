---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined DCS acceptance of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target- and local resupply-zone contract for that combined run
  - Option-B durable completion runtime acceptance boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground Fire Support Acceptance 2 – kombinierter Vier-Consumer-Lauf

## 1. Ziel

Ein DCS-Lauf bündelt vier getrennt bewertbare Rearm-Legs:

```text
Bostick   L118  -> Regression
Wright    L118  -> Runtime-Acceptance
Fortress  L118  -> Runtime-Acceptance
Honaker   2B11  -> Runtime-Acceptance über explicit MOOSE RearmingGroup
```

Aktueller MOOSE-first-Pfad:

```text
MOOSE BRIGADE/PLATOON/WAREHOUSE
-> WAREHOUSE:SetSpawnZone(RESUPPLY zone)
-> local M1083 materialization
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> ARTY OnAfterRearmed
-> CampaignState transaction COMPLETED
-> MOOSE ARTY support return
-> low-frequency MOOSE SCHEDULER return confirmation
-> WAREHOUSE:AddAsset(group)
-> physical M1083 removed / asset back in Warehouse stock
```

CampaignState bleibt einzige strategische Ressourcenautorität.

## 2. MOOSE-Provenienz

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
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY:onafterRearm
ARTY:onafterRearmed
SCHEDULER:New(...)
```

Bewusst ausgeschlossen:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
```

Grund: Der gepinnte Source ruft in `UTILS.ValidateAndRepositionGroundUnits(...)` `UTILS.GetCenterPoint(units)` auf; für den gepinnten OMW-Stand wurde keine Definition dieser Funktion gefunden. Ein realer DCS-Lauf reproduzierte exakt `attempt to call field 'GetCenterPoint' (a nil value)`. OMW patcht MOOSE nicht und implementiert keinen Ersatz, weil `SetSpawnZone(...)` mit kontrolliert freier ME-Zone ausreicht.

## 3. Frühere Acceptance-Evidenz

Revision 1:

```text
BOSTICK   SITE_PASS
WRIGHT    SITE_PASS
FORTRESS  SITE_PASS
HONAKER   kein SITE_PASS bis GlobalTimeout
Aggregate: FAIL reason=TIMEOUT
```

Revision 3 isolierte den gepinnten MOOSE-Reposition-Defekt:

```text
M1083 materialization: 0/4
SITE_SUPPORT_MATERIALIZED: 0/4
Aggregate: FAIL reason=TIMEOUT
Root cause: ValidateAndRepositionGroundUnits -> missing UTILS.GetCenterPoint
```

Danach wurde der fehlerhafte Pfad entfernt und `WAREHOUSE:SetSpawnZone(...)` beibehalten.

## 4. 2B11-Diagnose und korrigierte Interpretation

Die Honaker-Diagnose wurde bewusst auf vollständige Munitionsentleerung umgestellt. Der Harness verlangte:

```text
fireShells = 40
requireAmmoDepleted = true
postFireAmmo == 0
Support request erst nach bestätigter Vollentleerung
```

Der reale Lauf bewies für den exakt getesteten Stand:

```text
2B11 40 -> 0
-> support request
-> 0 -> 40
-> SITE_REARMED
-> SITE_SUPPORT_RETURNED
-> SITE_PASS
-> aggregate PASS
```

Provenienz:

```text
Source: 5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7
Bundle SHA-256: 1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D
DCS: 2.9.28.26385 MT
MIZ: OMW_Template_v16.miz
dcs.log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief.log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Belegbare Schlussfolgerung:

```text
- kein 2B11-Defekt nachgewiesen
- kein Custom-Rearm für 2B11 erforderlich
- vollständige Entleerung ist für den getesteten 2B11-Rearm-Pfad die nachgewiesene Voraussetzung
- partielle Entleerung ist NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

Die frühere Formulierung `DCS bestimmt den tatsächlichen Rearm-Zeitpunkt` war für partielle 2B11-Entleerung zu weitgehend und wird hiermit korrigiert.

## 5. Aktiver produktionsnaher Honaker-Vertrag

Owner-Entscheidung vom 22.08.2026:

```text
Honaker support template: TPL_BLUE_GND_SUP_M1083
weitere Bestätigung des M1083 als Supportfahrzeug: NICHT ERFORDERLICH
```

Der M939 war ausschließlich Diagnosemittel und ist kein Produktionsvertrag.

Für die 2B11-Munitionslogik bleibt dagegen die reale Diagnose maßgeblich:

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 40 rounds / requireAmmoDepleted=true
```

Honaker darf den Rearm-Request erst nach bestätigtem `postFireAmmo == 0` auslösen.

Der frühere Revision-2-8/2-9-Rückbau auf `HONAKER / M1083 / 4 rounds` war fachlich falsch, weil er die nachgewiesene Vollentleerungsbedingung gemeinsam mit der M939-Diagnosevariable entfernt hat. Revision 2-8 und der bisherige Revision-2-9-Build bleiben als historische Build-/Contract-Evidenz erhalten, bilden aber **nicht** den korrigierten Honaker-Acceptance-Vertrag.

Historische Builds:

```text
Revision 2-8
Source / Git HEAD: 02093710b7feabf3440cb04674f7799207b9da5e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
GeneratedUtc: 2026-08-22T12:49:12Z
Bundle SHA-256: 54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B

Revision 2-9
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
GeneratedUtc: 2026-08-22T13:06:55Z
Bundle SHA-256: D0E628C58567CB46126048AA2903F17C9D15F316C415FFB755FD0192B230EA09
```

## 6. Option B – Completion-Vertrag

Owner-approved Vertrag:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED

restored startup with CONSUMED but not COMPLETED
-> exactly-once compensation
-> transaction = COMPENSATED
-> no physical replay
```

Die kombinierte Acceptance prüft im normalen erfolgreichen Lauf zusätzlich:

```text
SITE_REARM_COMPLETED
CampaignState transaction status == COMPLETED
```

Der Restart-Compensation-Fall ist ein eigener Restore-Nachweis und wird nicht aus einem normalen successful-rearm-Lauf abgeleitet.

## 7. Real bestätigte Option-B-Produktionsbundles

Vom Projektinhaber am 22.08.2026 real ausgeführt:

```text
Source / Git HEAD:
49f43a856c1f8bc32ca64835af856119a295640e

AirOps Warehouse Production Base
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production Base
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB

CampaignState Source
SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093
```

Diese Produktionsbundle-Provenienz bleibt gültig. Die notwendige Korrektur betrifft den Honaker-Acceptance-Harness und dessen Buildervertrag, nicht den M1083-Produktionsvertrag.

## 8. Mission-Editor-Vertrag

RESUPPLY-Zonen:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Zielzonen:

```text
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Anforderung für RESUPPLY:

```text
- innerhalb der jeweiligen FOB/COP-Anlage
- nahe dem Warehouse
- freier Boden für M1083
- keine Road-/Convoy-Zone
```

## 9. Support-Return-/Cleanup-Vertrag

```text
1. ARTY OnAfterRearmed wird erreicht.
2. CampaignState transaction wird COMPLETED.
3. ARTY übernimmt den Return zur gemerkten M1083-Ausgangskoordinate.
4. OMW erzeugt keinen eigenen Return-Wegpunkt.
5. MOOSE SCHEDULER bestätigt die Rückkehrgrenze.
6. WAREHOUSE:AddAsset(group) übernimmt das bekannte Asset.
7. Die physische M1083-Repräsentation verschwindet.
8. Keine CampaignState-Munition wird bei erfolgreichem Rearm zurückerstattet.
```

## 10. PASS-Kriterien des korrigierten nächsten Acceptance-Builds

Pflichtmarker pro Standort:

```text
SITE_START
SITE_FIRE_COMPLETE
SITE_REARM_REQUEST
SITE_SUPPORT_MATERIALIZED
SITE_CONSUMPTION_COMMITTED
SITE_REARMED
SITE_REARM_COMPLETED
SITE_SUPPORT_RETURNED
SITE_PASS
```

Zusätzlich Honaker:

```text
initialAmmo = 40
postFireAmmo = 0
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
supportTemplate = TPL_BLUE_GND_SUP_M1083
```

Aggregate PASS:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4
```

## 11. Nicht Teil des normalen Runtime-Laufs

```text
- real server restart between CONSUMED and COMPLETED
- persistence-host verification
- exactly-once restart compensation across repeated restores
- automatic fire-mission generation
- tactical target allocation
- OP reinforcement lifecycle
- MOOSE patch or UTILS.GetCenterPoint fallback
```

Der Restart-Compensation-Pfad wird nur mit eigener realer Snapshot-/Restore-Provenienz als DCS-validiert bewertet.

## 12. Aktueller Status

```text
Revision-2-7 diagnostic: DCS PASS for exact full-depletion diagnostic provenance
Revision-2-8 rollback: HISTORICAL BUILD/HASH EVIDENCE; Honaker full-depletion condition was incorrectly removed
Revision-2-9 build: HISTORICAL BUILD/HASH EVIDENCE; Honaker contract requires correction
M1083 production support choice for Honaker: OWNER CONFIRMED; no further confirmation required
Corrected Honaker contract: M1083 + full 40-round depletion before rearm request
Corrected next acceptance build: PENDING
Option-B DCS COMPLETED-path acceptance: PENDING corrected Honaker harness
Restart-compensation DCS restore provenance: PENDING
VALIDATED for new Option-B runtime claims: false
```
