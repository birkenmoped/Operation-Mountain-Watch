---
document_id: OMW-ARCH-RESOURCE-WAREHOUSE-OWNERSHIP
status: BINDING_PROJECT_DECISION
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - strategic resource ownership boundary
  - approved CampaignState fuel resource identifiers and canonical fuel unit
  - approved AirOps fuel supply-parent topology
  - approved regional-node fuel stock thresholds and FARP buffers
  - planned CampaignState-to-MOOSE/DCS warehouse synchronization contract
  - planned delivery accounting and idempotency rules
  - source-reviewed MOOSE STORAGE adapter boundary
  - consolidated Warehouse/AirOps lifecycle evaluation after materialization, return, client rearm, client refuel and physical-loss testing
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - combined FUEL_AVGAS_JP8 working resource label for AirOps fuel accounting
superseded_by:
source_branch: agent/storage-client-fuel-exchange
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Resource-/Warehouse-Ownership-Vertrag

## 1. Zweck und Entscheidungsgrenze

Dieses Dokument präzisiert die bestehende Logistik- und CampaignState-Architektur für Ressourcen, Warehouse-Repräsentation und Lieferbuchung. Die in Abschnitt 14 dokumentierten Eigentümerentscheidungen sind verbindliche OMW-Projektentscheidungen. Technische Runtime-Synchronisation, automatische Verbrauchsbuchung und DCS-Acceptance bleiben davon getrennt und sind noch nicht als vollständige Produktionsintegration validiert.

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

Für OMW ist `STORAGE` damit der geeignete MOOSE-Wrapper für den operativen DCS-Warehouse-Mirror. Der Wrapper selbst besitzt kein strategisches CampaignState-Ressourcen-FSM und keine eigenständige OMW-Ressourcenhoheit.

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

Der Mehrknoten-Fuel-Mirror-Test hat zusätzlich praktisch gezeigt, dass ein laufender DCS-Aircraft-Verbrauch denselben `STORAGE`-Bestand während eines synchronen `SetLiquid()`-Write/Readback-Fensters verändern kann. Daraus folgt für die Produktionsrichtung: kein permanentes oder hochfrequentes CampaignState-`SetLiquid()`/`SetItem()`-Überschreiben während aktiver Operationen. Ein späterer Adapter muss operative DCS-Buchungen respektieren, Abweichungen protokollieren und nach einem ausdrücklich definierten Reconciliation-Verfahren behandeln.

## 4. Einheitenvertrag

### 4.1 Fuel

Der MOOSE-`STORAGE`-Liquidpfad arbeitet in kg. Für den strategischen Fuel-Vertrag gilt verbindlich:

```text
CampaignState canonical fuel quantity: kg
operational STORAGE liquid quantity: kg
planning/reporting display: may use US gal, kg or both
```

**kg ist die kanonische CampaignState-Fuel-Einheit.** Planungs- und Berichtswerte dürfen zusätzlich in US gal geführt werden, verändern aber nicht die kanonische Eigentumsmenge.

Jede Gallonen-zu-kg-Konvertierung benötigt einen expliziten, ressourcenspezifischen Dichtewert und Provenienz. Keine versteckte globale Magic Number.

### 4.2 Stückgüter und Munition

Diskrete Waffen und Module werden strategisch grundsätzlich als Stückzahl geführt, soweit das jeweilige Ressourcenmanifest nichts anderes festlegt. Gewicht und Volumen gehören zusätzlich in das Cargo-Manifest und bestimmen Transportfähigkeit, nicht Eigentumsmenge.

## 5. Fuel-Ressourcen und die AVGAS-/JP-8-Grenze

Dokument 05 führt die frühere Arbeitsbezeichnung `FUEL_AVGAS_JP8`. Die aktuelle Aircraft- und MOOSE-Prüfung zeigt jedoch eine notwendige fachliche Trennung:

- MQ-1 benötigt AVGAS;
- die übrigen hier betrachteten OMW-AirOps-Muster verwenden den JP-8-/Jet-Fuel-Pfad;
- MOOSE `STORAGE` trennt `JETFUEL` und `GASOLINE` technisch.

Der Projektinhaber hat deshalb die getrennten strategischen AirOps-Fuel-Ressourcen verbindlich festgelegt:

```text
FUEL_JP8
FUEL_AVGAS
```

Status:

```text
APPROVED_RESOURCE_IDS
BINDING_PROJECT_DECISION
```

`FUEL_AVGAS_JP8` darf für neue AirOps-Ressourcenbuchungen nicht mehr als gemeinsamer strategischer Fuel-Pool verwendet werden. Eine spätere Migration vorhandener Daten muss beide Ressourcen explizit und ohne stille Umdeutung zuordnen.

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

Für den AirOps-Warehouse-Lifecycle ist daraus **kein universeller Shadow-Transaction-Manager** abzuleiten, der jede physische STORAGE-Teiländerung parallel nachbaut. Nach der konsolidierten MOOSE-First-Auswertung in Abschnitt 15 ist zuerst die vorhandene AIRWING-/WAREHOUSE-/FLIGHTGROUP-Lifecycle-Semantik zu verwenden; OMW ergänzt nur die strategisch notwendige CampaignState-Grenze und Reconciliation.

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

Die frühere Foundation-Frage, ob DCS/STORAGE Aircraft-Fuel physisch selbst abbucht beziehungsweise bei Ground-Crew-Änderungen zurückbucht, ist für den dokumentierten Testscope beantwortet:

- AI-Materialisierung erzeugt beobachtbare JETFUEL-Debits im operativen STORAGE;
- physischer Totalverlust erzeugt keinen JETFUEL-Recredit;
- der Bagram-F-16-Client-Ground-Crew-Test bestätigte wiederholte Fuel-Reduktion und Fuel-Erhöhung mit gegenläufigem STORAGE-JETFUEL-Delta im Verhältnis 1:1 kg;
- ein permanenter CampaignState-Mirror-Write kann mit nativem DCS-Fuel-Verbrauch konkurrieren.

Damit ist ein eigener Fuel-Verbrauchssimulator oder eigener Client-Refuel-Pfad nicht erforderlich und nach MOOSE-First nicht vorgesehen.

Weiter offen für die **produktive CampaignState-Integration**, nicht für einen erneuten Grundlagenbeweis, bleiben:

- strategische Freigabe/Verfügbarkeitsprüfung vor geplanter AI-Materialisierung;
- CampaignState-Übernahme des validierten Nettoergebnisses;
- AAR-spezifische Abgrenzung, falls später strategisch benötigt;
- Disconnect/Slot-Wechsel/Abbruch für Clients;
- Reconciliation bei unerklärtem Drift;
- Persistenz/Restart.

Die frühere Markierung `NO_AUTOMATIC_AIRCRAFT_FUEL_DEBIT_YET` bedeutet daher ab diesem Stand nicht mehr „DCS-Fuelbuchung ungeklärt“, sondern ausschließlich „produktive CampaignState-Buchungsintegration noch nicht implementiert/abgenommen“.

## 11. AIRWING-Payload und strategische Munition

`AIRWING:NewPayload()` kann die MOOSE-seitige Missionsfähigkeit begrenzen. Diese Payloadzahl ist nicht automatisch der CampaignState-Waffenbestand.

Geplanter Ablauf für eine spätere Integration:

```text
CampaignState strategic weapon stock
-> mission demand / availability decision
-> AIRWING mission eligibility and payload availability
-> physical mission execution through MOOSE/DCS
-> observed STORAGE / lifecycle result
-> validated CampaignState state transition
-> operational mirror reconciliation only where needed
```

Die Grundlagenfrage der nativen DCS/STORAGE-Rückgabe muss nicht für bereits dokumentierte Fälle erneut getestet werden. Maßgeblich bleiben die jeweiligen Acceptance-Grenzen für AH-64D-Stores, F-16-Droptanks, Client-Rearm, interne Guns und physische Totalverluste.

## 12. Persistenz

MOOSE `STORAGE` stellt dateibasierte Save-/Load-Funktionen bereit, deren Nutzung `io`/`lfs`-Desanitization in `MissionScripting.lua` voraussetzt. OMW ändert `MissionScripting.lua` nicht automatisch.

Deshalb gilt:

```text
STORAGE file persistence
!= CampaignState persistence authority
```

Eine spätere CampaignState-Persistenz verwendet ausschließlich den vorgesehenen Projekt-Persistenzpfad. STORAGE-Persistenz darf nur nach eigener Architekturentscheidung und Acceptance eingesetzt werden.

## 13. MOOSE-First-Implementierungsgrenze

Vor produktiver Warehouse-/CampaignState-Synchronisation gilt nun die folgende Reihenfolge:

1. bereits validierte DCS/STORAGE-Grundlagen nicht erneut testen;
2. vorhandene MOOSE-AIRWING-/WAREHOUSE-/FLIGHTGROUP-Lifecycle-Punkte verwenden;
3. STORAGE ausschließlich über öffentliche MOOSE-Wrapper lesen beziehungsweise für ausdrücklich notwendige Mirror-Operationen schreiben;
4. CampaignState nur um die strategische Verfügbarkeits-, Ergebnis- und Reconciliation-Grenze ergänzen;
5. keine parallelen Spawn-, Return-, Rearm-, Refuel- oder Fuel-Verbrauchssysteme entwickeln;
6. erst die verbleibende konkrete Lücke identifizieren, bevor eigener Adaptercode erweitert wird;
7. den fertigen produktiven Adapter anschließend in einem gebündelten Integrationslauf prüfen.

Keine eigene parallele Transport-, Warehouse-, Aircraft-Lifecycle-, Client-Rearm-, Client-Refuel- oder Persistenzimplementierung ist durch dieses Dokument genehmigt.

## 14. Verbindliche Owner-Entscheidungen

Der Projektinhaber hat am 10.08.2026 folgende Entscheidungen für den Resource-/Warehouse-Vertrag freigegeben:

| Entscheidung | Verbindlicher Wert | Status |
|---|---|---|
| Fuel-Ressourcen trennen | `FUEL_JP8`, `FUEL_AVGAS` | `APPROVED` |
| kanonische strategische Fuel-Einheit | kg | `APPROVED` |
| Salerno Supply Parent | Kandahar | `APPROVED_OMW_DESIGN_DECISION` |
| Tarinkot Supply Parent | Kandahar | `APPROVED_OMW_DESIGN_DECISION` |
| Shindand Fuel Parent | Kandahar | `APPROVED_OMW_DESIGN_DECISION` |
| Regional-Node DoS | Target 5 / Reorder 3 / Critical 1,5 Tage | `APPROVED` |
| unmittelbarer FARP-Puffer | Theater/Regional Hub 2 d; Regional Node 1,5 d | `APPROVED` |

Für die drei Supply-Parent-Entscheidungen gilt: Sie sind OMW-Designentscheidungen. Unterschiedliche historische Evidenzstärken ändern ihre Projektverbindlichkeit nicht und dürfen nicht als Behauptung einer historisch exakt belegten Aviation-Fuel-Route formuliert werden.

## 15. Konsolidierte Warehouse-/AirOps-Auswertung vom 12.08.2026

### 15.1 Bereits belegte Grundlagen – kein erneuter Grundlagen-Test

Für den jeweils exakt dokumentierten DCS-/MOOSE-/Branch-/Missions-Scope liegen bereits praktische Nachweise vor für:

```text
STORAGE limited-liquid read/write
CampaignState -> STORAGE fuel mirror under a quiet sync window
seven AirOps STORAGE nodes under a quiet sync window
AI materialization debit
AI normal return/recredit for documented store classes
physical total loss without aircraft/fuel/store recredit
F-16 client weapon rearm/exchange
F-16 client fuel exchange
F-16 external tank return
AH-64D M151 / AGM-114K lifecycle
AH-64D IAFS special behavior
AH-64D M230 expenditure observation
F-16 M61 expenditure observation
F-15E M61 expenditure observation
OH-58D M3P documented behavior
CH-47 M60D container debit/recredit without round conversion
Kandahar ME parking -> MOOSE TerminalID correlation 376/376
```

Diese Punkte dürfen in der weiteren Warehouse-Arbeit nicht erneut als ungelöste Grundlagenfragen behandelt werden. Neue Tests sind nur erforderlich, wenn ein anderer Scope, eine neue Implementierung oder eine konkrete offene Semantik geprüft werden muss.

### 15.2 Source-reviewed MOOSE-Lifecycle im gepinnten `Moose.lua`

Gegen den tatsächlich verwendeten MOOSE-Stand wurden folgende vorhandene Frameworkpfade bestätigt:

```text
AIRWING:onafterFlightOnMission(From, Event, To, FlightGroup, Mission)
WAREHOUSE:onafterAssetSpawned(...)
WAREHOUSE:onafterAssetDead(...)
WAREHOUSE:onafterArrived(...)
WAREHOUSE:onafterDelivered(...)
FLIGHTGROUP:onafterArrived(From, Event, To)
OPSGROUP:ReturnToLegion(Delay)
STORAGE:GetInventory(...)
STORAGE:GetLiquidAmount(Type)
EVENTS.WeaponRearm
EVENTS.Refueling
EVENTS.RefuelingStop
```

Für normale AI-AIRWING-Flüge ist im gepinnten Source insbesondere folgende Kette vorhanden:

```text
FLIGHTGROUP:onafterArrived
-> if AI and Airwing asset and not pickup/transport
-> ReturnToLegion(1)
-> OPSGROUP:ReturnToLegion
-> legion:AddAsset(group, 1)
```

Daraus folgt nach MOOSE-First:

- kein eigener normaler AI-Aircraft-Return-Mechanismus;
- kein eigener AIRWING-Materialisierungs-/Spawn-Controller, solange vorhandene AIRWING-/WAREHOUSE-Lifecycle-Punkte ausreichen;
- kein eigener Client-Rearm-Pfad;
- kein eigener Client-Refuel-Pfad;
- kein eigener Fuel-Verbrauchssimulator;
- kein eigener Weapon-Return-Simulator für bereits nativ belegte Storeklassen.

`EVENTS.Refueling` und `EVENTS.RefuelingStop` sind im Source vorhanden. Ihre Existenz beweist jedoch **nicht**, dass sie Ground-Crew-Refuel für den benötigten OMW-Scope zuverlässig markieren. Da der Ground-Crew-Fuel-Exchange bereits durch bounded STORAGE-/Aircraft-Beobachtung praktisch 1:1 belegt wurde, ist kein zusätzlicher DCS-Test nur zur Erzwingung dieser Events erforderlich.

### 15.3 Produktionsrichtung – kleinster MOOSE-First-Adapter

Die konsolidierte technische Richtung ist:

```text
CampaignState
= strategic authority, availability, reservation where strategically required,
  validated result and persistence

MOOSE AIRWING / WAREHOUSE / FLIGHTGROUP
= operational aircraft lifecycle

MOOSE STORAGE / DCS warehouse
= physical runtime fuel/item inventory and native debit/return behavior

OMW adapter
= minimal lifecycle-bound observation, mapping and reconciliation boundary
```

Der Adapter soll **nicht** jede physische Teiländerung in einem zweiten Shadow-Ledger nachbauen. Er soll an bereits vorhandenen MOOSE-Lifecycle-Grenzen beziehungsweise bei bestätigten Client-Änderungen den relevanten STORAGE-Zustand lesen, bekannte Resource-IDs zuordnen, ein strategisch zulässiges Nettoergebnis an CampaignState übergeben und unerklärte Abweichungen als Reconciliation-Fehler behandeln.

Ein unerklärter STORAGE-Drift darf CampaignState niemals stillschweigend überschreiben.

### 15.4 Nächste technische Arbeit vor einem neuen DCS-Lauf

Vor einer weiteren Testmission sind zuerst ohne DCS-Lauf abzuschließen:

```text
A. final Resource/Store mapping
   CampaignState Resource ID
   <-> STORAGE liquid/item
   <-> canonical unit
   <-> strategic classification
   <-> documented return/loss semantics

B. minimal CampaignState <-> STORAGE/AIRWING adapter
   use existing MOOSE lifecycle callbacks/events first
   no duplicate physical lifecycle implementation

C. reconciliation policy
   expected/recognized lifecycle result
   observed STORAGE state
   tolerated timing/rounding where applicable
   unexplained drift -> log/fault, never blind reverse overwrite
```

Erst danach ist ein einzelner gebündelter Integrationslauf vorgesehen. Dieser soll nicht die bereits bestätigten DCS-Grundlagen neu beweisen, sondern nur die produktive OMW-Korrelation prüfen, mindestens für:

```text
AI materialization
AI normal return
client weapon exchange
client fuel exchange
physical total loss
CampaignState result correlation
idempotency/duplicate protection
unexplained drift protection
```

### 15.5 Nicht Teil dieses Warehouse-Zyklus

CSAR ist kein Bestandteil dieses Warehouse-/Resource-Testzyklus und wird aus dieser TODO-/Acceptance-Kette ausdrücklich herausgehalten. Eine spätere personelle/CSAR-Integration besitzt einen eigenen fachlichen Scope.

Forced-Landing-/Recovery-Detection baut später auf dem abgeschlossenen Ressourcenvertrag auf. Die bereits beschlossenen Domain-Regeln für Recovery-Zeit, Resource-Recredit und Repair-Lock müssen nicht im Warehouse-Grundlagentest erneut entschieden werden.

## 16. Acceptance-Grenze

Dieses Dokument ist `BINDING_PROJECT_DECISION` und `validated_in_dcs: false` für die **vollständige produktive CampaignState-/STORAGE-Integration**.

Bereits praktisch beziehungsweise source-reviewed belegt sind die in Abschnitt 15 genannten Einzelpfade innerhalb ihrer jeweils dokumentierten Provenienz. Nicht validiert bleiben als zusammenhängende Produktionsintegration:

- finaler produktiver CampaignState-`STORAGE`-/AIRWING-Adapter;
- vollständige strategische Fuel-/Weapon-Nettoergebnisbuchung;
- DCS-Warehouse-Reconciliation bei Drift;
- idempotente produktive CampaignState-Korrelation über alle vorgesehenen AirOps-Fälle;
- Persistenz/Restart;
- Multiplayer-Fehlerfälle außerhalb der bereits getesteten Einzelpfade.

`VALIDATED` oder eine technische Baseline für die **Gesamtintegration** darf erst nach Implementierung und einem exakt dokumentierten gebündelten DCS-Acceptance-Lauf gesetzt werden.
