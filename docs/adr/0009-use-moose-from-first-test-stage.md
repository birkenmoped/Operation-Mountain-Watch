# ADR 0009 – MOOSE ab der ersten Teststufe verwenden

- Status: Accepted
- Date: 2026-07-13

## Context

Operation Mountain Watch setzt MOOSE als zentrales Framework für Gruppensteuerung, Spawn-Logik, Zonen, Scheduler, Events, Debugging und spätere Virtualisierung ein.

Eine vollständig skriptfreie physische Teststufe wäre zwar einfach, würde aber eine zweite, nur für Tests verwendete Steuerungsart erzeugen. Routing, Gruppenidentifikation, Zustandsüberwachung und Debugging müssten anschließend für MOOSE erneut aufgebaut werden.

Gleichzeitig dürfen einfache Basistests nicht bereits durch CampaignState, Persistenz, Warehouses, Cargo Units oder Director-Systeme überladen werden. Sonst lassen sich Fehlerursachen nicht sauber eingrenzen.

## Decision

MOOSE wird in allen projektbezogenen Testmissionen bereits ab der ersten physischen Teststufe geladen und verwendet.

Stufe A verwendet:

- MOOSE-Wrapper für Gruppen und Zonen;
- Mission-Editor-Templates mit Late Activation und `SPAWN`, soweit ein Spawn Teil des Tests ist;
- MOOSE-Routing und Aufgabensteuerung;
- Scheduler, Events, Logging und Testmenüs;
- einen szenariospezifischen physischen Controller.

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

## Consequences

### Positive

- MOOSE wird bereits an kleinen, verständlichen Szenarien erlernt;
- physische und virtualisierte Tests verwenden dieselbe Controllerlogik;
- Template-, Wrapper- und Namensfehler werden früh erkannt;
- Debug- und Testwerkzeuge entstehen nur einmal;
- Unterschiede zwischen DCS-Pathfinding und Virtualisierungsfehlern bleiben sichtbar;
- spätere Übernahme in die Kampagnenmission benötigt weniger Neuimplementierung.

### Negative

- auch einfache Testmissionen benötigen eine korrekte MOOSE-Ladefolge;
- Fehler in der Framework-Integration können Basistests blockieren;
- Testautoren müssen MOOSE-Konventionen bereits früh beherrschen;
- die physische DCS-Wegfindung bleibt trotz MOOSE störanfällig;
- API-Nutzung muss gegen die versionierte MOOSE-Fassung geprüft werden.

## Rules

- Jede Testmission lädt die im Repository festgelegte MOOSE-Version vor dem Projektcode.
- Es gibt keine separate produktive Vanilla-Steuerungsimplementierung derselben Mechanik.
- Stufe A bleibt fachlich minimal, obwohl MOOSE aktiv ist.
- Stufe B verwendet denselben PhysicalController wie Stufe A.
- MOOSE-Methoden werden vor Verwendung gegen Source oder Dokumentation der versionierten Fassung geprüft.
- Die DCS-KI bleibt für physische Bewegung verantwortlich; MOOSE-Erfolg bedeutet nicht automatisch zuverlässiges Pathfinding.
- Testmissionen müssen MOOSE-Ladefehler und fehlende Templates eindeutig melden.
