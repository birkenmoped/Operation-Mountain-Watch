---
document_id: OMW-AIR-FIXED-WING-CAS-COVERAGE-GROUND-ALERT
status: PLANNED
document_class: OWNER_DECISION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local owner-approved fixed-wing CAS coverage and ground-alert planning
  - separation of airborne CAS presence and ground CAS readiness
  - fixed-wing CAS type roles and 2-ship Bagram alert objective
not_authoritative_for:
  - validated DCS schedule, response time, patrol geometry, or AI behavior
  - changes to existing AAR, CAS lifecycle, payload, parking, or resource authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
owner_approval: 2026-10-16; ausdrücklich bestätigt: 2-ship Ground Alert aus Bagram und zulässige Airborne-CAS-Lücken
---

# Fixed-Wing CAS – geplante Deckung, Ground Alert und taktische Rollen

## 1. Geltungs- und Entscheidungsgrenze

Dieses Dokument hält die im Gespräch vom 16.10.2026 bestätigte fachliche **OMW-Entscheidung zur CAS-Planungsrichtung** fest. Es ist auf diesem Arbeitsbranch `PLANNED`, bis die Integration nach `main` gemäß Governance erfolgt. Die Betreiberentscheidung ist dokumentiert, aber weder eine technische Implementierung noch DCS-Validation wird behauptet.

Bereits verbindliche Quellen auf `main`:
- [Governance](00-project-governance.md) und [MOOSE-first](26-moose-first-development-policy.md).
- [ATO-Foundation](88-air-tasking-plan-foundation.md): strukturierte Tasking-Ebene, keine zweite Ausführungsengine, Ground Alert als eigener Anwendungsfall.
- [Air-C2-/ATO-Referenz](54-air-tasking-airspace-control-cas-requests-and-mission-data.md).
- [Aktive Luft-ORBAT](19-active-air-orbat-decisions.md).
- [AAR-Baseline](29-isaf-2009-2013-air-to-air-refueling.md) und [AAR-Acceptance-7-Finalisierung](89-aar-acceptance-7-finalization.md).
- [Kandahar-A-10C-Loadout-Entscheidung](evidence/kandahar-a10c-cas-loadout-decision-2026-08-01.md).
- [MissionDemand / CAS_IMMEDIATE](90-mission-demand-resupply-and-cas-orchestration-concept.md).
- [CAS-Lifecycle-Law](moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md), [CAS Tactical Corridor](moose/STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md), [Accepted Lifecycle Preservation](moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md): derzeitige AH-64-/Stage-3-Scope-Grenze; nicht als bereits getestete Fixed-Wing-Orbit-Funktion ausgeben.

## 2. Operative Zielsetzung

OMW simuliert den Zeitraum 01.08.2010 bis 31.12.2011. **CAS soll grundsätzlich 24 Stunden anforderbar** sein; daraus folgt **keine** Forderung nach lückenloser physischer 24/7-CAS-Präsenz über dem Operationsraum. Auch bei Abwesenheit einer Airborne-CAS-Formation bleibt ein konkreter, nur mit Start- und Transitverzögerung erfüllbarer Ground-Alert-Pfad verfügbar.

Unterscheidung:
- **Scheduled / Airborne On-call CAS:** geplante bewaffnete Formation im zugewiesenen Holding-/CAS-Bereitschaftsraum; kann für eine konkrete Anforderung durch C2 neu zugewiesen werden.
- **Ground Alert CAS:** am Heimatflugplatz bereitgehaltene, kampfbeladene und für Start disponierbare Formation; nicht bereits on station.
- **CAS_IMMEDIATE:** bedarfs-/prioritätsgetriebene Anforderung; C2 entscheidet über verfügbare Airborne- oder Ground-Alert-Mittel. Eine sofortige Wirkung am Ziel wird nicht suggeriert.
- **Show of Force:** als historisch plausible taktische Maßnahme bzw. Missionsdarstellung zulässig, ohne künstliche RED-Moral-/Abschreckungsmechanik. Die DCS-Boden-KI bildet keine verlässliche Reaktion darauf ab; keine Wirkung behaupten.

Das Schedule enthält Bereitschaftsfenster und Reservierungen, keine künstliche Garantie permanenter Wirkung oder exakter historischer ATO-Zeitpunkte.

## 3. Verbindliche OMW-Muster und Herkunft

| Herkunft | Aktive OMW-SQUADRON | Muster | Gesamtbestand gemäß Governance | Vorgesehene CAS-Rolle |
|---|---|---|---:|---|
| Bagram | 335th Expeditionary Fighter Squadron | F-15E | 13 | Heavy/Precision CAS; schneller Ground Alert |
| Bagram | 121st Expeditionary Fighter Squadron | F-16C Block 30 (DCS: Block 50 als dokumentierter Ersatz) | 13 | Flexible/Rapid Response CAS; schneller Ground Alert |
| Kandahar | 74th Expeditionary Fighter Squadron | A-10C | 16 | bevorzugte taktische CAS-Präsenz im Nahunterstützungsprofil |

Gesamtbestand ist ausdrücklich nicht gleichzeitige technische Verfügbarkeit. Strategische Bestände, verfügbare Flugzeuge, Reservierungen, Clients, aktive DCS-KI, Statics und virtuelle Reserve bleiben getrennte Kategorien.

**A-10C-Priorität bedeutet eine taktische Präferenz, keine ausschließliche oder automatische Zuweisung aller Anforderungen.** Bagram bleibt durch kürzere geografische Distanz eine geeignete kurzfristige Reaktionsbasis für RC East; die genaue Reaktionszeit ist unbestätigt.

## 4. Einsatzprofile und Einschränkungen

- **A-10C:** primär Nahunterstützung von Infanterie, Fahrzeugen, FOB/COP, Patrouillen und Konvois; vergleichsweise geringe Angriffsgeschwindigkeit, längeres Loitering-Potenzial und 30-mm-Kanone. Enge Täler, feindnahe Kräfte, Witterung und Sichtverhältnisse sind dennoch kein Freibrief für niedrige Angriffe.
- **F-15E:** schwerere bzw. präzisionsorientierte CAS-Aufträge, komplexe Ziele, kurzfristige Verstärkung und Aufträge mit Koordinaten-/Sensorunterstützung.
- **F-16C:** flexibel einsetzbarer, schnell verlegbarer Präzisions-CAS- und Ground-Alert-Provider.
- **Bewölkung:** geschlossene Wolkendecke kann visuelle Zielerfassung und tiefe Angriffe stark einschränken; koordinatenbasierte Wirkung mit geeignetem Sensor-/Waffen-/JTAC-Vertrag ist nicht prinzipiell ausgeschlossen. Weder F-15E/F-16C noch A-10C erhalten eine pauschale Allwetter-Garantie.
- **ROE, Zielidentifikation und eigene Kräfte:** tatsächlicher CAS-Auftrag benötigt autorisierte Ziel-/Lageinformation. Holding-/Orbit-Präsenz allein autorisiert keinen Angriff.
- **Show of Force:** kann explizit als taktischer Auftrag geflogen werden; keine DCS-KI-Reaktion oder Kampagneneffekt ohne separate, genehmigte Designentscheidung.

## 5. Bereitschafts- und Schichtmodell

### 5.1 Bagram Ground Alert (Eigentümerentscheidung bestätigt)

- **Rund um die Uhr mindestens eine Ground-Alert-CAS-Formation als Ziel der Betriebsplanung.**
- **2-ship:** zwei physische Flugzeuge in einer Alarmformation; ausdrücklich vom Projektinhaber bestätigt.
- Zuweisbar aus **F-15E oder F-16C** nach tatsächlicher Bereitschaft; Muster dürfen in wechselnden Schichten die Ground-Alert-Rolle übernehmen.
- Alarmformation ist separat von planmäßigem Airborne CAS zu reservieren. Keine strategische Doppelreservierung derselben Flugzeug-IDs.
- Aktivierung durch einen qualifizierten CAS-Bedarf / C2-Tasking; bis zur physischen Start- und Transitbestätigung lediglich `GROUND_ALERT`, nicht `CAS_ON_STATION`.
- Nach Launch entsteht eine Alert-Lücke, sofern kein weiterer *tatsächlich verfügbarer* 2-ship-Relief-Pool aktiviert werden kann. Ein Ersatz darf nicht erfunden werden.
- Die nominelle Alert-Bereitschaft kann durch Wartung, Materiallage, Feindwirkung oder andere Verpflichtungen herabgesetzt werden; Abweichung protokollieren und C2 melden.

**Keine bestätigte Alarmstartfrist.** Ein früher diskutierter Beispielwert von 15 Minuten ist ausdrücklich **kein** genehmigter OMW-Standard und keine validierte MOOSE-/DCS-Leistung. Auch die ATO-Foundation verbietet eine unkritische Übernahme der Beispiel-Angabe `15M`.

### 5.2 Kandahar / A-10C

- Die A-10C ist **keine lediglich ergänzende Restkapazität**, sondern ein bevorzugter Anbieter für geplante taktische CAS-Präsenz über dem OMW-Operationsraum.
- AAR mit den in der operativen AAR-Baseline bereits vorgesehenen SLOW-Tracks ist integraler Bestandteil der geplanten Ausdauer, soweit die reale Track-/Tanker-Verfügbarkeit den Receiver unterstützt.
- Eine in Kandahar erst alarmierte A-10C ist wegen ihrer längeren geografischen Anflugstrecke nicht standardmäßig erste Reaktion auf einen akuten Kunar-/Nangarhar-Kontakt. Die genaue Zeitdifferenz ist erst nach konkreter Routen-/DCS-Prüfung belastbar.
- Optional kann A-10 Ground Alert in Kandahar später als Verstärkungs-/Ablösemittel geplant werden; **keine** jetzt genehmigte zweite Pflicht-Alarmformation.

### 5.3 Deckungsfenster

- Tagsüber bevorzugt geplante A-10C-Airborne-CAS-Präsenz, ergänzt durch F-15E/F-16C nach Bedarf und Kapazität.
- Nachts ist CAS weiter anforderbar; physische Airborne-Deckung nach ATO-/Operationsbedarf, Personal-/Tanker-/Flugzeuglage.
- **Lücken zwischen planmäßigen Airborne-CAS-Fenstern sind ausdrücklich zulässig**; Ground Alert ist die taktische Rückfallbereitschaft, aber keine On-station-Deckung.
- Höhere Dichte und zusätzliche fliegende Formationen für vorhersehbare Bodenoperationen statt pauschalem Zwang zu zwei permanenten Orbits.
- Keine fixierten Uhrzeiten, Sunrise-/Sunset-Grenzen, Orbit-Koordinaten, Flughöhen oder behaupteten Sortie-Längen ohne missionsdatums- und quellengestützte Berechnung.

## 6. Tanker, Rotation und Missionsausgang

Aktuelle operative AAR-Baseline:
- `PATTY`: SLOW / STANDARD / primärer A-10-/RC-East-Support.
- `MILHOUSE`: SLOW / STANDARD / A-10-Kandahar-Return.
- `KRUSTY`: SLOW / STANDARD / A-10-East-/Southeast-Recovery.
- `NELSON`: FAST / STANDARD / primärer Fast-Jet-Support.
- `LISA` und `MOE`: FAST / RESERVE / nur bei passendem MissionDemand.
- Rollen, Frequenzen, Callsigns, Track-Geometrien, Fuel- und Handover-Semantik dürfen nicht in diesem CAS-Dokument neu bestimmt werden; maßgeblich ist Dokument 29/89.

Einsatzlogik:
1. Plane AAR vor dem kritischen Treibstoffzustand, wenn passende Track-/Tanker-Kapazität verfügbar ist und sichere Rückkehrreserven gewahrt bleiben.
2. Während ein CAS-Flight tankt, steht er nicht in derselben Weise unmittelbar für den CAS-Orbit bereit; Ersatzabdeckung, sofern verfügbar, ist zu disponieren.
3. **Luftbetankung ersetzt keine Bewaffnung.** Bei unzureichender verbleibender CAS-Munition: keine falsche `READY`-Meldung, rechtzeitige Ablösung/RTB.
4. Reguläre Handover: Nachfolger disponieren und starten unter Berücksichtigung von Taxi-, Transit-, Orbit- und Übergabezeit; die aktuelle Formation nach Bestätigung der tatsächlich angekommenen einsatzbereiten Ablösung freigeben, soweit sicher möglich.
5. **Bingo/FuelLow, Winchester, Damage oder Emergency sind Ausnahme-/Unable-to-Continue-Pfade**, nicht erst der Beginn einer normalen Ablöseplanung. Sicherheit und kontrollierter Rückflug haben Vorrang vor lückenloser Deckung.
6. Bei fehlender Ablösung erfolgt dennoch rechtzeitiger sicherer RTB und offene `COVERAGE_GAP`-Meldung; kein endloses Orbiting bis Bingo.
7. Nach Landung erst nach tatsächlicher MOOSE-Lifecycle-Bestätigung und CampaignState-Reconciliation wieder verfügbar; keine sofortige fiktive Wiederherstellung von Treibstoff, Munition oder Wartungsstatus.

### 6.1 Owner-Entscheidung vom 17.10.2026: FuelLow-Scope Fixed-Wing-CAS

Der Projektinhaber legt fuer die naechste Fixed-Wing-CAS-Korrektur **30 % FuelLow** als vorlaeufigen, zu testenden Schwellenwert fest. Der Scope ist ausschliesslich **Fixed-Wing-CAS-Flights** (A-10C II, F-16C, F-15E in der CAS-Rolle), nicht alle OMW-Fluege und nicht automatisch jede Mission derselben SQUADRON.

- Die Implementierung muss diesen Scope am tatsaechlich zugewiesenen CAS-`FLIGHTGROUP` begrenzen; eine globale SQUADRON-Default-Aenderung waere nur zulaessig, wenn nachweislich keine anderen Einsatzrollen betroffen sind.
- MOOSE-first: `FLIGHTGROUP:SetFuelLowThreshold(30)` ist der vorgesehene Konfigurationsweg; die FuelLow-/FuelCritical-FSM und die vorhandenen AAR-/RTB-Lifecycles bleiben erhalten.
- **30 % ist eine FuelLow-Ereignisschwelle, keine nachgewiesene Bingo-/Landing-Reserve.** Der A4-FuelLow-/Tanker-Fallback und seine Konflikte mit der eingebauten 50-NM-Suche muessen vor Runtime-Aenderungen reconciliert werden.
- Keine Uebertragung auf AWACS, AAR-Tanker, ISR, rotary-wing CAS, Transport oder sonstige OMW-Fluege.
- Entscheidung dokumentiert, aber **nicht implementiert und nicht DCS-validiert**. A4 bleibt FAIL; A5 bleibt bis zur Ursachen- und Lifecycle-Reconciliation gesperrt.

## 7. ATO/C2- und MOOSE-Vertrag

Die bestehende ATO-Foundation bleibt maßgeblich:

```text
CampaignState (strategische Identität, Verfügbarkeit und Reservierung)
  -> MissionDemand / AIR_SUPPORT_REQUEST
  -> AIR_TASKING_PLAN (Schedule, Alert-Fenster, Mission-to-Support)
  -> OMW Tasking Adapter (nur fachliche Grenze)
  -> MOOSE COMMANDER / AIRWING / SQUADRON / AUFTRAG
  -> FLIGHTGROUP / DCS
  -> bestätigter physischer Lifecycle -> idempotentes CampaignState Settlement
```

- `alert_window`, `readiness_time`, tatsächlicher Takeoff, Transit, On-station und Missionsabschluss sind getrennte Daten; Ground Alert ist nicht On-station.
- Ein geplanter CAS-Orbit ist eine Halte-/Bereitschaftsposition, keine automatische Ziel-, Battle-Position-, Engagement- oder Ingress-/Egress-Freigabe.
- C2 priorisiert Bedarf und allokiert einen berechtigten Provider; MOOSE besitzt operative Missionsausführung und den vorhandenen Lifecycle.
- Bestehende CAS-/AAR-Lifecycles, dokumentierte SQUADRON- und Herkunftsbindungen sowie akzeptierte Routen und Release-/Recovery-Verträge **nicht** kopieren, umgehen oder durch zweite Scheduler/Controller ersetzen.
- Die Honaker-AH-64-Stage-3-Regeln gelten in ihrem nachgewiesenen Scope; ihre konkrete 3–4-NM-Gate- und PATROLZONE-Geometrie ist **nicht** ungeprüft als Fixed-Wing-CAS-Standard freigegeben.
- Keine zusätzliche Native-DCS-/Nicht-MOOSE-Implementierung ohne MOOSE-Quellenprüfung, dokumentierte Lücke und ausdrückliche separate Owner-Freigabe.

## 8. Historische Evidenz und OMW-Entscheidung

- Die Juli-2011-ORBAT belegt CAS-Staffeln in Bagram und Kandahar, aber keine dauerhafte 24/7-CAS-Präsenz in *jedem* Teilsektor.
- KAIA LOP 9.7 von 2009 erlaubt ISAF-/Coalition-Militärflugverkehr H24; das allein belegt keine permanente CAS-Abdeckung.
- A-10-Eignung, F-15E-/F-16C-Precision-CAS, Luftbetankung, Relief und Show of Force sind taktisch plausible OMW-Modellentscheidungen, **keine** unbewiesenen Zusicherungen einer bestimmten realen Schichtlänge oder Alarmstartzeit.
- OMW setzt bewusst auf ein zusammengesetztes spielbares 2010/2011-ORBAT; aktuelle Governance ersetzt ältere 107th-/75th-EFS-Kandahar-Auswahl.

## 9. Offene Prüfpunkte und Acceptance-Gates

Vor Runtime-Implementierung:
1. Airport-/AIRWING-/SQUADRON-/Parking-/Client-/Loadout-Manifeste für Bagram und Kandahar erneut mit aktuellem `main` abgleichen; bei zwei Maschinen prüfen, ob das jeweilige 2-ship-Template den Foundation-/ME-Verträgen entspricht (Client-1-ship-Obergrenze bleibt unverändert).
2. Operationsgebiet und CAS-Bereitschafts-/Orbitzonen, Terrain-/Airspace-Blöcke, Nacht-/Sicht- und Deconfliction-Regeln konkretisieren.
3. Reale Takeoff-/Transit-/Tankzeit und On-station-Ausdauer je Muster/Route im Missionstestszenario messen; 2-ship-Alert-Reaktionszeit nicht schätzen.
4. Verfügbare MOOSE-Dokumentation, **tatsächlich verwendete** `Moose.lua`, Signaturen/FSMs/Events und offizielle Demos speziell zu `COMMANDER`, `AIRWING`, `SQUADRON`, `AUFTRAG`, `FLIGHTGROUP`, Patrol-/Orbit-, Fuel-/AAR- und Recovery-Funktion prüfen.
5. Acceptance-Tests: Ground-Alert-Reservierung ohne Doppeldispatch; Alarmierung/Taxi/Takeoff/Transit; C2 Request/Retask; AAR zur SLOW-/FAST-Area; AAR-Abbruch; Deckungslücke; Ablöse-On-station-Übergabe; Winchester/RTB; physische Heimkehr/ReturnToLegion/AssetReturned; Wartungs-/Rearm-Verfügbarkeit; Multiplayer und Neustart.
6. Lifecycle-Inheritance-Tabelle für zu berührende akzeptierte CAS- und AAR-Komponenten mit Source-Pfaden und exakter DCS-/MOOSE-Provenienz vor jeder Implementierung anlegen.

**Status:** `OWNER_DECISION_RECORDED / PLANNED / DCS_PENDING`. Kein Lua, keine Mission, keine Parking-Pools und keine Tankergeometrie wurden mit dieser Entscheidung verändert.


## 10. A4-Reconciliation: MOOSE AAR Resume / Departure Holding (17.10.2026)

**Status: SOURCE_REVIEWED / DESIGN_PENDING / DCS_PENDING.** Diese Analyse aendert keine produktive Runtime, stellt keinen A4-PASS dar und autorisiert keine A5-Implementierung.

### 10.1 Source-Provenienz und Fehlerbefund

- A4 ausgefuehrte Testquelle: `ae4961a46cbe2bd47dfbb1a67426e480798b2135`; Bundle-SHA256 `284F001BD397DC171F4EB17B8676E75BAA37AC00D2588D59724804722E3C7FA8`.
- Owner-Upload `OMW_Template_v26_GroundWorks_Ready(1).miz`: SHA256 `c2273ffdbd2ecdeb43f2a3bab722fa9b33ed9c5679a311f3f15c7c61f1033d21`; enthaltene `Moose.lua` SHA256 `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`. Die lokale DCS-Runtime-Zuordnung ist auf den dokumentierten A4-Log-Scope begrenzt.
- A4-Konfiguration: `SetMissionHoldingCoord(kandahar, 12000, 210, 3600)` mit `AddConditionPush(joinedForMission)`; `SetDefaultAltitude(22000)`, `SetDefaultSpeed(260)` und `SetMissionSpeed(260)`.
- AAR: MOOSE `FLIGHTGROUP:Refuel`; `Refueled` belegt. Danach kein belastbarer Honaker-AO-Eintritt. Lead und Wingman sinken **zeitversetzt** von rund 24.000 ft auf rund 11.300 ft MSL und fliegen spaeter beide etwa 210 kn TAS. Ein A-10-zu-A-10-Hit und die anschliessenden zwei Crash-/Pilot-dead-Ereignisse sind Debrief-Evidenz; exakte Kollisionsdynamik bleibt unbelegt.
- `missionState=done/success` tritt in A4 erst **nach** den physischen A-10-Verlusten auf und ist kein CAS-Erfolg.

### 10.2 Verifizierte gepinnte MOOSE-Signaturen / Mechanismen

Quellcode: A4-eingebettete `Moose.lua` (SHA256 oben), Zeilennummern bezogen auf bereitgestellte identische `Moose.lua`:

| Methode / Ort | Quellcodebefund | Bedeutung |
|---|---|---|
| `AUFTRAG:SetMissionHoldingCoord` (ca. 181172) | Speichert `missionHoldingCoord`, Altitude, Speed, Duration auf AUFTRAG | Holding bleibt Missions-Eigenschaft; Setter bietet kein dokumentiertes One-shot/clear |
| `AUFTRAG:AddConditionPush` (ca. 179045) | Fuegt Push-Bedingung hinzu | Bedingung schliesst erneute Holding-Routenerzeugung nicht aus |
| `FLIGHTGROUP:onafterRefuel` (ca. 206366) | `PauseMission`, Refueling-Route/Task | MOOSE besitzt Betankungs-Ausfuehrung |
| `FLIGHTGROUP:onafterRefueled` (ca. 206404) | `_CheckGroupDone(1)` | MOOSE prueft Fortsetzung |
| `OPSGROUP:_CheckGroupDone` (ca. 229879) | Wenn alle verbleibenden Missionen pausiert: `UnpauseMission()` | Resume erfolgt ueber vorhandenes MOOSE |
| `OPSGROUP:onafterUnpauseMission` (ca. 224552) | `mission.unpaused=true`; `MissionStart(mission)` | MissionStart wird erneut ausgefuehrt |
| `OPSGROUP:onafterMissionStart` (ca. 224426) | `RouteToMission(Mission, 3)` | Routenaufbau nach Resume |
| `OPSGROUP:RouteToMission` (ca. 224853; Holding-Block ca. 225285) | Bei `GetMissionHoldingCoord()` wird unabhaengig von `mission.unpaused` wieder ein Holding-Wegpunkt samt Orbit-Task eingefuegt | **Source-belegter Reentry-Pfad** zum Kandahar-Departure-Holding |
| `FLIGHTGROUP:SetFuelLowThreshold` (ca. 203814) | Prozentwert; Default 25 | 30 als CAS-FLIGHTGROUP-Scope moeglich; nicht global |

**Ursachenbewertung:** Die Wiederanlage der Holding-Route beim Resume ist im Source reproduzierbar erkennbar. Dass exakt dieser Pfad in A4 den anschliessenden beobachteten DCS-Flug steuerte, ist eine starke, aber noch nicht durch aktive Waypoint-/FSM-Telemetrie vollstaendig verifizierte Schlussfolgerung. Keine generische MOOSE-Standardflughöhe von 11.000 ft nachgewiesen.

### 10.3 Abgleich gegen externe MOOSE-Demos

Geprueft: offizielles Repository `FlightControl-Master/MOOSE_MISSIONS_UNPACKED` (CAS-Fall `CAS-003 - CAS in a Zone by Airplane Group - Engage with Speed and Altitude`) sowie Verzeichnisstruktur CAS-/Formation-/Recovery-Tanker-Demos. `CAS-003` benutzt **`AI_CAS_ZONE`**, nicht den aktuellen `COMMANDER/AIRWING/AUFTRAG`-AAR-Resume-Pfad. **Keine** Uebernahme als Ersatzarchitektur und **kein** daraus abgeleiteter Nachweis fuer Two-Ship-Resume nach AAR.

### 10.4 Korrekturoptionen / Freigabe-Gate

1. **Prioritaet: MOOSE direkt.** Einmalige Departure-Formation-Qualifikation von langfristiger `AUFTRAG:NewCAS`-Mission trennen, soweit die gepinnte oeffentliche OPS-/Mission-API dies ohne zweiten Mission-Owner leisten kann. Separates MOOSE-Staging-Tasking ist ein **Kandidat**, aber Queue-Uebergang, Asset-Bindung, Join und Fuel/AAR-Resume sind vor Auswahl anhand gepinnter Methoden konkret zu belegen; kein voreiliges zweites `AUFTRAG` neben C2.
2. **Alternative: kleinster MOOSE-Adapter nur nach dokumentierter Gap-Analyse und Owner-Entscheidung.** Direkte interne Mutation `mission.missionHoldingCoord=nil` nach Join ist keine belegte oeffentliche Remove-Holding-API und darf nicht stillschweigend implementiert werden. Kein `Moose.lua`-Patch, Native-DCS-Task oder eigener Flug-/Resume-Controller.
3. A4-Frueh-AAR bei 65 %, deaktivierte `FuelLowRTB/Refuel`-Automatik und 500-NM-Tanker-Filter bleiben historische Testkonfiguration, **keine** Produktions-Fuel-Policy. Der genehmigte 30-%-FuelLow-Scope betrifft nur Fixed-Wing-CAS-Flights; MOOSE-FSM erhalten, produktive AWACS/AAR-Lifecycles nicht duplizieren.
4. Vor neuem A5-Code: Lifecycle-Inheritance-Tabelle (produktive AWACS/AAR/CAS-Quellen, exakte MOOSE-Methoden, geaenderte Boundary, Regressionen), klare MOOSE-API-Loesung und danach Owner-Freigabe, soweit eine interne MOOSE-Override-/INTENTIONAL_CHANGE-Grenze betroffen ist.
5. Neues Acceptance nur mit Diagnostik der `MissionStart/UnpauseMission/RouteToMission`-Reihenfolge, aktivem Routen-/Holding-Zustand, individueller Fuel-/Hoehen-/Geschwindigkeitstelemetrie und horizontalem/vertikalem Elementabstand sowie physischer CAS-/RTB-/Asset-Return-Evidenz; alte A1-A4-Artefakte nicht aendern.

**Aktueller Gate-Status: BLOCKED_FOR_A5_IMPLEMENTATION** bis zur dokumentierten Entscheidung fuer einen versionsverifizierten MOOSE-First-Korrekturweg.
