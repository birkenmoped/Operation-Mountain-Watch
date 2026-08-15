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
AAR – Kernmechanik für den dokumentierten DCS-/MOOSE-Stand praktisch bestätigt
AAR relief / identity / CampaignState coupling – implementiert, aber noch nicht DCS-validiert
```

Fachliche Grundlagen:

- [`OMW-C2-AIR-C2-CAS-AFGHANISTAN`](../45-air-c2-cas-afghanistan.md)
- [`OMW-TARGETING-AFGHANISTAN-NSL`](../48-afghanistan-no-strike-list.md)
- [`OMW-AAR-ISAF-ACO`](../29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md)

## 2. Funktionsschichten

```text
Sensor und Beobachtung
-> Kontakt-/Intelligence-Modell
-> Zielentwicklung und Entscheidung
-> Spieler- oder KI-Auftrag
-> Markierung / Koordinatenübergabe
-> Wirkung
-> Battle Damage Assessment
-> CampaignState-Folge
```

Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab.

## 3. Vorrangige MOOSE-Bausteine

- `INTEL`, `DETECTION` und Sets für Kontakte und Lagebild;
- `TARGET` für standardisierte Zielobjekte;
- `PLAYERRECCE` für Spieleraufklärung;
- `DESIGNATE` für Laser, Rauch, IR und Koordinatenübergabe;
- `PLAYERTASK` für Spieleraufträge;
- `AUFTRAG` für KI-Missionen;
- `COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP` für Assetauswahl und Ausführung;
- für AAR insbesondere `AUFTRAG:NewTANKER`, `FLIGHTGROUP`, `COORDINATE`, `SPAWN`, `SCHEDULER` und `OPSGROUP`.

Die produktiven Off-map-Pools MANAS und AL UDEID werden ausdrücklich **nicht** als AIRWING/WAREHOUSE modelliert. CampaignState besitzt dort die strategische count-basierte Verfügbarkeit; MOOSE führt nur die temporäre physische Tankerrepräsentation.

## 4. Verbindliche Architekturgrenzen

- Sensor, Entscheidung und Shooter besitzen getrennte Zustände.
- Spieler und KI arbeiten auf demselben Kontakt-, Ziel- und MissionDemand-Objekt.
- Unzureichende Identifikation, NSL-Konflikt oder fehlende Autorität blockieren Tasking beziehungsweise Wirkung.
- Zielbewegung und neue Koordinaten lösen eine erneute Targeting-Prüfung aus.
- BDA verändert CampaignState erst nach validierter Wirkung.
- Bewaffnete UAVs dürfen Aufklärung und Wirkung nur nach expliziter Rollen- und Freigabeentscheidung verbinden.
- `CampaignState` bleibt strategische Ressourcenautorität; MOOSE materialisiert und betreibt nur physische Missionsrepräsentationen.
- Die OMW-AAR-Station-Orchestrierung darf MOOSE-Tankermechanik, FuelLow-FSM, Mission-Cancel, Funk/TACAN oder Spawn-Lifecycle nicht parallel nachbauen.

## 5. AAR – gepinnter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsächlich verwendeten `Moose.lua` source-reviewed:

- `AUFTRAG:NewTANKER(Coordinate, Altitude, Speed, Heading, Leg, RefuelSystem)`;
- `AUFTRAG:SetRadio(...)`;
- `AUFTRAG:SetTACAN(...)`;
- `AUFTRAG:SetMissionIngressCoord(...)`;
- `AUFTRAG:SetMissionEgressCoord(...)`;
- `AUFTRAG:Cancel()`;
- `AIRWING:AddMission(...)`;
- `AIRWING:GetTankerForFlight(...)`;
- `SPAWN:InitCallSign(ID, Name, Minor, Major)`;
- `SPAWN:InitSTN(...)`;
- `GROUP:GetCallsign()`;
- `GROUP:GetFuelMin()`;
- `FLIGHTGROUP:Refuel(Coordinate)`;
- `FLIGHTGROUP:GetFuelMin()`;
- `FLIGHTGROUP:SetFuelLowThreshold(...)`;
- `FLIGHTGROUP:SetFuelLowRTB(...)`;
- `OPSGROUP:SwitchCallsign(...)`;
- `OPSGROUP:SwitchRadio(...)`;
- `OPSGROUP:TurnOffRadio()`;
- `OPSGROUP:SwitchTACAN(...)`;
- `OPSGROUP:TurnOffTACAN()`;
- `COORDINATE:Get2DDistance(...)`;
- `COORDINATE:Get3DDistance(...)`;
- `OPSGROUP:Despawn(...)`.

Die älteren Integration-3-Beobachtungen bestätigen den damaligen expliziten Spawn-Callsign-Pfad. Der aktuelle Produktionscontroller verwendet `SPAWN:InitCallSign(...)` dagegen für eine **Transitidentität** und wechselt erst beim Track-Entry auf die veröffentlichte Station-Identität. `InitSTN(...)` seedet die physische Tankerinstanz; Funk und TACAN werden während des Transitabschnitts abgeschaltet.

Die Methoden `SwitchCallsign`, `SwitchRadio`, `TurnOffRadio`, `SwitchTACAN` und `TurnOffTACAN` sind im gepinnten Source verfügbar und werden im aktuellen Controller verwendet. Ihr konkreter neuer Einsatz für den OMW-Station-Handover ist **SOURCE_REVIEWED**, aber bis zum neuen DCS-Lauf nicht `VALIDATED`.

Für `GROUP:GetFuelMin()` zeigte Integration-3 eine Timing-Grenze: unmittelbar im Materialisierungs-Callback kann die Methode den Sentinel `65535` liefern, solange noch kein belastbarer lebender Unit-Fuelwert ausgewertet werden konnte. Der korrigierte Harness `AAR-PRODUCTION-INTEGRATION-3R1` bewertet Fuel deshalb erst, wenn ein plausibler Fraction-Wert `0..1` vorliegt. Dieser Harness-only-Fix verändert den produktiven Controller nicht und wurde auf ausdrückliche Entscheidung des Projektinhabers nicht erneut isoliert in DCS ausgeführt.

## 6. Receiver-zu-Tanker-Auswahl

`AIRWING:GetTankerForFlight(flightgroup)` filtert aktive Tanker zunächst nach kompatiblem Refuelling-System und sortiert anschließend nach 2D-Distanz. Eine OMW-spezifische FAST/SLOW-Klasse ist dort nicht vorhanden.

`FLIGHTGROUP:Refuel(Coordinate)` pausiert die aktuelle Mission, erzeugt `TaskRefueling()` und routet den Receiver zu einem Refuel-Waypoint. Dieser öffentliche Pfad bindet keine konkrete Tanker-ID. Die DCS-Aufgabe refuelt beim nächstgelegenen kompatiblen Tanker.

Daraus folgt MOOSE-first:

```text
MissionDemand
-> Operationsraum + Receiver-Profil
-> OMW wählt AAR-Area und FAST/SLOW-Profil
-> OMW materialisiert den externen Tanker über SPAWN/FLIGHTGROUP/AUFTRAG
-> FLIGHTGROUP:Refuel() routet den Receiver zum vorgesehenen Refuel-Waypoint
```

Der COMMANDER darf die OMW-Rollenentscheidung nicht durch eine implizite Near-Tanker-Auswahl ersetzen. Die produktive Steuerung erfolgt durch Area-/Profilwahl und räumliche Trennung. Ein nativer DCS-Donor-Override ist nicht genehmigt.

Acceptance-6 zeigte zugleich die Grenze der nachträglichen Donor-Inferenz: A-10 und F-16 lieferten die erwartete räumliche Zuordnung, die F-15E-Proximity-Inferenz dagegen nicht. Der F-15E wurde dennoch tatsächlich betankt. Eine 3D-Nähe ist deshalb keine belastbare Donor-ID.

## 7. FuelLow, Relief und externer Egress

`FLIGHTGROUP:New()` setzt im gepinnten Stand standardmäßig:

```text
FuelLow threshold = 25 %
FuelLow RTB = true
```

`FLIGHTGROUP` prüft den minimalen Gruppenfuel und löst bei Unterschreiten der Schwelle `FuelLow` aus. Für externe OMW-Tanker gilt deshalb:

```text
SetFuelLowRTB(false)
```

Der aktuelle Controller verbindet den öffentlichen MOOSE-FuelLow-Callback mit einer kleinen OMW-Station-Orchestrierung:

```text
nominal:
ACTIVE on station
-> actual on-station timestamp
-> next handover = +3 h
-> relief launch based on gate-to-track transit
-> RELIEF_INBOUND
-> at approximately 5 min ETA: outgoing Cancel/Egress
-> relief reaches track-entry radius
-> station identity transfers
-> next cycle anchored to actual takeover

FuelLow fallback:
ACTIVE FuelLow
-> reuse existing relief OR queue exactly one emergency relief
-> Cancel/Egress outgoing
-> no duplicate relief for the same station
```

Pro Station sind höchstens ein `ACTIVE` und ein `RELIEF_INBOUND` vorgesehen. Das ist eine OMW-Orchestrierungsschicht um MOOSE-Primitiven, kein eigener Tanker-FSM-Ersatz.

Vor Egress wird die Station-Identität entfernt. Am externen Gate erfolgt der bereits bekannte kontrollierte `OPSGROUP:Despawn(...)`-Handoff. Der strategische CampaignState-Adapter recreditiert eine KC-135 erst nach diesem bestätigten Handoff.

Die in Acceptance-1 bis -6 verwendeten beschleunigten Schwellen bis 99 % waren ausschließlich Testmechanik. Sie dürfen nicht in produktiven Code übernommen werden.

## 8. Acceptance-6 – bestätigter AAR-Kernpfad

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Source/Builder commit: 29dbcd377603405292a2f37a682d6f6b5b19dcf8
Bundle SHA-256: 354433730acd0fc1eee4a3fe817cfaa870a054f3374dfab85f9814edfd29b091
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: 39da8370753e3ece055f0fd9f9dcc5dbeed2aa2eebe4540756931944f200963b
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Praktisch bestätigt:

- fünf KC-135 gleichzeitig als isolierte Stress-Test-Ausnahme;
- alle fünf Tanker `EXECUTING`;
- SLOW/FAST Same-area mit 3.000 ft vertikaler Staffelung;
- A-10C Boom-AAR;
- F-15E Boom-AAR;
- F-16C Boom-AAR;
- Post-Refuel-Dwell;
- FuelLow/Cancel/Egress/Off-map-Handoff als Mechanik.

Nicht bestätigt bzw. verworfen:

- C-130J als AAR-Receiver; die Annahme war fachlich falsch und wird aus der Receiver-Matrix entfernt;
- deterministische Donor-ID über Proximity-Telemetrie.

Die fünf Tanker bleiben eine Testausnahme. Produktiv gilt weiterhin:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

## 9. Integration-3 / 3R1 – belegte Grenzen

Bekannter Owner-Lauf:

```text
Testdatum: 2026-08-14/15
Branch: agent/aar-runtime-finalization
Commit: 4a6bef1c8a5b8f67606762e10c516610f970e491
BuilderVersion/TestId: AAR-PRODUCTION-INTEGRATION-3
Bundle SHA-256: 39fb3ecf80f6552d3478a8d83122eb69c83449bb3787731007c956fbdb6b49d1
Controller SHA-256: a937b67874dded3bb31ffcb4e7ea60d186ffde21f1e43bcccac4cf43f9e2da97
Mission: OMW_Template_v9_AirOps_rdy.miz
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Praktisch beobachtet:

- sechs MissionDemand-Mappings erfolgreich;
- sechs area-spezifische KC-135-Templates materialisiert;
- damalige area-spezifische DCS-Rufnamen sichtbar und im Controller-Log korrekt;
- Source-Domain-Staffelung mit vier Folgeabständen von jeweils `60.0 s`;
- parallele Materialisierung aus MANAS und AL UDEID zulässig.

Der korrigierte Harness `AAR-PRODUCTION-INTEGRATION-3R1` normalisiert Callsign-Trenner und verschiebt die Fuel-Auswertung bis zu einem plausiblen `0..1`-Wert. Für diese reine Testkorrektur ist kein weiterer DCS-Lauf vorgesehen.

Der Owner-lokale Source-/Build-Checkpoint für Commit `7c244d49f5070b490784c2659be51f5c1739bb55` bestätigt zusätzlich, dass der aktuelle Controller, der neue CampaignState-Adapter, die Off-map-Stockdaten und der Initializer exakt zum gepullten Branchstand vorlagen und der 3R1-Builder weiterhin erfolgreich lief. Dieser Checkpoint ist kein DCS-Nachweis für die neue Relief-/Identity-/CampaignState-Logik.

## 10. Keine unnötigen Wiederholungstests

Für denselben gepinnten DCS-/MOOSE-Stand besteht kein zusätzlicher allgemeiner Acceptance-Bedarf für die bereits bestätigte Grundmechanik: Spawn, Orbit, Boom-AAR, FAST/SLOW, Funk/TACAN-Grundpfad, Five-tanker-Stress und FuelLow/Cancel/Egress/Handoff.

Ein neuer DCS-Lauf ist dagegen erforderlich für den **neuen produktiven Integrationsscope**:

- nominaler 3-h-Relief-Zyklus;
- FuelLow-Relief ohne Doppelmaterialisierung;
- Transit-/Station-Callsign-, Radio- und TACAN-Handover;
- CampaignState `AIRCRAFT_KC135` Consume/Recredit;
- Fehler-/Loss-/No-Handoff-Verhalten;
- relevante Snapshot/Restore-Reconciliation.

Dieser neue DCS-Test bleibt gemäß Governance genehmigungspflichtig.

## 11. Aktuelle produktive Integration und offene Punkte

Implementierter Pfad:

```text
MissionDemand
-> AAR Controller selects Area/Profile/Source
-> CampaignState adapter CanMaterialize
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
-> CampaignState consumes 1 AIRCRAFT_KC135
-> transit identity
-> station identity / tanker mission
-> scheduled or FuelLow relief
-> Cancel / Egress
-> confirmed off-map handoff
-> CampaignState exact-once credit of 1 AIRCRAFT_KC135
```

Die Off-map-Pools sind reine CampaignState-count-Ressourcen:

```text
OFFMAP_MANAS    AIRCRAFT_KC135 = 16 count
OFFMAP_AL_UDEID AIRCRAFT_KC135 = 40 count
```

Es gibt bewusst keine künstliche DCS-Airbase, kein MOOSE WAREHOUSE/AIRWING für diese Pools, keine per-tail strategische Aircraft-Entität und keinen regulären Turnaround-Timer.

Noch offen:

1. MissionDemand-Ende/Cancel muss eine aktive Station kontrolliert auslaufen lassen und weitere Relief-Zyklen verhindern;
2. explizite Aircraft-Loss-Klassifikation/Logging muss einen bestätigten Verlust von einem bloß fehlenden Handoff unterscheiden, ohne unzulässige Recreditierung;
3. Snapshot/Restore während physische Tanker noch in der Luft sind benötigt eine deterministische Reconciliation;
4. höhere operative Concurrency bleibt außerhalb des strategischen Pools autoritativ und darf vom Adapter nicht dupliziert werden;
5. die neue produktive Integration benötigt nach Eigentümerfreigabe einen dokumentierten DCS-Acceptance-Lauf.
