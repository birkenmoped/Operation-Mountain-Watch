---
document_id: OMW-RESULT-FIXED-WING-CAS-A5-1-20261026
status: HISTORICAL_TEST_FIXTURE
evidence_status: FAILED_RUNTIME_EVIDENCE
runtime_result: FAIL
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact A5-1 DCS first-run evidence and failures
not_authoritative_for:
  - A5-2/A5-3 results or future DCS validation
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: f347aeb13f78e16c6c0c815c89d51b46a50d7702
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
validated_in_dcs: false
---

# A5-1 – Runtime FAIL vom 26.10.2026

## Exakte bekannte Artefaktkette

- Source-Commit/Bundled-Build: `f347aeb13f78e16c6c0c815c89d51b46a50d7702`
- Builder `OMW-FIXED-WING-CAS-RESPONSE-A5-1`
- Bundle SHA256 `D4BD212AAE55D2EB231F8261A752C9062F4156A301B0316E112562775425384B`
- Owner-Testmission `OMW_Template_v26_GroundWorks_Ready(3).miz` (hochgeladene Testkopie); MIZ SHA256 `2F342AEA94A8326087B59F205F01A031B7DD67A80BF126AE6AC9486C0EBCAFD9`
- Eingebettetes `mission` SHA256 `954368ABC7940E672FF87EC3FAC19C03044C8A49939341172BE7A608121ABC89`
- Eingebettete MOOSE `Moose.lua` SHA256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915` (Projektstand 2.9.18)
- DCS `2.9.30.28738` MT, Windows; Missionslog beginnt 26.10.2026 19:42 UTC.
- `dcs(5).log` SHA256 `83492623D01BB53737B3D7184C52E2EE734560344D7AD692DE9DC7B8904371B4`
- `debrief(5).log` SHA256 `DB99AD37CD04D0B71CFAC360CAD480B9389B9234749380865C48EE70E462ADD7`
- In der vorliegenden Debrief-Kopie ist kein bestandener End-to-End-CAS-Lauf nachgewiesen; der Owner beschreibt den starken F-16-Wingman-Nachbrenner und engen Circle direkt aus Sicht der DCS-Simulation.

## Ereignisnachweise

| Flight | Zuweisung (DCS-Walltime) | Zwei Flugzeuge gejoint | Separation beim Join | Nachfolgendes Holding |
|---|---|---|---|---|
| F-16C Bagram | 19:49:27.153 | 20:04:49.320 | 3157,946 m | `holding=true` |
| A-10C II Kandahar | 19:50:30.253 | 20:01:33.900 | 3479,615 m | `holding=true` |
| F-15E Bagram | 20:05:27.599 | 20:13:00.385 | 853,237 m | `holding=true` |

Bei jedem `TWO_SHIP_JOINED` wird in derselben Sekunde `DEPARTURE_HOLD_CLEARED` geloggt; danach wiederholt `FLIGHT_OBSERVER` `joined=true departureHoldCleared=true missionHoldingPresent=false holding=true missionState=started inAo=0`. Keine bestaetigte CAS-`MISSION_EXECUTE`, `ELEMENT_IN_AO`, `TWO_SHIP_IN_AO`, `AAR_SELECTED` oder `AAR_REFUELED` im Testzeitfenster. Im Debrief sind F-16- und A-10-`*_FlagHold`-Eintraege mit `value=0` vorhanden. **Der erfolgreiche Join fuehrte nicht zur MOOSE-Push-Freigabe.**

Fuel-Beispiel aus 20:16:01.389: F-16 Lead `fuelFraction=0.9539704323`, Wingman `fuelFraction=0.8292346597`, beide ungefaehr 15980–15920 ft MSL. Relative Fuel-Fraction-Werte und Eigentuemeraussage sind Evidenz eines energieunguensigen Joins; der tatsaechliche Nachbrennerzustand wurde nicht instrumentiert.

## Klassifikation und Root Cause

**FAIL**, nicht VALIDATED. Die A5-1-Source beseitigte unmittelbar bei `joinedForMission` das interne `AUFTRAG.missionHoldingCoord`. Die gepinnte MOOSE-2.9.18-`FLIGHTGROUP:Status()`-Pruefung verlangt gerade dieses Feld, um bei `IsReadyToPush()` selbst das `flaghold:Set(1)` zu setzen und `isHoldingAtHoldingPoint=false` zu erreichen. Die Logsequenz und Flagwerte sind mit genau dieser Fehlsteuerung konsistent. Weitere physische Folgen nach Ende der Logs nicht behaupten.

## Korrektur und naechstes freigegebenes Gate

A5-3 integriert **in einem neuen Gesamtstand**: `joinedAt`-Latch, MOOSE-native Release-Flag vor einmaliger Clearing-Mutation, MOOSE-`TaskOrbit`-Racetrack-Konstruktor-Adapter nur fuer identische A5-Departure-Coordinates, DCS-Terrain-Sampling und niedrigeres Initialprofil, vollstaendige CAS-/AAR-/RTB-Telemetrie. Alle A5-3-Aussagen bleiben DCS_PENDING; die vorliegenden Logs testen nur A5-1. Die MIZ wird ausschliesslich vom Owner angepasst, kein nachtraegliches Ueberschreiben der A5-1-Provenienz.

