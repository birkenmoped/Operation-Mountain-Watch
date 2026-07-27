# Combat Search and Rescue - quellenbasierte Anforderungen an die Missionsgestaltung

## 1. Abgrenzung

Dieses Dokument leitet Anforderungen ausschließlich aus der achtteiligen CSAR-Serie von **Graveyard of Empires** und der zugehörigen CombatFlite-Auswertung ab. Es beschreibt noch keine konkrete Lua- oder MOOSE-Implementierung.

## 2. PR statt einer einzigen CSAR-Spielmechanik

Die Mission muss mehrere Recovery-Arten unterscheiden:

| Recovery-Art | Einsatzkriterium aus der Quelle | Konsequenz für OMW |
|---|---|---|
| SAR | keine aktive feindliche Einwirkung erwartet | keine automatisch identische Bedrohungs- und Escortlogik wie CSAR |
| CSAR | feindliche Umgebung, ausgebildetes und ausgerüstetes IP, dedizierte Kräfte und Verfahren | vollständiger vorbereiteter Recovery-Ablauf |
| CR | feindliche Umgebung, aber keine dedizierten CSAR-Kräfte beziehungsweise kein vorbereitetes IP | improvisierter, risikoreicherer Auftrag mit verfügbaren Kräften |
| NAR | verdeckte oder politisch sensitive Recovery | nicht mit regulärem CSAR-Auftrag gleichsetzen; eigener späterer Scope |

Eine Ejection erzeugt daher nicht automatisch immer denselben Missionstyp.

## 3. Isolated-Personnel-Zustand und Vorbereitung

Für ein CSAR-fähiges IP müssen als Missionsdaten mindestens abbildbar sein:

- HIRE-/Risikostatus,
- ISOPREP vorhanden oder nicht,
- Authentifizierungsfähigkeit,
- Duress-Status,
- EPA beziehungsweise geplante Evasion- und Kommunikationsregeln,
- verfügbare Überlebensausrüstung,
- Funk-/Beacon-/PLS-Fähigkeit,
- Verletzungszustand,
- letzter bekannter Punkt und aktuelle beziehungsweise geschätzte Position.

Fehlen Ausbildung oder Ausrüstung, muss die Mission dies als CR-Risiko behandeln und darf nicht so tun, als läge eine vollständig vorbereitete CSAR-Lage vor.

## 4. Kommunikation und Authentifizierung

Die Quelle verlangt eine Trennung zwischen bloßer Positionsmeldung und bestätigter Identität.

OMW benötigt deshalb konzeptionell:

1. Detection beziehungsweise Location über Beacon, Funk, ISR oder andere Meldung,
2. Kontaktaufnahme,
3. Authentifizierung über ISOPREP-bezogene Informationen,
4. Erkennung eines möglichen Duress-Hinweises,
5. erst danach Freigabe weiterer Recovery-Schritte.

Ein einfacher Beacon-Treffer darf nicht automatisch als vollständige Identifizierung gelten.

## 5. C2- und Unterstützungselemente

Eine CSAR-Lage kann nach Quelle folgende Rollen erfordern:

- JPRC/PRCC beziehungsweise koordinierende Zelle,
- Rescue Mission Commander,
- On Scene Commander,
- Extraction Force,
- PJs beziehungsweise Guardian Angel Team,
- RESCAP,
- RESCORT,
- ISR/UAV,
- SOF oder andere Kräfte zur Sicherung von LZ/PUZ,
- medizinische Aufnahme und gegebenenfalls STRATEVAC.

Nicht jede Mission benötigt alle Rollen. Der Umfang muss sich aus Bedrohung, Entfernung, Gelände, IP-Status und verfügbaren Kräften ergeben.

## 6. Afghanistan-spezifische Machbarkeit

### 6.1 Gelände- und Höhenprüfung

Die Quelle verwendet als Planungsmodell:

- über 8.000 ft: nur besonders leistungsfähige Hubschrauber und begrenzte Nutzlast,
- über 10.000 ft: keine Hubschrauber-Combat-Operation; luftabgesetztes Team und spätere Aufnahme tiefer.

OMW muss diese Werte als **quellenbasierte Planungsgrenzen** behandeln. Sie dürfen nicht ungeprüft als exakte Leistungsdaten jedes DCS-Musters umgesetzt werden.

### 6.2 Hot-and-high

Vor Dispatch sind mindestens zu berücksichtigen:

- Höhe der Pickup-Zone,
- Temperatur,
- Masse/Nutzlast,
- erforderlicher OGE-/IGE-Hover,
- Treibstoff für Hinflug, Station, Rückflug und Reserve,
- mögliche Gewichtsreduktion und deren Auswirkungen,
- verfügbare Landefläche oder Hoist-Bedarf.

### 6.3 Wetter und Sicht

Die Quelle nennt Brownout, Staub, Schnee, Eis, starke Winde und schnelle Wetterwechsel. Diese Faktoren müssen die Einsatzfreigabe, Landeart und Erfolgswahrscheinlichkeit beeinflussen.

## 7. Bedrohungs- und Sicherungslogik

Als besondere Gefahren nennt die Quelle Handwaffen, MANPADS, Hinterhalte und hohe Verwundbarkeit bei Start und Landung.

Daraus folgen für OMW:

- Bedrohungsprüfung vor Einsatz eines Recovery-Hubschraubers,
- ISR-Aufklärung vor Einflug,
- Escort beziehungsweise RESCAP/RESCORT je nach Lage,
- mögliche SOF-/Bodensicherung der Pickup-Zone,
- Abbruch-, Holding- oder Ausweichentscheidung bei unvertretbarer Bedrohung,
- keine automatische Landung allein aufgrund geometrischer Erreichbarkeit.

## 8. Dedicated CSAR, CASEVAC und Combat Recovery

Für das Basing-Beispiel 2010 nennt die Quelle nur **Bagram und Kandahar** als dedizierte HH-60G-CSAR-Standorte.

Andere verteilte Hubschrauber sind als CASEVAC- beziehungsweise mögliche CR-Kräfte zu behandeln, nicht automatisch als gleichwertige CSAR-Einheiten.

Das bedeutet für OMW:

- Capability-Flag pro Asset,
- getrennte Einsatzregeln für `DEDICATED_CSAR`, `CASEVAC` und `COMBAT_RECOVERY`,
- unterschiedliche Besatzung, Ausrüstung, Authentifizierungs- und Escortanforderungen,
- Möglichkeit der Vorverlegung eines dedizierten CSAR-Assets,
- keine Gleichsetzung von Nähe mit Eignung.

## 9. Medical Support und Abschluss einer Recovery

Der Pickup allein beendet die PR-Kette nicht. Die Quelle verbindet Recovery mit medizinischer Versorgung und Reintegration.

OMW muss mindestens unterscheiden:

- Role 1 - frontnahe Erstversorgung und Stabilisierung,
- Role 2 - Trauma-/chirurgische Stabilisierung auf größerem FOB,
- Role 3 - umfassende Versorgung im Einsatzgebiet,
- STRATEVAC - strategischer Weitertransport aus dem Einsatzgebiet,
- Reintegration eines nicht oder nur leicht verletzten IP.

Die Zielwahl muss vom Verletzungszustand und der verfügbaren Einrichtung abhängen. Für das 2010-Beispiel sind Bagram und Kandahar als Role-3-Knoten genannt; Camp Bastion wird als Role 2 mit späterem Upgrade erwähnt.

## 10. Zeitliche Anforderungen

Die Quelle beschreibt die 10-1-2-Regel:

- 10 Minuten bis zu lebensrettenden Maßnahmen,
- 1 Stunde bis zur Reanimation/Resuscitation,
- 2 Stunden bis zur vollständigen Behandlung.

Für OMW sollte dies als medizinischer Zeitdruck und Priorisierungsgrundlage modelliert werden. Es handelt sich nicht automatisch um drei starre globale Missionstimer; die konkrete technische Umsetzung ist separat zu bestimmen.

## 11. Reichweiten- und Basingmodell

Die Combat-Radii-Karte in Teil 8 ist eine Planungsdarstellung. Die Radien:

- sind angenähert,
- berücksichtigen Höhe und Temperatur,
- setzen keine Luftbetankung voraus,
- enthalten 30 Minuten On-Station-Zeit.

Da die Einheit der XML-Radiuswerte nicht ausdrücklich belegt ist, dürfen die Zahlen nicht als harte Laufzeitgrenze in NM, km oder Metern implementiert werden, bevor die Original-`.cf`-Datei oder eine andere eindeutige Quelle vorliegt.

## 12. Lokale Bevölkerung

Die Quelle beschreibt sowohl mögliche Unterstützung durch die Bevölkerung als auch Sprach-, Kultur-, Dialekt- und Vertrauensprobleme.

Für spätere OMW-Erweiterungen sind daher möglich:

- Hilfe durch lokale Akteure,
- verzögerte oder fehlerhafte Information,
- Risiko von Taliban-Repressalien,
- Einsatz von Blood Chit oder Pointee-Talkee als abstrahierte Interaktionsmittel.

Diese Funktionen sind optional und dürfen nicht ohne eigenes Design automatisch aus einer Ejection entstehen.

## 13. Sonderverfahren

Die Quelle nennt:

- Hoist-Recovery,
- luftabgesetzte Rettungsteams,
- Hochgebirgs-Fallschirmsprung mit Sauerstoff,
- spätere Aufnahme in tieferem Gelände,
- improvisierte beziehungsweise doktrinierte Außenrettung an Kampfhubschraubern wie IMEX.

Diese Verfahren bilden getrennte spätere Missionsarten. Sie dürfen nicht als Standardverhalten jedes Hubschraubers angenommen werden.

## 14. Technische Folgeschritte nach MOOSE-First

Erst nach Freigabe dieser fachlichen Anforderungen ist zu prüfen:

1. welche Funktionen `MOOSE CSAR` bereits abbildet,
2. welche Funktionen `AICSAR` oder andere MOOSE-Klassen bereitstellen,
3. wie Pickup, Beacon, MASH/FARP und Spielerinteraktion im tatsächlich geladenen MOOSE-Stand funktionieren,
4. welche Anforderungen durch MOOSE nicht abgedeckt werden,
5. welche projektseitigen Adapter für CampaignState, medizinische Kette und Capability-Trennung tatsächlich notwendig sind.

Ohne diese Prüfung wird keine eigene CSAR-Laufzeitfunktion entwickelt.
