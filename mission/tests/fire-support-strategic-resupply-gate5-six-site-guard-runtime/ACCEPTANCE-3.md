---
document_id: OMW-FIRE-SUPPORT-GATE5-GUARD-PRODUCTION-MATERIALIZER-ACCEPTANCE-3
status: PLANNED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-5 DCS regression of the productive Guard PATHLINE materialization adapter
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5 - Guard Production Materializer Acceptance 3

## Ziel

Acceptance 2 hat den eng begrenzten Warehouse-Spawn-Adapter im Testscope erfolgreich in DCS validiert. Der Projektinhaber hat am 12.09.2026 die produktive Nutzung genau dieses Musters fuer Guard-Materialisierung freigegeben, sofern kein effektiver oeffentlicher MOOSE-Weg existiert.

Die erneute Source-Pruefung des gepinnten MOOSE-Stands bestaetigt diese Voraussetzung: `WAREHOUSE:SetSpawnZone(...)` bestimmt eine Spawnzone, `WAREHOUSE:_SpawnAssetGroundNaval(...)` waehlt daraus eine Koordinate und verschiebt die bestehende relative Template-Geometrie. `WAREHOUSE:SetValidateAndRepositionGroundUnits(...)` kann Positionen auf freie Flaechen korrigieren, bietet aber keinen Vertrag fuer die exakte kompakte Ausrichtung aller Units auf einem owner-authored PATHLINE-Segment. Damit existiert fuer die benoetigte exakte 9-Mann-Geometrie kein gleichwertiger oeffentlicher MOOSE-Pfad.

## Produktive Ausnahmegrenze

Zugelassen ist ausschliesslich:

```text
Guard asset
-> normaler MOOSE BRIGADE / WAREHOUSE Lifecycle
-> direkt vor Ground-Asset-Materialisierung exakte Unit-Positionen/Headings
   auf erstem Guard-PATHLINE-Segment setzen
-> normaler MOOSE PLATOON / ARMYGROUP / AUFTRAG Lifecycle
```

Nicht freigegeben sind:

```text
- allgemeine private-MOOSE-Nutzung;
- eigene Asset-Selektion;
- eigene Queue oder Retry-Queue;
- Ersatz des COMMANDER-/BRIGADE-Recruitments;
- Convoy-/QRF-/ARTY-/CAS-/Resupply-Nutzung dieser Ausnahme ohne neue Owner-Freigabe;
- Guard-Abhaengigkeit von ZON_BLUE_GND_*_ACCESS;
- MIZ-Mutation.
```

Produktives Modul:

```text
scripts/ground/OMW_GuardPathlineMaterializationAdapter.lua
```

Acceptance-Source:

```text
mission/tests/fire-support-strategic-resupply-gate5-six-site-guard-runtime/src/03-six-site-guard-production-materializer-acceptance.lua
```

## DCS-Pruefung

Die gleiche Six-Site-Geometrie wie in Acceptance 2 wird verwendet:

```text
JALALABAD_FENTY
COP_FORTRESS
FOB_JOYCE
FOB_WRIGHT
COP_HONAKER
FOB_BOSTICK
```

PASS nur wenn fuer alle sechs Sites gilt:

```text
- produktives Materializer-Modul wird verwendet;
- Guard materialisiert PATHLINE-ausgerichtet;
- Guard lebt;
- Route wurde gestartet;
- mindestens 25 m Bewegung innerhalb 300 Sekunden;
- visuell keine offensichtlichen Spawn-/HESCO-/Gebaeude-/Static-Probleme;
- keine Convoy-ACCESS-Zone ist Teil der Guard-Materialisierung.
```

Acceptance 2 bleibt als exakte Builder-4-Evidenz unveraendert gueltig. Acceptance 3 prueft die Auslagerung desselben eng begrenzten Mechanismus in das produktive Modul; bis zu einem realen DCS-Lauf bleibt `validated_in_dcs: false`.
