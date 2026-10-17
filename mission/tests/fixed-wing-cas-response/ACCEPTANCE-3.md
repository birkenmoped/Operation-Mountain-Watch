---
document_id: OMW-TEST-FIXED-WING-CAS-RESPONSE-ACCEPTANCE-3
status: PLANNED
document_class: TEST_ACCEPTANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Acceptance 3 MOOSE C2 high-terrain RTB, alarm-CAS speed and A-10 range test
not_authoritative_for:
  - validated cruise speeds, afterburner behavior, A-10 endurance or terrain-safe routes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Fixed-wing CAS Response – Acceptance 3

## Anlass und Beweislage

Acceptance 2 (DCS 2.9.30.28738 MT, v26-Mission, MOOSE 2.9.18, Commit `2aef5664408639d03d7d568e1e78d62db9535914`, lokales Bundle SHA-256 `CA99395C125040058CFB66023B789749435521CA7684A041628D88275E3CF74E`) bewies Bagram-Two-Ship-Join und verbesserten CAS-Hinflug. Die automatische MOOSE-FuelLow->RTB-Rueckkehr flog erneut zu tief durch das afghanische Gebirge; eine F-15E ging auf dem Rueckweg verloren, im letzten Fuel-Observer mit `fuelFraction=0.2726` und ca. 12.624 ft MSL. Die Ursache des Verlustes (Terrain/sonstiges) ist nicht abschliessend nachgewiesen. Die A-10 blieb mit `missionState=planned` ohne Rekrutierung.

Der Projektinhaber bestaetigte Kandahar->Honaker >330 NM einfach. MOOSE-`COHORT`-Reichweitenvorgabe ist fuer Airplanes typischerweise 200 NM; `AUFTRAG:SetMissionRange` und `COHORT:SetMissionRange` sind unterschiedliche Pruefungen. A3 konfiguriert beide gezielt und untersucht den anschliessenden Rekrutierungs-/Fuel-Lifecycle.

## A3-Einzelparameter (kein generelles Produktionsprofil)

| Parameter | F-16C Bagram | A-10C Kandahar | F-15E Bagram |
|---|---:|---:|---:|
| CAS-Anforderung | Erstes Ereignis | Nach 60 s | Nach beiden F-16-Takeoffs |
| MOOSE-Holding bei Bagram | 16.000 ft MSL, 250 kn | keines | 16.000 ft MSL, 250 kn |
| Zwei-Maschinen-Join | maximal 2 NM, beide airborne | unveraendert | maximal 2 NM, beide airborne |
| MOOSE-Default-Cruise-Hoehe (einschl. RTB) | 22.000 ft MSL | 22.000 ft MSL | 22.000 ft MSL |
| MOOSE-Default-Cruise-Geschwindigkeit | 450 kn | 260 kn | 460 kn |
| CAS-Orbit | 22.000 ft MSL / 350 kn | 22.000 ft MSL / 230 kn | 22.000 ft MSL / 350 kn |
| A-10 Missions-/COHORT-Reichweite | unveraendert | jeweils 400 NM | unveraendert |

**Reichweitenbedeutung:** 400 NM ist eine einmalige Test-Eignungsgrenze vom Startflugplatz zum AO, keine Hin-/Rueckflug-Reichweite und keine Fuel-Garantie. 330 NM Luftlinie bedeutet >660 NM fuer Hin-/Rueckflug ohne CAS-/Tanker-/Holding-Anteile; die beobachtete Wirtschaftlichkeit und sichere Rueckkehr sind eigenstaendige Acceptance-Kriterien. A3 veraendert keine AAR-, Refuel-, FuelLow- oder RTB-Entscheidungsparameter.

**Geschwindigkeitsbedeutung:** `SetDefaultSpeed` verwendet Knoten und delegiert Wegpunktplanung an MOOSE. 450/460 kn sind **Testwerte fuer schnellen Alarm-CAS-Transit**; keine garantierten Mindestgeschwindigkeiten, keine nachgewiesene Nachbrennersteuerung. Insbesondere `AUFTRAG:NewCAS(..., speed)` gibt die Missions-/Orbitgeschwindigkeit vor, **nicht** den gesamten Transit. Nachbrennerbetrieb oder Machzahl werden nicht als automatisch verfuegbare Telemetrie behauptet. Fuehrt ein Profil zu zu grossem Fuel-Verbrauch oder fehlender Time-On-Station, ist es ein Fehler und muss als solcher berichtet werden. Ein Scheduled-CAS-Standby bleibt ein anderes, hier nicht gemessenes Flugprofil.

**Hoehenbedeutung:** Das Quell-`Moose.lua`-Verfahren `OPSGROUP:SetDefaultAltitude(22000)` setzt `altitudeCruise`, welche von `FLIGHTGROUP:_LandAtAirbase` fuer RTB-Zwischenwegpunkte verwendet wird. 22.000 ft MSL ist noch kein nachgewiesener Sicherheitsabstand ueber allen Bergen; Sinkflug und Anflug koennen absichtlich darunter liegen und muessen relativ zum Ort bewertet werden.

## MOOSE-First-Implementierung

`AUFTRAG:NewCAS`, `SetMissionHoldingCoord`, `AddConditionPush`, `AssignSquadrons`, `SetRequiredAssets(1,1)`, `COMMANDER:AddMission` und `FLIGHTGROUP` bleiben unveraendert. Auf der von MOOSE ausgewaehlten `FLIGHTGROUP` ruft A3 `SetDefaultAltitude` und `SetDefaultSpeed` auf. Die A-10-CAS-SQUADRON aus der bestehenden Kandahar-Foundation erhaelt vor Request `COHORT:SetMissionRange(400)`, der Auftrag `AUFTRAG:SetMissionRange(400)`. **Keine** native DCS-Tasksteuerung, eigenen Spawns, verstaerkten Nachbrennerbefehle, vorgeplanten Tanker oder eigene Fuel-Threshold-Logik.

Die Reichweitenaenderung an der A-10-SQUADRON ist eine gezielte Testkonfiguration fuer dieses Acceptance-Bundle; vor Produktivadoption ist der persistente Vertrag mit der AIRWING-/CampaignState-Baseline gesondert zu entscheiden.

## Messung, DCS-Acceptance und Abweichungen

Der passive 15-Sekunden-Observer erfasst weiterhin pro Aircraft: Zeitpunkt, Fuel, MSL-Hoehe, und neu:
- `groundSpeedKts`: MOOSE `POSITIONABLE:GetVelocityKNOTS()` (3D-Geschwindigkeitsbetrag ueber Grund);
- `trueAirSpeedKts`: `GetAirspeedTrue()` in m/s via `UTILS.MpsToKnots`;
- `indicatedAirSpeedKts`: `GetAirspeedIndicated()` (MOOSE-naeherungsweise) via `UTILS.MpsToKnots`.

**Wichtige Einschraenkung:** Der Wert `groundSpeedKts` ist der Betrag des 3D-Vektors, nicht zwangslaeufig die horizontale Bodengeschwindigkeit. `GetAirspeedIndicated` ist eine modellierte Naeherung, kein Cockpit-Sensorwert. Auch ein beobachteter hoher Verbrauch allein beweist keinen aktiven Nachbrenner.

Abnahme pro Flight:
1. C2-Rekrutierung, beide Flugzeuge aktiv, beide Takeoffs und (Bagram) Join.
2. Zuendung des eigentlichen CAS-Lifecycles, AO-Eintritt, verbleibender Fuel.
3. Tatsachlich geflogene TAS/IAS/Geschwindigkeit und Fuel-Verbrauch im Alarm-Transit.
4. Automatisches MOOSE-FuelLow/FuelCritical/RTB, keine erzwungene AAR.
5. RTB auf geeignetem hochgelegenem Zwischenprofil, Abstieg erst im sicheren Platzanflug; keine Gelaendekollisionen.
6. Kandahar A-10: separate Rekrutierung und physischer Dispatch; >330-NM-Strecke bleibt Fuel-/Zeit-Risiko. Fehlschlag oder ausbleibender Spawn sind zu dokumentieren, keine weiteren Filter ohne Source-Evidenz erfinden.

**Keine DCS-VALIDATED-Aussage** vor realem Lauf und Logs/MIZ-/Bundle-/MOOSE-SHA256. A1/A2/A3 nie parallel in derselben Testmission laden; A3 ersetzt bei Besitzer-ME-Einbindung nur den A2-Trigger.

## Artefakte und Workflow

```text
mission/tests/fixed-wing-cas-response/src/acceptance-3-three-flight-cruise-rtb.lua
tools/build-fixed-wing-cas-response-acceptance-3.ps1
mission/tests/fixed-wing-cas-response/dist/OMW_FixedWing_CAS_Response_Acceptance_3.lua
```

Die GitHub Actions fuehren Lua-5.1-Syntax- und PowerShell-Builder-Checks durch. Erst dann Owner: Pull, Build, SHA-256 in dediziertem `Operation-Mountain-Watch-cas-ground-alert`-Worktree; Owner: ME-Einbindung und Hash-Verifikation der Test-`.miz`; Owner: reale DCS-Ausfuehrung. Die Original-`.miz` bleibt unveraendert.
