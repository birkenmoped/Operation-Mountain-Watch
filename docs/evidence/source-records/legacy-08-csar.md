# 08 – CSAR

## Ziel

Abgeschossene oder ausgestiegene Piloten erzeugen dynamische Personnel-Recovery-Aufträge. Je nach Region und Informationslage kann daraus ein Wettrennen zwischen blauer Rettung und roter Gefangennahme entstehen.

## Technische Basis

MOOSE CSAR erzeugt und verwaltet den Rettungsfall. Ein eigener `CSARCampaignManager` ergänzt HUMINT, rote Capture-Teams, Evasion, Gefangenschaft, Persistenz und Folgeoperationen.

## Ablauf

1. Pilot landet oder ein konfigurierter Crash erzeugt einen Fall.
2. Blau erhält letzte bekannte Position, Rufzeichen und gegebenenfalls Funkbake.
3. Rot erhält abhängig von Region, Nähe zu Siedlungen, Tageszeit und Signalmitteln verzögerte Informationen.
4. Ein geeignetes Capture-Team kann reserviert und zum Suchgebiet entsandt werden.
5. Der Pilot wird aufgenommen, gefangen, getötet oder bleibt vermisst.
6. Rettung gilt erst nach Rückkehr zu geeigneter Airbase, FARP, MASH oder FOB als abgeschlossen.

## Roter Informationsstand

- `NONE`
- `RUMOR`
- `APPROXIMATE`
- `CONFIRMED`

Rot erhält nicht bei jedem Vorfall automatisch exakte Koordinaten.

## Gefangennahme

Gefangennahme wird durch eigene Distanz- und Zustandslogik ausgelöst, nicht durch unkontrolliertes KI-Feuer. Ein Capture-Team muss den Piloten erreichen und den Bereich für eine Mindestzeit kontrollieren.

## Evasion

Piloten nutzen nur kurze, vorbereitete Bewegungen zu Hide Sites oder Recovery Points. Keine freie kilometerlange Boden-KI-Navigation.

## Folgen

- gerettet: Personal und Moral bleiben erhalten
- gefangen: möglicher Propagandaeffekt und spätere Befreiungsmission
- gefallen: Verlust im Pilotpool
- vermisst: persistenter Suchfall mit abnehmender Funkfähigkeit

## Begrenzung

Vollständige CSAR-Fälle gelten primär für menschliche Spieler und ausgewählte wichtige AI-Crews. Zahl und Rekursion aktiver Rettungsfälle werden begrenzt.
