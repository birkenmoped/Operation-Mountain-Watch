---
document_id: OMW-MOOSE-FIRE-SUPPORT-AUFTRAG-STAGE-3-SOURCE-REVIEW
status: SOURCE_REVIEWED
document_class: TECHNICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - Stage-3 MOOSE source evidence for fixed external fire-support dispatch
  - boundary between Stage-2 threat detection, MissionDemand and MOOSE ARTY execution
not_authoritative_for:
  - DCS runtime validation of the Stage-3 combined Honaker/Wright acceptance
  - a final numeric L118 range contract
  - strategic Ground-AMMO resupply settlement beyond the separately accepted Stage-1 baseline
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/fire-support-strategic-resupply-closure
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# Stage 3 – Fire Support über MOOSE AUFTRAG – Source Review

## 1. Zweck

Dieser Review klärt den kleinsten MOOSE-first-Pfad für den neuen Stage-3-Schnitt:

```text
bestehende Stage-2-OPSZONE-Bedrohung
-> Fire-Support-MissionDemand
-> vorhandene externe Fixed-Fire-Support-Batterie
-> MOOSE AUFTRAG ARTY
-> reale Feuerabgabe
```

Der Review ersetzt weder die bereits DCS-validierte lokale `ARTY`-Rearm-Baseline noch den bereits DCS-validierten Stage-1-Ground-AMMO-Resupply-Pfad.

## 2. Verbindliche Architekturgrenze

```text
Stage-2 OPSZONE adapter
= Bedrohungserkennung / Incident-Lifecycle

MissionDemand
= Demand-, Assignment- und Statusautorität

MOOSE ARMYGROUP / AUFTRAG
= operative Fire-Support-Ausführung

CampaignState
= einzige strategische Ressourcenautorität
```

Für Stage 3 wird **kein zweiter Threat-Detector**, kein Mission-Editor-Trigger und kein eigener Artillerie-Scheduler eingeführt.

Die bereits vorhandenen Stage-2-Reaktionen Guard/QRF/CAS bleiben eigenständige additive Reaktionen. Fire Support ersetzt sie nicht.

## 3. Tatsächlich geprüfter MOOSE-Stand

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden die tatsächlich verwendete `Moose.lua`, die vorhandene OMW-MOOSE-Dokumentation sowie die bereits akzeptierten OMW-Ground-/Fire-Support-Quellen.

## 4. `AUFTRAG:NewARTY(...)`

Der gepinnte Source enthält:

```lua
AUFTRAG:NewARTY(Target, Nshots, Radius, Altitude)
```

Source-seitig bestätigte Semantik:

```text
Target
= MOOSE COORDINATE / target object resolved by AUFTRAG

Nshots
= optionale Schusszahl;
  Werte 0 < Nshots < 1 werden als Anteil verfügbarer Munition interpretiert

Radius
= Streuradius in Metern, Default 100 m

Altitude
= optional

mission category
= GROUND / NAVAL

ROE
= OpenFire
```

Damit existiert ein direkter MOOSE-AUFTRAG-Weg für den geplanten festen Wright-L118-Feuerauftrag. Eine eigene DCS-`FireAtPoint`-Implementierung ist nicht erforderlich und wäre nicht MOOSE-first.

## 5. Vorhandene physische Batterie als `ARMYGROUP`

Der gepinnte Source unterstützt `ARMYGROUP:New(...)` für eine bereits vorhandene MOOSE-`GROUP` beziehungsweise einen Gruppennamen. Ein `ARMYGROUP` übernimmt danach normale `OPSGROUP`-Missionen über:

```lua
armyGroup:AddMission(mission)
```

Der MOOSE-MissionStart-Pfad aktiviert eine als Late Activation vorhandene Gruppe selbst, wenn sie sich noch `InUtero` befindet. Für die Wright-Batterie ist daher kein zusätzlicher nativer DCS-Aktivierungsmechanismus erforderlich.

Stage-3-Grenze:

```text
TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2
-> GROUP
-> ARMYGROUP
-> AUFTRAG:NewARTY(...)
-> ARMYGROUP:AddMission(...)
```

## 6. Reichweite – MOOSE-eigener Vertrag

Der gepinnte Source enthält:

```lua
OPSGROUP:AddWeaponRange(RangeMin, RangeMax, BitType, ConversionToMeters)
OPSGROUP:InWeaponRange(TargetCoord, WeaponBitType, RefCoord)
```

MOOSE weist ausdrücklich darauf hin, dass die Artillerie-Waffenreichweite nicht zuverlässig aus der DCS-API ermittelt werden kann und für `AUFTRAG`-ARTY konfiguriert werden soll.

Wichtig für OMW:

```text
- kein selbst geschriebener Distanzscanner notwendig;
- die bekannte Reichweite wird am MOOSE OPSGROUP/ARMYGROUP konfiguriert;
- die Eignungsprüfung erfolgt mit MOOSE InWeaponRange(...);
- ein numerischer L118-RangeMax wird in Stage 3 nicht erfunden.
```

Der aktuelle Mission-Editor-Nachweis des Owners zeigt Wright->Honaker innerhalb der DCS-Reichweitenanzeige. Das ist ausreichende Evidenz für den geplanten Acceptance-Ort, ersetzt aber noch keinen allgemein verbindlichen numerischen OMW-L118-Range-Vertrag.

## 7. Feste Batterie darf nicht zur Zielreichweite verlegt werden

Der AUFTRAG-ARTY-Pfad kann bei einer Gruppe außerhalb der konfigurierten Reichweite eine Koordinate in Reichweite suchen und einen Bewegungswegpunkt erzeugen.

Für die OMW-Fixed-Fire-Support-Standorte ist das unerwünscht:

```text
fixed battery
-> bleibt am vorgesehenen Standort
-> nur Ziel innerhalb konfigurierte Reichweite zulässig
-> außerhalb Reichweite: Kandidat ablehnen / nächsten Supporter prüfen
```

Der OMW-Dispatch-Adapter führt deshalb **vor** `AUFTRAG:NewARTY(...)` eine MOOSE-basierte Reichweitenprüfung durch und erzeugt bei negativem Ergebnis keinen Auftrag.

## 8. Target-Evidenz

Stage 2 liefert bereits den Angriffskontext über den MOOSE-OPSZONE-Pfad. Die bestehende Stage-2-QRF-Composition verwendet den vom OPSZONE-Scan gelieferten RED-Gruppensatz für konkrete Gegenangriffe.

Stage 3 darf denselben bestehenden Scan-Kontext wiederverwenden:

```text
OPSZONE threat incident
-> vorhandener scanned RED group set
-> konkrete lebende RED Ground target group
-> target coordinate
-> Fire-Support-MissionDemand
-> MOOSE AUFTRAG ARTY
```

Nicht zulässig beziehungsweise nicht erforderlich:

```text
neuer DCS event handler
neuer periodischer Feindscanner
zusätzliche ME Threat-Zone
zusätzlicher Trigger zur Fire-Support-Anforderung
```

## 9. MissionDemand-Erweiterung

Stage 3 ergänzt einen eigenen Demand-Typ:

```text
FIRE_SUPPORT_IMMEDIATE
```

Dies ist bewusst getrennt von:

```text
CAS_IMMEDIATE
RESUPPLY
```

Die aktive Deduplizierung bleibt im vorhandenen `MissionDemand`-Registry-Vertrag. Für einen angegriffenen Standort existiert höchstens ein aktiver Fire-Support-Demand mit:

```text
FIRE_SUPPORT_IMMEDIATE|FOB_ATTACK|<installationId>
```

Es wird kein separater Fire-Support-Dedupe-Ledger eingeführt.

## 10. Lokaler Rearm und strategische Nachversorgung bleiben getrennt

Die bereits akzeptierte lokale Fixed-Fire-Support-Rearm-Kette verwendet weiterhin MOOSE `ARTY` und `GROUND_AMMO_PACKAGE`:

```text
Batterie hat real Munition verschossen
-> lokale MOOSE ARTY-Rearm-Anforderung
-> CampaignState CONSUMPTION
-> quantity = 1 GROUND_AMMO_PACKAGE im akzeptierten Acceptance-Pfad
-> physischer M1083-Rearm
-> OnAfterRearmed
-> CompleteConsumption
```

Der strategische Stage-3-Schluss bleibt davon getrennt:

```text
CampaignState Wright AMMO erreicht bestehenden Reorder-Threshold
-> ResourceDemandPolicy
-> MissionDemand RESUPPLY
-> CampaignState TRANSFER
-> MOOSE Ground AMMOSUPPLY
-> reale Lieferung
-> MarkDelivered
-> MissionDemand SUCCESS
```

`ARTY.OnAfterRearmed` darf den strategischen RESUPPLY-Demand nicht schließen.

## 11. Acceptance-Ziel Honaker -> Wright

Der Owner hat den kombinierten DCS-Test wie folgt festgelegt:

```text
RED-Ground-Gruppen werden im Mission Editor gesetzt
-> bestehende Stage-2-OPSZONE-Erkennung erkennt den Angriff auf Honaker
-> bestehende Guard/QRF-Reaktion läuft weiter
-> Honaker 2B11 ist im Test nicht verfügbar
-> Wright L118 wird als externe Fire-Support-Option verwendet
-> Wright feuert real auf einen vom bestehenden OPSZONE-Kontext erkannten Angreifer
-> lokaler Wright-Rearm verbraucht real 1 GROUND_AMMO_PACKAGE
-> bestehender Wright-Reorder-Threshold wird erreicht
-> strategischer Ground-AMMO-RESUPPLY aus Jalalabad
-> physische Lieferung / Settlement / Demand closure
```

Testkontrollen dürfen den strategischen Wright-AMMO-Startbestand knapp oberhalb des vorhandenen Thresholds setzen. Diese Staging-Änderung ist Acceptance-only und keine Produktions-Policy.

## 12. Noch nicht validiert

Dieser Review beweist **nicht**:

```text
- den neuen Honaker->Wright Fire-Support-Demand in DCS;
- einen allgemeinen numerischen L118-Range-Vertrag;
- die kombinierte Gleichzeitigkeit von QRF + Fire Support + CAS;
- den Wright-Rearm in derselben Stage-3-Laufzeit;
- die automatische Wright-Threshold->RESUPPLY-Verkettung;
- Air-AMMO-Resupply.
```

Für Stage 3 bleibt der bereits DCS-validierte Ground-AMMOSUPPLY-Weg der kleinste belastbare strategische Nachschubpfad. Air-AMMO wäre ein eigener zusätzlicher MOOSE-/CampaignState-Contract und wird nicht stillschweigend in diesen Acceptance-Scope aufgenommen.
