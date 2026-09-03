---
document_id: OMW-C2-TAD-COLOR-NETS
status: BINDING
document_class: SOURCE_DERIVED_DATASET
source_status: SOURCE_CAPTURE_COMPLETE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW logical TAD and Color Net frequency plan
  - stable logical radio-net names for Mission Editor and runtime use
  - fixed airborne UAV-JTAC service allocations
  - current player-radio preset planning rules captured in this document
not_authoritative_for:
  - historical COMPLAN, ATO or SPINS frequencies
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - REFERENCE used as governance document status
superseded_by:
source_branch: agent/radio-preset-foundation
source_commit: GIT_HISTORY
validated_in_dcs: false
---

# 28 – Afghanistan TAD- und Color-Net-Frequenzplan

## 1. Einordnung

Dieses Dokument ist der verbindliche logische Frequenz- und Netzplan für **Operation Mountain Watch**. Die zugrunde liegende Zusammenstellung stammt von **Graveyard of Empires** und wird nach `OMW-GOV-SOURCE-USE` attribuiert und verwendet.

Der vollständige Quellen-, Tabellen- und Auswertungstext bleibt unverändert erhalten:

- [`Legacy-Frequenzplan mit vollständigen Tabellen`](evidence/source-records/legacy-28-afghanistan-tad-color-nets-source-capture.md)

Die inzwischen konsolidierte OMW-Frequenzmatrix ist für die Preset-Arbeit maßgeblich. Bereits festgelegte DCS-Szenery-/ATC-, AAR-, C2-, CSAR/PR-, FARP-, Ground-, Rotary- und JTAC/FAC/AFAC-Werte werden bei der Presetplanung nicht erneut aus historischen Vergleichsquellen abgeleitet.

## 2. Datensatzumfang

```yaml
color_net_groups: 8
slots_per_group: 20
unique_assignments: 160
airfield_radio_locations: 14
source_reference_version: v1.0
source_reference_date: 2025-10-17
omw_workbook_version: v1.3
```

Verwendete OMW-Color-Gruppen:

```text
Aqua
Brass
Carmine
Green
Khaki
Lemon
Purple
Zinc
```

Die kompakte OMW-Matrix umfasst damit `8 x 20 = 160` vollständig belegte Color-Adressen.

## 3. Verbindliche Projektregeln

- `TAD` bedeutet in diesem Kontext **Tactical Air Direction**.
- Logische Netznamen bleiben stabil, auch wenn eine numerische Frequenz später geändert werden muss.
- JTAC-, C2-, Flugplatz-, Tanker-, Package- und sonstige taktische Netze werden funktional getrennt.
- Eine Frequenz darf innerhalb desselben operativen Raums nicht widersprüchlich mehrfach belegt werden.
- Für OMW bereits aus dem aktuellen DCS-Afghanistan-Terrain übernommene Flugplatzfrequenzen gelten als Missionsdesign-Baseline; abweichende historische AIP-Werte eröffnen diese DCS-Werte nicht erneut.
- Die Werte sind ein DCS-Missionsdesign-Datensatz und keine Behauptung realer historischer COMPLAN-/ATO-/SPINS-Frequenzen.
- Ein Color-Code ist ein opaker Alias auf eine physische Frequenz. `Color != Service != Band != Modulation != Geography`.
- Nicht alle 160 Color-Frequenzen werden in jedem Spielerluftfahrzeug als Preset programmiert. Presets bilden die muster-, basis- und rollenrelevanten Schnellzugriffe ab.

## 4. Technische Verwendung

Der Datensatz darf verwendet werden für:

- Mission-Editor-Frequenzen und Presets;
- KI-Fluggruppen und `AIRWING`-/`SQUADRON`-Konfiguration;
- Spielerbriefings und Kneeboards;
- F10-Menüs, ATIS, FAC/JTAC und Package Coordination;
- spätere maschinenlesbare Radio-Net-Konfigurationen.

## 5. Noch erforderliche Validierung

- DCS-Frequenzbereiche und Modulationsarten je Luftfahrzeug;
- Multiplayer- und SRS/VoiceChat-Verhalten;
- vollständige Preset-Belegung je Modul;
- versionsbezogene ATIS-, FAC-, Tanker- und AWACS-Tests.

Ein Eintrag in dieser Dokumentation ist kein DCS-Runtime-Nachweis. `validated_in_dcs` bleibt für diesen Dokumentstand `false`.

## 6. Verbindlicher JTAC/FAC/AFAC/UAV-JTAC-Pool

Der genehmigte UHF-AM-Servicepool lautet:

```text
229.400
246.700
262.300
278.600
293.400
309.700
321.400
339.400
352.400
371.300 MHz AM
```

Am 03.09.2026 hat der Projektinhaber vier nicht zusammenhängende Kanäle daraus verbindlich den aktuell vorhandenen fliegenden UAV-JTAC/FAC-Templates zugeordnet:

| Basis | Plattform | operativer FAC/JTAC-Callsign | Frequenz | OMW Color |
|---|---|---|---:|---|
| Bagram | MQ-1A | `Jaguar` | **229.400 AM** | `Purple 13` |
| Kandahar | MQ-1A | `Pointer` | **278.600 AM** | `Brass 2` |
| Kandahar | MQ-9 | `Hammer` | **321.400 AM** | `Aqua 10` |
| Jalalabad | MQ-1A | `Firefly` | **371.300 AM** | `Carmine 3` |

Diese vier Frequenzen sind damit keine dynamischen Poolkanäle mehr, sondern feste airborne UAV-JTAC/FAC-Servicekanäle.

Im dynamischen JTAC/FAC/AFAC-Pool verbleiben:

```text
246.700
262.300
293.400
309.700
339.400
352.400 MHz AM
```

Die normalen DCS-Fluggruppen-Callsigns der UAV-Templates sind nicht mit den operativen FAC/JTAC-Callsigns gleichzusetzen. Die FAC/JTAC-Identität ist für den jeweiligen FAC-Auftrag separat zu setzen. Die konkrete Runtime-Implementierung wird erst bei der zuständigen MOOSE-/Mission-Integration vorgenommen und danach in DCS geprüft.

## 7. Aktuelle Spieler-Preset-Doktrin

Für die laufende Presetplanung gelten folgende bereits entschiedenen Regeln:

```text
P01 = HOME
```

Für die Theater-C2-Merkposition gilt:

```text
Presetbank mit mindestens 11 Plätzen: P11 = WIZARD / Theater C2
Presetbank mit genau 10 Plätzen:      P10 = WIZARD / Theater C2
```

Weitere Grundsätze:

- Presets werden in klar erkennbaren Funktionsblöcken organisiert, nicht als unsortierte Prioritätsliste.
- Fixed-Wing-Airfield-Presets enthalten nur für das konkrete Muster sinnvoll nutzbare Divert-/Recovery-Plätze.
- F-16CM und F-15E verwenden Shindand nicht als festen Divert-Preset.
- A-10C II darf Shindand als festen Divert berücksichtigen.
- Rotary-Wing-Diverts werden regional und reichweiten-/flugzeitbezogen geplant; theaterweit entfernte, operativ unplausible Ausweichplätze werden nicht nur wegen vorhandener ATC-Frequenzen programmiert.
- STANDARD-AAR-Tracks dürfen als feste Presets vorgesehen werden.
- RESERVE-/Spare-Tanker `LISA` und `MOE` erhalten keine festen Standard-Presets; bei Aktivierung werden Frequenz beziehungsweise Color-Code durch C2/ATO/Briefing bekanntgegeben.
- Die vier festen UAV-JTAC/FAC-Kanäle aus Abschnitt 6 dürfen in für CAS/ISR relevante Spieler-Presetbänke aufgenommen werden.
- Dynamische Mission-/JTAC-Kanäle bleiben als freie beziehungsweise auftragsbezogene Zuweisungen erhalten.

Die vollständige Presetnummerierung pro Muster und Basis ist noch in Arbeit und wird erst nach Abschluss der jeweiligen Radio-Bank-Prüfung als vollständig belegt betrachtet.
