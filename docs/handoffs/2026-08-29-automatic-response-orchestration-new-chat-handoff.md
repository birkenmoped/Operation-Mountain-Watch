---
document_id: OMW-HANDOFF-AUTOMATIC-RESPONSE-ORCHESTRATION-NEW-CHAT-2026-08-29
status: PLANNED
document_class: DEVELOPMENT_ORDER_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local new-chat continuation of automatic response orchestration
  - local worktree and Git topology after recovery
  - immediate next development scope Stage 1D-S
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/automatic-response-orchestration-continuation
source_commit: 645a20fd00235f3f578a1191b7b93f64ce402bcf
validated_in_dcs: false
base_branch: main
base_commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
---

# Automatic Response Orchestration – Übergabe für neuen Chat

## 1. Unmittelbarer Arbeitsauftrag

Der neue Chat setzt die Entwicklung der automatischen Response-Orchestrierung fort.

Arbeitsbranch:

```text
agent/automatic-response-orchestration-continuation
```

Arbeitsverzeichnis des Projektinhabers:

```text
P:\DCS-DEV\Operation-Mountain-Watch-automatic-response-continuation
```

Verifizierter Branchstand vor dieser Übergabe:

```text
HEAD:
645a20fd00235f3f578a1191b7b93f64ce402bcf

Upstream:
origin/agent/automatic-response-orchestration-continuation

HEAD == Upstream:
true
```

`main` liegt lokal in:

```text
P:\DCS-DEV\Operation-Mountain-Watch-main
```

Verifizierter `main`-Stand:

```text
99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
```

## 2. Verbindliche Arbeitsanweisungen vor jeder fachlichen Änderung

Vor relevanter Arbeit mindestens auf `main` lesen und anwenden:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Diese Dokumente sind keine Hinweise, sondern die verbindliche Projektgrundlage. Bei Widersprüchen gilt ausschließlich die Autoritätshierarchie aus `docs/00-project-governance.md`.

Zusätzlich je nach konkretem Arbeitsschritt die zuständigen Fach-, Manifest-, ORBAT-, Mission-Editor-, Acceptance- und `docs/moose/`-Dokumente prüfen.

Wichtige Authority-Regeln:

```text
main + BINDING_PROJECT_DECISION / BINDING
-> repository-weite Autorität

branch-local PASS / DCS-Test
-> nur für exakt dokumentierten Branch, Commit, Mission, Bundle, DCS- und MOOSE-Stand

VALIDATED
-> nur nach dokumentiertem DCS-Test
```

## 3. MOOSE-first – nicht verhandelbar

Operation Mountain Watch ist verbindlich MOOSE-first.

Vor eigener Lua-Logik gilt zwingend:

```text
passende MOOSE-Dokumentation
-> tatsächlich verwendete Moose.lua
-> Signaturen / Rückgaben / FSM / Events / Voraussetzungen
-> offizielle MOOSE-Demos / Tests, soweit relevant
-> vorhandene MOOSE-Lösung direkt verwenden oder konfigurieren
-> Events / Callbacks / FSMs verwenden
-> erst danach kleinster notwendiger Adapter
```

Nicht-MOOSE-, Native-DCS- oder projektspezifische Parallelimplementierungen benötigen eine dokumentierte Lückenanalyse und die ausdrückliche Freigabe des Projektinhabers.

Nicht erfinden:

```text
MOOSE-Klassen
MOOSE-Methoden
MOOSE-Events
Argumente oder Rückgabewerte
DCS-API-Verhalten
Mission-Editor-Verhalten
Commits / Hashes
Testergebnisse
```

MOOSE-Stand für den aktuellen Ground-RESUPPLY-Scope:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Branch-lokaler Source-Review:

```text
docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md
```

## 4. Architekturgrenzen

Verbindlich:

```text
CampaignState = einzige strategische Ressourcenautorität
MissionDemand = Demand-/Assignment-Autorität
MOOSE = primärer operativer Executor
DCS-Gruppen = temporäre physische Repräsentationen
```

Keine doppelte Ressourcenhoheit zwischen:

```text
CampaignState
MOOSE Warehouse / STORAGE
DCS Warehouses
CTLD
```

DCS-/MOOSE-Adapter von Campaign-/Domainlogik trennen. Vorhandene Framework-Funktionalität nicht parallel neu implementieren.

## 5. Lokale Umgebung – wichtig

Auf dem lokalen Rechner des Projektinhabers sind **weder Lua noch Python verfügbar**.

Daher niemals lokale Anweisungen wie diese voraussetzen:

```text
lua ...
luac ...
python ...
python3 ...
```

Lokale Build- und Prüfkommandos müssen, soweit im Repository vorhanden, über PowerShell beziehungsweise vorhandene `.ps1`-Builder laufen.

Wenn Lua-/Python-Prüfungen erforderlich sind, sind GitHub/CI beziehungsweise die für ChatGPT verfügbaren Werkzeuge zu verwenden; dem Projektinhaber dürfen keine lokal nicht verfügbaren Interpreter als Voraussetzung untergeschoben werden.

Befehle und Code für den Projektinhaber immer in sauberen Codeblöcken ausgeben.

## 6. Git-/Worktree-Topologie nach Recovery

Das frühere Root-Arbeitsverzeichnis

```text
P:\DCS-DEV\Operation-Mountain-Watch
```

existiert nicht mehr.

Die gemeinsame Git-Datenbank ist jetzt bewusst als Bare-Repository getrennt:

```text
P:\DCS-DEV\Operation-Mountain-Watch.git
```

Dieses Verzeichnis ist **kein Arbeitsverzeichnis** und darf nicht als solches behandelt oder gelöscht werden, solange die Worktrees darauf basieren.

Aktive Worktrees:

```text
P:\DCS-DEV\Operation-Mountain-Watch-main
P:\DCS-DEV\Operation-Mountain-Watch-automatic-response-continuation
P:\DCS-DEV\Operation-Mountain-Watch-bagram-mq1a-lre
P:\DCS-DEV\Operation-Mountain-Watch-bagram-parking
P:\DCS-DEV\Operation-Mountain-Watch-uav-isr-request
```

Alle fünf wurden nach Recovery verifiziert mit:

```text
HEAD == Upstream
working tree clean
git-common-dir = P:/DCS-DEV/Operation-Mountain-Watch.git
```

Die alte Recovery-/Migration-Struktur wurde nach vollständiger Prüfung und ausdrücklicher Eigentümerfreigabe entfernt.

Separat erhalten bleibt lediglich:

```text
P:\DCS-DEV\RECOVERED-LOCAL-FILES\OMW_AWACS_Base.lua
SHA-256: 510C876FF132D0EC612BB6E719529836FE21B4163AB9143D9E27495A6C4D4BE3
```

Diese Datei gehört nicht zum Automatic-Response-Arbeitsauftrag und darf nicht stillschweigend in den Branch übernommen werden.

## 7. GitHub-Workflow

Die GitHub-App ist verfügbar und soll für Repository-Arbeit verwendet werden.

Verbindlicher Ablauf:

```text
Repository / Governance prüfen
-> Änderung selbst erstellen
-> vollständigen Diff prüfen
-> Syntax / verfügbare Tests prüfen
-> Dokumentation und MOOSE-first prüfen
-> selbst committen
-> selbst auf den vorgesehenen Remote-Branch veröffentlichen
-> erst danach lokale PowerShell-Verifikation anfordern
```

Der Projektinhaber führt lokal nur die tatsächlich erforderlichen Schritte aus und liefert die reale Konsolenausgabe einschließlich realer Hashes zurück.

Keine lokalen Builds, Hashes oder DCS-Runtime-Ergebnisse annehmen oder simulieren.

Kein CODEX. Keine CODEX-CLI-Übergabe.

Keine `.miz` durch ChatGPT mutieren. Mission-Editor-Integration und DCS-Test erfolgen durch den Projektinhaber.

## 8. Bereits akzeptierter Ground-RESUPPLY-Parent-Scope

Der Parent wurde über PR #135 nach `main` integriert.

```text
main merge commit:
99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
```

Akzeptierte Ground-RESUPPLY-Bausteine:

```text
Stage 1A  AMMO RESUPPLY
          ACCEPTED_TECHNICAL_BASELINE

Stage 1C  neutraler Meta-RESUPPLY über AUFTRAG:NewNOTHING
          ACCEPTED_TECHNICAL_BASELINE

Stage 1B2 one-shot FUELSUPPLY
          ACCEPTED_TECHNICAL_BASELINE
```

Der historische frühere FUELSUPPLY-Pfad bleibt nur historischer Testkontext und überschreibt Stage 1B2 nicht.

## 9. Aktueller Branchstand – Stage 1D

Auf dem Continuation-Branch wurden bisher **nur Analyse und Dokumentation**, noch keine Stage-1D-S-Produktionsimplementierung, ergänzt.

Die ursprüngliche generische Stage 1D wurde nach MOOSE-first-Review aufgeteilt:

```text
Stage 1D-S  SUPPLY
Stage 1D-P  PERSONNEL
Stage 1D-V  VEHICLE
```

Source-Review-Ergebnis:

```text
SUPPLY
-> kein spezialisierter MOOSE-Ground-Supply-AUFTRAG gefunden
-> AUFTRAG:NewNOTHING(...) ist der kleinste bereits akzeptierte MOOSE-first-konforme physische Kandidat

PERSONNEL
-> AUFTRAG:NewTROOPTRANSPORT(...) existiert
-> nur bei realer GROUP/SET_GROUP-Cargo-Repräsentation
-> kein abstrakter PERSONNEL-Headcount-Transport

VEHICLE
-> LEGION/COMMANDER:RelocateCohort(...) existiert
-> verschiebt ganze Cohorts
-> kein beliebiger VEHICLE +N-Transfer

OPSTRANSPORT:AddCargoStorage(...)
-> arbeitet mit DCS STORAGE Warehouses
-> nicht als strategische CampaignState-Authority verwenden

AUFTRAG:NewOPSTRANSPORT(...)
-> im gepinnten Moose.lua auskommentiert
-> darf nicht als verfügbare öffentliche API behauptet werden
```

## 10. Nächster technischer Arbeitspunkt

Der nächste Implementierungsschritt ist ausschließlich **Stage 1D-S / SUPPLY**:

```text
MissionDemand RESUPPLY(resource=SUPPLY)
-> CampaignState reserve / transfer
-> bestehendes Ground logistics PLATOON / convoy asset
-> AUFTRAG:NewNOTHING(destinationZone)
-> BRIGADE:AddMission(...)
-> physische Ankunft nachweisen
-> exactly-once SUPPLY settlement
-> MissionDemand SUCCESS genau einmal
-> normaler MOOSE Return-Lifecycle
-> Returned
-> Warehouse AddAsset
```

Nicht in Stage 1D-S aufnehmen:

```text
PERSONNEL
VEHICLE
TROOPTRANSPORT-Acceptance
whole-cohort relocation
DCS warehouse storage authority
OPSTRANSPORT:AddCargoStorage als strategischer Transfer
```

Vor Implementation vorhandene Stage-1A/1C/1B2-Harnesses, Runtime-Adapter und Ground-Source-Reviews prüfen und nur die kleinste notwendige Änderung erstellen.

DCS-Acceptance für Stage 1D-S muss mindestens nachweisen:

```text
exactly one physical convoy
korrekte CampaignState-Source-/Destination-Mutation
keine zweite Warehouse-Ressourcenautorität
arrival observed before settlement
settlement exactly once
MissionDemand SUCCESS exactly once
normal MOOSE return
Returned -> Warehouse AddAsset
kein spontaner zweiter Auftrag
```

## 11. Verbleibende Entwicklungsreihenfolge

Nach Stage 1D-S:

```text
Stage 1D-P  PERSONNEL design/source reconciliation
Stage 1D-V  VEHICLE design/source reconciliation
Stage 2     FOB attacked -> support demand
Stage 3     fire support -> strategic resupply closure
Stage 4     convoy attacked -> support demand
Stage 5     BLUE/CAS automatic-response adapter
Stage 6     aircraft loss -> CSAR incident / MOOSE CSAR-first execution
Stage 7     complete end-to-end automatic response chain
Stage 8     restart / restore / idempotence
Stage 9     multiplayer / performance / failure acceptance
Stage 10    production reconciliation and merge readiness
```

## 12. Startcheck für den neuen Chat

Der neue Chat soll **nicht sofort Code schreiben**. Zuerst:

```text
1. AGENTS.md auf main lesen
2. docs/00-project-governance.md auf main lesen
3. docs/26-moose-first-development-policy.md auf main lesen
4. diesen Handoff lesen
5. docs/handoffs/2026-08-29-automatic-response-orchestration-continuation.md lesen
6. docs/moose/GROUND-GENERIC-RESUPPLY-STAGE-1D-SOURCE-REVIEW.md lesen
7. aktuellen Branch / HEAD / Upstream prüfen
8. zuständige Stage-1A/1C/1B2-Implementierung und Acceptance-Artefakte auf main/Branch prüfen
9. tatsächliche gepinnte Moose.lua gegen die benötigten Methoden erneut verifizieren
10. erst danach Stage 1D-S implementieren
```

Bei Unsicherheit nicht raten, sondern die erforderliche Quelle oder DCS-Prüfung benennen.
