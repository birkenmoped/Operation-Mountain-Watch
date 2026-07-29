---
document_id: OMW-SP-LLM-COMMANDERS-INTERFACTION
status: DRAFT_DESIGN_BASELINE
document_class: INTER_FACTION_RELATIONSHIP_AND_NEGOTIATION_MODEL
scenario_period: 2010-08-01/2011-12-31
source_branch: docs/optional-llm-commanders
validated_in_dcs: false
---

# Beziehungen, Konkurrenz und Verhandlungen zwischen RED Commandern

## 1. Zweck

Dieses Dokument definiert, wie Taliban, Haqqani Network und HIG innerhalb der optionalen Multi-Commander-Kampagne miteinander umgehen.

Ziel ist kein statisches Bündnissystem, sondern ein dynamisches Verhältnis aus:

- gemeinsamer Gegnerschaft zu BLUE;
- formaler oder ideologischer Nähe;
- operativer Eigenständigkeit;
- lokal begrenzter Kooperation;
- Konkurrenz um Territorium, Personal, Geld, Prestige und politische Autorität;
- Misstrauen, Täuschung, gebrochenen Zusagen und zeitweiligen Absprachen.

```text
SHARED_ENEMY != UNIFIED_COMMAND
FORMAL_ALIGNMENT != SHARED_RESOURCES
LOCAL_COOPERATION != STRATEGIC_TRUST
```

## 2. Bilaterale und asymmetrische Beziehungen

Jede Beziehung wird zweimal geführt:

```text
TALIBAN_VIEW_OF_HAQQANI
HAQQANI_VIEW_OF_TALIBAN
```

Die Werte müssen nicht identisch sein. Ein Akteur kann stärker abhängig sein, mehr Vertrauen investieren oder größere Konkurrenz wahrnehmen als sein Gegenüber.

```yaml
relationship_state:
  actor_id: string
  counterpart_id: string
  formal_alignment: 0..100
  ideological_alignment: 0..100
  political_trust: 0..100
  operational_trust: 0..100
  personal_network_trust: 0..100
  intelligence_sharing_willingness: 0..100
  logistics_cooperation_willingness: 0..100
  transit_cooperation_willingness: 0..100
  joint_operation_willingness: 0..100
  territorial_competition: 0..100
  recruitment_competition: 0..100
  revenue_competition: 0..100
  patronage_competition: 0..100
  prestige_competition: 0..100
  political_representation_competition: 0..100
  grievance_level: 0..100
  dependency: 0..100
  fear_of_betrayal: 0..100
  conflict_risk: 0..100
  negotiation_channel_quality: 0..100
```

## 3. Beziehungsebenen

Beziehungen werden auf drei Ebenen getrennt bewertet:

### 3.1 Strategische Ebene

- politische Anerkennung;
- langfristige Zielkompatibilität;
- Stellung gegenüber externer Unterstützung;
- Anspruch auf Gesamtführung;
- Verhandlungsstrategie gegenüber Regierung und Koalition;
- überregionale Prestige- und Repräsentationsfragen.

### 3.2 Operative Ebene

- Nutzung von Routen und Safehavens;
- Austausch von Spezialisten oder Informationen;
- Deconfliction paralleler Operationen;
- gemeinsame Schwerpunktbildung;
- Ressourcentransfers;
- zeitweise Unterstützung unter BLUE-Druck.

### 3.3 Lokale Ebene

- persönliche Beziehungen einzelner Kommandeure;
- Streit um Checkpoints, Steuern, Schmuggel oder Verträge;
- Konkurrenz um Rekruten und Informanten;
- Familien-, Patronage- und Stammeskontakte;
- lokale Waffenruhe;
- spontane Zusammenarbeit oder bewaffneter Konflikt.

Ein positives strategisches Verhältnis verhindert keinen lokalen Konflikt. Umgekehrt beweist lokale Kooperation keine strategische Allianz.

## 4. Ausgangsprofile 2010-2011

Die folgenden Werte sind keine historischen Messdaten. Sie sind vorläufige Simulationsstartbereiche, die später durch die Fraktionsdossiers und Szenariovorgaben präzisiert werden.

### 4.1 Taliban gegenüber Haqqani

```yaml
taliban_to_haqqani:
  formal_alignment: 75..95
  ideological_alignment: 65..90
  political_trust: 55..80
  operational_trust: 60..85
  intelligence_sharing_willingness: 45..75
  logistics_cooperation_willingness: 50..80
  joint_operation_willingness: 50..80
  territorial_competition: 15..50
  revenue_competition: 15..45
  prestige_competition: 30..65
  dependency: 20..55
  conflict_risk: 5..30
```

Taliban kann Haqqani als leistungsfähigen, formal verbundenen, aber eigenständigen Partner betrachten. Reibung entsteht, wenn Haqqani lokale Autorität, Ressourcen oder Prestige beansprucht, ohne sich ausreichend kontrollieren zu lassen.

### 4.2 Haqqani gegenüber Taliban

```yaml
haqqani_to_taliban:
  formal_alignment: 75..95
  ideological_alignment: 65..90
  political_trust: 50..80
  operational_trust: 60..85
  intelligence_sharing_willingness: 35..70
  logistics_cooperation_willingness: 45..80
  joint_operation_willingness: 50..85
  territorial_competition: 10..45
  revenue_competition: 10..40
  prestige_competition: 35..70
  dependency: 15..50
  fear_of_betrayal: 15..45
  conflict_risk: 5..25
```

Haqqani kann die formale Verbindung akzeptieren, gleichzeitig jedoch eigene Netzwerke, Quellen und Capability Packages schützen. Hohe operative Kooperation darf nicht automatisch zu vollständiger Informationsteilung führen.

### 4.3 Taliban gegenüber HIG

```yaml
taliban_to_hig:
  formal_alignment: 10..35
  ideological_alignment: 35..65
  political_trust: 10..35
  operational_trust: 15..45
  intelligence_sharing_willingness: 5..35
  logistics_cooperation_willingness: 10..45
  joint_operation_willingness: 15..55
  territorial_competition: 40..85
  recruitment_competition: 35..75
  revenue_competition: 40..85
  political_representation_competition: 45..90
  grievance_level: 20..70
  conflict_risk: 25..75
```

Taliban kann HIG lokal als nützlichen Mitkämpfer, politisch jedoch als konkurrierende Organisation betrachten. Absprachen bleiben regional, zeitlich und zweckgebunden.

### 4.4 HIG gegenüber Taliban

```yaml
hig_to_taliban:
  formal_alignment: 5..30
  ideological_alignment: 30..60
  political_trust: 5..30
  operational_trust: 10..40
  intelligence_sharing_willingness: 5..30
  logistics_cooperation_willingness: 10..40
  joint_operation_willingness: 15..50
  territorial_competition: 45..90
  recruitment_competition: 40..80
  revenue_competition: 45..90
  political_representation_competition: 55..95
  grievance_level: 25..75
  fear_of_betrayal: 35..80
  conflict_risk: 30..80
```

HIG kann die militärische Stärke der Taliban anerkennen, ohne deren politischen Führungsanspruch zu akzeptieren. Hohe Verhandlungsorientierung erhöht zusätzlich den Verdacht, dass HIG eigene Vereinbarungen zulasten anderer Akteure sucht.

### 4.5 Haqqani und HIG

Die direkte Quellenlage ist schwächer. Daher gelten breitere Startbereiche:

```yaml
haqqani_to_hig:
  political_trust: 10..45
  operational_trust: 15..50
  joint_operation_willingness: 10..55
  territorial_competition: 15..65
  revenue_competition: 15..65
  prestige_competition: 20..60
  conflict_risk: 15..60
  negotiation_channel_quality: 20..65

hig_to_haqqani:
  political_trust: 10..40
  operational_trust: 10..45
  joint_operation_willingness: 10..50
  territorial_competition: 15..65
  revenue_competition: 15..65
  fear_of_betrayal: 25..70
  conflict_risk: 15..65
  negotiation_channel_quality: 20..65
```

```text
DEFAULT_RELATIONSHIP = PRAGMATIC_UNCERTAINTY
```

## 5. Regionale Beziehungsinstanzen

Eine landesweite Beziehung reicht nicht aus. Zusätzlich existiert je überlappendem Raum ein lokaler Zustand:

```yaml
regional_relationship:
  region_id: string
  actor_id: string
  counterpart_id: string
  local_commander_relationship: 0..100
  active_deconfliction: true|false
  shared_route_use: 0..100
  shared_safehaven_use: 0..100
  territorial_dispute: 0..100
  tax_or_revenue_dispute: 0..100
  recruitment_dispute: 0..100
  recent_cooperation: 0..100
  recent_violence: 0..100
  mediator_present: true|false
  local_agreement_ids: []
```

Beispiel: Taliban und HIG können in einem Distrikt kooperieren, während sie in einem angrenzenden Distrikt um Steuereinnahmen kämpfen.

## 6. Verhandlungskanäle

Verhandlungen benötigen einen tatsächlichen Kanal:

```text
DIRECT_COMMANDER_CHANNEL
TRUSTED_EMISSARY
RELIGIOUS_MEDIATOR
LOCAL_ELDER
FAMILY_OR_PATRONAGE_CONTACT
POLITICAL_INTERMEDIARY
EXTERNAL_SPONSOR_CHANNEL
FIELD_COMMANDER_CONTACT
```

```yaml
negotiation_channel:
  channel_id: string
  participants: []
  channel_type: string
  reliability: 0..100
  secrecy: 0..100
  latency_hours: number
  distortion_risk: 0..100
  compromise_risk: 0..100
  mediator_bias: 0..100
  active: true|false
```

Ohne Kanal kann kein Commander direkt mit einem anderen kommunizieren. Schlechte Kanäle können Nachrichten verzerren, verspätet übermitteln oder kompromittieren.

## 7. Verhandlungsobjekte

Zulässige Verhandlungsgegenstände:

```text
INFORMATION_EXCHANGE
TRANSIT_ACCESS
SAFEHOUSE_ACCESS
ROUTE_DECONFLICTION
TEMPORARY_AREA_DECONFLICTION
RESOURCE_TRANSFER
SPECIALIST_SUPPORT
JOINT_OPERATION
PRISONER_OR_DETAINEE_MATTER
CREDIT_AND_PROPAGANDA_CLAIM
REVENUE_SHARING
LOCAL_NON_AGGRESSION
TEMPORARY_TRUCE
MEDIATION_OF_COMMANDER_DISPUTE
WITHDRAWAL_FROM_DISPUTED_AREA
```

Nicht jeder Commander darf alle Gegenstände mit gleicher Wahrscheinlichkeit anbieten. HIG erhält beispielsweise eine höhere Grundneigung zu politischen Absprachen; Haqqani kann eher spezifische Capability- oder Transitvereinbarungen bevorzugen.

## 8. Vereinbarungsmodell

```yaml
agreement:
  agreement_id: string
  parties: []
  agreement_type: string
  geographic_scope: []
  valid_from: timestamp
  valid_until: timestamp|null
  public_or_secret: public|secret|partially_disclosed
  obligations: []
  benefits: []
  verification_method: []
  breach_conditions: []
  termination_conditions: []
  mediator_id: string|null
  confidence_in_counterpart_compliance: 0..100
  campaign_state: proposed|negotiating|active|suspended|breached|expired|terminated
```

### 8.1 Verpflichtung

```yaml
obligation:
  obligation_id: string
  responsible_party: string
  action: string
  deadline: timestamp|null
  resource_ceiling: {}
  verification: string
  fulfilled: true|false|unknown
```

## 9. Verhandlungsentscheidung

Der empfangende Commander bewertet:

```text
EXPECTED_BENEFIT
+ BLUE_PRESSURE_RELIEF
+ RESOURCE_GAIN
+ ACCESS_GAIN
+ RIVAL_CONTAINMENT
+ POLITICAL_GAIN
- BETRAYAL_RISK
- PRESTIGE_COST
- AUTONOMY_COST
- INFORMATION_EXPOSURE
- COUNTERPART_STRENGTHENING
- OPPORTUNITY_COST
```

Zusätzliche Persönlichkeitsmodifikatoren:

- Pragmatismus erhöht Annahme zweckmäßiger Absprachen.
- ideologische Starrheit reduziert bestimmte Kompromisse.
- Misstrauen erhöht Verifikationsanforderungen.
- Prestigeempfindlichkeit erschwert einseitig wirkende Zugeständnisse.
- hohe politische Sensibilität kann eine militärisch günstige, politisch schädliche Vereinbarung verhindern.

## 10. Informationsaustausch

Information wird nicht als vollständige Datenbankfreigabe behandelt.

```yaml
shared_information:
  sender: string
  receiver: string
  knowledge_ids: []
  fidelity: 0..100
  intentional_omissions: []
  intentional_distortion: 0..100
  attribution: confirmed|claimed|anonymous
  sharing_restrictions: []
  expiry: timestamp|null
```

Ein Commander kann:

- wahre Information vollständig teilen;
- Teile zurückhalten;
- Unsicherheit verschweigen;
- eine Meldung absichtlich verzerren;
- falsche Attribution verwenden;
- einen Rivalen mit korrekter, aber selektiver Information lenken.

Die technische Ebene muss zwischen Irrtum und bewusster Täuschung unterscheiden.

## 11. Gemeinsame Operationen

Eine gemeinsame Operation besitzt keinen automatisch gemeinsamen Oberbefehl.

```yaml
joint_operation:
  operation_id: string
  participants: []
  sponsor: string
  lead_actor: string|null
  shared_objective: string
  individual_objectives: {}
  geographic_scope: []
  contribution_commitments: {}
  information_sharing_scope: []
  deconfliction_rules: []
  credit_sharing_rule: string
  abort_rights: {}
  withdrawal_rules: []
  betrayal_risk: 0..100
  status: proposed|assembling|ready|executing|complete|failed|aborted|disputed
```

Jeder Teilnehmer behält:

- eigene Kräfte;
- eigene Ressourcenbuchung;
- eigenes Lagebild;
- eigenes Abbruchrecht;
- eigene versteckte Ziele;
- eigene Bewertung des Ergebnisses.

### 11.1 Verdeckte Ziele

Mögliche versteckte Ziele:

```text
TEST_COUNTERPART_RELIABILITY
GAIN_ROUTE_ACCESS
OBSERVE_COUNTERPART_CAPABILITY
SHIFT_LOSSES_TO_COUNTERPART
CLAIM_DISPROPORTIONATE_CREDIT
WEAKEN_LOCAL_RIVAL
CREATE_FUTURE_DEPENDENCY
EXPOSE_COUNTERPART_NETWORK
```

Verdeckte Ziele dürfen nur innerhalb definierter Persönlichkeits-, Beziehungs- und Szenariogrenzen gewählt werden.

## 12. Deconfliction ohne Kooperation

Zwei Commander können eine Zusammenarbeit ablehnen, aber dennoch gegenseitige Störung vermeiden.

```yaml
deconfliction_measure:
  area: []
  time_window: {}
  restricted_actions: []
  communication_procedure: string
  identification_method: string
  violation_response: string
```

Beispiele:

- getrennte Operationsfenster;
- unterschiedliche Routen;
- keine Rekrutierung in einem definierten lokalen Netzwerk;
- keine Besteuerung bestimmter Märkte durch beide Seiten;
- gegenseitige Warnung vor BLUE-Operationen ohne weitergehenden Informationsaustausch.

## 13. Konflikteskalation

### 13.1 Eskalationsleiter

```text
POLITICAL_DISPUTE
-> PRIVATE_WARNING
-> WITHHOLD_INFORMATION
-> WITHHOLD_SUPPORT
-> COMPETE_FOR_LOCAL_ACTORS
-> OBSTRUCT_ROUTE_OR_REVENUE
-> DETAIN_OR_DISARM_LOCAL_MEMBERS
-> LIMITED_LOCAL_CLASH
-> RETALIATORY_ATTACK
-> SUSTAINED_LOCAL_CONFLICT
```

Nicht jeder Streit muss diese Leiter vollständig durchlaufen.

### 13.2 Eskalationsfaktoren

```text
territorial_overlap
revenue_dispute
recruitment_poaching
broken_agreement
casualties_caused
prestige_humiliation
suspected_betrayal
external_sponsor_pressure
weak_mediation
high_local_commander_autonomy
```

### 13.3 Deeskalationsfaktoren

```text
increased_blue_pressure
credible_mediator
resource_exhaustion
leadership_intervention
mutual_dependency
shared_immediate_threat
compensation
territorial_separation
replacement_of_local_commander
```

## 14. Vertragsbruch und Attribution

Ein Vertragsbruch ist nicht automatisch eindeutig.

```yaml
breach_assessment:
  agreement_id: string
  alleged_breaching_party: string
  observed_event: string
  attribution_confidence: 0..100
  accidental_or_deliberate: accidental|reckless|deliberate|unknown
  local_or_authorized: local|central|unknown
  severity: 0..100
  public_visibility: 0..100
```

Der Commander kann auf einen vermuteten Bruch reagieren, obwohl die Attribution falsch ist. Das eröffnet BLUE-Täuschung und Missverständnisse als Kampagnenelemente.

## 15. Prestige und Zuschreibung von Erfolgen

Erfolge besitzen eine materielle und eine politische Attribution.

```yaml
credit_claim:
  event_id: string
  claimant: string
  claimed_contribution: 0..100
  actual_contribution_known_to_state: 0..100
  evidence_presented: []
  audience: local|regional|national|external
  counterpart_dispute: true|false
```

Mögliche Folgen:

- Rekrutierungsvorteil;
- höheres Prestige;
- mehr externe Unterstützung;
- Verschlechterung der Partnerbeziehung;
- Forderung nach größerem Ressourcenanteil;
- lokaler Wechsel von Kommandeuren oder Unterstützern.

## 16. Ressourcenübertragung

```yaml
resource_transfer:
  transfer_id: string
  sender: string
  receiver: string
  resource_type: string
  amount: 0..100
  ownership_after_transfer: receiver|temporary_loan|shared_use
  expected_return: string|null
  delivery_route: string|null
  compromise_risk: 0..100
  conditions: []
  status: proposed|reserved|in_transit|delivered|intercepted|diverted|disputed
```

Ressourcen können unterwegs abgefangen, umgeleitet oder nur teilweise geliefert werden. Eine Zusage ist noch kein Bestand beim Empfänger.

## 17. Einfluss lokaler Kommandeure

Lokale Unterführer können zentrale Beziehungen verbessern oder beschädigen.

```yaml
local_commander_diplomacy:
  commander_id: string
  counterpart_contact: string
  authority_to_negotiate: 0..100
  personal_trust: 0..100
  private_interest: 0..100
  compliance_with_central_policy: 0..100
  ability_to_spoil_agreement: 0..100
```

Mögliche Ereignisse:

- lokale eigenmächtige Waffenruhe;
- geheime Einnahmenteilung;
- Angriff trotz zentraler Deconfliction;
- persönliche Fehde;
- Vermittlung eines regionalen Abkommens;
- falsche Meldung an die eigene Führung.

## 18. BLUE-Einwirkungsmöglichkeiten

BLUE kann Beziehungen beeinflussen, ohne vollständige Kontrolle zu besitzen:

```text
DISRUPT_COMMUNICATION_CHANNEL
EXPOSE_RESOURCE_COMPETITION
CREATE_ATTRIBUTION_UNCERTAINTY
PROTECT_DEFECTING_COMMANDER
INTERDICT_SHARED_ROUTE
PRESSURE_COMMON_SUPPORT_NODE
PUBLICIZE_ABUSE_OR_BROKEN_PROMISE
CHANGE_LOCAL_POWER_BALANCE
OFFER_POLITICAL_CHANNEL
CONDUCT_DECEPTION_OPERATION
```

Erfolg hängt von Intelligence-Qualität, Glaubwürdigkeit und tatsächlichen Bruchlinien ab. Die Simulation darf keine automatische Spaltung aufgrund pauschaler ethnischer oder tribaler Annahmen erzeugen.

## 19. Ereignisse und Beziehungsänderungen

```yaml
relationship_event:
  event_id: string
  actors: []
  event_type: string
  region: string|null
  verified_by_actor: {}
  trust_delta: {}
  grievance_delta: {}
  dependency_delta: {}
  competition_delta: {}
  conflict_risk_delta: {}
  memory_significance: 0..100
```

Beziehungswerte ändern sich durch Ereignisse, nicht allein durch Zeit. Langsamer Drift ist zulässig, beispielsweise wenn über lange Zeit kein Kontakt besteht.

## 20. LLM-Kommunikationsformat

```json
{
  "message_id": "MSG-2041",
  "sender": "HIG_COMMANDER",
  "recipient": "TALIBAN_COMMANDER",
  "channel_id": "CH-WARDAK-ELDER-02",
  "message_type": "PROPOSE_DECONFLICTION",
  "proposal": {
    "area": ["WARDAK-SECTOR-04"],
    "valid_hours": 72,
    "obligations": [
      "no_recruitment_from_counterpart_cells",
      "separate_route_use_windows"
    ]
  },
  "stated_reason": "Avoid losses while BLUE pressure remains high.",
  "requested_response_by": "timestamp",
  "disclosure": "secret"
}
```

Das LLM darf nur definierte Nachrichtentypen verwenden. Freier Text ist erläuternd, nicht technisch verbindlich.

## 21. Harte Regeln

1. Beziehungen sind bilateral und asymmetrisch.
2. Landesweite und regionale Beziehungen werden getrennt geführt.
3. Kooperation überträgt keine automatische Befehlsgewalt.
4. Informationen, Ressourcen und Kräfte bleiben Eigentum des jeweiligen Akteurs, sofern kein validierter Transfer vorliegt.
5. Eine gemeinsame Operation benötigt explizite Beiträge und Abbruchrechte.
6. Vereinbarungen benötigen Kanal, Laufzeit, Pflichten und Bruchbedingungen.
7. Lokale Gewalt wird nicht automatisch der zentralen Führung zugerechnet.
8. Haqqani-HIG-Beziehungen bleiben ohne weitere Quellen variabel und unsicher.
9. BLUE kann Bruchlinien beeinflussen, aber keine unbegründeten Fraktionskonflikte erzwingen.
10. Historische Kooperation oder Feindschaft wird nicht als unveränderliche Runtime-Regel behandelt.

## 22. Abnahmekriterien

Das Modell ist ausreichend, wenn:

- alle sechs gerichteten Beziehungen getrennt speicherbar sind;
- lokale Beziehungen vom strategischen Verhältnis abweichen können;
- Absprachen, Informationsaustausch, Ressourcentransfers und gemeinsame Operationen eigene Zustände besitzen;
- Vertragsbruch unsicher attribuiert werden kann;
- lokale Kommandeure zentrale Vereinbarungen stören können;
- Konkurrenz und Kooperation gleichzeitig möglich sind;
- BLUE glaubwürdige Möglichkeiten zur Netzwerkanalyse und Beeinflussung erhält;
- keine Beziehung eine automatische Allianz, Feindschaft oder Ressourcenvereinigung erzeugt.

## 23. Nächster Schritt

Als nächstes werden die fraktionsspezifischen Dossiers ausgearbeitet. Reihenfolge:

```text
04-taliban-commander-dossier.md
05-haqqani-commander-dossier.md
06-hig-commander-dossier.md
```

Das Taliban-Dossier bildet zuerst das politisch-territoriale Referenzprofil. Haqqani und HIG werden anschließend ausdrücklich als andersartige Commander und nicht als Varianten desselben Modells formuliert.
