---
document_id: OMW-UNIT-CATALOG
status: PLANNED
document_class: TEMPLATE_AND_UNIT_CATALOG
owning_policy: OMW-GOV-001
authoritative_for:
  - planned identifier and metadata model for DCS units and templates
  - naming separation between templates, runtime groups and strategic entities
not_authoritative_for:
  - final complete unit catalog
  - unverified DCS type names
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 13 – Einheiten- und Templatekatalog

## 1. Zweck

Der Katalog umfasst nur Einheiten, Gruppen, Templates und Luftfahrzeuge, die in der Kampagne tatsächlich verwendet werden.

Der vollständige frühere Katalogentwurf bleibt unverändert erhalten:

- [`Legacy-Einheiten- und Templatekatalog`](evidence/source-records/legacy-13-unit-catalog.md)

## 2. Vier getrennte Identifikatoren

1. DCS-Typname aus der tatsächlich verwendeten DCS-Version;
2. Mission-Editor-Gruppenname des Templates;
3. Mission-Editor-/Laufzeit-Einheitenname;
4. stabile strategische CampaignState-Entity-ID.

DCS- und MOOSE-Laufzeitnamen dürfen nicht als persistente strategische Primärschlüssel verwendet werden.

## 3. Namensregeln

```text
TPL_<COALITION>_<ROLE>_<VARIANT>
```

Das Zeichen `#` wird in eigenen Template- und Aliasnamen nicht verwendet, weil MOOSE es für Laufzeitsuffixe nutzt.

## 4. Pflichtmetadaten je Template

- Template-Gruppenname;
- Koalition und Land;
- operative Rolle;
- Zusammensetzung und Gruppengröße;
- bestätigte DCS-Typnamen;
- Skill, Formation, Bewaffnung und Loadout;
- Ressourcen- und Wiederbeschaffungskosten;
- Transport- oder Frachtkapazität;
- erlaubte Missionsarten und Geländearten;
- Modul- oder Modabhängigkeiten;
- DCS- und MOOSE-Validierungsstatus.

## 5. Validierungsregel

Interne DCS-Typnamen werden aus der verwendeten DCS-Version per Testmission und Diagnose ausgelesen. Unsichere externe Listen gelten nicht als technische Wahrheit.

Die konkrete Template-Bibliothek und die Spawnstrategie stehen in Dokument 15. Aktive Luftfahrzeugbestände und Client-Grenzen stehen in Dokument 19.
