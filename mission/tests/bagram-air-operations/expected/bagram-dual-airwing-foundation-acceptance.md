---
document_id: OMW-TEST-BAGRAM-DUAL-AIRWING-FOUNDATION-ACCEPTANCE
status: ACCEPTED_TECHNICAL_BASELINE
document_class: DCS_ACCEPTANCE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram dual-AIRWING foundation DCS acceptance criteria
  - exact DCS-tested Bagram dual-AIRWING foundation baseline
not_authoritative_for:
  - tactical tasking
  - parking assignment compliance
  - recovery or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - single-AIRWING Bagram foundation acceptance criteria
superseded_by: []
source_branch: agent/bagram-dual-airwing-foundation-rebuild
source_commit: 8401406c623004d04a40c8dc576df62334ba1477
validated_in_dcs: true
---

# Bagram Dual-AIRWING Foundation Acceptance

## Ergebnis

Der DCS-Lauf vom 10.08.2026 erfüllt den Foundation-Gate für den exakt dokumentierten Stand.

```text
Result: PASS
Scope: AIRWING_SQUADRON_FOUNDATION_ONLY
```

Diese Acceptance gilt ausschließlich für den unten dokumentierten Source-, Bundle-, MIZ-, DCS- und MOOSE-Stand.

## Getestete Runtime-Struktur

```text
AW_US_BGRM_455_AEW
├── SQ_US_BGRM_F15E_335_EFS
├── SQ_US_BGRM_F16C_121_EFS
├── SQ_US_BGRM_C130_774_EAS
└── SQ_US_BGRM_HH60G_83_ERQS

AW_US_BGRM_TF_FALCON_10_CAB
├── SQ_US_BGRM_UH60_A_1_169
└── SQ_US_BGRM_CH47_B_7_158
```

Beide AIRWINGs wurden an `Bagram` gebunden und aus getrennten Warehouse-Ankern gestartet:

```text
AW_US_BGRM_455_AEW           -> WH_AIR_US_BAGRAM
AW_US_BGRM_TF_FALCON_10_CAB -> WH_AIR_US_BAGRAM_ARMY
```

## Bestätigtes Accounting

```text
airwings=2
squadrons=6
registeredGroups=61
representedAirframes=73
logicalAirframes=75
logicalReserve=2
rolePayloads=7
```

Bestandsdetail:

```text
F-15E  13 logical / 12 represented / 1 reserve
F-16C  13 logical / 12 represented / 1 reserve
C-130  20 logical / 20 represented
HH-60G  6 logical /  6 represented
UH-60   10 logical / 10 represented
CH-47   13 logical / 13 represented
```

## Physische Helicopter-Seeds

Der getestete Stand verwendet entsprechend der projektweiten Seed-Regel jeweils einen physischen Mission-Editor-Seed für identische Konfigurationen:

```text
TPL_AIR_US_BGRM_HH60G_CSAR_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
```

Separate `CSAR_LEAD`, `CSAR_COVER` oder `UH60_TRANSPORT`-Template-Dubletten sind für diesen Foundation-Stand nicht erforderlich.

## Foundation-Sicherheitsgate

Der Runtime-Marker bestätigt:

```text
usafRunning=true
armyRunning=true
missionsCreated=0
transportsCreated=0
commanderCreated=false
f10Controls=false
```

Damit wurden im akzeptierten Foundation-Lauf keine taktischen Missionen, Transporte, COMMANDER-Instanzen oder F10-Teststeuerungen erzeugt.

## Exakte Provenienz

```text
OMW branch:
agent/bagram-dual-airwing-foundation-rebuild

OMW source commit:
8401406c623004d04a40c8dc576df62334ba1477

Builder:
BGRAM-AIR-OPS-DUAL-FOUNDATION-2

Generated / embedded Bagram bundle SHA-256:
75a51c3dbfa9e7492d0dd7d420218f07f88c558f427c126a6a8a2fa093852d7e

DCS-tested mission source name:
OMW_Template_v6_Tarinkot.miz

Uploaded evidence copy:
OMW_Template_v6_Tarinkot(9).miz

Uploaded MIZ SHA-256:
228a6053e5edb8c48603d2a4e57d55be2b97f2fda6ad2580be5db9c5b35379b4

Embedded mission SHA-256:
982c9c417981ce8a554761747fb0a6f9c609a256bc522a59c2883e60c5c7306d

DCS version:
2.9.28.26385

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Embedded Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915

DCS log SHA-256:
cd62517f66b5f1fa9749353d690f33046aa7dedcd6ea042d46aa5b96c3265247

Debrief log SHA-256:
c11451461f40ffa1b87ce79311c8b9d83c0fb8065a3bbda5fd989f0bf6c7f6e7
```

## Finaler RESULT-Marker

```text
RESULT status=RUNNING airwings=2 squadrons=6 registeredGroups=61 representedAirframes=73 logicalAirframes=75 logicalReserve=2 rolePayloads=7 usafRunning=true armyRunning=true missionsCreated=0 transportsCreated=0 commanderCreated=false f10Controls=false
```

## Unabhängige Laufzeitmeldungen

Im DCS-Log treten weitere Engine-, Modul-, Texture-, CH-47-/OH-58- und Saved-Games-Hook-Meldungen auf. Der bekannte Shutdown-Fehler

```text
bhHook.lua:168: attempt to index upvalue 'tcp' (a nil value)
```

tritt erst beim `Dispatcher Stop` auf und stammt aus dem externen Saved-Games-Hook. Er ist kein Fehler des Bagram-Foundation-Bundles und ändert den oben erreichten Bagram-RESULT-Marker nicht.

## Nicht validiert

Diese Acceptance validiert ausdrücklich nicht:

- taktische CAS-/STRIKE-Ausführung;
- C-130-Transportausführung;
- CSAR-Ausführung;
- Helicopter Cargo-/Troop-Transportausführung;
- Parking-Zuweisungen oder Client-Space-Compliance;
- Recovery/RTB;
- Post-Landing-Despawn/Return;
- Loss Accounting;
- CampaignState-Persistenz;
- Multiplayer-Endurance.
