---
document_id: OMW-AIR-IMPLEMENTATION
status: BINDING
owning_policy: OMW-GOV-001
authoritative_for:
  - technical representation of air operations in DCS and MOOSE
  - AIRWING and SQUADRON implementation rules
  - AI concurrency, MEDEVAC, static and warehouse implementation rules
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - pre-governance air-operations implementation document with four-client limit
superseded_by:
source_branch: agent/resolve-document-number-collisions
source_commit:
validated_in_dcs: false
document_class: AIR_OPERATIONS_ARCHITECTURE
---

# 18 – Luftoperations- und ORBAT-Umsetzung

## 1. Zweck und Autoritätsgrenzen

Dieses Dokument beschreibt, **wie** die aktive Luft-ORBAT technisch in DCS und MOOSE dargestellt und verwaltet wird.

Es ist ausdrücklich nicht die Quelle für:

- aktive Staffelauswahl;
- lokale Luftfahrzeugbestände;
- Client-Luftfahrzeuggrenzen;
- historische Rotationen.

Dafür ist ausschließlich verbindlich:

- [`OMW-AIR-ACTIVE-ORBAT – Dokument 19`](19-active-air-orbat-decisions.md).

Die historische Evidenz für Basen, Verbände, Konfigurationen und Einsatzmuster steht in:

- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION – Dokument 50`](50-afghanistan-force-basing-aviation-2010-2011.md).

Weitere maßgebliche Grundlagen:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION – Dokument 37`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-ME-MASTER-WORKLIST – Dokument 38`](38-mission-editor-master-worklist.md).

Der vollständige frühere Text bleibt unverändert als Legacy-Evidenz erhalten unter:

- [`legacy-18-air-operations-implementation-pre-governance.md`](evidence/source-records/legacy-18-air-operations-implementation-pre-governance.md).

## 2. Verbindliche MOOSE-Architektur

Militärische Luftoperationen werden grundsätzlich mit MOOSE OPS umgesetzt:

- `AIRWING` als lokaler Ressourcen- und Einsatzmanager eines Flugplatzes oder Luftfahrtknotens;
- `SQUADRON` als typgebundener Bestand mit Templates, Payloads und Fähigkeiten;
- `AUFTRAG` für CAS, Aufklärung, Eskorte, Strike, MEDEVAC und vergleichbare militärische Einsätze;
- `COMMANDER` für die Verteilung bereits erzeugter Aufträge an geeignete AIRWINGs;
- `WAREHOUSE` beziehungsweise die Warehouse-Funktion des AIRWINGs für die physische MOOSE-Verwaltung.

`CHIEF` wird nicht automatisch verwendet. Zielauswahl, Kampagnenlogik und Auftragserzeugung bleiben an die in Dokument 37 festgelegte CampaignState- und MissionDemand-Architektur gebunden.

Jede produktive Nicht-MOOSE-Ergänzung benötigt die vollständige Prüfung und ausdrückliche Projektinhaberfreigabe nach Dokument 26.

## 3. AIRWING- und SQUADRON-Struktur

Grundsätzlich wird ein `AIRWING` pro physischem Flugplatz oder dauerhaftem Luftfahrtknoten vorgesehen. Historisch gemischte Verbände werden technisch in typreine `SQUADRON`-Bestände aufgeteilt.

Bei:

```lua
SQUADRON:New(TemplateGroupName, Ngroups, SquadronName)
```

zählt `Ngroups` die Anzahl der Gruppen, nicht die Anzahl einzelner Luftfahrzeuge. ORBAT-Bestände müssen deshalb anhand der jeweiligen Template-Gruppengröße umgerechnet werden.

Beispiel:

```text
8 KI-Luftfahrzeuge
2 Luftfahrzeuge je Template-Gruppe
= 4 MOOSE-Gruppen
```

## 4. Bestands- und Darstellungsmodell

Folgende Ebenen sind strikt getrennt zu führen:

- logischer Kampagnenbestand;
- mission-ready Bestand;
- Client-Reservierungen;
- aktive KI-Luftfahrzeuge;
- Late-Activation-Templates;
- sichtbare Statics;
- virtuelle Reserve;
- beschädigte und endgültig verlorene Luftfahrzeuge.

Client-Slots, KI-Templates, aktive KI-Gruppen und Statics sind Darstellungen beziehungsweise Authoring-Objekte. Sie dürfen den logischen Bestand nicht mehrfach erhöhen.

### 4.1 Client-Grenzen

Die Zahl der Client-Luftfahrzeuge wird hier bewusst **nicht dupliziert**. Es gilt ausschließlich die jeweils aktuelle projektweite Grenze aus Dokument 19.

Technische Regeln:

- ein Luftfahrzeug je Client-Gruppe;
- Multicrew-Sitze sind keine zusätzlichen Luftfahrzeuge;
- Client-Gruppen werden nicht als KI-Templates wiederverwendet;
- Reservierung, Nutzung und Rückgabe müssen gegen den logischen Bestand geprüft werden.

### 4.2 Lokale KI-Sicherheitsgrenze

Pro Luftfahrzeugtyp und Basis dürfen höchstens vier KI-Luftfahrzeuge gleichzeitig aktiv sein:

```lua
maxAIAircraftPerTypeAndBase = 4
```

Diese Zahl ist eine technische Sicherheitsobergrenze und keine normale Einsatzstärke oder ORBAT-Angabe.

### 4.3 Globale operative KI-Grenze

Missionsweit gelten zunächst:

```lua
maxConcurrentSupportMissions = 2
maxAircraftPerSupportMission = 2
maxConcurrentSupportAircraft = 4
```

Unter diese Grenze fallen insbesondere CAS, Armed Reconnaissance, Aufklärung, Eskorte, Luft-QRF, MEDEVAC, CSAR-Unterstützung und angeforderte taktische Transporte. Spielerluftfahrzeuge und rein atmosphärischer RAT-Verkehr werden nicht angerechnet.

## 5. MEDEVAC als koordiniertes Two-Ship-Paket

UH-60-MEDEVAC wird grundsätzlich als Zweierteam geplant:

1. ein Lead-Luftfahrzeug landet und übernimmt Verwundete oder Personal;
2. ein Cover-Luftfahrzeug bleibt in der Luft und sichert den Landevorgang.

```lua
medevac = {
  packageSize = 2,
  leadAircraft = 1,
  coverAircraft = 1,
  allowSingleShip = false
}
```

Für die KI-Steuerung dürfen Lead und Cover als getrennte Ein-Schiff-Templates angelegt werden, sofern ein Koordinator beide Reservierungen und Zustände als gemeinsames Paket führt.

Das konkrete Anflug-, Orbit-, Feindkontakt- und Abflugverhalten muss in DCS reproduzierbar getestet werden.

## 6. Gepoolte Statics

Es wird keine individuelle 1:1-Airframe-Verfolgung vorausgesetzt. Sichtbare Statics stellen nur einen Teil des inaktiven Bestands dar und werden nicht zusätzlich zum ORBAT-Bestand gezählt.

Grundregel:

```text
maximal sichtbare Statics
= verbleibender Bestand
- aktive Client-Luftfahrzeuge
- aktive KI-Luftfahrzeuge
```

Zusätzlich erhält jeder Typ eine missionsgestalterisch festgelegte Obergrenze für sichtbare Statics. Statics dürfen operative Park-, Roll- und Spawnflächen nicht blockieren.

Wird ein Static zerstört, zählt dies nach bestätigter Ereigniszuordnung als realer Verlust des lokalen Kampagnenbestands. Es erfolgt kein automatischer Ersatz.

## 7. Verlust- und Ersatzmodell

Die erste Ausbaustufe verwendet:

```lua
lossPolicy = "PERMANENT"
replacementPolicy = "NONE"
```

Bestätigte Verluste reduzieren den lokalen Bestand dauerhaft. Grenzfälle wie Disconnect, beschädigte Landung, Notlandung, Ejection, aufgegebene Maschine oder Taxi-Fehler benötigen eigene dokumentierte Zustands- und Acceptance-Regeln.

## 8. Historische Detachments

Historische Parent- oder Detachment-Angaben bleiben Herkunfts- und Dokumentationsdaten. Für die Runtime zählt die verbindlich festgelegte lokale Bestandszahl aus Dokument 19 beziehungsweise dem zuständigen, nicht widersprechenden Basenmanifest.

Außenstellen dürfen nicht zusätzlich am Stammflugplatz gezählt werden. Dynamische Verlegungen werden erst eingeführt, wenn CampaignState-, Warehouse- und AIRWING-Übergaben gemeinsam spezifiziert und getestet sind.

## 9. Warehouse-Regel

Ein `AIRWING` benötigt einen von MOOSE verwendbaren Warehouse-Anker als benanntes `STATIC`- oder `UNIT`-Objekt.

Vorgehen:

1. prüfen, ob ein vorhandenes Missionsobjekt als MOOSE-Anker verwendbar ist;
2. reine Kartenszenerie nicht als benanntes Missionsobjekt voraussetzen;
3. bei fehlendem Anker genau ein technisches Warehouse-Static im vorhandenen Lagerbereich setzen;
4. Airbase-Bezug nach Möglichkeit explizit festlegen;
5. Rollwege, Landezonen und Parkpositionen freihalten.

Ein sichtbares Tanklager ist keine technische MOOSE-Voraussetzung. Es wird nur gesetzt, wenn es als Kampagneninfrastruktur relevant, zerstörbar und zustandsgeführt sein soll.

## 10. Template-FOBs und Luftoperationsknoten

- logistischer FOB: benannter Warehouse-Anker und Übergabezonen;
- FOB mit dauerhaft stationierten KI-Luftfahrzeugen: zusätzlich geeignete Spawn-/Parkmöglichkeiten und eigenes `AIRWING`;
- reines Missionsziel oder Landezone: kein eigenes `AIRWING` erforderlich.

Die konkrete Objekt-, Gruppen-, Zonen- und Template-Namensgebung folgt dem Master-Worklist- und Manifest-System.

## 11. Community- und Risikomodule

Community- und Drittanbietermodule müssen optional und ausfalltolerant integriert werden. Eine fehlende Modinstallation darf die Kernmission nicht unkontrolliert unbrauchbar machen.

Zu prüfen sind jeweils:

- interner DCS-Typname;
- Server-/Client-Ladeverhalten ohne Modul;
- Multicrew;
- Fracht und Außenlast;
- Parking und Rotorabstände;
- KI-Verhalten;
- AIRWING-/SQUADRON-Nutzung;
- Payload- und Livery-Verfügbarkeit.

## 12. RAT-Verkehr

RAT dient ausschließlich atmosphärischem Verkehr. RAT-Flüge:

- verändern keine CampaignState-Bestände;
- transportieren keine strategischen Ressourcen;
- erzeugen keinen automatischen Ersatz;
- dürfen operative Park- und Performancegrenzen nicht verdrängen.

## 13. Mindestvalidierung

Vor produktiver Verwendung eines Luftoperationsknotens sind mindestens zu prüfen:

1. dokumentierte MOOSE-Version und Hash;
2. gültiger Warehouse-Anker und Airbase-Bezug;
3. eindeutige Templates, Gruppen, Einheiten und Zonen;
4. Client-Grenze aus Dokument 19;
5. SQUADRON-Gruppenanzahl gegen Template-Größe und ORBAT;
6. keine Doppelzählung von Client, KI, Statics und Reserve;
7. kollisionsfreie Spawns und Rückkehr;
8. Verlust- und Rückgabelogik;
9. globale KI-Einsatzgrenzen;
10. reproduzierbarer DCS-Test mit Mission-, Bundle-, Commit- und MOOSE-Nachweis.

Ein technischer PASS gilt nur für den exakt dokumentierten Teststand und ersetzt nicht automatisch Governance oder aktive ORBAT.

## 14. Quellenbasierte historische Einsatzmuster

Die folgenden Muster stammen aus der konsolidierten Evidenz in Dokument 50. Sie sind **technische Darstellungsziele**, keine neuen aktiven Bestandsentscheidungen.

### 14.1 Kiowa Scout Weapons Team

Historisch direkt belegt:

```text
2 × OH-58D
```

Technische Rollen:

- `ARMED_RECONNAISSANCE`;
- `ROUTE_RECONNAISSANCE`;
- `SCREEN`;
- `ESCORT`;
- leichte Feuerunterstützung.

Umsetzung:

- bevorzugt ein Two-Ship-Template oder zwei koordinierte Single-Ship-Gruppen;
- gemeinsame Reservierung gegen den lokalen OH-58D-Pool;
- gemeinsame Missions-ID;
- getrennte Verlust- und Rückkehrereignisse;
- kein automatischer Ersatz bei Verlust.

### 14.2 Light Air Assault

Quellenbasiertes Paket:

```text
2 × CH-47
2 × AH-64 Escort
optional ISR
optional Fixed-Wing-CAS
Nachtinsertion
```

Da die aktuelle globale KI-Grenze maximal vier Supportluftfahrzeuge zulässt, kann dieses Paket vollständig aktiv dargestellt werden, sofern keine weitere Supportmission parallel läuft. Spielerluftfahrzeuge können einen Teil des Pakets übernehmen.

### 14.3 Large Air Assault

Quellenbasiertes Muster:

```text
4 × CH-47
mehrere Turns
mehrere HLZs
AH-64 Escort
HLZ-ISR
Fixed-Wing-Overwatch
Fire-Support-Plan
```

Eine vollständige gleichzeitige KI-Darstellung kann die Performance- und Concurrency-Grenzen überschreiten. Zulässige technische Abbildung:

- gestaffelte Wellen;
- Spieler als Teil des Pakets;
- virtuelle Vor- und Nachläufe im CampaignState;
- begrenzte aktive Escort-Komponente;
- getrennte Folgeversorgung;
- isolierte Performance-Tests vor jeder Grenzanhebung.

### 14.4 Night Cordon and Search

Quellenbasiertes Muster:

```text
2 × CH-47
ungefähr 70 Soldaten gesamt
mehrere HLZs/PZs möglich
2–5 Tage Bodeneinsatz
anschließende Exfiltration
```

Technisch sind mindestens drei getrennte Phasen zu führen:

```text
INFILTRATION
GROUND_OPERATION_AND_RESUPPLY
EXFILTRATION
```

Der Abschluss der Infiltration darf die spätere Exfiltration nicht automatisch als verfügbar oder erfolgreich verbuchen.

### 14.5 Talon-Purge-/Mehrturn-Muster

Historischer Maßstab:

- 4 CH-47 und 2 UH-60;
- knapp 350 Personen;
- fünf HLZs;
- mehrere Turns je Luftfahrzeug;
- ungefähr 30 Passagiere je CH-47 und Turn.

Umsetzung:

- Passagiere pro Turn und Luftfahrzeug reservieren;
- Teilwellen getrennt protokollieren;
- verlorene oder abgebrochene Welle nicht als transportiert verbuchen;
- HLZ-Verfügbarkeit und Bedrohungszustand pro Welle prüfen;
- keine einmalige Gruppenaktivierung als Ersatz für den gesamten Mehrturn-Transport verwenden.

### 14.6 Munitionsrotation

Operation Bulldog Bite belegt, dass OH-58D und AH-64 ihre mitgeführte Munition vollständig verbrauchen und durch frische Luftfahrzeuge abgelöst werden konnten.

Daraus folgen optionale Runtime-Zustände:

```text
AMMO_AVAILABLE
BINGO_AMMO
RTB_REARM
FARP_REARM
RELIEF_ON_STATION
```

Vor Einführung ist zu prüfen, welche MOOSE-AIRWING-/AUFTRAG-Funktionalität Fuel-, Munition-, RTB- und Replacement-Verhalten bereits abbildet.

## 15. Historische Konfigurationsvarianten

### 15.1 OH-58D AN/ALQ-144

Dokument 50 belegt visuell:

- 31.01.2011, Kandahar: AN/ALQ-144-Familie sichtbar;
- März 2012, Jalalabad: zwei Maschinen ohne sichtbaren AN/ALQ-144, außerhalb des OMW-Zeitraums.

Technische Regel:

- 2010/2011 darf die OH-58D-Darstellung mit sichtbarem ALQ-144 nicht als anachronistisch verworfen werden;
- ein post-periodischer Zustand ohne sichtbaren ALQ-144 wird nicht rückwirkend als Standard erzwungen;
- verfügbare DCS-Modelle, Liveries und Modvarianten werden als technische Abbildungsgrenze dokumentiert.

### 15.2 OH-58D Mischbewaffnung

Das Kandahar-Test-Fire-Foto zeigt:

- einen Siebenrohr-Raketenbehälter der M260-/70-mm-Systemfamilie;
- auf der Gegenseite wahrscheinlich einen Zweifachträger mit zwei Hellfire.

Diese Konfiguration darf als historisch plausible Payloadvariante vorgesehen werden. Sie wird nicht als häufigste oder einzige Einsatzbeladung bezeichnet. Die genaue Hellfire-Untervariante bleibt offen.

### 15.3 Zeit- und Quellenmetadaten

Jede historisch spezifische Payload- oder Livery-Variante führt mindestens:

```text
historicalSourceIds
evidenceClass
effectiveFrom
effectiveTo
configurationNotes
sourceConflict
```

## 16. Wartungs- und Bereitschaftsmodell

Quellen belegen hohe Flugbelastung, schnelle Materialalterung, FARP-Zyklen und umfangreiche Aviation-Reparaturen. Daher dürfen nominaler und mission-ready Bestand nicht gleichgesetzt werden.

Erweiterbares Modell:

```lua
aircraftState = {
  nominal = 0,
  missionReady = 0,
  maintenance = 0,
  damaged = 0,
  destroyed = 0,
  aogWaitingParts = 0
}
```

Mögliche MissionDemand-Typen:

- `AOG_PARTS_DELIVERY`;
- `FIELD_REPAIR_SUPPORT`;
- `DOWNED_AIRCRAFT_RECOVERY`;
- `FARP_FUEL_DELIVERY`;
- `FARP_AMMUNITION_DELIVERY`.

Diese Erweiterung ist noch keine implementierte technische Baseline. Vor eigenem Code sind MOOSE-Warehouse-, AIRWING-, AUFTRAG-, OPSTRANSPORT- und Event/FSM-Funktionen vollständig zu prüfen.
