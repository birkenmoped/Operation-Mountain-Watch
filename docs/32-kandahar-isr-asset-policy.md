# 32 – Kandahar Restricted ISR Drone Asset Policy

## 1. Dokumentstatus

**Grundsatz und Missionseditor-Templates vorhanden; konkrete Verfügbarkeits-, Freigabe- und Wiederholungslogik noch offen**

Dieses Dokument ergänzt das Kandahar Air Operations Manifest. Die in Kandahar vorhandenen MQ-1A- und MQ-9-Drohnen bleiben nicht ausschließlich visuelle Statics, sondern sollen später auch als durch KI steuerbare und durch Spieler beziehungsweise Missionslogik anforderbare ISR-Assets umgesetzt werden.

Der aktuelle Missionseditor-Nachweis stammt aus:

```text
OMW_TEST_TM01M_MooseFirst(13).miz
```

## 2. Historische und projektseitige Einordnung

Für Kandahar ist die 361st Expeditionary Reconnaissance Squadron mit MQ-1, MQ-9 und MC-12 dokumentiert. Im aktuellen DCS-Grundaufbau werden native DCS-Modelle verwendet:

```text
MQ-1A Predator
MQ-9 Reaper
```

Die derzeit gesetzten Statics bleiben visuelle Repräsentationen des lokalen ISR-Bestands:

```text
STATIC_AIR_US_KAF_MQ1A_01
STATIC_AIR_US_KAF_MQ1A_02
STATIC_AIR_US_KAF_MQ9_01
```

Zusätzlich sind inzwischen für beide Muster operative 1-Ship-KI-Templates vorhanden.

## 3. Verbindliche Grundentscheidung

Drohnen werden als eingeschränkt verfügbares, anforderbares KI-Asset behandelt.

Sie sind ausdrücklich:

- keine frei und unbegrenzt verfügbare Standardunterstützung;
- kein dauerhaft über jedem Einsatzgebiet kreisendes Komfort-Asset;
- kein zusätzlicher Client-Slot;
- kein rein dekoratives Static-Element.

Die eingeschränkte Verfügbarkeit wird innerhalb des Missionssettings damit erklärt, dass Teile der UAV-Kapazität durch nationale, nachrichtendienstliche oder anderweitig priorisierte Aufgaben gebunden sind. Eine mögliche CIA- oder Special-Operations-Nutzung dient als plausible In-World-Erklärung, ist jedoch ohne belastbaren Nachweis nicht als alleinige historische Betreiberzuordnung festzuschreiben.

## 4. Aktueller Missionseditor-Stand

### 4.1 MQ-1A Predator

```text
TPL_AIR_US_KAF_MQ1A_RECON_1SHIP
  TPL_AIR_US_KAF_MQ1A_RECON_1SHIP_UNIT_01
```

Technischer Stand:

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
Bewaffnung: 2 identische Lenkflugkörper, je einer an Pylon 1 und 2
Callsign: Ford 3-1
Frequenz: 127,5 MHz AM
```

Der zuvor versehentlich vorhandene Gruppennamenssuffix `-1` wurde entfernt. Der Gruppenname entspricht nun dem Projektschema.

### 4.2 MQ-9 Reaper

```text
TPL_AIR_US_KAF_MQ9_RECON_1SHIP
  TPL_AIR_US_KAF_MQ9_RECON_1SHIP_UNIT_01
```

Technischer Stand:

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
Bewaffnung:
  1 × GBU-38 an Pylon 2
  1 × GBU-38 an Pylon 3
Callsign: Chevy 3-1
Frequenz: 251 MHz AM
```

### 4.3 Template-Bewertung

Beide Templates erfüllen die aktuelle technische Grundanforderung:

```text
1 Luftfahrzeug je Gruppe
Late Activation
kein spontaner Missionsstart
native DCS-KI-Muster
getrennte MQ-1A- und MQ-9-Assets
bewaffnete ISR-Grundkonfiguration
```

Der Luftstart ist als Authoring- und Testbaseline zulässig. Vor der AIRWING-/SQUADRON-Integration ist zu entscheiden und zu testen, ob die Drohnen:

- dauerhaft per Air Spawn eingesetzt werden;
- als reale Kandahar-Warehouse-Assets starten und landen;
- oder durch ein bewusst abstrahiertes externes ISR-Kontingent bereitgestellt werden.

## 5. Vorgesehene Einsatzrollen

Primäre Rolle:

```text
ISR / persistent reconnaissance
```

Mögliche unterstützende Funktionen:

- Aufklärung eines vorgegebenen Ziel- oder Verdachtsgebiets;
- Beobachtung einer Route, eines Konvois oder eines Zielobjekts;
- Aufdeckung und Aktualisierung feindlicher Kontakte;
- Bereitstellung eines Lagebildes für Commander, JTAC oder Spieler;
- Battle Damage Assessment;
- zeitlich begrenzte Überwachung vor oder während einer Operation.

Durch die aktuelle Bewaffnung sind beide Templates grundsätzlich für bewaffnete ISR-Missionen geeignet. Daraus folgt jedoch keine automatische Strike-Freigabe.

Die operative Trennung lautet:

```text
RECON:
Aufklärung und Überwachung ohne selbstständigen Waffeneinsatz

ARMED ISR:
Aufklärung mit begrenzter und ausdrücklich freizugebender Bekämpfungsmöglichkeit
```

Standardzustand für reine ISR-Aufträge soll sein:

```text
Weapons Hold
keine selbstständige Bekämpfung zufällig erkannter Ziele
Waffeneinsatz nur nach expliziter Missions-, ROE- oder Zielzuweisung
```

Die endgültige ROE- und Engagement-Logik muss im späteren MOOSE-/DCS-Test nachgewiesen werden. Der Missionseditor-Task `Reconnaissance` allein gilt nicht als ausreichende Sicherung gegen unbeabsichtigten Waffeneinsatz.

## 6. Noch offene Steuerungsparameter

Vor der Implementierung müssen mindestens folgende Punkte festgelegt und getestet werden:

```text
Wer darf das Asset anfordern?
Über welches Menü oder welches Missionssystem erfolgt die Anforderung?
Welche Voraussetzungen müssen erfüllt sein?
Wie viele UAV-Einsätze sind gleichzeitig zulässig?
Wie oft darf ein Einsatz pro Missionslauf angefordert werden?
Gibt es Cooldown-, Kontingent- oder Prioritätsregeln?
Wie lange bleibt die Drohne im Einsatzgebiet?
Was geschieht bei Verlust, Treibstoffmangel oder Abbruch?
Wird das Asset aus einem persistenten Kampagnenbestand verbraucht?
Wie werden konkurrierende Anforderungen priorisiert?
Wann darf von RECON auf ARMED ISR beziehungsweise Strike-Freigabe gewechselt werden?
Wer erteilt die Waffenfreigabe?
```

## 7. Bevorzugtes Verfügbarkeitsmodell für den ersten Test

Für den ersten technischen Test ist ein konservatives Modell vorzuziehen:

```text
maximal 1 aktiver UAV-Auftrag gleichzeitig
begrenzte Missionsdauer
kein sofortiger Wiederaufruf
Cooldown nach Rückkehr, Abbruch oder Verlust
Anforderung nur für definierte ISR-Aufgaben
Weapons Hold als Standard
bewaffnete Wirkung nur nach ausdrücklicher Freigabe
```

Die genauen Zahlen werden bewusst noch nicht festgelegt. Sie müssen sich aus Spielbarkeit, Missionsdauer, historischem Plausibilitätsrahmen und technischer MOOSE-Umsetzung ergeben.

## 8. MOOSE-First-Anforderung

Vor eigener Lua-Logik ist zu prüfen, welche vorhandenen MOOSE-Klassen die Aufgabe bereits abdecken, insbesondere für:

- AIRWING und SQUADRON;
- AUFTRAG-basierte Reconnaissance-, Orbit- oder Strike-Missionen;
- begrenzte Asset-Bestände;
- Missionsanforderung und Missionswarteschlange;
- Cooldown- und Wiederverfügbarkeitslogik;
- Verlust- und Rückkehrbehandlung;
- Commander- oder Player-Tasking;
- ROE-, Alarm-State- und Zielzuweisung;
- kontrollierten Wechsel zwischen RECON und ARMED ISR.

Eigene Steuerlogik ist nur zulässig, wenn MOOSE die benötigte Einschränkung oder Anforderungslogik nicht ausreichend abbildet. Diese Abweichung muss dokumentiert und getestet werden.

## 9. Abgrenzung zu den Statics und Bestandsrechnung

Die drei vorhandenen Drohnen-Statics stellen sichtbaren Flugplatzbestand dar. Die beiden Mission-Editor-Templates sind technische Authoring Seeds. Weder Statics noch Templates dürfen ungeprüft als zusätzliche Luftfahrzeuge zum logischen AIRWING-Bestand addiert werden.

Für die spätere Bestandsrechnung muss ausdrücklich zwischen folgenden Ebenen unterschieden werden:

```text
sichtbare Statics
Mission-Editor-Templates
logischer SQUADRON-/AIRWING-Bestand
aktuell eingesetzte UAVs
verlorene oder vorübergehend nicht verfügbare UAVs
extern gebundene beziehungsweise nicht freigegebene UAV-Kapazität
```

## 10. Autoritative Festlegung

Für Kandahar gilt ab sofort:

```text
MQ-1A und MQ-9 werden als anforderbare KI-ISR-Assets vorgesehen.
Für beide Muster existiert jeweils ein Late-Activation-1-Ship-Template.
Beide Templates besitzen eine begrenzte Bewaffnung.
Die Standardrolle bleibt ISR/RECON.
Bewaffnung bedeutet keine automatische Waffenfreigabe.
Weapons Hold ist für reine ISR-Aufträge der vorgesehene Ausgangszustand.
Ihre Verfügbarkeit bleibt eingeschränkt.
Die konkrete Anforderungs-, Kontingent-, Cooldown-, ROE- und Verlustlogik ist noch zu entscheiden.
Eine CIA-/nachrichtendienstliche Bindung ist eine plausible Missionsbegründung, aber keine ungesicherte feste ORBAT-Zuordnung.
Die Umsetzung erfolgt MOOSE-first.
```
