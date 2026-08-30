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
source_commit: 1be16ef24e6f3727793dfe069d827690cc6a6bf9
validated_in_dcs: false
---

# Stage 3 Acceptance 1 – Honaker -> Wright -> Jalalabad Air-AMMO

## Zweck

Dieser Lauf ist der kombinierte Stage-3-End-to-End-Test. Er führt vorhandene MOOSE-first-Pfade in einer realen Kette zusammen und verlangt jetzt reale Feuer-Evidenz sowohl für Wright ARTY als auch für den AH-64-CAS-Anteil.

```text
RED ground forces attack COP Honaker
-> existing MOOSE OPSZONE Attacked qualification
-> Honaker own infantry QRF response
-> Jalalabad AH-64D CAS response
-> OMW_FlightPath at 500 ft AGL
-> OMW_FlightPath_WEST at 2500 ft AGL / RotaryWing.Column.D70
-> CAS combat mission at 10000 ft mission altitude
-> MOOSE EngageDetected against Ground Units inside Honaker security zone
-> real AH-64 Shot event required as execution evidence
AND
-> FIRE_SUPPORT_IMMEDIATE demand
-> Honaker local 2B11 intentionally unavailable
-> wait 15 s for the existing OPSZONE target picture
-> select up to 3 currently detected RED groups
-> obtain each target coordinate from the detected MOOSE GROUP
-> Wright L118 MOOSE Functional ARTY AssignTargetCoord
-> DCS Fire At Point
-> 4 rounds per queued coordinate fire mission
-> physical ARTY ammo decrease required for every target
-> only after all queued fire missions complete: FIRE_SUPPORT SUCCESS
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
- Keine neue Feinderkennung: Bedrohungsevidenz und ARTY-Zielauswahl kommen aus dem bestehenden `OMW_FobThreatOpsZoneAdapter` / MOOSE `OPSZONE`.
- Keine zweite QRF-Logik außerhalb des vorhandenen MOOSE-`BRIGADE`/`PLATOON`/`AUFTRAG:NewGROUNDATTACK`-Musters.
- Kein zweiter MOOSE-Owner für die Wright-Batterie: ein Functional-`ARTY`-FSM besitzt Feuer und lokalen Rearm-Lifecycle.
- `OnAfterOpenFire` / `OnAfterCeaseFire` allein gelten nicht als Beweis realer Schüsse. Für jedes ARTY-Ziel muss `ARTY:GetAmmo(false)` sinken.
- `AUFTRAG:NewCAS(...):OnAfterSuccess` allein gilt nicht als Beweis eines CAS-Angriffs. Im Acceptance-Lauf wird mindestens ein reales MOOSE-`EVENTS.Shot` der zugewiesenen AH-64-Gruppe verlangt.
- Honaker-Mörser werden im Test nicht zerstört oder teleportiert; das late-activation Template bleibt unmaterialisiert.
- Air-AMMO nach Wright verwendet weiterhin ausschließlich `OMW_FlightPath` hin und zurück.

## Wright ARTY – korrigierter MOOSE-Pfad

Der vorherige Versuch verwendete `ARTY:AssignAttackGroup()`. MOOSE akzeptierte den Auftrag und ging in `OpenFire`, DCS erzeugte aber innerhalb des 120-s-Wartefensters keinen Schuss; die physische Munition blieb `300 -> 300`. Deshalb wurde dieser Pfad für indirektes L118-Feuer verworfen.

Der neue Vertrag verwendet den für indirektes Feuer vorgesehenen Functional-ARTY-Koordinatenpfad:

```text
existing OPSZONE
-> detected RED GROUP
-> GROUP:GetCoordinate()
-> ARTY:AssignTargetCoord(...)
-> MOOSE _FireAtCoord
-> DCS TaskFireAtPoint
```

Die Zielkoordinaten werden bei der Feueranforderung aus den real erkannten RED-Gruppen gewonnen. Es gibt keinen zusätzlichen Target-Scanner und keinen manuell gesetzten Feuer-Marker.

Der Acceptance-Lauf wartet nach `OPSZONE Attacked` 15 Sekunden, damit die vorhandene OPSZONE ihr aktuelles Zielbild aktualisieren kann. Danach werden höchstens drei aktuell erkannte RED-Gruppen nach Nähe zu Honaker ausgewählt. Vor der Übergabe werden pro Ziel sichtbar/loggend Zielname, Koordinate, Wright-Zieldistanz sowie die vom laufenden MOOSE-ARTY-Objekt verwendete Min-/Max-Range ausgegeben. Ein außerhalb dieses Envelopes liegendes Ziel führt zum expliziten FAIL.

Für jedes ausgewählte Ziel gilt:

```text
4 rounds requested
-> OpenFire
-> physical ammo baseline
-> real MOOSE Shot events / DCS fire
-> CeaseFire
-> physical ammo must be lower
```

Erst wenn alle in diesem Incident tatsächlich eingereihten Koordinatenziele physisch bestätigt wurden, darf der gemeinsame `FIRE_SUPPORT_IMMEDIATE`-Demand `SUCCESS` erreichen und der lokale M1083-Rearm angefordert werden.

`ARTY:SetWaitForShotTime()` wird auf den MOOSE-Defaultwert von `300 s` gesetzt. Das ist **kein Artillerie-Cooldown**, sondern ausschließlich die maximale Wartezeit auf das erste reale `Shot`-Event, bevor MOOSE einen fehlgeschlagenen Feuerauftrag abbricht.

## CAS – korrigierter MOOSE-Pfad

Der erste CAS-Versuch zeigte, dass `AUFTRAG:NewCAS()` formal `SUCCESS` melden kann, ohne dass damit ein realer Waffenabschuss bewiesen ist. Der neue Acceptance-Vertrag behält den vorhandenen CAS-Missionstyp für AIRWING/SQUADRON-Kompatibilität bei, aktiviert aber zusätzlich die bereits vorhandene MOOSE-Engagement-Funktion:

```text
AUFTRAG:NewCAS(Honaker security zone, 10000 ft, 120 kt)
-> AUFTRAG:SetEngageDetected(5 NM, {"Ground Units"}, Honaker security zone)
```

Damit bleibt MOOSE für Zielerkennung und Engagement zuständig. Zusätzlich korreliert ein MOOSE-`EVENTHANDLER` das erste reale `EVENTS.Shot` mit der tatsächlich zugewiesenen AH-64-FLIGHTGROUP. Erst diese Evidenz darf den CAS-MissionDemand im Acceptance-Lauf erfolgreich schließen.

Der Acceptance-Code schreibt nicht vor, ob DCS für ein konkretes weiches Ziel M230, Hydra oder Hellfire wählt. Der reale Weapon-Type wird aus dem Shot-Event gemeldet. Eine spätere explizite Waffenpräferenz wäre eine eigene Entscheidung und wird nicht in diesen Test hineinerfunden.

## Verkettete PATHLINE-Route und Höhenprofil

`OMW_HelicopterFlightPathCorridor` unterstützt eine geordnete Folge vorhandener MOOSE-`PATHLINE`-Objekte. Zwischen zwei Linien wird das nächstgelegene Punktpaar als Junction verwendet. Der Acceptance-Vertrag akzeptiert nur Junctions bis `1000 m`; größere Lücken führen zu einem expliziten Fehler statt zu einem stillen Luftlinien-Segment.

Für den Honaker-CAS gilt:

```text
Jalalabad
-> OMW_FlightPath             500 ft AGL
-> Junction bei Kerala
-> OMW_FlightPath_WEST       2500 ft AGL
   RotaryWing.Column.D70
-> Honaker CAS mission       10000 ft mission altitude
```

MOOSE `FLIGHTGROUP:AddWaypoint()` verwendet für Helikopter `RADIO`-Höhen; die Korridorwerte sind deshalb AGL. Die Formation wird beim Eintritt in das profilierte WEST-Segment über die vorhandene MOOSE-`GROUP:SetFormation(ENUMS.Formation.RotaryWing.Column.D70)`-API gewechselt.

Der Rückweg wird aus derselben zusammengesetzten Geometrie rückwärts aufgebaut. Der WEST-Anteil bleibt bei `2500 ft AGL` und Column. Für Wright-Air-AMMO gilt weiterhin:

```text
Jalalabad
-> OMW_FlightPath
-> Wright
-> OMW_FlightPath reverse
-> Jalalabad
```

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

Nur dieser reale Rearm-Commit darf den Reorder-Threshold auslösen. Die Zahl der verschossenen Granaten wird nicht 1:1 auf `GROUND_AMMO_PACKAGE` abgebildet.

## Sichtbare Runtime-Telemetrie

Wesentliche Zustandswechsel werden zusätzlich zum DCS-Log über MOOSE `MESSAGE` angezeigt. Erfolgsmeldungen sind ereignis- und evidenzgebunden. Insbesondere werden sichtbar:

```text
[STAGE 3][THREAT] OPSZONE Attacked
[STAGE 3][QRF] ... assigned / engaging
[STAGE 3][CAS] AH-64 assigned; real weapon employment required
[STAGE 3][CAS] ... WEST 2500 ft AGL / RotaryWing.Column.D70
[STAGE 3][CAS] ... MOOSE EngageDetected active
[STAGE 3][CAS] AH-64D weapon employment confirmed: <weapon>
[STAGE 3][FIRE SUPPORT] waiting 15 s for OPSZONE target picture
[STAGE 3][FIRE SUPPORT] ... N OPSZONE targets selected
[STAGE 3][FIRE SUPPORT] Target i/N ... Wright range ... envelope ...
[STAGE 3][FIRE SUPPORT] Wright L118 ... coordinate Fire At Point missions queued
[STAGE 3][FIRE SUPPORT] Wright L118 firing at <target>; physical ammo before=...
[STAGE 3][FIRE SUPPORT] Wright target i/N complete ... ammo ... -> ...
[STAGE 3][FIRE SUPPORT] Wright completed N coordinate fire missions ... local M1083 rearm requested
[STAGE 3][FIRE SUPPORT] Wright local L118 rearm complete; CampaignState AMMO 15 / 30
[STAGE 3][LOGISTICS] Wright AMMO reorder threshold reached: 15 / 30
[STAGE 3][LOGISTICS] Exactly one strategic RESUPPLY demand created; Jalalabad selected
[STAGE 3][LOGISTICS] ... CH-47 ...
[STAGE 3][PASS] ...
```

Bleibt die physische ARTY-Munition eines Zieles unverändert, muss der Test mit `PHYSICAL_AMMO_UNCHANGED` abbrechen. Ein CAS-`AUFTRAG Success` ohne Shot-Evidenz darf den CAS-Demand nicht mehr erfolgreich schließen.

## PASS-Kriterien

1. Honaker erreicht MOOSE `OPSZONE` Attacked.
2. Mindestens eine eigene Honaker-QRF-Soldatengruppe materialisiert und beginnt einen realen `GROUNDATTACK` gegen eine erkannte RED-Gruppe.
3. Jalalabad-CAS erreicht `Executing`; `OMW_FlightPath -> OMW_FlightPath_WEST` wird mit gültiger Junction installiert.
4. Der WEST-Abschnitt wird mit `2500 ft AGL` und `RotaryWing.Column.D70` profiliert; der Hauptkorridor bleibt `500 ft AGL`.
5. CAS aktiviert MOOSE `SetEngageDetected` für Ground Units in der Honaker-Security-Zone und mindestens ein reales Shot-Event der zugewiesenen AH-64-Gruppe wird erfasst.
6. Ein `FIRE_SUPPORT_IMMEDIATE`-Demand entsteht aus demselben Threat-Incident.
7. Nach der 15-s-Akquisitionsphase werden bis zu drei aktuell von derselben OPSZONE erkannte RED-Gruppen als Koordinatenziele übernommen; alle liegen innerhalb des gemeldeten MOOSE-ARTY-Range-Envelopes.
8. Wright verwendet `ARTY:AssignTargetCoord()` / DCS `Fire At Point`; `ARTY:GetAmmo(false)` sinkt bei jedem eingereihten Ziel.
9. Erst nach allen physisch bestätigten Feueraufträgen erreicht FIRE_SUPPORT `SUCCESS` und wird der M1083-Rearm angefordert.
10. Der lokale M1083-Rearm läuft durch und CampaignState verbraucht genau ein `GROUND_AMMO_PACKAGE`, Wright `16 -> 15`.
11. `ResourceDemandPolicy` / `ResourceDemandCoordinator` erzeugen genau einen aktiven RESUPPLY-Demand; unmittelbare Zweitauswertung ergibt `active_duplicate`.
12. CampaignState reserviert genau einen Jalalabad->Wright-TRANSFER über 15 AMMO-Pakete.
13. Der CH-47 übernimmt dasselbe physische Manifest; `MarkInTransit` erfolgt erst nach beobachtetem Verlassen der Pickup-Zone.
14. CH-47 Hin- und Rückweg verwenden `OMW_FlightPath`.
15. Dasselbe Cargo liegt bei MOOSE-CARGOTRANSPORT-Success physisch in `OMW_BLUE_LZ_WRIGHT_01`.
16. CampaignState erreicht `DELIVERED`, RESUPPLY-MissionDemand `SUCCESS`, Wright `30`, Jalalabad `85`.
17. Der CH-47 landet physisch in Jalalabad und erst danach erfolgt `LegionAssetReturned`.

## Befunde der vorherigen Läufe vom 2026-08-30

Die vorherigen Bundle-Versionen sind **kein PASS** für diese revidierte Acceptance:

- OPSZONE-Threat und QRF wurden ausgelöst.
- Wright Functional ARTY meldete mit `AssignAttackGroup()` OpenFire/CeaseFire, erzeugte aber keinen realen Schuss; der physische Bestand blieb `300 -> 300`. Der Physical-Fire-Gate erkannte dies korrekt als `PHYSICAL_AMMO_UNCHANGED`.
- CAS wurde gestartet und die verkettete WEST-Route installiert.
- Beide AH-64 feuerten nach der vorliegenden Runtime-Evidenz nicht, bevor sie verloren gingen.
- Das Debrief weist beide AH-64-Verluste auf RED `Soldier AK` / 5.45x39-mm-Feuer zurück; eine zuvor erwogene Midair-Kollision ist für diesen Lauf damit verworfen.
- Die Route und das Profil wurden daraufhin geändert: WEST `2500 ft AGL`, `RotaryWing.Column.D70`; CAS-Erfolg verlangt jetzt reale Shot-Evidenz.

Diese Befunde sind Testevidenz für die jeweils dokumentierten alten Bundles und werden nicht als Validierung des neuen Standes fortgeschrieben.

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
