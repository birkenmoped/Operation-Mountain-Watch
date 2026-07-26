# Afghanistan-Konvois: TTP, ROE und DCS-Abbildung

Datum: 16. Juli 2026  
Status: Recherche- und Designgrundlage, noch keine DCS-Abnahme

## Zweck

Dieses Dokument trennt drei Ebenen:

1. reale taktische Konvoigrundsätze aus Afghanistan und aus multiservice Konvoidoktrin;
2. Afghanistan-spezifische ROE- und Force-Protection-Grundsätze;
3. die technisch sinnvolle Abbildung in DCS/MOOSE.

Eine DCS-Option ist niemals automatisch identisch mit einem realen Verfahren. Wo DCS eine reale Entscheidung nicht ausdrücken kann, wird die Abweichung ausdrücklich dokumentiert.

## Quellenlage

Primäre und offizielle Quellen:

- ALSSA, Multi-Service Tactics, Techniques, and Procedures for Tactical Convoy Operations, aktuelle Projekt-/Publikationsseite: https://www.alssa.mil/mttps/tco/
- U.S. Army Sustainment Resource Portal, Tactical Convoy Operations: https://cascom.army.mil/asrp/tng-relocate.html
- U.S. Army, Train as we fight: Using sustainment vehicles for convoy protection: https://www.army.mil/article/125012/train_as_we_fight_using_sustainment_vehicles_for_convoy_protection
- U.S. Army, Tactical Leader Lessons Learned in Afghanistan: Operation Enduring Freedom VIII: https://www.army.mil/article/26874/tactical_leader_lessons_learned_in_afghanistan_operation_enduring_freedom_viii
- NATO, ISAF Tactical Directive / civilian-protection briefing: https://www.nato.int/en/news-and-events/events/transcripts/2009/01/14/weekly-press-briefing
- DCS World Scripting Engine, Controller behavior options: https://www.digitalcombatsimulator.com/en/support/faq/1267/

Ergänzende historische Referenz:

- öffentlich gespiegelt: FM 4-01.45/MCRP 4-11.3H/NTTP 4-01.3/AFTTP(I) 3-2.58, Tactical Convoy Operations, 24 March 2005.

Die exakten Zahlen 75–100 m auf offener Straße und das Beispiel 50+ mph stammen aus dieser älteren Ausgabe. Sie sind keine universelle Afghanistan-SOP und müssen immer gegen Gelände, Fahrzeugmix, Auftrag und Bedrohung abgewogen werden.

# 1. Geschwindigkeit

## 1.1 Reale Grundsätze

Die Konvoigeschwindigkeit wird nicht pauschal als Höchstgeschwindigkeit des schnellsten Fahrzeugs festgelegt. Entscheidend sind:

- das langsamste Fahrzeug;
- die Fähigkeit des hinteren Fahrzeugs, nach Kurven, Kreuzungen und kurzen Verzögerungen wieder aufzuschließen;
- Straßenbeschaffenheit, Steigungen und Kurven;
- Verkehr und Bevölkerung;
- Sicht, Wetter und Fahrerausbildung;
- Bedrohung und Auftrag;
- Vermeidung des Ziehharmonikaeffekts.

Die ältere multiservice Doktrin nennt für offene Straßen beispielhaft 50+ mph, für urbane oder kanalisierte Bereiche dagegen nur „so schnell wie der Verkehr erlaubt“. Das ist ein Planungsbeispiel und kein für Afghanistan allgemein gültiger Marschwert.

## 1.2 Afghanistan-Bewertung

Auf guten offenen Hauptstraßen war ein zügiges Durchfahren sinnvoll. Auf Bergstraßen, in Ortschaften, bei unübersichtlichen Kurven, schlechter Fahrbahn oder hoher IED-Bedrohung konnte derselbe Konvoi wesentlich langsamer fahren.

Daher ist ein einziges globales Tempo für die gesamte Bagram–Jalalabad-Route nur ein Testkompromiss.

## 1.3 DCS-Empfehlung

Kurzfristig, während des Spielerrelevanztests:

```text
speedKph = 30
```

unverändert lassen. Dadurch wird die neue Automatik isoliert geprüft.

Später als eigener Realismustest:

```text
urban / stark kanalisiert:  25–30 km/h
offene befestigte Straße:   40–50 km/h
enge Berg-/Schlechtstrecke: 20–30 km/h
```

Diese Werte sind DCS-Testwerte, keine behaupteten historischen Standardwerte.

Ein späteres Produktionsmodell sollte Routensegmente klassifizieren und pro Segment ein Solltempo setzen. Zusätzlich sollte das Solltempo unter der angenommenen nachhaltigen Maximalgeschwindigkeit des langsamsten Fahrzeugs liegen, damit DCS-Fahrzeuge nach Kurven und Bremsmanövern wieder aufschließen können.

# 2. Fahrzeugabstand

## 2.1 Reale Grundsätze

Der Abstand wird nach Gelände und Bedrohung festgelegt. Er muss gleichzeitig:

- die Wirkung eines einzelnen Angriffs auf mehrere Fahrzeuge verringern;
- gegenseitige Beobachtung und Feuerunterstützung erhalten;
- sicheren Bremsweg und Ausweichraum bieten;
- verhindern, dass zivile oder feindliche Fahrzeuge den Verband teilen;
- den Ziehharmonikaeffekt begrenzen.

Die ältere multiservice Doktrin empfiehlt als Ausgangspunkt 75–100 m auf offener Straße. In urbanen und kanalisierten Bereichen werden die Abstände verkürzt, jedoch nicht so weit, dass keine Manövrierfähigkeit mehr besteht.

Der Abstand ist nicht allein aus einem angenommenen Splitterradius von RPG, Mörser oder IED abzuleiten. Wirkung, Zündpunkt, Deckung, Fahrzeugpanzerung, Angriffsrichtung und Gelände variieren zu stark. Doktrin behandelt Abstand deshalb als METT-TC-Entscheidung und nicht als feste Waffenradiusformel.

## 2.2 Afghanistan-Bewertung

Die Annahme „enger in Ortschaften, weiter auf Überlandstrecken“ ist fachlich plausibel:

- enge Abstände erschweren das Einscheren und Trennen des Konvois;
- größere Abstände auf offenen Strecken reduzieren Mehrfachverluste durch einen einzelnen Angriff;
- zu große Abstände schwächen gegenseitige Sicherung und erleichtern das Isolieren einzelner Fahrzeuge.

## 2.3 DCS-Empfehlung

Der aktuelle TM01C-Wert ist:

```text
vehicleSpacingMeters = 15
```

Für den laufenden Automatiktest bleibt dieser Wert zunächst unverändert.

Späterer DCS-Abnahmetest:

```text
urbaner Zielabstand:     15–25 m
offener Zielabstand:     50–75 m
```

75–100 m sollte zusätzlich getestet werden, ist aber wahrscheinlich nicht auf allen Afghanistan-Kurven und mit der DCS-Gruppen-KI stabil.

Wichtig: TM01C kann den Spawnabstand exakt planen. Ob DCS eine große Staffelung während langer Fahrt dauerhaft hält, ist ein gesonderter Laufzeitnachweis.

# 3. Verhalten bei Feindkontakt

## 3.1 Reale Grundsätze

Taktische Konvois waren keine administrativen Straßenmärsche. Die U.S.-Army-Konvoidoktrin fordert 360-Grad-Sicherung, Battle Drills und ständige Gefechtsbereitschaft.

Bei einem kurzen oder begrenzten Angriff kann das Weiterfahren durch die Gefahrenzone die beste Reaktion sein. Offizielle Marine-Ausbildungsberichte beschreiben ausdrücklich, dass bei vereinzeltem Scharfschützenfeuer weitergefahren werden konnte. Bei komplexen Hinterhalten, blockierter Route, ausgefallenem Fahrzeug oder Verwundeten war dagegen eine andere Battle-Drill-Entscheidung erforderlich.

Es gibt daher keinen universellen Satz „unter allen Umständen durchbrechen“. Die Verantwortung, den Kontakt abzubrechen oder zu bleiben und zu kämpfen, liegt beim Convoy Commander und hängt von Route, Schaden, Auftrag und Bedrohung ab.

## 3.2 DCS-Problem

DCS `Disperse under fire` bildet nicht sauber „unter Feuer weiterfahren“ ab. Die Funktion kann Fahrzeuge von der Route wegfahren und für die konfigurierte Zeit anhalten. Das widerspricht dem gewünschten Verhalten eines mobilen Logistikkonvois, der einen begrenzten Hinterhalt möglichst verlässt.

## 3.3 DCS-Empfehlung

```text
DISPERSE_ON_ATTACK = false
```

für reguläre BLUE-Logistikkonvois.

Das gewünschte Verhalten wird später als eigene Zustandslogik abgebildet:

```text
Kontakt, alle Fahrzeuge mobil
→ Route halten
→ Feuer erwidern
→ Kill Zone verlassen

Mobilitätsausfall / Route blockiert / kritischer Verlust
→ kein automatisches Weiterfahren erzwingen
→ separater Recovery-/Security-Zustand
```

DCS soll nicht automatisch verteilen und mehrere Minuten am Straßenrand stehen.

# 4. Alarmzustand

## 4.1 Reale Bewertung

Afghanistan-Konvois operierten in einem Umfeld, in dem Angriffe jederzeit möglich waren. Offizielle Army-Erfahrungsberichte beschreiben taktische Bewegung, Counter-IED-Maßnahmen, bemannte Waffen und ständige Sicherung. Das entspricht eher einem dauerhaft hohen Bereitschaftsgrad als einer friedensmäßigen Grundstellung.

## 4.2 DCS-Empfehlung

```text
ALARM_STATE = RED
```

ist die passendste DCS-Abstraktion für einen bewaffneten BLUE-Konvoi im Einsatzgebiet.

Das bedeutet nicht, dass real ständig auf jedes unbekannte Objekt gezielt oder geschossen wurde. Es bedeutet nur, dass Besatzungen und Waffen nicht erst nach einer langen DCS-Automatikumschaltung gefechtsbereit werden.

Der Einfluss von `RED` auf Fahrverhalten und Routenannahme muss im DCS-Lauf geprüft werden. Falls DCS bei `RED` die Marschbewegung unzuverlässig macht, ist das eine Simulationsgrenze und kein Argument für eine historisch unplausible entspannte Haltung.

# 5. ROE

## 5.1 Historische Bewertung

Es gab keine einzige, über alle Jahre, Nationen, Regionen und Missionen identische Afghanistan-Konvoi-ROE.

Öffentlich zugängliche Afghanistan-Erfahrungsberichte nennen:

- positive Identifikation;
- Reaktion auf hostile act;
- Reaktion auf anhand der Gesamtlage erkannten hostile intent;
- inhärentes Recht auf Selbstverteidigung;
- Verhältnismäßigkeit, Unterscheidung und Schutz von Zivilisten;
- Warn- und Eskalationsmaßnahmen im Straßenverkehr, soweit die Lage dies zuließ.

Damit ist „erst schießen, nachdem die eigene Einheit getroffen wurde“ als allgemeine historische Regel zu eng. Gleichzeitig wäre ein uneingeschränktes Bekämpfen jedes erkannten roten DCS-Objekts in einer COIN-Umgebung zu aggressiv.

## 5.2 DCS-Grenze

DCS bietet für Bodenverbände nur:

```text
OPEN_FIRE
RETURN_FIRE
WEAPON_HOLD
```

DCS kennt keine belastbare Zwischenschicht für positive Identifikation, hostile intent, Warnverfahren und abgestufte Eskalation.

## 5.3 DCS-Empfehlung

Standard für den BLUE-Logistikkonvoi:

```text
ROE = RETURN_FIRE
```

Begründung:

- vermeidet proaktives Feuer auf jeden von DCS erkannten roten Kontakt;
- passt besser zu restriktiver COIN-Umgebung und Zivilistenschutz;
- erlaubt Selbstverteidigung nach tatsächlichem Angriff.

Späterer Ausbau:

```text
bestätigter hostile act / scripted hostile intent
→ zeitweise OPEN_FIRE gegen bestätigte Angreifer

Kontakt beendet / kein bestätigtes Ziel
→ RETURN_FIRE
```

Das ist näher an der realen Logik als dauerhaft `OPEN_FIRE`, bleibt aber eine vereinfachte DCS-Abbildung.

# 6. Empfohlener BLUE-Konvoi-Basissatz

Für den nächsten isolierten Spielerrelevanztest:

```text
Speed:                 30 km/h, unverändert
Spawn spacing:         15 m, unverändert
Formation:             ON_ROAD
Alarm state:           RED
ROE:                   RETURN_FIRE
Disperse under fire:   OFF
```

Keine Geschwindigkeits- oder Abstandsprofile im selben Test einführen. Dadurch bleibt klar, ob ein Fehler aus der Spielerrelevanzautomatik oder aus geänderten Fahrzeug-TTP stammt.

# 7. Spätere getrennte DCS-Tests

## Test A – Alarmzustand und ROE

- Konvoi mit `RED`, `RETURN_FIRE`, `DISPERSE_OFF` starten;
- Weiterfahrt ohne Feindkontakt prüfen;
- begrenzten Hinterhalt auslösen;
- prüfen, ob der Verband feuert und mobil bleibt;
- prüfen, ob Verluste weiterhin korrekt persistiert werden.

## Test B – Abstand

- 15 m, 25 m, 50 m, 75 m vergleichen;
- gerade Straße, enge Kurve, S-Kurve, Ortsdurchfahrt;
- Spawnfähigkeit, Routenaktivierung, Kollisionsverhalten und DCS-Kompression protokollieren.

## Test C – Geschwindigkeit

- 30, 40 und 50 km/h mit 3 HMMWV und 3 Lkw;
- mittlere Geschwindigkeit, Rückstand des letzten Fahrzeugs, Accordion-Effekt und Wiederaufschließen messen;
- kein Wert wird allein nach nomineller Höchstgeschwindigkeit ausgewählt.

# 8. Schutzregel für automatische Pack-/Unpack-Logik

Ein Konvoi darf später nicht automatisch packen, wenn:

- aktuell Beschuss oder bestätigter Feindkontakt besteht;
- ein Verlust noch nicht in den CampaignState übernommen wurde;
- ein Fahrzeug mobilitätsunfähig ist;
- eine Recovery-/Casualty-Entscheidung offen ist;
- die letzte Feindberührung noch innerhalb eines festgelegten Contact-Cooldowns liegt.

Der erste visuelle Spielerrelevanztest findet bewusst ohne Feindkontakt statt. Die Contact-Sperre ist danach als eigener Test hinzuzufügen.
