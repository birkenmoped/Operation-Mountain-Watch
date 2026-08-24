---
document_id: OMW-AWACS-ACCEPTANCE-4
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - AWACS full fuel-driven AAR acceptance scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
supersedes:
superseded_by:
validated_in_dcs: false
---

# AWACS Acceptance 4 – vollständiger Fuel-/AAR-Lifecycle

## 1. Ziel

Acceptance 4 ist der integrierte End-to-End-Test des sichtbaren E-3A-WIZARD-Lifecycles auf diesem Branch. Der bereits ausgeführte Lauf vom 23./24.08.2026 bestätigte die physische MOOSE-AAR-Kette, zeigte aber zwei Orchestrierungsprobleme: WIZARD wartete trotz vorausgeschickter LISA bis zum 40-%-Fallback und LISA erhielt während des laufenden Receiver-Refuels bereits ihren FuelLow-Egress. Diese Befunde wurden korrigiert.

Acceptance 5 hat anschließend die E-3A-Flugprofile vermessen. Der finale Acceptance-4-Rerun prüft nun die reconciliierte Runtime in einem Durchgang.

## 2. Framework- und Architekturgrenze

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Physische Aktionen müssen ausschließlich aus der AWACS-/AAR-Produktionsruntime stammen. Das Acceptance-Skript ist observer-only und darf insbesondere nicht:

```text
spawnen
routen
Refuel auslösen
AUFTRAG erzeugen
Fuel künstlich verändern
Aircraft zerstören
```

## 3. Finaler Runtime-Stand

Foundation:

```text
tools/build-awacs-foundation.ps1
-> mission/runtime/air-operations/OMW_AWACS_Foundation.lua
```

Controller:

```text
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
```

Observer:

```text
tools/build-awacs-acceptance-4.ps1
-> mission/tests/awacs-external-lifecycle/dist/OMW_AWACS_Acceptance_4.lua
```

## 4. Erwartetes Flugprofil

```text
WIZARD visible spawn / normal transit:
FL350 / 270 KIAS target

APOC persistent racetrack:
FL320 / 250 KIAS / 017T / 30 NM

LISA dedicated AAR racetrack:
FL250 / 270 KIAS / 340T / 20 NM

WIZARD dedicated-LISA rendezvous route:
FL250 / 290 KIAS target

Final join/contact:
DCS refuelling task controlled
```

WIZARD-Route-Speed wird mit derselben `UTILS.IasToTas()`-Konvertierung erzeugt, die Acceptance 5 praktisch verwendet hat. Für die AUFTRAG-Racetracks bleiben die Trackwerte direkte Missions-IAS.

## 5. Fuel-/AAR-Policy

```text
65 %  LISA pre-dispatch
LISA ready -> geplanter AAR beginnt sofort
40 %  fallback trigger, falls LISA nicht bereit ist
25 %  sichtbarer off-map contingency egress, falls kein Refuel-Pfad etabliert ist

LISA FuelLow: 38 %
```

`40 %` ist keine normale AAR-Zielschwelle.

LISA-ready:

```text
<= 5 NM vom Rendezvous-Anker
+/- 1000 ft um FL250
```

Es wird kein zusätzlicher ungeprüfter Speed-Gate verwendet; tatsächliche LISA-IAS/TAS wird protokolliert.

## 6. MOOSE-Refuel-Vertrag

Der gepinnte Source bestätigt:

```text
FLIGHTGROUP:Refuel(Coordinate)
-> PauseMission()
-> DCS TaskRefueling()
-> receiver route mit self.speedCruise
-> Refueled FSM
```

Vor dem geplanten LISA-Refuel setzt die Runtime den öffentlichen `SetDefaultSpeed(...)`-Pfad auf das TAS-Äquivalent von `FL250 / 290 KIAS`. Ein eigener Native-DCS-Contact-Controller wird nicht eingeführt.

Nach `Refueled` wird der normale WIZARD-Route-Speed wiederhergestellt. Die pausierte APOC-Mission bleibt MOOSE-Autorität; Sensorservice wird erst nach physischem APOC-Rejoin wieder aktiv.

## 7. Observer-Telemetrie

Alle 30 Sekunden werden mindestens protokolliert:

```text
runtime ID
local mission time
service state
sensor state
AAR phase
designated tanker
WIZARD altitude
WIZARD IAS
WIZARD TAS
heading
fuel percent
position
egress state
```

Zusätzlich werden bei LISA-ready und AAR-Phasenwechsel LISA-Höhe und LISA-IAS/TAS protokolliert.

## 8. PASS-Kriterien des finalen Laufs

Der Lauf gilt nur dann als technisch erfolgreich, wenn die reale DCS-Evidenz für den ausgeführten Branch-/Commit-/MIZ-/Bundle-/MOOSE-Stand mindestens Folgendes bestätigt:

```text
1. WIZARD materialisiert sichtbar am externen Handoff.
2. ROSIE-Ingress bleibt erhalten.
3. Normaler Transit entspricht dem neuen FL350-/270-KIAS-Profil ohne alten 440-kt-Zwang.
4. WIZARD erreicht den persistenten APOC-Racetrack bei FL320 / 250 KIAS plausibel.
5. Der 15:30-Servicewechsel erzeugt keinen Missions-/ROSIE-Detour.
6. Bei <=65 % wird LISA vorausgeschickt.
7. LISA erreicht den FL250-/270-KIAS-AAR-Track und wird ready.
8. LISA-ready startet den geplanten WIZARD-AAR ohne absichtliches Warten auf 40 %.
9. WIZARD verwendet den MOOSE-Refuel-Pfad; finaler DCS-Join/Contact bleibt plausibel.
10. MOOSE `Refueled` tritt ein.
11. WIZARD kehrt physisch zum APOC-Racetrack zurück; Sensorservice wird erst danach reaktiviert.
12. Falls LISA FuelLow während des aktiven Receiver-Refuels auftritt, wird ihr Egress bis `Refueled` aufgeschoben.
13. Planmäßiger oder explizit angeforderter Service-Ende-Egress führt über ROSIE zum externen Handoff.
14. WIZARD wird erst am externen Handoff despawned und strategisch genau einmal recredited.
15. LISA wird über ihren externen Handoff ebenfalls genau einmal strategisch reconciliiert.
```

Nicht jeder negative Fallback muss künstlich provoziert werden, sofern sein Teilpfad bereits auf exakt dokumentierter technischer Evidenz beruht und durch die finale Änderung nicht berührt wurde.

## 9. Provenienzpflicht

Ein PASS darf erst dokumentiert werden, wenn mindestens vorliegen:

```text
Branch
Source commit
DCS version
MIZ file name
MIZ SHA-256
internal mission SHA-256
AWACS Foundation bundle SHA-256
Acceptance-4 bundle SHA-256
Moose.lua SHA-256
MOOSE commit
dcs.log / relevante Logevidenz
```

Fehlende Werte werden nicht rekonstruiert oder geraten.

## 10. Status

Der final reconciliierte Runtime-Stand ist vorbereitet, aber noch nicht im integrierten DCS-Lauf geprüft.

```text
status: DRAFT
validated_in_dcs: false
final integrated rerun: DCS_PENDING
```
