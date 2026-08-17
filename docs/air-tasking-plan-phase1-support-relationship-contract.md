---
document_id: OMW-AIR-TASKING-PLAN-PHASE1-SUPPORT-RELATIONSHIP
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 1 support-relationship model between Air Tasking Missions
  - bidirectional traceability rules without duplicate relationship authority
  - dependency direction, cycle prevention and lifecycle rules for support relationships
not_authoritative_for:
  - concrete MOOSE mission dependency methods or FSM behavior
  - final AAR receiver scheduling or tanker allocation runtime
  - concrete DCS runtime behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 1 Support Relationship Contract

## 1. Zweck

Dieses Dokument legt fest, wie Air-Tasking-Missionen fachlich miteinander verknuepft werden, ohne Support-Beziehungen doppelt zu speichern oder eine zweite Ressourcenhoheit zu erzeugen.

Der Kernfall ist beispielsweise:

```text
AAR mission
    supports
receiver mission
```

Weitere spaetere Beispiele koennen sein:

```text
ESCORT mission
    supports
AIRLIFT mission

ISR mission
    supports
CAS mission
```

Die Beziehung beschreibt fachliche Abhaengigkeit und Support. Sie reserviert kein Asset und erzeugt keine MOOSE-Mission.

## 2. Kanonische Autoritaet der Beziehung

Sobald eine Support-Beziehung eigenen Zustand, Timing, Prioritaet oder Ergebnis besitzt, existiert genau ein autoritatives `SUPPORT_RELATIONSHIP`-Objekt mit eigener stabiler `REL-`-ID.

```text
REL-000001
= canonical relationship record
```

Missionen duerfen nur dessen ID referenzieren.

Nicht zulaessig ist:

```text
provider mission stores full relationship copy
+
consumer mission stores second full relationship copy
```

Dadurch wuerden zwei konkurrierende Wahrheiten entstehen.

## 3. Richtungssemantik

Jede Beziehung besitzt eine eindeutige Richtung:

```text
provider_mission_id
    -> supports ->
consumer_mission_id
```

Beispiel:

```text
REL-000014
relationship_type = AAR_SUPPORT
provider_mission_id = ATM-000021
consumer_mission_id = ATM-000018
```

Dabei gilt:

```text
provider
= Mission, die eine Support-Capability bereitstellt

consumer
= Mission, die diese Support-Capability benoetigt oder nutzt
```

Die Richtung ist fachlich und darf nicht aus Startzeit, Callsign, Flugzeugtyp oder DCS-Gruppenname abgeleitet werden.

## 4. Kanonischer Datensatz

Konzeptionell:

```lua
local relationship = {
  relationship_id = "REL-000001",
  relationship_type = "AAR_SUPPORT",
  provider_mission_id = "ATM-000002",
  consumer_mission_id = "ATM-000001",
  status = "PLANNED",
  priority = nil,
  sequence = nil,
  required = true,
  time_constraints = {
    earliest = nil,
    latest = nil,
  },
  result = nil,
  closure_reason = nil,
  change_serial = 1,
}
```

Pflichtfelder:

```text
relationship_id
relationship_type
provider_mission_id
consumer_mission_id
status
required
change_serial
```

Optional:

```text
priority
sequence
time_constraints
result
closure_reason
```

## 5. Bidirektionale Nachvollziehbarkeit ohne doppelte Hoheit

Beide Missionsseiten muessen die Beziehung auffindbar machen koennen. Das geschieht ausschliesslich ueber stabile `REL-`-IDs.

Zielbild:

```text
ATM-000002
  support_relationship_ids = { REL-000001 }

REL-000001
  provider_mission_id = ATM-000002
  consumer_mission_id = ATM-000001

ATM-000001
  support_relationship_ids = { REL-000001 }
```

Die Missionslisten sind Index-/Referenzdaten. Die fachliche Wahrheit der Beziehung liegt ausschliesslich im `REL-`-Objekt.

Beim Laden oder Validieren muss aus jeder Missionsreferenz wieder eindeutig auf das kanonische Relationship-Objekt geschlossen werden koennen.

## 6. Relationship-Typen

Phase 1 definiert nur einen offenen fachlichen Katalog. Mindestens vorgesehen sind:

```text
AAR_SUPPORT
ESCORT_SUPPORT
ISR_SUPPORT
CSAR_SUPPORT
AIRLIFT_SUPPORT
OTHER_SUPPORT
```

Ein Relationship-Typ beschreibt die Support-Semantik, nicht automatisch den MOOSE-`AUFTRAG`-Typ.

Neue Typen duerfen spaeter hinzugefuegt werden, muessen aber vor operativer Verwendung ein Feld-/Validierungsprofil erhalten.

## 7. Statusmodell

Support-Beziehungen besitzen einen eigenen kleinen Lifecycle:

```text
PLANNED
ACTIVE
SATISFIED
FAILED
CANCELLED
```

Semantik:

`PLANNED`
: Beziehung ist fachlich vorgesehen, aber die Support-Ausfuehrung hat noch nicht begonnen.

`ACTIVE`
: Die Support-Beziehung ist waehrend physischer Ausfuehrung relevant.

`SATISFIED`
: Der benoetigte Support wurde fuer diese Beziehung fachlich erbracht.

`FAILED`
: Der benoetigte Support konnte fuer diese Beziehung nicht ausreichend erbracht werden.

`CANCELLED`
: Die Beziehung wurde vor erfolgreichem Abschluss autorisiert beendet.

Zulaessige Grundtransitionen:

```text
PLANNED -> ACTIVE | CANCELLED | FAILED
ACTIVE  -> SATISFIED | FAILED | CANCELLED
```

Terminal:

```text
SATISFIED
FAILED
CANCELLED
```

Relationship-Status ist nicht automatisch identisch mit Provider- oder Consumer-Missionsstatus.

## 8. `required`-Semantik

`required = true` bedeutet:

```text
consumer mission must not be treated as fully support-ready
unless this relationship can be satisfied according to later planning rules
```

`required = false` bedeutet:

```text
support is beneficial/optional but not a hard prerequisite
```

Diese Semantik ist reine Planungsinformation. Sie darf nicht selbst Ressourcen reservieren oder eine MOOSE-Mission erzeugen.

Die konkrete Frage, ob ein fehlgeschlagener required Support automatisch die Consumer-Mission stoppt, wird nicht pauschal in Phase 1 entschieden. Sie kann missions- und runtimeabhaengig sein und muss spaeter gegen MOOSE-/Missionslogik geprueft werden.

## 9. Keine implizite Ressourcenhoheit

Eine Support-Beziehung besitzt keine strategischen Ressourcen.

Insbesondere gilt:

```text
REL AAR_SUPPORT exists
!= tanker reserved

REL ESCORT_SUPPORT exists
!= fighter reserved

REL ISR_SUPPORT exists
!= ISR asset allocated
```

Reale Ressourcenbindungen laufen weiterhin ausschliesslich ueber CampaignState-Reservierungen beziehungsweise die vorhandenen Air-Ops-/Warehouse-Vertraege.

Das Relationship-Objekt darf hoechstens auf die Missions-IDs verweisen, deren eigene `resource_reservation_refs` wiederum auf CampaignState zeigen.

## 10. Keine implizite MOOSE-Ausfuehrung

Eine Relationship-Erstellung darf nicht automatisch:

```text
- AUFTRAG erzeugen
- AIRWING/SQUADRON Asset auswaehlen
- FLIGHTGROUP erzeugen
- DCS-Gruppe spawnen
- Missionen starten oder retasken
```

Welche Teile davon MOOSE spaeter bereits nativ fuer Mission Support/Dependencies abbildet, ist Gegenstand von Phase 2.

OMW baut keine parallele Support-Dispatcher-Engine.

## 11. Zyklusverbot

Der aktive Support-Dependency-Graph muss azyklisch bleiben.

Nicht zulaessig:

```text
ATM-A supports ATM-B
ATM-B supports ATM-A
```

Ebenso nicht:

```text
ATM-A -> ATM-B
ATM-B -> ATM-C
ATM-C -> ATM-A
```

Begruendung:

- Planung und Readiness waeren nicht eindeutig aufloesbar;
- Cancellation-/Failure-Propagation wuerde rekursiv beziehungsweise widerspruechlich;
- Resource-/Mission-Settlement duerfte nicht von einem zyklischen Graphen abhaengen.

Vor Commit einer neuen aktiven Relationship muss daher geprueft werden, ob dadurch im aktuell relevanten Supportgraph ein Zyklus entsteht.

## 12. Selbstreferenzen und Duplikate

Strikt unzulaessig:

```text
provider_mission_id == consumer_mission_id
```

Ebenfalls unzulaessig ist eine doppelte aktive Relationship mit identischer fachlicher Semantik, wenn sie denselben Provider, Consumer und Relationship-Typ repraesentiert.

Beispiel:

```text
REL-000010 AAR_SUPPORT ATM-1 -> ATM-2 ACTIVE
REL-000011 AAR_SUPPORT ATM-1 -> ATM-2 ACTIVE
```

ist ohne ausdruecklich unterschiedliche fachliche Rolle beziehungsweise Zeit-/Sequenzbedeutung unzulaessig.

Mehrere unterschiedliche Support-Beziehungen zwischen denselben Missionen koennen dagegen zulaessig sein, wenn ihre Semantik eindeutig verschieden ist.

## 13. Mehrere Provider und Consumer

Ein Consumer darf mehrere Provider-Beziehungen besitzen:

```text
CAS mission
  <- AAR_SUPPORT from tanker mission
  <- ESCORT_SUPPORT from escort mission
  <- ISR_SUPPORT from ISR mission
```

Ebenso darf ein Provider mehrere Consumer unterstuetzen, sofern seine konkrete Capacity/Availability dies spaeter zulaesst.

Beispiel:

```text
one tanker mission
  -> supports ATM-A
  -> supports ATM-B
```

Die Relationship-Struktur allein behauptet dabei keine ausreichende Tankerkapazitaet. Kapazitaets- und Scheduling-Pruefung bleibt Phase 3/6 beziehungsweise MOOSE-/AAR-spezifischer Logik vorbehalten.

## 14. Zeit und Reihenfolge

`time_constraints` und `sequence` duerfen fachliche Anforderungen beschreiben, zum Beispiel:

```text
AAR before target ingress
ISR support before CAS execution
escort active during vulnerable transit window
```

Phase 1 legt nur die Datenfaehigkeit fest.

Nicht festgelegt werden:

```text
- Scheduler-Implementierung
- konkrete Uhrzeitberechnung
- automatische Retasking-Entscheidung
- MOOSE-FSM-Eventmapping
```

## 15. Provider-Ausfall und Consumer-Folge

Ein Provider-Fehler aktualisiert zunaechst die Relationship:

```text
provider mission fails
    ↓
relationship evaluated
    ↓
REL may become FAILED
```

Danach muss die Consumer-Mission fachlich neu bewertet werden.

Nicht zulaessig ist die pauschale Regel:

```text
provider FAILED
-> consumer FAILED
```

Moegliche spaetere Reaktionen sind je nach Missionstyp:

```text
- replacement provider
- delay
- reroute
- continue without optional support
- abort consumer mission
```

Die konkrete Entscheidung gehoert in spaetere Planning-/Runtime-Regeln und darf nicht aus dem Relationship-Datensatz allein erfunden werden.

## 16. Consumer-Abbruch und Provider-Folge

Ebenso gilt nicht pauschal:

```text
consumer CANCELLED
-> provider CANCELLED
```

Ein Provider kann weitere Consumer haben oder eine eigenstaendige Mission erfuellen.

Stattdessen:

```text
consumer terminal state
    ↓
re-evaluate affected relationships
    ↓
relationship may close/cancel
    ↓
provider mission remains subject to its own mission/tasking authority
```

## 17. Persistenz

Persistiert wird das kanonische `REL-`-Objekt einschliesslich:

```text
relationship_id
relationship_type
provider_mission_id
consumer_mission_id
status
required
priority/sequence/time_constraints where used
result
closure_reason
change_serial
```

Nicht persistiert werden:

```text
MOOSE object references
DCS object references
callback handles
scheduler handles
runtime dependency objects
```

Die Missionsrecords persistieren nur die zugehoerigen `support_relationship_ids`.

## 18. Restore und Reconciliation

Nach Restore gilt:

```text
load mission records
load relationship records
validate references
validate direction
validate no self-reference
validate active graph acyclic
rebuild indexes
```

Ein fehlerhafter oder unaufloesbarer Relationship-Record darf nicht stillschweigend als gueltig weiterlaufen.

Fail-closed Verhalten:

```text
invalid relationship
-> relationship not activated
-> stable IDs logged
-> affected mission remains unresolved/not support-ready until explicit handling
```

## 19. Mindestvalidierung

Die spaetere Implementierung muss mindestens pruefen:

```text
- REL- prefix and unique relationship_id
- provider mission exists
- consumer mission exists
- provider != consumer
- relationship_type valid
- status transition valid
- required is boolean
- both missions reference the REL ID consistently
- no duplicate active equivalent relationship
- adding relationship does not create an active dependency cycle
- relationship contains no strategic resource quantity
- relationship contains no MOOSE/DCS object in persistent state
```

Fehlerlogging muss mindestens enthalten:

```text
relationship_id
provider_mission_id
consumer_mission_id
validation/error code
```

## 20. Konsequenz fuer AAR Vertical Slice

Fuer Phase 3 kann damit ein Receiver-/Tanker-Zusammenhang eindeutig modelliert werden:

```text
ATM-RECEIVER
    <- REL-AAR-SUPPORT -
ATM-TANKER
```

Die Beziehung beschreibt nur:

```text
who supports whom
what type of support
whether support is required
relationship lifecycle/result
```

Nicht die Beziehung entscheidet:

```text
which tanker aircraft exists
which SQUADRON provides it
how much fuel is available
which orbit is selected
when relief occurs
how MOOSE assigns the tanker
```

Diese Punkte bleiben in ihren bestehenden AAR-/CampaignState-/MOOSE-Vertraegen.

## 21. Phase-1-Ergebnis

Mit diesem Contract ist der Manifest-Punkt abgeschlossen:

```text
[x] Support-Beziehungen bidirektional nachvollziehbar machen, ohne zyklische Ressourcenhoheit zu erzeugen
```

Weiter offen bleiben:

```text
- Player-/AI-Assignment-Semantik
- konkreter Snapshot-/Serialisierungsvertrag
- vollstaendige Datenvalidierungs- und Logging-Regeln
```

Kein Runtime-Code wurde geaendert. Kein DCS-Test ist fuer diesen reinen Domain-Contract erforderlich. `validated_in_dcs` bleibt `false`.
