---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-STABLE-ID-CONVENTION
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 stable identifier convention for Air Tasking domain objects and relationships
  - separation of persistent internal identifiers from player-facing labels and callsigns
not_authoritative_for:
  - final player-visible mission numbering or callsign presentation
  - Lua ID generator implementation
  - MOOSE or DCS object naming
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 Stable ID Convention

## 1. Zweck

Dieses Dokument legt die technische Identitätsgrenze für die Air-Tasking-Foundation fest. Es beantwortet nur die Frage, wie Domain-Objekte und Beziehungen über Runtime-Neustarts, Reconciliation und spätere MOOSE-Materialisierung eindeutig korreliert werden.

Es entscheidet ausdrücklich **nicht**, wie Missionen später für Spieler nummeriert oder dargestellt werden. Beispiele wie `ASR-0042` oder `CAS-017` aus Dokument 88 bleiben bis zu einer gesonderten Player-Produktentscheidung Darstellungsbeispiele und keine automatisch verbindlichen internen IDs.

## 2. Grundregel

Jedes persistente Air-Tasking-Domänenobjekt erhält genau eine stabile interne ID.

```text
stable domain ID
!= display label
!= callsign
!= DCS group name
!= MOOSE object reference
!= Lua table address
```

Eine stabile ID:

- wird genau einmal erzeugt;
- bleibt über Statusänderungen unverändert;
- bleibt über Save/Restore unverändert;
- wird nach Abschluss nicht für ein anderes Objekt wiederverwendet;
- darf nicht aus einem DCS-Gruppennamen oder einer MOOSE-Runtime-ID abgeleitet werden;
- wird für Logs, Persistenz, Reconciliation und Beziehungen verwendet.

## 3. ID-Klassen

Phase 0 benötigt mindestens folgende getrennte ID-Klassen:

```text
MissionDemand ID
Air Support Request ID
Air Tasking Mission ID
Air Tasking Plan ID
Support Relationship ID
Execution Attempt / Runtime Correlation ID
CampaignState Reservation / Transaction ID
```

Bereits bestehende CampaignState-IDs wie `transactionId`, `reservationId`, `creditId`, `entityId` und `nodeId` behalten ihre vorhandene Semantik. Air Tasking führt dafür keine parallelen Ersatz-IDs ein.

## 4. Kanonische interne Präfixe

Für die Air-Tasking-Domäne wird folgende **technische** Präfixkonvention festgelegt:

```text
MD-   MissionDemand
ASR-  AIR_SUPPORT_REQUEST
ATM-  AIR_TASKING_MISSION
ATP-  AIR_TASKING_PLAN
REL-  Support / dependency relationship
EXE-  execution attempt / runtime correlation
```

Die Präfixe kennzeichnen ausschließlich die Objektklasse und sind keine taktische Bedeutung.

Ein `ATM-...` darf deshalb unabhängig davon eine CAS-, ISR-, AAR-, CSAR- oder andere Air-Tasking-Mission repräsentieren. Der Missionstyp gehört in `mission_type`, nicht in die Primär-ID.

Dadurch bleibt die Identität stabil, auch wenn sich Rolle, Tasking oder Darstellung ändern.

## 5. Serienanteil

Der produktive Generator muss pro ID-Klasse einen persistenten, monoton steigenden Serienwert verwenden.

Konzeptionelles Format:

```text
<prefix><serial>
```

Beispiele:

```text
MD-000001
ASR-000001
ATM-000001
ATP-000001
REL-000001
EXE-000001
```

Die gezeigte Breite ist eine technische Darstellungskonvention. Der Generator muss intern numerisch arbeiten und darf bei Überschreiten der Beispielbreite nicht umbrechen oder IDs wiederverwenden.

## 6. Warum keine zufälligen Runtime-IDs

Für die aktuelle OMW-Architektur ist ein persistenter serieller Namespace ausreichend und besser nachvollziehbar als DCS-/MOOSE-Runtime-Namen.

Er ermöglicht:

- deterministische Logs;
- verständliche Testfixtures;
- eindeutige Save/Restore-Korrelation;
- einfache Duplikatprüfung;
- nachvollziehbare Request-to-Mission-Historie.

Phase 1 muss den Generator so entwerfen, dass der zuletzt vergebene Serienwert Teil des persistenten Domain-Snapshots ist und nach Restore fortgesetzt wird.

## 7. Beziehungen referenzieren IDs, keine Objekte

Persistente Beziehungen werden ausschließlich über stabile IDs gespeichert.

Beispiele:

```text
MissionDemand.id
    -> ASR.mission_demand_id

ASR.request_id
    -> ATM.request_ids[]

ATM.mission_id
    -> REL.consumer_mission_id

REL.provider_mission_id
    -> ATM.mission_id

ATM.mission_id
    -> CampaignState reservation correlation
```

Persistente Daten dürfen nicht enthalten:

```text
AUFTRAG object
FLIGHTGROUP object
DCS Group / Unit userdata
Lua table reference
scheduler handle
callback closure
```

## 8. Support-Beziehungen

Support-Beziehungen erhalten eine eigene `REL-`-ID, wenn sie selbst Zustand oder Lifecycle besitzen müssen.

Beispiel:

```text
REL-000014
provider_mission_id = ATM-000021
consumer_mission_id = ATM-000018
relationship_type = AAR_SUPPORT
```

Eine bloße Liste wie `support_mission_ids` darf weiterhin als abgeleitete beziehungsweise einfache Referenz verwendet werden. Sobald jedoch Sequenz, Status, Timing, Priorität oder ein eigener Lifecycle der Beziehung benötigt wird, ist ein eigenes Relationship-Objekt erforderlich.

Damit wird vermieden, fachlichen Beziehungszustand in zwei Missionsobjekten redundant zu pflegen.

## 9. Execution Attempts

Eine einzelne Air-Tasking-Mission kann über ihre Lebensdauer mehr als eine physische Materialisierung benötigen, zum Beispiel nach Restart, zulässigem Retry oder Replacement.

Daher gilt:

```text
ATM mission identity
!= physical execution attempt
```

Jeder physische Ausführungsversuch erhält eine eigene `EXE-`-ID.

Beispiel:

```text
ATM-000042
  EXE-000061  first materialization
  EXE-000079  later restored/retried materialization
```

MOOSE-`AUFTRAG`-, `FLIGHTGROUP`- und DCS-Objekte werden nur an die jeweilige `EXE-`-ID gebunden. Die `ATM-`-ID bleibt unabhängig von diesen Runtime-Objekten stabil.

## 10. CampaignState-Korrelation

Air Tasking erzeugt keine zweite Ressourcen-ID-Hierarchie.

Für Ressourcenbindungen gilt:

```text
ATM / ASR / MissionDemand stable IDs
    -> correlation metadata
    -> existing CampaignState transactionId / reservationId
```

Die vorhandenen CampaignState-Transaktions- und Reservierungs-IDs bleiben autoritativ für den Ressourcenvertrag.

Phase 1 darf die CampaignState-Spezifikation um eindeutige Air-Tasking-Korrelationsfelder erweitern, falls erforderlich. Sie darf jedoch nicht `transactionId` oder `reservationId` durch Air-Tasking-IDs ersetzen.

## 11. Player-facing Identifiers

Interne IDs und spielersichtbare Kennungen werden getrennt.

```text
internal:
ATM-000042

possible later display:
CAS-017
HAWG 2
ATO Day 14 / Mission 17
```

Welche dieser Darstellungen verwendet wird, ist **keine Phase-0-Technikentscheidung** und bleibt für Phase 4 beziehungsweise eine ausdrückliche Projektinhaberentscheidung offen.

Dadurch kann die interne Architektur jetzt stabil definiert werden, ohne ein späteres Spieler-UX- oder historisches Darstellungsmodell vorwegzunehmen.

## 12. Unzulässige Primärschlüssel

Folgende Werte dürfen nicht als persistente Primär-ID eines Air-Tasking-Domänenobjekts verwendet werden:

```text
callsign
DCS group name
DCS unit name
MOOSE object name
parking ID
aircraft type
squadron name
mission type + timestamp without persistent sequence authority
array index
Lua table identity
```

Diese Werte dürfen Attribute oder Lookup-Hilfen sein, aber keine dauerhafte Identität ersetzen.

## 13. Generator- und Restore-Anforderungen für Phase 1

Der spätere ID-Generator muss mindestens:

- pro ID-Klasse monoton steigende Serienwerte verwalten;
- die Counter persistent exportieren und restorefähig machen;
- bereits vorhandene IDs beim Restore validieren;
- Duplikate fail-closed ablehnen;
- nach Restore mit einem Wert größer als jeder bereits persistierte Serienwert fortsetzen;
- keine Clock-, DCS- oder MOOSE-Abhängigkeit benötigen;
- keine ID wiederverwenden, auch wenn ein Objekt CANCELLED oder FAILED wurde.

Die genaue Lua-API wird erst in Phase 1 definiert.

## 14. Phase-0-Entscheidung

Damit gilt für die Air-Tasking-Foundation:

```text
internal domain identity
= persistent typed serial ID

player-visible mission identifier
= separate presentation field, decision deferred

runtime MOOSE/DCS identity
= transient binding through EXE-ID
```

Diese Trennung erfüllt die bereits verbindlichen Regeln zu stabilen Entity-IDs, Persistenz und temporären DCS-/MOOSE-Repräsentationen, ohne eine Spieler-Darstellungsentscheidung vorwegzunehmen.

## 15. Noch offene Phase-0-Punkte

Nach diesem Schritt bleiben offen:

```text
- MissionDemand producer/consumer boundary
- view/briefing-data authority boundary
- Gate 0 assessment
```

Kein DCS-Test ist für diese reine Domain-ID-Konvention erforderlich. `validated_in_dcs` bleibt `false`.
