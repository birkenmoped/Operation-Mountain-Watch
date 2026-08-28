---
document_id: OMW-TEST-SHINDAND-FINAL-FOUNDATION-ACCEPTANCE
status: BINDING
document_class: MISSION_RUNTIME_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - final combined Shindand AIRWING/SQUADRON foundation runtime acceptance
  - observed AH-64D, UH-60 and CH-47 departure behavior in the documented DCS run
  - native AIRWING/AUFTRAG mission execution for the tested foundation roles
not_authoritative_for:
  - physical parking enforcement
  - validated off-field landing behavior
  - OPSTRANSPORT, COMMANDER, CSAR, MEDEVAC specialization, CampaignState or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-TEST-SHINDAND-FOUNDATION-ACCEPTANCE
superseded_by: []
source_branch: agent/shindand-heliport-parking-diagnostic
source_commit: 584ed674e1d3f642a22c96398c2ebc97b9efcb61
validated_in_dcs: true
---

# Shindand – Final Combined AIRWING/SQUADRON Foundation Acceptance

## 1. Ergebnis

Der Projektinhaber akzeptiert den finalen kombinierten Shindand-Foundation-Lauf als **PASS** und die Shindand AIRWING/SQUADRON Foundation für den dokumentierten Umfang als abgeschlossen.

Die Acceptance gilt ausschließlich für den in diesem Dokument beschriebenen Branch-, Commit-, Bundle-, DCS- und MOOSE-Stand sowie für den tatsächlich beobachteten Umfang. Der Status `BINDING` dokumentiert die ausdrückliche Projektinhaberentscheidung zur Übernahme dieser Foundation-Baseline; er ersetzt keine fehlende technische Einzelprovenienz durch Annahmen.

## 2. Artefakt- und Runtime-Provenienz

```text
Branch: agent/shindand-heliport-parking-diagnostic
Source commit: 584ed674e1d3f642a22c96398c2ebc97b9efcb61
BuilderVersion: SHND-FINAL-FOUNDATION-ACCEPTANCE-1
Bundle: OMW_AirOps_Shindand_FinalFoundationAcceptance.lua
Bundle SHA-256: 8202dfd353a854ea0a1ce7db3fcadb5bb716ae757b6ac41181dadb2cf7ecba7c
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
DCS: 2.9.28.26385 MT
DCS log SHA-256: 53d65dba5e5dc426558e430bace12403648ed16b5917fbbda1bf1629e912d250
Debrief log SHA-256: 153247efccc18c9a050b9d309ab0c3eed9f3fb15363774fc995a63e55c54ee87
Mission file reported by debrief: OMW_Template_v7_Shindand.miz
```

Ein neuer MIZ-SHA-256 wurde für diesen Lauf nicht separat ermittelt und wird deshalb nicht behauptet. Aus diesem Grund wird dieser Bericht nicht als `ACCEPTED_TECHNICAL_BASELINE` nach `OMW-GOV-DOCUMENT-METADATA` klassifiziert; die Projektinhaberentscheidung zur Foundation-Baseline bleibt davon getrennt.

## 3. Foundation-Regression

Der Lauf bestätigte die operative Foundation-Baseline:

```text
Airbase: Shindand Heliport
Airbase ID: 14
AIRWING: running
SQUADRONs: 3
Registered asset groups: 16
Represented/logical airframes: 20
Logical reserve: 0
```

Der getestete Bestand blieb damit bei:

```text
8 AH-64D
8 UH-60
4 CH-47
```

## 4. Beobachtetes Abflugverhalten

Der Projektinhaber beobachtete im DCS-Lauf:

```text
UH-60: vertical takeoff
CH-47: vertical takeoff
AH-64D: rolling/taxi departure
```

Das Rollen der AH-64D am Shindand Heliport ist ausdrücklich akzeptiert. Ein senkrechter Start vom Standplatz ist kein Foundation-Acceptance-Kriterium.

Die Runtime-Telemetrie bestätigte für alle drei Muster den normalen AIRWING/AUFTRAG-Pfad, Cold-Takeoff-Konfiguration, Vertical-Preference-Propagation, Engine-Start sowie Takeoff/Airborne. Taxi bleibt Telemetrie und ist kein PASS-Zwang.

## 5. Missionsausführung

### AH-64D

```text
Mission type: CAS
Assignment: PASS
Cold takeoff: PASS
Vertical preference propagation: PASS
Engine start: PASS
Taxi: observed
Takeoff: PASS
Airborne: PASS
Mission success: PASS
```

Der Test-Harness meldete unmittelbar vor Missionsabschluss einen Timeout. Die AH-64-CAS-Mission wechselte rund 1,5 Sekunden danach auf `success`. Dieser Harness-Grenzfall wird nicht als Funktionsfehler der Foundation gewertet.

### UH-60

```text
Mission type: LANDATCOORDINATE
Assignment: PASS
Cold takeoff: PASS
Vertical preference propagation: PASS
Engine start: PASS
Takeoff: PASS
Airborne: PASS
Mission success: PASS
Visual departure: vertical takeoff
```

### CH-47

```text
Mission type: LANDATCOORDINATE
Assignment: PASS
Cold takeoff: PASS
Vertical preference propagation: PASS
Engine start: PASS
Takeoff: PASS
Airborne: PASS
Mission success: PASS
Visual departure: vertical takeoff
```

## 6. Wichtige Acceptance-Grenze: Außenlandung

Der Projektinhaber hat im finalen Lauf **weder bei der UH-60 noch bei der CH-47 eine Außenlandung visuell beobachtet**.

Der Test-Harness registrierte für beide Missionen einen MOOSE-Missionserfolg, aber kein eigenes `LandedAt`-Telemetry-Ereignis. Daraus wird ausdrücklich **keine validierte Aussage über physische Außenlandung** abgeleitet.

Für die aktuelle Shindand AIRWING/SQUADRON Foundation ist dies kein Blocker. Die Annahme, dass spätere konkrete Transportaufträge ihre benötigte Lande-/Transportsemantik bereitstellen, ist eine Design-Erwartung und **kein DCS-validierter Nachweis dieses Tests**.

## 7. Nicht Teil dieses PASS

Nicht durch dieses Acceptance-Ergebnis validiert werden:

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

Parking war im finalen Test ausdrücklich kein Acceptance-Kriterium.

## 8. Schlussfolgerung

Für den dokumentierten Umfang ist die **Shindand AIRWING/SQUADRON Foundation abgeschlossen und als Projektbaseline übernommen**.

Bestätigt sind insbesondere die Foundation-Initialisierung, der logische 20-Airframe-Bestand, die drei SQUADRONs, native AIRWING/AUFTRAG-Zuweisung, Cold-Start und operative Abflugfähigkeit aller drei Muster sowie erfolgreiche Ausführung der im Test verwendeten Missionsarten.

Die fehlende visuelle Außenlandung von UH-60 und CH-47 bleibt eine ausdrücklich dokumentierte Geltungsgrenze und erzeugt keinen weiteren Foundation-Testlauf.
