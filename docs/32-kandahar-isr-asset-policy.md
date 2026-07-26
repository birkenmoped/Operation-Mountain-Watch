# 32 – Kandahar Restricted ISR Drone Asset Policy

## 1. Dokumentstatus

**Grundsatz entschieden; konkrete Verfügbarkeits-, Freigabe- und Wiederholungslogik noch offen**

Dieses Dokument ergänzt das Kandahar Air Operations Manifest. Die in Kandahar vorhandenen MQ-1A- und MQ-9-Drohnen bleiben nicht ausschließlich visuelle Statics, sondern sollen später auch als durch KI steuerbare und durch Spieler beziehungsweise Missionslogik anforderbare ISR-Assets umgesetzt werden.

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

Zusätzlich soll mindestens eine operative KI-Template- und spätere AIRWING-/SQUADRON-Struktur für anforderbare ISR-Aufträge entstehen.

## 3. Verbindliche Grundentscheidung

Drohnen werden als eingeschränkt verfügbares, anforderbares KI-Asset behandelt.

Sie sind ausdrücklich:

- keine frei und unbegrenzt verfügbare Standardunterstützung;
- kein dauerhaft über jedem Einsatzgebiet kreisendes Komfort-Asset;
- kein zusätzlicher Client-Slot;
- kein rein dekoratives Static-Element.

Die eingeschränkte Verfügbarkeit wird innerhalb des Missionssettings damit erklärt, dass Teile der UAV-Kapazität durch nationale, nachrichtendienstliche oder anderweitig priorisierte Aufgaben gebunden sind. Eine mögliche CIA- oder Special-Operations-Nutzung dient als plausible In-World-Erklärung, ist jedoch ohne belastbaren Nachweis nicht als alleinige historische Betreiberzuordnung festzuschreiben.

## 4. Vorgesehene Einsatzrollen

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

Bewaffnete Wirkung, direkte Zielbekämpfung oder automatische Strike-Freigabe werden nicht aus der bloßen Verfügbarkeit des MQ-1-/MQ-9-Modells abgeleitet. Dafür ist eine separate fachliche Entscheidung erforderlich.

## 5. Noch offene Steuerungsparameter

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
```

## 6. Bevorzugtes Verfügbarkeitsmodell für den ersten Test

Für den ersten technischen Test ist ein konservatives Modell vorzuziehen:

```text
maximal 1 aktiver UAV-Auftrag gleichzeitig
begrenzte Missionsdauer
kein sofortiger Wiederaufruf
Cooldown nach Rückkehr, Abbruch oder Verlust
Anforderung nur für definierte ISR-Aufgaben
```

Die genauen Zahlen werden bewusst noch nicht festgelegt. Sie müssen sich aus Spielbarkeit, Missionsdauer, historischem Plausibilitätsrahmen und technischer MOOSE-Umsetzung ergeben.

## 7. MOOSE-First-Anforderung

Vor eigener Lua-Logik ist zu prüfen, welche vorhandenen MOOSE-Klassen die Aufgabe bereits abdecken, insbesondere für:

- AIRWING und SQUADRON;
- AUFTRAG-basierte Reconnaissance- oder Orbit-Missionen;
- begrenzte Asset-Bestände;
- Missionsanforderung und Missionswarteschlange;
- Cooldown- und Wiederverfügbarkeitslogik;
- Verlust- und Rückkehrbehandlung;
- Commander- oder Player-Tasking.

Eigene Steuerlogik ist nur zulässig, wenn MOOSE die benötigte Einschränkung oder Anforderungslogik nicht ausreichend abbildet. Diese Abweichung muss dokumentiert und getestet werden.

## 8. Missionseditor-Bedarf

Vor der Runtime-Implementierung sind voraussichtlich erforderlich:

```text
mindestens ein Late-Activation-KI-Template für MQ-1A oder MQ-9
saubere Gruppen- und Unitnamen nach Projektschema
kein zusätzlicher Client-Slot
keine Hilfszone ohne konkrete Runtime-Funktion
```

Die Auswahl zwischen MQ-1A, MQ-9 oder beiden Typen sowie konkrete Template-Namen werden erst mit dem operativen Modell festgelegt.

## 9. Abgrenzung zu den Statics

Die drei vorhandenen Drohnen-Statics stellen sichtbaren Flugplatzbestand dar. Sie sind nicht automatisch zusätzliche logische Assets und dürfen nicht ungeprüft zum AIRWING-Bestand addiert werden.

Für die spätere Bestandsrechnung muss ausdrücklich zwischen folgenden Ebenen unterschieden werden:

```text
sichtbare Statics
Mission-Editor-Templates
logischer SQUADRON-/AIRWING-Bestand
aktuell eingesetzte UAVs
verlorene oder vorübergehend nicht verfügbare UAVs
```

## 10. Autoritative Festlegung

Für Kandahar gilt ab sofort:

```text
MQ-1A und/oder MQ-9 werden als anforderbare KI-ISR-Assets vorgesehen.
Ihre Verfügbarkeit bleibt eingeschränkt.
Die konkrete Anforderungs-, Kontingent-, Cooldown- und Verlustlogik ist noch zu entscheiden.
Eine CIA-/nachrichtendienstliche Bindung ist eine plausible Missionsbegründung, aber keine ungesicherte feste ORBAT-Zuordnung.
Die Umsetzung erfolgt MOOSE-first.
```