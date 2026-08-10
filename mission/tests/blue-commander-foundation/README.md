---
document_id: OMW-TEST-BLUE-COMMANDER-FOUNDATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - central BLUE COMMANDER foundation test layout
  - combined BLUE AIRWING registration acceptance criteria
not_authoritative_for:
  - resource ownership contract
  - automatic mission generation
  - tactical mission acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/blue-commander-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# BLUE COMMANDER Foundation Test

## Scope

Der Test prüft ausschließlich, ob die auf `main` vorhandenen produktiven BLUE-AIRWING-Foundations in einer zentralen MOOSE-`COMMANDER`-Instanz registriert werden und der COMMANDER startet.

```text
CampaignState
= Strategie und Ressourcenhoheit

Mission Coordinator / Adapter
= CampaignState -> AUFTRAG

MOOSE COMMANDER
= operative Auswahl geeigneter Legion/AIRWING

AIRWING/SQUADRON
= physische Luftfahrzeugbereitstellung
```

Die Foundation erzeugt keine AUFTRAG- oder OPSTRANSPORT-Instanzen und mutiert keinen CampaignState.

## Erwarteter AIRWING-Bestand

```text
Bagram USAF
Bagram Army Aviation
Jalalabad
Kandahar Main
Kandahar Heliport
Salerno
Shindand Heliport
Tarinkot
```

Erwartet: `8` registrierte AIRWINGs. Fehlende oder nicht laufende Foundations werden mit stabiler Registry-ID protokolliert und nicht stillschweigend registriert.

## Build

```powershell
.\tools\build-blue-commander-foundation.ps1
```

Generated bundle:

```text
mission\tests\blue-commander-foundation\dist\OMW_Blue_Commander_Foundation.lua
```

## MOOSE pin

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## DCS Acceptance

PASS erfordert für den exakt dokumentierten Branch-/Commit-/MIZ-/Bundle-/DCS-/MOOSE-Stand:

```text
BLUE Commander: Running / OnDuty
expected AIRWINGs: 8
registered AIRWINGs: 8
skipped AIRWINGs: 0
all registered AIRWINGs remain Running
generated missions: 0
generated transports: 0
unexpected spawns: 0
CampaignState mutation: false
```

Erst nach realem DCS-Test werden MIZ-, Bundle-, Moose.lua-, Log- und gegebenenfalls Debrief-Hashes sowie die DCS-Version eingetragen. Bis dahin bleibt `validated_in_dcs: false`.
