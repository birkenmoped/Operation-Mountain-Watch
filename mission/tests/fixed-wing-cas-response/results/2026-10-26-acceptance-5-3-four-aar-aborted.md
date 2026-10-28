---
document_id: OMW-RESULT-FIXED-WING-CAS-A5-3-20261026
status: HISTORICAL_TEST_FIXTURE
evidence_status: FAILED_RUNTIME_EVIDENCE
runtime_result: FAIL
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact A5-3 real flight observations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: a407cc3bea9b3734482167fb986c17549df31ce2
validated_in_dcs: false
---

# A5-3 – Vier A-10-Betankungen, vom Owner abgebrochen

## Quelldaten

- Besitzerlogs: `dcs(6).log`, SHA256 `D10474D157CC9D1869DB8A2BEB05E98E4DB33DBD10C89493DD388314054F7610`; `debrief(6).log`, SHA256 `65D8043455871467A74DA73257FF19039B6E9282E58753FE9642D6E7F7E2AE15`.
- Lokaler A5-3-Git-/Builder-Stand aus der Besitzerkonsole: `a407cc3bea9b3734482167fb986c17549df31ce2`; Bundle SHA256 `951BEB67CC41E502FB8359F8692116C10CF2F853689F70ED2BBB4ED2C676A285`. Ein MIZ-/eingebetteter Bundle-Hash **dieses** Testlaufs wurde nicht mitgeliefert, daher Zuordnung anhand Testkontext und Builder-Signatur, nicht vollstaendig kryptografisch validiert.
- Das DCS-Log enthaelt auch Zeilen aus einem vorangegangenen Lauf. Die A5-3-Evidenz beginnt bei `DEPARTURE_RACETRACK_CONFIGURED` 21:20:20.027 und darf nicht mit vorherigen `TWO_SHIP_JOINED`-Zeilen ohne ReleaseFlag verwechselt werden.

## Tatsächlich beobachtete Ereignisse (DCS-Log Wallclock / Missionszeit)

| Ereignis | Wallclock | Ingame Missionszeit |
|---|---|---|
| Racetrack-Task F-16 | 21:20:58 | 15:01:44 |
| Racetrack-Task A-10 | 21:22:01 | 15:02:47 |
| Join A-10 | 21:34:57 | 15:15:43 |
| A-10 Holding cleared / MOOSE `releaseFlag=1` | 21:35:05 | 15:15:50 |
| F-16 Join / Holding cleared | 21:37:54 / 21:38:05 | 15:18:40 / 15:18:50 |
| F-15E Join / Holding cleared | 21:53:24 / 21:53:35 | 15:34:10 / 15:34:20 |
| A-10 1. `AAR_REFUELED` | 22:13:14 | 17:01:13 |
| A-10 `TWO_SHIP_IN_AO` | 22:15:12 | 17:09:51 |
| A-10 2. `AAR_REFUELED` | 22:19:04 | 19:16:53 |
| A-10 3. `AAR_REFUELED` | 22:23:15 | 21:30:17 |
| A-10 4. `AAR_REFUELED` | 22:25:32 | 23:47:37 |

**Ergebnis:** Drei native MOOSE-Racetracks generiert; alle drei Two-Ship-Join-Latches und native Holding-Flag-Releases bestaetigt. A-10 nach initialer AAR mit beiden Flugzeugen im CAS-AO, danach vier AAR-Resume-Zyklen. Owner beendete Test nach vierter Betankung. Keine zeitabhaengige Sortie-/Station-Endgrenze im getesteten A5-3-Code. F-16 und F-15E wechselten bei fehlendem verfuegbaren kompatiblen Tanker bereits durch MOOSE FuelLow-Fallback nach RTB (keine generelle CAS-Dauer-Abnahme). A5-4 fuegt die gemeinsame zeitbasierte Endentscheidung hinzu; **DCS-Landung innerhalb Limits ist ausstehend**.

