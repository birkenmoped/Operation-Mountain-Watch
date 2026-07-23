# 20 – Missionseditor-Arbeitsliste für die Luft-ORBAT

## 1. Zweck und Autorität

Dieses Dokument trennt verbindlich:

1. Arbeiten des Missionsdesigners im DCS Mission Editor,
2. Aufgaben der Entwicklung und MOOSE-Integration,
3. basisbezogene Manifest- und Testanforderungen,
4. den Übergang vom Prototyp auf weitere Flugplätze.

Verbindliche Bezugsdokumente:

```text
docs/18-air-operations-implementation.md
docs/19-active-air-orbat-decisions.md
docs/22-test-mission-build-transfer-and-validation-workflow.md
```

Für jeden Flugplatz ist zusätzlich dessen eigenes Air Operations Manifest autoritativ. Für Jalalabad gilt:

```text
docs/21-jalalabad-air-operations-manifest.md
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
```

Ein basisbezogenes Manifest darf strengere Limits als die globalen technischen Obergrenzen festlegen. Ältere allgemeine Werte werden dadurch überschrieben.

---

## 2. Umsetzungsreihenfolge

Verbindliche Reihenfolge:

1. Jalalabad Airfield / FOB Fenty als vertikaler Prototyp,
2. Warehouse-, Parking-, Spieler-, KI-, Static- und Reserve-Mechanik dort vollständig validieren,
3. MEDEVAC-Two-Ship, Heavy Lift und globale KI-Einsatzgrenzen validieren,
4. Persistenz- und Verlustanbindung ergänzen,
5. das bestätigte Schema basisbezogen auf Bagram, Kandahar, Khost, Camp Bastion, Camp Dwyer, Tarinkot und Shindand übertragen,
6. atmosphärischen RAT-Verkehr zuletzt ergänzen.

Es werden keine Namen, Bestände, Templategrößen, Spielerlimits oder Static-Zahlen ungeprüft von Jalalabad auf andere Basen kopiert.

---

## 3. Grundsatz der Aufgabenteilung

### 3.1 Missionsdesigner

Der Missionsdesigner ist verantwortlich für Eigenschaften, die nur im DCS Mission Editor zuverlässig angelegt oder visuell geprüft werden können:

- physische Platzierung,
- Park- und Spawnpositionen,
- Spieler-Slots,
- Late-Activation-Templates,
- Static-Objekte,
- Liveries und sichtbare Markierungen,
- Trigger- und Funktionszonen,
- FARP-, Helipad- und Warehouse-Infrastruktur,
- Rollwege und Abflugrichtungen,
- Rotorabstände und Kollisionen,
- erneute Auswahl gebauter Lua-Dateien in `DO SCRIPT FILE`,
- Speicherung der `.miz`,
- visueller Testlauf.

### 3.2 Entwicklung

Die Entwicklung ist verantwortlich für:

- historische und missionsgestalterische ORBAT-Entscheidungen,
- verbindliche Objekt-, Gruppen- und Einheitennamen,
- CampaignState- und Inventarkonfiguration,
- Template-, Rollen- und Payload-Matrix,
- AIRWING- und SQUADRON-Konfiguration,
- Diagnose- und Validierungsskripte,
- numerische Bestands- und Verlustlogik,
- Trennung von aktivem Bestand, sichtbaren Statics und virtueller Reserve,
- Spieler- und KI-Aktivitätsgrenzen,
- MEDEVAC-Paketsteuerung,
- globale KI-Auftragsbegrenzung,
- Persistenzanbindung,
- Builder und Ergebnisdokumentation.

Der Missionsdesigner soll keine eigenen MOOSE-Strukturen, Bestandsregeln oder Benennungssysteme erfinden müssen.

---

## 4. Vor jeder Missionseditor-Platzierung bereitzustellen

Für jeden Flugplatz wird ein separates Air Operations Manifest erstellt. Es enthält mindestens:

| Bereich | Verbindlicher Inhalt |
|---|---|
| aktive Einheiten | Verband, Typ und logischer Gesamtbestand |
| historische Evidenz | Quellen, Momentaufnahmen und Unsicherheiten |
| DCS-Typ | bestätigter oder gezielt zu ermittelnder interner Typname |
| Darstellung | aktive Assets, sichtbare Statics, virtuelle Reserve |
| Spieler-Slots | genaue Anzahl und vollständige Namen |
| KI-Templates | Anzahl, Gruppengröße, Rolle und Namen |
| MOOSE-Bestand | SQUADRON-Asset-Gruppen und Gruppierung |
| Payloads | Missionsrollen und Template-Zuordnung |
| Statics | sichtbare Obergrenzen und zulässige Flächen |
| Warehouse | technischer Anker und Airbase-Bezug |
| Parking | DCS-Kapazität, reservierte operative Flächen und Sicherheitsreserve |
| Zonen | vollständige Namen und Zwecke |
| Verluste | Abzug, Nachrücken und Ramp-Aktualisierung |
| Testfälle | erwartete Logzeilen und Abnahmekriterien |

Zusätzlich werden bereitgestellt:

```text
Diagnose-/Validierungsquellen unter mission/tests/<TEST>/src
PowerShell-Builder unter tools/
Acceptance-Vorgabe unter mission/tests/<TEST>/expected
Ergebnisberichte unter mission/tests/<TEST>/results
```

Die konkrete MOOSE-Version wird mit Commit und Dateihash festgeschrieben.

---

## 5. Verbindlicher Repository- und Buildablauf

Der vollständige Workflow steht in Dokument 22. Jeder konkrete Arbeitsauftrag nennt Branch, erwarteten Commit, Builder, Bundlepfad, Mission und Laufzeit.

Standard:

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git branch --show-current
git status --short
git fetch origin
git switch <TESTBRANCH>
git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\<BUILDER>.ps1"
```

Danach:

1. Bundlehash prüfen,
2. Lua-Datei im Mission Editor erneut über `DO SCRIPT FILE` auswählen,
3. Mission speichern,
4. Acceptance-Test ausführen,
5. standardmäßig nur die aktuelle `dcs.log` bereitstellen.

Eine `.miz` wird nur bei Einbettungsnachweis, ME-Unklarheiten, einem nicht erklärbaren Fehler oder einem größeren Meilenstein zusätzlich benötigt.

---

## 6. Allgemeine Missionseditor-Regeln

### 6.1 Warehouse und Airbase

- Pro AIRWING genau ein eindeutig benannter Warehouse-Anker.
- Warehouse, Airbase und Koalition werden vor AIRWING-Start validiert.
- Technische Warehouse-Statics dürfen keine Roll-, Lande- oder Parkflächen blockieren.
- Zusätzliche sichtbare Tanks oder Lagerobjekte werden nur gesetzt, wenn sie als Kampagneninfrastruktur benötigt werden.

### 6.2 Spieler-Slots

- grundsätzlich eine Spieler-Maschine je DCS-Gruppe,
- Multicrew-Sitze sind keine zusätzlichen Luftfahrzeuge,
- Client-Slots werden nicht als KI-Templates wiederverwendet,
- lokale Slotzahl richtet sich nach Manifest und Parkkapazität,
- Community-Mod-Slots müssen optional und vollständig deaktivierbar sein,
- unbesetzte Client-Gruppen werden technisch über die Mission-Template-Datenbank validiert.

### 6.3 KI-Templates

- Late Activation,
- eindeutige Gruppen- und Einheitennamen,
- keine `#`-Zeichen,
- Gruppengröße muss zur SQUADRON-Bestandsrechnung passen,
- Template ist technische Vorlage, nicht zusätzlicher Bestand,
- Payload und Rolle werden über AIRWING/SQUADRON registriert.

### 6.4 Statics und virtuelle Reserve

Statics sind Teil des logischen Bestands und kein zusätzlicher Bestand.

Nicht jedes Bestandsflugzeug muss sichtbar sein. Es gelten getrennte Ebenen:

```text
logischer Bestand
aktive Spieler/KI
sichtbare Statics
virtuelle Reserve
```

Statics:

- blockieren keine Spawn-, Rückkehr- oder Rollflächen,
- benötigen ausreichenden Rotor- oder Flügelabstand,
- werden keinem bestimmten Spieler- oder KI-Asset dauerhaft zugeordnet,
- zählen bei Zerstörung als endgültiger Verlust,
- werden während derselben Mission nicht sofort sichtbar ersetzt.

Ein anderes überlebendes Reserveflugzeug darf beim nächsten kontrollierten Ramp-Zyklus einen freien Static-Platz übernehmen.

### 6.5 Zonen

Jede Zone erhält einen eindeutigen Namen und genau einen dokumentierten Hauptzweck. Überschneidungen sind nur zulässig, wenn die physische Fläche tatsächlich mehrere kompatible Funktionen erfüllt.

### 6.6 Kollision und Betrieb

Visuell zu prüfen:

- Rotor- und Flügelabstände,
- Two-Ship-Spawn,
- freie Abflugrichtung,
- KI-Rückkehr,
- Rollwege,
- Spieler-/Template-/Static-Überlagerungen,
- Außenlast- und Frachtflächen,
- Flächenbedarf großer Transporthubschrauber und C-130.

---

## 7. Aktueller Jalalabad-Arbeitsstand

### 7.1 Verbindlicher logischer Bestand

```text
24 OH-58D
 8 AH-64D
 8 UH-60-Familie
 8 CH-47 Heavy Lift
```

### 7.2 Lokale Spielergrenze

```text
2 je nutzbarem Typ
```

Kern:

```text
2 OH-58D
2 AH-64D
2 CH-47
```

Optional:

```text
0 oder 2 UH-60L
```

### 7.3 Templates

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
TPL_AIR_US_JBAD_CH47_HEAVYLIFT_1SHIP
```

### 7.4 Sichtbare Static-Obergrenzen

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47
```

### 7.5 Zonen

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

### 7.6 Parkmodell

```text
50 auslesbare DCS-/MOOSE-Parking-Einträge
ca. 36 für die reale Hubschrauberramp vergleichbare Positionen
13 Kern-Operationspositionen
15 mit optionalen UH-60L-Slots
20 sichtbare Static-Obergrenze
```

Die detaillierte C1-C14-, G1-G7- und Ramp-Zuordnung steht in Dokument 21 und der Jalalabad-Acceptance-Datei.

---

## 8. Nach der Missionseditor-Bearbeitung bereitzustellen

Standardmäßig:

- aktuelle `dcs.log`,
- kurze Beschreibung sichtbarer Kollisionen oder unerwarteter Spawns.

Nur bei Bedarf zusätzlich:

- `.miz`,
- `debrief.log`,
- Screenshots bestimmter Park- oder Static-Bereiche.

Der Testlauf prüft mindestens:

1. Missionsstart ohne relevante Lua-/Timerfehler,
2. Airbase- und Warehouse-Erkennung,
3. vollständige Template- und Objektvalidierung,
4. korrekte SQUADRON-Bestände,
5. Einhaltung lokaler Spieler- und KI-Grenzen,
6. keine spontanen Luftfahrzeugspawns ohne Auftrag,
7. kollisionsfreie Spieler-, KI-, Static- und Rollflächen.

---

## 9. Von der Entwicklung nach dem Missionseditor-Stand umzusetzen

### 9.1 Konfiguration

- basisbezogene ORBAT als Lua-Datenmodell,
- klare Trennung von Bestand, Aktivität, Static und Reserve,
- lokale Spieler- und KI-Grenzen,
- Missions- und Paketgrenzen,
- sichtbare Static-Obergrenzen,
- vollständige Objekt- und Zonenlisten.

### 9.2 MOOSE-Bootstrap

- AIRWING anlegen,
- typreine SQUADRONs anlegen,
- Templates und Payloads registrieren,
- Airbase und Warehouse explizit verbinden,
- AIRWING erst nach vollständigem Validation-Gate starten,
- COMMANDER erst nach AIRWING-Abnahme verknüpfen.

### 9.3 Manager und Adapter

Späterer Produktionsumfang:

- `AirOperationsManager`,
- `AirframePool`,
- `StaticAirframeManager`,
- `PlayerSlotManager`,
- `MedevacPackageCoordinator`,
- CampaignState-/MOOSE-Adapter,
- globale KI-Auftragsreservierung,
- Verlust- und Persistenzanbindung,
- kontrollierte Ramp-Neuverteilung bei Missionsstart.

### 9.4 Validierung

- keine Doppelzählung von Spieler-, KI-, Static- und Reserveebene,
- kein MEDEVAC-Start ohne Lead und Cover,
- keine Überschreitung lokaler KI-Grenzen,
- kein Einsatz über den verbleibenden Bestand hinaus,
- endgültiger Bestandsabzug bei Verlust,
- Rückgabe überlebender Assets nach ordnungsgemäßer Rückkehr,
- reproduzierbares Speichern und Laden.

---

## 10. Übertragung auf weitere Flugplätze

Erst nach erfolgreicher Jalalabad-Abnahme wird das Verfahren wiederholt.

| Flugplatz | Erstes verbindliches Kernpaket |
|---|---|
| Bagram | 336th EFS mit 16 F-15E; später C-130, HH-60G und weitere lokale Bestände |
| Kandahar | 75th EFS mit 16 A-10C; anschließend regionale Army-Aviation-Bestände |
| Khost / Salerno | AH-64D-, OH-58D- und Utility-Bestand gemäß eigener lokaler ORBAT |
| Camp Bastion | HMLA-169 mit 10 AH-1W; UH-1Y zunächst nicht physisch; HMH-361 mit 17 CH-53E |
| Camp Dwyer | lokal bereinigte USMC-Bestände ohne Doppelzählung mit Bastion |
| Tarinkot | lokale Army-Aviation-Bestände nach eigenem Manifest |
| Shindand | Ausbildungs-, Spezialoperations- und Unterstützungsbestände nach technischer Prüfung |

Für jeden Platz wird vor ME-Arbeit ein eigenes Manifest erstellt und ein eigener Acceptance-Test definiert.

---

## 11. RAT-Verkehr

RAT wird erst nach erfolgreicher AIRWING-, Bestands- und Persistenzvalidierung ergänzt.

Vorgesehen sind seltene atmosphärische Flüge. RAT-Flüge:

- verändern keine CampaignState-Bestände,
- transportieren keine persistenten Ressourcen,
- blockieren keine operativen Missionsgrenzen,
- werden getrennt von lokal stationierten SQUADRONs protokolliert.

---

## 12. Unmittelbar nächster Schritt

Für Jalalabad gilt nicht mehr der alte Diagnoseauftrag. Der aktuelle vollständige Arbeitsauftrag steht ausschließlich in:

```text
mission/tests/jalalabad-air-operations/expected/jalalabad-complete-node-acceptance.md
```

Nach dessen Umsetzung wird das Bundle gemäß Dokument 22 gebaut, erneut in die Mission eingebettet und in einem vollständigen DCS-Acceptance-Lauf geprüft.
