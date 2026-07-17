# TM02V bootstrap diagnostics note

TM02V now installs a reduced fallback F10 menu when configuration or Mission Editor validation fails during bootstrap.

```text
OMW Tests
└── TM02V Proxy Movement
    ├── Validate test
    └── Show bootstrap status
```

The fallback menu is diagnostic only. It does not permit movement start after a failed bootstrap. Mission Editor object corrections require saving the mission and restarting it.

A successful bootstrap still installs the full TM02V menu with start, status, pack, unpack, and marker commands.
