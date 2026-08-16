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
  - OMW operational AAR standard/reserve roles and source-domain decisions
  - current production-facing FAST/SLOW, callsign-family, FIR-entry/exit, transit and fuel rules
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
source_branch: main
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# 29 – ISAF 2009–2013: Air-to-Air Refuelling und OMW-AAR-Baseline

## 1. Einordnung und Evidenzgrenze

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Der vollständige frühere Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt als Source-Evidence erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Ergänzend gelten:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](moose/AAR-LRC-TRANSIT.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)

AIP-Reporting-Points und Airways belegen die veröffentlichte Airspace-Struktur. Sie beweisen nicht, dass konkrete historische KC-135-Sorties exakt diesen Routen folgten. OMW-Callsigns, Tracks, Verfügbarkeitsregeln, Transitwerte, Fuel-Schwellen und Designbestände sind Projektentscheidungen, soweit nicht ausdrücklich anders gekennzeichnet.

## 2. Verbindliche Track-Geometrie

Die produktive Track-Geometrie steht in:

```text
data/air-operations/aar/omw-2011-aar-areas.csv
data/air-operations/aar/omw-2011-aar-areas.geojson
```

Alle 19 Areas bleiben als Geometrien erhalten. Die sechs operativen Areas sind Track-/Area-Namen, keine Tankernamen. KC-135-Templates tragen die Area im Namen zur eindeutigen Konfiguration und bleiben an ihre Area gebunden.

## 3. Operatives AAR-Netz

| Area | Rolle | Profil | Source | Verfügbarkeit | FIR Fix | Callsign-Familie |
|---|---|---|---|---|---|---|
| `NELSON` | primärer Fast-Jet-Support | FAST | MANAS | STANDARD | EGPAN | Texaco |
| `PATTY` | primärer A-10-/RC-East-Support | SLOW | MANAS | STANDARD | EGPAN | Texaco |
| `MILHOUSE` | A-10 Recovery / Kandahar Return | SLOW | AL_UDEID | STANDARD | DAVER | Shell |
| `KRUSTY` | A-10 Recovery East / Southeast | SLOW | AL_UDEID | STANDARD | DAVER | Arco |
| `LISA` | RC-West / Shindand | FAST | MANAS | RESERVE | PINAX | Texaco |
| `MOE` | Swing / Reserve / Central Support | FAST | MANAS | RESERVE | PINAX | Texaco |

Maschinenlesbar:

- `data/air-operations/aar/omw-2011-aar-operational-core.csv`

Bis eine belastbare ATO-/Zeitfensterregel entwickelt und genehmigt ist, laufen die vier STANDARD-Tracks kontinuierlich. `LISA` und `MOE` sind RESERVE und werden nur bei passendem MissionDemand materialisiert. Das Ende des letzten zugehörigen Demands ordnet Egress an.

## 4. Tankeridentität und kalibrierte Fuel-Werte

Ein physischer Tanker behält seine Callsign-Familie und konkrete `n-1`-Gruppenidentität während seiner gesamten Sortie. Relief ist eine neue 1-Ship-Gruppe derselben Familie mit anderer freier Gruppennummer.

```text
NELSON/PATTY/LISA/MOE -> Texaco n-1
KRUSTY                 -> Arco n-1
MILHOUSE               -> Shell n-1
```

Track-Identität besteht aus Area, Funkfrequenz und TACAN. Radio/TACAN werden nur beim Stationsbesitz aktiviert und vor Egress deaktiviert.

| Area | Frequenz | TACAN | Initial Fuel | FuelLow |
|---|---:|---|---:|---:|
| `NELSON` | 384.400 AM | 47Y `NEL` | 91.4067 % | 24 % |
| `PATTY` | 237.300 AM | 48Y `PAT` | 91.4067 % | 26 % |
| `LISA` | 235.900 AM | 50Y `LIS` | 91.4067 % | 35 % |
| `MOE` | 243.400 AM | 52Y `MOE` | 91.4067 % | 31 % |
| `KRUSTY` | 258.300 AM | 42Y `KRU` | 79.4558 % | 36 % |
| `MILHOUSE` | 272.600 AM | 58Y `MIL` | 79.4558 % | 36 % |

Die Initial-Fuel-Werte bilden den virtuellen Flug von MANAS beziehungsweise AL_UDEID bis zum jeweiligen External Spawn ab. Im gepinnten MOOSE-Stand ist keine öffentliche `SPAWN:InitFuel(...)`-Methode nachgewiesen. Der Controller führt die Werte daher als verbindlichen Konfigurationsvertrag/Metadatum; die physische Fuel-Menge der KC-135-Templates muss im Mission Editor entsprechend gesetzt werden.

FuelLow wurde aus real gemessenem `TRACK_DEPARTURE -> EXTERNAL_HANDOFF`-Verbrauch, virtuellem `EXTERNAL_HANDOFF -> Source Base`-Verbrauch und einer 45-Minuten-Reserve berechnet. Der geplante Landing-Fuel-Floor von 13,000 lb wird dabei nicht unterschritten. Die Triggerwerte sind konservativ auf volle Prozent aufgerundet.

Für Link-16 erzwingt OMW keine `SPAWN:InitSTN(...)`. Die gepinnte MOOSE-SPAWN-Implementierung verwaltet Template-STN-Kollisionen; OMW liest die materialisierte STN über `UNIT:GetSTN()` nur als Runtime-Telemetrie/Identitätsprüfung.

## 5. External Spawn/Handoff versus FIR Ingress/Egress

```text
EXTERNAL SPAWN
= technischer Materialisierungspunkt außerhalb der Kabul FIR

FIR INGRESS FIX
= veröffentlichter Eintritt in die Kabul FIR

TRACK
= AAR Area / Racetrack

FIR EGRESS FIX
= veröffentlichter Austritt aus der Kabul FIR

EXTERNAL HANDOFF / DESPAWN
= technischer Abschluss außerhalb der Kabul FIR
```

Produktiver Pfad:

```text
External Spawn
-> FIR Ingress Fix
-> AAR Track
-> FIR Egress Fix
-> External Handoff
-> Despawn / exact-once strategic settlement
```

Zuordnung:

```text
NELSON / PATTY    -> EGPAN
KRUSTY / MILHOUSE -> DAVER
LISA / MOE        -> PINAX
```

External Points:

```text
MANAS:     N38.83163 E70.95271
AL_UDEID:  N28.90264890 E64.61166667
```

FIR-Fixes:

```text
EGPAN: N38°25'00" E70°44'00"
PINAX: N37°15'00" E69°06'00"
DAVER: N29°34'18" E64°40'36"
```

DAVER-Evidenzgrenze: Die 2011er AIP enthält zwischen ENR-Route-/Navfix-Daten und ENR 1.10 eine widersprüchliche DAVER-Koordinate. OMW verwendet die projektseitig etablierte M375-/Navfix-Koordinate. Die Quelleninkonsistenz bleibt offen.

Vollständiges Lower-/Upper-Airway-Routing zwischen FIR-Fix und Track bleibt optional/später und blockiert die aktuelle AAR-Baseline nicht.

## 6. Kalibrierter Transitvertrag

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Produktiver Geschwindigkeitsvertrag:

```text
SPAWN:InitSpeedKnots(480) = initiale In-Air-Materialisierung
route speed 300 kt        = Transit-Routenkommando
track speed               = area-/profile-spezifischer Missionswert
```

Directional LRC:

```text
MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340
```

Kein routinemäßiger weight-/fuel-basierter Step-Climb.

Die Track-Höhe wird nach source-reviewtem MOOSE-Verhalten explizit gesetzt:

```lua
mission:SetMissionAltitude(profile.altitudeFt)
```

Damit wird das für den ORBIT-Pfad beobachtete 90-Prozent-Default nicht als OMW-Track-Höhe übernommen.

Der optionale 60-NM-Late-Approach ist **nicht** Produktionsanforderung und wird nicht implementiert. Candidate 3 ersetzte den akzeptierten FIR-Ingress unzulässig und ist verworfen; Candidate 4 stellte den FIR-Vertrag wieder her, der zusätzliche UID-basierte Late-Approach-Adapter scheiterte jedoch im realen DCS-Lauf.

## 7. MOOSE-first Routing und Fuel-Lifecycle

Produktiv relevant und im gepinnten Source geprüft:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionAltitude(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
SPAWN:InitSpeedKnots(...)
UNIT:GetSTN()

FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:SetFuelLowThreshold(...)
FLIGHTGROUP:SetFuelLowRTB(false)
FLIGHTGROUP FuelLow
FLIGHTGROUP Dead / OnAfterDead

OPSGROUP:SwitchRadio(...)
OPSGROUP:TurnOffRadio()
OPSGROUP:SwitchTACAN(...)
OPSGROUP:TurnOffTACAN()
OPSGROUP:Despawn(...)

COORDINATE:Get2DDistance(...)
SCHEDULER:New(...)
```

`SetMissionIngressCoord(...)` führt über den FIR-Ingress-Fix zum Auftrag. `SetMissionEgressCoord(...)` führt nach Cancel zum FIR-Egress-Fix. Nach physischer Passage ergänzt OMW über `FLIGHTGROUP:AddWaypoint(...)` den External-Handoff-Punkt.

## 8. Relief und MissionDemand

Scheduled Relief:

```text
1 ACTIVE
-> genau 1 RELIEF
-> gleiche Callsign-Familie, andere n-1-Gruppennummer
-> natürliche Route External Spawn -> FIR Fix -> Track
-> ETA <= 5 min armt nur Handover
-> outgoing bleibt ACTIVE bis reale Track-Ankunft
-> erst dann Station Owner wechseln, Radio/TACAN übertragen und outgoing Cancel/Egress
```

FuelLow bleibt bewusst getrennt:

```text
ACTIVE FuelLow
-> vorhandenen Relief wiederverwenden oder genau einen Emergency-Relief erzeugen
-> outgoing verlässt Station sofort und geht auf Egress
-> kein Warten auf Handover-Gate
```

STANDARD-Demand-Ende schließt den kontinuierlichen Track nicht. RESERVE schließt nach Ende des letzten Demands und ordnet vorhandenen ACTIVE/RELIEF auf Egress.

## 9. Strategische Pools und CampaignState

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

CampaignState bleibt alleinige strategische Ressourcenautorität. MOOSE SPAWN/FLIGHTGROUP/AUFTRAG sind physische Repräsentationen.

```text
materialization
-> consume 1 AIRCRAFT_KC135

confirmed external handoff
-> exact-once +1 AIRCRAFT_KC135

aircraft loss
-> kein Aircraft-Recredit
-> exact-once +1 AIRCRAFT_KC135_LOST audit counter
```

Kein per-tail-Inventar, kein regulärer strategischer Turnaround-Timer und keine parallele Ressourcenhoheit in WAREHOUSE/AIRWING/DCS Warehouse/SPAWN.

## 10. Concurrency und Source Spacing

```text
Standard steady state: 4 Tanker
Reserve: +1 Tanker je geöffnetem Reserve-Track
pro Track maximal: 1 ACTIVE + 1 RELIEF
```

```text
MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

Für AAR gilt keine globale `2/2/4`-Grenze aus anderen AI-Unterstützungsmissionen.

## 11. DCS-Evidenz

### 11.1 Production Final Acceptance

Der dokumentierte Acceptance-Stand auf `agent/aar-runtime-finalization` bestätigte die Produktionsarchitektur einschließlich vier STANDARD-/zwei RESERVE-Tracks, Scheduled-Relief-Handover erst bei Track-Ankunft, FuelLow Immediate Egress, FIR-Fixes, External Handoff, Loss/Replacement und CampaignState exact-once Accounting. Die genaue Provenienz steht in `docs/moose/VERIFIED-METHODS.md`.

### 11.2 AAR Fuel Telemetry Candidate 5 – 16.08.2026

```text
Branch: agent/aar-fuel-telemetry-calibration
Source commit: 40965420d4c6dea7a6b0fa27b4e3cd80d2a2b26a
Builder/Test-ID: AAR-FUEL-TELEMETRY-5
Mission: OMW_Template_v10_AirOps_rdy.miz
Mission SHA-256: 9dbff62a28e858d6eaf85d9037399dd591dd64edeccbe39bc74ecc63c43b6ca3
Bundle SHA-256: dd2386bd5bb2b0d2f89ac4e225a2e76ab171df1008f1d46eda16a9757c592a94
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Result: PASS
```

Endmarker:

```text
RESULT PASS allTracks=6 samplesPerTrack=6
points=SPAWN,INGRESS,TRACK,TRACK_DEPARTURE,FIR_EGRESS,EXTERNAL_HANDOFF
fuelLowExcluded=true
```

Der Lauf bestätigt die sechs vollständigen Messpfade bis External Handoff und liefert die Outbound-Basis für die genehmigten FuelLow-Werte. Er bestätigt noch nicht die **anschließend promovierte Produktionsquelle**; dafür ist ein neuer Production-Acceptance-Lauf erforderlich.

## 12. Aktueller Produktionskandidat und verbleibendes Gate

Vom Projektinhaber am 16.08.2026 genehmigte Promotion:

```text
Spawn initialization: 480 kt
Transit route:         300 kt

MANAS -> Afghanistan:      FL340
Afghanistan -> MANAS:      FL350
AL_UDEID -> Afghanistan:   FL350
Afghanistan -> AL_UDEID:   FL340

Exact track mission altitude: enabled
60-NM late approach: not required / not implemented

Initial Fuel:
MANAS:     91.4067 %
AL_UDEID:  79.4558 %

FuelLow:
NELSON:    24 %
PATTY:     26 %
LISA:      35 %
MOE:       31 %
MILHOUSE:  36 %
KRUSTY:    36 %
```

Vor finaler Produktionsfreigabe verbleibt:

```text
1. lokaler Build und Hash-Prüfung des promovierten Remote-Commits;
2. Mission-Editor-Anpassung der sechs KC-135-Template-Fuelwerte durch den Projektinhaber;
3. neuer DCS-Lauf mit vollständiger Commit-/Mission-/Bundle-/DCS-/MOOSE-Provenienz;
4. Regression der bestehenden AAR-Lifecycle-Gates;
5. erst danach Status des promovierten Produktionsstands auf VALIDATED anheben.
```
