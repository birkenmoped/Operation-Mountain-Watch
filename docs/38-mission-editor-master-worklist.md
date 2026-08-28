---
document_id: OMW-ME-MASTER-WORKLIST
status: BINDING
document_class: WORKLIST
owning_policy: OMW-GOV-001
authoritative_for:
  - project-wide Mission Editor foundation-build worklist
  - required authoring metadata and validation evidence
  - separation of Mission Editor, campaign-domain and MOOSE responsibilities
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - incomplete or prototype-only Mission Editor worklists
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 38 – Missionseditor-Masterarbeitsliste

## 1. Zweck und Abgrenzung

Diese Arbeitsliste ist die projektweite Foundation-Build-Grundlage für Objekte, Zonen, Marker, Templates und Metadaten im DCS Mission Editor.

Maßgebliche Grundlagen:

- [`OMW-GOV-001`](00-project-governance.md);
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md);
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md);
- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md);
- [`OMW-AIR-ME-WORKLIST`](20-air-orbat-mission-editor-worklist.md).

Der vollständige frühere Arbeitsstand bleibt unverändert erhalten:

- [`Legacy-Masterarbeitsliste`](evidence/source-records/legacy-38-mission-editor-master-worklist-pre-governance.md)

## 2. Grundregeln

- stabile, eindeutige Namen ohne automatische Umnummerierung;
- keine Doppelbestände durch Client-Gruppen, Templates, aktive Gruppen und Statics;
- jede physische Einheit benötigt einen CampaignState- oder MissionDemand-Bezug;
- keine technische Funktion als validiert kennzeichnen, bevor ein reproduzierbarer DCS-Test vorliegt;
- branchgebundene Tests nicht als allgemeine `main`-Acceptance darstellen;
- MOOSE-Funktionen vor eigener Lua-Logik prüfen;
- Nicht-MOOSE-Ausnahmen nur mit ausdrücklicher Projektinhaberfreigabe.

## 3. Benennungsfamilien

```text
OMW_BLUE_AIRBASE_...
OMW_BLUE_FOB_...
OMW_BLUE_FARP_...
OMW_BLUE_WH_...
OMW_BLUE_ARTY_...
OMW_BLUE_PATROL_...
OMW_RED_HQ_...
OMW_RED_DIST_...
OMW_RED_HIDE_...
OMW_RED_CACHE_...
OMW_RED_TRANSFER_...
OMW_RED_ROUTE_...
OMW_SETTLEMENT_...
OMW_DELIVERY_...
OMW_HUMINT_...
```

Fachspezifische bestehende Namen wie `AW_US_...`, `SQ_US_...`, `CLIENT_US_...`, `TPL_AIR_US_...`, `STATIC_AIR_US_...` und `ZONE_AIR_US_...` bleiben in den zuständigen Manifesten verbindlich.

## 4. Flugplätze und Luftoperationsknoten

Für jeden Knoten sind zu dokumentieren und zu prüfen:

### Stammdaten

- [ ] DCS-Airbase-Name und ID;
- [ ] Koalition und Land;
- [ ] zuständiger `AIRWING`;
- [ ] `COMMANDER`-Zuordnung;
- [ ] Warehouse-Anker und DCS-Airbase-Bezug;
- [ ] Parkpositionen und Größenklassen;
- [ ] Taxiwege und bekannte KI-Probleme;
- [ ] Spawn- und Recovery-Verfahren.

### Client-Gruppen

- [ ] Anzahl ausschließlich nach Dokument 19;
- [ ] ein Luftfahrzeug je Client-Gruppe;
- [ ] eindeutige Gruppen- und Einheitennamen;
- [ ] Cold-/Hot-Start nach lokaler Baseline;
- [ ] Multicrew und Modulabhängigkeiten dokumentieren;
- [ ] keine Wiederverwendung als KI-Template.

### KI-Templates und SQUADRONs

- [ ] `Late Activation`;
- [ ] Gruppengröße und MOOSE-Asset-Zahl dokumentieren;
- [ ] Rollen, Payloads, Liveries und Treibstoff definieren;
- [ ] Startpositionen gegen Blockierung testen;
- [ ] Hubschrauberoptionen wie `SetOptionPreferVertical()` versionsbezogen prüfen;
- [ ] Templatebestand nicht als zusätzlichen Kampagnenbestand zählen.

### Statics

- [ ] sichtbare Zielzahl je Typ;
- [ ] Bestandsbezug und Obergrenze;
- [ ] getrennte Rampflächen;
- [ ] Kollisions- und Rotorabstände;
- [ ] Verlustzuordnung zum CampaignState;
- [ ] keine sofortige sichtbare Nachbesetzung ohne genehmigten Ramp-Zyklus.

## 5. FOBs, COPs, OPs und Bodenkräfte

- [ ] stabile Standort-ID und Anzeigename;
- [ ] Zonen, Anker und Template-Gruppe;
- [ ] Garnison, Bereitschaft und Ressourcen;
- [ ] Warehouse, Munition und Treibstoff;
- [ ] Straßen-, Luft- und Fußzugang;
- [ ] Patrouillen- und QRF-Bereiche;
- [ ] Landezonen, Slingload- und Entladepunkte;
- [ ] Schadens-, Wiederaufbau- und Verlustzustände;
- [ ] zugeordnete `BRIGADE`, `PLATOON`, `ARMYGROUP` oder `OPSGROUP`-Struktur.

## 6. Routen und Logistik

- [ ] MSR-/ASR-Segmente nach Dokument 49;
- [ ] `PATHLINE`s und Routinganker getrennt erfassen;
- [ ] Brücken, Furten, Engstellen, Tore und Übergabepunkte markieren;
- [ ] Assembly Areas und Withdrawal Points;
- [ ] alternative Routen und Sperrbedingungen;
- [ ] Fahrzeug- und Infanterieeignung;
- [ ] `Core.Astar`, MOOSE-Routing und `OPSTRANSPORT` prüfen;
- [ ] keine ungeprüfte Offroad-Navigation voraussetzen.

## 7. RED-Netzwerk

- [ ] HQ, Verteilerdepots, Hide Sites und Caches;
- [ ] Candidate Sites mit Metadaten;
- [ ] Kommando-, Bewegungs- und Personalnetze getrennt erfassen;
- [ ] Guard Floor, Readiness Target und Hard Capacity;
- [ ] alternative Versorgungswege;
- [ ] Materialisierungs- und Dematerialisierungsanker;
- [ ] keine Übergänge in Sichtweite von Spielern;
- [ ] Tracking-, Aufklärungs- und Kampfzustände berücksichtigen.

## 8. Aufklärung, C2 und Targeting

- [ ] JTAC-/FAC-/AFAC-/ASOC-Knoten;
- [ ] Callsigns und Frequenznetze aus den zuständigen Referenzen;
- [ ] Sensor- und Beobachtungszonen;
- [ ] HUMINT-, SIGINT- und Visual-Exposure-Metadaten;
- [ ] gestufte Erkenntniszustände;
- [ ] No-Strike-List-Daten in die Zielprüfung einbinden;
- [ ] positive Zielbestätigung und ziviles Umfeld dokumentieren;
- [ ] keine Zielnominierung ohne NSL-Prüfung.

## 9. CSAR und medizinische Infrastruktur

- [ ] Rettungseinrichtungen und Coverage-Radien;
- [ ] CSAR-/MEDEVAC-Basen und Bereitschaftspositionen;
- [ ] Funkbaken, Authentifizierung und Duress-Anforderungen;
- [ ] Landezonen und Hot-and-high-Grenzen;
- [ ] medizinische Rollen und Übergabepunkte;
- [ ] Spieler- und KI-Reservierung desselben `CSARIncident` synchronisieren;
- [ ] keine Doppelrettung zulassen.

## 10. Wetter und Umgebungsprofile

- [ ] historische Baseline nach Dokument 41;
- [ ] DCS-Editor-Grenzen nach Dokument 42;
- [ ] Regen-/Schauerprofil nach Dokument 43;
- [ ] Talnebel-/Tiefe-Wolken-Profil nach Dokument 44;
- [ ] Sichtweite, Wolkenbasis, Wind und Temperatur pro Test dokumentieren;
- [ ] Flugplatz-, Hubschrauber- und KI-Verhalten separat validieren.

## 11. Pflichtnachweise je Arbeitspaket

```text
OMW branch
OMW commit
Missionsdatei
Mission SHA-256
Bundle-Datei
Bundle SHA-256
DCS-Version
MOOSE branch/release
MOOSE commit
Moose.lua SHA-256
Testbedingungen
Erwartete Logmeldungen
Beobachtetes Ergebnis
Offene Einschränkungen
```

## 12. Aktueller Foundation-Integrationsstand der Mission

Stand der Übergabe ist `main` nach Merge von PR #110 mit Commit:

```text
2512ad3cd03606e146d0e238a468cd5bdc1c9965
```

Die zuletzt strukturell geprüfte Mission ist:

```text
OMW_Template_v14_ground_test(8).miz
SHA-256: d16583aaa69b2dbf17fd65c003295649f2c67fc54744fcc5d25920a44e3fd9e5
```

Diese MIZ-Prüfung bestätigt die Mission-Editor-Verdrahtung der nachfolgend beschriebenen Production-Bases. Sie ist kein neuer vollständiger DCS-Runtime-Acceptance-Nachweis.

### 12.1 Production-Bases und Abhängigkeiten

Die produktive Foundation ist derzeit wie folgt aufgebaut:

```text
Moose.lua
   |
   +-- OMW_AirOps_Warehouse_Base.lua
   |      +-- gemeinsamer OMW.AirOps.CampaignContext
   |      |     +-- store
   |      |     +-- campaignState
   |      |     `-- restored
   |      `-- OMW_WAREHOUSE_READY = 1
   |
   +-- OMW_Ground_Base.lua
   |      +-- Attach an denselben CampaignState/store
   |      `-- OMW_GROUND_READY = 1
   |
   +-- OMW_AAR_Base.lua
   |      `-- produktive AAR-Runtime
   |
   `-- AirOps Foundations
          +-- Bagram
          +-- Kandahar
          +-- Jalalabad
          +-- Salerno
          +-- Tarinkot
          `-- Shindand
```

CampaignState bleibt die einzige strategische Ressourcenautorität. Ground, AAR, MOOSE Warehouse/STORAGE und die AirOps-Foundations dürfen keine parallele strategische Ressourcenhoheit erzeugen.

### 12.2 Builder und produktive Artefakte

Die wiederverwendbaren Bundles werden lokal aus den versionierten Quellen gebaut. Die generierten `dist`-Artefakte sind Buildprodukte und nicht die strategische Source of Truth.

```text
Warehouse / CampaignState
Builder:  tools/build-air-ops-warehouse-production-base.ps1
MIZ:      OMW_AirOps_Warehouse_Base.lua

Ground
Builder:  tools/build-ground-production-base.ps1
MIZ:      OMW_Ground_Base.lua

AAR
Builder:  tools/build-aar-production-base.ps1
MIZ:      OMW_AAR_Base.lua

AirOps Foundations
Builder:  tools/build-bagram-air-operations-foundation.ps1
Builder:  tools/build-kandahar-air-operations-foundation.ps1
Builder:  tools/build-jalalabad-air-operations-foundation.ps1
Builder:  tools/build-salerno-air-operations-foundation.ps1
Builder:  tools/build-tarinkot-air-operations-foundation.ps1
Builder:  tools/build-shindand-air-operations-foundation.ps1
```

Der zuletzt durch den Projektinhaber real verifizierte Ground-Production-Build war:

```text
BuilderVersion: OMW-GROUND-PRODUCTION-BASE-1
Bundle: mission/ground-operations/dist/OMW_Ground_Base.lua
Length: 23038 bytes
SHA-256: 1ff2a48219dd3cb8e1d1d7ba7a7ac93b6a94b581b4daff068b39d0a06a7e0291
```

### 12.3 Aktuelle MIZ-Startup-Reihenfolge

Die zuletzt geprüfte v14-MIZ verwendet folgende Staffelung:

```text
T+0   LOAD_MOOSE
      -> Moose.lua

T+1   LOAD_AIROPS_WAREHOUSE_BASE
      -> OMW_AirOps_Warehouse_Base.lua
      -> OMW_WAREHOUSE_READY = 1 nach erfolgreichem Bootstrap

T+2   LOAD_GROUND_BASE
      Bedingung: OMW_WAREHOUSE_READY == 1
      -> OMW_Ground_Base.lua
      -> OMW.Ground.Base.Attach(...)
      -> OMW_GROUND_READY = 1

T+5   LOAD_AAR_BASE
      Bedingung: OMW_WAREHOUSE_READY == 1
      -> OMW_AAR_Base.lua

T+6   LOAD_TM01M
      -> bestehender älterer Ground/Convoy-Pfad; produktive Rolle noch zu reconciliieren

T+8   LOAD_AIROPS_BAGRAM
T+11  LOAD_AIROPS_KANDAHAR
T+14  LOAD_AIROPS_JALALABAD
T+17  LOAD_AIROPS_SALERNO
T+20  LOAD_AIROPS_TARINKOT
T+24  LOAD_AIROPS_SHINDAND
```

Die Zeitwerte staffeln nur den Startup. Die fachlich relevanten Sicherheitsbedingungen sind die Ready-Gates und der gemeinsame CampaignState-Kontext.

### 12.4 Ground-Foundation

Aktive strategische Ground-Nodes:

```text
GROUND_NODE_JALALABAD
GROUND_NODE_FORTRESS
GROUND_NODE_JOYCE
GROUND_NODE_WRIGHT
GROUND_NODE_HONAKER
GROUND_NODE_BOSTICK
```

Der akzeptierte aktuelle Motorized-Patrol-Ressourcenvertrag lautet:

```text
1 M-ATV = 1 VEHICLE + 3 PERSONNEL
```

Die Ground-Foundation deckt den strategischen Pfad von Ressourcenbindung, physischer Materialisierung und Mission bis Settlement, Return/Loss und Restart-Reconciliation ab. DCS-Gruppen bleiben temporäre physische Repräsentationen; CampaignState bleibt autoritativ.

Fortress und Honaker-Miracle sind inzwischen in den Ground-Initialbeständen enthalten. Der aktuelle Production-Stock lautet:

```text
FORTRESS
PERSONNEL = 160
VEHICLE   = 18
SUPPLY    = 44
AMMO      = 48
FUEL      = 40

HONAKER
PERSONNEL = 120
VEHICLE   = 18
SUPPLY    = 40
AMMO      = 40
FUEL      = 36
```

### 12.5 Ground-Templates und Fixed Fire Support

Die wiederverwendbaren Ground-Templates umfassen unter anderem motorisierte Patrouillen, gemischte Fahrzeuggruppen und Infanterie. Die 9-Mann-Rifle-Squad ist als eigener physischer Baustein vorgesehen, etwa für Fußpatrouillen, OP-Ablösung oder späteren Dismount aus einem Convoy.

Standortgebundene Fire-Support-Gruppen bleiben Mission-Editor-Assets an ihren exakt gesetzten Stellungen und werden von `OMW_Ground_Base.lua` nicht generisch gespawnt, verschoben oder ersetzt:

```text
TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1
TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2
TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2
```

Für Fortress wird konservativ eine einzelne L118 als DCS-Proxy für die belegte lokale 105-mm-Fähigkeit geführt. Aus der historischen/visuellen Evidenz wird keine zweite Haubitze abgeleitet.

### 12.6 Erreichter und noch offener Integrationsstand

Als Foundation vorhanden und auf `main` integriert sind:

```text
MOOSE framework
CampaignState foundation
AirOps Warehouse Production Base
Ground Production Base
AAR Production Base
Bagram AirOps Foundation
Kandahar AirOps Foundation
Jalalabad AirOps Foundation
Salerno AirOps Foundation
Tarinkot AirOps Foundation
Shindand AirOps Foundation
Ground nodes and Ground resource contracts
Ground templates including infantry and fixed fire support
```

`READY` beziehungsweise vorhandene Production-Foundation bedeutet nicht, dass die vollständige dynamische Kampagne abgeschlossen ist. Der nächste große Integrationsblock ist die Orchestrierung über MissionDemand/ATO/COMMANDER zwischen den bereits vorhandenen AirOps-, AAR- und Ground-Foundations.

Der Trigger `LOAD_TM01M` ist als separater offener Reconciliation-Punkt zu behandeln. Vor einer endgültigen Production-MIZ ist zu prüfen, welche Funktion davon weiterhin produktiv benötigt wird und welche Teile inzwischen durch die aktuelle Ground-Foundation ersetzt wurden.

Weitere neue DCS-Runtime-Prüfungen dieser Foundation-Phase sollen nach Projektinhaberentscheidung nur noch als gebündelte Integrations-/Sammelmission erfolgen, nicht als neue isolierte Einzelabnahmen.

## 13. Abschlussregel

Ein Objektpaket ist erst produktionsreif, wenn:

- sein zuständiges Manifest und seine Source of Truth geklärt sind;
- Namens-, Bestands- und Zonenprüfung bestanden wurden;
- MOOSE-Konstruktion reproduzierbar funktioniert;
- Start, Rückkehr, Verlust und Abbruch geprüft wurden;
- keine Kollisionen oder Doppelzählungen bestehen;
- der exakt getestete Stand dokumentiert ist.
