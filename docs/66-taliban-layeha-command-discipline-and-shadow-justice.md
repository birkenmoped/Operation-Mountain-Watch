---
document_id: OMW-RED-LAYEHA-COMMAND-DISCIPLINE-SHADOW-JUSTICE
status: BINDING
document_class: SOURCE_CRITICAL_RED_DESIGN_REFERENCE
authoritative_for:
  - Taliban 2009 Layeha-derived command and discipline abstractions
  - RED local-command friction and shadow-justice modeling
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/stability-layeha-route-clearance-cerp-sigacts
validated_in_dcs: false
---

# Taliban Layeha, Command Discipline, Shadow Justice and Local Friction

## 1. Source and qualification

Primary source: Naval Postgraduate School, Program for Culture and Conflict Studies, *Analyzing the Taliban Code of Conduct: Reinventing the Layeha*, 6 August 2009. The paper analyzes the 2009 Taliban rules and compares them with the 2006 Layeha.

```text
LAYEHA_RULE != OBSERVED_BEHAVIOR
STRATEGIC_DIRECTIVE != LOCAL_COMMANDER_COMPLIANCE
```

## 2. Organizational model

The 2009 document contains 13 chapters and 67 rules and appears aimed primarily at group leaders commanding approximately 10-15 fighters. It also assigns responsibilities to district and provincial authorities. The NPS analysis interprets the expanded rules as an attempt to consolidate command and control and restrain rogue, criminal or factional behavior.

```yaml
red_command:
  strategic_cohesion: 0..100
  provincial_control: 0..100
  district_control: 0..100
  local_commander_compliance: 0..100
  discipline: 0..100
  criminality_pressure: 0..100
  war_booty_competition: 0..100
  internal_rivalry: 0..100
  propaganda_damage: 0..100
  local_legitimacy: 0..100
  shadow_justice_capacity: 0..100
```

The rules cover security, prisoners, alleged spies, enemy logistics and construction, captured equipment, organization, personal conduct, education, local relations, prohibited behavior, command transmission and guerrilla fundamentals.

## 3. Population-centric behavior

The analysis highlights instructions to maintain relations with local communities, avoid internal tribal or linguistic fighting and dress like local people to reduce recognition and facilitate movement.

```text
LOCAL_DRESS -> LOWER_VISUAL_SIGNATURE
LOCAL_RELATIONSHIPS -> WARNING + SHELTER + LOGISTICS
INTERNAL_RIVALRY -> RED_FRICTION + OPSEC_FAILURE + DEFECTION_RISK
```

Local support and sanctuary are capabilities, but neither is inferred from tribe or ethnicity.

## 4. Criminality and command weakness

The source identifies leadership concern over kidnapping, extortion, mutilation, bribery, unauthorized checkpoints, looting, captured-vehicle misuse and personal enrichment. These behaviors damage political capital and drain resources.

OMW effects:

- local cells may deviate from commander intent for profit;
- criminal checkpoints may coexist with ideological activity;
- extortion raises short-term resources while reducing long-term support;
- disputes over loot, routes or illicit revenue create rivalry;
- discipline operations can disarm, replace or punish a local commander.

## 5. Captured materiel and treasury

The source describes a central-treasury concept and rules for dividing captured material. Captured items may be retained locally, transferred upward or exploited for propaganda according to discipline, corruption, need and leadership control.

## 6. Logistics and construction targeting

Provincial authority is assigned decisions concerning captured drivers, contractors, vehicles and construction equipment. This supports RED mission logic for convoy surveillance, contractor intimidation, construction interdiction, capture or destruction of engineering assets and tension between local profit and provincial direction.

## 7. Shadow justice

The source describes provincial courts with a judge and religious experts for disputes beyond local leaders and elders. Field research cited by NPS reported that Taliban parallel justice could be perceived as swift and less corrupt than official channels.

```text
SHADOW_JUSTICE_POPULARITY != GENERAL_TALIBAN_SUPPORT
OFFICIAL_COURT_PRESENT != OFFICIAL_COURT_TRUSTED
```

## 8. Civilian harm and propaganda vulnerability

Restrictions on brutality, kidnapping and publicized executions are interpreted as evidence that leadership recognized political damage from such acts. The source also documents contradictions between rules and behavior.

- civilian harm by RED can reduce local legitimacy;
- graphic propaganda may motivate one audience and alienate another;
- local cadres may ignore politically motivated restraint;
- coalition information activity may exploit the gap between claimed discipline and observed abuse.

## 9. Binding RED rules

1. RED remains one consolidated project commander unless later changed by binding decision.
2. Local cells may have different discipline, criminality and compliance values.
3. Local support is never inferred from ethnicity or tribe alone.
4. The Layeha informs intent and organizational concern, not exact battlefield behavior.
5. Shadow governance and justice can operate independently of combat strength.
6. Leadership may punish commanders whose behavior threatens revenue, legitimacy or cohesion.
7. Captured equipment can create capability, competition or propaganda; it does not automatically enter inventory.

## 10. Source limits

- The NPS paper is an analytical interpretation of a captured and translated document.
- Literacy, dissemination and compliance rates are unknown.
- Specific allegations remain source-reported unless corroborated.
- Nothing here authorizes targeting, ROE or detention decisions.
