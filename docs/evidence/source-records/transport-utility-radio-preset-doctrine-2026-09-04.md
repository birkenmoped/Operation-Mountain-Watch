# Transport / Utility radio preset doctrine – 2026-09-04

## Status

Project-owner decision recorded during the player-radio preset reconciliation on `agent/radio-preset-foundation`.

This record documents the intended standard-preset role split for transport / utility aircraft. It does not by itself constitute DCS runtime validation.

## Owner decision

The project owner confirmed that theater-wide JTAC/FAC preset blocks are not useful as a standard allocation for transport / utility player assets such as C-130J-30, CH-47F and the future UH-60 player asset.

The resulting OMW rule is:

```text
CAS / ISR assets
F-16 / F-15E / A-10 / AH-64 / OH-58
-> fixed UAV-JTAC/FAC presets may be part of the normal preset baseline
-> dynamic JTAC/FAC channels may be included where bank capacity and role justify them

Transport / utility assets
C-130 / CH-47 / future UH-60
-> no theater-wide fixed/dynamic JTAC/FAC block in the standard preset baseline
-> JTAC/FAC is mission-/role-assigned when operationally required
-> presets prioritize mobility, ATC/recovery, FARP/rotary/ground, C2 and CSAR according to aircraft role
```

## C-130J-30 theater-mobility rule

The C-130J-30 is treated as a theater-wide transport asset. Its standard preset baseline must therefore prioritize access to all OMW airfields that are part of the current fixed DCS airfield-frequency baseline rather than a narrow regional divert set.

The nine airfields carried in both UHF and VHF preset banks are:

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

Heliport-only locations are not part of this C-130 airfield set.

Preset order is HOME-first and then adjusted by home base for operational usefulness. The current C-130 client bases are Bagram and Kandahar.

The standard C-130 UHF bank additionally retains:

```text
US Army UHF Common
WIZARD / Theater C2
CSAR / PR Primary
CSAR / PR Secondary
STANDARD AAR: NELSON, PATTY, MILHOUSE, KRUSTY
Rotary Common
Air-Assault Common
US Army Helo Common
```

The fixed UAV-JTAC channels Jaguar, Pointer, Hammer and Firefly and the dynamic JTAC/FAC block are deliberately not part of the C-130 standard preset baseline.

## CH-47F transport / utility rule

The CH-47F continues to use regional aviation/FARP entries according to home location. Its UHF standard bank retains Rotary Common, Air-Assault Common, CSAR/PR and WIZARD. Fixed and dynamic JTAC/FAC channels are removed from the standard CH-47F bank and replaced by approved Rotary Mission channels.

A mission that genuinely requires direct JTAC/FAC coordination may assign the required JTAC/FAC frequency ad hoc through mission planning/briefing rather than consuming the permanent standard-preset block.

## Future UH-60 application

No UH-60 player client is present in the current v21 player scope. When UH-60 player assets are added, the same transport/utility doctrine applies unless the project owner explicitly approves a role-specific exception:

```text
regional HOME / aviation / FARP
-> Ground / Rotary / Air-Assault
-> C2 / CSAR
-> mission-specific JTAC/FAC only when required
```

No UH-60 Mission Editor implementation is claimed by this record.

## v1.7 implementation artifacts

Generated implementation artifacts:

```text
OMW_Radio_Frequency_Master_v1.7.xlsx
SHA-256 6F9B56CA994DEFC96670CFE656AAE9B8C257EC949F88C6C80299B4BAE082CFC4

OMW_Template_v21_GroundWorks_RadioPresets_v1.7.miz
SHA-256 069509AE483A57EBC76AEAC0C299C588DF0794C0568F2B39EDCE33B7815DF69E
```

Source MIZ for this change:

```text
OMW_Template_v21_GroundWorks_RadioPresets_v1.6.miz
SHA-256 503733900123A80CBD26B2E505349AD08E89089C9607C9358E587FB9FA3F762E
```

Implementation verification performed before publication of the artifacts:

```text
C-130 client aircraft updated: 4
CH-47F client aircraft updated: 11
ZIP members changed: mission only
MIZ ZIP integrity: OK
Workbook C-130 airfield coverage: all nine UHF + all nine VHF per home-base block
Workbook C-130 JTAC/FAC standard rows: 0
Workbook CH-47F JTAC/FAC standard rows: 0
Serialized radio-bank Soll/Ist comparison: OK
```

## Acceptance boundary

`validated_in_dcs` remains false.

Required follow-up in the current DCS Mission Editor / cockpit:

- verify C-130 UHF/VHF bank display and preset order at Bagram and Kandahar;
- verify CH-47F ARC-164 UHF banks at representative home bases;
- verify that the revised frequencies remain selectable and usable in the current module versions;
- perform normal multiplayer/SRS/DCS Voice Chat sanity if used in the acceptance mission.
