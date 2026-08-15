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
AAR production finalization – implementiert und source-reviewed, aber noch nicht DCS-validiert
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
- für AAR insbesondere `AUFTRAG:NewTANKER`, `FLIGHTGROUP`, `COORDINATE`, `SPAWN`, `SCHEDULER`, `UNIT` und `OPSGROUP`.

Die produktiven Off-map-Pools MANAS und AL UDEID werden ausdrücklich **nicht** als AIRWING/WAREHOUSE modelliert. CampaignState besitzt dort die strategische count-basierte Verfügbarkeit; MOOSE führt nur die temporäre physische Tankerrepräsentation.

## 4. Verbindliche Architekturgrenzen

- Sensor, Entscheidung und Shooter besitzen getrennte Zustände.
- Spieler und KI arbeiten auf demselben Kontakt-, Ziel- und MissionDemand-Objekt.
- Unzureichende Identifikation, NSL-Konflikt oder fehlende Autorität blockieren Tasking beziehungsweise Wirkung.
- Zielbewegung und neue Koordinaten lösen eine erneute Targeting-Prüfung aus.
- BDA verändert CampaignState erst nach validierter Wirkung.
- Bewaffnete UAVs dürfen Aufklärung und Wirkung nur nach expliziter Rollen- und Freigabeentscheidung verbinden.
- `CampaignState` bleibt strategische Ressourcenautorität; MOOSE materialisiert und betreibt nur physische Missionsrepräsentationen.
- Die OMW-AAR-Orchestrierung darf MOOSE-Tankermechanik, FuelLow-/Dead-FSM, Mission-Cancel, Funk/TACAN, STN-Verwaltung oder Spawn-Lifecycle nicht parallel nachbauen.

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
- SPAWN-interne Template-STN-Kollisionsauflösung ohne erzwungenes `InitSTN(...)`;
- `UNIT:GetSTN()`;
- `GROUP:GetCallsign()`;
- `GROUP:GetFuelMin()`;
- `FLIGHTGROUP:Refuel(Coordinate)`;
- `FLIGHTGROUP:GetFuelMin()`;
- `FLIGHTGROUP:SetFuelLowThreshold(...)`;
- `FLIGHTGROUP:SetFuelLowRTB(...)`;
- `FLIGHTGROUP`-FSM `Dead` / `onafterDead` und projektspezifischer `OnAfterDead`-Callback;
- `OPSGROUP:SwitchCallsign(...)`;
- `OPSGROUP:SwitchRadio(...)`;
- `OPSGROUP:TurnOffRadio()`;
- `OPSGROUP:SwitchTACAN(...)`;
- `OPSGROUP:TurnOffTACAN()`;
- `COORDINATE:Get2DDistance(...)`;
- `COORDINATE:Get3DDistance(...)`;
- `OPSGROUP:Despawn(...)`.

Die älteren Integration-3-Beobachtungen bestätigen den damaligen expliziten Spawn-Callsign-Pfad. Der aktuelle Produktionscontroller verwendet `SPAWN:InitCallSign(...)` für eine **Transitidentität** und wechselt erst beim Track-Entry auf die veröffentlichte Station-Identität. Für Link-16 setzt OMW **keine** feste `SPAWN:InitSTN(...)` mehr. Der gepinnte SPAWN-Pfad übernimmt die Template-STN und löst Kollisionen intern über seine STN-Verwaltung; OMW ruft `_DATABASE` nicht auf. Nach dem Spawn liest OMW die tatsächlich materialisierte STN ausschließlich über `UNIT:GetSTN()` aus.

Die Methoden `SwitchCallsign`, `SwitchRadio`, `TurnOffRadio`, `SwitchTACAN`, `TurnOffTACAN`, `UNIT:GetSTN()` sowie der `Dead`-/`OnAfterDead`-Pfad sind im gepinnten Source verfügbar und werden im aktuellen Controller verwendet. Ihr konkreter Einsatz für Continuous-Core-Handover, STN-Readback und Aircraft-Loss ist **SOURCE_REVIEWED**, aber bis zum Acceptance-3-Lauf nicht `VALIDATED`.

Für `GROUP:GetFuelMin()` zeigte Integration-3 eine Timing-Grenze: unmittelbar im Materialisierungs-Callback kann die Methode den Sentinel `65535` liefern. Der korrigierte Harness `AAR-PRODUCTION-INTEGRATION-3R1` bewertet Fuel deshalb erst, wenn ein plausibler Fraction-Wert `0..1` vorliegt. Dieser Harness-only-Fix verändert den produktiven Controller nicht.

## 6. Receiver-zu-Tanker-Auswahl

`AIRWING:GetTankerForFlight(flightgroup)` filtert aktive Tanker zunächst nach kompatiblem Refuelling-System und sortiert anschließend nach 2D-Distanz. Eine OMW-spezifische FAST/SLOW-Klasse ist dort nicht vorhanden.

Für das externe OMW-AAR-Kernnetz gilt aktuell:

```text
LISA      FAST
MOE       FAST
MILHOUSE  SLOW
KRUSTY    SLOW
PATTY     SLOW
NELSON    FAST
```

MissionDemand erzeugt keinen dieser Tracks. Es wird gegen das Operationsgebiet und das Receiver-Profil auf einen kompatiblen **bereits betriebenen** Core-Track abgebildet. Der COMMANDER darf diese OMW-Rollenentscheidung nicht durch eine implizite Near-Tanker-Auswahl ersetzen. Ein nativer DCS-Donor-Override ist nicht genehmigt.

`FLIGHTGROUP:Refuel(Coordinate)` bleibt der MOOSE-Receiverpfad zum vorgesehenen Refuel-Waypoint; er bindet keine konkrete Tanker-ID.

## 7. FuelLow, Relief, Demand-Ende und externer Egress

`FLIGHTGROUP:New()` setzt im gepinnten Stand standardmäßig:

```text
FuelLow threshold = 25 %
FuelLow RTB = true
```

Für externe OMW-Tanker gilt:

```text
SetFuelLowRTB(false)
```

Der aktuelle Controller verbindet die öffentlichen MOOSE-FSM-/Mission-/Identity-Pfade mit einer kleinen OMW-Core-Orchestrierung:

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
-> no duplicate relief
-> continuous core coverage is restored by the relief/replacement

MissionDemand COMPLETE / CANCELLED / ABORTED:
-> demand ownership ends
-> continuous Core-Track remains active
-> no demand-end egress of the Core-Tanker
```

Vor Egress wird die Station-Identität entfernt. Am externen Gate erfolgt der kontrollierte `OPSGROUP:Despawn(...)`-Handoff. Der strategische CampaignState-Adapter recreditiert eine KC-135 erst nach diesem bestätigten Handoff.

## 8. Aircraft Loss und CampaignState

Der aktuelle Controller verwendet den source-reviewed `FLIGHTGROUP`-`Dead`-/`OnAfterDead`-Pfad zur Loss-Klassifikation:

```text
FLIGHTGROUP Dead
-> OMW OnAfterDead callback
-> strategic adapter OnLost
-> no AIRCRAFT_KC135 recredit
-> AIRCRAFT_KC135_LOST audit counter +1 exactly once
-> runtime/identity cleanup
-> replacement materialized while continuous core coverage remains required
```

Der Loss-Audit ist Teil des CampaignState-Ressourcenmodells und damit kein paralleles Bestandsbuch. `AIRCRAFT_KC135_LOST` ist ein kumulativer Audit-Zähler und niemals eine Verfügbarkeitsquelle.

Die DCS-Praxis dieses neuen Continuous-Core-Loss-/Replacement-Pfads ist noch nicht bestätigt. Bis dahin bleibt er `SOURCE_REVIEWED`.

## 9. Persistenz / Restore

`OMW_AAR_RuntimeIntegration.lua` bindet den bereits erzeugten oder wiederhergestellten **einzigen** CampaignState-Store an `OMW_AAR_CampaignStateAdapter` und `OMW_AAR_Controller`. Es erzeugt keine zweite Resource Authority. Nach der Adapterbindung startet es die kontinuierliche sechs-Track-Core-Abdeckung.

Bei `RESTORE` wird vor neuen AAR-Materialisierungen deterministisch reconciled:

```text
consumed AAR commitment + recorded loss
-> loss remains permanent

consumed AAR commitment + handoff/restart credit
-> already resolved, no duplicate credit

consumed AAR commitment + no handoff/loss/restart resolution
-> old physical DCS representation no longer exists after mission/server restart
-> one exact-once AIRCRAFT_KC135 restart credit
```

Der letzte Fall ist keine Behauptung eines geflogenen Handoffs, sondern Reconciliation eines flüchtigen Runtime-Objekts im count-basierten No-tail-Modell.

## 10. Operative AAR-Concurrency und aktuelle Verfügbarkeit

Die für bestimmte AI-Unterstützungsmissionen verwendete `2/2/4`-Begrenzung gilt **nicht** für das AAR-Kernnetz.

Produktiv gilt bis auf weiteres:

```text
sechs Core-Tracks gleichzeitig aktiv
kein globales AAR-Mission-Limit = 2
kein globales AAR-Aircraft-Limit = 4

pro Track maximal:
1 ACTIVE
1 RELIEF

bei gleichzeitigem Relief aller sechs Tracks:
bis zu 12 physische KC-135
```

Physisch noch vorhandene Egress-Tanker bleiben bis Handoff oder Loss echte Runtime-Repräsentationen. Die per-Track-Grenze verhindert eine dritte Materialisierung für denselben Track; eine globale AAR-Sperre zwischen unabhängigen Tracks existiert nicht.

Der strategische Pool `16/40` bleibt davon getrennt. Zusätzlich gilt weiterhin mindestens 60 s Materialisierungsabstand innerhalb derselben Source Domain; MANAS und AL UDEID dürfen parallel materialisieren.

Die kontinuierliche Verfügbarkeit aller sechs Tracks ist eine **vorläufige OMW-Betriebsentscheidung**, bis eine belastbare ATO-/Zeitfensterregel entwickelt und genehmigt wird. Sie ist keine Behauptung historisch nachgewiesener 24/7-CAS- oder 24/7-AAR-Abdeckung.

## 11. Acceptance-6 – bestätigter AAR-Kernpfad

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

- fünf KC-135 gleichzeitig im damaligen Test;
- Tankermissionen `EXECUTING`;
- SLOW/FAST Same-area mit 3.000 ft vertikaler Staffelung;
- A-10C, F-15E und F-16C Boom-AAR;
- FuelLow/Cancel/Egress/Off-map-Handoff als Grundmechanik.

Die spätere Eigentümerkorrektur stellt klar, dass für das heutige AAR-Kernnetz keine globale 2/2/4-Grenze gilt.

## 12. Integration-3 / 3R1 – belegte Grenzen

Integration-3 auf Commit `4a6bef1c8a5b8f67606762e10c516610f970e491` beobachtete praktisch sechs MissionDemand-Mappings, sechs area-spezifische KC-135-Templates, vier Same-source-Abstände von jeweils `60.0 s` und parallele MANAS-/AL_UDEID-Materialisierung.

Der korrigierte Harness `AAR-PRODUCTION-INTEGRATION-3R1` behebt reine Harness-False-Negatives und wurde nicht allein deshalb erneut in DCS ausgeführt.

`AAR-PRODUCTION-FINAL-ACCEPTANCE-1` und die Zwischenfassung Acceptance-2 sind kein akzeptierter Abschlusslauf. Sie deckten Entwicklungsfehler beziehungsweise eine noch nicht finalisierte Betriebsannahme auf. Positive Beobachtungen bleiben nur für die tatsächlich ausgeführten Teilpfade gültig.

## 13. Finaler gemeinsamer DCS-Integrationsscope

Der korrigierte Abschlusslauf ist:

```text
AAR-PRODUCTION-FINAL-ACCEPTANCE-3
```

Er prüft zusammenhängend:

- automatischer Start aller sechs Core-Tracks;
- `LISA=FAST`, `MOE=FAST`, `MILHOUSE/KRUSTY/PATTY=SLOW`, `NELSON=FAST`;
- vier MANAS- und zwei AL_UDEID-Initialmaterialisierungen mit >=60 s Same-source-Abstand und unabhängigen Source Domains;
- MissionDemand-Attach ohne zusätzliche Tankermaterialisierung;
- sechs gleichzeitige Reliefs, damit 6 ACTIVE + 6 RELIEF = 12 physische KC-135;
- keine globale AAR-2/2/4-Sperre, aber maximal `1 ACTIVE + 1 RELIEF` je Track;
- MOOSE-gesteuerte STN-Kollisionsauflösung mit `UNIT:GetSTN()`-Readback;
- Transit-/Station-Identity-Handover;
- CampaignState Consume und exact-once Handoff-Recredit;
- `COMPLETE`/`CANCELLED`/`ABORTED` ohne Core-Track-Shutdown;
- FuelLow-Relief ohne Doppelrelief;
- FLIGHTGROUP Dead -> `OnLost` -> permanenter Verlust ohne Recredit plus Ersatzmaterialisierung;
- Snapshot/Restore-Reconciliation, soweit im Testaufbau reproduzierbar.

Erst nach diesem dokumentierten DCS-Nachweis werden die neuen konkret bestätigten Methoden/Pfade in `VERIFIED-METHODS.md` als praktisch bestätigt ergänzt.
