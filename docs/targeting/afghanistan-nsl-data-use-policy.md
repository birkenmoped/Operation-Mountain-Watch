---
document_id: OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE
status: BINDING
document_class: DATA_USE_POLICY
owning_policy: OMW-GOV-SOURCE-USE
authoritative_for:
  - NSL-specific implementation handling
  - NSL attribution and artifact separation
not_authoritative_for:
  - project-wide source licensing decisions
  - targeting architecture outside the Afghanistan NSL
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified Afghanistan NSL data-use document
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Afghanistan-NSL v1.0 – Datenverwendung und Umsetzung

## 1. Autorität

Die projektweite Entscheidung über Quellen, Originaldateien, normalisierte Daten, abgeleitete Projektdateien und Veröffentlichung wird ausschließlich geführt in:

- [`OMW-GOV-SOURCE-USE`](../sources/graveyard-of-empires.md).

Dieses Dokument konkretisiert nur die technische Behandlung der Afghanistan-NSL v1.0. Die fachliche Targeting-Architektur steht in:

- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md).

Der vollständige frühere Text bleibt erhalten:

- [`Legacy-Datenverwendungsrichtlinie`](../evidence/source-records/legacy-afghanistan-nsl-data-use-policy.md).

## 2. Verbindliche Projektverwendung

```text
Datensatz: Afghanistan NSL v1.0
Einträge:  2.954
Quelle:    Graveyard of Empires
Status:    APPROVED_FOR_PROJECT_USE
```

Zulässig und vorgesehen sind:

- unveränderte Ablage rechtmäßig bereitgestellter Originalartefakte nach Projektentscheidung;
- Normalisierung mit stabiler Quell-ID und Provenienz;
- Konvertierung von WGS84 in kartenversionabhängige DCS-/MOOSE-Koordinaten;
- Ergänzung von OMW-Kategorien, Schutzradien, Polygonen und Prüfstatus;
- Speicherung als Lua, JSON, CSV, GeoJSON oder anderes Laufzeitformat;
- Verwendung als verpflichtende Zielschutzprüfung vor projektseitiger Zielnominierung oder Angriffserzeugung.

## 3. Trennung der Datenebenen

| Ebene | Behandlung |
|---|---|
| Originaldateien | unverändert mit Hash, Quelle, Version und Zugriffsnachweis |
| normalisierte WGS84-Daten | OMW-Arbeitsdaten mit unveränderter Quell-ID |
| DCS-/MOOSE-Koordinaten | kartenversionabhängige Ableitung |
| Kategorien und Bezeichnungen | Quelle, Korrektur und OMW-Normalisierung getrennt |
| Schutzradien und Schutzpolygone | ausdrückliche OMW-Sicherheits- und Gameplay-Entscheidung |
| Audit und Acceptance | DCS-Version, Datenstand, Toolstand und Prüfergebnis dokumentieren |

Ursprüngliche WGS84-Werte werden niemals durch DCS-abgeleitete Werte überschrieben.

## 4. Attribution

Sämtliche Credits für ursprüngliche Recherche und Quelldatensatz gehen an **Graveyard of Empires**. Attribution und Provenienz sind mindestens in Quellartefakt-Manifesten, normalisierten Datensätzen, Laufzeitdateien, Dokumentation, Missionsbriefings und Release-Hinweisen zu führen.

## 5. Implementierungsstatus

Die Datenverwendung ist verbindlich geregelt. Die vollständige Laufzeitintegration und DCS-Alignment-Acceptance bleiben separat zu implementieren und nachzuweisen.
