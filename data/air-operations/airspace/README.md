# Afghanistan 2011 navigation fixes

## Purpose

This directory contains the canonical OMW navigation-fix register used to author BLUE DCS Initial Points into the base mission. The productive register intentionally contains only:

```text
name,lat_dd,lon_dd
```

Airway membership is not part of the Initial-Point data model. A fix is stored once even when it belongs to multiple ATS routes.

## Primary source

The register is derived from:

- Republic of Afghanistan, Aeronautical Information Publication, Forty Fifth Edition, effective 05 May 2011;
- ENR 3.1 `LOWER ATS ROUTES`;
- ENR 3.2 `UPPER ATS ROUTES`;
- ENR 4.3, which states that significant points for the Kabul FIR are listed in the ENR 3.1 and ENR 3.2 route tables.

The union of the named ENR 3.1 and ENR 3.2 fixes is deduplicated by the exact five-letter designator and normalized to WGS84 decimal degrees.

For FIR boundary points, ENR 1.10 is used as the coordinate tie-breaker when the 2011 AIP repeats a fix with slightly different precision. In particular, `SERKA` is normalized to:

```text
N29 51 00 E066 15 01.02
```

because ENR 1.10 identifies that value for the FIR reporting point, while one lower-route table rounds the longitude to `E066 15 00`.

## DCS representation

The current OMW base mission used to verify the serialization contract was:

```text
OMW_Template_v8_AirOps_rdy(20260814-070806).miz
SHA-256: da661d02e381d567640b165f1b8645ff1ad65180e71e99d594a6a7251ac2ed32
```

Its BLUE `mission["coalition"]["blue"]["nav_points"]` table is empty. Existing DCS-authored navigation points in the same mission use the following object contract:

```text
type = "Default"
comment = ""
callsignStr = <visible name>
id = <numeric nav-point id>
properties = { vnav=3, scale=4, vangle=0, angle=0, steer=3 }
x = <DCS local northing>
y = <DCS local easting>
```

`tools/build-blue-navigation-initial-points.ps1` writes the canonical fixes into that BLUE table and refuses to overwrite a non-empty BLUE nav-point table.

## Afghanistan coordinate projection

The builder uses the Afghanistan terrain Transverse Mercator projection:

```text
central_meridian = 63
scale_factor = 0.9996
false_easting = -300150.0000226601
false_northing = -3759657.0000381926
datum = WGS84
```

The constants are independently published from an in-sim DCS Afghanistan projection probe in:

- `robgrady/DCS-Mission-Starter`, `missiongen/terrains/afghanistan/projection.py`.

They were cross-checked against the current OMW mission and 2011 AIP aerodrome reference points. The Jalalabad AIP ARP (`N34 24 02 E070 29 50`) projects to approximately DCS `x=72497.9463`, `y=389650.1928`, consistent with the current OMW Jalalabad mission geometry.

## MOOSE-first boundary

The pinned MOOSE source provides runtime navigation abstractions such as `NAVFIX` and WGS84 coordinate conversion. They are not used here because this requirement is specifically for DCS Initial Points that already exist when the mission loads. No runtime Lua is generated or required by this builder.

## Validation boundary

The builder can statically verify register uniqueness, naming, projection, BLUE serialization, and output hash. DCS must still be used to validate Mission Editor visibility and A-10C/A-10C II access before the result can be marked `VALIDATED`.
