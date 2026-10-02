---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ALARM-EVIDENCE-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local Production Base build provenance after physical alarm-evidence wiring
  - exact hashes for Runtime 8 / Builder 4 production package
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 29517ddc1ebf3a42c7aff8b5a812650e77ac2514
validated_in_dcs: false
---

# Production Base Runtime 8 / Alarm Evidence – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Production-Base-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
29517ddc1ebf3a42c7aff8b5a812650e77ac2514
```

Die vorgeschaltete HEAD-Prüfung bestätigte exakt denselben Commit. Der Builder lief ohne Source-/Contract-Abbruch durch und erzeugte das Production-Bundle.

## Builder-Ausgabe

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-4
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-8
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
GuardQRFRecruitmentConstraintAuthority: MOOSE AUFTRAG/LEGION
PhysicalAlarmEvidence: optional MOOSE EVENTHANDLER/WEAPON adapter
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
PerimeterAccessZoneDependency: none
PerimeterClearClosesIncident: false
MissionSpecificGeometryInjected: true
MOOSEOverride: Guard materialization exact-geometry exception only
MizMutation: false
Encoding: UTF-8 without BOM
```

## Verifizierte SHA-256-Werte

Builder-Ausgabe und die anschließend separat mit `Get-FileHash` ermittelten Werte stimmen für Builder und Bundle überein:

```text
RuntimeSourceSHA256:
BE1B938B9021E6E6115FA8461082FCF06B9A600745379FD34B8DBF7E9DCE5BE5

AlarmEvidenceAdapterSourceSHA256:
DE58083A22F8A85FDA609F8C3E8FB2FC78EACA0FBA929DEB81A95379D2485386

ProductionBuilderSHA256:
AD6C40306FF2014913D28EC8B52E743DFEB58D2D388A2E1D9C6C1E76D43F3DBF

ProductionBundleSHA256:
5A54ED37E7C2FD9AD01BE25205C60691979AFCD7C45DAD00BA080FF814EBF010
```

Damit ist der Build-Artefaktstand eindeutig an Runtime 8 / Builder 4 gebunden.

## Lokaler Git-Status

Nach dem Build meldete `git status --short` ausschließlich generierte bzw. bereits bekannte `dist/`-Verzeichnisse:

```text
?? mission/fire-support-strategic-resupply/
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/
?? mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Das neue Production-Bundle liegt lokal unter:

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

Der Builder meldete ausdrücklich `MizMutation: false`; es wurde durch diesen Build keine `.miz` verändert.

## Statusgrenze

```text
Local build / hash provenance: VERIFIED
Source/contract CI on source commit: PASS
Physical alarm-evidence DCS runtime acceptance: OPEN
```

Dieser Nachweis validiert die Buildbarkeit und die exakten Hashes des Production-Bundles. Er ist kein DCS-Runtime-PASS für `EVENTHANDLER`-/`WEAPON`-basierte Shot-/Hit-/Impact-Evidence.

Ein späterer DCS-PASS gilt ausschließlich für den exakt dokumentierten Commit-, Production-Bundle-, Acceptance-Bundle-, Mission-, DCS- und MOOSE-Stand.
