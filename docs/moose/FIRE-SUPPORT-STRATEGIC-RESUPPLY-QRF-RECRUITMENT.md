---
document_id: OMW-MOOSE-FSSR-QRF-RECRUITMENT
status: PLANNED
document_class: MOOSE_INTEGRATION
authoritative_for:
  - Fire Support Strategic Resupply QRF recruitment filtering
  - MOOSE-first separation between capability constraints and asset selection
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# QRF-Rekrutierung über MOOSE-Anforderungsfilter

## Problem

Guard und lokale QRF verwenden im aktuellen OMW-Unterbau beide `AUFTRAG.Type.ONGUARD`. Sobald in derselben lokalen `BRIGADE` mehrere ONGUARD-fähige Cohorts existieren, darf OMW den konkreten QRF-Asset nicht selbst auswählen. Gleichzeitig muss der Auftrag ausdrücken können, welche **Fähigkeitsklasse** benötigt wird, damit MOOSE nicht einen fachlich ungeeigneten Guard-Cohort rekrutiert.

## Gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsächlich verwendeten `Moose.lua` sind öffentliche AUFTRAG-Anforderungsfilter vorhanden:

```lua
AUFTRAG:SetRequiredAttribute(Attributes)
AUFTRAG:SetRequiredProperty(Properties)
```

Der gepinnte Source führt die hinterlegten Missionsanforderungen in den LEGION-Rekrutierungspfad. Damit bleiben Cohort-/Assetbewertung und Rekrutierung bei MOOSE.

## OMW-Vertrag

`OMW_FireSupStratResupply_QrfMissionFactory` akzeptiert optional:

```text
requiredAttributes
requiredProperties
```

und leitet diese unverändert an den erzeugten MOOSE-`AUFTRAG` weiter. Ohne Konfiguration setzt OMW **keinen** impliziten Filter.

Die generische Runtime stellt dafür bereit:

```text
qrfRequiredAttributes
qrfRequiredProperties
```

Diese Werte sind Fähigkeitsanforderungen, keine Asset-IDs, Cohort-Namen oder Template-Auswahl. Verboten bleibt insbesondere:

```text
OMW chooses concrete QRF asset/cohort
OMW AssignCohort / explicit asset selection
CampaignState selects operational MOOSE asset
```

Der zulässige Pfad bleibt:

```text
Incident / capability need
-> QRF AUFTRAG
-> SetRequiredAttribute / SetRequiredProperty when required
-> local BRIGADE / LEGION
-> MOOSE evaluates eligible cohorts/assets
-> MOOSE recruits operational asset
```

## Acceptance-2-Konfiguration

Für die konkrete Honaker-Acceptance wird verwendet:

```text
qrfRequiredAttributes = GROUP.Attribute.GROUND_APC
```

Diese Testkonfiguration ist durch die bestehende Foundation-Fixture `TPL_BLUE_GND_QRF_MIXED_6` und frühere reale DCS-Ausgabe begründet, die dieses Template als `Ground_APC` klassifiziert. Sie ist **keine** projektweite Aussage, dass jede zukünftige QRF ein APC sein muss.

Der Production-Factory-Code enthält deshalb keinen festen `Ground_APC`-Default.

## Statusgrenze

Source und Unit-Test-Vertrag sind für die gepinnte MOOSE-Version vorbereitet. Die konkrete Production-Base-QRF-Rekrutierung über diesen Filter gilt erst nach erfolgreichem Acceptance-2-DCS-Lauf als praktisch bestätigt.
