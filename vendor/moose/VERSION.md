# Vendored MOOSE version

## Selected framework

Framework: MOOSE
Version: 2.9.18
Upstream tag: 2.9.18
Upstream stable branch: master-ng
Upstream release tag commit: 23112c99545d8b052f850fe0680d77272d24433b
Embedded build commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Embedded build timestamp: 2026-06-14T16:11:05+02:00
Include repository: FlightControl-Master/MOOSE_INCLUDE
Include family: Moose_Include_Static
Selected runtime file: Moose.lua
Compression: none
Retrieved: 2026-07-13
File size Moose.lua: 9773155 bytes
SHA-256 Moose.lua: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
SHA-256 LICENSE: 6323e4f7949aece19b6ae14e62f0e42a1de8d66e6ace79133e1dfa06ccf9994f
License file: LICENSE
License identifier: GPL-3.0
Vendor status: IMPORTED

## Sources

- https://github.com/FlightControl-Master/MOOSE/releases/tag/2.9.18
- https://github.com/FlightControl-Master/MOOSE_INCLUDE/tree/master/Moose_Include_Static
- https://flightcontrol-master.github.io/MOOSE/
- https://flightcontrol-master.github.io/MOOSE/developer/buildsystem/build-includes.html

## Project policy

- Use the pinned release, not a moving branch checkout.
- Preserve the upstream filename `Moose.lua`.
- Do not modify the vendored framework file.
- Load exactly one MOOSE include in a mission.
- Do not use `Moose_Include_Dynamic` for mission runtime.
- Do not use an unpinned `develop` branch.
- Update this file with the retrieval date, full SHA-256 and license status when the actual include file is imported.
- Re-run all relevant MOOSE test missions after every version or build-variant change.

The selected release metadata is documented before the binary-size framework file is imported so that the later import is explicit and verifiable.
