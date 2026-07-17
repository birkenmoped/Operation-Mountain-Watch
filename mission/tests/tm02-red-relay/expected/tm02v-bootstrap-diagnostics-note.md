# TM02V bootstrap diagnostics note

The first DCS startup reached TM02V and MOOSE successfully but failed validation because the initial design required a dedicated `TPL_TEST_RED_PROXY_01` group. The early-return path also prevented the normal F10 test menu from being created.

The current design corrects both problems:

1. bootstrap diagnostics remain available when Mission Editor validation fails;
2. no dedicated proxy template is required;
3. every logical packet derives its own leader proxy from unit slot 1 of its own strength template;
4. the bootstrap status reports configured and active packet counts.

Fallback menu:

```text
OMW Tests
└── TM02V Multi-Proxy Movement
    ├── Validate test
    └── Show bootstrap status
```

The fallback menu is diagnostic only. Mission Editor corrections require saving and restarting the mission.

A successful version 3 bootstrap installs the full global menu plus one independent submenu for each configured packet. The former singleton `state.packet` design is superseded and must not recur.
