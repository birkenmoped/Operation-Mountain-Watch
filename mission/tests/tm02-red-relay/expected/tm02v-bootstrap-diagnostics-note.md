# TM02V bootstrap diagnostics note

The first DCS startup reached TM02V and MOOSE successfully but failed validation because the initial design required a dedicated `TPL_TEST_RED_PROXY_01` group. The early-return path also prevented the normal F10 test menu from being created.

Two corrections followed:

1. bootstrap diagnostics remain available when Mission Editor validation fails;
2. the dedicated proxy template requirement was removed entirely.

TM02V version 2 now derives the proxy dynamically from unit slot 1 of the standard strength template. For the current six-person test this is `TPL_TEST_RED_PACKET_06_01`. The previous missing-proxy failure is therefore superseded and must not recur.
