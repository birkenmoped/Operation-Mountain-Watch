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
acceptance_mission_sha256: D51A38BBD352AE7E5F17A4CB4A025B4BD8F875339B97A19441EBD14D8653B1D9
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

Damit ist fuer diesen exakten Teststand nachgewiesen, dass das generierte Production-Base-Paket geladen wird und der sechs-Site-Guard-Pfad durch den produktiven Composition Root bis zur MOOSE-Rekrutierung, Materialisierung und PATHLINE-Ausfuehrung funktioniert.

## Ziel

Diese Acceptance prueft erstmals das generierte Production-Base-Paket

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

als zusammenhaengenden DCS-Laufzeitbaustein.

Der Test beweist ausschliesslich:

1. das generierte Paket wird nach MOOSE erfolgreich geladen;
2. `OMW.FireSupStratResupply.New(spec)` erzeugt und vorbereitet den allgemeinen Runtime-Composition-Root;
3. die sechs bereits vorhandenen lokalen BRIGADE-/PLATOON-Guard-Organisationen koennen ueber `Runtime:StartSite()` ihren persistenten Guard-Demand erhalten;
4. MOOSE rekrutiert/materialisiert den Guard;
5. der bereits akzeptierte Guard-Materialisierungsadapter und der vorhandene PATHLINE-Routenadapter werden durch den Production-Composition-Root erreicht;
6. alle sechs Guards bleiben lebendig und zeigen mindestens 25 m Positionsaenderung gegenueber der beim `OnAfterArmyOnMission` beobachteten Startposition.

## Nicht Bestandteil dieser Acceptance

Diese Acceptance prueft **nicht**:

- dauerhafte oder endlose Guard-Patrouillenzyklen;
- QRF-Ausfuehrung;
- ARTY-Ausfuehrung;
- CAS-Ausfuehrung;
- Perimeter-/Multi-Evidence-Incident-Ausloesung;
- Ground-/Air-Resupply;
- CampaignState-Settlement eines physischen Transports;
- missionsspezifische Alarmradien, QRF-Ziele, CAS-Zonen oder Resupply-Routen.

Fuer diese Punkte wurden keine Geometrien oder Provider erfunden. Sie bleiben gesonderten Acceptance-Schritten vorbehalten.

## Guard-Vertrag

Die bereits genehmigte Ausnahme wird nicht erweitert. Sie betrifft weiterhin ausschliesslich die exakte kompakte Guard-Materialisierung unmittelbar vor der MOOSE-Warehouse-Materialisierung. Rekrutierung, BRIGADE/WAREHOUSE, PLATOON, ARMYGROUP und AUFTRAG bleiben bei MOOSE.

Die bekannte Beobachtung aus Gate 5, dass nicht alle sechs Gruppen nach dem ersten PATHLINE-Lauf dauerhaft identisch weiterpatrouillieren, ist kein Fehlerkriterium dieser Acceptance. Der Projektinhaber hat entschieden, den aktuellen Stand beizubehalten und keine zweite Ausnahme fuer eine eigene Patrol-Loop-Logik zu genehmigen.

## Mission-Editor-Voraussetzungen

Verwendet wurde die Foundation-Mission mit den bereits in Gate 5 bestaetigten Objekten:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
WH_BLUE_GND_FENTY
WH_BLUE_GND_FORTRESS
WH_BLUE_GND_JOYCE
WH_BLUE_GND_WRIGHT
WH_BLUE_GND_HONAKER
WH_BLUE_GND_BOSTICK
OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

`ZON_BLUE_GND_*_ACCESS` gehoert nicht zum Guard-Testvertrag.

## Builder und Artefakte

Builder:

```text
tools/build-fire-support-strategic-resupply-production-base-acceptance-1.ps1
```

Ausgabe:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/dist/OMW_FireSupStratResupply_Production_Base_Acceptance_1.lua
```

Reale lokale Build-Provenance:

```text
ProductionBuilderSHA256  D12E7F545B3BE0CD425B2AC26A9998C998A7AE7E3AC5887E53DFF99F1BDC248C
ProductionBundleSHA256   B88935BCE655726D3E7BE10ECE2013E0A3E87761E3241F7CCED2C6BB27D7831C
AcceptanceSourceSHA256   7101E4A3B15441A0CDD841C3F98C7CC82A4B6E36E8615066D8A1DF16D16491B8
AcceptanceBuilderSHA256  E43B516205E4132CC56442E9666643E014D132B46DD1EAF0D155187EAFF631B2
AcceptanceBundleSHA256   5B6E7CCECCA143CB93A5B5158EEEB53B8D6D93E382DDC1A7458FAF09A6E25EDF
```

## DCS-Nachweis

Der reale Test lief unter DCS `2.9.29.27468`.

Der Log zeigt zunaechst den erwarteten READY-Zustand und fuer alle sechs Sites die produktiven Guard-Demands. Anschliessend wurden alle sechs Guards auf Mission beobachtet und ihre PATHLINE-Routen gestartet. Der geforderte PASS wurde um 23:10:57 protokolliert.

Die PASS-Telemetrie des Test-Harness ist der Abnahmepunkt. Spaetere Telemetrie nach dem PASS gehoert nicht mehr zum Acceptance-Kriterium und aendert diesen PASS nicht.

Im Log treten unabhaengig vom Acceptance-Harness MOOSE/DCS-Warnungen auf, insbesondere `EVENTMETA data for event ID=61` und spaetere `TRANSPORT ... CREATING PATH MAKES TOO LONG!!!!!`-Warnungen. Sie haben den dokumentierten Acceptance-PASS nicht verhindert und werden durch diesen Test weder als behoben noch als fuer andere Laufzeitpfade akzeptiert bewertet.

## Abgrenzung der Aussage

Dieser PASS darf nicht auf QRF, ARTY, CAS, Multi-Evidence-Incident, Ground-/Air-Resupply oder CampaignState-Transport-Settlement verallgemeinert werden. Diese Pfade benoetigen eigene DCS-Acceptance-Nachweise.

Das 25-m-Kriterium bleibt ein initialer Bewegungsnachweis. Es beweist keinen vollstaendigen oder dauerhaften Patrol-Zyklus.
