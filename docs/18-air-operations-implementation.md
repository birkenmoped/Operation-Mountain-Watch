# 18 – Luftoperations- und ORBAT-Umsetzung

## Zweck

Dieses Dokument legt die verbindlichen technischen und missionsgestalterischen Entscheidungen für die Umsetzung der US-Luftstreitkräfte-ORBAT in **Operation Mountain Watch** fest.

Die historische und planerische ORBAT steht in [`us-air-orbat-2010-2011.md`](us-air-orbat-2010-2011.md). Dieses Dokument beschreibt dagegen, **wie** die dort genannten Bestände in DCS und MOOSE dargestellt, begrenzt und verwaltet werden.

Offene Ablösungen und Überschneidungen werden nicht pauschal entschieden. Für jeden einzelnen Fall werden die historisch plausiblen Varianten mit ihren Auswirkungen vorgelegt und anschließend durch den Missionsdesigner verbindlich ausgewählt.

---

## 1. Verbindliche MOOSE-Architektur

Militärische Luftoperationen werden grundsätzlich mit MOOSE OPS umgesetzt:

- `AIRWING` als lokaler Ressourcen- und Einsatzmanager eines Flugplatzes oder Luftfahrtknotens,
- `SQUADRON` als typgebundener Bestand mit Templates, Payloads und Fähigkeiten,
- `AUFTRAG` für CAS, Aufklärung, Eskorte, Strike, MEDEVAC und vergleichbare militärische Einsätze,
- `COMMANDER` für die Verteilung bereits erzeugter Aufträge an geeignete AIRWINGs,
- `WAREHOUSE` beziehungsweise die Warehouse-Funktion des AIRWINGs für die physische MOOSE-Verwaltung.

`CHIEF` wird zunächst nicht eingesetzt, weil Zielauswahl, Kampagnenlogik und Auftragserzeugung durch die eigenen Module `CampaignState`, `MissionGenerator`, `RedDirector` und die zugehörigen Adapter kontrolliert werden.

`CampaignState` bleibt die alleinige autoritative Quelle für strategische Bestände, Verluste und Zustände. MOOSE-Warehouses, AIRWINGs, DCS-Warehouses, Statics und aktive Gruppen bilden diesen Zustand nur ab.

---

## 2. AIRWING- und SQUADRON-Struktur

Grundsätzlich wird ein AIRWING pro physischem Flugplatz oder dauerhaftem Luftfahrtknoten vorgesehen, zum Beispiel:

```text
AW_US_BAGRAM
AW_US_JALALABAD
AW_US_KHOST
AW_US_KANDAHAR
AW_US_TARINKOT
AW_US_SHINDAND
AW_USMC_BASTION
AW_USMC_DWYER
```

Historisch gemischte Verbände werden technisch in typreine SQUADRONs aufgeteilt. Ein `SQUADRON` enthält nur einen Luftfahrzeugtyp.

Beispiel Jalalabad:

```text
AW_US_JALALABAD
├── SQ_6_6_CAV_OH58D
├── SQ_B_1_10_AVN_AH64D
└── SQ_JBAD_UTILITY_UH60
```

Bei `SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)` zählt `Ngroups` die Zahl der Gruppen und nicht die Zahl der einzelnen Luftfahrzeuge. Die ORBAT-Zahlen müssen deshalb immer anhand der Template-Gruppengröße umgerechnet werden.

Beispiel:

```text
8 KI-OH-58D
2 Luftfahrzeuge je Template-Gruppe
= 4 MOOSE-Gruppen
```

---

## 3. Spieler- und KI-Grenzen

### 3.1 Spielerplätze

Pro Luftfahrzeugtyp und Flugplatz werden höchstens vier Spieler-Luftfahrzeuge vorgesehen:

```lua
maxPlayerAircraftPerTypeAndBase = 4
```

Diese Begrenzung gilt für Luftfahrzeuge, nicht für Sitzplätze. Ein Multicrew-Luftfahrzeug kann mehrere Besatzungsplätze erzeugen, ohne den Luftfahrzeugbestand mehrfach zu belasten.

Die hohe theoretische Gesamtzahl verfügbarer Slots über alle Flugplätze dient der Auswahl. Erwartet werden auf normalen Servern selten mehr als ungefähr zehn gleichzeitig aktive Spieler.

### 3.2 Lokale KI-Sicherheitsgrenze

Pro Luftfahrzeugtyp und Flugplatz dürfen höchstens vier KI-Luftfahrzeuge gleichzeitig aktiv sein:

```lua
maxAIAircraftPerTypeAndBase = 4
```

Diese Grenze ist eine technische Obergrenze, nicht die normale Einsatzstärke.

### 3.3 Globale operative KI-Grenze

Missionsweit gelten für angeforderte oder automatisch erzeugte Unterstützungsflüge:

```lua
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Damit sind gleichzeitig höchstens zwei Unterstützungsmissionen mit jeweils maximal zwei Luftfahrzeugen aktiv.

Beispiele:

- ein AH-64D-Two-Ship für CAS und ein OH-58D-Two-Ship für Aufklärung,
- ein UH-60-MEDEVAC-Paket und ein AH-64D-Two-Ship,
- zwei einzelne Transportaufträge mit jeweils höchstens zwei Luftfahrzeugen.

Unter diese globale Grenze fallen zunächst:

- CAS,
- Armed Reconnaissance,
- Aufklärung,
- Eskorte,
- Luft-QRF,
- MEDEVAC,
- CSAR-Unterstützung,
- angeforderte taktische Transporte.

Spielerflugzeuge und rein atmosphärischer RAT-Verkehr werden nicht auf diese Grenze angerechnet.

---

## 4. MEDEVAC als verbindliches Two-Ship-Paket

UH-60-MEDEVAC wird grundsätzlich als Zweierteam eingesetzt:

1. ein Lead-Hubschrauber landet und übernimmt Verwundete oder Personal,
2. ein Cover-Hubschrauber bleibt in der Luft und stellt während der Landung Feuerunterstützung und Sicherung bereit.

Ein MEDEVAC-Auftrag reserviert daher immer zwei UH-60.

```lua
medevac = {
  packageSize = 2,
  leadAircraft = 1,
  coverAircraft = 1,
  allowSingleShip = false
}
```

Für die KI-Steuerung werden zwei getrennte Ein-Schiff-Templates vorgesehen, damit Lead und Cover unterschiedliche Aufgaben erhalten können:

```text
TPL_AIR_US_<BASE>_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_<BASE>_UH60_MEDEVAC_COVER_1SHIP
```

Beide Hubschrauber stammen aus demselben lokalen Bestand. Die technische Trennung erzeugt keine zusätzlichen Luftfahrzeuge.

Das Verhalten des Cover-Hubschraubers bei Anflug, Orbit, Feindkontakt und Abflug muss in DCS praktisch getestet werden.

---

## 5. Gepoolte Statics

Es wird keine individuelle 1:1-Airframe-Verfolgung eingeführt. Stattdessen gilt ein gepooltes Static-Modell.

Der lokale Bestand wird numerisch geführt. Sichtbare Statics stellen nur einen Teil des momentan inaktiven Bestands dar und werden nicht zusätzlich zum ORBAT-Bestand gezählt.

Beispiel:

```text
OH-58D Gesamtbestand:          24
Spieler aktiv:                  2
KI aktiv:                       4
dauerhaft verloren:             1
verbleibender Bestand:         23
inaktiv verfügbar:             17
davon als Statics sichtbar:    10
unsichtbare Reserve:            7
```

Grundregel:

```text
maximal sichtbare Statics
= verbleibender Bestand
- aktive Spieler-Luftfahrzeuge
- aktive KI-Luftfahrzeuge
```

Zusätzlich erhält jeder Typ eine missionsgestalterisch festgelegte Obergrenze für sichtbare Statics, damit nicht der gesamte Restbestand auf der Ramp dargestellt werden muss.

Die Statics sollen möglichst auf separaten Abstellflächen stehen und keine für Spieler oder KI benötigten Start-, Roll- oder Parkpositionen blockieren.

### Zerstörung eines Statics

Wird ein statisch dargestelltes Luftfahrzeug zerstört, zählt dies als realer Verlust des lokalen ORBAT-Bestands:

```text
Static zerstört
→ lokaler Bestand minus 1
→ kein automatischer Ersatz
```

Eine individuelle Airframe-ID ist dafür nicht erforderlich.

---

## 6. Verlust- und Ersatzmodell

Die erste Ausbaustufe verwendet endgültige Verluste:

```lua
lossPolicy = "PERMANENT"
replacementPolicy = "NONE"
```

Bestätigte Verluste reduzieren den lokalen Bestand dauerhaft. Es gibt zunächst:

- keinen automatischen Respawn,
- keine zeitbasierte Ersatzmaschine,
- keine automatische Wiederauffüllung beim Missionsneustart.

Grenzfälle wie Disconnect, beschädigte Landung, Notlandung, Ejection, aufgegebene Maschine und Taxi-Fehler werden später separat als eigene Entscheidungsfälle festgelegt.

---

## 7. Historische Detachments

Ein eigener `DetachmentManager` wird zunächst nicht entwickelt.

Für den Betrieb zählt nur die lokal festgelegte Anzahl eines Luftfahrzeugtyps am jeweiligen Flugplatz oder FOB. Historische Angaben wie „Detachment von Task Force Destiny“ bleiben Dokumentations- und Herkunftsinformationen, beeinflussen aber nicht automatisch die Laufzeitlogik.

Beispiel:

```lua
{
  id = "TF_DESTINY_TARINKOT_CH47",
  base = "TARINKOT",
  aircraftType = "CH-47F",
  count = 2,
  historicalParent = "TF_DESTINY"
}
```

Die Bestandszahlen müssen bei der ORBAT-Festlegung einmalig so bereinigt werden, dass Flugzeuge an Außenstellen nicht zusätzlich am Stammflugplatz gezählt werden.

Dynamische Verlegungen zwischen Flugplätzen sind zunächst nicht Bestandteil der Implementierung.

---

## 8. Warehouse-Regel

Ein AIRWING benötigt einen von MOOSE verwendbaren Warehouse-Anker als benanntes `STATIC`- oder `UNIT`-Objekt.

Viele DCS-Afghanistan-Flugplätze und fest zur Karte gehörende FOBs besitzen sichtbare Warehouse- und Tanklagerinfrastruktur. Ob diese karteneigenen Objekte direkt von MOOSE als verwendbarer Warehouse-Anker angesprochen werden können, muss in einer Testmission geprüft werden.

### Ergebnisfall A

Das vorhandene Kartenobjekt ist benannt und für `AIRWING:New()` beziehungsweise `WAREHOUSE:New()` verwendbar.

Dann wird kein zusätzliches Warehouse platziert.

### Ergebnisfall B

Das vorhandene Gebäude ist nur Kartenszenerie oder DCS-interne Infrastruktur und kann nicht als MOOSE-`STATIC` oder `UNIT` referenziert werden.

Dann wird genau ein benanntes technisches Warehouse-Static pro AIRWING in einem vorhandenen Lagerbereich platziert.

Beispiel:

```text
WH_AIR_US_BAGRAM
WH_AIR_US_JALALABAD
WH_AIR_US_KHOST
WH_AIR_US_KANDAHAR
```

Der zugehörige DCS-Airbase-Bezug wird nach Möglichkeit explizit gesetzt und nicht allein über Entfernungserkennung bestimmt.

### Template-FOBs

Für selbst erstellte Template-FOBs gilt:

- logistischer FOB: benanntes Warehouse-Static und Übergabezonen erforderlich,
- FOB mit dauerhaft stationierten KI-Hubschraubern: zusätzlich FARP/Helipad, geeignete Spawn-/Parkmöglichkeiten und eigenes AIRWING,
- reines Missions- oder Landezonen-Ziel: kein eigenes AIRWING erforderlich.

Ein Tanklager ist keine technische MOOSE-Voraussetzung. Es wird gesetzt, wenn Treibstoffinfrastruktur sichtbar, zerstörbar und für den Kampagnenzustand relevant sein soll.

---

## 9. Community- und Risikomodule

### UH-60L

Der UH-60L Community Mod wird als geplanter Spieler-Mod berücksichtigt:

```lua
availability = "COMMUNITY_PLAYER_MOD"
requiredForCoreMission = false
```

Die Kernmission soll möglichst auch ohne installierten UH-60L-Mod geladen und genutzt werden können. Multicrew, interne Fracht, Außenlast, Truppentransport und Multiplayer-Verhalten werden versionsbezogen getestet.

### USMC-Luftfahrzeuge

- AH-1W: als KI-Luftfahrzeug einplanen, sofern der konkrete DCS-Typ in der verwendeten Version bestätigt ist.
- CH-53E: als KI-Luftfahrzeug einplanen, sofern Typname, Parkverhalten und AIRWING-Nutzung bestätigt sind.
- UH-1Y: derzeit kein bestätigtes natives DCS-Kernasset; spätere Einzelentscheidung erforderlich.
- MV-22B: derzeit keine verpflichtende Mod-Abhängigkeit festlegen; spätere Einzelentscheidung erforderlich.

### F-15E und AV-8B

Beide Muster bleiben historisch in der ORBAT relevant, gelten aber wegen der unsicheren langfristigen Pflege der ehemaligen RAZBAM-Module als technische Risikomodule.

```lua
availability = "THIRD_PARTY_AT_RISK"
```

Die Kampagnenlogik darf nicht von ihrer dauerhaften Verfügbarkeit abhängen. Spieler-Slots und physische Darstellung müssen deaktivierbar bleiben, ohne die gesamte ORBAT- oder CampaignState-Struktur umzubauen.

---

## 10. RAT ausschließlich als atmosphärischer Verkehr

RAT wird nur zurückhaltend für nicht persistente Hintergrundflüge verwendet.

```lua
ratTraffic = {
  atmosphericOnly = true,
  persistent = false,
  affectsInventory = false,
  transfersResources = false,
  continuousTraffic = false
}
```

RAT-Flüge verändern weder lokale Luftfahrzeugbestände noch strategische Ressourcen.

### Vorgesehene Größenordnung

- ein bis zwei C-130-Hintergrundflüge pro Kampagnentag,
- null bis ein C-17-Flug pro Kampagnentag von oder zu einem externen Kartenrand-Spawn,
- null bis zwei gelegentliche CH-47-Verbindungs- oder Repositionierungsflüge pro Kampagnentag,
- maximal ein gleichzeitig aktiver Fixed-Wing-Hintergrundflug,
- maximal ein gleichzeitig aktiver Rotary-Wing-Hintergrundflug.

Es gibt keinen permanenten oder endlosen Luftverkehr.

Plausible Verbindungen sind beispielsweise:

- Bagram ↔ Jalalabad,
- Bagram ↔ Khost,
- Bagram ↔ Kandahar,
- Kandahar ↔ Tarinkot,
- Kandahar ↔ Shindand,
- Bastion ↔ Dwyer.

C-17-Verkehr wird als externer strategischer Verkehr zwischen Kartenrand und großen Flugplätzen wie Bagram oder Kandahar dargestellt.

Tatsächliche Logistikflüge, die Kampagnenressourcen transportieren, verwenden nicht RAT, sondern AIRWING, Transportauftrag und das gemeinsame Manifestmodell.

---

## 11. Entscheidungsverfahren für Ablösungen und Überschneidungen

Für jede historische Ablösung oder zeitliche Überschneidung wird einzeln entschieden.

Ablauf:

1. belegte oder plausible Einheiten und Zeiträume werden aufgelistet,
2. die Varianten und Auswirkungen auf Spieler-Slots, KI, Statics und Templates werden beschrieben,
3. der Missionsdesigner wählt die für die Kampagne gültige Einheit,
4. die nicht gewählte Einheit wird aus der aktiven Missions-ORBAT entfernt,
5. die Entscheidung wird mit Begründung dokumentiert.

Es wird zunächst kein automatisches fortlaufendes Kampagnendatum mit dynamischem Staffelwechsel vorausgesetzt.

Bekannte Entscheidungsfälle sind mindestens:

- Bagram: 494th EFS oder 336th EFS,
- Jalalabad: Task Force Lighthorse oder Task Force Six Shooters,
- Kandahar: 81st EFS oder 75th EFS,
- Camp Bastion: HMLA-369 oder HMLA-169,
- Camp Bastion: VMM-365 oder VMM-264,
- Camp Bastion: CH-53D-/CH-53E-Verbände und mögliche Überschneidung.

---

## 12. Verbindlicher aktueller Konfigurationsstand

```lua
AirOperationsPolicy = {
  player = {
    maxAircraftPerTypeAndBase = 4
  },

  ai = {
    maxAircraftPerTypeAndBase = 4,
    maxConcurrentSupportMissions = 2,
    maxAircraftPerMission = 2,
    maxConcurrentSupportAircraft = 4
  },

  medevac = {
    packageSize = 2,
    leadAircraft = 1,
    coverAircraft = 1,
    allowSingleShip = false
  },

  statics = {
    mode = "POOLED",
    destroyedStaticCountsAsLoss = true
  },

  losses = {
    permanent = true,
    automaticReplacement = false
  },

  rat = {
    atmosphericOnly = true,
    persistent = false,
    affectsResources = false,
    continuousTraffic = false,
    maxConcurrentFixedWing = 1,
    maxConcurrentRotaryWing = 1
  }
}
```

---

## 13. Verantwortungsaufteilung

### Missionsdesigner

Der Missionsdesigner bereitet in DCS vor:

- endgültige Auswahl der bei Ablösungen verwendeten Verbände,
- Spieler-Slots,
- Late-Activation-AI-Templates,
- Payload-Templates,
- Warehouse-Anker,
- Park- und Static-Abstellbereiche,
- Landezonen, Lade-/Entladezonen und Missionszonen,
- FARP-/Helipad-Infrastruktur bei Template-FOBs,
- praktische Tests von Rollwegen, Parkplätzen und Spawnverhalten.

### Skript- und Datenvorbereitung

Die Skriptseite liefert:

- bereinigte ORBAT-Datensätze pro Flugplatz,
- verbindliche Namen für AIRWINGs, SQUADRONs, Templates, Slots und Zonen,
- Umrechnung der Luftfahrzeugbestände in MOOSE-Gruppenanzahlen,
- Capability- und Payload-Matrix,
- AIRWING-/SQUADRON-/AUFTRAG-Konfiguration,
- globale KI-Einsatzbegrenzung,
- MEDEVAC-Paketlogik,
- gepoolte Static-Verwaltung,
- permanente Verlustbuchung,
- RAT-Zeit- und Streckenplanung,
- Diagnose-Skripte für DCS-Typnamen, Parkpositionen und Warehouse-Kompatibilität,
- Validierungs- und Testprotokolle.

---

## 14. Unmittelbar nächster Schritt

Vor dem Aufbau der Missionseditor-Templates werden alle bekannten Ablösungen und Überschneidungen einzeln entschieden. Danach wird eine endgültige Arbeitsliste je Flugplatz erstellt, die exakt vorgibt:

- welche Einheit bestehen bleibt,
- welcher Luftfahrzeugtyp verwendet wird,
- wie hoch der lokale ORBAT-Bestand ist,
- wie viele Spieler-Slots anzulegen sind,
- welche AI-Templates benötigt werden,
- welche Static-Anzahl vorbereitet werden soll,
- welche Warehouse-, Park- und Zoneninformationen erfasst werden müssen.
