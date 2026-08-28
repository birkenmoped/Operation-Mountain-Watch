---
document_id: OMW-HIST-RUSSIA-OEF-ISAF-AFGHANISTAN
status: BINDING
document_class: SOURCE_CRITICAL_HISTORICAL_CONTEXT_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical Russian role in Afghanistan during OEF and ISAF
  - scenario-period limits on Russian support to insurgent forces
  - Russian transit, helicopter-maintenance and counter-narcotics cooperation
  - separation of 2010-2011 evidence from post-2014 Taliban contacts and allegations
not_authoritative_for:
  - active OMW ORBAT
  - runtime faction architecture
  - Russian force, weapon, inventory or Mission Editor object creation
  - claims of direct Russian arms delivery without case-specific provenance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/document-russia-afghanistan-role
source_commit: 0d2518f13f787c79d43c3a15ef3062f33b9fa941
validated_in_dcs: false
---

# 82 – Russland, OEF und ISAF in Afghanistan

## 1. Kernaussage für Operation Mountain Watch

Für den verbindlichen OMW-Zeitraum vom 1. August 2010 bis 31. Dezember 2011 ist Russland **nicht** als belegter verdeckter Sponsor der Taliban zu modellieren. Die belastbare Quellenlage zeigt in dieser Phase vor allem begrenzte, interessengeleitete Kooperation mit den USA und der NATO:

- Transit und logistische Entlastung über die nördlichen Versorgungswege;
- Kooperation beim Aufbau der afghanischen Hubschrauber-Wartung;
- gemeinsame Ausbildung zur Drogenbekämpfung;
- gleichzeitiges russisches Misstrauen gegenüber einer dauerhaften US-/NATO-Präsenz in Zentralasien.

Eine russische „Retourkutsche“ nach dem Muster der amerikanischen Unterstützung der afghanischen Mudschaheddin in den 1980er-Jahren ist für 2010/2011 nicht belegt. Spätere russische Kontakte zu den Taliban und westliche Vorwürfe materieller Unterstützung dürfen nicht rückwirkend in den Szenariozeitraum projiziert werden. [S01–S05]

Verbindliche Designgrenze:

```text
RUSSIAN_STATE_SUPPORT_TO_TALIBAN_2010_2011 = NOT_ESTABLISHED
RUSSIA_AS_OMW_RED_SPONSOR = PROHIBITED_WITHOUT_NEW_CASE_SPECIFIC_EVIDENCE
POST_2014_RUSSIA_TALIBAN_CONTACTS != SCENARIO_PERIOD_BASELINE
SOVIET_OR_RUSSIAN_WEAPON_PATTERN != SUPPLY_PROVENANCE
```

## 2. Ausgangslage nach dem 11. September 2001

Russland sah Taliban, al-Qaida und grenzüberschreitende jihadistische Netzwerke zunächst als eigene Sicherheitsbedrohung. Vor 2001 hatte Moskau zusammen mit regionalen Partnern die gegen die Taliban kämpfende Nordallianz unterstützt. Nach den Anschlägen vom 11. September bot Präsident Wladimir Putin politische Unterstützung, Nachrichtenaustausch und die Öffnung russischen Luftraums für humanitäre Lieferungen an; Russland ermutigte außerdem zentralasiatische Staaten zur Unterstützung der amerikanischen Operation. Eigene russische Kampftruppen für OEF wurden ausgeschlossen. [S01, S02]

Diese Kooperation war interessengeleitet. Sie beruhte auf einer zeitweiligen Schnittmenge:

- Bekämpfung von al-Qaida und Taliban;
- Eindämmung islamistischer Gewalt in Zentralasien und im Nordkaukasus;
- Stabilisierung Afghanistans;
- Begrenzung des afghanischen Drogentransits nach Russland;
- Verbesserung der Beziehungen zu den USA nach 2001.

Sie machte Russland weder zu einem ISAF-Truppensteller noch zu einem dauerhaften strategischen Verbündeten der NATO. [S01, S02]

## 3. Praktische Kooperation im Szenariozeitraum

### 3.1 Northern Distribution Network und Transit

Das Northern Distribution Network (NDN) ergänzte ab 2009 die gefährdeten pakistanischen Versorgungswege. Ein erheblicher Teil der nördlichen Route führte über russisches und zentralasiatisches Gebiet. GAO dokumentiert die wachsende Nutzung alternativer Luft-, See- und Landwege sowie die operative Bedeutung des NDN für Afghanistan. Die USA und Russland schlossen 2011 zusätzlich ein Abkommen über Lufttransit von Personal und Ausrüstung im Zusammenhang mit Afghanistan. [S03, S04]

Für OMW folgt daraus:

```text
RUSSIA_2010_2011 = LIMITED_LOGISTICS_AND_TRANSIT_PARTNER
TRANSIT_COOPERATION != NATO_MEMBERSHIP
TRANSIT_DEPENDENCY != RUSSIAN_OPERATIONAL_COMMAND
```

Russische Genehmigungen verliehen Moskau politischen Einfluss, begründen aber keine russische operative Rolle innerhalb von ISAF und keine russischen Kampfkräfte in Afghanistan.

### 3.2 Afghanische Mi-17-/Mi-35-Flotte

Der NATO-Russia Council startete 2011 einen Helicopter Maintenance Trust Fund, um Wartungs- und Instandsetzungsfähigkeiten für die afghanische Hubschrauberflotte aufzubauen. NATO dokumentiert Ausbildung afghanischer Techniker, Ersatzteile und technische Unterstützung für Mi-17 und Mi-35; der 2012 begonnene Lehrgang setzte das 2011 gestartete Projekt praktisch um. [S05, S06]

Dies ist für die historische Einordnung relevant, aber keine OMW-Inventarfreigabe:

```text
RUSSIAN_ORIGIN_AIRFRAME != RUSSIAN_COMBAT_PRESENCE
MAINTENANCE_SUPPORT != RUSSIAN_SQUADRON
SOURCE_CONTEXT != ACTIVE_OMW_ORBAT
```

Aktive Luftfahrzeugbestände und Einheiten bleiben ausschließlich Dokument 19 und den basisbezogenen Manifesten vorbehalten.

### 3.3 Drogenbekämpfung

Das NATO-Russia-Council-Projekt zur Ausbildung afghanischer, zentralasiatischer und pakistanischer Drogenbekämpfungsbehörden bestand bereits im Szenariozeitraum. NATO-Unterlagen dokumentieren Lehrgänge, mobile Ausbildungsteams und russische Beteiligung. Das gemeinsame Interesse war nachvollziehbar, weil afghanische Opiate über Zentralasien nach Russland gelangten. [S07, S08]

Die Kooperation blieb konfliktbehaftet. Unterschiedliche Vorstellungen über Mohnfeldvernichtung, lokale wirtschaftliche Folgen und die Wirksamkeit westlicher Drogenpolitik bestanden fort. Diese Spannungen ändern nichts an der belegten praktischen Zusammenarbeit.

## 4. Kooperation und Konkurrenz gleichzeitig

Russische Politik war doppelt, aber im Szenariozeitraum nicht im Sinn einer belegten bewaffneten Stellvertreterkampagne:

| Dimension | Belegbare Einordnung 2010/2011 |
|---|---|
| Terrorismus | gemeinsames Interesse gegen al-Qaida und grenzüberschreitende jihadistische Netzwerke |
| ISAF-Logistik | Transit- und NDN-Kooperation |
| Afghanische Luftstreitkräfte | Wartungs-, Ersatzteil- und Ausbildungshilfe für sowjetisch/russisch konstruierte Hubschrauber |
| Drogenbekämpfung | gemeinsame Ausbildung, aber politische Differenzen |
| Zentralasien | russisches Interesse, den eigenen Einfluss zu erhalten und dauerhafte US-Basen zu begrenzen |
| Russische Kampftruppen | keine russische Beteiligung an OEF/ISAF als Kampftruppensteller |
| Taliban-Unterstützung | für 2010/2011 keine belastbare staatliche russische Waffen- oder Finanzierungsbaseline |

Russland konnte den westlichen Einsatz somit unterstützen, weil er unmittelbare russische Sicherheitsinteressen bediente, und zugleich eine dauerhafte westliche Machtprojektion in Zentralasien ablehnen. Das ist kein Widerspruch, sondern eine begrenzte Zweckkooperation.

## 5. Spätere Annäherung an die Taliban

Ungefähr ab 2014/2015 veränderten sich die Rahmenbedingungen:

- Zusammenbruch wesentlicher NATO-Russland-Kooperation nach der Annexion der Krim;
- Aufstieg von ISIS-K;
- erwarteter westlicher Truppenabzug;
- russische Zweifel an der Tragfähigkeit der afghanischen Regierung;
- russisches Interesse an einer eigenen regionalen Vermittlerrolle.

Russland baute nachweislich politische Kontakte zu Taliban-Vertretern aus und behandelte die Taliban zunehmend als unvermeidlichen Gesprächspartner. Die russische Begründung stellte ISIS-K als transnationale und damit unmittelbarere Bedrohung dar. Diese Kontakte und spätere Moskauer Gesprächsformate sind belegt; sie sind jedoch **Nachperioden-Kontext**, keine OMW-Baseline. [S09, S10]

## 6. Vorwürfe russischer Waffen- und Materialhilfe

US- und afghanische Stellen erhoben ab 2016/2017 Vorwürfe, Russland unterstütze die Taliban materiell und möglicherweise mit Waffen. In einer Anhörung des U.S. Senate Armed Services Committee vom 9. Februar 2017 erklärte General John Nicholson, Russland habe Taliban öffentlich legitimiert; weitere öffentliche Aussagen amerikanischer Militärvertreter gingen später über politische Kontakte hinaus. [S11]

Für die Quellenbewertung sind vier Ebenen strikt zu trennen:

1. **Belegt:** politische und diplomatische Kontakte Russlands zu den Taliban.
2. **Offiziell behauptet:** mögliche Geld-, Material- oder Waffenhilfe.
3. **Öffentlich nicht eindeutig attribuiert:** konkrete aufgefundene sowjetische/russische Waffen.
4. **Nicht belegt:** ein systematisches russisches Programm im Umfang oder nach dem Muster von Operation Cyclone.

In Afghanistan weit verbreitete AK-, PKM-, RPG- oder sowjetische Munitionsmuster beweisen allein weder Lieferdatum noch Lieferweg noch staatliche russische Urheberschaft. Altbestände, regionale Arsenale, Drittstaaten, Zwischenhändler und Schwarzmarkt sind konkurrierende Herkunftsmöglichkeiten.

Verbindliche Evidenzregel:

```text
WEAPON_DESIGN_OR_MARKING != STATE_SUPPLY_CHAIN
ALLEGATION != VERIFIED_DELIVERY
POST_PERIOD_ALLEGATION != 2010_2011_SCENARIO_FACT
```

## 7. Angebliche russische Kopfgelder

2020 berichteten Medien über die nachrichtendienstliche Hypothese, eine Einheit des russischen Militärnachrichtendienstes habe Taliban-nahen Akteuren Prämien für Angriffe auf Koalitionskräfte angeboten. Eine offizielle US-Regierungsunterrichtung vom 15. April 2021 beschrieb die Einschätzung nur mit **low to moderate confidence** und verwies auf Gefangenenberichte sowie das schwierige Informationsumfeld in Afghanistan. [S12]

Für OMW gilt daher:

- nicht als erwiesene Tatsache darstellen;
- nicht auf 2010/2011 zurückprojizieren;
- nicht als Begründung für russische RED-Ressourcen, Waffenlieferungen oder Missionsobjekte verwenden;
- allenfalls als quellenkritischen Nachperioden-Kontext erwähnen.

## 8. Missionsdesign-Folgen

### 8.1 Zulässig

- sowjetische oder russische Waffenmuster aus historischen Altbeständen;
- nicht näher attribuierter regionaler Schmuggel;
- abstrakter krimineller oder externer Nachschub, sofern keine staatliche Herkunft behauptet wird;
- Briefing-Kontext zu NDN, Transit, afghanischer Mi-17-Wartung und russischer Zentralasienpolitik;
- politische Ambivalenz und Misstrauen gegenüber langfristiger US-Präsenz.

### 8.2 Ohne neue Evidenz unzulässig

- russische Berater, Geheimdienstoffiziere oder Waffenlieferanten als physische RED-Objekte im Szenariozeitraum;
- russische staatliche Finanzierung des OMW-`INSURGENT_NETWORK`;
- russische Waffenlieferungen als Erklärung allein aufgrund des Waffenmusters;
- GRU-Kopfgelder als bestätigter Kampagnenmechanismus;
- eine eigene russische Runtime-Fraktion oder ein russischer RED Commander;
- nach 2014 belegte oder behauptete Entwicklungen als Ursache für Ereignisse 2010/2011.

### 8.3 Verhältnis zu Dokument 56

Dokument 56 führt `EXTERNAL_SUPPORT` als abstrakte mögliche Finanzierungs- und Kapazitätsquelle. Dieses Feld erhält durch das vorliegende Dokument **keine russische staatliche Attribution**. Eine solche Attribution erfordert eine neue, fallbezogene Quelle, ausdrückliche Projektentscheidung und Aktualisierung beider Dokumente.

## 9. Zeitleiste und Evidenzstatus

| Zeitraum | Quellenkritische Einordnung |
|---|---|
| vor 2001 | Russland unterstützt Gegner der Taliban und betrachtet Taliban/al-Qaida als Sicherheitsbedrohung |
| 2001–2008 | politische und nachrichtendienstliche Unterstützung gegen Taliban/al-Qaida; keine russischen OEF-Kampftruppen |
| 2009–2013 | NDN-/Transitkooperation, Hubschrauber-Wartungsprojekt und gemeinsame Drogenbekämpfung |
| 2010–2011 | für OMW: begrenzter Kooperationspartner, kein belegter staatlicher Taliban-Sponsor |
| ab 2014/2015 | deutlichere russische Kontakte zu den Taliban; Nachperioden-Kontext |
| ab 2016/2017 | westliche Vorwürfe begrenzter materieller Unterstützung; öffentliche Attribution und Umfang umstritten |
| 2020/2021 | Kopfgeld-Hypothese; offizielle US-Einstufung nur „low to moderate confidence“ |

## 10. Quellen

### Primär- und Regierungsquellen

- **S01 – U.S. Army Center of Military History:** *Operation Enduring Freedom, September 2001–March 2002*. Belegt russische politische Unterstützung, Nachrichtenaustausch, Luftraumöffnung, Einfluss in Zentralasien und den Ausschluss eigener Kampftruppen.  
  <https://history.army.mil/Portals/143/Images/Publications/Publication%20By%20Title%20Images/O%20titles%20PDF/operation-enduring-freedom-3.pdf>

- **S02 – U.S. Department of State, 2 November 2001:** *U.S.-Russia Working Group on Afghanistan Joint Press Statement*. Zeitnahe offizielle Dokumentation der gemeinsamen Interessen und Afghanistan-Konsultationen.  
  <https://2001-2009.state.gov/r/pa/prs/ps/2001/5867.htm>

- **S03 – U.S. Government Accountability Office, GAO-12-138, 2011:** *Warfighter Support: DOD Has Made Progress, but Supply and Distribution Challenges Remain in Afghanistan*. Belegt alternative Versorgungswege und die operative Rolle des Northern Distribution Network.  
  <https://www.gao.gov/products/gao-12-138>

- **S04 – U.S. Department of State, TIAS 11-419, 2011:** *Agreement Between the United States of America and the Russian Federation Concerning Air Transit of Personnel and Equipment for Afghanistan*. Primärquelle zum russischen Lufttransit.  
  <https://2009-2017.state.gov/documents/organization/191780.pdf>

- **S05 – NATO, 26 April 2012:** *Afghan helicopter-maintenance staff start training under NATO-Russia project*. Dokumentiert den 2011 gestarteten Trust Fund, Zweck, Teilnehmer, Ausbildung und afghanische Mi-17-/Mi-35-Flotte.  
  <https://www.nato.int/en/news-and-events/articles/news/2012/04/26/afghan-helicopter-maintenance-staff-start-training-under-nato-russia-project>

- **S06 – NATO, 25 April 2013:** *NATO-Russia Council expands Helicopter Maintenance Trust Fund Project for Afghanistan*. Spätere Bestätigung und Erweiterung des Projekts; nur für Projektkontinuität, nicht als 2011-Inventarnachweis.  
  <https://www.nato.int/en/news-and-events/articles/news/2013/04/25/nato-russia-council-expands-helicopter-maintenance-trust-fund-project-for-afghanistan>

- **S07 – NATO Archives, 2011:** *NATO-Russia Council Project on Counter-Narcotics Training of Afghan, Central Asian and Pakistani Personnel*. Zeitnahe Projektübersicht.  
  <https://archives.nato.int/uploads/r/nato-archives-online/b/4/3/b4306384eaa133c9564d8212e068d8babfba54f9d37c357f1b26a8eb8a420535/1444_Info-NRC-on-counter-narcotics__2011_ENG_HR.pdf>

- **S08 – NATO, 19 April 2012:** *NATO-Russia counter-narcotics training reaches milestone*. Belegt Reichweite und Fortführung des im Szenariozeitraum aktiven Ausbildungsprojekts.  
  <https://www.nato.int/en/news-and-events/articles/news/2012/04/19/nato-russia-counter-narcotics-training-reaches-milestone>

- **S11 – U.S. Senate Armed Services Committee, 9 February 2017:** *Situation in Afghanistan*, Stenographic Transcript. Primärquelle für General Nicholsons öffentliche Einordnung russischer Taliban-Legitimierung; Nachperiodenquelle.  
  <https://www.armed-services.senate.gov/imo/media/doc/17-08_02-09-17.pdf>

- **S12 – The White House, archived, 15 April 2021:** *Background Press Call by Senior Administration Officials on Russia*. Offizielle Einordnung der Kopfgeldinformationen mit „low to moderate confidence“ und Begründung der Unsicherheit.  
  <https://bidenwhitehouse.archives.gov/briefing-room/press-briefings/2021/04/15/background-press-call-by-senior-administration-officials-on-russia/>

### Fach- und Kontextquellen

- **S09 – NATO Defense College:** *Regional Powers and Post-NATO Afghanistan*. Fachanalyse regionaler Interessen und konkurrierender Einflussstrategien; Kontextquelle, keine Beweisquelle für einzelne Waffenlieferungen.  
  <https://www.ndc.nato.int/regional-powers-and-post-nato-afghanistan/>

- **S10 – RAND, 2017:** *While Americans Fight the Taliban, Putin Is Making Headway in Afghanistan*. Analyse der späteren russischen Annäherung und Einflussstrategie; als Autorenanalyse gekennzeichnet.  
  <https://www.rand.org/pubs/commentary/2017/07/while-americans-fight-the-taliban-putin-is-making-headway.html>

## 11. Quellenkritische Schlussregel

```text
SCENARIO_PERIOD_EVIDENCE_OVERRIDES_LATER_ANALOGY
COOPERATION_AND_COMPETITION_CAN_COEXIST
CONTACT_WITH_TALIBAN != PROVEN_ARMING_OF_TALIBAN
RUSSIAN_OR_SOVIET_MATERIEL != RUSSIAN_STATE_DELIVERY
```

Die historisch sauberste OMW-Darstellung ist daher: Russland war 2010/2011 ein begrenzter, misstrauischer und interessengeleiteter Kooperationspartner der westlichen Afghanistan-Mission. Die später sichtbare Annäherung an die Taliban war eine nachperiodische geopolitische Anpassung, keine belastbar nachgewiesene „Retourkutsche“ innerhalb des OMW-Zeitraums.
