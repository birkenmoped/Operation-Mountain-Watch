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
  - player radio preset design baseline
not_authoritative_for:
  - historical COMPLAN, ATO or SPINS frequencies
  - DCS runtime validation of the preset implementation
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

Die konsolidierte OMW-Frequenzmatrix ist für die Preset-Arbeit maßgeblich. Bereits festgelegte DCS-Szenery-/ATC-, AAR-, C2-, CSAR/PR-, FARP-, Ground-, Rotary- und JTAC/FAC/AFAC-Werte werden bei der Presetplanung nicht erneut aus historischen Vergleichsquellen abgeleitet.

## 2. Datensatzumfang

```yaml
color_net_groups: 8
slots_per_group: 20
unique_assignments: 160
airfield_radio_locations: 14
source_reference_version: v1.0
source_reference_date: 2025-10-17
omw_workbook_version: v1.4
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
- Nicht alle 160 Color-Frequenzen werden in jedem Spielerluftfahrzeug als Preset programmiert. Presets bilden muster-, basis- und rollenrelevante Schnellzugriffe ab.

## 4. Technische Verwendung

Der Datensatz darf verwendet werden für:

- Mission-Editor-Frequenzen und Presets;
- KI-Fluggruppen und `AIRWING`-/`SQUADRON`-Konfiguration;
- Spielerbriefings und Kneeboards;
- F10-Menüs, ATIS, FAC/JTAC und Package Coordination;
- spätere maschinenlesbare Radio-Net-Konfigurationen.

## 5. Noch erforderliche Validierung

- tatsächliche Eintragung der Presets in die Player-Gruppen der Mission;
- DCS-Frequenzbereiche und Modulationsarten je Luftfahrzeug im aktuellen Modulstand;
- Multiplayer- und SRS/VoiceChat-Verhalten;
- versionsbezogene ATIS-, FAC-, Tanker- und AWACS-Tests.

Ein Eintrag in dieser Dokumentation oder im Workbook ist kein DCS-Runtime-Nachweis. `validated_in_dcs` bleibt für diesen Dokumentstand `false`.

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

Diese vier Frequenzen sind feste airborne UAV-JTAC/FAC-Servicekanäle. Im dynamischen JTAC/FAC/AFAC-Pool verbleiben:

```text
246.700
262.300
293.400
309.700
339.400
352.400 MHz AM
```

Die normalen DCS-Fluggruppen-Callsigns der UAV-Templates sind nicht mit den operativen FAC/JTAC-Callsigns gleichzusetzen. Die FAC/JTAC-Identität ist für den jeweiligen FAC-Auftrag separat zu setzen. Die konkrete Runtime-Implementierung wird bei der zuständigen MOOSE-/Mission-Integration vorgenommen und danach in DCS geprüft.

## 7. Spieler-Preset-Doktrin

Für die Presetplanung gelten folgende Regeln:

```text
P01 = HOME, soweit der jeweilige Funkbereich den HOME-Dienst tragen kann
```

Für die Theater-C2-Merkposition gilt auf einer UHF-fähigen Bank:

```text
Presetbank mit mindestens 11 Plätzen: P11 = WIZARD / Theater C2
Presetbank mit genau 10 Plätzen:      P10 = WIZARD / Theater C2
```

Weitere Grundsätze:

- Presets werden in klar erkennbaren Funktionsblöcken organisiert, nicht als unsortierte Prioritätsliste.
- Fixed-Wing-Airfield-Presets enthalten nur für das konkrete Muster sinnvoll nutzbare Divert-/Recovery-Plätze.
- F-16CM und F-15E verwenden Shindand nicht als festen Divert-Preset.
- A-10C II darf Shindand als festen Divert berücksichtigen.
- Rotary-Wing-Diverts werden regional und reichweiten-/flugzeitbezogen geplant; theaterweit entfernte Ausweichplätze werden nicht nur wegen vorhandener ATC-Frequenzen programmiert.
- STANDARD-AAR-Tracks dürfen als feste Presets vorgesehen werden.
- RESERVE-/Spare-Tanker `LISA` und `MOE` erhalten keine festen Standard-Presets; bei Aktivierung werden Frequenz beziehungsweise Color-Code durch C2/ATO/Briefing bekanntgegeben.
- Die vier festen UAV-JTAC/FAC-Kanäle aus Abschnitt 6 werden in für CAS/ISR relevante Presetbänke aufgenommen.
- Dynamische Mission-/JTAC-Kanäle bleiben als freie beziehungsweise auftragsbezogene Zuweisungen erhalten.
- Die DCS-Szenery-Frequenz `121.500 AM` des Shindand Heliport wird wegen der geschützten VHF-Guard-Frequenz nicht als Player-Preset verwendet.

## 8. Aktueller v21-Player-/Radio-Scope

Arbeitsgrundlage für die vollständige Presetplanung ist:

```text
Mission: OMW_Template_v21_GroundWorks(2).miz
SHA-256: 24BD36CB608881C9AA0DB8B04A8F06424B85BB34B6DD23A5A88CEA272FB60B1C
```

Die Mission enthält 37 Client-Luftfahrzeuge der folgenden Preset-relevanten Muster:

| Muster | aktuelle Client-Basen |
|---|---|
| F-16C_50 | Bagram |
| F-15ESE | Bagram |
| A-10C_2 | Kandahar |
| C-130J-30 | Bagram, Kandahar |
| AH-64D_BLK_II | Jalalabad, Kandahar, Salerno, Shindand, Tarin Kowt |
| OH58D | Jalalabad, Kandahar, Salerno |
| CH-47Fbl1 | Bagram, Jalalabad, Kandahar, Salerno, Shindand, Tarin Kowt |

Aus der aktuellen v21-Mission sind folgende Presetbank-Strukturen direkt serialisiert:

| Muster | Radio / Bank | Presets | Bereich |
|---|---|---:|---|
| F-16C_50 | COMM1 | 20 | UHF AM |
| F-16C_50 | COMM2 | 20 | VHF AM |
| F-15ESE | Radio 1 | 20 | UHF AM |
| F-15ESE | Radio 2 | 40 | V/UHF AM |
| A-10C_2 | ARC-210 | 25 | Multiband; P01-P20 AM, P21-P25 FM im aktuellen Missionsstand |
| A-10C_2 | ARC-164 | 20 | UHF AM |
| A-10C_2 | ARC-186 | 20 | VHF FM |
| AH-64D_BLK_II | VHF AM | 10 | VHF AM |
| AH-64D_BLK_II | UHF AM | 10 | UHF AM |
| AH-64D_BLK_II | FM1 | 10 | VHF FM |
| AH-64D_BLK_II | FM2 | 10 | VHF FM |
| OH58D | UHF | 20 | UHF AM |
| OH58D | VHF AM | 20 | VHF AM |
| OH58D | FM1 | 21 | VHF FM, so in v21 serialisiert |
| OH58D | FM2 | 21 | VHF FM, so in v21 serialisiert |
| CH-47Fbl1 | Radio 1 | 20 | FM |
| CH-47Fbl1 | Radio 2 | 20 | UHF AM |
| CH-47Fbl1 | Radio 3 | 10 | FM |
| C-130J-30 | Radio 1 | 20 | UHF AM |
| C-130J-30 | Radio 2 | 10 | VHF AM |

Für den C-130J-30 besteht zusätzlich frühere Mission-Editor-Evidenz für zwei UHF- und zwei VHF-Radios (`UHF-1/UHF-2` mit je 20 sowie `VHF-1/VHF-2` mit je 10 Presets). Da v21 nur eine UHF- und eine VHF-Presetliste serialisiert, werden die zweiten Banken im Workbook als **gespiegelte Planungsbanken** geführt und vor einer ME-Bindung erneut am aktuellen C-130-Modul geprüft. Sie werden nicht als unabhängig in v21 nachgewiesene Presetlisten ausgegeben.

Beim CH-47F ist in v21 keine separate VHF-AM-Presetbank serialisiert. Eine solche Bank wird deshalb in der aktuellen Presetbaseline nicht erfunden.

## 9. Vollständige Player-Preset-Arbeitsbaseline

Die vollständigen Einzelbelegungen stehen in `OMW_Radio_Frequency_Master_v1.4.xlsx` auf jeweils eigenen Muster-Arbeitsblättern:

```text
PRESET F-16CM
PRESET F-15E
PRESET A-10C II
PRESET C-130J-30
PRESET AH-64D
PRESET OH-58D
PRESET CH-47F
```

Jede Zeile führt mindestens Basis, Funkgerät/Bank, Presetnummer, Funktion/Netz, Frequenz, Modulation, OMW-Color-Alias und Status beziehungsweise Hinweis.

### 9.1 F-16CM und F-15E – Bagram

Der feste UHF-Kern besteht aus:

```text
HOME / geeignete Jet-Diverts
-> STANDARD AAR
-> CSAR/PR
-> P11 WIZARD
-> feste UAV-JTAC/FAC
-> dynamische Mission-/JTAC-Kanäle
```

Feste Jet-Diverts für beide Bagram-Fighter sind ausschließlich:

```text
Bagram
Kabul
Kandahar
Camp Bastion
```

Shindand ist für F-16CM und F-15E ausdrücklich kein fester Divert-Preset.

### 9.2 A-10C II – Kandahar

Die A-10-Baseline nutzt die drei Funkgeräte ihrer jeweiligen Funktion entsprechend. Feste Recovery-/Divert-Plätze sind:

```text
Kandahar
Camp Bastion
Bagram
Kabul
Shindand
Tarin Kowt
```

Die UHF-Bank enthält zusätzlich die vier STANDARD-AAR-Tracks, C2, CSAR/PR und die festen UAV-JTACs. VHF-AM und FM werden für die passenden Airfield-, Ground- und Missionsnetze genutzt.

### 9.3 C-130J-30 – Bagram und Kandahar

Die Fixed-Wing-Recovery-Auswahl ist breiter als bei den Fighter-Presets und umfasst in der Arbeitsbaseline:

```text
Bagram
Kabul
Kandahar
Camp Bastion
Shindand
Tarin Kowt
Dwyer
```

Die Reihenfolge wird je Heimatbasis nach operativer Nähe/Nutzbarkeit angepasst. Die in Abschnitt 8 beschriebene C-130-Radiobank-Evidenzgrenze bleibt bestehen.

### 9.4 Rotary-Wing – regionale Presetlogik

AH-64D, OH-58D und CH-47F verwenden standortabhängige regionale Aviation-, Ground-, Rotary-, JTAC- und C2-Blöcke.

Die regionalen Schwerpunkte sind:

| Heimatregion | vorrangige Aviation-/Support-Knoten |
|---|---|
| Jalalabad | Jalalabad, Bagram, Kabul, Khost/Khost Heliport, Urgoon nach Band/Relevanz |
| Bagram | Bagram, Kabul, Jalalabad, Khost nach Band/Relevanz |
| Kandahar | Kandahar, Kandahar Heliport, Kandahar FARP Complex, Tarin Kowt, Dwyer, Bastion nach Band/Relevanz |
| Salerno | Khost/Salerno-Region, Khost Heliport, Urgoon, Jalalabad |
| Shindand | Shindand, Shindand Heliport; VHF 121.500 des Heliports ausgeschlossen |
| Tarin Kowt | Tarin Kowt, Kandahar, Kandahar Heliport, Kandahar FARP Complex, Dwyer |

Die 10er-UHF-Bank des AH-64D verwendet `P10 = WIZARD`. 20er-UHF-Banken von OH-58D und CH-47F verwenden `P11 = WIZARD`.

Die FM-Bänke priorisieren HOME-/lokale FM-Dienste, `Ground Common 46.000 FM`, `Ground Command 46.025 FM` und anschließend dynamische Ground-Mission-Kanäle. UHF-Bänke priorisieren regionale Aviation-Knoten, Rotary/Air-Assault Common, CSAR/PR sowie die lokal sinnvollsten festen UAV-JTACs und dynamischen JTAC-Kanäle.

## 10. Implementierungs- und Acceptance-Grenze

Diese Presetbelegung ist die abgeschlossene **Design-/Mission-Editor-Arbeitsbaseline** für den in Abschnitt 8 genannten v21-Stand. Sie ist noch nicht als DCS-Runtime-Verhalten validiert.

Vor `VALIDATED` sind mindestens erforderlich:

1. Presets in den tatsächlichen Client-Gruppen der aktuellen Mission eintragen;
2. daraus erzeugte `.miz` erneut auslesen und gegen das Workbook vergleichen;
3. im Cockpit mindestens je Muster die Bank-/Preset-Auswahl, Modulation und erreichbaren Dienste prüfen;
4. Multiplayer-/SRS-/DCS-VoiceChat-Sanity prüfen, soweit diese Kommunikationswege im Teststand verwendet werden;
5. FAC/JTAC-, AWACS-, Tanker-, CSAR- und ATC-Ansprechbarkeit für die vorgesehenen Beispielkanäle verifizieren.

Erst ein dokumentierter DCS-Lauf darf den Presetstand als `VALIDATED` kennzeichnen.
