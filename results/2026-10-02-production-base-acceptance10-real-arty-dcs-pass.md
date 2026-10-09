---
document_id: OMW-RESULT-FSSR-PRODUCTION-BASE-A10-REAL-ARTY-DCS-PASS-20261002
status: ACCEPTED_TECHNICAL_BASELINE
document_class: ACCEPTANCE_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact-provenance DCS evidence for Production Base Acceptance 10
  - real fixed ARTY/Mortar MOOSE materialization
  - MOOSE COMMANDER real-asset selection-only recruitment
  - Functional ARTY and M1083 rearm regression result
not_authoritative_for:
  - repository-wide authority before merge
  - concurrent multi-demand orchestration
  - Strategic Resupply physical lifecycle
  - mortar firing beyond materialization/eligibility
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: 4c8793a9b155f85e7a229117725fca55f58987c3
acceptance_mission: OMW_Template_v25_GroundWorks_base.miz
acceptance_mission_sha256: 95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232
acceptance_bundle_sha256: FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9
dcs_version: 2.9.30.28536 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
---

# Production Base Acceptance 10 – Real ARTY/Mortar DCS PASS

## Ergebnis

Der zweite reale DCS-Lauf vom 02.10.2026 bestand Production Base Acceptance 10.

~~~text
real MOOSE fixed-ARTY/Mortar materialization = PASS
exact emplacement preservation             = PASS
multiple eligible provider setup           = PASS
COMMANDER real-asset selection              = PASS
Functional ARTY single-owner fire path      = PASS
selection reservation release               = PASS
fixed-battery no-movement invariant         = PASS
accepted M1083/CampaignState rearm reuse     = PASS
M1083 return-to-stock                        = PASS
A10 overall                                 = PASS
~~~

## Getesteter Stand

~~~text
branch:
agent/fire-support-strategic-resupply-base-gate0

source / acceptance commit:
4c8793a9b155f85e7a229117725fca55f58987c3

mission:
OMW_Template_v25_GroundWorks_base.miz

mission SHA-256:
95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232

acceptance bundle SHA-256:
FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9

DCS:
2.9.30.28536 MT

MOOSE:
2.9.18
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
~~~

## Laufhistorie

Das hochgeladene DCS-Log enthaelt zwei aufeinanderfolgende Missionslaeufe. Der erste Lauf endete mit:

~~~text
[PRODUCTION BASE A10][FAIL]
ARTY_TEMPLATE_MUST_BE_LATE_ACTIVATION site=FORTRESS
~~~

Dies ist Negativ-Evidenz fuer die Fixture-Anforderung: alle vier realen Fixed-Fire-Support-Gruppen muessen beim Registry-Start nicht aktiv sein. Nach dem erneuten Missionsstart bestand der zweite Lauf.

## Materialisierung und Geometrie

MOOSE materialisierte:

~~~text
FORTRESS -> FortressArtillery_AID-219#001
BOSTICK  -> BostickArtillery_AID-220#001
WRIGHT   -> WrightArtillery_AID-221#001
HONAKER  -> HonakerMortar_AID-222#001
~~~

Alle sieben physischen Geschuetze/Moerser lagen innerhalb der A10-Toleranz von 1.0 m zur jeweiligen urspruenglichen Template-Position. Die maximal beobachtete Abweichung betrug 0.014 m.

## MOOSE-Selektion ohne OMW-Providerwahl

Der Testzielpunkt lag gleichzeitig innerhalb der gepinnten MOOSE-Reichweiten von Wright und Honaker:

~~~text
WRIGHT distance 4610.4 m / max 17500.0 m
HONAKER distance 4737.7 m / max 7000.0 m
~~~

Beide Cohorts verwendeten dieselbe Performance. Der Harness gab keinen konkreten Provider vor. MOOSE/COMMANDER selektierte:

~~~text
provider = BDE_FSSR_A10_WRIGHT
asset    = WrightArtillery_AID-221#001
~~~

Damit ist fuer diesen Scope die Selection-only-Kette praktisch bestaetigt:

~~~text
AUFTRAG descriptor
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> real Assetitem reservation
-> exact physical group handoff
-> existing Functional ARTY owner
~~~

Der Selection-AUFTRAG wurde nicht mit COMMANDER:AddMission gequeued.

## Feuer, Reservation und No-Movement

Wright startete mit 300 rounds. Functional ARTY fuehrte vier Schuss aus: 300 -> 296. Bei CeaseFire wurde die MOOSE-Selection-Reservation freigegeben. Die Wright-Batterie bestand die Positionspruefung nach dem Feuer.

## M1083 / CampaignState Regression

Der bestehende Rearm-Lifecycle wurde direkt wiederverwendet:

~~~text
transactionId = FSSR-A10-REARM-WRIGHT
resourceBefore = 30
support state = WAITING_FOR_SUPPORT
M1083 materialized
CampaignState consumption committed
ARTY rearm completed
finalAmmo = 301
M1083 returned to Warehouse stock
~~~

Danach bestand Wright erneut die No-Movement-Pruefung.

## Erfahrungen und Grenzen

A10 bestaetigt, dass die Descriptor-only-Zwischenrepräsentation fuer Fixed ARTY/Mortar nicht benoetigt wird. Die realen Batterien koennen MOOSE-eigene rekrutierbare Assets sein, solange MOOSE selbst ihre Materialisierung besitzt und die exakten festen Stellungen erhalten bleiben.

~~~text
A10 proves:
one demand
+ more than one eligible fixed-fire-support provider
+ MOOSE selection of one real asset

A10 does not prove:
multiple simultaneous demands
+ contention/queueing across providers
+ mortar actually firing
+ concurrent CAS
+ Strategic Resupply
~~~

Diese Grenzen werden nicht hochinterpretiert, sondern in Acceptance 11 separat getestet.
