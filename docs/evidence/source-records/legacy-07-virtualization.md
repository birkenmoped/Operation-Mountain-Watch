# 07 – Virtualisierung

## Zweck

Entfernte Gruppen und Konvois werden als strategische Entitäten statt als aktive DCS-Gruppen geführt. Dadurch entfallen Wegfindung, Sensorberechnung, Kollisionen und KI-Last, solange kein physischer Kontakt möglich ist.

## Virtueller Zustand

- keine DCS-Gruppe
- mathematisch fortgeschriebene Position
- erhaltene Zusammensetzung, Fracht, Verluste, Auftrag und Route
- Bewegung mit abschnittsabhängiger Durchschnittsgeschwindigkeit

## Physischer Zustand

Eine DCS-Gruppe wird aus einer Mission-Editor-Vorlage erzeugt und mit der strategischen Entity-ID verknüpft. Beim Rückwechsel werden Position, Überlebende, Fracht und relevanter Zustand gespeichert.

## Materialisierung

Materialisierung erfolgt bei:

- Annäherung eines Spielers oder relevanter blauer/roter KI
- bevorstehendem Kampf
- aktivem Eskorteinsatz
- Annäherung an FOB, Camp, Checkpoint oder Missionsziel
- Aufklärung einer vorbereiteten Angriffszone

Spawns erfolgen nur an validierten Straßen-, Gelände- oder Versteckankern und außerhalb plausibler Beobachtung.

## Dematerialisierung

Nur zulässig, wenn:

- seit mehreren Minuten kein Kontakt besteht
- kein Spieler die Gruppe beobachtet oder eskortiert
- keine Waffe unterwegs ist
- keine Be-/Entladung oder Zielinteraktion läuft
- die Gruppe nicht kritisch beschädigt ist

Aktivierungs- und Deaktivierungsradien verwenden Hysterese, um ständiges Ein- und Auspacken zu vermeiden.

## Straßenkonvois

Virtuelle Konvois bewegen sich entlang gespeicherter Straßenpolylinien und benötigen kein Proxy-Fahrzeug. Bei Materialisierung werden mehrere kleine Gruppen auf validierten Ankern erzeugt. Ein Stuck Detector darf nur außerhalb der Spielerbeobachtung repositionieren.

## Rote Vorhut

Physische Spotter oder Vorausfahrzeuge können als eigene Entities eingesetzt werden. Sie sind nicht die technische Repräsentation der gesamten virtualisierten Gruppe.

## Grenzen

Exakter individueller Subsystemschaden, Munitionszustand und laufende DCS-Controller-Aufgaben können nach Respawn nicht grundsätzlich identisch rekonstruiert werden und müssen im Prototyp praktisch geprüft werden.
