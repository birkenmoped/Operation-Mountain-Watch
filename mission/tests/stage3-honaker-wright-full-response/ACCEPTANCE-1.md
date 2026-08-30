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

Dieser Lauf ist der erste kombinierte Stage-3-End-to-End-Test. Er soll nicht erneut jede bereits akzeptierte Stage-2-Einzelfunktion isoliert beweisen, sondern die vorhandenen Pfade in einer realen Kette zusammenführen.

```text
RED ground forces attack COP Honaker
-> existing MOOSE OPSZONE Attacked qualification
-> Honaker own infantry QRF response
-> existing Jalalabad AH-64D immediate CAS response
-> additional FIRE_SUPPORT_IMMEDIATE demand
-> Honaker local 2B11 intentionally unavailable in this acceptance
-> Wright L118 selected
-> MOOSE Functional ARTY attacks one OPSZONE-detected RED group
-> real DCS artillery ammunition decreases
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
- Kein zweiter MOOSE-Owner für die Wright-Batterie: der kombinierte Test verwendet einen einzigen Functional-`ARTY`-FSM sowohl für reales Feuern als auch für den bereits akzeptierten lokalen Rearm-Lifecycle.
- Honaker-Mörser werden im Test nicht zerstört oder teleportiert; das late-activation Template bleibt einfach unmaterialisiert.
- CAS und Air-AMMO-Helikopter müssen Hin- **und** Rückflug über `OMW_FlightPath` durchführen.

## Warum Functional ARTY im kombinierten Lauf

Der Stage-3-Source-Review hat sowohl `AUFTRAG:NewARTY(...)` als auch Functional `ARTY:AssignAttackGroup(...)` im gepinnten MOOSE bestätigt. Der bestehende lokale Rearm-Vertrag arbeitet jedoch mit demselben Functional-`ARTY`-FSM und dessen `OnBeforeRearm` / `OnAfterRearmed`-Lifecycle.

Für diesen End-to-End-Lauf wird deshalb Functional ARTY verwendet:

```text
one Wright physical battery
-> one MOOSE ARTY FSM
-> AssignAttackGroup(real RED OPSZONE group)
-> OnAfterOpenFire
-> OnAfterCeaseFire
-> same ARTY instance
-> local Rearm()
-> OnAfterRearmed
```

Damit entsteht keine parallele MOOSE-Steuerung derselben physischen Batterie.

## Strategische Testvorbedingung

Wright beginnt laut Ground-Initial-Stock mit:

```text
GROUND_AMMO_PACKAGE = 30
reorder = 15
critical = 7.5
```

Um den vollständigen Test nicht durch unrealistisch viele lokale Rearm-Zyklen zu verlängern, setzt die Acceptance einmalig und sichtbar eine reine Testvorbedingung:

```text
Wright 30 -> 16
```

Danach muss **ein realer** Wright-L118-Feuer-/Rearm-Zyklus genau ein strategisches Paket verbrauchen:

```text
16 -> 15
```

Nur dieser reale Rearm-Commit darf den Reorder-Threshold auslösen.

## Sichtbare Runtime-Telemetrie

Wesentliche Zustandswechsel werden zusätzlich zum DCS-Log über MOOSE `MESSAGE` angezeigt. Die Meldungen sind Ereignis-getrieben; es gibt keine zeitgesteuerten Fake-Erfolgsmeldungen.

Erwartete Milestones:

```text
[STAGE 3][READY] ...
[STAGE 3][THREAT] COP Honaker under attack ...
[STAGE 3][QRF] Honaker requests own QRF ...
[STAGE 3][QRF] ... engaging ...
[STAGE 3][CAS] Honaker immediate CAS demand assigned ...
[STAGE 3][CAS] CAS outbound + return valley route installed via OMW_FlightPath
[STAGE 3][FIRE SUPPORT] Honaker requests immediate fire support ...
[STAGE 3][FIRE SUPPORT] Wright L118 selected and assigned
[STAGE 3][FIRE SUPPORT] Wright L118 fire mission commencing
[STAGE 3][FIRE SUPPORT] Wright fire mission complete; local M1083 rearm requested
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

## PASS-Kriterien

Der Lauf ist nur PASS, wenn mindestens folgende Evidenz gleichzeitig vorliegt:

1. Honaker erreicht MOOSE `OPSZONE` Attacked.
2. Mindestens eine eigene Honaker-QRF-Soldatengruppe materialisiert und beginnt einen realen `GROUNDATTACK` gegen eine erkannte RED-Gruppe.
3. Jalalabad-CAS erreicht `Executing` und die `OMW_FlightPath`-Korridorinstallation ist bestätigt.
4. Ein `FIRE_SUPPORT_IMMEDIATE`-Demand entsteht aus demselben Threat-Incident.
5. Wright L118 beginnt real zu feuern und DCS-Munition sinkt.
6. Der bestehende lokale M1083-Rearm läuft durch und der CampaignState-Rearm-Verbrauch ist abgeschlossen.
7. Wright erreicht dadurch exakt `15` strategische AMMO-Einheiten.
8. `ResourceDemandPolicy` / `ResourceDemandCoordinator` erzeugen genau einen aktiven RESUPPLY-Demand; eine unmittelbare zweite Evaluation ergibt `active_duplicate`.
9. CampaignState reserviert genau einen Jalalabad->Wright-TRANSFER über 15 AMMO-Pakete.
10. Der CH-47 übernimmt dasselbe physische Manifest und `MarkInTransit` erfolgt erst nach beobachtetem Verlassen der Pickup-Zone.
11. CH-47 Hin- und Rückweg verwenden `OMW_FlightPath`.
12. Dasselbe Cargo liegt bei MOOSE-CARGOTRANSPORT-Success physisch in `OMW_BLUE_LZ_WRIGHT_01`.
13. CampaignState erreicht `DELIVERED`, MissionDemand erreicht `SUCCESS`, Wright ist wieder `30`, Jalalabad `85`.
14. Der CH-47 landet physisch in Jalalabad und erst danach erfolgt `LegionAssetReturned`.

## Mission-Editor-Vertrag

Die Acceptance mutiert keine `.miz` automatisch. Der gebaute Dist-Bundle wird als einmaliger `DO SCRIPT FILE` **nach MOOSE, Ground Base und Jalalabad AirOps** geladen.

Vorgesehene Missionsbasis für den aktuellen Lauf:

```text
OMW_Template_v20_GroundWorks(20260830-181206).miz
```

Die Mission enthält bereits die für diesen Test benötigten RED-Angriffsgruppen um Honaker sowie die benötigten OMW-Objekte/Geometrien einschließlich `OMW_FlightPath`, Wright-L118, Wright-Resupply-Zone, Jalalabad-Logistics-Zone und Wright-LZ.

## Build

```text
tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
```

Output:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

`VALIDATED` darf erst nach realem DCS-Lauf mit dokumentierter Missions-/Bundle-/DCS-/MOOSE-Provenienz gesetzt werden.
