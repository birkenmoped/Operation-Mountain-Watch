# TM02V bootstrap and scope corrections

TM02V reached MOOSE and its controller successfully during the DCS tests. The observed failures were design errors in the test implementation, not missing MOOSE functionality.

Corrections applied in sequence:

1. diagnostic F10 commands remain available when Mission Editor validation fails;
2. the dedicated `TPL_TEST_RED_PROXY_01` requirement was removed;
3. every packet receives its own leader proxy derived from unit slot 1 of its own strength template;
4. simultaneous proxies use separated deterministic HQ launch slots;
5. the fixed `config.movements` plan was removed;
6. packets are generated dynamically from live shelter deficits until every configured shelter reaches target strength.

Version 5 uses:

```text
configurationVersion=TM02V-red-proxy-dynamic-fill-5
configuredMovementCount=0
dynamicPacketGeneration=true
```

The primary acceptance starts with HQ 100 and all six shelters at 0/10. The dispatcher must continue automatically until all six visible destination garrisons are at 10/10.

Fallback menu:

```text
OMW Tests
└── TM02V Dynamic Proxy Fill
    ├── Validate test
    └── Show bootstrap status
```
