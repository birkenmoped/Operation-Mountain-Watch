---
document_id: OMW-CSAR-INDEX
status: BINDING
document_class: SOURCE_SERIES_INDEX
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - CSAR source inventory and document classification
  - separation of source notes, derived data and mission-design requirements
not_authoritative_for:
  - technical MOOSE CSAR acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified CSAR source index
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: ecb825540facc5effce777efa29716ee965f55a3
validated_in_dcs: false
---

# Combat Search and Rescue – Quellen- und Anforderungsindex

## 1. Autorität und Abgrenzung

Dieser Index ordnet die vollständige achtteilige CSAR-Quellenserie und die daraus abgeleiteten OMW-Dokumente ein.

Vorrangige Projektregeln:

- [`OMW-GOV-001`](../00-project-governance.md)
- [`OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](../37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-GOV-SOURCE-USE`](../sources/graveyard-of-empires.md)

Der vollständige frühere CSAR-Index bleibt unverändert erhalten:

- [`Legacy-CSAR-Index`](../evidence/source-records/legacy-csar-readme-source-series.md)

## 2. Quellenstatus

```yaml
source_author: Graveyard of Empires
series_parts: 8
available_parts: 8
source_status: SOURCE_CAPTURE_COMPLETE
runtime_validation: false
```

Alle acht Artikeltexte wurden aus den vom Projektinhaber bereitgestellten vollständigen Druck-PDFs ausgewertet. Separat genannte Anhänge bleiben dort als ausstehend markiert, wo die Originaldatei nicht vorliegt.

## 3. Dokumentklassen

| Pfad | Stabile Funktion | Dokumentklasse | Governance-Status |
|---|---|---|---|
| [`source-notes-1-8.md`](source-notes-1-8.md) | quellengetreue Auswertung | `SOURCE_REFERENCE` | kein eigenständiges BINDING ohne diesen Index |
| [`afghanistan-2010-facilities-and-coverage.md`](afghanistan-2010-facilities-and-coverage.md) | aus Quellen und CombatFlite abgeleitete Orts-/Coverage-Daten | `SOURCE_DERIVED_DATA` | `PLANNED` für Missionsnutzung |
| [`mission-design-requirements.md`](mission-design-requirements.md) | quellenbasierte Missionsanforderungen | `WORKLIST` / `DESIGN_REQUIREMENTS` | `PLANNED` |
| [`moose-csar-aicsar-development-baseline.md`](moose-csar-aicsar-development-baseline.md) | konsolidierte Architektur-, Entscheidungs- und Testbaseline | `ARCHITECTURE_AND_TEST_PLAN` | `PLANNED` |
| spätere DCS-Acceptance | getesteter Laufzeitstand | `TEST_RESULT` | separat als `ACCEPTED_TECHNICAL_BASELINE` |

## 4. Verbindliche fachliche Themen

Die Quellenserie ist für folgende Bereiche auszuwerten und in der Missionsgestaltung zu berücksichtigen:

- PR-, SAR-, CSAR-, CR- und NAR-Abgrenzungen;
- C2-Rollen und Missionsphasen;
- Vorbereitung und Ausrüstung isolierten Personals;
- Authentifizierung, Duress und Kommunikation;
- Gelände-, Höhen-, Wetter- und Bedrohungsbedingungen in Afghanistan;
- Recovery-Kräfte, Luftfahrzeuge, Basing und Vorverlegung;
- HLO-Leistungsgrenzen, IGE/OGE und Hot-and-high;
- medizinische Rollen, Zeitketten und STRATEVAC;
- Karten-, Radius-, Koordinaten- und Hospitalinformationen;
- CampaignState-, MissionDemand- und MOOSE-Anforderungen.

## 5. Architekturgrenzen

- Für jeden Vorfall existiert genau ein autoritatives `CSARIncident`-Objekt.
- Spieler und KI arbeiten auf demselben Vorfall.
- `AICSAR` darf nur übernehmen, wenn der Vorfall nicht wirksam durch einen Spieler reserviert ist.
- Rettung, Gefangennahme, Tod, Ablauf und Rückführung sind persistente Kampagnenzustände.
- MOOSE CSAR und AICSAR werden vorrangig geprüft; projektspezifische Ergänzungen benötigen Dokument 26 und Eigentümerfreigabe.
- Die aktuelle technische und spielerische Arbeitsbaseline steht in [`OMW-CSAR-MOOSE-AICSAR-DEVELOPMENT-BASELINE`](moose-csar-aicsar-development-baseline.md).

## 6. Noch erforderliche technische Dokumente

1. `CSARIncident`-Datenmodell und endgültiger Zustandsautomat;
2. DCS-Testharness für `Ops.CSAR`, `Functional.AICSAR` und `Wrapper.Net`;
3. Acceptance-Bericht für Spieler-CSAR und AICSAR;
4. Dedicated-Server-Acceptance für Slot-Lock und Reconnect;
5. Multiplayer-, Persistenz- und Missionsneustarttests;
6. optionale Capture-/Evasion-/NAR-Erweiterungen nach Freigabe.
