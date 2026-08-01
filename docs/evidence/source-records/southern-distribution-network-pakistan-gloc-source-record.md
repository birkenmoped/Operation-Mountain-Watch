---
document_id: OMW-EVIDENCE-SDN-PAKISTAN-GLOC
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance and source limits of the supplied Southern Distribution Network map
  - historical Pakistan ground lines of communication through Torkham and Chaman
  - separation of the Southern Distribution Network from the Northern Distribution Network Caucasus route
not_authoritative_for:
  - exact inner-Afghan MSR names or PATHLINE geometry
  - exact local convoy roads between entry gates, hubs and forward bases
  - exact cargo quantities, schedules or CampaignState values for OMW
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: PENDING_CURRENT_COMMIT
validated_in_dcs: false
---

# Southern Distribution Network – Pakistan-GLOC und afghanische Logistikhubs

## 1. Zweck

Diese Quellenakte dokumentiert die vom Projektinhaber bereitgestellte Übersichtskarte `Southern Distribution Network` und gleicht ihre Aussagen mit einer zeitgenössischen amtlichen US-Quelle ab.

Die Karte zeigt eine strategische Zuführung aus pakistanischen Seehäfen über zwei Hauptkorridore nach Afghanistan. Sie ist keine ISAF-MSR-Karte und keine straßengenaue Darstellung der innerafghanischen Verteilung.

## 2. Quellen

### 2.1 Bereitgestellte Karte

```text
Titel im Bild: Southern Distribution Network
Datei: vom Projektinhaber am 31.07.2026 bereitgestellte JPEG-Grafik
sichtbare Datums-/Herausgeberangabe: keine
Originalpublikation: derzeit nicht verifiziert
```

Die Grafik selbst wird wegen der ungeklärten Originalprovenienz nicht als alleinige historische Autorität behandelt. Ihre sichtbaren Aussagen werden in dieser Akte transkribiert und mit amtlichen Quellen abgeglichen.

### 2.2 Amtliche Hauptquelle

- U.S. Government Accountability Office, `GAO-10-842T`, *Warfighter Support: Preliminary Observations on DOD's Progress and Challenges in Distributing Supplies and Equipment to Afghanistan*, 25. Juni 2010: <https://www.gao.gov/products/gao-10-842t>

Die GAO-Aussagen beruhen auf DOD-Dokumenten, Planungsunterlagen und Gesprächen mit unter anderem U.S. Transportation Command, U.S. Central Command, Surface Deployment and Distribution Command, U.S. Forces-Afghanistan, 1st Theater Sustainment Command und Joint Sustainment Command-Afghanistan.

### 2.3 Ergänzende amtliche Terminologiebestätigung

- U.S. Army, 1st Theater Sustainment Command, *The Army's premier logistics unit right sizes Afghanistan*, 12. Dezember 2013: <https://www.army.mil/article/116810/1st_theater_sustainment_command_the_armys_premier_logistics_unit_right_sizes_afghanistan>

Der Army-Bericht verwendet `Southern Distribution Network` ausdrücklich für die Ground Lines of Communication durch Pakistan und stellt sie dem `Northern Distribution Network` durch zentralasiatische Staaten gegenüber.

Quellenklassifikation:

```text
bereitgestellte Karte: INCORPORATED_WITH_LIMITS
GAO-10-842T: INCORPORATED
Army-Terminologiebestätigung: INCORPORATED_WITH_LIMITS
```

## 3. Sichtbarer Inhalt der Karte

Die Karte zeigt Karachi als maritimen Ausgangs- und Umschlagpunkt und zwei farblich getrennte Korridore.

### 3.1 Östlicher/nördlicher Pakistan-Korridor

Die rote Linie verläuft schematisch:

```text
Karachi
→ Sindh / Raum Hyderabad
→ Punjab / Raum Multan
→ Raum Islamabad–Peshawar
→ Khyber-/Torkham-Korridor
→ Jalalabad
→ Kabul-/Bagram-Verteilraum
```

Die Grenzbezeichnung `Torkham` ist im Bild nicht ausgeschrieben. Die Lage der Linie über Peshawar nach Jalalabad und die GAO-Bestätigung erlauben jedoch eine hohe Zuordnungssicherheit zum Torkham-Korridor.

### 3.2 Westlicher Pakistan-Korridor

Die orange Linie verläuft schematisch:

```text
Karachi
→ Quetta
→ Chaman / Weesh–Spin-Boldak-Korridor
→ Kandahar
```

Auch `Chaman` ist im Bild nicht beschriftet. Der Verlauf über Quetta nach Kandahar und die GAO-Bestätigung erlauben eine hohe Zuordnungssicherheit zum Chaman-Korridor.

### 3.3 Dargestellte afghanische Standorte

Die Karte bezeichnet folgende Standorte beziehungsweise Empfängeräume:

```text
Bagram
Kabul
Jalalabad
Khowst
Shank
Sharona
Kandahar
```

Weiße Pfeile verbinden die Beschriftungen mit schwarzen Standortpunkten. Sie sind als schematische Standortzuordnung zu lesen, nicht als eingezeichnete Straßen- oder MSR-Segmente.

Rote Ovale heben den Kabul-/Bagram-/Jalalabad-Verteilraum und Kandahar hervor. Daraus darf keine exakte Hub-Grenze, Route oder Straßenhierarchie abgeleitet werden.

## 4. Amtlich bestätigte Pakistan-GLOC

GAO beschreibt den Haupt-Surface-Flow wie folgt:

```text
kommerzieller Seetransport
→ Hafen Karachi
→ contractor-operated trucks
→ Pakistan ground route
→ Torkham oder Chaman
→ afghanischer Logistikhub
```

Typische Zuordnung:

```text
Torkham crossing → Bagram logistics hub
Chaman crossing  → Kandahar logistics hub
```

GAO nennt als ungefähre Entfernungen:

```text
Karachi → Bagram:   1.210 miles
Karachi → Kandahar:   690 miles
```

Die Zuordnung ist eine typische strategische Destinationsbeziehung. Sie bedeutet nicht, dass jedes Fahrzeug unverändert bis Bagram oder Kandahar fuhr oder dass nur eine einzige innerafghanische Straße genutzt wurde.

## 5. Transportierte Güter und Verkehrsbedeutung

Über Pakistan wurden laut GAO sowohl Unit Equipment als auch Sustainment Materiel transportiert, darunter:

- Fahrzeuge und sonstige einheitsspezifische Ausrüstung;
- Lebensmittel und Wasser;
- Baumaterial;
- Ersatzteile;
- Kraftstoff.

Hochpriorisierte und sensitive Güter, darunter Waffensysteme und Munition, wurden dagegen häufig per militärischem oder kommerziellem Lufttransport zu afghanischen Logistikhubs gebracht.

Für Mai bis November 2009 nennt GAO:

```text
Pakistan surface routes: mehr als 21.500 TEU
Northern Distribution Network: mehr als 4.700 TEU
```

Damit waren die Pakistan-Routen zu diesem Zeitpunkt der deutlich stärker genutzte Surface-Korridor. Diese Mengen sind historische Vergleichswerte und keine OMW-Bestands- oder Lieferfrequenzvorgabe.

## 6. Grenz-, Sicherheits- und Kapazitätsprobleme

### 6.1 Contractor-Abhängigkeit

Innerhalb Pakistans operierten keine US-Militärtransporteinheiten. DOD war vollständig auf private Auftragnehmer für Transport und Ladungssicherung angewiesen.

### 6.2 Chaman-Kapazität

GAO dokumentiert für Chaman eine Begrenzung auf insgesamt 100 Lastwagen pro Tag. Angriffe im Grenzraum führten zu zusätzlichen Sicherheitsmaßnahmen und Rückstaus. Rückstaus am Grenzübergang konnten wiederum Fahrzeuge binden und die Abholung weiterer Ladung in Karachi verzögern.

### 6.3 Angriffe und Diebstahl

Lkw auf den Pakistan- und Afghanistan-Ground-Routes sowie abgestellte Fahrzeuge an Terminals und Grenzübergängen waren Angriffsziele. GAO nennt unter anderem:

- Angriffe auf zwei Terminals in Peshawar an zwei aufeinanderfolgenden Tagen im März 2009;
- 31 beschädigte oder zerstörte Fahrzeuge und Trailer bei diesen Angriffen;
- 44 verlorene Lastwagen und 220.000 Gallonen Kraftstoff durch Angriffe oder andere Ereignisse allein im Juni 2008;
- geschätzte Entwendung von ungefähr einem Prozent der auf den Pakistan-Routen transportierten Ladung, bei zugleich eingeschränkter Messgenauigkeit.

Diese Werte beschreiben den strategischen Transportkorridor. Sie dürfen nicht als IED- oder Hinterhaltsrate für eine bestimmte afghanische MSR übernommen werden.

### 6.4 Eingeschränkte Transportverfolgung

In Karachi bestand Sichtbarkeit beim Umschlag. Entlang der Pakistan-Routen war die RFID-Abdeckung lückenhaft; Fahrer waren nicht an eine einzige vorgeschriebene Straßenführung gebunden. Teilweise erschien eine Ladung erst am Grenzübergang wieder in der Erfassung.

Damit stützt die Quelle ein logistisches Modell mit Unsicherheit über Position und Ankunftszeit während des Transits.

## 7. Weiterverteilung innerhalb Afghanistans

Nach dem Eingang in Bagram, Kandahar oder einem anderen Hub wurde Fracht weiter zu FOBs und COPs transportiert:

- überwiegend durch afghanische beziehungsweise Host-Nation-Contractor-Trucks;
- teilweise durch US-Militär-Lkw;
- per kleinerem Fixed Wing oder Airdrop bei hochpriorisierten oder sensitiven Gütern;
- ergänzend durch Rotary Wing nach lokaler Verfügbarkeit und Missionsbedarf.

GAO schätzte, dass ungefähr 90 Prozent des innerafghanischen Straßentransports durch private Auftragnehmer und ungefähr 10 Prozent durch US-Militär-Lkw erfolgten. Diese theaterweite Verteilung darf nicht ohne lokale Quelle auf einen einzelnen RC-, FOB- oder MSR-Sektor übertragen werden.

## 8. Terminologische Trennung

Für OMW gilt verbindlich:

```text
Southern Distribution Network / SDN
= Pakistan-GLOC über Karachi, Torkham und Chaman
```

```text
Northern Distribution Network / NDN
= Korridorfamilie über Europa, Russland, Kaukasus und Zentralasien
```

Innerhalb des NDN existierten unter anderem:

```text
NDN northern rail route
Riga/Tallinn → Russland → Kazakhstan → Uzbekistan → Hairatan

NDN Caucasus/Poti route
Poti → Baku → Kaspisches Meer → Kazakhstan → Uzbekistan → Hairatan
```

Die Bezeichnung `NDN South` für den Kaukasus-Korridor ist nur innerhalb der NDN-Korridorfamilie verständlich und kann leicht mit dem Pakistan-basierten `Southern Distribution Network` verwechselt werden. In OMW soll deshalb bevorzugt `NDN CAUCASUS / POTI ROUTE` verwendet werden.

## 9. Verhältnis zu MSR EAST-E3

Die Karte und GAO belegen:

- strategischer Eingang über Torkham;
- Jalalabad als erster großer afghanischer Knoten im Khyber-Korridor;
- Bagram als typischer Logistikhub für Fracht über Torkham;
- Weiterverteilung über das afghanische Straßennetz.

Sie belegen nicht:

- die konkrete lokale Straße zwischen Kabul und Bagram;
- die Zuordnung von `MSR EAST-E3` zur Kabul–Charikar-/NH01-Achse oder zur direkten Kabul–Bagram-/Old-Russian-Road-Achse;
- einen zwingenden unveränderten Direktlauf Torkham–Bagram;
- eine meter- oder straßengenaue DCS-`PATHLINE`.

Die Quelle stärkt damit die logistische Bedeutung des Ostkorridors und Bagrams, entscheidet aber die offene EAST-E3-Geometrie nicht.

## 10. OMW-Modell

Zulässige strategische Korridorobjekte:

```text
GLOC_SDN_TORKHAM
GLOC_SDN_CHAMAN
ENTRY_TORKHAM
ENTRY_WEESH_CHAMAN
HUB_BAGRAM
HUB_KANDAHAR
```

Mögliche Statusfelder:

```text
borderStatus
portBacklog
truckAvailability
contractorSecurity
cargoVisibility
transitDelay
attackDisruption
pilferageRisk
```

Diese Felder sind OMW-Designvorschläge. Historische Quellen belegen die zugrunde liegenden Probleme, aber keine konkreten Simulationswerte oder Wahrscheinlichkeiten.

## 11. Quellenbewertung

### Bereitgestellte Karte

Stärken:

- übersichtliche Darstellung der beiden Pakistan-Korridore;
- korrekte strategische Hub- und Raumlogik;
- sichtbare Trennung der Torkham-/Bagram- und Chaman-/Kandahar-Achsen.

Grenzen:

- Herausgeber und Datum nicht sichtbar;
- schematische Linienführung;
- keine Straßenklassen oder Segmentnamen;
- keine Legende für Punkte, Pfeile oder rote Ovale;
- keine lokale Routengenauigkeit.

### GAO-10-842T

Stärken:

- zeitgenössische amtliche Prüfung;
- direkte Abstimmung mit relevanten DOD-Logistikorganisationen;
- konkrete Gate-, Hub-, Mengen-, Entfernungs- und Risikoinformationen;
- klare Trennung zwischen strategischem Eingang und innerafghanischer Verteilung.

Grenzen:

- keine ISAF-MSR-Karte;
- keine vollständige lokale Routengeometrie;
- überwiegend theaterweite oder systemische Werte;
- Snapshot des Planungs- und Betriebsstands 2009/2010.

## 12. Repository-Ziele

Fachliche Hauptreferenz:

- [`OMW-LOGISTICS`](../../05-logistics.md)

Strategische Nordzuführung:

- [`OMW-EVIDENCE-NDN-CSIS-2010`](northern-distribution-network-csis-2010-source-record.md)

Lokale MSR- und PATHLINE-Abgrenzung:

- [`OMW-MSR-ROUTE-DESIGN`](../../49-msr-routendesign-und-infrastrukturmarker.md)
- [`MSR EAST-E3, California, Vermont und Oregon – Quellenakte`](msr-east-california-vermont-oregon-source-record-2026-07-31.md)
