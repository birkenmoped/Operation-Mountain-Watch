---
document_id: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2-LOCAL-BUILD
status: VERIFIED_LOCAL_BUILD
document_class: BUILD_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - local Production Base Acceptance 2 build provenance
  - exact hashes for the Acceptance 2 DCS test artifact
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: 4d790a9caff326ba18dceb218f83338816200ea9
validated_in_dcs: false
---

# Production Base Acceptance 2 – lokaler Buildnachweis

## Ergebnis

Der Projektinhaber hat den Acceptance-2-Builder lokal auf folgendem exakten Git-Stand ausgeführt:

```text
4d790a9caff326ba18dceb218f83338816200ea9
```

Der zuerst verwendete erwartete HEAD `c91793361da2d802edd8a135b5a70e954ac8c115` war durch den nachfolgenden Dokumentationscommit zur Testfixture-Abgrenzung bereits veraltet. Die Schutzprüfung brach deshalb korrekt mit `HEAD mismatch - build aborted.` ab. Anschließend wurde bewusst auf dem tatsächlich gepullten aktuellen HEAD `4d790a9c...` gebaut.

## Builder-Ausgabe

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-3
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-7
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
OperationalAssetSelectionAuthority: MOOSE
GuardQRFRecruitmentConstraintAuthority: MOOSE AUFTRAG/LEGION
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
PerimeterAccessZoneDependency: none
PerimeterClearClosesIncident: false
MissionSpecificGeometryInjected: true
MOOSEOverride: Guard materialization exact-geometry exception only
MizMutation: false
Encoding: UTF-8 without BOM
```

Acceptance-2-Builder:

```text
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2-2
TestId: FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-2
IncidentEvidenceSource: acceptance fixture at live BadGuys1 coordinate
GuardRecruitmentConstraint: MOOSE SetRequiredAttribute Ground_Infantry
QRFRecruitmentConstraint: MOOSE SetRequiredAttribute Ground_APC
AccessZoneDependency: none
MizMutation: false
```

## Verifizierte SHA-256-Werte

Die Builder-Ausgabe und die anschließend separat mit `Get-FileHash` ermittelten Werte stimmen überein:

```text
ProductionBuilderSHA256:
F2FB946ACAB9955E38E27DBB264D2249D2A8F8492FE6339F557FEEDDAE7A00AB

ProductionBundleSHA256:
8A532490E1E70F546ECE15EE3F537D41D2B2F1673E0C29296E79B1E4D763579E

AcceptanceSourceSHA256:
F8AB365B08491DFA002387C7DFA4D866DD160FB15EE504356DD11FDAAD55D84E

AcceptanceBuilderSHA256:
4D0CCC4EDF0AE92E2C4BEE07C47DDF0F279E65A48CDF543C2AED2413C7838761

AcceptanceBundleSHA256:
173290E5F4123D41D79400238385729E8C1A71C77BFBFB54C6A4E7F9C1F4A2F8
```

## Lokaler Git-Status

Der lokale `git status --short` enthielt ausschließlich bereits bekannte bzw. generierte `dist/`-Verzeichnisse:

```text
?? mission/fire-support-strategic-resupply/
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/
?? mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Es wurde keine `.miz` durch den Builder verändert.

## Testfixture-Abgrenzung

`BadGuys1` sowie weitere derzeit in der Test-`.miz` vorhandene `BadGuys*`-Gruppen sind ausschließlich Acceptance-/Testfixtures. Sie sind kein produktives RED-ORBAT-, Spawn-, Tasking- oder C2-Modell. Die spätere produktive RED-C2-Schicht soll feindliche rote Kräfte dynamisch einsetzen und bewegen. BLUE-Alarm-/Incident-/Support-Logik darf deshalb keine produktive Abhängigkeit von Namen, Positionen oder Existenz dieser Testgruppen erhalten.

Acceptance 2 darf `BadGuys1` nur als deterministische Testfixture verwenden, um die Incident-/QRF-Integrationskette gegen eine reale physische DCS-Gruppenposition zu prüfen.

## Statusgrenze

```text
Local build / hash provenance: VERIFIED
DCS runtime acceptance: OPEN
```

Ein späterer DCS-PASS gilt nur für den exakt dokumentierten Commit-, Bundle-, Mission-, DCS- und MOOSE-Stand.
