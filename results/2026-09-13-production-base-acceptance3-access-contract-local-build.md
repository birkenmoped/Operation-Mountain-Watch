---
document_id: OMW-FSSR-PRODUCTION-BASE-A3-ACCESS-LOCAL-BUILD-20260913
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact local build provenance for corrected Acceptance 3 ACCESS contract
not_authoritative_for:
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: d63aded64cc7eb63c9f5809f5bf5451067332d3a
validated_in_dcs: false
supersedes:
superseded_by:
---

# Production Base Acceptance 3 – korrigierter lokaler Build

Owner-lokal gebaut auf exakt:

```text
d63aded64cc7eb63c9f5809f5bf5451067332d3a
```

`git rev-parse HEAD` bestätigte den Commit. Builder-Ausgabe und unabhängige `Get-FileHash -Algorithm SHA256`-Prüfungen stimmen überein.

```text
Production Builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-13

QRF Runtime:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-10

QRF Mission Factory:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-MISSION-FACTORY-5

Acceptance Builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-9
```

Hashes:

```text
Production Builder SHA-256:
7F97951ABB02CEE0B1BE841AEDB6436C22EBEA3B2831E44E21D2AF63F5DEFF6F

Production Bundle SHA-256:
7432541B6EA8906BBC6B80ECCA4A3F9E150E6BF523BA403A73C05ACC5F70DE7E

Acceptance Source SHA-256:
826BFADBEB704A3FC0A57DB26A48BB68A59E815860A7DFA7EACAF2B712C9CA33

Acceptance Builder SHA-256:
39FF498FDD679F5BE872F33A3927F9C008E2695D39891DF6032FB7033879229C

Acceptance Bundle SHA-256:
1B3C23AB249A128A9863877CCFE3E3D996EA470CA9F450A18DF8498F324C0873
```

Der aktuelle Vertrag dieses Builds ist:

```text
QRF = ONGUARD + SetEngageDetected + SetReturnToLegion(true)
QRF materialization boundary = exact site ZON_BLUE_GND_XXX_ACCESS
PATROL_TEST dependency = none
additional ME spawn zone = none
movement/perimeter/incident release authority = none
```

Pinned MOOSE:

```text
2.9.18
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256 E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

CI auf dem Build-Commit:

```text
Documentation validation #2033: PASS
MissionDemand validation #805: PASS
```

Status: `VERIFIED_LOCAL_BUILD`. Für dieses Bundle liegt noch kein DCS-Runtime-PASS vor.