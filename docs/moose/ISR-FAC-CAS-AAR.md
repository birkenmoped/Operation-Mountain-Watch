---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike, BDA and AAR integration
  - separation of sensing, decision, tasking, designation and effects
not_authoritative_for:
  - DCS runtime acceptance
  - active ORBAT or mission-specific ROE
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - PLANNED used only as prose status without governance metadata
superseded_by:
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# ISR-, FAC-, AFAC-, JTAC-, CAS- und AAR-Architektur

## 1. Status und Architekturgrenze

```text
PLANNED – noch nicht als vollständige Laufzeitkette in DCS akzeptiert
```

Sensor, Entscheidung, Tasking, Shooter, BDA und CampaignState bleiben getrennte Zustände. Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab. Die ausführliche ältere Matrix bleibt unter `docs/evidence/source-records/legacy-moose-isr-fac-cas-aar.md` erhalten.

Vorrangige MOOSE-Bausteine bleiben `INTEL`, `DETECTION`, `TARGET`, `PLAYERRECCE`, `DESIGNATE`, `PLAYERTASK`, `AUFTRAG`, `COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP`.

## 2. AAR – gepinnter MOOSE-Stand

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed im tatsächlich verwendeten `Moose.lua`:

- `AUFTRAG:NewTANKER(Coordinate, Altitude, Speed, Heading, Leg, RefuelSystem)`;
- `AUFTRAG:SetRadio(Frequency, Modulation)`;
- `AUFTRAG:SetTACAN(Channel, Morse, UnitName, Band)`;
- `AUFTRAG:SetMissionEgressCoord(...)`;
- `AIRWING:CheckTANKER()` und `AIRWING:GetTankerForFlight()`;
- `FLIGHTGROUP:GetFuelMin()`, `SetFuelLowThreshold()`, `SetFuelLowRTB()` und FuelLow callback;
- `FLIGHTGROUP:GetCoordinate()` / `COORDINATE:Get2DDistance()`;
- `OPSGROUP:Despawn(Delay, NoEventRemoveUnit)`.

Damit wird kein paralleler Orbit-, Funk-, TACAN- oder Fuel-Schwellencontroller gebaut.

## 3. Acceptance-2 Befund

Der Owner-Lauf vom 14.08.2026 mit DCS 2.9.28.26385 bestätigte für den getesteten Fünf-Tanker-Stressstand:

- plausible verzögerte 90/96-%-Seed-Fuelwerte;
- `AUFTRAG:TANKER -> EXECUTING` für alle fünf Tanker;
- den vorgesehenen 180-s-EXECUTING-Dwell vor beschleunigtem FuelLow;
- `FuelLow -> AUFTRAG:Cancel() -> Egress`;
- Gate-Eintritt <= 10 NM und `OPSGROUP:Despawn(1, true)` für alle fünf;
- visuell beobachtete Racetrack-Flüge.

Der Fünf-Tanker-Lauf bleibt eine Testausnahme und ändert `maxConcurrentSupportMissions = 2` nicht.

Aus der visuellen Beobachtung folgen zwei Produktivregeln:

```text
same gate/domain minimum materialization separation = 60 s
different gate domains may materialize simultaneously
```

Zusätzlich werden die Gate-Kandidaten weiter nach außen verlegt: SOUTH ungefähr 120 km nach Süden, NORTH_EAST ungefähr 75 km nach Südosten. Diese neuen Positionen sind bis Acceptance-3 nur Kandidaten.

## 4. AI-Boom-Receiver – MOOSE-first

Der Projektinhaber kann den Boom-Transfer nicht manuell fliegen. Acceptance-3 nutzt deshalb einen KI-Receiver, ohne ein neues Mission-Editor-Template anzulegen.

Bestehender Foundation-Pfad:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Für diesen Pfad wurden im gepinnten `Moose.lua` zusätzlich geprüft:

- `AUFTRAG:NewCAS(ZoneCAS, Altitude, Speed, Coordinate, Heading, Leg, TargetTypes)`;
- `AUFTRAG:AssignSquadrons({squadron})` – verlangt ausdrücklich eine Tabelle von `SQUADRON`-Objekten;
- `AUFTRAG:AddRequiredPayload(payload)`;
- `AUFTRAG:SetRequiredAssets(NassetsMin, NassetsMax)`;
- `AIRWING:AddMission(mission)` und der öffentliche `OnAfterFlightOnMission`-Callback;
- `FLIGHTGROUP:IsAirborne()`;
- `FLIGHTGROUP:Refuel(Coordinate)`;
- FSM-Übergänge `Refuel -> Going4Fuel` und `Refueled -> Cruising`;
- `FLIGHTGROUP:OnAfterRefueled(...)` als positiver Completion-Callback.

Der interne MOOSE-Refuel-Handler erzeugt selbst den DCS-Refueling-Task. Acceptance-3 ruft deshalb ausschließlich `FLIGHTGROUP:Refuel()` auf und implementiert weder `Controller:setTask` noch einen Native-DCS-Eventhandler.

Der CAS-Auftrag dient im Test nur dazu, das **vorhandene** Bagram-F-16C-Asset über seinen bereits registrierten AIRWING-/SQUADRON-/Payload-Pfad zu materialisieren. Er wird auf `WeaponHold` / `NoReaction` gesetzt; es wird kein künstliches Ziel erzeugt.

Nach dem positiven AI-Boom-Nachweis wird der bereits in Acceptance-2 source-reviewte FuelLow-/Cancel-/Egress-/Despawn-Pfad erneut benutzt, damit beide verlegten Gate-Kandidaten auch beim Rückweg geprüft werden.

## 5. Funk/TACAN Acceptance

Eine manuelle Prüfung aller fünf Tanker ist nicht erforderlich. Acceptance-3 verwendet exemplarisch:

```text
CLANCY / Shell 1: 241.600 AM, TACAN 60X / CLA
NELSON / Texaco 1: 384.400 AM, TACAN 47X / NEL
```

Damit wird je eine südliche und eine nördlich/östliche Runtime-Domäne geprüft. Ein positiver Test belegt den gemeinsamen MOOSE-Funk-/TACAN-Pfad für diese beiden Konfigurationen, nicht automatisch jede individuelle Frequenz/TACAN-Zuweisung der übrigen drei vorbereiteten Tanker.

## 6. Weiter offene Grenzen

Auch nach Acceptance-3 bleiben gesondert zu bearbeiten:

- produktiver MissionDemand-/CampaignState-Aktivierungsentscheid;
- produktive Umsetzung des 60-s-Same-Domain-Staggerings;
- AIRWING-/WAREHOUSE-Übernahme der geplanten Tanker-Initial-Fuelwerte statt isoliertem SPAWN-Testpfad;
- tatsächlicher Offload und die daraus folgende CampaignState-/off-map-Fuelbilanz;
- Persistenz und Missionsneustart;
- finale Gate-/Map-edge-Freigabe nach DCS-Beobachtung.

`VALIDATED` bleibt an einen exakt dokumentierten Owner-DCS-Lauf mit Branch, Commit, MIZ-/Bundle-/MOOSE-Hashes und beobachtetem Ergebnis gebunden.
