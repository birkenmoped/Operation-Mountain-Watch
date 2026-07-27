# TM02W – Geplanter Abnahmerahmen für rotes Netzwerk, Führung und Standorte

## Status

```text
PLANNED
NOT IMPLEMENTED
```

TM02W ist der geplante Nachfolger der reinen Packet-/Proxy-Stufe TM02V. Dieses Dokument friert den fachlichen Testumfang ein, bevor Controller, Registry und Mission-Editor-Daten implementiert werden.

TM02W darf nicht als ein einzelner großer Lauf umgesetzt werden. Die Unterstufen müssen separat implementiert und abgenommen werden.

## Abgrenzung zu TM02V

TM02V weist weiterhin nach:

- dynamisch erzeugte Personalkontingente;
- Gruppengrößen bis zum konfigurierten Maximum;
- unabhängige Proxies und physische Gruppen;
- Pack/Unpack und Retention;
- Verluste und exakte Personalbilanz;
- mehrere gleichzeitig aktive Gruppen.

TM02W ergänzt:

- präfixbasierte Netzregistrierung;
- mehrere Personalquellen;
- kostenbewertete Quelle und Route;
- zeitlich begrenzte Kommandeursentscheidungen;
- verzögerte und unsichere Informationen;
- geplante Unterbesetzung und spätere Wiederauffüllung;
- Angriffsverbände aus zwei Sechserteams;
- Landschaftsstandorte, Zerstörung und Ersatzbesetzung.

Die TM02V-Version-6-Annahme „jeder leere Knoten endet zwingend als 6 + 4“ ist kein Produktionsziel.

## Gemeinsame Testparameter

### Mobile Kräfte

```text
maxTeamStrength = 6
standardAttackTeamCount = 2
standardAttackTeamStrength = 6
standardAttackTotalStrength = 12
```

### Knotenklassen

```text
STATION:
  guardFloor = 2
  readinessTarget = 6
  hardCapacity = 12

SUB_HQ / REGIONAL_HUB:
  guardFloor = 4
  readinessTarget = 12
  hardCapacity = 24
```

### Kommandeurszyklen

```text
localCycleSeconds = 45
subHqCycleSeconds = 120
mainHqCycleSeconds = 240

localOrdersPerCycle = 1
subHqOrdersPerCycle = 2
mainHqOrdersPerCycle = 2
```

Diese Werte sind Testkonfiguration. Sie dürfen später kalibriert werden, ohne die Architektur zu ändern.

## TM02W1 – Registry und Mission-Editor-Vertrag

### Mission-Editor-Präfixe

```text
OMW_RED_HQ_<freier Name>
OMW_RED_SUBHQ_<freier Name>
OMW_RED_SITE_<freier Name>
OMW_RED_NODEAREA_<freier Name>
OMW_RED_ROUTE_<freier Name>
```

### PASS

- Objekte werden ausschließlich über Präfix und vollständigen tatsächlichen Namen registriert.
- Keine globale fortlaufende Nummerierung ist erforderlich.
- DCS-seitig ergänzte Suffixe erzeugen weiterhin eindeutige IDs.
- Genau ein Haupt-HQ pro getesteter Netzkomponente wird erkannt.
- Sites und Nodes sind getrennte Laufzeitobjekte.
- Jede Route besitzt gültige Endpunkte.
- Doppelte, selbstreferenzierende oder unauflösbare Verbindungen werden als Fehler gemeldet.
- Ein Baum wird als gültiger Spezialfall akzeptiert.
- Eine Quer- oder Alternativverbindung wird ebenfalls korrekt registriert.

### FAIL

- Topologie muss aus Namen wie `PARENT_007` abgeleitet werden.
- Der Designer muss eine globale Nummernliste pflegen.
- Ein unbekanntes Präfix wird stillschweigend als gültiger Netztyp behandelt.
- Fehlende Route oder fehlender Endpunkt führt erst während einer Bewegung zu einem Fehler.

## TM02W2 – Mehrere Quellen und Kostenwahl

### Testnetz

Mindestens:

```text
Haupt-HQ
Unter-HQ
rückwärtige Station
frontnahe Station
Zielstation
```

Für dasselbe Ziel müssen mindestens zwei technisch mögliche Quellen existieren.

### Kostenbestandteile

Mindestens:

```text
Reisezeit
Entfernung
Schwächung der Quelle
Zeit bis zur Wiederauffüllung der Quelle
Routenrisiko
```

### PASS

- Der geometrisch nächste Knoten wird nicht automatisch gewählt.
- Die Quelle mit den niedrigsten Gesamtkosten wird gewählt.
- Ein rückwärtiger Knoten darf Personal abgeben, wenn seine schnelle Wiederauffüllung die Gesamtkosten senkt.
- `currentPersonnel`, `reservedInbound` und `reservedOutbound` bleiben widerspruchsfrei.
- Kein Personal und keine Zielkapazität werden doppelt reserviert.
- Kein Team überschreitet sechs Mann.
- Reisewege stammen aus registrierten Verbindungen, nicht aus einer erfundenen Direktkante.
- Nach Ankunft wird mit dem neuen Zustand neu geplant.

### Kontrollierter Gegenfall

Eine nahe Station mit knapper Restbesatzung muss gegen ein etwas weiter entferntes Unter-HQ verlieren können, wenn die Quellschwächungs- und Wiederauffüllkosten der Station höher sind.

## TM02W3 – Begrenzte Führung und verzögertes Wissen

### Technische Wahrheit

Der Testcontroller kennt alle tatsächlichen Bestände und Ereignisse.

### Kommandowissen

Der Kommandeur erhält Ereignisse erst nach `deliveryTime` und plant nur mit seinem bekannten Zustand.

### PASS

- Ein Verlust löst vor Zustellung der Meldung keinen zentralen Auftrag aus.
- Ein einzelner lokaler Verlust kann bis zum nächsten Melde- und Führungszyklus unkompensiert bleiben.
- Pro Zyklus wird das konfigurierte Auftragsbudget nicht überschritten.
- Nur eine begrenzte Zahl Aufgaben, Quellen und Routen wird bewertet.
- Das Kommandowissen darf vom tatsächlichen Zustand abweichen.
- Meldungen altern von `CONFIRMED` oder `REPORTED` zu `STALE` und verfallen.
- Blue-Kontakte werden als Gebiet und Größenband gespeichert, nicht als dauerhaft exakte Einheitentracks.
- Lokale HUMINT kann offene Bewegungen melden, ohne verdeckte Blue-Kräfte allwissend zu erfassen.

### FAIL

- HQ reagiert im selben technischen Tick auf jeden Verlust.
- Der Planer kennt exakte Blue-Positionen ohne Beobachtung oder Meldung.
- Ein Zyklus erzeugt unbegrenzt viele neue Aufträge.
- Eine alte Meldung bleibt unbegrenzt exakt und aktuell.

## TM02W4 – Angriffsverband, geplante Unterbesetzung und Nachersatz

### Ausgangslage

Eine rückwärtige Station besitzt genügend Personal für einen Standardangriff und darf bewusst geschwächt werden. Ein Unter-HQ kann sie später auffüllen.

### Angriffsauftrag

```text
2 unabhängige Teams
je 6 Mann
Gesamt 12 Mann
```

### PASS

- Beide Teams besitzen getrennte IDs, Proxies, Positionen und Verluststände.
- Der Angriff ist ein gemeinsamer Auftrag, keine physische Zwölfergruppe.
- Der Quellknoten darf durch eine dokumentierte Entscheidung unter sein Bereitschaftsziel fallen.
- Das entstehende Defizit wird als `PLANNED_DEFICIT` markiert.
- Das Unter-HQ plant Nachersatz erst gemäß Melde- und Kommandeurszyklus.
- Angriffsbewegung und Nachersatz dürfen gleichzeitig laufen.
- Fällt ein Angriffsteam aus, kann der Auftrag warten, abbrechen oder ausdrücklich reduziert werden.
- Die Gesamtbilanz umfasst stationäres, unterwegs befindliches, operativ gebundenes und verlorenes Personal.

### FAIL

- Ein Knoten darf nie Personal für einen Angriff abgeben.
- Der Dispatcher füllt die bewusst geschwächte Quelle im selben Tick reflexartig wieder auf.
- Beide Angriffsteams teilen eine Proxygruppe oder eine Verlustbilanz.
- Ein Zwölferteam wird entgegen `maxTeamStrength = 6` erzeugt.

## TM02W5 – Landschaftsstandort, Zerstörung und Ersatz

### Setup

Mindestens:

```text
1 festes HQ
1 optionales Unter-HQ
3 designerfreigegebene OMW_RED_SITE_*
1 OMW_RED_NODEAREA_* für experimentelle Kandidatensuche
2 bis 3 OMW_RED_ROUTE_*
```

Ein Site muss ein vorhandenes Afghanistan-Landschaftsgebäude oder einen geprüften Compound als Anker verwenden.

### Standortzustände

```text
AVAILABLE
SELECTED
OCCUPYING
ESTABLISHING
ACTIVE
COMPROMISED
DESTROYED
```

### PASS

- Der Kommandeur wählt nur designerfreigegebene Sites oder gefilterte Kandidaten innerhalb eines NodeArea.
- Garnisonen materialisieren plausibel um den Anker und nicht in ungeeigneter Gebäudegeometrie.
- Blue muss die rote Nutzung durch Aktivität oder Meldung aufklären; das Gebäude allein ist kein automatisch bestätigtes Ziel.
- Garnisonsverlust ohne Gebäudeverlust kann `SITE_COMPROMISED` erzeugen.
- Bestätigte Gebäudezerstörung setzt einen dauerhaften `SITE_DESTROYED`-Latch.
- Ein zerstörter Site wird nie erneut aktiviert.
- Ein Ersatzknoten erhält einen anderen Site und eine neue Node-ID.
- Ersatzwahl erfolgt erst nach Meldungs-, Entscheidungs-, Sperr- und Aufbauzeit.

### Vorläufige Zeit- und Distanzwerte

```text
Mindestabstand Ersatz-Site: 1 bis 2 km
regionale Sperrzeit:        10 bis 30 Minuten
Aufbauzeit:                  5 bis 15 Minuten
```

### FAIL

- Ein zerstörtes Landschaftsgebäude wird per Skript repariert oder wiederbelebt.
- Rot besetzt unmittelbar dasselbe zerstörte Gebäude neu.
- Der Kommandeur wählt ein beliebiges ungeprüftes Gebäude auf der gesamten Karte.
- Jedes zivile Gebäude wird ohne Aufklärung als legitimes Blue-Ziel behandelt.

## Gemeinsame Bilanzinvarianten

In jeder Unterstufe muss gelten:

```text
stationäres Personal
+ unterwegs befindliches Personal
+ operativ gebundenes Personal
+ bestätigte Verluste
= autoritativer Gesamtbestand
```

Zusätzlich:

```text
currentPersonnel >= 0
reservedInbound >= 0
reservedOutbound >= 0
currentPersonnel + reservedInbound <= hardCapacity
reservedOutbound <= currentPersonnel
aktive Teamstärke <= 6
```

## Erforderliche Diagnostik

Die Implementierung muss semantisch mindestens folgende Ereignisse liefern. Die endgültigen Feldnamen werden mit der jeweiligen Unterstufe eingefroren.

```text
red_network_registry_ready
red_network_validation_failed
red_report_queued
red_report_delivered
red_commander_cycle_started
red_commander_cycle_completed
red_order_issued
red_order_rejected
red_personnel_reserved
red_team_started
red_team_arrived
red_attack_created
red_attack_state_changed
red_site_selected
red_site_occupied
red_site_active
red_site_compromised
red_site_destroyed
red_replacement_site_selected
```

Jedes Ereignis muss die relevanten Node-, Site-, Team-, Auftrag- und Bilanzkennungen enthalten.

## Implementierungsreihenfolge

```text
W1 Registry und Graph
→ W2 Mehrquellen- und Kostenwahl
→ W3 Meldungen und begrenzte Führung
→ W4 Angriffsverband und Nachersatz
→ W5 Landschaftsstandorte und Ersatz
```

Keine Unterstufe wird übersprungen. TM02W5 darf erst beginnen, wenn W1 bis W4 eine stabile Personal- und Auftragsbilanz besitzen.