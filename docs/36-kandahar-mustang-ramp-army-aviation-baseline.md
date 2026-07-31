---
document_id: OMW-AIR-KANDAHAR-MUSTANG-RAMP
status: WAREHOUSE_VALIDATED_RUNTIME_REGISTRATION_BLOCKED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar Mustang Ramp Army Aviation baseline
  - Kandahar Army Aviation clients templates and statics
  - Task Force Thunder and 159th CAB organizational representation
  - Kandahar Heliport AIRWING and SQUADRON identifiers
  - Kandahar Heliport runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: AIRWING_OBJECT_CONTRACT
supersedes:
  - docs/33-kandahar-mustang-ramp-army-aviation-baseline.md
  - prior blanket deferral of Kandahar AH-64 OH-58D CH-47 and Army UH-60
  - AH-64A and CH-47D Mission Editor substitution baseline
  - separate AH-64 escort OH-58D escort and CH-47 slingload seed requirement
  - Kandahar assignment of 3-101 Attack Aviation / Task Force Attack
  - generic Kandahar Heliport AIRWING name
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(4).miz
source_mission_sha256: 0732f929d4e35641c84bfb34bd75912692c3a1b7b7a0106847ce56e21aa5345c
validated_in_dcs: false
warehouse_validated_in_dcs: true
---

# 36 – Kandahar Mustang Ramp Army Aviation Baseline

## 1. Dokumentstatus

Die historische Juli-2011-Stationierung, die Mission-Editor-Objekte, beide nativen Airbases und beide Warehouse-Anker sind geprüft. Der Heliport-Warehouse-Vertrag ist in DCS/MOOSE runtime-validiert.

Noch nicht validiert sind:

```text
AIRWING-Konstruktion und Start
SQUADRON-Registrierung
logische Army-Aviation-Bestände
Safe Parking pro Muster
kontrollierte Spawns
AUFTRAG und OPSTRANSPORT
Verlust- und Rückgabelogik
```

Verbindliche Evidenz:

- [`Kandahar Juli-2011 ORBAT Unit Name Reconciliation`](evidence/kandahar-july-2011-orbat-unit-name-reconciliation.md)
- [`Kandahar Heliport Warehouse Contract`](kandahar-heliport-warehouse-contract.md)
- [`Warehouse No-Spawn PASS`](../mission/tests/kandahar-air-operations/results/2026-07-31-kandahar-heliport-warehouse-pass.md)

## 2. Historische Juli-2011-Struktur

Die Juli-2011-ORBAT meldet am Kandahar Airfield:

```text
Task Force Thunder / 159th Combat Aviation Brigade
├── Task Force Guns / 4-227 Attack Aviation
│   └── Attack Aviation Support in Kandahar Province
├── Task Force Palehorse / 7-17 Air Cavalry
│   └── Scout Aviation Support in Kandahar Province
└── Task Force Lift / 7-101 General Support Aviation
    └── Transport Aviation Support in Kandahar Province
```

Verbindliche Korrektur gegenüber dem früheren Dokumentstand:

```text
NICHT Kandahar:
Task Force Attack / 3-101 Attack Aviation
Standort laut Juli-2011-ORBAT: FOB Tarin Kowt
Auftrag: Aviation Support Uruzgan

NICHT Kandahar:
Task Force Wings / 4-101 Assault Aviation
Standort laut Juli-2011-ORBAT: FOB Wolverine, Zabul
Auftrag: Aviation Support Zabul

Kandahar AH-64-Verband:
Task Force Guns / 4-227 Attack Aviation
```

Die historische Quelle bezeichnet den Standort zusammenfassend als `Kandahar Airfield`. Die Zuordnung der Army-Aviation-Elemente zur DCS-Airbase `Kandahar Heliport` ist eine technisch und räumlich validierte OMW-Abbildung der Mustang Ramp, keine abweichende historische Standortbehauptung.

Die Juli-2011-ORBAT nennt `7-101 General Support Aviation` als Transport-Task-Force, löst deren CH-47- und UH-60-Kompanien aber nicht einzeln auf. Ohne zusätzliche Quelle wird deshalb keine Company-Bezeichnung erfunden.

Die zuvor genannte `563rd Aviation Support Battalion / Task Force Fighting` wird nicht als Flug-SQUADRON verwendet. Der Eintrag ist durch die ausgewertete Juli-2011-ORBAT nicht als Kandahar-Eintrag bestätigt und bleibt ein separater Support-/Recherchepunkt.

USAF-HH-60G des 26th ERQS bleiben organisatorisch und bestandsseitig von Army-UH-60 getrennt.

## 3. Native DCS-Airbase und Warehouse

```text
Historical owner:
Task Force Thunder / 159th Combat Aviation Brigade

Technical AIRWING:
AW_US_KAF_159_CAB_TF_THUNDER

Native airbase:
AIRBASE.Afghanistan.Kandahar_Heliport
DCS airdromeId: 15

Warehouse:
WH_AIR_US_KANDAHAR_HELI
DCS type: container_20ft
Coalition: Blue / 2
```

Der Warehouse-Vertrag wurde mit `OMW_Template_v4_Kandahar(4).miz` runtime-validiert:

```text
Nearest Heliport TerminalID: 60
TerminalType: 40
Distance: 149.63 m
Heliport parking nodes: 86
```

Der Heliport-Anker darf niemals an `AIRBASE.Afghanistan.Kandahar` / ID 7 gebunden werden.

## 4. Verbindliche SQUADRON-Kennungen

```text
SQ_US_KAF_AH64_4_227_AVN
Historical label: Task Force Guns / 4-227 Attack Aviation
DCS type: AH-64D_BLK_II

SQ_US_KAF_OH58D_7_17_CAV
Historical label: Task Force Palehorse / 7-17 Air Cavalry
DCS type: OH58D

SQ_US_KAF_CH47_7_101_GSAB
Historical label: Task Force Lift / 7-101 General Support Aviation
DCS type: CH-47Fbl1

SQ_US_KAF_UH60_7_101_GSAB
Historical label: Task Force Lift / 7-101 General Support Aviation
DCS type: UH-60A
```

Verboten beziehungsweise superseded:

```text
SQ_US_KAF_AH64_3_101_AVN
SQ_US_KAF_UH60_159_CAB
```

Der erste Name bindet fälschlich einen Tarin-Kowt-Verband an Kandahar. Der zweite ist historisch zu ungenau, obwohl die Juli-2011-ORBAT mit TF Lift / 7-101 GSAB einen belastbaren Parent nennt.

## 5. Tatsächliche DCS-Abbildung

```text
AH-64 Clients/Templates/Statics: AH-64D_BLK_II
OH-58D Clients/Templates/Statics: OH58D
CH-47 Clients/Templates/Statics: CH-47Fbl1
UH-60 Templates/Statics: UH-60A
UH-60 Clients: keine
HH-60G: separater USAF-Verband; DCS-Repräsentation UH-60A
```

Diese DCS-Typen sind technische Repräsentationen. Historische Einheit, Rolle und logischer Bestand bleiben getrennte Vertragsfelder.

## 6. Client-Assets

```text
CLIENT_US_KAF_AH64D_01 | AH-64D_BLK_II | TerminalID 30 | MST38-H
CLIENT_US_KAF_AH64D_02 | AH-64D_BLK_II | TerminalID 19 | MST30-H

CLIENT_US_KAF_OH58D_01 | OH58D          | TerminalID 80 | MST01-H
CLIENT_US_KAF_OH58D_02 | OH58D          | TerminalID 23 | MST11-H

CLIENT_US_KAF_CH47F_01 | CH-47Fbl1      | TerminalID 4  | MST75-H
CLIENT_US_KAF_CH47F_02 | CH-47Fbl1      | TerminalID 47 | MST82-H
```

```text
Gesamt: 6 Clientgruppen / 6 Spielerluftfahrzeuge
UH-60-Clientgruppen: 0
```

Alle sechs TerminalIDs sind verbindliche Client-Reservierungen. Client-Slots sind keine zusätzlichen Airframes.

## 7. KI-Templates

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

Alle fünf Gruppen sind:

```text
Late Activation: true
Uncontrolled: false
Authoring-Seeds ohne zusätzlichen logischen Bestand
```

Nicht vorhanden und nicht erforderlich:

```text
TPL_AIR_US_KAF_AH64D_ESCORT_2SHIP
TPL_AIR_US_KAF_OH58D_ESCORT_2SHIP
TPL_AIR_US_KAF_CH47_SLINGLOAD_1SHIP
```

MOOSE-first gilt:

```text
ein typreiner SQUADRON-Pool je Muster
Rollen über AUFTRAG, Payload, ROE, Formation und FLIGHTGROUP
keine zusätzlichen Airframe-Pools nur wegen Escort, MEDEVAC oder Slingload
```

## 8. Static-Baseline

```text
STATIC_AIR_US_KAF_AH64_01 ... _08 | 8 x AH-64D_BLK_II
STATIC_AIR_US_KAF_OH58D_01 ... _08 | 8 x OH58D
STATIC_AIR_US_KAF_CH47_01 ... _10   | 10 x CH-47Fbl1
STATIC_AIR_US_KAF_UH60_01 ... _08   | 8 x UH-60A
```

```text
Gesamt: 34 Army-Aviation-Statics
```

Diese Objekte visualisieren Teile des logischen Bestands. Sie sind keine zusätzlichen Airframes. Die zwei USAF-HH-60G-/CSAR-Statics bleiben separat.

## 9. AIRWING-Registrierungsvertrag

`AW_US_KAF_159_CAB_TF_THUNDER` darf nur konstruiert und gestartet werden, wenn:

1. `WH_AIR_US_KANDAHAR_HELI` genau einmal als Blue `container_20ft` erkannt wird;
2. `AIRBASE.Afghanistan.Kandahar_Heliport` als ID 15 erkannt wird;
3. Warehouse und Airbase geometrisch korrekt zugeordnet bleiben;
4. alle vier SQUADRON-Kennungen aus Abschnitt 4 verwendet werden;
5. alle benötigten Templates eindeutig, Late Activation und nicht Uncontrolled sind;
6. Clients und Statics nicht zum logischen Bestand addiert werden;
7. USAF-HH-60G nicht dem Army-UH-60-Pool zugeordnet werden;
8. Bestände und Forward-Detachment-Abzüge verbindlich feststehen;
9. Safe Parking pro Muster akzeptiert ist;
10. jede Abweichung fail-closed den Start blockiert.

## 10. Bestandsverwaltung und Tarinkot-Abzug

Die logischen Anfangsbestände dürfen nicht aus Client-, Static- oder Templatezahlen abgeleitet werden.

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

Tarinkot besitzt verbindlich:

```text
14 AH-64D
6 UH-60
2 CH-47
0 OH-58D
```

Diese Luftfahrzeuge sind aus dem Kandahar-/RC-South-Regionalpool abzuziehen. Die dort historisch gemeldete `Task Force Attack / 3-101 Attack Aviation` darf weder als lokaler Kandahar-Verband noch als zusätzlicher Parallelbestand erscheinen.

Solange der regionale Gesamtpool und weitere Forward Detachments nicht festgelegt sind, dürfen keine produktiven Kandahar-Army-Anfangsbestände registriert werden.

Gemeinsame Rollenpools:

```text
AH-64 CAS und ESCORT: ein AH-64-Pool
OH-58D RECON, AFAC und ESCORT: ein OH-58D-Pool
CH-47 TRANSPORT, OPSTRANSPORT und SLINGLOAD: ein CH-47-Pool
UH-60 TRANSPORT, UTILITY und MEDEVAC: ein UH-60-Pool
```

## 11. Payload-Grenzen

### AH-64D

Das aktuelle Template besitzt M261-Raketenbehälter, zwei Hellfire-Racks, IAFS-Kombinationspaket und 25 Prozent Kanonenmunition. Die konkrete CAS-/Escort-Verwendung wird über Payload und AUFTRAG geprüft.

### OH-58D

Aktuelles Template:

```text
M260_APKWS_M151
OH58D_AGM_114_R
```

APKWS benötigt für den OMW-Zeitraum eine ausdrückliche Projektentscheidung. Ohne Freigabe ist das Template zu korrigieren oder die bewaffnete Nutzung bleibt deaktiviert.

### CH-47F

```text
CH47_PORT_M60D
CH47_STBD_M60D
```

## 12. AUFTRAG- und OPSTRANSPORT-Rollen

```text
AH-64: CAS, ESCORT
OH-58D: RECON, AFAC, ESCORT
CH-47: TRANSPORT, OPSTRANSPORT, SLINGLOAD
UH-60: TRANSPORT, UTILITY, MEDEVAC
```

Jeder Auftrag benötigt definierte SQUADRON, Gruppengröße, Template, Payload, Start-/Zielposition, Formation, ROE, Alarm State, Cargo-/Patientenstatus, Erfolg, Abbruch, Rückkehr und Verlustbehandlung.

MOOSE-first zu prüfen beziehungsweise zu verwenden:

```text
AIRWING
SQUADRON
AUFTRAG
FLIGHTGROUP
OPSTRANSPORT
vorhandene Cargo-, CTLD-, Slingload-, MEDEVAC- und CSAR-Funktionen
SetOptionPreferVertical für gebundene Rotorcraft FLIGHTGROUPs
```

Army-MEDEVAC und USAF-CSAR bleiben getrennte Rollen und Bestände.

Für OPSTRANSPORT gilt: Erfolgreiche Entladung bedeutet nicht automatisch sichere Rückkehr. Wird der Transporter danach zerstört, bleibt die Frachtwirkung erfolgreich, der Airframe ist jedoch verloren.

## 13. Safe Parking

Für `AIRBASE.Afghanistan.Kandahar_Heliport` wurden 86 Runtime-Parking-Nodes festgestellt. Vor produktiver Registrierung sind getrennt je Muster zu prüfen:

1. sechs Client-TerminalIDs dauerhaft reservieren;
2. 34 Statics ihren nächsten Nodes zuordnen;
3. bewusst belegte Nodes blockieren;
4. freie Nodes für AH-64, OH-58D, UH-60 und CH-47 klassifizieren;
5. Rotor-, Revettement-, Taxi- und Nachbarabstände prüfen;
6. CH-47 nur auf ausreichend großen, getesteten Nodes zulassen;
7. Allow-/Blocklists ausschließlich aus Runtime-Daten ableiten.

Keine Parking-ID wird aus der optischen Karte geraten.

## 14. Verlust- und Rückgabelogik

```text
Auftrag angenommen -> Asset reserviert
Spawn/Start -> aktiv
Landung und sichere Rückkehr -> verfügbar oder Wartung/Cooldown
Abbruch mit sicherer Rückkehr -> verfügbar oder Wartung/Cooldown
beschädigte Rückkehr -> beschädigt/Wartung
Crash/Zerstörung -> verloren
Despawn ohne bestätigte Rückkehr -> nicht automatisch verfügbar
```

## 15. Funktionszonen

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

Eine Zone wird nur angelegt, wenn die konkrete MOOSE-/OPSTRANSPORT-/MEDEVAC-Funktion sie benötigt. Parking, Spawn und Static-Zuordnung werden nicht über Funktionszonen gelöst.

## 16. Nächster Runtime-Inkrement

Nächster Teststand:

```text
Kandahar TF Thunder AIRWING Registration Preflight
```

Er darf zunächst:

```text
AW_US_KAF_159_CAB_TF_THUNDER konstruieren
WH_AIR_US_KANDAHAR_HELI binden
Airbase ID 15 verifizieren
vier SQUADRON-Verträge ohne produktiven Bestand prüfen
Templates und Gruppengrößen prüfen
Client-Reservierungen und Parking-Kandidaten protokollieren
```

Er darf noch nicht:

```text
produktive Army-Aviation-Bestände registrieren
AIRWING automatisch starten
Assets spawnen
AUFTRAG oder OPSTRANSPORT erzeugen
Parking-Blacklists ohne Acceptance festschreiben
```

## 17. Offene Entscheidungen

```text
regionaler Gesamtbestand AH-64D, OH-58D, CH-47F und UH-60
weitere Forward-Detachment-Abzüge neben Tarinkot
am Kandahar-Stammknoten verbleibende Anfangsbestände
OH-58D-APKWS-Freigabe oder Payloadkorrektur
vollständige Heliport-Allow-/Blocklists
konkrete Funktionszonen
Wartung, Cooldown, Reparatur und Wiederbeschaffung
CampaignState-Schnittstelle
Performance- und Controlled-Spawn-Acceptance
```

## 18. Acceptance-Kriterien

```text
AIRWING-Name entspricht TF Thunder / 159th CAB
AH-64-SQUADRON entspricht TF Guns / 4-227 Attack Aviation
OH-58D-SQUADRON entspricht TF Palehorse / 7-17 Air Cavalry
CH-47- und UH-60-Pools entsprechen TF Lift / 7-101 GSAB
3-101 und 4-101 werden nicht als Kandahar-SQUADRONs registriert
Warehouse an AIRBASE.Afghanistan.Kandahar_Heliport / ID 15 gebunden
alle sechs Clients und fünf Templates eindeutig erkannt
34 Army-Statics ohne Bestandsaddition erkannt
keine Spawns auf Client- oder Static-Nodes
CH-47 nur auf getesteten großen Nodes
keine spontane Templateaktivierung
Bestände berücksichtigen Tarinkot und weitere Detachments
Rollenvarianten erzeugen keine zusätzlichen Airframe-Pools
Verlust und sichere Rückkehr verändern den Bestand korrekt
keine relevanten Lua-, Parking-, Timer- oder Eventfehler
```