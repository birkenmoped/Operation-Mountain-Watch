---
document_id: OMW-TEST-AAR-PRODUCTION-ACCEPTANCE-5
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR-PRODUCTION-FINAL-ACCEPTANCE-5 test scope
  - natural FIR and real-track transit expectations for the final AAR acceptance run
not_authoritative_for:
  - repository-wide DCS runtime acceptance without complete acceptance provenance
  - CampaignState strategic inventory authority
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by: []
source_branch: agent/aar-runtime-finalization
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AAR Production Final Acceptance 5

## Zweck

`AAR-PRODUCTION-FINAL-ACCEPTANCE-5` ersetzt Acceptance-4 als nächsten gemeinsamen DCS-Abschlusslauf. Acceptance-4 hat positive Teilbeobachtungen geliefert, ist aber kein Final-PASS.

Der neue Harness beseitigt insbesondere die missverständliche Testbeschleunigung, bei der nach natürlichem FIR-Einflug der controller-beobachtete `runtime.trackCoord` auf die aktuelle Flugzeugposition verschoben wurde. Acceptance-5 verändert `runtime.trackCoord` nicht.

## Produktive Baseline

STANDARD, bis zu einer später genehmigten ATO-/Zeitfensterlogik kontinuierlich betrieben:

```text
NELSON    FAST   MANAS      EGPAN   Texaco
PATTY     SLOW   MANAS      EGPAN   Texaco
MILHOUSE  SLOW   AL_UDEID   DAVER   Shell
KRUSTY    SLOW   AL_UDEID   DAVER   Arco
```

RESERVE, nur auf passenden MissionDemand:

```text
LISA      FAST   MANAS      PINAX   Texaco
MOE       FAST   MANAS      PINAX   Texaco
```

Lower-/Upper-Airway-Routing bleibt ausdrücklich späterer Scope.

## Physischer Relief-Grundsatz

Ein Relief-Tanker entsteht weiterhin ausschließlich am zugeordneten externen Spawnpunkt und fliegt physisch über den FIR-Fix zum realen AAR-Track.

Dadurch existieren während des Relief-Transits notwendigerweise zeitweise zwei physische Sorties desselben Tracks, zum Beispiel:

```text
Shell2-1  MILHOUSE ACTIVE / station owner
Shell3-1  MILHOUSE RELIEF / inbound
```

Das ist keine doppelte Stationsbesetzung. Während des Inbound-Transits darf ausschließlich der aktuelle ACTIVE-Tanker Track-Radio/TACAN besitzen. Erst im finalen Relief-Ingress wird der outgoing Tanker auf Egress geschickt; der Relief-Tanker übernimmt die Station erst am realen Track.

Acceptance-5 prüft deshalb explizit:

```text
physical MILHOUSE sorties during relief transit = 2
MILHOUSE station owners during relief transit = 1
```

## Testbeschleunigung

Der Scheduled-Relief-Test beschleunigt ausschließlich den Zeitpunkt, ab dem MILHOUSE eine Ablösung anfordert. Vorher verbleibt der Initialtanker mindestens 60 Simulationssekunden allein auf Station.

Nicht beschleunigt beziehungsweise nicht manipuliert werden:

```text
physical aircraft position
FIR ingress passage
track coordinate
relief transit from external spawn to track
track-entry geometry
FIR egress passage
external handoff route
```

Der Harness besitzt deshalb keinen `forceControlledTrackEntry`-Pfad mehr.

## Acceptance-Ablauf

1. CampaignState Restore/Reconciliation und Pools 16/40 prüfen.
2. Nur die vier STANDARD-Tracks materialisieren; LISA/MOE bleiben ohne Demand absent.
3. Mindestens 60 s Same-source-Abstand prüfen; MANAS und AL_UDEID bleiben voneinander unabhängig.
4. Natürlichen FIR-Ingress der vier STANDARD-Tanker über EGPAN beziehungsweise DAVER abwarten.
5. Natürliche Ankunft an den tatsächlichen vier AAR-Tracks abwarten.
6. STANDARD-MissionDemand attach/end prüfen, ohne Track-Shutdown.
7. Einen Scheduled Relief auf MILHOUSE auslösen; Shell-Familie und unterschiedliche `n-1`-Gruppennummer prüfen.
8. Relief fliegt natürlich über DAVER zum realen MILHOUSE-Track. Während des Transits: zwei physische MILHOUSE-Sorties, aber nur ein Station Owner.
9. Natürlichen MILHOUSE-Handover am Track sowie DAVER-Egress, externen Handoff, Despawn und exact-once Recredit des outgoing Tankers prüfen.
10. FuelLow-Relief separat auf NELSON prüfen; Replacement fliegt natürlich über EGPAN zum realen Track.
11. LISA und MOE per Demand starten, natürlichen PINAX-Ingress und natürliche Track-Ankunft prüfen.
12. Letzten Reserve-Demand beenden; PINAX-Egress und externen Handoff beider Reserve-Tanker prüfen.
13. PATTY-Verlust mit MOOSE `UNIT:Explode()` injizieren; kein Recredit, Loss-Audit +1 und natürliche Replacement-Sortie prüfen.
14. Finalzustand: vier STANDARD-Tanker aktiv, LISA/MOE absent, MANAS 13 mit Loss-Audit 1, AL_UDEID 38.

## Timeout

Der kombinierte Harness erhält 12 Simulationsstunden. Das ist bewusst länger als Acceptance-4, weil Acceptance-5 die physischen Transitstrecken zu den realen Tracks nicht mehr durch Track-Koordinaten-Manipulation abkürzt.

## DCS-Status

```text
VALIDATED: no
DCS test required: yes
```

Ein PASS darf erst nach dem realen Owner-DCS-Lauf mit dokumentierter Mission-, Bundle-, DCS- und MOOSE-Provenance gesetzt werden.
