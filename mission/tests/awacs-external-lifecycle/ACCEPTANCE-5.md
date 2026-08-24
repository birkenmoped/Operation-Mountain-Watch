---
document_id: OMW-AWACS-ACCEPTANCE-5
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - E-3A DCS performance matrix test
  - AWACS altitude and IAS fuel-consumption evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: false
---

# AWACS Acceptance 5 – E-3A Performance Matrix

## Ziel

Der Test ermittelt in einem einzigen DCS-Lauf die tatsächlich erreichbare Geschwindigkeit und den relativen Treibstoffverbrauch des DCS-E-3A-Modells bei drei für OMW relevanten Höhen und fünf IAS-Sollwerten. Er dient ausschließlich zur Auswahl belastbarer Engineering-Werte für Transit, On-Station und AAR-Rendezvous. Er ändert keine Produktionsbaseline.

## Testmatrix

```text
              230 KIAS  250 KIAS  270 KIAS  290 KIAS  310 KIAS
FL250            X         X         X         X         X
FL320            X         X         X         X         X
FL350            X         X         X         X         X
```

Insgesamt werden 15 E-3A gleichzeitig aus dem bestehenden Late-Activation-Template `OMW_C2_E3A_WIZARD` erzeugt.

## Geometrie

Die komplette Geometrie wird vom Testskript mit MOOSE erzeugt. Im Mission Editor sind keine Marker, Zonen, Routen oder 15 Einzeltrigger anzulegen.

```text
Reference: 30.10 N / 61.85 E
Heading: 090 true
Lane spacing: 12 NM
Stabilization leg: 20 NM
Measurement leg: 200 NM
```

Die fünf Geschwindigkeits-Lanes werden seitlich versetzt erzeugt. Die drei Höhenblöcke verwenden dieselbe horizontale Lane-Geometrie und sind vertikal getrennt.

## Namen

```text
OMW_TEST_E3_FL250_IAS230 ... OMW_TEST_E3_FL250_IAS310
OMW_TEST_E3_FL320_IAS230 ... OMW_TEST_E3_FL320_IAS310
OMW_TEST_E3_FL350_IAS230 ... OMW_TEST_E3_FL350_IAS310
```

MOOSE ergänzt beim tatsächlichen Spawn seinen normalen Runtime-Suffix. Die logische Test-ID bleibt in jeder Telemetriezeile vollständig erhalten.

## MOOSE-First

Verwendet werden ausschließlich verifizierte MOOSE-Abstraktionen für den physischen Test:

```text
SPAWN:NewWithAlias(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)
FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:GetAltitude()
POSITIONABLE:GetAirspeedIndicated()
POSITIONABLE:GetAirspeedTrue()
COORDINATE:NewFromLLDD(...)
COORDINATE:Translate(...)
UTILS.IasToTas(...)
SCHEDULER:New(...)
```

`FLIGHTGROUP:AddWaypoint()` übernimmt im gepinnten MOOSE-Source einen Speed-Wert in knots und erzeugt daraus den DCS-Air-Waypoint. Für die Testmatrix wird der gewünschte KIAS-Wert deshalb vorher mit `UTILS.IasToTas()` auf die jeweilige Testhöhe umgerechnet. Die tatsächlich geflogene IAS wird anschließend unabhängig mit `POSITIONABLE:GetAirspeedIndicated()` beobachtet.

Es gibt keine Native-DCS-Routenlogik, keine `trigger.action`-Marker und keine eigenen World-Scans.

## Fuel-Normalisierung

Das Testskript verändert den Template-Fuelwert nicht. Alle 15 Spawns erben denselben Fuelstand aus `OMW_C2_E3A_WIZARD`. Für den vorgesehenen Teststand ist dies der aktuelle WIZARD-Templatewert von ungefähr 77 Prozent beziehungsweise rund 50.050 kg. Damit wird der für den sichtbaren Produktionseintritt relevante Gross-Weight-Bereich untersucht.

Fuel wird im Test nur über den im gepinnten MOOSE-Stand vorhandenen `FLIGHTGROUP:GetFuelMin()`-Prozentwert ausgewertet. Nicht verifizierte Methoden wie `GetCurrentFuelKgs()` oder `GetFuelMassMax()` werden ausdrücklich nicht verwendet.

## Messung

Jeder Flug erhält zunächst 20 NM zur Stabilisierung. Erst am Messstart wird Fuel und Zeit erfasst. Anschließend folgt die 200-NM-Messstrecke.

Während der Messung wird alle 30 Sekunden protokolliert:

```text
testId
targetAltFt
targetIASKt
actualAltFt
actualIASKt
actualTASKt
fuelPct
distanceToEndNm
```

Am Ende wird pro Profil eine `SUMMARY`-Zeile ausgegeben mit:

```text
elapsedSec
sample count
average altitude
average IAS
average TAS
maximum IAS error
fuel start/end/burn percent
fuel burn percent per 100 NM
fuel burn percent per hour
classification
```

## Klassifikation

Die Klassifikation ist eine OMW-Testdefinition und kein Herstellerlimit:

```text
STABLE:
>=90 percent der Messsamples innerhalb +/-5 KIAS vom Soll

UNSUSTAINABLE:
>=20 percent der Messsamples mehr als 15 KIAS vom Soll entfernt

MARGINAL:
alle übrigen Fälle
```

Die Fuelwerte dürfen nur zwischen Profilen verglichen werden, die den Lauf physisch vollständig absolvieren und deren Flugverhalten plausibel bleibt.

## DCS-Ablauf

Für den Test muss in der Test-MIZ nur Folgendes vorhanden sein:

```text
Moose.lua
Late-Activation template OMW_C2_E3A_WIZARD
OMW_AWACS_Acceptance_5.lua
```

Acceptance 5 startet sich selbst. Es werden keine Produktions-AWACS-Foundation, kein AAR-Controller, keine AWACS-Aufgabe, kein CampaignState und keine weiteren Acceptance-Skripte für diesen isolierten Performance-Lauf benötigt.

## Acceptance-Evidenz

Ein auswertbarer Lauf benötigt mindestens:

1. Branch und Commit;
2. `OMW_AWACS_Acceptance_5.lua` SHA256;
3. `Moose.lua` SHA256;
4. MIZ SHA256 und internal-mission SHA256;
5. DCS-Version;
6. vollständiges `dcs.log`;
7. `debrief.log`, soweit erzeugt;
8. `ALL_COMPLETE profiles=15` oder dokumentierte Einzel-FAILs.

Erst nach realem DCS-Lauf darf dieses Dokument auf einen validierten Acceptance-Status gehoben werden.
