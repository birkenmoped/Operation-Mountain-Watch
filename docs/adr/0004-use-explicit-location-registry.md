# ADR 0004 – Eigenes Ortsregister und validierte Terrainpfade

- Status: Accepted
- Date: 2026-07-13

## Context

DCS und MOOSE können Airbases auflisten, Koordinaten auf Straßen oder Schienen projizieren und Pfade zwischen vorgegebenen Endpunkten entlang dieser Netze berechnen. MOOSE registriert Scenery-Objekte jedoch nicht flächendeckend, sondern scannt sie nur innerhalb definierter Zonen.

Die Mission benötigt zusätzlich semantische Informationen wie Ortsname, militärische Rolle, Sektor, Versorgungsfähigkeit, Hinterhaltrisiko und Materialisierungsregeln. Diese Informationen lassen sich nicht zuverlässig allein aus Scenery-IDs oder F10-Kartenbeschriftungen ableiten.

## Decision

Operation Mountain Watch führt ein eigenes versioniertes Ortsregister und einen eigenen Routengraphen.

- Airbases werden über MOOSE referenziert.
- FOBs, COPs, Dörfer, Pässe, Checkpoints und taktische Zonen erhalten eigene stabile IDs.
- Straßen- und Schienenpfade werden zwischen bekannten Knoten über die DCS-Terrainfunktionen erzeugt.
- Jeder produktiv verwendete Pfad wird praktisch validiert und anschließend gecacht.
- Scenery-Scans dienen nur zur Erzeugung von Kandidaten in begrenzten Entwicklungszonen.
- Stromleitungen und andere Infrastruktur ohne eigene Routing-API werden manuell oder über begrenzte Scenery-Scans erfasst.

## Consequences

### Positive

- Kampagnenlogik verwendet stabile und aussagekräftige IDs.
- DCS-Terrainpfade können automatisiert erzeugt werden, ohne die semantische Kontrolle abzugeben.
- Fehlerhafte Straßen, Brücken und AI-Probleme können pro Route dokumentiert werden.
- Große Scenery-Scans belasten die Produktionsmission nicht.
- Karten- und DCS-Versionen können gezielt nachvalidiert werden.

### Negative

- Orte und Routen benötigen einen Erfassungs- und Freigabeprozess.
- Terrainpfade müssen nach Kartenupdates erneut getestet werden.
- Automatische Siedlungserkennung liefert nur Kandidaten, keine verlässlichen Namen oder Rollen.
- Nicht routbare Infrastruktur erfordert zusätzliche manuelle Datenpflege.

## Rules

- Kein flächendeckender Scenery-Scan beim normalen Missionsstart.
- Kein automatisch erzeugter Straßenpfad gilt ohne Test als produktionsbereit.
- Ein fehlgeschlagener Pfad wird nicht durch eine unmarkierte Luftlinie ersetzt.
- Scenery-Namen oder IDs sind keine semantischen Orts-IDs.
- Stromleitungen, Pipelines und ähnliche Netze werden nicht als Straßen behandelt.
- Freigegebene Routen speichern DCS-Version, Länge, Fahrzeugklassen, bekannte Probleme und Validierungsstatus.
