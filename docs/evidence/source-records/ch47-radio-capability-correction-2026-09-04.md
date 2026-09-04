---
document_id: OMW-EVIDENCE-CH47-RADIO-CAPABILITY-20260904
status: SOURCE_CAPTURE_COMPLETE
document_class: EVIDENCE_SOURCE_RECORD
owning_policy: OMW-GOV-001
source_branch: agent/radio-preset-foundation
validated_in_dcs: false
---

# CH-47F radio capability correction — 2026-09-04

## Purpose

This record captures the correction of the CH-47F player-radio preset interpretation discovered during Mission Editor verification of the OMW v1.5 preset build.

It supersedes the earlier working assumption that the CH-47F ARC-186/V3 preset bank could carry VHF, FM, and UHF services together.

## Sources checked

1. Current project-owner Mission Editor observation from `OMW_Template_v21_GroundWorks_RadioPresets_v1.5.miz` on 2026-09-04.
2. `DCS CH-47F Early Access Guide EN.pdf`, especially pages 38–42.

## Official DCS manual evidence

The DCS CH-47F Early Access Guide identifies the communications radios as:

```text
F1 = VHF-FM
U2 = UHF-AM
V3 = VHF-AM/FM
H4 = HF-AM
F5 = VHF-FM
```

The Emergency/Auxiliary Control Panel description states that the MAN/NORM/GUARD switch can manually control the `VHF-AM/FM (V3)` radio through the ARC-186 Control Panel. In GUARD it tunes:

```text
F1 VHF-FM      -> 40.500 MHz
U2 UHF-AM      -> 243.000 MHz
V3 VHF-AM/FM   -> 121.500 MHz
```

The manual also distinguishes the UHF-AM U2 radio from the VHF-AM/FM V3 radio in the backup-radio selection and antenna-selection descriptions.

Therefore the project interpretation is:

```text
ARC-186 / V3 = VHF AM/FM only
ARC-164 / U2 = UHF AM
ARC-201D      = VHF FM bank(s) represented by the current DCS module/ME
```

No UHF service is to be programmed into the CH-47F ARC-186/V3 preset bank.

## Mission Editor evidence

The OMW v1.5 test intentionally placed valid VHF-AM and VHF-FM values together with UHF values into the CH-47F ARC-186 bank.

Mission Editor displayed the valid VHF-AM and VHF-FM values normally, while the attempted UHF entries appeared repeatedly near the upper VHF limit as approximately `151.97 MHz FM`.

This observation is treated as evidence that the previous UHF assignments were invalid for the ARC-186/V3 bank. The precise numerical ARC-186 frequency limits are not promoted to a binding project claim from this observation alone; only the band-role conclusion supported by the official guide is bound here.

## Corrected OMW preset architecture

```text
ARC-186 / V3
- VHF-AM home / regional ATC and heliport services
- VHF common
- VHF-FM Ground Common / Ground Command
- VHF-FM dynamic Ground Mission channels
- no UHF services

ARC-164 / U2
- UHF home / regional ATC and FARP services
- Rotary / Air-Assault common
- WIZARD / Theater C2
- CSAR / PR
- UAV-JTAC / FAC
- dynamic UHF mission/JTAC channels

ARC-201D
- dedicated VHF-FM home / ground / tactical presets
```

`Shindand Heliport 121.500 AM` remains excluded from player presets because the physical frequency collides with protected VHF Guard.

## Implementation baseline

The corrected workbook/output baseline is:

```text
OMW_Radio_Frequency_Master_v1.6.xlsx
OMW_Template_v21_GroundWorks_RadioPresets_v1.6.miz
```

Only the CH-47F ARC-186/V3 preset architecture is corrected relative to v1.5. The A-10C II ARC-210 multiband/multimode interpretation and the previously established OH-58D Channel C / Channel M offset handling are not changed by this correction.

## Validation state

```text
Official manual capability check: complete
Mission Editor failure evidence for v1.5 UHF-in-ARC-186: observed
v1.6 structural preset verification: complete
v1.6 Mission Editor display verification: pending
v1.6 cockpit/runtime verification: pending
validated_in_dcs: false
```

Do not mark the corrected preset implementation `VALIDATED` until the project owner confirms the v1.6 Mission Editor and cockpit behavior in the current DCS build.
