---
document_id: OMW-AIR-KANDAHAR-ISR-POLICY
status: IMPLEMENTED_IN_MIZ_UNVALIDATED
authoritative_for:
  - Kandahar MQ-1 and MQ-9 Mission Editor templates
  - restricted ISR asset design
  - ISR and armed-ISR separation
  - Mission Editor UAV state in OMW_TEST_TM01M_MooseFirst(17).miz
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/32-kandahar-isr-asset-policy.md
source_branch: docs/bagram-air-operations-manifest
source_mission: OMW_TEST_TM01M_MooseFirst(17).miz
validated_in_dcs: false
---

# 35 – Kandahar Restricted ISR Drone Asset Policy

## 1. Dokumentstatus

Grundsatz und Missionseditor-Templates sind vorhanden. Die konkrete Verfügbarkeits-, Freigabe-, Cooldown-, ROE-, Verlust- und Wiederholungslogik ist noch nicht technisch validiert.

Aktueller Missionseditor-Nachweis:

```text
OMW_TEST_TM01M_MooseFirst(17).miz
```

## 2. Historische und technische Einordnung

Für Kandahar ist die 361st Expeditionary Reconnaissance Squadron mit MQ-1, MQ-9 und MC-12 dokumentiert.

Im aktuellen nativen DCS-Grundaufbau:

```text
MQ-1A Predator
MQ-9 Reaper
```

Vorhandene Statics:

```text
STATIC_AIR_US_KAF_MQ1A_01
STATIC_AIR_US_KAF_MQ1A_02
STATIC_AIR_US_KAF_MQ9_01
```

Die Statics sind visuelle Repräsentationen und kein zusätzlicher logischer Bestand.

## 3. Verbindliche Grundentscheidung

MQ-1 und MQ-9 werden als eingeschränkt verfügbare, anforderbare KI-ISR-Assets vorgesehen.

Sie sind:

- keine frei und unbegrenzt verfügbare Standardunterstützung;
- kein dauerhaft über jedem Einsatzgebiet kreisendes Komfort-Asset;
- keine Client-Slots;
- nicht ausschließlich dekorative Statics;
- keine automatisch zum Strike freigegebenen Waffenträger.

Teile der UAV-Kapazität dürfen im Missionssetting als durch nationale, nachrichtendienstliche oder höher priorisierte Aufgaben gebunden erklärt werden. Eine CIA- oder Special-Operations-Zuordnung bleibt plausible In-World-Erklärung, aber keine ungesicherte feste historische Betreiberzuordnung.

## 4. Missionseditor-Templates

### MQ-1A Predator

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
  TPL_AIR_US_KAF_MQ1A_RECON_1SHIP_UNIT_01
```

```text
DCS-Typ: RQ-1A Predator
Gruppengröße: 1
Skill: High
Late Activation: ja
Uncontrolled: nein
Task: Reconnaissance
Start: Luftstart
Höhe: 2.000 m BARO
Geschwindigkeit: ca. 111 km/h
Fuel: 200
Bewaffnung: keine; pylons = {}
Callsign: Enfield 3-1
Frequenz: 127,5 MHz AM
```

Die MQ-1A ist in Revision 17 ausdrücklich als unbewaffnetes RECON-/ISR-Asset konfiguriert. Ein späterer Waffeneinsatz ist für dieses Template nicht vorgesehen, solange keine neue ausdrückliche Projektentscheidung getroffen wird.

### MQ-9 Reaper

```text
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
  TPL_AIR_US_KAF_MQ9_RECON_1SHIP_UNIT_01
```

```text
DCS-Typ: MQ-9 Reaper
Gruppengröße: 1
Skill: High
Late Activation: ja
Uncontrolled: nein
Task: Reconnaissance
Start: Luftstart
Höhe: 2.000 m BARO
Geschwindigkeit: ca. 296 km/h
Fuel: 1.300
Bewaffnung: 2 × GBU-38
Callsign: Chevy 3-1
Frequenz: 251 MHz AM
```

Die aktuellen Luftstarts sind Authoring- und Testbaseline. Vor der AIRWING-/SQUADRON-Integration ist zu entscheiden und zu testen, ob UAVs:

- per Air Spawn bereitgestellt werden;
- als reale Kandahar-Warehouse-Assets starten und landen;
- oder als ausdrücklich abstrahiertes externes ISR-Kontingent gelten.

## 5. Rollen und Waffenfreigabe

Primäre Rolle:

```text
ISR / persistent reconnaissance
```

Mögliche Aufgaben:

- Aufklärung eines Ziel- oder Verdachtsgebiets;
- Beobachtung von Route, Konvoi oder Zielobjekt;
- Kontaktaufdeckung und Lagebildaktualisierung;
- Unterstützung für COMMANDER, JTAC und Spieler;
- Battle Damage Assessment;
- zeitlich begrenzte Operationsüberwachung.

Trennung:

```text
MQ-1 RECON:
unbewaffnete Aufklärung ohne eigenen Waffeneinsatz

MQ-9 RECON:
Aufklärung mit vorhandener Bewaffnung, aber ohne automatische Waffenfreigabe

ARMED ISR:
nur nach ausdrücklich freigegebener Missions-, ROE- oder Zielzuweisung
```

Standard für reine ISR-Aufträge:

```text
Weapons Hold
keine selbstständige Bekämpfung zufällig erkannter Ziele
Waffeneinsatz nur nach expliziter Missions-, ROE- oder Zielzuweisung
```

Der Missionseditor-Task `Reconnaissance` allein gilt nicht als nachgewiesene Schutzmaßnahme gegen unbeabsichtigten Waffeneinsatz der bewaffneten MQ-9.

## 6. Bevorzugtes erstes Verfügbarkeitsmodell

```text
maximal 1 aktiver UAV-Auftrag gleichzeitig
begrenzte Missionsdauer
kein sofortiger Wiederaufruf
Cooldown nach Rückkehr, Abbruch oder Verlust
Anforderung nur für definierte ISR-Aufgaben
Weapons Hold als Standard
bewaffnete Wirkung der MQ-9 nur nach ausdrücklicher Freigabe
```

Konkrete Zahlen und Regeln bleiben bis zum MOOSE-First-Entwurf offen.

## 7. Noch zu entscheidende Parameter

- anforderungsberechtigte Rolle oder Spielergruppe;
- Menü- oder Missionssystem;
- Voraussetzungen und Prioritäten;
- gleichzeitige und kumulative Einsatzgrenzen;
- Cooldown und Missionsdauer;
- Treibstoff-, Abbruch- und Verlustbehandlung;
- persistenter Bestand;
- Autorität für eine mögliche MQ-9-Waffenfreigabe;
- Rückkehr, Landung und Wiederverfügbarkeit.

## 8. MOOSE-First-Anforderung

Vor eigener Lua-Logik sind mindestens zu prüfen:

- `AIRWING` und `SQUADRON`;
- `AUFTRAG` für Reconnaissance, Orbit und gegebenenfalls Strike;
- begrenzte Assetbestände und Missionswarteschlangen;
- COMMANDER- und Player-Tasking;
- ROE, Alarm State und Zielzuweisung;
- Rückkehr, Verlust und Wiederverfügbarkeit;
- Events, FSM-Callbacks und Scheduler.

Eine verbleibende Nicht-MOOSE-Logik darf nur nach dokumentierter technischer Lücke und ausdrücklicher Projektinhaberfreigabe umgesetzt werden.

## 9. Bestandsrechnung

Getrennte Ebenen:

```text
sichtbare Statics
Missionseditor-Templates
logischer SQUADRON-/AIRWING-Bestand
aktuell eingesetzte UAVs
verlorene oder nicht verfügbare UAVs
extern gebundene beziehungsweise nicht freigegebene Kapazität
```

## 10. Autoritative Festlegung

```text
MQ-1 und MQ-9 sind anforderbare, eingeschränkt verfügbare KI-ISR-Assets.
Je Muster existiert ein 1-Ship-Template.
Die MQ-1A ist in Revision 17 unbewaffnet.
Die MQ-9 besitzt weiterhin 2 × GBU-38.
Standardrolle ist ISR/RECON mit Weapons Hold.
Bewaffnung der MQ-9 ist keine automatische Waffenfreigabe.
Verfügbarkeit, Cooldown, ROE und Verlustlogik bleiben vor technischer Freigabe offen.
Umsetzung erfolgt MOOSE-first.
```