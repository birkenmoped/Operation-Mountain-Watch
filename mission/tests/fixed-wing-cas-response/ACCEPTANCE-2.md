---
document_id: OMW-TEST-FIXED-WING-CAS-RESPONSE-ACCEPTANCE-2
status: PLANNED
document_class: TEST_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local fixed-wing CAS two-ship holding and join acceptance
  - terrain-safe MOOSE-CAS profile and diagnostics of A-10 recruitment and fuel handling
not_authoritative_for:
  - a validated departure/rejoin technique
  - DCS-confirmed safe terrain clearance, fuel returns, AAR or crashes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fixed-wing CAS Response – Acceptance 2

## Anlass und Evidenz

Acceptance 1: v26-Mission, DCS 2.9.30.28738 MT, MOOSE 2.9.18, A1-Git-Commit `147e74ccc17d22aa47cba8f133532014f51d6c10`, lokal generiertes A1-Bundle SHA-256 `C6DAE11DF56FA2A941C2FFD0CEF7363A4127F2F1C48560D3A7911B09129CB37F`. Nutzerbeobachtung und bereitgestellte DCS-/Debrief-Logs vom 17.10.2026: F-16/F-15E-Lead/Wingman nehmen stark versetzt Startpositionen ein; F-16-Wingman verbraucht im Aufholflug unverhaeltnismaessig Treibstoff, Fuel-Observer meldete 0; tiefer Gebirgstransit; Kandahar A-10 wurde trotz C2-Request nicht disponiert; DCS endete mit nativem Access-Violation-Crash. F-16-Lead fuehrte erfolgreiche GBU-12-Angriffe aus.

Die Ursache fuer den DCS-Absturz ist **nicht** nachgewiesen. Ein an 0 Fuel angrenzender Wingman-Verlust ist eine starke Fuel-Evidenz, aber kein vollstaendig bewiesener Unfallhergang.

## Verbindliche Eingriffsgrenzen

- Keine Lua-Eingriffe in DCS-ATC, Runway-Freigaben, Taxi und Parkplaetze.
- Keine native DCS-Task-/Eventsteuerung, keine vom Test selbst erzeugten `SPAWN`-Flights.
- Keine AAR-Automatik, Tankerzuweisung, Fuel-Low-Schwellenwerte oder vom Test ausgeloestes RTB.
- Normaler `AUFTRAG:NewCAS`, `AssignSquadrons`, `SetRequiredAssets(1,1)`, `COMMANDER:AddMission` und bereits vorhandene AIRWING-/SQUADRON-Lifecycles.
- MOOSE-Parameter fuer Mission und Departure-Holding sind **ausdruecklich gewollte Missionskonfiguration**, keine Umgehung der Missionsengine.
- Bestehende Nutzer-Callbacks werden verkettet; Laufzeitinteraktionen aus Fuel-/RTB-Callbacks bleiben MOOSE-Eigentum.
- Der Acceptance-Code misst den Join-Abstand, gibt nur ein Boolean an `AUFTRAG:AddConditionPush` zurueck und steuert kein Flugzeug.
- Das Original-`.miz` bleibt unveraendert; ME-Einbindung ausschliesslich durch Projektinhaber.

## Neue MOOSE-Missionsparameter

| Bereich | A2-Startwert | MOOSE-Mechanik |
|---|---|---|
| Gemeinsames CAS-AO | Honaker, 5 NM | `AUFTRAG:NewCAS(state.ao,...)` |
| CAS-Missionshoehe | 22.000 ft MSL | `AUFTRAG:NewCAS(zone, altitude, speed)` |
| CAS-Missionsgeschwindigkeit | 350 kn | ebenfalls `NewCAS` |
| Bagram Departure-Holding | Airbase-Koordinate | `AUFTRAG:SetMissionHoldingCoord` |
| Holding-Hoehe | 16.000 ft MSL | `SetMissionHoldingCoord` |
| Holding-Geschwindigkeit | 250 kn | `SetMissionHoldingCoord` |
| MOOSE-Holding-Maximaldauer | 3.600 s | `SetMissionHoldingCoord` |
| Join-Freigabe | Beide Flight-Elemente airborne und 2D-Abstand maximal 2 NM | `AUFTRAG:AddConditionPush` |
| A-10 | unveraenderte direkte CAS-Request-Kette | kein Holding-Override |

Alle Hoehen sind **Startwerte fuer DCS-Acceptance**, kein fuer jede Strecke bereits bewiesenes Mindesthoehenprofil. Der tatsaechliche MOOSE-/DCS-Flugweg muss auf Terrain Clearance geprueft werden. Der Bagram-Holding-Orbit ist nicht identisch mit einer stabilen engen taktischen Formation; 2 NM ist eine hier explizit definierte Join-Freigabeschwelle.

**MOOSE-Grenze:** Der im gepinnten Source vorhandene Controlled-Orbit besitzt eine endliche TaskCondition-Dauer. Es wird **nicht** behauptet, dass `AddConditionPush` einen Orbit ohne Dauerlimit garantiert. Das Script protokolliert `HOLD_RELEASED_WITHOUT_JOIN`, sofern es einen entsprechend erkennbaren Fall feststellt; dieser Marker ersetzt keinen beweiskraeftigen DCS-Track. Wenn der Orbit nach 60 Minuten ohne Join abbricht, ist das ein Testfehler, keine zugelassene Policy.

## Gemeinsamer Test

In genau einem DCS-Lauf:
1. F-16C Two-Ship aus Bagram als echter CAS-Request.
2. A-10C Two-Ship aus Kandahar 60 Sekunden spaeter.
3. F-15E Two-Ship aus Bagram nach bestaetigtem Start beider F-16.

Die F-15E-Anfrage wartet **nicht** auf die erfolgreiche Join-Freigabe der F-16; dadurch bleibt das vereinbarte Bagram-ATC-Staggering identisch mit Acceptance 1. Der formierte CAS-Transit selbst wartet auf die Join-Freigabe.

## Beobachtung und Akzeptanzgrenze

- `MOOSE_HOLDING`, `ELEMENT_TAKEOFF`, `ELEMENT_AIRBORNE`, `TWO_SHIP_JOINED`, `MISSION_EXECUTE`, `ELEMENT_IN_AO`, `TWO_SHIP_IN_AO`.
- `FLIGHT_OBSERVER` dokumentiert MOOSE-Fuel-, Refuel-/RTB-/Holding-Zustand sowie Formationsdistanz. `MOOSE_FUEL_LOW`, `MOOSE_FUEL_CRITICAL`, `MOOSE_RTB` beobachten FSM-Lifecycle ohne eigene Entscheidung.
- `C2_PENDING` zeigt die ausstehende A-10-C2-Zuweisung. Der eigentliche Rekrutierungsgrund ist erst nach DCS-/MOOSE-Logauswertung feststellbar. A2 behauptet **keinen reparierten Kandahar-Spawn**.
- Bei Timeouts ohne Join, niedrigem Transit, schneller Entleerung, fehlendem A-10-Dispatch oder DCS-Crash: `DCS_FAIL`/offene Abweichung, niemals `VALIDATED`.

## Artefakte

```text
mission/tests/fixed-wing-cas-response/src/acceptance-2-three-flight-joined-departure.lua
tools/build-fixed-wing-cas-response-acceptance-2.ps1
mission/tests/fixed-wing-cas-response/dist/OMW_FixedWing_CAS_Response_Acceptance_2.lua (build output)
```

Die GitHub Actions muessen die Lua-5.1-Source und das generierte Bundle pruefen. Danach Besitzer: lokaler `git pull`, PowerShell-Build und reale SHA-256-Konsole. Besitzer: neues `DO SCRIPT FILE` in separater Test-`.miz` **anstelle** der A1-Testeinbindung; nicht zwei Acceptance-Bundles parallel laden. Nach jedem Speichern gemaess Dokument 22 vollstaendige MIZ-/Bundle-/MOOSE-Hashkette. Erst dann DCS.
