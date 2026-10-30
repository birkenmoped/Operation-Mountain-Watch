---
document_id: OMW-MOOSE-FIXED-WING-CAS-FUEL-RECOVERY-CORRECTION
status: DRAFT
document_class: CORRECTION_IMPLEMENTATION_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - owner-approved branch-local A5-5 correction scope and source implementation
not_authoritative_for:
  - DCS-validated receiver recovery or a historical flight procedure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
implementation_status: A5_5_RUNTIME_FAIL_A5_6_SOURCE_CORRECTED_DCS_BLOCKED
---

# Fixed-Wing CAS – konsolidierter Fuel-/Recovery-Korrekturvertrag

**Aktuell 30.10.2026: A5-5 ist Runtime FAIL. A5-6 enthaelt eine Source-Korrektur der Fuel-Regression und zusaetzliche Departure-Evidenz; DCS-Freigabe bleibt BLOCKED.** Historische A5-5-Aussagen unten sind kein aktueller PASS. Befunde und Grenzen: [A5-5-Ergebnis](../../mission/tests/fixed-wing-cas-response/results/2026-10-30-acceptance-5-5-premature-recovery-fail.md).

## A5-6: Regression korrigieren, Departure nicht als geloest ausgeben

Lifecycle-Inheritance: dieselben Module und MOOSE-FSMs aus §2; gleiche Ressourcenhoheit,
gleiche physische Two-Ships, gleicher Return-/Recovery-AAR-Vertrag. Geaendert werden nur
Receiver-Prognose/Entscheidungsgrenze und passive Diagnostik. Keine neue Native-DCS- oder
Per-Unit-Flugsteuerung, kein weiterer Scheduler, keine Aenderung an Moose.lua.

- Langfristige Verbrauchsrate: A5-4-Referenz als ausdruecklich geloggte Schaetzung, nicht als Flughandbuchwert. Eine beobachtete Rate darf sie erst nach mindestens 120 s zusammenhaengend qualifiziertem Level-Cruise anheben. Qualifizierung: Hoehe innerhalb 1000 ft der Profil-Reiseflughoehe, vertikale Aenderung maximal 500 ft/min, TAS-Aenderung maximal 20 kt/min und Messabstand maximal zwei Observer-Intervalle. Das sind pruefbare Testfilter, keine DCS-abgenommenen Performanceparameter. Bei Phasenwechsel endet das Messfenster; eine bereits belegte Cruise-Rate bleibt konservativ erhalten. Auch diese Schaetzung beweist keine sichere physische Rueckroute.
- Aktueller Fuelverbrauch aller Phasen reduziert weiterhin den gemessenen Vorrat. Join-/Steigflugverbrauch wird nicht ueber die gesamte Reservezeit extrapoliert. Die genehmigten 2700 s bleiben unveraendert.
- Eine negative Bilanz Position -> AO -> Home ohne zwischenzeitliche AAR loest bei weiterhin positiver Home-Marge nicht mehr automatisch CAS-Abbruch aus. Ein erreichbarer Tanker kann weiterhin sofort ueber MOOSE angefordert werden. Sonst `TRANSIT_AAR_PENDING` und Neubeurteilung im vorhandenen Takt; es wird weder ein spaeter verfuegbarer Tanker behauptet noch Fuel reserviert. Spaetestens am unveraenderten Home-Entscheidungspunkt wird RTB angefordert. Ungueltige Routen bleiben Fehler, kein Weiterflug aufgrund fehlender Daten.
- Jede Tankeroption erhaelt einen konkreten, bei Aenderung protokollierten Ablehnungsgrund: Runtime/On-Station, Kompatibilitaet, Zugangsroute/-fuel, Station-Zeitfenster, Offload und Rueckkehr nach AAR.
- Missing-Element-Diagnostik prueft lebende Elemente getrennt von airborne. Ein lebendes Flugzeug beim Aufsetzen ist nicht verloren. Exakte Home-Landungen und Asset-Return bleiben erforderlich.
- Racetrack-Adapter prueft die wirklich zurueckgegebene Tasktabelle auf Orbit, Race-Track und point2. Der Marker kennzeichnet ausdruecklich CONSTRUCTED_TASK_NOT_DCS_EXECUTION. `GetTaskCurrent`, `GetWaypointCurrent` und `GetState` liefern passive MOOSE-Queue-/Waypoint-Evidenz, keinen behaupteten DCS-Controllerdump.

**Departure-Blocker:** In der gepinnten Moose.lua fuehrt `OPSGROUP:_QueueUpdate` (ca. 225404) die Flight-Taskqueue nur bei `IsAirborne()` aus; `FLIGHTGROUP:IsAirborne` (203939) prueft den Gruppen-FSM-Zustand. `OPSGROUP:_UpdateStatus` (232024 ff.) setzt den gemeinsamen Airborne-Uebergang nach Elementzustandspruefung. Das belegt eine relevante Grenze vor dem Wingman-Takeoff, aber noch NICHT die Ursache der beobachteten engen Kreise. Ein Eingriff nur am Mission-Holding-Konstruktor beweist keine Steuerung dieser fruehen Phase. Die offizielle [FlightGroup-Dokumentation](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.FlightGroup.html) bestaetigt die verwendeten lesenden Methoden; der gepinnte Source bleibt massgeblich. Kein neuer DCS-Lauf wird hier als freigegeben erklaert. Die fruehe Flugfuehrung muss erst belastbar aufgeloest werden; eine Per-Unit-Controller-Loesung ist nicht durch die bestehende TaskOrbit-Ausnahme genehmigt.


## 1. Ergebnis und Freigabegrenze

A5-4 bleibt fuer den [dokumentierten Lauf](../../mission/tests/fixed-wing-cas-response/results/2026-10-28-acceptance-5-4-loss-reconstruction.md) FAIL. A5-5 ist als gemeinsamer Source-Kandidat implementiert und mit Lua 5.1 geprueft; kein DCS-PASS, kein echter Owner-Build und keine neue MIZ werden hier behauptet.

Owner-Freigabe im Chat am 28.10.2026: „wenn es keine MOOSE first - Wege in der MOOSE Dokumentation auf Github, Webseite und in den Beispielmissionen fuer unsere Probleme gibt, dann gebe ich das hier frei!“ Sie bezieht sich auf die zuvor konkret beantragte minimale Fuel-Policy, den 45-Minuten-Fuel-Zuschlag als Testparameter und die begrenzte Post-RTB-AAR-currbase-Ausnahme. Die gezielte Pruefung in §3 fand fuer diese beiden Policy-/Handoff-Luecken keinen passenden oeffentlichen Weg. Das ist keine Behauptung ueber alle denkbaren MOOSE-Erweiterungen. Oeffentliche Methoden werden fuer alle tatsaechlichen Flugoperationen weiterverwendet.

## 2. Lifecycle-Inheritance vor Implementierung

| Feld | Wiederverwendung / Grenze |
|---|---|
| inherited_contract | `ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md` §§16–20; keine Uebernahme der AH-64-Geometrie |
| accepted_source_paths | bestehende AirOps-Bootstraps fuer Bagram/Kandahar; `scripts/air-operations/OMW_AAR_Controller.lua`, `OMW_AirOps_AAR_Bootstrap.lua`; MOOSE COMMANDER/LEGION/AIRWING/SQUADRON/AUFTRAG/FLIGHTGROUP |
| evidence | AAR-7: `7d55a1383cbf3f52ea776d7354b37dbe5a920466`, exakte Provenienz in `docs/89-aar-acceptance-7-finalization.md`; A9 nur Rotary-Wing-CAS; A4/A5 Fixed-Wing bleiben negative/partielle Evidenz |
| invariants | ein physisches Two-Ship; MOOSE besitzt Task/FSM/Route/RTB/Landing/Return; kein strategischer Recredit vor bestaetigtem Ereignis; Fuel-Abbruch ist kein normaler CAS-Erfolg |
| reuse_mode | DIRECT_REUSE fuer Tanker-/AirOps-Lifecycle; MINIMAL_ADAPTER fuer belegte Receiver-Policy-/Handoff-Luecke, bedingt freigegeben am 28.10.2026 |
| harness_role | Trigger, individuelle Telemetrie, Event-/Asset-Korrelation, Assertions; keine Fuel-/Recovery-FSM im Harness |
| changed_boundary | Fixed-Wing-Receiver-Entscheidung und freigegebener Post-RTB-AAR-Handoff; kein Neubau des Tankercontrollers |
| owner_approval | minimale Fuel-Policy, 45-Minuten-Fuel-Testreserve und begrenzte currbase-Ausnahme nach gezielter Negativpruefung freigegeben |
| revalidation_scope | alle drei Two-Ships: Departure/Join, Fuel-Entscheidung, AAR/Resume, CAS-Ende, Recovery-AAR, sechs Landungen und exakter Asset-Return |

## 3. MOOSE-first – Dokumentation, Source und Beispielgrenzen

Geprueft: bereitgestellte und MIZ-eingebettete MOOSE 2.9.18, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, SHA256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`.

Offizielle Dokumentation: [Ops.FlightGroup](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.FlightGroup.html), [Ops.Auftrag](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html), [Wrapper.Controllable](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Controllable.html). Online-Dokumentation ist nicht automatisch versionsgleich; die folgenden Aussagen beruhen auf dem gepinnten Source.

| Schnittstelle / Sourcezeilen in der gepinnten Datei | Quellenbefund | Konsequenz |
|---|---|---|
| `SetFuelLowThreshold`, ca. 203814; Fuel-State-Check ca. 204528 | oeffentliche veraenderbare Prozentgrenze gegen `GetFuelMin`; kein streckenabhaengiges Bingo-Modell | Schwelle allein beweist keine Rueckkehrreserve |
| Diagnoseblock ca. 204439–204486 | Restflugzeit aus momentaner Fuel-Differenz nur bei `verbose>=4`; lokale Variablen, keine Return-Entscheidung | kein vorhandener oeffentlicher Recovery-Budget-Service; Diagnose nicht als Sicherheitsmodell ausgeben |
| `UNIT:GetFuel`, ca. 61557 | Fraktion relativ zum internen Tankvorrat; kann mit Zusatztanks >1 sein | keine Prozent-vom-Gesamttank-Verwechslung |
| `UNIT:GetCurrentFuelKgs`, `GetFuelMassMax`, ca. 62425 | oeffentliche Massen-/Bezugsdaten | individuelle Bilanz in kg, Prozent nur Darstellung; keine Fuel-Mutation |
| `FLIGHTGROUP:Refuel` / `onafterRefuel`, ca. 206366 | pausiert Mission, routet zur Koordinate, erzeugt gruppenweiten DCS-Refuel-Task | kein expliziter Tanker-Target-Lock; keine einzelne Wingman-Route |
| `onafterRefueled`, ca. 206404; `_CheckGroupDone`, ca. 205750 | MOOSE prueft danach u.a. pausierte Missionen und kann unpausieren | CAS-Endabsicht muss alte CAS-Fortsetzung verhindern, ohne AAR zu sperren |
| `onbeforeRTB`, ca. 205892 | kann bei FuelGood und verbleibenden Tasks RTB zurueckstellen | Anfrage und bestaetigtes RTB getrennt erfassen; kein Erfolg allein durch Log-Latch |
| `onafterRTB`, ca. 205995 | `CancelAllMissions`, danach eigener Landing-Pfad | Tasks kontrolliert ueber oeffentliche Missions-APIs schliessen; kein eigener Flugcontroller |
| `_LandAtAirbase`, ca. 206090; `onbeforeRTB`, ca. 205913 | setzt `currbase` bereits beim RTB; spaeteres RTB zur gleichen Base kann deshalb abgewiesen werden | wichtige neue Post-RTB-AAR-Luecke, siehe §5 |
| `ClearToLand`, ca. 204118 | wirkt nur auf bestehenden Holding-Zustand/Flag | kein Ersatz fuer die durch Refuel ersetzte Recovery-Route |
| `SetProhibitAfterburner`, ca. 203626 / 178624 | oeffentliche gruppen-/missionsbezogene Konfiguration vorhanden | kein eigener Throttle-/Wingman-Controller erforderlich |
| `TaskOrbit`, ca. 52571 | vierter Parameter erzeugt RACE_TRACK; x/z werden zu DCS x/y | vorhandene eng begrenzte A5-Ausnahme beibehalten, keine neue globale Erweiterung |

Offizielle Demo geprueft: [AID-A2G-363 CAS Airplanes Patrol Refuel](https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AI/AI_A2G_Dispatcher/AID-A2G-363%20-%20CAS%20Airplanes%20Patrol%20Refuel/AID-A2G-363%20-%20CAS%20Airplanes%20Patrol%20Refuel.lua), Blob `19a13b20a99f36bed73676640c65f504243b2e51`. Sie verwendet den aelteren AI_A2G_DISPATCHER und eine feste Fuel-Grenze. Sie belegt keinen COMMANDER/AIRWING-Two-Ship-Handoff, keine variable Bingo-Bilanz und keine Recovery-AAR nach RTB. Ein Wechsel auf diesen Dispatcher waere kein minimaler Fix.

Zusaetzlich gezielt geprueft: offizielle MOOSE_MISSIONS-OPS-Demos auf `develop`, Commit `e355b0542adfd91d6d93170b9aca1c3fb30eef4c` (master enthaelt diese modernen Beispiele nicht).

| Pfad unter MOOSE_MISSIONS | Blob | Befund |
|---|---|---|
| `Ops/Flightgroup/Flightgroup - 060 - Refuel/Flightgroup - 060 - Refuel.lua` | `d2667db1cf9b153941c827b3d2aeaa4a3771e607` | oeffentliches Refuel und Refueled, keine variable Reserve oder Same-base-Post-RTB-Recovery |
| Flightgroup Destination 020 | `70de6eefaa48fef01a5022b471e6f5ac068cf3a2` | SetDestinationbase, kein Reset eines begonnenen RTB |
| Flightgroup Divert 031 | `13a95ab8bf62cbdad39ab6bf5d54fbd63aad26ad` | RTB zu anderer Base, kein gleicher Recovery-Ort nach AAR |
| Auftrag CAS 017 | `b53afb5bf5c253323f8cd7056eda94af3ebff005` | NewCAS/AddMission; kein Receiver-Budget |
| Commander Bombing Airwings 020 | `8847f91b635bf9d4ea2996d598e7f5198bff33cb` | native Rekrutierung; kein benoetigter Fuel-/Recovery-Handoff |

Die Beispiele werden nicht als versionsgleicher Ersatz fuer den gepinnten Source gewertet. Ergebnis: die passenden oeffentlichen Methoden werden genutzt; fuer die abgegrenzten beiden Luecken wurde in dieser gezielten Pruefung keine ausreichende Alternative gefunden.

## 4. Implementierter minimaler Fuel-Policy-Adapter

Drei gemeinsame Module unter `scripts/air-operations/`: `OMW_FixedWingCasFuelPolicy.lua` rechnet reine Fuel-Bilanzen; `OMW_FixedWingCasProfiles.lua` liefert ausdrueckliche Testprofile, MOOSE-Geometrie und Tankerkapazitaetspruefung; `OMW_FixedWingCasRecovery.lua` fordert oeffentliche Missionsaktionen an und korreliert Ereignisse. Der Harness komponiert sie und beobachtet im bestehenden 15-s-Takt. Keine zweite Flug-FSM, kein eigener Controller, kein weiterer Scheduler.

Je tatsaechlich fliegendem Element: `marginKg = availableKg - routeTimeS * rateKgS - 2700 * rateKgS`. Massgeblich ist die kleinste individuelle Marge. Werte >100 % bleiben erhalten. `GetFuelMassMax()` liefert im gepinnten Source entgegen der missverstaendlichen Return-Beschreibung als ZWEITEN Wert den internen Referenzvorrat aus dem DCS-Descriptor. Keine Fuel-Mutation.

Verbrauch ist das Maximum aus dem je Typ belegten A5-4-Referenzverbrauch und dem individuellen gleitenden 300-s-Verbrauch (mindestens 60 s Beobachtung nach Join, ausserhalb AAR). Refuel, fehlende/ungueltige Daten und Bodenphasen werden nicht als sparsamer Verbrauch gewertet. Referenzen: F-16 Wingman 57906–59136 s; F-15E Wingman 63336–64836 s; A-10 Lead 76972–81517 s. Alle Endproben liegen vor Ejection beziehungsweise Landung. Das sind konservative Testkalibrierungen aus genau diesem fehlgeschlagenen Lauf, keine universellen Leistungsdaten.

Rueckweg: individuelle Entfernung, profilierte Cruise-TAS, Gegenwindprojektion ohne Rueckenwindbonus, zweimal Airbase-Zonenradius sowie 20 NM bei 170 kt als horizontale Schranke fuer den gepinnten MOOSE-Anflug. Die **genehmigten 45 Minuten zusaetzlicher Fuel-Bedarf** werden einmal aufgeschlagen und decken weiteren Anflug-/Holding-/Landungsbedarf ab; keine zweite versteckte 45-Minuten-Reserve. Dies ist ein A5-Testparameter, keine historische Vorschrift oder Garantie fuer einen beliebigen Divert. Weiterflug zur AO wird als eigene Kette Position → AO → Home beurteilt.

AAR-Zugang: individuelle Entfernung plus 35-NM-Bewegungsspielraum des Tankertracks, Wind und gesampelte Terrainmarge entlang des Zugangskorridors. Verwendet werden nur aktive kompatible Tanker mit geschaetzter Aufnahmekapazitaet nach Eigenverbrauch/FuelLow-Schutz und ausreichendem Restfenster bis `nextPlannedHandoverAt`. KRUSTY ist fuer A-10 enthalten; Tanker duerfen weiter entfernt als Home sein. Zusaetzlich muss die Rueckkehr vom Tanker nach Auffuellen der internen Tanks samt Reserve fuel-seitig unterstuetzt sein; eine bloss erreichbare Tankstelle ohne anschliessend tragfaehigen Rueckweg wird verworfen. Die Kapazitaetsschaetzung beruecksichtigt auch Receiver-Verbrauch waehrend des Servicezuschlags. Reserve-Tanker werden dadurch nicht neu beauftragt. Die 45 Minuten dienen hier als konservativer Zugang-/Servicezuschlag; kein gesonderter erfundener Servicezeitwert.

Vor Bingo wird ein Joker aus aktueller Rueckkehrmarge und Zugangsdauer zum geeigneten Tanker gebildet: verbleibende Margenzeit <= Tankerzugangszeit + zwei Beobachtungsintervalle. Ohne geeigneten Tanker fuehrt eine noch positive Rueckkehrmarge von hoechstens zwei Beobachtungsintervallen zur CAS-Schliessung und RTB. Ungesicherte Home-/AAR-Marge ist FAIL/STOP, kein sicherer RTB-PASS. Laufende physische Recovery wird trotzdem weiter beobachtet. Die 30-%-MOOSE-Schwelle ist nur noch ein zusaetzliches FuelLow-Ereignis; native FuelCritical-Sicherheit bleibt bestehen.

Begrenzungen: keine Reservierung von Tanker-Offload gegen parallele Receiver, kein DCS-Tanker-Target-Lock, keine physikalisch bewiesene Zugangszeit. DCS kann einen anderen Tanker waehlen. Native MOOSE-RTB-Geometrie und zufaelliges Holding sind keine gepruefte Terrainroute; der Zeit-/Fuel-Zuschlag beweist keine Hindernisfreiheit. Ungueltige oder nicht belegte Route sperrt weitere CAS-Bindung und wird als FAIL ausgewiesen. Diese Grenzen sind im integrierten Test zu beurteilen.

## 5. Post-RTB-AAR: freigegebene, begrenzte Ausnahme

Im gepinnten Source setzt `_LandAtAirbase` `self.currbase=airbase`, obwohl die Gruppe noch fliegt. `Refuel` ersetzt die physische Route; `Refueled` allein baut nicht garantiert den vorherigen Landing-Pfad wieder auf. `onbeforeRTB` und `onbeforeLandAtAirbase` weisen denselben Zielflugplatz bei passendem `currbase` ab. `_CheckGroupDone` prueft ebenfalls dieses Feld. Ein weiterer unbedingter `RTB(home)`-Aufruf ist deshalb kein belastbarer Post-AAR-Fix.

Kein oeffentlicher Setter zum gezielten Zuruecksetzen dieses Zwischenzustands wurde im gepinnten FLIGHTGROUP-API gefunden. `ClearToLand` rekonstruiert keine ersetzte Route. Ein kuenstliches `Airborne`-Ereignis oder ein neues Landungsrouting wird nicht als Scheinloesung eingesetzt.

**Nach Quellenpruefung bedingt freigegebene und implementierte Minimal-Ausnahme:** einmal pro tatsaechlich beendetem Recovery-AAR-Zyklus ausschliesslich `flight.currbase=nil`, unmittelbar vor dem erneuten oeffentlichen `flight:RTB(destination)`.

Zwingende Guards:

1. Dieselbe physische MOOSE-FLIGHTGROUP hat vorher ein echtes RTB-Ereignis und danach ein echtes Refuel-/Refueled-Ereignis durchlaufen.
2. Recovery-Absicht ist final; es existiert kein fortzusetzender CAS-Auftrag.
3. Die ueberlebenden Elemente sind tatsaechlich airborne; kein bestaetigter Land-/Asset-Return-Zustand wird geloescht.
4. Der gespeicherte `currbase` entspricht genau dem weiter gueltigen Recovery-Ziel; homebase, destbase, legion, cohort, Aufgaben-/Ressourcen-IDs und alle anderen MOOSE-Interna bleiben unangetastet.
5. Pro Zyklus idempotent protokollieren; MOOSE fuehrt danach RTB/Landing/Return selbst aus. Keine direkte `_LandAtAirbase`-Nutzung, kein Moose.lua-Patch.

Die Freigabe vom 28.10.2026 betrifft diese zusaetzliche Feldmutation gesondert; die fruehere Departure-Ausnahme wird dafuer nicht umgedeutet. Falls ein nachweislich geeigneter oeffentlicher Weg gefunden wird, entfaellt die interne Ausnahme; eine solche Alternative muss denselben Lifecycle erhalten.

## 6. Weitere Aenderungen im selben Korrektursatz

- Departure-Staging pro Basis fest konfigurieren und anhand vorhandener AIP-/Mission-/Terrain-Evidenz begruenden. Die bisherige Acht-Richtungs-Minimum-Heuristik entfaellt. Keine jetzt erfundenen safe coordinates, kein pauschaler 5-/13-NM-Track fuer beide Basen.
- Oeffentliche Afterburner-Restriktion fuer Departure/Join an Mission und Flight; Wiederfreigabe ueber beide oeffentlichen SetAllowAfterburner-Methoden erst nach bestaetigtem nativen Holding-Release und dessen einmaliger Bereinigung. DCS muss die tatsaechliche Wirkung und Formation bestaetigen. Fuel-Logs allein beweisen keinen Nachbrennerzustand.
- CAS-Endabsicht, Mission-Closure-Anfrage und bestaetigtes RTB getrennt loggen. Aktiven CAS kontrolliert ueber bestehende oeffentliche MOOSE-Cancel-/Done-Ereignisse schliessen, statt einen RTB-Request bei laufendem Task als vollzogen zu behandeln.
- Tankerzugang mit individueller Fuel-/Zeitmarge bewerten; `distance < homeDistance` nicht als pauschale Sicherheitsbedingung verwenden. A-10-Kandidaten schliessen KRUSTY ein. Aktiver kompatibler Tanker ist noch kein Beweis fuer erreichbare Aufnahme-/Fuel-/Zeitkapazitaet. Reserve-Tracks nur ueber bestehenden MissionDemand-Vertrag, kein automatisches fremdes Reserve-Tanker-Tasking.
- CAS-Ausfuehrung, AO-/Standby-Geometrie und echte Two-Ship-Aufenthaltszeit trennen. Die F-15E-121-Minuten-Differenz ist kein belegter reiner Transit. Der 5-NM-Beobachtungskreis wird nicht ohne Geometrienachweis vergroessert, um ein PASS zu erzeugen.
- Individuelle Position/AGL/MSL/Fuel/Geschwindigkeit und echte aktuelle Airborne-/Land-Zustaende beobachten; historische Takeoff-Zaehler entsprechend benennen. Boolean `false` nicht durch Lua-`and/or` zu `unknown` umdeuten.
- `OnAfterElementLanded` plus exact `LegionAssetReturned` mit Flight-/Asset-Identitaet korrelieren. Spaeteres Despawn nach Return ist Cleanup, kein neuer Verlust.

## 7. Pruefung und ein integrierter DCS-Test

Vor Build: genehmigte Grenzen dokumentieren; Lua-Syntax; meaningful Policy-Tests fuer unterschiedliche Elementverbraeuche, Route/Reserve, Betankung, ungueltige Daten und unveraenderliche Sortieuhr; Source-Replay der realen A5-4-Sicherheitsverletzungen; voller Diff; Dokumentvalidator. Replay ist keine DCS-Validierung und beweist keine neue Flugtrajektorie.

Erst danach neuer Builder/Remote-Commit, echter Owner-Build und SHA256-Kette. Ein gemeinsamer DCS-Lauf prueft alle drei Two-Ships. Fruehe FAIL-/Stop-Kriterien: ungesicherte Fuel-to-land-/Tanker-Marge, ungeeigneter Departure-Pfad, schwere AAR-Trennung, keine echte Closure-/RTB-Bestaetigung oder drohender Verlust. Das FAIL stoppt keine notwendige Recovery-Beobachtung.

PASS erfordert sechs individuelle Landungen beziehungsweise separat dokumentierten genehmigten Divert, exakte Asset-Rueckgaben, keine neue CAS-Fortsetzung nach Final-Recovery, erlaubte Safety-AAR und vollstaendige reale Provenienz. Vor dieser Owner-Acceptance bleibt A5-5 DCS_PENDING.

Pruefstand: 23 Vertrags-/Policytests unter echter Lua 5.1, Syntax der drei Module und des Harness sowie der lexikalisch komponierten Quellen; Smoke-Ausfuehrung dieser Komposition mit nicht ausfuehrendem Scheduler-Double. Kein DCS-Verhalten wird simuliert oder als bestaetigt ausgegeben. Der A5-5-CI-Job baut zusaetzlich mit dem echten PowerShell-Builder; dessen erfolgreicher Lauf und der reale Owner-Build sind separat einzuholen. Dokumentvalidator und Diff-Whitespace-Pruefung gehoeren zum Pre-Publish-Review.

## 8. Konkrete Testprofile und Quellenbegrenzung

| Profil | Cruise KTAS / CAS KIAS / Departure KTAS | AO / planned / absolute |
|---|---|---|
| F-16 | 450 / 250 / 230 | 150 min / 4 h / 5 h |
| F-15E | 460 / 250 / 230 | 180 min / 5 h / 6 h |
| A-10 | 260 / 180 / 195 | 240 min / 8 h / 10 h |

Die CAS-IAS ist gegenueber A5-4 reduziert; die Wirkung auf die tatsaechliche AO-Geometrie ist offen. Der bestehende 5-NM-Beobachtungskreis wird nicht vergroessert. AO-Zeit zaehlt nur beide aktuell fliegenden Elemente im Kreis, ausserhalb AAR und vor Final-Recovery; die Sortieuhr ab erstem Takeoff wird nie zurueckgesetzt.

Departure-Kandidaten: Bagram 3 NM westlich der Base, 4-NM-Nord/Sued-Achse, mindestens 8500 ft MSL; Kandahar 3 NM nordwestlich, 3-NM-Achse Richtung AO, mindestens 6500 ft MSL. Terrain-Samples auf Zubringer und im 2-NM-Umfeld der Achse koennen die Hoehe anheben (2500 ft Sample-Marge). Es ist kein Suchalgorithmus fuer die niedrigste Richtung und kein ATC-/SID-Nachweis.

Read-only herangezogen: bereitgestellte Bagram-Karte ist nur ein DCS-Rasterplan. Afghanistan-AIP 2008: PDF-Seite 229 / AD2.1-57, OAIX 2.20.5 (RW03 links/RW21 rechts); PDF-Seite 209 / AD2.1-37, OAKN 2.20.3 (Range suedlich/suedoestlich und Einschraenkungen fuer Kurven). Das stuetzt die Wahl der Basisseite, belegt aber weder exakte Staging-Koordinaten noch einen fuer 2011 zugelassenen Racetrack. Tatsächliche Abflug-/Turn-/Holding-Terrainfreiheit bleibt DCS_PENDING; ungeeignete Geometrie bedeutet fruehes FAIL/STOP.
