---
document_id: OMW-GROUND-AMMO-REARM-CURRENT-STATUS
status: DRAFT
document_class: WORKING_STATUS
owning_policy: OMW-GOV-001
authoritative_for:
  - current branch-local Ground ammo rearm implementation status and remaining work
  - handoff state for PR 112 before owner-gated Ready or Merge
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/ground-ammo-rearm-integration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# Ground Ammo Rearm Integration – aktueller Stand und TODO

Stand: 22.08.2026

## Arbeitszweig

```text
Repository: birkenmoped/Operation-Mountain-Watch
Arbeitsbranch: agent/ground-ammo-rearm-integration
Draft PR: #112 Integrate Ground ammo rearm lifecycle
Status: OPEN / DRAFT / NOT MERGED
Projektphase: COMPLETE_FOUNDATION_BUILD_PHASE
```

## Architektur

```text
fixed fire-support consumer
-> reale DCS-Munition wird verbraucht
-> MOOSE WAREHOUSE / BRIGADE / PLATOON materialisiert lokalen M1083
-> CampaignState bucht genau 1 GROUND_AMMO_PACKAGE
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> DCS/MOOSE Rearm
-> ARTY OnAfterRearmed
-> CampaignState transaction = COMPLETED
-> ARTY-owned support return
-> WAREHOUSE:AddAsset(...)
```

`CampaignState` bleibt einzige strategische Ressourcenautorität. Kein MIST, kein eigener Rearm-FSM, kein FullAmmo-Scanner, kein MOOSE-Patch.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

`WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` bleibt wegen des real bestätigten `UTILS.GetCenterPoint`-Defekts ausgeschlossen. Lokale Materialisierung bleibt auf `WAREHOUSE:SetSpawnZone(...)`.

## Aktiver Vier-Consumer-Vertrag

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / L118 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / L118 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / L118 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 2B11 / 40 rounds / requireAmmoDepleted=true
```

Honaker darf den Support-/Rearm-Request erst nach `postFireAmmo == 0` auslösen.

## Option B

```text
physical rearm begins
-> transaction = CONSUMED

ARTY OnAfterRearmed
-> transaction = COMPLETED

Restore mit CONSUMED aber nicht COMPLETED
-> exactly-once strategic compensation
-> transaction = COMPENSATED
-> no physical replay
-> later service requires a new transaction ID
```

Produktionsbundles real gebaut/gehasht:

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

OMW_AirOps_Warehouse_Base.lua
472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

OMW_Ground_Base.lua
9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

## Revision 2-11 Build-/Hash-Provenienz

```text
Source / Git HEAD: d52a47a418fe3a1a996a5b68198b8dc033ff86c4
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-11
GeneratedUtc: 2026-08-22T14:07:19Z
Bundle SHA-256:
CBA3ACF5D835E6EF6AD11C3FDD295E178B2B8E6B9330749C15419A1638CF379B
```

Builder-Ausgabe und separate `Get-FileHash`-Ausgabe stimmen exakt überein.

## Revision 2-11 DCS Runtime

```text
DCS: 2.9.28.26385 MT
Executed mission:
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v16.miz

Executed mission SHA-256:
388F02C932BE83823543F97887B4EDBB9E6764D4CEBE543BD8423D43A6ED8620

dcs(20260822-141914).log
SHA-256: B65B3010612F9FEDCB90210C0799DE889F64A7D643818CD8326730716662D128

debrief(20260822-141915).log
SHA-256: ED298DC7A21F153021C50726A7B9D245BD9BAF098163D6D59B9D4CB593E40C39
```

Der lokale Runtime-MIZ-Pfad wurde real gehasht. Sein SHA-256 stimmt exakt mit dem hochgeladenen Prüfartefakt `OMW_Template_v16(2).miz` überein. Die bytegenaue Mission-Provenienz ist damit geschlossen.

Physische Phase:

```text
BOSTICK   300 -> 296 -> 301 / M1083 / COMPLETED / support returned / SITE_PASS
WRIGHT    300 -> 296 -> 300/301 / M1083 / COMPLETED / support returned / SITE_PASS
FORTRESS  150 -> 146 -> 151 / M1083 / COMPLETED / support returned / SITE_PASS
HONAKER    40 ->   0 ->  40 / M1083 / COMPLETED / support returned / SITE_PASS
```

Honaker-Marker:

```text
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
```

Restore-Settlement innerhalb derselben DCS-Laufzeit:

```text
CONSUMED -> COMPENSATED exactly once                         PASS
second restore -> no duplicate credit                       PASS
new transaction after compensation -> new ID -> COMPLETED   PASS
COMPLETED restore -> no compensation                        PASS
RESERVED restore -> CANCELLED                               PASS
LOADING restore -> CANCELLED                                PASS
authoritative runtime store isolated from fixture copies    PASS
```

Gesamtmarker:

```text
PASS FIXED_FIRE_SUPPORT_REARM_CONFIRMED=true sites=4 restoreSettlement=true
```

Ausführliche Runtime-Evidenz:

```text
mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md
```

## Persistenzgrenze

```text
CampaignState ExportSnapshot/Restore/ReconcileRestore: DCS RUNTIME PASS
externer Dateisystem-/Server-Persistence-Host: NICHT VORHANDEN
realer DCS-Prozessrestart mit Snapshot-Datei: NICHT GETESTET / NICHT BEHAUPTET
```

Revision 2-11 führt keine `io`-/`lfs`-Persistenz, keine `MissionScripting.lua`-Änderung und keinen zweiten Persistenzpfad ein.

## Dokumentationsstatus

Der letzte geprüfte Workflow `Documentation validation` meldete:

```text
18 errors
0 warnings
```

Alle 18 Fehler lagen in geerbten `docs/ground/`- bzw. `mission/tests/army-ground-foundation/`-Dokumenten; keiner in den geänderten Ground-Rearm-Dokumenten.

## TODO

```text
[x] Acceptance-1 Provenienz
[x] Vier-Consumer-Pfad
[x] CampaignState Debit
[x] lokaler WAREHOUSE M1083 Spawn
[x] SetSpawnZone
[x] defekter GetCenterPoint-Pfad ausgeschlossen
[x] ARTY-owned Support Return
[x] WAREHOUSE AddAsset Return-to-stock
[x] Honaker 2B11 40 -> 0 -> 40
[x] M1083 für Honaker owner-confirmed
[x] Option B source-seitig implementiert
[x] Option-B Produktionsbundles real gebaut/gehasht
[x] Revision 2-11 real gebaut/gehasht
[x] EIN gebündelter DCS-Acceptance-Lauf
[x] vier physische Rearms inkl. Honaker full depletion
[x] COMPLETED für alle vier Standorte
[x] Support Return-to-stock für alle vier Standorte
[x] Restore compensation exactly once
[x] repeated-restore idempotence
[x] completed-preservation
[x] RESERVED/LOADING cancellation
[x] new transaction after compensation
[x] Runtime-Logs ausgewertet und Ergebnis dokumentiert
[x] exakten SHA-256 des im Debrief genannten Runtime-MIZ-Pfads real bestätigt
[x] Mission-Provenienz bytegenau geschlossen

[ ] finalen PR-#112-Diff / Registry / CI-Stand gegen Governance prüfen
[ ] Owner-Entscheidung PR #112 Ready / Merge
```

## Aktueller Abschlussstand

```text
Ground Ammo Rearm / Fixed Fire Support
        |
        +-- source implementation            COMPLETE
        +-- production build/hash            VERIFIED
        +-- Revision 2-11 build/hash         VERIFIED
        +-- bundled DCS runtime              PASS
        +-- Option-B restore settlement      PASS within DCS runtime
        +-- exact runtime MIZ provenance     CLOSED
        +-- final PR review                  PENDING
        `-- Owner-Entscheidung PR #112 Ready / Merge
```
