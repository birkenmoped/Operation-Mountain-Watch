---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-1
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Production Base package DCS acceptance scope
  - six-site Guard regression through production composition root
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 7f69d0ca532e328f67a88b2948d61bbd456a19e6
validated_in_dcs: true
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: 7f69d0ca532e328f67a88b2948d61bbd456a19e6
acceptance_mission: OMW_Template_v24_GroundWorks_base.miz
acceptance_mission_sha256: d51a38bbd352ae7e5f17a4cb4a025b4bd8f875339b97a19441ebd14d8653b1d9
dcs_version: 2.9.29.27468
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
production_builder_sha256: D12E7F545B3BE0CD425B2AC26A9998C998A7AE7E3AC5887E53DFF99F1BDC248C
production_bundle_sha256: B88935BCE655726D3E7BE10ECE2013E0A3E87761E3241F7CCED2C6BB27D7831C
acceptance_source_sha256: 7101E4A3B15441A0CDD841C3F98C7CC82A4B6E36E8615066D8A1DF16D16491B8
acceptance_builder_sha256: E43B516205E4132CC56442E9666643E014D132B46DD1EAF0D155187EAFF631B2
acceptance_bundle_sha256: 5B6E7CCECCA143CB93A5B5158EEEB53B8D6D93E382DDC1A7458FAF09A6E25EDF
---

# Production Base Acceptance 1

## Ergebnis

**PASS / ACCEPTED_TECHNICAL_BASELINE** fuer den exakt oben dokumentierten Branch-, Commit-, Missions-, Bundle-, DCS- und MOOSE-Stand.

Der reale DCS-Lauf enthielt den geforderten Abschluss:

```text
[PRODUCTION BASE][PASS] 6/6 production-package Guards recruited, routed and >=25 m movement observed
```

Die finale PASS-Telemetrie zeigte fuer alle sechs Sites `missionObserved=true`, `alive=true` und mehr als 25 m Positionsaenderung:

```text
JALALABAD_FENTY  movementM=269.1
COP_FORTRESS     movementM=219.7
FOB_JOYCE        movementM=256.7
FOB_WRIGHT       movementM=312.0
COP_HONAKER      movementM=234.0
FOB_BOSTICK      movementM=191.7
```

## Verbindliche Provenance

```text
Acceptance commit:
7f69d0ca532e328f67a88b2948d61bbd456a19e6

Mission:
OMW_Template_v24_GroundWorks_base.miz

Mission SHA-256:
d51a38bbd352ae7e5f17a4cb4a025b4bd8f875339b97a19441ebd14d8653b1d9

DCS:
2.9.29.27468

MOOSE release:
2.9.18

MOOSE commit:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

Production Builder SHA-256:
D12E7F545B3BE0CD425B2AC26A9998C998A7AE7E3AC5887E53DFF99F1BDC248C

Production Bundle SHA-256:
B88935BCE655726D3E7BE10ECE2013E0A3E87761E3241F7CCED2C6BB27D7831C

Acceptance Source SHA-256:
7101E4A3B15441A0CDD841C3F98C7CC82A4B6E36E8615066D8A1DF16D16491B8

Acceptance Builder SHA-256:
E43B516205E4132CC56442E9666643E014D132B46DD1EAF0D155187EAFF631B2

Acceptance Bundle SHA-256:
5B6E7CCECCA143CB93A5B5158EEEB53B8D6D93E382DDC1A7458FAF09A6E25EDF
```

## Technisch belegt

Dieser Acceptance-Lauf bestaetigt fuer exakt den dokumentierten Stand:

```text
Production package load               PASS
OMW.FireSupStratResupply.New()        PASS
Runtime Prepare                       PASS
6x Runtime:StartSite()                PASS
6x MOOSE Guard recruitment            PASS
6x approved Guard materialization     PASS
6x PATHLINE route start               PASS
6x Guard alive                        PASS
6x >=25 m movement                    PASS
```

## Nicht durch diesen Lauf belegt

```text
dauerhafte/endlose Guard-Patrouille   NOT TESTED / NOT REQUIRED BY THIS ACCEPTANCE
QRF                                   NOT TESTED
ARTY                                  NOT TESTED
CAS                                   NOT TESTED
Multi-Evidence Incident               NOT TESTED
Ground Resupply                       NOT TESTED
Air Resupply                          NOT TESTED
CampaignState transport settlement    NOT TESTED
```

Die bekannte Patrol-Einschraenkung aus Gate 5 bleibt unveraendert. Der Projektinhaber hat keine zweite Ausnahme fuer eigene Patrol-Loop-Logik genehmigt.

## Laufzeitbeobachtungen ausserhalb des PASS-Kriteriums

Im DCS-Log treten unter anderem folgende Meldungen auf:

```text
EVENTMETA data for event ID=61
TRANSPORT: CREATING PATH MAKES TOO LONG!!!!!
```

Sie sind nicht Bestandteil des Acceptance-1-PASS-Kriteriums und haben den dokumentierten Guard-Lauf nicht verhindert. Sie duerfen jedoch nicht als allgemein harmlos verallgemeinert werden; insbesondere Ground-Pathfinding-Meldungen muessen in spaeteren Convoy-/Resupply-Acceptances erneut bewertet werden.
