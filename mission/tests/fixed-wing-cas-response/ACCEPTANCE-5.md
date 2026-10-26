---
document_id: OMW-TEST-FIXED-WING-CAS-RESPONSE-ACCEPTANCE-5
status: PLANNED
document_class: TEST_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local fixed-wing CAS one-shot departure holding and AAR mission resume regression
not_authoritative_for:
  - production fuel policy or DCS-validated CAS lifecycle
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fixed-Wing CAS Response – Acceptance 5

## Ausgangslage und Owner-Ausnahme

A4 ist FAIL fuer genau seinen dokumentierten Teststand. Der A-10-Two-Ship erhielt bei PATTY eine bestaetigte Luftbetankung, erreichte aber den Honaker-CAS-Raum danach nicht nachweislich; zwei A-10 gingen spaeter verloren. Das in A4 auf `AUFTRAG` gespeicherte Departure-Holding wird in `OPSGROUP:RouteToMission` bei erneutem Route-Build beruecksichtigt; `joinedForMission` wertete ausserdem den jeweils aktuellen Abstand statt des schon bestaetigten Join aus.

Die alternative ORBIT/CAS-Queue-Trennung wurde untersucht. Der `COMMANDER -> LEGION -> flightgroup:AddMission(CAS) -> OnAfterOpsOnMission`-Pfad und die `self.legion`-Behandlung in `_GetNextMission` lassen kein garantiert racefreies nachtraegliches ORBIT-Prepend erkennen. Quellenbelege siehe `docs/air-operations-fixed-wing-cas-coverage-and-ground-alert-decision.md` §§10.10–10.13.

**Explizite Owner-Freigabe vom 26.10.2026:** A5 darf **nur nach nachgewiesenem Zwei-Flugzeug-Join** das interne Feld `mission.missionHoldingCoord = nil` setzen. Keine weiteren MOOSE-Interna, keine eigene Flugsteuerung, kein Patch an `Moose.lua`, keine A4-Retrokorrektur. Die Freigabe ist auf diese A5-Diagnose-/Korrekturgrenze beschraenkt. Spaetere MOOSE-Entwicklerantworten sind ein Review-Trigger.

## Implementierte A5-Differenz zu A4

- Neue Quelltestdatei `src/acceptance-5-three-flight-joined-aar-resume.lua`, A4-Datei bleibt unveraendert.
- Derselbe `COMMANDER` erstellt drei `AUFTRAG:NewCAS`-Anfragen, nutzt existierende AIRWING/SQUADRON-Bestandsobjekte und laesst MOOSE FLIGHTGROUP rekrutieren und fuehren.
- `joinedForMission` gibt nach bestaetigtem `record.joinedAt` dauerhaft `true` zurueck; nach AAR keine neue Join-Freigabe.
- Beim **ersten** Join wird ausschliesslich `mission.missionHoldingCoord` auf `nil` gesetzt, wenn zuvor tatsaechlich ein Holding gespeichert war. Diese interne Ausnahme verhindert nachfolgendes erneutes Einfuegen des Departure-Holdings in `RouteToMission`-Rebuilds. Der aktuelle DCS-Orbit wird dabei weder manuell gecancelt noch umgeroutet. `DEPARTURE_HOLD_CLEARED` ist Diagnose, keine DCS-Wirksamkeitsgarantie.
- `SetFuelLowThreshold(30)` wird **nur an der fuer CAS zugewiesenen FLIGHTGROUP** gesetzt, wie zuvor vom Owner genehmigt. A4-exploratives fruehes A-10-AAR bei 65%, A4-Tankerauswahl und FuelLow-Fallback bleiben als **test-only** kenntlich. Die Koexistenz mit FuelLowRefuel(false) ist **kein** finales Produktions-Fuel-/AAR-Konzept.
- Die bisherigen MOOSE-`Refuel/Refueled`, `MissionStart/RouteToMission`, `RTB` und `LEGION/AIRWING`-Recovery-Verantwortlichkeiten bleiben erhalten. Der Acceptance-Observer misst; er ist kein zweiter Flug-/Recovery-Controller.

## Lifecycle-Inheritance

`docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md` §§8.3, 11, 11.2 beachten: A9 ist fuer den dokumentierten Rotary-Wing-CAS-Scope akzeptiert, **nicht** fuer diese Fixed-Wing-CAS-A5-Variante. Vorhandene `OMW.AirOps.Bagram/Kandahar`-SQUADRONs, `OMW.AAR.GetActive` und MOOSE-FSMs werden wiederverwendet. A4-AAR-Testlogik ist historische Fixture, kein produktives Asset-Settlement. Kein neuer `CampaignState`-Owner. Normaler physischer Return/Asset-Recredit ist im A5-DCS-Lauf gesondert nachzuweisen.

## Neue Diagnose und DCS-Abnahme

Marker:
`TWO_SHIP_JOINED`, `DEPARTURE_HOLD_CLEARED`, `DEPARTURE_HOLD_ALREADY_ABSENT`, `FLIGHT_OBSERVER` mit `departureHoldCleared` und `missionHoldingPresent`, `AAR_SELECTED`, `AAR_REFUELED`, `MISSION_EXECUTE`, `ELEMENT_IN_AO`, `TWO_SHIP_IN_AO`, `MOOSE_RTB`.

1. Fuer alle drei Two-Ships starten beide Elemente; vor erstmaliger Departure-Freigabe ist der tatsaechliche Abstand <=2 NM und beide sind airborne.
2. Genau einmal `TWO_SHIP_JOINED` und `DEPARTURE_HOLD_CLEARED` je betroffene CAS-Mission. Nach dem Join keine erneute Freigabeanforderung, auch nicht nach AAR-Trennung.
3. A-10 AAR am tatsaechlich verfuegbaren, kompatiblen PATTY/MILHOUSE-Tanker und anschliessende `Refueled`-Fortsetzung; danach kein erneuter Kandahar-Departure-Orbit. Aktive MOOSE-Waypoints/Flugweg in DCS und Logs gegen die Hypothese pruefen.
4. Nach AAR erreichen **beide** A-10 den Honaker-CAS-Raum; getrennt dokumentieren, ob die CAS-Mission tatsaechlich ausfuehrt oder nur AO-Eintritt erreicht.
5. F-16/F-15E behalten funktionsfaehigen Join, CAS-Anflug, AAR/FuelLow- und Recovery-Pfad; keine Fuel-0-Verluste durch die Korrektur als unerhebliche Regression behandeln.
6. Fuer jeden der sechs Flieger physische Landung oder Verlust nachweisen; `AUFTRAG success/done` ist nicht gleich sichere Landung oder Asset-Recredit.
7. AAR waehrend Transit und waehrend laufender CAS-Mission muessen separat erprobt werden, sobald der jeweilige Zeitpunkt reproduzierbar ausgeloest werden kann. AAR **nach** `RTB()` ist weiterhin ein separates offenes Gate, weil MOOSE dort `CancelAllMissions()` aufruft.
8. Multiplayer-/Serverstart-, Doppel-Request- und Foundation-Regressionen bleiben vor Produktionsfreigabe verpflichtend.

## Build und Provenienz

Builder: `tools/build-fixed-wing-cas-response-acceptance-5.ps1`

Bundle: `mission/tests/fixed-wing-cas-response/dist/OMW_FixedWing_CAS_Response_Acceptance_5.lua`

Gepinnte MOOSE-Version: 2.9.18, eingebetteter SHA256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`.

Die Test-.miz wird **nur** vom Projektinhaber in einer separaten Kopie angepasst. A1–A5 duerfen nie parallel geladen werden. Vor DCS-Lauf Build-Commit, generiertes Bundle, Bundle-SHA256 und tatsaechliche MIZ-/embedded-MOOSE-SHA256 erfassen; reale Konsolenausgabe dokumentieren.

**Status: SOURCE_IMPLEMENTED / STATIC_REVIEW_PENDING / DCS_PENDING. Kein A5-PASS.**


## A5-2 Korrektur der Holding-Freigabereihenfolge (26.10.2026)

**A5-1 Static-Review-FAIL / DCS nicht ausgefuehrt:** Die zuerst gebaute A5-1-Datei (Builder `OMW-FIXED-WING-CAS-RESPONSE-A5-1`, Bundle-SHA256 `D4BD212AAE55D2EB231F8261A752C9062F4156A301B0316E112562775425384B`) setzte `mission.missionHoldingCoord=nil` unmittelbar beim erstmaligen Join. Die gepinnte MOOSE-2.9.18-Funktion `FLIGHTGROUP:Status()` prueft jedoch `mission and mission.missionHoldingCoord and self.isHoldingAtHoldingPoint == true`, **bevor** sie bei `mission:IsReadyToPush()` `self.flaghold:Set(1)` ausloest. Vorzeitiges Nullsetzen blockiert diesen normalen, MOOSE-eigenen Release-Check. Dies erklaert den vom Owner beobachteten fortgesetzten Platzrunden-Orbit nach Join als quellengestuetzte Fehlerhypothese; ohne neue DCS-/Waypoint-Evidenz kein bereits bestaetigter Laufzeit-Causal-PASS.

**A5-2 Implementierung:** `joinedForMission` setzt ausschliesslich das dauerhaft gueltige `record.joinedAt`. `FLIGHTGROUP:Status()` darf das bestehende `missionHoldingCoord` sehen und **selbst** den Controlled-Orbit durch `flaghold:Set(1)` beenden. Erst ein spaeterer passiver A5-Observer entfernt das vom Owner genehmigte interne `mission.missionHoldingCoord=nil`, wenn `flight.isHoldingAtHoldingPoint==false` **und** die MOOSE-`USERFLAG:Is(1)` die Freigabe bestaetigt. Es gibt keinen OMW-`flaghold:Set`, keine Task-/Route-/Controller-Mutation und keine neue Scheduler-Instanz. `DEPARTURE_HOLD_CLEARED` ist erst nach dem nachgewiesenen MOOSE-Release zulaessig.

**Neue erwartete Reihenfolge:** `TWO_SHIP_JOINED -> MOOSE Status IsReadyToPush -> MOOSE flaghold=1 -> isHoldingAtHoldingPoint=false -> DEPARTURE_HOLD_CLEARED -> MOOSE RouteToMission after AAR without departure holding`. Vor dem naechsten DCS-Lauf ist ein **neuer** A5-2-Build mit Git-Commit und echtem Bundle-SHA256 erforderlich; die bereits eingebettete A5-1-Version und deren MIZ-Hash sind nur historische Testvorbereitung, nicht gueltig fuer A5-2. Eine eventuell spaeter gewuenschte Racetrack-Geometrie ist eine getrennte noch offene A5-Folgeentscheidung; A5-2 haelt zunaechst Circle 16.000 ft Bagram / 12.000 ft Kandahar unveraendert und behebt ausschliesslich die Release-Reihenfolge.

**DCS-Regressionen:** physische Abkehr vom Departure-Orbit **zeitnah nach Join**, kein Fortsetzen bis zum 3600-s-Timeout, kein erneutes Kandahar-Holding nach AAR, beide Flugzeuge im CAS-AO, Fuel-/Speed-/Altitude- und RTB-/Landing-/Return-Verhalten. Das Besitzer-Feedback zu F-16-Wingman-Nachbrenner und engem Kreis bleibt als separate offene Geometrie-/Energiefrage. **Status: SOURCE_CORRECTED / BUILDER_A5-2 / NEW_BUILD_PENDING / DCS_PENDING.**
