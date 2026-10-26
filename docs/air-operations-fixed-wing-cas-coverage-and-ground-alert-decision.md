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


### 10.5 Konkretisierung: Push-Bedingung ist kein abtrennbarer Departure-Task

Die erneute Source-Pruefung der eingebetteten MOOSE-Version ergibt eine entscheidende Differenz:

- A4 erstellt **einen** `AUFTRAG:NewCAS` und setzt am selben Objekt sowohl `SetMissionHoldingCoord` als auch `AddConditionPush`.
- `AUFTRAG:IsReadyToPush` (Zeile ca. 179407) prueft `Tpush` und `conditionPush`.
- `OPSGROUP:onbeforeTaskExecute` (ca. 223075) prueft `IsReadyToPush` bei Ausfuehrung des *Mission-Tasks*. Bei noch offener Bedingung nutzt es `FLIGHTGROUP:Wait` **an der dann erreichten Position**, nicht zwingend im Departure-Raum.
- `FLIGHTGROUP:onafterWait` (ca. 206312) implementiert ein MOOSE-eigenes Orbit an der aktuellen Position mit konfigurierbarer Hoehe/Geschwindigkeit. Dies ist ein vorhandener Baustein, **aber kein Beleg fuer einmalige Departure-Freigabe bei bereits laufender C2-CAS-Mission**.
- `OPSGROUP:RouteToMission` (ca. 224853) baut bei jedem Aufruf einen Holding-Wegpunkt auf, solange `mission:GetMissionHoldingCoord()` einen Wert liefert. `mission.unpaused` verhindert den Holding-Block nicht.
- `AUFTRAG:SetMissionHoldingCoord(nil)` ist **kein** oeffentlicher Loeschweg: die Methode ruft `Coordinate:IsInstanceOf` auf; ohne Coordinate ist das ungueltig. Im gepinnten AUFTRAG-Source ist keine eigene dokumentierte Clear-/OneShot-Holding-Methode gefunden worden.

**Ausgeschlossene vermeintliche Sofortkorrektur:** `SetMissionHoldingCoord` einfach streichen und `AddConditionPush(joined)` beibehalten. Dadurch entfaellt der Departure-Orbit; der MOOSE-Wartepfad greift erst am Missions-Ausfuehrungspunkt. Der erforderliche Start-/Join-Vertrag wird nicht nachgewiesen.

**Kleinste fachliche Trennung:** einmaliger Departure-Orbit/Join (MOOSE-eigen), anschliessend wiederaufnehmbarer CAS-`AUFTRAG` ohne Departure-Holding; AAR unterbricht ausschliesslich den jeweils laufenden MOOSE-Auftrag und fuehrt danach mit dessen FSM fort. Dies beschreibt den Soll-Vertrag und ist **noch kein nachgewiesenes Queue-/Dispatch-Rezept**.

**Naechstes Source-Gate:** Fuer einen vollstaendig oeffentlichen MOOSE-Pfad muss gezeigt werden, wie eine bereits C2-rekrutierte konkrete FLIGHTGROUP ihren einmaligen Staging-/Join-Abschnitt abschliesst, **bevor** die CAS-Route beginnt, ohne einen zweiten operativen C2-Mission-Owner zu erzeugen und ohne selbst Route/Task/RTB zu uebernehmen. Zu pruefen sind insbesondere `AUFTRAG:NewORBIT`, `FLIGHTGROUP:Wait`, `OPSGROUP:AddMission` und die AIRWING-Rekrutierungs-/Mission-Queue-Semantik. Keiner dieser einzelnen API-Namen belegt schon den gesamten Workflow.

**Minimaladapter nur als ausdruecklich freizugebende Alternative:** Den einmaligen Holding-Wert nach echtem Join zu entfernen wuerde einen internen `AUFTRAG`-Zustand aendern. Weil eine oeffentliche Clear-Methode nicht gefunden wurde, ist dies **kein** derzeit genehmigter Produktionsfix. Keine stille Mutation, kein MOOSE-Source-Patch.

### 10.6 MOOSE Mission-Queue: separates ORBIT technisch vorhanden, aber kein bewiesener C2-Handoff

Gepinnte `Moose.lua`:

- `AUFTRAG:NewORBIT` (ca. 176248) erzeugt einen legitimen Air-Missionstyp mit Kreis-/Racetrack-Orbit, Hoehe und Geschwindigkeit. Dies ist **kein** allgemeiner Sammel-/Join-Abschlussvertrag.
- `OPSGROUP:AddMission` (ca. 224035) stellt einen Auftrag fuer **eine bereits existierende konkrete OPSGROUP** in deren lokale Queue; `AUFTRAG:AddOpsGroup`, Gruppenstatus und Missionqueue werden aktualisiert.
- `OPSGROUP:_GetNextMission` (ca. 224191) waehlt nach Priority/Startzeit und `SCHEDULED`-/Ready-/Importance-Bedingungen aus. Ein eigener ORBIT muss demnach vorher beendet oder kontrolliert uebergeben werden, bevor CAS regelhaft startet.
- `OPSGROUP:onafterMissionDone` (ca. 224683) entfernt die abgelaufenen Wegpunkte und prueft `Mission.legionReturn`; eine unachtsame Staging-Mission kann die Asset-Rueckgabe beeinflussen.
- `AUFTRAG:NewNOTHING` (ca. 177848) ist ausdruecklich nur fuer GROUND/NAVAL und fuer Fixed-Wing-Departure ungeeignet.

**Bewertung:** MOOSE stellt alle erforderlichen Grundbausteine bereit, aber eine zweite, nach C2-Zuweisung derselben Gruppe hinzugefuegte ORBIT-Mission ist nicht schon allein durch API-Existenz ein fehlerfreier, minimaler Ersatz. Die Queue-Prioritaet, die Join-Abschluss-/MissionDone-Semantik, die konkrete AIRWING-Asset-Zuordnung und die Rueckbuchung muessen im Verbund nachgewiesen werden. Eine solche Architektur waere ausserdem komplexer als der im Owner-Gespraech gewuenschte einzelne CAS-Auftrag.

Der zuerst zu pruefende Korrekturvorschlag bleibt daher die **einmalige Departure-Freigabe mit genau einem CAS-Mission-Owner**. Falls die gepinnte oeffentliche API die einmalige Entfernung des CAS-Holdings nicht zulaesst, muss vor jedem internen Minimaladapter eine ausdrueckliche Owner-Entscheidung fallen. Eine vermutete MOOSE-Faehigkeit nicht als bestaetigten API-Vertrag ausgeben.

### 10.7 Source-gepruefte zweite Fehlerursache: nicht persistente Join-Freigabe

Im tatsaechlich getesteten A4-Source `mission/tests/fixed-wing-cas-response/src/acceptance-4-three-flight-joined-aar.lua` speichert `joinedForMission(requestId)` zwar `record.joinedAt` beim ersten erfolgreichen Join, gibt am Funktionsende aber `return joined` fuer die **erneut gemessene** Entfernung zurueck. Da die Funktion direkt als `AUFTRAG:AddConditionPush` installiert ist, kann nach getrenntem AAR ein zuvor erfuellter Departure-Join beim naechsten MOOSE-Push-Check wieder FALSE sein.

**Erforderliche Korrektur im naechsten, neuen Testsource (nicht im historisch getesteten A4):** Die einmalig bestaetigte Departure-Freigabe als latch aus `record.joinedAt ~= nil` auswerten; weiterhin nur MOOSE-`AddConditionPush` als Missionsfreigabe benutzen. Dies loest **nicht** das unabhaengige erneut eingefuegte Holding bei `RouteToMission`, ist aber notwendig, um einen blockierten CAS-Push nach AAR zu vermeiden. Keine eigene Mission-FSM.

### 10.8 Quellcodegrenze: AAR nach eingeleitetem RTB

`FLIGHTGROUP:onafterRTB` (ca. 205995) setzt `destbase`, ruft **`CancelAllMissions()`** und danach `_LandAtAirbase(...)` auf. `FLIGHTGROUP:onafterRefuel` (ca. 206366) verwendet dagegen `PauseMission()` nur fuer eine *vorhandene aktuelle Mission*; `onafterRefueled` (ca. 206404) laesst `_CheckGroupDone()` entscheiden, ob ein pausierter Auftrag vorliegt.

**Folge:** Betankung im RTB-Abschnitt kann nicht ohne Weiteres als `PauseMission -> UnpauseMission -> RTB fortsetzen` modelliert werden. Nach RTB-Cancel existiert typischerweise kein pausierter CAS-Auftrag. Ein erneuter `RTB()`-Aufruf oder eine andere Recovery-Fortsetzung darf nicht ungeprueft im Harness erfunden werden. Zuerst die vorhandenen produktiven AWACS-/AAR- und AIRWING-Recovery-Vertraege auf eine getestete MOOSE-First-Loesung pruefen; dann gegebenenfalls ein eigenes, begrenztes Acceptance-Gate fuer RTB-AAR vorsehen.

### 10.9 Korrekturreihenfolge und Verifikationsgrenze

1. In neuer Acceptance-Quelle (A4 bleibt unveraendert) **sticky join** ueber vorhandene `AddConditionPush`-Bedingung korrigieren, geeigneten quellengestützten einmaligen Holding-Abschluss bestimmen.
2. Den einmaligen Departure-Holding-Abschluss vorzugsweise ueber **oeffentliche** MOOSE-API umsetzen. Ein blosses Versetzen des Holdings auf das AO per `SetMissionHoldingCoord` wurde **nicht** als semantisch gleichwertige CAS-Resume-Loesung nachgewiesen: es erzeugt beim Resume weiterhin einen separaten Orbit-Wegpunkt.
3. Fixed-Wing-CAS-FLIGHTGROUPs auf `SetFuelLowThreshold(30)` konfigurieren; FuelLow/FuelCritical, Tanker-Eignung und MOOSE-RTB muessen ohne zweiten Fuel-/Recovery-FSM-Owner reconciliert sein.
4. Vor erneutem DCS-Lauf Source-/Unit-/Build-Checks, exakte Bundle-Provenienz und diagnostische FSM-/Wegpunkt-/Two-Ship-Telemetrie herstellen. DCS-Test muss AAR waehrend Transit und waehrend CAS gesondert beobachten. RTB-AAR ist wegen `CancelAllMissions` ein eigenes offenes Gate.
5. Kein auf A4 rueckwirkender PASS, keine `.miz`-Mutation, keine neue DCS-Validierungsbehauptung.

**Aktueller Gate-Status: BLOCKED_FOR_A5_IMPLEMENTATION** bis zur dokumentierten Entscheidung fuer einen versionsverifizierten MOOSE-First-Korrekturweg.


### 10.10 Erneute offizielle MOOSE-Demo-Recherche: Legacy UND OPS/develop (18.10.2026)

**Grund fuer erneute Untersuchung:** Die vorangegangene Sichtung betrachtete vor allem `MOOSE_MISSIONS/master` und ueberging die OPS-Beispiele unter `MOOSE_MISSIONS/develop`. Der Owner forderte einen breiten Source-Abgleich fuer CAS/CAP-Holding plus AAR plus Weiterflug. Die GitHub-Gesamtdateibaeume wurden fuer `FlightControl-Master/MOOSE_Demos/master` (175 Dateien), `MOOSE_MISSIONS_UNPACKED/master` (6859 Dateien), `MOOSE_MISSIONS/master` (798 Lua/Demo-Dateien und weitere Binaerdateien) und `MOOSE_MISSIONS/develop` (1708 Dateien) nach Script-/Demo-Themen inventarisiert. Relevante Original-Lua-Demos wurden anschliessend einzeln gelesen. **Dies ist keine manuelle Quellcode-Zeilenpruefung jedes Demo-Skripts und keine DCS-Validierung.**

**Legacy Demos (historische Quelle fuer das MOOSE-Konzept, aber NICHT importierbarer OMW-Code):**

| Offizielles Demo | Gelesener Mechanismus | Evidenzgrenze |
|---|---|---|
| `AI/AI_A2G_Dispatcher/AID-A2G-363 - CAS Airplanes Patrol Refuel/AID-A2G-363 - CAS Airplanes Patrol Refuel.lua` | `AI_A2G_DISPATCHER`, `SetSquadronCasPatrol`, `SetDefaultTanker("Tanker")`, `SetDefaultFuelThreshold(0.9)` | Demonstriert CAS-Patrol plus AAR-Konfiguration, nicht `AUFTRAG`-Resume |
| `AI/AI_A2A_Dispatcher/AID-A2A-016 - Refuel Tanker Test/AID-A2A-016 - Refuel Tanker Test.lua` | `AI_A2A_DISPATCHER`, `SetSquadronCap`, `SetDefaultTanker`, `SetSquadronTanker`, FuelThresholds | Demonstriert CAP plus Tanker-Konfiguration |
| `AID-A2A-030`, `AID-A2A-031` | CAP RTB/ReEngage beziehungsweise Out-of-Fuel | Kein vollstaendiger Refueled/Resume-Demo-Quellnachweis |

Web-Dokumentation `AI.AI_A2G_Dispatcher` Abschnitt 10.7.3 beschreibt explizit automatische Betankung statt Low-Fuel-RTB fuer SEAD/BAI/CAS. Die aktuelle gepinnte OMW-`Moose.lua` enthaelt **weder `AI_A2G_DISPATCHER` noch `AI_A2A_DISPATCHER`**; diese historischen Aufrufsignaturen sind deshalb nicht auf OMW uebertragbar.

**OPS-Demos des offiziellen `MOOSE_MISSIONS/develop`-Branches (teilweise direkt versionsueberpruefbar):**

| Offizielles Demo | Gelesener Mechanismus | Bedeutung |
|---|---|---|
| `Ops/Flightgroup/Flightgroup - 060 - Refuel/Flightgroup - 060 - Refuel.lua` | `FLIGHTGROUP:__Refuel(60)`, `OnAfterRefuel`, `OnAfterRefueled` | Direkter offizieller Nachweis fuer FLIGHTGROUP-AAR und FSM-Callbacks; Demo **weist nach Betankung keine weitere CAS-Mission zu** |
| `Ops/Airwing/Airwing - 200 - GCICAP/Airwing - 200 - GCICAP.lua` | AIRWING CAP-Patrolpoints; `SQUADRON:SetFuelLowRefuel(true)`; `SQUADRON:SetFuelLowThreshold(0.3)` | Moderne, konzeptionell nahe OPS-Konfiguration fuer CAP und automatisches AAR. **Achtung: gepinnte SQUADRON-Methode erwartet Prozent 0..100, nicht 0..1; `0.3` wird als 0,3 % gespeichert, nicht als 30 %. Beispielwert deshalb NICHT uebernehmen.** |
| `Ops/EasyGCICAP/EasyGCICAP - 100 - Basic/EasyGCICAP - 100 - Basic.lua` | `EASYGCICAP` mit CAP- und Tanker-Patrolpoints, Fighter- und Tanker-Squadrons | Bestandteil neuerer OPS-Architektur; kein exakter CAS-/Two-Ship-Join-Resume-Beweis |
| `Ops/Auftrag/Airforce/Auftrag - 017 - CAS/Auftrag - 017 - CAS.lua` | `AUFTRAG:NewCAS` + `FLIGHTGROUP:AddMission` | CAS-Missionsgrundfunktion |
| `Ops/Auftrag/Airforce/Auftrag - 018 - CAP/Auftrag - 018 - CAP.lua` | `AUFTRAG:NewCAP` + FLIGHTGROUP | CAP-Missionsgrundfunktion |
| `Ops/Auftrag/Airforce/Auftrag - 022 - Orbit/Auftrag - 022 - Orbit.lua` | Mehrere priorisierte `AUFTRAG:NewORBIT_*` in einer FLIGHTGROUP-Queue; `OnAfterExecuting` -> `__Cancel` nach fester Zeit | Quellbeleg fuer legitime MOOSE-Missionsqueue und kontrollierte Orbit-Beendigung, aber kein direktes C2-Recruit-Join-AAR-Beispiel |
| `Ops/Auftrag/Airforce/Auftrag - 100 - CAS Enhanced/Auftrag - 100 - CAS Enhanced.lua` | `AUFTRAG:NewPATROLZONE` + `FLIGHTGROUP:SetEngageDetectedOn` | Alternative MOOSE-First-CAS-Semantik fuer flexible AO; keine automatische AAR-Fortsetzung im Demo nachgewiesen |
| `Ops/Airwing/Airwing - 010 - Fighter Wing/Airwing - 010 - Fighter Wing.lua` | `SQUADRON:SetGrouping(2)`, AIRWING + CAP/BAI + `AUFTRAG` | Belegt native Two-Ship-Rekrutierung, kein expliziter nachgezogener Departure-Join oder Refueled-Resume |

**Versionierter MOOSE-Check:** Die gepinnte `Moose.lua` enthaelt u.a. `FLIGHTGROUP:SetFuelLowThreshold` (ca. 203814), `FLIGHTGROUP:SetFuelLowRefuel` (ca. 203862), `FLIGHTGROUP:onafterRefueled` (ca. 206404), `SQUADRON:SetFuelLowThreshold` (ca. 245348), `SQUADRON:SetFuelLowRefuel` (ca. 245357). `FLIGHTGROUP:SetFuelLowThreshold(30)` und `SQUADRON:SetFuelLowThreshold(30)` erwarten **30**, nicht **0.3**. Bei der historischen A2G-Dispatcher-Konfiguration wird dagegen der Bruch `0.9` genutzt. Die Demo-Quellen gehoeren unterschiedlichen Klassen-/API-Generationen an; Schwellenwerte duerfen nicht unbesehen gemischt werden.

**Befund:** Offizielle MOOSE-Projekte demonstrieren explizit (a) CAS-/CAP-Patrol mit AAR, (b) moderne AIRWING-/SQUADRON-FuelLowRefuel-Konfiguration, (c) direkte FLIGHTGROUP-Refuel-FSM und (d) AUFTRAG-Missionqueue. **Nicht gefunden wurde in den konkret gesichteten modernen Originalskripten** die vollstaendige Kombination `AIRWING/COMMANDER Zwei-Flugzeug-Start -> Departure-Join-Holding -> AAR in CAS-Transit -> Refueled -> CAS-Resume ohne Hold-Reentry -> physischer Return`. Die Existenz der einzelnen Framework-Funktionen bedeutet weder einen nachgewiesenen identischen kombinierten Lifecycle noch dessen Unmoeglichkeit.

**Konsequenz fuer A4/A5:** Kein eigener Flight-Controller und kein vorschneller interner Holding-Mutator. Zuerst `SQUADRON:SetFuelLowRefuel` + `FLIGHTGROUP`-AAR-FSM als dokumentierte moderne MOOSE-First-Baseline gegen konkrete AAR-Provider-Entscheidung und Pinned-Source pruefen; danach das klar separierbare Problem des einmaligen Departure-Join/Push und wiederholten `RouteToMission` korrigieren. Fuer den A4-Test-Scope bleibt die 30-%-Schwelle **nur CAS-FLIGHTGROUP**, keine globale SQUADRON-Aenderung. Eine neue DCS-Acceptance bleibt erforderlich.

**Offizielle Links:**
- https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/develop/Ops/Flightgroup
- https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/develop/Ops/Auftrag/Airforce
- https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/develop/Ops/Airwing
- https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/AI/AI_A2G_Dispatcher
- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/AI.AI_A2G_Dispatcher.html
- https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.FlightGroup.html


### 10.11 Owner-Entscheidung vom 23.10.2026: A5-Arbeit wieder aufnehmen

**Entscheidung:** Nach der am 18.10.2026 im MOOSE-Discord gestellten und bis zum 23.10.2026 unbeantworteten Rueckfrage wird A5 nicht weiter allein wegen ausstehender externer Beratung blockiert. Der Owner hat den **MOOSE-First-Pruef- und Entwicklungsweg** genehmigt: einmaliges Departure-Marshalling bevorzugt als eigenstaendigen MOOSE-ORBIT-Auftrag, anschliessend einen wiederaufnehmbaren CAS-AUFTRAG ohne Departure-Holding. Eine spaetere Discord-Antwort wird als Revisionsanlass bewertet, nicht als Implementierungs-Voraussetzung.

**Freigabeumfang:** Erlaubt sind versionsverifizierte oeffentliche MOOSE-Funktionen, dokumentierte FSM-/Queue-Kombinationen sowie ein neuer, getrennt provenancegefuehrter Acceptance-Test. **Nicht freigegeben** sind interne AUFTRAG-Feldmutation, MOOSE-Source-Patch, Native-DCS-Flugcontroller, alternative Ressourcenautoritaet oder Veraenderung akzeptierter Recovery-Invarianten. Ist eine solche Ausnahme erforderlich, bleibt sie ausdruecklich owner-approval-pflichtig.

**Pruefung der eingebetteten MOOSE-2.9.18-Quelle (23.10.2026):**

| Methode | Quellenbefund | Noch nicht bewiesen |
|---|---|---|
| `AUFTRAG:NewORBIT(Coordinate, Altitude, Speed, Heading, Leg)` | Oeffentlicher Konstruktor, `Moose.lua` ca. Zeile 176248; ORBIT_CIRCLE/RACETRACK ebenfalls vorhanden | Automatisches Freigeben eines bereits begonnenen Departure-Orbits bei Join |
| `OPSGROUP:AddMission(Mission)` | Oeffentliche Queue-API, ca. Zeile 224035; registriert OpsGroup, scheduled Mission und haengt Queue-Eintrag an | Reihenfolge, Pause-/Cancel-Grenze und Uebergang fuer ein vom COMMANDER rekrutiertes Two-Ship |
| `AUFTRAG:AddConditionPush` | Oeffentliche Push-Bedingung, ca. Zeile 179045 | Korrekte Ingress-Behandlung in Kombination mit weiteren Waypoints; Discord-Befund vom 11.12.2024 ist historische Evidenz |
| `AUFTRAG:SetMissionHoldingCoord` | Eigenschaft bleibt auf dem Mission-Objekt; ca. Zeile 181172 | Keine belegte oeffentliche One-shot-Clear-API in diesem Source |
| `OPSGROUP:RouteToMission` | Fuegt weiterhin einen Holding-Wegpunkt ein, sofern die Mission einen Holding-Coordinate besitzt | Exakte physische A4-Waypoint-Ausfuehrung nach AAR bleibt DCS-diagnostisch offen |

**A5-Ausfuehrungsvertrag, vor Lua-Implementierung auf dem konkreten COMMANDER/AIRWING-Pfad zu schliessen:**

1. Eine C2-CAS-Anfrage behaelt einen eindeutigen Demand-/Mission-Owner und die exakte zugewiesene SQUADRON/AIRWING-/Asset-Herkunft. Kein zweiter konkurrierender Recruitment-/Asset-Owner fuer ORBIT und CAS.
2. MOOSE startet das Two-Ship. Der Departure-ORBIT wird nur der **bereits ausgewaehlten physischen FLIGHTGROUP** zugeordnet; ob und wann ein COMMANDER-generierter CAS-Auftrag vorher/nachher in der Queue stehen darf, wird am gepinnten Source und den offiziellen Demos geprueft. Kein blindes Cancel/Replace, das MOOSE zum RTB veranlassen kann.
3. Der Join wird erst nach zwei nachgewiesen airborne Elementen und Erreichen des vereinbarten 2-NM-Abstands einmalig gesetzt (`joinedAt`-Latch). Nach gesetzter Freigabe gibt es keine erneute dynamische Join-Anforderung nach AAR.
4. Die Beendigung des ORBIT und der Uebergang zum CAS muessen **ausschliesslich ueber belegte oeffentliche MOOSE-Methoden/Callbacks** erfolgen. Der CAS-AUFTRAG erhaelt **kein** `SetMissionHoldingCoord` fuer den Departure-Orbit.
5. `FLIGHTGROUP:Refuel`, das Pausieren und die Fortsetzung bleiben MOOSE-Aufgabe. AAR im Transit und in CAS werden getrennt diagnostiziert; AAR nach `RTB()` bleibt eigenes Gate wegen `CancelAllMissions()`.
6. Normaler Missionsabschluss, RTB, Landung, ReturnToLegion/AIRWING-Asset-Return und CampaignState-Settlement behalten ihre bisherigen Eigentuemer. Der Testharness darf nur ausloesen, beobachten und verifizieren.
7. Kein A4-Quellcode-/Ergebnis-Retrofit und kein `.miz`-Eingriff. A5 benoetigt eigene Source-/Builder-/Bundle-/Mission-/MOOSE-Hashes und anschliessende echte DCS-Validierung.

**Lifecycle-Inheritance / Regressionsgrenze:** Inherit `docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, insbesondere §8.3, §11 und §11.2. Die dortige validierte A9-Baseline betrifft Rotary-Wing-CAS; sie ist **kein** PASS fuer Fixed-Wing-CAS. Fuer den fixed-wing-spezifischen A4-Lifecycle bleiben Testquelle `mission/tests/fixed-wing-cas-response/src/acceptance-4-three-flight-joined-aar.lua`, Quellencommit `ae4961a46cbe2bd47dfbb1a67426e480798b2135`, Bundle-SHA256 `284F001BD397DC171F4EB17B8676E75BAA37AC00D2588D59724804722E3C7FA8` reine FAIL-/Diagnose-Evidenz. Verwendete produktive AIRWING-/AAR-/Return-Module muessen vor dem naechsten Runtime-Diff einzeln erfasst werden; nicht vom Testharness kopieren.

**Gate-Zustand:** `A5_DESIGN_AUTHORIZED / PUBLIC_QUEUE_HANDOFF_SOURCE_CHECK_PENDING / RUNTIME_NOT_CHANGED / DCS_PENDING`. Der fruehere pauschale Status `BLOCKED_FOR_A5_IMPLEMENTATION` aus §10.9 ist hinsichtlich der Owner-Entscheidung **ueberholt**, nicht hinsichtlich der noch offenen API-/Lifecycle-Pruefung. Falls die oeffentliche Queue-Uebergabe nicht nachweisbar tragfaehig ist, zuerst Gap-/Ausnahme-ADR und neue Owner-Entscheidung, danach erst Minimaladapter.


### 10.12 Quellpruefung des konkreten COMMANDER-ORBIT-CAS-Queue-Handoffs (24.10.2026)

**Ergebnis:** Die isolierte Existenz von `NewORBIT` und `AddMission` reicht **nicht** aus, um die genehmigte Zwei-Auftrag-Richtung unveraendert als sichere A5-Runtime zu implementieren. Die hier belegten Quellpfade muessen beim konkreten Hand-off respektiert werden:

1. `COMMANDER:onafterMissionAssign` (Moose.lua ca. 196633) uebergibt den CAS-Auftrag ueber `Legion:AddMission` und `Legion:MissionRequest` an die AIRWING-Rekrutierung. Dort fuehrt `LEGION` beim Materialisieren `flightgroup:AddMission(mission)` **vor** dem spaeteren `__OpsOnMission(5, flightgroup, mission)` aus (ca. 213180–213199).
2. Der bisherige OMW-Callback `COMMANDER.OnAfterOpsOnMission` erhaelt die FLIGHTGROUP deshalb erst **nach** der CAS-Queue-Eintragung. `OPSGROUP:_QueueUpdate` (ca. 225355–225397) kann einen bereits wartenden CAS-Auftrag starten, sobald keine `currentmission` gesetzt ist. Ein erst im Callback nachgereichter ORBIT darf daher **nicht** als garantiert zuerst laufend ausgegeben werden.
3. `OPSGROUP:_GetNextMission` (ca. 224191–224270) sortiert nach `prio`, bei Gleichstand `Tstart`, und filtert nach Gruppenstatus/Importance. Ein ORBIT mit hoeherer Prioritaet kann bei gleichzeitiger SCHEDULED-Queue gewinnen, **nicht** aber zeitliche Reihenfolge im gerade beschriebenen 5-Sekunden-Fenster garantieren.
4. Ein als `urgent=true` konfigurierter, hoeher priorisierter ORBIT kann in `_QueueUpdate` einen bereits laufenden CAS-Auftrag durch `MissionCancel(currentmission)` unterbrechen. Das ist **keine** zulaessige stille Alternative zu einem einmaligen Join-Holding, weil Cancel/TaskDone, Missionsabschluss und Return-Lifecycle beeinflusst werden koennen.
5. `OPSGROUP:onafterMissionDone` (ca. 224683–224840) entfernt Missionswegpunkte und ruft `_CheckGroupDone` auf. Diese Methode (ca. 229879) sendet eine Gruppe nicht sofort heim, solange weitere Aufgaben/Missionen verbleiben. Damit ist `ORBIT beendet -> bereits eingequeue-ter CAS` grundsaetzlich frameworkkompatibel; jedoch ist **noch nicht nachgewiesen**, wie der Orbit vor dem Start des von COMMANDER bereits zugewiesenen CAS atomar initialisiert wird.
6. Zwei separat an COMMANDER gesendete Missionen sind **keine** nachgewiesene Loesung: Zwei Rekrutierungsentscheidungen koennen verschiedene AIRWING-Assets binden und verletzen ohne weitere Quellpruefung den Ein-Asset-/Ein-Owner-Vertrag.

**Neu eingegrenzte technische Luecke:** Ein garantiertes und racefreies `CAS mission enrolled but not yet started -> append/execute ORBIT for exactly same FLIGHTGROUP -> joined -> ORBIT Done -> CAS starts` ist mit den bislang nachgewiesenen oeffentlichen Funktionen **noch nicht belegt**. Die erforderliche atomare Queue-Initialisierung darf nicht mit einem zeitlichen Scheduler-Trick oder `urgent`-Cancellation erraten werden.

**Naechster Implementierungsgate:** Vor A5-Testcode eine oeffentliche MOOSE-Moeglichkeit fuer einen vor der AIRWING-Zuweisung wirksamen, einmaligen Marshalling-Auftrag oder einen dokumentierten Delay-/Queue-Startvertrag identifizieren und an genau diesem Codepfad beweisen. Falls das nicht gelingt, ist dem Owner **ein separater, eng begrenzter Ausnahmevorschlag** fuer den bestehenden CAS-Holding-Zustand vorzulegen; §10.11 genehmigt noch **keine** interne AUFTRAG-Mutation. A4-Source bleibt unangetastet und A5 bleibt DCS_PENDING.


### 10.13 AddConditionStart-Pruefung und Ausnahmegrenze (25.10.2026)

**Gepruefter Kandidat:** `AUFTRAG:AddConditionStart(function() return joinedAt ~= nil end)` koennte theoretisch den CAS-Start zurueckhalten und den bereits rekrutierten FLIGHTGROUP-Owner bewahren. **Ergebnis: fuer die von LEGION/AIRWING verwaltete FLIGHTGROUP kein belastbarer Hard-Gate.**

Gepinnte `Moose.lua` 2.9.18, wesentliche Stellen:

- `AUFTRAG:AddConditionStart` (ca. 178981) legt den Callback in `conditionStart` ab.
- `AUFTRAG:IsReadyToGo` (ca. 179320) wertet `conditionStart` aus und kann `false` liefern.
- **`OPSGROUP:_GetNextMission` (ca. 224251): `local isReadyToGo=(mission:IsReadyToGo() or self.legion)`.** Bei einer FLIGHTGROUP mit gesetztem `self.legion` kann der Mission-Start daher auch erfolgen, wenn `IsReadyToGo()` noch `false` meldet. Die Missionsqueue behandelt `AddConditionStart` nicht als verpflichtende Blockade fuer diese Klasse von Gruppen.
- `OPSGROUP:_QueueUpdate` (ca. 225369) ruft bei freiem Slot `MissionStart(mission)`; `OPSGROUP:onafterMissionStart` (ca. 224426) setzt `currentmission` und `RouteToMission` an. Damit wuerde CAS bereits ohne abgeschlossenen Departure-Join loslaufen koennen.

**Nicht zulaessige Scheinloesung:** Ein ORBIT nach `COMMANDER.OnAfterOpsOnMission` einqueue-en und CAS mit `AddConditionStart` zu sichern, schafft fuer LEGION-Gruppen **keine** Quellcode-garantierte Reihenfolge. Ebenso wenig darf die `self.legion`-Mitgliedschaft zur Umgehung kuenstlich entfernt werden; sie ist fuer Ownership und physische Asset-Rueckfuehrung erforderlich.

**Praezise verbleibende Loesungsoptionen (noch nicht implementiert):**

1. Ein anderer, explizit belegter und racefreier oeffentlicher MOOSE-Einstieg *vor* der Queue-Eintragung des CAS-Auftrags. Die bislang geprueften OPS-/COMMANDER-/LEGION-Handoffs liefern dafuer keinen Nachweis. Weitergehende Source-Recherche ist moeglich; **kein** Negativbeweis fuer alle MOOSE-Erweiterungspunkte.
2. **Minimaladapter nur nach neuer, ausdruecklicher Owner-Ausnahme:** A4-kompatibles einzelnes `AUFTRAG:NewCAS` beibehalten, den bereits erfolgreichen Join per `joinedAt` dauerhaft freigeben und **nach bestaetigtem Join** ausschliesslich den abgeschlossenen `AUFTRAG`-Departure-Holding-Zustand entfernen. Letzteres waere ein gezielter Eingriff in undokumentierte AUFTRAG-Interna (zum Beispiel `mission.missionHoldingCoord=nil`), **keine** oeffentliche MOOSE-API. Die MOOSE-Routen-/AAR-/FSM-/RTB-/Ressourcenlogik bleibt unveraendert. Auch hier sind Ereignisreihenfolge, Wiederaufnahme und DCS-Verhalten in einer neuen A5-Quelle zu testen.

**Owner-Entscheidungsbedarf:** Die Freigabe vom 23.10. ermaechtigt die MOOSE-First-Recherche und einen oeffentlichen API-Weg, **nicht** die interne Feldmutation. Deshalb keine neue A5-Runtime und keine A4-Retrokorrektur. Status `PUBLIC_START_GATE_NOT_PROVEN / MINIMAL_INTERNAL_ADAPTER_REQUIRES_OWNER_APPROVAL / DCS_PENDING`.


### 10.14 Owner-Freigabe und A5-Implementierung (26.10.2026)

Der Owner hat die in §10.13 einzeln benannte Ausnahme **ausdruecklich genehmigt**: `mission.missionHoldingCoord = nil` **einmalig nach tatsaechlich bestaetigtem Two-Ship-Join**, sonst keine interne MOOSE-Mutation. Die fruehere ORBIT-vor-CAS-Queue-Variante bleibt wegen des belegten COMMANDER-/LEGION-Handoff-Rennens ausgeschlossen, bis eine gesondert belegte MOOSE-Loesung vorliegt. Die A5-Folge ist keine Freigabe fuer eigene Routing- oder Recovery-FSMs.

Eigene A5-Testquelle `mission/tests/fixed-wing-cas-response/src/acceptance-5-three-flight-joined-aar-resume.lua` und PowerShell-Builder `tools/build-fixed-wing-cas-response-acceptance-5.ps1`; A4 bleibt unveraendert. Implementierte Differenz: Join-Latch aus `joinedAt`; danach gezieltes Nullsetzen **nur** von `missionHoldingCoord`; eigene Logs `DEPARTURE_HOLD_CLEARED` und `missionHoldingPresent`; genehmigtes `FLIGHTGROUP:SetFuelLowThreshold(30)` nur fuer Fixed-Wing-CAS. A4-65%-A10-AAR bleibt als explizite **Testbedingung**, nicht Produktionsentscheidung. Vollstaendige Risiken, Schritte und DCS-Gates in `mission/tests/fixed-wing-cas-response/ACCEPTANCE-5.md`.

**Review-Trigger:** spaetere MOOSE-Discord-/Upstream-Antwort, neuer MOOSE-Stand, DCS-Route-Reentry, nicht erwartetes Holding nach Resume oder Regression bei Fuel/RTB/Asset-Return. Status: OWNER_EXCEPTION_APPROVED / SOURCE_IMPLEMENTED / DCS_PENDING; A4 FAIL unveraendert.


### 10.15 Owner-Zielentscheidung vom 26.10.2026: Departure-Racetrack statt engem Circle

**Owner-Richtung:** Die bisher beobachteten engen Lead-Holding-Kreise ueber Bagram/Kandahar sollen durch ein laengeres Racetrack-Marshalling abgeloest werden, um das Formation Joining und den Treibstoffverbrauch zu verbessern. **Ein geringerer Nachbrennereinsatz ist eine Testhypothese, kein bereits nachgewiesener Effekt.** Die beiden Flugplaetze/Flugzeugfamilien benoetigen eigene, in DCS zu validierende Racetrack-Geometrien; Positionen, Track-Heading und Leg-Laenge wurden vom Owner noch nicht verbindlich festgelegt.

**Pinned MOOSE 2.9.18 – gesicherte technische Grenze:**

- `AUFTRAG:SetMissionHoldingCoord(Coordinate, Altitude, Speed, Duration)` (ca. Zeile 181172) stellt **keine** Heading-, Leg- oder Racetrack-Parameter bereit.
- `OPSGROUP:RouteToMission` (ca. Zeilen 225170–225205) erzeugt das Departure-Holding mit `self.group:TaskOrbit(holdingcoord, altitude, speed)` **ohne vierten Parameter**. Dies ist technisch ein CIRCLE, auch wenn die MOOSE-Holding-Koordinate auf dem AUFTRAG gespeichert wird.
- `CONTROLLABLE:TaskOrbit(Coord, Altitude, Speed, CoordRaceTrack)` (ca. Zeile 52571) besitzt dagegen einen **oeffentlichen vierten Parameter**: Mit `CoordRaceTrack` erzeugt MOOSE den nativen DCS-Task `AI.Task.OrbitPattern.RACE_TRACK` und die Endpunkte `point` und `point2`. MOOSE liefert also die Racetrack-Task-Basis bereits.
- `AUFTRAG:NewORBIT_RACETRACK(Coordinate, Altitude, Speed, Heading, Leg)` (ca. Zeile 176315) ist ebenfalls oeffentlich, erzeugt aber einen **separaten AUFTRAG**. Die bereits in §§10.12–10.13 nachgewiesene COMMANDER/LEGION-Queue-Reihenfolge blockiert ein ungeprueftes nachtraegliches Prepend vor die CAS-Mission.
- Der bereits genehmigte A5-Adapter `mission.missionHoldingCoord=nil` **nach Join** bleibt fachlich getrennt von der Frage, wie der *vorherige* aktive Holding-Task erzeugt wird. Der Owner hat bis hierher **keinen** weiteren internen MOOSE-Override oder DCS-Controller freigegeben.

**MOOSE-First-Folge:** Es waere eine unbegruendete Behauptung, `SetMissionHoldingCoord` koenne durch ein zusaetzliches Argument einen Racetrack erzeugen. Ein kleiner Glue-Code-Pfad um die vorhandene MOOSE-`TaskOrbit(..., CoordRaceTrack)`-Funktion ist technisch naheliegend, muss aber an der konkreten `RouteToMission`-/`AddTaskWaypoint`-Grenze auf einen **belegten oeffentlichen Hook** untersucht werden. Fehlt dieser, ist eine **gesondert genehmigte** minimale MOOSE-Override-/Adapter-Ausnahme noetig. Kein Patch an der eingebetteten `Moose.lua`, keine parallele Flugsteuerung, kein blindes `AddMission(NewORBIT_RACETRACK)` im spaeten COMMANDER-Callback.

**Acceptance-Konsequenz:** A5-1 bleibt ein reproduzierbares, bereits lokal gebautes **Circle-Holding-/Resume-Gate** mit Bundle-SHA256 `D4BD212AAE55D2EB231F8261A752C9062F4156A301B0316E112562775425384B`. Dieses Bundle und seine eingebaute Test-.miz werden durch die neue Zielentscheidung nicht stillschweigend umdefiniert. Ein kuenftiger Racetrack-Test benoetigt neuen Source-/Builder-/Bundle-Commit, eine neue MIZ-Hashkette und eigene DCS-Nachweise fuer (a) reale Racetrack-Pfade, (b) beide Two-Ship-Joins, (c) geringere bzw. gemessene Fuel-/Afterburner-Last, (d) nach Join einmaligen Holding-Abschluss und (e) AAR-Resume bis CAS-AO und physische Rueckkehr. Status `DESIGN_DECIDED / RACETRACK_INTEGRATION_API_GAP / DCS_PENDING`.
