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

Die Diagnoseevidenz bleibt in der Dokumentation erhalten.

Aktueller Builder:

```text
GROUND-FIRE-SUPPORT-ACCEPTANCE-2-8
```

## 9. LOCAL REARM Restart/Replay – Owner-Entscheidung

```text
STATUS: OWNER APPROVED
DECISION: OPTION B
DATE: 22.08.2026
```

Der Projektinhaber hat Option B ausdrücklich genehmigt.

Verbindlicher Implementierungsvertrag:

```text
Rearm accepted / physical service begins
-> GROUND_AMMO_PACKAGE = CONSUMED

OnAfterRearmed
-> Rearm transaction = COMPLETED

Server stop/crash while CONSUMED but not COMPLETED
-> one-time restart compensation
-> old transaction remains historical/closed
-> any later rearm requires a new transaction ID
```

Zusätzliche Grenzen:

```text
kein Replay des alten physischen DCS/MOOSE-Rearm-Vorgangs
keine Wiederverwendung derselben Transaction ID
keine zweite Ressourcenhoheit im MOOSE Warehouse
CampaignState bleibt strategische Autorität
allgemeiner Ground-Restart-Reconciliation-Pfad bleibt unverändert
LOCAL REARM ergänzt nur Completion-/Restart-Korrelation
```

MOOSE-first:

```text
OnAfterRearmed = vorhandener ARTY-FSM-Completion-Hook
kein Custom-Rearm-FSM
kein eigener FullAmmo-Scanner
kein MOOSE-Patch
```

## 10. Aktuelle TODO-Liste

### TODO 1 – Acceptance-Provenienz

```text
STATUS: COMPLETE
```

### TODO 2 – MOOSE-/Acceptance-Dokumentation finalisieren

```text
STATUS: OPEN
```

Nachzutragen sind insbesondere SetSpawnZone, der gepinnte Reposition-Defekt, Support Return-to-stock, die korrigierte DCS-Rearm-Interpretation, die 2B11-Diagnoseevidenz und die genehmigte LOCAL-REARM-Restart-Semantik.

### TODO 3 – Lifecycle-Hygiene / finaler Review

```text
STATUS: SUBSTANTIALLY COMPLETE / FINAL REVIEW PENDING
```

Der synchrone Materialisierungsfall ist im Source berücksichtigt. Der vollständige Diff-/Contract-Review bleibt vor PR-Abschluss erforderlich.

### TODO 4 – LOCAL REARM Completion-/Restart-Korrelation implementieren

```text
STATUS: OWNER APPROVED / IMPLEMENTATION OPEN
```

```text
CONSUMED -> durable COMPLETED correlation through CampaignState
CONSUMED && not COMPLETED on restore -> exactly-once compensation
old transaction -> historical/closed
new physical rearm -> new transaction ID
```

Die Umsetzung muss den vorhandenen CampaignState Snapshot-/Restore-Pfad verwenden und darf keine zweite Persistenzautorität schaffen.

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
[x] Bostick/Wright/Fortress Rearm PASS
[x] CampaignState Debit
[x] lokaler WAREHOUSE Support-Spawn
[x] SetSpawnZone
[x] defekter GetCenterPoint-Pfad ausgeschlossen
[x] ARTY-owned Support Return
[x] WAREHOUSE AddAsset Return-to-stock
[x] 2B11 40 -> 0 -> 40 Diagnose
[x] Diagnosevertrag aus produktionsnahem Harness/Builder entfernt
[x] Option B ausdrücklich owner-approved
```

Offen:

```text
[ ] neuen BuilderVersion-2-8-Bundle-Hash real ermitteln
[ ] LOCAL REARM Completion-/Restart-Korrelation implementieren
[ ] Acceptance-2 / MOOSE-Dokumentation finalisieren
[ ] finalen Diff / Contract / Builder prüfen
[ ] falls neue Runtime-Claims erforderlich: gebündelter DCS-Test
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
        +-- Diagnose-Rückbau                 SOURCE COMPLETE
        +-- LOCAL REARM Option B             OWNER APPROVED
        +-- Builder 2-8 real bauen/hashen
        +-- Completion/Restart implementieren
        +-- Acceptance-/MOOSE-Doku finalisieren
        +-- finaler Review
        `-- PR #112 Abschluss
```
