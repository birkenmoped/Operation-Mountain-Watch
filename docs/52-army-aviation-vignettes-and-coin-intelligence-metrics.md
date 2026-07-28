---
document_id: OMW-HIST-ARMY-AVIATION-COIN-INTELLIGENCE-METRICS
status: BINDING
document_class: HISTORICAL_RESEARCH_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified Army Aviation and UK Apache/Chinook operational vignettes for Afghanistan 2010-2011
  - source-qualified emergency, escort, casualty evacuation, recovery and threat-intelligence mission-design patterns
  - source handling and scope classification for the sources registered in this document
not_authoritative_for:
  - active campaign air ORBAT
  - exact simultaneous unit strength
  - final Mission Editor placement
  - DCS or MOOSE technical acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# 52 - Army Aviation Vignetten, Chinook Operations und COIN-Intelligence/Metriken

## 1. Zweck und Autoritaetsgrenze

Dieses Dokument konsolidiert die zusaetzlich bereitgestellten Quellen zu:

- AH-64-Notverfahren und Verhalten nach einer Aussenlandung;
- Apache-Einsatz als Escort, Sensorplattform, Funkrelais und Overwatch;
- CH-47-Einsatz fuer Air Assault, Truppentransport, Nachschub, Aussenlast und Casualty Evacuation;
- gemeinsamer Apache-/Chinook-Nachtflug bei Staub und sehr geringer Sicht;
- Bedrohungsbriefing, Intelligence-Weitergabe und Folgen unvollstaendiger Threat Dissemination;
- missionsbezogenen Erfolgskriterien fuer COIN-, MEDEVAC-, CSAR- und Aviation-Support-Auftraege;
- Quellen, die ausserhalb des OMW-Zeitraums liegen oder aufgrund ihrer Verteilungskennzeichnung nicht inhaltlich publiziert werden duerfen.

Es ergaenzt:

- [`OMW-HIST-AFGHANISTAN-FORCE-BASING-AVIATION`](50-afghanistan-force-basing-aviation-2010-2011.md);
- [`OMW-HIST-USMC-RC-SOUTHWEST-COALITION-OPS`](51-usmc-rc-southwest-and-coalition-operations-2010-2011.md);
- [`OMW-AIR-IMPLEMENTATION`](18-air-operations-implementation.md);
- [`OMW-CSAR-INDEX`](csar/README.md).

Die aktive Missions-ORBAT bleibt ausschliesslich:

- [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md).

Historische Einheiten, Einzelfaelle und Nachkriegsquellen erzeugen daher keine zusaetzlichen Spieler-Slots, KI-SQUADRONs, Statics, Warehouse-Bestaende oder basisbezogenen Mission-Editor-Vorgaben.

## 2. Zeit- und Evidenzmodell

### 2.1 Zeitklassen

| Kennzeichnung | Bedeutung |
|---|---|
| `IN_PERIOD` | Ereignis oder Einsatz liegt unmittelbar im OMW-Zeitraum |
| `PRE_PERIOD_CONTINUITY` | kurz vor dem 01.08.2010; nur als Kontinuitaetsbeleg |
| `POST_PERIOD_CONTEXT` | nach dem 31.12.2011; nur Vergleich oder organisatorischer Kontext |
| `BACKGROUND_ONLY` | deutlich ausserhalb des Zeitraums; keine zeitgenoessische ORBAT- oder TTP-Autoritaet |

### 2.2 Evidenzklassen

| Klasse | Verwendung |
|---|---|
| `DIRECT_OFFICIAL` | offizielle Army-, State-DoD- oder UK-MoD-Aussage |
| `OFFICIAL_RETROSPECTIVE` | spaetere offizielle Rueckschau mit klarer zeitlicher Zuordnung |
| `OFFICIAL_HISTORY` | amtshistorische Darstellung ausserhalb des Szenariozeitraums |
| `OFFICIAL_ORIGIN_REPOST` | nichtamtliche Seite gibt einen gekennzeichneten amtlichen Text wieder |
| `SECONDARY_MEMOIR` | persoenlicher Erlebnisbericht; wertvoll fuer Verfahren und Wahrnehmung, nicht fuer theaterweite Bestandszahlen |
| `SECONDARY` | Fach- oder Medienquelle ohne Primaerquellenstatus |
| `SECONDARY_REHOST_OF_PROFESSIONAL_ACCOUNT` | fachlicher Erfahrungsbericht, dessen Originalpublikation im aktuellen Lauf nicht direkt vorlag |
| `ANECDOTAL` | glaubhafte Einzelanekdote, aber ohne ausreichende Primaerbelegkette |
| `LEAD_ONLY` | Recherchehinweis; vor Nutzung als Tatsache weiter zu bestaetigen |
| `RESTRICTED_SOURCE` | Quelle ist mit einer Verteilungs- oder Nutzungsbeschraenkung versehen und wird nicht inhaltlich in das Repository uebertragen |
| `EXCLUDED` | fuer den behaupteten Zweck nicht verwendbar |

## 3. Quellenregister

### AVIM-S01 - U.S. Army: *14 Seconds: Pilot uses experience, quick thinking during aviation accident*

- URL: <https://www.army.mil/article/86735/14_seconds_pilot_uses_experience_quick_thinking_during_aviation_accident>
- Artikel: 05.09.2012; Ereignis: 07.07.2011
- Zeitklasse: `IN_PERIOD`
- Evidenz: `DIRECT_OFFICIAL`
- Belegt:
  - AH-64-Besatzung von C Company, 1st Battalion, 10th Aviation Regiment, Task Force Phoenix;
  - Rueckflug nach Bagram Airfield;
  - Verlust des Heckrotors in etwa 400 ft Hoehe;
  - 14 Sekunden bis zum Aufschlag beziehungsweise zur Notlandung;
  - Auswahl eines freien Feldes, kontrollierte Leistungs- und Lageentscheidung sowie Vermeidung des Ueberschlags;
  - Verlust der Funkverbindung nach der Landung;
  - Aufteilung der Besatzung in Sicherung des Perimeters und Bergen beziehungsweise Sichern sensibler Gegenstaende;
  - Eintreffen eines USAF-Rettungshubschraubers innerhalb von 14 Minuten;
  - Ableitung angepasster Emergency-Briefings durch den Pilot in Command.
- Grenze: Einzelereignis; keine Unfallwahrscheinlichkeit und keine allgemeine Einsatzquote.

### AVIM-S02 - HeliHub / UK Ministry of Defence: *Apache pilot honoured for bravery in Afghanistan*

- URL: <https://www.helihub.com/2011/10/08/apache-pilot-honoured-for-bravery-in-afghanistan/>
- Datum: 08.10.2011; berichtete Ereignisse: Dezember 2010
- Zeitklasse: `IN_PERIOD`
- Evidenz: `OFFICIAL_ORIGIN_REPOST`; die Seite bezeichnet UK MoD als Quelle
- Belegt:
  - Apache als Funkrelais, nachdem eine IED-Explosion die Bodenfunkgeraete bis auf die Aircraft-Frequency unbrauchbar gemacht hatte;
  - Fortsetzung des Relaisauftrags trotz sehr niedrigen Kraftstoffstands bis zum Eintreffen der Rettungs- und Abloeseplattformen;
  - Apache-Sensoren als Navigations- und Terrainhilfe fuer einen Chinook bei Nacht, Staub und praktisch fehlender visueller Referenz;
  - Fuehrung des Chinook bis in unmittelbare Naehe der Landezone;
  - Apache-Einsatz als regelmaessige Absicherung von Casualty-Missions und als Overwatch fuer Bodenpatrouillen.
- Grenze: Repost; fuer woertliche Zitate oder Auszeichnungsdetails ist die originale UK-MoD-Fassung vorzuziehen.

### AVIM-S03 - U.S. Army: *10th Combat Aviation Brigade to deploy in spring*

- URL: <https://www.army.mil/article/95919/10th_combat_aviation_brigade_to_deploy_in_spring>
- Datum: 07.02.2013
- Zeitklasse: gemischt
  - `OFFICIAL_RETROSPECTIVE` fuer die Aussage, dass die Brigade im Oktober 2011 von einer zwoelfmonatigen Afghanistan-Rotation zurueckkehrte;
  - `POST_PERIOD_CONTEXT` fuer die 2013 beschriebene Brigadezusammensetzung und Einsatzvorbereitung.
- Evidenz: `DIRECT_OFFICIAL`
- Belegt:
  - vorherige Afghanistan-Einsaetze 2003, 2006 und 2010;
  - Rueckkehr aus einer zwoelfmonatigen Rotation im Oktober 2011;
  - funktionale CAB-Breite mit Transport, MEDEVAC, Heavy Lift, Close Air Support, Reconnaissance, Maintenance, Air Traffic Control, Recovery, Intelligence, Logistics, Communications und Medical Support.
- Grenze: Die 2013 aufgelisteten Luftfahrzeugtypen und Faehigkeiten duerfen nicht ohne weitere Rotationsquelle als exakte 2010/2011-Stichtagszusammensetzung ausgegeben werden.

### AVIM-S04 - Breaking Defense: *The Monster Is Here*

- URL: <https://breakingdefense.com/2011/10/the-monster-is-here-or-how-the-taliban-gave-apache-a-new-name/>
- Datum: 10.10.2011
- Zeitklasse: `IN_PERIOD`
- Evidenz: `SECONDARY`, Einzelpassage `ANECDOTAL`
- Verwertbar:
  - zeitgenoessische Wahrnehmung des AH-64 als starke psychologische Abschreckung;
  - Sensorik und Stand-off-Wirkung als wesentliche Ursache dieser Wirkung.
- Nicht belastbar genug fuer:
  - feste Taliban-Bezeichnung;
  - quantitative Wirkung;
  - Einheits- oder Standortzuordnung ohne weiteren Primaerbeleg.
- Quellenkette der Anekdote: Boeing-Marketingvertreter berichtet eine Aussage eines Army-Kommandeurs; deshalb keine `DIRECT_OFFICIAL`-Einstufung.

### AVIM-S05 - FOX 13 Utah: 1-211th Aviation Regiment

- URL: <https://www.fox13now.com/news/local-news/ah-64-apache-helicopters-and-300-utah-national-guard-members-to-deploy-to-afghanistan>
- Jahr: 2020
- Zeitklasse: `POST_PERIOD_CONTEXT`
- Evidenz: `SECONDARY`
- Verwertbar nur als spaeter organisatorischer Vergleich:
  - Attack/Reconnaissance Battalion mit AH-64;
  - Rollen Reconnaissance und Attack;
  - National-Guard-Verstaerkung einer aktiven Combat Aviation Brigade.
- Ausgeschlossen fuer OMW:
  - 2020-Personalstaerke;
  - Task Force Ivy Eagle;
  - jede Rueckprojektion auf 2010/2011.

### AVIM-S06 - State of Hawaii Department of Defense: Afghanistan War service history

- URL: <https://dod.hawaii.gov/blog/2001-2021-federal-service-during-the-afghanistan-war/>
- Zeitklasse: `IN_PERIOD` fuer die Rotation Herbst 2010 bis August 2011
- Evidenz: `OFFICIAL_RETROSPECTIVE`
- Belegt:
  - Company B, 1st Battalion, 171st Aviation Regiment, Hawaii Army National Guard;
  - CH-47-Heavy-Lift-Einheit;
  - ungefaehr 120 Aviators und Support Personnel;
  - Verlegung im Herbst 2010 und Rueckkehr im August 2011;
  - Air Assault, Troop Transport, Cargo Resupply und Logistics Support;
  - Bildunterschrift des 2011 Annual Report ordnet CH-47 der Einheit Kandahar Air Base zu.
- Grenze:
  - `approximately 120` ist eine Personal-, keine Luftfahrzeugzahl;
  - die Quelle liefert keine exakte Anzahl gleichzeitig einsatzbereiter CH-47.

### AVIM-S07 - ARSOF History: *Afghan Ambush - ODA 744 in Afghanistan*

- URL: <https://arsof-history.org/articles/v1n2_afghan_ambush_page_1.html>
- Zeitraum: 2002/2003
- Zeitklasse: `BACKGROUND_ONLY`
- Evidenz: `OFFICIAL_HISTORY`
- Verwertbar als fruehe SOF-/CSAR-/QRF-Hintergrundreferenz:
  - FOB 72 auf Kandahar Airfield als C2-Knoten;
  - Firebase Gereshk nahe Highway 1 und einer Nord-Sued-Verbindung;
  - gemeinsames Wirken von Special Forces, Civil Affairs und PSYOP;
  - Retasking vorhandener Luftmittel nach `Team in Contact`;
  - MEDEVAC mit Battalion Surgeon;
  - luft- und bodengebundene QRF sowie Herstellung eines gesicherten Aufnahmepunktes.
- Grenze: keine Stationierungs- oder TTP-Autoritaet fuer 2010/2011.

### AVIM-S08 - Helis.com / US Army Safety Program: AH-64 operations 2002

- URL: <https://www.helis.com/stories/ah64afgh.php>
- Autorenzuordnung: CW3(P) Rich Chenault, A/3rd Battalion, 101st Aviation Regiment
- Zeitraum: Januar bis Juli 2002
- Zeitklasse: `BACKGROUND_ONLY`
- Evidenz: `SECONDARY_REHOST_OF_PROFESSIONAL_ACCOUNT`
- Verwertbar als technischer Hintergrund:
  - High/Hot- und Hochgebirgsleistung;
  - Power-Available-Planung;
  - OGE-Hover-Margin als missionsrelevante Groesse;
  - Training fuer Fuel-Flow-/TGT-/Rotor-RPM-Grenzen;
  - Bedarf einer Performance-Planning-Funktion.
- Grenze: AH-64A, 2002; keine automatische Uebertragung von Triebwerksmix, Bewaffnung oder Performancewerten auf 2010/2011.

### AVIM-S09 - Michael Fry: *The Workhorse of Helmand*

- bereitgestellte Datei: `The Workhorse of Helmand_ A Chinook Crewman's Account of Operations in Afghanistan and Iraq - Michael Fry.epub`
- Verlag: Pen & Sword; 2022
- Evidenz: `SECONDARY_MEMOIR`
- Zeitklasse:
  - Kapitel 15 und 16: `IN_PERIOD`, Camp Bastion, Operation Herrick, ab November 2010;
  - fruehere Afghanistan-Episoden: je nach Datum `BACKGROUND_ONLY` oder `PRE_PERIOD_CONTINUITY`.
- Quellenwert:
  - detaillierte Wahrnehmung einer Chinook-Crew;
  - Crew Coordination, Nacht-/Staubverfahren, Escort, MERT, Illumination, Risikoentscheidungen, Beschuss und Battle Damage;
  - Beispiel fuer eine Intelligence-Dissemination-Luecke innerhalb einer Joint Helicopter Force.
- Grenze:
  - Erinnerungsliteratur, keine offizielle Einsatzchronik;
  - keine theaterweiten Verlust-, Treffer- oder Einsatzraten ohne unabhaengige Bestaetigung;
  - urheberrechtlich geschuetzter Volltext wird nicht in das Repository uebernommen.
- Vollstaendige Quellenakte:
  - [`workhorse-of-helmand-chinook-memoir.md`](evidence/source-records/workhorse-of-helmand-chinook-memoir.md).

### AVIM-S10 - RAND / USJFCOM: *Intelligence Operations and Metrics in Iraq and Afghanistan*

- bereitgestellte Datei: `Intelligence Operations and Metrics in Iraq and Afghanistan - Fourth in a Series of Joint Urban Operations and Counterinsurgency.pdf`
- Autoren: Russell W. Glenn und S. Jamie Gayton
- Datum: November 2008
- sichtbare Kennzeichnung auf Titelblatt und Folgeseiten:
  - `UNCLASSIFIED//FOR OFFICIAL USE ONLY//REL TO USA/AUS/NZL/ISR/NATO`;
  - Distribution Statement C mit beschraenktem Empfaengerkreis.
- Evidenz: `RESTRICTED_SOURCE`
- Zeitklasse: `BACKGROUND_ONLY`
- Verwendungsentscheidung:
  - keine inhaltliche Extraktion in dieses Repository;
  - keine laengeren Zitate, Tabellen, Matrizen oder Ableitungen;
  - keine Nutzung als OMW-Source of Truth, solange Berechtigung und Repository-Verteilungsrahmen nicht geklaert sind.
- Quellenakte:
  - [`rand-intelligence-operations-metrics-2008-restricted.md`](evidence/source-records/rand-intelligence-operations-metrics-2008-restricted.md).

## 4. Historisch belastbare 2010/2011-Erkenntnisse

### 4.1 C Company, 1-10 Aviation Regiment / Task Force Phoenix

Der AH-64-Unfall vom 07.07.2011 belegt eine C-Company-Besatzung von 1st Battalion, 10th Aviation Regiment, Task Force Phoenix auf dem Rueckflug nach Bagram Airfield. Der Beleg ist fuer Einheit, Plattform, Datum und Zielort belastbar. Er ist keine Aussage ueber Gesamtstaerke oder dauerhafte Alleinbasierung der Einheit.

### 4.2 Company B, 1-171 Aviation Regiment

Fuer Herbst 2010 bis August 2011 ist eine Hawaii-Army-National-Guard-CH-47-Komponente mit ungefaehr 120 Aviators und Support Personnel belegt. Der Einsatz umfasste Air Assault, Truppentransport, Cargo Resupply und logistische Unterstuetzung. Eine zeitgenoessische Bildunterschrift verortet Luftfahrzeuge der Einheit auf Kandahar Air Base.

### 4.3 Britischer Apache-/Chinook-Verbund

Fuer Dezember 2010 sind zwei miteinander verknuepfte Rollen belegt:

1. Apache als airborne communications relay fuer eine durch IED verwundete Bodenpatrouille;
2. Apache als Sensor- und Navigationsfuehrer fuer einen Casualty-Evacuation-Chinook bei Nacht, Staub und sehr geringer Sicht.

Diese Faelle stuetzen fuer OMW die Trennung von `ATTACK`, `ESCORT`, `OVERWATCH`, `RELAY` und `SENSOR_GUIDE` als unterschiedliche Aufgabenrollen. Ein Apache muss nicht schiessen, um missionsentscheidend zu sein.

## 5. Chinook-Missionsmuster aus dem Memoir

Die folgenden Punkte werden als `SECONDARY_MEMOIR`, nicht als offizielle TTP, gefuehrt.

### 5.1 Nacht-/Staub-CASEVAC nach Sangin

Aus Kapitel 15 ergibt sich ein Missionsmuster mit:

- Camp Bastion als Ausgangs- und medizinischem Rueckkehrknoten;
- hochbereitem Chinook und Medical Emergency Response Team;
- zunaechst abgebrochenem Pave-Hawk-Versuch aufgrund der Sicht;
- Apache als vorausfliegender FLIR-/IR-Fuehrer;
- Chinook in engem visuellen beziehungsweise NVG-bezogenen Anschluss an das IR-Anticollision-Light des Apache;
- tiefer Flughoehe und fortlaufendem Terrain-/Hindernisrisiko;
- IR-Mortar-Illumination von FOB Jackson;
- Aufnahme eines ersten schwer verwundeten Soldaten;
- zweitem Casualty einer estnischen Patrouille;
- bewusster Ablehnung eines unmittelbar unsicheren zweiten Landeversuchs;
- Rueckkehr nach Bastion, Refuel, Replanning und erneutem Start;
- alternativer Illumination durch FOB Robinson;
- erfolgreicher zweiter Aufnahme auf FOB Jackson.

Der fachlich wichtigste Punkt ist nicht heroische Risikosteigerung, sondern die Abfolge:

```text
ASSESS -> ATTEMPT -> ABORT_UNSAFE -> RECOVER -> REPLAN -> RELAUNCH -> COMPLETE
```

### 5.2 ROE und nicht freigegebene Threat Intelligence

Kapitel 16 beschreibt einen RPG-Schuetzen, der seine Waffe ablegt, nachdem die Chinook-Crew ihn erfasst hat. Die Crew unterlaesst den Beschuss, sobald keine unmittelbare Bedrohung mehr vorliegt. Im Debrief wird bekannt, dass Hinweise auf ein Pakistan-trained anti-air team im Gebiet vorlagen, diese Information jedoch nicht in das Crew-Briefing gelangt war.

Fuer OMW folgt daraus:

- die Mission muss zwischen `INTELLIGENCE_KNOWN` und `INTELLIGENCE_BRIEFED_TO_CREW` unterscheiden koennen;
- ein Threat Record darf nicht automatisch bedeuten, dass jedes Element ihn kennt;
- ROE-Status und beobachtetes Verhalten des Gegners koennen sich innerhalb weniger Sekunden aendern;
- Nichtbeschuss kann ein korrekter Missionserfolg sein.

### 5.3 Beschuss waehrend einer Aussenlastmission

Das Memoir beschreibt einen Nachschubauftrag mit zwei Chinooks und Apache Escort. Nach Beschuss eines Luftfahrzeugs setzt das zweite mit einer ungefaehr vier Tonnen schweren Aussenlast aus Munition, Kraftstoff und Hexamin fort. Unter Small-Arms- und Airburst-RPG-Beschuss wird die Aussenlast abgeworfen, um Manoevrierfaehigkeit zurueckzugewinnen. Beschuss trennt Instrumentenleitungen; die Drehmomentanzeigen fallen auf null, obwohl die Triebwerke weiter Leistung liefern. Die Crew erkennt den Instrumentenausfall durch Cross-Check weiterer Anzeigen und kehrt nach Bastion zurueck.

Fuer OMW sind daraus folgende Zustandswechsel ableitbar:

```text
SLING_ATTACHED
-> THREAT_CONTACT
-> LOAD_JETTISONED
-> SYSTEMS_DEGRADED
-> MAYDAY
-> CONTROLLED_RECOVERY
-> BATTLE_DAMAGE_ASSESSMENT
```

Die konkrete Schadensphysik und ein realistischer Aussenlastabwurf muessen in DCS separat getestet werden. Die Quelle begruendet ein Missionsdesignmuster, keine behauptete Simulationsfaehigkeit.

## 6. AH-64-Rollenmodell fuer OMW

Die Quellen stuetzen mindestens folgende getrennte Rollen:

| Rolle | Zweck | Erfolgsbedingung |
|---|---|---|
| `ATTACK` | unmittelbare Wirkung gegen bestaetigte Ziele | Zielwirkung gemaess ROE und Auftrag |
| `ESCORT` | Schutz von Transport-, CASEVAC- oder Recovery-Luftfahrzeugen | Paket erreicht Ziel und kehrt zurueck beziehungsweise uebergibt sicher |
| `OVERWATCH` | Sensorische und bewaffnete Deckung fuer Boden-/Luftkraefte | Bedrohung erkannt, abgeschreckt oder bei Freigabe bekaempft |
| `AIRBORNE_RELAY` | Funkbruecke zwischen isolierter Bodenkomponente und C2/Rettung | Notruf und Lagebild erreichen die erforderlichen Stellen |
| `SENSOR_GUIDE` | Terrain-, Wetter- und LZ-Fuehrung fuer weniger geeignete Plattform | gefuehrtes Luftfahrzeug erreicht LZ oder sicheren Abbruchpunkt |
| `QRF_SUPPORT` | schnelle Reaktion auf TIC, Downed Aircraft oder isolierte Crew | Zeitfenster fuer Rettung, Sicherung oder Extraktion geschaffen |

Ein reiner Abschusszaehler waere fuer diese Rollen ungeeignet. Mehrere der belegten Apache-Erfolge beruhen auf Relais, Navigation, Abschreckung, Escort oder sicherem Nichtschiessen.

## 7. Notlandung, Downed-Aircraft- und CSAR-Muster

### 7.1 Besatzungsaufgaben nach der Landung

Aus AVIM-S01 werden folgende Anforderungen abgeleitet:

1. Crew-Survival und Verletzungsstatus feststellen;
2. Funk beziehungsweise alternative Signalisierung versuchen;
3. sensible Gegenstaende und Missionsdaten sichern;
4. Perimeter herstellen;
5. Wingman/C2 ueber Position und Status informieren;
6. Rescue-/Recovery-Kraefte einweisen;
7. zwischen Personnel Recovery und spaeterer Aircraft Recovery unterscheiden.

### 7.2 Missionszustand

```text
AIRBORNE
-> EMERGENCY
-> FORCED_LANDING
-> CREW_ALIVE_ISOLATED
-> PERIMETER_ESTABLISHED
-> RESCUE_INBOUND
-> PERSONNEL_RECOVERED
-> AIRCRAFT_RECOVERY_PENDING
```

Die Crew darf nach einer Aussenlandung nicht automatisch als gerettet gelten. Ebenso ist ein gerettetes Personal kein automatisch geborgenes Luftfahrzeug.

## 8. Intelligence- und Briefingmodell

### 8.1 Getrennte Informationszustaende

Fuer relevante Bedrohungen sollen mindestens folgende Felder unterschieden werden:

```yaml
intel_recorded: true|false
intel_confidence: low|medium|high
intel_age_minutes: integer
intel_shared_with_hq: true|false
intel_briefed_to_package: true|false
intel_acknowledged_by_crew: true|false
```

Damit kann die Kampagne folgende unterschiedliche Fehlerbilder abbilden:

- Bedrohung wurde nie entdeckt;
- Bedrohung wurde entdeckt, aber nicht bewertet;
- Bedrohung wurde bewertet, aber nicht geteilt;
- Bedrohung wurde geteilt, aber nicht in das Missionsbriefing uebernommen;
- Crew wurde gebrieft, hat die Information aber nicht bestaetigt.

### 8.2 Threat Briefing

Ein Aviation-Briefing soll fuer jede Route oder LZ mindestens enthalten:

- bekannte Small-Arms-, RPG- und MANPADS-Hinweise;
- Quelle, Alter und Confidence;
- letzte bestaetigte Aktivitaet;
- erwartete Bedrohungsrichtung und Fluchtkorridore;
- Wetter-, Staub- und Illuminationseinfluss;
- Alternate Route und Abort Criteria;
- verfuegbare Escort-, QRF-, MEDEVAC- und Recovery-Mittel.

## 9. Wetter, Illumination und Abort Logic

Die Sangin-Vignette zeigt, dass `mission possible` nicht mit `mission safe enough` gleichzusetzen ist. OMW soll deshalb keine einzige binaere Wetterfreigabe verwenden.

Empfohlene Bewertung:

```yaml
visibility_state: VMC | DEGRADED | SEVERE | NO_GO
illumination_state: NORMAL | LOW | ZERO | IR_ASSISTED
sensor_escort_available: true|false
terrain_clearance_confidence: low|medium|high
alternate_available: true|false
medical_urgency: routine|priority|urgent|immediate
```

Die Entscheidung kann je nach Auftrag zu verschiedenen Ergebnissen fuehren:

- `GO`;
- `GO_WITH_ESCORT`;
- `GO_WITH_IR_ILLUMINATION`;
- `HOLD_FOR_WEATHER`;
- `ABORT_AND_REPLAN`;
- `DIVERT`.

Ein spaeter erfolgreicher Auftrag darf einen vorherigen sicherheitsbedingten Abbruch nicht als Fehler werten.

## 10. Missionsmetriken

Fuer die hier dokumentierten Missionen sind reine Activity- oder Kill-Metriken unzureichend. Empfohlen wird die Trennung:

### 10.1 Measure of Effort

- Sorties gestartet;
- Escort-Minuten;
- Relay-Zeit;
- Anzahl Briefings oder Intel Records;
- Aussenlasten bewegt.

### 10.2 Measure of Performance

- Reaktionszeit vom Tasking bis Takeoff;
- Funkverbindung hergestellt;
- Route beziehungsweise LZ erreicht;
- Casualty innerhalb medizinischem Zeitfenster uebergeben;
- Crew nach Notlandung lokalisiert;
- Threat Briefing vor Takeoff bestaetigt.

### 10.3 Measure of Effectiveness

- Patient ueberlebt beziehungsweise erreicht hoehere Behandlungsebene;
- isolierte Besatzung wird geborgen;
- Transportpaket erfuellt Auftrag trotz sicherem Abort/Replan;
- keine unzulaessige Waffenwirkung;
- bekannte Threat Intelligence erreicht die betroffenen Crews rechtzeitig;
- wiederholte Nutzung einer Route fuehrt nicht zu vorhersehbarer, unbehandelter Gefaehrdung;
- Luftfahrzeug oder Crew bleibt fuer Folgeoperationen verfuegbar.

## 11. Technische Umsetzungsgrenzen

Dieses Dokument beschreibt fachliche Anforderungen, keine bereits nachgewiesene DCS-/MOOSE-Funktionalitaet.

Vor Eigenentwicklung ist gemaess [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md) zu pruefen, ob MOOSE bereits geeignete Klassen oder Ereignismodelle fuer:

- Escort-/Follow-Auftraege;
- CSAR/AICSAR;
- Airborne Mission Tasking;
- Events fuer Treffer, Notlandung, Ausstieg und Recovery;
- Cargo-/Slingload-Zustaende;
- Threat Detection und RECCE;
- Mission Scoring und FSM-Zustandswechsel

bereitstellt.

Gesondert in DCS zu validieren sind:

- kontrollierter missionslogischer Load Jettison;
- Erkennung einer ueberlebten Notlandung versus Crash;
- persistenter Crew-/Aircraft-Recovery-Split;
- Sensor-Guide-Verhalten bei staubbedingter Sichtminderung;
- IR-Illumination als spiel- und KI-wirksame Hilfe;
- glaubwuerdiger Ausfall einzelner Instrumente beziehungsweise dessen missionslogische Abstraktion.

## 12. Offene Forschungsfragen

1. Originalfassung der UK-MoD-Auszeichnungsmeldung auffinden und gegen den HeliHub-Repost pruefen.
2. Exakte Unterstellung und Stationierung von Company B, 1-171 Aviation waehrend der gesamten Rotation 2010/2011 weiter aufloesen.
3. Fuer C Company, 1-10 Aviation Regiment / Task Force Phoenix die Rotationschronologie und Bagram-Basierung mit zusaetzlicher offizieller Quelle ergaenzen.
4. Die 10th-CAB-2010/2011-Zusammensetzung nicht aus dem 2013-Artikel extrapolieren, sondern aus Deployment Orders, Unit Histories oder DVIDS belegen.
5. Fuer die Fry-Vignetten Datum, Callsigns, beteiligte Squadrons und offizielle Incident-/Award-Quellen soweit moeglich querpruefen.
6. Verteilungsberechtigung und Repository-Zugriff fuer AVIM-S10 klaeren; bis dahin bleibt die Quelle gesperrt.

## 13. Verbindliche Kurzregeln

1. Dokument 52 ergaenzt die historische Recherche, aendert aber Dokument 19 nicht.
2. Apache ist nicht nur `ATTACK`; Escort, Relay, Overwatch und Sensor Guide sind eigenstaendige Rollen.
3. Ein sicherer Abort mit spaeterem Replan kann ein korrekter Zwischenerfolg sein.
4. Downed Crew, Personnel Recovery und Aircraft Recovery sind getrennte Zustaende.
5. Threat Intelligence gilt erst dann als missionswirksam, wenn sie der betroffenen Crew rechtzeitig gebrieft wurde.
6. Memoir-Aussagen bleiben `SECONDARY_MEMOIR` und werden nicht zu theaterweiten Zahlen verallgemeinert.
7. AVIM-S10 wird wegen der sichtbaren Distribution-Statement-C-/FOUO-Kennzeichnung nicht inhaltlich in das Repository uebertragen.
8. Keine der Quellen begruendet ohne ausdrueckliche Projektentscheidung neue aktive Bestaende, Slots oder Mission-Editor-Objekte.
