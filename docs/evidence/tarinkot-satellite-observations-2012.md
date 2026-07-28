---
document_id: OMW-EVIDENCE-TARINKOT-SATELLITE-2012
status: BINDING
document_class: VISUAL_EVIDENCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - classification of the project-owner-supplied Tarinkot satellite observations dated 2012-05-03 and 2012-05-17
  - visually observed aircraft counts and ramp-use findings on those image dates
  - temporal and evidentiary limits of those observations
not_authoritative_for:
  - exact Tarinkot inventory during 2010-08-01 through 2011-12-31
  - historical unit identity
  - mission-ready aircraft count
  - personnel strength
  - final Mission Editor placement
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/tarinkot-air-operations-baseline
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Tarinkot – Satellitenbildbeobachtungen vom 03. und 17. Mai 2012

## 1. Zweck und Zeitgrenze

Dieses Dokument hält die durch den Projektinhaber bereitgestellten Google-Earth-Beobachtungen für Tarinkot beziehungsweise Tarin Kowt fest. Die zugrunde liegenden Bilder werden nicht in das Repository übernommen oder weiterverteilt; dokumentiert werden ausschließlich die daraus abgeleiteten Beobachtungen.

Aufnahmedaten:

```text
03.05.2012
17.05.2012
```

Beide Aufnahmen liegen nach dem verbindlichen OMW-Szenariozeitraum, der am 31.12.2011 endet. Sie werden deshalb ausschließlich als:

```text
POST_PERIOD_CONTEXT
```

geführt. Die zeitliche Nähe macht sie für Rampenlayout, Größenordnung und spätere Standortfunktion relevant. Sie beweisen jedoch nicht, dass am 31.12.2011 exakt dieselben Luftfahrzeuge, Einheiten oder Stückzahlen vorhanden waren.

## 2. Beobachtete Standortstruktur

Die Aufnahmen zeigen mindestens folgende funktionale Bereiche:

1. eine große mittlere Fixed-Wing-Abstellfläche, die auf den ausgewerteten Bildern weitgehend leer ist;
2. eine weitere Fixed-Wing-Abstellfläche am südwestlichen Ende der Start-/Landebahn;
3. einen ausgebauten Hubschrauberbereich mit zwei länglichen Reihen einzelner Abstellflächen;
4. eine offene Fläche unmittelbar nordöstlich beziehungsweise bahnseitig des Hubschrauberbereichs;
5. mehrere ausgewiesene Helikopter-Lande- oder Bereitschaftsflächen.

Die funktionale Trennung zwischen Hubschrauberabstellung, offener Heavy-Lift-Fläche und Fixed-Wing-Abstellung ist für die spätere Mission-Editor-Planung relevant. Konkrete DCS-Parking-IDs oder sichere Spawnpositionen folgen daraus noch nicht.

## 3. Visuell beobachtete Luftfahrzeuge

### 3.1 Konsolidierter Stand vom 17.05.2012

| Muster/Familie | sichtbar | Evidenzklasse | Anmerkung |
|---|---:|---|---|
| AH-64 Apache | 14 | `VISUAL_CONFIRMED` | südliche beziehungsweise untere Abstellreihe |
| UH-60 Black Hawk | 6 | `VISUAL_CONFIRMED` | nördliche beziehungsweise obere Abstellreihe |
| CH-47 Chinook | 1 | `VISUAL_CONFIRMED` | einzeln auf der offenen Fläche |
| OH-58D Kiowa Warrior | 0 bestätigt | `NOT_OBSERVED` | kein Luftfahrzeug konnte belastbar als OH-58D identifiziert werden |
| Fixed-Wing, Typ offen | 1 | `VISUAL_PROBABLE` | wahrscheinlich ziviler, administrativer oder vertraglicher Verkehr; keine lokale Einheit ableitbar |

Damit sind auf dem Bild vom 17.05.2012 mindestens:

```text
21 militärische Drehflügler
```

gleichzeitig sichtbar.

### 3.2 Vergleich zur Aufnahme vom 03.05.2012

Auf der Aufnahme vom 03.05.2012 waren bereits erkennbar:

- 1 CH-47;
- 6 UH-60;
- ungefähr 14 weitere Hubschrauber in der südlichen Reihe, deren Typ wegen Untergrund, Schatten und Auflösung zunächst nicht sicher bestimmt werden konnte.

Die Aufnahme vom 17.05.2012 erlaubt die nachträgliche Typzuordnung dieser südlichen Reihe als AH-64.

## 4. Identifikationsmerkmale der AH-64-Reihe

Die Zuordnung der 14 südlichen Hubschrauber zu AH-64 beruht auf mehreren gemeinsam sichtbaren Merkmalen:

- schmale Tandemkanzel;
- voneinander abgesetzte vordere und hintere Kanzelverglasung;
- seitliche Avionikverkleidungen beziehungsweise charakteristische „Backen“ am vorderen Rumpf;
- schmaler Rumpf und Heckausleger;
- erkennbare Stummelflügel;
- im Vergleich zum UH-60 deutlich andere Rumpfbreite und Kabinenform.

Die Identifikation stützt sich nicht allein auf Rotorblattspitzen oder Schattenformen.

## 5. Erkenntniswert und Grenzen

Direkt belastbar sind:

- die sichtbaren Mindestzahlen am jeweiligen Bilddatum;
- die typbezogene Rampennutzung;
- die Größenordnung eines bedeutenden Attack-/Utility-Aviation-Standorts spätestens im Mai 2012;
- das Vorhandensein einer gesonderten Heavy-Lift-Abstellung;
- die Nutzung der südwestlichen Fixed-Wing-Abstellfläche durch mindestens ein nicht identifiziertes Flugzeug.

Nicht direkt belastbar sind:

- administrative Sollstärke;
- vollständiger lokaler Bestand;
- Mission-Ready-Rate;
- Luftfahrzeuge in Wartung, im Flug oder außerhalb des Bildausschnitts;
- konkrete Squadron-, Company- oder Task-Force-Zuordnung;
- permanenter Fixed-Wing-Bestand;
- Personalstärke aus Zelt-, Gebäude-, Fahrzeug- oder Luftfahrzeugzahlen;
- identische Belegung während des OMW-Zeitraums.

## 6. Abgleich mit der historischen Dokumentation

Die historischen Quellen in Dokument 50 belegen für 2011 einen vorgeschobenen CH-47-Platoon-/Detachment-Standort in Tarinkot als Teil des Kandahar-Regionalpools. Die Quelle beschreibt außerdem die Verteilung von CH-47-Elementen zwischen Kandahar, Tarinkot und FOB Wolverine, nennt aber keine exakte lokale Stückzahl.

Dokument 55 klassifiziert Camp Holland/Tarin Kowt darüber hinaus als Combined-Team-, Partnerschafts-, SOF- und späteren Aviation-Knoten. Die Aufnahme von Mai 2012 ist mit einer erheblich ausgebauten Aviation-Funktion vereinbar, ersetzt aber keinen zeitgenössischen 2010/2011-Nachweis für die exakten AH-64- und UH-60-Zahlen.

## 7. Zulässige Verwendung in Operation Mountain Watch

Die Beobachtungen dürfen verwendet werden für:

- eine quellennahe OMW-Projektentscheidung zur Größenordnung des Tarinkot-Luftfahrtknotens;
- die räumliche Trennung von AH-64-, UH-60-, CH-47- und transienten Fixed-Wing-Flächen;
- eine Rampenbelegungsreferenz für Statics, Clients und aktive KI;
- den Ausschluss einer automatisch angenommenen lokalen OH-58D-Komponente;
- die Einordnung Tarinkots als bedeutenden vorgeschobenen Aviation-Knoten und nicht als kleinen Vier-Luftfahrzeug-Außenposten.

Die Beobachtungen dürfen nicht allein verwendet werden für:

- die Behauptung eines historisch exakt belegten 2011er Bestands von 14 AH-64 und 6 UH-60;
- erfundene Einheitsbezeichnungen;
- eine Personalstärkenschätzung;
- zusätzliche, nicht vom Kandahar-Regionalpool abgezogene Theaterbestände;
- eine technische DCS-Parking- oder MOOSE-Acceptance.

## 8. Bestands- und Darstellungsregel

Bei einer späteren Mission-Editor-Umsetzung gilt:

```text
sichtbare Rampenbelegung
= Statics + besetzte Client-Slots + aktive oder abgestellte KI-Luftfahrzeuge
```

Die beobachteten Werte dürfen nicht gleichzeitig vollständig als Statics angelegt und zusätzlich durch Clients oder KI verdoppelt werden. Der logische Kampagnenbestand, der mission-ready Bestand und die sichtbare Rampenbelegung bleiben getrennte Größen.
