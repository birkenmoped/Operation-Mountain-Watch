---
document_id: OMW-ARCH-AMMUNITION-RESOURCE-ID-CONTRACT
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - strategic CampaignState ammunition resource identifiers
  - separation of M230, GAU-8 and OH-58 M3P ammunition ownership
  - Bagram fighter AIM-120 and AIM-9 strategic resource identifiers
  - migration boundary for superseded generic ammunition identifiers
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - generic AMMUNITION_30MM resource interpretation
  - generic AMMUNITION_50CAL resource interpretation for the OH-58 M3P path
superseded_by:
source_branch: agent/ammunition-resource-id-split
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/storage-weapon-item-matrix
base_commit: acb8955c6256bcaf1107227ec5869151d3cb4542
base_status: ACCEPTED_TECHNICAL_BASELINE_CHILD_BRANCH
merged_to_main: false
---

# Ammunition Resource-ID Contract

## 1. Owner-Entscheidung

Der Projektinhaber hat am 11.08.2026 entschieden, die zuvor generisch gefuehrten 30-mm- und .50-cal-Munitionsressourcen fuer die betroffenen AirOps-Waffensysteme getrennt zu fuehren. Am 13.08.2026 wurde die bereits in der AirOps-Logistikplanung gefuehrte endliche Bagram-Fighter-A/A-Deployment-Stock-Regel bestaetigt; dafuer werden AIM-120 und AIM-9 als getrennte strategische Ressourcen gefuehrt.

Verbindliche strategische Resource IDs:

```text
AMMUNITION_30MM_M230
AMMUNITION_30MM_GAU8
AMMUNITION_50CAL_M3P
AMMUNITION_AIM120
AMMUNITION_AIM9
```

Die bestehenden Familien bleiben zusaetzlich bestehen, soweit sie fachlich bereits eindeutig sind:

```text
AMMUNITION_HELLFIRE
AMMUNITION_ROCKETS_70MM
FLARES_CHAFF
MAINTENANCE_PARTS_LIGHT
MAINTENANCE_PARTS_HEAVY
AIRCRAFT_ENGINE_MODULE
```

## 2. Verbindliche Bedeutung

```text
AMMUNITION_30MM_M230
  -> strategischer CampaignState-Bestand fuer AH-64/M230-Munition

AMMUNITION_30MM_GAU8
  -> strategischer CampaignState-Bestand fuer A-10/GAU-8-Munition

AMMUNITION_50CAL_M3P
  -> strategischer CampaignState-Bestand fuer den OH-58/M3P-.50-cal-Pfad

AMMUNITION_AIM120
  -> endlicher strategischer CampaignState-Bestand der Bagram-Fighter-AIM-120-Familie

AMMUNITION_AIM9
  -> endlicher strategischer CampaignState-Bestand der Bagram-Fighter-AIM-9-Familie
```

Diese Ressourcen sind nicht gegeneinander austauschbar. Eine Mission darf Bestand einer Resource ID nicht als Ersatz fuer eine andere Resource ID verwenden, auch wenn Kaliber- oder Waffenfamilienbezeichnungen teilweise verwandt sind.

Fuer `AMMUNITION_AIM120` und `AMMUNITION_AIM9` gilt zusaetzlich der spezielle Vertrag aus `docs/bagram-fighter-deployment-ammunition-stock-policy.md`:

```text
initial stock source = deployment inventory only
normal campaign resupply = none
DoS stock sizing = not applicable
reserve-factor stock sizing = not applicable
```

## 3. Superseded Generic IDs

Fuer neue AirOps-Ressourcenbuchungen gilt:

```text
AMMUNITION_30MM
  -> SUPERSEDED_AS_INTERCHANGEABLE_AIROPS_RESOURCE

AMMUNITION_50CAL
  -> SUPERSEDED_FOR_OH58_M3P_AIROPS_RESOURCE
```

Vorhandene Dokumente oder historische Test-Fixtures duerfen die alten Bezeichnungen weiterhin als historischen Stand enthalten. Eine spaetere Datenmigration muss alte Bestandswerte explizit zuordnen; eine automatische oder anteilige Aufteilung ist nicht genehmigt.

## 4. Grundlage der Trennung

Der akzeptierte read-only Test `STORAGE-WEAPON-ITEM-MATRIX-1` hat fuer den exakt dokumentierten DCS-/MOOSE-Stand gezeigt:

- M230- und GAU-8-Munition liegen in getrennten MOOSE/DCS-Itemfamilien;
- die untersuchten M230-, GAU-8- und .50-cal-`gunmounts`/`shells` liefern im getesteten Warehouse-Pfad nicht denselben gemeinsam nutzbaren Bestand;
- fuer den OH-58-M3P-Pfad sind zusaetzliche Container-/Store-Keys sichtbar;
- dieser Runtime-Befund rechtfertigt keine Zusammenfassung zu einem gemeinsamen strategischen Kaliberpool.

Der Lauf `AIRBORNE-AMMO-PARKING-CORRELATION-3` hat fuer die aktuellen Bagram-CAS-Templates ausserdem die konkreten operativen Store-Keys `weapons.missiles.AIM_120C` und `weapons.missiles.AIM_9` beobachtet. Dieser Befund belegt die getesteten Payload-Varianten, aber keine universelle Variantenkonvertierung und keine F-16-Deployment-AIM-9-Zuordnung.

Die technische Acceptance der Mapping-Tests bleibt auf deren exakten Source-/MIZ-/Bundle-/MOOSE-/DCS-Stand begrenzt. Die strategischen Resource IDs und die Deployment-Stock-Mengen sind separate Owner-Entscheidungen.

## 5. MOOSE-First und Mapping-Grenze

Die Trennung der strategischen IDs veraendert die MOOSE-first-Architektur nicht:

```text
CampaignState resource ID
  -> strategische Eigentums- und Reservierungslogik

MOOSE STORAGE / DCS warehouse item
  -> operative Warehouse-Repräsentation

AIRWING payload
  -> operative Missions-/Payload-Verfuegbarkeit
```

Ein spaeterer Adapter darf eine strategische Resource ID auf mehrere technisch passende DCS/MOOSE-Item-IDs abbilden, wenn dieser Mapping-Vertrag explizit dokumentiert und getestet ist. Umgekehrt darf ein DCS-Item nicht stillschweigend mehrere strategisch getrennte Ressourcen zusammenfassen.

## 6. Noch nicht entschieden beziehungsweise noch nicht technisch freigegeben

Die Resource-ID-Entscheidung selbst legt nicht automatisch fest:

```text
vollstaendige DCS/MOOSE item mapping lists je Resource ID
CampaignState-to-STORAGE mutation
AIRWING payload debit implementation
OPSTRANSPORT/CTLD resupply execution
persistence/restart/multiplayer reconciliation
```

Fuer die Bagram-Fighter-A/A-Ressourcen sind Initialbestand und Resupply-Policy dagegen jetzt separat in `docs/bagram-fighter-deployment-ammunition-stock-policy.md` verbindlich festgelegt.

## 7. Implementierungsfolge

Verbindliche Reihenfolge:

```text
owner-approved strategic Resource IDs
-> exact DCS/MOOSE item mapping per weapon family
-> allowed aircraft/loadout mapping
-> initial stock and resupply policy
-> CampaignState resource manifest
-> MOOSE STORAGE mirror adapter
-> AIRWING payload correlation
-> combined DCS acceptance
```

Keine generische Kaliber- oder Missile-Family-Austauschlogik darf in der Zwischenzeit implementiert werden.
