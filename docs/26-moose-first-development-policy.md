# Verbindliche MOOSE-First-Entwicklungsrichtlinie

## Status

**Mandatory / projektweit verbindlich**

Diese Richtlinie gilt für sämtliche Lua-Entwicklung in **Operation Mountain Watch**: Missionslogik, Diagnostik, Testskripte, Hilfsfunktionen, Runtime-Koordinatoren, Persistenzanbindung und sonstige projektspezifische Erweiterungen.

## Grundsatz

Bevor eigener Lua-Code oder eine eigene Funktion zur Lösung einer Problemstellung entwickelt oder geschrieben wird, muss zuerst geprüft werden, ob das MOOSE-Framework die benötigte Funktionalität bereits bereitstellt.

Vorhandene MOOSE-Klassen, Methoden, Ereignismodelle, Scheduler, Sets, Wrapper, Dispatcher, Ops-Klassen und sonstige Framework-Funktionen sind vorrangig zu verwenden.

Wir entwickeln auf Basis von MOOSE und wollen keine bereits vorhandene Framework-Funktion unnötig neu implementieren.

## Verbindlicher Prüfablauf

Vor jeder Eigenentwicklung sind mindestens folgende Schritte durchzuführen:

1. Die fachliche und technische Anforderung eindeutig beschreiben.
2. Die aktuelle MOOSE-Dokumentation, Klassenreferenz, Beispiele und bei Bedarf den MOOSE-Quellcode nach passenden Funktionen durchsuchen.
3. Prüfen, ob die Anforderung durch Konfiguration, Vererbung, Komposition, Events, Callbacks oder vorhandene MOOSE-Klassen gelöst werden kann.
4. Geeignete MOOSE-Funktionen und deren Einschränkungen dokumentieren.
5. Erst wenn MOOSE die Anforderung nicht oder nicht ausreichend abbildet, darf projektspezifischer Lua-Code entwickelt werden.
6. Bei einer Eigenentwicklung ist zu dokumentieren, warum die vorhandenen MOOSE-Funktionen nicht ausreichen.

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

- welche MOOSE-Funktionen geprüft wurden;
- welches Ergebnis die Prüfung hatte;
- warum keine vorhandene MOOSE-Lösung ausreicht;
- welche eigene Logik deshalb erforderlich ist;
- wie die Eigenentwicklung an MOOSE angebunden bleibt.

## Review- und Abnahmekriterium

Eine neue eigene Lua-Funktion gilt nicht als fachlich begründet, solange die MOOSE-Prüfung nicht nachvollziehbar erfolgt ist.

Bei Code-Reviews und Entwicklungsabnahmen ist daher ausdrücklich zu prüfen:

> Existiert bereits eine MOOSE-Funktion, die diese Problemstellung vollständig oder ausreichend abbildet?

Wurde diese Frage nicht geprüft oder dokumentiert, ist die Entwicklung vor einer weiteren Implementierung zunächst auf MOOSE-Funktionalität zu untersuchen.
