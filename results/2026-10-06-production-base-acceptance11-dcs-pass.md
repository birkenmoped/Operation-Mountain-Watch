---
document_id: OMW-RESULT-FSSR-PRODUCTION-BASE-A11-DCS-PASS-20261006
status: ACCEPTED_TECHNICAL_BASELINE
document_class: RUNTIME_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact observed DCS runtime result of Production Base Acceptance 11
  - combined Joyce/Wright/Honaker Guard and QRF regression evidence
  - MOOSE-selected real L118 and 2B11 fire evidence
  - two independent rotary CAS owner-corridor lifecycles
  - Strategic Resupply physical corridor/STORAGE/settlement/return evidence
not_authoritative_for:
  - repository-wide governance
  - provider/site profiles not exercised by this run
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
acceptance_branch: agent/fire-support-strategic-resupply-base-gate0
acceptance_commit: 1193a3b9b1ad67ddfa2e43b16d408f34851b62e2
acceptance_mission: OMW_Template_v25_GroundWorks_base.miz
acceptance_mission_sha256: C5C0235FC0923A4A66518FD8ADCD48618536E56595E112F01EDCFD9C942FE113
acceptance_bundle_sha256: 680D727C991A4F98A4CFA291CFA8C1BBA9AED54889DC31CC35D1F37A05A3E539
dcs_version: 2.9.30.28738 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
validated_in_dcs: true
validation_status: DCS_VALIDATED_FOR_DOCUMENTED_SCOPE
---

# Production Base Acceptance 11 – DCS-PASS am 06.10.2026

## Ergebnis

Der reale A11-Wiederholungslauf nach der ACCESS-Containment-Korrektur bestand die
kombinierte Multi-Site-Acceptance.

~~~text
Joyce Guard/QRF regression                     = PASS
Wright Guard/QRF regression                    = PASS
Honaker Guard/QRF regression                   = PASS
Honaker ACCESS anchor-only materialization     = PASS
MOOSE-selected Wright L118 fire                = PASS
MOOSE-selected Honaker 2B11 fire               = PASS
physical mortar weapon effect                  = PASS
CAS Joyce owner-corridor lifecycle             = PASS
CAS Honaker owner-corridor lifecycle           = PASS
Strategic Resupply outbound corridor           = PASS
MOOSE STORAGE transit/delivery                 = PASS
CampaignState/TransportSettlement              = PASS
Strategic Resupply return corridor             = PASS
physical carrier home landing / asset return   = PASS
A11 explicit runtime marker                    = PASS
~~~

Der DCS-Log endet mit:

~~~text
[PRODUCTION BASE A11][PASS]
A11 combined multi-site response complete:
overlapping Joyce/Wright/Honaker incidents;
Guard/QRF regression;
MOOSE-selected L118 + real 2B11 fire;
two independent CAS lifecycles;
mandatory-corridor Strategic Resupply
with exact CampaignState settlement and physical carrier return.
~~~

## Getesteter Stand

~~~text
branch:
agent/fire-support-strategic-resupply-base-gate0

tested source commit:
1193a3b9b1ad67ddfa2e43b16d408f34851b62e2

Production Builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-33
SHA-256:
04FF1D73202D1863709C0ED01FDBAA95F10B4B0A299BC87E2CE29651B2E9B17C

Production Base bundle SHA-256:
EC1CC8BD359AB97E4A03D0DCA2F70FD854903F3AF23E21178CE40681A3C736F1

Acceptance Builder:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-11-2
SHA-256:
D81A721D41291C20DB620A7890A780DDC4110211FCD1ABA91C672D316CB01E0F

Acceptance bundle SHA-256:
680D727C991A4F98A4CFA291CFA8C1BBA9AED54889DC31CC35D1F37A05A3E539

mission:
OMW_Template_v25_GroundWorks_base.miz

mission SHA-256:
C5C0235FC0923A4A66518FD8ADCD48618536E56595E112F01EDCFD9C942FE113

DCS:
2.9.30.28738 MT

MOOSE:
2.9.18
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54

Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915

runtime evidence:
dcs(20261006-204448).log
debrief(20261006-204447).log
~~~

## Guard und QRF

Alle drei Installationen erreichten ihre Guard-Beobachtung. Anschließend
materialisierten Joyce, Honaker und Wright jeweils sechs QRF-Fahrzeuge über den
gemeinsamen GroundRoadSpawnAdapter.

Für Honaker wurde der geänderte Vertrag real bestätigt:

~~~text
ROAD_ALIGNED_WAREHOUSE_SPAWN
entityId=BLUE_GROUND_COP_HONAKER_MIRACLE|QRF
units=6
formationLengthM=90.0
vehicleSpacingM=18
accessContainment=ANCHOR_ONLY
~~~

Danach erreichten alle drei Sites QRF_OBSERVED und QRF_DIRECT_TARGET_ENGAGE.
Die frühere Honaker-Regression road spawn position outside access zone trat nicht
erneut auf.

## ARTY und Mortar

Nach den drei QRF-Engagements erzeugte A11 gleichzeitig zwei ARTY-, zwei CAS- und
einen threshold-driven AIR_RESUPPLY-Demand. Die Provider-/Assetwahl blieb MOOSE-owned.

Selektiert wurden WrightArtillery_AID-227#001 und HonakerMortar_AID-228#001.
Beide Functional-ARTY-Lifecycles starteten realen Fire Support. Das Debrief enthält
physische Schussereignisse für L118 und 2B11. Für den 2B11 sind zusätzlich reale
120-mm-Hit-/Kill-Ereignisse gegen RED-Infanterie dokumentiert.

Damit ist die in A10 noch offene selected-2B11-fire-Grenze für diesen exakten A11-Stand
praktisch geschlossen.

## CAS

Zwei unabhängige CAS-Demands liefen über den bestehenden Production-CAS-Lifecycle.
Joyce und Honaker erreichten jeweils owner corridor installed, Home Landing in
Jalalabad, Legion asset return und CAS_LIFECYCLE_COMPLETE.

Der Projektinhaber beobachtete den Abflug beider CAS-Flights über die vorgesehenen
Korridore positiv.

## Strategic Resupply

Der Wright-AMMO-Testzustand erzeugte über ResourceDemandPolicy/ResupplyMonitor den
normalen AIR_RESUPPLY-Demand. MOOSE selektierte das CH-47-Asset
SQ_US_JBAD_CH47_HEAVYLIFT_AID-176 aus AW_US_JBAD_TF_SHOOTER_6_6_CAV.

Der physische Lifecycle erreichte outbound corridor, STORAGE in-transit,
OPSTRANSPORT Delivered, TransportSettlement outcome=DELIVERED changed=true,
return corridor, Home Landing Jalalabad und Legion asset return.

Der Projektinhaber beobachtete den realen Anflug des Resupply-Carriers über den
Korridor positiv.

## Watchdog und Shutdown

Der A11-Beobachtungswatchdog lief vor den späten physischen Rückkehrereignissen ab
und meldete ausschließlich WARN. Der Harness griff nicht ein; die produktiven
Lifecycles liefen bis zu Home Landing, Asset Return und finalem PASS weiter.

Nach Dispatcher Stop trat erneut der lokale Saved-Games-Hookfehler bhHook.lua
(tcp == nil) auf. Er liegt zeitlich nach dem A11-PASS und ist keine
FSSR-Lifecycle-Evidenz.

## Governance-Grenze

Der reale Runtime-Lauf ist DCS PASS und validated_in_dcs: true für den dokumentierten
A11 Source-/Bundle-/DCS-/MOOSE-Stand.

Der Projektinhaber hat am 09.10.2026 den exakten SHA-256 der tatsächlich getesteten
Mission lokal nachgereicht. Damit ist die vollständige technische Acceptance-Provenienz
geschlossen und dieser exakte A11-Stand ist ACCEPTED_TECHNICAL_BASELINE.

Repository-weite normative Wirkung entsteht dadurch noch nicht; dafür gilt weiterhin
die Governance-Grenze für Branch-Acceptances bis zum Merge nach `main`.

