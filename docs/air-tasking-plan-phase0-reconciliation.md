---
document_id: OMW-AIR-TASKING-PLAN-PHASE0-RECONCILIATION
status: DRAFT
document_class: ARCHITECTURE_RECONCILIATION
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 0 reconciliation between the Air Tasking source model and production architecture
  - branch-local separation of MissionDemand, Air Support Request, Air Tasking Mission and MOOSE execution responsibilities
not_authoritative_for:
  - repository-wide architecture beyond documents already binding on main
  - MOOSE method signatures or runtime behavior
  - AAR runtime integration before the current AAR finalization is integrated to main
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 0 Reconciliation

## 1. Zweck

Dieses Dokument bearbeitet den ersten offenen Punkt aus `OMW-AIR-TASKING-PLAN-FOUNDATION-MANIFEST`:

```text
Dokument 54 gegen Dokument 88 prüfen
und Überschneidungen / Abgrenzungen dokumentieren.
```

Geprüfte Baselines:

- `OMW-GOV-001` – Projekt-Governance;
- `OMW-GOV-MOOSE-FIRST` – MOOSE-First;
- `OMW-ARCH-CAMPAIGN-STATE` – strategische Autorität und Persistenzgrenze;
- `OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` – `MissionDemand` als einheitliche Auftragsautorität;
- `OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS` – fachliches ATO-/ASR-/ACO-/SPINS-Datenmodell;
- `OMW-AIR-TASKING-PLAN-FOUNDATION` – produktive Air-Tasking-Architekturentscheidung.

Die Reconciliation ändert noch keinen Runtime-Code.

## 2. Ergebnis

Dokument 54 und Dokument 88 widersprechen sich im Grundsatz **nicht**. Sie besitzen aber unterschiedliche Rollen und müssen deshalb ausdrücklich getrennt bleiben.

```text
Dokument 54
= fachliches Referenz- und Produktmodell
= beschreibt, welche Informationen ein OMW Air Tasking Plan enthalten kann
= qualifiziert historische und synthetische Quellen

Dokument 88
= produktive Architekturgrenze
= beschreibt, wo Air Tasking im OMW-System liegt
= legt CampaignState- und MOOSE-Grenzen fest
= bestimmt die Implementierungsreihenfolge
```

Dokument 54 darf daher nicht als eigenständige Runtime- oder Ressourcenautorität interpretiert werden. Dokument 88 darf umgekehrt die fachlichen Detailfelder aus Dokument 54 nicht stillschweigend neu definieren.

## 3. Verbindliche Schichtung

Die für den Branch zu verwendende Zielschichtung lautet:

```text
CampaignState
    ↓
MissionDemand
    ↓
AIR_SUPPORT_REQUEST
    ↓
AIR_TASKING_MISSION / AIR_TASKING_PLAN
    ↓
OMW Tasking Adapter
    ↓
MOOSE COMMANDER / AIRWING / SQUADRON / AUFTRAG
    ↓
FLIGHTGROUP / DCS
```

Die Begriffe sind nicht austauschbar.

### 3.1 `CampaignState`

`CampaignState` bleibt die einzige strategische Wahrheit für:

- Ressourcen und Bestände;
- Reservierungen und strategische Verfügbarkeit;
- persistente strategische IDs und Zustände;
- strategische Verluste, Wiederherstellung und Ergebnis-Settlement.

Der aktuelle produktive `OMW_CampaignState.lua` besitzt bereits Ressourcen-, Transaktions-, Credit- und Aircraft-Recovery-Persistenz. Er führt derzeit **noch keinen generischen persistenten `MissionDemand`-Store**. Das vorhandene Feld `missionDemandId` in Resource Transactions ist lediglich eine Referenz und kein vollständiges MissionDemand-Domänenobjekt.

Folgerung für Phase 0/1:

```text
kein Air-Tasking-Modul darf aus dem heutigen missionDemandId-Feld
bereits eine vollständige MissionDemand-Implementierung ableiten.
```

### 3.2 `MissionDemand`

`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION` definiert `MissionDemand` als kampagnenweite Auftragsautorität mit mindestens:

```text
id
missionType
origin
objective
target
priority
playerCapable
aiCapable
reservationState
expiresAt
successCriteria
failureConsequences
resourceReservation
```

`MissionDemand` beantwortet damit primär:

```text
Was muss die Kampagne erreichen?
```

Es ist noch keine ATO-Mission und kein MOOSE-`AUFTRAG`.

### 3.3 `AIR_SUPPORT_REQUEST`

Das Objekt aus Dokument 54 beschreibt den fachlich normalisierten Unterstützungsbedarf, der aus einem `MissionDemand` hervorgehen kann.

Es beantwortet insbesondere:

```text
Wer benötigt welche Luftunterstützung,
mit welcher Priorität,
für welchen Effekt,
wo und wann?
```

Ein `AIR_SUPPORT_REQUEST` garantiert noch keine verfügbaren Assets und erzeugt keine Ressourcen.

### 3.4 `AIR_TASKING_MISSION`

Die Air-Tasking-Mission ist die konkrete operative Zuordnung, die einen oder mehrere Requests erfüllen soll.

Sie beantwortet:

```text
Welche konkrete Luftmission soll den Bedarf erfüllen?
```

Sie darf unter anderem referenzieren:

- Request-IDs;
- Task Unit / SQUADRON;
- Aircraft type/count als Planungsbedarf;
- Start-/Recovery-Knoten;
- Area/Target;
- Zeitfenster;
- Callsign;
- Control Agency;
- Support-Missionen;
- Player-/AI-Zuordnung.

Die Air-Tasking-Mission **besitzt** diese Ressourcen nicht. Strategische Verfügbarkeit und Reservierung müssen über CampaignState beziehungsweise die dafür autorisierten Resource-Adapter laufen.

### 3.5 MOOSE `AUFTRAG`

MOOSE `AUFTRAG` ist die technische Ausführungsrepräsentation einer Mission, soweit die geprüfte MOOSE-API die konkrete Missionsart unterstützt.

```text
AIR_TASKING_MISSION
!=
MOOSE AUFTRAG
```

Der spätere OMW Tasking Adapter übergibt nur die für die physische Ausführung erforderlichen Daten an MOOSE und beobachtet den MOOSE-Lifecycle. Request-Historie, strategische Ressourcenhoheit, persistente IDs und Player-Views bleiben OMW-Domänendaten.

## 4. Dokument-54-/Dokument-88-Crosswalk

| Thema | Dokument 54 | Dokument 88 | Phase-0-Regel |
|---|---|---|---|
| ATO-artiges Produkt | definiert `AIR_TASKING_PLAN` und Felder | ordnet es als operative Planungsschicht ein | Dokument 54 liefert Felder, Dokument 88 die Systemgrenze |
| Air Support Request | definiert Typen, Pflichtdaten und Lifecycle | verlangt Request-to-Mission-Verknüpfung | Request bleibt Bedarf, nicht Asset-Zuweisung |
| Mission Record | definiert fachliche Missionsfelder | definiert `AIR_TASKING_MISSION` als operative Zuordnung | Phase 1 harmonisiert Namen und Pflicht-/Optionalfelder |
| Ground Alert | definiert Alert-Daten und Trennung von Readiness/Transit | bestimmt Ground Alert als späteren Use Case | keine Runtime in Phase 0 |
| AAR | definiert Tanker-/Receiver-Daten | bestimmt AAR als ersten späteren Vertical Slice | aktuelle AAR-Finalisierung nicht verändern |
| Player Views | beschreibt Briefing-/Export-Möglichkeiten | legt Views als Ableitungen derselben Missionsdaten fest | Views besitzen keine eigene Mission-/Ressourcenwahrheit |
| USMTF/ADatP-3 | erlaubt begrenzte lesbare Exporte | schließt vollständigen ATO-Generator als Foundation-Ziel aus | kein generischer Parser / keine Rohmessage als Runtime-Autorität |
| Persistenz | fachlich nicht abschließend autorisiert | verlangt ausdrückliche Persistenzgrenze | Phase 0 legt die Persistenzklassen fest, Phase 1 implementiert noch nicht automatisch |
| MOOSE | keine technische Acceptance-Autorität | MOOSE ist Ausführungsschicht | konkrete APIs erst in Phase 2 nach pinned-source-Prüfung |

## 5. Bestehender AAR-Sonderfall

Der aktuelle `OMW_AAR_Controller.lua` akzeptiert bereits ein spezialisiertes Demand-Objekt mit Feldern wie:

```text
missionDemandId
receiverProfile
operationsArea
supportMode
priority
```

und verwendet dieses zur AAR-Area-Auswahl. Dieser bestehende Vertrag ist **kein Beweis für einen bereits implementierten generischen `MissionDemand`-Store** und darf nicht stillschweigend zum allgemeinen Air-Tasking-Datenmodell erklärt werden.

Für die Foundation gilt deshalb:

```text
current AAR demand descriptor
= existing specialized consumer contract

future canonical MissionDemand / AIR_SUPPORT_REQUEST
= separate domain contracts to be defined in Phase 1
```

Die aktuelle AAR-Finalisierung wird nicht geändert. Erst nach Integration ihrer finalen Baseline nach `main` wird in Phase 3 geprüft, wie der bestehende AAR-Demand-Vertrag durch einen kleinen Adapter angebunden werden kann, ohne Area-Auswahl, Track-Lifecycle oder Ressourcenlogik zu duplizieren.

## 6. Offene Phase-0-Verträge

Mit dieser Reconciliation ist nur der Überschneidungs-/Abgrenzungspunkt abgeschlossen. Noch festzulegen sind getrennt:

1. CampaignState-Vertrag für Request-/Mission-Reservierung und Ergebnisrückmeldung;
2. Persistenzklassen für Requests, Missionen, Bindings und Views;
3. stabile ID-Konventionen;
4. zulässige MissionDemand-Produzenten und -Konsumenten;
5. View-/Briefingdaten ohne Ressourcenautorität;
6. formales Gate-0-Ergebnis.

Diese Punkte werden nicht durch Annahmen aus Dokument 54 oder der aktuellen AAR-Runtime vorweggenommen.

## 7. Phase-0-Status nach diesem Schritt

```text
DONE:
- Document 54 vs Document 88 reconciliation
- authority crosswalk
- explicit MissionDemand / Request / Mission / AUFTRAG separation
- current AAR demand descriptor classified as specialized existing contract

OPEN:
- CampaignState request/mission settlement contract
- persistence boundary
- ID convention
- producer/consumer boundary
- view-data boundary
- Gate 0 assessment
```

Kein DCS-Test ist für diesen reinen Architektur-Reconciliation-Schritt erforderlich. `validated_in_dcs` bleibt `false`.