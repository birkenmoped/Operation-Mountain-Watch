---
document_id: OMW-AIR-ACTIVE-ORBAT
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - active campaign air ORBAT
  - active squadron selection
  - local aircraft inventory
  - player aircraft limits
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - Bagram 336th EFS active baseline
  - Kandahar 75th EFS active baseline
  - Jalalabad 24/8/6 inventory
  - Khost Salerno research ranges of 12-16 AH-64D 4-8 OH-58D 2-4 UH-60 and 0-2 CH-47
  - provisional Salerno 6 AH-64D 6 OH-58D 8 UH-60 and 6 CH-47 working estimate
  - player limits above two aircraft per type and base
source_branch: agent/document-salerno-air-operations
validated_in_dcs: false
document_class: PROJECT_DECISION
source_commit: PENDING_MERGE
superseded_by:
---

# 19 – Verbindliche Entscheidungen zur aktiven Luft-ORBAT

## Zweck

Dieses Dokument legt die aktive, in der Mission umzusetzende Luft-ORBAT fest. Die historische Recherche und reale Rotationen bleiben in den Fach- und Quelldokumenten erhalten, erzeugen jedoch nicht automatisch Spieler-Slots, KI-SQUADRONs, Templates, Statics oder Bestände.

Der verbindliche Kampagnenzeitraum ist:

```text
01.08.2010 bis 31.12.2011
```

Die aktive ORBAT ist eine quellenbasierte und spielbare Auswahl innerhalb dieses Zeitraums. Sie ist keine Behauptung, alle ausgewählten Verbände hätten an einem einzigen historischen Stichtag gleichzeitig exakt in dieser Stärke bereitgestanden.

## Gemeinsame Bestands- und Darstellungsregeln

Folgende Größen sind strikt getrennt zu führen:

- logischer Kampagnenbestand;
- mission-ready Bestand;
- sichtbare Statics;
- Client-Reservierungen;
- aktive KI-Luftfahrzeuge;
- virtuelle Reserve;
- beschädigte und endgültig verlorene Luftfahrzeuge.

Statics, Client-Slots, Late-Activation-Templates und aktive KI-Gruppen sind Repräsentationen beziehungsweise Authoring-Objekte und dürfen den logischen Bestand nicht mehrfach erhöhen.

## Projektweite Client-Obergrenze

```text
maximal 2 Client-Luftfahrzeuge je Muster und Basis
maximal 2 Client-Gruppen je Muster und Basis
1 Luftfahrzeug je Client-Gruppe
```

Diese Regel ersetzt sämtliche älteren Angaben von vier, vier bis acht oder mehr Spielerluftfahrzeugen je Muster und Basis.

## Entscheidungsübersicht

| Nr. | Flugplatz | Muster / Bereich | Verbindliche aktive Entscheidung | Status |
|---:|---|---|---|---|
| 1 | Bagram | F-15E | 335th Expeditionary Fighter Squadron, 13 F-15E | `BINDING` |
| 2 | Bagram | F-16C | 121st Expeditionary Fighter Squadron, 13 historische F-16C Block 30; DCS Block 50 als gekennzeichneter Ersatz | `BINDING` |
| 3 | Jalalabad | Army Aviation | 24 OH-58D, 8 AH-64D, 8 UH-60, 8 CH-47 | `BINDING`, historisch ausreichend bestätigt |
| 4 | Kandahar | A-10C | 107th Expeditionary Fighter Squadron, 16 A-10C | `BINDING` |
| 5 | Camp Bastion | AH-1W / UH-1Y | HMLA-169 „Vipers“, 10 AH-1W und 5 UH-1Y | `BINDING` |
| 6 | Camp Bastion | MV-22B | keine aktive Umsetzung | `BINDING`: entfällt vollständig |
| 7 | Camp Bastion | CH-53E | HMH-361 (-) Reinforced, 17 CH-53E | `BINDING` |
| 8 | FOB Salerno / Khost | AH-64D Attack | Task Force Tigershark, 8 AH-64D | `BINDING` |
| 9 | FOB Salerno / Khost | OH-58D Cavalry | Troop B, 6-6 Cavalry „Bounty Hunter“, 8 OH-58D | `BINDING` |
| 10 | FOB Salerno / Khost | UH-60L Assault | angegliederte Assault Company, 7 UH-60L | `BINDING` |
| 11 | FOB Salerno / Khost | UH-60 MEDEVAC | C Company, 5-159 Aviation „Cowboy Dustoff“, 3 UH-60 | `BINDING` |
| 12 | FOB Salerno / Khost | CH-47D Medium Lift | angegliederte Medium Lift Company, 8 CH-47D | `BINDING` |

Ein automatischer Staffelwechsel anhand eines fortlaufenden Kampagnendatums wird zunächst nicht umgesetzt.

---

## 1. Bagram Airfield – Fighter-Komponente

### Verbindliche aktive ORBAT

```text
AW_US_BAGRAM
├── SQ_US_BGRM_F15E_335_EFS
│   13 F-15E
└── SQ_US_BGRM_F16C_121_EFS
    13 F-16C Block 30 historisch
    DCS-Abbildung: F-16C Block 50
```

### Evidenz- und Designstatus

- Die 335th EFS ist für November 2011 in Bagram belegt.
- Die 121st EFS ist für Oktober 2011 bis April 2012 in Bagram belegt.
- Die projektseitig ausgewertete Satellitenaufnahme Ende 2011 stützt mindestens 13 sichtbare F-15E und 11 sichtbare F-16.
- Für die 121st EFS sind 13 F-16C Block 30 als Rainbow-Bestand dokumentiert.
- Der lokale Kampagnenbestand von jeweils 13 ist konservativ und quellenbasiert; er ist keine Aussage über eine vollständige USAF-TOE.

### DCS-Abbildung

Die verfügbare DCS F-16C Block 50 wird als technischer Ersatz für die historische Block 30 verwendet. Diese Abweichung muss in Dokumentation, Mission und Payloadauswahl sichtbar bleiben.

Die F-15E bleibt als `THIRD_PARTY_AT_RISK` gekennzeichnet. Spielerobjekte, Templates und Payloadregistrierungen müssen deaktivierbar bleiben, ohne die Bagram-AIRWING-Struktur neu zu entwerfen.

### Nicht aktiv umgesetzt

494th und 336th Expeditionary Fighter Squadron bleiben historischer Rotationskontext. Für sie werden in der aktiven Missionsbaseline nicht zusätzlich angelegt:

- keine separaten Client-Gruppen;
- keine parallelen KI-SQUADRONs;
- keine zusätzlichen Payload-Templates;
- keine zusätzlichen Statics als eigener Bestand;
- kein automatischer Staffelwechsel.

---

## 2. Jalalabad Airfield / FOB Fenty – Army Aviation

### Verbindlicher historisch ausreichend bestätigter Bestand

```text
Flugplatz: Jalalabad Airfield / FOB Fenty

6th Squadron, 6th Cavalry Regiment / Task Force Six Shooters
24 OH-58D

B Company, 1-10 Aviation
8 AH-64D

angegliedertes Utility-/MEDEVAC-Element
8 UH-60

angegliedertes Heavy-Lift-Element
8 CH-47
```

Der Bestand `24/8/8/8` ist die verbindliche Kampagnenbaseline und gilt als historisch ausreichend bestätigt. Er bleibt dennoch von sichtbaren Statics, Client-Slots, aktiven KI-Gruppen und virtueller Reserve getrennt.

### Technische Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

Die technisch akzeptierte Jalalabad-Baseline auf dem zugehörigen Draft-Branch beweist den dort dokumentierten Laufzeitstand. Ihre normativen Bestandsentscheidungen werden durch dieses Dokument projektweit verbindlich.

### MEDEVAC-Regel

MEDEVAC wird als logisch koordiniertes Two-Ship-Paket geplant:

```text
1 UH-60 MEDEVAC Lead: Landung und Aufnahme
1 UH-60 Cover: Sicherung und Feuerunterstützung aus der Luft
```

Technisch dürfen beide Luftfahrzeuge als unabhängig taskbare Single-Ship-Gruppen modelliert werden, sofern der Runtime-Koordinator sie als gemeinsames Paket führt.

### Nicht aktiv umgesetzt

Task Force Lighthorse bleibt historische Vorgängereinheit. Sie erzeugt keinen parallelen aktiven Bestand und keinen automatischen Verbandswechsel.

---

## 3. Kandahar Airfield – A-10C

### Verbindliche aktive ORBAT

```text
Einheit: 107th Expeditionary Fighter Squadron
Flugplatz: Kandahar Airfield
Muster: A-10C
Lokaler ORBAT-Bestand: 16 Luftfahrzeuge
```

### Geplante technische Struktur

```text
AW_US_KANDAHAR
└── SQ_US_KAF_A10C_107_EFS
```

### Historischer Rotationskontext

81st, 74th und 75th Expeditionary Fighter Squadron bleiben zeitbezogene Recherche- und Rotationsangaben. Sie werden nicht zusätzlich als parallele aktive A-10C-SQUADRONs umgesetzt.

Die Auswahl der 107th EFS ist eine bewusste aktive Missionsentscheidung innerhalb des Gesamtzeitraums und kein automatisch datumsabhängiger Staffelwechsel.

---

## 4. Camp Bastion – HMLA Light Attack / Utility

### Verbindliche Entscheidung

```text
Einheit: HMLA-169 „Vipers“
Flugplatz: Camp Bastion

10 AH-1W
5 UH-1Y
```

Die fünf UH-1Y bleiben Bestandteil der historischen und strategischen ORBAT. Ihre physische Umsetzung in DCS bleibt deaktiviert, bis ein geeignetes natives oder ausdrücklich zugelassenes Asset bestätigt ist. Eine UH-1H wird nicht automatisch als historisch falscher Ersatz verwendet.

```text
AW_USMC_BASTION
├── SQ_HMLA_169_AH1W
└── SQ_HMLA_169_UH1Y   # erst nach bestätigter Asset-Entscheidung aktivieren
```

HMLA-369 bleibt historischer Vorgängerkontext und erzeugt keinen parallelen aktiven Bestand.

---

## 5. Camp Bastion – MV-22B

### Verbindliche Entscheidung

```text
VMM-365 „Blue Knights“: keine aktive Umsetzung
VMM-264 „Black Knights“: keine aktive Umsetzung
MV-22B-Bestand in der aktiven Mission: 0
```

Es werden keine Spieler-Slots, KI-SQUADRONs, Templates, Statics, RAT-Flüge oder verpflichtenden Community-Mod-Abhängigkeiten vorgesehen. Eine spätere Wiedereinführung benötigt eine neue ausdrückliche Architektur- und ORBAT-Entscheidung.

---

## 6. Camp Bastion – Heavy Lift

### Verbindliche aktive Entscheidung

```text
Einheit: HMH-361 (-) Reinforced
Flugplatz: Camp Bastion
Muster: CH-53E
Lokaler ORBAT-Bestand: 17 Luftfahrzeuge
```

Betriebsregeln:

- KI-Nutzung erst nach Bestätigung von DCS-Typname, Parking und MOOSE-AIRWING-Verhalten;
- keine CH-53E-Client-Slots;
- höchstens vier gleichzeitig aktive lokale CH-53E als technische Obergrenze;
- normale Einsätze als Single- oder Two-Ship-Flüge;
- Statics als Repräsentation des inaktiven Bestands;
- Verluste sind endgültig und werden nicht automatisch ersetzt.

```text
AW_USMC_BASTION
└── SQ_HMH_361_CH53E
```

HMH-363, HMH-362 und CH-53D bleiben historischer Kontext und erzeugen keinen parallelen aktiven Bestand.

---

## 7. FOB Salerno / Khost – Task Force Tigershark

### Verbindlicher lokaler Bestand

```text
Task Force Tigershark
Lead Formation: 1st Battalion, 10th Aviation Regiment
Higher Formation: 10th Combat Aviation Brigade / 10th Mountain Division

Attack Company:       8 AH-64D
Cavalry Troop:        8 OH-58D
Assault Company:      7 UH-60L
MEDEVAC Detachment:   3 UH-60
Medium Lift Company:  8 CH-47D
```

Die Einzelkomponenten ergeben 34 Hubschrauber. Die ausgewertete Kommandeursbeschreibung nennt gleichzeitig 33 Hubschrauber insgesamt. Die Ursache der Differenz ist ungeklärt; kein Einzelbestand wird ohne neue belastbare Evidenz künstlich reduziert.

### Identifizierte Untereinheiten

```text
OH-58D:
Troop B, 6th Squadron, 6th Cavalry Regiment
„Bounty Hunter“

MEDEVAC:
Company C, 5th Battalion, 159th Aviation Regiment
„Cowboy Dustoff“
```

Die genaue Company-Bezeichnung der AH-64D-Komponente sowie die Company-/Battalion-Zuordnung der Assault- und Medium-Lift-Komponenten bleiben offen. Es werden keine Untereinheiten erfunden.

### Technische Struktur

```text
AW_US_SALERNO
├── SQ_US_SAL_AH64D_TF_TIGERSHARK_ATTACK
├── SQ_US_SAL_OH58D_B_6_6_CAV
├── SQ_US_SAL_UH60_TF_TIGERSHARK_ASSAULT
├── SQ_US_SAL_UH60_MEDEVAC_C_5_159_AVN
└── SQ_US_SAL_CH47_TF_TIGERSHARK_MEDIUM_LIFT

WH_AIR_US_SALERNO
```

Die vollständige Client-, Template-, Static-, Parking- und Evidenzbaseline steht branchgebunden in [`OMW-AIR-SALERNO-MANIFEST`](51-salerno-air-operations-manifest.md). Khost Airfield erhält durch diese Entscheidung keinen zweiten parallelen US-AIRWING.

### DCS-Abbildung

- AH-64D und OH-58D erhalten native Spieler-Slots gemäß der projektweiten Obergrenze;
- CH-47D wird für Spieler durch das CH-47F-Modul repräsentiert;
- UH-60L-Clients bleiben optional und modabhängig;
- UH-60L Assault und UH-60 MEDEVAC werden für KI und Statics durch UH-60A dargestellt;
- Clients, Templates, Statics und aktive KI sind keine additiven Bestände.

## Verbleibende technische Detailentscheidungen

Noch offen sind nicht die oben festgelegten aktiven Verbände und Bestände, sondern unter anderem:

- genaue Zahl und Platzierung gepoolter Statics je Muster, soweit kein aktuelles Basenmanifest sie bereits festlegt;
- historisch passende oder verfügbare Liveries;
- konkrete Client- und KI-Parkpositionen;
- Payload- und Rollen-Templates;
- technische Verwendbarkeit karteneigener Warehouse-Gebäude;
- DCS-Typnamen und MOOSE-Verhalten der KI-Muster;
- physische Darstellung der UH-1Y;
- versionsbezogene Prüfung des UH-60L Community Mods;
- Fallback-Verhalten für F-15E und andere Risikomodule.

Diese Punkte werden in den Missionseditor-Arbeitslisten und basisbezogenen Manifesten behandelt. Sie dürfen die hier festgelegte aktive ORBAT nicht stillschweigend verändern.