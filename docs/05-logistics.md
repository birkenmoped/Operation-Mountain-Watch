---
document_id: OMW-LOGISTICS
status: BINDING
document_class: LOGISTICS_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - common logistics manifest and ownership model
  - supported strategic transport modes
  - one-time cargo credit and loss semantics
  - separation of theater-level supply ingress from inner-Afghan distribution
  - separation of the Pakistan Southern Distribution Network from Northern Distribution Network corridors
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only logistics wording
superseded_by:
source_branch: main
source_commit: c3762527fa92f38eee3860642128d6b2bb7f561f
validated_in_dcs: false
---

# 05 – Logistik

## 1. Zweck und Autorität

Logistik ist strategisch und spielerisch relevant, ohne unnötiges Mikromanagement. Hauptbasen verfügen über große strategische Reserven; lokale Knoten besitzen begrenzte, tatsächlich zu transportierende Bestände.

Der vollständige frühere Logistikentwurf bleibt unverändert erhalten:

- [`Legacy-Logistikarchitektur`](evidence/source-records/legacy-05-logistics.md)

Maßgebliche Grundlagen:

- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`MOOSE-Logistik und Transport`](moose/LOGISTICS-AND-TRANSPORT.md)
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md)
- [`OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS`](52-army-aviation-vignettes-and-coin-intelligence-metrics.md)
- [`OMW-EVIDENCE-NDN-CSIS-2010`](evidence/source-records/northern-distribution-network-csis-2010-source-record.md)
- [`OMW-EVIDENCE-SDN-PAKISTAN-GLOC`](evidence/source-records/southern-distribution-network-pakistan-gloc-source-record.md)

Dokument 50 ist die quellenqualifizierte historische Referenz für Kräfte-, Basierungs- und Aviation-Sustainment-Fragen. Dokument 52 ergänzt missionsbezogene Army-Aviation-Einsatzmuster. Die NDN- und SDN-Quellenakten dokumentieren strategische Zuführungskorridore und deren Grenzen. Dieses Dokument bleibt für das technische und strategische Logistikmodell autoritativ.

## 2. Transportarten

- `ROAD_CONVOY`;
- `HELICOPTER_INTERNAL`;
- `HELICOPTER_SLING`;
- `FIXED_WING_LANDED`;
- `FIXED_WING_AIRDROP`;
- ausdrücklich genehmigte begrenzte AI-Notversorgung.

Kein Transportverfahren ersetzt automatisch die anderen. Kapazität, Reichweite, Infrastruktur, Bedrohung und Verfügbarkeit bestimmen die Auswahl.

Historisch belegte Zusatzaufgaben werden als Spezialisierungen der vorhandenen Transportarten modelliert:

```text
FARP_FUEL_DELIVERY
FARP_AMMUNITION_DELIVERY
AOG_PARTS_DELIVERY
AIRCRAFT_RECOVERY_SUPPORT
COP_EMERGENCY_RESUPPLY
MEDEVAC_TRANSFER
BASE_CLOSURE_RETROGRADE
```

Sie erzeugen keine neuen Ressourcenarten ohne eigenes Manifest.

## 3. Gemeinsames Manifestmodell

Jede Lieferung besitzt genau eine stabile Cargo-ID und ein Manifest mit mindestens:

```text
cargoId
resourceType
quantity
weight
volume
origin
destination
transportMode
carrierEntityId
status
reservationId
historicalSourceIds
missionDemandId
```

Zustände umfassen unter anderem:

```text
AVAILABLE
RESERVED
LOADING
INTERNAL
SLING
IN_TRANSIT
TRANSFERRED
DELIVERED
LOST
DESTROYED
```

Eine Cargo-ID darf einem Zielbestand genau einmal gutgeschrieben werden. Umschlag oder Wechsel des Transportmittels erzeugt keine neue Ressource.

## 4. CampaignState- und Laufzeittrennung

CampaignState führt Eigentum, Menge, Reservierung und Ergebnis. MOOSE CTLD, `OPSTRANSPORT`, DCS Dynamic Cargo, Slingload-Objekte und Gruppen führen die operative Darstellung aus.

Ein projektspezifischer Adapter darf nur nach der vollständigen MOOSE-Prüfung und ausdrücklicher Projektinhaberfreigabe eingesetzt werden.

## 5. Verlust und Abschluss

- zerstörte oder endgültig verlorene Fracht wird nicht gutgeschrieben;
- ein zerstörter Transport kann nicht allein durch vorheriges Entladen automatisch als erfolgreich gelten, wenn die Missionsbedingungen seinen Erhalt verlangen;
- stabile Endposition und gültige Übergabezone werden vor Gutschrift geprüft;
- Teillieferung, Notabwurf und Umschlag werden ausdrücklich modelliert;
- alle Zustandsänderungen werden mit Cargo- und Entity-ID protokolliert.

## 6. Historische Sustainment-Baseline

### 6.1 Luftversorgung als strukturelle Notwendigkeit

Die offizielle Surge-Darstellung belegt:

- mehr als die Hälfte der Straßen war unbefestigt;
- Highway 1 war die zentrale Ringstraßenachse;
- zahlreiche abgelegene Außenposten waren auf Luftversorgung angewiesen;
- IED-Bedrohung, Gelände und Straßenzustand begrenzten Bodentransport.

Daraus folgt:

- Convoy und Luftversorgung müssen parallel existieren;
- ein abgeschnittener COP kann trotz vorhandener Theaterreserven lokal in einen kritischen Zustand geraten;
- Wetter, Feindlage, FARP-Verfügbarkeit und Aircraft Readiness beeinflussen die Lieferzeit;
- strategische Reserven auf Bagram oder Kandahar sind nicht ohne Transportleistung am Ziel verfügbar.

Quelle: Dokument 50, S01.

### 6.2 FARP, Refuel und Rearm

Direkte Quellen belegen FARP-Betrieb unter anderem:

- Camp Wright durch Echo Troop, 3-17 CAV;
- FOB Wilson durch E Troop, 2-17 CAV;
- schnelle Betankung und Wiederbewaffnung von AH-64/OH-58D;
- 24/7-Betrieb kleiner FARP-Teams;
- operative Rückkehr der Luftfahrzeuge nach kurzem Turnaround.

Für CampaignState werden mindestens getrennt:

```text
FUEL_AVGAS_JP8
AMMUNITION_ROCKETS_70MM
AMMUNITION_HELLFIRE
AMMUNITION_30MM
AMMUNITION_50CAL
FLARES_CHAFF
MAINTENANCE_PARTS_LIGHT
MAINTENANCE_PARTS_HEAVY
AIRCRAFT_ENGINE_MODULE
```

Die endgültigen Ressourcennamen und Mengen benötigen eine eigene Datenentscheidung. Historische Quellen belegen die Funktion, nicht automatisch den Verbrauchswert pro Sortie.

### 6.3 M-ATV und geschützte Mobilität

Bis Ende September 2010 waren laut offizieller Army-Quelle mehr als 5.000 M-ATV nach Afghanistan geliefert. Damit sind M-ATV/MRAP als häufige Fahrzeuge für Patrouillen, Route Security, Convoy Escort, QRF, EOD-/Route-Clearance-Sicherung und Bewegungen zwischen FOBs und COPs historisch gerechtfertigt.

Die Zahl ist theaterweit und bestimmt keine lokale Sollstärke. Quelle: Dokument 50, S02.

### 6.4 CH-47-Sustainment-Muster

Die CH-47-Studie belegt getrennte Infiltration, Nachversorgung und Exfiltration, vier Chinooks pro Nacht allein für Nachschub während Dragon Strike, mehrere Turns pro Luftfahrzeug, mehrere PZs/HLZs, Versorgung eingesetzter Kräfte über 48–72 Stunden beziehungsweise zwei bis fünf Tage sowie starke Belastung kleiner vorgeschobener Detachments.

Für die technische Umsetzung gilt:

- Passagiertransport und Nachschub sind getrennte Manifeste;
- ein Air Assault reserviert nicht automatisch unbegrenzt nachfolgende Versorgung;
- Folgeversorgung erzeugt eigene MissionDemand-Objekte;
- Exfiltration benötigt eine neue Reservierung und verfügbare Luftfahrzeuge;
- ein ausgefallenes CH-47 kann einen kompletten Missionsplan verzögern.

Quelle: Dokument 50, S05.

### 6.5 Maintenance und Mission Readiness

Army-Quellen beschreiben hohen Verschleiß durch hohes OPTEMPO, Wüsten- und Gebirgsbedingungen, begrenzte Depotinstandsetzung im Theater und schneller als geplant alternde Flugzeug- und Fahrzeugflotten.

Bis 31.07.2011 wurden Army-weit mehr als 290 Starr- und Drehflügler durch ein spezielles Inspektions-/Reparaturprogramm wieder gefechtsbereit gemacht. Diese Zahl ist kein Afghanistan-Bestand, belegt aber die Größenordnung der Reparaturlast.

CampaignState trennt deshalb:

```text
nominalInventory
missionReadyInventory
maintenanceInventory
damagedInventory
destroyedInventory
```

Erweiterbare technische Zustände:

```text
TURNAROUND_REFUEL
TURNAROUND_REARM
AOG_WAITING_PARTS
FIELD_REPAIR
DEPOT_REPAIR
RECOVERY_PENDING
```

Eine Einführung dieser Zustände benötigt eine MOOSE-First-Prüfung und eigene Acceptance.

Quelle: Dokument 50, S03.

### 6.6 Rapid Equipping und lokale Varianten

Die Rapid Equipping Force brachte im FY2011 Army-weit mehr als 221 Ausrüstungstypen und 34.245 Einzelgegenstände zu eingesetzten Verbänden. Daraus folgt, dass lokale Sonderausstattung plausibel ist, gleichartige Einheiten unterschiedliche Sensor-, Kommunikations- oder Schutzstände besitzen können und Sonderausstattung quellen- oder missionsbegründet bleiben muss.

Quelle: Dokument 50, S03.

### 6.7 Northern Distribution Network und strategische Theaterzuführung

Die zeitgenössische CSIS-Analyse vom Januar 2010 beschreibt das `Northern Distribution Network` als kommerziell basierten strategischen Versorgungskorridor für Afghanistan. Es diente der Redundanz gegenüber der stark gefährdeten und politisch verwundbaren Pakistan-Zuführung sowie der Aufnahme des zusätzlichen nichtmilitärischen Versorgungsbedarfs des US-Aufwuchses 2009/2010.

Quellenbelegte Hauptkorridore:

```text
NDN NORTHERN RAIL ROUTE
Riga oder Tallinn
→ Russland
→ Kazakhstan
→ Uzbekistan
→ Termez–Galaba–Hairatan
→ Afghanistan
```

```text
NDN CAUCASUS / POTI ROUTE
Türkei oder Europäische Union
→ Poti
→ Baku
→ Kaspisches Meer
→ Atyrau oder Aktau
→ Uzbekistan
→ Afghanistan
```

Für September 2009 nennt die Quelle etwa 30 Prozent der damaligen NDN-Sendungen für den Kaukasus-Korridor. Der Bericht erwähnt außerdem nahezu täglichen Bahnverkehr ab Hairatan mit Lebensmitteln beziehungsweise landwirtschaftlichen Produkten, Petroleumprodukten und Baumaterial.

Die Quelle belegt damit einen realen strategischen Gütereingang nach Afghanistan, aber nicht die anschließende straßen- oder schienengenaue Verteilung zu einzelnen US-/ISAF-Basen. Insbesondere bestimmt sie keine lokale MSR-Bezeichnung und keine DCS-`PATHLINE`.

Für OMW gilt daher verbindlich:

1. strategische Theaterzuführung und innerafghanische Verteilung sind getrennte Logistikstufen;
2. ein offener NDN-Korridor erzeugt keine unmittelbare Gutschrift an einem FOB oder COP;
3. Fracht muss nach dem Eingang in Afghanistan weiterhin über regionale Hubs, Straßenkonvois, Fixed Wing oder Rotary Wing verteilt werden;
4. eine strategische Transitstörung kann Theaterreserven verzögern, auch wenn lokale MSRs offen sind;
5. eine lokale MSR-Sperrung kann Versorgung am Ziel verhindern, obwohl der strategische GLOC offen ist;
6. NDN-Quellen dürfen nicht zur Festlegung lokaler Routenlinien verwendet werden.

Quelle: [`OMW-EVIDENCE-NDN-CSIS-2010`](evidence/source-records/northern-distribution-network-csis-2010-source-record.md).

### 6.8 Southern Distribution Network über Pakistan

Das `Southern Distribution Network` bezeichnet die strategischen Ground Lines of Communication durch Pakistan. Es darf nicht mit dem innerhalb der NDN-Korridorfamilie gelegenen Kaukasus-/Poti-Korridor verwechselt werden.

Quellenbelegte Grundstruktur:

```text
SDN TORKHAM CORRIDOR
Karachi
→ Pakistan northbound surface route
→ Peshawar / Khyber corridor
→ Torkham
→ Jalalabad
→ Bagram logistics hub
```

```text
SDN CHAMAN CORRIDOR
Karachi
→ Quetta
→ Chaman / Weesh–Spin Boldak
→ Kandahar logistics hub
```

Die GAO-Prüfung vom Juni 2010 nennt für den üblichen strategischen Fluss:

```text
Torkham crossing → Bagram logistics hub
Chaman crossing  → Kandahar logistics hub
```

Über Pakistan wurden sowohl Unit Equipment als auch Sustainment Materiel transportiert, darunter Fahrzeuge, Lebensmittel, Wasser, Baumaterial, Ersatzteile und Kraftstoff. Hochpriorisierte und sensitive Güter wurden häufiger per Lufttransport bewegt.

Für OMW gilt verbindlich: Torkham und Chaman sind strategische Entry Nodes, keine automatischen lokalen Warehouse-Gutschriften; Bagram und Kandahar sind strategische Hubs, von denen die innerafghanische Verteilung getrennt modelliert wird.

Quelle: [`OMW-EVIDENCE-SDN-PAKISTAN-GLOC`](evidence/source-records/southern-distribution-network-pakistan-gloc-source-record.md).

### 6.9 Quantitative Aviation-Nutzungs- und Fuel-Throughput-Benchmarks

Für die laufende Bestands- und Days-of-Supply-Planung werden historische Einsatz- und Durchsatzwerte ausdrücklich als **Plausibilitäts- und Kalibrierungsdaten** geführt. Sie sind keine automatische Warehouse-Sollmenge und dürfen nicht ohne Scope-Prüfung auf einzelne Flugplätze oder Muster heruntergerechnet werden.

| Quelle / Scope | Belegter Wert | Zulässige Verwendung | Nicht zulässige Ableitung |
|---|---|---|---|
| 10th CAB / Task Force Falcon, Afghanistan 2011 | 127.075 Flugstunden in 31.362 Missionen; 1.279 Air Assaults; 2.823 MEDEVAC-Missionen; 298 Phase Inspections; 5.270 Patienten; 18.703.777 US-gal gepumpter Kraftstoff | Brigadeweite OPTEMPO-, Maintenance- und Fuel-Throughput-Plausibilisierung | kein Bagram-only-Verbrauch, kein Verbrauch pro Muster oder Sortie |
| 6-6 CAV / Task Force Six Shooters, N2KL 2011 | 40-Hubschrauber-Flotte; >30.000 Flugstunden; 13 Battalion-, 30 Company- und >100 SOF-Air-Assaults; >50.000 Passagiere; >1.200 Sling Loads / >7 Mio. lb Cargo; >700 MEDEVAC-Patienten; 60 Hoist-Missionen | regionaler Aviation-Hub-/Task-Force-OPTEMPO und Cargo-/MissionDemand-Kalibrierung | keine Annahme, dass alle 40 Luftfahrzeuge gleichzeitig in Jalalabad standen; keine Fuelmenge ohne separate Quelle |
| TF Ready / 5-158 AVN, RC-West 2011 | gestaffelter 60-Tage-Aufbau; Maintenance Company unterstützte 40 Luftfahrzeuge und führte acht Phase Inspections durch | Shindand-/RC-West-Readiness-, Deployment- und Ersatzteil-/Maintenance-Plausibilisierung | 40 Luftfahrzeuge sind kein Shindand-Bestand und keine Musteraufteilung |
| TF Spearhead / RC-West, Jun–Sep 2011 | >1.000.000 US-gal Kraftstoff in weniger als vier Monaten an US-, Koalitions- und zivile Luftfahrtkunden ausgegeben | regionaler Rotary-Wing-Fuel-Throughput-Check | kein Shindand-only-Verbrauch; Millionengrenze wurde am Camp Victory erreicht |
| Kandahar Mustang Ramp FARP, 2011 | 50.000-US-gal-JP-8-Bladder-Quelle, sechs Fueling Points, ca. 10.000–15.000 US-gal/Tag bei voller Kapazität | lokaler FARP-Puffer-/Durchsatz-Benchmark; zeigt Größenordnung mehrtägiger Forward-Fuel-Puffer | keine Gleichsetzung mit gesamtem Kandahar-Airfield-Verbrauch oder strategischer Reserve |
| FOB Salerno FARP, Nov 2011 | Hot-/Cold-Refuel-Betrieb und „thousands of gallons“ Kraftstoff im unmittelbaren FARP-Bereich | Nachweis realer lokaler Fuel-Puffer und FARP-Betrieb | keine exakte Stock- oder Tagesverbrauchszahl |
| Army cargo helicopters / CH-47 in Afghanistan, Sep 2010 | 60–80 Flugstunden pro Monat gegenüber 20–25 Stunden in CONUS | per-aircraft Heavy-Lift-Utilization-Plausibilität | keine automatische Sortie- oder Fuelrate ohne Missionsprofil und Verbrauchsmodell |
| C/3-10 AVN Mountain Dustoff, bis Jul 2011 | >2.300 Missionen und >3.500 transportierte Patienten seit Herbst 2010 | MEDEVAC-MissionDemand-/OPTEMPO-Plausibilität | kein per-aircraft Wert ohne belegten Aircraft-Denominator |
| A/1-169 AVN, Afghanistan 2011 | >5.000 Flugstunden; nahezu sieben Missionen pro Tag über zehn Monate | UH-60-Utility-OPTEMPO-Plausibilität für Bagram-/RC-East-Kontext | keine allgemeine UH-60-Flottenrate und kein lokaler Fuelverbrauch ohne weitere Daten |

Für das aktuelle Ressourcenmodell folgt daraus:

1. `aircraft fuel capacity` ist nicht mit `sortie fuel consumption` gleichzusetzen.
2. Ein belastbarer Mindestbestand benötigt je Muster/Einheit einen nachvollziehbaren Einsatzsatz oder Flugstundenansatz **und** einen belastbaren Verbrauch pro Flugstunde beziehungsweise Missionsprofil.
3. Brigade- oder Task-Force-Gesamtwerte dürfen nur top-down zur Plausibilisierung eines errechneten OMW-Gesamtbedarfs genutzt werden.
4. Standortbezogene FARP-Durchsatzwerte sind für lokale Puffer geeignet, aber nicht automatisch für strategische Hauptlager.
5. Split-based Detachments und vorgeschobene FARPs benötigen eigene Puffer; ihr Verbrauch bleibt Teil des Parent-Pools und darf theaterweit nicht doppelt gezählt werden.
6. Maintenance-/Phase-Inspection-Daten sind neben Fuel und Munition für Ersatzteil- und Aircraft-Availability-Modelle relevant.
7. Historische Verbrauchswerte und OMW-Designentscheidungen bleiben getrennt. Eine Bestandszahl wird erst verbindlich, wenn sie im zuständigen Ressourcen-/Warehouse-Vertrag ausdrücklich beschlossen ist.

Quellen: *Army Aviation*, März/April 2012, 2011 AAAA National Award Winners (TF Six Shooters / TF Falcon); *Army Aviation*, November 2011, „The Mission Ready Experience: Afghanistan“; ergänzende direkte Army-/DVIDS-/USACE-Belege im AirOps-Logistics-Evidence-Register und Dokument 50/52.

## 7. Logistische Standortfunktionen

| Standorttyp | Mindestfunktion |
|---|---|
| strategische Hauptbasis | große Reserve, schwere Wartung, Fixed-Wing- und Rotary-Wing-Umschlag |
| regionaler Aviation-Hub | lokaler AIRWING-/Warehouse-Anker, FARP-/Maintenance-Funktion, taktischer Transport |
| vorgeschobenes Aviation-Detachment | begrenzte Reserve, Turnaround, leichte Wartung, abhängig vom Parent-Hub |
| FARP | Kraftstoff, ausgewählte Munition, begrenzte Crew-/Sicherungsfunktion |
| FOB/COP | lokaler Verbrauch, Garnison, medizinische/defensive Mindestfähigkeit |
| PZ/HLZ | kein eigener strategischer Bestand ohne ausdrückliche Übergabezone |

Detachments besitzen keine unabhängige unendliche Versorgung. Ihr Bestand wird aus dem Parent-Hub transportiert oder beim Split-Basing explizit zugeordnet.

## 8. Acceptance

Jeder Transportpfad benötigt eigene Tests für:

- Aufnahme und Reservierung;
- Gewicht und Kapazität;
- Übergabe und Einmalgutschrift;
- Zerstörung, Abbruch und Disconnect;
- Multiplayer-Synchronisation;
- Persistenz und Missionsneustart;
- Parent-/Detachment-Bestandsabbuchung;
- Folgeversorgung und Exfiltration;
- FARP-Refuel-/Rearm-Übergabe;
- AOG-/Maintenance-Zustände, falls umgesetzt;
- verwendete DCS- und MOOSE-Version.
