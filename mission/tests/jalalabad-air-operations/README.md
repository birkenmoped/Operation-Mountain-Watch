---
document_id: OMW-TEST-JBAD-AIR-OPS-INDEX
status: BINDING
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - scope and navigation of the Jalalabad air-operations test project
  - separation of main-branch requirements from PR-18 acceptance evidence
not_authoritative_for:
  - project-wide air ORBAT
  - project-wide client limits
  - branch-independent runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Jalalabad test README with 24/8/6 inventory and no CH-47
  - four-client-per-type test authoring rule
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Jalalabad Air Operations – Testprojektindex

## 1. Autorität

Dieses README beschreibt den Testprojektpfad. Für die aktive Projektbaseline gelten vorrangig:

- [`OMW-AIR-ACTIVE-ORBAT`](../../../docs/19-active-air-orbat-decisions.md);
- [`OMW-AIR-JBAD-MANIFEST`](../../../docs/21-jalalabad-air-operations-manifest.md);
- [`OMW-AIR-IMPLEMENTATION`](../../../docs/18-air-operations-implementation.md).

Die technische Acceptance liegt weiterhin ausschließlich im offenen Draft-PR [#18](https://github.com/birkenmoped/Operation-Mountain-Watch/pull/18) und gilt für dessen exakt dokumentierten Stand.

## 2. Verbindlicher Jalalabad-Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
-------------------
48 Luftfahrzeuge
```

Der logische Bestand ist von Client-Reservierungen, aktiver KI, Templates, sichtbaren Statics und virtueller Reserve getrennt.

## 3. Client-Regel

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

Verpflichtende modfreie Jalalabad-Gruppen:

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02
CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02
CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

Optionale UH-60L-Modvariante:

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
```

Zulässig sind nur null oder zwei UH-60L-Clientgruppen. Die modfreie Kernmission verwendet null.

## 4. KI-Templates

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Alle Templates bleiben Authoring-/Seedvorlagen. Sie sind nicht als dauerhaft belegte Runtime-Parkplätze oder zusätzlicher Bestand zu zählen.

## 5. Branchgebundene technische Acceptance

```text
PR:                 #18
Branch:             feature/jalalabad-air-operations-diagnostics
Commit:             734de196b37730c291edb892936a7dc685d88dc6
Status:             ACCEPTED_TECHNICAL_BASELINE
Merged to main:     false
Repository authority: false
DCS:                2.9.28.26283 MT
MOOSE commit:       73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:  e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Akzeptiert wurden unter anderem AIRWING, vier SQUADRONs, COMMANDER-Grundstart, Bestands-/Templateprüfung, Parking-Schutz und das Ausbleiben spontaner Jalalabad-Missionen.

Nicht akzeptiert sind weiterhin taktische AUFTRAG-Ausführung, OPSTRANSPORT, vollständige 1+1-MEDEVAC-Koordination, persistente Verluste sowie Ramp-/Static-Neuverteilung.

## 6. Historischer Altstand

Der frühere Inhalt mit `24/8/6`, ohne CH-47 und mit vier Clients je Muster bleibt als Quelldatensatz erhalten unter:

- [`legacy-jalalabad-air-operations-test-readme.md`](../../../docs/evidence/source-records/legacy-jalalabad-air-operations-test-readme.md)
