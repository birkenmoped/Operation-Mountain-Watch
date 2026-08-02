---
document_id: OMW-EVIDENCE-KANDAHAR-A10C-CAS-LOADOUT-DECISION
status: BINDING_PROJECT_DECISION
owning_policy: OMW-GOV-001
authoritative_for:
  - Kandahar A-10C II CAS authoring payload
  - DCS station allocation for TPL_AIR_US_KAF_A10C_CAS_2SHIP
  - evidence boundary between historical weapon presence and the OMW composite loadout
scenario_period: 2010-08-01/2011-12-31
decision_date: 2026-08-01
source_branch: agent/kandahar-airwing-baseline-contract
source_editor_artifact: OMW_Template_v4_Kandahar.miz
source_editor_artifact_sha256: NOT_PROVIDED
mission_file_payload_audited: false
validated_in_dcs: false
---

# Kandahar A-10C II CAS loadout decision – 1 August 2026

## 1. Scope and authority

This document records the binding Operation Mountain Watch Mission Editor authoring decision for the Kandahar A-10C II CAS seed:

```text
TPL_AIR_US_KAF_A10C_CAS_2SHIP
```

It defines the exact DCS payload to be used by this template. It does **not** claim that every real A-10C sortie from Kandahar carried this exact combination or station arrangement.

The decision was taken from the project-owner-supplied Mission Editor view of `OMW_Template_v4_Kandahar.miz` on 1 August 2026. No saved `.miz` file or SHA-256 was supplied with the screenshot. The payload therefore remains an authoring decision until the saved mission table is inspected and the exact artifact is hashed.

## 2. Current template authoring state

Observed Mission Editor state:

```text
Group: TPL_AIR_US_KAF_A10C_CAS_2SHIP
Aircraft type: A-10C II / DCS type A-10C_2
Group size: 2 aircraft
Task: CAS
Skill: Veteran
Late Activation: enabled
Callsign: Pig 1
Radio: 251 MHz AM
Livery: 74th FS Moody AFB, Georgia (t)
Internal fuel: 100 percent / 11,087 lb
Gun ammunition: 100 percent / CM mixed
Chaff: 240
Flares: 240
Displayed weapon mass: 5,697 lb
Displayed total mass: 42,413 lb
Displayed maximum mass: 46,476 lb
Displayed load ratio: 91 percent
```

The displayed mass values are DCS Mission Editor observations for this specific configuration, not independent real-aircraft performance data.

## 3. Binding station allocation

DCS station numbering is recorded exactly as shown in the A-10C II loadout editor:

| Station | Binding store |
|---:|---|
| 11 | Empty |
| 10 | AN/AAQ-28 LITENING II AT targeting pod as represented by DCS A-10C II |
| 9 | SUU-25 illumination-flare dispenser; eight rounds shown by the DCS payload display; exact LUU-2 subtype not captured in the supplied screenshot |
| 8 | 1 × GBU-38 JDAM |
| 7 | 1 × GBU-38 JDAM |
| 6 | Empty |
| 5 | 1 × GBU-38 JDAM |
| 4 | 1 × GBU-38 JDAM |
| 3 | LAU-117 with 1 × AGM-65D Maverick |
| 2 | LAU-131 with 7 × Hydra 70 M156 SM |
| 1 | Empty |

Internal weapon:

```text
GAU-8/A
DCS gun load: 100 percent
DCS ammunition selection: CM mixed
```

Compact payload signature:

```text
TGP*1, SUU-25*1, GBU-38*4, AGM-65D*1, LAU-131/M156-SM*7, GAU-8/A
```

Both aircraft in the two-ship authoring seed are to use the same payload unless a later documented section-level mixed-load decision explicitly replaces this rule.

## 4. Lateral distribution decision

The four GBU-38 are paired symmetrically around the aircraft centerline:

```text
Station 8 <-> Station 4
Station 7 <-> Station 5
```

The remaining non-identical stores are deliberately split across the two sides:

```text
Stations 10 and 9: targeting pod plus SUU-25
Stations 3 and 2: AGM-65D/LAU-117 plus LAU-131/M156
```

This replaces the rejected working arrangement that placed the targeting pod and Maverick on the same side. The adopted arrangement is an OMW Mission Editor balancing decision. It is not presented as proof of an official USAF station-by-station standard.

## 5. Historical evidence and its limits

### 5.1 Directly supported

Official U.S. Air Force and DVIDS material supports the following points:

- the 74th Expeditionary Fighter Squadron operated A-10C aircraft from Kandahar Airfield in 2011;
- GBU-38 bombs were loaded onto A-10C aircraft at Kandahar on 8 August 2011 by personnel deployed from the 74th Aircraft Maintenance Unit;
- an attached rocket pod was serviced on an A-10C at Kandahar on the same date;
- an AGM-65 Maverick and its launching mechanism were installed on a Kandahar A-10 in December 2011;
- 30 mm ammunition was uploaded for Kandahar A-10 missions;
- DCS represents the A-10C targeting system with the LITENING II AT pod.

Primary references:

1. U.S. Air Forces Central, `74th EFS, Thunder!`, 25 March 2011: https://www.afcent.af.mil/News/Article/219569/74th-efs-thunder/
2. DVIDS image 441976, GBU-38 loading at Kandahar, 8 August 2011: https://www.dvidshub.net/image/441976/airmen-deployed-afghanistan-load-ammo-onto-10s-missions
3. DVIDS image 441975, rocket-pod servicing at Kandahar, 8 August 2011: https://www.dvidshub.net/image/441975/airmen-deployed-afghanistan-load-ammo-onto-10s-missions
4. DVIDS image 494073, AGM-65 installation at Kandahar, 2 December 2011: https://www.dvidshub.net/image/494073/10-inspection
5. DVIDS image 441966, 30 mm ammunition upload at Kandahar, 8 August 2011: https://www.dvidshub.net/image/441966/airmen-deployed-afghanistan-load-ammo-onto-10s-missions
6. Eagle Dynamics, DCS A-10C Warthog product description, LITENING II AT targeting pod: https://www.digitalcombatsimulator.com/en/products/warthog/?SHOWALL_1=1

### 5.2 Not directly proven by those sources

The reviewed sources do not establish all of the following as one historical standard configuration:

```text
exactly four GBU-38 on every standard CAS sortie
AGM-65D rather than another Maverick subtype
M156 SM rather than another 70 mm rocket warhead
SUU-25 on the same aircraft and sortie
this exact station-by-station arrangement
this exact 42,413 lb launch configuration
```

The official rocket-pod caption does not identify the loaded rocket subtype. The official Maverick caption does not identify the missile subtype. The M156 SM and AGM-65D selections are therefore explicit OMW standardizations within the weapons available to the DCS A-10C II.

The complete payload is a source-informed **composite CAS loadout**, not a verbatim reconstruction of one documented aircraft photograph or published load sheet.

## 6. Role and employment boundary

This is the primary Kandahar CAS seed for the active OMW A-10C component:

```text
SQ_US_KAF_A10C_74_EFS
74th Expeditionary Fighter Squadron
16 logical A-10C aircraft
```

Intended mission set:

```text
on-call and preplanned CAS
armed overwatch
troops-in-contact support
point-target attack against vehicles and compounds
marking and smoke support through M156 SM
night or reduced-visibility support through TGP and illumination flares
```

The template is not a dedicated anti-armor, runway-attack, SEAD, training, or ferry configuration.

Player-client rearm choices are not automatically restricted by this AI authoring decision. A separate client-payload policy is required if player aircraft are to be forced to the same baseline.

## 7. Required saved-mission verification

Before the payload is treated as an audited mission artifact, the next supplied `.miz` must confirm:

```text
exact mission filename, size and SHA-256
TPL_AIR_US_KAF_A10C_CAS_2SHIP remains 2 x A-10C_2
both template units carry the exact station allocation from section 3
both units remain Late Activation and not Uncontrolled
task remains CAS
skill remains Veteran
fuel, gun load and countermeasure values match section 2
no obsolete A-10C rather than A-10C_2 template type returns
```

The first controlled DCS acceptance must additionally prove:

```text
successful AIRWING/SQUADRON registration
successful spawn from an approved Kandahar Main parking node
successful taxi and takeoff at the configured mass
no payload-related Lua or DCS error
safe recovery or explicitly recorded loss
```

Until those checks pass:

```yaml
payload_authoring_decision: BINDING
saved_mission_payload_audit: PENDING
dcs_spawn_takeoff_recovery_acceptance: NOT_RUN
validated_in_dcs: false
```

## 8. Superseded working assumptions

This decision supersedes the following provisional statements for the Kandahar A-10C template:

```text
Sniper XR is the DCS A-10C II targeting pod
Maverick and targeting pod should be grouped on the same side
AGM-65D, M156 SM or the complete composite loadout are directly proven as one historical Kandahar standard
station allocation may be inferred without reading the DCS A-10C II station numbers
```

The binding DCS pod identification is the LITENING II AT representation, and the binding station arrangement is the table in section 3.