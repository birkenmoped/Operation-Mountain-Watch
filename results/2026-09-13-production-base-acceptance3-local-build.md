---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local Production Base Acceptance 3 build provenance
  - exact hashes for the Acceptance 3 DCS test artifact
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: e5773c9956fadfeb9b95684d9aafaee3e519885a
validated_in_dcs: false
---

# Production Base Acceptance 3 – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Acceptance-3-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
e5773c9956fadfeb9b95684d9aafaee3e519885a
```

Die HEAD-Schutzprüfung bestätigte erwarteten und tatsächlichen Stand identisch.

## Builder-Ausgabe

Production Base:

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-5
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
GuardQRFRecruitmentConstraintAuthority: MOOSE AUFTRAG/LEGION
PhysicalAlarmEvidence: optional MOOSE EVENTHANDLER/WEAPON adapter with hostile coordinate propagation
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
PerimeterAccessZoneDependency: none
PerimeterClearClosesIncident: false
MissionSpecificGeometryInjected: true
MOOSEOverride: Guard materialization exact-geometry exception only
MizMutation: false
Encoding: UTF-8 without BOM
```

Acceptance 3:

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-2
GitCommit: e5773c9956fadfeb9b95684d9aafaee3e519885a
PhysicalEvidenceSource: MOOSE EVENTHANDLER/WEAPON only
MissionEditorTestZonesRequired: false
MizMutation: false
```

## Verifizierte SHA-256-Werte

```text
ProductionBuilderSHA256:
BC8CB42179AFE407BC71D05C2DE3B09FA5BADD5EF29E345A49A7C97E8F4D8218

ProductionBundleSHA256:
10345F95F1BEAA9EE170D4E188176C91F102DE0550119E990EBCDEC535BC507E

AcceptanceSourceSHA256:
F7738B3C6593E9351E857758588D464704B6F4F013238856FBA105DFE384CBAD

AcceptanceBuilderSHA256:
D4D1D35E0EC434269AC7BAED0446C726EE7987FF79035E10F05701ADEA3E0783

AcceptanceBundleSHA256:
85188B19EEB71ADFA793DDB9D69B73B55C49143FC0CA4E5373C42241FC1A902E
```

Der separat mit `Get-FileHash` ermittelte Acceptance-Bundle-Hash stimmt exakt mit der Builder-Ausgabe überein.

## Acceptance-Testfixture

Der zu testende DCS-Lauf setzt sechs ausschließlich für Acceptance 3 vorgesehene late-activated RED-Gruppen voraus:

```text
BadGuys_A3_FENTY
BadGuys_A3_FORTRESS
BadGuys_A3_JOYCE
BadGuys_A3_WRIGHT
BadGuys_A3_HONAKER
BadGuys_A3_BOSTICK
```

Diese Gruppen sind reine Testfixtures. Sie sind keine produktive RED-ORBAT und keine produktive RED-C2-Quelle. Die spätere RED-C2 soll feindliche Kräfte dynamisch einsetzen und bewegen.

## Statusgrenze

```text
Local build / hash provenance: VERIFIED
DCS runtime acceptance: OPEN
```

Ein späterer DCS-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Bundle-, Missions-, DCS- und MOOSE-Stand.
