---
document_id: OMW-AIR-KANDAHAR-ISR-POLICY
status: IMPLEMENTED_IN_MIZ_UNVALIDATED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar MQ-1 and MQ-9 Mission Editor templates
  - restricted ISR asset design
  - ISR and armed-ISR separation
  - ISR runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - docs/32-kandahar-isr-asset-policy.md
source_branch: docs/bagram-air-operations-manifest
source_mission: OMW_TEST_TM01M_MooseFirst(18).miz
validated_in_dcs: false
---

# 35 – Kandahar Restricted ISR Drone Asset Policy

## 1. Dokumentstatus

Die Missionseditor-Templates und Statics sind vorhanden. Die konkrete AIRWING-/SQUADRON-Registrierung, Anforderungsfreigabe, Cooldown-, ROE-, Verlust- und Rückgabelogik ist noch nicht in DCS/MOOSE validiert.

## 2. Historische und technische Einordnung

```text
361st Expeditionary Reconnaissance Squadron
historische Muster: MQ-1, MQ-9, MC-12
physisch in der nativen DCS-Baseline: MQ-1A und MQ-9
```

Statics:

```text
STATIC_AIR_US_KAF_MQ1A_01
STATIC_AIR_US_KAF_MQ1A_02
STATIC_AIR_US_KAF_MQ9_01
```

Diese Statics sind visuelle Repräsentationen und kein zusätzlicher logischer Bestand.

## 3. Missionseditor-Templates – Revision 18

### MQ-1A Predator

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
  TPL_AIR_US_KAF_MQ1A_RECON_1SHIP_UNIT_01
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
Bewaffnung: keine; pylons leer
Callsign: Ford 3-1
Frequenz: 127,5 MHz AM
```

### MQ-9 Reaper

```text
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
  TPL_AIR_US_KAF_MQ9_RECON_1SHIP_UNIT_01
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

Die Luftstarts sind zunächst Authoring-/Testbaseline. Vor AIRWING-Integration ist zu entscheiden, ob die UAVs als Kandahar-Warehouse-Assets oder als abstrahiertes externes ISR-Kontingent behandelt werden.

## 4. Verbindliche operative Trennung

```text
MQ-1A:
RECON-only Baseline
unbewaffnet
Weapons Hold
keine Strike-Rolle

MQ-9:
RECON als Standard
bewaffnete Fähigkeit vorhanden
Weapons Hold als Standard
ARMED ISR nur nach ausdrücklicher Missions- und ROE-Freigabe
```

Der DCS-Task `Reconnaissance` ist allein kein ausreichender Schutz gegen unbeabsichtigten Waffeneinsatz. ROE und Zielzuweisung müssen ausdrücklich gesetzt und getestet werden.

## 5. AIRWING- und SQUADRON-Registrierung

Vorgesehene Struktur:

```text
AW_US_KANDAHAR
├── SQ_US_KAF_MQ1_361_ERS
└── SQ_US_KAF_MQ9_361_ERS
```

Die UAV-SQUADRONs verwenden `WH_AIR_US_KANDAHAR` als organisatorischen Anker, sofern der Architekturtest kein externes Kontingentmodell verlangt.

Die Registrierung muss:

- beide Templategruppen eindeutig finden;
- Template, Static und logischen Bestand strikt trennen;
- maximal einen aktiven UAV-Auftrag gleichzeitig zulassen, bis anders entschieden;
- MQ-1 und MQ-9 getrennte Verfügbarkeiten führen;
- eine fehlende Templategruppe fail-closed behandeln;
- kein UAV beim Missionsstart spontan aktivieren.

## 6. Bestands- und Verfügbarkeitsmodell

Noch festzulegen sind die absoluten logischen Airframebestände. Unabhängig davon werden folgende Zustände benötigt:

```text
verfügbar
extern gebunden / nicht freigegeben
für Auftrag reserviert
aktiv im Einsatz
zurückkehrend
Cooldown/Wartung
beschädigt
verloren
```

Die eingeschränkte Verfügbarkeit wird innerhalb des Settings durch nationale, nachrichtendienstliche, Special-Operations- oder höher priorisierte Aufgaben erklärt. Eine CIA-Bindung bleibt eine plausible In-World-Erklärung, aber keine ungesicherte feste historische Betreiberzuordnung.

Bevorzugte erste Testregel:

```text
maximal 1 aktiver UAV-Auftrag gleichzeitig
begrenzte Missionsdauer
kein sofortiger Wiederaufruf
Cooldown nach Rückkehr, Abbruch oder Verlust
MQ-1 nur RECON
MQ-9 ARMED ISR nur nach ausdrücklicher Freigabe
```

## 7. AUFTRAG-Ausführung

Vorgesehene Aufgaben:

```text
Area Reconnaissance
Route/Convoy Overwatch
Target/Named Area Observation
Contact Detection and Update
Battle Damage Assessment
zeitlich begrenzte Operationsüberwachung
MQ-9 Armed ISR nach Freigabe
```

Jeder ISR-Auftrag benötigt:

- Zielgebiet beziehungsweise Orbit;
- On-Station-Dauer;
- gewünschtes Muster oder automatische Auswahl;
- Freigabe-/Prioritätsprüfung;
- ROE und Zielzuweisung;
- Rückkehr-, Abbruch- und Treibstoffkriterien;
- Cooldown und Rückgabe;
- Verlustbehandlung.

MOOSE-first zu prüfen sind `AIRWING`, `SQUADRON`, `AUFTRAG`, `FLIGHTGROUP`, Detection/Recon-Funktionen, Events, FSM-Callbacks und Missionswarteschlangen.

## 8. Parking und Funktionszonen

Da beide aktuellen Templates per Luftstart authorisiert sind, benötigen sie für den ersten technischen Test keine physischen Kandahar-Startplätze.

Falls später reale Start-/Landesequenzen verwendet werden:

- TerminalIDs und geeignete UAV-Parkpositionen per Laufzeitdiagnose bestimmen;
- Safe Parking aktivieren;
- durch UAV-Statics belegte Plätze blacklisten;
- keine Position aus der Static-Platzierung erraten.

Dauerhafte Flugplatz-Hilfszonen sind für ISR nicht erforderlich. Orbit-, Recon- und Zielzonen sind auftragsbezogen und werden durch die jeweilige Mission erzeugt oder referenziert.

## 9. Verlust- und Rückgabelogik

```text
Anforderung akzeptiert -> Asset reserviert
Spawn/Aktivierung -> aktiv
Auftrag beendet und sichere Rückkehr bestätigt -> Cooldown
Cooldown beendet und Freigabe vorhanden -> verfügbar
Abbruch mit sicherer Rückkehr -> Cooldown
Beschädigte Rückkehr -> Wartung/beschädigt
Zerstörung/Crash -> verloren
Despawn ohne bestätigte sichere Rückkehr -> nicht automatisch verfügbar
```

Ein verlorenes UAV darf nicht allein wegen eines erfolgreichen Recon- oder Strike-Ergebnisses zurückgegeben werden.

Bei extern abstrahiertem Air-Spawn muss eine getestete Endzustandsregel definieren, wann „sichere Rückkehr“ als erfüllt gilt.

## 10. Offene Entscheidungen

- logischer MQ-1- und MQ-9-Gesamtbestand;
- Warehouse-Asset oder externes Kontingent;
- anforderungsberechtigte Rollen/Spieler;
- Priorität und Menü-/Missionssystem;
- Missionsdauer und Cooldown;
- persistente Verluste und Ersatz;
- Freigabeautorität für MQ-9-Waffeneinsatz;
- automatische oder manuelle Musterwahl.

## 11. Acceptance-Kriterien

```text
beide Templates eindeutig erkannt
beide bleiben bis zur Anforderung inaktiv
MQ-1 startet unbewaffnet und bekämpft keine Ziele
MQ-9 startet mit 2 × GBU-38, aber Weapons Hold
maximal 1 UAV-Auftrag gleichzeitig
abgelehnte Anforderungen verbrauchen kein Asset
Rückkehr führt in Cooldown und anschließend korrekt in verfügbar
Verlust reduziert den Bestand
keine Doppelzählung der drei Statics
keine ungeplante automatische Waffenfreigabe
```
