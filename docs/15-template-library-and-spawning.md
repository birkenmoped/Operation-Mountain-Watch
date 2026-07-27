---
document_id: OMW-TEMPLATE-LIBRARY-SPAWNING
status: BINDING
document_class: TEMPLATE_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - Mission Editor template library and runtime naming strategy
  - standard physical group creation through MOOSE templates
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only exception wording for Lua-built groups
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 15 – Template-Bibliothek und Spawnstrategie

## 1. Grundentscheidung

Reguläre physische Gruppen werden aus wiederverwendbaren Mission-Editor-Templates erzeugt. CampaignState entscheidet über Existenz, Auftrag und Ressourcen; das Template definiert DCS-spezifische Zusammensetzung und Eigenschaften.

Der vollständige frühere Template- und Spawnentwurf bleibt erhalten:

- [`Legacy-Template- und Spawnstrategie`](evidence/source-records/legacy-15-template-library-and-spawning.md)

## 2. Standardverfahren

1. Gruppe im DCS Mission Editor anlegen.
2. `Late Activation` setzen.
3. eindeutigen `TPL_...`-Namen vergeben.
4. Template über MOOSE `SPAWN`, AIRWING-/SQUADRON- oder OPS-Funktion referenzieren.
5. an validierter Laufzeitposition, Zone oder Airbase erzeugen.
6. Laufzeitgruppe mit stabiler CampaignState-Entity-ID verknüpfen.
7. Start, Events, Verlust und Abschluss protokollieren.

Vollständig in Lua aufgebaute DCS-Gruppentabellen sind keine Standardlösung. Sie benötigen eine dokumentierte MOOSE-Prüfung und ausdrückliche Projektinhaberfreigabe.

## 3. Namensebenen

- Template-ID: stabile Mission-Editor-Gruppe;
- MOOSE-/DCS-Laufzeitname: flüchtige physische Repräsentation;
- DCS-Einheitenname: flüchtige Unit-Referenz;
- CampaignState-Entity-ID: persistente strategische Identität.

`#` ist in eigenen Template- und Aliasnamen verboten.

## 4. Template-Bibliothek

Die Bibliothek wird nach Koalition, Domäne und Rolle strukturiert. Jedes Template besitzt Metadaten aus Dokument 13 und wird gegen die verwendete DCS-/MOOSE-Version validiert.

## 5. Spawn- und Beobachtungsregeln

- keine Spawns in plausibler Spielerbeobachtung;
- keine Doppelzählung von Templates und Kampagnenbestand;
- Position, Fahrtrichtung und Gelände vor Spawn validieren;
- Materialisierung und Dematerialisierung nach Dokument 07;
- keine ungeprüfte Übernahme alter Controller-Aufgaben;
- Fehler und fehlende Templates fail-fast protokollieren.
