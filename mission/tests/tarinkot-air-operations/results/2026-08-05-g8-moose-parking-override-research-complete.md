---
document_id: OMW-TEST-TKOT-G8-MOOSE-PARKING-OVERRIDE-RESEARCH-2026-08-05
status: BINDING
document_class: SOURCE_RESEARCH_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - completion of the mandatory G8 MOOSE parking override research
  - post-research Tarinkot gate state
not_authoritative_for:
  - authorization of an override, MIZ mutation, parking-pool change or DCS rerun
  - G8 vertical-departure acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - OMW-TEST-TKOT-AIR-OPS-STATUS-FREEZE-2026-08-05 for current-next-action authority
superseded_by: []
---

# G8 – MOOSE-Parking-Override-Recherche abgeschlossen

## Ergebnis

Die im Status-Freeze vorgeschriebene Prüfung ist abgeschlossen. Vollständiger technischer Befund:

- [`docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md`](../../../../docs/moose/WAREHOUSE-PARKING-OVERRIDE-RESEARCH.md)

Kernaussagen:

```text
Kein dokumentierter WAREHOUSE-Setter für scanradius, scanunits,
scanstatics, scanscenery oder verysafe.

Kein dokumentierter WAREHOUSE-Hook für diese Werte.

AIRBASE:FindFreeParkingSpotForAircraft() unterstützt dieselben Parameter,
wird von WAREHOUSE:_FindParkingForAssets() aber nicht verwendet.

SetSafeParkingOn/Off setzt im geprüften Warehouse.lua nur self.safeparking;
dieses Feld wird im WAREHOUSE-Pfad nicht gelesen.

Ein Instanz- oder Klassenoverride ist Lua-technisch möglich,
aber keine offizielle MOOSE-API und weiterhin nicht autorisiert.
```

Vergleich:

```yaml
pinned_moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
checked_master_ng: 490c798848e5991c5d3e4b1ab445f5de9cda2eab
checked_develop: 28a12c6eb3fcd370fe6fba24a9522162e0e7efbf
Warehouse_lua_changed_between_pinned_and_checked_heads: false
```

## Gate-Stand

```yaml
G8_first_runtime_attempt: BLOCKED_MISSING_TARGET_ZONE
G8_second_runtime_attempt: BLOCKED_MOOSE_WAREHOUSE_PARKING_OBSTACLE_CONFLICT
G8_vertical_departure: NOT_PROVEN
MOOSE_parking_override_research: COMPLETE
next_action: OWNER_DECISION
DCS_rerun: BLOCKED
MIZ_mutation: BLOCKED
parking_pool_change: BLOCKED
MOOSE_override: NOT_AUTHORIZED
```

Der Freeze-Snapshot bleibt als historischer Übergabestand unverändert. Dieses Ergebnis taut ausschließlich die Recherchephase auf und verschiebt den Arbeitsstand zum Eigentümerentscheid.

## Kleinster diagnostischer Folgeschritt

Falls ein weiterer DCS-Lauf genehmigt wird, ist die kleinste nicht verhaltensändernde Variante eine instrumentierte Wiederholung mit `WAREHOUSE:SetDebugOn()`. Der vorhandene MOOSE-Code protokolliert dabei Hindernisname, -typ, -größe und Distanz des ersten blockierenden Objekts.

Auch dieser Lauf ist mit diesem Bericht noch nicht genehmigt.
