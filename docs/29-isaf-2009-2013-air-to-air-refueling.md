---
document_id: OMW-AAR-ISAF-ACO
status: BINDING_PROJECT_DECISION
document_class: SOURCE_DERIVED_DESIGN_REFERENCE
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW AAR-area and ACO mission-design reference for Afghanistan 2009-2013
  - source-derived tanker-area geometry and planning constraints
  - OMW 2011-compatible corrected AAR production-planning geometry
  - OMW operational AAR core-area roles and source-domain decisions
  - current production-facing FAST/SLOW and external-origin rules
  - OMW off-map KC-135 strategic design stock and lifecycle semantics
  - AAR production integration status and remaining acceptance work
not_authoritative_for:
  - historical operational ACO authenticity
  - undocumented DCS behavior outside the recorded acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier AAR planning without consolidated runtime evidence and operational source-domain decisions
superseded_by:
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und OMW-AAR-Baseline

## 1. Einordnung und Evidenzgrenze

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Es konsolidiert die OMW-Entscheidungen zu Geometrie, Core-Areas, FAST/SLOW, External Origins, Tankeridentität, Relief, CampaignState und Acceptance.

Der vollständige frühere Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt als Source-Evidence erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Ergänzend gelten:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)

AIP-Reporting-Points und Airways belegen die veröffentlichte Airspace-Struktur. Sie beweisen nicht, dass konkrete historische KC-135-Sorties exakt diesen Routen folgten. OMW-Callsigns, Tracks, Verfügbarkeitsregeln und Designbestände sind Projektentscheidungen, soweit nicht ausdrücklich anders gekennzeichnet.

## 2. Verbindliche OMW-Geometrie

Die produktive Geometrie ist auf den für OMW maßgeblichen 2011er AIP-Luftraum abgestimmt:

```text
data/air-operations/aar/omw-2011-aar-areas.csv
data/air-operations/aar/omw-2011-aar-areas.geojson
```

Verbindlich:

- alle 19 Areas bleiben als Geometrien erhalten;
- die 35-NM-Grundform bleibt soweit möglich erhalten;
- die produktive Geometrie vermeidet die dokumentierten Konflikte mit relevanten Airways und Class-C-/Class-D-Lufträumen;
- die ursprünglichen `isaf-2009-2013-*`-Daten bleiben Source-Evidence;
- die drei LA/HAAR-Areas bleiben deaktiviert, solange kein genehmigter passender Tanker-/Mod-Pfad existiert.

## 3. Operatives AAR-Kernnetz

| Region | Area | Rolle | Receiver-Profil | Source Domain |
|---|---|---|---|---|
| WEST | `LISA` | RC-West / Shindand | FAST | `MANAS` |
| CENTRAL | `MOE` | Swing / Reserve / Central Support | FAST | `MANAS` |
| SOUTH-CENTRAL | `MILHOUSE` | A-10 Recovery / Kandahar Return | SLOW | `AL_UDEID` |
| SOUTHEAST | `KRUSTY` | A-10 Recovery East / Paktika / Sharana / Southeast | SLOW | `AL_UDEID` |
| EAST | `PATTY` | primärer A-10-/RC-East-Support | SLOW | `MANAS` |
| NORTHEAST | `NELSON` | primärer Fast-Jet-Support | FAST | `MANAS` |

Maschinenlesbar:

- `data/air-operations/aar/omw-2011-aar-operational-core.csv`

Verbindliche Rollen:

```text
LISA      -> FAST -> RC-West / Shindand
MOE       -> FAST -> Swing / Reserve / Central Support
MILHOUSE  -> SLOW -> A-10 Recovery / Kandahar Return
KRUSTY    -> SLOW -> A-10 Recovery East / Southeast
PATTY     -> SLOW -> A-10C / RC-East
NELSON    -> FAST -> F-15E / F-16C
```

`LISA`, `MOE`, `MILHOUSE`, `KRUSTY`, `PATTY` und `NELSON` sind **Track-/Area-Namen**, keine individuellen Tankernamen. Die area-spezifischen KC-135-Templates tragen diese Namen nur zur eindeutigen Zuordnung von Initial Fuel und Track-Konfiguration. Ein Template bleibt immer an seine Area gebunden.

## 4. Aktuelle Verfügbarkeitsentscheidung

Bis eine historisch und operativ belastbare ATO-/Zeitfensterregel entwickelt und genehmigt ist, behandelt OMW die sechs ausgewählten Core-Tracks als **kontinuierlich verfügbar**.

Das ist ausdrücklich:

```text
vorläufige OMW-Betriebsentscheidung
!= historischer Nachweis einer 24/7-CAS-Abdeckung
!= historischer Nachweis einer 24/7-AAR-Abdeckung
!= Verpflichtung zu einem 24-Stunden-Endurance-Test
```

MissionDemand nutzt einen kompatiblen bereits betriebenen Core-Track. MissionDemand startet oder beendet den Core-Track nicht. Eine spätere ATO-/Campaign-Schicht darf Track-Verfügbarkeit zeitlich steuern; der Tanker-Lifecycle selbst soll keine historische Tag-/Nacht-Verfügbarkeit erraten.

## 5. Produktive Station-Identitäten

| Area | Station-Callsign | Radio | TACAN | Initial Fuel | FuelLow |
|---|---|---:|---|---:|---:|
| `NELSON` | `Texaco 1-1` | 384.400 AM | 47Y `NEL` | 96 % | 20 % |
| `PATTY` | `Texaco 2-1` | 237.300 AM | 48Y `PAT` | 96 % | 21 % |
| `LISA` | `Texaco 3-1` | 235.900 AM | 50Y `LIS` | 96 % | 24 % |
| `MOE` | `Texaco 4-1` | 243.400 AM | 52Y `MOE` | 96 % | 22 % |
| `KRUSTY` | `Arco 2-1` | 258.300 AM | 42Y `KRU` | 90 % | 27 % |
| `MILHOUSE` | `Shell 2-1` | 272.600 AM | 58Y `MIL` | 90 % | 27 % |

Der produktive Controller trennt physische Transitidentität und veröffentlichte Station-Identität:

```text
TRANSIT
- reservierter Transit-Callsign je physischer Tankerrepräsentation
- tatsächlich von MOOSE materialisierte Link-16-STN
- Station-Radio OFF
- Station-TACAN OFF

ON STATION
- area-spezifischer Station-Callsign
- area-spezifische Frequenz
- area-spezifischer Y-TACAN

EGRESS
- Station-Radio OFF
- Station-TACAN OFF
- zurück auf Transit-Callsign
```

## 6. External Origins und Transit

```text
MANAS:
- LISA
- MOE
- PATTY
- NELSON

AL_UDEID:
- MILHOUSE
- KRUSTY
```

```text
MANAS gate:
N38.83163 E70.95271

AL_UDEID gate:
N28.90264890 E64.61166667

MANAS_WEST_HIGH:
ingress FL340
egress  FL330

MANAS_EAST_HIGH:
ingress FL330
egress  FL340

AL_UDEID_NORTH_HIGH:
ingress FL330
egress  FL340
```

Produktiver Pfad:

```text
External Gate
-> high transit
-> track entry
-> AAR station
-> scheduled/FuelLow transition
-> high egress
-> External Gate
-> controlled off-map handoff
```

Source-domain Materialisierung:

```text
MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

Der 60-s-Abstand ist **kein globales AAR-Concurrency-Limit**.

## 7. Strategische Off-map-KC-135-Pools

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

Die Werte sind plausible OMW-Komposit-Designbestände und keine Behauptung einer historisch exakt zugewiesenen Aircraft Strength.

Der strategische Vertrag ist count-basiert:

```text
AVAILABLE count
-> materialization consumes 1 AIRCRAFT_KC135

confirmed off-map handoff
-> exact-once +1 AIRCRAFT_KC135
-> immediately AVAILABLE

aircraft loss
-> no AIRCRAFT_KC135 recredit
-> exact-once +1 AIRCRAFT_KC135_LOST audit counter
```

Es gibt keine strategischen Tail Numbers, kein Template-Inventar und **keinen regulären Turnaround-Timer**. `AIRCRAFT_KC135_LOST` ist nur ein persistenter kumulativer Audit-Zähler.

## 8. CampaignState- und Runtime-Verdrahtung

```text
single authoritative CampaignState store
-> OMW_AAR_CampaignStateAdapter
-> OMW_AAR_RuntimeIntegration
-> OMW_AAR_Controller
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
```

`OMW_AAR_RuntimeIntegration.Attach(...)` erzeugt keinen zweiten Store. Nach Adapterbindung startet es die kontinuierliche sechs-Track-Core-Abdeckung über den Controller.

## 9. MOOSE-First-Runtimepfad

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Source-reviewed und im produktiven Scope relevant:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN template-STN collision handling without forced InitSTN
UNIT:GetSTN()

FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow callback
FLIGHTGROUP Dead / onafterDead
OnAfterDead callback override

OPSGROUP:SwitchCallsign(...)
OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:Get2DDistance(...)
COORDINATE:Get3DDistance(...)
SCHEDULER:New(...)
```

Für Link-16 erzwingt OMW keine `SPAWN:InitSTN(...)` mehr. Nach der Materialisierung liest der Controller die tatsächlich gesetzte STN über die öffentliche Wrapper-Methode `UNIT:GetSTN()` und verwendet sie nur als Runtime-Telemetrie/Identitätsprüfung.

## 10. Relief-, FuelLow- und Demand-Lifecycle

Nominal:

```text
ACTIVE
-> 3 h station cycle from actual takeover
-> RELIEF_INBOUND launched for approximately 5 min ETA at handover
-> outgoing station identity OFF + AUFTRAG Cancel/Egress
-> relief reaches track entry
-> station identity ON for relief
-> next 3 h cycle
```

FuelLow:

```text
ACTIVE FuelLow
-> use existing relief OR queue exactly one emergency relief
-> outgoing Cancel/Egress
-> no duplicate relief
-> continuous core coverage is restored by the replacement
```

MissionDemand-Ende:

```text
COMPLETE / CANCELLED / ABORTED
-> demand ownership ends
-> continuous core track remains active
-> no demand-end egress of the core tanker
```

## 11. Aircraft Loss

```text
FLIGHTGROUP Dead
-> OnAfterDead
-> strategic adapter OnLost
-> no AIRCRAFT_KC135 recredit
-> AIRCRAFT_KC135_LOST +1 exactly once
-> replacement materialized while continuous core coverage remains required
```

## 12. Snapshot / Restore

CampaignState persistiert Ressourcenstände, Transaktionen und idempotente Resource-Credits. Der Adapter reconciled konsumierte AAR-Commitments bei Restore vor neuer Materialisierung. Ein nicht aufgelöstes Commitment wird genau einmal als Restart-Reconciliation recreditiert; persistierte Verluste bleiben permanent.

Grenze: Ein physischer Verlust, der vor Serverausfall nicht persistiert wurde, kann im count-basierten No-tail-Modell nachträglich nicht beweissicher rekonstruiert werden.

## 13. Operative Concurrency

Für AAR gilt **keine** globale 2/2/4-Grenze.

```text
6 kontinuierliche Core-Tracks
pro Track maximal 1 ACTIVE + 1 RELIEF
maximal 12 physische KC-135 bei gleichzeitigem Relief aller sechs Tracks
```

Der strategische Bestand 16/40 bleibt davon getrennt. Physisch noch vorhandene Egress-Tanker zählen bis Handoff/Loss als Runtime-Repräsentation ihres bereits konsumierten strategischen Commitments.

## 14. Belegter DCS-Stand

Acceptance-6 bestätigte für den exakt dokumentierten Stand Tankermissionen bis `EXECUTING`, Boom-AAR A-10C/F-15E/F-16C, Same-area SLOW/FAST mit 3.000 ft Staffelung, Y-Band-TACAN und den FuelLow/Cancel/Egress/Off-map-Handoff-Grundpfad.

Production Integration-3 bestätigte sechs MissionDemand-Mappings, sechs area-spezifische Templates, vier Same-source-Folgeabstände von 60 s und parallele MANAS-/AL_UDEID-Materialisierung. Diese älteren Nachweise validieren nicht automatisch die neue kontinuierliche Core-/Relief-/Loss-Architektur.

## 15. Finaler gemeinsamer Acceptance-Scope

`AAR-PRODUCTION-FINAL-ACCEPTANCE-3` prüft zusammenhängend:

1. CampaignState 16/40;
2. automatischer Start aller sechs Core-Tracks;
3. `LISA=FAST`, `MOE=FAST`, `MILHOUSE/KRUSTY/PATTY=SLOW`, `NELSON=FAST`;
4. Source-domain spacing und Parallelität;
5. MissionDemand-Attach ohne zusätzliche Materialisierung;
6. Track-only Identity;
7. sechs gleichzeitige Reliefs mit bis zu 12 physischen KC-135;
8. Scheduled Relief und natural External-Gate-Handoff/Recredit;
9. Demand-Ende ohne Core-Track-Shutdown;
10. FuelLow-Relief ohne Doppelrelief;
11. Dead/OnLost ohne Aircraft-Recredit plus Ersatzmaterialisierung;
12. Restore-Reconciliation ohne Doppelcredit.

Die Testbeschleunigung verändert nur Controller-observed Track-Entry-Koordinaten und Relief-Zeitpunkte. Flugzeuge werden nicht teleportiert; der Egress-Handoff bleibt am produktiven External Gate.

## 16. Architekturgrenze

```text
continuous AAR core policy
-> OMW AAR Controller
-> CampaignState strategic adapter
-> MOOSE physical tanker lifecycle
-> observed runtime result
-> CampaignState exact-once settlement

MissionDemand
-> attaches to compatible core track
-> never owns strategic inventory
-> does not start/stop continuous core coverage
```

MOOSE Warehouse, AIRWING, DCS Warehouse und SPAWN besitzen keine parallele strategische Ressourcenhoheit für die Off-map-KC-135-Pools.
