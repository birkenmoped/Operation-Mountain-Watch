# Bagram Air Operations Foundation Test

## Scope

Dieser Testpfad validiert ausschließlich den produktionsnahen Bagram-AIRWING-/SQUADRON-Grundbau nach ADR 0006.

```text
AW_US_BGRM_455_AEW
AW_US_BGRM_TF_FALCON_10_CAB
```

Nicht Bestandteil dieses Pfads sind COMMANDER, konkrete AUFTRAG-Instanzen, OPSTRANSPORT, F10-Teststeuerung, Bagram→Jalalabad-Bewegungen, Parking-Overrides, Recovery oder Persistenz.

## Required Mission Editor objects

Airbase:

```text
Bagram
```

Warehouse anchors:

```text
WH_AIR_US_BAGRAM
WH_AIR_US_BAGRAM_ARMY
```

`WH_AIR_US_BAGRAM` ist der bestehende USAF-/Hauptanker. `WH_AIR_US_BAGRAM_ARMY` muss als separater Army-Aviation-Anker an Bagram angelegt werden. Beide dürfen nicht dasselbe DCS-Objekt sein.

Required Late Activation templates:

```text
TPL_AIR_US_BGRM_F15E_CAS_2SHIP
TPL_AIR_US_BGRM_F15E_STRIKE_2SHIP
TPL_AIR_US_BGRM_F16C_CAS_2SHIP
TPL_AIR_US_BGRM_C130_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_LEAD_1SHIP
TPL_AIR_US_BGRM_HH60G_CSAR_COVER_1SHIP
TPL_AIR_US_BGRM_UH60_TRANSPORT_1SHIP
TPL_AIR_US_BGRM_UH60_UTILITY_1SHIP
TPL_AIR_US_BGRM_CH47_TRANSPORT_1SHIP
```

Der alte Branch verwendete für den F-16-CAS-Seed teilweise `TPL_AIR_US_BGRM_F16_CAS_2SHIP`. Der Neubau normalisiert diesen Identifier bewusst auf `F16C`; die Mission-Editor-Gruppe ist vor dem Test entsprechend zu benennen.

## Build

```powershell
.\tools\build-bagram-air-operations-foundation.ps1
```

Generated bundle:

```text
mission\tests\bagram-air-operations\dist\OMW_AirOps_Bagram.lua
```

Die `dist`-Datei ist Buildartefakt und nicht Source of Truth.

## MOOSE pin

```text
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

## Expected foundation accounting

```text
2 AIRWINGs
6 SQUADRONs
61 MOOSE asset groups
73 represented airframes
75 logical airframes
2 logical fighter reserve airframes
9 role-payload registrations
0 created missions
0 created transports
0 COMMANDER
0 F10 controls
```

Die Missionsdatei wird durch ChatGPT nicht automatisiert verändert oder neu gepackt. Ein DCS-PASS gilt nur für die vom Projektinhaber tatsächlich getestete MIZ samt Hash, DCS-Version, eingebettetem Bundle und eingebetteter Moose.lua.
