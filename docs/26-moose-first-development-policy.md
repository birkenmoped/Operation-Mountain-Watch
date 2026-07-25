# Verbindliche MOOSE-First-Entwicklungsrichtlinie

## Status

**Mandatory / projektweit verbindlich**

Diese Richtlinie gilt für sämtliche Lua-Entwicklung in **Operation Mountain Watch**: Missionslogik, Diagnostik, Testskripte, Hilfsfunktionen, Runtime-Koordinatoren, Persistenzanbindung und sonstige projektspezifische Erweiterungen.

## Grundsatz

Bevor eigener Lua-Code oder eine eigene Funktion zur Lösung einer Problemstellung entwickelt oder geschrieben wird, muss zuerst geprüft werden, ob das MOOSE-Framework die benötigte Funktionalität bereits bereitstellt.

Vorhandene MOOSE-Klassen, Methoden, Ereignismodelle, Scheduler, Sets, Wrapper, Dispatcher, OPS-Klassen und sonstige Framework-Funktionen sind vorrangig zu verwenden.

Wir entwickeln auf Basis von MOOSE und wollen keine bereits vorhandene Framework-Funktion unnötig neu implementieren.

## Verbindlicher Rechercheweg

Für neue Funktionen, Fehleranalysen und Architekturentscheidungen gilt künftig der folgende Ablauf. Die Reihenfolge ist verbindlich und darf nur dann verkürzt werden, wenn einzelne Schritte nachweislich nicht auf die konkrete Fragestellung anwendbar sind.

### 1. MOOSE-Klassendokumentation durchsuchen

- Die Dokumentation muss zur tatsächlich verwendeten MOOSE-Version beziehungsweise zum verwendeten Branch passen.
- Zuerst sind vorhandene Klassen, Methoden, Events, FSM-Callbacks, Konfigurationsmöglichkeiten und Erweiterungspunkte zu suchen.
- Für einen Develop-Stand ist die Develop-Dokumentation zu verwenden:
  - <https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/index.html>
- Für einen stabilen Master-Stand ist die stabile Dokumentation zu verwenden:
  - <https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/>
- Eine Fundstelle in der Dokumentation ist noch kein ausreichender Nachweis dafür, dass die Methode in der tatsächlich geladenen `Moose.lua` vorhanden ist.

### 2. MOOSE-Quellcode kontrollieren

- Signatur und Parameterreihenfolge,
- Rückgabewerte,
- Zustandsübergänge,
- FSM-Events und Callbacks,
- interne Voraussetzungen,
- Seiteneffekte,
- Versions- und Branchabhängigkeiten,
- Fehler- und Abbruchverhalten.

Die Klassendokumentation allein ist nicht immer vollständig oder eindeutig. Bei Unklarheiten ist deshalb der zugehörige MOOSE-Quellcode maßgeblich zu prüfen:

- <https://github.com/FlightControl-Master/MOOSE>

Nicht dokumentierte interne Felder und Tabellen gelten nicht automatisch als stabile öffentliche API.

### 3. Offizielle Demo- und Testmissionen prüfen

Offizielle Demo- und Testmissionen zeigen häufig die vorgesehene Verwendung einer Klasse besser als eine isolierte Methodenbeschreibung. Zu prüfen sind insbesondere Konstruktorreihenfolge, Startzeitpunkt, Mission-Editor-Voraussetzungen, Events und das Zusammenspiel mehrerer Klassen.

Relevante offizielle Repositories sind unter anderem:

- <https://github.com/FlightControl-Master/MOOSE_MISSIONS>
- <https://github.com/FlightControl-Master/MOOSE_MISSIONS_UNPACKED>

Beispiele aus Foren, Discord, fremden Repositories oder älteren Guides sind nur ergänzende Hinweise. Sie müssen gegen den aktuell verwendeten MOOSE-Quellstand geprüft werden.

### 4. Erst danach projektspezifischen Lua-Code entwickeln

- Eigenlogik ist nur zulässig, wenn MOOSE die Anforderung nicht oder nicht ausreichend abbildet.
- Vorhandene MOOSE-Funktionen sind zunächst direkt, anschließend durch Konfiguration oder Kombination zu nutzen.
- Erweiterungen sollen möglichst über dokumentierte Events, FSM-Callbacks und öffentliche Methoden angebunden werden.
- Eine kleine Adapter- oder Koordinationsschicht ist einer vollständigen Parallelimplementierung vorzuziehen.
- Direkte Zugriffe auf MOOSE-Interna wie `_DATABASE` sind auf begründete Diagnose- oder Validierungsfälle zu beschränken und ausdrücklich zu dokumentieren.
- Direkte DCS-API-Fallbacks sind nur zulässig, wenn keine ausreichende MOOSE-Abstraktion existiert oder MOOSE beim frühen Missionsstart nachweislich noch nicht verfügbar ist.

### 5. Ergebnis in der Projektdokumentation festhalten

Für jede neue oder wesentlich geänderte MOOSE-basierte Funktion sind mindestens zu dokumentieren:

- verwendete MOOSE-Klasse und Methode,
- Zweck der Verwendung im Projekt,
- geprüfter MOOSE-Branch und möglichst der genaue MOOSE-Commit,
- geprüfte Methoden-Signatur,
- bekannte Einschränkungen und Voraussetzungen,
- relevante FSM-Events oder Callbacks,
- projektspezifische Entscheidung,
- Verweis auf den geprüften MOOSE-Quellcode,
- Verweis auf eine passende offizielle Demo- oder Testmission, sofern vorhanden,
- zugehöriger OMW-Quellcode,
- Teststand und Acceptance-Ergebnis.

Kann der genaue MOOSE-Commit eines älteren Testlaufs nicht mehr ermittelt werden, wird dies ausdrücklich als Nachweislücke dokumentiert. Es darf kein Commit geraten oder aus dem aktuellen Stand rückwirkend abgeleitet werden.

## Verbindlicher Prüfablauf vor Eigenentwicklungen

Vor jeder Eigenentwicklung sind mindestens folgende Schritte durchzuführen:

1. Die fachliche und technische Anforderung eindeutig beschreiben.
2. Die passende MOOSE-Dokumentation nach Klassen, Methoden, Events und FSM-Callbacks durchsuchen.
3. Den tatsächlichen MOOSE-Quellcode und die Signaturen prüfen.
4. Offizielle Demo- und Testmissionen auf vorgesehene Nutzung und Voraussetzungen untersuchen.
5. Prüfen, ob die Anforderung durch Konfiguration, Vererbung, Komposition, Events, Callbacks oder vorhandene MOOSE-Klassen gelöst werden kann.
6. Geeignete MOOSE-Funktionen und deren Einschränkungen in der Projekt-MOOSE-Dokumentation erfassen.
7. Erst wenn MOOSE die Anforderung nicht oder nicht ausreichend abbildet, projektspezifischen Lua-Code entwickeln.
8. Bei einer Eigenentwicklung dokumentieren, warum die vorhandenen MOOSE-Funktionen nicht ausreichen.
9. Die Lösung durch einen reproduzierbaren DCS-Test und einen Ergebnisbericht absichern.

## Prioritätsreihenfolge

Bei der Lösungsfindung gilt folgende Reihenfolge:

1. Vorhandene MOOSE-Funktion direkt verwenden.
2. Vorhandene MOOSE-Funktion konfigurieren oder kombinieren.
3. MOOSE über dokumentierte Events, Callbacks oder Erweiterungspunkte ergänzen.
4. Eine kleine projektspezifische Adapter- oder Koordinationsschicht um MOOSE erstellen.
5. Vollständig eigene Logik nur dann entwickeln, wenn keine tragfähige MOOSE-Lösung existiert.

## Zulässige Eigenentwicklungen

Eigener Lua-Code bleibt zulässig, wenn mindestens einer der folgenden Fälle vorliegt:

- MOOSE bietet keine passende Funktion.
- Die vorhandene MOOSE-Funktion bildet die Anforderung nachweislich nicht vollständig oder nicht zuverlässig ab.
- Projektspezifische Kampagnenlogik, Persistenz, Zustandsmodelle oder Datenstrukturen liegen außerhalb des MOOSE-Funktionsumfangs.
- Eine klar abgegrenzte Integration mit der DCS-Scripting-API oder anderen Projektkomponenten ist erforderlich.
- Ein dokumentierter MOOSE-Fehler oder eine nachgewiesene Framework-Einschränkung erfordert einen Workaround.

Auch in diesen Fällen soll eigener Code MOOSE ergänzen und nicht unnötig ersetzen.

## Dokumentationspflicht bei Eigenentwicklungen

Die zugehörige technische Dokumentation, der Commit oder der Quellcode-Kommentar muss nachvollziehbar festhalten:

- welche MOOSE-Funktionen geprüft wurden,
- welches Ergebnis die Prüfung hatte,
- warum keine vorhandene MOOSE-Lösung ausreicht,
- welche eigene Logik deshalb erforderlich ist,
- wie die Eigenentwicklung an MOOSE angebunden bleibt,
- wie die Eigenentwicklung getestet wurde.

## Fortlaufende Pflege der MOOSE-Projektdokumentation

Die projektbezogene MOOSE-Dokumentation liegt unter:

```text
docs/moose/
```

Sobald sich im Laufe der Entwicklung eine weitere MOOSE-Klasse, Methode oder ein weiteres Modul als hilfreich, notwendig oder tatsächlich verwendet erweist, muss die Dokumentation im selben Entwicklungsstand ergänzt werden.

Mindestens zu aktualisieren sind:

- `docs/moose/PROJECT-CLASS-INDEX.md`,
- die passende thematische Dokumentation,
- bei praktisch bestätigten Methoden `docs/moose/VERIFIED-METHODS.md`,
- gegebenenfalls der zugehörige Test- oder Acceptance-Bericht.

Eine Klasse darf erst als **validiert** gekennzeichnet werden, wenn ihr konkreter Einsatz in DCS mit dem dokumentierten MOOSE-Stand geprüft wurde. Eine reine Planungsentscheidung oder eine Dokumentationsfundstelle reicht dafür nicht aus.

## Review- und Abnahmekriterium

Eine neue eigene Lua-Funktion gilt nicht als fachlich begründet, solange die MOOSE-Prüfung nicht nachvollziehbar erfolgt ist.

Bei Code-Reviews und Entwicklungsabnahmen ist daher ausdrücklich zu prüfen:

> Existiert bereits eine MOOSE-Funktion, die diese Problemstellung vollständig oder ausreichend abbildet?

Zusätzlich ist zu prüfen:

> Wurden Dokumentation, Quellcode und offizielle Beispiele passend zum tatsächlich geladenen MOOSE-Stand untersucht und im Projekt dokumentiert?

Wurde eine dieser Fragen nicht geprüft oder dokumentiert, ist die Entwicklung vor einer weiteren Implementierung zunächst auf vorhandene MOOSE-Funktionalität zu untersuchen.