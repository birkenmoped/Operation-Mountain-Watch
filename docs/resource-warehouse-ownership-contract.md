---
document_id: OMW-ARCH-RESOURCE-WAREHOUSE-OWNERSHIP
status: PLANNED
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - planned strategic resource ownership boundary
  - planned CampaignState-to-MOOSE/DCS warehouse synchronization contract
  - planned delivery accounting and idempotency rules
  - source-reviewed MOOSE STORAGE adapter boundary
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/resource-warehouse-ownership-contract
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Resource-/Warehouse-Ownership-Vertrag

## 1. Zweck und Entscheidungsgrenze

Dieses Dokument präzisiert die bestehende Logistik- und CampaignState-Architektur für Ressourcen, Warehouse-Repräsentation und Lieferbuchung. Es ersetzt keine bereits bindende Governance und erhebt offene Datenentscheidungen nicht stillschweigend zu Projektentscheidungen.

Maßgebliche Grundlagen:

- [`OMW-GOV-001`](00-project-governance.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)
- [`OMW-LOGISTICS`](05-logistics.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-MOOSE-CLASS-INDEX`](moose/PROJECT-CLASS-INDEX.md)
- [`OMW-MOOSE-VERIFIED-METHODS`](moose/VERIFIED-METHODS.md)

Der bindende Bestand aus Dokument 05 bleibt maßgeblich: `CampaignState` führt Eigentum, Menge, Reservierung und Ergebnis; MOOSE/DCS-Komponenten führen die operative Darstellung aus.

## 2. Hoheitsmodell

Folgende Bestände sind getrennte Domänen und dürfen nicht als identisch behandelt werden:

```text
CampaignState resource stock
MOOSE WAREHOUSE / AIRWING asset stock
MOOSE AIRWING payload availability
MOOSE STORAGE / DCS warehouse liquids and items
MOOSE CTLD / OPSTRANSPORT cargo representation
DCS Dynamic Cargo / slingload representation
physical runtime groups and statics
```

### 2.1 CampaignState

`CampaignState` ist alleinige strategische Ressourcenhoheit. Nur dort werden strategisch verbindlich geführt:

- vorhandene Menge;
- reservierte Menge;
- verfügbare Menge;
- Herkunft und Ziel;
- Lieferung in Transit;
- Verlust;
- einmalige Zielgutschrift;
- persistenter Kampagnenstand.

Ein Adapter darf einen CampaignState-Bestand darstellen oder prüfen, aber nicht eigenständig strategische Ressourcen erzeugen.

### 2.2 MOOSE `WAREHOUSE` / `AIRWING`

MOOSE `WAREHOUSE` verwaltet im aktuellen OMW-Einsatz AIRWING-/SQUADRON-Assets und deren operativen Lifecycle. Dieser Bestand ist keine zweite strategische Kraftstoff- oder Munitionshoheit.

Insbesondere gilt:

```text
WAREHOUSE asset stock
!= CampaignState resource quantity
!= DCS warehouse liquid/item quantity
```

AIRWING-Payloadzahlen dienen der MOOSE-Missionsfähigkeit und Payloadauswahl. Sie dürfen nicht ohne eigenen Vertrag als strategischer Munitionsbestand interpretiert werden.

### 2.3 MOOSE `STORAGE`

Im gepinnten MOOSE-Stand `2.9.18`, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, ist `STORAGE` als Wrapper um das DCS-Warehouse vorhanden. Source-reviewed sind insbesondere:

```text
STORAGE:FindByName(AirbaseName)
AIRBASE:GetStorage()
STORAGE:AddItem(Name, Amount)
STORAGE:SetItem(Name, Amount)
STORAGE:GetItemAmount(Name)
STORAGE:RemoveItem(Name, Amount)
STORAGE:AddLiquid(Type, Amount)
STORAGE:SetLiquid(Type, Amount)
STORAGE:GetLiquidAmount(Type)
STORAGE:RemoveLiquid(Type, Amount)
STORAGE:GetInventory()
```

Die Liquid-Typen des geprüften Quellstands umfassen:

```text
STORAGE.Liquid.JETFUEL  = 0
STORAGE.Liquid.GASOLINE = 1
STORAGE.Liquid.MW50     = 2
STORAGE.Liquid.DIESEL   = 3
```

Liquid-Mengen werden in diesem MOOSE-/DCS-Pfad in **kg** geführt.

Für OMW ist `STORAGE` deshalb ein geeigneter Kandidat für einen späteren operativen DCS-Warehouse-Adapter. Der Source-Review beweist noch keine produktive Synchronisation, keine Multiplayer-Korrektheit und keine DCS-Acceptance.

## 3. Synchronisationsrichtung

Die geplante Synchronisationsrichtung ist grundsätzlich:

```text
CampaignState
    |
    +--> MOOSE STORAGE / DCS warehouse mirror
    +--> MOOSE AIRWING payload capability/availability where required
    +--> CTLD / OPSTRANSPORT / physical cargo representation
```

Rücklesungen aus DCS/MOOSE sind Telemetrie und Reconciliation-Signale. Sie dürfen nicht automatisch die strategische Wahrheit überschreiben.

Unzulässig wäre beispielsweise:

```text
DCS warehouse changed
-> overwrite CampaignState without a recognized campaign transaction
```

Ein späterer Adapter muss Abweichungen protokollieren und nach einem ausdrücklich definierten Reconciliation-Verfahren behandeln.

## 4. Einheitenvertrag

### 4.1 Fuel

Der MOOSE-`STORAGE`-Liquidpfad arbeitet in kg. Für den strategischen Fuel-Vertrag ist deshalb folgende Zielrichtung vorgesehen:

```text
CampaignState canonical fuel quantity: kg
operational STORAGE liquid quantity: kg
planning/reporting display: may use US gal, kg or both
```

Die Festlegung von **kg als kanonische CampaignState-Fuel-Einheit ist noch `TBD_OWNER_DECISION`**. Bis zur ausdrücklichen Freigabe bleibt sie eine Architekturvorlage und darf nicht als bindende Datenmigration umgesetzt werden.

Jede Gallonen-zu-kg-Konvertierung benötigt einen expliziten, ressourcenspezifischen Dichtewert und Provenienz. Keine versteckte globale Magic Number.

### 4.2 Stückgüter und Munition

Diskrete Waffen und Module werden strategisch grundsätzlich als Stückzahl geführt, soweit das jeweilige Ressourcenmanifest nichts anderes festlegt. Gewicht und Volumen gehören zusätzlich in das Cargo-Manifest und bestimmen Transportfähigkeit, nicht Eigentumsmenge.

## 5. Fuel-Ressourcen und die AVGAS-/JP-8-Grenze

Dokument 05 führt derzeit die historische Arbeitsbezeichnung `FUEL_AVGAS_JP8`. Die aktuelle Aircraft- und MOOSE-Prüfung zeigt jedoch eine notwendige fachliche Trennung:

- MQ-1 benötigt AVGAS;
- die übrigen hier betrachteten OMW-AirOps-Muster verwenden den JP-8-/Jet-Fuel-Pfad;
- MOOSE `STORAGE` trennt `JETFUEL` und `GASOLINE` technisch.

Daraus folgt als **noch nicht genehmigte Datenentscheidung** die vorgeschlagene Aufteilung:

```text
FUEL_JP8
FUEL_AVGAS
```

Status:

```text
PROPOSED_RESOURCE_IDS
TBD_OWNER_DECISION
```

Bis zur Entscheidung darf kein produktiver Code `FUEL_AVGAS_JP8` stillschweigend in einen der beiden neuen Typen umdeuten.

## 6. Munitionsressourcen

Die bindende Logistikarchitektur nennt derzeit mindestens:

```text
AMMUNITION_ROCKETS_70MM
AMMUNITION_HELLFIRE
AMMUNITION_30MM
AMMUNITION_50CAL
FLARES_CHAFF
MAINTENANCE_PARTS_LIGHT
MAINTENANCE_PARTS_HEAVY
AIRCRAFT_ENGINE_MODULE
```

Diese Liste bleibt eine Ressourcenbaseline, aber noch kein vollständiges AirOps-Waffenmanifest. Für produktive AIRWING-/STORAGE-Synchronisation ist pro Ressource zusätzlich erforderlich:

```text
resourceId
canonicalUnit
DCS/MOOSE item mapping
allowed aircraft/loadouts
initial stock policy
consumption event
return/cancel semantics
resupply source
```

Die bereits verbindliche AH-64D-CAS-Payloadkonfiguration definiert eine Mission-Editor-/Payload-Baseline, aber nicht automatisch einen strategischen Verbrauchswert je Mission.

## 7. Transaktions- und Reservierungsmodell

Jede strategische Ressourcenbewegung benötigt eine stabile Transaktion. Zusätzlich zum bestehenden `cargoId` und `reservationId` wird für die Implementierung ein stabiler Transaktionsschlüssel benötigt.

Vorgesehener Datensatz:

```text
resourceTransactionId
cargoId
reservationId
resourceType
quantity
canonicalUnit
origin
 destination
status
createdAt
missionDemandId
carrierEntityId
creditedAtDestination
```

`resourceTransactionId` ist ein Implementierungsdetail des geplanten Vertrags und noch kein freigegebenes persistentes Schemafeld. Die funktionale Anforderung der Idempotenz ist dagegen bereits durch die bindende Einmal-Gutschrift aus Dokument 05 vorgegeben.

## 8. Buchungssemantik einer Lieferung

### 8.1 Reservierung am Ursprung

Bei genehmigter Lieferanforderung wird die Menge am Ursprung reserviert. Reservierte Menge steht keiner zweiten Lieferung zur Verfügung.

```text
AVAILABLE
-> RESERVED
```

### 8.2 Übergang in Transport

Loading, Sling, Internal Cargo oder physische Übergabe an einen Carrier ändern die Eigentumskette, erzeugen aber keine neue Ressource.

```text
RESERVED
-> LOADING
-> IN_TRANSIT
```

Die genaue operative Darstellung wird nach MOOSE-First über CTLD, `OPSTRANSPORT` oder andere genehmigte vorhandene Frameworkpfade gewählt.

### 8.3 Zielgutschrift

Eine strategische Gutschrift erfolgt erst, wenn die Campaign-Domain die Lieferung als erfolgreich bestätigt. Dokument 05 verlangt dafür insbesondere gültige Übergabebedingungen, stabile Endposition und genau einmalige Gutschrift.

```text
IN_TRANSIT
-> delivery conditions satisfied
-> CampaignState commit
-> DELIVERED
-> adapter synchronization
```

Ein MOOSE-Event wie `WAREHOUSE.Delivered`, ein CTLD-Unload oder ein DCS-Cargo-Event ist damit ein **operatives Signal**, aber nicht automatisch die strategische Commit-Grenze. Der spätere Adapter muss das Event gegen Cargo-ID, Ziel, Transferzone und erwartete Transaktion korrelieren.

### 8.4 Verlust

```text
IN_TRANSIT
-> LOST / DESTROYED
-> no destination credit
```

Eine verlorene Fracht darf nicht durch erneutes Spawn oder erneutes Adapter-Sync dupliziert werden.

## 9. Idempotenz

Mindestens folgende Invarianten gelten:

1. eine `cargoId` wird einem Zielbestand höchstens einmal gutgeschrieben;
2. Wiederholung desselben Runtime-Events erzeugt keine zweite Gutschrift;
3. ein bereits abgeschlossener `resourceTransactionId` darf nicht erneut committen;
4. Adapter-Reconnect oder Mission-Restart erzeugt keine Ressourcen;
5. Umschlag zwischen Carriern verändert die Ressourcensumme nicht;
6. Verlust beendet die betroffene Menge ohne Zielgutschrift.

## 10. Fuel-Verbrauch durch Aircraft

Die aktuelle Verbrauchsrecherche liefert Planungswerte und Szenarien, aber noch keinen produktiven Runtime-Verbrauchsvertrag. Vor einer automatischen Fuel-Abbuchung ist gesondert zu entscheiden:

- Buchung bei Start, Engine Start, Takeoff oder tatsächlicher Betankung;
- Umgang mit Recovery Fuel;
- AAR-Trennung bei F-15E/F-16C/HH-60G;
- Player- versus AI-Aircraft;
- Disconnect, Slot-Wechsel und Abbruch;
- DCS-Warehouse-Telemetrie versus CampaignState-Sollbestand.

Daher gilt für diese Foundation:

```text
NO_AUTOMATIC_AIRCRAFT_FUEL_DEBIT_YET
```

## 11. AIRWING-Payload und strategische Munition

`AIRWING:NewPayload()` kann die MOOSE-seitige Missionsfähigkeit begrenzen. Diese Payloadzahl ist nicht automatisch der CampaignState-Waffenbestand.

Geplanter Ablauf für eine spätere Integration:

```text
CampaignState strategic weapon stock
-> mission demand / reservation
-> AIRWING mission eligibility and payload availability
-> physical mission execution
-> confirmed expenditure / return semantics
-> CampaignState transaction
-> operational mirror reconciliation
```

Vor dieser Integration müssen DCS-/MOOSE-Weapon-IDs und Rückgabe-/Verbrauchsereignisse musterweise geprüft werden.

## 12. Persistenz

MOOSE `STORAGE` stellt dateibasierte Save-/Load-Funktionen bereit, deren Nutzung `io`/`lfs`-Desanitization in `MissionScripting.lua` voraussetzt. OMW ändert `MissionScripting.lua` nicht automatisch.

Deshalb gilt:

```text
STORAGE file persistence
!= CampaignState persistence authority
```

Eine spätere CampaignState-Persistenz verwendet ausschließlich den vorgesehenen Projekt-Persistenzpfad. STORAGE-Persistenz darf nur nach eigener Architekturentscheidung und Acceptance eingesetzt werden.

## 13. MOOSE-First-Implementierungsgrenze

Vor produktiver Transport- oder Warehouse-Synchronisation sind mindestens zu prüfen:

1. konkrete `STORAGE`-Methoden gegen die tatsächlich verwendete `Moose.lua`;
2. DCS-Warehouse-Verhalten für Fuel und verwendete Waffen;
3. CTLD- und/oder `OPSTRANSPORT`-Pfad je Transportart;
4. Event/FSM-Semantik für Loading, Unloading, Delivered und Verlust;
5. Multiplayer- und Restart-Verhalten;
6. idempotente CampaignState-Commit-Grenze;
7. DCS-Test mit dokumentierter Mission, Bundle, DCS- und MOOSE-Provenienz.

Keine eigene parallele Transport-, Warehouse- oder Persistenzimplementierung ist durch dieses Dokument genehmigt.

## 14. Offene Owner-Entscheidungen

Vor einem bindenden Daten-/Runtime-Vertrag sind mindestens zu entscheiden:

| Entscheidung | Aktueller Vorschlag | Status |
|---|---|---|
| Fuel-Ressourcen trennen | `FUEL_JP8`, `FUEL_AVGAS` | `TBD_OWNER_DECISION` |
| kanonische strategische Fuel-Einheit | kg | `TBD_OWNER_DECISION` |
| Salerno Supply Parent | Bagram / Jalalabad / anderer genehmigter Parent | `TBD_OWNER_DECISION` |
| Tarinkot Supply Parent | Kandahar als starker Kandidat | `TBD_OWNER_DECISION` |
| Shindand Fuel Parent | Kandahar nur Kandidat; Munitionsroute belegt | `TBD_OWNER_DECISION` |
| Regional-Node DoS | Target 5 / Reorder 3 / Critical 1,5 Tage | `TBD_OWNER_DECISION` |
| unmittelbarer FARP-Puffer | Theater/Regional Hub 2 d; Regional Node 1,5 d | `TBD_OWNER_DECISION` |

## 15. Acceptance-Grenze

Dieses Dokument ist `PLANNED` und `validated_in_dcs: false`.

Source-reviewed ist die Existenz und Methodensemantik von MOOSE `STORAGE` im gepinnten Quellstand. Nicht validiert sind:

- produktive CampaignState-`STORAGE`-Synchronisation;
- strategische Fuel-/Weapon-Abbuchung;
- DCS-Warehouse-Reconciliation;
- Transport-Delivery-Commit;
- Persistenz;
- Multiplayer-Fehlerfälle.

`VALIDATED` oder eine technische Baseline darf erst nach einem exakt dokumentierten DCS-Test gesetzt werden.
