# MOOSE-Projektdokumentation

## Zweck

Diese Dokumentation ist die projektspezifische MOOSE-Wissensbasis für **Operation Mountain Watch**.

Sie ersetzt nicht die offizielle MOOSE-Klassendokumentation. Sie hält ausschließlich fest:

- welche MOOSE-Module und Klassen im Projekt verwendet oder konkret geplant werden,
- welche Methoden im Projekt geprüft wurden,
- welcher MOOSE-Stand zugrunde lag,
- welche DCS- und Mission-Editor-Voraussetzungen bestehen,
- welche Einschränkungen oder Workarounds bekannt sind,
- welche projektspezifischen Entscheidungen getroffen wurden,
- welche Testmission oder welcher Acceptance-Bericht den Einsatz belegt.

## Verbindliche Arbeitsanweisung

Vor jeder Eigenentwicklung gilt:

- [`Verbindliche MOOSE-First-Entwicklungsrichtlinie`](../26-moose-first-development-policy.md)

Die dort definierte Reihenfolge aus Klassendokumentation, Quellcodeprüfung, offiziellen Demo-/Testmissionen, MOOSE-Lösung und erst danach möglicher Eigenentwicklung ist projektweit verbindlich.

## Primäre externe Quellen

### Develop-Dokumentation

<https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html>

Diese Quelle ist zu verwenden, wenn die Mission tatsächlich einen Develop-Stand von MOOSE lädt.

### Stable-/Master-Dokumentation

<https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/>

Diese Quelle ist zu verwenden, wenn die Mission einen stabilen Master-/Release-Stand lädt.

### MOOSE-Quellcode

<https://github.com/FlightControl-Master/MOOSE>

### Offizielle Demo- und Testmissionen

- <https://github.com/FlightControl-Master/MOOSE_MISSIONS>
- <https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED>

## Dokumentationsstruktur

- [`VERSION-AND-SOURCES.md`](VERSION-AND-SOURCES.md) – verwendeter MOOSE-Stand, Quellenhierarchie und Nachweispflicht
- [`PROJECT-CLASS-INDEX.md`](PROJECT-CLASS-INDEX.md) – alle für OMW relevanten MOOSE-Klassen mit Status
- [`AIR-OPERATIONS.md`](AIR-OPERATIONS.md) – AIRWING-, SQUADRON-, AUFTRAG- und COMMANDER-Architektur
- [`GROUND-OPERATIONS.md`](GROUND-OPERATIONS.md) – Bodengruppen, Brigaden, Spawning und Gruppenmengen
- [`LOGISTICS-AND-TRANSPORT.md`](LOGISTICS-AND-TRANSPORT.md) – Warehouse, OPSTRANSPORT, CTLD, CSAR und RAT
- [`EVENTS-AND-FSM.md`](EVENTS-AND-FSM.md) – Events, FSM-Callbacks und Scheduler
- [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md) – praktisch bestätigte Methoden und ihre Projektverwendung

## Statusbegriffe

| Status | Bedeutung |
|---|---|
| `VALIDATED` | Konkreter Einsatz wurde mit dokumentiertem OMW-Stand in DCS erfolgreich geprüft. |
| `IN_USE_PARTIAL` | Klasse oder Methode wird bereits verwendet, aber nicht alle vorgesehenen Laufzeitpfade wurden validiert. |
| `PLANNED` | Architekturentscheidung ist getroffen, Implementierung oder DCS-Test steht noch aus. |
| `CANDIDATE` | Möglicherweise geeignet; MOOSE-Recherche und Architekturentscheidung stehen noch aus. |
| `NOT_USED` | Bewusst derzeit nicht Teil der Architektur. |
| `INTERNAL_RESTRICTED` | Interner MOOSE-Zugriff; nur begründet für Diagnose oder Validierung zulässig. |

## Pflegepflicht

Sobald eine weitere MOOSE-Klasse oder Methode im Projekt hilfreich, notwendig oder tatsächlich verwendet wird, muss sie im selben Entwicklungsstand dokumentiert werden.

Mindestens zu aktualisieren sind:

1. [`PROJECT-CLASS-INDEX.md`](PROJECT-CLASS-INDEX.md),
2. die passende thematische Datei,
3. bei einem erfolgreichen DCS-Nachweis [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md),
4. der zugehörige Test- oder Acceptance-Bericht.

Eine reine Erwähnung in der MOOSE-Dokumentation reicht nicht für den Status `VALIDATED`.