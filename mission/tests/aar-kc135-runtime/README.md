---
document_id: OMW-TEST-AAR-KC135-RUNTIME-INDEX
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - KC-135 multi-tanker AAR runtime acceptance test layout
  - exact active template set and expected test markers
  - source-reviewed MOOSE paths used by the acceptance harness
not_authoritative_for:
  - DCS runtime acceptance before an owner-run test
  - final ingress-gate airspace clearance
  - historical tanker callsign authenticity
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# KC-135 Multi-Tanker Runtime Acceptance

## Ziel

Der Test prueft in einem gemeinsamen DCS-Lauf mehrere AAR-Funktionen statt einzelner Tippelschritte:

- drei KC-135 Boom-Tanker aus Mission-Editor-Seed-Templates im selben Testlauf;
- maximal zwei gleichzeitig laufende Supportmissionen entsprechend `OMW-AIR-IMPLEMENTATION`;
- Uebernahme der im Template gesetzten 90/96-%-Fuelwerte beim MOOSE-SPAWN;
- `SPAWN -> FLIGHTGROUP -> AUFTRAG:TANKER` im gepinnten MOOSE-Stand;
- unterschiedliche AAR-Areas, Frequenzen, TACAN-Kanaele und Callsigns;
- Transit vom OMW-Ingress-Gate zur AAR-Area;
- Racetrack-Auftrag;
- beschleunigter `FuelLow`-Test ohne eigenen Fuel-Polling-Controller;
- Abbruch des Tankerauftrags bei `FuelLow` und Nutzung des AUFTRAG-Egress-Waypoints;
- gestaffelte Aktivierung von Homer nach dem Clancy-FuelLow-Ereignis, sodass die globale Supportmissionsgrenze nicht ueberschritten wird.

Der Test veraendert keine `.miz` automatisch. Der Projektinhaber bindet das erzeugte Bundle manuell in die Testmission ein.

## Test-ID

```text
AAR-KC135-RUNTIME-ACCEPTANCE-1
```

## Source / Builder / Dist

```text
mission/tests/aar-kc135-runtime/src/01-aar-kc135-runtime-acceptance.lua
tools/build-aar-kc135-runtime-acceptance.ps1
mission/tests/aar-kc135-runtime/dist/OMW_AAR_KC135_Runtime_Acceptance.lua
```

`dist/` wird ausschliesslich durch den Builder erzeugt.

## MOOSE-First-Nachweis

Gepinnter MOOSE-Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Im tatsaechlich verwendeten `Moose.lua` source-reviewed:

```text
SPAWN:New(template)
SPAWN:SpawnFromCoordinate(coordinate)
FLIGHTGROUP:New(group)
OPSGROUP:AddMission(mission)
AUFTRAG:NewTANKER(...)
AUFTRAG:SetRadio(...)
AUFTRAG:SetTACAN(...)
AUFTRAG:SetMissionEgressCoord(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP:OnAfterFuelLow(...)
AUFTRAG:Cancel()
```

Der Harness nutzt MOOSE `SCHEDULER` nur fuer 30-sekuendiges Acceptance-Logging. Er implementiert keinen eigenen Fuel-Controller und keinen Native-DCS-Eventhandler.

## Governance-Grenze fuer Supportmissions-Concurrency

`docs/18-air-operations-implementation.md` setzt missionsweit:

```text
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Der Acceptance-Harness haelt diese Grenze ein. Initial laufen gleichzeitig nur `CLANCY` und `NELSON`. Sobald `CLANCY` den beschleunigten `FuelLow`-Schwellwert erreicht, wird dessen Tankerauftrag abgebrochen und auf den Missions-Egress uebergeleitet. Erst danach wird `HOMER` als neuer Tankerauftrag gestartet. Damit werden im selben DCS-Lauf drei Tankerpfade geprueft, ohne drei gleichzeitige Supportmissionen zu erzeugen.

## Mission-Editor-Vertrag

Die hochgeladene Owner-Mission vom 14.08.2026 enthaelt folgende Late-Activation-Templates mit leeren Advanced-Waypoint-Tasks:

| Area | Template | Callsign | Radio | Fuel | Datalink | STN |
|---|---|---|---:|---:|---|---|
| Clancy | `OMW_AAR_KC135_CLANCY` | Shell 1-1 | 241.600 AM | 90 % / 81630 kg | SH11 | 04461 |
| Homer | `OMW_AAR_KC135_HOMER` | Arco 1-1 | 376.000 AM | 90 % / 81630 kg | AC11 | 04462 |
| Krusty | `OMW_AAR_KC135_KRUSTY` | Arco 2-1 | 258.300 AM | 90 % / 81630 kg | AC21 | 04463 |
| Nelson | `OMW_AAR_KC135_NELSON` | Texaco 1-1 | 384.400 AM | 96 % / 87072 kg | TX11 | 04464 |
| Patty | `OMW_AAR_KC135_PATTY` | Texaco 2-1 | 237.300 AM | 96 % / 87072 kg | TX21 | 04465 |

Die Template-Gruppe behaelt DCS `task = Refueling`; die automatisch erzeugten Wegpunktaktionen fuer Tanker/TACAN/Orbit sind entfernt. Die eigentliche Runtime-Mission kommt aus MOOSE.

## Aktiver Testblock

Der gemeinsame Lauf startet gestaffelt:

```text
INITIAL CONCURRENT:
CLANCY
NELSON

AFTER CLANCY FUELLOW/CANCEL:
HOMER

PREPARED BUT INACTIVE:
KRUSTY
PATTY
```

Homer/Krusty bleiben weiterhin Alternativen; Krusty wird in diesem Acceptance-Lauf nicht aktiviert.

### Testwerte

| Area | Track | Altitude | Speed | Heading | Leg | Radio | TACAN | Fuel erwartet | FuelLow Test |
|---|---|---:|---:|---:|---:|---:|---|---:|---:|
| Clancy | N31.75441342 E66.82695501 | FL225 | 300 kt | 225.276 T | 35 NM | 241.600 AM | 60X / CLA | 90 % | 89 % |
| Homer | N32.93833333 E68.22333333 | FL230 | 300 kt | 317.573 T | 35 NM | 376.000 AM | 54X / HOM | 90 % | 89 % |
| Nelson | N36.37666667 E71.01833333 | FL275 | 300 kt | 10.428 T | 35 NM | 384.400 AM | 47X / NEL | 96 % | 95 % |

Die 300 kt liegen innerhalb des source-derived KC-135 Boom-Domains 200-320 kt. Die Testhoehen liegen innerhalb der jeweiligen produktiven AAR-Bloecke. Diese Kombination ist eine Testkonfiguration und noch keine DCS-validierte optimale Receiver-Konfiguration.

### Ingress/Egress

```text
CLANCY / HOMER:
OMW_TANKER_GATE_S
N29.9818333333 E64.6116666667

NELSON:
OMW_TANKER_GATE_NE
N38.1211666667 E70.3600000000
```

`OMW_TANKER_GATE_NE` bleibt ein Candidate mit offener Airway- und Map-edge-Pruefung. Der Test kann das technische MOOSE-Egress-Verhalten pruefen, macht den Gate-Punkt aber nicht automatisch `BINDING` oder `VALIDATED`.

## Erwartete DCS-Logmarker

```text
START
START_AREA_PASS area=CLANCY
START_AREA_PASS area=NELSON
SPAWN_PASS area=CLANCY
SPAWN_PASS area=NELSON
MISSION_CONFIG_PASS area=CLANCY
MISSION_CONFIG_PASS area=NELSON
HARNESS_READY
TANKER_EXECUTING_PASS area=CLANCY
TANKER_EXECUTING_PASS area=NELSON
STATUS area=...
SUMMARY ... supportMissionLimit=2
FUEL_LOW_PASS area=CLANCY action=CANCEL_TO_EGRESS
STAGE_TRANSITION from=CLANCY to=HOMER reason=CLANCY_FUEL_LOW
START_AREA_PASS area=HOMER
SPAWN_PASS area=HOMER
MISSION_CONFIG_PASS area=HOMER
TANKER_EXECUTING_PASS area=HOMER
```

Der Fuel-Readback ist in Prozent der tatsaechlichen DCS-Einheit. Als Template-Referenz gelten 90700 kg = 100 %, 81630 kg = 90 % und 87072 kg = 96 %.

## Acceptance-Kriterien

Ein erfolgreicher gemeinsamer Lauf muss mindestens zeigen:

1. Clancy und Nelson werden initial genau einmal als KC-135 gespawnt;
2. Fuel-Readback liegt unmittelbar nach Spawn plausibel bei 90/96 % und wird nicht auf 100 % zurueckgesetzt;
3. beide initialen `AUFTRAG:TANKER` erreichen `EXECUTING`;
4. Funk und TACAN sind fuer Clancy und Nelson im Cockpit eines geeigneten Receivers praktisch pruefbar;
5. Boom-Refueling ist mit mindestens einem aktuellen OMW-Boom-Receiver praktisch pruefbar;
6. Clancy erreicht den beschleunigten FuelLow-Schwellwert, automatisches MOOSE-FuelLow-RTB bleibt deaktiviert und der Tankerauftrag wird stattdessen abgebrochen;
7. der vorhandene AUFTRAG-Egress-Waypoint fuehrt Clancy aus dem Track in Richtung zugewiesenem Gate;
8. Homer wird erst nach dem Clancy-FuelLow/CANCEL-Ereignis gestartet und erreicht ebenfalls `EXECUTING`;
9. Homer uebernimmt seinen 90-%-Seed-Fuelwert sowie eigene Funk-/TACAN-Konfiguration;
10. zu keinem Zeitpunkt meldet der Harness mehr als zwei gleichzeitig `EXECUTING` befindliche Supportmissionen;
11. Nelson und Homer erreichen ihre beschleunigten FuelLow-Schwellwerte und erhalten jeweils den CANCEL-to-Egress-Pfad;
12. keine Behauptung ueber simulierte Off-map-Recovery wird aus diesem Lauf abgeleitet.

`VALIDATED` darf erst nach dokumentiertem Owner-DCS-Lauf mit Branch, Commit, MIZ-Hash, Bundle-Hash, DCS-Version und gepinntem MOOSE-Hash gesetzt werden.
