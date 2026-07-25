# Jalalabad ORBAT and ramp correction

## Reason

The previous `24 OH-58D / 8 AH-64D / 6 UH-60` manifest omitted the CH-47 heavy-lift component and incorrectly implied that the complete inventory should be represented directly on the ramp.

The supplied 2011 satellite composite shows at least:

```text
13 OH-58
 7 AH-64
 7 UH-60
 7 CH-47
 1 Mi-8
 1 UH-1
```

The image is a momentary ramp state. Aircraft may also be airborne, in maintenance, inside hangars or on non-visible dispersal areas.

Contemporary Task Force Shooter reporting identifies Jalalabad / FOB Fenty as a multi-functional aviation task force location using OH-58D, AH-64D, UH-60 and CH-47 aircraft. The exact heavy-lift sub-unit attribution remains intentionally generic until the rotation boundary is fully reconciled.

## Corrected logical inventory

```text
24 OH-58D
 8 AH-64D
 8 UH-60-family
 8 CH-47 heavy-lift aircraft
```

Mi-8 and UH-1 remain recorded as observed external or transient aircraft and are not currently charged to the US Task Force Shooter inventory.

## Core design decision

The local numerical inventory, active aircraft, visible statics and DCS parking capacity are separate layers.

Not every SQUADRON asset must be visible. A hidden reserve aircraft may fly a later sortie after another airframe is lost, but the loss remains permanent and reduces the total inventory.

Visible statics are a capped representation of the remaining inactive reserve. A destroyed static is a real loss. It is not immediately respawned during the same mission. A different surviving reserve aircraft may occupy a visual static slot after a later controlled ramp refresh or mission restart.

## Parking-limited representation

Comparable DCS helicopter positions:

```text
36
```

Local player limit:

```text
2 aircraft per playable type at Jalalabad
```

Core operational demand:

```text
6 required player positions
7 late-activation template start positions
= 13 core operational positions
```

Optional two UH-60L player positions raise this to 15.

Visible static caps:

```text
7 OH-58D
4 AH-64D
4 UH-60A
5 CH-47
= 20 visible statics
```

This uses 33 of 36 comparable positions without the UH-60L mod, or 35 of 36 with both optional UH-60L slots.

## Technical implementation

- local inventory set to `24/8/8/8`,
- player slots reduced to two per type,
- CH-47 heavy-lift template and SQUADRON added,
- CH-47 internal DCS type discovered from the mission template,
- final validator uses virtual inventory and static caps,
- AIRWING/COMMANDER activation remains gated by the complete corrected manifest.

The confirmed Warehouse, Parking, OH-58D and AH-64D test results remain valid.
