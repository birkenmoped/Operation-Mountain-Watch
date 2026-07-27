# ADR 0007 – Community-Templates bleiben am historischen Standort

- Status: Accepted
- Date: 2026-07-13

## Context

Die DCS-Afghanistan-Karte stellt zahlreiche historische FOBs, COPs, PBs und OPs nicht oder nur unvollständig in der 3D-Welt dar. Community-Ersteller veröffentlichen dafür Static Templates, die konkrete reale Stützpunkte an deren Kartenposition rekonstruieren.

Ein solches Template ist nicht nur eine Sammlung austauschbarer Objekte. Position, Geländeanpassung, Zufahrten, Sichtlinien, Höhenlage, umgebende Siedlungen und die historische Bezeichnung gehören zusammen. Das Verschieben eines Templates zu einem anderen Standort oder das Umbenennen in einen anderen realen Stützpunkt würde die geografische und historische Aussage verfälschen.

Gleichzeitig darf die bloße Verfügbarkeit eines Community-Templates nicht automatisch bestimmen, welche Operationsräume die Kampagne verwendet.

## Decision

Community-Static-Templates werden ausschließlich am historischen Standort verwendet, für den sie erstellt wurden.

- Ein Template wird nicht an einen anderen Kartenpunkt verschoben.
- Ein Template wird nicht unter dem Namen eines anderen realen Stützpunkts verwendet.
- Ein Template für FOB Joyce bleibt FOB Joyce; es wird weder zu FOB Blessing noch zu einem generischen Kunar-FOB umgedeutet.
- Ein vorhandenes Template darf einen bisher geplanten Stützpunkt nur konzeptionell ersetzen, wenn die Kampagnenplanung ausdrücklich auf den realen Standort des verfügbaren Templates umgestellt wird.
- Eine solche Umplanung umfasst Operationsraum, Routen, unterstützte Außenposten, Logistik, Missionsarten, Zeitraum und Führungszuordnung.
- Ist keine realistische Umplanung möglich, bleibt der ursprünglich geplante Standort bestehen und benötigt eine andere Community-Vorlage oder einen eigenen Mission-Editor-Aufbau.

Die Auswahlreihenfolge lautet:

1. vorhandenen nativen DCS-Standort verwenden;
2. standortgetreues Community-Template prüfen;
3. nach einer weiteren standortgetreuen Vorlage suchen oder den Ersteller anfragen;
4. den Standort selbst im Mission Editor aufbauen;
5. den Standort bewusst aus dem Kampagnenumfang entfernen oder den Operationsraum ausdrücklich neu planen.

## Consequences

### Positive

- reale Namen, Gelände und Operationsachsen bleiben konsistent;
- Community-Arbeit wird nicht aus ihrem geografischen Kontext gelöst;
- Routen, Sichtlinien und taktische Rollen bleiben nachvollziehbar;
- das Vorhandensein eines Templates verzerrt die Kampagnenplanung nicht unbemerkt;
- fehlende Stützpunkte werden als echte Planungs- oder Bauaufgabe sichtbar.

### Negative

- einige geplante Standorte müssen selbst erstellt werden;
- verfügbare Templates können nicht als schnelle generische Ersatzbausätze dienen;
- Operationsraumänderungen erfordern eine vollständige fachliche Neubewertung;
- die Zahl offener Mission-Editor-Aufgaben kann steigen.

## Rules

- Standort, Name und historische Identität eines Community-Templates sind untrennbar.
- Eine technische Positionskorrektur innerhalb des realen Standortareals ist nur zur Anpassung an Kartenupdates, Terrain oder Objektkollisionen zulässig.
- Objektteile dürfen als Referenz für einen Eigenbau betrachtet werden, aber nicht ohne Rechteprüfung kopiert oder als anderer historischer Standort ausgegeben werden.
- Ein anderer realer Stützpunkt ist kein Ersatzobjekt, sondern ein möglicher neuer Kampagnenknoten.
- Jede Änderung des geplanten Operationsraums wird in den Theater-, Sektor-, Routen- und Basendokumenten nachvollzogen.
- Fehlt für einen verbindlich geplanten Stützpunkt eine Vorlage, wird dies im Template-Inventar als offene Aufgabe geführt.
