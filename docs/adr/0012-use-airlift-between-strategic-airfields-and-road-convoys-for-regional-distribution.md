# ADR 0012 – Lufttransport zwischen strategischen Flugplätzen und Straßenkonvois für regionale Verteilung verwenden

- Status: Accepted
- Date: 2026-07-13

## Context

TM01A verwendete die Strecke Bagram–Jalalabad als technische Langstreckenroute für Spawn-, Routing- und Ankunftstests. Der Konvoi erreichte Jalalabad zuverlässig, benötigte wegen DCS-Straßenrouting und großer Umwege jedoch mehr als sieben Stunden simulierte Fahrzeit ab Routenzuweisung.

Bagram und Jalalabad verfügen beide über geeignete Flugplätze. Bagram ist der strategische Rückraum mit großen Reserven und zentraler Lufttransportkapazität. Jalalabad Airfield / FOB Fenty ist der regionale operative Logistikknoten für Nangarhar, Laghman, Kunar und Nuristan.

Ein regelmäßiger Straßenpendelverkehr Bagram–Jalalabad wäre deshalb weder spielerisch noch logistisch der bevorzugte Standard. Straßenkonvois sind dort sinnvoll, wo Jalalabad regionale FOBs, COPs, OPs und Checkpoints versorgt und dabei Hinterhalt-, IED-, Escort- und Route-Clearance-Missionen erzeugt.

## Decision

Die reguläre Versorgungshierarchie lautet:

```text
Bagram / Kabul
    │
    │ strategischer oder physischer Fixed-Wing-Lufttransport
    ▼
Jalalabad Airfield / FOB Fenty
    │
    ├── Straßenkonvoi → straßengebundene FOBs, COPs und Checkpoints
    ├── Hubschrauber → abgelegene FOBs, COPs und OPs
    └── Luftabwurf → abgeschnittene oder zeitkritische Ziele
```

### Bagram und Kabul

- bleiben im ersten Prototyp strategisch abstrahierte Reserve- und Herkunftsknoten;
- versorgen Jalalabad/Fenty primär durch gelandeten Lufttransport;
- können bei späterer physischer Nutzung native Warehouse-Anbindungen erhalten;
- erzeugen keine regelmäßige physische Straßenkonvoiroute nach Jalalabad.

### Jalalabad Airfield / FOB Fenty

- ist regionales Lager und operativer Umschlagpunkt;
- empfängt gelandete taktische Lufttransporte;
- stellt regionale Straßenkonvois zusammen;
- stellt Hubschrauber- und QRF-Kapazität bereit;
- verteilt Ressourcen an vorgeschobene Standorte.

### Regionale Straßenkonvois

Die primäre Produktions- und Prototyproute ist:

```text
ROUTE_FENTY_CONNOLLY_PRIMARY
Jalalabad/Fenty → FOB Connolly
```

Weitere Straßenkonvois sind nur für Ziele vorgesehen, deren Straßenanbindung praktisch validiert wurde. Kleine COPs, OPs und Checkpoints erhalten kleinere Fahrzeugpakete statt automatisch den vollständigen Fünf- bis Sechs-Fahrzeug-Standardkonvoi.

### Abgelegene Standorte

- schwer erreichbare FOBs werden bevorzugt mit CH-47 oder vergleichbarer Drehflüglerkapazität versorgt;
- kleine Posten können UH-1-, UH-60- oder einzelne Frachtpakete verwenden;
- Luftabwurf bleibt ein risikobehafteter Sonderpfad für gesperrte Straßen, fehlende Landezonen oder hohe Dringlichkeit.

## Einordnung der Route Bagram–Jalalabad

Die bestehende TM01A-Route wird als technische Referenz- und Stressroute beibehalten:

```text
ROUTE_TM01_BAGRAM_JALALABAD
classification = TEST_STRESS_ROUTE
productionLogistics = false
```

Sie bleibt nützlich für:

- Langzeitstabilität;
- DCS-Pathfinding- und Straßengraphprobleme;
- Ankunfts- und Zustandslogik;
- Performance- und Virtualisierungstests über große Distanz;
- Regressionstests nach DCS- oder MOOSE-Updates.

Sie ist kein regulärer Kampagnenversorgungstakt.

## Ausnahmen

Ein physischer Straßenkonvoi Bagram–Jalalabad darf als besonderes Ereignis erzeugt werden, beispielsweise bei:

- geschlossenem oder beschädigtem Flugplatz;
- Wetter- oder Bedrohungslage, die Lufttransport verhindert;
- Transport nicht luftverladbarer Fahrzeuge oder übergroßer Fracht;
- narrativem Großkonvoi;
- besonderer Escort-, Interdiction- oder Route-Clearance-Mission;
- strategischer Krise mit bewusst akzeptierter langer Laufzeit.

Eine Ausnahme muss im Auftrag ausdrücklich begründet werden.

## Transportauswahl

Der `LogisticsManager` wählt den Transportweg anhand mindestens folgender Kriterien:

- Zielinfrastruktur und zulässige Lieferverfahren;
- Entfernung und erwartete Fahr- beziehungsweise Flugzeit;
- Frachtart, Masse, Volumen und Fahrzeugslots;
- verfügbare Plattformen;
- Straßen-, Flugplatz-, LZ- und Drop-Zone-Status;
- Bedrohung, Wetter, Tageszeit und Dringlichkeit;
- verfügbare Eskorte;
- gewünschter Missionswert für Spieler.

Eine direkte Straßenverbindung allein reicht nicht aus, um einen Konvoi als Standardtransport zu wählen.

## Consequences

### Positive

- strategische und regionale Logistik erhalten klare Rollen;
- die Kampagne vermeidet unplausible mehrstündige Standardkonvois zwischen zwei Flugplätzen;
- Konvoimissionen konzentrieren sich auf taktisch relevante FOB-, COP- und OP-Verbindungen;
- C-130-, Hubschrauber- und Straßenlogistik ergänzen sich statt dieselbe Aufgabe zu duplizieren;
- die lange TM01A-Route bleibt als wertvolle technische Teststrecke erhalten.

### Negative

- Fenty–Connolly benötigt eine neue vollständige Routenaufnahme und DCS-Validierung;
- strategischer Lufttransport und regionale Weiterverteilung benötigen gemeinsame Cargo- und Warehouse-Transaktionen;
- Fahrzeugtransporte per Luftweg bleiben separat zu testen;
- Ausnahmeereignisse Bagram–Jalalabad benötigen eigene Missionsregeln.

## Required validation

- C-130J- oder abstrahierter Transfer Bagram/Kabul → Jalalabad/Fenty;
- genau einmalige Warehouse-Gutschrift in Jalalabad;
- primäre Straßenroute Fenty–Connolly praktisch abfahren;
- typische Fahrzeit, Engstellen und alternative Route erfassen;
- kleine regionale Konvoipakete für COPs und Checkpoints testen;
- Hubschrauberversorgung eines abgelegenen Postens testen;
- LogisticsManager darf Bagram–Jalalabad nicht ohne ausdrückliche Ausnahme als Standardkonvoi wählen.