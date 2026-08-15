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
source_branch: main
source_commit: b0af0093dd276aa07b8e011543e8a00435e518f8
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

DAVER-Evidenzgrenze: Die 2011er AIP enthält zwischen ENR-Route-/Navfix-Daten und ENR 1.10 eine widersprüchliche DAVER-Koordinate. OMW verwendet für diesen Stand die bereits projektseitig verwendete M375-/Navfix-Koordinate `N29°34'18" E64°40'36"`. Die Quelleninkonsistenz bleibt ausdrücklich offen und wird nicht als historisch aufgelöst behauptet.

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

`SetMissionIngressCoord(...)` führt die Materialisierung über den FIR-Ingress-Fix zum Tankerauftrag. `SetMissionEgressCoord(...)` führt nach Cancel zum FIR-Egress-Fix. Nach physischer Passage dieses Fixes ergänzt OMW über das öffentliche `FLIGHTGROUP:AddWaypoint(...)` den Weg zum External-Handoff-Punkt.

Acceptance-5 auf dem Arbeitsbranch `agent/aar-runtime-finalization` hat die natürliche FIR-Passage und den anschließenden External-Handoff für die beobachteten Pfade praktisch bestätigt. Diese Evidenz gilt nur für den exakten Acceptance-5-Stand und hebt den Gesamtpfad wegen des verbliebenen Scheduled-Relief-Fehlers nicht zur final akzeptierten Produktionsbaseline an.

## 7. Relief und FuelLow

### 7.1 Scheduled Relief

Verbindlicher Zielablauf:

```text
1 ACTIVE
-> nach geplantem Zyklus genau 1 RELIEF
-> Relief gleiche Callsign-Familie, andere n-1-Gruppennummer
-> Relief fliegt natürlich External Spawn -> FIR Fix -> Track
-> ETA <= 5 min armt nur den Handover
-> outgoing bleibt ACTIVE und behält Radio/TACAN
-> erst bei realer Track-Ankunft / enger Handover-Geometrie übernimmt Relief
-> dann outgoing Radio/TACAN OFF + Cancel/Egress
-> outgoing passiert FIR Egress Fix
-> External Handoff / recredit / despawn
-> wieder 1 ACTIVE
```

Acceptance-5 zeigte, dass der Controller auf Commit `877f0c15c0b46dc8d08f39f7cdcde36e065563b5` das 5-Minuten-Gate noch falsch behandelt: Bei `etaSec=297` und `distanceNm=24.7` wurde der outgoing MILHOUSE-Tanker bereits auf Egress geschickt und der Relief wenige Sekunden später als Station Owner aktiviert. Dieser Ablauf ist **nicht** akzeptiert, obwohl der Harness formal `RESULT PASS` erreichte.

### 7.2 FuelLow

FuelLow bleibt bewusst von Scheduled Relief getrennt:

```text
ACTIVE FuelLow
-> vorhandenen Relief wiederverwenden oder genau einen Emergency-Relief erzeugen
-> outgoing verlässt Station sofort und geht auf Egress
-> kein Warten auf ein 5-Minuten-Gate
-> vorübergehende Track-Lücke ist zulässig
-> Ersatz übernimmt denselben Track nach natürlicher Ankunft
```

Diese Trennung ist beabsichtigt: Beim FuelLow-Pfad hat der Schutz des Tankers vor Treibstoffmangel Vorrang vor lückenloser Stationsabdeckung.

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

Acceptance-5 injizierte den PATTY-Verlust absichtlich mit MOOSE `UNIT:Explode()`. Der beobachtete Pfad `Dead/OnAfterDead -> kein Recredit -> Loss-Audit -> natürlicher PATTY-Replacement über EGPAN` ist für diesen exakten Lauf positiv belegt.

Restore:

```text
CampaignState ExportSnapshot/Restore
-> persistierte Verluste bleiben erhalten
-> unresolved consumed AAR commitment wird genau einmal reconciled
-> bereits aufgelöste Commitments werden nicht doppelt credited
```

Ein in-process Snapshot/Restore-Test ist kein physischer Serverrestart.

## 12. Letzte Tests und Ergebnisse

### Acceptance-4

Acceptance-4 bestätigte unter anderem vier STANDARD-Tracks, Reserve-Semantik, stabile Callsign-Familien und FIR-Fixes, verwendete aber noch eine Track-Koordinaten-Manipulation zur Testbeschleunigung. Deshalb blieb der Lauf nur Teil-Evidenz.

### Acceptance-5 – realer Owner-DCS-Lauf 15.08.2026

```text
Arbeitsbranch: agent/aar-runtime-finalization
Commit: 877f0c15c0b46dc8d08f39f7cdcde36e065563b5
Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-5
Bundle SHA-256: b04ad66bc7525c65c89c5946eda5d598af7570235a2d7b2750c17cb86919f6e6
Controller SHA-256: 53af372b26aaf4f8afce5e27e3b7c70de52ad5a0606fc97705ac2b9f3bb6790c
RuntimeIntegration SHA-256: 598aa378d95f9dcde9aa982222d40070006c3c892ffa66668576c64ff07aa91b
Mission observed by DCS: OMW_Template_v9_AirOps_rdy.miz
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Kein Mission-SHA-256 wurde für diesen Lauf als reale Owner-Ausgabe dokumentiert; damit ist keine vollständige Acceptance-Provenienz gegeben.

Positiv beobachtet:

- vier STANDARD-Tracks kontinuierlich; LISA/MOE nur auf Demand;
- natürliche EGPAN-/DAVER-/PINAX-Ingress- und Egress-Passage;
- External Spawn/Handoff getrennt von FIR Entry/Exit;
- Callsign-Familien stabil und `n-1`-Relief korrekt;
- MILHOUSE Relief physisch über DAVER mit zunächst nur einem Station Owner;
- NELSON FuelLow Immediate-Egress und Replacement;
- LISA/MOE Reserve-Lifecycle inklusive External Handoff;
- absichtlicher PATTY-Loss und natürlicher Replacement;
- Harness formal `RESULT PASS`.

Nicht akzeptiert:

- Scheduled MILHOUSE Handover wechselte den Stationsbesitz bereits am 5-Minuten-Gate (`etaSec=297`, `distanceNm=24.7`) statt erst bei realer Track-Ankunft.

Daher gilt Acceptance-5 **nicht** als finaler Produktions-PASS. Die positiven Teilmechaniken bleiben Evidenz für diesen exakten Stand.

## 13. Aktuelle To-do-Liste bis zum Ziel

### Ziel

Eine produktionsreife, MOOSE-first AAR-Struktur für OMW mit:

```text
4 STANDARD-Tracks bis auf weiteres kontinuierlich
2 RESERVE-Tracks nur auf MissionDemand
stabile Callsign-Familien und eindeutige n-1-Sorties
External Spawn/Handoff getrennt von FIR Ingress/Egress
EGPAN / DAVER / PINAX als reale FIR-Fixes
Scheduled Relief ohne Versorgungslücke
FuelLow mit sicherem Immediate Egress
CampaignState exact-once consume/recredit/loss
keine sichtbaren Teleports/Spawns/Despawns
Airways optional/später
```

### Aktueller Arbeitsbranch

```text
agent/aar-runtime-finalization
```

PR #101 bleibt Draft und ist nicht mergebereit, solange der Scheduled-Relief-Handover nicht korrigiert und erneut akzeptiert ist.

### Noch zu erledigen

1. Scheduled-Relief-Controller korrigieren: 5-Minuten-Gate nur als `handover armed` behandeln.
2. Outgoing ACTIVE bis zur realen Track-Ankunft beziehungsweise eng definierten Handover-Geometrie des Reliefs auf Station halten.
3. Erst bei tatsächlicher Übernahme Radio/TACAN auf den Relief übertragen und danach outgoing `Cancel/Egress` auslösen.
4. FuelLow-Pfad bewusst unverändert lassen: Immediate Egress ohne 5-Minuten-Warten.
5. Acceptance-Harness korrigieren: vorzeitiges Abschalten des outgoing oder vorzeitiger Station-Owner-Wechsel zwischen 5-Minuten-Gate und Track-Ankunft muss FAIL sein.
6. Regressionen beibehalten: vier STANDARD / zwei RESERVE, Callsign-Familien, STN-Readback, 60-s-Source-Spacing, EGPAN/DAVER/PINAX, External Handoff, Reserve-Stop, PATTY-Loss/Replacement, CampaignState exact-once.
7. neuen Owner-DCS-Lauf mit vollständiger Mission-, Bundle-, Commit-, DCS- und MOOSE-Provenienz durchführen.
8. nur bei realem PASS `VERIFIED-METHODS.md` und Acceptance-Status hochstufen; danach PR #101 erst nach ausdrücklicher Owner-Freigabe Ready/Merge.
9. Lower-/Upper-Airway-Routing als separaten optionalen Folgeausbau behandeln; es blockiert den aktuellen AAR-Abschluss nicht.
