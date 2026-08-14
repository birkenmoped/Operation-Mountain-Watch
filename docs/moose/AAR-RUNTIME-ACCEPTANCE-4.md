---
document_id: OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-4
status: PLANNED
document_class: TECHNICAL_ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected MOOSE-first AAR runtime acceptance after Acceptance-3 findings
  - DCS-runtime Y-band tanker TACAN for CLANCY and NELSON
  - gate-to-track materialization heading for acceptance tankers
  - Clancy A-10-compatible acceptance speed
not_authoritative_for:
  - complete production tanker speed matrix
  - production MissionDemand/CampaignState activation logic
  - final acceptance before owner-run DCS test
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-MOOSE-AAR-RUNTIME-ACCEPTANCE-3
superseded_by: []
source_branch: agent/aar-rc-east-runtime-scope
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# AAR Runtime Acceptance-4 – korrigierter MOOSE-first Plan

## 1. Anlass

Acceptance-3 bestätigte Clancy und Nelson bis `AUFTRAG:TANKER -> EXECUTING`, zeigte aber drei für den nächsten Lauf zu korrigierende Punkte:

1. Texaco 1-1 antwortete auf 384.400 MHz AM, das konfigurierte 47X-TACAN war im F-16 jedoch nicht empfangbar.
2. Nelson materialisierte mit einer unpassenden Anfangsausrichtung nach Norden, obwohl sein Track südlich des Nordost-Gates liegt.
3. Die pauschalen 300 KIAS sind für den A-10-Receiverfall Clancy nicht als geeigneter OMW-Wert belegt.

Zusätzlich blieb der Bagram-F-16C-Receiver in Acceptance-3 unassigned; der Boom-Test wurde daher nicht erreicht.

## 2. MOOSE-First-Quellprüfung

Gepinnter Stand:

```text
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Für die Korrektur sind im tatsächlich verwendeten `Moose.lua` geprüft:

- `AUFTRAG:SetTACAN(Channel, Morse, UnitName, Band)`; Aircraft verwenden laut API-Dokumentation standardmäßig Y;
- `RECOVERYTANKER`-Dokumentation: Air-to-Air-Tanker-TACAN soll im Y-Band laufen; X funktioniert dort nicht;
- `BEACON:ActivateTACAN()` / A/A-Tanker-Systempfad;
- `COORDINATE:HeadingTo(ToCoordinate)`;
- `SPAWN:InitHeading(HeadingMin, HeadingMax)`;
- `SPAWN:SpawnFromCoordinate(Coordinate)`;
- `AUFTRAG:NewTANKER(...)`, dessen Speed-Parameter als Orbit-KIAS dokumentiert ist;
- `AUFTRAG:CountOpsGroups()` für zusätzliche Receiver-Assignment-Telemetrie.

Es wird weder MIST noch ein paralleler Native-DCS-Tanker-/Beaconcontroller eingeführt.

## 3. Runtime-Konfiguration der zwei Exemplare

Die Quellen-/Planungswerte der AAR-Areas bleiben unverändert erhalten. Acceptance-4 trennt davon die DCS-Runtime-Konfiguration:

```text
CLANCY / Shell 1
Gate: N28.90264890 E64.61166667
Track: N31.75441342 E66.82695501
Orbit: FL225 / 220 KIAS / 225.276 deg / 35 NM
Radio: 241.600 AM
DCS runtime TACAN: 60Y / CLA
Receiver focus: A-10-compatible exemplar

NELSON / Texaco 1
Gate: N37.64268794 E70.96231552
Track: N36.37666667 E71.01833333
Orbit: FL275 / 300 KIAS / 10.428 deg / 35 NM
Radio: 384.400 AM
DCS runtime TACAN: 47Y / NEL
Receiver focus: northern fast-jet exemplar
```

220 KIAS für Clancy ist ein gezielter Acceptance-Wert, kein automatisch auf alle OMW-Tanker übertragener Standard. Eine vollständige receiverbezogene Tanker-Speed-Matrix bleibt gesonderte Facharbeit.

## 4. Materialisierungsheading

Der Harness berechnet für jeden Tanker:

```lua
local spawnHeadingDeg = gateCoord:HeadingTo(trackCoord)
local spawner = SPAWN:New(spec.template)
spawner:InitHeading(spawnHeadingDeg)
local group = spawner:SpawnFromCoordinate(gateCoord)
```

Damit zeigt der Tanker bei der Materialisierung grundsätzlich in Richtung seines Tracks. Das ändert nicht die spätere Racetrack-Ausrichtung; diese bleibt durch den `AUFTRAG:NewTANKER()`-Heading definiert.

Die berechnete Anfangsausrichtung wird als `spawnHeadingDeg` geloggt und muss im DCS-Lauf visuell plausibel sein.

## 5. TACAN-Acceptance

Manuelle Prüfung:

```text
CLANCY: 60Y / CLA
NELSON: 47Y / NEL
```

Für jeden getesteten Tanker müssen mindestens folgende Punkte beobachtet werden:

- DME/Entfernungsinformation vorhanden;
- Bearing/Steuerinformation vorhanden;
- richtige Kanalzuordnung;
- richtige Identifikation, soweit im Cockpit ausgegeben;
- keine Verwechslung zwischen Clancy und Nelson.

Das frühere 60X/47X bleibt historische/planerische Quellenangabe und ist kein positiver DCS-Runtime-Nachweis.

## 6. AI-Boom-Receiver

Der bestehende Bagram-Pfad bleibt unverändert:

```text
AW_US_BGRM_455_AEW
-> SQ_US_BGRM_F16C_121_EFS
-> TPL_AIR_US_BGRM_F16C_CAS_2SHIP
```

Acceptance-4 ändert die Receiver-Architektur nicht spekulativ. Zusätzlich zur bisherigen Summary wird `receiverMissionOpsGroups` über das öffentliche `AUFTRAG:CountOpsGroups()` geloggt. Damit kann der nächste Lauf sauber unterscheiden:

```text
mission added to AIRWING
vs.
OPSGROUP actually assigned/materialized
vs.
FLIGHTGROUP callback received
```

Wenn erneut keine Zuordnung erfolgt, wird die Ursache anhand dieses Runs und der MOOSE-Queue-/Assetlogik isoliert untersucht, statt den AIRWING-Pfad durch einen Test-Bypass zu ersetzen.

## 7. Acceptance-Sequenz

```text
CLANCY + NELSON materialize at separate gate domains
-> initial heading points toward own track
-> manual Y-band TACAN/radio check
-> both AUFTRAG:TANKER reach EXECUTING
-> existing Bagram F-16C mission is offered to AIRWING
-> receiver assignment telemetry
-> if assigned and airborne: FLIGHTGROUP:Refuel(CLANCY track)
-> AI_BOOM_REFUELED_PASS
-> tanker FuelLow threshold 99%
-> FuelLow -> Cancel -> Egress
-> <=10 NM gate -> EGRESS_GATE_PASS -> Despawn
```

## 8. Acceptance-Grenzen

Der Lauf darf nur das tatsächlich Beobachtete bestätigen. Insbesondere gilt:

- Y-band TACAN ist erst nach realer DCS-Navigation `VALIDATED`;
- 220 KIAS Clancy ist erst nach A-10-/Tanker-Kompatibilitätsbeobachtung ein akzeptierter OMW-Runtime-Wert;
- der AI-Boom-Pfad bleibt offen, falls kein F-16C zugeordnet wird;
- die Gate-Kandidaten bleiben bis zur Sichtbarkeits-/Map-Edge-Prüfung Acceptance-Kandidaten;
- keine Aussage dieses Tests erzeugt strategische Ressourcenhoheit außerhalb `CampaignState`.
