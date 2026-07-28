---
document_id: OMW-LOGISTICS
status: BINDING
document_class: LOGISTICS_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - common logistics manifest and ownership model
  - supported strategic transport modes
  - one-time cargo credit and loss semantics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only logistics wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
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

Dokument 50 ist die quellenqualifizierte historische Referenz. Dieses Dokument bleibt für das technische und strategische Logistikmodell autoritativ.

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

Bis Ende September 2010 waren laut offizieller Army-Quelle mehr als 5.000 M-ATV nach Afghanistan geliefert. Damit sind M-ATV/MRAP als häufige Fahrzeuge für:

- Patrouillen;
- Route Security;
- Convoy Escort;
- QRF;
- EOD-/Route-Clearance-Sicherung;
- Bewegungen zwischen FOBs und COPs

historisch gerechtfertigt.

Die Zahl ist theaterweit und bestimmt keine lokale Sollstärke. Quelle: Dokument 50, S02.

### 6.4 CH-47-Sustainment-Muster

Die CH-47-Studie belegt:

- getrennte Infiltration, Nachversorgung und Exfiltration;
- vier Chinooks pro Nacht allein für Nachschub während Dragon Strike;
- mehrere Turns pro Luftfahrzeug;
- mehrere PZs/HLZs;
- Versorgung eingesetzter Kräfte über 48–72 Stunden beziehungsweise zwei bis fünf Tage;
- starke Belastung kleiner vorgeschobener Detachments.

Für die technische Umsetzung gilt:

- Passagiertransport und Nachschub sind getrennte Manifeste;
- ein Air Assault reserviert nicht automatisch unbegrenzt nachfolgende Versorgung;
- Folgeversorgung erzeugt eigene MissionDemand-Objekte;
- Exfiltration benötigt eine neue Reservierung und verfügbare Luftfahrzeuge;
- ein ausgefallenes CH-47 kann einen kompletten Missionsplan verzögern.

Quelle: Dokument 50, S05.

### 6.5 Maintenance und Mission Readiness

Army-Quellen beschreiben hohen Verschleiß durch:

- hohes OPTEMPO;
- Wüsten- und Gebirgsbedingungen;
- begrenzte Depotinstandsetzung im Theater;
- schneller als geplant alternde Flugzeug- und Fahrzeugflotten.

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

Die Rapid Equipping Force brachte im FY2011 Army-weit mehr als 221 Ausrüstungstypen und 34.245 Einzelgegenstände zu eingesetzten Verbänden. Daraus folgt:

- lokale Sonderausstattung ist plausibel;
- gleichartige Einheiten können unterschiedliche Sensor-, Kommunikations- oder Schutzstände besitzen;
- Sonderausstattung muss quellen- oder missionsbegründet sein;
- sie darf nicht als unbeschränkte Beschaffungsmöglichkeit dienen.

Quelle: Dokument 50, S03.

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
