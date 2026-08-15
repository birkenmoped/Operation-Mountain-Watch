---
document_id: OMW-TEST-AAR-PRODUCTION-ACCEPTANCE-5
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - AAR-PRODUCTION-FINAL-ACCEPTANCE-5 test scope
  - natural FIR and real-track transit expectations for the final AAR acceptance run
  - observed Acceptance-5 partial runtime evidence and rejected scheduled-handover semantics
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

# AAR Production Final Acceptance 5

## Zweck

`AAR-PRODUCTION-FINAL-ACCEPTANCE-5` ersetzte Acceptance-4 als nächsten gemeinsamen DCS-Abschlusslauf. Acceptance-4 hatte positive Teilbeobachtungen geliefert, war aber kein Final-PASS.

Acceptance-5 beseitigte insbesondere die frühere Testbeschleunigung, bei der nach natürlichem FIR-Einflug der controller-beobachtete `runtime.trackCoord` auf die aktuelle Flugzeugposition verschoben wurde. Acceptance-5 verändert `runtime.trackCoord` nicht und teleportiert keine physischen Tanker.

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

Ein Relief-Tanker entsteht ausschließlich am zugeordneten externen Spawnpunkt und fliegt physisch über den FIR-Fix zum realen AAR-Track.

Dadurch existieren während des Relief-Transits notwendigerweise zeitweise zwei physische Sorties desselben Tracks, zum Beispiel:

```text
Shell2-1  MILHOUSE ACTIVE / station owner
Shell3-1  MILHOUSE RELIEF / inbound
```

Das ist keine doppelte Stationsbesetzung. Während des Inbound-Transits darf ausschließlich der aktuelle ACTIVE-Tanker Track-Radio/TACAN besitzen.

Nach Auswertung des realen Acceptance-5-Laufs gilt die präzisierte Scheduled-Relief-Regel:

```text
RELIEF ETA <= 5 min
-> Handover nur ARMEN / vorbereiten
-> outgoing bleibt ACTIVE und behält Station-Radio/TACAN
-> relief bleibt RELIEF / inbound

RELIEF erreicht den realen Track / die enge Handover-Geometrie
-> relief übernimmt Station-Radio/TACAN
-> erst jetzt outgoing Cancel/Egress
```

Das 5-Minuten-Gate ist damit **kein** Station-Owner-Wechsel und **kein** Egress-Gate für den planmäßig abzulösenden Tanker.

FuelLow ist ausdrücklich anders:

```text
ACTIVE FuelLow
-> outgoing verlässt die Station sofort und geht auf Egress
-> vorhandenen Relief wiederverwenden oder genau einen Emergency-Relief erzeugen
-> vorübergehende Track-Lücke ist zulässig
-> Ersatz übernimmt nach natürlicher Track-Ankunft
```

Beim FuelLow-Pfad gibt es bewusst kein 5-Minuten-Handover-Gate; Schutz des Tankers vor Treibstoffmangel hat Vorrang vor lückenloser Stationsabdeckung.

## Testbeschleunigung

Der Scheduled-Relief-Test beschleunigte ausschließlich den Zeitpunkt, ab dem MILHOUSE eine Ablösung anfordert. Vorher verblieb der Initialtanker mindestens 60 Simulationssekunden allein auf Station.

Nicht beschleunigt beziehungsweise nicht manipuliert wurden:

```text
physical aircraft position
FIR ingress passage
track coordinate
relief transit from external spawn to track
track-entry geometry
FIR egress passage
external handoff route
```

Der Harness besitzt keinen `forceControlledTrackEntry`-Pfad mehr.

## Acceptance-Ablauf des ausgeführten Stands

1. CampaignState Restore/Reconciliation und Pools 16/40 prüfen.
2. Nur die vier STANDARD-Tracks materialisieren; LISA/MOE bleiben ohne Demand absent.
3. Mindestens 60 s Same-source-Abstand prüfen; MANAS und AL_UDEID bleiben voneinander unabhängig.
4. Natürlichen FIR-Ingress der vier STANDARD-Tanker über EGPAN beziehungsweise DAVER abwarten.
5. Natürliche Ankunft an den tatsächlichen vier AAR-Tracks abwarten.
6. STANDARD-MissionDemand attach/end prüfen, ohne Track-Shutdown.
7. Einen Scheduled Relief auf MILHOUSE auslösen; Shell-Familie und unterschiedliche `n-1`-Gruppennummer prüfen.
8. Relief fliegt natürlich über DAVER zum realen MILHOUSE-Track. Während des Transits: zwei physische MILHOUSE-Sorties, aber nur ein Station Owner.
9. MILHOUSE-Handover, DAVER-Egress, externen Handoff, Despawn und exact-once Recredit des outgoing Tankers prüfen.
10. FuelLow-Relief separat auf NELSON prüfen; Replacement fliegt natürlich über EGPAN zum realen Track.
11. LISA und MOE per Demand starten, natürlichen PINAX-Ingress und natürliche Track-Ankunft prüfen.
12. Letzten Reserve-Demand beenden; PINAX-Egress und externen Handoff beider Reserve-Tanker prüfen.
13. PATTY-Verlust mit MOOSE `UNIT:Explode()` injizieren; kein Recredit, Loss-Audit +1 und natürliche Replacement-Sortie prüfen.
14. Finalzustand: vier STANDARD-Tanker aktiv, LISA/MOE absent, MANAS 13 mit Loss-Audit 1, AL_UDEID 38.

## Realer Owner-DCS-Lauf 15.08.2026

Ausgeführter Branch-/Build-Stand:

```text
Branch: agent/aar-runtime-finalization
Commit: 877f0c15c0b46dc8d08f39f7cdcde36e065563b5
Builder/Test-ID: AAR-PRODUCTION-FINAL-ACCEPTANCE-5
Bundle SHA-256: b04ad66bc7525c65c89c5946eda5d598af7570235a2d7b2750c17cb86919f6e6
Harness SHA-256: a2a7311a87537dae203f38f1683006b71ed026e6d7aab7d49d2f031f913e0b43
CycleControl SHA-256: 34ab413eb726ac6ab8c388fba43f262a41d56a378c137b362ea407dd462a422b
Controller SHA-256: 53af372b26aaf4f8afce5e27e3b7c70de52ad5a0606fc97705ac2b9f3bb6790c
RuntimeIntegration SHA-256: 598aa378d95f9dcde9aa982222d40070006c3c892ffa66668576c64ff07aa91b
Mission file observed by DCS: OMW_Template_v9_AirOps_rdy.miz
DCS: 2.9.28.26385 MT
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Kein Mission-SHA-256 wurde für diesen Lauf als reale Owner-Ausgabe dokumentiert. Der Lauf kann daher unabhängig vom Harness-Ergebnis nicht als vollständige `ACCEPTED_TECHNICAL_BASELINE` hochgestuft werden.

### Positiv beobachtet

- vier STANDARD-Tracks wurden automatisch betrieben; LISA/MOE blieben bis zum Demand Reserve;
- natürliche FIR-Ingress-/Egress-Passage funktionierte über EGPAN, DAVER und PINAX;
- External Spawn/Handoff blieb vom FIR-Fix getrennt;
- stabile Callsign-Familien und separate `n-1`-Gruppen funktionierten (`MILHOUSE`: `Shell2-1` / `Shell3-1`);
- während des MILHOUSE-Relief-Transits existierten zwei physische MILHOUSE-Sorties, aber zunächst nur ein Station Owner;
- NELSON FuelLow -> unmittelbarer Egress -> Replacement funktionierte; dieser Immediate-Egress-Pfad bleibt ausdrücklich gewollt;
- LISA/MOE Demand-Lifecycle inklusive PINAX-Egress und External Handoff funktionierte;
- PATTY-Verlust wurde absichtlich mit MOOSE `UNIT:Explode()` injiziert; `FLIGHTGROUP Dead/OnAfterDead`, kein Recredit, Loss-Audit und natürliche Replacement-Sortie wurden beobachtet;
- der Harness erreichte formal `RESULT PASS`.

### Relevanter Fehler trotz formalem Harness-PASS

Der Scheduled MILHOUSE Relief zeigte:

```text
RELIEF_FINAL_INGRESS etaSec=297 distanceNm=24.7
-> outgoing Shell2-1 STATION_IDENTITY_OFF + EGRESS_ORDERED
-> wenige Sekunden später Shell3-1 STATION_IDENTITY_ON
```

Damit wurde der outgoing Tanker bereits beim circa 5-Minuten-/24,7-NM-Gate vom Track geschickt, bevor der Relief-Tanker den realen Track erreicht hatte. Der Harness prüfte daher eine falsche Handover-Semantik und konnte trotz sichtbarer Versorgungslücke `RESULT PASS` melden.

**Folge:** Acceptance-5 ist kein final akzeptierter Produktions-PASS. Die positiven Teilbeobachtungen bleiben gültige Evidenz für genau die beobachteten Mechaniken; der Scheduled-Relief-Handover muss korrigiert und erneut getestet werden.

## Aktueller Zielzustand und Restarbeit

Ziel ist eine produktionsreife MOOSE-first AAR-Struktur mit vier bis auf weiteres kontinuierlichen STANDARD-Tracks, zwei demand-gesteuerten RESERVE-Tracks, natürlichem FIR-Routing, sauberem Scheduled Relief, sicherem FuelLow-Egress, CampaignState-exact-once-Accounting und ohne sichtbare Teleports/Off-map-Transitions.

Bis dahin noch erforderlich:

1. Scheduled-Relief-Controller korrigieren: `<=5 min` nur als Handover-Arming; outgoing bleibt ACTIVE.
2. Station-Owner-Wechsel erst bei realer Track-Ankunft beziehungsweise enger, explizit definierter Handover-Geometrie auslösen.
3. Outgoing Scheduled Tanker erst nach tatsächlicher Relief-Übernahme auf `Cancel/Egress` schicken.
4. FuelLow-Pfad unverändert getrennt halten: Immediate Egress, kein 5-Minuten-Warten.
5. Acceptance-Harness so ändern, dass er die kontinuierliche Station-Besetzung zwischen 5-Minuten-Gate und realer Relief-Ankunft explizit prüft und einen vorzeitigen Owner-Wechsel als FAIL wertet.
6. Regressionen für Callsign-Familie, FIR Ingress/Egress, External Handoff, Reserve-Lifecycle, Loss/Replacement und CampaignState-Accounting beibehalten.
7. neuen Owner-DCS-Lauf mit vollständiger Mission-/Bundle-/DCS-/MOOSE-Provenienz ausführen.
8. erst nach diesem realen PASS `VERIFIED-METHODS.md`, Acceptance-Status und PR-Readiness entsprechend hochstufen.
9. Lower-/Upper-Airway-Routing bleibt optionaler späterer Ausbau und blockiert den AAR-Abschluss nicht.

## DCS-Status

```text
VALIDATED: partial
FINAL ACCEPTANCE: no
NEXT DCS TEST REQUIRED: yes, after scheduled-relief handover correction
```
