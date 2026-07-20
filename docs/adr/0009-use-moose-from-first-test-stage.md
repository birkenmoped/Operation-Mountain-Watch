# ADR 0009 – MOOSE ab der ersten Teststufe verwenden

- Status: Accepted; strengthened by GOV-001
- Date: 2026-07-13
- Governance update: 2026-07-20

## Binding governance

This ADR is governed by [`docs/00-project-governance.md`](../00-project-governance.md).

Operation Mountain Watch is MOOSE-first. All available and applicable MOOSE capabilities must be identified, evaluated, and used as the implementation foundation. Native DCS scripting, project-specific code, or hybrid fallbacks may be proposed only after the relevant MOOSE limitation has been documented. Only the project owner may approve such an exception. Technical discussion of disadvantages or alternatives does not constitute approval.

## Context

Operation Mountain Watch setzt MOOSE als zentrales Framework für Gruppensteuerung, Spawn-Logik, Zonen, Scheduler, Events, Debugging und spätere Virtualisierung ein.

Eine vollständig skriptfreie physische Teststufe wäre zwar einfach, würde aber eine zweite, nur für Tests verwendete Steuerungsart erzeugen. Routing, Gruppenidentifikation, Zustandsüberwachung und Debugging müssten anschließend für MOOSE erneut aufgebaut werden.

Gleichzeitig dürfen einfache Basistests nicht bereits durch CampaignState, Persistenz, Warehouses, Cargo Units oder Director-Systeme überladen werden. Sonst lassen sich Fehlerursachen nicht sauber eingrenzen.

## Decision

MOOSE wird in allen projektbezogenen Testmissionen bereits ab der ersten physischen Teststufe geladen und verwendet.

MOOSE ist nicht nur eine bevorzugte Bibliothek, sondern der verbindliche technische Grundstock. Für jede neue Mechanik werden zuerst die einschlägigen MOOSE-Klassen, Funktionen und Framework-Muster geprüft, kombiniert und getestet.

Stufe A verwendet:

- MOOSE-Wrapper für Gruppen und Zonen;
- Mission-Editor-Templates mit Late Activation und `SPAWN`, soweit ein Spawn Teil des Tests ist;
- MOOSE-Routing und Aufgabensteuerung;
- Scheduler, Events, Logging und Testmenüs;
- einen szenariospezifischen physischen Controller auf Basis der verfügbaren MOOSE-Mechaniken.

Stufe A verwendet noch nicht:

- Virtualisierung;
- CampaignState-Persistenz;
- Warehouse- und Cargo-Systeme;
- CTLD oder CSAR;
- produktive Director-Logik;
- automatische Fehlerkorrektur.

Stufe B ergänzt die Virtualisierung um den bereits in Stufe A validierten physischen Controller.

```text
Stufe A: PhysicalController
Stufe B: VirtualizationAdapter -> PhysicalController
```

MOOSE ersetzt nicht die physische DCS-Wegfindung. Es dient als kontrollierte Orchestrierungs- und Beobachtungsschicht über der DCS-KI.

Diese technische Grenze berechtigt nicht automatisch zu einer nativen DCS- oder Eigenimplementierung. Eine solche Abweichung benötigt die in GOV-001 definierte Analyse und die ausdrückliche Entscheidung des Projektinhabers.

## Consequences

### Positive

- MOOSE wird bereits an kleinen, verständlichen Szenarien erlernt;
- physische und virtualisierte Tests verwenden dieselbe Controllerlogik;
- Template-, Wrapper- und Namensfehler werden früh erkannt;
- Debug- und Testwerkzeuge entstehen nur einmal;
- Unterschiede zwischen DCS-Pathfinding und Virtualisierungsfehlern bleiben sichtbar;
- spätere Übernahme in die Kampagnenmission benötigt weniger Neuimplementierung;
- Eigenentwicklungen entstehen nur nach belegter MOOSE-Grenze und ausdrücklicher Freigabe.

### Negative

- auch einfache Testmissionen benötigen eine korrekte MOOSE-Ladefolge;
- Fehler in der Framework-Integration können Basistests blockieren;
- Testautoren müssen MOOSE-Konventionen bereits früh beherrschen;
- die physische DCS-Wegfindung bleibt trotz MOOSE störanfällig;
- API-Nutzung muss gegen die versionierte MOOSE-Fassung geprüft werden;
- eine alternative Lösung darf nicht ohne den dokumentierten Entscheidungsprozess kurzfristig eingebaut werden.

## Rules

- Jede Testmission lädt die im Repository festgelegte MOOSE-Version vor dem Projektcode.
- Für jede Anforderung werden zuerst alle einschlägigen MOOSE-Funktionen und -Muster ermittelt und getestet.
- Es gibt keine separate produktive Vanilla-Steuerungsimplementierung derselben Mechanik ohne ausdrückliche Projektinhaberfreigabe.
- Stufe A bleibt fachlich minimal, obwohl MOOSE aktiv ist.
- Stufe B verwendet denselben PhysicalController wie Stufe A.
- MOOSE-Methoden werden vor Verwendung gegen Source oder Dokumentation der versionierten Fassung geprüft.
- Die DCS-KI bleibt für physische Bewegung verantwortlich; MOOSE-Erfolg bedeutet nicht automatisch zuverlässiges Pathfinding.
- Testmissionen müssen MOOSE-Ladefehler und fehlende Templates eindeutig melden.
- MOOSE-Nachteile und Alternativen dürfen und sollen diskutiert werden; die Entscheidung zur Eigen-, DCS- oder Hybridlösung trifft ausschließlich der Projektinhaber.
- Eine genehmigte Ausnahme wird als ADR mit Umfang, Begründung, geprüften MOOSE-Alternativen und Regressionstests festgehalten.
