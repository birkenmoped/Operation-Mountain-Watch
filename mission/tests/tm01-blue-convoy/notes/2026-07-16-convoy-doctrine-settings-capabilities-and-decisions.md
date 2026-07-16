# BLUE-Konvois in Afghanistan – Doktrin, aktuelle Einstellungen, DCS/MOOSE-Fähigkeiten und Designentscheidungen

Datum: 16. Juli 2026  
Status: kanonischer Gesprächs- und Entscheidungsstand; laufende technische Entwicklung; keine Merge-Freigabe

## 1. Zweck und Geltungsbereich

Dieses Dokument konsolidiert die vollständige Diskussion zu:

- realistischen BLUE-Konvoigrundsätzen für Afghanistan/COIN;
- den derzeit tatsächlich im TM01C-Code aktiven Einstellungen;
- den für den nächsten DCS-Test beschlossenen Einstellungen;
- Geschwindigkeit, Fahrzeugabstand, Alarmzustand, ROE und Verhalten unter Feuer;
- automatischer Spielerrelevanz für Pack/Unpack;
- der Frage, ob Stadt, Dorf oder Überlandstrecke automatisch erkannt werden können;
- den Fähigkeiten und Grenzen von DCS und MOOSE;
- den CPU-, Skript- und DCS-AI-Kosten dynamischer Profile;
- der geplanten Reihenfolge weiterer Technik- und Realismustests.

Wichtig: In diesem Dokument werden vier Statusklassen streng getrennt:

```text
AKTIV IM CODE
= derzeit tatsächlich im TM01C-Branch implementiert und geladen

BESCHLOSSEN FÜR NÄCHSTEN TEST
= fachlich festgelegt, aber noch nicht zwingend implementiert oder in DCS abgenommen

SPÄTERES PRODUKTIONSMODELL
= Zielbild nach isolierten Techniktests

DOKTRIN-/RECHERCHEGRUNDLAGE
= reale oder historische Leitlinie; nicht automatisch identisch mit einer DCS-Option
```

## 2. Projekt- und Laufzeitkontext

```text
Repository: birkenmoped/Operation-Mountain-Watch
Branch:     feature/tm01b-convoy-caching
PR:         #8, Draft, nicht mergen
Entität:    TEST.TM01.CONVOY.001
Route:      ROUTE_TM01_BAGRAM_JALALABAD
DCS:        2.9.27.25340 Open Beta MT
MOOSE:      2.9.18, gepinnter Projektstand
MOOSE-Commit im Projektkontext:
73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:
e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Zuletzt erfolgreich getestete Fahrzeugzusammensetzung:

```text
3 × HMMWV
3 × Lkw
```

Die Stable-Slot-, Survivor-, Schadens- und Lead-Logik ist ausdrücklich nicht an homogene Fahrzeugtypen gebunden.

## 3. Derzeit tatsächlich aktive TM01C-Einstellungen

Konfigurationskennung:

```text
TM01C-manual-proxy-pack-unpack-4
```

### 3.1 Template und Stable Slots

```text
Templategruppe:             TPL_TEST_BLUE_CONVOY_STANDARD_01
Runtime-Aliaspräfix:        TM01C_BLUE_CONVOY_001
Erwartete Fahrzeuganzahl:   6
Stable Slots rear-to-front: 6,5,4,3,2,1
```

Der vorderste überlebende Stable Slot ist stets die aktuelle Lead-/Proxyrolle.

### 3.2 Aktuelle Route und Marschparameter

```text
roadOnly:                         true
speedKph:                         30
formation:                        ON_ROAD
routeSampleMeters:                10
maximumRoadSnapMeters:            1500
roadPositionToleranceMeters:      30
vehicleSpacingMeters:             15
minimumVehicleSeparationMeters:   8
unpackLeadOffsetCandidatesMeters: 0,15,30,45,60
```

Bedeutung:

- `speedKph = 30` gilt derzeit für alle erzeugten Ground-Waypoints;
- `vehicleSpacingMeters = 15` ist der geplante physische Abstand beim initialen Spawn und beim Unpack;
- dieser Wert ist noch nicht dasselbe wie die DCS-Controlleroption `Formation Interval`;
- `ON_ROAD` ist die derzeit zulässige Formation;
- die Route wird einmal aus Start, sieben Ankern und Ziel kompiliert;
- jedes Fahrzeug erhält eine eigene Straßenposition und ein eigenes lokales Heading.

### 3.3 Transition- und Aktivierungsparameter

```text
pollSeconds:                               1
markerUpdateSeconds:                       5
destroyConfirmationPollSeconds:            0.5
destroyConfirmationTimeoutSeconds:         10
automaticUnpackAtTarget:                    true
routeActivationInitialDelaySeconds:         1
routeActivationPollSeconds:                 1
routeActivationReissueSeconds:              5
routeActivationTimeoutSeconds:              30
routeActivationMovementThresholdMeters:     2
```

Die wiederholte Routenzuweisung ist ausschließlich während `ACTIVATING_ROUTE` zulässig. Nach bestätigter Bewegung gibt es keine automatische Unstuck-, Teleport- oder Dauer-Re-Routing-Logik.

### 3.4 Schadensparameter

```text
damageCaptureTolerancePercent: 0.05
damageRestoreTolerancePercent: 1
damageRestoreRetrySeconds:      1
damageRestoreMaxAttempts:       5
```

Partielle Schäden werden pro Stable Slot als Domainzustand gespeichert und nach einem Repräsentationsspawn wiederhergestellt und verifiziert.

### 3.5 Derzeit noch ausgeschlossene Systeme

```text
revealWindows:                    ausgeschlossen
automaticPlayerInterestDetection: ausgeschlossen
automaticEnemyInterestDetection:  ausgeschlossen
persistenceAcrossMissionRestart:  ausgeschlossen
cargoUnits:                       ausgeschlossen
manifests:                        ausgeschlossen
warehouses:                       ausgeschlossen
```

Diese Ausschlüsse beschreiben den aktuellen TM01C-Stand. Die automatische Spielerrelevanz ist der nächste geplante, isolierte Erweiterungsschritt.

## 4. Bereits bestätigter manueller Kern

Der erfolgreiche DCS-Lauf mit Version 4 bestätigte:

```text
9 × Pack gestartet
9 × Pack bestätigt
9 × Unpack gestartet
9 × Unpack bestätigt
10 × Routenaktivierung bestätigt
0 × TM01C-Fehler
0 × movementState=FAILED
0 × halted=true
```

Zusätzliche Sichtbeobachtung:

- korrekte Fahrzeugausrichtung nach jedem Unpack;
- korrekte lokale Ausrichtung auch in Kurven und S-Kurven;
- keine 180-Grad-Wendemanöver;
- keine Entwirrung quer oder entgegen der Marschrichtung;
- gemischte Fahrzeugtypen funktionierten;
- reduzierte Survivor-Gruppen funktionierten;
- zerstörte Slots wurden nicht wiederhergestellt.

Noch nicht vollständig abgeschlossen:

- visueller Endnachweis partieller Schadenswiederherstellung;
- Angriff auf das eingepackte Proxyfahrzeug;
- vollständige Zielankunft in expandierter und eingepackter Darstellung;
- vollständige Verlustsequenz bis auf zwei konkrete Survivor-Slots mit Zielankunft.

Diese offenen Punkte blockieren den nächsten isolierten Spielerrelevanztest nicht, bleiben aber vor einer Gesamtfreigabe offen.

## 5. Beschlossener nächster Test: automatische BLUE-Spielerrelevanz

### 5.1 Zweck

Der erste Automatiktest ist ausdrücklich ein visueller Nahbereichstest aus einem Spielerhubschrauber. Er soll nur zeigen, dass der Konvoi automatisch entpackt, wenn sich ein Spieler nähert, und nach bestätigter Abwesenheit wieder einpackt.

Er bildet noch keine operative Sichtbarkeit, Sensorreichweite, Feinderkennung oder taktische Bedrohung ab.

### 5.2 Verbindliche Testwerte

```text
Automatisches Unpack:  horizontale Distanz ≤ 500 m
Pack-Timer starten:   horizontale Distanz > 750 m
Pack-Verzögerung:     30 s kontinuierlich außerhalb 750 m
Hysteresezone:        500 m bis 750 m
Distanzmodell:        2D/horizontal
Höhe:                 ignoriert
Geometrie:            vertikaler Zylinder um Lead-/Proxyposition
```

Einordnung:

```text
1000 ft ≈ 305 m
1500 ft ≈ 457 m
500 m   ≈ 1640 ft
750 m   ≈ 2460 ft
```

### 5.3 Relevante Spieler

Für den ersten Test zählen ausschließlich:

- lebende BLUE-Spielerunits;
- tatsächlich besetzte Client-/Player-Slots;
- der jeweils nächste relevante Spieler.

Nicht relevant:

- Zuschauer;
- unbesetzte Client-Slots;
- AI-Einheiten;
- RED-Spieler oder RED-AI;
- Sensor- oder Sichtkontakte.

Ein einzelner relevanter Spieler im Bereich hält den Konvoi expandiert.

### 5.4 Hysterese- und Timerlogik

```text
Distanz ≤ 500 m
→ bei COLLAPSED_PROXY genau ein automatisches Unpack anfordern

Distanz 500–750 m
→ vorhandenen Repräsentationszustand beibehalten
→ keinen neuen Pack-Timer starten

Distanz > 750 m
→ bei EXPANDED Pack-Timer starten
→ erst nach 30 s ununterbrochener Abwesenheit Pack anfordern

Wiedereintritt auf ≤ 750 m während Timer
→ Pack-Timer sofort abbrechen
```

Keine neue Automatikaktion während:

```text
PACKING
UNPACKING
ACTIVATING_ROUTE
```

Nach Abschluss einer Transition wird die Spielerrelevanz erneut ausgewertet. Die manuellen F10-Befehle bleiben als Diagnose- und Override-Werkzeug erhalten.

### 5.5 Nicht Bestandteil dieses Tests

- Sichtlinie;
- Geländeabschattung;
- Sensorreichweite;
- Waffenreichweite;
- Sichtweitenmodell;
- Feinderkennung;
- taktische Bedrohungsbewertung;
- Flughöhenabhängigkeit;
- automatische Stadt-/Dorferkennung.

## 6. Reale Konvoidoktrin und Afghanistan-/COIN-Grundsätze

### 6.1 Geschwindigkeit

Ein realer Konvoi fährt nicht einfach dauerhaft mit der technischen Höchstgeschwindigkeit des schnellsten Fahrzeugs. Maßgeblich sind:

- nachhaltige Leistung des langsamsten Fahrzeugs;
- Beladung und Fahrzeugmix;
- Straßenoberfläche, Steigung, Kurven und Engstellen;
- Verkehr und Bevölkerung;
- Sicht und Wetter;
- Bedrohungslage und Auftrag;
- Fahrerausbildung;
- Vermeidung des Ziehharmonikaeffekts;
- Fähigkeit hinterer Fahrzeuge, nach Kurven, Bremsungen oder Kreuzungen wieder aufzuschließen.

Daraus folgt:

- Das Solltempo sollte unterhalb der theoretischen Maximalleistung des langsamsten Fahrzeugs liegen.
- Ein kleiner Leistungsüberschuss ermöglicht zurückgefallenen Fahrzeugen das Wiederaufschließen.
- Eine hohe durchschnittliche Marschgeschwindigkeit entsteht eher durch gleichmäßigen Verkehrsfluss und geringe Stopprate als durch ständiges Vollgas.

Historische multiservice Konvoidoktrin nennt für offene Straßen beispielhaft hohe Geschwindigkeiten, teils 50+ mph. Das ist kein universeller Afghanistan-Standard. Afghanische Bergstraßen, Ortsdurchfahrten, schlechte Fahrbahnen und IED-Bedrohung können deutlich niedrigere Geschwindigkeiten erfordern.

Für spätere DCS-Profile wurden als Testwerte diskutiert:

```text
URBAN / stark kanalisiert: 25–30 km/h
RURAL / offene Straße:     40–50 km/h
Berg-/Schlechtstrecke:     20–30 km/h
```

Diese Werte sind Testhypothesen und keine behaupteten universellen historischen SOP-Werte.

### 6.2 Fahrzeugabstand

Der reale Abstand muss mehrere konkurrierende Ziele ausbalancieren:

- Mehrfachverluste durch einen einzelnen Angriff vermeiden;
- gegenseitige Beobachtung und Feuerunterstützung erhalten;
- Bremsweg und Ausweichraum sichern;
- Einscheren und Trennen durch zivile oder feindliche Fahrzeuge erschweren;
- Ziehharmonikaeffekt begrenzen;
- einzelne Fahrzeuge nicht isolieren.

Plausible Grundtendenz:

```text
Ortschaft / enger Verkehr
→ relativ enger Verband
→ erschwert Einscheren und Trennen

Offene Überlandstrecke
→ größerer Abstand
→ reduziert Mehrfachwirkung eines einzelnen Angriffs
```

Ältere multiservice Doktrin nennt 75–100 m als Ausgangspunkt auf offener Straße. Das ist kein universeller Afghanistan-Festwert. Der reale Abstand ist METT-TC-abhängig und darf nicht allein aus einem angenommenen Splitterradius von RPG, Mörser oder IED abgeleitet werden.

Für spätere DCS-Tests wurden diskutiert:

```text
URBAN: 15–25 m
RURAL: 50–75 m
zusätzlicher Grenztest: 75–100 m
```

### 6.3 Verhalten bei Feindkontakt

Der Grundgedanke „nicht in der Kill Zone stehen bleiben“ ist plausibel, aber keine ausnahmslose Regel.

Vereinfachtes reales Entscheidungsbild:

```text
begrenzter Angriff
Route frei
Fahrzeuge mobil
→ Feuer erwidern
→ Bewegung erhalten
→ Gefahrenbereich verlassen

Fahrzeug ausgefallen
Route blockiert
kritische Verwundete
komplexer Hinterhalt
→ angepasster Battle Drill
→ Sicherung, Bergung, Versorgung oder Evakuierung
```

Es gibt keine glaubwürdige Universalregel „unter allen Umständen durchbrechen“. Auftrag, Schaden, Gelände, Route und Bedrohung bestimmen die Reaktion.

### 6.4 Alarmzustand

Afghanistan-Konvois bewegten sich in einem Umfeld ständiger möglicher Bedrohung. Taktische Bewegung, Counter-IED-Maßnahmen, bemannte Waffen und 360-Grad-Sicherung entsprechen eher einem dauerhaft hohen Bereitschaftsgrad als einer friedensmäßigen Haltung.

DCS-Abstraktion:

```text
ALARM_STATE = RED
```

`RED` bedeutet nicht, dass real automatisch auf jedes unbekannte Objekt gezielt oder geschossen wurde. Es soll nur die Gefechtsbereitschaft und sofortige Waffenverfügbarkeit abbilden.

### 6.5 ROE

Es gab keine einzige, über alle Jahre, Nationen, Regionen und Missionen identische Afghanistan-Konvoi-ROE.

Wiederkehrende reale Prinzipien:

- positive Identifikation;
- Reaktion auf `hostile act`;
- Reaktion auf hinreichend erkannten `hostile intent`;
- inhärentes Recht auf Selbstverteidigung;
- Verhältnismäßigkeit;
- Unterscheidung;
- Schutz von Zivilisten;
- Warn- und Eskalationsmaßnahmen, soweit die Lage dies zuließ.

Daraus folgt:

- „Erst schießen, nachdem die eigene Einheit getroffen wurde“ ist historisch als allgemeine Regel zu eng.
- Dauerhaftes freies Feuer auf jedes von DCS erkannte rote Objekt wäre für eine COIN-Umgebung zu aggressiv.

DCS besitzt keine vollständige PID-, Warn- oder Hostile-Intent-Logik. Die passende Grundabstraktion ist daher:

```text
ROE = RETURN_FIRE
```

Späteres Zielbild:

```text
Normalfahrt
→ RETURN_FIRE

bestätigter hostile act oder gescripteter hostile intent
→ zeitweise OPEN_FIRE gegen bestätigte Angreifer

Kontakt beendet
→ zurück zu RETURN_FIRE
```

## 7. Beschlossener taktischer DCS-Basissatz

Für reguläre bewaffnete BLUE-Logistikkonvois wurde fachlich festgelegt:

```text
Formation:            ON_ROAD
Alarmzustand:         RED
ROE:                  RETURN_FIRE
Disperse under fire:  OFF
```

Begründung:

- `RED` bildet die hohe Bereitschaft besser ab;
- `RETURN_FIRE` ist restriktiver und COIN-tauglicher als permanentes `OPEN_FIRE`;
- `DISPERSE_ON_ATTACK = false` verhindert, dass DCS die Fahrzeuge bei Beschuss von der Route wegfahren und länger stehen lässt;
- das gewünschte Verhalten „mobil bleiben und Gefahrenbereich verlassen“ muss später durch eigene Zustandslogik statt durch die DCS-Disperse-Funktion abgebildet werden.

Status dieser Optionen:

```text
fachlich beschlossen
aber noch nicht als vollständig DCS-abgenommener Produktionssatz bestätigt
```

Vor Nutzung als Standard ist ein kurzer Regressionstest erforderlich:

- fährt der Konvoi mit `RED` zuverlässig an;
- bleibt die Route stabil;
- schießt er unter `RETURN_FIRE` nach tatsächlichem Angriff zurück;
- bleibt er mit `DISPERSE_OFF` mobil;
- funktionieren Verlust- und Schadenspersistenz weiter.

## 8. Was DCS direkt umsetzen kann

### 8.1 Geschwindigkeit pro Wegpunkt

DCS-Ground-Routen speichern eine Geschwindigkeit pro Wegpunkt. MOOSE erzeugt passende Wegpunkte über:

```lua
aCoordinate:WaypointGround(speedKph, formation)
```

Folge:

- verschiedene Abschnittsgeschwindigkeiten können beim Routenbau vorab kodiert werden;
- DCS arbeitet die Geschwindigkeitswechsel selbst ab;
- kein permanentes Lua-Umschalten erforderlich;
- gilt gleichermaßen für expandierte Gruppe und Proxyfahrzeug.

### 8.2 Formation Interval

DCS besitzt die Ground-Option `Formation Interval`. MOOSE stellt sie als Wrapper bereit:

```lua
group:OptionFormationInterval(meters)
```

Dokumentierter Wertebereich:

```text
0 bis 100 m
```

Der Mission Editor kann den Wert abhängig vom eingestellten Einheitensystem in Fuß anzeigen. Die MOOSE-Funktion erwartet Meter.

Umrechnung:

```text
20 m  ≈  66 ft
50 m  ≈ 164 ft
60 m  ≈ 197 ft
75 m  ≈ 246 ft
100 m ≈ 328 ft
```

Wichtig:

```text
vehicleSpacingMeters
= physische Ausgangsaufstellung beim Spawn/Unpack

OptionFormationInterval
= von DCS angestrebter laufender Marschabstand
```

Beide Werte sind getrennte Mechanismen. Für erste Techniktests sollten sie identisch gesetzt werden.

### 8.3 ROE, Alarm und Disperse

Diese Controlleroptionen können beim Spawn beziehungsweise nach Erzeugung einer Gruppe mit einzelnen DCS-/MOOSE-Aufrufen gesetzt werden. Die Skriptkosten sind vernachlässigbar. Das Hauptrisiko ist nicht CPU, sondern das konkrete DCS-AI-Verhalten.

### 8.4 Zonen und Routensegmente

MOOSE kann Trigger-, Radius- und Polygonzonen effizient prüfen. Damit kann ein Missionsautor Siedlungsbereiche oder Profilübergänge explizit markieren.

### 8.5 Straßenpfad und Routenfortschritt

TM01C kompiliert die Route bereits einmal und speichert Samplepunkte mit kumulierter Routendistanz. Das ist eine gute Grundlage für vorab klassifizierte Profile.

## 9. Was DCS nicht direkt oder nicht zuverlässig kann

DCS liefert keine belastbare semantische Abfrage:

```text
Diese Koordinate liegt in einer Stadt.
Diese Koordinate liegt in einem Dorf.
Diese Koordinate liegt auf freier Überlandstrecke.
```

Weitere Grenzen:

- `land.getSurfaceType()` unterscheidet keine Stadt gegen Dorf gegen Freiland;
- `SceneryObject` liefert Kartenobjekte, aber kein verlässliches Siedlungsflächenmodell;
- DCS kennt keine vollständige PID-/Hostile-Intent-/Warnlogik;
- DCS garantiert nicht, dass ein vorgegebenes Formationsintervall in jeder Kurve oder Verkehrslage exakt gehalten wird;
- DCS erlaubt über die reguläre Missionsskript-API kein belastbares nachträgliches Hinzufügen einzelner Fahrzeuge zu einer bestehenden Gruppe;
- daher bleibt Unpack ein sichtbarer Gruppentausch;
- ein perfektes taktisches Konvoi-Battle-Drill-System ist nicht nativ vorhanden.

## 10. Was MOOSE zusätzlich bietet – und was nicht

MOOSE erleichtert und strukturiert vorhandene DCS-Fähigkeiten:

- `WaypointGround()`;
- `Route()`;
- `OptionFormationInterval()`;
- ROE-, Alarm- und Disperse-Wrapper;
- Zonen;
- Koordinaten-, Straßen- und Scenery-Hilfsfunktionen;
- Spawn- und Wrapperabstraktionen.

MOOSE erweitert aber nicht die eigentliche DCS-KI. Es kann nicht garantieren:

- exakte Siedlungsgrenzen;
- perfekte Formationshaltung;
- verlässliche taktische Feindabsichtserkennung;
- nahtloses Hinzufügen von Fahrzeugen zu einer bestehenden DCS-Gruppe;
- eine vollständig realistische COIN-ROE-Entscheidung.

Jede MOOSE-Funktion muss außerdem gegen den gepinnten Projektstand 2.9.18 geprüft werden; aktuelle Online-Dokumentation kann neuere Funktionen enthalten.

## 11. Modelle zur Erkennung von Stadt, Dorf und Überland

### 11.1 Autorenseitig klassifizierte Routensegmente – empfohlen

Beispiel:

```lua
routeProfiles = {
  {
    fromAnchor = "ZONE_TM01_START_BAGRAM",
    toAnchor = "ZONE_TM01_PROFILE_01",
    environment = "URBAN",
    speedKph = 25,
    intervalMeters = 20,
  },
  {
    fromAnchor = "ZONE_TM01_PROFILE_01",
    toAnchor = "ZONE_TM01_PROFILE_02",
    environment = "RURAL",
    speedKph = 45,
    intervalMeters = 60,
  },
}
```

Ablauf:

```text
Missionsstart
→ Profilpunkte einmal auf Straßenroute projizieren
→ Routendistanzen der Profilgrenzen speichern

Laufzeit
→ aktuelle Routendistanz mit Profilgrenzen vergleichen
→ nur bei tatsächlichem Profilwechsel reagieren
```

Bewertung:

```text
CPU:                sehr gering
Authoring-Aufwand:  gering bis mittel
Zuverlässigkeit:    hoch
Kartenabhängigkeit: explizit und kontrollierbar
```

### 11.2 Trigger-/Polygonzonen

Geeignet für wenige bekannte Siedlungen oder Engstellen.

```text
CPU:               gering
Authoring-Aufwand: mittel
Zuverlässigkeit:   hoch innerhalb gepflegter Zonen
```

Nachteile:

- viele Zonen auf langen Routen;
- manuelle Pflege;
- komplexe Siedlungsformen.

### 11.3 Dynamische Gebäude-/Scenery-Dichte

Möglicher Ansatz:

```text
bewegliche Zone um Lead
→ Gebäude/Scenery zählen
→ Dichte klassifizieren
```

Bewertung:

```text
CPU:                mittel bis hoch
Implementierung:    hoch
Zuverlässigkeit:    niedrig bis mittel
Kartenabhängigkeit: hoch
```

Probleme:

- Scenery-Verteilung ist kein stabiles Siedlungsmodell;
- Objektnamen und Kategorien sind nicht garantiert einheitlich;
- Gebäudesuchen können CPU-intensiv sein;
- Klassifikationsfehler wären schwer nachvollziehbar.

Entscheidung:

```text
nicht für die Produktionslogik verwenden
```

### 11.4 MOOSE-Town-Datenbank

Kann möglicherweise grobe Nähe zu benannten Orten liefern, ersetzt aber keine Siedlungsgrenzen. Für Afghanistan und den gepinnten MOOSE-Stand wäre eine separate Prüfung erforderlich.

Entscheidung:

```text
höchstens Autorisierungs-/Entwicklungshilfe
nicht alleinige Laufzeitentscheidung
```

## 12. Dynamische Geschwindigkeit – empfohlene Umsetzung

Nicht jede Sekunde die Route neu zuweisen.

Stattdessen:

```text
Route bauen
→ Profilgrenzen als zusätzliche Waypoints aufnehmen
→ jedem Waypoint die Profilgeschwindigkeit geben
→ Route einmal an DCS übergeben
```

Vorteile:

- praktisch keine wiederkehrende Lua-Last;
- gilt für expandierte Gruppe und Proxy;
- kein zusätzlicher Scheduler nötig;
- kein permanenter Task-Churn;
- DCS führt Geschwindigkeitswechsel selbst aus.

Nicht empfohlen:

```text
jede Sekunde Position prüfen
→ Geschwindigkeit neu bestimmen
→ Route neu erzeugen
→ Controller.setTask oder GROUP:Route erneut aufrufen
```

Das Hauptproblem wäre weniger CPU als DCS-AI-Instabilität:

- kurzes Stoppen;
- erneute Routenannahme;
- Formationsneubildung;
- Wegfindungsänderung;
- mögliche Konflikte mit Pack/Unpack und Aktivierungslogik.

## 13. Dynamischer Formationsabstand – empfohlene Umsetzung

`Formation Interval` ist eine Controlleroption und nicht nur Spawngeometrie.

Empfohlener Ablauf:

```text
Profilwechsel erkannt
→ prüfen, ob Sollintervall geändert wurde
→ genau einmal OptionFormationInterval(newMeters) aufrufen
→ Wert im CampaignState speichern
→ Änderung strukturiert loggen
```

Wichtig:

- im Proxyzustand ist das Intervall physisch wirkungslos;
- das aktuelle Profil und Sollintervall müssen trotzdem im CampaignState erhalten bleiben;
- beim Unpack wird der aktuelle Wert auf die neue Gruppe angewendet;
- Spawnabstand und Formation Interval sollten für erste Tests gleich sein;
- große Abstände benötigen längere freie Straße hinter dem Lead;
- große Abstände können die Layoutsuche und den benötigten Unpack-Korridor beeinflussen.

## 14. Kosten- und Risikomatrix

| Funktion | Skript-/CPU-Kosten | DCS-AI-Risiko | Entscheidung |
|---|---:|---:|---|
| ROE/Alarm/Disperse einmal setzen | sehr gering | niedrig bis mittel | verwenden, separat regressieren |
| Formation Interval einmal beim Spawn | sehr gering | mittel | Techniktest erforderlich |
| Intervallwechsel nur an Profilgrenze | sehr gering | mittel | sinnvoll |
| Geschwindigkeit pro Waypoint vorkodieren | sehr gering | niedrig | bevorzugt |
| Wenige Autorenzonen prüfen | gering | niedrig | sinnvoll |
| Profilvergleich über Routendistanz | sehr gering | niedrig | bevorzugt |
| Route bei jedem Profil-Poll neu zuweisen | gering bis mittel | hoch | vermeiden |
| Gebäudedichte während der Fahrt scannen | mittel bis hoch | niedriges AI-Risiko, hohe Unzuverlässigkeit | vermeiden |
| vollständige Route jede Sekunde projizieren | mit Routelänge und Konvoizahl wachsend | niedrig | vermeiden |

Der bestehende TM01C-Tick läuft bereits einmal pro Sekunde. Einige Zahlenvergleiche oder wenige Punkt-in-Zone-Prüfungen darin sind auch bei mehreren Konvois unkritisch. Es soll dafür kein zusätzlicher Hochfrequenz-Scheduler eingeführt werden.

## 15. EXPANDED gegen COLLAPSED_PROXY

| Eigenschaft | EXPANDED | COLLAPSED_PROXY |
|---|---|---|
| Geschwindigkeitsprofil | gilt | gilt genauso |
| Formation Interval | physisch relevant | physisch wirkungslos |
| gespeichertes Sollintervall | erforderlich | erforderlich |
| Alarmzustand/ROE | relevant | relevant für Proxyfahrzeug |
| Profilbestimmung | Leadposition | Proxyposition |
| Profilwechsel | Intervalloption und Geschwindigkeitswegpunkte | Geschwindigkeitswegpunkte; Intervall nur speichern |
| Unpack | aktuelles Profil bereits physisch | neue Gruppe mit aktuellem Profil erzeugen |

Der Proxy ist keine andere strategische Entität. Er ist nur die reduzierte physische Darstellung desselben CampaignState-Konvois.

## 16. Beschlossene Entwicklungsreihenfolge

### Schritt 1 – automatische Spielerrelevanz isolieren

Unverändert lassen:

```text
speedKph = 30
vehicleSpacingMeters = 15
```

Neue Funktion:

```text
Unpack bei ≤ 500 m horizontal
Pack-Timer bei > 750 m
Pack nach 30 s kontinuierlicher Abwesenheit
```

Keine Sichtlinie, Sensorik, Feindrelevanz oder adaptive Streckenprofile.

### Schritt 2 – taktische Controlleroptionen regressieren

```text
ALARM_STATE = RED
ROE = RETURN_FIRE
DISPERSE_ON_ATTACK = false
```

Prüfen:

- Anfahren;
- Routenstabilität;
- Feuererwiderung;
- Mobilität unter Beschuss;
- Survivor-/Schadenspersistenz.

### Schritt 3 – Formation-Interval-Techniktest

Noch ohne Stadtlogik:

```text
Lauf A: 20 m
Lauf B: 60 m
```

Prüfen:

- Gerade;
- Kurven;
- S-Kurven;
- gemischte HMMWV-/Lkw-Gruppe;
- Wiederaufschließen nach Bremsmanövern;
- Pack/Unpack;
- Länge des benötigten Unpack-Korridors;
- Verhalten unter Beschuss.

Optionaler zusätzlicher Grenztest:

```text
75–100 m
```

### Schritt 4 – statisches Zwei-Profil-Modell

```text
URBAN:
Speed:    25–30 km/h
Interval: 20 m

RURAL:
Speed:    40–45 km/h
Interval: 60 m
```

Grenzen autorenseitig definieren und beim Missionsstart auf Routendistanzen abbilden.

### Schritt 5 – spätere Erweiterungen

Erst nach den obigen Nachweisen:

- weitere Profiltypen wie Berg-/Schlechtstrecke;
- gescripteter `hostile intent`;
- zeitweises `OPEN_FIRE` gegen bestätigte Angreifer;
- Recovery-/Security-Zustände bei Mobilitätsausfall;
- operative Spieler-/Feindrelevanz;
- Sichtlinie und Sensorik, sofern Kosten und Nutzen dies rechtfertigen.

## 17. Festgehaltene Nicht-Ziele

Nicht vorgesehen:

- permanente Gebäudeerkennung pro Konvoi;
- ständiges Neusetzen der Route;
- automatisches Teleportieren oder Entwirren nach bestätigter Aktivierung;
- ungeprüfte Übernahme kleiner 500-/750-m-Testwerte in die Produktion;
- Gleichsetzung einer DCS-Option mit einer realen SOP;
- pauschales `OPEN_FIRE` in einer COIN-Umgebung;
- pauschales „immer durchbrechen“ ohne Schadens- und Routenbewertung;
- stilles Wiederherstellen zerstörter Fahrzeuge.

## 18. Offene Designfragen

Vor Produktionsfreigabe noch zu beantworten:

1. Hält DCS `Formation Interval` mit gemischten Fahrzeugtypen stabil genug?
2. Beeinflusst `ALARM_STATE = RED` die Routenannahme oder Geschwindigkeit negativ?
3. Wie verhält sich `RETURN_FIRE` gegen verschiedene Hinterhaltsarten?
4. Wie lang muss der freie rückwärtige Straßenkorridor bei 60, 75 oder 100 m Intervall sein?
5. Soll ein Profilwechsel im expandierten Zustand sofort das Intervall ändern oder erst an einer sicheren Übergangsposition?
6. Wie wird ein Mobilitätsausfall erkannt, ohne eine ungewollte automatische Recovery einzuführen?
7. Wie werden spätere operative Relevanzradien bestimmt?
8. Welche Feindkontakte zählen als bestätigter `hostile act` oder gescripteter `hostile intent`?
9. Welche Profilwerte sind auf der konkreten Bagram–Jalalabad-Route mit DCS-AI nachhaltig stabil?

## 19. Quellen- und Dokumentregister

Projektinterne Grundlagen:

- `mission/tests/tm01-blue-convoy/notes/2026-07-16-tm01c-dcs-findings.md`
- `mission/tests/tm01-blue-convoy/results/2026-07-16-tm01c-manual-cycle-heading-pass.md`
- `mission/tests/tm01-blue-convoy/notes/2026-07-16-afghanistan-convoy-tactics-and-dcs-mapping.md`
- `mission/tests/tm01-blue-convoy/notes/2026-07-16-adaptive-convoy-profile-feasibility.md`
- `mission/tests/tm01-blue-convoy/expected/proxy-pack-unpack-acceptance.md`

Offizielle und primäre Referenzen, wie in der Recherche verwendet:

- ALSSA, Multi-Service Tactics, Techniques, and Procedures for Tactical Convoy Operations: https://www.alssa.mil/mttps/tco/
- U.S. Army Sustainment Resource Portal, Tactical Convoy Operations: https://cascom.army.mil/asrp/tng-relocate.html
- U.S. Army, Train as we fight: Using sustainment vehicles for convoy protection: https://www.army.mil/article/125012/train_as_we_fight_using_sustainment_vehicles_for_convoy_protection
- U.S. Army, Tactical Leader Lessons Learned in Afghanistan: Operation Enduring Freedom VIII: https://www.army.mil/article/26874/tactical_leader_lessons_learned_in_afghanistan_operation_enduring_freedom_viii
- NATO/ISAF civilian-protection and tactical-directive context: https://www.nato.int/en/news-and-events/events/transcripts/2009/01/14/weekly-press-briefing
- Eagle Dynamics, DCS Scripting Engine Controller/Behavior options: https://www.digitalcombatsimulator.com/en/support/faq/1267/
- Eagle Dynamics, DCS Scripting Engine SceneryObject: https://www.digitalcombatsimulator.com/en/support/faq/1265/
- MOOSE documentation for Group/Controllable options, ground routing and zones; every concrete use must be verified against pinned MOOSE 2.9.18.

## 20. Kanonische Entscheidung

Für OMW gilt ab diesem Stand:

```text
1. Der manuelle Pack-/Unpack-Kern ist ausreichend stabil für die nächste Automatikstufe.
2. Der nächste Test verwendet 500 m Unpack, 750 m Pack-Grenze und 30 s Abwesenheit.
3. Geschwindigkeit und Spawnabstand bleiben dabei zunächst 30 km/h und 15 m.
4. BLUE-Konvois sollen langfristig RED, RETURN_FIRE und DISPERSE_OFF verwenden.
5. Geschwindigkeit wird später pro Routensegment in Waypoints vorkodiert.
6. Formation Interval wird nur beim Spawn und bei tatsächlichen Profilwechseln gesetzt.
7. Stadt/Dorf/Überland wird nicht per laufendem Gebäudescan erkannt.
8. Produktionsprofile werden autorenseitig klassifiziert und beim Missionsstart kompiliert.
9. CampaignState bleibt Autorität für Profil, Repräsentation, Survivor, Lead und Schaden.
10. Kein permanentes Re-Routing, kein automatisches Teleportieren und keine stille Recovery.
```

Jede Abweichung von diesen Entscheidungen muss in einem neuen datierten Eintrag mit Begründung, Codeänderung, DCS-Retest und Abnahmestatus dokumentiert werden.
