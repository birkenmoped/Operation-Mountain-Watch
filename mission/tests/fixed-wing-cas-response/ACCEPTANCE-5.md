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

**Aktueller Stand 30.10.2026: A5-4 und A5-5 Runtime FAIL; A5-6 SOURCE_CORRECTED / DCS_BLOCKED_DEPARTURE.** Die bedingte Owner-Freigabe fuer die minimalen Fuel-/Recovery-Ergaenzungen ist nach gezielter MOOSE-Pruefung umgesetzt. [Verlustrekonstruktion](results/2026-10-28-acceptance-5-4-loss-reconstruction.md) und [aktueller Korrekturvertrag](../../../docs/moose/FIXED-WING-CAS-FUEL-RECOVERY-CORRECTION.md). Aeltere A5-1 bis A5-4-Abschnitte sind historische Entwicklungsstaende; insbesondere das AAR-Verbot nach Final-RTB und die 65-%-Testschwelle gelten NICHT fuer A5-5. Vor neuem DCS-Test sind realer Owner-Pull, Build und Hashpruefung erforderlich.

## Aktuelle Sperre nach A5-5 (30.10.2026)

**A5-5 Runtime FAIL; A5-6 SOURCE_CORRECTED / DCS_BLOCKED_DEPARTURE.**
[Ergebnisbericht](results/2026-10-30-acceptance-5-5-premature-recovery-fail.md).
Die A5-5-Abschnitte unten sind historische Staende.
Der neue Builder erzeugt A5-6 nur als Source-/Diagnosekandidat. Kein neuer DCS-Lauf
ist allein durch Build/Unit-PASS freigegeben: die vom Owner beobachteten engen
Kreise vor dem Wingman-Takeoff sind nicht behoben oder positiv erklaert.
Die qualifizierte Fuel-Prognose und das Transit-AAR-Pending-Verhalten muessen
zunaechst die aufgezeichneten A5-4/A5-5-Daten bestehen. Danach sind vollstaendige
Build-/MIZ-Provenienz und die Departure-Aufklaerung erforderlich.

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


## A5-3 – Integrierter naechster Teststand (26.10.2026)

**Owner-Anweisung:** Keine weiteren isolierten Teiltests. In **einem** naechsten DCS-Acceptance-Lauf sind Racetrack-Marshalling, niedrigeres Initialprofil, zeitnahe MOOSE-Push-Freigabe, CAS-Anflug, AAR-/Resume, RTB und physische Rueckkehr gemeinsam zu pruefen. Der Owner hat die integrierte Umsetzung der zuvor besprochenen Racetrack-Adapter-Ergaenzung angewiesen; ausschliesslich diese A5-Testausnahme ist zusaetzlich autorisiert, keine produktive MOOSE-Patch-/Controller-Freigabe.

**Realer A5-1-DCS-Befund (26.10.2026; Owner-Logs `dcs(5).log`, `debrief(5).log`):** DCS 2.9.30.28738 MT. Drei MOOSE-AUFTRAG-Zuweisungen und drei Zwei-Flugzeug-Joins. A-10 `TWO_SHIP_JOINED` 20:01:33.900 (3479,6 m), F-16 20:04:49.320 (3157,9 m), F-15E 20:13:00.385 (853,2 m). Alle drei erhielten unmittelbar `DEPARTURE_HOLD_CLEARED`; die folgenden `FLIGHT_OBSERVER`-Events melden trotzdem `holding=true` bei `missionHoldingPresent=false`. Keine `MISSION_EXECUTE`, `ELEMENT_IN_AO`, `TWO_SHIP_IN_AO` oder `AAR_REFUELED` fuer CAS bestaetigt. Debrief dokumentiert entsprechende `*_FlagHold`-Werte 0. **A5-1 FAIL**: Der Join-Latch wurde gesetzt, aber der MOOSE-native Holding-Exit durch vorzeitige Clearing-Mutation verhindert. In der letzten F-16-Telemetrie (20:16:01) Lead fuelFraction 0,95397, Wingman 0,82923; Owner beobachtete dabei langen Nachbrennereinsatz. Fuel-Fraction beweist keinen spezifischen Nachbrennerzustand.

**A5-3 Quellimplementierung (eine gemeinsame Revision):**

1. Das CAS-`AUFTRAG`-Holding bleibt fuer die MOOSE-Queue/FSM erhalten. `joinedAt` wird nach 2-airborne / 2 NM dauerhaft gelatcht; der bestehende `AddConditionPush` prueft danach immer `true`. MOOSE `FLIGHTGROUP:Status` setzt **selbst** `flaghold=1` und `isHoldingAtHoldingPoint=false`. Ein passiver Observer setzt erst nach dieser Freigabe das einzeln genehmigte `mission.missionHoldingCoord=nil`, damit AAR-Route-Rebuilds kein Departure-Holding enthalten. Kein eigener `SetTask`, `TaskPush` oder `flaghold:Set`.
2. Weil das gepinnte `OPSGROUP:RouteToMission` fuer Departure-Holding intern `self.group:TaskOrbit(coord,alt,speed)` mit drei Argumenten aufruft, installiert der A5-Test **vor dem ersten COMMANDER-Request** einen auf die Identitaet genau dieser A5-Holding-Koordinate eingeschraenkten Konstruktor-Adapter an `CONTROLLABLE.TaskOrbit`. Er delegiert alle sonstigen Aufrufe unveraendert an die Originalfunktion; nur fuer eine gepruefte A5-CAS-Holding-Koordinate ergaenzt er den vierten **oeffentlichen MOOSE-`TaskOrbit`-Parameter** `CoordRaceTrack`. Damit erzeugt der Original-MOOSE-Code den DCS `RACE_TRACK`-Task. Kein zweiter AUFTRAG, keine Queue-Prioritaets-Race, kein direkter DCS-Controller. **Grenze:** Die Constructor-Methode wird testweise pro Mission-Skriptglobal erweitert; das ist kein bereits upstream akzeptierter oeffentlicher Holding-Hook und keine Produktionsfreigabe.
3. Beide Racetrack-Punkte werden vor dem Request ueber `COORDINATE:Translate` aus der vorhandenen AIRBASE-Koordinate berechnet. Distanz zum ersten Punkt 5 NM, 8 NM gerader Leg, Kandidatenwinkel `45,90,135,180,225,270,315,0` Grad **in der MOOSE-Coordinate-Plane**. An acht Richtungen werden Terrainhoehen entlang 0–13 NM in 1-NM-Schritten anhand `COORDINATE:GetLandHeight` gemessen; die niedrigste gefundene Hoehenobergrenze gewinnt. Diese **Sampling-Heuristik ist keine DCS-terrain-/ATC-validierte Flugroute** und ersetzt keine DCS-Abnahme der Raender, Kurven und Abflugpfade. Statischer Unterwert Bagram 8500 ft MSL, Kandahar 6500 ft MSL; resultierende Holding-Hoehe jeweils `max(floor, sampledPeakTerrainFt+2500ft)`. Der tatsaechliche Wert wird geloggt und kann bei unguenstigem Terrain hoeher liegen. Holdinggeschwindigkeiten Bagram 230 kt, Kandahar 195 kt. Zuordnung und echte Kinematik im DCS-Lauf bestaetigen. Kein garantiertes Nachbrennerverbot.
4. `DEPARTURE_RACETRACK_CONFIGURED` (Angle/Stand-off/Leg/Peak/Altitude/Speed/Koordinaten) und `DEPARTURE_RACETRACK_TASK_CREATED` (tatsaechlicher gezielter MOOSE-Task-Konstruktor) muessen fuer jeden der drei Requests auftreten. `DEPARTURE_RELEASE_DELAYED` ist der FAIL-Hinweis, falls die native Freigabe >45 s nach Join noch nicht gemeldet ist. Danach `DEPARTURE_HOLD_CLEARED` mit ReleaseFlag=1 und `FLIGHT_OBSERVER holding=false`. Nachweis tatsaechlicher Entfernung vom Sammelbereich sowie CAS-AO-Eintritt bleiben zusaetzlich notwendig.
5. AAR-Ausloeser/Trackfilter aus A4 bleiben ausschliesslich Testlogik, FuelLowThreshold 30 nur pro CAS-FLIGHTGROUP. AAR im Transit, AAR-Resume zum CAS-AO, CAS und sicherer Return sind zu pruefen; AAR nach MOOSE-RTB weiterhin explizites separates Lifecycle-Risiko, nicht automatisch bestanden.

**Vor der naechsten DCS-Abnahme:** Neuer A5-3-Build, echter Git-Commit + Bundle-/MIZ-/embedded-Moose-Hash; in der Owner-MIZ ausschliesslich das A5-Testbundle austauschen, keine parallelen A4/A5-Kopien. `BuilderVersion=OMW-FIXED-WING-CAS-RESPONSE-A5-3`. **Status SOURCE_IMPLEMENTED / STATIC_CHECKS_PENDING / DCS_PENDING**; die A5-1-Hashkette gilt ausschliesslich fuer den fehlgeschlagenen Erstlauf. Kein PASS vor positiver realer DCS-Evidenz.


## A5-4 – Verbindliche Sortie-/On-Station-Grenzen (27.10.2026)

**Owner-Beschluss (Chat nach A5-3-Abbruch):** Geplante Standby-/CAS-Zeit getrennt von der gesamten Flugzeit behandeln. Bagram-Jets haben eine eigenstaendige On-Station-Grenze, Kandahar-A-10 erhalten wegen >330 NM Transit laengere Gesamtsorties. Fuer A-10 regulär max. 8 h, 10 h absolute Ausnahmeobergrenze; ohne neue Owner-Ausnahme wird die Achtstundenplanung angewandt, nicht automatisch auf zehn Stunden ausgedehnt. Vier belegte AAR-Zyklen im A5-3-Lauf sind keine Erlaubnis zu unbegrenzter Missionsdauer.

**A5-4-Testparameter (vorgeschlagene operative Defaults des fuer diesen Branch freigegebenen Owner-Gates, noch nicht DCS-validiert):**

| Muster | Zielzeit tatsaechlich im CAS-AO | geplante Gesamtflugzeit | absolute Obergrenze |
|---|---:|---:|---:|
| F-16C Bagram | 150 min | 4 h | 5 h |
| F-15E Bagram | 180 min | 5 h | 6 h |
| A-10C II Kandahar | 240 min | 8 h | 10 h (nur Ausnahmedecke) |

Die beiden Uhren werden **nicht** gleichgesetzt: Der erste `OnAfterElementTakeoff` startet die monotone Sortieuhr via `timer.getTime()`; erst `TWO_SHIP_IN_AO` setzt `onStationAtS`. Standby-Racetracks sind noch nicht implementiert, daher gilt On-Station in A5-4 ausdruecklich nur fuer die **aktuelle CAS-AO**. Die geplante Gesamtflugzeit beinhaltet Start, Join, alle AAR, Transit, CAS, Rueckflug und Landung. Die absolute Obergrenze ist keine Garantie fuer rechtzeitiges physisches Landing ohne DCS-Verifikation.

**RTB-Vorhaltung:** Schon vor der geplanten Gesamtgrenze wird anhand der **aktuellen** MOOSE-Flugkoordinate und der DCS-AIRBASE-Koordinate eine Rueckkehrzeit berechnet: `max(60 min, distance/base-cruise-speed + 45 min approach/vectoring buffer)`. Diese konservative Entfernungsschaetzung ist keine Terrain-, ATC- oder DCS-Taxi-Garantie. Bei Erreichen der On-Station-Dauer oder `elapsed + estimatedReturn >= plannedLimit` wird einmalig `FLIGHTGROUP:RTB(homebase)` aufgerufen. Die zehnstuendige A-10-Grenze ist ein zusaetzlicher harter Schutz vor spaeteren Missionsverlaengerungen; laufende MOOSE-AAR wird normalerweise erst zu Ende gefuehrt, bevor RTB angefordert wird, **ausser** wenn die absolute Rueckkehrgrenze bereits erreicht ist. A5-4 darf niemals als Garantie betrachtet werden, dass ein kritisch betankendes Flugzeug dadurch sicher landet.

**Final-RTB-Latch:** Nach `SORTIE_FINAL_RTB_ORDERED` oder normalem MOOSE-/FuelLow-RTB blockiert der Adapter weitere selbst ausgelöste AAR-Aufrufe und den A-10-65%-Fruehtanktest. Keine parallele Routing-Engine, kein direkter DCS-Controller, keine AAR-Nachladung als Neustart der Sortieuhr. Die unveraenderte MOOSE-RTB-FSM uebernimmt die echte Flugausfuehrung.

**Verbindliche Folge-Acceptance im gemeinsamen DCS-Lauf:** `SORTIE_CLOCK_STARTED` nur einmal pro Two-Ship; `SORTIE_ON_STATION_STARTED` erst bei beiden Flugzeugen im AO; abgelaufener On-Station-/Sortie-Horizont erzeugt genau ein `SORTIE_FINAL_RTB_ORDERED`; anschliessend keine neue `AAR_SELECTED` und kein weiterer CAS-Execute fuer diesen Flight; DCS-Landung vor der jeweiligen absoluten Obergrenze nach realen Flugzeiten, sichere gemeinsame Rueckkehr, MOOSE-AIRWING/Legion-Asset-Lifecycle, AAR-Unterbrechung und Fehlerlogs pruefen. F-16/F-15E-AAR-Verfuegbarkeit separat beurteilen: Im A5-3-Lauf fanden beide keinen geeigneten Tanker und gingen vorzeitig RTB. **Status: SOURCE_IMPLEMENTED / STATIC_REVIEW_PENDING / DCS_PENDING.**

**A5-4 Prazisierung der tatsaechlichen AO-Zeit:** Die Time-on-Station-Grenze zaehlt ausschliesslich beobachtete Intervalle, in denen **beide** lebenden Luftfahrzeuge innerhalb der CAS-AO sind. Waerend AAR-Abwesenheit wird kein AO-Zeitkontingent verbraucht; die davon unabhaengige gesamte Sortieuhr laeuft jedoch unveraendert weiter. Der 15-s-Observer ist die zeitliche Aufloesung. Das erste volle AO-Eintreten setzt `onStationAtS`; `stationSeconds` summiert nur aufeinanderfolgende valide AO-Samples. Eine spaetere AAR-Rueckkehr setzt die stationierte Zeit **nicht** wieder auf null.


## A5-5 – aktueller integrierter Korrekturtest, DCS_PENDING

Dieser Abschnitt und der [Korrekturvertrag](../../../docs/moose/FIXED-WING-CAS-FUEL-RECOVERY-CORRECTION.md) ersetzen fuer A5-5 die obigen historischen A5-4-Fuel-/Final-RTB-Sperren. Bedingte Owner-Freigabe 28.10.2026 nach gezielter Quellen-/Web-/Demo-Pruefung. Builder-Version `OMW-FIXED-WING-CAS-RESPONSE-A5-5`. Keine bisherige Laufkopie wird als A5-5 umetikettiert.

### Quellen und Preflight

- Gemeinsame Module `scripts/air-operations/OMW_FixedWingCasFuelPolicy.lua`, `OMW_FixedWingCasProfiles.lua`, `OMW_FixedWingCasRecovery.lua`; Harness bleibt Trigger/Observer/Komposition. Der Builder bettet die Module lexikalisch ein; es ist keine zusaetzliche MIZ-Script-Reihenfolge erforderlich.
- 23 Vertrags-/Policytests unter echter Lua 5.1; drei Module, Harness und komponierter Quelltext syntaxgeprueft. Test-Doubles belegen API-Anforderungsreihenfolge und Guards, keine DCS-Flugphysik. CI erhaelt A5-5 mit echtem PowerShell-Build; CI-/Owner-Build-Ergebnis separat dokumentieren.
- Vor MIZ-/DCS-Schritten muss der Owner den publizierten Commit lokal pullen, den PowerShell-Builder ausfuehren und reale Konsolenausgabe mit Commit, BuilderVersion und SHA256 zurueckgeben. Kein konstruierter Bundle-Hash. Danach die tatsaechliche Testkopie und eingebetteten Dateien read-only pruefen.
- MOOSE unveraendert 2.9.18 / `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, SHA256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`. Source-MIZ bleibt unveraendert; kein automatischer MIZ-Umbau.

### Ein gemeinsamer End-to-End-Lauf

1. Alle drei echten COMMANDER/AIRWING/AUFTRAG-Two-Ships rekrutiert; sechs individuelle Takeoffs. Bagram westlicher und Kandahar nordwestlicher Departure-Kandidat mit gesampelter Terrainmarge; tatsächlichen Zubringer, Turns und Racetrack visuell und anhand Position/AGL pruefen. Konfiguration/Task-Konstruktion allein ist kein Geometrie-PASS.
2. Zwei Elemente tatsaechlich airborne und Join bestaetigt; nativer Holding-Flag-Release zuerst, einmaliges Holding-Clear danach. Afterburner-Verbot an Mission und Flight nur bis diesem Abschluss, danach `DEPARTURE_AFTERBURNER_RESTRICTION_RELEASED`. Wirkung, Wingman-Joinverbrauch und aktuelle Separation auswerten; keine Behauptung ueber tatsaechliche Triebwerksstellung nur anhand Fuel.
3. Weiterflug-/Recovery-Budget je Element: kg, Verbrauchsrate, Trip-/Allowance-/Margin getrennt. Schlechtestes Element entscheidet. Joker/Bingo vor ungesicherter Home-Marge, keine alleinige 30-%-Entscheidung. Beide aktuelle Airborne-/AO-Zustaende pruefen; `MISSION_EXECUTE` ist kein Nachweis fuer beide im AO. Keine reine Transitzeit aus der alten F-15E-Differenz ableiten.
4. Falls benoetigt native AAR an aktivem kompatiblem Tanker mit gepruefter Zugangs-/Zeit-/Offload-Schaetzung. KRUSTY ist fuer A-10 erlaubt; keine Bedingung Tanker naeher als Home. Reale Tankerwahl, sechs Positionsspuren, Formation und individuelle Fuel-Zunahme pruefen. Zwei-Ship-Aufenthaltszeit stoppt waehrend AAR, Sortieuhr laeuft weiter. CAS-Resume ohne Departure-Reorbit nur solange keine finale Recovery besteht.
5. Bei Endabsicht getrennt `FINAL_RECOVERY_INTENT`, `CAS_CLOSURE_REQUESTED`, `MOOSE_RTB_REQUESTED` und bestaetigtes `MOOSE_RTB`. Keine 17-minuetige unbemerkte RTB-Anforderungswartezeit; fehlender Uebergang nach zwei Observer-Intervallen wird FAIL/STOP. CAS darf nach Final-Absicht nicht neu starten.
6. Safety-AAR bleibt auch nach finaler Absicht oder begonnenem RTB moeglich. Ein realer Post-RTB-AAR-Fall muss die streng begrenzte `RECOVERY_AAR_CURRBASE_RESET`-Ausnahme und anschliessendes neues MOOSE-RTB belegen. Wird dieser Pfad im Lauf nicht benoetigt, bleibt gerade dieser Teil DCS_UNPROVEN; kein pauschaler PASS durch den Lua-Test.
7. Sechs individuelle Landungen an der vorgesehenen Base und je Flight exaktes `EXACT_ASSET_RETURNED` (passende `asset.flightgroup`, zwei Home-Landungen, keine vorherigen Fehler). MOOSE-Landing/Holding/Terrain tatsaechlich pruefen. Landung, MissionDone, Despawn oder historischer Airborne-Zaehler sind jeweils kein Ersatz fuer den vollstaendigen Return. Keine vorzeitige strategische Recredit-Annahme.

### Fruehe FAIL-/Stop-Kriterien

`SAFETY_FAIL_STOP` wird sichtbar mit MESSAGE gemeldet: ungueltige/ungesicherte Recovery-/AAR-Marge, verlorener ausgewaehlter Tanker, fehlender RTB-Uebergang, fehlendes/verlorenes Element vor Landung, Landung nach geplanter Sortiegrenze oder drohendes absolutes Return-Limit. Auch ungeeignete Departure-/Recovery-Geometrie, gefaehrliche Trennung, unerwartetes langes Holding oder Sinkflug ins Terrain sind sofort FAIL; kein stundenlanges Weiterlaufen zur erzwungenen Verlustbestaetigung. Die Diagnose deaktiviert keinen weiter benoetigten Recovery-Observer und despawnt keine Gruppe.

PASS ist erst nach vollstaendiger realer Provenienz und Owner-Auswertung moeglich. Nicht ausgeloeste AAR-/Recovery-AAR-Pfade bleiben einzeln offen. AAR-7 ist keine Abnahme dieses Receiver-Lifecycles. Nach normalem Asset-Return entstehendes Cleanup ist kein neuer Flugverlust.

