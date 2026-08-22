---
document_id: OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2
status: SUPERSEDED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - combined DCS acceptance plan of fixed fire-support rearm for Bostick, Wright, Fortress and Honaker
  - required Mission Editor target- and local resupply-zone contract for that combined run
  - Option-B durable completion and restore-settlement runtime acceptance boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11-RUNTIME
source_branch: main
source_commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
validated_in_dcs: true
---

# Ground Fire Support Acceptance 2 – gebündelter Abschlusslauf

> Der Plan ist abgeschlossen und durch `results/2026-08-22-acceptance-2-11-runtime.md` als exakte Runtime-Evidenz superseded. PR #112 wurde mit Merge-Commit `761f392bbd4e9ffee416e2e598235d9040a9a752` nach `main` integriert.

## 1. Ziel und Vertrag

Revision 2-11 bündelte die verbleibenden Runtime-Prüfungen in einem DCS-Lauf:

```text
Phase A: reale MOOSE/DCS-Rearm-Legs
Bostick   L118 / M1083 / 4 rounds
Wright    L118 / M1083 / 4 rounds
Fortress  L118 / M1083 / 4 rounds
Honaker   2B11 / M1083 / 40 -> 0

Phase B: CampaignState Restore-Settlement auf isolierten Snapshot-Kopien
CONSUMED    -> COMPENSATED exactly once
COMPENSATED -> repeated restore without duplicate credit
COMPLETED   -> preserved without compensation
RESERVED    -> CANCELLED
LOADING     -> CANCELLED
new transaction after compensation -> new ID -> COMPLETED
```

Phase B lief innerhalb derselben DCS-Session. Sie war kein echter DCS-Prozessrestart und kein externer Persistenztest.

`CampaignState` bleibt einzige strategische Ressourcenautorität.

## 2. MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verwendete MOOSE-Verträge:

```text
WAREHOUSE:SetSpawnZone(...)
WAREHOUSE:AddAsset(...)
ARTY:SetRearmingGroup(...)
ARTY:SetRearmingGroupOnRoad(...)
ARTY:SetRearmingDistance(...)
ARTY:Rearm()
ARTY OnAfterRearmed
SCHEDULER:New(...)
```

Ausgeschlossen bleiben:

```text
WAREHOUSE:SetValidateAndRepositionGroundUnits(...)
MIST
MOOSE patch / UTILS.GetCenterPoint fallback
private/native DCS rearm parallel path
```

## 3. Honaker / 2B11

Aktiver Vertrag:

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 40 rounds / requireAmmoDepleted=true
```

Honaker darf den Support-/Rearm-Request erst bei `postFireAmmo == 0` auslösen. M1083 ist owner-confirmed; M939 bleibt historische Diagnosevariable.

## 4. Option B

Owner-approved:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED

Restore mit CONSUMED aber nicht COMPLETED
-> deterministic CreditResourceOnce
-> transaction = COMPENSATED
-> no physical replay
-> old transaction remains closed
-> later rearm requires a new transaction ID
```

## 5. Produktionsbundle-Provenienz des getesteten Branch-Standes

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production Base
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production Base
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

## 6. Acceptance 2-11 Build-/Runtime-Provenienz

```text
Acceptance source/build commit:
d52a47a418fe3a1a996a5b68198b8dc033ff86c4

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11

GeneratedUtc:
2026-08-22T14:07:19Z

Acceptance Bundle SHA-256:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B

Executed mission:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz

Executed mission SHA-256:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620

internal mission SHA-256:
180D07D7001FA6EFBDD92D4867F8EDAEFFEFA72470FEE2AEC6A3616B5E919481

DCS:
2.9.28.26385 MT

dcs(20260822-141914).log SHA-256:
B65B3010612F9FEDCB90210C0799DE889F64A7D643818CD8326730716662D128

debrief(20260822-141915).log SHA-256:
ED298DC7A21F153021C50726A7B9D245BD9BAF098163D6D59B9D4CB593E40C39
```

Der lokale Runtime-MIZ-Pfad wurde real mit `Get-FileHash -Algorithm SHA256` bestätigt. Sein Hash stimmt exakt mit dem hochgeladenen Prüfartefakt `OMW_Template_v16(2).miz` überein. Die Mission-Provenienz ist damit bytegenau geschlossen.

## 7. Runtime-Ergebnis

Physische Phase:

```text
BOSTICK   300 -> 296 -> 301 / M1083 / COMPLETED / return-to-stock / PASS
WRIGHT    300 -> 296 -> 300/301 / M1083 / COMPLETED / return-to-stock / PASS
FORTRESS  150 -> 146 -> 151 / M1083 / COMPLETED / return-to-stock / PASS
HONAKER    40 ->   0 ->  40 / M1083 / COMPLETED / return-to-stock / PASS
```

Honaker-Pflichtmarker:

```text
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
```

Restore-Settlement auf isolierten Restore-Kopien innerhalb derselben DCS-Session:

```text
CONSUMED -> COMPENSATED exactly once                       PASS
second restore -> no duplicate credit                     PASS
new transaction after compensation -> new ID -> COMPLETED PASS
COMPLETED restore -> no compensation                      PASS
RESERVED restore -> CANCELLED                             PASS
LOADING restore -> CANCELLED                              PASS
authoritative runtime store isolation                     PASS
```

Gesamtmarker:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4 restoreSettlement=true
```

Vollständige Ergebnisdatei:

```text
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
```

## 8. Persistenzgrenze

```text
CampaignState ExportSnapshot -> Restore -> ReconcileRestore: DCS RUNTIME PASS in same-session scope
externer Dateisystem-/Server-Persistence-Host: NICHT VORHANDEN
realer DCS-Prozessrestart mit Snapshot-Datei: NICHT GETESTET / NICHT BEHAUPTET
```

Keine `io`-/`lfs`-Persistenz, keine `MissionScripting.lua`-Änderung und keine zweite Persistenzautorität wurden eingeführt.

## 9. Mission-Editor-Vertrag und Cleanup

RESUPPLY-Zonen sind produktiv und bleiben erhalten:

```text
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Acceptance-spezifisch und nach Abschluss aus einer normalen Arbeits-/Produktionsmission entfernbar:

```text
OMW_Ground_Fire_Support_Acceptance_2.lua
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET
```

Die getestete `OMW_Template_v16.miz` mit SHA-256 `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620` bleibt als unverändertes Acceptance-Artefakt erhalten. Weitere Missionsarbeit erfolgt auf einer neuen Arbeitsrevision.

## 10. Post-Merge Produktionsbuild

Nach Merge von PR #112 auf `main` wurde bei `HEAD=761f392bbd4e9ffee416e2e598235d9040a9a752` real neu gebaut:

```text
AirOps Warehouse Production
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Output: mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
Builder-reported BundleSHA256:
F4FBF6DB71E56AADBF0B31C931638754FF4DDB75F90E570BA127E56A0251974F

Ground Production
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Output: mission/ground-operations/dist/OMW_Ground_Base.lua
Builder-reported SHA256:
A5D2A101FFEC3F1C222463002D7D5668C77EF6ACDEEDE1D8B8FEEB5E19D2E026
```

Die separaten direkten `Get-FileHash`-Readbacks dieser beiden korrekten Ausgabepfade stehen noch aus. Bis dahin werden die Werte nicht als unabhängig bestätigte Artefakthashes bezeichnet.

## 11. Status

```text
Revision-2-7 full-depletion diagnostic: DCS PASS for exact provenance
Revision-2-10 corrected contract: BUILD/HASH VERIFIED; no isolated DCS rerun
Revision-2-11 bundled acceptance: DCS PASS for exact documented scope
Mission provenance: CLOSED
M1083 as Honaker support: OWNER CONFIRMED
Option-B production implementation: MERGED TO MAIN
PR #112: MERGED
Merge commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
Post-merge production rebuild: COMPLETE
Post-merge direct production artifact hash readback: PENDING
External filesystem/server persistence host: NOT PRESENT / NOT TESTED / NOT CLAIMED
```
