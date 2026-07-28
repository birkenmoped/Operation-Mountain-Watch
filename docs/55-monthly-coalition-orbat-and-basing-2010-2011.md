---
document_id: OMW-HIST-MONTHLY-COALITION-ORBAT-BASING
status: BINDING
document_class: HISTORICAL_RESEARCH_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - source-critical use of Wesley Morgan's Afghanistan Order of Battle monthly snapshots
  - historical coalition command, unit, base and area-of-responsibility research for 2010-08-01 through 2011-12-31
  - temporal qualification of unit rotations and basing claims derived from the source
not_authoritative_for:
  - active OMW ORBAT
  - exact personnel strength unless independently stated and corroborated
  - logistics, medical, intelligence, PRT or black special-operations laydown omitted by the source
  - DCS or MOOSE runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: docs/afghanistan-force-aviation-source-consolidation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Monatliche Koalitions-ORBAT und Basierung 2010-2011

## 1. Zweck und Autoritätsgrenze

Dieses Dokument erschließt Wesley Morgans **Afghanistan Order of Battle 2009-2012** als monatlich fortgeschriebene historische Sekundärreferenz. Die Quelle ist für Operation Mountain Watch außergewöhnlich wertvoll, weil sie Koalitionsverbände, übergeordnete Task Forces, Stützpunkte und räumliche Zuständigkeiten häufig bis auf Bataillonsebene zusammenführt.

Sie ersetzt jedoch weder eine amtliche Stichtags-ORBAT noch die aktive OMW-Entscheidung in [`OMW-AIR-ACTIVE-ORBAT`](19-active-air-orbat-decisions.md). Historische Nennungen erzeugen insbesondere keine zusätzlichen Spieler-Slots, KI-SQUADRONs, WAREHOUSE-Bestände oder statischen Missionseditor-Objekte.

## 2. Quellenprofil

### 2.1 Hauptquelle

- Wesley Morgan, *Afghanistan Order of Battle 2009-2012*, Institute for the Study of War, Dezember 2012;
- bereitgestellte Datei: `Morgan-AfghanistanOrderBattle-2012.pdf`;
- Umfang: 387 PDF-Seiten mit wiederholten Monatsständen, Änderungslisten und Endnoten;
- Charakter: institutionelle, offen recherchierte Sekundärkompilation mit zahlreichen Verweisen auf ISAF, DVIDS, Ministerien, Einheitsseiten und Presseberichte.

### 2.2 Stärken

Die Quelle verbindet vier für OMW besonders wichtige Ebenen:

1. **Führung:** ISAF/USFOR-A, IJC, Regional Commands, NTM-A/CSTC-A, SOF- und Fachkommandos;
2. **Verbände:** Brigade-, Regiments-, Bataillons- und Task-Force-Zuordnung;
3. **Basierung:** Airfields, Camps, FOBs und COPs;
4. **Auftrag/AOR:** Provinzen, Distrikte oder Unterstützungsrollen.

Damit lässt sich nicht nur feststellen, *dass* eine Einheit in Afghanistan war, sondern häufig auch, *wann*, *unter welchem Kommando*, *von welchem Stützpunkt* und *für welchen Raum* sie eingesetzt wurde.

### 2.3 Grenzen

Die einzelnen Monatsstände besitzen nicht immer denselben Scope. Frühe Fassungen konzentrieren sich vor allem auf Bodenkampfverbände. Spätere Fassungen nehmen zusätzlich Aviation, Engineer, EOD, Military Police und offen benennbare Special Operations Forces auf.

Die Quelle erklärt ausdrücklich, dass sie je nach Fassung insbesondere folgende Elemente nicht oder nur unvollständig erfasst:

- geheime beziehungsweise „black“ Special Operations Forces;
- Logistik-, Transport-, Sanitäts- und Intelligence-Verbände;
- Provincial Reconstruction Teams;
- einzelne Unterstützungs- und Stabselemente;
- Personalstärken der aufgeführten Verbände.

Ein fehlender Eintrag bedeutet daher nicht automatisch, dass eine Fähigkeit oder Einheit nicht vorhanden war. Umgekehrt ist eine nominelle Bataillonsbezeichnung kein Beleg dafür, dass das Bataillon mit voller Sollstärke, vollständig an einem Ort oder ohne abgesetzte Kompanien eingesetzt war.

## 3. Zeitliche Erschließung

Die für den OMW-Zeitraum relevanten Monatsstände beginnen in der PDF ungefähr an folgenden Seiten. Die Angaben dienen als Navigationshilfe; bei einer endgültigen Datenextraktion ist zusätzlich der auf der jeweiligen Titelseite gedruckte Monat zu prüfen.

| Monat | ungefährer PDF-Beginn |
|---|---:|
| August 2010 | 294 |
| September 2010 | 287 |
| Oktober 2010 | 281 |
| November 2010 | 274 |
| Dezember 2010 | 268 |
| Januar 2011 | 262 |
| Februar 2011 | 255 |
| März 2011 | 248 |
| April 2011 | 241 |
| Mai 2011 | 234 |
| Juni 2011 | 222 |
| Juli 2011 | 209 |
| August 2011 | 197 |
| September 2011 | 185 |
| Oktober 2011 | 172 |
| November 2011 | 159 |
| Dezember 2011 | 147 |

Für jede aus Morgan übernommene Aussage müssen mindestens folgende Felder gespeichert werden:

```yaml
source: Morgan-AfghanistanOrderBattle-2012
snapshot_month: YYYY-MM
unit_name: string
parent_formation: string|null
location: string|null
area_of_operations: string|null
role: string|null
source_scope: ground_only|expanded_orbat
confidence: HIGH|MEDIUM|LOW
corroboration: []
notes: string|null
```

## 4. August 2010 als OMW-Ausgangsbild

Der Monatsstand August 2010 liegt genau am Beginn des OMW-Szenariozeitraums und ist deshalb die wichtigste Einstiegsebene. Die nachfolgende Darstellung ist eine historische Forschungsbaseline, keine vollständige aktive Missionseinrichtung.

### 4.1 Theater- und Spezialkräfteführung

- ISAF/USFOR-A unter General David Petraeus mit Hauptquartier in Kabul;
- Combined Forces Special Operations Component Command-Afghanistan in Kabul;
- Combined Joint Special Operations Task Force-Afghanistan in Bagram;
- regional ausgerichtete amerikanische SOF-Task-Forces für Ost, Süd sowie West/Nord;
- australische Special Operations Task Group / Task Force 66 in Camp Holland, Tarin Kowt;
- NTM-A/CSTC-A in Camp Phoenix, Kabul;
- ISAF Joint Command am Kabul International Airport.

Diese Einträge belegen Führungsknoten und offene Zuständigkeiten, nicht die vollständige SOF-Struktur oder deren tatsächliche Einsatzorte.

### 4.2 Regional Command West

- RC-West unter der italienischen „Taurinense“ Alpine Brigade in Camp Arena, Herat;
- 2nd Alpine Regiment in Bala Murghab mit Verantwortung in Badghis;
- 3rd Alpine Regiment in Camp La Marmora, Shindand, mit Einsatzraum südliches Herat;
- 9th Alpine Regiment in Camp El-Alamein, Farah;
- 7-10 Cavalry in Camp Stone, Herat, mit Aufgaben in Herat und Badghis.

**OMW-Relevanz:** Shindand ist nicht nur Flugplatz, sondern ein regionaler Bodentruppen- und Führungsstandort. Eine ausschließlich aviation-zentrierte Darstellung wäre unvollständig.

### 4.3 Regional Command East

RC-East wurde durch die 101st Airborne Division von Bagram geführt.

#### N2KL / Jalalabad

Task Force Bastogne / 1st Brigade Combat Team, 101st Airborne Division war in Jalalabad Airfield stationiert und für Kunar, Laghman, Nangarhar und Nuristan verantwortlich.

Unterstellte beziehungsweise zugeordnete Verbände:

- 1-32 Cavalry, FOB Bostick/Naray, nördliches Kunar und Nuristan;
- 1-102 Infantry, FOB Mehtar Lam, Laghman;
- 1-327 Infantry, FOB Blessing/Pech, westliches Kunar;
- 2-327 Infantry, FOB Joyce/Chawkay, östliches Kunar.

#### Logar/Wardak

Task Force Bayonet / 173rd Airborne Brigade Combat Team führte von FOB Shank:

- 1-91 Airborne Cavalry in Logar;
- 1-503 Airborne Infantry von FOB Airborne in Wardak;
- 2-503 Airborne Infantry in Wardak.

#### Kapisa/Surobi

Task Force La Fayette / 3rd Mechanized Brigade führte von FOB Nijrab französische Kräfte in Kapisa und Surobi.

#### Loya Paktia/Paktika

Task Force Rakkasan / 3rd Brigade Combat Team, 101st Airborne Division führte von FOB Salerno Kräfte in Khost, Paktya und Paktika:

- 1-33 Cavalry, Camp Clark, Khost;
- 3-172 Mountain Infantry, FOB Lightning, Paktya;
- 1-187 Infantry, FOB Orgun, östliches Paktika;
- 3-187 Infantry, FOB Sharana, westliches Paktika.

#### Ghazni und nördlicher Zentralraum

- Task Force White Eagle / polnische 1st Armored Brigade von FOB Ghazni;
- Battle Group Alpha in östlichem Ghazni;
- Battle Group Bravo von FOB Warrior in westlichem Ghazni;
- Task Force Wolverine / 86th Brigade Combat Team von Bagram für Bamyan, Panjshir und Parwan.

### 4.4 Regional Command North

- RC-North unter deutscher Führung in Camp Marmal, Mazar-e-Sharif;
- Training and Protection Battalion 1 in FOB Kunduz;
- Training and Protection Battalion 2 in Camp Marmal;
- Task Force Warrior / 1st Brigade Combat Team, 10th Mountain Division in Camp Mike Spann;
- 1-87 Infantry in FOB Kunduz mit Aufgaben in Kunduz und Baghlan.

### 4.5 Regional Command South

#### Uruzgan/Tarin Kowt

Combined Team Uruzgan wurde von Camp Holland, Tarin Kowt, geführt:

- 1/2 Stryker Cavalry in Uruzgan;
- 6 Royal Australian Regiment mit Mentoring- und Reconstruction-Auftrag;
- australische Spezialkräfte waren ebenfalls in Camp Holland verortet.

**OMW-Relevanz:** Tarin Kowt ist gleichzeitig Regional-/Combined-Team-Knoten, australisch-amerikanischer Partnerschaftsstandort, SOF-Ausgangspunkt und später auch Aviation-Knoten. Die Basis darf deshalb nicht wie ein reines Flugfeld modelliert werden.

#### Zabul und Highway 1

- Combined Team Zabul / 2nd Stryker Cavalry Regiment von FOB Lagman, Qalat;
- 2/2 Stryker Cavalry in Zabul;
- rumänisch-amerikanische und rumänische Bataillonselemente entlang Highway 1;
- weitere Kräfte an FOB Spin Boldak und im Grenzraum.

#### Kandahar

- Task Force Fury / 4th BCT, 82nd Airborne Division für Kandahar City;
- Task Force Kandahar unter kanadischer Führung für Daman, Dand und Panjwayi;
- Task Force Strike / 2nd BCT, 101st Airborne Division von FOB Wilson für Zhari, Arghandab und Maywand;
- zugeordnete Einheiten unter anderem an FOB Ramrod, FOB Wilson und FOB Howz-e-Madad.

### 4.6 Regional Command Southwest

RC-Southwest wurde durch I Marine Expeditionary Force (Forward) von Camp Leatherneck geführt. Die detaillierte USMC-Auswertung bleibt in Dokument 51. Morgan bestätigt jedoch die Einordnung des südwestlichen Operationsraums als eigenständige regionale Führungs- und Kräftearchitektur.

## 5. Veränderungen während 2011

Die Monatsstände machen sichtbar, dass statische „eine Einheit pro Basis“-Listen historisch irreführend wären. 2011 treten unter anderem folgende Rotations- und Strukturmuster auf:

- Brigade- und Bataillons-Task-Forces werden abgelöst, während AOR und Basen teilweise bestehen bleiben;
- RC-Hauptquartiere wechseln ihre truppenstellenden Divisionen;
- Aviation-Brigaden rotieren, wobei unterstellte Task Forces ihre Basen und Unterstützungsräume neu zugeordnet bekommen;
- Engineer-, EOD-, MP- und Training-Kommandos werden in späteren Monatsständen wesentlich detaillierter erfasst;
- der Übergang zu Training, Advising und Transition wird organisatorisch sichtbarer.

Der Dezember-2011-Stand zeigt beispielsweise:

- RC-East unter 1st Cavalry Division in Bagram;
- Task Force Bronco / 3rd BCT, 25th Infantry Division in Jalalabad Airfield für Kunar, Laghman, Nangarhar und Nuristan;
- Task Force Saber / 1-17 Air Cavalry ebenfalls in Jalalabad mit Aviation-Support für Kunar, Nangarhar und Nuristan;
- Task Force Poseidon / 82nd Combat Aviation Brigade in Bagram;
- Task Force ODIN-A III in Bagram für theaterbezogene Aufklärung im Osten;
- regionale EOD- und Engineer-Kommandos mit Task Forces an Bagram, Kandahar, Camp Leatherneck, Camp Stone, FOB Shank und FOB Sharana.

Diese Struktur unterstützt ein zeitabhängiges OMW-Datenmodell:

```text
LOCATION bleibt bestehen
FORMATION rotiert
SUBORDINATE_UNIT rotiert oder wird verlegt
AOR kann bestehen, verkleinert oder neu zugeschnitten werden
CAPABILITY kann trotz Namenswechsel fortbestehen
```

## 6. Basenbezogene Folgerungen

### 6.1 Jalalabad Airfield / FOB Fenty

Morgan bestätigt Jalalabad wiederholt als:

- Brigade-/Task-Force-Hauptquartier für N2KL;
- Standort von Brigadeartillerie und weiteren Bodenelementen in späteren Ständen;
- Standort einer Air-Cavalry-Task-Force;
- Ausgangspunkt für Aviation-Support nach Kunar, Nangarhar und Nuristan.

Für den Missionseditor folgt daraus ein mehrschichtiges Standortmodell mit mindestens:

1. Airfield-Betrieb;
2. Brigade-/Task-Force-C2;
3. Aviation-Unterstützung;
4. Bodentruppen-/QRF-/Sicherungsanteilen;
5. Logistik- und Wartungsflächen, deren konkrete Einheiten Morgan jedoch nicht vollständig benennt.

### 6.2 Tarin Kowt / Camp Holland

Camp Holland/Tarin Kowt wird als Combined-Team- und späterer Aviation-Standort sichtbar. Im Verlauf der Gesamtreihe erscheinen dort unterschiedliche niederländische, australische und amerikanische Führungs- und Manöverelemente sowie Aviation-Task-Forces.

Die Quelle liefert dagegen keinen belastbaren Gesamt-Personalbestand des Lagers. Sichtbare Zelt-, Unterkunfts- oder Fahrzeugzahlen dürfen nicht direkt in Personalstärken umgerechnet werden.

### 6.3 Shindand

Shindand wird als Camp La Marmora/FOB La Marmora und Airfield mit mindestens folgenden Rollen erkennbar:

- italienisches Manöverelement für südliches Herat;
- später Aviation-Support für westliches Afghanistan;
- in post-periodischen Ständen zusätzliche amerikanische Bodenelemente.

Für August 2010 ist insbesondere das 3rd Alpine Regiment belastbar. Spätere 2012-Einträge wie TF Stormrider oder TF Iron dürfen nicht ohne datierte Zusatzquelle auf 2010/2011 zurückprojiziert werden.

### 6.4 Bagram und Kandahar

Beide Plätze sind über den gesamten Quellenbestand deutlich mehr als Flugplätze:

- Regional-Command- oder IJC-nahe Führung;
- USAF-Wing- und Squadron-Strukturen;
- Combat Aviation Brigades und Spezialaviation;
- EOD/Paladin- und Engineer-Kommandos;
- Training, MP, Detention, ISR, Airlift, Rescue und CAS.

Die konkrete aktive OMW-Bestückung bleibt dennoch Dokument 19 und den jeweiligen ME-Manifesten vorbehalten.

## 7. Stärkeangaben

Morgan liefert überwiegend **Einheitenidentität**, nicht Ist-Personalstärke. Aus einer Brigade- oder Bataillonsbezeichnung darf daher weder eine NATO-Sollgliederung noch eine pauschale Soldatenzahl abgeleitet werden.

Zulässige Stärkearten sind:

```text
EXPLICIT_HEADCOUNT       Quelle nennt eine Zahl ausdrücklich
FORMATION_ECHELON_ONLY   nur Brigade/Bataillon/Kompanie bekannt
PARTIAL_DEPLOYMENT       Abstellung/Detachment/Element ausdrücklich genannt
UNKNOWN_STRENGTH         Einheit bekannt, Iststärke unbekannt
```

Schätzungen aus Satellitenbildern sind als unabhängige Beobachtung zu führen:

```yaml
visual_estimate:
  date: YYYY-MM-DD
  observed_objects: integer|null
  inferred_personnel: null
  confidence: LOW|MEDIUM
  limitations:
    - imagery date uncertainty
    - hidden or temporary assets
    - no personnel conversion without evidence
```

## 8. Missionsdesign-Nutzen

Die Monatsreihe unterstützt:

- zeitlich korrekte Basisbelegung;
- ROTATION-Events und Transfer-of-Authority-Missionen;
- Ablösung von Task Forces ohne künstlichen Verlust der regionalen Fähigkeit;
- AOR-basierte Tasking- und Reaktionsräume;
- historisch plausible QRF-, Aviation-, EOD-, Route-Clearance- und Advisory-Verfügbarkeit;
- realistische C2-Hierarchien zwischen ISAF, IJC, RC, Task Force und Bataillon;
- Unterschiede zwischen Basen, die im DCS-Terrain äußerlich ähnlich erscheinen.

Nicht zulässig ist eine automatische 1:1-Umsetzung jeder genannten Einheit als dauerhaft physisch gespawnte DCS-Gruppe. Die Quelle beschreibt reale Organisationsstrukturen; die DCS-Repräsentation muss über Dokument 07, Dokument 15, die CampaignState-Architektur und MOOSE-First skaliert werden.

## 9. Offene Prüfpunkte

1. Monatliche Normalisierung aller 17 OMW-relevanten Snapshots in einen strukturierten Datensatz;
2. Gegenprüfung wichtiger Einträge mit amtlichen ISAF-Placemats, DVIDS-Transfer-of-Authority-Berichten und nationalen Quellen;
3. Trennung von Hauptquartierstandort, Einheitsbasis, Detachment und tatsächlichem Operationsraum;
4. Ergänzung der von Morgan ausgelassenen PRT-, Logistik-, Sanitäts- und Intelligence-Strukturen aus Fachquellen;
5. Prüfung, ob eine Basisbezeichnung im jeweiligen Monat Airfield, Camp, FOB oder benachbarte Teilanlage meint;
6. keine Änderung der aktiven ORBAT ohne gesonderte Projektinhaberentscheidung.
