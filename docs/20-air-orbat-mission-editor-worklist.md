# 20 – Missionseditor-Arbeitsliste für die Luft-ORBAT

## Zweck

Dieses Dokument trennt verbindlich:

1. die vom Missionsdesigner im DCS Mission Editor auszuführenden Arbeiten,
2. die zuvor oder parallel durch die Entwicklung bereitzustellenden Informationen, Konfigurationen und Prüfskripte,
3. die Reihenfolge, in der die Luft-ORBAT technisch aufgebaut und validiert wird.

Die historische Auswahl der aktiven Einheiten ist in [`19-active-air-orbat-decisions.md`](19-active-air-orbat-decisions.md) abgeschlossen. Die gemeinsamen Betriebsregeln stehen in [`18-air-operations-implementation.md`](18-air-operations-implementation.md).

---

## 1. Umsetzungsreihenfolge

Die vollständige ORBAT wird nicht gleichzeitig auf allen Flugplätzen aufgebaut.

Verbindliche Reihenfolge:

1. **Jalalabad Airfield / FOB Fenty** als vertikaler Prototyp,
2. Warehouse-, Parking-, Spieler-, KI- und Static-Mechanik in Jalalabad validieren,
3. MEDEVAC-Two-Ship und globale KI-Einsatzgrenzen validieren,
4. erst danach Übertragung des bewährten Schemas auf Bagram, Kandahar, Khost, Camp Bastion, Camp Dwyer, Tarinkot und Shindand,
5. atmosphärischen RAT-Verkehr zuletzt ergänzen.

Bagram und andere große Basen werden zunächst nicht vollständig ausgebaut. Dies entspricht dem bestehenden Prototypfokus auf Jalalabad/Fenty und FOB Connolly.

---

## 2. Grundsatz der Aufgabenteilung

### Missionsdesigner

Der Missionsdesigner ist verantwortlich für alle Objekte und Eigenschaften, die nur im DCS Mission Editor zuverlässig angelegt oder visuell geprüft werden können:

- physische Platzierung,
- Parkpositionen,
- Spieler-Slots,
- Late-Activation-Templates,
- Static-Objekte,
- Liveries und sichtbare Markierungen,
- Zonen und Triggerzonen,
- FARP-, Helipad- und Warehouse-Infrastruktur,
- Prüfung von Rollwegen, Rotorabständen und Kollisionen,
- Speicherung und Bereitstellung der `.miz`-Testmission.

### Entwicklung

Die Entwicklung ist verantwortlich für alle Vorgaben und Komponenten, die vor der Platzierung eindeutig definiert werden müssen:

- verbindliche Objekt- und Gruppennamen,
- ORBAT-Konfiguration,
- Template-Matrix,
- Rollen- und Payload-Matrix,
- AIRWING- und SQUADRON-Konfiguration,
- Diagnose- und Validierungsskripte,
- Bestands-, Static-, Verlust- und Slotlogik,
- MEDEVAC-Paketsteuerung,
- globale KI-Auftragsbegrenzung,
- Persistenzanbindung und Logging.

Der Missionsdesigner soll keine eigenen MOOSE-Strukturen oder Benennungssysteme erfinden müssen.

---

## 3. Von der Entwicklung vor der eigentlichen ME-Platzierung bereitzustellen

Für jeden Flugplatz wird ein separates **Air Operations Manifest** vorbereitet. Dieses muss mindestens enthalten:

| Information | Inhalt |
|---|---|
| aktive Einheiten | verbindlicher Verband und Luftfahrzeugbestand |
| DCS-Typ | bestätigter interner DCS-Typname |
| Verfügbarkeit | Spieler, KI, Community-Mod oder nur strategisch |
| Spieler-Slots | genaue Zahl und vollständige Gruppen-/Einheitennamen |
| KI-Templates | genaue Zahl, Gruppengröße, Rolle und vollständige Namen |
| Payloads | benötigte Missionsrollen und zugehörige Template-Namen |
| Statics | Zielzahl, mögliche Liveries und zulässiger Abstellbereich |
| Warehouse | zu prüfendes Kartenobjekt oder zu setzender technischer Anker |
| Parken | benötigte Parkkategorien und zu prüfende Parkpositionen |
| Zonen | vollständige Zonenliste mit Zweck und Benennung |
| Testfälle | erwartetes Verhalten und Abnahmekriterien |

Zusätzlich werden folgende Diagnosewerkzeuge vorbereitet:

```text
DumpAircraftTypes.lua
DumpAirbaseParking.lua
ProbeWarehouseAnchor.lua
ValidateMissionTemplates.lua
```

Diese Werkzeuge sollen aus der verwendeten DCS-Version ermitteln beziehungsweise prüfen:

- tatsächliche DCS-Typnamen,
- Airbase- und Parking-IDs,
- Größe und Eignung von Parkpositionen,
- Erkennbarkeit karteneigener Warehouse-Objekte,
- vorhandene Gruppen, Einheiten, Statics und Zonen,
- doppelte oder falsch benannte Missionsobjekte.

Außerdem wird eine konkrete MOOSE-Version mit Dateihash festgeschrieben. Die Mission soll nicht mit einer unbestimmten oder laufend wechselnden `Moose.lua` entwickelt werden.

---

## 4. Arbeitsauftrag 1 – Jalalabad-Testmission vorbereiten

### Vom Missionsdesigner jetzt auszuführen

1. Eine Arbeitskopie der aktuellen Prototypmission anlegen.
2. Die Arbeitskopie eindeutig benennen, beispielsweise:

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
```

3. In dieser Kopie noch **keine vollständige Luft-ORBAT auf allen Basen** platzieren.
4. Vorhandene Jalalabad-/Fenty-Infrastruktur, Trigger, Zonen und bereits vorhandene Spielergruppen unverändert erhalten.
5. Die Arbeitskopie für die weitere Analyse bereitstellen.

Die Arbeitskopie ist die gemeinsame technische Referenz. Alle nachfolgenden Gruppen-, Zonen- und Static-Namen werden auf genau dieser Mission aufgebaut.

### Von der Entwicklung anschließend bereitzustellen

- Jalalabad Air Operations Manifest,
- festgeschriebene MOOSE-Version,
- Warehouse-Prüfskript,
- Parking-Dump,
- DCS-Typ- und Livery-Prüfung,
- Validierungsskript für Namen und Templates,
- erste AIRWING-/SQUADRON-Bootstrap-Datei.

---

## 5. Jalalabad – vom Missionsdesigner nach Lieferung des Manifests auszuführen

## 5.1 Warehouse und Airbase-Bezug

1. Prüfen, ob ein vorhandenes karteneigenes Warehouse-Gebäude durch das bereitgestellte Prüfskript als geeigneter MOOSE-Anker erkannt wird.
2. Falls das Ergebnis positiv ist, das vorhandene Objekt verwenden und kein zusätzliches Warehouse setzen.
3. Falls das Ergebnis negativ ist, genau ein technisches Warehouse-Static im bestehenden Lagerbereich platzieren:

```text
WH_AIR_US_JALALABAD
```

4. Das Warehouse darf keine Rollwege, Landezonen oder Parkpositionen blockieren.
5. Ein Tanklager wird nicht allein für MOOSE benötigt. Zusätzliche Tanks werden nur gesetzt, wenn sie als sichtbare und später zerstörbare Kampagneninfrastruktur vorgesehen sind.

## 5.2 Parkbereiche festlegen

In Jalalabad werden getrennte Bereiche benötigt für:

- Spieler-Hubschrauber,
- KI-Spawn und KI-Rückkehr,
- sichtbare gepoolte Statics,
- MEDEVAC-Bereitschaft,
- Logistik- und Frachtbetrieb,
- C-130-Roll- und Entladebetrieb.

Der Missionsdesigner prüft visuell:

- Rotorabstände,
- Überschneidungen der Spawnpunkte,
- Rollwege,
- Kollision mit Statics und Bodenobjekten,
- Nutzbarkeit durch Two-Ship-Gruppen,
- ausreichend freie Fläche für UH-60 und AH-64D,
- getrennte Flächen für sichtbare OH-58D-Statics.

Die exakten Parking-IDs werden mit `DumpAirbaseParking.lua` ermittelt und danach in der technischen Konfiguration festgeschrieben.

## 5.3 Spieler-Slots

Nach Freigabe des Jalalabad-Manifests werden höchstens vier Spieler-Luftfahrzeuge je nutzbarem Muster angelegt.

Vorgesehene Gruppenfamilien:

```text
CLIENT_US_JBAD_OH58D_01
CLIENT_US_JBAD_OH58D_02
CLIENT_US_JBAD_OH58D_03
CLIENT_US_JBAD_OH58D_04

CLIENT_US_JBAD_AH64D_01
CLIENT_US_JBAD_AH64D_02
CLIENT_US_JBAD_AH64D_03
CLIENT_US_JBAD_AH64D_04

CLIENT_US_JBAD_UH60L_01
CLIENT_US_JBAD_UH60L_02
CLIENT_US_JBAD_UH60L_03
CLIENT_US_JBAD_UH60L_04
```

Regeln:

- grundsätzlich eine Spieler-Maschine je DCS-Gruppe,
- Client-Slots werden nicht als KI-Templates wiederverwendet,
- UH-60L-Slots bleiben optional und dürfen die Kernmission ohne Mod nicht unbrauchbar machen,
- Multicrew-Sitze zählen nicht als zusätzliche Luftfahrzeuge,
- endgültige Gruppennamen werden aus dem Manifest übernommen und nicht frei verändert.

## 5.4 KI-Templates

Alle KI-Templates werden im Missionseditor als **Late Activation** angelegt und nicht als dauerhaft aktive Gruppen gestartet.

Vorgesehene Mindeststruktur:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
```

Zusätzliche Utility-, Escort- oder Transporttemplates werden erst nach Festlegung der Rollenmatrix ergänzt.

Regeln:

- OH-58D und AH-64D werden für reguläre Unterstützung grundsätzlich als Two-Ship vorbereitet,
- MEDEVAC Lead und Cover müssen getrennte Ein-Schiff-Gruppen sein,
- die Template-Gruppengröße darf später nicht ohne Anpassung der SQUADRON-Bestandsrechnung verändert werden,
- keine `#`-Zeichen in Template-Namen,
- Gruppen- und Einheitennamen müssen eindeutig sein,
- jede Vorlage erhält nur die für ihre Rolle benötigte Grundkonfiguration; die endgültige Payload-Zuordnung erfolgt über die vorbereitete Payload-Matrix.

## 5.5 Gepoolte Statics

Der Missionsdesigner legt Static-Abstellpositionen an, aber zunächst nur in der vom Manifest vorgegebenen Zielzahl.

Benennungsfamilien:

```text
STATIC_AIR_US_JBAD_OH58D_01
STATIC_AIR_US_JBAD_AH64D_01
STATIC_AIR_US_JBAD_UH60_01
```

Regeln:

- Statics sind Teil des lokalen ORBAT-Bestands und kein zusätzlicher Bestand,
- Statics stehen auf getrennten Abstellflächen und blockieren keine operativen Parkplätze,
- Statics werden nicht dauerhaft einem bestimmten Spieler-Slot oder KI-Template zugeordnet,
- zerstörte Statics zählen später als endgültiger Bestandsverlust,
- die genaue sichtbare Anzahl wird durch das Jalalabad-Manifest festgelegt.

## 5.6 Zonen

Mindestens folgende Zonenfamilien werden für Jalalabad vorbereitet:

```text
ZONE_AIR_US_JBAD_STATIC_OH58D
ZONE_AIR_US_JBAD_STATIC_AH64D
ZONE_AIR_US_JBAD_STATIC_UH60
ZONE_AIR_US_JBAD_MEDEVAC_READY
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_C130_UNLOAD
```

Die bereits im Prototyp geplanten Lande-, Fracht-, Außenlast- und C-130-Zonen werden wiederverwendet, sofern Zweck, Lage und Name eindeutig sind. Doppelte Zonen für denselben Zweck sollen vermieden werden.

---

## 6. Nach der Missionseditor-Bearbeitung bereitzustellen

Nach jedem Arbeitsstand stellt der Missionsdesigner bereit:

- die aktuelle `.miz`,
- die zugehörige `dcs.log` eines kurzen Testlaufs,
- Screenshots der belegten Park- und Static-Bereiche,
- Hinweise auf im Mission Editor nicht auswählbare Typen oder Liveries,
- eine Liste auffälliger Spawn-, Roll- oder Kollisionsprobleme.

Der Testlauf muss mindestens enthalten:

1. Missionsstart ohne Lua-Fehler,
2. Erkennung von Jalalabad Airfield,
3. Erkennung des Warehouse-Ankers,
4. Auflistung der Parking-IDs,
5. Validierung aller erwarteten Gruppen und Zonen,
6. manueller Spawn jedes KI-Templates,
7. Prüfung, ob Two-Ship-Gruppen kollisionsfrei erscheinen,
8. Prüfung von MEDEVAC Lead und Cover als getrennte Gruppen.

---

## 7. Von der Entwicklung nach Erhalt der Jalalabad-Testmission umzusetzen

## 7.1 Konfiguration

- strukturierte Jalalabad-ORBAT als Lua-Datenmodell,
- Bestände 24 OH-58D, 8 AH-64D und 6 UH-60,
- vier Spieler-Luftfahrzeuge je nutzbarem Muster als Obergrenze,
- vier KI-Luftfahrzeuge je Muster als lokale technische Obergrenze,
- maximal zwei parallele Unterstützungsmissionen mit jeweils höchstens zwei Luftfahrzeugen.

## 7.2 MOOSE-Bootstrap

- `AW_US_JALALABAD` anlegen,
- `SQ_6_6_CAV_OH58D` anlegen,
- `SQ_B_1_10_AVN_AH64D` anlegen,
- `SQ_JBAD_UTILITY_UH60` anlegen,
- Templates, Fähigkeiten und Payloads zuordnen,
- Airbase und Warehouse explizit verbinden,
- Start, Rückkehr und Verlust protokollieren.

## 7.3 Manager und Adapter

- `AirOperationsManager`,
- `AirframePool` für numerische Bestände,
- `StaticAirframeManager` für gepoolte Statics,
- `PlayerSlotManager` für Bestandsgrenzen,
- `MedevacPackageCoordinator` für Lead und Cover,
- Adapter zwischen `CampaignState` und MOOSE AIRWING/SQUADRON,
- globale KI-Auftragsreservierung,
- Verlust- und Persistenzanbindung.

## 7.4 Validierung

- keine Doppelzählung von Spieler-, KI- und Static-Darstellungen,
- kein MEDEVAC-Start mit nur einem verfügbaren UH-60,
- keine dritte parallele KI-Unterstützungsmission,
- keine Überschreitung von vier aktiven KI-Luftfahrzeugen eines Musters in Jalalabad,
- endgültiger Bestandsabzug bei bestätigtem Verlust,
- Wiederherstellung freier Bestände nach ordnungsgemäßer Rückkehr,
- reproduzierbares Speichern und Laden.

---

## 8. Übertragung auf weitere Flugplätze

Erst nach erfolgreicher Jalalabad-Abnahme wird dasselbe Verfahren je Flugplatz wiederholt.

| Flugplatz | Erstes verbindliches Kernpaket |
|---|---|
| Bagram | 336th EFS mit 16 F-15E; später C-130, HH-60G und weitere lokale Bestände |
| Kandahar | 75th EFS mit 16 A-10C; anschließend regionale Army-Aviation-Bestände |
| Khost / Salerno | AH-64D-, OH-58D- und Utility-Bestand gemäß bereinigter lokaler ORBAT |
| Camp Bastion | HMLA-169 mit 10 AH-1W; UH-1Y zunächst nicht physisch; HMH-361 mit 17 CH-53E |
| Camp Dwyer | lokal bereinigte USMC-Bestände ohne Doppelzählung mit Bastion |
| Tarinkot | lokal festgelegte Army-Aviation-Bestände ohne dynamischen Detachment-Manager |
| Shindand | lokale Ausbildungs-, Spezialoperations- und Unterstützungsbestände nach technischer Prüfung |

Für jeden Platz wird vor der ME-Arbeit ein eigenes Manifest erstellt. Es werden keine Namen, Template-Größen oder Static-Zahlen aus Jalalabad ungeprüft kopiert.

---

## 9. RAT-Verkehr

RAT wird erst nach erfolgreicher AIRWING- und Bestandsvalidierung ergänzt.

Vorgesehen sind ausschließlich seltene atmosphärische Flüge:

- ein bis zwei C-130-Flüge pro Kampagnentag,
- null bis ein C-17-Flug pro Kampagnentag,
- null bis zwei gelegentliche CH-47-Verbindungsflüge pro Kampagnentag,
- höchstens ein gleichzeitig aktiver Fixed-Wing-Hintergrundflug,
- höchstens ein gleichzeitig aktiver Rotary-Wing-Hintergrundflug.

RAT-Flüge verändern keine Bestände und transportieren keine CampaignState-Ressourcen.

---

## 10. Unmittelbar nächster Schritt

Der Missionsdesigner erstellt und übermittelt jetzt ausschließlich die Arbeitskopie:

```text
Operation_Mountain_Watch_Jalalabad_AirOps_Test_01.miz
```

Danach liefert die Entwicklung das Jalalabad Air Operations Manifest und die vier Diagnosewerkzeuge. Erst auf dieser Grundlage beginnt die konkrete Platzierung von Spieler-Slots, KI-Templates, Statics und Warehouse-Anker.