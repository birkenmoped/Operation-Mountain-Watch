---
document_id: OMW-FIRE-SUPPORT-GATE5B-SIX-SITE-PERIMETER-RUNTIME-ACCEPTANCE-1
status: SUPERSEDED
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - historical Gate-5B Guard-first perimeter acceptance design
  - owner-local build provenance for commit 4ad6ec9ad8e83f48f5f1b1d54dcd130d71050f43
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
  - OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PERIMETER-RUNTIME owner decision 2026-09-15
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Gate 5B – Six-Site Perimeter Runtime Acceptance 1

## Status

**SUPERSEDED fuer die aktuelle Produktionssemantik.**

Dieses Acceptance-Design wurde fuer den inzwischen ersetzten Vertrag erstellt:

```text
persistent Guard already physically present
-> start runtime perimeter
-> force physical RED intrusion at all six sites
-> expect exactly one QRF demand at all six sites
```

Am 15.09.2026 hat der Projektinhaber die produktive Guard-Semantik geaendert:

```text
NORMAL
-> kein physischer Guard
-> MOOSE OPSZONE ueberwacht den Alarmperimeter

RED innerhalb Alarmperimeter
-> Installation Incident
-> Guard als INCIDENT_LOCAL_SECURITY materialisieren
-> QRF als mobile INCIDENT_LOCAL_DEFENSE ausloesen
```

Damit ist die zentrale Voraussetzung dieses Acceptance-1 – sechs bereits materialisierte Guards vor dem Perimeter-Alarm – nicht mehr gueltig. Ebenso ist ein Testziel "alle sechs Sites muessen einen QRF-Demand erreichen" fuer einen produktionsnahen Lauf ungeeignet, wenn vorhandene MORTAR-/ARTY-Unterstuetzung einzelne Angreifer bereits vor ihrer qualifizierten Intrusion vernichtet.

Die Datei bleibt aus Provenienzgruenden erhalten. Sie darf **nicht** als Acceptance-Plan fuer die neue incident-lokale Guard-Semantik verwendet werden.

## Historische Build-Provenienz

Der Projektinhaber hat den damaligen Builder lokal aus folgendem Stand ausgefuehrt:

```text
Source commit: 4ad6ec9ad8e83f48f5f1b1d54dcd130d71050f43
Production BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-17
Acceptance BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5B-PERIMETER-RUNTIME-1
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Verifizierte lokale SHA-256-Werte:

```text
Production builder:
9D65F27B869AB2AA24FACB557213D47204ADD612F1956331605D9408EF667982

Production bundle:
80DD735720D5134F252E3CA5A36C692DD29F2DC1228CB088A25F5923BA760607

Acceptance source:
A41D271D880A8A9263F72DC1DA0BDB84FBD66B4E5BA97D2338E75EF751975108

Acceptance builder:
C0CDDBD0C9FA5E18273C883C47905D7DDC8A5F7F05EDA353F53EEEDF9B7564BD

Acceptance bundle:
34F8B60683502418464AC937070747F7DB9F83DF9BCB66FBC01E5A46AAB580EB
```

Der spaetere reale DCS-Lauf mit diesem Harness erreichte keinen Acceptance-PASS; der Harness scheiterte an seiner Fixture-Aktivierungsannahme. Dieser Fehler darf nicht als Fehler der neuen incident-lokalen Guard-Architektur interpretiert werden.

## Weiterhin gueltige fachliche Geometrie

Die Owner-bestaetigten Alarmradien bleiben unveraendert:

```text
JALALABAD_FENTY   2438.4 m   8000 ft
COP_FORTRESS      1524.0 m   5000 ft
FOB_JOYCE         2743.2 m   9000 ft
FOB_WRIGHT        1219.2 m   4000 ft
COP_HONAKER       2743.2 m   9000 ft
FOB_BOSTICK       1524.0 m   5000 ft
```

Anchor-Vertrag:

```text
JALALABAD_FENTY -> OMW_BLUE_OBJECTIVE_JALALABAD_AIRPORT center
COP_FORTRESS    -> WH_BLUE_GND_FORTRESS
FOB_JOYCE       -> WH_BLUE_GND_JOYCE
FOB_WRIGHT      -> WH_BLUE_GND_WRIGHT
COP_HONAKER     -> WH_BLUE_GND_HONAKER
FOB_BOSTICK     -> WH_BLUE_GND_BOSTICK
```

Diese Geometrie ist durch die Guard-Redesign-Entscheidung nicht superseded.

## Neue Acceptance-Grenze

Ein neuer DCS-Nachweis darf nur die **neue** Differenz gegen bereits akzeptierte Baselines pruefen:

```text
vor Alarm kein physischer Guard
-> RED presence durch MOOSE OPSZONE scan
-> PROXIMITY_INTRUSION / Installation Incident
-> genau ein Guard-Demand INSTALLATION_ATTACK_LOCAL_GUARD
-> Guard lokal ONGUARD, keine PATHLINE-Patrouille, kein proaktives EngageTarget
-> bestehender QRF-Demand INSTALLATION_ATTACK_INITIAL_QRF bleibt unveraendert
-> autoritative Incident-Schliessung cancelt Guard
-> QRF wird dadurch nicht automatisch beendet
```

Die bereits akzeptierte A4-8-QRF-Ausfuehrung wird dabei nicht erneut entwickelt oder neu definiert.
