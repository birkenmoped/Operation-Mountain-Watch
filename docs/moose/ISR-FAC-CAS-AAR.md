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
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status

```text
PLANNED – vollständige ISR/FAC/CAS-Kette noch nicht akzeptiert
AAR – ältere Kernmechanik für dokumentierte DCS-/MOOSE-Stände teilweise praktisch bestätigt
AAR production finalization – korrigierter Standard/Reserve-/FIR-Fix-Pfad source-reviewed, noch nicht DCS-validiert
```

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

Im tatsächlich verwendeten `Moose.lua` source-reviewed:

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
- `SCHEDULER:New(...)`.

`FLIGHTGROUP:AddWaypoint(...)` verwendet für Fluggruppen Speed in Knoten und optionale Höhe in Fuß. Der aktuelle AAR-Controller nutzt diese öffentliche Methode nach physischer Passage des FIR-Egress-Fixes, um den separaten External-Handoff-Punkt anzufügen. Dieser konkrete Pfad ist source-reviewed, aber noch nicht DCS-validiert.

`OPSGROUP:SwitchCallsign(...)` bleibt im MOOSE verfügbar, ist aber nicht mehr Teil des korrigierten AAR-Identity-Lifecycles. Ein physischer Tanker behält seine Callsign-Familie vom Spawn bis Despawn.

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

Die kontinuierliche STANDARD-Verfügbarkeit ist eine vorläufige OMW-Betriebsentscheidung, kein historischer 24/7-Nachweis. Eine spätere ATO-/Zeitfensterlogik darf diese Verfügbarkeit oberhalb des Tanker-Lifecycles steuern.

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

Vollständiges Lower-/Upper-Airway-Routing bleibt ausdrücklich späterer Scope.

## 9. Relief / FuelLow

Nominal:

```text
ACTIVE
-> 3 h station cycle from actual takeover
-> exactly one RELIEF
-> same callsign family, different n-1 group number
-> outgoing Cancel/Egress
-> relief takeover
-> outgoing FIR egress
-> external handoff/recredit/despawn
```

FuelLow:

```text
ACTIVE FuelLow
-> existing relief reuse OR exactly one emergency relief
-> outgoing Egress
-> no duplicate relief
-> required track coverage restored
```

Acceptance-4 beschleunigt nur **einen** Scheduled Relief. Es erzeugt keinen künstlichen simultanen Relief aller Tracks.

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

Acceptance-6 und Integration-3 bleiben nur für ihre exakt dokumentierten älteren Stände gültig. Acceptance-1/2/3 sind keine final akzeptierten Baselines; sie deckten mehrere Integrations- und Scopefehler auf.

Der nächste genehmigte kombinierte Test ist:

```text
AAR-PRODUCTION-FINAL-ACCEPTANCE-4
```

Er prüft insbesondere vier STANDARD-Tracks, zwei demand-getriebene FAST-RESERVE-Tracks, stabile Callsign-Familien, natürliche FIR-Fix-Passage, getrennten External-Handoff, einen Scheduled Relief, FuelLow, Loss und Restore.

Bis zum realen PASS bleibt dieser korrigierte Produktionspfad `SOURCE_REVIEWED` / `PLANNED`; `VERIFIED-METHODS.md` wird nicht vorgezogen.
