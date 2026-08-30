---
document_id: OMW-MOOSE-CLASS-INDEX-STAGE-2-ACCEPTANCE-2-ACTIVE-GROUND-ADDENDUM
status: PLANNED
document_class: MOOSE_CLASS_REGISTER_ADDENDUM
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Stage 2B active Fortress Guard MOOSE API evidence
  - branch-local Stage 2B multi-QRF MOOSE API evidence
not_authoritative_for:
  - master PROJECT-CLASS-INDEX status on main
  - DCS validation before Acceptance 2 passes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Stage 2B active Ground response – MOOSE class-index addendum

Pinned framework:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## Source-verifizierte APIs

| Klasse/API | Source-Status | Stage-2B-Verwendung |
|---|---|---|
| `PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | `Ngroups` ist ausdrücklich die Anzahl der Asset-Gruppen des Platoons; Acceptance stellt bis zu sieben QRF-Squad-Assets aus einem vorhandenen 9-Mann-Template bereit. |
| `AUFTRAG:NewONGUARD(Coordinate)` | `SOURCE_VERIFIED`, bestehender Stage-2B-Pfad | Bereitschafts-/Sicherungsmission des Fortress Guards. |
| `AUFTRAG:SetEngageDetected(RangeMax, TargetTypes, EngageZoneSet, NoEngageZoneSet)` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | aktiviert MOOSE-eigene automatische Zielerfassung für den Guard; RangeMax wird in NM angegeben. |
| `ARMYGROUP:EngageTarget(Target, Speed, Formation)` / `OnAfterEngageTarget` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | aktiver Ground-Gegenstoß gegen erkannten Feind; MOOSE setzt OpenFire/Alarm Auto und fügt einen Waypoint bei 95 % der Strecke zum Ziel ein. |
| `ARMYGROUP:_UpdateEngageTarget()` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | aktualisiert den Engage-Waypoint, wenn sich das Ziel >100 m bewegt oder LOS verloren geht. |
| `ARMYGROUP:Disengage()` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | beendet den Engage-Detour, stellt ROE/Alarmzustand wieder her und lässt den normalen Missions-/Done-Pfad weiterlaufen. |
| `AUFTRAG:NewGROUNDATTACK(Target, Speed, Formation)` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | eine konkrete QRF pro konkret zugewiesener RED-Gruppe; MOOSE Ground-Attack-Weg statt eigener DCS Attack-Task-Logik. |
| `COHORT/PLATOON:CountAssets(true, AUFTRAG.Type.GROUNDATTACK)` | `SOURCE_VERIFIED_PENDING_DCS_STAGE2B` | begrenzt QRF-Dispatch auf tatsächlich verfügbare GROUNDATTACK-fähige physische Assets. |

## MOOSE-internes Präzedenzsignal für ONGUARD

Der gepinnte `Moose.lua` verwendet in seinem CHIEF-/strategischen Pfad selbst folgende Kombination:

```lua
mission = AUFTRAG:NewONGUARD(TargetZone:GetRandomCoordinate(...))
mission:SetEngageDetected(25, {"Ground Units", "Light armed ships", "Helicopters"})
```

Damit ist `ONGUARD + SetEngageDetected` kein erfundener OMW-Sonderweg, sondern eine im gepinnten Framework selbst verwendete Kombination.

Für Ground-Gruppen prüft MOOSE während des Cruising-Zustands `detectionOn` und `engagedetectedOn`; bei erkanntem Ziel wird `EngageTarget(targetgroup)` ausgelöst.

## `EngageTarget`-Bewegungssemantik

Der gepinnte `ARMYGROUP:onafterEngageTarget(...)`:

```text
Target -> TARGET wrapper
-> target coordinate
-> intermediate coordinate at 95 % toward target
-> Alarm Auto
-> ROE OpenFire
-> AddWaypoint(..., updateRoute=true)
-> detour=1
```

Bei laufender Nicht-GROUNDATTACK-/Nicht-CAPTUREZONE-Mission pausiert `onbeforeEngageTarget` die aktuelle Mission und versucht das Engage-Ereignis erneut. Das ist für den ONGUARD-Guard relevant.

DCS-only bleibt, ob Infantry-Pathfinding diesen MOOSE-Waypoint in der konkreten Fortress-/HESCO-Geometrie sinnvoll ausführt.

## Multi-QRF-Grenze des Acceptance-Harness

Der Harness verwendet keinen starren Spawnwert als taktische Entscheidung. Die disponierte Anzahl ist:

```text
min(
  alive RED groups in current OPSZONE scan,
  available GROUNDATTACK-capable QRF assets,
  CampaignState 9-person slots above reserve floor 80,
  acceptance cap 7
)
```

Die Zielauswahl wird vor Dispatch deterministisch nach Entfernung zur Fortress-Referenz und anschließend nach Gruppenname sortiert. Jede QRF erhält eine eigene `GROUNDATTACK`-Mission und eine eigene CampaignState-Deployment-Reservation.

Diese konkrete Sizing-/Targeting-Komposition bleibt bis zum realen DCS-Lauf `PLANNED`; sie ist noch keine produktionsweite Doktrin.

## Demo-Prüfung

Die offizielle MOOSE-Missionssammlung wurde für `EngageTarget`, `SetEngageDetected`, `ONGUARD` und `GROUNDATTACK` durchsucht. In der durchsuchbaren Sammlung wurde kein belastbarer passender Demo-Nachweis gefunden. Deshalb beruht der API-/Semantiknachweis hier auf dem tatsächlich gepinnten `Moose.lua`, einschließlich der dort vorhandenen CHIEF-internen Nutzung von `ONGUARD + SetEngageDetected`.

## DCS-Acceptance erforderlich

Vor Hochstufung sind mindestens sichtbar zu bestätigen:

```text
Guard leaves passive stance and actively engages a detected RED target
QRF count matches target/asset/reserve constraints
QRF target assignments are deterministic and distinct where possible
all dispatched QRFs visibly move/engage or are destroyed beforehand
no unacceptable HESCO/pathfinding behavior is hidden by log-only success
native origin ReturnToLegion and CampaignState settlement still work for all survivors
```
