---
document_id: OMW-GOV-SOURCE-USE
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Graveyard of Empires attribution
  - source evaluation
  - original file use
  - normalized and derived data publication
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - project rules that treat missing explicit licence text as an automatic implementation blocker
  - project rules that generally prohibit repository inclusion of provided original files
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: SOURCE_USE_POLICY
scenario_period:
source_commit: GIT_HISTORY
superseded_by:
---

# Graveyard of Empires – Credits, Quellen- und Dateinutzung

## Verbindliche Credit-Zuordnung

**Sämtliche Credits für die zugrunde liegende Recherche, Datensammlung, Zusammenstellung, historische Aufbereitung und die veröffentlichten Afghanistan-/OEF-/ISAF-Missionsdesign-Unterlagen gehen an:**

- **Graveyard of Empires**
- <https://www.patreon.com/cw/graveyard4DCS>

Operation Mountain Watch übernimmt, strukturiert, normalisiert und verarbeitet Inhalte für die eigene DCS-Missionsgestaltung. Das Projekt beansprucht keine eigene Urheberschaft an der von Graveyard of Empires geleisteten Recherche oder Zusammenstellung.

Diese Credit-Zuordnung gilt projektweit für alle daraus abgeleiteten:

- Dokumentationen und Tabellen;
- Frequenz-, Callsign-, ACO-, AAR-, ROZ-, CSAR- und NSL-Datensätze;
- CombatFlite-, KMZ-, Karten- und Kneeboard-Auswertungen;
- normalisierten CSV-, GeoJSON-, Lua- und Konfigurationsdaten;
- DCS- und MOOSE-Umsetzungen;
- Missionspakete und öffentliche Projektartefakte.

## Quellenverständnis

Graveyard of Empires erklärt, dass die dargestellten Informationen aus offenen Quellen stammen und für eine möglichst realitätsnahe Missionsgestaltung im DCS-Afghanistan-Theater aufbereitet werden.

Für Operation Mountain Watch gilt:

1. Die eigentliche Quellenarbeit, Auswahl, Einordnung und Zusammenstellung wird sichtbar Graveyard of Empires zugerechnet.
2. Konkrete Aussagen werden nach Zeit, Ort, Aussagekraft und verfügbarer Evidenz eingeordnet.
3. Nicht verfügbare Inhalte werden nicht durch Allgemeinwissen ersetzt oder rekonstruiert.
4. Projektseitige Entscheidungen, Annahmen und technische Umsetzungen werden von Quellenaussagen getrennt gekennzeichnet.
5. Wo Primär- oder Fachquellen bekannt sind, werden sie zusätzlich dokumentiert.

## Verbindlicher Nutzungsumfang

Für alle von Graveyard of Empires frei zugänglich veröffentlichten oder vom Projektinhaber rechtmäßig bereitgestellten Informationen und Dateien gilt bis auf Weiteres:

- vollständige fachliche Auswertung ist zulässig und ausdrücklich erwünscht;
- Fakten, Verfahren, Geometrien, Tabellen, Organisationsbeziehungen und Missionsdesign-Erkenntnisse dürfen vollständig in eigene Projektstrukturen überführt werden;
- Inhalte dürfen paraphrasiert, übersetzt, normalisiert, tabellarisch neu strukturiert und technisch implementiert werden;
- Originaldateien dürfen nach Entscheidung des Projektmanagers beziehungsweise Autors in das öffentliche oder interne Repository aufgenommen werden;
- normalisierte und abgeleitete Daten dürfen im Repository, in Missionen, Kneeboards, Briefings und Distributionspaketen gespeichert und weitergegeben werden;
- dies gilt insbesondere für NSL-, ACO-, AAR-, ROZ-, Callsign-, Frequenz-, CombatFlite-, KMZ-, Karten- und Referenzdateien;
- die fehlende Nennung einer ausdrücklichen Lizenz im Ausgangsmaterial ist innerhalb dieser Projektentscheidung kein automatischer Implementierungsblocker;
- Attribution, Quellenlink und konkrete materialspezifische Bedingungen bleiben verpflichtend.

## Originaldateien

Die Aufnahme einer Originaldatei erfolgt bewusst und nicht automatisch. Vor einer Veröffentlichung sind mindestens zu prüfen:

```yaml
source_creator:
source_url:
access_status: FREE | PROVIDED_LAWFULLY | PAYWALLED | UNKNOWN
project_relevance:
repository_scope: PUBLIC | INTERNAL | MISSION_PACKAGE_ONLY
specific_usage_terms:
attribution_present:
project_manager_decision:
```

Der Projektmanager beziehungsweise Autor entscheidet über:

- öffentliche Repository-Aufnahme;
- interne Ablage;
- Aufnahme nur in Missionspakete;
- ausschließliche Verwendung normalisierter oder abgeleiteter Daten.

## Paywall- und Zugriffsschranke

Nicht rechtmäßig zugängliche Inhalte hinter einer Patreon- oder sonstigen Paywall werden nicht:

- beschafft;
- umgangen;
- aus Fragmenten rekonstruiert;
- als vollständig bekannt dargestellt.

Zulässige Grundlagen sind:

- frei veröffentlichte Beiträge und Anhänge;
- vom Projektinhaber rechtmäßig bereitgestellte Dateien;
- offene Originalquellen;
- Materialien mit einer konkreten Erlaubnis oder Projektfreigabe.

Nicht verfügbare Bestandteile bleiben `AUSSTEHEND`.

## Konkrete Nutzungsbedingungen

Materialspezifische Bedingungen bleiben wirksam. Enthält eine Datei beispielsweise ein ausdrückliches Verbot der Veränderung oder Weitergabe, muss dies für genau diese Datei berücksichtigt werden. Die zentrale Projektfreigabe hebt konkrete entgegenstehende Bedingungen nicht stillschweigend auf.

## Rechtliche und projektinterne Einordnung

Diese Regel ist eine verbindliche interne Projekt- und Veröffentlichungsentscheidung. Sie stellt nicht fest, dass sämtliche Materialien gemeinfrei, lizenzfrei oder außerhalb des Urheberrechts liegen.

Die Projektentscheidung lautet vielmehr:

- die Materialien werden für ihren erkennbaren DCS-Missionsdesign-Zweck verwendet;
- die Urheberschaft und Quellenzusammenstellung werden sichtbar zugerechnet;
- der Projektmanager entscheidet über den konkreten Weitergabeumfang;
- konkrete Nutzungsbedingungen und Zugriffsschranken werden beachtet.

## Standard-Creditzeile

Mindestens zu verwenden:

> **Research and source compilation credits: Graveyard of Empires — <https://www.patreon.com/cw/graveyard4DCS>**

oder:

> **Credits für Recherche und Quellenzusammenstellung: Graveyard of Empires — <https://www.patreon.com/cw/graveyard4DCS>**

## Dokumentationspflicht

Bei jeder weiteren Quellenübernahme wird festgehalten:

- konkreter Beitrag, Link oder Anhang;
- Zugriffsstatus;
- tatsächlich ausgewerteter Inhalt;
- nicht verfügbare Bestandteile;
- Originaldatei, normalisierte Daten und projektspezifische Ableitungen getrennt;
- spezifische Nutzungsbedingungen;
- Entscheidung über den Weitergabeumfang;
- sichtbarer Credit;
- bekannte Primär- und Sekundärquellen.

## Verhältnis zu branchspezifischen Richtlinien

Branchspezifische Quellen- oder NSL-Richtlinien dürfen fachliche Details ergänzen. Sie dürfen diese zentrale Regel nicht parallel ersetzen oder widersprüchlich neu definieren. Vor dem Merge werden doppelte Richtlinientexte entfernt oder als Verweis auf `OMW-GOV-SOURCE-USE` umgestellt.
