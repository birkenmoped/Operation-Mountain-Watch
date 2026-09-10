---
document_id: OMW-STAGE3-CAS-RESUPPLY-FOCUS-1-8-STALE-FOUNDATION
status: REJECTED
document_class: DCS_ACCEPTANCE_EVIDENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Focus-1-8 rejection reason
  - stale Jalalabad foundation evidence in OMW_Template_v22_GroundWorks.miz
  - required preflight before the next focused DCS run
not_authoritative_for:
  - production Stage 3 acceptance
  - repository-wide architecture before merge
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: GIT_HISTORY
validated_in_dcs: false
supersedes:
superseded_by:
---

# Focus 1-8 – stale Jalalabad foundation evidence

## Ergebnis

Der Focus-1-8-Lauf wird als `REJECTED_TEST_FIXTURE` behandelt. Er erreichte den eigentlichen CH-47-OPSTRANSPORT-Lifecycle nicht.

Der Lauf meldete für den Jalalabad-CH-47 über alle sechs Recruitment-Versuche:

```text
cohortState=OnDuty
onDuty=true
capability=false
stock=0
payloads=0
unitType=CH-47Fbl1
```

Damit war ein weiterer Retry keine tragfähige Fehlerbehebung.

## Nachgewiesene Ursache

Die tatsächlich getestete Mission war:

```text
OMW_Template_v22_GroundWorks.miz
```

Aus der real verwendeten Mission wurde das eingebettete Foundation-Bundle read-only geprüft:

```text
l10n/DEFAULT/OMW_AirOps_Jalalabad.lua
SHA256: E70443B6363D576BCDA55CF7EE87266BA413546AB5840CF002ACEC2E0023C468
BuilderVersion: JBAD-AIR-OPS-FOUNDATION-ONLY-4
GitCommit: 8c543826f63d7cb436c8cddfac3feb029bcdce96
AUFTRAG.Type.OPSTRANSPORT occurrences: 0
```

Der eingebettete CH-47-Vertrag enthielt nur:

```text
TROOPTRANSPORT
CARGOTRANSPORT
LANDATCOORDINATE
```

Der aktuelle Repository-Source `scripts/air-operations/OMW_AirOps_Jalalabad_Bootstrap.lua` enthält dagegen für CH-47 sowohl in der SQUADRON-Mission-Capability als auch im Payload ausdrücklich:

```text
AUFTRAG.Type.OPSTRANSPORT
```

Damit ist die Root Cause des Focus-1-8-Laufs:

```text
STALE_EMBEDDED_JALALABAD_FOUNDATION
```

Nicht MOOSE-Startup-Timing, nicht fehlender CH-47-Bestand und nicht der R200-FlightPath verhinderten das Recruitment. Die Acceptance lief gegen eine ältere, in der `.miz` eingebettete Jalalabad-Foundation ohne OPSTRANSPORT-Capability.

## Verhinderung eines vierten Blindtests

Vor dem nächsten DCS-Lauf müssen zwei getrennte Artefakte neu gebaut und in der Mission aktuell eingebettet sein:

```text
mission/tests/jalalabad-air-operations/dist/OMW_AirOps_Jalalabad.lua
mission/tests/stage3-cas-resupply-focused/dist/OMW_Stage3_CAS_Resupply_Focused_Acceptance_1.lua
```

Der Jalalabad-Builder wurde auf `JBAD-AIR-OPS-FOUNDATION-ONLY-5` angehoben und prüft `AUFTRAG.Type.OPSTRANSPORT` als erforderlichen Foundation-Marker.

Zusätzlich prüft vor jedem weiteren DCS-Lauf read-only:

```text
tools/verify-stage3-cas-resupply-focused-miz.ps1
```

Der Preflight verlangt:

```text
embedded Jalalabad foundation == aktuell lokal gebautes Foundation-Bundle
embedded focused acceptance == aktuell lokal gebautes Acceptance-Bundle
embedded Moose.lua SHA256 == gepinnter MOOSE-Hash
embedded Jalalabad foundation contains AUFTRAG.Type.OPSTRANSPORT
embedded Jalalabad foundation BuilderVersion == JBAD-AIR-OPS-FOUNDATION-ONLY-5
```

Er verändert die `.miz` nicht.

Bis dieser Preflight `PASS` liefert, wird **kein weiterer DCS-Acceptance-Lauf** als sinnvoller nächster Schritt angesetzt.

## Status

```text
Focus 1-8: REJECTED_TEST_FIXTURE
R200 route selection: DCS observed
Jalalabad CH-47 physical inventory creation: DCS observed
Focus 1-8 OPSTRANSPORT carrier recruitment: BLOCKED_BY_STALE_EMBEDDED_FOUNDATION
OPSTRANSPORT execution/delivery/return: NOT TESTED IN FOCUS 1-8
full Stage 3: NOT VALIDATED
```
