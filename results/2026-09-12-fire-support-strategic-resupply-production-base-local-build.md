---
title: Fire Support / Strategic Resupply production base local build
status: ACCEPTED_TECHNICAL_BASELINE
document_class: BUILD_RESULT
validated_in_dcs: false
source_commit: db805a3e3b54df1775b9ce921925045c3a060e01
---

# Fire Support / Strategic Resupply production base – lokaler Build

## Ergebnis

Der erste lokale Build des allgemeinen Production-Bundles wurde vom Projektinhaber auf dem exakten Branch-Stand ausgefuehrt und erfolgreich abgeschlossen.

```text
Branch: agent/fire-support-strategic-resupply-base-gate0
GitCommit: db805a3e3b54df1775b9ce921925045c3a060e01
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
PackageSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-1
RuntimeSchema: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RUNTIME-5
Sites: 6
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Reale lokale Hashes

Die Builder-Ausgabe und die unabhaengige `Get-FileHash`-Pruefung lieferten identische Werte:

```text
BuilderSHA256:
D12E7F545B3BE0CD425B2AC26A9998C998A7AE7E3AC5887E53DFF99F1BDC248C

BundleSHA256:
573271A705C171C99922D8A30900DBA1489B0B62332EB68A534153A664C6CD5D
```

Erzeugtes Bundle:

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

## Vom Builder bestaetigte Vertragsmerkmale

```text
OperationalAssetSelectionAuthority: MOOSE
StrategicResourceAuthority: caller-provided CampaignState/store
GuardAccessZoneDependency: none
PerimeterAccessZoneDependency: none
PerimeterClearClosesIncident: false
MissionSpecificGeometryInjected: true
MOOSEOverride: Guard materialization exact-geometry exception only
MizMutation: false
Encoding: UTF-8 without BOM
```

Damit ist der allgemeine Production-Builder auf diesem exakten Source-Stand lokal reproduzierbar nachgewiesen.

## Git-Status

Nach dem Build waren ausschliesslich lokale `dist/`-Artefakte untracked:

```text
?? mission/fire-support-strategic-resupply/
?? mission/tests/fire-support-strategic-resupply-gate4-stage3-regression/dist/
?? mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/dist/
?? mission/tests/stage3-honaker-wright-full-response/dist/
```

Es gab keine gemeldeten Source-Aenderungen.

## Bewertungsgrenze

Dieser Nachweis ist ein lokaler Build-/Packaging-PASS. Er ist **kein DCS-Runtime-PASS** und fuehrt daher nicht zu `VALIDATED` fuer das Production-Bundle.

Noch nicht durch diesen Build bewiesen sind insbesondere:

- Runtime-Initialisierung in DCS,
- Guard/QRF/ARTY/CAS-Zusammenspiel im kombinierten Six-Site-Betrieb,
- Installation-Incident-/Multi-Evidence-Laufzeit,
- Ground-/Air-OPSTRANSPORT-Lifecycle,
- CampaignState-Settlement nach realen Transportereignissen,
- missionsspezifische Geometrie-Resolver.

Diese Punkte benoetigen einen separaten DCS-Acceptance-Schritt.
