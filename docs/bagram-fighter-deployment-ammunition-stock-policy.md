---
document_id: OMW-LOG-BAGRAM-FIGHTER-AA-DEPLOYMENT-STOCK
status: BINDING_PROJECT_DECISION
document_class: RESOURCE_STOCK_POLICY
owning_policy: OMW-GOV-001
authoritative_for:
  - Bagram F-15E/F-16C initial AIM-120 and AIM-9 strategic resource quantities
  - deployment-derived fighter A/A stock policy
  - separation of fitted deployment inventory and warehouse inventory
  - prohibition of DoS/reserve-factor sizing for the covered fighter A/A stock
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Bagram fighter AIM-120/AIM-9 concurrency-plus-DoS stock sizing
  - Bagram fighter AIM-120/AIM-9 reserve-factor replenishment planning
superseded_by:
source_branch: agent/warehouse-resource-final-acceptance
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Bagram Fighter A/A Deployment Stock Policy

## 1. Owner-Entscheidung

Der Projektinhaber hat am 13.08.2026 die bereits in der AirOps-Logistikplanung gefuehrte Deployment-/Ferry-Regel fuer die Bagram-Fighter als verbindliche OMW-Ressourcenregel bestaetigt.

Fuer die hier abgedeckten AIM-120- und AIM-9-Bestaende gilt:

```text
INITIAL STOCK SOURCE = DEPLOYMENT INVENTORY ONLY
NORMAL CAMPAIGN RESUPPLY = NONE
DAYS OF SUPPLY MODEL = NOT APPLICABLE
DAILY CONSUMPTION STOCK SIZING = NOT APPLICABLE
RESERVE FACTOR STOCK SIZING = NOT APPLICABLE
```

Die Regel gilt nur fuer die in diesem Dokument genannten Bagram-Fighter-A/A-Ressourcen. Sie ist keine pauschale Aussage ueber Bomben, Luft-Boden-Lenkflugkoerper, Rockets, Gun Ammunition, Countermeasures oder technische Stores.

## 2. Strategische Resource IDs

Fuer diesen Vertrag werden folgende systemspezifischen strategischen Resource IDs verbindlich verwendet:

```text
AMMUNITION_AIM120
AMMUNITION_AIM9
```

CampaignState bleibt gemaess `OMW-GOV-001` und `OMW-ARCH-RESOURCE-WAREHOUSE-OWNERSHIP` die alleinige strategische Ressourcenhoheit. MOOSE `STORAGE`, DCS Warehouse und AIRWING-Payloads sind nur operative Reprasentationen beziehungsweise Lifecycle-Sichten.

## 3. Deployment-Bestand je Luftfahrzeug

Die verbindliche Deployment-Regel lautet:

| Aircraft | Store | Arrival quantity | Unload to Bagram warehouse | Remain fitted on arrival |
|---|---|---:|---:|---:|
| F-16C | AIM-120 | 2 | 0 | 2 |
| F-16C | AIM-9 | 2 | 2 | 0 |
| F-15E | AIM-120 | 6 | 4 | 2 |
| F-15E | AIM-9 | 2 | 0 | 2 |

Die Mengen beschreiben die OMW-Deployment-Baseline. Sie sind keine Behauptung ueber eine universelle historische Ferry-Konfiguration aller realen Staffeln.

## 4. Ableitung fuer die verbindliche Bagram-ORBAT

Die verbindliche Bagram-Fighter-ORBAT umfasst:

```text
13 F-15E
13 F-16C
```

Daraus folgt fuer den unmittelbar beim Deployment entladenen Anfangsbestand des Bagram-Warehouses:

```text
AMMUNITION_AIM120
  13 F-15E x 4 unloaded AIM-120
  = 52 initial warehouse missiles

AMMUNITION_AIM9
  13 F-16C x 2 unloaded AIM-9
  = 26 initial warehouse missiles
```

Verbindliche initiale Warehouse-Werte:

```text
BAGRAM / AMMUNITION_AIM120 = 52
BAGRAM / AMMUNITION_AIM9   = 26
```

Diese Werte sind nicht mit einem 14-Tage-DoS, einer Sortierate, einem erwarteten A/A-Verbrauch oder einem 20-Prozent-Reservefaktor zu multiplizieren.

## 5. Fitted Inventory und Double-Counting-Verbot

Beim Deployment am Luftfahrzeug verbleibende Raketen sind physische Aircraft Inventory und duerfen nicht gleichzeitig als verfuegbarer Warehouse-Bestand gebucht werden.

Fuer die 13 + 13 Fighter ergibt sich bei Ankunft zusaetzlich:

```text
F-16C fitted AIM-120: 13 x 2 = 26
F-15E fitted AIM-120: 13 x 2 = 26
F-15E fitted AIM-9:   13 x 2 = 26
```

Damit ist der gesamte mitgebrachte Theaterbestand der beiden Waffenfamilien:

```text
AMMUNITION_AIM120 total theater deployment inventory = 104
  warehouse on arrival = 52
  fitted on arrival    = 52

AMMUNITION_AIM9 total theater deployment inventory = 52
  warehouse on arrival = 26
  fitted on arrival    = 26
```

Die strategische Gesamtsumme darf durch Wechsel zwischen Aircraft und Warehouse nicht veraendert werden.

## 6. Spaetere Einsatz-Payloads

Die aktuell beschlossenen OMW-Einsatz-Payloads koennen von der Deployment-Konfiguration abweichen. Eine solche Payloadaenderung ist keine neue Ressourcenquelle.

Verbindliche Semantik:

```text
unused fitted missile -> warehouse
warehouse missile -> fitted aircraft
```

ist eine reine Bestandsverlagerung innerhalb des vorhandenen Theaterinventars.

Ohne eine separat dokumentierte Transaktion wird aus einer spaeteren Payloadentscheidung keine zusaetzliche Initialmenge abgeleitet. Insbesondere wird nicht stillschweigend angenommen, dass eine nach dem Deployment abgeruestete Rakete bereits zum initialen Warehouse-Bestand gehoerte.

## 7. Verbrauch, Verlust und Rueckgabe

Fuer die strategische Ressourcenlogik gilt:

```text
weapon fired / physically lost
-> finite theater inventory decreases

unused weapon returned from aircraft
-> same finite theater inventory changes location only

aircraft loss with fitted weapon
-> fitted weapon is lost with the aircraft unless a separate recovery transaction is confirmed
```

Eine DCS-/MOOSE-Runtime-Automatik fuer diese Buchungen ist durch dieses Dokument nicht freigegeben oder validiert.

## 8. Resupply-Grenze

Im normalen Kampagnenbetrieb existiert fuer die beiden hier geregelten Bagram-Fighter-A/A-Bestaende kein automatischer DoS-/Threshold-Nachschub.

Ein spaeterer Zuwachs ist nur durch ein separat autorisiertes Ereignis zulaessig, zum Beispiel:

```text
OFF_MAP_REPLACEMENT
NEW_DEPLOYMENT_PACKAGE
OWNER_APPROVED_STRATEGIC_RESUPPLY
```

Ein solches Ereignis benoetigt eine explizite CampaignState-Transaktion und darf nicht aus einem Reorder-Threshold oder einem STORAGE-Abgleich automatisch entstehen.

## 9. DCS-/MOOSE-Mapping-Grenze

Der aktuell dokumentierte Runtime-Korrelationsstand fuer die eingesetzten Fighter-Payloads bleibt versions- und payloadgebunden. Dieses Dokument legt strategische Ressourcenmengen fest; es erfindet keine noch nicht belegte DCS-/MOOSE-Item-Zuordnung.

Insbesondere gilt fuer einen im aktuellen F-16C-Einsatztemplate nicht vorhandenen AIM-9-Store:

```text
strategic stock policy = APPROVED
exact F-16 deployment-store DCS/MOOSE item correlation = NOT ESTABLISHED BY THIS DECISION
```

Vor einem schreibenden CampaignState-to-`STORAGE`-Mirror muss die exakte Item-Zuordnung gegen die tatsaechlich verwendete `Moose.lua` und den DCS-Runtime-Bestand belegt sein.

## 10. Acceptance-Grenze

Dieses Dokument ist eine `BINDING_PROJECT_DECISION`, aber keine DCS-Runtime-Acceptance.

Noch in DCS beziehungsweise im kombinierten Resource-Adapter zu pruefen sind insbesondere:

- Initialisierung der exakten Warehouse-Items auf die beschlossenen Mengen;
- Debit beim Ausruesten beziehungsweise Materialisieren;
- Rueckgabe ungenutzter Raketen;
- Verlust mit Aircraft;
- Multiplayer-/Restart-Reconciliation;
- Vermeidung von Double Counting zwischen CampaignState, AIRWING und STORAGE.

`VALIDATED` ist erst nach einem exakt dokumentierten Lauf mit Mission-, Bundle-, DCS- und MOOSE-Provenienz zulaessig.
