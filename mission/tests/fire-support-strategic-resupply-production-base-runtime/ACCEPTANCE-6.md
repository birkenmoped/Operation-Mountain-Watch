---
document_id: OMW-TEST-FSSR-PRODUCTION-BASE-ACCEPTANCE-6
status: REJECTED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - compact production Base command-chain validation
  - runtime C2 CAS provider selection without Acceptance provider hardcoding
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - rejected Stage 3 Acceptance 2 as a provider-selection test
superseded_by:
---

# Production Base Acceptance 6 - C2 Provider Selection

## Ziel

Dieser Lauf kehrt zum eigentlichen fire-support-strategic-resupply_base-Ziel zurueck. Er prueft keine historische Honaker-End-to-End-Fixture und keinen strategischen Resupply.

Die zu pruefende Kette ist:

```text
physical RED attack at FOB Joyce
-> production MOOSE perimeter
-> authoritative installation incident
-> production QRF
-> concrete incident UNIT engagement

same incident
-> explicit C2 CAS escalation
-> Base:RequestIncidentSupport(..., CAS)
-> ExternalSupportRuntime
-> CommanderBridge
-> MOOSE COMMANDER
-> MOOSE selects/recruits provider and operational CAS asset
-> OPSGROUP on mission
```

## Warum Joyce

FOB_JOYCE ist im aktuellen SiteRegistry fuer localSupport mit NOT_ESTABLISHED_BY_CURRENT_BASELINE gekennzeichnet. Damit vermeiden wir die bekannte Honaker-Regression, bei der lokale autonome Feuerunterstuetzung die RED-Fixture vor der eigentlichen Acceptance vernichtete.

Die RED-Fixture BadGuys_A3_JOYCE wird nur aktiviert. Die Acceptance schreibt ihre Mission-Editor-Route nicht um.

## C2-Pool

Die Acceptance nennt keinen Provider und keinen Flugzeugtyp.

Sie liest ausschliesslich die bereits laufenden OMW-AirOps-Grundknoten aus:

```text
OMW.AirOps
-> every node with Status == RUNNING
-> Airwing / Airwings
-> COMMANDER:AddAirwing(...)
```

Vor Testbeginn muessen mindestens zwei unterschiedliche laufende AIRWINGs mit einer CAS-faehigen Cohort vorhanden sein. Die Diagnose verwendet den gepinnten MOOSE-Vertrag AUFTRAG.CheckMissionCapability(AUFTRAG.Type.CAS, cohort.missiontypes).

Verboten in dieser Acceptance:

```text
hardcoded Jalalabad/Bagram/Kandahar/Salerno/Tarinkot/Shindand provider
hardcoded AH-64/A-10/F-15/F-16 selection
specialLegions / specialCohorts
AIRWING:AddMission()
SQUADRON binding
Acceptance-owned asset choice
Stage-3 CAS corridor
strategic resupply
ARTY provider binding
```

## CAS-Geometrie

Die Acceptance erzeugt nur die fuer AUFTRAG:NewCAS() erforderliche taktische Testzone um die aktuelle physische RED-Fixture. Diese Zone ist ausdruecklich Testgeometrie fuer die Provider-Auswahl:

```text
CAS test zone != alarm perimeter
CAS test zone != production tactical doctrine
```

Es werden keine Ingress-/Egress-Wegpunkte, keine Corridors und keine Providerparameter gesetzt.

## PASS

PASS erfordert positive Runtime-Evidenz fuer:

```text
1. physical Joyce RED fixture activates on existing ME route
2. production perimeter qualifies the attack
3. authoritative installation incident exists
4. production QRF reaches ARMYGROUP:OnAfterEngageTarget against a concrete incident target
5. exactly one CAS escalation is requested through Base:RequestIncidentSupport()
6. at least two CAS-capable running AIRWING candidates were registered with COMMANDER
7. COMMANDER OnAfterMissionAssign identifies the provider selected by MOOSE
8. COMMANDER OnAfterOpsOnMission confirms a physical CAS OPSGROUP on mission
9. Acceptance contains no AIRWING/SQUADRON/provider/aircraft selection
```

Nicht Bestandteil dieses Runs:

```text
CAS weapon employment
CAS route doctrine
CAS RTB
ARTY
rearm
strategic resupply
CampaignState delivery settlement
```

Diese Begrenzung ist absichtlich. Erst die Befehls-/Auswahlkette wird positiv bewiesen; danach werden weitere Ausfuehrungspfade auf derselben Base ergaenzt.

## Timeout

Der Test wartet maximal 600 Sekunden nach Aktivierung der RED-Fixture. Damit wird ein weiterer 30-Minuten-Lauf ohne Provider-Auswahl-Evidenz ausgeschlossen.

## Local build verification 2026-09-18

Owner-local build completed successfully on the exact source commit:

```text
branch: agent/fire-support-strategic-resupply-base-gate0
source commit: 4f5bb335da2ffdd69b20f6b95b8e8289fe592efc
production builder version: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-19
acceptance builder version: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-6-1
production builder SHA-256: 2463B10AC996D762D8903AE8F6C7C006E28C806DF61D290B2D74E2A3BF38D0F2
production bundle SHA-256: 1A2B5746EB58D5F487F6407792BE2AD63607D90136F6DDCC4897646F3189FD44
acceptance source SHA-256: 866EFFB2CF128D466A572D25D04F916C71538E835117DC3010C3B6DB5DA36DDC
acceptance builder SHA-256: D7E7017BFF919C63F71FE6C4A7DBCBBA10AB55B42BDA9974C6B41907F6E79AC1
acceptance bundle SHA-256: F2F3CECF2EBA0444D75019B8AFD4EDFA7B83E25DB09F80FA51B3ECAA1F78E6D4
miz mutation: false
```

The builder-reported hashes match the independent owner-local `Get-FileHash` output. This establishes `VERIFIED_LOCAL_BUILD` only. DCS runtime validation remains pending.

Local `git status --short` showed generated `dist/` directories only; no tracked source modification was reported.

## DCS run 2026-09-18 - harness composition failure

The first Acceptance-6 DCS run did not reach the RED attack. The C2 preflight itself succeeded and discovered eight running AIRWINGs, seven of them CAS-capable. The run then failed while preparing the production runtime:

```text
RUNTIME_PREPARE_FAILED
[OMW][FireSupStratResupply.GuardRuntime] brigades[COP_HONAKER] must be a table
```

Root cause: the Acceptance supplied only the Joyce BRIGADE but let `Package.New()` inject the complete six-site production `SiteRegistry`. `GuardRuntime` correctly validates that every site in the injected registry has a BRIGADE. The test harness therefore violated the Runtime composition contract before any incident/QRF/CAS path could execute.

Correction: Acceptance 6 now passes an explicit one-site registry view containing only `FOB_JOYCE` together with the Joyce BRIGADE. This does not alter production source, provider selection, or C2 authority; it only makes the test composition match its declared single-site physical scope.

Status of this DCS run: `FAIL_HARNESS_COMPOSITION`; no Base runtime result may be inferred from it.

## Local rebuild verification after harness composition fix

Owner-local rebuild completed successfully on:

```text
source commit: da83ed66d37cf4574256a2ddda3a897e049558a8
production builder version: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-19
acceptance builder version: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-6-1
production builder SHA-256: 2463B10AC996D762D8903AE8F6C7C006E28C806DF61D290B2D74E2A3BF38D0F2
production bundle SHA-256: 84B438D240895CA03990DA5AE736CFBD6D6355FD3044DE3290F0DF73498CE982
acceptance source SHA-256: DA94FE4B38126A3B13C1E8B3902436D1E6478ED09EF1A3D557F52A9BE8B696A5
acceptance builder SHA-256: 675213DA81D414FB204DEA036AE40680F8C0C06AC40723575F7E9CF076C88107
acceptance bundle SHA-256: 9F498AF90A109494D6BFA22675B4ED8DFB76C8733840358A756A26B2846B03E8
miz mutation: false
```

The independent owner-local `Get-FileHash` for the generated Acceptance bundle matched the builder output exactly.

Status after this rebuild: `VERIFIED_LOCAL_BUILD / DCS_PENDING`.

## DCS run 2026-09-18 - rejected Base acceptance

Der reale Lauf mit Bundle SHA-256 `9F498AF90A109494D6BFA22675B4ED8DFB76C8733840358A756A26B2846B03E8` erreichte die Joyce-Angriffs-, Incident-, QRF- und CAS-Dispatch-Kette. Der Harness meldete bereits nach `COMMANDER:OnAfterOpsOnMission` einen PASS. Dieser PASS ist fuer die Base ungueltig und wird verworfen.

Beobachtete positive Teil-Evidenz:

```text
Joyce physical attack -> installation incident
QRF materialized
QRF direct concrete-target engagement
CAS demand created through Base
COMMANDER selected AW_US_JBAD_TF_SHOOTER_6_6_CAV
MOOSE recruited SQ_US_JBAD_AH64D_B_1_10_AVN
physical AH-64D OPSGROUP on mission
```

Die anschliessende reale Ausfuehrung verletzte jedoch bindende CAS-/Rotary-Wing-Vertraege:

```text
- outbound flight used direct line instead of approved OMW helicopter owner route
- no controlled route-gated ingress/egress lifecycle
- CAS did not close by supported-element release plus stable own no-contact picture
- mission continued until FuelLow/Bingo path
- return used direct low-altitude route instead of owner reverse route
- one AH-64D was lost during recovery
- surviving AH-64D circled near Jalalabad without completing physical landing/recovery
```

Zusaetzlich war bereits der Acceptance-Entwurf architektonisch falsch: Er registrierte einen ungebundenen Gesamtpool mehrerer AIRWINGs in einem COMMANDER und ueberliess MOOSE die strategische Herkunftsauswahl. Das widerspricht dem bindenden allgemeinen CAS-Vertrag in `STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md`: C2/OMW muss Kandidaten bewerten, genau eine strategische Ressource samt AIRWING/SQUADRON/COHORT und Routen-/Recovery-Profil auswaehlen und reservieren; erst danach darf MOOSE den physischen Auftrag innerhalb dieses ausgewaehlten Pools ausfuehren.

Damit gilt:

```text
Acceptance 6 = REJECTED
validated_in_dcs = false
the early PASS marker is INVALID as Base evidence
do not rerun A6
do not use global unbound COMMANDER pool as Base provider selection
```

Der Lauf ist wertvolle Negativ-Evidenz: Er beweist, dass `OpsOnMission` allein keine ausreichende Base-Acceptance-Grenze ist und dass Routing, Release und physische Recovery Bestandteil jedes CAS-Base-Vertrags bleiben muessen.
