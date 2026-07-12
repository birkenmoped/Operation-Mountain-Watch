# ADR 0003 – Mission-Editor-Gruppen als primäre Spawnvorlagen

- Status: Accepted
- Date: 2026-07-13

## Context

Die Kampagne muss viele physische Gruppen dynamisch materialisieren, virtualisieren und später mit reduziertem Zustand wiederherstellen. MOOSE unterstützt sowohl Mission-Editor-Gruppen mit `Late Activation` als auch vollständig in Lua aufgebaute DCS-Gruppentabellen.

Vollständig dynamische Tabellen erfordern die fehlerfreie Pflege zahlreicher DCS-spezifischer Felder für Einheiten, Formationen, Aufgaben, Payloads, Funkdaten und Namen. Gleichzeitig dürfen MOOSE-Laufzeitnamen nicht als persistente Kampagnenidentität verwendet werden.

## Decision

Reguläre Bodenverbände, Konvois, QRFs, Garnisonen, rote Zellen und AI-Luftfahrzeuge werden aus wiederverwendbaren Mission-Editor-Gruppen erzeugt, die auf `Late Activation` gesetzt sind.

MOOSE `SPAWN:New()` oder `SPAWN:NewWithAlias()` ist der Standardmechanismus. Der CampaignState vergibt davon unabhängige strategische Entity-IDs.

`SPAWN:NewFromTemplate()` und vollständig dynamische DCS-Gruppentabellen werden nur für begründete Sonderfälle oder spätere, getestete Wiederherstellungslogik eingesetzt.

## Consequences

### Positive

- DCS-spezifische Gruppendetails bleiben im Mission Editor prüfbar.
- Komplexe Payloads, Formationen und Länderzuordnungen müssen nicht manuell rekonstruiert werden.
- Templates können in isolierten Testmissionen validiert werden.
- MOOSE wird entsprechend seinem vorgesehenen Standardworkflow verwendet.
- CampaignState und physische DCS-Namen bleiben sauber getrennt.

### Negative

- Die `.miz` enthält eine Template-Bibliothek.
- Änderungen an Zusammensetzungen erfordern teilweise Mission-Editor-Arbeit.
- Stark variable Reststärken benötigen mehrere Varianten oder eine getestete Template-Manipulation.
- Templates und externe Metadaten müssen synchron gehalten werden.

## Rules

- Template-Namen beginnen mit `TPL_`.
- Template- und Aliasnamen enthalten kein `#`.
- Jedes Template besitzt externe Metadaten.
- Spieler-Slots sind keine dynamischen Spawnvorlagen.
- Persistente Entity-IDs werden nie aus MOOSE-Laufzeitnamen abgeleitet.
- Vollständig dynamische Gruppentabellen benötigen eine dokumentierte Begründung und eigene Tests.
