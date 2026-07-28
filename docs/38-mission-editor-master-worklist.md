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
source_branch: agent/document-shindand-air-operations
source_commit: PENDING_MERGE
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

### 4.1 Shindand – dokumentierter Foundation-Build-Stand

Autoritative lokale Dokumente:

- [`OMW-AIR-SHINDAND-MANIFEST`](shindand-air-operations-manifest.md);
- [`OMW-AIR-SHINDAND-IMPLEMENTATION-HANDOFF`](shindand-air-operations-implementation-handoff.md);
- [`OMW-EVIDENCE-SHINDAND-SATELLITE-2013`](evidence/shindand-satellite-observations-2013.md).

Geprüfte Missionsdatei:

```text
OMW_Template(2).miz
SHA-256: 645f09b21793324a1df4d442fbaeffc0d1a2ee7c97f6453a4c3a97dde82c6e00
```

Abgeschlossen:

- [x] Standortcode `SHND` festgelegt;
- [x] aktive lokale ORBAT `8 AH-64D / 8 UH-60 / 4 CH-47` festgelegt;
- [x] `AW_US_SHINDAND` und `WH_AIR_US_SHINDAND` festgelegt;
- [x] vier Clientgruppen und Unitnamen strukturell geprüft;
- [x] fünf KI-Templategruppen und sechs Template-Units strukturell geprüft;
- [x] `Late Activation = true` für alle fünf KI-Templates geprüft;
- [x] neun Luftfahrzeug-Statics strukturell geprüft;
- [x] AH-64A als gewolltes Vanilla-KI-/Static-Ersatzmodell dokumentiert;
- [x] Client-Parkingwerte `6, 8, 12, 28` dokumentiert;
- [x] Warehouse-Anker als Missionsobjekt vorhanden;
- [x] Satellitenbilder 2013 als `POST_PERIOD_CONTEXT` abgegrenzt.

Offen:

- [ ] Runtime-Airbase-Name und Airbase-ID 14 im DCS-/MOOSE-Lauf bestätigen;
- [ ] Warehouse-Erkennung testen;
- [ ] vollständigen Parking-Dump erstellen;
- [ ] finale KI-Allowlist und Blacklist festlegen;
- [ ] vier minimale Funktionszonen anlegen;
- [ ] Payload-, Funk- und Callsign-Baseline festlegen;
- [ ] AIRWING und SQUADRONs registrieren;
- [ ] gemeinsamen UH-60-Pool ohne Doppelbestand implementieren;
- [ ] AUFTRAG- und OPSTRANSPORT-Ausführung testen;
- [ ] Safe Parking und parallele Rückkehr testen;
- [ ] Verlust-, Rückgabe- und Disconnect-Logik testen;
- [ ] dynamische Static-/Rampenumverteilung separat abnehmen.

```yaml
mission_editor_structure: PASS
runtime_validation: NOT_RUN
validated_in_dcs: false
```

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

## 12. Abschlussregel

Ein Objektpaket ist erst produktionsreif, wenn:

- sein zuständiges Manifest und seine Source of Truth geklärt sind;
- Namens-, Bestands- und Zonenprüfung bestanden wurden;
- MOOSE-Konstruktion reproduzierbar funktioniert;
- Start, Rückkehr, Verlust und Abbruch geprüft wurden;
- keine Kollisionen oder Doppelzählungen bestehen;
- der exakt getestete Stand dokumentiert ist.
