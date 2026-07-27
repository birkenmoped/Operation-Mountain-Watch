---
document_id: OMW-ADR-0003-ME-GROUP-TEMPLATES
status: BINDING
document_class: ADR
owning_policy: OMW-GOV-001
authoritative_for:
  - use of Mission Editor Late Activation groups as primary spawn templates
  - separation of persistent entity IDs from DCS and MOOSE runtime names
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented preference for fully dynamic DCS group tables
superseded_by:
source_branch: design/map-and-unit-catalog
source_commit: fca101b4cf207719941700dd98ec86d92adf1abb
validated_in_dcs: partial
---

# ADR 0003 – Mission-Editor-Gruppen als primäre Spawnvorlagen

## Kontext

Die Kampagne muss physische Gruppen dynamisch materialisieren, virtualisieren und mit reduziertem Zustand wiederherstellen. Vollständig dynamische DCS-Gruppentabellen erfordern die Pflege zahlreicher DCS-spezifischer Felder. MOOSE-Laufzeitnamen dürfen zugleich nicht als persistente Kampagnenidentität verwendet werden.

## Entscheidung

Reguläre Bodenverbände, Konvois, QRFs, Garnisonen, rote Zellen und AI-Luftfahrzeuge werden grundsätzlich aus wiederverwendbaren Mission-Editor-Gruppen erzeugt, die auf `Late Activation` stehen.

Standardmechanismen sind:

```lua
SPAWN:New()
SPAWN:NewWithAlias()
```

Der CampaignState vergibt unabhängige strategische Entity-IDs. `SPAWN:NewFromTemplate()` und vollständig dynamische DCS-Gruppentabellen sind nur für begründete, MOOSE-first geprüfte und separat getestete Sonderfälle zulässig.

## Regeln

- Template-Namen beginnen mit `TPL_`.
- Template- und Aliasnamen enthalten kein `#`.
- Jedes Template besitzt externe Metadaten.
- Spieler-Slots sind keine dynamischen Spawnvorlagen.
- Persistente Entity-IDs werden nie aus MOOSE-Laufzeitnamen abgeleitet.
- Dynamische Gruppentabellen benötigen dokumentierte Lücke, Eigentümerfreigabe und Acceptance.

## Konsequenzen

Mission-Editor-Details bleiben prüfbar; komplexe Payloads, Formationen und Länderzuordnungen werden nicht unnötig in Lua rekonstruiert. Änderungen an Zusammensetzungen benötigen dafür teilweise Missionseditor-Arbeit und synchronisierte Metadaten.
