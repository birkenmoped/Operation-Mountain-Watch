---
document_id: OMW-GROUND-AMMO-REARM-CURRENT-STATUS
status: DRAFT
document_class: WORKING_STATUS
owning_policy: OMW-GOV-001
authoritative_for:
  - post-merge Ground ammo rearm implementation status
  - post-merge production artifact verification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
validated_in_dcs: partial
---

# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## Integrationsstatus

```text
Repository: birkenmoped/Operation-Mountain-Watch
Former work branch: agent/ground-ammo-rearm-integration
PR: #112 Integrate Ground ammo rearm lifecycle
PR status: MERGED
Merge commit: 761f392bbd4e9ffee416e2e598235d9040a9a752
Target: main
Project phase: COMPLETE_FOUNDATION_BUILD_PHASE
```

## Abschlussstatus

```text
Source implementation: COMPLETE / MERGED TO MAIN
Acceptance 2-11 build/hash: VERIFIED
Bundled DCS physical rearm: PASS
Option-B same-session Restore settlement: PASS
Exact runtime MIZ provenance: CLOSED
External process/server persistence: NOT PRESENT / NOT TESTED / NOT CLAIMED
Governance/register review: COMPLETE
PR #112 Ready/Merge decision: COMPLETED
Post-merge production rebuild: COMPLETED
Post-merge direct artifact hash readback: VERIFIED
Ground rearm integration block: CLOSED
```

## Exakte Acceptance-Provenienz

```text
Acceptance source/build commit:
d52a47a418fe3a1a996a5b68198b8dc033ff86c4

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11

Acceptance bundle SHA-256:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B

Executed mission:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz

Executed mission SHA-256:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620

DCS:
2.9.28.26385 MT

dcs(20260822-141914).log SHA-256:
B65B3010612F9FEDCB90210C0799DE889F64A7D643818CD8326730716662D128

debrief(20260822-141915).log SHA-256:
ED298DC7A21F153021C50726A7B9D245BD9BAF098163D6D59B9D4CB593E40C39

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der lokale Runtime-MIZ-Pfad wurde real gehasht. Sein SHA-256 stimmt exakt mit dem hochgeladenen Artefakt `OMW_Template_v16(2).miz` überein.

## Runtime-Ergebnis

```text
BOSTICK   300 -> 296 -> 301 / M1083 / COMPLETED / support returned / PASS
WRIGHT    300 -> 296 -> 300/301 / M1083 / COMPLETED / support returned / PASS
FORTRESS  150 -> 146 -> 151 / M1083 / COMPLETED / support returned / PASS
HONAKER    40 ->   0 ->  40 / M1083 / COMPLETED / support returned / PASS
```

Restore-Settlement innerhalb derselben DCS-Session:

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

## Architekturgrenzen

```text
CampaignState = einzige strategische Ressourcenautorität
MIST = nicht verwendet
MOOSE patch = nicht verwendet
Custom Rearm FSM = nicht verwendet
FullAmmo scanner = nicht verwendet
WAREHOUSE:SetSpawnZone(...) = verwendet
WAREHOUSE:SetValidateAndRepositionGroundUnits(...) = ausgeschlossen
Honaker M1083 = owner-confirmed
Honaker 2B11 request only at postFireAmmo == 0
```

Die Restore-Phase verwendete isolierte `CampaignState.Restore(...)`-Kopien innerhalb derselben DCS-Session. Ein echter Prozess-/Server-Restart mit externer Snapshot-Datei wurde nicht getestet und wird nicht behauptet.

## Post-Merge Produktionsbuild auf `main`

Der Projektinhaber hat nach dem Merge real auf `main` gebaut und die Builder-Ausgaben anschließend durch direkte `Get-FileHash`-Readbacks der erzeugten Artefakte bestätigt:

```text
Build Git HEAD:
761f392bbd4e9ffee416e2e598235d9040a9a752

AirOps Warehouse Production
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Output: mission/runtime/logistics/OMW_AirOps_Warehouse_Base.lua
Builder-reported BundleSHA256:
F4FBF6DB71E56AADBF0B31C931638754FF4DDB75F90E570BA127E56A0251974F
Direct Get-FileHash SHA-256:
F4FBF6DB71E56AADBF0B31C931638754FF4DDB75F90E570BA127E56A0251974F
Result: MATCH / VERIFIED

Ground Production
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Output: mission/ground-operations/dist/OMW_Ground_Base.lua
Builder-reported SHA256:
A5D2A101FFEC3F1C222463002D7D5668C77EF6ACDEEDE1D8B8FEEB5E19D2E026
Direct Get-FileHash SHA-256:
A5D2A101FFEC3F1C222463002D7D5668C77EF6ACDEEDE1D8B8FEEB5E19D2E026
Result: MATCH / VERIFIED
```

Die ersten direkten Hash-Versuche schlugen ausschließlich wegen zuvor falsch angegebenen Artefaktpfaden fehl. Die anschließend auf den realen Builder-Ausgabepfaden ermittelten Hashes stimmen jeweils exakt mit der Builder-Ausgabe überein. Es war kein erneuter Build erforderlich.

## Mission-Editor Cleanup nach Acceptance

`OMW_Ground_Fire_Support_Acceptance_2.lua` ist ausschließlich Acceptance-Harness und gehört nicht in die normale Produktions-/Arbeitsmission.

```text
Aus normaler Arbeitsmission entfernen:
OMW_Ground_Fire_Support_Acceptance_2.lua
ZON_BLUE_GND_BOSTICK_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_WRIGHT_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_FORTRESS_ARTY_ACCEPTANCE_TARGET
ZON_BLUE_GND_HONAKER_MORTAR_ACCEPTANCE_TARGET

Produktiv behalten:
Moose.lua
OMW_AirOps_Warehouse_Base.lua
OMW_Ground_Base.lua
ZON_BLUE_GND_BOSTICK_RESUPPLY
ZON_BLUE_GND_WRIGHT_RESUPPLY
ZON_BLUE_GND_FORTRESS_RESUPPLY
ZON_BLUE_GND_HONAKER_RESUPPLY
```

Die bytegenau belegte Acceptance-Mission `OMW_Template_v16.miz` mit SHA-256 `388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620` bleibt als unverändertes Acceptance-Artefakt erhalten; die weitere Missionsentwicklung erfolgt auf einer neuen Arbeitsrevision.

## Dokumentationsstatus

Der finale PR-Workflow vor dem Merge meldete 18 Fehler und 0 Warnungen. Diese 18 Fehler lagen ausschließlich in geerbten Ground-/Army-Ground-Dokumenten; nach Schließen der Acceptance-MIZ-Metadaten bestand kein Ground-Rearm-spezifischer Validatorfehler mehr.

Der Ground-Rearm-Arbeitsblock ist nach realem Merge, post-merge Produktionsbuild, direkter Artefakt-Hashbestätigung und dokumentierter Mission-Editor-Cleanup-Grenze vollständig abgeschlossen. Ein externer Prozess-/Server-Persistence-Host bleibt ausdrücklich außerhalb dieses Abschlusses, weil er nicht vorhanden und nicht getestet ist.

## TODO

```text
[x] Source implementation
[x] Production implementation merged to main
[x] Acceptance 2-11 build/hash
[x] Bundled DCS acceptance
[x] four physical rearm legs
[x] Honaker 40 -> 0 -> 40
[x] COMPLETED for all four sites
[x] support return-to-stock for all four sites
[x] same-session restore compensation exactly once
[x] repeated restore idempotence
[x] completed preservation
[x] RESERVED/LOADING cancellation
[x] new transaction after compensation
[x] Runtime logs evaluated
[x] exact runtime MIZ path SHA-256 confirmed
[x] byte-level mission provenance closed
[x] governance and register reconciliation
[x] PR #112 Ready for Review
[x] PR #112 merged to main
[x] post-merge production rebuild on main
[x] direct Get-FileHash confirmation of both post-merge production bundles
[x] Mission Editor cleanup boundary documented

OPEN ITEMS FOR THIS BLOCK: NONE
```
