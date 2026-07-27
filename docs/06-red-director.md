# 06 – Red Director

## Informationslage

Rot kennt permanente blaue Airbases und FOBs grundsätzlich. Abstrakte Informanten melden größere Konvois, Bauarbeiten und sichtbare Truppenbewegungen mit variabler Verzögerung und Genauigkeit. Eine physische Spitzel-KI wird nicht simuliert.

Zusätzlich führt der `CampaignState` einen Aufklärungsgrad für rote Aufenthaltsorte, Hide Sites, Caches und Strongpoints. Mögliche Stufen sind:

- `UNKNOWN`
- `POSSIBLE_ACTIVITY`
- `LIKELY_PRESENCE`
- `HIDE_SITE_NARROWED`
- `CONFIRMED_POSITION`
- `CONTACT`

## Operative Zellzustände

- `DORMANT`
- `SELECT_TARGET`
- `PREPARE`
- `ASSEMBLE`
- `MOVE`
- `ATTACK`
- `WITHDRAW`
- `DISPERSED`
- `REBUILDING`
- `DESTROYED`

Der operative Zustand beschreibt Absicht und Auftrag. Er wird nicht mit dem physischen Verbergungszustand vermischt.

## Concealment-Zustände

- `VIRTUAL_HIDDEN`
- `VIRTUAL_ALERTED`
- `MATERIALIZING`
- `PHYSICAL_CONCEALED`
- `PHYSICAL_OBSERVING`
- `PHYSICAL_ENGAGED`
- `PHYSICAL_DISPLACING`
- `VIRTUAL_DISPERSED`
- `CAPTURED`
- `DESTROYED`

Eine Zelle kann beispielsweise operativ `PREPARE` und gleichzeitig `VIRTUAL_HIDDEN` sein.

## Zielauswahl

Ziele werden anhand strategischer Bedeutung, Verteidigungsstärke, Versorgungslage, Entfernung, bekannter Route, eigener Verluste und blauer Luftüberwachung bewertet.

Zusätzliche Faktoren für verdeckte Operationen:

- verfügbare Hide Sites;
- lokale Unterstützung;
- bekannte Suchaktivität;
- vorhandene Fluchtwege;
- Sichtschutz und Tageszeit;
- Aufklärungsgrad der blauen Seite;
- Verfügbarkeit vorbereiteter Strongpoints;
- Risiko, beim Materialisieren beobachtet zu werden.

## Operationstypen

- Straßenhinterhalt
- Angriff auf Patrouille oder Fahrzeuggruppe
- Mörser- oder Raketenangriff
- Raid auf FOB oder Logistikpunkt
- koordinierter Großangriff
- Such- und Capture-Team für abgeschossene Piloten
- verdeckte Beobachtung einer Route
- Flucht aus einer durchsuchten Siedlung
- Verteidigung eines Caches oder Strongpoints
- Ablenkungsangriff während einer Suchoperation

Kampfgruppen bestehen üblicherweise aus mindestens fünf Personen. Kleinere Elemente sind als Spotter, Kuriere oder Vorhut zulässig.

## Verdeckter Aufenthalt

Ruhende und nicht beobachtete rote Kräfte werden überwiegend virtualisiert. Eine Siedlung enthält daher nicht dauerhaft sichtbare Infanteriegruppen, sondern logische Zellpositionen und vorbereitete Hide Sites.

Geeignete Hide Sites liegen beispielsweise:

- in oder hinter Compounds;
- in Innenhöfen;
- hinter Mauern und Gebäuden;
- an Baumreihen und in Obstgärten;
- in Wadis und Gräben;
- hinter Felsen oder auf rückwärtigen Hängen;
- in vorbereiteten urbanen Gassen oder Deckungsstellungen.

Beliebige DCS-Scenery-Häuser werden nicht als automatisch begehbar oder garnisonierbar vorausgesetzt.

## ConcealmentManager

Der `RedDirector` entscheidet über operative Absicht. Der `ConcealmentManager` entscheidet über die physische verdeckte Repräsentation.

Er berücksichtigt:

- Rolle und Gruppengröße;
- Hide-Site-Kapazität;
- Entfernung und Sichtlinie zu Spielern;
- Deckungstyp und Tageszeit;
- Aufklärungsgrad;
- aktuelle Belegung;
- vorbereitete Fluchtwege;
- geplanten Auftrag;
- Risiko sichtbaren Pop-ins;
- Serverleistung.

Hide Sites werden reserviert, bevor eine Gruppe materialisiert wird.

## Materialisierung

Eine rote Gruppe wird nur an einer geprüften Position materialisiert. Vorher werden mindestens geprüft:

- keine direkte Sichtlinie naher Spieler;
- keine unmittelbare Nähe zu blauen Einheiten;
- plausible Verbindung zur virtuellen Position;
- genügend freier Platz für das Template;
- erreichbarer Angriffs- oder Fluchtweg;
- passende Rolle und Kapazität der Hide Site.

Kann keine sichere Position gefunden werden, bleibt die Einheit virtuell oder wird weiter entfernt materialisiert. Offenes Pop-in wird nicht als normaler Fallback verwendet.

Nach der Materialisierung beginnt die Gruppe abhängig vom Auftrag zunächst mit:

- Alarmzustand Green;
- Hold oder kurzer verdeckter Route;
- ROE Return Fire oder Hold Fire;
- Beobachtung oder Vorbereitung;
- Aktivierung von Angriff oder Flucht erst bei erfüllter Bedingung.

## Durchsuchungen

Durchsuchungen werden als Kampagnenprozess modelliert und setzen keine echte Gebäudeinnenraum-Navigation voraus.

Mögliche Ergebnisse:

- keine relevante Aktivität;
- Zelle bleibt unentdeckt;
- Hinweise oder Waffenlager werden gefunden;
- Kurier oder Unterstützer wird festgenommen;
- Zelle beginnt verdeckte Flucht;
- Zelle eröffnet das Feuer;
- vorbereiteter Hinterhalt wird ausgelöst;
- Fehlinformation oder leeres Ziel;
- Strongpoint wird identifiziert.

Die Wahrscheinlichkeit hängt von Intelligence, Suchintensität, beteiligten Kräften, lokaler Unterstützung, Tageszeit, Alarmzustand, Hide-Site-Qualität und Fluchtwegen ab.

## Strongpoints

Bewaffnete Häuser oder vergleichbare Assets werden nur für ausgewählte, vorbereitete Strongpoints verwendet.

Geeignete Rollen:

- befestigter Kommandoposten;
- Waffenlager;
- HVT-Versteck;
- vorbereitete Hinterhalt-Hauptstellung;
- verteidigter Compound;
- dauerhafte Mörser- oder Beobachtungsstellung.

Ein Strongpoint bleibt mit einer roten Zelle, Personal, Munition und strategischer Wirkung im `CampaignState` verknüpft. Das physische Asset erzeugt keine unabhängigen Ressourcen.

Bewaffnete Häuser werden nicht in jedem Dorf eingesetzt und ersetzen keine reguläre Virtualisierung.

## Verluste und Rückzug

Rote Gruppen sollen bei hohen Verlusten nicht bis zur vollständigen Vernichtung weiterkämpfen. Rückzug erfolgt zu vorbereiteten Punkten mit kurzen, geprüften Routen.

Überlebende werden erst wieder virtualisiert, wenn:

- der unmittelbare Kontakt beendet ist;
- ausreichende Entfernung erreicht wurde;
- keine relevante Beobachtung besteht;
- eine plausible Hide Site oder ein Rückzugsraum verfügbar ist;
- Verluste und Munitionsstand im CampaignState übernommen wurden.

## Wiederaufbau

Zellen ersetzen Personal, Waffen, Fahrzeuge und Camps mit Verzögerung. Die Geschwindigkeit hängt von regionalem Einfluss, vorhandenen Verstecken, Verlusten und blauem Druck ab.

Zerstörte oder aufgeklärte Hide Sites, Caches und Strongpoints reduzieren lokale Handlungsfreiheit und Regenerationsrate. Neue Hide Sites entstehen nicht automatisch durch einen Respawn-Timer, sondern durch Rückzug, lokale Unterstützung oder erfolgreiche Regeneration.

## Spielerzahlskalierung

Ein gegnerisches Bedrohungsbudget wird aus Zahl und Rollen aktiver Spieler abgeleitet und geglättet. Es beeinflusst parallele Operationen und verfügbare Mittel. Kurzfristige Verbindungswechsel dürfen keine unmittelbaren Großangriffe auslösen.

Die Skalierung verändert nicht die Grundregel der verdeckten Präsenz. Weniger Spieler bedeuten weniger gleichzeitig materialisierte Gruppen, nicht automatisch offen sichtbare oder unrealistisch schwache Siedlungszellen.
