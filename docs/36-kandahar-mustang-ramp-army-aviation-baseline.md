---
document_id: OMW-AIR-KANDAHAR-MUSTANG-RAMP
status: STRUCTURALLY_AUDITED_RUNTIME_BLOCKED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Mustang Ramp Army Aviation baseline
  - Kandahar Army Aviation clients templates and statics
  - 159th CAB organizational representation
  - Kandahar Heliport runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: AIRWING_OBJECT_CONTRACT
supersedes:
  - docs/33-kandahar-mustang-ramp-army-aviation-baseline.md
  - prior blanket deferral of Kandahar AH-64 OH-58D CH-47 and Army UH-60
  - AH-64A and CH-47D Mission Editor substitution baseline
  - separate AH-64 escort OH-58D escort and CH-47 slingload seed requirement
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(1).miz
source_mission_sha256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
validated_in_dcs: false
---

# 36 – Kandahar Mustang Ramp Army Aviation Baseline

## 1. Dokumentstatus

Die historische Stationierung ist ausreichend bestätigt. Die aktuelle Missionseditor-Baseline ist strukturell auditiert. DCS-Laufzeit-, Parking-, Performance- und MOOSE-Registrierungsvalidierung stehen noch aus.

Die Mustang Ramp verwendet in DCS eine eigene native Airbase:

```text
AIRBASE.Afghanistan.Kandahar_Heliport
DCS airdromeId: 15
```

Sie kann daher nicht über das Main-Airfield-Warehouse von `AW_US_KANDAHAR` betrieben werden. Ein zweites AIRWING-/WAREHOUSE-Paar ist vor jeder Runtime-Registrierung zwingend erforderlich.

Vollständiger Rohbefund:

- [`OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-1`](evidence/kandahar-mission-editor-audit-omw-template-v4-kandahar-1.md).

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

## 3. Tatsächliche DCS-Abbildung

Die aktuelle Mission verwendet keine ältere AH-64A-/CH-47D-Ersatzbaseline mehr:

```text
AH-64 Clients/Templates/Statics: AH-64D_BLK_II
OH-58D Clients/Templates/Statics: OH58D
CH-47 Clients/Templates/Statics: CH-47Fbl1
UH-60 Templates/Statics: UH-60A
UH-60-Clients: keine
HH-60G: separater USAF-Verband; UH-60A-Repräsentation
```

Diese Typen sind für die aktuelle `.miz` verbindlicher Strukturstand. Die historische Rollenbeschreibung bleibt davon getrennt.

## 4. Tatsächlich gesetzte Client-Assets

```text
CLIENT_US_KAF_AH64D_01 | AH-64D_BLK_II | MST38-H | airdromeId 15
CLIENT_US_KAF_AH64D_02 | AH-64D_BLK_II | MST30-H | airdromeId 15

CLIENT_US_KAF_OH58D_01 | OH58D          | MST01-H | airdromeId 15
CLIENT_US_KAF_OH58D_02 | OH58D          | MST11-H | airdromeId 15

CLIENT_US_KAF_CH47F_01 | CH-47Fbl1      | MST75-H | airdromeId 15
CLIENT_US_KAF_CH47F_02 | CH-47Fbl1      | MST82-H | airdromeId 15
```

```text
Gesamt: 6 Clientgruppen / 6 Spielerluftfahrzeuge
UH-60-Clientgruppen: 0
```

Die Mission-Editor-Parkingwerte sind keine autoritativen MOOSE-TerminalIDs. Die vollständige Heliport-/Parkingliste wird durch den No-Spawn-Diagnoselauf ermittelt.

## 5. Tatsächlich gesetzte KI-Templates

```text
TPL_AIR_US_KAF_AH64D_CAS_2SHIP
  2 x AH-64D_BLK_II

TPL_AIR_US_KAF_OH58D_RECON_2SHIP
  2 x OH58D

TPL_AIR_US_KAF_CH47_TRANSPORT_1SHIP
  1 x CH-47Fbl1

TPL_AIR_US_KAF_UH60_TRANSPORT_2SHIP
  2 x UH-60A

TPL_AIR_US_KAF_UH60_MEDEVAC_1SHIP
  1 x UH-60A
```

Alle fünf Gruppen:

```text
Late Activation: true
Uncontrolled: false
Authoring-Seeds ohne zusätzlichen logischen Bestand
```

Nicht mehr vorhanden und nicht mehr als separate Pflichtseeds vorgesehen:

```text
TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
```

Die aktuelle MOOSE-first-Zielregel lautet:

```text
ein typbasierter SQUADRON-Pool je Muster
mehrere Rollen über AUFTRAG Payload ROE Formation und FLIGHTGROUP
keine getrennten Airframe-Pools nur wegen Escort oder Slingload
```

Template-Summe:

```text
AH-64: 1 Gruppe / 2 Flugzeuge
OH-58D: 1 Gruppe / 2 Flugzeuge
CH-47: 1 Gruppe / 1 Flugzeug
UH-60: 2 Gruppen / 3 Flugzeuge
Gesamt: 5 Gruppen / 8 Templateflugzeuge
```

## 6. Tatsächlich gesetzte Static-Baseline

```text
STATIC_AIR_US_KAF_AH64_01 ... _08
STATIC_AIR_US_KAF_OH58D_01 ... _08
STATIC_AIR_US_KAF_CH47_01 ... _10
STATIC_AIR_US_KAF_UH60_01 ... _08
```

```text
AH-64D_BLK_II: 8
OH58D: 8
CH-47Fbl1: 10
UH-60A: 8
Gesamt: 34 Army-Aviation-Statics
```

Diese 34 Objekte sind keine zusätzlichen logischen Airframes. Die zwei USAF-HH-60G-/CSAR-Statics werden separat geführt.

## 7. Verbindlicher Heliport-AIRWING-Vertrag

Die bisherige Einbindung aller Kandahar-SQUADRONs in ein einziges technisches `AW_US_KANDAHAR` ist für den aktuellen MOOSE-2.9.18-Stand nicht zulässig, weil Kandahar Main und Kandahar Heliport getrennte native Airbases sind.

Für die Mustang Ramp gilt verbindlich:

```text
Airbase: AIRBASE.Afghanistan.Kandahar_Heliport
DCS airdromeId: 15
technisches AIRWING: Name durch Projektinhaber festzulegen
technisches WAREHOUSE: Name durch Projektinhaber festzulegen
Mission-Editor-Warehouse-Anker: noch anzulegen
```

Vorgesehene SQUADRON-Kennungen bleiben:

```text
SQ_US_KAF_AH64_3_101_AVN
SQ_US_KAF_OH58D_7_17_CAV
SQ_US_KAF_CH47_7_101_AVN
SQ_US_KAF_UH60_159_CAB
```

Die UH-60-Kennung bleibt eine vorläufige Implementierungskennung, bis der historische Unterverband abschließend zugeordnet ist. Sie darf nicht als neue historische Behauptung behandelt werden.

Bis der zweite Warehouse-Anker vorhanden, benannt und runtime-validiert ist, bleiben alle vier Mustang-Ramp-SQUADRONs fail-closed deaktiviert.

## 8. AIRWING-Registrierung

Die Mustang-Ramp-Registrierung muss:

- ausschließlich den noch festzulegenden Heliport-Warehouse-Anker verwenden;
- den Anker an `AIRBASE.Afghanistan.Kandahar_Heliport` binden;
- die vier Army-SQUADRONs eindeutig binden;
- Templates nur als Authoring-Seeds verwenden;
- Clients und 34 Statics nicht zum Bestand addieren;
- USAF-HH-60G nicht der Army-UH-60-SQUADRON zuordnen;
- Late-Activation-Templates bis zur Zuweisung inaktiv halten;
- vor AIRWING-Start die Helipad-/Parking-Verfügbarkeit prüfen;
- bei fehlendem Anker, unklarer Airbase oder ungeklärtem Bestand fail-closed bleiben.

## 9. SQUADRON-Bestandsverwaltung

Die logischen Anfangsbestände dürfen nicht aus den Statics, Clients oder Templategrößen abgeleitet werden.

Je SQUADRON erforderlich:

```text
regionaler Gesamtbestand
Forward-Detachment-Abzüge
am Kandahar-Stammknoten verbleibender Anfangsbestand
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

### 9.1 Tarinkot-Abzug

Tarinkot besitzt verbindlich:

```text
14 AH-64D
6 UH-60
2 CH-47
0 OH-58D
```

Diese Luftfahrzeuge sind aus dem Kandahar-/RC-South-Regionalpool abzuziehen. Weitere Forward Detachments sind ebenfalls zu berücksichtigen.

Solange kein verbindlicher regionaler Gesamtpool festgelegt ist, dürfen keine produktiven Kandahar-Anfangsbestände registriert werden.

### 9.2 Gemeinsame Rollenpools

```text
AH-64 CAS und ESCORT: ein gemeinsamer AH-64-Pool
OH-58D RECON AFAC und ESCORT: ein gemeinsamer OH-58D-Pool
CH-47 TRANSPORT OPSTRANSPORT und SLINGLOAD: ein gemeinsamer CH-47-Pool
UH-60 TRANSPORT UTILITY und MEDEVAC: ein gemeinsamer UH-60-Pool
```

Separate Rollen dürfen nicht als zusätzliche Airframebestände gezählt werden.

## 10. Payload-Grenzen

### AH-64D

Das aktuelle Template besitzt M261-Raketenbehälter, zwei Hellfire-Racks, IAFS-Kombinationspaket und 25 Prozent Kanonenmunition. Die konkrete CAS-/Escort-Verwendung wird später über Payload und AUFTRAG geprüft.

### OH-58D

Das aktuelle Template besitzt:

```text
M260_APKWS_M151
OH58D_AGM_114_R
```

Die APKWS-Konfiguration benötigt vor produktiver Verwendung eine ausdrückliche Perioden- und Projektentscheidung. Ohne Freigabe ist das Template zu korrigieren oder die SQUADRON bleibt für bewaffnete Aufgaben deaktiviert.

### CH-47F

Das aktuelle Template besitzt:

```text
CH47_PORT_M60D
CH47_STBD_M60D
```

## 11. AUFTRAG- und OPSTRANSPORT-Ausführung

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

## 12. Safe Parking und Mustang-Ramp-Allow-/Blocklist

Die Laufzeitdiagnose muss für `AIRBASE.Afghanistan.Kandahar_Heliport`:

1. sämtliche Helipads und TerminalIDs mit Typ und Koordinaten erfassen;
2. alle sechs Clientpositionen reservieren;
3. die 34 Statics dem nächsten Helipad/Parking-Node zuordnen;
4. bewusst blockierte Nodes als Blocklist-Kandidaten ausgeben;
5. freie Nodes nach Größenklasse AH-64/OH-58D/UH-60/CH-47 klassifizieren;
6. Rotor-, Revettement-, Taxi- und Nachbarabstände prüfen;
7. CH-47 nur auf ausreichend großen, getesteten Nodes zulassen;
8. Safe Parking für jede SQUADRON separat validieren.

Die endgültige Allow-/Blocklist wird nicht aus der optischen Karte oder geratenen Nummern erstellt, sondern aus der Runtime-Diagnose.

## 13. Verlust- und Rückgabelogik

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

## 14. Flugplatzspezifische Funktionszonen

In der aktuellen Mission existiert keine Mustang-Ramp-Funktionszone.

Mögliche spätere Bedarfe:

```text
Embark
Disembark
Cargo
Slingload
MEDEVAC Pickup
MEDEVAC Handover
```

Verbindlich gilt:

- keine Zone nur zur optischen Gruppierung anlegen;
- nur anlegen, wenn die konkrete MOOSE-/OPSTRANSPORT-/MEDEVAC-Funktion sie benötigt;
- Namen vor Anlage nach Projektkonvention freigeben;
- Koordinaten und Radien anhand der tatsächlichen Rampgeometrie festlegen;
- Parking-, Spawn- und Static-Zuordnung nicht über diese Zonen lösen.

## 15. Nächster Runtime-Inkrement

Der Mustang-Ramp-Anteil des nächsten Tests ist ausschließlich Teil des:

```text
Kandahar Dual-Airbase No-Spawn Diagnostic
```

Er darf:

- Heliport-Airbase und IDs protokollieren;
- das Fehlen des zweiten Warehouse-Ankers melden;
- Clients, Templates, Statics und Payload-Signaturen prüfen;
- sämtliche Heliport-Terminals und Koordinaten ausgeben;
- mögliche Allow-/Blocklist-Kandidaten ausgeben.

Er darf noch nicht:

- ein Mustang-Ramp-AIRWING starten;
- SQUADRON-Bestände registrieren;
- Assets spawnen;
- AUFTRAG oder OPSTRANSPORT erzeugen;
- Parking-IDs fest verdrahten.

## 16. Offene Entscheidungen

- Name des zweiten Heliport-AIRWINGs;
- Name und Mission-Editor-Anlage des zweiten Heliport-Warehouse-Ankers;
- logischer regionaler Gesamtbestand je Army-Muster;
- weitere Forward-Detachment-Abzüge neben Tarinkot;
- am Kandahar-Stammknoten verbleibende Anfangsbestände;
- endgültige UH-60-Unterverbandszuordnung;
- OH-58D-APKWS-Freigabe oder Payloadkorrektur;
- vollständige Heliport-Terminal-/Allow-/Blocklist;
- konkrete Funktionszonen;
- Wartung, Cooldown, Reparatur und Wiederbeschaffung;
- CampaignState-Schnittstelle;
- Performance- und Runtime-Acceptance.

## 17. Acceptance-Kriterien

```text
zweiter Heliport-Warehouse-Anker vorhanden und eindeutig erkannt
Warehouse an AIRBASE.Afghanistan.Kandahar_Heliport gebunden
alle sechs Clients eindeutig erkannt
alle fünf Templates eindeutig erkannt
34 Army-Statics ohne Bestandsaddition erkannt
keine Spawns auf Client- oder Static-Nodes
CH-47 nur auf getesteten großen Nodes
keine spontane Templateaktivierung
Bestände berücksichtigen Tarinkot und weitere Detachments
Rollenvarianten erzeugen keine zusätzlichen Airframe-Pools
Verlust und sichere Rückkehr verändern den Bestand korrekt
keine relevante Lua-, Parking-, Timer- oder Eventfehler
```
