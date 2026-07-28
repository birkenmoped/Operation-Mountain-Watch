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
  - Tarinkot 2-4 per-type planning ranges without active inventory decision
  - player limits above two aircraft per type and base
source_branch: agent/reconcile-documentation-authority
validated_in_dcs: false
document_class: PROJECT_DECISION
source_commit: GIT_HISTORY
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
| 8 | Tarinkot / Camp Holland | Army Aviation | 14 AH-64D, 6 UH-60, 2 CH-47, 0 OH-58D; vom Kandahar-Regionalpool abzuziehen | `BINDING_PROJECT_DECISION` auf gemischter In-Period- und Post-Period-Evidenz |

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

## 7. Tarinkot / Tarin Kowt / Camp Holland – Army Aviation

### 7.1 Verbindlicher lokaler Kampagnenbestand

```text
14 AH-64D
 6 UH-60-Familie
 2 CH-47D/F, DCS-Abbildung CH-47F
 0 OH-58D
-------------------------------
22 Luftfahrzeuge
```

Dieser Bestand ist eine ausdrückliche OMW-Projektentscheidung. Er kombiniert:

- den innerhalb des Szenariozeitraums belegten Status Tarinkots als CH-47-Platoon-/Detachment-Standort ab 2011;
- die Einordnung als Bestandteil des Kandahar-Regionalpools;
- die dokumentierte Verteilung von CH-47-Elementen zwischen Kandahar, Tarinkot und FOB Wolverine;
- die post-periodische Satellitenbildbeobachtung vom 17.05.2012 mit 14 sichtbaren AH-64, 6 UH-60 und 1 CH-47;
- den fehlenden belastbaren Nachweis einer lokalen OH-58D-Komponente.

Die Zahlen `14/6/2/0` sind keine Behauptung einer amtlich belegten Stichtags-ORBAT für 2011. Für AH-64 und UH-60 bilden die sichtbaren post-periodischen Mindestzahlen die quellennahe Designbasis. Zwei CH-47 werden als konservative OMW-Baseline gewählt, weil ein CH-47-Platoon/Detachment im Zeitraum belegt ist und Two-Ship-Pakete als typisches Einsatzmuster dokumentiert sind, während die Quelle keine exakte lokale Platoonstärke nennt.

Vollständige Bildbeobachtung und Einschränkungen:

- [`OMW-EVIDENCE-TARINKOT-SATELLITE-2012`](evidence/tarinkot-satellite-observations-2012.md).

### 7.2 Parent-Pool- und Doppelzählungsregel

Alle Tarinkot-Luftfahrzeuge werden vom regionalen Kandahar-/RC-South-Army-Aviation-Pool abgezogen. Sie sind keine zusätzlichen Theaterluftfahrzeuge.

```text
Kandahar regional inventory
- Tarinkot local inventory
- andere forward detachments
= am Stammknoten verbleibender regionaler Bestand
```

Solange für Kandahar keine verbindliche vollständige Army-Aviation-Bestandsentscheidung getroffen ist, darf die Tarinkot-Entscheidung nicht durch einen parallel vollständig angesetzten Kandahar-CAB-Bestand doppelt gezählt werden.

### 7.3 Verbindliche allgemeine Vorgaben für Tarinkot

Standortkürzel:

```text
TKOT
```

MOOSE-Struktur:

```text
AW_US_TARINKOT
├── SQ_US_TKOT_AH64D_ATTACK_DET
├── SQ_US_TKOT_UH60_UTILITY_MEDEVAC_DET
└── SQ_US_TKOT_CH47_HEAVYLIFT_DET
```

Warehouse-Anker:

```text
WH_AIR_US_TARINKOT
```

Für nicht ausreichend belegte Untereinheiten werden keine Company-, Battalion- oder Task-Force-Bezeichnungen erfunden. Eine spätere Umbenennung benötigt eine belastbare Quellenzuordnung und darf bestehende technische Referenzen nicht unkontrolliert brechen.

Es wird keine lokale OH-58D-SQUADRON angelegt. Neue Quellen können eine getrennte Review auslösen, ändern den Bestand aber nicht stillschweigend.

Tarinkot erhält keine permanente lokale Fixed-Wing-SQUADRON allein aufgrund des auf dem Satellitenbild sichtbaren Einzelverkehrs. Fixed-Wing-Verkehr wird zunächst als Transport-, Administrativ- oder Transitbetrieb behandelt.

### 7.4 Client-Gruppen

Maximal zulässige modfreie Gruppen:

```text
CLIENT_US_TKOT_AH64D_01
CLIENT_US_TKOT_AH64D_02

CLIENT_US_TKOT_CH47F_01
CLIENT_US_TKOT_CH47F_02
```

Optionale UH-60L-Modgruppen:

```text
CLIENT_US_TKOT_UH60L_01
CLIENT_US_TKOT_UH60L_02
```

Die UH-60L-Gruppen werden nur nach ausdrücklicher Modentscheidung angelegt. Die Client-Obergrenze ist keine Bestandsaufstockung. Client-, KI- und Static-Repräsentationen müssen denselben lokalen Bestand reservieren.

### 7.5 KI-Templates

Geplante Mission-Editor-Seeds:

```text
TPL_AIR_US_TKOT_AH64D_CAS_2SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_TKOT_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_TKOT_CH47_HEAVYLIFT_1SHIP
```

Alle Templates sind `Late Activation` und kein zusätzlicher Bestand. Vor zusätzlichen Escort-, Slingload-, Armed-Recon- oder Payloadvarianten ist MOOSE-first zu prüfen, ob derselbe Seed über `AUFTRAG`, Payloadzuweisung oder `OPSTRANSPORT` wiederverwendet werden kann.

MEDEVAC Lead und Cover werden als getrennte Single-Ship-Gruppen angelegt, aber als gemeinsames 1+1-Paket reserviert und geführt.

### 7.6 Bestands- und Rampenmodell

Verbindliche Ebenen:

```yaml
nominalInventory:
  AH64D: 14
  UH60: 6
  CH47: 2
  OH58D: 0

missionReadyInventory:
  status: RUNTIME_STATE
  rule: never greater than nominalInventory

postPeriodVisibleReference_2012_05_17:
  AH64: 14
  UH60: 6
  CH47: 1
```

Die post-periodische sichtbare Belegung ist eine Rampenreferenz, keine Pflicht, jederzeit dieselbe Zahl physisch darzustellen.

Vorläufiges Authoring-Ziel bis zur basisbezogenen Parking-Validierung:

```text
10 AH-64-Statics
 4 UH-60-Statics
 1 CH-47-Static
```

Damit bleiben innerhalb des logischen Bestands grundsätzlich Reserven für Clients und KI. Die maximale physische Darstellung darf zu keinem Zeitpunkt den lokalen logischen Bestand überschreiten. Insbesondere gilt:

```text
Statics + aktive Clients + aktive KI <= lokaler Bestand je Muster
```

Für UH-60 teilen sich optionale Clients und das KI-MEDEVAC-Paket denselben Sechserbestand. Für CH-47 darf bei einem sichtbaren Static ohne bestätigten Ramp-Cycle zunächst höchstens ein weiteres Luftfahrzeug gleichzeitig als Client oder KI materialisiert sein.

Die Static-Zielzahlen sind noch keine DCS-Acceptance. Sie dürfen nach Parking-, Rotorabstands-, Performance- und Sichtbarkeitsprüfung reduziert werden, ohne den logischen Bestand zu ändern.

### 7.7 Funktionsflächen

Vorgesehene Namen:

```text
ZONE_AIR_US_TKOT_AH64_RAMP
ZONE_AIR_US_TKOT_UH60_RAMP
ZONE_AIR_US_TKOT_CH47_READY
ZONE_AIR_US_TKOT_MEDEVAC_READY
ZONE_AIR_US_TKOT_LOGISTICS_LOAD
ZONE_AIR_US_TKOT_LOGISTICS_UNLOAD
ZONE_AIR_US_TKOT_TRANSIENT_FIXED_WING
```

Zonen werden nur angelegt, wenn sie eine konkrete MOOSE-, Logistik-, CSAR-/MEDEVAC- oder Testfunktion besitzen. Die große mittlere Abstellfläche wird nicht automatisch mit Statics gefüllt. Die südwestliche Fixed-Wing-Fläche bleibt für transienten Verkehr und DCS-Parking-Tests frei.

### 7.8 Nicht durch diese Entscheidung bestätigt

- exakte historische 2011er AH-64- oder UH-60-Einheitsidentität;
- vollständige Camp-Holland-Personalstärke;
- Mission-Ready-Rate;
- permanente lokale Fixed-Wing-Einheit;
- produktive Parking-IDs und Blacklists;
- technisch akzeptierter Warehouse-Anker;
- DCS-/MOOSE-Laufzeitverhalten;
- automatische Static-/Client-/KI-Rampenumverteilung.

---

## Verbleibende technische Detailentscheidungen

Noch offen sind nicht die oben festgelegten aktiven Verbände und Bestände, sondern unter anderem:

- genaue Zahl und Platzierung gepoolter Statics je Muster, soweit nicht basisbezogen vorläufig festgelegt;
- historisch passende oder verfügbare Liveries;
- konkrete Client- und KI-Parkpositionen;
- Payload- und Rollen-Templates;
- technische Verwendbarkeit karteneigener Warehouse-Gebäude;
- DCS-Typnamen und MOOSE-Verhalten der KI-Muster;
- physische Darstellung der UH-1Y;
- versionsbezogene Prüfung des UH-60L Community Mods;
- Fallback-Verhalten für F-15E und andere Risikomodule;
- Tarinkot-spezifische DCS-Parking-, Rotorabstands- und Rückkehrtests.

Diese Punkte werden in den Missionseditor-Arbeitslisten und basisbezogenen Manifesten behandelt. Sie dürfen die hier festgelegte aktive ORBAT nicht stillschweigend verändern.
