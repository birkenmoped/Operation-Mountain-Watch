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
  - current production-facing FAST/SLOW, callsign-family and FIR-entry/exit rules
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

Dieses Dokument ist die verbindliche AAR-Planungs- und Designreferenz für **Operation Mountain Watch**. Der vollständige frühere Quellen-, Tabellen-, KMZ- und CombatFlite-Auswertungstext bleibt als Source-Evidence erhalten:

- [`Legacy-AAR-/ACO-Quellenfassung`](evidence/source-records/legacy-29-isaf-aar-aco-source-capture.md)

Ergänzend gelten:

- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
- [`OMW-MOOSE-ISR-FAC-CAS-AAR`](moose/ISR-FAC-CAS-AAR.md)
- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)

AIP-Reporting-Points und Airways belegen die veröffentlichte Airspace-Struktur. Sie beweisen nicht, dass konkrete historische KC-135-Sorties exakt diesen Routen folgten. OMW-Callsigns, Tracks, Verfügbarkeitsregeln und Designbestände sind Projektentscheidungen, soweit nicht ausdrücklich anders gekennzeichnet.

## 2. Verbindliche Track-Geometrie

Die produktive Track-Geometrie steht in:

```text
data/air-operations/aar/omw-2011-aar-areas.csv
data/air-operations/aar/omw-2011-aar-areas.geojson
```

Alle 19 Areas bleiben als Geometrien erhalten. Die sechs hier behandelten operativen Areas sind Track-/Area-Namen, keine Tankernamen. Die KC-135-Templates tragen die Area im Namen nur zur eindeutigen Zuordnung von Initial Fuel und Track-Konfiguration; ein Template bleibt an seine Area gebunden.

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

### 3.1 Aktuelle Verfügbarkeitsentscheidung

Bis eine belastbare ATO-/Zeitfensterregel entwickelt und genehmigt ist, laufen die vier STANDARD-Tracks kontinuierlich. Das ist eine vorläufige OMW-Betriebsentscheidung und **kein** historischer Nachweis einer 24/7-CAS- oder 24/7-AAR-Abdeckung.

`LISA` und `MOE` sind RESERVE. Sie werden nur bei passendem MissionDemand materialisiert. Ende des letzten zugehörigen Demands beendet den Reserve-Track operativ und ordnet Egress an.

## 4. Tankeridentität

Ein physischer Tanker behält seine Callsign-Familie und konkrete `n-1`-Gruppenidentität während seiner gesamten Sortie. Ein Relief-Tanker ist eine neue 1-Ship-Gruppe derselben Familie und erhält eine andere freie Gruppennummer.

```text
NELSON/PATTY/LISA/MOE -> Texaco n-1
KRUSTY                 -> Arco n-1
MILHOUSE               -> Shell n-1
```

Ein `Shell`-Tanker wird weder auf Station noch bei Relief zu `Texaco`; ein `Arco`-Tanker bleibt `Arco`.

Track-Identität besteht aus Area, Funkfrequenz und TACAN. Radio/TACAN werden nur beim Stationsbesitz aktiviert und vor Egress deaktiviert. Der Callsign selbst wird beim Track-Entry/Egress nicht mehr zwischen verschiedenen Familien umgeschaltet.

| Area | Frequenz | TACAN | Initial Fuel | FuelLow |
|---|---:|---|---:|---:|
| `NELSON` | 384.400 AM | 47Y `NEL` | 96 % | 20 % |
| `PATTY` | 237.300 AM | 48Y `PAT` | 96 % | 21 % |
| `LISA` | 235.900 AM | 50Y `LIS` | 96 % | 24 % |
| `MOE` | 243.400 AM | 52Y `MOE` | 96 % | 22 % |
| `KRUSTY` | 258.300 AM | 42Y `KRU` | 90 % | 27 % |
| `MILHOUSE` | 272.600 AM | 58Y `MIL` | 90 % | 27 % |

Für Link-16 erzwingt OMW keine `SPAWN:InitSTN(...)`. Die gepinnte MOOSE-SPAWN-Implementierung verwaltet Template-STN-Kollisionen; OMW liest die materialisierte STN über `UNIT:GetSTN()` nur als Runtime-Telemetrie/Identitätsprüfung.

## 5. External Spawn/Handoff versus FIR Ingress/Egress

Die Begriffe sind verbindlich getrennt:

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

External Points bleiben:

```text
MANAS external point:     N38.83163 E70.95271
AL_UDEID external point:  N28.90264890 E64.61166667
```

FIR-Fixes im aktuellen Controller:

```text
EGPAN: N38°25'00" E70°44'00"
PINAX: N37°15'00" E69°06'00"
DAVER: N29°34'18" E64°40'36"
```

DAVER-Evidenzgrenze: Die 2011er AIP enthält zwischen ENR-Route-/Navfix-Daten und ENR 1.10 eine widersprüchliche DAVER-Koordinate. OMW verwendet für diesen Branch die bereits projektseitig verwendete M375-/Navfix-Koordinate `N29°34'18" E64°40'36"`. Die Quelleninkonsistenz bleibt ausdrücklich offen und wird nicht als historisch aufgelöst behauptet.

### 5.1 Airways

Vollständiges Lower-/Upper-Airway-Routing zwischen FIR-Fix und Track ist **optional/später**. Der aktuelle Produktionsscope erzwingt nur den korrekten FIR Entry/Exit Fix. Eine spätere Airways-Erweiterung muss die tatsächlichen 2011er Routen, Höhenbänder und Track-Abzweige separat prüfen.

## 6. MOOSE-first Routing

Gepinnter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Produktiv relevant und source-reviewed:

```text
AUFTRAG:NewTANKER(...)
AUFTRAG:SetMissionIngressCoord(...)
AUFTRAG:SetMissionEgressCoord(...)
AUFTRAG:Cancel()

SPAWN:InitCallSign(...)
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

`SetMissionIngressCoord(...)` führt die Materialisierung über den FIR-Ingress-Fix zum Tankerauftrag. `SetMissionEgressCoord(...)` führt nach Cancel zum FIR-Egress-Fix. Nach physischer Passage dieses Fixes ergänzt OMW über das öffentliche `FLIGHTGROUP:AddWaypoint(...)` den Weg zum External-Handoff-Punkt. Dieses konkrete zweistufige Egress-Routing bleibt bis zum Acceptance-4-Lauf `SOURCE_REVIEWED`, nicht `VALIDATED`.

## 7. Relief und FuelLow

Nominaler STANDARD-Track:

```text
1 ACTIVE
-> nach geplantem Zyklus genau 1 RELIEF
-> Relief gleiche Callsign-Familie, andere n-1-Gruppennummer
-> outgoing Radio/TACAN OFF + Cancel/Egress
-> Relief übernimmt Track
-> outgoing passiert FIR Egress Fix
-> external handoff / recredit / despawn
-> wieder 1 ACTIVE
```

Acceptance-4 erzwingt **keinen** simultanen Relief aller Tracks. Scheduled Relief wird an genau einem Standard-Track geprüft; FuelLow-Relief getrennt an einem anderen Track.

FuelLow:

```text
ACTIVE FuelLow
-> vorhandenen Relief wiederverwenden oder genau einen Relief erzeugen
-> outgoing Egress
-> kein Doppelrelief
-> Ersatz übernimmt denselben Track
```

## 8. MissionDemand

STANDARD:

```text
MissionDemand attach
-> vorhandenen Standard-Track nutzen

COMPLETE / CANCELLED / ABORTED
-> Demand endet
-> Standard-Track bleibt aktiv
```

RESERVE:

```text
erster passender Demand
-> Reserve-Track öffnen und materialisieren

weitere passende Demands
-> denselben Reserve-Track nutzen

letzter Demand endet
-> keine weitere Relief-Erzeugung
-> ACTIVE/RELIEF egress
-> FIR Egress Fix
-> External Handoff
-> Track wieder unbesetzt
```

## 9. Strategische Pools und CampaignState

```text
OFFMAP_MANAS
AIRCRAFT_KC135 = 16 count

OFFMAP_AL_UDEID
AIRCRAFT_KC135 = 40 count
```

CampaignState bleibt alleinige strategische Ressourcenautorität. MOOSE SPAWN/FLIGHTGROUP/AUFTRAG sind nur physische Repräsentationen.

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

Für AAR gilt **keine** globale `2/2/4`-Grenze aus AI-Unterstützungsmissionen.

```text
Standard steady state: 4 Tanker
Reserve: +1 Tanker je geöffnetem Reserve-Track
pro Track maximal: 1 ACTIVE + 1 RELIEF
```

Source Domain:

```text
MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

## 11. Aircraft Loss und Restore

Loss:

```text
FLIGHTGROUP Dead
-> OnAfterDead
-> Adapter OnLost
-> kein Aircraft-Recredit
-> Loss-Audit +1 exactly once
-> Ersatz nur, wenn der Track weiterhin benötigt/offen ist
```

Restore:

```text
CampaignState ExportSnapshot/Restore
-> persistierte Verluste bleiben erhalten
-> unresolved consumed AAR commitment wird genau einmal reconciled
-> bereits aufgelöste Commitments werden nicht doppelt credited
```

Ein in-process Snapshot/Restore-Test ist kein physischer Serverrestart.

## 12. Belegter DCS-Stand und offene Grenze

Acceptance-6 bestätigte für seinen exakten dokumentierten Stand Boom-AAR, SLOW/FAST, Y-Band-TACAN sowie FuelLow/Cancel/Egress/Off-map-Handoff-Grundmechanik. Integration-3 bestätigte sechs Demand-Mappings, area-spezifische Templates, 60-s-Same-source-Abstände und parallele MANAS-/AL_UDEID-Materialisierung.

Acceptance-1/2/3 sind **keine final akzeptierten Produktionsbaselines**. Sie deckten nacheinander RuntimeIntegration-, AAR-2/2/4-, STN-, Continuous-Core-, Callsign- und Testdesignfehler auf. Positive Beobachtungen gelten nur für die tatsächlich beobachteten Teilmechaniken des jeweiligen Stands.

## 13. Finaler Acceptance-Scope

Der nächste genehmigte Abschlusslauf ist:

```text
AAR-PRODUCTION-FINAL-ACCEPTANCE-4
```

Er prüft zusammenhängend:

1. Pools 16/40 und Restore-Reconciliation;
2. ausschließlich vier automatisch gestartete STANDARD-Tracks;
3. LISA/MOE bleiben ohne Demand aus;
4. Source-Domain-Spacing und Parallelität;
5. natürliche FIR-Ingress-Passage vor kontrollierter Track-Entry-Beschleunigung;
6. stabile Callsign-Familien und eindeutige `n-1`-Gruppenidentitäten;
7. Track-Radio/TACAN;
8. genau einen Scheduled Relief;
9. FuelLow-Relief auf einem zweiten Track;
10. Standard-Demand-Ende ohne Shutdown;
11. LISA/MOE Reserve-Demand-Lifecycle über PINAX;
12. FIR-Egress -> External-Handoff -> exact-once Recredit;
13. Loss ohne Recredit plus Ersatz bei weiter benötigtem Standard-Track;
14. final vier Standard-Tracks aktiv, beide Reserve-Tracks aus.

`VALIDATED` wird erst nach dokumentiertem realem DCS-PASS dieses exakten Branch-/Commit-/Bundle-/Mission-/MOOSE-Stands vergeben.
