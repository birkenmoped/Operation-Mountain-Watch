---
document_id: OMW-TEST-SHINDAND-HELIPORT-PARKING-MAP
status: BINDING
document_class: MISSION_RUNTIME_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Shindand Heliport parking mapping and diagnostic evidence
  - owner-defined Shindand Heliport parking allocation baseline
  - completed Shindand AIRWING/SQUADRON foundation scope and test index
not_authoritative_for:
  - project-wide active Shindand ORBAT beyond the documented owner decision
  - physical type-specific parking enforcement
  - validated off-field landing behavior
  - COMMANDER, OPSTRANSPORT, CSAR/MEDEVAC specialization, CampaignState or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: PENDING_MERGE
validated_in_dcs: partial
supersedes: []
superseded_by: []
---

# Shindand Heliport – AIRWING/SQUADRON Foundation und Testindex

## 1. Aktueller Projektstand

Der Projektinhaber hat die **Shindand AIRWING/SQUADRON Foundation** fuer den hier dokumentierten Umfang als abgeschlossen und zur Uebernahme nach `main` freigegeben.

Operativer Knoten:

```text
Shindand Heliport
DCS/MOOSE Airbase ID: 14
Warehouse: WH_AIR_US_SHINDAND_HELIPORT
AIRWING: AW_US_SHINDAND
```

Logischer aktiver OMW-Bestand:

```text
8 AH-64D
8 UH-60
4 CH-47
```

Foundation-Vertrag:

```text
SQ_US_SHND_AH64D_ATTACK
  4 Assetgruppen x 2 = 8 AH-64D

SQ_US_SHND_UH60_UTILITY_MEDEVAC
  8 Assetgruppen x 1 = 8 UH-60

SQ_US_SHND_CH47_HEAVYLIFT
  4 Assetgruppen x 1 = 4 CH-47

Total: 16 Assetgruppen / 20 Luftfahrzeuge
```

Produktionsquelle:

```text
scripts/air-operations/OMW_AirOps_Shindand_Bootstrap.lua
```

Der Produktionspfad bleibt MOOSE-first und verwendet AIRWING, SQUADRON, WAREHOUSE und AUFTRAG. Es wurde kein MOOSE-Override, kein Native-DCS-Spawnpfad und keine parallele Ressourcenhoheit eingefuehrt.

## 2. Finaler Foundation-PASS

Massgeblicher Abschlussbericht:

- [`OMW-TEST-SHINDAND-FINAL-FOUNDATION-ACCEPTANCE`](expected/shindand-final-foundation-acceptance-pass.md)

Finaler Teststand:

```text
Source commit: 584ed674e1d3f642a22c96398c2ebc97b9efcb61
BuilderVersion: SHND-FINAL-FOUNDATION-ACCEPTANCE-1
Bundle SHA-256: 8202dfd353a854ea0a1ce7db3fcadb5bb716ae757b6ac41181dadb2cf7ecba7c
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS log SHA-256: 53d65dba5e5dc426558e430bace12403648ed16b5917fbbda1bf1629e912d250
Debrief log SHA-256: 153247efccc18c9a050b9d309ab0c3eed9f3fb15363774fc995a63e55c54ee87
```

Beobachtet und akzeptiert:

```text
Foundation initialization: PASS
AIRWING Running: PASS
3 SQUADRONs: PASS
16 Assetgruppen / 20 Airframes: PASS
AH-64D CAS dispatch and mission success: PASS
UH-60 LANDATCOORDINATE mission success: PASS
CH-47 LANDATCOORDINATE mission success: PASS
Cold takeoff configuration: PASS for all three
Takeoff/Airborne: PASS for all three
UH-60 visual departure: vertical takeoff
CH-47 visual departure: vertical takeoff
AH-64D visual departure: rolling/taxi departure, accepted
```

Der AH-64-CAS-Erfolg trat rund 1,5 Sekunden nach dem Test-Harness-Timeout ein. Der Projektinhaber bewertet dies als Harness-Grenzfall und nicht als Foundation-Fehler.

## 3. Acceptance-Grenzen

Nicht als Foundation-PASS behauptet werden:

```text
physical type-specific parking enforcement
off-field landing behavior
transport loading/unloading semantics
OPSTRANSPORT
COMMANDER
CSAR/MEDEVAC specialization
CampaignState integration
persistence
```

Insbesondere wurde bei UH-60 und CH-47 **keine physische Aussenlandung visuell beobachtet**. MOOSE meldete die verwendeten `LANDATCOORDINATE`-Missionen als erfolgreich; daraus wird kein Aussenlande-Nachweis abgeleitet.

Parking ist fuer die abgeschlossene Shindand AIRWING/SQUADRON Foundation kein Acceptance-Kriterium.

## 4. Parking-Mapping und Owner-Baseline

Der read-only Mappingtest bestaetigte 42 MOOSE-Parking-Spots am Shindand Heliport und 38 akzeptierte Mission-Editor-Zuordnungen. Der doppelte ME-Eintrag `34` ist technisch aufgeloest:

```text
ME 34  -> MOOSE TerminalID 20
ME 34a -> MOOSE TerminalID 19
```

Die Diagnoseanker `ME 46-52` liegen ausserhalb der bestaetigten Heliport-Parking-Domain. Es wird keine andere Airbase-Zuordnung behauptet.

Owner-definierte typgebundene Konfigurationspools:

```text
AH-64D: ME 01,02,05,07     -> TerminalID 21,3,34,15
UH-60:  ME 29,30,31,34,34a -> TerminalID 41,18,13,20,19
CH-47:  ME 41,39,37        -> TerminalID 30,10,23
```

Allgemeiner freier Pool:

```text
ME 11-19 und ME 20-27
TerminalIDs: 0,16,24,33,14,25,42,27,22,39,38,5,29,11,26,40,9
```

Diese Listen bleiben Konfigurations-/Allocation-Baseline. Die Diagnosephase zeigte, dass der gepinnte MOOSE-HELIPAD-Spawnpfad die physische typgebundene Platzierung nicht garantiert.

## 5. Historische Diagnoseevidenz

Die Parking-Experimente bleiben als historische Testfixtures erhalten und sind **keine offenen Foundation-Gates**:

- [`OMW-TEST-SHINDAND-G2-AH64-DISPATCH-FAIL`](expected/shindand-g2-ah64-dispatch-fail.md)
- [`OMW-TEST-SHINDAND-G2-HELIPAD-SPAWN-ROOT-CAUSE`](expected/shindand-g2-helipad-spawn-root-cause.md)
- [`OMW-TEST-SHINDAND-G3-AH64-CONTROLLED-PARKING-FAIL`](expected/shindand-g3-ah64-controlled-parking-fail.md)
- weitere G4-G6-Testquellen unter `src/` als Entwicklungs- und Diagnoseartefakte

Der fruehere Idle-Foundation-Lauf bleibt ebenfalls als historische Testevidenz erhalten:

- [`OMW-TEST-SHINDAND-FOUNDATION-ACCEPTANCE`](expected/shindand-foundation-acceptance.md)

## 6. Aktive Produktionsgrenze

Nach Integration nach `main` gilt fuer Shindand AIRWING/SQUADRON:

```text
Foundation: COMPLETE
Production AIRWING/SQUADRON source: scripts/air-operations/OMW_AirOps_Shindand_Bootstrap.lua
Parking diagnostics: CLOSED as Foundation blocker
Further DCS foundation tests: none planned
```

Spaetere Transport-, Recovery-, COMMANDER-, OPSTRANSPORT-, CSAR-/MEDEVAC-, CampaignState- oder Persistenzarbeit ist ein eigener Funktions-/Integrationsschritt und erweitert nicht rueckwirkend den Umfang dieses Foundation-PASS.
