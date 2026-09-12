---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-LOCAL-LEGION-BRIDGE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed local LEGION/BRIGADE mission handoff for Fire Support / Strategic Resupply
  - no-preselection boundary for installation-local Guard and QRF support
not_authoritative_for:
  - DCS runtime validation
  - concrete six-site QRF composition, route or response anchor
  - approval of non-MOOSE asset selection or dispatch
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fire Support / Strategic Resupply – Local LEGION Bridge

## Zweck

`scripts/campaign/OMW_FireSupStratResupply_LegionBridge.lua` bildet die kleinste MOOSE-first-Grenze fuer standortlokale Ground-Unterstuetzung. Der Adapter waehlt **kein** operatives Asset, keinen COHORT und kein Template aus. Er loest nur die fuer den Standort konfigurierte lokale MOOSE-`LEGION`/`BRIGADE`-Instanz auf, erzeugt ueber eine injizierte Factory einen oeffentlichen MOOSE-Auftrag und uebergibt diesen an `LEGION:AddMission(...)`.

Der Pfad lautet:

```text
Base demand
-> site-local LEGION/BRIGADE resolver
-> public AUFTRAG factory
-> LEGION:AddMission(AUFTRAG)
-> MOOSE mission queue / cohort capability / asset recruitment
-> ARMYGROUP / DCS lifecycle
```

## Source-Review

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Im tatsaechlich verwendeten `Moose.lua` ist `LEGION:AddMission(Mission)` oeffentlich dokumentiert. Der Vertrag beschreibt ausdruecklich, dass die LEGION die besten verfuegbaren Assets fuer den Auftrag auswaehlt und den Auftrag startet, sobald er bereit ist. `BRIGADE` verwendet den geerbten LEGION-Missionsqueue-Pfad und verarbeitet diesen in seinem Statuszyklus.

Fuer Ground-Response-Auftraege stehen oeffentliche `AUFTRAG`-Konstruktoren zur Verfuegung, darunter `AUFTRAG:NewONGUARD(Coordinate)`. `AUFTRAG:SetRequiredAssets(...)` und der native `Cancel()`-Lifecycle sind im gepinnten Stand ebenfalls vorhanden.

Damit bestaetigt sich der bereits in Gate 1 dokumentierte MOOSE-first-Befund:

```text
QRF/Guard demand
-> Ground AUFTRAG
-> COMMANDER oder bewusst engere lokale BRIGADE/LEGION-Grenze
-> MOOSE recruitment
```

Eine eigene OMW-QRF-Assetliste oder Retry-Queue ist nicht erforderlich und bleibt verboten.

## Local-first-Grenze

Die projektweite Alarm-/QRF-Entscheidung fordert zuerst lokal verfuegbare geeignete Faehigkeiten. Fuer einen bewusst lokalen QRF-Bedarf darf die Site deshalb ihre **lokale BRIGADE als organisatorische Ausfuehrungsgrenze** vorgeben. Das ist keine operative Asset-Vorselektion: innerhalb dieser BRIGADE entscheidet weiterhin MOOSE ueber COHORT und konkretes Warehouse-Asset.

Externe Supportfaehigkeiten mit mehreren moeglichen Providern bleiben dem `COMMANDER`-Aggregationspfad vorbehalten.

## Noch nicht festgelegt

Der Bridge legt absichtlich nicht fest:

```text
- welcher Ground-AUFTRAG die konkrete QRF-Taktik je Site beschreibt;
- welche Response-Coordinate / owner-authored Route verwendet wird;
- welche Infantry-/Vehicle-Kombination Phase 1 lokal tatsaechlich bereitstellt;
- welche konkrete BRIGADE-Objektinstanz beim Runtime-Bootstrap zu welchem siteId gehoert.
```

Die Ground-Domain-Baseline dokumentiert zwar die operativen Zuordnungen `BDE_BLUE_GND_*` zu den sechs Installationen, aber die produktive Runtime muss die tatsaechlichen MOOSE-Objekte injizieren bzw. aufloesen. Es werden keine Namen in physische Asset-Selektion umgedeutet.

## Contract-Test

```text
tests/mission-demand/test_fire_support_strategic_resupply_legion_bridge.lua
```

Der Test prueft:

- site-lokale LEGION-Aufloesung;
- genau einen `AddMission`-Aufruf pro Demand;
- keine Beruehrung einer anderen Site-LEGION;
- idempotenten Duplicate-Dispatch;
- nativen `Cancel()`-Forward;
- sauberes `SITE_LEGION_NOT_CONFIGURED` ohne Ersatz-/Fallbackselektion.

Das ist CI-/Contract-Evidenz und kein DCS-Runtime-PASS.
