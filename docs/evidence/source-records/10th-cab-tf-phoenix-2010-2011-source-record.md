---
document_id: OMW-EVID-10CAB-TF-PHOENIX-2010-2011
status: BINDING_SOURCE_RECORD
document_class: HISTORICAL_SOURCE_RECORD
scenario_period: 2010-10-01/2011-07-31
primary_orbat_source: 122362406-Afghanistan-order-of-battle-july-2011.pdf
validated_in_dcs: false
---

# 10th CAB / Task Force Phoenix 2010-2011 - Quellenakte

## 1. Zweck

Diese Quellenakte dokumentiert die im OMW-Zeitraum belegte Struktur der 10th Combat Aviation Brigade, der unterstellten Aviation Task Forces und insbesondere von Task Force Phoenix / 3-10 General Support Aviation Battalion.

Sie ergänzt den verbindlichen Juli-2011-ORBAT-Snapshot. Sie ersetzt ihn nicht.

```text
PRIMARY JULY 2011 UNIT/LOCATION BASELINE
= 122362406-Afghanistan-order-of-battle-july-2011.pdf

SUPPLEMENTAL UNIT PUBLICATIONS
= company attachments, transfers, mission use and forward-location evidence
```

## 2. Quellenhierarchie

### 2.1 Primäre ORBAT-Quelle

- Wesley Morgan, *Afghanistan Order of Battle - Coalition Combat Forces in Afghanistan*, Institute for the Study of War, July 2011.
- bereitgestellte Datei: `122362406-Afghanistan-order-of-battle-july-2011.pdf`.
- maßgeblich für den Juli-2011-Snapshot von Einheit, übergeordneter Formation, Standort, Rolle, AOR und dokumentierter Rotation.

### 2.2 Zeitgenössische Eigenpublikationen der 10th CAB

- `pdf_7936.pdf`, *Falcon Flyer*, October/November 2010.
- `pdf_8886.pdf`, *Eye of the Falcon*, May 2011.

Diese beiden Publikationen sind für die konkrete Rotation besonders hoch zu gewichten, weil sie von der eingesetzten Brigade selbst während des Einsatzes herausgegeben wurden.

### 2.3 Offizielle ergänzende Berichte

- DVIDS: `One Falcon to Another: 10th CAB takes control of RC-East aviation operations`.
  - https://www.dvidshub.net/news/59870/one-falcon-another-10th-cab-takes-control-rc-east-aviation-operations
- U.S. Army: `Task Force Phoenix supports largest air assault in RC-East`.
  - https://www.army.mil/article/54519/task_force_phoenix_supports_largest_air_assault_in_rc_east
- U.S. Army: `Entire 101st to deploy to Afghanistan within year`.
  - https://www.army.mil/article/38151/entire_101st_to_deploy_to_afghanistan_within_year

### 2.4 Sekundäre Recherchehilfen

Folgende Seiten dürfen zum Auffinden weiterer Quellen und zum Kontext verwendet werden, aber nicht allein eine aktive OMW-Stärke oder Stationierung festlegen:

- Wikipedia, NATO installations und 10th CAB;
- Alchetron;
- GlobalSecurity;
- Afghan War News;
- Military History Fandom;
- Everything Explained;
- SLDInfo.

## 3. Belegte Task-Force-Struktur

Die zeitgenössischen Brigadepublikationen führen folgende Aviation Task Forces und Einsatzstandorte:

| Task Force | Stamm-/Führungselement | belegter Standort |
|---|---|---|
| TF Phoenix | 3-10 General Support Aviation | Bagram Airfield |
| TF Tigershark | 1-10 Attack Aviation | FOB Salerno |
| TF Knighthawk | 2-10 Assault Aviation | FOB Shank |
| TF Shooter | 6-6 Air Cavalry | FOB Fenty / Jalalabad |
| TF Eagle / Mountain Eagle | Aviation Support | Bagram Airfield |
| TF ODIN-A | ISR/Aerial Exploitation | Bagram Airfield |
| TF Gambler | Aviation Task Force | FOB Sharana |
| TF Taeguek | Korean aviation element | Bagram Airfield |
| TF Hippo | Czech aviation element | FOB Sharana |

Die May-2011-Ausgabe nennt TF Phoenix, TF Eagle und TF ODIN-A getrennt. Sie sind daher als eigenständige organisatorische beziehungsweise funktionale Pools zu behandeln.

## 4. TF Phoenix ist keine rein organische 3-10-GSAB-Abbildung

Task Force Phoenix wurde durch 3-10 GSAB geführt, bestand im Einsatz aber aus organischen und attached Companies beziehungsweise Detachments.

```text
3-10 GSAB = Stamm- und Führungselement
TF Phoenix = einsatzbezogene multifunktionale Aviation Task Force
```

Daraus folgt:

```text
ORGANIC BATTALION ASSIGNMENT != OPERATIONAL TASK-FORCE ASSIGNMENT
ORGANIC HOME UNIT != CURRENT FORWARD LOCATION
TASK-FORCE MEMBERSHIP != ALL AIRCRAFT PHYSICALLY AT TASK-FORCE HQ BASE
```

## 5. Direkt belegte Company-Transfers und Attachments

### 5.1 B Company, 3-10 Aviation

Die May-2011-Ausgabe dokumentiert, dass die organische B Company, 3-10 Aviation im März aus TF Phoenix herausgelöst und TF Shooter zugeteilt wurde.

Belegte operative Einordnung:

```yaml
unit: B Company, 3rd Battalion, 10th Aviation Regiment
aircraft_family: CH-47
organic_parent: 3-10 GSAB
operational_task_force_after_march_2011: TF Shooter
operational_location: FOB Fenty / Jalalabad
```

### 5.2 B Company, 1-168 Aviation

Als Ersatz beziehungsweise Verstärkung wurde B Company, 1-168 Aviation an TF Phoenix angegliedert und von Bagram aus eingesetzt.

```yaml
unit: B Company, 1st Battalion, 168th Aviation Regiment
aircraft_family: CH-47
component: Army National Guard
attached_to: TF Phoenix / 3-10 GSAB
operational_location: Bagram Airfield
```

### 5.3 B Company, 7-158 Aviation

Der getrennt dokumentierte 25-Aircraft-CH-47-Einsatzpool von B/7-158 Aviation ist ein weiterer eigener Verbandspool.

```text
B/7-158 POOL != B/3-10 ORGANIC COMPANY
B/7-158 POOL != B/1-168 ATTACHED COMPANY
B/7-158 POOL != TOTAL CH-47 IN RC-EAST OR AFGHANISTAN
```

Die OMW-Rekonstruktion `Bagram 13 / Salerno 6 / Shank 6` gilt ausschließlich für den dokumentierten B/7-158-Einsatzpool.

## 6. Army MEDEVAC

`pdf_7936.pdf` dokumentiert:

- C Company, 3rd General Support Aviation Battalion, 10th Aviation Regiment;
- Funktion als Medical Evacuation Unit;
- Verlegung nach Afghanistan ab August 2010.

Damit ist die Army-MEDEVAC-Komponente von 3-10 GSAB für die Rotation belegt.

Sie ist organisatorisch und bestandsmäßig strikt von der USAF-Rescue-Komponente zu trennen:

| Komponente | Organisation | Rolle |
|---|---|---|
| C/3-10 GSAB | U.S. Army | taktische MEDEVAC |
| 83rd ERQS | USAF | HH-60G Personnel Recovery / Rescue / medical evacuation support |

```text
ARMY MEDEVAC BLACK HAWKS != USAF HH-60G RESCUE POOL
```

Eine vollständige Stationierung aller C/3-10-Luftfahrzeuge in Bagram ist durch die vorliegenden Quellen nicht belegt. Forward Detachments und mission-related staging sind gesondert zu dokumentieren.

## 7. Bagram-UH-60-Nachweis

`pdf_7936.pdf` enthält einen zeitgenössischen Bild- und Textnachweis eines TF-Phoenix-UH-60 auf Bagram Airfield am 23. November 2010.

Damit ist belegt:

```yaml
Bagram_TF_Phoenix_UH60:
  presence_confirmed: true
  date_context: 2010-11-23
  exact_company: not established by this image alone
  exact_inventory: not established
```

Der Nachweis bestätigt Anwesenheit, aber keine exakte lokale Stückzahl.

## 8. Gemischte Attack-/Scout-Komponente

`pdf_8886.pdf` nennt Company C `Blue Max`, Task Force Phoenix, mit OH-58D-Wartung und zusätzlicher Unterstützung des AH-64-Musters.

Diese Company darf nicht mit C/3-10 GSAB `Mountain Dustoff` gleichgesetzt werden.

```text
COMPANY LETTER ALONE IS NOT A UNIQUE UNIT IDENTIFIER
```

Jede Company muss in der OMW-Dokumentation mindestens mit Stammverband, Task-Force-Zuordnung, Rolle und Fluggerät benannt werden.

## 9. Flugplatzübergreifende Operationen

Offizielle Berichte belegen gemeinsame Missionspakete mehrerer Task Forces. Beim größten Air Assault in RC-East unterstützten TF Phoenix und TF Shooter gemeinsam die Operation; beteiligte CH-47 und Besatzungen wurden task-force- und standortübergreifend eingesetzt.

Daraus folgt:

```text
ASSIGNED INVENTORY != SATELLITE-RAMP COUNT
MISSION PACKAGE != PERMANENT BASING
TRANSIENT AIRCRAFT != LOCAL UNIT INVENTORY
```

Satellitenbilder liefern daher einen sichtbaren Mindestbestand, aber nicht automatisch den vollständigen organisatorischen Bestand.

## 10. Verbindliche Auswirkungen auf OMW

### 10.1 Bagram

- TF Phoenix / 3-10 GSAB ist die primäre Army-Aviation-Task-Force des Juli-2011-Snapshots in Bagram.
- UH-60-Präsenz ist belegt.
- exakte UH-60-Utility-Stärke bleibt offen, bis eine zeitgerechte Stückzahlquelle oder eine dokumentierte OMW-Rekonstruktion beschlossen wird.
- Army MEDEVAC und USAF HH-60G sind getrennte Pools.
- TF Eagle und TF ODIN-A sind getrennte Bagram-Pools.

### 10.2 Jalalabad / FOB Fenty

- TF Shooter ist der belegte lokale Aviation-Verband.
- B/3-10 Aviation wurde ab März 2011 TF Shooter zugeteilt.
- daraus resultierende CH-47 dürfen nicht zusätzlich als Bagram-Bestand gezählt werden.

### 10.3 Salerno

- TF Tigershark ist der belegte lokale Aviation-Verband.
- der B/7-158-Anteil von sechs CH-47 bleibt ein separat definierter Pool und darf nicht als vollständiger Salerno-CH-47-Gesamtbestand aller Einheiten bezeichnet werden.

### 10.4 Shank

- TF Knighthawk ist der belegte lokale Aviation-Verband.
- Forward Detachments und fremde attached Companies müssen getrennt von organischen Bataillonsbeständen betrachtet werden.

## 11. Offene Punkte

- exakte Juli-2011-UH-60-Utility-Stärke von TF Phoenix in Bagram;
- vollständige Company-Liste von TF Phoenix im Juli 2011 mit Stammverbänden;
- genaue Forward-Detachment-Verteilung der Army-MEDEVAC-Komponente;
- eindeutige Stammverbandsidentifikation von Company C `Blue Max`;
- Abgrenzung aller parallel vorhandenen CH-47-Companies und ihrer jeweiligen lokalen Bestände.

Keine dieser offenen Fragen darf durch bloße Übernahme einer Friedens-MTOE oder durch Addition aller auf verschiedenen Flugplätzen genannten Fluggeräte geschlossen werden.
