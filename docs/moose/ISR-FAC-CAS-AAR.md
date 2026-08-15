---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike, BDA and AAR integration
  - separation of sensing, decision, tasking, designation and effects
  - current MOOSE AAR runtime boundaries and integration rules
not_authoritative_for:
  - active ORBAT or mission-specific ROE
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR section without current runtime evidence
superseded_by:
source_branch: main
source_commit: 2e9cbe6104f2e23bc3031821459e1f16309a946b
validated_in_dcs: partial
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status

```text
PLANNED – vollständige ISR/FAC/CAS-Kette noch nicht akzeptiert
AAR production finalization – ACCEPTED_TECHNICAL_BASELINE für den exakt dokumentierten Acceptance-5-Stand
```

Der Dokumentstatus bleibt `PLANNED`, weil die übergreifende ISR-/FAC-/CAS-Architektur nicht vollständig akzeptiert ist. Der AAR-Unterbereich besitzt dagegen eine eigene, vollständig dokumentierte technische Acceptance.

Fachliche Grundlagen:

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](../45-air-c2-cas-afghanistan.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md)
- [`OMW-AAR-ISAF-ACO`](../29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md)

## 2. Architekturgrenzen

```text
Sensor / Beobachtung
-> Kontakt-/Intelligence-Modell
-> Zielentwicklung / Entscheidung
-> Spieler- oder KI-Auftrag
-> Markierung / Koordinatenübergabe
-> Wirkung
-> BDA
-> CampaignState-Folge
```

Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab. `CampaignState` bleibt strategische Ressourcenautorität; MOOSE materialisiert und betreibt physische Missionsrepräsentationen.

Für externe OMW-AAR-Pools gilt ausdrücklich:

```text
kein AIRWING-/WAREHOUSE-Bestand für MANAS/AL_UDEID
kein paralleles DCS-Warehouse-Inventar
CampaignState = count authority
SPAWN/FLIGHTGROUP/AUFTRAG = physical representation
```

## 3. Vorrangige MOOSE-Bausteine

- `INTEL`, `DETECTION`, Sets für Kontakte und Lagebild;
- `TARGET`, `PLAYERRECCE`, `DESIGNATE`, `PLAYERTASK`;
- `AUFTRAG`, `COMMANDER`, `AIRWING`, `SQUADRON`, `FLIGHTGROUP` für KI-Missionsausführung;
- für externes AAR insbesondere `AUFTRAG`, `FLIGHTGROUP`, `COORDINATE`, `SPAWN`, `SCHEDULER`, `UNIT`, `OPSGROUP`.

## 4. AAR – gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich verwendeten `Moose.lua` geprüft und für den dokumentierten Acceptance-5-Scope praktisch bestätigt:

- `AUFTRAG:NewTANKER(...)`;
- `AUFTRAG:SetMissionIngressCoord(...)`;
- `AUFTRAG:SetMissionEgressCoord(...)`;
- `AUFTRAG:Cancel()`;
- `SPAWN:InitCallSign(...)`;
- SPAWN-interne Template-STN-Kollisionsauflösung ohne erzwungenes `InitSTN(...)`;
- `UNIT:GetSTN()`;
- `GROUP:GetCallsign()`;
- `FLIGHTGROUP:GetFuelMin()`;
- `FLIGHTGROUP:SetFuelLowThreshold(...)`;
- `FLIGHTGROUP:SetFuelLowRTB(false)`;
- `FLIGHTGROUP`-FSM `FuelLow`, `Dead` / `onafterDead` und projektspezifischer `OnAfterDead`-Callback;
- `FLIGHTGROUP:AddWaypoint(Coordinate, Speed, AfterWaypointWithID, Altitude, Updateroute)`;
- `OPSGROUP:SwitchRadio(...)`, `TurnOffRadio()`, `SwitchTACAN(...)`, `TurnOffTACAN()`, `Despawn(...)`;
- `COORDINATE:Get2DDistance(...)`;
- `SCHEDULER:New(...)`;
- `UNIT:Explode(...)` ausschließlich als Testverlustinjektion.

`FLIGHTGROUP:AddWaypoint(...)` wird nach physischer Passage des FIR-Egress-Fixes verwendet, um den separaten External-Handoff-Punkt anzufügen. Acceptance-5 bestätigte diesen zweistufigen Egress-/Handoff-Pfad praktisch.

`OPSGROUP:SwitchCallsign(...)` bleibt im MOOSE verfügbar, ist aber nicht Teil des korrigierten AAR-Identity-Lifecycles. Ein physischer Tanker behält seine Callsign-Familie vom Spawn bis Despawn.

## 5. AAR-Netz: STANDARD und RESERVE

```text
STANDARD / bis auf weiteres kontinuierlich:
NELSON     FAST   MANAS      EGPAN   Texaco
PATTY      SLOW   MANAS      EGPAN   Texaco
MILHOUSE   SLOW   AL_UDEID   DAVER   Shell
KRUSTY     SLOW   AL_UDEID   DAVER   Arco

RESERVE / nur bei MissionDemand:
LISA       FAST   MANAS      PINAX   Texaco
MOE        FAST   MANAS      PINAX   Texaco
```

Die kontinuierliche STANDARD-Verfügbarkeit ist eine OMW-Betriebsentscheidung, kein historischer 24/7-Nachweis. Eine spätere ATO-/Zeitfensterlogik darf diese Verfügbarkeit oberhalb des Tanker-Lifecycles steuern.

## 6. MissionDemand

STANDARD:

```text
Demand
-> kompatiblen bereits laufenden Standard-Track nutzen

COMPLETE / CANCELLED / ABORTED
-> Demand endet
-> Standard-Track bleibt aktiv
```

RESERVE:

```text
erster Demand
-> Reserve-Track materialisieren

weitere Demands
-> denselben Track nutzen

letzter Demand endet
-> keine weitere Relief-Erzeugung
-> vorhandene Tanker Cancel/Egress
-> FIR Egress
-> External Handoff
-> Reserve wieder unbesetzt
```

Der COMMANDER darf diese OMW-Rollenentscheidung nicht durch implizite Near-Tanker-Auswahl ersetzen.

## 7. Sortie-Identity und Track-Identity

Jeder KC-135 ist eine eigene 1-Ship-Gruppe. Der Callsign ist `Family n-1` und bleibt während der gesamten Sortie stabil:

```text
Texaco n-1: NELSON/PATTY/LISA/MOE
Arco n-1:   KRUSTY
Shell n-1:  MILHOUSE
```

Relief verwendet dieselbe Familie mit anderer freier Gruppennummer. Link-16-STN wird von MOOSE verwaltet und über `UNIT:GetSTN()` ausgelesen.

Track-Identity:

```text
Radio + TACAN ON nur bei Stationsbesitz
Radio + TACAN OFF bei Transit/Relief-inbound/Egress
```

Acceptance-5 bestätigte unter anderem den MILHOUSE-Relief mit stabiler Shell-Familie und getrennten `n-1`-Sorties.

## 8. FIR- und External-Routing

Verbindliche Trennung:

```text
External Spawn
-> FIR Ingress Fix
-> AAR Track
-> FIR Egress Fix
-> External Handoff
-> Despawn
```

FIR Fix:

```text
NELSON/PATTY    -> EGPAN
KRUSTY/MILHOUSE -> DAVER
LISA/MOE        -> PINAX
```

MOOSE-first:

```text
SPAWN:SpawnFromCoordinate(externalSpawn)
AUFTRAG:SetMissionIngressCoord(firIngress)
AUFTRAG:SetMissionEgressCoord(firEgress)
AUFTRAG:Cancel()
FLIGHTGROUP:AddWaypoint(externalHandoff) after FIR-egress passage
OPSGROUP:Despawn(...) only at external handoff
```

Acceptance-5 bestätigte natürliche FIR-Passage über EGPAN, DAVER und PINAX sowie den anschließenden External Handoff. Vollständiges Lower-/Upper-Airway-Routing bleibt ausdrücklich späterer optionaler Scope.

## 9. Relief / FuelLow

### 9.1 Scheduled Relief

Akzeptierte Semantik:

```text
ACTIVE
-> 3 h station cycle from actual takeover
-> exactly one RELIEF
-> same callsign family, different n-1 group number
-> relief flies natural external spawn -> FIR ingress -> real track
-> ETA <= 5 min: handover ARMED only
-> outgoing remains ACTIVE and owns radio/TACAN
-> relief reaches real track / close handover geometry
-> relief becomes station owner
-> only then outgoing Cancel/Egress
-> outgoing FIR egress
-> external handoff/recredit/despawn
```

Der frühere Acceptance-5-Vorlauf auf Commit `877f0c15c0b46dc8d08f39f7cdcde36e065563b5` deckte einen Controllerfehler auf: Das 5-Minuten-Gate wurde fälschlich als Handover selbst behandelt. Dieser Lauf bleibt verworfene Regressionsevidenz.

Die Korrektur auf Acceptance-Commit `5e7dbec37f53155f39c63c25590cf6b4e35814ca` trennt `HANDOVER_ARMED` vom tatsächlichen Track-Handover. Im finalen Owner-Lauf wurde ausdrücklich protokolliert:

```text
SCHEDULED_RELIEF_ARMED_HOLD_PASS area=MILHOUSE outgoingStillActive=true reliefStillInbound=true
SINGLE_SCHEDULED_RELIEF_PASS area=MILHOUSE armedHold=true naturalTrackHandover=true
```

Damit ist die Scheduled-Relief-Semantik für den dokumentierten Acceptance-Stand praktisch bestätigt.

### 9.2 FuelLow

FuelLow bleibt bewusst asymmetrisch zum Scheduled Relief:

```text
ACTIVE FuelLow
-> existing relief reuse OR exactly one emergency relief
-> outgoing Egress immediately
-> no 5-minute wait
-> temporary coverage gap allowed
-> replacement becomes station owner after natural track arrival
```

Acceptance-5 bestätigte diesen NELSON-FuelLow-Pfad praktisch.

## 10. Loss und CampaignState

```text
FLIGHTGROUP Dead
-> OnAfterDead
-> Adapter OnLost
-> kein AIRCRAFT_KC135 recredit
-> AIRCRAFT_KC135_LOST +1 exactly once
-> replacement nur wenn Track weiterhin benötigt/offen
```

Strategische Pools:

```text
OFFMAP_MANAS    AIRCRAFT_KC135 = 16
OFFMAP_AL_UDEID AIRCRAFT_KC135 = 40
```

Bestätigter External-Handoff recreditiert genau eine KC-135. Restore-Reconciliation löst nur persistierte, nicht anderweitig aufgelöste Commitments exactly once auf.

Acceptance-5 injizierte PATTY absichtlich über die öffentliche MOOSE-Methode `UNIT:Explode()`. Beobachtet wurden `FLIGHTGROUP Dead/OnAfterDead`, kein Recredit, Loss-Audit +1 und eine natürliche Replacement-Sortie über EGPAN.

## 11. Operative Concurrency

Die AI-Support-Regel `2/2/4` gilt nicht für AAR.

```text
steady state STANDARD = 4 Tanker
Reserve = +1 je geöffnetem Reserve-Track
pro Track max. 1 ACTIVE + 1 RELIEF
MANAS und AL_UDEID parallel möglich
>=60 s Materialisierungsabstand innerhalb derselben Source Domain
```

## 12. Evidence / Acceptance

Final akzeptierter Owner-DCS-Lauf:

```text
Test: AAR-PRODUCTION-FINAL-ACCEPTANCE-5
Branch: agent/aar-runtime-finalization
Acceptance commit: 5e7dbec37f53155f39c63c25590cf6b4e35814ca
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: c9e3978a4bbb35ebbfe5ae362021b5f8870129d6c8b06b58147424dde71a94e3
Bundle SHA-256: f33b0a5a6212d9a1103dfa2e0ab677777142ca771a2f5007a3ab1c7fee594cbf
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Der Lauf bestätigte insbesondere:

- vier STANDARD- und zwei demand-gesteuerte RESERVE-Tracks;
- mindestens 60 s Same-source-Spacing;
- natürliche EGPAN-/DAVER-/PINAX-Transits;
- stabile Callsign-Familien und STN-Readback;
- Scheduled Relief mit Armed-Hold bis zur realen Relief-Ankunft;
- Radio/TACAN-Transfer erst bei tatsächlicher Übernahme;
- FuelLow Immediate Egress;
- External Handoff;
- Reserve-Shutdown;
- PATTY Loss/Replacement;
- CampaignState exact-once Accounting;
- `FINAL_STEADY_STATE_PASS` und `RESULT PASS`.

Der AAR-Unterbereich ist damit für diese exakte Provenienz `ACCEPTED_TECHNICAL_BASELINE`. Die vollständige ISR/FAC/CAS-Kette bleibt weiterhin `PLANNED`.
