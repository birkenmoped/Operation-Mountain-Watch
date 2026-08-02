---
document_id: OMW-AIR-SALERNO-MANIFEST
status: BINDING
document_class: MISSION_EDITOR_BASELINE
owning_policy: OMW-GOV-001
authoritative_for:
  - Salerno-specific Mission Editor naming and object structure
  - application of the active Salerno ORBAT from OMW-AIR-ACTIVE-ORBAT
  - Salerno client, template, static, warehouse and zone authoring requirements
not_authoritative_for:
  - project-wide air ORBAT
  - project-wide client limits
  - branch-independent technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Salerno manifests using document numbers 51-53
  - Khost as the presumed DCS airbase binding for airdromeId 23
  - CH-47D as the Mission Editor type for current Salerno CH-47 objects
superseded_by:
source_branch: agent/normalize-salerno-air-orbat
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 81 – FOB Salerno Air Operations Manifest

## 1. Autorität und Abgrenzung

Dieses Manifest ist die Salerno-spezifische Missionseditor-Arbeitsbaseline. Vorrangige Quellen sind:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md);
- [`OMW-ME-MASTER-WORKLIST`](38-mission-editor-master-worklist.md);
- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md);
- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md).

Historische Forschung, aktive OMW-ORBAT, Mission-Editor-Repräsentation und Runtime-Acceptance bleiben getrennt.

## 2. Historische Einordnung Juli 2011

Für Juli 2011 sind auf FOB Salerno unter anderem belegt:

```text
TF Duke / 3rd BCT, 1st Infantry Division
TF Centaur / 1-6 Field Artillery
TF Blue Spader / 1-26 Infantry
TF Tigershark / 1-10 Attack Aviation
```

TF Tigershark war TF Falcon / 10th Combat Aviation Brigade unterstellt und unterstützte Khost und Paktya.

B Company, 7-158 Aviation ist ab April 2011 als CH-47-Company-Hauptquartier auf FOB Salerno dokumentiert. Der zugehörige Pool umfasste 25 CH-47 und war auf Bagram, FOB Salerno und FOB Shank verteilt. Die Quelle nennt keine exakte lokale Aufteilung.

## 3. Verbindlicher logischer Salerno-Bestand

```text
 8 AH-64D
 8 OH-58D
 7 UH-60 Assault
 3 UH-60 MEDEVAC
 6 CH-47
------------
32 Luftfahrzeuge
```

Evidenzstatus:

| Komponente | Wert | Einstufung |
|---|---:|---|
| AH-64D | 8 | `SOURCE_DERIVED / CORROBORATED_PLAUSIBLE` |
| OH-58D | 8 | `SOURCE_DERIVED / CORROBORATED_PLAUSIBLE` |
| UH-60 Assault | 7 | `RECONSTRUCTED_LOCAL_INVENTORY` |
| UH-60 MEDEVAC | 3 | `RECONSTRUCTED_LOCAL_INVENTORY` |
| CH-47 | 6 | `RECONSTRUCTED_POOL_ALLOCATION` |

Diese Werte sind eine quellenbasierte OMW-Kampagnenentscheidung. Sie sind keine Behauptung einer vollständig veröffentlichten Stichtags-TOE.

## 4. Bestands- und Repräsentationsregel

Der logische Bestand ist strikt getrennt von:

- Client-Reservierungen;
- aktiven KI-Luftfahrzeugen;
- Late-Activation-Templates;
- sichtbaren Statics;
- virtueller Reserve;
- beschädigten und endgültig verlorenen Luftfahrzeugen.

```text
LOGICAL_INVENTORY
!= STATIC_COUNT
!= CLIENT_COUNT
!= TEMPLATE_COUNT
!= ACTIVE_AI_COUNT
```

Statics, Clients und Templates sind wechselnde Repräsentationen desselben Bestands und dürfen ihn nicht mehrfach erhöhen.

## 5. DCS-Airbase-Vertrag

Historische Ortsbezeichnung:

```text
FOB Salerno, Khost
```

Technische DCS-Bindung:

```text
AIRBASE.Afghanistan.FOB_Salerno
observed airdromeId = 23
```

`Khost` bezeichnet in historischen Quellen den geografischen Raum beziehungsweise einen separaten Flugplatz. Für den Salerno-Knoten darf nicht zusätzlich `AIRBASE.Afghanistan.Khost` gebunden werden, solange ein Runtime-Diagnoselauf keine abweichende Zuordnung beweist.

## 6. MOOSE-Objektstruktur

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT
```

Warehouse-Anker:

```text
WH_AIR_US_SALERNO
```

Die Rollenbezeichnungen bleiben dort absichtlich generisch, wo eine exakte Company-Zuordnung noch nicht ausreichend belegt ist. Es werden keine Einheitsnamen erfunden.

## 7. Client-Gruppen

Verpflichtende Client-Gruppen im aktuellen Missionsstand:

```text
CLIENT_US_SAL_AH64D_01
CLIENT_US_SAL_AH64D_02
CLIENT_US_SAL_OH58D_01
CLIENT_US_SAL_OH58D_02
CLIENT_US_SAL_CH47F_01
CLIENT_US_SAL_CH47F_02
```

Optionale UH-60L-Modvariante:

```text
CLIENT_US_SAL_UH60L_01
CLIENT_US_SAL_UH60L_02
```

Für die Kernmission sind nur `0` oder `2` UH-60L-Client-Gruppen zulässig. Die modfreie Kernmission darf nicht von der Modvariante abhängen.

## 8. Aktuelle Client-Parkpositionen

| Client | Parking-ID |
|---|---:|
| `CLIENT_US_SAL_AH64D_01` | 36 |
| `CLIENT_US_SAL_AH64D_02` | 40 |
| `CLIENT_US_SAL_OH58D_01` | 22 |
| `CLIENT_US_SAL_OH58D_02` | 23 |
| `CLIENT_US_SAL_CH47F_01` | 21 |
| `CLIENT_US_SAL_CH47F_02` | 13 |

Vorläufige Client-Blacklist:

```text
13, 21, 22, 23, 36, 40
```

Die vollständige KI-Parking-Allowlist und das Safe-Parking-Verhalten bleiben bis zu einem MOOSE-/DCS-Parking-Dump offen.

## 9. KI-Templates

```text
TPL_AIR_US_SAL_AH64D_CAS_2SHIP          2 AH-64D
TPL_AIR_US_SAL_OH58D_RECON_2SHIP        2 OH-58D
TPL_AIR_US_SAL_UH60_ASSAULT_2SHIP       2 UH-60A
TPL_AIR_US_SAL_UH60_MEDEVAC_1SHIP       1 UH-60A
TPL_AIR_US_SAL_CH47_TRANSPORT_1SHIP     1 CH-47Fbl1
```

Alle Templates werden als `Late Activation` und `Uncontrolled = false` geführt. Sie sind Authoring-Objekte und kein zusätzlicher Bestand.

## 10. Historische und technische Typabbildung

| Rolle | Historische Einordnung | Aktueller DCS-Typ |
|---|---|---|
| Attack | AH-64D | `AH-64D_BLK_II` |
| Scout/Recon | OH-58D | `OH58D` |
| Assault/MEDEVAC | UH-60-Familie | `UH-60A`; optionale Clients UH-60L-Mod |
| Medium/Heavy Lift | CH-47D im historischen Zeitraum | `CH-47Fbl1` |

Die CH-47-Abweichung muss ausdrücklich sichtbar bleiben:

```text
historisch: CH-47D
DCS-Repräsentation: CH-47Fbl1
```

## 11. Aktuelle Payload-Baseline

### AH-64D

Das Salerno-CAS-Template verwendet die projektweite Baseline aus Dokument 19:

```text
2 × M261 mit jeweils 19 × M151 HE
2 × AGM-114K gesamt
300 × M789 HEDP / ME-Wert 25 Prozent
IAFS/Robbie Tank
```

### OH-58D

Der aktuelle Missionsstand verwendet:

```text
M3P mit 500 Schuss
M260 mit M151 HE
```

Diese Konfiguration ist als Salerno-Arbeitsbaseline dokumentiert, aber noch nicht branchunabhängig in DCS akzeptiert.

### UH-60 und CH-47

Die aktuellen Templates verwenden:

```text
UH-60A: keine Pylonenbeladung
CH-47Fbl1: Port und Starboard M60D
```

## 12. Sichtbare Statics im aktuellen Missionsstand

```text
3 AH-64D-Statics
4 OH-58D-Statics
3 UH-60-Assault-Statics
1 UH-60-MEDEVAC-Static
4 CH-47F-Statics
```

Gesamt:

```text
15 Luftfahrzeug-Statics
```

Die Statics sind Teil des logischen Bestands und kein Zusatzbestand.

Für den Sechserbestand der CH-47 gilt insbesondere: vier Statics, zwei Client-Reservierungen und ein Late-Activation-Template dürfen nicht gleichzeitig als sieben physisch verfügbare Luftfahrzeuge gezählt werden. Die spätere Runtime muss Repräsentationen aus demselben Pool reservieren und freigeben.

## 13. Funktionszonen

Im aktuellen Missionsstand vorhanden:

```text
ZONE_AIR_US_SAL_CSAR_UNLOAD
```

Zusätzliche Zonen werden nur angelegt, wenn eine konkrete Funktion sie benötigt. Der frühere Planname `ZONE_AIR_US_SAL_MEDEVAC_TRANSFER` wird nicht parallel als Synonym angelegt.

Noch fachlich vorgesehene, aber nicht automatisch anzulegende Zonen:

```text
ZONE_AIR_US_SAL_MEDEVAC_READY
ZONE_AIR_US_SAL_LOGISTICS_LOAD
ZONE_AIR_US_SAL_LOGISTICS_UNLOAD
```

Optionale Zonen erst nach bestätigtem Bedarf:

```text
ZONE_AIR_US_SAL_SLING_PICKUP
ZONE_AIR_US_SAL_HOT_REFUEL
ZONE_AIR_US_SAL_HEAVYLIFT_LOAD
ZONE_AIR_US_SAL_TEST_SAFETY
```

## 14. Aktueller Missionsstand

Referenzdatei:

```text
OMW_Template_v4_Kandahar(11).miz
SHA-256: 3063a05a394f058e99d45f78591dcc5d4f71e06457915302789cb73bffa81b22
```

Enthalten:

```text
6 Client-Gruppen / 6 Client-Units
5 Late-Activation-KI-Templates / 8 Template-Units
15 Luftfahrzeug-Statics
1 Warehouse-Anker
1 Salerno-Funktionszone
```

Nicht enthalten:

```text
keine Salerno-AIRWING-Runtime
keine Salerno-SQUADRON-Registrierung
kein Salerno-Parking-Contract
kein Salerno-AUFTRAG oder OPSTRANSPORT
```

## 15. MOOSE-first und nächster technischer Schritt

Vor produktivem Lua-Code sind die tatsächlich eingebundene MOOSE-Version, ihre Quellen, Dokumentation und Demos für mindestens folgende Bereiche zu prüfen:

- `AIRBASE` und Runtime-Namensauflösung;
- Parking-Dump, Parking-Blacklist und Safe Parking;
- `STATIC` beziehungsweise Warehouse-Ankerauflösung;
- `AIRWING`;
- `SQUADRON`;
- Bestands- und Repräsentationsverwaltung.

Der erste zulässige Test ist ein read-only Diagnoselauf ohne Spawn und ohne Tasking. Er soll:

1. MOOSE-Version und Hash protokollieren;
2. `WH_AIR_US_SALERNO` auflösen;
3. `FOB_Salerno` und `airdromeId 23` bestätigen;
4. die Parking-Nodes ausgeben;
5. Clients, Templates, Statics und Zonen zählen;
6. keine AIRWING-, SQUADRON-, Payload- oder Spawn-Mutation ausführen.

## 16. Offene Punkte

- vollständige Parking-Node-Liste und KI-Allowlist;
- exakte Ramp-/Taxi-Acceptance;
- Runtime-Bestätigung von `AIRBASE.Afghanistan.FOB_Salerno`;
- endgültige Company-Zuordnung der Assault-UH-60;
- belastbarere lokale Aufteilung des B/7-158-CH-47-Pools;
- Mission-ready- und Wartungsquoten;
- Liveries und Selbstschutzkonfigurationen;
- produktive Verlust-, Rückkehr- und Repräsentationslogik;
- DCS-Runtime-Acceptance.
