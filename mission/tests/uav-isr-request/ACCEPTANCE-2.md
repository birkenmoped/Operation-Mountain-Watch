# UAV ISR Acceptance 2 — physical Kandahar RECON dispatch

## Scope

This is a separate, non-production acceptance mission. It verifies one BLUE
player request from a F10 marker through CampaignState reservation and the
public MOOSE AIRWING/AUFTRAG path to a real Kandahar MQ-9 launch and flight
towards the marker.

It does not activate Bagram, certify terrain routing, validate holding,
recovery, persistence, Fog of War or weapon employment.

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-2.ps1
```

Inject only `mission/tests/uav-isr-request/dist/OMW_UAV_ISR_Request_Acceptance_2.lua`
into a copy of the mission after MOOSE has loaded. Do not load the production
Kandahar bootstrap separately: this bundle contains it.

## DCS acceptance

1. Confirm the initial ISR Cell message.
2. As BLUE, set an exact BLUE F10 marker `UAV RECON` no more than 50 km from
   the client group.
3. Select `F10 -> Command -> ISR Cell -> Submit nearest UAV marker`.
4. Observe a group-scoped assignment message naming MQ-9.
5. In the Mission Editor / F10 view, observe the existing Kandahar MQ-9
   template physically start and fly towards the marker. No teleport/despawn is
   acceptable.
6. Capture `dcs.log`, `debrief.log`, bundle SHA-256 and screenshots.

## Pass criterion

The bundle emits no ISR Lua error; exactly one acceptance-local MQ-9 resource
is reserved; MOOSE AIRWING starts the existing fixed-loadout template from
Kandahar and the aircraft begins physical transit toward the submitted marker.

