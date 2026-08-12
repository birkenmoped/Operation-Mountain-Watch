---
document_id: OMW-TEST-STORAGE-FORCED-LANDING-RECOVERY-V1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - forced-landing/recovery V1 runtime classification gate
  - client off-field landing observation across the 5 km recovery envelope
  - pure recovery-delay and repair-lock policy verification
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/storage-forced-landing-recovery-v1
source_commit: 76998ae9c802c915d099a30207ec902dd54f1edc
validated_in_dcs: true
base_branch: agent/storage-resource-integration-final
base_commit: aec92c3574d338dba16aa0d615879e7de74e7f44
merged_to_main: false
---

# Forced Landing / Recovery V1 Gate

## 1. Zweck

Dieser Gate validiert die nach den bereits akzeptierten Warehouse-/STORAGE-Grundlagen offene Runtime-Frage: Erkennen die vorhandenen MOOSE-/DCS-Land- und Engine-Shutdown-Signale einen unerwarteten Client-Off-field-Landing-Fall so, dass die OMW-Recovery-Policy ihn innerhalb des 5-km-Recovery-Envelope als `RECOVERABLE_FORCED_LANDING` und außerhalb als `OFF_FIELD_UNRECOVERABLE` klassifiziert?

Nicht erneut getestet werden Materialisierung, normaler Return, Client-Rearm, Client-Refuel oder physischer Totalverlust.

## 2. MOOSE-First-Grenze

Der Observer verwendet öffentliche MOOSE-Pfade für Event-, Unit-, Airbase- und Coordinate-Beobachtung. Für AIRWING-AI-Flüge bleiben die source-reviewed FLIGHTGROUP-Pfade maßgeblich; der Observer implementiert keinen eigenen Return-Controller.

Für Clients wird ein eigener read-only `TrackClientGroup()`-Pfad verwendet, weil Clients nicht über den produktiven AIRWING-Asset-Lifecycle laufen.

Der erste Runtime-Lauf zeigte eine wichtige DCS/MOOSE-Grenze: `PlaceName == Shindand Heliport` ist kein ausreichender Nachweis für einen physischen Return zum Parking. Ein absichtlich off-field gelandeter Client wurde bei 2223,6 m Entfernung noch mit `place=Shindand Heliport` gemeldet.

Die Branch-Implementierung enthält deshalb zusätzlich eine read-only Parking-Korrektur auf Basis der in MOOSE vorhandenen Parking-Semantik (`AIRBASE:GetParkingSpotsTable()` / Distanzprüfung; 5-m-Grenze entsprechend `FLIGHTGROUP:GetParkingSpot(...)`). Diese Korrektur wurde nach dem ersten Fehlversuch implementiert, war aber nicht Bestandteil der vom Projektinhaber für die finale Acceptance verwendeten Gate-1-Mission. Die Acceptance unten gilt daher für die ausdrücklich dokumentierte Forced-Landing-/Recovery-Klassifikation und die beobachtete 5-km-Grenze; sie stellt keinen separaten DCS-Nachweis der späteren Parking-Korrektur dar.

## 3. Bindende Policy

```text
Recovery envelope: 5000 m
Recovery delay: 1800 s
Repair lock: 21600 s
Low fuel <= 5%: supporting evidence only, not sole trigger
```

Der Gate prüft die 30-Minuten-/6-Stunden-Zustandsübergänge deterministisch mit synthetischen Zeitwerten. Es ist kein realer 30-Minuten-Warteversuch erforderlich.

## 4. Runtime-Fall

Mission-Editor-Gruppe:

```text
CLIENT_US_SHND_AH64D_01
```

Recovery Node:

```text
Shindand Heliport
```

## 5. Runtime-Evidenz

### Versuch 1 – verwertbarer FAIL / PlaceName-Grenze

```text
DCS: 2.9.28.26385 MT
Client: CLIENT_US_SHND_AH64D_01
place=Shindand Heliport
distanceM=2223.6182540257
classification=NORMAL_EXPECTED_RETURN
RESULT status=FAIL reason=CLASSIFICATION
```

Dieser Lauf widerlegte die Annahme, dass `PlaceName` allein einen echten Return zum Heliport beweist. Land und EngineShutdown wurden beobachtet; falsch war die damalige OMW-Client-Return-Annahme.

Log-Provenienz:

```text
dcs.log SHA-256:     d33f7c46089a7284396272450c9de74c6bdb3cea010a9d2e4a71dfc1e31b2fae
debrief.log SHA-256: 9fda0649ae354b093b221cd8c6d541d8a034f80a179bc659ba3dd6a9155739f7
```

### Versuch 2 – außerhalb des Recovery-Envelope

Mit derselben Gate-1-Grundlage wurde ein unerwarteter Off-field-Landing-Fall außerhalb der Recovery-Grenze beobachtet:

```text
expectedReturn=false
recoveryCapable=true
distanceM=5432.5138283616
classification=OFF_FIELD_UNRECOVERABLE
RESULT status=FAIL reason=CLASSIFICATION
```

Der Harness erwartete für seinen positiven Gate-Fall `RECOVERABLE_FORCED_LANDING`; fachlich bestätigt dieser Lauf jedoch die Gegenseite der 5-km-Policy: >5000 m wird als `OFF_FIELD_UNRECOVERABLE` klassifiziert.

### Versuch 3 – innerhalb des Recovery-Envelope / PASS

Vom Projektinhaber als erfolgreiche Acceptance gewertet:

```text
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v8_AirOps_rdy.miz
Client: CLIENT_US_SHND_AH64D_01
place=nil
expectedReturn=false
recoveryCapable=true
distanceM=4782.4415407502
classification=RECOVERABLE_FORCED_LANDING
RECOVERABLE_RUNTIME_PASS distanceM=4782.442
RESULT status=PASS campaignStateMutation=false storageMutation=false physicalMutation=false csar=false
```

Provenienz der vom Projektinhaber hochgeladenen Mission und Logs:

```text
MIZ SHA-256: dbe72aa0627b01e25491d89418a24bfb4a07a6228a2613d4332fee41bfe1eb1a
internal mission SHA-256: b5fcab7d428811f97c06beea2355a213608fdbc8788073ae618556edd94305e3
embedded Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
embedded Gate SHA-256: 0b99504ca01c6e543d82c022fa41fa3940e65413da9dfa43d10a94048ef9eabc
embedded BuilderVersion: FORCED-LANDING-RECOVERY-V1-GATE-1
embedded GitCommit: 76998ae9c802c915d099a30207ec902dd54f1edc
dcs.log SHA-256: 5598b58bc22ecc6cdb30d2a59dfeea2027cc290e0b0b0b5d24850dcc6cb58c11
debrief.log SHA-256: 7ba77812600f3b7737ba0d4e5fe10ffa7785f1519d369b0d6fb7a887fd8afe3c
```

## 6. Acceptance-Entscheidung

Der Projektinhaber hat am 13.08.2026 ausdrücklich entschieden, die Forced-Landing-/Recovery-V1-Testreihe als erfolgreich abgenommen zu werten. Grundlage sind die mehreren realen DCS-Läufe mit Gate 1, insbesondere:

```text
4782.44 m < 5000 m -> RECOVERABLE_FORCED_LANDING -> PASS
5432.51 m > 5000 m -> OFF_FIELD_UNRECOVERABLE
```

Die Acceptance umfasst damit die Runtime-Erkennung von Land/EngineShutdown, die 5-km-Recovery-Klassifikation und die deterministisch geprüften 30-min-/6-h-Policyzeiten für diesen dokumentierten Stand.

Nicht als separat DCS-validiert gilt die nach Versuch 1 implementierte Parking-Korrektur des späteren Gate-2-Standes. Diese Einschränkung bleibt dokumentiert und darf nicht nachträglich als eigener Runtime-Nachweis interpretiert werden.

## 7. Grenzen

Der Gate mutiert weder CampaignState noch STORAGE und entfernt oder zerstört kein Aircraft. Er aktiviert keine automatische Recovery-Gutschrift und keinen produktiven Repair-Timer im CampaignState. CSAR ist ausdrücklich außerhalb dieses Testzyklus.

Die strategische Settlement-Integration für verbleibenden Fuel/Stores und Aircraft-Repair-Lock ist ein separater Produktionsschritt.
