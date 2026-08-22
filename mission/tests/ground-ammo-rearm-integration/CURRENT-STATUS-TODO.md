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

## 1. Arbeitszweig und Autorität

```text
Repository: birkenmoped/Operation-Mountain-Watch
Arbeitsbranch: agent/ground-ammo-rearm-integration
Draft PR: #112 Integrate Ground ammo rearm lifecycle
Status: OPEN / DRAFT / NOT MERGED
Projektphase: COMPLETE_FOUNDATION_BUILD_PHASE
```

Projektweit verbindliche normative Wirkung entsteht erst nach dem Governance-konformen Integrationsweg nach `main`.

Vor relevanter Weiterarbeit mindestens prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

## 2. Ziel

```text
fixed fire-support consumer
-> reale DCS-Munition wird verbraucht
-> MOOSE WAREHOUSE / BRIGADE / PLATOON materialisiert lokalen Ammo-Support
-> CampaignState bucht genau 1 GROUND_AMMO_PACKAGE
-> ARTY:SetRearmingGroup(...)
-> ARTY:Rearm()
-> DCS führt die Rearm-Mechanik aus
-> MOOSE erkennt Rearmed
-> CampaignState markiert die Transaktion COMPLETED
-> Support kehrt zurück
-> WAREHOUSE:AddAsset(...)
-> physische Support-Gruppe wird wieder Warehouse-Bestand
```

`CampaignState` bleibt einzige strategische Ressourcenautorität.

## 3. Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Der gepinnte Source enthält den ARTY-`Rearmed`-FSM-Pfad und den User-Hook `OnAfterRearmed`. Dieser vorhandene MOOSE-Callback ist der Completion-Anknüpfungspunkt; ein eigener Rearm-FSM oder FullAmmo-Scanner wird nicht eingeführt.

Für Option B wurde **keine neue MOOSE-API** eingeführt. Die vorhandenen `PROJECT-CLASS-INDEX.md`-/`VERIFIED-METHODS.md`-Einträge für ARTY, WAREHOUSE und die verwendeten Callbacks bleiben deshalb die maßgebliche MOOSE-Evidenz; es erfolgt keine unbegründete Runtime-Aufwertung dieser Register.

## 4. Bereits abgeschlossen

```text
Ground-Foundation                         COMPLETE
Ground Return/Loss/Restart Reconciliation COMPLETE
TM01M Reconciliation                      COMPLETE
TM01M = HISTORICAL_TEST_FIXTURE           COMPLETE
produktiver TM01M-Nachfolger              NICHT ERFORDERLICH
LOAD_TM01M aus aktueller Mission entfernt COMPLETE
Acceptance-1 Provenienz                   COMPLETE
```

Die ältere `main`-Dokumentation, die TM01M beziehungsweise `LOAD_TM01M` noch als offen beschreibt, ist Dokumentationsschuld und kein Entwicklungs-TODO.

## 5. Bostick Acceptance-1

```text
Source:
213119ca03a6aeae529d4291b4bbe174ac0995c2

Acceptance bundle:
94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7

Executed MIZ:
OMW_Template_v15.miz

MIZ SHA-256:
A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4

Runtime:
300 -> 296 -> 302
GROUND_AMMO_PACKAGE 52 -> 51
M1083
PASS
```

## 6. Acceptance-2 Erkenntnisse

Bestätigter generalisierter Pfad:

```text
BOSTICK   -> L118
WRIGHT    -> L118
FORTRESS  -> L118
HONAKER   -> 2B11
```

Bestätigte Architektur:

```text
WAREHOUSE:SetSpawnZone(local RESUPPLY zone)
-> local materialization
-> CampaignState GROUND_AMMO_PACKAGE debit
-> ARTY RearmingGroup
-> DCS rearm
-> ARTY Rearmed
-> ARTY-owned return
-> bounded return watcher
-> WAREHOUSE:AddAsset(group)
-> physical support removal / asset back in stock
```

Der gepinnte MOOSE-Pfad `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` ist für diesen Scope ausgeschlossen, weil er im realen Test über die fehlende `UTILS.GetCenterPoint(...)`-Abhängigkeit scheiterte. Kein MOOSE-Patch und kein Native-DCS-Fallback werden eingeführt.

## 7. 2B11-Diagnoseevidenz

Der diagnostische Lauf bestätigte:

```text
2B11 40 -> 0
-> Support request
-> 0 -> 40
-> SITE_REARMED
-> SITE_SUPPORT_RETURNED
-> SITE_PASS
-> aggregate PASS
```

Diagnose-Provenienz:

```text
Source:
5c5fa0ba7653ef51144ca0223dd7cad0ad36f0a7

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-7

Bundle SHA-256:
1655E4F2F5D4AB69BF4BDAFBD82CE3D8FF0049CD557245336B71C275F21BED3D

Executed mission:
OMW_Template_v16.miz

dcs(20260822-115128).log SHA-256:
B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10

debrief(20260822-115128).log SHA-256:
0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Schlussfolgerung:

```text
kein 2B11-Defekt nachgewiesen
keine M1083-Inkompatibilität nachgewiesen
DCS bestimmt den tatsächlichen Rearm-Zeitpunkt
keine 2B11-Sonderimplementierung erforderlich
```

## 8. Diagnostischer Rückbau

```text
STATUS: SOURCE / BUILDER COMPLETE
RUNTIME REVALIDATION: PENDING
```

Der produktionsnahe Acceptance-2-Vertrag verwendet wieder für alle vier Standorte:

```text
TPL_BLUE_GND_SUP_M1083
fireShells = 4
keine erzwungene vollständige Entleerung
```

Entfernt wurden aus Harness und Builder:

```text
TPL_BLUE_GND_SUP_M939 als Honaker-Support
fireShells = 40
requireAmmoDepleted
HONAKER_AMMO_DEPLETED
HONAKER_REARM_REQUEST_AFTER_EMPTY
HONAKER_AMMO_NOT_DEPLETED
korrespondierende Builder-Gates und Diagnose-Header
```

Realer Revision-2-8-Build:

```text
Source / Git HEAD:
02093710b7feabf3440cb04674f7799207b9da5e

BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8

GeneratedUtc:
2026-08-22T12:49:12Z

Bundle SHA-256:
54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B
```

Dieser Nachweis ist Build-/Contract-Evidenz, kein neuer DCS-PASS.

## 9. LOCAL REARM Restart/Replay – Owner-Entscheidung und Umsetzung

```text
STATUS: OWNER APPROVED / SOURCE IMPLEMENTED / BUILD VERIFIED
DECISION: OPTION B
DATE: 22.08.2026
```

Verbindlicher Vertrag:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

OnAfterRearmed
-> Rearm transaction = COMPLETED

Server stop/crash while CONSUMED but not COMPLETED
-> one-time restart compensation
-> transaction = COMPENSATED
-> old transaction remains historical/closed
-> any later rearm requires a new transaction ID
```

Implementiert wurde:

```text
CampaignState.TransactionStatus.COMPLETED
CampaignState.TransactionStatus.COMPENSATED
Store:CompleteConsumption(...)
Store:MarkConsumptionCompensated(...)

GroundAmmoRearmAdapter reservationId:
GROUND-LOCAL-REARM:<transactionId>

Restart creditId:
GROUND-LOCAL-REARM-RESTART:<transactionId>

GroundAmmoRearmAdapter.ReconcileRestore(...)
CONSUMED   -> CreditResourceOnce + COMPENSATED
COMPLETED  -> bleibt konsumiert
COMPENSATED -> keine zweite Gutschrift
RESERVED/LOADING -> Cancel / Reservation freigeben
```

`GroundRuntimeIntegration` führt beim bestehenden restored Attach zuerst den allgemeinen Ground-`ReconcileRestore()`-Pfad und danach die getrennte Local-Rearm-Reconciliation aus. Kein physischer DCS/MOOSE-Vorgang wird wiederholt.

Zusätzliche Grenzen:

```text
kein Replay des alten physischen DCS/MOOSE-Rearm-Vorgangs
keine Wiederverwendung einer bereits vorhandenen Transaction ID für einen neuen Rearm
keine zweite Ressourcenhoheit im MOOSE Warehouse
CampaignState bleibt strategische Autorität
allgemeiner Ground-Restart-Reconciliation-Pfad bleibt unverändert
kein neuer Persistenz-Host
```

### 9.1 Real bestätigte Build-/Hash-Provenienz für Option B

Vom Projektinhaber am 22.08.2026 real ausgeführt und zurückgemeldet:

```text
Source / Git HEAD:
49f43a856c1f8bc32ca64835af856119a295640e

CampaignState source SHA-256:
18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production BuilderVersion:
OMW-AIROPS-WAREHOUSE-BASE-3
Bundle SHA-256:
472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production BuilderVersion:
OMW-GROUND-PRODUCTION-BASE-4
GroundBaseSchema: OMW-GROUND-PRODUCTION-BASE-2
GroundRuntimeIntegrationSchema: OMW-GROUND-RUNTIME-INTEGRATION-2
GroundAmmoRearmAdapterSchema: OMW-GROUND-AMMO-REARM-ADAPTER-2
Bundle SHA-256:
9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB

Fixed Fire Support Acceptance BuilderVersion:
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
GeneratedUtc:
2026-08-22T13:06:55Z
Bundle SHA-256:
D0E628C58567CB46126048AA2903F17C9D15F316C415FFB755FD0192B230EA09
```

Die vom jeweiligen Builder ausgegebenen Bundle-Hashes stimmen exakt mit den anschließend separat über `Get-FileHash -Algorithm SHA256` ermittelten Hashes überein.

Zusätzlich bestätigte Builder-Gates:

```text
LocalRearmRestartCompensation: true
LocalRearmPhysicalReplay: false
DurableRearmCompletion: true
ValidateAndRepositionGroundUnits: false
PinnedMooseRepositionDefectGuard: true
ApprovedRoadSpawnException: false
SupportReturnToStock: true
HonakerM939Diagnostic: false
MizMutation: false
```

Dieser Nachweis bestätigt Build, Contract-Gates und Hash-Konsistenz. Er ist **kein** DCS-Runtime-Nachweis für den neuen `COMPLETED`-/Restart-Compensation-Pfad.

## 10. Aktuelle TODO-Liste

### TODO 1 – Acceptance-Provenienz

```text
STATUS: COMPLETE
```

### TODO 2 – MOOSE-/Acceptance-Dokumentation finalisieren

```text
STATUS: BUILD PROVENANCE RECORDED / FINAL REVIEW PENDING
```

`ACCEPTANCE-2.md`, `docs/moose/FIXED-FIRE-SUPPORT-REARM.md` und diese Statusdatei enthalten Diagnoseevidenz, SetSpawnZone/Reposition-Boundary, Support Return-to-stock, Option-B-Completion-/Restart-Semantik und die realen Option-B-Build-Hashes. Für Option B wurde keine neue MOOSE-Methode eingeführt; daher ist keine künstliche Statusänderung in `PROJECT-CLASS-INDEX.md` oder `VERIFIED-METHODS.md` erforderlich.

### TODO 3 – Lifecycle-Hygiene / finaler Review

```text
STATUS: SUBSTANTIALLY COMPLETE / FINAL REVIEW PENDING
```

Der synchrone Materialisierungsfall ist berücksichtigt. Die neuen Source-Contracts besitzen Tests für `COMPLETED`, exactly-once `COMPENSATED`, Pre-Commit-Cancel und die Verdrahtung über `GroundRuntimeIntegration`. Diese Lua-Tests sind im Repository vorhanden, wurden in diesem Arbeitsgang aber mangels dokumentierter ausführbarer Lua-CI **nicht als ausgeführt behauptet**.

### TODO 4 – LOCAL REARM Completion-/Restart-Korrelation

```text
STATUS: SOURCE IMPLEMENTED / BUILD VERIFIED / DCS RUNTIME PENDING
```

Die Implementierung folgt dem owner-approved Option-B-Vertrag und nutzt ausschließlich den vorhandenen CampaignState Snapshot-/Restore-/Credit-Vertrag. Die drei betroffenen Bundles wurden für Source `49f43a856c1f8bc32ca64835af856119a295640e` real gebaut und gehasht; die neuen Runtime-Claims bleiben bis zum DCS-Lauf offen.

### TODO 5 – OP-Verluste und automatische Verstärkung

```text
STATUS: OPEN / SEPARATER FOLGESCOPE
```

Gehört später in Ground-/MissionDemand-Orchestrierung, nicht in den Rearm-Adapter.

### TODO 6 – Regression / Produktionsintegration

```text
STATUS: IN FINALIZATION
```

Erledigt:

```text
[x] Acceptance-1 Provenienz
[x] generalisierter Vier-Consumer-Harness
[x] Bostick/Wright/Fortress Rearm-PASS für dokumentierte ältere Provenienz
[x] CampaignState Debit
[x] lokaler WAREHOUSE Support-Spawn
[x] SetSpawnZone
[x] defekter GetCenterPoint-Pfad ausgeschlossen
[x] ARTY-owned Support Return
[x] WAREHOUSE AddAsset Return-to-stock
[x] 2B11 40 -> 0 -> 40 Diagnose
[x] Diagnosevertrag aus produktionsnahem Harness/Builder entfernt
[x] Revision 2-8 real gebaut/gehasht
[x] Option B ausdrücklich owner-approved
[x] Option B source-seitig implementiert
[x] Acceptance-Harness auf dauerhaften COMPLETED-Status angehoben
[x] Ground-Production-Base um Local-Rearm-Restore-Reconciliation erweitert
[x] AirOps Warehouse Production Base für Option-B-CampaignState neu gebaut/gehasht
[x] Ground Production Base 4 real gebaut/gehasht
[x] Acceptance-2 Revision 2-9 real gebaut/gehasht
[x] Builder-/separate Get-FileHash-Werte stimmen für alle drei Bundles überein
[x] Option-B-Build-Provenienz in Acceptance-/MOOSE-/Statusdokumentation eingetragen
```

Offen:

```text
[ ] finalen Diff / Contract / Builder prüfen
[ ] branch-eigene Dokumentationsvalidator-Schuld bereinigen; geerbte Ground-Foundation-Schuld separat ausweisen
[ ] gebündelten DCS-Test des neuen COMPLETED-Pfades durchführen
[ ] Restart-Compensation nur mit realer Restore-Provenienz als DCS-validiert markieren
[ ] Owner-Entscheidung PR #112 Ready / Merge
```

## 11. Nicht mehr offen

```text
TM01M Reconciliation
LOAD_TM01M entfernen
produktiven TM01M-Nachfolger entwickeln
2B11 ersetzen
M109 einführen
Custom-Rearm für 2B11 bauen
M939 als Honaker-Produktionslösung verwenden
MOOSE GetCenterPoint nachbauen
SetValidateAndRepositionGroundUnits wieder einschalten
zweiten Ground CampaignState schaffen
zweite Ressourcenhoheit im Warehouse einführen
```

## 12. Reihenfolge

```text
Ground Ammo Rearm / Fixed Fire Support
        |
        +-- Diagnose-Rückbau                 COMPLETE / BUILD VERIFIED
        +-- LOCAL REARM Option B             OWNER APPROVED / SOURCE IMPLEMENTED / BUILD VERIFIED
        +-- Option-B Bundle-Provenienz       COMPLETE
        +-- Doku-Reconciliation              BUILD PROVENANCE RECORDED
        +-- finaler Diff/Contract-Review     PENDING
        +-- DCS COMPLETED Runtime-Acceptance PENDING
        +-- Restart-Compensation Acceptance  PENDING REAL RESTORE PROVENANCE
        `-- Owner-Entscheidung PR #112 Ready / Merge
```
