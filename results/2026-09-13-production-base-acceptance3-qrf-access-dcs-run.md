---
document_id: OMW-FSSR-PRODUCTION-BASE-ACCEPTANCE3-QRF-ACCESS-DCS-RUN-2026-09-13
status: DIAGNOSTIC_FAIL
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - DCS runtime evidence for Acceptance 3 QRF ACCESS materialization attempt
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: f834e3b5c0416f143585541e2dd17496d1bc3f95
validated_in_dcs: false
---

# Production Base Acceptance 3 – QRF ACCESS DCS-Lauf, 2026-09-13

## Provenienz

Vom Projektinhaber vor dem Lauf real lokal gebaut und separat per SHA-256 geprüft:

```text
GitCommit: f834e3b5c0416f143585541e2dd17496d1bc3f95
ProductionBuilder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-7
QrfRuntime: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-QRF-RUNTIME-3
ProductionBundleSHA256: 83FD97FA8962CE835BE464B3536C27F5F0F309D6F5BA240D6AF4A71233D61B46
AcceptanceBuilder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-ACCEPTANCE-3-3
AcceptanceBundleSHA256: 922467FD9803E25CE5C09B8E98BC41F8D9CFAE5668960FED8D8FE53ED89E8690
MOOSERelease: 2.9.18
MOOSECommit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MooseLuaSHA256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
DCS: 2.9.29.27468 MT
```

## Ergebnis

Der Lauf ist `DIAGNOSTIC_FAIL`. Die QRF-ACCESS-Integration war unvollständig.

Jalalabad erreichte im Lauf nachweislich die vollständige Alarmkette bis zum QRF-Demand:

```text
siteId=JALALABAD_FENTY
perimeterStarted=true
proximity=true
incident=true
demandCount=1
qrfObserved=nil
```

Der physische QRF-Spawn scheiterte anschließend explizit im GroundRoadSpawnAdapter:

```text
[OMW][Ground.RoadSpawnAdapter] outbound road path unavailable entityId=BLUE_GROUND_HUB_JALALABAD_FENTY|QRF
```

Unmittelbar davor meldete die gepinnte MOOSE-Road-Path-Auflösung, dass kein gültiger Straßenpfad gefunden werden konnte. Damit ist der Fehler nicht als fehlender QRF-Bestand oder fehlender Incident zu klassifizieren. Der QRF-Runtime hatte den Incident-Zielpunkt direkt als `forwardCoordinate` für die Spawn-Straßengeometrie verwendet. Das entspricht nicht dem bereits akzeptierten Ground-Foundation-Vertrag, der einen road-qualifizierten outbound/approach anchor für die Materialisierungsrichtung verwendet.

Zusätzlich traten mindestens folgende harte Materialisierungsfehler auf:

```text
COP_FORTRESS:
  road snap exceeds limit
  unit=1
  distanceM=58.300426341027

FOB_BOSTICK:
  road spawn position outside access zone
  unit=1
```

Joyce und Wright erzeugten dagegen im selben Lauf beobachtbare `Ground_APC`-QRFs. Für Wright wurde ein `ROAD_ALIGNED_WAREHOUSE_SPAWN` geloggt. Der Lauf beweist daher, dass der MOOSE-AUFTRAG-/Recruitment-Pfad grundsätzlich bis zur physischen Materialisierung gelangte, aber die allgemeine ACCESS-Straßengeometrie nicht für alle sechs Standorte korrekt umgesetzt war.

Der Harness endete mit:

```text
[PRODUCTION BASE A3][FAIL] TIMEOUT_INCOMPLETE_SIX_SITE_PHYSICAL_CHAIN
```

## Korrektur nach diesem Lauf

Die Folgekorrrektur muss den bereits akzeptierten Ground-Foundation-Vertrag vollständig übernehmen:

```text
MOOSE QRF demand / AUFTRAG / BRIGADE recruitment
-> existing site ACCESS zone
-> road-qualified outbound anchor
-> fixed accepted vehicle spacing
-> road-axis materialization inside ACCESS
-> MOOSE mission lifecycle
```

Der Projektinhaber hat nach dem Lauf zusätzlich entschieden, den Jalalabad-Alarmradius von 6000 ft um 2000 ft auf insgesamt 8000 ft zu vergrößern:

```text
8000 ft = 2438.4 m
```

Der vorhandene Mission-Editor-Kreis `OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT` bleibt als Mittelpunktquelle nutzbar; seine bisherige 6000-ft-Geometrie reicht jedoch nicht mehr als Alarmperimeter aus. Die korrigierte Acceptance muss daher den Mittelpunkt dieser Zone verwenden und daraus zur Laufzeit einen MOOSE `ZONE_RADIUS` mit 2438.4 m erzeugen. Die `.miz` wird nicht automatisch verändert.

## Statusgrenze

```text
Alarm -> incident -> one QRF demand: OBSERVED for Jalalabad
QRF recruitment/materialization path: PARTIALLY OBSERVED
Six-site road-aligned ACCESS materialization: FAILED
Jalalabad 8000 ft perimeter: OWNER DECISION AFTER RUN, NOT YET DCS VALIDATED
Acceptance 3: FAIL
validated_in_dcs: false
```
