# A-10C II ARC-210 preset naming convention – 2026-09-05

## Status

Project-owner decision recorded during player-radio preset reconciliation on `agent/radio-preset-foundation`.

This record documents the cockpit-visible ARC-210 preset-name convention used by Operation Mountain Watch. It does not by itself constitute DCS runtime validation of every configured preset.

## Evidence

Source reviewed:

```text
TO 1A-10C-ARC-210-ADM
AN/ARC-210 Pilot Manual
476th vFighter Group Series
A-10C Aircraft
Change 2, 18 May 2023
```

Relevant DCS-only findings from the source and the project-owner cockpit observation:

```text
COMM page -> ARC210 PRESETS
PRESETS page columns -> CHN / NAME / FREQ / MOD
25 simplex presets
preset names can be entered through the Mission Editor
preset names are displayed on the COMM/PRESETS MFD page
names are converted to uppercase
maximum displayed/stored name length: 12 characters
special characters are replaced by ?
```

The project owner additionally confirmed in the current A-10C II cockpit that the preset description is not shown on the ARC-210 Radio Set Control head itself, but is visible on the MFD COMM/PRESETS page.

The original Eagle Dynamics A-10C II Flight Manual available to the project predates the completed ARC-210 documentation and therefore is not used as the detailed authority for this naming behavior.

## Owner decision

OMW uses a category-first naming convention for cockpit-visible A-10C II ARC-210 presets:

```text
<CATEGORY> <NAME/CODE>
```

The category is normally 2–4 characters. The service/category is placed first so the COMM/PRESETS page can be scanned by function.

Approved category prefixes for the current A-10C II bank:

```text
ATC   airfield / aerodrome service
TKR   tanker
JTAC  JTAC / FAC service
C2    theater command and control
CSAR  combat search and rescue / personnel recovery
GND   ground / tactical FM service
```

Named tanker and JTAC callsigns are not shortened. Where the full callsign plus a four-character category would exceed the ARC-210 12-character limit, the category is shortened instead. Therefore `TKR MILHOUSE` is used rather than shortening `MILHOUSE`.

For airfields, use established or explicitly approved operational abbreviations where available. The project owner explicitly approved:

```text
KAF = Kandahar Airfield
KIA = Kabul International Airport
```

Other current A-10 display codes remain the existing readable OMW codes unless separately changed:

```text
BSTN = Camp Bastion
BGRM = Bagram
SHND = Shindand
TKOT = Tarin Kowt
```

## A-10C II ARC-210 v1.8 display labels

```text
P01  ATC KAF
P02  ATC BSTN
P03  ATC BGRM
P04  ATC KIA
P05  ATC SHND
P06  ATC TKOT
P07  TKR NELSON
P08  TKR PATTY
P09  TKR MILHOUSE
P10  TKR KRUSTY
P11  C2 WIZARD
P12  CSAR PRI
P13  CSAR ALT
P14  JTAC JAGUAR
P15  JTAC POINTER
P16  JTAC HAMMER
P17  JTAC FIREFLY
P18  JTAC DYN1
P19  JTAC DYN2
P20  JTAC DYN3
P21  GND KAF
P22  GND COMMON
P23  GND CMD
P24  GND BSTN
P25  GND TKOT
```

All labels are uppercase and no longer than 12 characters.

## Workbook implementation

Implemented in:

```text
OMW_Radio_Frequency_Master_v1.8.xlsx
SHA-256 C5B3218CB880A05E035B3859A1DE31559C42C70BB7A634A630D5ED1ECA3859B9
```

The workbook keeps the full semantic `Function / Net` text and stores the short cockpit-visible ARC-210 name in the A-10C II `Notes` column as `UI label: ...`.

## Acceptance boundary

`validated_in_dcs` remains false for the complete preset baseline.

The naming behavior itself has cockpit evidence for the COMM/PRESETS page and source support from the DCS-specific ARC-210 pilot manual. A future MIZ update must serialize the v1.8 labels into the A-10C II `channelsNames[]` entries and should then be rechecked in the Mission Editor and cockpit.
