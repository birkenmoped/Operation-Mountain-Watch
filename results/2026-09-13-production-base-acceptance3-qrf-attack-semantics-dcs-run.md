---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE3-QRF-ATTACK-SEMANTICS-DCS-RUN-2026-09-13
status: DIAGNOSTIC_FAIL
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: a2eb177ff7038befceeb55275bbb7c4aac25c1ff
validated_in_dcs: false
---

# Production Base Acceptance 3 – QRF attack-semantics DCS run, 2026-09-13

## Provenance

Owner-verified build used for this DCS run:

```text
GitCommit: a2eb177ff7038befceeb55275bbb7c4aac25c1ff
ProductionBundleSHA256: C1A31887538D8E35DBAEA31E206354AD5B76A9DBBA5763A5A384F234D1927943
AcceptanceBundleSHA256: 471C9065A6E278E28CFE31D5499808BAE51BD033C466ECD12910EFFD791907BD
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27468 MT
```

Owner observation: motorized QRF groups materialized at several sites but did not attack the intruding RED groups. Screenshots showed QRF groups stationary or otherwise not executing an attack against the visible hostile fixture.

## Runtime evidence

The ACCESS materialization correction is runtime-observed for at least:

```text
FOB_JOYCE   -> ZON_BLUE_GND_JOYCE_ACCESS inside=true
FOB_WRIGHT  -> ZON_BLUE_GND_WRIGHT_ACCESS inside=true
JALALABAD   -> ZON_BLUE_GND_FENTY_ACCESS inside=true
```

Jalalabad also logged the expected six-vehicle road-aligned materialization with fixed 18 m spacing.

However, the same run still had separate ACCESS-materialization failures for other sites, including Honaker (`road spawn position outside access zone`) and Fortress (`outbound road path too short`). At the final telemetry interval Fortress, Honaker and Bostick had incidents and one QRF demand each but no observed physical QRF. Therefore this run is a hard Acceptance FAIL independently of the attack-semantics defect.

## Root cause of spawned QRF groups not attacking

The QRF mission factory in the tested build created:

```lua
AUFTRAG:NewONGUARD(coordinate)
```

The coordinate supplied by the installation-incident path represented the installation/alarm anchor. `ONGUARD` is a guard-at-coordinate mission. It is not an attack task against the hostile group that caused the incident. The fact that `ONGUARD` uses an open-fire ROE does not convert it into an attack mission; the QRF had no physical hostile target bound to its AUFTRAG.

The old Acceptance telemetry also measured QRF progress toward the installation anchor, so positive `qrfProgressM` at Joyce/Wright proved movement toward that anchor, not movement toward or attack of the RED fixture.

## Pinned-MOOSE correction

The pinned MOOSE source provides the public ground mission:

```lua
AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)
```

For this mission type the physical target is a MOOSE GROUP/UNIT/STATIC. The pinned MOOSE OPSZONE also exposes the scanned group set, and MOOSE's own zone-capture logic uses `OPSZONE:GetScannedGroupSet():GetClosestGroup(...)` to resolve a physical hostile group before engaging it.

The correction therefore keeps MOOSE operational authority:

```text
MOOSE OPSZONE hostile scan
-> physical hostile GROUP selected from OPSZONE scanned group set
-> PROXIMITY_INTRUSION evidence carries transient physical target identity
-> authoritative installation incident
-> one initial local QRF demand
-> MOOSE AUFTRAG:NewGROUNDATTACK(hostile GROUP)
-> MOOSE LEGION/BRIGADE recruitment
-> accepted ACCESS road materialization
-> MOOSE ground-attack execution
```

The MOOSE GROUP reference is transient runtime context only. It is not CampaignState data and creates no second strategic/resource authority.

## Follow-up implementation

Follow-up commits after this run replace QRF `ONGUARD` with `GROUNDATTACK`, bind the OPSZONE-qualified physical hostile GROUP into the transient incident context, and harden Acceptance 3 so it requires:

```text
QRF materialized inside the site ACCESS zone
QRF AUFTRAG type == GROUNDATTACK
QRF target == the site's BadGuys_A3_* fixture
QRF closes at least 25 m toward that physical hostile target
```

The build carrying these changes has not yet been locally built or DCS-validated.

## Status

```text
Jalalabad runtime alarm radius 8000 ft: observed through runtime perimeter configuration path; full acceptance still open
ACCESS materialization at Joyce/Wright/Jalalabad: runtime observed
Spawned QRF attack execution: FAILED – wrong ONGUARD mission semantics
Fortress/Honaker/Bostick materialization: INCOMPLETE / errors observed
Acceptance 3: DIAGNOSTIC FAIL
Corrected GROUNDATTACK build: PENDING LOCAL BUILD
Corrected DCS validation: PENDING
```
