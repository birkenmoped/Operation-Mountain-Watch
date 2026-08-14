# AAR runtime branch history

This directory preserves the historical planning and acceptance artifacts from `agent/aar-rc-east-runtime-scope` during its reconciliation into `main`.

These files are evidence snapshots. They are **not** current project authority and must not override the consolidated `main` baseline in `docs/29-isaf-2009-2013-air-to-air-refueling.md`, current `docs/moose/` documentation, or current production-facing AAR data.

In particular, planning states, receiver scope, candidate areas, acceptance status, accelerated FuelLow thresholds, or unfinished Acceptance-6 wording contained in the preserved snapshots describe the branch at the time of capture. Current validated runtime conclusions and owner decisions are recorded in the consolidated main documentation.

The branch history itself is retained through the reconciliation merge ancestry. Runtime test source and the PowerShell builder remain under `mission/tests/aar-kc135-runtime/` and `tools/` as historical/reproducibility fixtures; they are not production tanker control code.
