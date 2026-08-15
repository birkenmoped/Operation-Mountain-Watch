---
document_id: OMW-TEST-AAR-PRODUCTION-INTEGRATION
status: PLANNED
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR MissionDemand production-integration test scope
  - combined production-finalization acceptance scope
not_authoritative_for:
  - repository-wide DCS runtime acceptance without complete acceptance provenance
  - CampaignState strategic inventory authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# AAR Production Integration

## Final-Acceptance-4

Der Projektinhaber hat den korrigierten Produktionsscope am 15.08.2026 freigegeben. `AAR-PRODUCTION-FINAL-ACCEPTANCE-4` ersetzt Acceptance-1/2/3 als geplanten Abschlusslauf. Frühere positive Beobachtungen bleiben nur Evidenz für das im jeweiligen Stand tatsächlich beobachtete Verhalten.

## Betriebsbaseline

Bis eine spätere ATO-/Zeitfensterregel beschlossen wird:

```text
STANDARD / kontinuierlich:
NELSON     FAST   MANAS      EGPAN   Texaco
PATTY      SLOW   MANAS      EGPAN   Texaco
MILHOUSE   SLOW   AL_UDEID   DAVER   Shell
KRUSTY     SLOW   AL_UDEID   DAVER   Arco

RESERVE / nur bei MissionDemand:
LISA       FAST   MANAS      PINAX   Texaco
MOE        FAST   MANAS      PINAX   Texaco
```

Die kontinuierliche Standardabdeckung ist eine vorläufige OMW-Betriebsentscheidung, kein historischer Nachweis einer 24/7-CAS- oder AAR-Abdeckung.

`LISA` und `MOE` werden nicht automatisch materialisiert. Der erste passende Demand öffnet den Reserve-Track; nach Ende des letzten zugehörigen Demands wird kein weiterer Relief erzeugt und vorhandene Tanker gehen auf Egress.

## Sortie- und Track-Identität

Ein physischer KC-135 behält seine Callsign-Familie während der gesamten Sortie. Jeder Tanker ist eine eigene 1-Ship-Gruppe und verwendet deshalb `n-1`, nicht `x-2` als zweiten Tanker derselben Gruppe.

```text
NELSON/PATTY/LISA/MOE -> Texaco n-1
KRUSTY                 -> Arco n-1
MILHOUSE               -> Shell n-1
```

Bei Relief bleibt die Callsign-Familie identisch; die neue 1-Ship-Gruppe erhält eine andere freie Gruppennummer. Radio und TACAN sind die Track-Identität und werden nur während Stationsbesitz aktiviert. Der Callsign selbst wird beim Track-Entry/Egress nicht mehr zwischen verschiedenen Familien umgeschaltet.

Link-16-STN bleibt MOOSE-gemanagt. OMW erzwingt keine `SPAWN:InitSTN(...)`; nach Materialisierung wird die tatsächlich gesetzte STN über `UNIT:GetSTN()` gelesen.

## Spawn, FIR und Handoff

Die Begriffe sind getrennt:

```text
external spawn
-> FIR ingress fix
-> AAR track
-> FIR egress fix
-> external handoff
-> despawn
```

Zuordnung:

```text
NELSON/PATTY    -> EGPAN
KRUSTY/MILHOUSE -> DAVER
LISA/MOE        -> PINAX
```

Die technischen External Points für MANAS und AL UDEID bleiben außerhalb der Kabul FIR. `AUFTRAG:SetMissionIngressCoord(...)` und `SetMissionEgressCoord(...)` verwenden die FIR-Fixes. Nach Erreichen des Egress-Fixes wird über `FLIGHTGROUP:AddWaypoint(...)` zum externen Handoff-Punkt weitergeroutet; erst dort erfolgt exact-once Recredit und Despawn.

Vollständiges Lower-/Upper-Airway-Routing ist **nicht** Bestandteil dieses Scopes und bleibt als späterer Ausbau offen.

DAVER-Hinweis: Für den aktuellen Produktionspfad wird die im Projekt bereits verwendete M375-/Navfix-Koordinate `N29°34'18" E64°40'36"` verwendet. Die 2011er ENR-1.10-Tabelle enthält dazu eine widersprüchliche DAVER-Koordinate; diese Quelleninkonsistenz wird separat reconciled und nicht stillschweigend als geklärt dargestellt.

## Concurrency und Spacing

Für AAR gilt keine globale AI-Support-`2/2/4`-Grenze.

```text
normaler Standardzustand: 4 physische KC-135
Reserve bei Bedarf: +1 je geöffnetem Reserve-Track
pro Track maximal: 1 ACTIVE + 1 RELIEF
```

Acceptance-4 erzeugt bewusst **keinen** künstlichen simultanen Relief aller Tracks. Scheduled Relief wird an genau einem Standard-Track geprüft; FuelLow-Relief separat an einem zweiten Track.

Materialisierung:

```text
MANAS: mindestens 60 s zwischen zwei Materialisierungen
AL_UDEID: mindestens 60 s zwischen zwei Materialisierungen
MANAS und AL_UDEID dürfen parallel materialisieren
```

## Acceptance-4 Scope

Der kombinierte Lauf prüft:

1. CampaignState-Pools MANAS 16 / AL_UDEID 40 und Restore-Reconciliation;
2. automatischen Start ausschließlich der vier Standard-Tracks;
3. `LISA` und `MOE` bleiben ohne Demand unbesetzt;
4. Same-source-Spacing >=60 s und unabhängige Source Domains;
5. natürliche Passage der FIR-Ingress-Fixes vor kontrollierter Track-Entry-Beschleunigung;
6. stabile Callsign-Familie vom Spawn bis Handoff, eindeutige `n-1`-Gruppennummern und MOOSE-STN;
7. Track-Radio/TACAN nur beim Stationsbesitz;
8. genau einen Scheduled Relief inklusive gleicher Callsign-Familie, FIR-Egress und External-Handoff/Recredit;
9. FuelLow-Relief auf einem anderen Standard-Track ohne Doppelrelief;
10. Standard-Demand-Ende ohne Track-Shutdown;
11. LISA- und MOE-Reserve-Start durch Demand, PINAX-Ingress, End-of-last-demand-Egress via PINAX und Rückkehr auf vier Standard-Tracks;
12. MOOSE `UNIT:Explode()` -> FLIGHTGROUP Dead/OnAfterDead -> kein Aircraft-Recredit + Loss-Audit + Ersatzmaterialisierung;
13. finaler Zustand: vier Standard-Tracks aktiv, LISA/MOE aus, kein Relief-Restbestand.

## Testbeschleunigung und Evidenzgrenze

```text
naturalFirIngressRequired = true
controlledTrackEntryAfterFir = true
singleScheduledRelief = true
physicalTeleport = false
naturalFirEgressAndExternalHandoffRequired = true
airwaysRouting = false
restoreMode = in-process CampaignState Snapshot/Restore
```

Der Harness verschiebt kein Flugzeug. Erst nachdem ein Tanker den produktiv konfigurierten FIR-Ingress-Fix physisch erreicht hat, wird ausschließlich die vom Controller für Track-Entry ausgewertete Runtime-Koordinate auf die aktuelle reale Flugzeugposition gesetzt. Dadurch wird nicht die natürliche Fix-Passage, aber die restliche echte Fix-to-track-Flugzeit verkürzt.

Egress-Fix, External-Handoff und strategisches Settlement werden nicht auf die aktuelle Position verschoben.

## Dateien

```text
mission/tests/aar-production-integration/src/02-aar-production-final-acceptance.lua
tools/build-aar-production-final-acceptance.ps1
mission/tests/aar-production-integration/dist/OMW_AAR_Production_Final_Acceptance.lua
```

`dist/` ist builder-generiert; keine automatische `.miz`-Mutation.

## Pflichtmarker Acceptance-4

```text
AAR_POLICY_BASELINE_PASS
RESTORE_RECONCILIATION_PASS
POOL_BASELINE_PASS
STANDARD_TRACKS_4_PASS
FIR_INGRESS_STANDARD_PASS
STABLE_CALLSIGN_AND_STATION_IDENTITY_PASS
STANDARD_DEMAND_END_PASS
SINGLE_SCHEDULED_RELIEF_PASS
FUEL_LOW_RELIEF_PASS
RESERVE_FIR_INGRESS_PASS
RESERVE_DEMAND_LIFECYCLE_PASS
LOSS_INJECTION_ARMED
AIRCRAFT_LOSS_PASS
FINAL_STEADY_STATE_PASS
RESULT PASS
```

Bis zum realen Acceptance-4-Lauf bleiben die neu korrigierten Standard/Reserve-, stabile-Callsign- und FIR-Fix-Routingpfade `SOURCE_REVIEWED` beziehungsweise `PLANNED`; sie dürfen nicht als `VALIDATED` bezeichnet werden.
