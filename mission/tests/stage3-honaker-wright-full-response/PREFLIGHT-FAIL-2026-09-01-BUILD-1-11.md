---
document_id: OMW-TEST-STAGE3-BUILD-1-11-PREFLIGHT-FAIL-2026-09-01
status: RECORDED_FAIL
document_class: TEST_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - real local PowerShell preflight/build failure before Stage 3 build 1-11 DCS execution
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
validated_in_dcs: false
---

# Stage 3 Build 1-11 – Local Preflight FAIL 2026-09-01

## 1. Ergebnis

Der erste reale lokale Buildversuch des geplanten Stage-3-Builds `1-11` wurde **vor Erzeugung eines neuen Stage-3-Bundles** durch ein fehlerhaftes statisches Builder-Gate abgebrochen.

Dies ist **kein DCS-Test** und kein Runtime-Fail der Stage-3-Lua-Logik.

## 2. Reale lokale Provenienz

Vom Projektinhaber gemeldeter lokaler Worktree:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

Branch nach `fetch/switch/pull --ff-only`:

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

Realer lokaler HEAD beim fehlgeschlagenen Buildversuch:

```text
a2f6cf3d2de6922999cde21e825d69d5a71d2ae7
```

`git status --short` vor und nach dem Versuch enthielt ausschließlich untracked `dist/`-Verzeichnisse:

```text
?? mission/tests/air-ammo-resupply/dist/
?? mission/tests/jalalabad-air-operations/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Es wurden keine tracked Dateien lokal verändert.

## 3. Jalalabad-AirOps-Build

Der Jalalabad-Foundation-Build lief auf diesem HEAD durch:

```text
BuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-3
GitCommit: a2f6cf3d2de6922999cde21e825d69d5a71d2ae7
SHA256: 557E49B3119758700E6F82467684ACED0C1D475E50C9E0C1E301D9C8F4DC2EFA
```

Die Builder-Telemetrie meldete dabei noch:

```text
AH64DCapabilities: CAS,CASENHANCED
```

obwohl der tatsächliche Bootstrap-Source bereits `AUFTRAG.Type.PATROLZONE` sowohl in der AH-64D-SQUADRON-Capability als auch im Payload enthielt.

Das war eine **veraltete Builder-Telemetrie/Header-Angabe**, nicht ein fehlendes `PATROLZONE` im Bootstrap-Source.

Korrektur nach dem realen Buildversuch:

```text
BuilderVersion -> JBAD-AIR-OPS-FOUNDATION-ONLY-4
required marker -> AUFTRAG.Type.PATROLZONE
reported/header capabilities -> CAS,CASENHANCED,PATROLZONE
```

## 4. Stage-3-Buildabbruch

Der reale Stage-3-Build wurde mit folgender Meldung abgebrochen:

```text
Stage 3 full-response sources missing marker: GROUP:Activate
```

Der Builder erwartete den Literalstring:

```text
GROUP:Activate
```

Der tatsächliche Acceptance-Source verwendet jedoch den konkreten MOOSE-GROUP-Aufruf:

```lua
state.guardGroup:Activate()
```

Die Guard-Implementierung war damit vorhanden; das statische Gate prüfte lediglich auf einen falschen Literalmarker.

Korrektur nach dem realen Buildversuch:

```text
GROUP:Activate
-> state.guardGroup:Activate()
```

Der Builderstand bleibt `STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-11`, weil vor dieser Gate-Korrektur **kein neues Build-1-11-Bundle erzeugt wurde**. Die Korrektur ändert nicht den generierten Stage-3-Runtime-Source, sondern ausschließlich das fehlerhafte Preflight-Gate.

## 5. Wichtige Hash-Grenze

Nach dem Builder-Abbruch zeigte `Get-FileHash` für:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

weiterhin:

```text
C42D5967DB56D2FD5CE2D881395A73BD2ABC61F2320596C24F1C3175E8B6DCD3
```

Dieser Hash gehört zum **vorhandenen älteren Build-1-10-Artefakt** und darf ausdrücklich **nicht** als Build-1-11-Hash verwendet werden, da der neue Builder vor `WriteAllText()` abbrach.

Der reale Acceptance-Dokumenthash beim Versuch war:

```text
BE0C639AC7D63EA00FF21A887CB956B52D33832113C8A6CB1A9BD25AD5D68BAF
```

## 6. Nachfolgende Remote-Korrekturen

Nach Analyse der realen Ausgabe wurden auf demselben Arbeitsbranch veröffentlicht:

```text
04b38f16ca0f3d6f4ce0b46936ea87d3027f54c6
  Align Jalalabad builder telemetry with PATROLZONE capability

763be9956833ca6493ea02afe6c333b34458803b
  Fix Stage 3 builder Guard activation marker
```

Vor dem nächsten Mission-Editor-/DCS-Schritt ist ein neuer lokaler Pull und ein erneuter realer Build erforderlich.

## 7. Status

```text
Jalalabad source PATROLZONE capability   SOURCE CONFIRMED
Jalalabad builder v3 telemetry           FAIL / STALE
Jalalabad builder v4 correction          REMOTE COMMITTED / LOCAL BUILD PENDING
Stage-3 source Guard activation          SOURCE CONFIRMED
Stage-3 build 1-11 first local attempt   FAIL AT STATIC GATE
New Stage-3 1-11 bundle                  NOT CREATED
New Stage-3 1-11 SHA-256                 UNKNOWN / PENDING REAL BUILD
DCS validation                           NOT STARTED
validated_in_dcs                         false
```
