# Vendored MOOSE version

## Selected framework

```text
Framework: MOOSE
Version: 2.9.18
Upstream tag: 2.9.18
Upstream stable branch: master-ng
Upstream release commit: 23112c9
Include repository: FlightControl-Master/MOOSE_INCLUDE
Include family: Moose_Include_Static
Selected runtime file: Moose.lua
Compression: none
Retrieved: 2026-07-13
SHA-256 Moose.lua: <vollständiger Hash von Moose.lua>
SHA-256 LICENSE: <vollständiger Hash von LICENSE>
License file: LICENSE (GPL-3.0, MOOSE tag 2.9.18)
Vendor status: IMPORTED
```

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
