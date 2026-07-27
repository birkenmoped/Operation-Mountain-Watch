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