---
document_id: OMW-COIN-GOVERNANCE-STRATEGY-TRANSITION
status: BINDING
document_class: SOURCE_CRITICAL_DESIGN_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - OMW campaign variables for subnational governance and perceived legitimacy
  - distinction between government presence, capability, representation and legitimacy
  - Afghan-led versus Afghan-self-sufficient security transition semantics
  - strategic-effect assessment for regular and irregular operations
  - source-qualified use of pre-period OEF air-ground and insurgency lessons
  - integration of RAND, US Army CMH and strategic-studies findings into OMW design
not_authoritative_for:
  - active OMW air or ground ORBAT
  - DCS Mission Editor unit counts or player slots
  - target authorization, ROE or No-Strike-List decisions
  - runtime acceptance of MOOSE implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghan-air-wars-source-integration
source_commit: 63b2f0c3be0a097bb9ac5a73694285df4c1f5676
validated_in_dcs: false
---

# COIN, Governance, Strategie und afghanisch geführter Übergang

## 1. Zweck

Dieses Dokument überführt die für Operation Mountain Watch verwertbaren Inhalte einer weiteren Quellencharge in eine gemeinsame, quellenkritische Designreferenz. Die Charge umfasst:

- offizielle Geschichtswerke des U.S. Army Center of Military History;
- RAND-Studien zu subnationaler Regierungsführung, Afghan-led COIN, COIN-Assessment und frühen Air-Ground-Operationen;
- Colin S. Grays strategietheoretische Studie zu irregulären Gegnern;
- ergänzende Überblicksseiten von CNN und Encyclopaedia Britannica.

Der Schwerpunkt liegt nicht auf zusätzlichen Runtime-Fraktionen oder automatischen Einheiten. Verbindlich bleibt:

```text
1 konsolidierter RED Commander
1 gemeinsamer REDState
1 gemeinsamer RED-Ressourcenpool
```

Die neue Evidenz erweitert vor allem:

1. die strategische Bewertung von BLUE- und RED-Aktionen;
2. das Governance- und Legitimitätsmodell;
3. die Readiness- und Enabler-Abhängigkeit afghanischer Kräfte;
4. die Quellenbasis für Moshtarak, Hamkari, RC-East und RC-South;
5. die Air-Ground-, ISR-, C2- und Logistikgrundlagen;
6. die historische Entwicklung gegnerischer Sanctuary- und Reinfiltrationsmuster.

## 2. Quellenhierarchie und Verwendungsgrenzen

### 2.1 Hauptquellen

| Quelle | Zeitbezug | Quellenklasse | OMW-Verwendung |
|---|---|---|---|
| Edmund J. Degen und Mark J. Reardon, *Modern War in an Ancient Land*, Band II, U.S. Army CMH, 2021 | 2005-2014; Schwerpunkt 2009-2011 | offizielle institutionelle Geschichtsdarstellung | Operationen, Kommandostrukturen, Force Laydowns, Moshtarak, Hamkari, ANSF, Special Operations, RC-East/RC-South |
| Michael Shurkin, *Subnational Government in Afghanistan*, RAND OP-318, 2011 | zeitgenössisch | peer-reviewte Forschungsstudie | Governance, lokale Legitimität, Repräsentation, Patronage, Gerichte, Shuras und Partnerauswahl |
| Seth G. Jones, *Transitioning to Afghan-Led Counterinsurgency*, RAND CT-361, Mai 2011 | zeitgenössisch | Expertenaussage/Policy-Analyse | Afghan-led COIN, ANSF/ALP, SOF, VSO und Enabler-Abhängigkeit |
| Christopher Paul et al., *Counterinsurgency Scorecard: Afghanistan in Early 2013*, RAND RR-396, 2013 | post-periodisch | vergleichende COIN-Methodik | Assessment-Methodik; keine Lagebeschreibung 2010/2011 |
| Walter L. Perry und David Kassing, *Toppling the Taliban*, RAND RR-381, 2015 | Operationen 2001-2002 | retrospektive Operationsanalyse | Air-Ground-Integration, ISR, HUMINT, Basing, C2 und Logistik als Vorperiodenlehre |
| Benjamin S. Lambeth, *Air Power Against Terror*, RAND MG-166-1, 2005 | Operationen 2001-2002 | detaillierte Airpower-Operationsanalyse | CAOC, Targeting, Air-Ground-Synergie, AAR, ISR-Fusion und Anaconda-Lehren |
| Brian F. Neumann et al., *Operation Enduring Freedom, March 2002-April 2005*, U.S. Army CMH | 2002-2005 | offizielle historische Darstellung | frühe Insurgentenregeneration, pakistanische Sanctuaries, CT/COIN-Spannung und geografische Netzwerke |
| Colin S. Gray, *Irregular Enemies and the Essence of Strategy*, 2006 | strategietheoretisch | Strategic Studies Institute / Naval History Online Reading Room | Mittel-Zweck-Beziehung, politische Wirkung und Anpassung an irreguläre Gegner |

### 2.2 Ergänzende Webquellen

| Quelle | Zulässige Verwendung | Grenze |
|---|---|---|
| CNN, *Operation Enduring Freedom Fast Facts* | Chronologie-Lead und Datumsabgleich | keine alleinige Autorität für ORBAT, Stärke oder TTP |
| Encyclopaedia Britannica, *Taliban* | allgemeiner historischer und begrifflicher Hintergrund | keine lokale oder zeitgenaue Operationsautorität |

### 2.3 Quellenkritische Grundregel

```text
OFFICIAL_HISTORY != COMPLETE_PRIMARY_RECORD
PEER_REVIEWED_STUDY != RUNTIME_PARAMETER
POST_PERIOD_ASSESSMENT != IN_PERIOD_SITUATION
WEB_TIMELINE != ORBAT_AUTHORITY
```

Jede konkrete Einheiten-, Stärke-, Orts- oder Operationsangabe muss weiterhin nach Zeit, Raum, Quellenklasse und Verwendungszweck qualifiziert werden.

## 3. Offizielle Kampagnen- und Operationsstruktur 2009-2011

*Modern War in an Ancient Land*, Band II, ist für unseren Zeitraum eine zentrale Referenz. Besonders relevant sind:

- McChrystals Assessment und die Umstellung des Kommandosystems;
- RC-South als Main Effort;
- parallele Entwicklungen in RC-East;
- Operation Moshtarak;
- Moshtarak Phase III und Operation Hamkari;
- die Ausbildung und Entwicklung der ANSF zwischen 2009 und 2011;
- Special Operations und lokale Sicherheitskräfte;
- die Entwicklung der Special-Operations-Kommandostruktur;
- Operationen gegen die nördliche Insurgenz;
- Force-Laydown- und Transfer-of-Authority-Karten bis Ende 2011.

### 3.1 Karten und Lagebilder

Die Quelle enthält insbesondere:

- RC-East Transfer of Authority, Juni 2009 bis November 2010;
- Moshtarak Phase I und II;
- RC-South und RC-Southwest, Juli 2010;
- Hamkari Phase II sowie Phase IIIA-IIIB;
- RC-East Transfer of Authority, November 2009 bis Dezember 2011;
- RC-South und RC-Southwest, Juli 2011;
- Force Laydown, 26. Dezember 2011.

Diese Karten sind wertvolle Vergleichs- und Plausibilitätsquellen für unsere Standort-, Sektor- und Einheitenrecherche. Sie sind nicht ohne Georeferenzierung als DCS-Koordinatendatensatz zu verwenden.

```text
HISTORICAL_MAP_LOCATION
-> verify_name
-> verify_date
-> georeference
-> compare_with_OMW_location_registry
-> verify_in_DCS_terrain
-> authorize_for_use
```

### 3.2 Operative Ableitung

Für OMW wird zwischen vier Ebenen unterschieden:

```text
CAMPAIGN_INTENT
REGIONAL_COMMAND_EFFECT
TACTICAL_OPERATION
LOCAL_CAMPAIGN_STATE_CHANGE
```

Eine taktisch erfolgreiche Räumung darf nicht automatisch als regionaler Kampagnenerfolg gelten. Moshtarak und Hamkari zeigen, dass Initialerfolg, Halten, Governance, ANSF-Präsenz und gegnerische Reinfiltration getrennt bewertet werden müssen.

## 4. Governance ist mehrdimensional

RAND OP-318 beschreibt das afghanische subnationale Regierungssystem als stark zentralisiert, lokal schwach und von erheblichen formellen sowie informellen Machtunterschieden geprägt.

### 4.1 Verbindliche Trennung

```text
GOVERNMENT_PRESENT != GOVERNMENT_CAPABLE
GOVERNMENT_CAPABLE != GOVERNMENT_REPRESENTATIVE
GOVERNMENT_REPRESENTATIVE != GOVERNMENT_LEGITIMATE
GOVERNMENT_SUPPORTED_BY_BLUE != LOCALLY_ACCEPTED
```

Ein Distriktgouverneur, Polizeichef, Rat oder Gericht ist zunächst nur eine Institution beziehungsweise ein Akteur. Seine Kampagnenwirkung hängt von tatsächlicher Leistung, lokaler Wahrnehmung, Repräsentation, Patronage, Sicherheit und Verhalten ab.

### 4.2 CampaignState-Felder

Für jeden politisch relevanten Sektor sind mindestens folgende getrennte Zustände vorzusehen:

```text
government_presence
government_service_delivery
government_legitimacy
local_representation
justice_access_formal
justice_access_informal
official_corruption
police_professionalism
police_abuse_risk
patronage_capture
local_powerbroker_influence
shura_representativeness
partner_reliability
population_access_to_government
population_fear_of_government
population_fear_of_red
```

Diese Werte dürfen nicht zu einem einzigen pauschalen `governance_score` verdichtet werden, ohne dass die Einzelwerte erhalten bleiben.

### 4.3 Formale und informelle Macht

Provincial- und District-Level-Funktionsträger können formal schwach, informell aber sehr mächtig sein. Mögliche Machtquellen sind:

- persönliche Beziehungen zur Zentralregierung;
- Stammes- und Familiennetzwerke;
- Zugriff auf legale oder illegale Einnahmen;
- Kontrolle bewaffneter Kräfte;
- Stellung als Gatekeeper zu PRT-, Regierungs- oder Hilfsressourcen;
- Kontrolle des Zugangs zu Gerichten, Verwaltung und Auftragsvergabe.

Daraus folgt:

```text
formal_authority
informal_influence
resource_gatekeeping
armed_backing
patronage_network
```

müssen getrennt modelliert werden.

### 4.4 Partnerauswahl

Vor der Unterstützung eines lokalen Partners sind nach Möglichkeit mehrere unabhängige Informationsquellen erforderlich.

```text
LOCAL_PARTNER_SUPPORT_ALLOWED only if:
- identity sufficiently established
- represented interests understood
- community reach estimated
- rivalries assessed
- abuse and corruption risk assessed
- reporting not based solely on the partner himself
```

Eine Shura, ein Ältester oder ein lokaler Beamter darf nicht allein aufgrund seiner Verfügbarkeit als legitimer Vertreter einer Gemeinschaft gelten.

```text
SHURA_EXISTS != SHURA_REPRESENTATIVE
ELDER_AVAILABLE != COMMUNITY_MANDATE
PRO_GOVERNMENT != NON_PREDATORY
```

### 4.5 Justiz und Streitbeilegung

Formelle und informelle Systeme können gleichzeitig existieren. Für die Bevölkerung zählt häufig weniger die formale Zuständigkeit als:

- Erreichbarkeit;
- Geschwindigkeit;
- Vorhersehbarkeit;
- wahrgenommene Fairness;
- Schutz vor Vergeltung;
- Durchsetzbarkeit einer Entscheidung.

Daraus entstehen getrennte Zustände:

```text
formal_justice_availability
formal_justice_trust
informal_justice_availability
informal_justice_trust
red_shadow_justice_access
dispute_resolution_delay
retaliation_risk
```

RED kann Einfluss gewinnen, ohne breite ideologische Zustimmung zu besitzen, wenn sein Streitbeilegungssystem schneller, erreichbarer oder durchsetzungsfähiger erscheint.

## 5. Legitimität ist Wahrnehmung, nicht nur Output

Objektive Leistungen wie gebaute Straßen, Schulen oder Brunnen können Legitimität unterstützen, erzeugen sie aber nicht automatisch.

```text
PROJECT_COMPLETED != LEGITIMACY_GAIN
SECURITY_FORCE_PRESENT != POPULATION_PROTECTED
ELECTION_HELD != REPRESENTATION_ACCEPTED
```

Ein Projekt kann die Legitimität sogar senken, wenn:

- nur ein Patronagenetz profitiert;
- Land- oder Wasserstreitigkeiten verschärft werden;
- Korruption sichtbar wird;
- eine Gruppe ausgeschlossen wird;
- Schutzversprechen nicht eingehalten werden;
- RED Unterstützer oder Beteiligte ungestraft einschüchtert.

### 5.1 Wirkungskette

```text
BLUE_OR_GOV_ACTION
-> objective_output
-> distribution_of_benefit
-> local_interpretation
-> perceived_fairness
-> security_consequence
-> legitimacy_effect
```

Die Kampagne muss nach dem wahrgenommenen Effekt bewerten, nicht allein nach dem ausgeführten Auftrag.

## 6. Afghan-led ist nicht Afghan-self-sufficient

RAND CT-361 beschreibt für Mai 2011 einen Übergang zu afghanisch geführter COIN, bei dem afghanische nationale und lokale Kräfte eine wachsende Rolle übernehmen, aber weiterhin externe Enabler benötigen.

### 6.1 Verbindliche Semantik

```text
AFGHAN_LED != AFGHAN_INDEPENDENT
AFGHAN_UNIT_PRESENT != MISSION_CAPABLE
TACTICAL_LEAD != ENABLER_SELF_SUFFICIENCY
```

Ein afghanischer Verband kann die taktische Führung innehaben und gleichzeitig abhängig sein von:

- ISR;
- Luftunterstützung;
- MEDEVAC;
- Logistik;
- Kommunikation;
- EOD;
- Intelligence Fusion;
- Mentoring und Stabsunterstützung;
- Civil Affairs und Information Operations.

### 6.2 ANSF-/ALP-Readiness-Modell

Für afghanische Kräfte sind getrennt zu führen:

```text
personnel_present
leadership_quality
small_unit_tactical_skill
staff_planning_capability
discipline
logistics_sustainment
intelligence_capability
communications_capability
eod_access
air_support_access
medevac_access
advisor_support
local_knowledge
local_legitimacy
infiltration_risk
patronage_dependency
```

### 6.3 Missionsauswirkung

Ein afghanisch geführter Einsatz kann je nach Enablerlage unterschiedliche Formen annehmen:

| Zustand | Mögliche OMW-Auswirkung |
|---|---|
| hohe Führung, gute lokale Legitimität, BLUE-Enabler verfügbar | selbstständige Bodenführung mit BLUE-On-Call-Support |
| gute taktische Kräfte, schwache Planung | gemeinsamer Stab oder BLUE-Mentoring erforderlich |
| geringe Logistik | kurze Operationsdauer oder Versorgungskonvoi nötig |
| kein MEDEVAC-Zugang | höhere Abbruchschwelle beziehungsweise geringere Einsatzbereitschaft |
| schwache Intelligence | höheres Risiko falscher Partner- oder Zielauswahl |
| hohe Infiltration | eingeschränkter Informationszugang und erhöhte Insidergefahr |

## 7. COIN-Assessment ohne Scheingenauigkeit

RAND RR-396 nutzt eine vergleichende Scorecard, warnt aber zugleich durch seine Methodik vor übermäßiger Sicherheit bei schwachen Daten. Für OMW wird kein historisches RAND-Gesamtergebnis als direkter 2010/2011-Wert übernommen.

### 7.1 Verwendbare Grundfaktoren

Besonders relevant sind:

1. greifbare Unterstützung des Gegners unterbrechen;
2. Commitment und Motivation von Regierung und Sicherheitskräften;
3. Flexibilität und Anpassungsfähigkeit der COIN-Kräfte.

### 7.2 OMW-Assessment-Regeln

```text
NO_METRIC_WITHOUT_DEFINITION
NO_SCORE_WITHOUT_SCOPE
NO_TREND_WITHOUT_METHOD_CONTINUITY
NO_CAMPAIGN_SUCCESS_FROM_SINGLE_MISSION
NO_CONTROL_VALUE_FROM_DAYLIGHT_PRESENCE_ONLY
```

Bewertungen benötigen mindestens:

```text
metric_name
definition
spatial_scope
temporal_scope
source
confidence
collection_method
last_updated
known_bias
```

### 7.3 Qualität vor Quantität

Eine größere nominelle Zahl lokaler Kräfte ist nicht automatisch besser. Besonders bei lokalen, irregulären oder paramilitärischen Sicherheitsakteuren können Zuverlässigkeit, Führung, Disziplin, Repräsentation und Verhalten wichtiger sein als Kopfzahl.

## 8. Strategie: militärische Aktion muss politische Wirkung erzeugen

Colin S. Gray beschreibt Strategie als Verbindung von militärischen Mitteln und politischen Zwecken. Für OMW ist damit jede Aktion auf mehreren Ebenen zu bewerten.

### 8.1 Verbindliche Wirkungskette

```text
TACTICAL_ACTION
-> OPERATIONAL_EFFECT
-> STRATEGIC_EFFECT
-> POLITICAL_AND_POPULATION_EFFECT
```

Eine Aktion kann taktisch erfolgreich und strategisch schädlich sein.

Beispiele:

- RED-Gruppe vernichtet, aber hohe zivile Schäden und Legitimitätsverlust;
- Route kurzfristig geöffnet, aber Kräfte werden dauerhaft gebunden und andere Räume bleiben ungeschützt;
- Cache gefunden, aber lokaler Informant wird nicht geschützt und künftige HUMINT bricht zusammen;
- Checkpoint gehalten, aber missbräuchliche lokale Sicherheitskräfte treiben Bevölkerung zu RED;
- BLUE zieht RED in ein langes Gefecht, RED erzielt jedoch den gewünschten Medien- und Ressourceneffekt.

### 8.2 Strategische Bewertungsfelder

```text
tactical_result
operational_freedom_of_action
resource_cost
force_protection_burden
population_security_effect
population_perception_effect
government_legitimacy_effect
red_influence_effect
intelligence_network_effect
media_information_effect
future_access_effect
```

### 8.3 RED-Strategie

Der konsolidierte RED Commander muss nicht regelmäßig taktische Siege erzielen. Strategischer Nutzen kann entstehen durch:

- Erzwingen hoher BLUE-Schutz- und Reaktionskosten;
- Störung von Regierung, Justiz und Dienstleistungen;
- Einschüchterung lokaler Partner;
- Schädigung staatlicher Legitimität;
- Bindung von ISR, EOD, QRF und Luftunterstützung;
- Erzeugen politisch oder medial schädlicher BLUE-Reaktionen;
- Aufrechterhaltung der Wahrnehmung, dass RED jederzeit zurückkehren kann;
- Nutzung von Zeit als Ressource.

```text
RED_TACTICAL_LOSS may still produce:
- BLUE_RESOURCE_DRAIN
- POPULATION_FEAR
- GOVERNMENT_DELEGITIMIZATION
- MEDIA_EFFECT
- RECRUITMENT_EFFECT
- FREEDOM_OF_ACTION_REDUCTION
```

## 9. Historische Entwicklung des gegnerischen Systems

Die CMH-Darstellung für 2002-2005 beschreibt die frühe Regeneration aus grenznahen und pakistanischen Rückzugsräumen:

- al-Qaida-Schwerpunkte in Nord- und Süd-Waziristan;
- Grenzübertritte nach Nuristan, Kunar, Nangarhar, Paktiya, Paktika und Khost;
- Taliban-Reorganisation im Raum Quetta;
- lokales Untertauchen insbesondere in Uruzgan und Kandahar;
- indirekte Angriffe, Minen und Raketen statt dauerhafter offener Gefechte;
- widersprüchliche pakistanische Interessen zwischen logistischer Unterstützung der USA und selektiver Schonung beziehungsweise Unterstützung militanter Gruppen.

Diese Vorperiodenquelle erklärt die spätere Netzwerklogik, ist aber keine direkte 2010/2011-Stärkereferenz.

```text
PRE_PERIOD_NETWORK_EVIDENCE
-> supports_behavior_model
-> supports_geographic_hypothesis
-> does_not_create_runtime_force
```

## 10. RED-Commander-Erweiterungen

Die neuen Quellen bestätigen die bestehende Ein-Gegner-Architektur. Ergänzt werden strategische Ziele und Lernfelder.

### 10.1 Strategische Prioritäten

1. Netzwerk und Führung überleben lassen.
2. externe und lokale Unterstützungswege aufrechterhalten.
3. staatliche und lokale Legitimität schwächen.
4. Bevölkerung einschüchtern oder zur Passivität zwingen.
5. BLUE zu hohen Schutz-, ISR-, EOD- und Reaktionskosten zwingen.
6. taktische Gefechte abbrechen, bevor überlegene Luft- oder QRF-Kräfte wirksam werden.
7. nach Räumungsoperationen zurückkehren, sofern Hold und Governance unzureichend sind.
8. aus wiederkehrenden BLUE-Verhaltensmustern begrenzt lernen.

### 10.2 Begrenztes RED-Wissen

```text
red_estimated_blue_qrf_time
red_estimated_cas_response_time
red_known_patrol_patterns
red_known_checkpoint_routines
red_known_landing_zones
red_observed_isr_windows
red_known_local_partner_vulnerabilities
red_estimated_population_fear
red_estimated_government_legitimacy
```

Jeder Wert benötigt:

```text
confidence
source_cell
last_observed
age_decay
possible_deception
```

Der RED Commander besitzt kein vollständiges Lagebild.

### 10.3 Zielauswahl

RED priorisiert nicht nur militärische Ziele. Mögliche strategische Ziele sind:

- Informanten und lokale Unterstützer;
- Richter, Beamte und Älteste;
- schwach geschützte Checkpoints;
- Route-Clearance-Routinen;
- Baustellen und Dienstleistungsprojekte;
- lokale Polizei mit geringer Legitimität;
- symbolische Regierungspräsenz;
- Kommunikations- und Versorgungsabhängigkeiten;
- bekannte Landeplätze und wiederkehrende Marschwege.

Die physische Darstellung in DCS bleibt missions- und ROE-abhängig. Viele Aktionen werden als CampaignState-Ereignis simuliert.

## 11. Air-Ground-, ISR- und C2-Lehren aus der Vorperiode

RAND RR-381 und MG-166-1 behandeln 2001-2002, liefern aber grundlegende Lehren, die später fortwirkten.

### 11.1 Sensoren und HUMINT

```text
SENSOR_DETECTION != IDENTIFICATION
HUMINT_REPORT != VERIFIED_FACT
IDENTIFICATION != TARGET_AUTHORIZATION
```

Technische Sensoren können HUMINT nicht ersetzen. HUMINT kann zugleich durch Eigeninteressen lokaler Akteure verfälscht sein. Verbindlich ist daher ein Fusionsmodell:

```text
technical_sensor
+ local_report
+ pattern_of_life
+ source_reliability
+ contextual_intelligence
-> assessed_contact
```

### 11.2 Air-Ground-Integration

Frühe OEF-Operationen zeigen die Wirksamkeit kleiner SOF-/Controller-Teams, die indigene Kräfte mit präziser Luftwirkung verbanden. Sie zeigen gleichzeitig die Risiken mangelnder gemeinsamer Planung, besonders bei Operation Anaconda.

Für OMW:

```text
GROUND_PLAN
AIR_PLAN
AIRSPACE_CONTROL
FIRE_SUPPORT_PLAN
ISR_PLAN
MEDEVAC_PLAN
CONTINGENCY_PLAN
```

müssen vor komplexen Operationen aufeinander abgestimmt werden.

### 11.3 Command and Control

Grundmodell:

```text
centralized_campaign_control
+ decentralized_tactical_execution
+ centralized_sensitive_target_authorization
```

Zu starke Zentralisierung taktischer Ausführung kann dynamische Reaktionen verzögern. Vollständig dezentrale Zielautorisierung ist bei zivilem Risiko, unklarer Identifizierung oder strategisch sensiblen Zielen ebenfalls unzulässig.

### 11.4 Logistik und Basing

Afghanistan ist ein landumschlossenes, infrastrukturell begrenztes Theater. Basing-, Transit-, Tanker- und Lufttransportrechte beeinflussen:

- verfügbare Flugzeugtypen;
- Station Time;
- Waffen- und Nutzlast;
- Reaktionszeit;
- Wartung;
- Durchhaltefähigkeit;
- Verfügbarkeit von Reserven;
- Evakuierung und MEDEVAC.

```text
MISSION_AVAILABLE only if:
- suitable_base_access
- route_or_airlift_support
- fuel_and_munitions
- maintenance_capacity
- crew_and_rest
- communications
- recovery_or_divert_option
```

## 12. BLUE-Commander-Entscheidungsmodell

Der BLUE Commander bewertet nicht nur Feindverluste, sondern die gesamte Wirkung.

### 12.1 Prioritäten

1. Bevölkerung und Partner vor kalkulierbarer Vergeltung schützen.
2. Regierungshandeln ermöglichen, ohne schädliche Patronage zu verstärken.
3. gegnerische Unterstützung, Caches, Routen und Intelligence-Netze stören.
4. ANSF schrittweise führen lassen, ohne Enabler-Abhängigkeit zu verbergen.
5. militärische Mittel so einsetzen, dass politische Ziele unterstützt werden.
6. taktische Erfolge halten und in Governance- beziehungsweise Sicherheitswirkung überführen.

### 12.2 Vor jeder Operation

```text
What political or campaign effect is intended?
Who benefits locally?
Who may be threatened or excluded?
Can BLUE and ANSF hold the area afterward?
Which governance actor will appear after CLEAR?
Is that actor locally accepted?
Which RED network can regenerate?
Which enablers are necessary?
What happens if the mission succeeds tactically but fails politically?
```

### 12.3 Nach jeder Operation

```text
Tactical result?
Population security improved or worsened?
Government legitimacy improved or worsened?
Informant network protected or exposed?
RED network destroyed, displaced or merely dormant?
ANSF capability demonstrated or masked by BLUE enablers?
Hold force sufficient?
Reinfiltration indicators present?
```

## 13. Missionstypen aus der Charge

### 13.1 Governance Support Mission

Ziel:

- Schutz einer Shura, eines Gerichts oder eines lokalen Verwaltungsereignisses;
- Prüfung tatsächlicher Repräsentation;
- Verhinderung von Einschüchterung;
- Gewinn lokaler Lageinformation.

Erfolg ist nicht nur die störungsfreie Veranstaltung, sondern auch:

```text
representative_participation
participant_survival
follow_up_access
perceived_fairness
absence_of_retaliation_or_effective_response
```

### 13.2 Afghan-Led Clearance

ANSF führt die Bodenoperation. BLUE stellt nur freigegebene Enabler.

Variable Enabler:

- ISR;
- JTAC/FAC(A);
- CAS;
- MEDEVAC;
- EOD;
- QRF;
- Logistik;
- Advisor Team.

Missionserfolg bewertet, ob ANSF tatsächlich führte und welche Abhängigkeiten sichtbar wurden.

### 13.3 Partner Reliability Investigation

Missionsziel ist nicht zwingend Kampf, sondern die Prüfung widersprüchlicher Meldungen über:

- lokale Führung;
- Korruption;
- Missbrauch;
- RED-Verbindungen;
- Rivalitäten;
- Manipulation von BLUE-Aufträgen.

### 13.4 Support-Network Disruption

Angriffsziel ist das greifbare Unterstützungssystem des Gegners:

- Cache;
- Kurier;
- Finanzvermittler;
- Transitpunkt;
- IED-Komponenten;
- Safehouse;
- lokaler Intelligence-Zugang.

Der Effekt wird nicht nur anhand zerstörter Objekte, sondern anhand der nachfolgenden RED-Operationsfähigkeit bewertet.

### 13.5 Hold and Governance Protection

Nach einer CLEAR-Operation werden Patrouillen, lokale Kräfte, HUMINT, QRF und Schutz für Amtsträger kombiniert. Ohne diesen Missionstyp darf der Sektor in `BLUE_CLEARED_NOT_HELD` zurückfallen und später `RED_REINFILTRATING` werden.

## 14. Datenmodell-Vorschlag

```yaml
sector_governance:
  government_presence: 0.0
  government_service_delivery: 0.0
  government_legitimacy: 0.0
  local_representation: 0.0
  justice_access_formal: 0.0
  justice_access_informal: 0.0
  official_corruption: 0.0
  police_professionalism: 0.0
  police_abuse_risk: 0.0
  patronage_capture: 0.0
  shura_representativeness: 0.0
  partner_reliability: 0.0

ansf_readiness:
  personnel_present: 0.0
  leadership_quality: 0.0
  tactical_skill: 0.0
  staff_planning: 0.0
  discipline: 0.0
  logistics_sustainment: 0.0
  intelligence_capability: 0.0
  communications_capability: 0.0
  air_support_access: 0.0
  medevac_access: 0.0
  advisor_support: 0.0
  local_legitimacy: 0.0
  infiltration_risk: 0.0

campaign_effect:
  tactical_result: null
  operational_freedom_of_action: 0.0
  resource_cost: 0.0
  population_security_effect: 0.0
  legitimacy_effect: 0.0
  red_influence_effect: 0.0
  intelligence_network_effect: 0.0
  information_effect: 0.0
```

Die konkreten Wertebereiche und Persistenzregeln werden erst in der CampaignState-Implementierung festgelegt.

## 15. Nicht zulässige automatische Ableitungen

Die Quellen autorisieren nicht automatisch:

- neue AIRWING- oder SQUADRON-Bestände;
- neue Player Slots;
- neue RED-Fraktionen;
- pauschale Loyalität ethnischer oder religiöser Gruppen;
- feste Kopfzahlen aus historischen Gesamtstärken;
- automatische Zielautorisierung für Moscheen, Schulen, Madrassas, Verwaltungsgebäude oder Wohnhäuser;
- pauschale Einstufung lokaler Polizei, Milizen oder Shuras als BLUE;
- Übertragung von 2001/2002-TTP ohne Anpassung auf 2010/2011;
- Übertragung von 2013-Assessmentwerten auf den Missionszeitraum.

## 16. Verknüpfung mit bestehender OMW-Dokumentation

Dieses Dokument ergänzt insbesondere:

- [`37-campaign-architecture-and-dynamic-mission-design.md`](37-campaign-architecture-and-dynamic-mission-design.md): CampaignState, strategische Wirkung und Missionsbewertung;
- [`45-air-c2-cas-afghanistan.md`](45-air-c2-cas-afghanistan.md): Air-Ground-Integration, C2 und dynamische Luftunterstützung;
- [`54-air-tasking-airspace-control-cas-requests-and-mission-data.md`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md): Airspace, Targeting und Joint Planning;
- [`56-insurgent-factions-shadow-governance-and-red-commander-behavior.md`](56-insurgent-factions-shadow-governance-and-red-commander-behavior.md): konsolidierter RED Commander und Bevölkerungseinfluss;
- [`57-kandahar-helmand-enemy-system-and-red-commander-strategy.md`](57-kandahar-helmand-enemy-system-and-red-commander-strategy.md): Moshtarak, Hamkari, Governance und Reinfiltration;
- [`58-eastern-afghanistan-network-operations-and-complex-attack-model.md`](58-eastern-afghanistan-network-operations-and-complex-attack-model.md): Sanctuary-, Transit- und Unterstützungsnetzwerke;
- [`59-campaign-assessment-operational-transitions-and-nonstate-security.md`](59-campaign-assessment-operational-transitions-and-nonstate-security.md): Assessment, Übergang, lokale Sicherheitsakteure und Clear-Hold-Build;
- [`60-afghan-air-wars-2009-2011-airpower-operations-reference.md`](60-afghan-air-wars-2009-2011-airpower-operations-reference.md): Airpower-, ISR-, CSAR- und RED-Luftmachtanpassung.

Bei Widerspruch gelten die Governance-Hierarchie und die fachlich speziellere aktuelle Quelle.

## 17. Quellenverzeichnis

### 17.1 Hochgeladene Dokumente

1. Edmund J. Degen und Mark J. Reardon, *Modern War in an Ancient Land: The United States Army in Afghanistan, 2001-2014*, Volume II, U.S. Army Center of Military History, 2021, Datei `59-1-p2.pdf`.
2. Michael Shurkin, *Subnational Government in Afghanistan*, RAND OP-318, 2011, Datei `RAND_OP318.pdf`.
3. Seth G. Jones, *Transitioning to Afghan-Led Counterinsurgency*, RAND CT-361, Mai 2011, Datei `RAND_CT361.pdf`.
4. Christopher Paul, Colin P. Clarke, Beth Grill und Molly Dunigan, *Counterinsurgency Scorecard: Afghanistan in Early 2013 Relative to Insurgencies Since World War II*, RAND RR-396, 2013, Datei `RAND_RR396.pdf`.
5. Walter L. Perry und David Kassing, *Toppling the Taliban: Air-Ground Operations in Afghanistan, October 2001-June 2002*, RAND RR-381, 2015, Datei `RAND_RR381.pdf`.
6. Benjamin S. Lambeth, *Air Power Against Terror: America's Conduct of Operation Enduring Freedom*, RAND MG-166-1, 2005, Datei `RAND_MG166-1.pdf`.
7. Brian F. Neumann, Lisa Mundey und Jon Mikolashek, *Operation Enduring Freedom: The United States Army in Afghanistan, March 2002-April 2005*, U.S. Army Center of Military History, Datei `70-122-1.pdf`.

### 17.2 Webquellen

8. Colin S. Gray, *Irregular Enemies and the Essence of Strategy: Can the American Way of War Adapt?*, U.S. Army War College Strategic Studies Institute, März 2006; online im Naval History and Heritage Command Reading Room: `https://www.history.navy.mil/research/library/online-reading-room/title-list-alphabetically/i/irregular-enemies-essence-strategy.html`.
9. CNN Editorial Research, *Operation Enduring Freedom Fast Facts*: `https://edition.cnn.com/world/operation-enduring-freedom-fast-facts`.
10. Encyclopaedia Britannica, *Taliban*: `https://www.britannica.com/topic/Taliban`.

## 18. Offene Verifikationsaufgaben

1. Relevante Karten aus *Modern War in an Ancient Land* einzeln gegen unsere Location Registry und DCS Afghanistan prüfen.
2. Einheiten- und Basenangaben aus den Operationskarten mit Dokument 55 und Primärquellen abgleichen.
3. Moshtarak- und Hamkari-Phasen in einen maschinenlesbaren Operationsdatensatz überführen.
4. Governance- und ANSF-Felder mit Dokument 04 und Dokument 37 auf Namenskollisionen prüfen.
5. MOOSE-First-Prüfung für die technische Umsetzung von Sector State, Tasking und Scoring durchführen.
6. CNN-Chronologie ausschließlich als Lead verwenden und alle übernommenen Daten gegen offizielle Quellen bestätigen.
7. Britannica nur für allgemeinen Hintergrund nutzen; keine lokalen Runtime-Parameter daraus erzeugen.
8. Keine technische Acceptance beanspruchen, bevor die Felder und Übergänge in einer DCS-Testmission validiert sind.
