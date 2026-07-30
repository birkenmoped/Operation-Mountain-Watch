---
document_id: OMW-AIR-KANDAHAR-MUSTANG-RAMP
status: IMPLEMENTED_IN_MIZ_UNVALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Mustang Ramp Army Aviation baseline
  - Kandahar Army Aviation clients templates and statics
  - 159th CAB organizational representation
  - Mustang Ramp runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/33-kandahar-mustang-ramp-army-aviation-baseline.md
  - prior blanket deferral of Kandahar AH-64 OH-58D CH-47 and Army UH-60
source_branch: docs/bagram-air-operations-manifest
source_mission: OMW_TEST_TM01M_MooseFirst(18).miz
validated_in_dcs: false
---

# 36 – Kandahar Mustang Ramp Army Aviation Baseline

## 1. Dokumentstatus

Die historische Stationierung ist ausreichend bestätigt. Die Missionseditor-Baseline ist in Revision 18 vollständig gesetzt. Alle acht Army-Aviation-Templates besitzen `Late Activation = true` und `Uncontrolled = false`. DCS-Laufzeit-, Parking-, Performance- und MOOSE-Registrierungsvalidierung stehen noch aus.

Dieses Dokument ergänzt `OMW-AIR-KANDAHAR-MANIFEST` um den Army-Aviation-Knoten der 159th Combat Aviation Brigade auf der Mustang Ramp.

## 2. Historische Struktur

```text
159th Combat Aviation Brigade – Task Force Thunder
├── 3rd Battalion, 101st Aviation Regiment / Task Force Attack
│   └── AH-64 Apache
├── 7th Squadron, 17th Cavalry Regiment / Task Force Palehorse
│   └── OH-58D Kiowa Warrior
├── 7th Battalion, 101st Aviation Regiment / Task Force Lift
│   └── CH-47F Chinook
├── Brigade-UH-60-Element
│   └── UH-60 Black Hawk
└── 563rd Aviation Support Battalion / Task Force Fighting
    └── Wartung und Instandsetzung
```

Die genaue Unterverbandszuordnung des gesamten UH-60-Bestands bleibt offen. USAF-HH-60G/26th ERQS bleibt organisatorisch und bestandsseitig getrennt.

## 3. DCS-Abbildung

```text
AH-64: Client AH-64D; KI/Static AH-64A
OH-58D: Client OH-58D; KI/Static OH-58D
CH-47: Client CH-47F; KI/Static CH-47D
UH-60: kein Client in modfreier Baseline; KI/Static UH-60A
HH-60G: separater USAF-Verband; KI/Static UH-60A als Ersatz
```

## 4. Tatsächlich gesetzte Client-Assets

```text
CLIENT_US_KAF_AH64D_01
  CLIENT_US_KAF_AH64D_01_UNIT_01
CLIENT_US_KAF_AH64D_02
  CLIENT_US_KAF_AH64D_02_UNIT_01

CLIENT_US_KAF_OH58D_01
  CLIENT_US_KAF_OH58D_01_UNIT_01
CLIENT_US_KAF_OH58D_02
  CLIENT_US_KAF_OH58D_02_UNIT_01

CLIENT_US_KAF_CH47F_01
  CLIENT_US_KAF_CH47F_01_UNIT_01
CLIENT_US_KAF_CH47F_02
  CLIENT_US_KAF_CH47F_02_UNIT_01
```

```text
Gesamt: 6 Clientgruppen / 6 Spielerluftfahrzeuge
UH-60-Clientgruppen: 0
```

Die vollständige Mustang-Ramp-Helipad-/Parkingliste wird durch den späteren Diagnoselauf autoritativ ermittelt.

## 5. Tatsächlich gesetzte KI-Templates – Revision 18

```text
TPL_AIR_US_KAF_AH64D_CAS_2SHIP
  2 × AH-64A
  DCS-Task: CAS

TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
  2 × AH-64A
  DCS-Task: CAS

TPL_AIR_US_KAF_OH58D_RECON_2SHIP
  2 × OH-58D
  DCS-Task: AFAC

TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
  2 × OH-58D
  DCS-Task: AFAC

TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
  1 × CH-47D
  DCS-Task: Transport

TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
  1 × CH-47D
  DCS-Task: Transport

TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP
  2 × UH-60A
  DCS-Task: Transport

TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
  1 × UH-60A
  DCS-Task: Transport
```

Alle acht Gruppen:

```text
Late Activation: true
Uncontrolled: false
Skill: High oder Veteran entsprechend Mission-Editor-Einstellung
```

Die OMW-Rolle wird später über AUFTRAG, Payload, ROE und FLIGHTGROUP bestimmt. Der DCS-Haupttask muss nicht namensgleich sein.

Template-Summe:

```text
AH-64: 2 Gruppen / 4 Flugzeuge
OH-58D: 2 Gruppen / 4 Flugzeuge
CH-47: 2 Gruppen / 2 Flugzeuge
UH-60: 2 Gruppen / 3 Flugzeuge
Gesamt: 8 Gruppen / 13 Templateflugzeuge
```

## 6. Tatsächlich gesetzte Static-Baseline

```text
STATIC_AIR_US_KAF_AH64_01 ... _08
STATIC_AIR_US_KAF_OH58D_01 ... _08
STATIC_AIR_US_KAF_CH47_01 ... _10
STATIC_AIR_US_KAF_UH60_01 ... _08
```

```text
AH-64: 8
OH-58D: 8
CH-47D: 10
UH-60A: 8
Gesamt: 34 Army-Aviation-Statics
```

Diese 34 Objekte sind keine zusätzlichen logischen Airframes. Die zwei USAF-HH-60G-/CSAR-Statics werden separat geführt.

## 7. Runtime-Zielstruktur

Vorgesehene Kennungen:

```text
AW_US_KANDAHAR
├── SQ_US_KAF_AH64_3_101_AVN
├── SQ_US_KAF_OH58D_7_17_CAV
├── SQ_US_KAF_CH47_7_101_AVN
└── SQ_US_KAF_UH60_159_CAB

WH_AIR_US_KANDAHAR
```

Die UH-60-Kennung bleibt eine vorläufige Implementierungskennung, bis der historische Unterverband abschließend zugeordnet ist. Sie darf nicht als neue historische Behauptung behandelt werden.

Falls ein eigener Army-AIRWING technisch erforderlich erscheint, ist dies vor Umsetzung gegen die zentrale Kandahar-Architektur zu prüfen und als ausdrückliche Architekturentscheidung zu dokumentieren. Standardannahme ist zunächst die Einbindung in `AW_US_KANDAHAR`.

## 8. AIRWING-Registrierung

Die Mustang-Ramp-Registrierung muss:

- `WH_AIR_US_KANDAHAR` verwenden;
- die vier Army-SQUADRONs eindeutig binden;
- Templates nur als Authoring-Seeds verwenden;
- Clients und 34 Statics nicht zum Bestand addieren;
- USAF-HH-60G nicht der Army-UH-60-SQUADRON zuordnen;
- Late-Activation-Templates bis zur Zuweisung inaktiv halten;
- vor AIRWING-Start die Helipad-/Parking-Verfügbarkeit prüfen.

## 9. SQUADRON-Bestandsverwaltung

Die logischen Anfangsbestände sind noch nicht aus den Statics abzuleiten und müssen vor produktiver Registrierung ausdrücklich festgelegt werden.

Je SQUADRON erforderlich:

```text
initialer Gesamtbestand
maximal gleichzeitig einsetzbar
verfügbar
reserviert
aktiv
zurückkehrend
Wartung/Cooldown
beschädigt
verloren
virtuelle Reserve
```

Die 34 Statics bilden Rampdichte ab. Sie sind keine verbindlichen Bestandszahlen.

CH-47-Transport und CH-47-Slingload dürfen nicht als zwei getrennte Airframe-Pools gezählt werden. MOOSE-first ist zu prüfen, ob ein gemeinsamer SQUADRON-Bestand mit mehreren Payload-/AUFTRAG-Varianten ausreicht.

## 10. AUFTRAG- und OPSTRANSPORT-Ausführung

Vorgesehene Rollen:

```text
AH-64: CAS, ESCORT
OH-58D: RECON/AFAC, ESCORT
CH-47: TRANSPORT, OPSTRANSPORT, SLINGLOAD
UH-60: TRANSPORT, UTILITY, MEDEVAC
```

Jeder Auftrag benötigt:

- erlaubte SQUADRON und Gruppengröße;
- geeignetes Template und Payload;
- Start-/Zielposition;
- Formation, ROE und Alarm State;
- Cargo-, Truppen- oder Patientendefinition;
- Erfolg, Abbruch und Rückkehr;
- Verlust- und Rückgabelogik.

MOOSE-first zu prüfen:

- `AIRWING`, `SQUADRON`, `AUFTRAG`, `FLIGHTGROUP`;
- `OPSTRANSPORT` für Truppen/Fracht;
- CTLD-/Cargo-/Slingload-Funktionen;
- vorhandene MEDEVAC-/CSAR-Integration;
- Formationseinstellungen und vertikale Startpräferenz.

Army-MEDEVAC und USAF-CSAR bleiben getrennte Rollen und Bestände.

## 11. Safe Parking und Mustang-Ramp-Blacklist

Die Laufzeitdiagnose muss:

1. sämtliche Mustang-Ramp-Helipads und TerminalIDs mit Koordinaten erfassen;
2. alle sechs Clientpositionen reservieren;
3. die 34 Statics dem nächsten Helipad/Parking-Node zuordnen;
4. bewusst blockierte Nodes blacklisten;
5. freie Nodes nach Größenklasse AH-64/OH-58D/UH-60/CH-47 klassifizieren;
6. Rotor-, Revettement-, Taxi- und Nachbarabstände prüfen;
7. CH-47 nur auf ausreichend großen, getesteten Nodes zulassen;
8. Safe Parking für jede SQUADRON separat validieren.

Die Blacklist wird nicht aus der optischen Karte oder geratenen Nummern erstellt, sondern aus der Runtime-Diagnose.

## 12. Verlust- und Rückgabelogik

```text
Auftrag angenommen -> Asset reserviert
Spawn/Start -> aktiv
Landung und sichere Rückkehr -> verfügbar oder Wartung/Cooldown
Abbruch mit sicherer Rückkehr -> verfügbar oder Wartung/Cooldown
beschädigte Rückkehr -> beschädigt/Wartung
Crash/Zerstörung -> verloren
Despawn ohne bestätigte Rückkehr -> nicht automatisch verfügbar
```

Für OPSTRANSPORT gilt zusätzlich:

- erfolgreiche Entladung bedeutet nicht automatisch erfolgreiche Rückkehr;
- wird der Transporter nach Entladung zerstört, bleibt der Auftrag hinsichtlich Frachtwirkung erfolgreich, der Airframe wird jedoch als verloren verbucht;
- Cargo-/Patientenstatus und Airframebestand werden getrennt bilanziert.

## 13. Flugplatzspezifische Funktionszonen

Keine Zone wird nur zur optischen Gruppierung der Mustang-Ramp-Statics angelegt.

Voraussichtlich funktional erforderlich:

```text
ZONE_AIR_US_KAF_MUSTANG_EMBARK
ZONE_AIR_US_KAF_MUSTANG_DISEMBARK
ZONE_AIR_US_KAF_MUSTANG_CARGO
ZONE_AIR_US_KAF_MUSTANG_SLINGLOAD
ZONE_AIR_US_KAF_MUSTANG_MEDEVAC_PICKUP
ZONE_AIR_US_KAF_MUSTANG_MEDEVAC_HANDOVER
```

Diese Namen sind reservierte Vorschläge, noch keine Anweisung, alle sechs Zonen sofort anzulegen.

Es gilt:

- nur anlegen, wenn die konkrete MOOSE-/OPSTRANSPORT-/MEDEVAC-Funktion die Zone benötigt;
- Koordinaten und Radien anhand der tatsächlichen Rampgeometrie festlegen;
- Embark/Disembark, Cargo/Slingload und MEDEVAC nicht ohne fachlichen Grund zusammenlegen;
- Parking-, Spawn- und Static-Zuordnung nicht über diese Zonen lösen.

## 14. Offene Entscheidungen

- logischer Anfangsbestand je Army-SQUADRON;
- endgültige UH-60-Unterverbandsbezeichnung;
- gemeinsames Kandahar-AIRWING oder technisch begründete Trennung;
- vollständige Mustang-Ramp-TerminalID-/Blacklist-Tabelle;
- Payloads, ROE und Formation je Rolle;
- konkrete OPSTRANSPORT-, Cargo-, Slingload- und MEDEVAC-Zonen;
- Wartungs-, Cooldown-, Reparatur- und Ersatzzeiten;
- CampaignState-Persistenz;
- Performance mit 34 Army-Statics.

## 15. Acceptance-Kriterien

```text
6 Clientgruppen und 8 Templates eindeutig erkannt
alle 8 Templates bleiben bis zur Zuweisung inaktiv
34 Statics werden nicht zum Bestand addiert
Army-UH-60 und USAF-HH-60G bleiben getrennt
keine Spawns auf reservierten Client- oder Static-Nodes
CH-47 nutzt nur geeignete große Nodes
AUFTRAG/OPSTRANSPORT reserviert und gibt Assets korrekt zurück
Verlust nach erfolgreicher Entladung reduziert trotzdem den Airframebestand
beschädigte Rückkehr führt nicht direkt zu verfügbar
keine relevante Lua-, Parking-, Cargo-, Timer- oder Eventfehlermeldung
```
