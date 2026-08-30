---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage 3 combined Honaker attack, local response, Wright fire support, local rearm and strategic Air-AMMO closure acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: 9fbfe27c9b5204689ccf578b3a00771d0b26102b
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## Zweck

Dieser Lauf ist der kombinierte Stage-3-End-to-End-Test. Er führt vorhandene MOOSE-first-Pfade in einer realen Kette zusammen.

```text
RED ground forces attack COP Honaker
-> existing MOOSE OPSZONE Attacked qualification
-> Honaker own infantry QRF response
-> existing Jalalabad AH-64D immediate CAS response
-> CAS route OMW_FlightPath -> OMW_FlightPath_WEST -> Honaker
-> additional FIRE_SUPPORT_IMMEDIATE demand
-> Honaker local 2B11 intentionally unavailable in this acceptance
-> Wright L118 selected
-> MOOSE Functional ARTY attacks one OPSZONE-detected RED group
-> physical MOOSE ARTY ammo must actually decrease
-> only then FIRE_SUPPORT demand SUCCESS
-> existing M1083 local rearm composition
-> CampaignState consumes exactly 1 GROUND_AMMO_PACKAGE
-> Wright strategic AMMO 16 -> 15
-> ResourceDemandPolicy hits reorder threshold
-> exactly one MissionDemand RESUPPLY
-> exactly one CampaignState TRANSFER 15 from Jalalabad to Wright
-> one physical slingload manifest
-> Jalalabad CH-47 via MOOSE AUFTRAG CARGOTRANSPORT
-> outbound OMW_FlightPath valley route
-> physical delivery at OMW_BLUE_LZ_WRIGHT_01
-> CampaignState MarkDelivered
-> MissionDemand SUCCESS
-> Wright strategic AMMO 15 -> 30
-> return OMW_FlightPath valley route
-> physical Jalalabad landing
-> LegionAssetReturned
```

## Verbindliche Architekturgrenzen

- `CampaignState` bleibt alleinige strategische Ressourcenautorität.
- `GROUND_AMMO_PACKAGE` wird nicht in Kilogramm umgerechnet.
- Ein physisches `ammo_cargo` repräsentiert das komplette Transfermanifest von 15 strategischen Paketen.
- Die 1000-kg-Cargomasse ist ausschließlich ein Acceptance-Parameter für den DCS-Slingload.
- Keine neue Feinderkennung: Bedrohungsevidenz kommt aus dem bestehenden `OMW_FobThreatOpsZoneAdapter` / MOOSE `OPSZONE`.
- Keine zweite QRF-Logik außerhalb des vorhandenen MOOSE-`BRIGADE`/`PLATOON`/`AUFTRAG:NewGROUNDATTACK`-Musters.
- Kein zweiter MOOSE-Owner für die Wright-Batterie: ein Functional-`ARTY`-FSM besitzt Feuer und lokalen Rearm-Lifecycle.
- `OnAfterOpenFire` / `OnAfterCeaseFire` allein gelten nicht mehr als Beweis realer Schüsse. Vor FIRE_SUPPORT-SUCCESS muss `ARTY:GetAmmo(false)` tatsächlich sinken.
- Honaker-Mörser werden im Test nicht zerstört oder teleportiert; das late-activation Template bleibt unmaterialisiert.
- CAS nach Honaker verwendet die verkettete Route `OMW_FlightPath -> OMW_FlightPath_WEST`; der Rückweg wird aus derselben Sequenz rückwärts aufgebaut.
- Air-AMMO nach Wright verwendet weiterhin ausschließlich `OMW_FlightPath` hin und zurück.

## Verkettete PATHLINE-Route

`OMW_HelicopterFlightPathCorridor` unterstützt nun eine geordnete Folge vorhandener MOOSE-`PATHLINE`-Objekte. Zwischen zwei Linien wird das nächstgelegene Punktpaar als Junction verwendet. Der aktuelle Acceptance-Vertrag akzeptiert nur Junctions bis maximal `1000 m`; größere Lücken führen zu einem expliziten Fehler statt zu einem stillen Luftlinien-Segment.

Für Honaker:

```text
Jalalabad
-> OMW_FlightPath
-> Junction
-> OMW_FlightPath_WEST
-> Honaker mission area
```

Rückweg:

```text
Honaker mission area
-> OMW_FlightPath_WEST reverse
-> Junction
-> OMW_FlightPath reverse
-> Jalalabad
```

Für Wright:

```text
Jalalabad
-> OMW_FlightPath
-> Wright
-> OMW_FlightPath reverse
-> Jalalabad
```

## Warum Functional ARTY

Der bestehende lokale Rearm-Vertrag arbeitet mit Functional `ARTY` und dessen `OnBeforeRearm` / `OnAfterRearmed`-Lifecycle. Der End-to-End-Lauf nutzt daher dieselbe ARTY-Instanz:

```text
one Wright physical battery
-> one MOOSE ARTY FSM
-> AssignAttackGroup(real RED OPSZONE group)
-> OnAfterOpenFire
-> physical ammo baseline
-> OnAfterCeaseFire
-> physical ammo must be lower
-> MissionDemand SUCCESS
-> same ARTY instance
-> local Rearm()
-> OnAfterRearmed
```

Bleibt die physische Munition unverändert, muss der Fire-Support-Demand mit `PHYSICAL_AMMO_UNCHANGED` fehlschlagen und es darf kein lokaler M1083-Rearm als erfolgreiche Feuerfolge gestartet werden.

## Strategische Testvorbedingung

Wright beginnt mit:

```text
GROUND_AMMO_PACKAGE = 30
reorder = 15
critical = 7.5
```

Die Acceptance setzt einmalig sichtbar:

```text
Wright 30 -> 16
```

Danach muss ein real bestätigter Wright-L118-Feuer-/Rearm-Zyklus genau ein strategisches Paket verbrauchen:

```text
16 -> 15
```

Nur dieser reale Rearm-Commit darf den Reorder-Threshold auslösen.

## Sichtbare Runtime-Telemetrie

Wesentliche Zustandswechsel werden zusätzlich zum DCS-Log über MOOSE `MESSAGE` angezeigt. Erfolgsmeldungen sind ereignis- und evidenzgebunden.

Erwartete Milestones:

```text
[STAGE 3][READY] ...
[STAGE 3][THREAT] COP Honaker under attack ...
[STAGE 3][QRF] Honaker requests own QRF ...
[STAGE 3][QRF] ... engaging ...
[STAGE 3][CAS] Jalalabad AH-64D assigned to Honaker
[STAGE 3][CAS] CAS outbound + return valley route installed via OMW_FlightPath -> OMW_FlightPath_WEST; junction gap ... m
[STAGE 3][CAS] Jalalabad AH-64D CAS executing for Honaker
[STAGE 3][FIRE SUPPORT] Honaker requests immediate fire support ...
[STAGE 3][FIRE SUPPORT] Wright L118 selected and assigned
[STAGE 3][FIRE SUPPORT] Wright L118 fire mission commencing; physical ammo before=...
[STAGE 3][FIRE SUPPORT] Wright physical fire confirmed: ammo ... -> ...; local M1083 rearm requested
[STAGE 3][FIRE SUPPORT] Wright local L118 rearm complete; CampaignState AMMO 15 / 30
[STAGE 3][LOGISTICS] Wright AMMO reorder threshold reached: 15 / 30
[STAGE 3][LOGISTICS] Exactly one strategic RESUPPLY demand created; Jalalabad selected
[STAGE 3][LOGISTICS] Physical slingload manifest created at Jalalabad
[STAGE 3][LOGISTICS] CH-47 assigned; Air-AMMO manifest loading at Jalalabad
[STAGE 3][LOGISTICS] AIR-AMMO outbound + return valley route installed via OMW_FlightPath
[STAGE 3][LOGISTICS] Air-AMMO cargo picked up; Jalalabad -> Wright IN TRANSIT
[STAGE 3][LOGISTICS] Air-AMMO delivered at Wright; strategic stock restored to 30 / 30
[STAGE 3][LOGISTICS] CH-47 landed back at Jalalabad via OMW_FlightPath
[STAGE 3][LOGISTICS] CH-47 recovered by Jalalabad AIRWING
[STAGE 3][PASS] ...
```

Negativer ARTY-Gate:

```text
[STAGE 3][FIRE SUPPORT] Wright ARTY FSM ceased but physical fire NOT confirmed ...
[STAGE 3][FAIL] Wright L118 physical fire not confirmed: PHYSICAL_AMMO_UNCHANGED
```

## PASS-Kriterien

1. Honaker erreicht MOOSE `OPSZONE` Attacked.
2. Mindestens eine eigene Honaker-QRF-Soldatengruppe materialisiert und beginnt einen realen `GROUNDATTACK` gegen eine erkannte RED-Gruppe.
3. Jalalabad-CAS erreicht `Executing`; `OMW_FlightPath -> OMW_FlightPath_WEST` wird mit gültiger Junction installiert, hin und zurück.
4. Ein `FIRE_SUPPORT_IMMEDIATE`-Demand entsteht aus demselben Threat-Incident.
5. Wright L118 beginnt den Functional-ARTY-Lifecycle und `ARTY:GetAmmo(false)` ist nach CeaseFire kleiner als bei OpenFire.
6. Erst nach dieser physischen Feuerbestätigung erreicht der FIRE_SUPPORT-Demand `SUCCESS` und wird der M1083-Rearm angefordert.
7. Der lokale M1083-Rearm läuft durch und der CampaignState-Rearm-Verbrauch ist abgeschlossen.
8. Wright erreicht dadurch exakt `15` strategische AMMO-Einheiten.
9. `ResourceDemandPolicy` / `ResourceDemandCoordinator` erzeugen genau einen aktiven RESUPPLY-Demand; unmittelbare Zweitauswertung ergibt `active_duplicate`.
10. CampaignState reserviert genau einen Jalalabad->Wright-TRANSFER über 15 AMMO-Pakete.
11. Der CH-47 übernimmt dasselbe physische Manifest; `MarkInTransit` erfolgt erst nach beobachtetem Verlassen der Pickup-Zone.
12. CH-47 Hin- und Rückweg verwenden `OMW_FlightPath`.
13. Dasselbe Cargo liegt bei MOOSE-CARGOTRANSPORT-Success physisch in `OMW_BLUE_LZ_WRIGHT_01`.
14. CampaignState erreicht `DELIVERED`, MissionDemand `SUCCESS`, Wright `30`, Jalalabad `85`.
15. Der CH-47 landet physisch in Jalalabad und erst danach erfolgt `LegionAssetReturned`.

## Ergebnis des ersten kombinierten Laufs vom 2026-08-30

Der erste Lauf mit der vorherigen Bundle-Version ist **kein PASS** für diese revidierte Acceptance. Beobachtet bzw. geloggt wurden:

- OPSZONE-Threat wurde erkannt.
- QRF wurde angefordert.
- CAS wurde gestartet.
- Wright Functional ARTY meldete OpenFire und CeaseFire, aber der Tester beobachtete vor Ort keine sichtbaren Schüsse; deshalb ist dieser Lauf keine physische ARTY-Validierung.
- Beide AH-64 gingen später verloren. Der Tester beobachtete, dass sie nach Verlassen des bisherigen `OMW_FlightPath` wieder direkte Luftlinie über hohes Gelände flogen. Die Verlustursache bleibt unbewiesen; eine Midair-Kollision ist möglich, aber nicht belegt.
- Dieser Befund führte zur Aufnahme von `OMW_FlightPath_WEST` und zum physischen ARTY-Munitions-Gate.

## Mission-Editor-Vertrag

Die Acceptance mutiert keine `.miz` automatisch. Das Dist-Bundle wird einmalig **nach MOOSE, Ground Base und Jalalabad AirOps** geladen.

Aktuelle Missionsbasis:

```text
OMW_Template_v20_GroundWorks(20260830-185704).miz
```

Die Mission muss `OMW_FlightPath`, `OMW_FlightPath_WEST`, die RED-Angriffsgruppen um Honaker, Wright-L118, Wright-Resupply-Zone, Jalalabad-Logistics-Zone und Wright-LZ enthalten.

## Build

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Output:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

`VALIDATED` darf erst nach realem DCS-Lauf mit dokumentierter Missions-/Bundle-/DCS-/MOOSE-Provenienz gesetzt werden.