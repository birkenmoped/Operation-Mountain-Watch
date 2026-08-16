---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-CAMPAIGNSTATE-CONTRACT
status: DRAFT
document_class: ARCHITECTURE_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 CampaignState boundary for Air Support Requests and Air Tasking Missions
  - branch-local resource-reservation and result-settlement contract for later Air Tasking implementation
not_authoritative_for:
  - current production CampaignState Lua API beyond the verified existing interfaces
  - MOOSE API signatures or runtime behavior
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 CampaignState Contract

## 1. Zweck

Dieses Dokument legt für Phase 0 die Autoritäts- und Übergabegrenze zwischen `CampaignState`, `MissionDemand`, `AIR_SUPPORT_REQUEST`, `AIR_TASKING_MISSION` und späterer MOOSE-Ausführung fest.

Es ist noch keine Runtime-Implementierung. Es beschreibt, welche Ebene welchen Zustand besitzen darf und wie Reservierung sowie Ergebnisrückmeldung später angebunden werden müssen.

Geprüfte Grundlagen:

- `OMW-GOV-001`;
- `OMW-GOV-MOOSE-FIRST`;
- `OMW-ARCH-CAMPAIGN-STATE`;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`;
- `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`;
- `OMW-AIR-TASKING-PLAN-FOUNDATION`;
- aktueller `scripts/campaign/OMW_CampaignState.lua` auf diesem Branch.

## 2. Autoritätsregel

Verbindliche Zielgrenze:

```text
CampaignState
= strategische Wahrheit

MissionDemand
= kampagnenweiter Bedarf / Auftragsautorität

AIR_SUPPORT_REQUEST
= normalisierter Luftunterstützungsbedarf

AIR_TASKING_MISSION
= operative Missionsplanung / Zuordnung

MOOSE / DCS
= physische Ausführung und beobachtbare Runtime
```

Kein Air-Tasking-Objekt darf einen strategischen Bestand unabhängig von `CampaignState` führen oder erhöhen.

Insbesondere gilt:

```text
planned aircraft_count
!= aircraft inventory

assigned_squadron_id
!= owned aircraft pool

support_mission_ids
!= reserved support resources

MOOSE AUFTRAG state
!= CampaignState strategic result
```

## 3. Aktueller CampaignState-Iststand

Der aktuelle `OMW_CampaignState.lua` ist DCS-/MOOSE-unabhängig und verwaltet bereits:

```text
resource quantities
resource reservations
resource transactions
idempotent resource credits
aircraft recovery records
snapshot export / restore
```

Der bestehende Ressourcenvertrag stellt insbesondere bereit:

```text
Store:ReserveResource(spec)
Store:MarkLoading(transactionId)
Store:MarkInTransit(transactionId)
Store:MarkDelivered(transactionId)
Store:MarkLost(transactionId)
Store:Consume(transactionId)
Store:Cancel(transactionId)
Store:GetTransaction(transactionId)
Store:CreditResourceOnce(spec)
Store:ExportSnapshot()
CampaignState.Restore(snapshot)
```

`ReserveResource(spec)` kann bereits `missionDemandId` als Referenz im Transaktionsdatensatz tragen. Daraus folgt jedoch ausdrücklich nicht, dass ein generischer persistenter `MissionDemand`-, `AIR_SUPPORT_REQUEST`- oder `AIR_TASKING_MISSION`-Store bereits existiert.

## 4. Air Support Request und CampaignState

Ein `AIR_SUPPORT_REQUEST` besitzt keine Ressourcen.

Es darf:

- einen `MissionDemand` referenzieren;
- Priorität, geforderten Effekt, Area/Target und Zeitbedingungen beschreiben;
- auf zugewiesene Air-Tasking-Missionen verweisen;
- einen fachlichen Request-Status führen.

Es darf nicht:

- Aircraft-/Fuel-/Weapon-Bestände selbst verringern oder erhöhen;
- MOOSE-Warehouse-/AIRWING-Bestände als eigene Wahrheit übernehmen;
- durch bloße Erstellung bereits eine strategische Ressource verbrauchen.

Zielprinzip:

```text
request created
-> no resource mutation

request approved / mission planned
-> still no implicit resource mutation

resource allocation required
-> explicit CampaignState reservation transaction
```

## 5. Air Tasking Mission und Ressourcenreservierung

Eine `AIR_TASKING_MISSION` beschreibt geplante beziehungsweise zugewiesene Ressourcen nur durch Referenzen und Planungswerte.

Wenn eine Mission reale strategische Ressourcen bindet, muss dies durch einen expliziten CampaignState-Reservierungsvorgang erfolgen.

Zielbild:

```text
MissionDemand
    ↓
AIR_SUPPORT_REQUEST
    ↓
AIR_TASKING_MISSION planned
    ↓
CampaignState reservation(s)
    ↓
mission allocation confirmed
    ↓
MOOSE execution may be materialized
```

Die bestehende `ReserveResource(spec)`-Semantik ist dafür grundsätzlich nutzbar, soweit die konkrete Ressource durch den generischen CampaignState-Ressourcenvertrag abgebildet wird.

Phase 1 muss festlegen, wie Air-Tasking-Referenzen in einer Reservierung eindeutig korreliert werden. Mindestens müssen folgende Beziehungen nachvollziehbar bleiben:

```text
missionDemandId
request_id
mission_id
transactionId / reservationId
resourceId
originNodeId
quantity
status
```

Der aktuelle produktive `ReserveResource(spec)`-Vertrag besitzt noch keine eigenen `request_id`- oder `mission_id`-Felder. Eine spätere Erweiterung darf erst in Phase 1 als Datenmodell-/API-Änderung entworfen werden; Phase 0 erfindet keine noch nicht implementierte Methode.

## 6. Reservierungsgrundsätze

Für spätere Air-Tasking-Implementierung gelten:

1. **Keine implizite Reservierung durch Planung.** Ein Mission Record allein bindet keine Ressource.
2. **Keine doppelte Reservierung.** Mehrere Views oder MOOSE-Objekte dürfen dieselbe strategische Reservierung nicht duplizieren.
3. **Idempotente Korrelation.** Wiederholte Verarbeitung desselben fachlichen Vorgangs darf keine zweite Reservierung erzeugen.
4. **Explizite Freigabe.** Wird eine Mission vor Ressourcenverbrauch abgebrochen, muss eine noch stornierbare CampaignState-Reservierung explizit aufgehoben werden.
5. **Verbrauch erst über den zuständigen Ressourcenvertrag.** Der Zeitpunkt von Debit/Consume richtet sich nach dem vorhandenen CampaignState-/Warehouse-/missionsspezifischen Adaptervertrag, nicht nach dem Air-Tasking-Statusnamen allein.
6. **Keine Bestandsrückrechnung aus MOOSE.** MOOSE-Laufzeitstatus darf nicht als unabhängige Ressourcenzählung verwendet werden.

## 7. Missionsergebnis und Settlement

MOOSE-/DCS-Ereignisse sind zunächst Beobachtungen der physischen Ausführung. Sie werden nicht automatisch selbst zur strategischen Wahrheit.

Zielkette:

```text
MOOSE / DCS runtime event
    ↓
OMW tasking / mission adapter
    ↓
validated mission outcome
    ↓
CampaignState settlement
    ↓
MissionDemand / AIR_SUPPORT_REQUEST result
```

Das Settlement muss zwischen mindestens drei Dingen unterscheiden:

```text
mission execution status
resource settlement
campaign-effect settlement
```

Beispiel:

```text
MOOSE mission completed
!= automatically campaign success
```

Eine Mission kann physisch beendet sein, während die Erfolgskriterien des zugehörigen `MissionDemand` noch separat bewertet werden müssen.

Ebenso gilt:

```text
mission aborted before resource consumption
-> cancel eligible reservations

resource physically consumed or lost
-> settle through resource contract
-> do not recredit merely because mission status becomes FAILED/CANCELLED
```

## 8. Ergebnisautorität

Die späteren Objekte besitzen unterschiedliche Ergebnisfelder:

```text
AIR_TASKING_MISSION result
= operative Missionsausführung

AIR_SUPPORT_REQUEST result/status
= wurde der angeforderte Unterstützungsbedarf erfüllt?

MissionDemand result/status
= wurde der kampagnenweite Bedarf beziehungsweise Effekt erreicht?

CampaignState resource settlement
= welche strategischen Ressourcen wurden reserviert, verbraucht, verloren oder zurückgegeben?
```

Diese Ebenen dürfen miteinander korreliert, aber nicht gleichgesetzt werden.

## 9. MOOSE-First-Grenze

Dieses Contract-Dokument führt keine eigene Missionsausführungslogik ein.

MOOSE bleibt für die physische Air-Ops-Ausführung vorgesehen. Der spätere OMW-Adapter darf nur:

- geplante OMW-Missionsdaten in geprüfte MOOSE-Aufträge übersetzen;
- MOOSE-Lifecycle und relevante Events beobachten;
- stabile OMW-IDs an der Integrationsgrenze korrelieren;
- daraus fachliche Ergebnisvorschläge an die CampaignState-/MissionDemand-Ebene melden.

Konkrete MOOSE-Methoden, FSM-Callbacks und Events werden erst in Phase 2 gegen die gepinnte Dokumentation, `Moose.lua` und offizielle Beispiele verifiziert.

## 10. Phase-0-Entscheidung

Für die weitere Entwicklung gilt damit:

```text
CampaignState owns resources and strategic settlement.
MissionDemand owns the campaign need.
AIR_SUPPORT_REQUEST owns the normalized support request.
AIR_TASKING_MISSION owns operational planning references.
MOOSE owns physical mission execution.
```

Ein Air-Tasking-Plan darf Ressourcen **referenzieren und eine Reservierung anfordern**, aber niemals selbst Ressourcen besitzen.

## 11. Noch offene Folgepunkte

Dieser Vertrag schließt den Phase-0-Punkt `CampaignState-Vertrag für Air-Support-Requests, Missionsreservierungen und Ergebnisrückmeldung` ab.

Weiter offen bleiben:

```text
- persistence boundary
- stable ID convention
- MissionDemand producer/consumer boundary
- view/briefing-data authority boundary
- Gate 0 assessment
```

Die konkrete Lua-Datenstruktur und eventuelle CampaignState-API-Erweiterung gehören zu Phase 1.

Kein DCS-Test ist für diesen reinen Architekturvertrag erforderlich. `validated_in_dcs` bleibt `false`.
