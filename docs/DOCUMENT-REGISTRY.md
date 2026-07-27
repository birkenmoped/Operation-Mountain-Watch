---
document_id: OMW-GOV-DOCUMENT-REGISTRY
status: BINDING_PROJECT_DECISION
authoritative_for:
  - document number reservations
  - stable document IDs
  - merge-time renumbering
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
---

# Operation Mountain Watch – Zentrales Dokumentregister

## Zweck

Dieses Register reserviert projektweit Dokumentnummern und stabile IDs. Eine Nummer darf nur einmal vergeben werden. Auf ungemergten Branches bereits verwendete, aber hier nicht bestätigte Nummern sind vorläufig und müssen vor dem Merge angepasst werden.

Verweise verwenden bevorzugt:

```text
<document_id> – <Pfad>
```

und nicht nur eine Nummer wie „Dokument 28“.

## Verbindlich belegte Nummern auf `main`

| Nr. | Stabile ID | Pfad | Status / Funktion |
|---:|---|---|---|
| 00 | `OMW-GOV-001` | `docs/00-project-governance.md` | höchste Projekt-Governance |
| 09 | `OMW-HIST-SETTING` | `docs/09-historical-setting.md` | historischer Rahmen und Kampagnenzeitraum |
| 14 | `OMW-PHASE-VERTICAL-PROTOTYPE` | `docs/14-prototype-scope.md` | frühere Projektphase; durch Foundation Build ersetzt |
| 18 | `OMW-AIR-IMPLEMENTATION` | `docs/18-air-operations-implementation.md` | gemeinsame technische Luftoperationsregeln |
| 19 | `OMW-AIR-ACTIVE-ORBAT` | `docs/19-active-air-orbat-decisions.md` | aktive Luft-ORBAT |
| 20 | `OMW-AIR-ME-WORKLIST` | `docs/20-air-orbat-mission-editor-worklist.md` | Luft-ORBAT-Missionseditor-Arbeitsliste |
| 21 | `OMW-AIR-JBAD-MANIFEST` | `docs/21-jalalabad-air-operations-manifest.md` | Jalalabad-Manifest |
| 22 | `OMW-TEST-BUILD-TRANSFER` | `docs/22-test-mission-build-transfer-and-validation-workflow.md` | Build-, Transfer- und Testworkflow |
| 23 | `OMW-AIR-JBAD-PARKING-MEDEVAC` | `docs/23-jalalabad-parking-template-and-medevac-model.md` | Jalalabad Parking-/MEDEVAC-Modell |
| 24 | `OMW-AIR-JBAD-CH47-PARKING` | `docs/24-jalalabad-ch47-static-parking-reservations.md` | CH-47-Static-Parking |
| 25 | `OMW-AIR-JBAD-ACCEPTANCE` | `docs/25-jalalabad-final-validation-and-operational-baseline.md` | technische Jalalabad-Akzeptanz |
| 26 | `OMW-GOV-MOOSE-FIRST` | `docs/26-moose-first-development-policy.md` | MOOSE-First-Richtlinie |
| 27 | `OMW-C2-JTAC-CALLSIGNS` | `docs/27-oef-jtac-callsign-reference.md` | JTAC-Callsign-Referenz |
| 28 | `OMW-C2-TAD-COLOR-NETS` | `docs/28-afghanistan-tad-color-nets.md` | TAD-/Color-Net-Frequenzplan |
| 29 | `OMW-AAR-ISAF-ACO` | `docs/29-isaf-2009-2013-air-to-air-refueling.md` | ISAF-AAR-/ACO-Referenz |
| 30 | `OMW-AAR-PART2-FIGURE` | `docs/30-isaf-2009-2013-aar-part2-figure-reference.md` | AAR-Abbildungsreferenz |

## Reservierungen für noch ungemergte Fachzweige

Die folgenden Nummern sind für die genannten stabilen IDs reserviert. Bestehende Branch-Dateinamen mit kollidierenden Nummern sind vor dem Merge entsprechend umzubenennen.

| Nr. | Stabile ID | Vorgesehener Zielpfad | Aktueller Branch-/PR-Hinweis |
|---:|---|---|---|
| 31 | `OMW-AIR-BAGRAM-MANIFEST` | `docs/31-bagram-air-operations-manifest.md` | PR #24; aktuell fälschlich `28-...` |
| 32 | `OMW-AIR-PLAYER-SLOT-POLICY` | `docs/32-player-aircraft-slot-policy.md` | PR #24; aktuell fälschlich `29-...` |
| 33 | `OMW-AIR-KANDAHAR-MANIFEST` | `docs/33-kandahar-air-operations-manifest.md` | PR #24; aktuell fälschlich `30-...` |
| 34 | `OMW-AIR-BAGRAM-ME-BASELINE` | `docs/34-bagram-current-mission-editor-baseline.md` | PR #24; aktuell `31-...` |
| 35 | `OMW-AIR-KANDAHAR-ISR-POLICY` | `docs/35-kandahar-isr-asset-policy.md` | PR #24; aktuell `32-...` |
| 36 | `OMW-AIR-KANDAHAR-MUSTANG-RAMP` | `docs/36-kandahar-mustang-ramp-army-aviation-baseline.md` | PR #24; aktuell `33-...` |
| 37 | `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` | `docs/37-campaign-architecture-and-dynamic-mission-design.md` | PR #20; aktuell fälschlich `27-...` |
| 38 | `OMW-ME-MASTER-WORKLIST` | `docs/38-mission-editor-master-worklist.md` | PR #20; aktuell fälschlich `28-...` |
| 39 | `OMW-REVIEW-TM01-TM02-MOOSE-FIRST` | `docs/39-tm01-tm02-moose-first-code-review.md` | PR #21; aktuell fälschlich `29-...` |
| 40 | `OMW-PLAN-TM01-TM02-MOOSE-ADOPTION` | `docs/40-moose-module-adoption-plan-for-tm01-tm02.md` | PR #21; aktuell fälschlich `30-...` |
| 41 | `OMW-WX-HISTORICAL-BASELINE` | `docs/41-historical-weather-baseline.md` | PR #23; aktuelle Branch-Nummer vor Merge prüfen |
| 42 | `OMW-WX-DCS-IMPLEMENTATION` | `docs/42-dcs-weather-implementation.md` | PR #23 |
| 43 | `OMW-WX-RAIN-PROFILE` | `docs/43-dcs-rain-profile.md` | PR #23 |
| 44 | `OMW-WX-MIST-PROFILE` | `docs/44-dcs-mist-profile.md` | PR #23 |
| 45 | `OMW-C2-AIR-C2-CAS-AFGHANISTAN` | `docs/45-air-c2-cas-afghanistan.md` | PR #25 |
| 46 | `OMW-ROE-NON-LETHAL-USE-OF-FORCE` | `docs/46-non-lethal-use-of-force.md` | PR #26; aktuell fälschlich `27-...` |
| 47 | `OMW-C2-AIRCRAFT-TACTICAL-CALLSIGNS` | `docs/47-aircraft-tactical-callsigns.md` | PR #27 |
| 48 | `OMW-TARGETING-AFGHANISTAN-NSL` | `docs/48-afghanistan-no-strike-list.md` | PR #30 |

## Nicht nummerierte stabile Dokumente

| Stabile ID | Pfad | Status / Funktion |
|---|---|---|
| `OMW-AIR-US-ORBAT-RESEARCH` | `docs/us-air-orbat-2010-2011.md` | historischer Recherche- und Planungsbestand; aktive Auswahl steht in `OMW-AIR-ACTIVE-ORBAT` |
| `OMW-GOV-SOURCE-USE` | `docs/sources/graveyard-of-empires.md` | zentrale Quellen-, Datei- und Attributionsregel |
| `OMW-GOV-MOOSE-VERSION` | `docs/moose/VERSION-AND-SOURCES.md` | MOOSE-Versions- und Nachweisregeln |
| `OMW-MOOSE-CLASS-INDEX` | `docs/moose/PROJECT-CLASS-INDEX.md` | projektbezogener MOOSE-Klassenindex |
| `OMW-MOOSE-VERIFIED-METHODS` | `docs/moose/VERIFIED-METHODS.md` | praktisch verifizierte Methoden |

## Branch- und Merge-Regel

1. Ein Branch darf neue Dokumente zunächst ohne endgültige Nummer entwickeln.
2. Spätestens vor Merge wird eine Nummer in diesem Register reserviert.
3. Kollidierende Branch-Dateinamen werden vor Merge umbenannt.
4. README-Links, Querverweise und ADRs werden im selben Commit angepasst.
5. Alte Nummern dürfen in der Historie genannt werden, aber nicht als aktuelle Referenz bestehen bleiben.
6. Branchspezifische Dubletten zentraler Richtlinien werden nicht als parallele Wahrheit gemergt. Sie werden entfernt oder auf das zentrale Dokument umgestellt.

## Pflege

Jede Reservierung oder Statusänderung erfolgt gemeinsam mit der zugehörigen Dokumentänderung. Ein ungenutzter reservierter Platz kann durch ausdrückliche Projektentscheidung freigegeben werden; eine bereits veröffentlichte stabile ID wird nicht neu vergeben.
