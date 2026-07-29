---
document_id: OMW-HIST-ISAF-FORCE-POSTURE-MAPS-ADDITIONAL-SOURCES
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_CONTEXT_REFERENCE
authoritative_for:
  - supplied ISAF RC and PRT force-posture map interpretation
  - source-critical use of the 2009 insurgency essay
  - source-critical use of the 2008 RC-East OSINT summary
  - historical sanctions-list context with data minimization
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/stability-layeha-route-clearance-cerp-sigacts
validated_in_dcs: false
---

# ISAF Force-Posture Maps and Additional Historical Sources

## 1. ISAF RC and PRT maps

The supplied map set depicts Afghanistan Regional Command boundaries, PRT or city markers, lead-nation flags and national troop totals. The legend reports an approximate total of 71,030 personnel. Visible national totals include United States 34,800; United Kingdom 9,000; Germany 4,365; France 3,095; Canada 2,830; Italy 2,795; Netherlands 2,160; Poland 1,910; Australia 1,350; Spain 1,000 and additional smaller contingents.

Visible locations include Bagram, Jalalabad, Mehtar Lam, Asadabad, Kalagush, Kabul, Gardez, Khost, Ghazni, Sharana, Mazar-e-Sharif, Kunduz, Pul-i-Khumri, Bamyan, Herat, Farah, Shindand, Chaghcharan, Tarin Kowt, Qalat, Kandahar and Lashkar Gah.

The supplied images do not expose a reliable publication date. They are therefore classified as:

```text
UNDATED_VISUAL_FORCE_POSTURE_REFERENCE
```

They may support spatial and national-lead context, but not exact scenario-date strength or active OMW ORBAT.

## 2. 2009 essay on the growing Taliban insurgency

Amina Khan, *US and Growing Taliban Insurgency in Afghanistan*, Reflections No. 2, 2009, is a contemporary political-analysis source. It discusses deteriorating security, reconciliation, reintegration, local grievances, political inclusion, Pashtun alienation, the Sarposa prison break and negotiations involving Taliban or HIG-linked actors.

Use rules:

```text
AUTHOR_ASSESSMENT != VERIFIED_INTELLIGENCE
SOURCE_REPORTED_PERCENTAGE != PROJECT_FACT
RECONCILABLE_LABEL != FIXED_FACTION_IDENTITY
```

The essay supports political-context and reconciliation design, but not active ORBAT or exact control percentages.

## 3. RC East OSINT Summary - 18 December 2008

The supplied copy is titled *The Landing Zone - RC East OSINT Summary* and retains visibly struck-through `SECRET//REL TO USA, ISAF, NATO` headers plus a partial FOIA-case indicator. It contains open press reporting and analyst comments concerning reconciliation, Taliban/Al-Qaida tensions, information activity, coalition reinforcement, private security companies and a Khost operation.

Source classification:

```yaml
source_class: OFFICIALLY_PUBLIC_FOIA_RELEASE_INDICATED
original_marking: SECRET//REL TO USA, ISAF, NATO
marking_status: visibly_struck_through
foia_indicator: present_but_case_number_incomplete
```

Usable content is separated as:

```text
PRESS_REPORT
SOURCE_QUOTATION
ANALYST_ASSESSMENT
PROJECT_DERIVATION
```

Analyst speculation is never promoted to fact. The PDF is not committed to the public repository. Historical use includes reconciliation concepts, the RC-East information environment, local grievances and coalition-GIRoA coordination problems.

## 4. Consolidated sanctions list - 31 January 2002

The Canadian consolidated list reproduces historical UN and Canadian sanctions designations for Taliban officials, Al-Qaida-associated persons and entities and numerous unrelated international organizations. It predates the scenario by more than eight years.

Permitted use:

- historical office and alias cross-checks for already relevant Taliban figures;
- pre-2002 institutional background;
- historical diplomatic and provincial-office context.

Prohibited repository use:

- reproduction of private addresses, telephone numbers, identification numbers or comparable personal data;
- treating the 2002 list as a 2010/2011 network ORBAT;
- assuming continued designation or role without period-appropriate corroboration.

```text
PRE_PERIOD_SANCTIONS_LIST != SCENARIO_PERIOD_ORBAT
HISTORICAL_ALIAS != CURRENT_IDENTITY_CONFIRMATION
```

## 5. Binding limits

1. Document 19 remains the authority for active OMW air ORBAT and player slots.
2. Undated maps do not establish exact scenario-date strength.
3. Political essays and OSINT summaries retain their source perspective and confidence.
4. Historical classifications and release markings are recorded, not silently removed.
5. Sensitive personal data from historical lists are minimized and not republished.
