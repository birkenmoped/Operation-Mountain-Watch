---
document_id: OMW-TEST-TKOT-AIROPS-CLOSURE-2026-08-09
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot AirOps branch closure state on 2026-08-09
  - documented G5-G8D findings and rejected hypotheses
  - unresolved AH-64D departure and recovery observations at Tarinkot
  - preservation of test lessons for a future investigation
not_authoritative_for:
  - repository-wide production acceptance
  - proof of the root cause of the Tarinkot AH-64D airbase behavior
  - authorization of a native-DCS or non-MOOSE workaround
  - deterministic landing or parking recovery behavior
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 913b67b43e81f4bdf3b8d3b0b5dead3199572d2e
validated_in_dcs: partial
supersedes: []
superseded_by: []
---

# Tarinkot AirOps – Branch-Abschluss mit offenem AH-64D-Airbase-Verhalten

## 1. Abschlussentscheidung

Die Tarinkot-AirOps-Arbeit auf `agent/tarinkot-object-contract-reconciliation` wird nach dem G8D-DCS-Lauf vom 9. August 2026 für die aktuelle Foundation-Phase vorläufig beendet.

Der Foundation-, Parking-, AIRWING-, SQUADRON- und Payload-Stand wird erhalten. Die verbleibenden AH-64D-Probleme werden **nicht** durch weitere ad-hoc AUFTRAG-, Parking-, Native-DCS- oder MOOSE-Override-Experimente in diesem Arbeitsgang verfolgt.

Offen bleiben ausdrücklich:

```text
AH-64D departure at Tarinkot:
vertical preference is applied,
but DCS does not keep the aircraft in a direct ramp departure.
Observed sequence can be:
ready -> short vertical lift/hover -> heading change -> touchdown -> taxi -> runway departure.

AH-64D/rotary recovery at Tarinkot:
returning helicopters do not reliably recover to the parking position from which they departed.
Observed landings can be geometrically implausible or crosswise on the airfield/apron.
```

Diese Punkte sind **UNRESOLVED**, nicht `VALIDATED` und keine akzeptierte Produktionslösung.

## 2. Verbindlicher getesteter Plattformstand

Für den letzten G8D-Lauf ist aus dem bereitgestellten DCS-Log belegt:

```text
DCS: 2.9.28.26385 MT
Mission: OMW_Template_v6_Tarinkot.miz
G8D builder: tools/build-tarinkot-air-operations-g8d-ah64-jalalabad-profile-ab.ps1
G8D BuilderVersion: TKOT-G8D-AH64-JBAD-PROFILE-AB-1
Embedded GitCommit: 913b67b43e81f4bdf3b8d3b0b5dead3199572d2e
MOOSE project baseline: release 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die Log- und Debriefdateien wurden im Chat für die Auswertung bereitgestellt. Für diese beiden Dateien wird hier kein lokaler Projektbesitzer-Hash behauptet, weil kein entsprechender PowerShell-Hashnachweis übergeben wurde.

## 3. Foundation- und Parking-Erkenntnisse

### 3.1 G7-Grundlage

Der korrigierte Foundation-Pfad bestätigt im DCS-Lauf weiterhin:

```text
AIRWING running
3 SQUADRONs
5 registered AI groups
7 registered AI aircraft
3 role payloads
safeParking=true
verticalPolicy=true
takeoffCold=true
```

Für AH-64D ist das Template weiterhin ein physisches Two-Ship:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
units=2
grouping=2
registeredGroups=2
registeredAircraft=4
```

### 3.2 Aktueller Tarinkot-Parkplatzvertrag

Der im Branch reconciliierte Vertrag lautet:

```yaml
clients:
  AH64: [21, 8]
  CH47: [3]
ai_parking:
  AH64: [20, 19]
  UH60: [23, 27, 30]
  CH47: [32, 29, 10]
```

Die Client-TerminalIDs `21`, `8` und `3` sind harte KI-Ausschlüsse.

Der zuvor blockierte G8C-Lauf mit `AH64: [21,4]` war daher kein gültiger Test der vertikalen Abfluglogik. Dieses Problem wurde vor den späteren G8C/G8D-Läufen korrigiert.

### 3.3 Parking-Kapazität und zweiter AH-64-Two-Ship

In G8C wurden bewusst zwei AH-64-Two-Ships angefordert. Die wiederholten Meldungen

```text
No free parking spot for asset SQ_US_TKOT_AH64D_3_101_AVN_AID-94-*
```

gehören zur Rekrutierung des zweiten Two-Ships, während der erste Two-Ship die beiden dedizierten AH-64-Parkpositionen belegt.

Diese Meldung erklärt **nicht** das falsche Departure-Verhalten des bereits gespawnten ersten Two-Ships. Parking-Kapazität und Departure-Verhalten sind getrennte Problemklassen.

## 4. Vertikaloption: was nachgewiesen ist

Die MOOSE-First-Prüfung ergab für den tatsächlich gepinnten `Moose.lua`-Stand:

```text
AIRWING:SetOptionPreferVerticalLanding()
  -> AIRWING OptionPreferVerticalLanding=true
  -> propagation in AIRWING:onafterFlightOnMission
  -> FLIGHTGROUP:SetOptionPreferVertical()
  -> native DCS group option PREFER_VERTICAL=true
```

Die Runtime-Telemetrie bestätigte diese Weitergabe sowohl in G8C als auch in G8D.

G8D protokollierte für den realen Tarinkot-AH-64D-Two-Ship:

```text
FLIGHT_ON_MISSION
group=SQ_US_TKOT_AH64D_3_101_AVN_AID-93
mission=OMW-TKOT-G8D-AH64-CAS-JBAD-PROFILE
missionType=CAS
runtimeUnits=2
expectedUnits=2
optionPreferVertical=true
```

Damit ist die Hypothese **„die MOOSE-Vertikaloption wird bei Tarinkot nicht auf die reale FLIGHTGROUP übertragen“** verworfen.

Nicht nachgewiesen ist, dass `PREFER_VERTICAL` DCS zwingt, für jeden Helicopter/Airbase/Parking-Fall den gesamten Start- und Landeablauf vertikal auszuführen. Der beobachtete Tarinkot-Lauf zeigt das Gegenteil für diese konkrete Kombination.

## 5. G8C – HOVER-Isolationstest

G8C verwendete für alle fünf registrierten Rotary-Gruppen denselben öffentlichen MOOSE-Pfad:

```text
AUFTRAG:NewHOVER()
AH64_1 = 2 units
AH64_2 = 2 units
UH60_1 = 1 unit
UH60_2 = 1 unit
CH47_1 = 1 unit
```

Die Ziele lagen nur 60 m vom gemeinsamen Staging-Anker entfernt.

Ergebnis im relevanten Lauf:

```text
assigned=5/5
runtimeUnits=7/7
optionPreferVertical=5/5
hoverMissionsAdded=5/5
status=FAIL
reason=TAKEOFF_TIMEOUT key=AH64_1
```

Die UH-60 konnten deutlich früher abheben; die AH-64 zeigten visuell das unerwünschte Airbase-/Taxi-Verhalten. Später wurden in einem längeren Lauf vier AH-64-Abflüge beobachtet, jedoch erst nach langen Bodenprozeduren.

### Erkenntnis

`AUFTRAG.Type.HOVER` ist **nicht** als Lösung für den Tarinkot-AH-64D-Ramp-Departure geeignet.

Der Test bewies gleichzeitig, dass die Vertikaloption auch auf den HOVER-FlightGroups gesetzt war. Das Problem ist daher nicht allein eine fehlende Option.

## 6. Frühere CAS-Versuche und verworfene Nahbereichshypothese

Ein früher Tarinkot-CAS-Test verwendete sehr kurze Zielgeometrie im unmittelbaren Flugplatzbereich. Danach bestand die plausible Hypothese, dass eine extrem kurze Mission-/Routing-Geometrie die DCS-Airbase-State-Machine ungünstig beeinflusst.

Diese Hypothese wurde mit G8D gezielt überprüft.

## 7. G8D – Jalalabad-Profil als Tarinkot-A/B-Test

G8D behielt bewusst bei:

```text
AH-64D two-ship
cold start
Tarinkot AIRWING/SQUADRON foundation
Tarinkot AH64 parking IDs 20,19
AIRWING:SetOptionPreferVerticalLanding()
AUFTRAG:NewCAS()
```

und ersetzte die problematische Nahbereichsgeometrie durch ein Jalalabad-ähnliches Rotorprofil:

```text
CAS target distance: 8000 m
CAS radius: 1500 m
ingress distance: 3000 m
egress distance: 5000 m
mission altitude: 3500 ft
mission speed: 110 kt
formation: EchelonRight300
required assets: 1 two-ship group
```

Runtime:

```text
MISSION_ADDED ... type=CAS ... targetDistanceM=8000 ... altitudeFt=3500 speedKt=110
FLIGHT_ON_MISSION ... runtimeUnits=2 ... optionPreferVertical=true
```

Der automatisierte G8D-Endmarker meldete:

```text
RESULT G8D_AH64_JALALABAD_PROFILE_AB
status=FAIL
reason=TAKEOFF_TIMEOUT
airborneUnits=0/2
assigned=true
runtimeUnits=2/2
takeoff=false
optionPreferVertical=true
missionType=CAS
targetDistanceM=8000
altitudeFt=3500
speedKt=110
formation=EchelonRight300
```

Der Debrief bestätigt zwei nahezu gleichzeitige AH-64D-Engine-Start-Ereignisse in Tarinkot. Bis zum Mission-Ende enthält der bereitgestellte Debrief für diesen Lauf keine AH-64D-Takeoff-Ereignisse.

Die Eigentümer-Sichtbeobachtung ergänzt den automatisierten Befund: Nach vollständiger Startbereitschaft hoben beide Maschinen zunächst kurz vertikal ab, richteten sich auf ein Heading aus, setzten wieder auf und rollten danach zur Startbahn. Die bereitgestellten Screenshots zeigen die anschließende Bodenbewegung in Richtung beziehungsweise auf der Runway.

### Schlussfolgerung aus G8D

Die Hypothese **„nur HOVER oder ein 35/60-m-Nahbereichsauftrag verursacht das Tarinkot-Verhalten“** ist verworfen.

Auch ein CAS-Auftrag mit 8-km-Ziel, 3500-ft-Rotorprofil, 110 kt, explizitem Ingress/Egress und Echelon-Right-Formation erzeugt bei Tarinkot kein belastbar sauberes vertikales Ramp-Departure-Verhalten.

## 8. Vergleich Jalalabad

Der Vergleichslauf in derselben DCS-Umgebung zeigt einen entscheidenden Gegenbeleg gegen mehrere pauschale Erklärungen.

Jalalabad:

```text
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
model: physical two-ship
grouping: 2
parkingIDs: 26,51,11
preferVerticalTakeoffAndLanding=true
mission authority: AUFTRAG
mission type in observed case: CAS
```

Dort wurde visuell ein realistischer direkter Ramp-Abflug des AH-64D-Two-Ships beobachtet; beide Maschinen hoben ohne Taxi zur Startbahn direkt von ihren Ramp-Positionen ab.

Daraus folgen für Tarinkot verworfene Pauschalhypothesen:

```text
NOT: AH-64D cannot vertically depart under MOOSE.
NOT: a two-ship is inherently incompatible with vertical departure.
NOT: CAS inherently forces runway departure.
NOT: SetOptionPreferVerticalLanding is simply missing.
NOT: only short target distance explains the Tarinkot behavior.
```

Der verbleibende Unterschied liegt damit wahrscheinlich in airbase-/parking-/route-spezifischem DCS-Verhalten oder in einer noch nicht identifizierten Kombination aus diesen Faktoren. Das ist eine **Hypothese**, keine bestätigte Root Cause.

## 9. Recovery-/Landing-Problem

Separat vom Departure-Problem wurde bei zurückkehrenden Rotary-Gruppen beobachtet:

```text
landing does not reliably return an aircraft to its departure parking position;
helicopters can land crosswise or at visually implausible airfield/apron locations;
return-to-original-spot is not established by the current Tarinkot configuration.
```

Wichtige Architekturgrenze:

`SQUADRON:SetParkingIDs()` wird im Projekt als erlaubter Parking-Pool für die Asset-/Spawn-Seite verwendet. Für den getesteten Pfad liegt kein Nachweis vor, dass diese Methode eine persistente Zuordnung

```text
specific aircraft -> specific home terminal -> deterministic recovery to same terminal
```

garantiert.

Deshalb darf das beobachtete Recovery-Problem nicht durch eine bloße Umdeutung von `SetParkingIDs()` als gelöst dokumentiert werden.

Ein möglicher künftiger MOOSE-First-Untersuchungspunkt ist das Lifecycle-/Despawn-Modell nach Landung. Jalalabad verwendet für AH-64D dokumentiert `despawnAfterLanding=true`; daraus folgt jedoch **keine** automatische Freigabe oder Übertragbarkeit für Tarinkot. Eine solche Änderung wäre separat zu entscheiden und zu testen.

## 10. Nicht erfolgreiche beziehungsweise verworfene Ansätze

Die folgenden Ansätze gelten nach diesem Arbeitsgang nicht als Lösung für Tarinkot:

```text
1. stale AH64 parking pool 21,4
   -> invalid against current parking contract; blocked before valid dispatch.

2. SetOptionPreferVerticalLanding only
   -> option is propagated, but behavior remains wrong.

3. uniform AUFTRAG:NewHOVER test
   -> option propagates; AH64 still shows undesired airbase behavior.

4. very short CAS/HOVER target geometry
   -> plausible confounder, but not sufficient explanation.

5. Jalalabad-like CAS profile at 8 km
   -> still no clean Tarinkot ramp departure.

6. two-ship as primary cause
   -> contradicted by visually correct Jalalabad AH64 two-ship departure.

7. CAS mission type as primary cause
   -> contradicted by Jalalabad CAS success and Tarinkot G8D behavior.
```

## 11. Offene technische Fragen für eine spätere Wiederaufnahme

Falls das Thema später wieder geöffnet wird, muss die Untersuchung an dieser Stelle weitergehen und darf die verworfenen Hypothesen nicht ohne neue Evidenz wiederholen.

Sinnvolle, noch nicht ausgeführte Untersuchungsrichtungen sind:

```text
A. exact DCS airbase/parking graph difference Tarinkot vs Jalalabad;
B. terminal type and taxi-link topology for Tarinkot IDs 20/19 versus Jalalabad 51/26;
C. generated DCS route/task structure after AIRWING dispatch at both airbases;
D. whether another Tarinkot HelicopterOnly pair produces different DCS behavior;
E. deterministic recovery options in public MOOSE lifecycle APIs;
F. despawn-after-landing as a visual/lifecycle mitigation, only after explicit design decision;
G. DCS-engine regression/airfield-specific defect reproduction outside OMW, only if explicitly approved.
```

Diese Punkte sind keine Arbeitsfreigabe für Native-DCS- oder Parallelmechanik. Vor Eigenlogik gilt weiterhin `docs/26-moose-first-development-policy.md`.

## 12. Branch-Abschlussstatus

Für den Abschluss dieses Arbeitsgangs gilt:

```yaml
foundation: COMPLETE_FOR_CURRENT_PHASE
parking_contract: RECONCILED_BRANCH
G7_foundation: PASS_DCS_FOR_DOCUMENTED_SCOPE
vertical_option_propagation: CONFIRMED_IN_DCS
AH64_two_ship_dispatch: CONFIRMED
AH64_direct_vertical_ramp_departure_Tarinkot: FAIL_VISUAL_UNRESOLVED
AH64_CAS_long_range_profile_fix: REJECTED_AS_SOLUTION
AH64_HOVER_fix: REJECTED_AS_SOLUTION
return_to_original_parking: NOT_PROVEN_AND_VISUALLY_UNSATISFACTORY
root_cause: UNKNOWN
native_DCS_override: NOT_AUTHORIZED
MOOSE_source_patch: NOT_AUTHORIZED
Tarinkot_AirOps_current_phase: CLOSED_WITH_KNOWN_LIMITATIONS
```

Der bekannte Mangel wird damit bewusst konserviert und dokumentiert, statt eine ungeprüfte oder nicht genehmigte Umgehung als Lösung einzubauen.
