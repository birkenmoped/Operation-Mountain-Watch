# 21 – Jalalabad Air Operations: Manifest, Testchronik und Abschlussstand

## 1. Status und Autorität

Dieses Dokument ist die verbindliche Jalalabad-spezifische Quelle für:

- lokale Luft-ORBAT,
- Spieler- und KI-Grenzen,
- MOOSE-AIRWING-/SQUADRON-Struktur,
- sichtbare Statics und virtuelle Reserve,
- Park- und Flächenkonzept,
- Missionseditor-Namen,
- bisherige DCS-Tests,
- Fehlerursachen und Korrekturen,
- aktuellen Abschlussauftrag.

Bei Widersprüchen mit älteren allgemeinen Planungsständen gilt für Jalalabad dieses Dokument zusammen mit:

```text
mission/tests/jalalabad-air-operations/README.md
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
```

Der projektweite Build-, Übertragungs- und Testworkflow steht in:

```text
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

## 2. Technische Ausgangsbasis

### 2.1 Testmission

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
```

Karte und Missionszeitraum:

```text
DCS: Afghanistan
2. Mai 2011
```

Die Ausgangsmission lädt bereits MOOSE und ein bestehendes TM02W2F-Testbundle. Jalalabad AirOps bleibt als getrennt gebautes Bundle erhalten.

### 2.2 MOOSE-Basis

```text
MOOSE Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Build: 2026-06-14T16:11:05+02:00
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Die MOOSE-Datei darf während der Testreihe nicht stillschweigend ausgetauscht werden.

### 2.3 Repository

```text
Branch: feature/jalalabad-air-operations-diagnostics
Draft-PR: #18
Builder: tools/build-jalalabad-air-operations-bundle.ps1
Bundle: mission/tests/jalalabad-air-operations/dist/OMW_AirOps_Jalalabad.lua
Builder-Version: JBAD-AIR-OPS-COMPLETE-2
```

## 3. Historische und bildliche Evidenz

### 3.1 Task Force Shooter

Zeitgenössische Berichte beschreiben Task Force Shooter in Jalalabad / FOB Fenty als multi-funktionalen Heeresfliegerverband mit:

- OH-58D,
- AH-64D,
- UH-60,
- CH-47.

Die frühere Planung mit ausschließlich OH-58D, AH-64D und UH-60 war deshalb unvollständig.

### 3.2 Satellitenaufnahme 2011

Auf der gemeinsam ausgewerteten Momentaufnahme wurden mindestens gezählt:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

Die Zuordnung einzelner AH-64 und UH-60 ist wegen Auflösung, Schattenwurf und ähnlicher Silhouetten teilweise unsicher. Der Gesamtbefund belegt jedoch klar eine gemischte Ramp-Belegung und ein substantielles CH-47-Kontingent.

Die Aufnahme zeigt nur einen Zeitpunkt. Weitere Flugzeuge können:

- im Einsatz,
- in Wartung,
- in Hallen,
- auf nicht dargestellten Dispersal-Flächen,
- oder vorübergehend an anderen Standorten gewesen sein.

Mi-8 und UH-1 werden als beobachtete externe oder transiente Luftfahrzeuge festgehalten. Sie werden derzeit nicht dem US-Task-Force-Shooter-Bestand zugerechnet.

## 4. Verbindlicher logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

Gesamt:

```text
48 Luftfahrzeuge
```

Diese 48 Luftfahrzeuge müssen und dürfen nicht gleichzeitig physisch auf der DCS-Ramp dargestellt werden.

## 5. Vier getrennte Darstellungsebenen

### 5.1 Logischer Bestand

Der CampaignState beziehungsweise der MOOSE-SQUADRON-Bestand ist die autoritative Anzahl noch vorhandener Luftfahrzeuge.

### 5.2 Aktive Luftfahrzeuge

Spieler- und KI-Luftfahrzeuge, die aktuell gespawnt oder für einen Einsatz reserviert sind.

### 5.3 Sichtbare Statics

Ein begrenzter visueller Ausschnitt der inaktiven Bestandsmaschinen.

### 5.4 Virtuelle Reserve

Noch vorhandene Maschinen, die nicht sichtbar auf der Ramp stehen. Sie gelten beispielsweise als:

- in Hallen,
- in Wartung,
- auf nicht modellierten Abstellflächen,
- oder als nicht sichtbarer Bereitschaftsbestand.

## 6. Verlust- und Nachrückregel

Ein endgültiger Verlust reduziert den logischen Gesamtbestand dauerhaft:

```text
verbleibender Bestand
= Ausgangsbestand
- endgültig verlorene Spielerflugzeuge
- endgültig verlorene KI-Flugzeuge
- zerstörte Bestands-Statics
```

Ein anderes, zuvor virtuelles Reserveflugzeug darf anschließend einen späteren Einsatz übernehmen. Das ist kein automatischer Ersatz von außen, sondern ein anderes bereits vorhandenes Bestandsflugzeug.

Ein während der Mission zerstörtes Static wird nicht unmittelbar an derselben Stelle neu erzeugt. Eine kontrollierte neue Ramp-Verteilung darf erst:

- beim nächsten Missionsstart,
- oder durch einen später ausdrücklich implementierten Ramp-/Wartungszyklus

erfolgen.

Maximal sichtbare Statics je Typ:

```text
min(
  konfigurierte Static-Obergrenze,
  verbleibender Bestand
  - aktive Spieler
  - aktive KI
  - bereits reservierte Einsätze
)
```

## 7. Parkplatz- und Flächenmodell

### 7.1 Festgestellte DCS-Kapazität

Die Diagnose hat für Jalalabad insgesamt 50 MOOSE-/DCS-Parking-Einträge geliefert.

Davon wurden anhand der Karte und der Satellitenaufnahme ungefähr 36 Positionen als für die reale Hubschrauberbelegung vergleichbar oder funktional geeignet identifiziert.

Wichtige Bereiche:

```text
G01-G07   kleiner OH-58D-Bereich
C01-C14   großer Heavy-Lift-/CH-47-Bereich
weitere südliche und westliche Aprons für AH-64D und UH-60
```

DCS-Flächen und reale Satellitenpositionen stimmen nicht 1:1 überein. Deshalb sind visuelle Anpassungen und frei platzierte Statics zulässig, solange keine operativen Flächen blockiert werden.

### 7.2 Spielerbegrenzung

Die ursprünglich geplanten vier Spielerluftfahrzeuge je Typ sind für Jalalabad aufgehoben.

Verbindlich:

```text
maximal 2 Spielerluftfahrzeuge je nutzbarem Typ in Jalalabad
```

### 7.3 Verpflichtende Kern-Spielergruppen

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02

CLIENT_US_JBAD_CH47_01
CLIENT_US_JBAD_CH47_02
```

Regeln:

- eine DCS-Gruppe je Spielerluftfahrzeug,
- genau eine Einheit je Gruppe,
- Skill `Client`,
- Cold Start,
- Einheitennamen mit Suffix `-1`,
- Client-Slots werden nicht als KI-Templates wiederverwendet.

### 7.4 Optionale UH-60L-Spielergruppen

```text
CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
```

Es gelten nur zwei zulässige Zustände:

```text
0 Gruppen vorhanden
oder
2 Gruppen vorhanden
```

Ein einzelner UH-60L-Slot ist nicht zulässig. Die Kernmission muss ohne installierten Community-Mod lauffähig bleiben.

### 7.5 KI-Template-Positionen

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP          2 Positionen
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP            2 Positionen
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP    1 Position
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP   1 Position
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP       1 Position
```

Gesamt:

```text
7 Template-Startpositionen
```

Alle Templates:

- BLUE / USA,
- Skill `High`,
- Late Activation,
- nicht `Uncontrolled`,
- Cold Start.

### 7.6 Formale Operationskapazität

```text
6 verpflichtende Kern-Spielerpositionen
7 KI-Template-Startpositionen
--------------------------------------
13 Kern-Operationspositionen

+ 2 optionale UH-60L-Spielerpositionen
= 15 Operationspositionen mit Mod
```

Von 36 vergleichbaren Flächen verbleiben damit 23 ohne beziehungsweise 21 mit UH-60L-Mod für sichtbare Ramp-Darstellung und Sicherheitsreserve.

## 8. Sichtbare Static-Obergrenzen

Erster verbindlicher Ramp-Zustand:

```text
7 OH-58D-Statics
4 AH-64D-Statics
4 UH-60A-Statics
5 CH-47-Statics
----------------
20 sichtbare Statics
```

Namen:

```text
STATIC_AIR_US_JBAD_OH58D_01 bis _07
STATIC_AIR_US_JBAD_AH64D_01 bis _04
STATIC_AIR_US_JBAD_UH60_01 bis _04
STATIC_AIR_US_JBAD_CH47_01 bis _05
```

Die Statics:

- gehören zum logischen Bestand,
- sind keine zusätzlichen Luftfahrzeuge,
- dürfen frei auf geeigneten Apronflächen platziert werden,
- dürfen keine Spawn-, Rückkehr- oder Rollposition blockieren,
- benötigen ausreichenden Rotorabstand,
- werden keinem bestimmten Spieler- oder KI-Asset dauerhaft zugeordnet.

Die 20 Statics plus 13 Kern-Operationspositionen ergeben konservativ 33 belegte oder reservierte Flächen. Mit zwei optionalen UH-60L-Slots sind es 35 von 36.

## 9. MOOSE-Struktur

```text
AW_US_JALALABAD
├── SQ_US_JBAD_OH58D_6_6_CAV
├── SQ_US_JBAD_AH64D_B_1_10_AVN
├── SQ_US_JBAD_UH60_UTILITY_MEDEVAC
└── SQ_US_JBAD_CH47_HEAVYLIFT
```

### 9.1 OH-58D

```text
Bestand: 24
Templategröße: 2
MOOSE-Asset-Gruppen: 12
Capability: RECON
```

### 9.2 AH-64D

```text
Bestand: 8
Templategröße: 2
MOOSE-Asset-Gruppen: 4
Capability: CAS
```

### 9.3 UH-60

```text
Bestand: 8
Templategröße: 1
MOOSE-Asset-Gruppen: 8
Capabilities: Transport, Land, Ground Escort
```

Der historische Bestand wird als ein gemeinsames SQUADRON geführt. Lead und Cover sind getrennte Payloadtemplates und keine getrennten Bestände.

MEDEVAC-Regel:

```text
1 Lead + 1 Cover
kein Single-Ship-Fallback
```

### 9.4 CH-47

```text
Bestand: 8
Templategröße: 1
MOOSE-Asset-Gruppen: 8
Capabilities: Troop Transport, Cargo Transport, Land
```

Der interne DCS-Typ des verfügbaren CH-47 wird aus folgendem Template erkannt:

```text
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

Dieser erkannte Typ wird anschließend verbindlich für CH-47-Spielergruppen und Statics geprüft. Dadurch wird kein unbestätigter interner Typname fest in den Validator geschrieben.

## 10. Funktionszonen

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_STATIC_CH47
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_CH47_READY
ZONE_AIR_US_JBAD_HEAVYLIFT_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

C1-C14 dient als bevorzugter CH-47-/Heavy-Lift-Bereich. Die genaue Verteilung der fünf CH-47-Statics, zwei CH-47-Spielerpositionen sowie KI-/Rückkehrflächen wird visuell im Missionseditor festgelegt.

## 11. Aktivitätsgrenzen

```text
maximale Spieler-Luftfahrzeuge je Typ und Basis: 2
maximale gleichzeitig aktive KI-Luftfahrzeuge je Typ und Basis: 4
maximale parallele Unterstützungsmissionen: 2
maximale Luftfahrzeuge je Unterstützungsmission: 2
maximale gleichzeitig aktive Unterstützungs-Luftfahrzeuge: 4
```

Diese Grenzen sind von der logischen SQUADRON-Größe zu unterscheiden. Ein SQUADRON kann beispielsweise acht CH-47 besitzen, obwohl höchstens vier gleichzeitig als KI aktiv werden dürfen.

## 12. Warehouse und Airbase

Bestätigt:

```text
MOOSE-Airbase: Jalalabad
Airbase-ID: 19
Parking-Einträge: 50
Warehouse-Anker: WH_AIR_US_JALALABAD
Koalition: BLUE
Land: USA
DCS-Warehouse verfügbar: ja
MOOSE-Storage verfügbar: ja
```

Der AIRWING wird erzeugt durch:

```lua
AIRWING:New("WH_AIR_US_JALALABAD", "AW_US_JALALABAD")
```

und explizit Jalalabad zugeordnet.

## 13. Build-Reihenfolge

```text
01-jalalabad-bootstrap.lua
02-dump-airbase-parking.lua
03-probe-warehouse-anchor.lua
04-dump-aircraft-types.lua
05-validate-mission-templates.lua
06-construct-oh58d-squadron.lua
07-construct-ah64d-squadron.lua
08-construct-uh60-squadron.lua
09-construct-ch47-squadron.lua
09-finalize-jalalabad-node.lua
```

Der doppelte numerische Präfix `09` ist technisch unschädlich, da die Reihenfolge ausdrücklich im PowerShell-Builder festgelegt ist. Bei einer späteren Bereinigung darf der Dateiname geändert werden, aber niemals ohne gleichzeitige Builder-Anpassung.

## 14. Chronologische Test- und Fehlerhistorie

### 14.1 Lokaler Branchwechsel zunächst blockiert

Ausgangszustand:

```text
aktueller Branch: feature/tm02w2f-red-initial-network-fill
lokal geändert: mission/tests/tm02-red-relay/dist/TM02A.lua
weitere nicht verfolgte dist-Dateien vorhanden
```

Folge:

- Wechsel auf den Jalalabad-Branch wurde zunächst durch die verfolgte lokale Änderung verhindert.
- Ein später ausgeführtes `git pull --ff-only` aktualisierte versehentlich den weiterhin aktiven TM02-Branch.
- Der Jalalabad-Builder war dort nicht vorhanden.

Korrektur:

```powershell
git stash push -m "Preserve local TM02A bundle before Jalalabad AirOps switch" -- mission/tests/tm02-red-relay/dist/TM02A.lua

git switch --track origin/feature/jalalabad-air-operations-diagnostics
```

Erkenntnis:

Ein erfolgreicher Pull bedeutet nicht, dass der richtige Branch aktiv ist. Vor jedem Build werden `git branch --show-current` und `git rev-parse HEAD` geprüft.

### 14.2 Erster reproduzierbarer Build

Bestätigter Stand:

```text
Commit: 69c037beb94bc38befb3eff78021e42da2f51d5c
Bundlegröße: 9489 Bytes
SHA-256: 7B754CD8F964A868B65B95C62B01C5C1891ABF01160EBC72F5D20E0D3995036A
```

Builder-Ausgabe und unabhängiges `Get-FileHash` stimmten überein.

### 14.3 Erster DCS-Diagnoselauf: PARTIAL

Erfolgreich:

- Jalalabad erkannt,
- Airbase-ID 19,
- 50 Parking-Einträge ausgelesen,
- Parking-Typen und freie Positionen protokolliert,
- fehlende Gruppen, Statics und Zonen erkannt.

Fehler:

```text
STATIC not found for: WH_AIR_US_JALALABAD
Error in timer function
```

Ursache:

`STATIC:FindByName(name)` wirft in der verwendeten MOOSE-Version bei einem fehlenden Static standardmäßig einen Fehler.

Betroffen:

```text
01-jalalabad-bootstrap.lua
03-probe-warehouse-anchor.lua
05-validate-mission-templates.lua
```

Korrektur:

```lua
STATIC:FindByName(name, false)
```

Ergebnisbewertung:

```text
PARTIAL – Parking- und Airbase-Diagnose gültig; Warehouse-/Bootstrap-Pfade mussten erneut getestet werden.
```

### 14.4 Retest ohne Warehouse-Anker: PASS

Bestätigt:

```text
STATIC found=false
UNIT found=false
Airbase found=true name=Jalalabad
DCS warehouse verfügbar
MOOSE storage verfügbar
WAITING: Warehouse anchor missing
```

Keine Timerfehler mehr.

### 14.5 Erster Warehouse-Anker-Lauf: FAIL durch nicht gespeicherten Namen

Das statische Objekt war sichtbar platziert, aber der Einheitenname `WH_AIR_US_JALALABAD` war im Missionseditor nicht gespeichert worden.

Log:

```text
STATIC found=false
WAREHOUSE_ANCHOR MISSING
WAITING: Warehouse anchor missing
```

Ursache:

Missionseditor-Benennung beziehungsweise Speichern, kein Lua-Fehler.

Korrektur:

- Einheitenname erneut setzen,
- Mission ausdrücklich speichern,
- Test wiederholen.

Erkenntnis:

Bei einem sichtbaren, aber nicht gefundenen ME-Objekt zuerst Gruppen-/Einheitenname und gespeicherte `.miz` prüfen.

### 14.6 Warehouse-Anker und AIRWING-Konstruktion: PASS

Bestätigt:

```text
STATIC found=true
coalition=Blue
country=USA
DCS warehouse call successful=true available=true
MOOSE storage call successful=true available=true
WAREHOUSE_ANCHOR OK WH_AIR_US_JALALABAD
AIRWING constructed and explicitly linked
```

Das AIRWING wurde in dieser Stufe bewusst nicht gestartet.

### 14.7 OH-58D-SQUADRON: PASS

Bestätigt:

```text
Template: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
DCS-Typ: OH58D
Templategröße: 2
logischer Bestand: 24
Asset-Gruppen: 12
Capability: RECON
AIRWING-Verknüpfung: erfolgreich
```

Das AIRWING blieb ungestartet; keine spontanen Flugzeugspawns.

### 14.8 AH-64D-SQUADRON: PASS

Bestätigt:

```text
Template: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
DCS-Typ: AH-64D_BLK_II
Templategröße: 2
logischer Bestand: 8
Asset-Gruppen: 4
Capability: CAS
AIRWING-Verknüpfung: erfolgreich
```

### 14.9 Unbesetzte Client-Slots falsch über Runtime-GROUP geplant

Problem:

Unbesetzte `Client`-Gruppen sind nicht zuverlässig als aktive MOOSE-`GROUP` verfügbar.

Korrektur:

Client-Slots und Late-Activation-Templates werden über:

```lua
_DATABASE.Templates.Groups
```

validiert.

### 14.10 Zu frühe Vollständigkeitserklärung 24/8/6

Fehlerhafte Annahme:

```text
24 OH-58D / 8 AH-64D / 6 UH-60 = vollständiger Jalalabad-Knoten
```

Die Satellitenbilder und zeitgenössischen Berichte zeigten ein substanzielles CH-47-Kontingent. Zusätzlich waren mindestens sieben UH-60 sichtbar, sodass ein Bestand von nur sechs nicht tragfähig war.

Korrektur:

```text
24 OH-58D / 8 AH-64D / 8 UH-60 / 8 CH-47
```

Der damalige Abschlussgate wurde sofort blockiert, damit kein falsches `RESULT: COMPLETE` ausgegeben werden konnte.

### 14.11 Parkplatzanalyse und Spielerreduktion

Die reale sichtbare Ramp-Belegung ist in DCS nicht 1:1 reproduzierbar. Insbesondere stehen für den realen OH-58D-Bereich mit mehr als zehn Maschinen nur sieben geeignete G-Positionen zur Verfügung.

Entscheidung:

```text
Spielerplätze von 4 auf 2 je Typ reduzieren
Gesamtbestand virtuell führen
sichtbare Statics begrenzen
```

Damit wird nicht versucht, alle 48 Bestandsflugzeuge gleichzeitig darzustellen.

## 15. Was gut funktioniert hat

- Repository-basierter Source-/Builder-Workflow.
- Reproduzierbarer PowerShell-Build mit Commit- und SHA-Ausgabe.
- Erneutes Einbetten des Bundles in die `.miz` konnte über Hash nachgewiesen werden.
- MOOSE erkannte Jalalabad und alle 50 Parking-Einträge zuverlässig.
- DCS-Warehouse und MOOSE-Storage sind am Flugplatz verfügbar.
- Benannter Warehouse-Anker funktioniert als AIRWING-Anker.
- AIRWING-Konstruktion und explizite Airbase-Zuordnung funktionieren.
- OH-58D- und AH-64D-SQUADRON-Konstruktion funktionieren.
- MOOSE-Asset-Gruppenzählung wurde korrekt von Luftfahrzeuganzahl und Templategröße abgeleitet.
- Fehlende Objekte werden nach der `STATIC:FindByName(..., false)`-Korrektur kontrolliert gemeldet.
- Browser-Upload der `dcs.log` reicht für die meisten PASS/FAIL-Prüfungen.

## 16. Was nicht gut funktioniert hat

- Zu viele sehr kleine Einzeltests führten zu unnötigem Zeitaufwand.
- Der aktive Branch wurde anfangs nicht vor dem Pull ausreichend abgesichert.
- Eine alte lokale generierte Datei blockierte den Branchwechsel.
- Fehlende Statics verursachten aufgrund eines falschen MOOSE-Aufrufs Timerfehler.
- Ein Missionseditor-Name wurde nicht gespeichert und erzeugte einen vermeintlichen Codefehler.
- Client-Slots sollten zunächst über die falsche Runtime-Abstraktion geprüft werden.
- Die historische ORBAT wurde zu früh als vollständig erklärt.
- Satellitenbild und Parkflächen wurden zu spät in die Bestandsplanung einbezogen.
- Sichtbarer Ramp-Bestand und logischer Gesamtbestand wurden zunächst vermischt.
- Vier Spielerplätze je Typ waren für Jalalabad angesichts der real nutzbaren Flächen zu hoch.

## 17. Gegenmaßnahmen für das gesamte Projekt

- Einheitlicher Workflow in `docs/22-test-mission-build-transfer-and-validation-workflow.md`.
- Vor jedem Build: Branch, Status und Commit prüfen.
- Nach jedem Build: Bundlehash prüfen und Datei im ME neu auswählen.
- Ergebnisse standardmäßig nur über `dcs.log`; `.miz` nur bei klar definiertem Bedarf.
- Jeder Fehlerlauf bleibt als eigener Bericht erhalten.
- Keine Vollständigkeitserklärung ohne historische Plausibilitätsprüfung und DCS-Gesamttest.
- Bestands-, Aktiv-, Static- und Reserveebene getrennt modellieren.
- Größere Knoten in einem vollständigen Arbeitsgang umsetzen, nachdem technische Grundannahmen isoliert bestätigt wurden.

## 18. Aktueller Implementierungsstand

### In DCS bestätigt

- Airbase und Parking,
- Warehouse-Anker,
- DCS-Warehouse und MOOSE-Storage,
- AIRWING-Konstruktion,
- OH-58D-SQUADRON,
- AH-64D-SQUADRON.

### Im Repository umgesetzt, aber noch nicht im abschließenden DCS-Lauf bestätigt

- UH-60-Bestand auf acht angehoben,
- CH-47-Templateerkennung,
- CH-47-SQUADRON mit acht Single-Ship-Asset-Gruppen,
- CH-47-Heavy-Lift-Payload,
- zwei Spielerplätze je Typ,
- sechs verpflichtende Kern-Spielergruppen,
- 20 Static-Obergrenzen,
- elf Funktionszonen,
- korrigierter Finalizer,
- virtuelle Reserve und Parkplatzmodell,
- Builder-Version `JBAD-AIR-OPS-COMPLETE-2`.

### Noch offen

- Missionseditor-Platzierung des CH-47-Templates,
- tatsächlicher interner DCS-Typ des gewählten CH-47,
- zwei CH-47-Client-Slots,
- korrigierte zwei OH-58D- und zwei AH-64D-Client-Slots,
- zwei UH-60A-Templates,
- 20 Statics,
- elf Zonen,
- visuelle C1-C14- und Ramp-Aufteilung,
- vollständiger DCS-Abschlusslauf,
- späterer persistenter Static-/Ramp-Manager für Verluste und Neustarts.

## 19. Aktueller Build- und Übertragungsablauf

### Repository

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git pull --ff-only
git rev-parse HEAD
```

Der erwartete Commit wird vor dem nächsten Test separat genannt und muss exakt übereinstimmen.

### Build

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

### Hash prüfen

```powershell
Get-FileHash `
  .\mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua `
  -Algorithm SHA256
```

### Mission aktualisieren

Im Missionseditor:

```text
DO SCRIPT FILE -> OMW_AirOps_Jalalabad.lua
```

öffnen, die neue Datei erneut auswählen und Mission speichern.

## 20. Aktueller vollständiger Missionseditor-Auftrag

Die ausführbare Liste steht in:

```text
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
```

Sie verlangt zusammengefasst:

```text
5 KI-Templates
6 verpflichtende Kern-Spielergruppen
0 oder 2 optionale UH-60L-Spielergruppen
20 sichtbare Statics
11 Funktionszonen
1 Warehouse-Anker
4 MOOSE-SQUADRONs
```

## 21. Abschlusskriterium

Jalalabad gilt erst als abgeschlossen, wenn der DCS-Gesamttest meldet:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: COMPLETE. Jalalabad AirOps node OPERATIONAL; AIRWING started; COMMANDER linked; missionsQueued=0; spontaneousSpawns=0.
```

und zusätzlich gilt:

- keine relevanten Lua-/Timerfehler,
- alle verpflichtenden ME-Objekte validiert,
- keine spontanen OMW-Luftfahrzeugspawns ohne Auftrag,
- Spieler-, KI-, Static- und Rollflächen visuell kollisionsfrei,
- CH-47-Typ korrekt erkannt,
- Ergebnisbericht im Repository,
- PR bleibt bis zur ausdrücklichen Freigabe Draft.
