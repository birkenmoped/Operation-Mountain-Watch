---
document_id: OMW-GOV-MOOSE-FIRST
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - MOOSE-first development workflow
  - non-MOOSE exception approval
  - diagnostics and test implementation policy
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - technical justification without explicit owner approval
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: GOVERNANCE_POLICY
scenario_period:
source_commit: GIT_HISTORY
superseded_by:
---

# Verbindliche MOOSE-First-Entwicklungsrichtlinie

## Status

**Mandatory / projektweit verbindlich**

Diese Richtlinie gilt für sämtliche Lua-Entwicklung in **Operation Mountain Watch**:

- Missionslogik;
- Diagnostik und Testskripte;
- Hilfsfunktionen und Runtime-Koordinatoren;
- Persistenz-, CampaignState- und Warehouse-Anbindung;
- Routing, Spawn, Detection, Scheduling und Lifecycle;
- sämtliche projektspezifischen Erweiterungen.

## Grundsatz

Bevor eigener Lua-Code oder eine eigene Funktion zur Lösung einer Problemstellung entwickelt wird, muss zuerst geprüft werden, ob MOOSE die benötigte Funktionalität vollständig oder ausreichend bereitstellt.

Vorhandene MOOSE-Klassen, Methoden, Ereignismodelle, Scheduler, Sets, Wrapper, Dispatcher, OPS-Klassen, FSMs, Zonen-, Coordinate-, Routing-, Spawn-, Detection-, Warehouse-, AIRWING-, SQUADRON-, AUFTRAG- und Transportfunktionen sind vorrangig zu verwenden.

Operation Mountain Watch entwickelt auf Basis von MOOSE und implementiert vorhandene Framework-Funktionalität nicht unnötig parallel neu.

## Verbindlicher Rechercheweg

Die Reihenfolge ist verbindlich. Ein Schritt darf nur ausgelassen werden, wenn seine Nichtanwendbarkeit dokumentiert wird.

### 1. Passende MOOSE-Dokumentation prüfen

- Die Dokumentation muss zur tatsächlich geladenen MOOSE-Version beziehungsweise zum verwendeten Branch passen.
- Klassen, Methoden, Events, FSM-Callbacks, Konfigurationsmöglichkeiten und Erweiterungspunkte sind systematisch zu suchen.
- Develop-Dokumentation: <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html>
- Stable-/Master-Dokumentation: <https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/>
- Eine Dokumentationsfundstelle beweist noch nicht, dass die Methode in der tatsächlich geladenen `Moose.lua` enthalten ist.

### 2. Tatsächlichen MOOSE-Quellcode prüfen

Zu kontrollieren sind mindestens:

- Signatur und Parameterreihenfolge;
- Rückgabewerte;
- Zustandsübergänge;
- FSM-Events und Callbacks;
- interne Voraussetzungen und Seiteneffekte;
- Versions- und Branchabhängigkeiten;
- Fehler- und Abbruchverhalten.

Quellrepository: <https://github.com/FlightControl-Master/MOOSE>

Nicht dokumentierte interne Felder und Tabellen gelten nicht automatisch als stabile öffentliche API.

### 3. Offizielle Demo- und Testmissionen prüfen

Zu prüfen sind insbesondere Konstruktorreihenfolge, Startzeitpunkt, Mission-Editor-Voraussetzungen, Events und das Zusammenspiel mehrerer Klassen.

- <https://github.com/FlightControl-Master/MOOSE_MISSIONS>
- <https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED>

Foren-, Discord-, Guide- und Fremdrepository-Beispiele sind nur ergänzende Hinweise und müssen gegen den tatsächlich verwendeten Quellstand geprüft werden.

### 4. MOOSE-Lösung priorisieren

Es gilt folgende Reihenfolge:

1. vorhandene MOOSE-Funktion direkt verwenden;
2. vorhandene MOOSE-Funktion konfigurieren oder kombinieren;
3. dokumentierte MOOSE-Events, Callbacks oder Erweiterungspunkte verwenden;
4. eine kleine Adapter- oder Koordinationsschicht um MOOSE erstellen;
5. vollständig eigene oder Native-DCS-Logik nur dann entwerfen, wenn keine tragfähige MOOSE-Lösung existiert.

Direkte Zugriffe auf MOOSE-Interna wie `_DATABASE` sind auf begründete Diagnose- oder Validierungsfälle zu beschränken und ausdrücklich zu dokumentieren.

### 5. Technische Lücke dokumentieren

Vor einer Ausnahme sind mindestens festzuhalten:

```yaml
requirement:
moose_version:
moose_documentation_checked:
moose_classes_and_methods_evaluated:
moose_source_locations:
official_examples_checked:
verified_limitation:
smallest_required_fallback:
integration_with_moose:
planned_acceptance_test:
```

Eine bloße Aussage wie „MOOSE ist nicht erforderlich“ oder „Native DCS ist einfacher“ genügt nicht.

### 6. Ausdrückliche Projektinhaberfreigabe einholen

Eine technische Begründung, ein erfolgreicher Prototyp oder ein bestandener Test genehmigt keine Abweichung.

**Nur der Projektinhaber darf eine produktive Nicht-MOOSE-, Native-DCS- oder projektspezifische Parallelimplementierung freigeben.**

Die Freigabe muss dokumentiert werden, mindestens mit:

```yaml
owner_approval:
approved_scope:
approved_fallback:
conditions:
required_regressions:
review_trigger:
```

Ohne ausdrückliche Freigabe bleibt die Lösung:

- `DRAFT`,
- `EXPLORATORY`, oder
- `HISTORICAL_TEST_FIXTURE`.

Sie darf nicht als Produktionsarchitektur, neue verbindliche Baseline oder stillschweigende Ausnahme weiterverwendet werden.

### 7. Erst danach Eigenentwicklung umsetzen

Eigener Lua-Code bleibt grundsätzlich möglich, wenn MOOSE die Anforderung nachweislich nicht oder nicht ausreichend abbildet, insbesondere bei:

- projektspezifischer Kampagnenlogik und Persistenz;
- domänenspezifischen Zustandsmodellen und Datenstrukturen;
- klar abgegrenzten Integrationen mit der DCS-Scripting-API;
- dokumentierten MOOSE-Fehlern oder Framework-Einschränkungen;
- sehr kleinen Adaptern, die MOOSE ergänzen und nicht ersetzen.

Auch in diesen Fällen sind MOOSE-Lifecycle, Events, Wrapper und öffentliche Methoden soweit wie möglich weiterzuverwenden.

### 8. Reproduzierbar testen und dokumentieren

Für jede neue oder wesentlich geänderte Funktion sind mindestens zu dokumentieren:

- verwendete MOOSE-Klasse und Methode;
- Zweck der Verwendung;
- MOOSE-Branch, Commit und Hash der tatsächlich geladenen `Moose.lua`;
- geprüfte Methodensignatur;
- Einschränkungen und Voraussetzungen;
- relevante FSM-Events oder Callbacks;
- projektspezifische Ergänzung;
- genehmigte Ausnahme, falls vorhanden;
- zugehöriger OMW-Quellcode;
- DCS-Version, Mission, Commit und Acceptance-Ergebnis.

Kann ein Versionsnachweis eines älteren Tests nicht mehr vollständig ermittelt werden, wird die verbleibende Lücke ausdrücklich dokumentiert. Ein Commit oder Hash darf nicht geraten werden.

## Verbindlicher Prüfablauf vor Eigenentwicklungen

1. Fachliche und technische Anforderung beschreiben.
2. Passende MOOSE-Dokumentation durchsuchen.
3. Tatsächlich verwendeten MOOSE-Quellcode und Signaturen prüfen.
4. Offizielle Demo- und Testmissionen untersuchen.
5. Konfiguration, Kombination, Events, Callbacks, FSMs und vorhandene Klassen bewerten.
6. Geeignete MOOSE-Funktionen und Einschränkungen dokumentieren.
7. Technische Lücke und kleinstmöglichen Fallback dokumentieren.
8. Ausdrückliche Projektinhaberfreigabe einholen.
9. Erst danach den genehmigten projektspezifischen Code entwickeln.
10. Lösung durch reproduzierbaren DCS-Test und Ergebnisbericht absichern.

## Besondere Regel für Diagnose- und Testskripte

Diagnostik und Tests sind nicht von MOOSE-First ausgenommen.

Ein nativer DCS-Test kann sinnvoll sein, wenn er gezielt eine DCS-Engine-Fähigkeit untersucht, für die MOOSE keine geeignete Abstraktion bietet oder selbst nur einen Wrapper über dieselbe native API bereitstellt. Auch dann müssen:

- die MOOSE-Prüfung nachgeholt werden;
- der Zweck des Native-DCS-Zugriffs abgegrenzt werden;
- die Ausnahme vom Projektinhaber genehmigt werden, bevor der Test zur produktiven Grundlage wird.

Ältere Tests aus der Zeit vor Einführung dieser Richtlinie dürfen als historische Fixtures erhalten bleiben. Sie erhalten dadurch keine automatische Produktionsfreigabe.

## Fortlaufende Pflege der MOOSE-Projektdokumentation

Die projektbezogene Dokumentation liegt unter:

```text
docs/moose/
```

Bei jeder neuen verwendeten oder als relevant bewerteten MOOSE-Klasse sind mindestens zu aktualisieren:

- `docs/moose/PROJECT-CLASS-INDEX.md`;
- die passende thematische Dokumentation;
- bei praktisch bestätigten Methoden `docs/moose/VERIFIED-METHODS.md`;
- der zugehörige Test- oder Acceptance-Bericht;
- gegebenenfalls der Ausnahme-ADR.

Eine Klasse darf erst als `VALIDATED` gelten, wenn ihr konkreter Einsatz mit dem dokumentierten MOOSE-Stand in DCS geprüft wurde.

## Review- und Abnahmekriterien

Bei jedem Review sind mindestens folgende Fragen verbindlich zu beantworten:

> Existiert bereits eine MOOSE-Funktion, die die Problemstellung vollständig oder ausreichend abbildet?

> Wurden Dokumentation, Quellcode und offizielle Beispiele passend zur tatsächlich geladenen MOOSE-Version untersucht?

> Ist eine verbleibende Nicht-MOOSE-Lösung ausdrücklich durch den Projektinhaber genehmigt?

Fehlt eine Prüfung, Dokumentation oder Genehmigung, darf die Lösung nicht als produktiv akzeptiert werden.
