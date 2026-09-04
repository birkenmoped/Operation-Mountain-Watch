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
omw_workbook_version: v1.7
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
- Transport-/Utility-Assets (`C-130J-30`, `CH-47F`, später `UH-60`) erhalten **keinen theaterweiten JTAC/FAC-Standardblock**. JTAC/FAC wird nur missions-/rollenbezogen zugewiesen, wenn die konkrete Aufgabe direkte JTAC/FAC-Koordination erfordert.
- Der `C-130J-30` priorisiert als Theater-Transporter vollständige Airfield-Abdeckung vor JTAC/FAC-Presets.
- `CH-47F` und später `UH-60` priorisieren regionale Aviation-/FARP-, Ground-/Rotary-, C2- und CSAR-Dienste vor JTAC/FAC-Presets.
- Die DCS-Szenery-Frequenz `121.500 AM` des Shindand Heliport wird wegen der geschützten VHF-Guard-Frequenz nicht als Player-Preset verwendet.

Die Transport-/Utility-Entscheidung und ihre v1.7-Umsetzung sind zusätzlich dokumentiert in:

- [`Transport / Utility radio preset doctrine – 2026-09-04`](evidence/source-records/transport-utility-radio-preset-doctrine-2026-09-04.md)

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

Aus der aktuellen v21-Mission und der nachfolgenden Mission-Editor-Evidenz ergeben sich folgende Presetbank-Strukturen:

| Muster | Radio / Bank | Presets | Bereich |
|---|---|---:|---|
| F-16C_50 | COMM1 | 20 | UHF AM |
| F-16C_50 | COMM2 | 20 | VHF AM |
| F-15ESE | Radio 1 | 20 | UHF AM |
| F-15ESE | Radio 2 | 40 | V/UHF AM |
| A-10C_2 | ARC-210 | 25 | Multiband / multimode; Frequenz, Modulation und Presetname je Kanal serialisiert |
| A-10C_2 | ARC-164 | 20 | UHF AM |
| A-10C_2 | ARC-186 | 20 | VHF FM |
| AH-64D_BLK_II | ARC-186 | 10 | VHF AM |
| AH-64D_BLK_II | ARC-164 | 10 | UHF AM |
| AH-64D_BLK_II | FM1 ARC-201D | 10 | VHF FM |
| AH-64D_BLK_II | FM2 ARC-201D | 10 | VHF FM |
| OH58D | UHF | 19 normale Presets + Channel M | UHF AM |
| OH58D | VHF AM | 19 normale Presets + Channel M | VHF AM |
| OH58D | FM1 | 19 normale Presets + Channel C + Channel M | VHF FM |
| OH58D | FM2 | 19 normale Presets + Channel C + Channel M | VHF FM |
| CH-47Fbl1 | ARC-186 / V3 / Radio 1 | 20 | **VHF AM/FM** |
| CH-47Fbl1 | ARC-164 / U2 / Radio 2 | 20 | **UHF AM** |
| CH-47Fbl1 | ARC-201D / Radio 3 | 10 | **VHF FM** |
| C-130J-30 | Radio 1 | 20 | UHF AM |
| C-130J-30 | Radio 2 | 10 | VHF AM |

Für den C-130J-30 besteht zusätzlich frühere Mission-Editor-Evidenz für zwei UHF- und zwei VHF-Radios (`UHF-1/UHF-2` mit je 20 sowie `VHF-1/VHF-2` mit je 10 Presets). Da v21 nur eine UHF- und eine VHF-Presetliste serialisiert, werden die zweiten Banken im Workbook als **gespiegelte Planungsbanken** geführt und vor einer ME-Bindung erneut am aktuellen C-130-Modul geprüft. Sie werden nicht als unabhängig in v21 nachgewiesene Presetlisten ausgegeben.

Für den CH-47F korrigiert die aktuelle Evidenz die frühere Arbeitsannahme. Der offizielle `DCS CH-47F Early Access Guide` bezeichnet V3/ARC-186 ausdrücklich als **VHF-AM/FM**, U2 als **UHF-AM** sowie F1/F5 als VHF-FM. Der Mission-Editor-Test mit v1.5 zeigte UHF-Werte im ARC-186 als wiederholte Werte nahe `151.97 MHz FM`; UHF-Belegungen sind daher aus der ARC-186-Bank entfernt. Maßgeblicher Evidenzdatensatz:

- [`CH-47F radio capability correction – 2026-09-04`](evidence/source-records/ch47-radio-capability-correction-2026-09-04.md)

## 9. Vollständige Player-Preset-Arbeitsbaseline

Die vollständigen Einzelbelegungen stehen in `OMW_Radio_Frequency_Master_v1.7.xlsx` auf jeweils eigenen Muster-Arbeitsblättern:

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

Die A-10-Baseline nutzt die drei Funkgeräte ihrer tatsächlichen Mission-Editor-Fähigkeit entsprechend. Das `ARC-210` ist eine benennbare Multiband-/Multimode-Bank und darf deshalb VHF-AM-, UHF-AM- und VHF-FM-Dienste innerhalb derselben Presetbank führen. Frequenz, Modulation und Presetname werden je Kanal getrennt serialisiert. `ARC-164` bleibt die dedizierte UHF-AM-Bank, `ARC-186` die dedizierte VHF-FM-Bank.

Feste Recovery-/Divert-Plätze sind:

```text
Kandahar
Camp Bastion
Bagram
Kabul
Shindand
Tarin Kowt
```

Die A-10-Presets enthalten zusätzlich die STANDARD-AAR-Tracks, C2, CSAR/PR, feste UAV-JTACs und die vorgesehenen Ground-/Mission-Netze.

### 9.3 C-130J-30 – Bagram und Kandahar

Der C-130J-30 ist in OMW ein **theaterweiter Transporter**. Die Standard-Presets priorisieren deshalb vollständige Airfield-Abdeckung statt eines festen JTAC/FAC-Blocks.

In **beiden** C-130-Basisvarianten (`Bagram`, `Kandahar`) sind auf UHF und VHF alle neun OMW-Airfields enthalten; nur die Reihenfolge ist HOME-first und danach nach operativer Nutzbarkeit angepasst:

```text
Bagram
Camp Bastion
Dwyer
Jalalabad
Kabul
Kandahar
Khost
Shindand
Tarin Kowt
```

Heliport-only-Standorte gehören nicht zu diesem C-130-Airfield-Set.

Die 20er-UHF-Bank führt zusätzlich:

```text
P10 US Army UHF Common
P11 WIZARD / Theater C2
P12 CSAR / PR Primary
P13 CSAR / PR Secondary
P14 NELSON / Texaco 1-1
P15 PATTY / Texaco 2-1
P16 MILHOUSE / Shell 2-1
P17 KRUSTY / Arco 2-1
P18 Rotary Common
P19 Air-Assault Common
P20 US Army Helo Common
```

Die vier festen UAV-JTAC-Kanäle und die dynamischen JTAC/FAC-Kanäle sind ausdrücklich **keine C-130-Standardpresets**. Bei einer konkreten missionsbezogenen Notwendigkeit wird die JTAC/FAC-Frequenz durch Missionsplanung/Briefing zugewiesen.

Die in Abschnitt 8 beschriebene C-130-Radiobank-Evidenzgrenze bleibt bestehen.

### 9.4 Rotary-Wing – regionale Presetlogik

AH-64D, OH-58D und CH-47F verwenden standortabhängige regionale Aviation-, Ground-, Rotary- und C2-Blöcke. JTAC/FAC bleibt bei CAS/ISR-Mustern Bestandteil der normalen Presetlogik; bei Transport-/Utility-Mustern dagegen missions-/rollenbezogen.

Die regionalen Schwerpunkte sind:

| Heimatregion | vorrangige Aviation-/Support-Knoten |
|---|---|
| Jalalabad | Jalalabad, Bagram, Kabul, Khost/Khost Heliport, Urgoon nach Band/Relevanz |
| Bagram | Bagram, Kabul, Jalalabad, Khost nach Band/Relevanz |
| Kandahar | Kandahar, Kandahar Heliport, Kandahar FARP Complex, Tarin Kowt, Dwyer, Bastion nach Band/Relevanz |
| Salerno | Khost/Salerno-Region, Khost Heliport, Urgoon, Jalalabad |
| Shindand | Shindand; VHF 121.500 des Heliports ausgeschlossen |
| Tarin Kowt | Tarin Kowt, Kandahar, Kandahar Heliport, Kandahar FARP Complex, Dwyer |

Die 10er-UHF-Bank des AH-64D verwendet `P10 = WIZARD`. Die tatsächlichen UHF-Bänke von OH-58D und CH-47F verwenden `P11 = WIZARD`.

Für den OH-58D gilt das im aktuellen Mission Editor nachgewiesene Sonderkanal-Mapping: UHF/VHF besitzen vor `Kanal 1` einen `Channel M`; FM1/FM2 besitzen `Channel C` und danach `Channel M`. Diese Sonderkanäle werden nicht als normale OMW-Presets überschrieben.

Für den CH-47F gilt ab v1.7:

```text
ARC-186 / V3
-> ausschließlich VHF
-> regionale VHF-AM Aviation-/ATC-/Heliport-Dienste
-> VHF Common
-> VHF-FM Ground Common / Ground Command
-> VHF-FM Dynamic Ground Mission
-> keine UHF-Dienste

ARC-164 / U2
-> UHF-AM HOME / regionale Aviation-/FARP-Dienste
-> Rotary / Air-Assault Common
-> WIZARD / Theater C2
-> CSAR / PR
-> Rotary Mission 1..10
-> keine festen oder dynamischen JTAC/FAC-Standardpresets

ARC-201D
-> dedizierte VHF-FM HOME-/Ground-/Tactical-Presets
```

Eine konkrete CH-47F-Mission darf bei operativer Notwendigkeit eine JTAC/FAC-Frequenz missionsbezogen zugewiesen bekommen; sie wird nicht als permanenter Standardblock vorgehalten.

Für einen späteren `UH-60`-Player gilt dieselbe Transport-/Utility-Doktrin, solange der Projektinhaber keine rollenbezogene Ausnahme freigibt. Da aktuell kein UH-60-Playerclient im v21-Scope vorhanden ist, wird daraus noch keine Mission-Editor-Implementierung behauptet.

Damit ist die v1.5-Annahme eines UHF-fähigen CH-47F-ARC-186 ausdrücklich verworfen; v1.7 ergänzt die rollenbasierte Transport-/Utility-Abgrenzung.

## 10. Implementierungs- und Acceptance-Grenze

Diese Presetbelegung ist die aktuelle **Design-/Mission-Editor-Arbeitsbaseline** für den in Abschnitt 8 genannten v21-Stand. Sie ist noch nicht als DCS-Runtime-Verhalten validiert.

Vor `VALIDATED` sind mindestens erforderlich:

1. Presets in den tatsächlichen Client-Gruppen der aktuellen Mission eintragen;
2. daraus erzeugte `.miz` erneut auslesen und gegen das Workbook vergleichen;
3. im Mission Editor mindestens je Muster die Bank-/Preset-Zuordnung und Modulation prüfen;
4. im Cockpit mindestens je Muster die Bank-/Preset-Auswahl, Modulation und erreichbaren Dienste prüfen;
5. Multiplayer-/SRS-/DCS-VoiceChat-Sanity prüfen, soweit diese Kommunikationswege im Teststand verwendet werden;
6. FAC/JTAC-, AWACS-, Tanker-, CSAR- und ATC-Ansprechbarkeit für die vorgesehenen Beispielkanäle verifizieren.

Erst ein dokumentierter DCS-Lauf darf den Presetstand als `VALIDATED` kennzeichnen.
