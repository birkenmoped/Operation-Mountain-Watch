---
document_id: OMW-AIR-KANDAHAR-ISR-POLICY
status: STRUCTURALLY_AUDITED_RUNTIME_BLOCKED
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar MQ-1 and MQ-9 Mission Editor templates
  - restricted ISR asset design
  - ISR and armed-ISR separation
  - ISR runtime implementation handoff
scenario_period: 2010-08-01/2011-12-31
project_phase: AIRWING_OBJECT_CONTRACT
supersedes:
  - docs/32-kandahar-isr-asset-policy.md
  - MQ-1 unarmed payload claim for OMW_TEST_TM01M_MooseFirst(18).miz
  - MQ-9 two-GBU-38 payload claim for OMW_TEST_TM01M_MooseFirst(18).miz
source_branch: agent/kandahar-airwing-baseline-contract
source_mission: OMW_Template_v4_Kandahar(1).miz
source_mission_sha256: 07cc90b18bf3a09fee8c650cb9f1668c9ec6c2412a37be5f005642d216deeb8a
validated_in_dcs: false
---

# 35 – Kandahar Restricted ISR Drone Asset Policy

## 1. Dokumentstatus

Die Missionseditor-Templates und Statics sind strukturell bestätigt. Die konkrete AIRWING-/SQUADRON-Registrierung, Anforderungsfreigabe, Cooldown-, ROE-, Verlust- und Rückgabelogik ist noch nicht in DCS/MOOSE validiert.

Die aktuelle Mission widerspricht den älteren dokumentierten Payloadangaben. Deshalb bleiben beide UAV-SQUADRONs bis zur Payloadkorrektur beziehungsweise ausdrücklichen Freigabe fail-closed deaktiviert.

Rohbefund:

- [`OMW-EVIDENCE-KANDAHAR-ME-AUDIT-V4-1`](evidence/kandahar-mission-editor-audit-omw-template-v4-kandahar-1.md).

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

## 3. Tatsächliche Missionseditor-Templates

### 3.1 MQ-1A Predator

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
DCS-Typ: RQ-1A Predator
Gruppengröße: 1
Late Activation: ja
Uncontrolled: nein
Start: Luftstart
```

Payload-Rohbefund:

```text
zwei belegte Pylon-Einträge
CLSID je Pylon: {ee368869-c35a-486a-afe7-284beb7c5d52}
```

Damit ist das aktuelle Template nicht unbewaffnet. Die exakte Waffenbezeichnung dieses CLSIDs muss gegen den tatsächlich verwendeten DCS-Datenstand verifiziert werden.

Verbindliche RECON-only-Zielregel:

```text
MQ-1A
RECON-only
Weapons Hold
keine Strike-Rolle
```

Vor Laufzeitregistrierung muss deshalb eine der folgenden Bedingungen erfüllt sein:

1. beide Pylons werden im Mission Editor geleert; oder
2. der CLSID wird eindeutig gemappt, die Bewaffnung durch den Projektinhaber ausdrücklich freigegeben und eine neue operative Rolle dokumentiert.

Ohne diese Entscheidung bleibt `SQ_US_KAF_MQ1_361_ERS` deaktiviert.

### 3.2 MQ-9 Reaper

```text
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
DCS-Typ: MQ-9 Reaper
Gruppengröße: 1
Late Activation: ja
Uncontrolled: nein
Start: Luftstart
```

Payload-Rohbefund:

```text
Pylon 1: AGM114x2_OH_58
Pylon 2: Bomben-CLSID mit NFP_PRESID=Paveway_II und Laser Code 1688
Pylon 3: Bomben-CLSID mit NFP_PRESID=Paveway_II und Laser Code 1688
Pylon 4: AGM114x2_OH_58
```

Damit trägt das aktuelle Template:

```text
4 x AGM-114
2 x Paveway-II-konfigurierte Bomben
```

Die exakte Bombenvariante muss noch gegen den verwendeten DCS-Datenstand gemappt werden. Die ältere Angabe `2 x GBU-38` ist für die aktuelle Mission ausdrücklich aufgehoben.

Verbindliche operative Trennung:

```text
MQ-9 Standard: RECON / Weapons Hold
MQ-9 ARMED ISR: nur nach ausdrücklicher Missions- und ROE-Freigabe
keine automatische Zielbekämpfung
```

## 4. Luftstart und organisatorisches Modell

Beide aktuellen Templates sind Luftstart-Seeds. Für den ersten technischen Diagnoselauf benötigen sie keine physischen Kandahar-Startplätze.

Vor SQUADRON-Registrierung ist zu entscheiden:

```text
Variante A: organisatorische Assets von AW_US_KANDAHAR
Variante B: abstrahiertes externes ISR-Kontingent
```

Die Wahl beeinflusst:

- Bestand und Verlustbilanz;
- Rückkehrdefinition bei Air-Spawn;
- Cooldown und Wiederverfügbarkeit;
- Warehouse-Zuordnung;
- Parking-Anforderungen;
- Persistenz.

Eine bloße Luftstartposition darf nicht stillschweigend als sichere Rückkehr oder als unbegrenzte Verfügbarkeit interpretiert werden.

## 5. AIRWING- und SQUADRON-Grenze

Reservierte SQUADRON-Kennungen:

```text
SQ_US_KAF_MQ1_361_ERS
SQ_US_KAF_MQ9_361_ERS
```

Der technische AIRWING-Vertrag bleibt offen, bis das Warehouse- oder externe Kontingentmodell entschieden ist.

Die Registrierung muss:

- beide Templategruppen eindeutig finden;
- Template, Static und logischen Bestand strikt trennen;
- maximal einen aktiven UAV-Auftrag gleichzeitig zulassen, bis anders entschieden;
- MQ-1 und MQ-9 getrennte Verfügbarkeiten führen;
- eine fehlende oder unerwartet bewaffnete Templategruppe fail-closed behandeln;
- kein UAV beim Missionsstart spontan aktivieren;
- ROE und Zielzuweisung ausdrücklich setzen;
- Payload-Signaturen beim Start protokollieren.

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

Bevorzugte erste Testregel nach Payloadfreigabe:

```text
maximal 1 aktiver UAV-Auftrag gleichzeitig
begrenzte Missionsdauer
kein sofortiger Wiederaufruf
Cooldown nach Rückkehr, Abbruch oder Verlust
MQ-1 RECON-only
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

Da beide Templates per Luftstart authorisiert sind, benötigen sie für den No-Spawn-Diagnosetest keine physischen Kandahar-Startplätze.

Falls später reale Start-/Landesequenzen verwendet werden:

- geeignete Airbase und Warehouse-Zuordnung zuerst festlegen;
- TerminalIDs und geeignete UAV-Parkpositionen per Laufzeitdiagnose bestimmen;
- Safe Parking aktivieren;
- durch UAV-Statics belegte Plätze blacklisten;
- keine Position aus der Static-Platzierung erraten.

Dauerhafte Flugplatz-Hilfszonen sind für ISR nicht erforderlich. Orbit-, Recon- und Zielzonen sind auftragsbezogen.

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

Bei extern abstrahiertem Air-Spawn muss eine getestete Endzustandsregel definieren, wann sichere Rückkehr als erfüllt gilt.

## 10. Offene Entscheidungen

- MQ-1-Payload leeren oder ausdrücklich bewaffnete Rolle freigeben;
- exakte Zuordnung des MQ-1-CLSIDs;
- exakte Zuordnung der MQ-9-Paveway-II-Bomben;
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
MQ-1-Payload entspricht der ausdrücklich freigegebenen RECON-only-Konfiguration
MQ-1 bekämpft keine Ziele
MQ-9-Payload ist eindeutig gemappt
MQ-9 startet standardmäßig mit Weapons Hold
maximal 1 UAV-Auftrag gleichzeitig
abgelehnte Anforderungen verbrauchen kein Asset
Rückkehr führt in Cooldown und anschließend korrekt in verfügbar
Verlust reduziert den Bestand
keine Doppelzählung der drei Statics
keine ungeplante automatische Waffenfreigabe
```
