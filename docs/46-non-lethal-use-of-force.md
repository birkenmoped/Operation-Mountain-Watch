---
document_id: OMW-ROE-NON-LETHAL-USE-OF-FORCE
status: PLANNED
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: PARTIAL
owning_policy: OMW-GOV-001
authoritative_for:
  - source-derived Show of Presence and Show of Force design requirements
  - explicit separation of available and unavailable source material
not_authoritative_for:
  - aircraft-specific flight clearance
  - runtime implementation acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - PARTIAL and PLANNED combined as document status
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 46 – Non-Lethal Use of Force: Show of Presence und Show of Force

## 1. Einordnung

Dieses Dokument ist eine geplante, quellenbasierte Missionsdesign-Referenz. Es ist noch keine technisch akzeptierte DCS-/MOOSE-Implementierung.

Der vollständige frühere Quellen- und Auswertungstext bleibt unverändert erhalten:

- [`Legacy-Quellenfassung`](evidence/source-records/legacy-46-non-lethal-use-of-force-source-capture.md)

## 2. Quellenstatus

```yaml
show_of_presence: VERIFIED_FROM_PROVIDED_SOURCE
show_of_force: VERIFIED_FROM_PROVIDED_SOURCE
introduction_to_show_of_force: PENDING_SOURCE
source_status: PARTIAL
```

Nicht vorliegende Inhalte werden weder rekonstruiert noch durch Allgemeinwissen als Originalquelleninhalt ausgegeben. Die Nutzung folgt [`OMW-GOV-SOURCE-USE`](sources/graveyard-of-empires.md).

## 3. Projektseitige Begriffsabgrenzung

### Show of Presence

Präsenz, Beobachtung und sichtbare Bereitschaft ohne absichtlich einschüchternden Hochgeschwindigkeits- oder Tiefflug. Ziel ist Abschreckung, Rückversicherung oder Lagebeobachtung.

### Show of Force

Gezielte, nichtkinetische Demonstration militärischer Fähigkeit mit definiertem Zweck, freigegebenem Profil, Sicherheitsabständen und Abbruchkriterien. Eine SOF ist keine pauschale Freigabe für beliebige Tiefflugmanöver.

## 4. Verbindliche Designanforderungen

- Auftragstyp, gewünschter Effekt und freigebende Stelle müssen eindeutig sein.
- Friendly Positions, Zivilisten, Gelände, Hindernisse, Wetter und Bedrohung sind zu berücksichtigen.
- Flugprofil und Mindestabstände werden muster- und missionsspezifisch festgelegt.
- Nichtkinetische Wirkung wird als eigener Auftragserfolg modelliert.
- Eskalation zu Waffenwirkung erfordert einen neuen beziehungsweise aktualisierten Auftrag und die vollständige Zielprüfung.
- Spieler und KI dürfen dasselbe Ereignis nicht unabhängig doppelt bearbeiten.

## 5. Noch offene Arbeiten

- vollständige Einführungquelle beschaffen und auswerten;
- musterbezogene Profile für DCS validieren;
- Geländehöhe, Geschwindigkeit und Abstände testen;
- Multiplayer- und KI-Verhalten prüfen;
- C2-, ROE-, NSL- und MissionDemand-Anbindung implementieren;
- reproduzierbare Acceptance-Berichte erstellen.
