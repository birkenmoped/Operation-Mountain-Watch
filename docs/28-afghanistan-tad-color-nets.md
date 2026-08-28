---
document_id: OMW-C2-TAD-COLOR-NETS
status: BINDING
document_class: SOURCE_DERIVED_DATASET
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW logical TAD and Color Net frequency plan
  - stable logical radio-net names for Mission Editor and runtime use
not_authoritative_for:
  - historical COMPLAN, ATO or SPINS frequencies
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - REFERENCE used as governance document status
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 28 – Afghanistan TAD- und Color-Net-Frequenzplan

## 1. Einordnung

Dieses Dokument ist der verbindliche logische Frequenz- und Netzplan für **Operation Mountain Watch**. Die zugrunde liegende Zusammenstellung stammt von **Graveyard of Empires** und wird nach `OMW-GOV-SOURCE-USE` attribuiert und verwendet.

Der vollständige Quellen-, Tabellen- und Auswertungstext bleibt unverändert erhalten:

- [`Legacy-Frequenzplan mit vollständigen Tabellen`](evidence/source-records/legacy-28-afghanistan-tad-color-nets-source-capture.md)

## 2. Datensatzumfang

```yaml
color_net_groups: 20
slots_per_group: 20
unique_assignments: 400
airfield_radio_locations: 14
source_version: v1.0
source_date: 2025-10-17
```

## 3. Verbindliche Projektregeln

- `TAD` bedeutet in diesem Kontext **Tactical Air Direction**.
- Logische Netznamen bleiben stabil, auch wenn eine numerische Frequenz später geändert werden muss.
- JTAC-, C2-, Flugplatz-, Tanker-, Package- und sonstige taktische Netze werden funktional getrennt.
- Eine Frequenz darf innerhalb desselben operativen Raums nicht widersprüchlich mehrfach belegt werden.
- Flugplatzfrequenzen und DCS-AI-Funkstellen werden gegen die aktuelle DCS-Version geprüft.
- Die Werte sind ein DCS-Missionsdesign-Datensatz und keine Behauptung realer historischer COMPLAN-/ATO-/SPINS-Frequenzen.

## 4. Technische Verwendung

Der Datensatz darf verwendet werden für:

- Mission-Editor-Frequenzen und Presets;
- KI-Fluggruppen und `AIRWING`-/`SQUADRON`-Konfiguration;
- Spielerbriefings und Kneeboards;
- F10-Menüs, ATIS, FAC/JTAC und Package Coordination;
- spätere maschinenlesbare Radio-Net-Konfigurationen.

## 5. Noch erforderliche Validierung

- DCS-Frequenzbereiche und Modulationsarten je Luftfahrzeug;
- Überschneidungen mit Karten-/Flugplatzfunkstellen;
- Multiplayer- und SRS/VoiceChat-Verhalten;
- Preset-Belegung je Modul;
- versionsbezogene ATIS-, FAC-, Tanker- und AWACS-Tests.
