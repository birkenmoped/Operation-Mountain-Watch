# Jalalabad CH-47 ORBAT correction

## Status

The previously declared `24 OH-58D / 8 AH-64D / 6 UH-60` Jalalabad manifest was incomplete and must not be accepted as a complete local Air Operations node.

The missing component is a locally based or permanently forward-staged CH-47 heavy-lift element.

## Evidence

### Contemporary official unit reporting

The DVIDS article **“TF Shooter takes over aviation ops”** dated 20 November 2010 states that Task Force Shooter at Forward Operating Base Fenty was a multi-functional aviation task force and explicitly included all four major U.S. Army helicopter types:

- OH-58D Kiowa Warrior,
- AH-64D Apache Longbow,
- UH-60 Black Hawk,
- CH-47 Chinook.

The same report states that the task force provided assault and lift support from Jalalabad.

### Contemporary imagery

Multiple satellite captures from February and March 2011 show a sustained concentration of tandem-rotor helicopters on the Jalalabad heavy-lift parking areas. One clear capture contains approximately eight CH-47-shaped airframes distributed across the two large aprons. The repeated appearance and apron organization are inconsistent with treating all aircraft as incidental transient traffic.

### Heavy-lift company scale

The DVIDS article **“Spartan soldiers complete RC-East mission”** reports that Bravo Company, 7th Battalion, 158th Aviation Regiment assumed responsibility for nine CH-47 Chinooks during its 2011-2012 Regional Command-East deployment. The company was split among three forward operating bases. This does not prove that all nine aircraft were permanently at Jalalabad, but it establishes the correct order of magnitude and supports an eight-aircraft Jalalabad working count when combined with the satellite evidence.

## Corrective decision

The Jalalabad node must include CH-47 heavy lift before it can be declared complete.

Working mission-design baseline:

```text
24 OH-58D
 8 AH-64D
 6 UH-60-family
 8 CH-47 heavy-lift aircraft
```

The CH-47 figure is an evidence-based working count derived from the visible 2011 Jalalabad concentration and the documented nine-aircraft RC-East heavy-lift company scale. The exact sub-unit attribution changed during the deployment and is therefore represented initially as a generic Task Force Shooter heavy-lift detachment rather than with an unsupported company designation.

## Technical consequence

Until the revised CH-47 implementation is present, the final activation gate must remain blocked:

```text
Jalalabad status = INCOMPLETE
AIRWING must not Start()
COMMANDER must not be linked
```

The confirmed Warehouse, Parking, OH-58D and AH-64D test results remain valid. Only the claim of a complete Jalalabad ORBAT is withdrawn.
