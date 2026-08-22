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

`ARTY OnAfterRearmed` ist der vorhandene MOOSE-FSM-Completion-Hook. Es gibt keinen eigenen Rearm-FSM, keinen FullAmmo-Scanner und keinen MOOSE-Patch.

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

## 5. Acceptance-1 / Grundpfad

```text
Source: 213119ca03a6aeae529d4291b4bbe174ac0995c2
Bundle SHA-256: 94C18556B80E97A30420DD551BC0CD98E978CBA2E487A6AA6B35281E1F29FDD7
Executed MIZ: OMW_Template_v15.miz
MIZ SHA-256: A2AF2BD5FA9792DEF422F3B47755894E8F3220453F31F63F1594CCD61E9AF1B4
Runtime: 300 -> 296 -> 302
GROUND_AMMO_PACKAGE: 52 -> 51
Support: M1083
Result: PASS
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

Der gepinnte `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)`-Pfad bleibt wegen der real bestätigten fehlenden `UTILS.GetCenterPoint(...)`-Abhängigkeit ausgeschlossen.

## 6. 2B11-Diagnose – korrigierte Evidenz

Die entscheidende Honaker-Diagnose verwendete bewusst:

```text
fireShells = 40
requireAmmoDepleted = true
postFireAmmo == 0
Support request erst nach bestätigter Vollentleerung
```

Realer Lauf:

```text
2B11 40 -> 0
-> Support request
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
Executed mission: OMW_Template_v16.miz
dcs.log SHA-256: B3C218B81D5A3C386213E4721F1F1AF12C53DF840C8BB758FE7147E6BAF5FD10
debrief.log SHA-256: 0014C8FE4A4E3BD7DE3D3AF0BCB3DC30C30E786470F1EDA951EBD582F1A48FAE
```

Korrigierte Schlussfolgerung:

```text
kein 2B11-Defekt nachgewiesen
kein Custom-Rearm für 2B11 erforderlich
vollständige Entleerung ist für den getesteten 2B11-Rearm-Pfad die nachgewiesene Voraussetzung
partielle Entleerung ist NICHT als funktionierender 2B11-Rearm-Pfad nachgewiesen
```

Die frühere Aussage, bei partieller Entleerung müsse lediglich länger auf DCS gewartet werden, ist verworfen.

## 7. M1083 – Owner-Entscheidung

Owner-Entscheidung vom 22.08.2026:

```text
Honaker verwendet TPL_BLUE_GND_SUP_M1083.
Eine weitere Bestätigung des M1083 als Supportfahrzeug ist nicht erforderlich.
```

Der M939 bleibt ausschließlich historische Diagnoseevidenz und ist keine offene Produktionsalternative.

Der gültige nächste Acceptance-Vertrag lautet daher:

```text
BOSTICK   -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
WRIGHT    -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
FORTRESS  -> TPL_BLUE_GND_SUP_M1083 / 4 rounds
HONAKER   -> TPL_BLUE_GND_SUP_M1083 / 40 rounds / requireAmmoDepleted=true
```

Honaker darf erst bei `postFireAmmo == 0` den Rearm-Request auslösen.

## 8. Fehler im Diagnose-Rückbau

Beim Rückbau der M939-Diagnose wurde die Honaker-Vollentleerungsbedingung irrtümlich mit entfernt. Dadurch entstanden Revision 2-8 und Revision 2-9 mit:

```text
HONAKER -> M1083 / 4 rounds / keine Vollentleerungsbedingung
```

Dieser Vertrag ist für Honaker fachlich falsch und wird nicht weiterverwendet.

Historische Build-Evidenz bleibt erhalten:

```text
Revision 2-8
Source: 02093710b7feabf3440cb04674f7799207b9da5e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
Bundle SHA-256: 54019389DF61173BAA732524F716DFAC7930B2E74B226445167588380554FF0B

Revision 2-9
Source: 49f43a856c1f8bc32ca64835af856119a295640e
BuilderVersion: GROUND-FIRE-SUPPORT-ACCEPTANCE-2-9
Bundle SHA-256: D0E628C58567CB46126048AA2903F17C9D15F316C415FFB755FD0192B230EA09
```

Diese Builds sind Build-/Hash-Evidenz, aber kein gültiger Honaker-Acceptance-Vertrag.

## 9. LOCAL REARM Restart/Replay – Option B

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

Implementiert:

```text
CampaignState.TransactionStatus.COMPLETED
CampaignState.TransactionStatus.COMPENSATED
Store:CompleteConsumption(...)
Store:MarkConsumptionCompensated(...)
GroundAmmoRearmAdapter.ReconcileRestore(...)
```

Kein physischer Replay, kein zweiter Ressourcenledger, kein neuer Persistenz-Host.

### 9.1 Real bestätigte Option-B-Build-/Hash-Provenienz

```text
Source / Git HEAD: 49f43a856c1f8bc32ca64835af856119a295640e
CampaignState source SHA-256: 18189A633DBD78FC7EAFBDAF09601BC3241ADAD115DF09DA3EF28B1D85E3E093

AirOps Warehouse Production Base
BuilderVersion: OMW-AIROPS-WAREHOUSE-BASE-3
Bundle SHA-256: 472F72F3D688BB4B8624C882527DCA3DEBD42CDE5DD455AC63D7CD2D796BB735

Ground Production Base
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-4
Bundle SHA-256: 9AAF32A10A9EEB906123AFD37FF14B62542EE7C78F7B5E81E388A22F41EABEAB
```

Diese Produktionsbundle-Provenienz bleibt gültig. Korrigiert werden muss ausschließlich der Honaker-Acceptance-Harness/Buildervertrag.

## 10. Aktuelle TODO-Liste

```text
[x] Acceptance-1 Provenienz
[x] generalisierter Vier-Consumer-Pfad
[x] CampaignState Debit
[x] lokaler WAREHOUSE Support-Spawn
[x] SetSpawnZone
[x] defekter GetCenterPoint-Pfad ausgeschlossen
[x] ARTY-owned Support Return
[x] WAREHOUSE AddAsset Return-to-stock
[x] 2B11 40 -> 0 -> 40 Diagnose
[x] Option B owner-approved
[x] Option B source-seitig implementiert
[x] Option-B Produktionsbundles real gebaut/gehasht
[x] Dokumentation zur 2B11-Vollentleerung korrigiert
[x] M1083 für Honaker durch Owner bestätigt; keine weitere Bestätigung erforderlich

[ ] Acceptance-Harness Honaker wieder auf 40 rounds + requireAmmoDepleted=true setzen
[ ] Builder-Gates entsprechend korrigieren
[ ] korrigierten Acceptance-Bundle real bauen/hashen
[ ] finalen Diff / Contract / Builder prüfen
[ ] DCS COMPLETED-Runtime-Acceptance mit korrigiertem Honaker-Vertrag
[ ] Restart-Compensation nur mit realer Restore-Provenienz als DCS-validiert markieren
[ ] branch-eigene Dokumentationsvalidator-Schuld bereinigen
[ ] Owner-Entscheidung PR #112 Ready / Merge
```

## 11. Nicht mehr offen

```text
M1083 als Honaker-Supportfahrzeug bestätigen
M939 als Honaker-Produktionslösung verwenden
2B11 ersetzen
M109 einführen
Custom-Rearm für 2B11 bauen
MOOSE GetCenterPoint nachbauen
SetValidateAndRepositionGroundUnits wieder einschalten
zweiten Ground CampaignState schaffen
zweite Ressourcenhoheit im Warehouse einführen
```

## 12. Reihenfolge

```text
Ground Ammo Rearm / Fixed Fire Support
        |
        +-- 2B11 Evidenzkorrektur            COMPLETE
        +-- M1083 Owner-Entscheidung         COMPLETE
        +-- LOCAL REARM Option B             OWNER APPROVED / SOURCE IMPLEMENTED / BUILD VERIFIED
        +-- Honaker Acceptance-Harness       CORRECTION PENDING
        +-- korrigierter Acceptance-Build    PENDING
        +-- DCS COMPLETED Runtime-Acceptance PENDING
        +-- Restart-Compensation Acceptance  PENDING REAL RESTORE PROVENANCE
        `-- Owner-Entscheidung PR #112 Ready / Merge
```
