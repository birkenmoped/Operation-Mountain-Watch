# ADR-0001: MOOSE als primäres Framework

## Status

Angenommen

## Kontext

Die Mission benötigt dynamische Spawns, Objekt-Wrapper, Events, Scheduler, Zonen, Menüs, CTLD, CSAR und umfangreiche operative Logik. Ein paralleler Einsatz mehrerer allgemeiner Frameworks erhöht Integrations- und Debugaufwand.

## Entscheidung

MOOSE wird als primäres DCS-Scripting-Framework verwendet. Eigene Kampagnenmodule bauen auf MOOSE und der nativen DCS-Scripting-API auf.

MIST wird nicht standardmäßig geladen. Eine spätere Aufnahme erfordert eine konkret benannte Funktion oder Abhängigkeit und ein weiteres ADR.

## Konsequenzen

- Eine getestete MOOSE-Version wird im Projekt festgeschrieben.
- Mission-Editor-Vorlagen und Namenskonventionen müssen mit MOOSE abgestimmt sein.
- Entwickler müssen zwischen strategischer Domänenlogik und MOOSE-/DCS-Objekten trennen.
- Beispiele aus älteren MOOSE-Versionen werden nicht ungeprüft übernommen.
