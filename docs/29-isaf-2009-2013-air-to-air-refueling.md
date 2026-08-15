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
| WEST | `LISA` | RC-West / Shindand | FLEX | `MANAS` |
| CENTRAL | `MOE` | Swing / Reserve / Central Support | FLEX | `MANAS` |
| SOUTH-CENTRAL | `MILHOUSE` | A-10 Recovery / Kandahar Return | SLOW | `AL_UDEID` |
| SOUTHEAST | `KRUSTY` | A-10 Recovery East / Paktika / Sharana / Southeast | SLOW | `AL_UDEID` |
| EAST | `PATTY` | primärer A-10-/RC-East-Support | SLOW | `MANAS` |
| NORTHEAST | `NELSON` | primärer Fast-Jet-Support | FAST | `MANAS` |

Maschinenlesbar:

- `data/air-operations/aar/omw-2011-aar-operational-core.csv`

Verbindliche Rollen:

```text
NELSON    -> FAST -> F-15E / F-16C
PATTY     -> SLOW -> A-10C
MILHOUSE  -> SLOW -> A-10 Recovery / Kandahar Return
KRUSTY    -> SLOW -> A-10 Recovery East / Southeast
MOE       -> FLEX / Swing
LISA      -> FLEX / RC-West
```

`LISA`, `MOE`, `MILHOUSE`, `KRUSTY`, `PATTY` und `NELSON` sind **Track-/Area-Namen**, keine individuellen Tankernamen. Die area-spezifischen KC-135-Templates tragen diese Namen nur zur eindeutigen Zuordnung von Initial Fuel und Track-Konfiguration. Ein Template bleibt immer an seine Area gebunden; ein `PATTY`-Template übernimmt beispielsweise niemals `KRUSTY`.

Für zwei unabhängige Tanker im selben AAR-Gebiet gilt weiterhin:

```text
SLOW unten
FAST oben
mindestens 3,000 ft vertikale Tanker-zu-Tanker-Staffelung
```

## 4. Aktuelle Verfügbarkeitsentscheidung

Bis eine historisch und operativ belastbare ATO-/Zeitfensterregel entwickelt und genehmigt ist, behandelt OMW die sechs ausgewählten Core-Tracks als **kontinuierlich verfügbar**.

Das ist ausdrücklich:

```text
vorläufige OMW-Betriebsentscheidung
!= historischer Nachweis einer 24/7-CAS-Abdeckung
!= historischer Nachweis einer 24/7-AAR-Abdeckung
!= Verpflichtung zu einem 24-Stunden-Endurance-Test
```

Eine spätere ATO-/Campaign-Schicht darf Track-Verfügbarkeit zeitlich steuern. Der Tanker-Lifecycle selbst soll keine historische Tag-/Nacht-Verfügbarkeit erraten.

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

Die dazu verwendeten MOOSE-Methoden sind source-reviewed; der vollständige neue Identity-Handover bleibt bis Acceptance-2 DCS-offen.

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

Gates und High-Transit-Profile:

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
-> scheduled/FuelLow/demand-end transition
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

OMW-Designbestände:

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

Diese Werte sind keine Behauptung einer historisch exakt zugewiesenen Aircraft Strength. Dokumentierte Google-Earth-Auswertungen zeigten für MANAS 11 sichtbare KC-135 (06/2010), 13 (03/2011), 9 (07/2011), 8 (07/2012) und für AL UDEID ungefähr 27 (07/2010) beziehungsweise 33 (08/2011). Die OMW-Werte 16/40 sind bewusst plausible Komposit-Designbestände.

MANAS und AL UDEID besitzen auf der DCS-Afghanistan-Karte keine nutzbare DCS-Airbase. Es werden deshalb **keine** künstlichen DCS-Airbases, MOOSE WAREHOUSEs oder AIRWINGs für diese Pools erzeugt.

Der strategische Vertrag ist count-basiert:

```text
AVAILABLE count
-> materialization consumes 1 AIRCRAFT_KC135
-> COMMITTED is represented by the consumed CampaignState transaction

confirmed off-map handoff
-> exact-once +1 AIRCRAFT_KC135
-> immediately AVAILABLE

aircraft loss
-> no AIRCRAFT_KC135 recredit
-> exact-once +1 AIRCRAFT_KC135_LOST audit counter
```

Es gibt keine strategischen Tail Numbers, kein Template-Inventar und **keinen regulären Turnaround-Timer**.

`AIRCRAFT_KC135_LOST` ist nur ein persistenter kumulativer Audit-Zähler. Er ist niemals Verfügbarkeits- oder Materialisierungsquelle.

## 8. CampaignState- und Runtime-Verdrahtung

Produktive Module:

```text
scripts/logistics/OMW_AARStrategicStock.lua
scripts/logistics/OMW_AirOpsCampaignStateInitializer.lua
scripts/air-operations/OMW_AAR_CampaignStateAdapter.lua
scripts/air-operations/OMW_AAR_RuntimeIntegration.lua
scripts/air-operations/OMW_AAR_Controller.lua
```

Verbindlicher Pfad:

```text
single authoritative CampaignState store
-> OMW_AAR_CampaignStateAdapter
-> OMW_AAR_Controller
-> MOOSE SPAWN / FLIGHTGROUP / AUFTRAG
```

`OMW_AAR_RuntimeIntegration.Attach(...)` erzeugt keinen zweiten Store. Der Caller stellt den bereits über NEW oder RESTORE aufgebauten CampaignState-Store bereit. Bei RESTORE führt der Adapter die AAR-Reconciliation aus und wird danach in den Controller injiziert.

Adaptervertrag:

```text
CanMaterialize(selection)
OnMaterialized(selection, runtime)
OnHandoff(selection, runtime)
OnLost(selection, runtime, reason)
ReconcileRestore()
```

## 9. MOOSE-First-Runtimepfad

Gepinnter Stand:

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

Für Link-16 erzwingt OMW keine `SPAWN:InitSTN(...)` mehr. Im gepinnten `Moose.lua` übernimmt SPAWN die Template-STN und löst eine bereits belegte STN intern über seine eigene STN-Verwaltung. OMW ruft `_DATABASE` nicht auf. Nach der Materialisierung liest der Controller die tatsächlich gesetzte STN über die öffentliche Wrapper-Methode `UNIT:GetSTN()` und verwendet sie nur als Runtime-Telemetrie/Identitätsprüfung.

Die MOOSE-Details und Evidenzgrenzen stehen in [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md) und [`OMW-MOOSE-CLASS-INDEX`](moose/PROJECT-CLASS-INDEX.md). Neue Relief-/Identity-/Dead-/STN-Readback-Pfade bleiben bis zum DCS-Nachweis `SOURCE_REVIEWED`.

## 10. Relief-, FuelLow- und Demand-End-Lifecycle

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
```

MissionDemand-Ende – Eigentümerentscheidung A:

```text
last demand COMPLETE / CANCELLED / ABORTED
-> close only that Area/Profile station immediately
-> remove queued relief for that station
-> ACTIVE Egress
-> RELIEF_INBOUND Egress
-> no further relief cycle for that station
```

Existiert noch ein anderer aktiver Demand für dieselbe Area-/Profil-Station, bleibt diese Station aktiv. Unabhängige Tracks werden durch das Demand-Ende eines anderen Tracks nicht geschlossen oder übernommen.

## 11. Aircraft Loss

Der gepinnte MOOSE-Stand besitzt den `FLIGHTGROUP`-`Dead`-/`onafterDead`-FSM-Pfad. Der aktuelle Controller nutzt einen `OnAfterDead`-Callback für den AAR-Loss-Vertrag:

```text
FLIGHTGROUP Dead
-> OnAfterDead
-> strategic adapter OnLost
-> no AIRCRAFT_KC135 recredit
-> AIRCRAFT_KC135_LOST +1 exactly once
-> runtime and transit-identity cleanup
-> replacement only if station demand remains
```

Das ist MOOSE-first source-reviewed. Der konkrete AAR-Loss-Pfad ist noch nicht DCS-validiert.

## 12. Snapshot / Restore

CampaignState persistiert Ressourcenstände, Transaktionen und idempotente Resource-Credits. Der Adapter reconciled AAR-Commitments bei Restore vor neuer Materialisierung:

```text
consumed commitment + loss credit
-> permanent loss remains

consumed commitment + handoff/restart credit
-> already resolved

consumed commitment without handoff/loss/restart credit
-> previous transient DCS representation no longer exists after restart
-> exact-once AIRCRAFT_KC135 restart credit
```

Die Restore-Recreditierung ist **kein historischer oder physischer Handoff-Nachweis**. Sie ist die deterministische Auflösung einer nicht mehr existierenden transienten DCS-Repräsentation im count-basierten No-tail-Modell.

Grenze: Wird ein Tanker zerstört und fällt der Server aus, bevor das Dead-/Loss-Ereignis in einen Snapshot gelangt, kann Restore diesen nicht persistierten Verlust nicht nachträglich beweisen.

## 13. Operative AAR-Concurrency

Die für bestimmte **AI-Unterstützungsmissionen** bekannte `2/2/4`-Regel gilt **nicht** für das AAR-Kernnetz.

Produktiv gilt:

```text
6 Core-Tracks dürfen gleichzeitig aktiv sein

kein globales AAR-Mission-Limit = 2
kein globales AAR-Aircraft-Limit = 4

pro Track maximal:
1 ACTIVE
1 RELIEF

wenn auf allen sechs Tracks gleichzeitig Relief läuft:
6 ACTIVE + 6 RELIEF = bis zu 12 physische KC-135
```

Die per-Track-Grenze verhindert eine dritte Materialisierung für denselben Track. Sie verhindert nicht, dass andere Core-Tracks gleichzeitig fliegen. Physische Egress-Tanker bleiben bis Handoff oder Loss Runtime-Repräsentationen; für strategische Materialisierung bleibt der reale CampaignState-Bestand maßgeblich.

`16/40` ist strategischer Bestand und kein globales Spawnlimit. Der 60-s-Abstand pro Source Domain bleibt unabhängig davon gültig.

## 14. Belegter DCS-Stand

### 14.1 Acceptance-6

```text
Testdatum: 2026-08-14
Branch: agent/aar-rc-east-runtime-scope
Source/Builder commit: 29dbcd377603405292a2f37a682d6f6b5b19dcf8
BuilderVersion/TestId: AAR-KC135-RUNTIME-ACCEPTANCE-6
Bundle SHA-256: 354433730acd0fc1eee4a3fe817cfaa870a054f3374dfab85f9814edfd29b091
Mission: OMW_Template_v9_AirOps_rdy.miz
Mission SHA-256: 39da8370753e3ece055f0fd9f9dcc5dbeed2aa2eebe4540756931944f200963b
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Belegt:

- fünf KC-135 gleichzeitig im damaligen Stress-Test-Scope;
- Tankermissionen `EXECUTING`;
- Same-area SLOW/FAST mit 3.000 ft Staffelung;
- Boom-AAR mit A-10C, F-15E und F-16C;
- FuelLow -> Cancel -> Egress -> Gate -> Off-map-Handoff;
- Y-Band-TACAN-Grundpfad.

Die spätere Eigentümerkorrektur stellt klar, dass dieser Fünf-Tanker-Lauf nicht als Beleg einer globalen AAR-2/2/4-Grenze interpretiert werden darf.

### 14.2 Production Integration-3 / 3R1

Integration-3 auf Commit `4a6bef1c8a5b8f67606762e10c516610f970e491` beobachtete:

- sechs MissionDemand-Mappings;
- sechs area-spezifische Templates;
- damalige area-spezifische Callsigns;
- vier Same-source-Folgeabstände von `60.0 s`;
- parallele MANAS-/AL_UDEID-Materialisierung.

Die beiden False Negatives des Harness betrafen Callsign-Darstellung und einen zu frühen Fuel-Read. `3R1` korrigiert diese Harnessfehler und wurde auf Eigentümerentscheidung nicht allein deshalb erneut in DCS ausgeführt.

### 14.3 Final-Acceptance-1 – nicht akzeptiert

`AAR-PRODUCTION-FINAL-ACCEPTANCE-1` ist **kein** finaler PASS. Die beiden Versuche deckten nacheinander auf:

1. falsche Modulbindung in `RuntimeIntegration.Attach(...)` durch `:` statt `.`;
2. die unzulässige Übertragung der AI-Unterstützungsregel `2/2/4` auf AAR;
3. einen Fehlerpfad bei explizit erzwungener `SPAWN:InitSTN(...)`-Kollision.

Positive Beobachtungen dieser Läufe gelten nur für exakt tatsächlich ausgeführte Teilpfade, insbesondere den beobachteten NELSON-FuelLow/Egress/Handoff-Grundpfad und Restore-Reconciliation. Sie ersetzen Acceptance-2 nicht.

### 14.4 Owner-lokale Source-/Build-Checkpoints

Owner-Checkpoints bestätigen reale Pull-/Build-/Hash-Stände, jedoch kein DCS-Verhalten von nachfolgenden Änderungen.

## 15. Keine unnötigen Wiederholungstests

Für denselben gepinnten DCS-/MOOSE-Stand müssen nicht erneut isoliert bewiesen werden:

- KC-135 Spawn/Heading/Transit als Grundmechanik;
- Racetrack/EXECUTING;
- Boom-AAR A-10C/F-15E/F-16C;
- Y-Band-TACAN-Grundpfad;
- FAST/SLOW-Grundmechanik und 3.000-ft-Same-area-Staffelung;
- FuelLow/Cancel/Egress/Off-map-Handoff als Grundmechanik;
- reine 3R1-Harness-Korrekturen.

## 16. Genehmigter gemeinsamer Final-Acceptance-Scope

Der Projektinhaber hat den kombinierten AAR-Abschlusstest am 15.08.2026 ausdrücklich freigegeben. Nach den während Acceptance-1 gefundenen Fehlern ist der korrigierte Lauf:

```text
AAR-PRODUCTION-FINAL-ACCEPTANCE-2
```

Er prüft zusammenhängend:

1. CampaignState erkennt die unabhängigen MANAS-/AL-UDEID-Pools 16/40;
2. alle sechs Core-Tracks können gleichzeitig aktiv sein;
3. vier MANAS- und zwei AL_UDEID-Initialmaterialisierungen halten >=60 s Same-source-Abstand und beide Source Domains arbeiten unabhängig;
4. es existiert keine globale AAR-2-Missionen-/4-Aircraft-Sperre;
5. pro Track existieren höchstens 1 ACTIVE + 1 RELIEF;
6. gleichzeitiges Relief aller sechs Tracks erlaubt 6 ACTIVE + 6 RELIEF = 12 physische KC-135;
7. Transit-Callsigns und tatsächlich von MOOSE materialisierte STNs bleiben eindeutig;
8. Transit-/Station-Identity-Handover funktioniert ohne unzulässige Doppelidentität;
9. Scheduled/FuelLow Relief erzeugt höchstens einen inbound Relief je Track;
10. `COMPLETE`/`CANCELLED`/`ABORTED` schließt nur die betroffene letzte Demand-Station;
11. erfolgreicher External-Gate-Handoff recreditiert exakt einmal;
12. `FLIGHTGROUP Dead` erzeugt `OnLost`, keinen Aircraft-Recredit und einen Loss-Audit;
13. Restore-Reconciliation erzeugt keine Doppelcredits und erhält dokumentierte Losses.

Testbeschleunigung darf nur Controller-beobachtete Track-Entry-Koordinaten und Relief-Zeitpunkte verändern. Flugzeuge werden nicht teleportiert. Egress und Off-map-Handoff bleiben an den produktiven External Gates.

Erst nach realem DCS-Nachweis werden die konkret bestätigten neuen Methoden/Pfade in `docs/moose/VERIFIED-METHODS.md` als praktisch bestätigt ergänzt.

## 17. Architekturgrenze

```text
MissionDemand / spätere ATO-Verfügbarkeit
-> OMW AAR Controller
-> per-track ACTIVE/RELIEF lifecycle
-> CampaignState strategic adapter
-> MOOSE physical tanker lifecycle
-> observed runtime result
-> CampaignState exact-once settlement
```

MOOSE Warehouse, AIRWING, DCS Warehouse, SPAWN und Tanker-Fuelzustand besitzen keine parallele strategische Ressourcenhoheit für die Off-map-KC-135-Pools.