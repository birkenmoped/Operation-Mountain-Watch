# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index erfasst alle MOOSE-Klassen und Module, die für **Operation Mountain Watch**:

- nachweislich verwendet werden,
- bereits teilweise verwendet werden,
- verbindlich geplant sind,
- als Kandidaten geprüft werden sollen,
- bewusst nicht eingesetzt werden,
- nur als interner Diagnosezugriff zulässig sind.

Die Statusdefinitionen stehen in [`README.md`](README.md).

## 2. Aktuell nachgewiesen oder verwendet

| Modul / Klasse | Global | Status | Verwendung in OMW | Nachweis |
|---|---|---|---|---|
| `Wrapper.Airbase` | `AIRBASE` | `VALIDATED` | Jalalabad suchen, Name und ID prüfen, Parking-Blacklist setzen | Jalalabad Complete Node PASS |
| `Ops.Airwing` | `AIRWING` | `VALIDATED` | Lokaler Ressourcen- und Einsatzmanager für Jalalabad; Airbase-Zuordnung, Parking-Schutz, Squadrons und Payloads | Jalalabad Complete Node PASS |
| `Ops.Squadron` | `SQUADRON` | `VALIDATED` | Vier typgebundene Jalalabad-Bestände mit Gruppierung, Skill und Mission Capabilities | Jalalabad Complete Node PASS |
| `Functional.Warehouse` | `WAREHOUSE` | `VALIDATED` über `AIRWING` | Warehouse-Funktion und physische Ressourcenbasis des AIRWING | Log bestätigt gestartetes `WAREHOUSE / AIRWING` |
| `Ops.Auftrag` | `AUFTRAG` | `IN_USE_PARTIAL` | Missionstypen und Capabilities für RECON, CAS, Transport, Landung und Escort; künftig FAC, FACA, CAS-Bereitschaft und Strike | Capability-/Payload-Konfiguration validiert; taktische Auftragserzeugung offen |
| `Ops.Commander` | `COMMANDER` | `VALIDATED` für Grundstart | Blue Commander erstellen, AIRWING anbinden und ohne spontane Missionen starten; künftig Asset-Auswahl und Eskalation | Jalalabad Complete Node PASS |
| `Core.Scheduler` | `SCHEDULER` | `VALIDATED` | Verzögerte, geordnete Konstruktion und Validierung der Jalalabad-Komponenten | Jalalabad-Bundle ohne relevanten Timerfehler |
| `Wrapper.Group` | `GROUP` | `VALIDATED` | Late-Activation-Templates finden und Einheiten prüfen; Payloadvorlagen an AIRWING übergeben | Squadron-Konstruktion und Payloadregistrierung bestanden |
| `Wrapper.Unit` | `UNIT` | `VALIDATED` | Typnamen und Namen von Template-Einheiten prüfen; optionaler Warehouse-Anker | Jalalabad-Validatoren bestanden |
| `Wrapper.Static` | `STATIC` | `VALIDATED` | Warehouse-Anker und sichtbare Luftfahrzeug-Statics finden und validieren | 20/20 Statics und Warehouse-Anker bestätigt |
| `Core.Zone` | `ZONE` | `VALIDATED` | Benannte Mission-Editor-Zonen finden und Vollständigkeit prüfen | 11/11 Zonen bestätigt |
| MOOSE Template Database | `_DATABASE` | `INTERNAL_RESTRICTED` | Unbesetzte Client- und Late-Activation-Gruppen in der Template-Datenbank validieren | Nur für Diagnose/Validierung; keine allgemeine Produktions-API |

## 3. Implizit verwendete Basisklassen

Die folgenden MOOSE-Klassen werden durch die oben genannten OPS-Klassen geerbt oder intern verwendet. Sie sind für Architektur- und Eventanalysen relevant, werden im aktuellen OMW-Code aber nicht direkt konstruiert.

| Modul / Klasse | Status | Bedeutung für OMW |
|---|---|---|
| `Core.Base` | `IN_USE_PARTIAL` | Gemeinsame Basisklasse und Logging-/Scheduling-Funktionen vieler MOOSE-Klassen |
| `Core.Fsm` | `IN_USE_PARTIAL` | Zustandsautomaten von AIRWING, COMMANDER, AUFTRAG und weiteren OPS-Klassen |
| `Ops.Legion` | `IN_USE_PARTIAL` | Gemeinsame Legion-Basis von AIRWING, BRIGADE und FLEET |
| `Ops.Cohort` | `IN_USE_PARTIAL` | Gemeinsame Bestandsbasis von SQUADRON, PLATOON und FLOTILLA |

Diese Einträge gelten nicht automatisch als praktisch vollständig validiert. Validiert sind nur die konkret beobachteten Laufzeitpfade der abgeleiteten Klassen.

## 4. Verbindlich geplante Klassen

| Modul / Klasse | Global | Status | Geplanter Einsatz | Voraussetzung vor Implementierung |
|---|---|---|---|---|
| `Ops.FlightGroup` | `FLIGHTGROUP` | `PLANNED` | Laufzeitsteuerung gebundener Hubschrauber und Fluggruppen; CAS-Station, Fuel-, Munitions-, Refuelling- und RTB-Logik | Signaturen, Bindung durch AIRWING, Fuel-/Ammo-Methoden und FSM-Callbacks prüfen |
| `Core.Point` | `COORDINATE` | `PLANNED` | Afghanistan-NSL-Punkte aus WGS84 mit `NewFromLLDD()` in DCS-Koordinaten überführen; Distanz- und Prüfberichte erzeugen | Signatur im eingebundenen MOOSE-Stand, Afghanistan-Kartenkonvertierung und Landhöhenverhalten testen |
| `Core.Zone` | `ZONE_RADIUS`, `ZONE_POLYGON_BASE` | `PLANNED` | NSL-Schutzgeometrien und zentrale Prüfung von Zielkoordinaten über `IsCoordinateInZone()` beziehungsweise `IsVec2InZone()` | Konstruktoren, Randverhalten, Polygonquelle, Registrierungsstrategie und Performance mit großem Datenbestand testen |
| `Ops.Intel` | `INTEL` | `PLANNED` | Gemeinsames taktisches Lagebild für UAVs, Bodensensoren und erkannte Kontakte/Cluster | Kontaktmodell, Events, Timeout und Abgrenzung zu CampaignState/RedDirector prüfen |
| `Ops.Target` | `TARGET` | `PLANNED` | Standardisierte Ziele für Spieler-, AI-, FAC-, CAS- und Strike-Aufträge | Zieltypen, Zustände, BDA und Bindung an AUFTRAG prüfen |
| Player-Task-System | `PLAYERTASKCONTROLLER` und zugehörige Klassen | `PLANNED` | Spieleraufträge aus Gruppe, Einheit, Zone, Koordinate oder Suchgebiet; Annahme und AI-Eskalation | Exakte Klassen, Signaturen, Multiplayer-Verhalten und Menürechte prüfen |
| `Functional.Designate` | `DESIGNATE` | `PLANNED` | Laser-, Rauch-, Beleuchtungs- und Zielmarkierungsdienst für UAV, AFAC und JTAC | Zusammenspiel mit INTEL, Detection, Spielergruppen und aktuellem MOOSE-Stand prüfen |
| Detection-Klassen | `DETECTION_*` | `PLANNED` | Sensorerkennung für DESIGNATE und gegebenenfalls ergänzend zu INTEL | Geeignete Detection-Klasse, Sichtlinie, Reichweite und Performance festlegen |
| `Ops.OpsTransport` | `OPSTRANSPORT` | `PLANNED` | Truppen- und Frachttransporte zwischen Lade- und Entladezonen | Carrier-/Cargo-Modell und Failure-/Success-Zustände in DCS validieren |
| `Ops.ArmyGroup` | `ARMYGROUP` | `PLANNED` | Laufzeitsteuerung von Bodengruppen, insbesondere transportierbarer oder entpackter Gruppen und JTAC-Patrouillen | Verhalten bei Transport, Feindkontakt, Route, Markierung und Festfahren prüfen |
| `Ops.Brigade` | `BRIGADE` | `PLANNED` | Bestands- und Einsatzmanager größerer Bodeneinheiten | Zusammenspiel mit CampaignState und COMMANDER klären |
| `Ops.CTLD` | `CTLD` | `PLANNED` | Spielerlogistik, Truppen und Fracht | Abgrenzung zu OPSTRANSPORT und CampaignState festlegen |
| `Ops.CSAR` | `CSAR` | `PLANNED` | CSAR-Spielmechanik und Rettungsaufträge | Abgrenzung zu MEDEVAC und Persistenz festlegen |
| `Functional.Rat` | `RAT` | `PLANNED` | Ausschließlich nicht persistenter, atmosphärischer Hintergrundverkehr | Kein Ressourcen- oder Bestandsübergang; Spawnlimits testen |
| `Core.Event` | `EVENT` | `PLANNED` | Zentrale Reaktion auf Birth, Dead, Crash, Land, Takeoff, Treffer, Zielverluste und BDA | Eventdaten und Mehrfachmeldungen versionsbezogen testen |
| `Core.Set` | `SET_GROUP`, `SET_ZONE`, weitere Sets | `PLANNED` | Dynamische Mengen von Sensor-, Markierer-, Spieler-, Ziel- und gegebenenfalls Schutzgebietszonen | Filter, Aktualisierung, Registrierungsstrategie und Performance prüfen |
| `Core.Spawn` | `SPAWN` | `PLANNED` | Dynamisches Erzeugen projektgesteuerter Gruppen, soweit AIRWING/BRIGADE dies nicht übernehmen | Vor Nutzung prüfen, ob OPS-/Warehouse-Assets geeigneter sind |
| `Core.Menu` | Menüklassen | `PLANNED` | Spieler-Kontaktmeldungen, Unterstützungsanforderungen und Markierungssteuerung | Bedienkonzept, Rechte und Mehrspieler-Sichtbarkeit festlegen |
| `Core.Message` | `MESSAGE` | `PLANNED` | Kontaktberichte, Aufgabenbriefings, Laser-Codes, Status- und BDA-Meldungen | Ausgabe-, Frequenz- und Lokalisierungskonzept festlegen |

## 5. Geplante AUFTRAG-Funktionen für ISR, FAC, CAS und Strike

| Funktion / Missionstyp | Status | Geplanter Zweck | Vor DCS-Einsatz zu prüfen |
|---|---|---|---|
| `AUFTRAG:NewRECON()` | `PLANNED` | ISR- und UAV-Aufklärungsmissionen | Zonen, Sensorverhalten, Dauer und Abschluss |
| `AUFTRAG:NewFAC()` | `PLANNED` | gebietsbezogene FAC-Mission für UAV oder anderes Asset | Signatur, Luft-/Bodenfähigkeit, Funk und Zielerkennung |
| `AUFTRAG:NewFACA()` | `PLANNED` | FAC(A) gegen konkrete bestätigte Zielgruppe | Zieltyp, Designation, Datalink, Funk und Missionsende |
| `AUFTRAG:NewCAS()` | `PLANNED` | CAS-Orbit und Bereitschaft in einem Einsatzraum | Reaktion auf Ziele, Rückkehr zum Orbit, RTB und Abschluss |
| `AUFTRAG:NewCASENHANCED()` | `PLANNED` | patrouillierende CAS-Bereitschaft mit eigener Erkennung | Suchradius, No-Engage-Zonen, Zieltypen und Wiederaufnahme |
| BAI-Auftrag | `PLANNED` | Bekämpfung bestätigter Bodenkräfte außerhalb unmittelbarer TIC-Lage | Zielbindung, Angriffswiederholung und Abschluss |
| BOMBING-Auftrag | `PLANNED` | geplanter Angriff auf Gruppe oder Camp | Waffenprofil, Zielwirkung und Rückkehr |
| PRECISIONBOMBING-Auftrag | `PLANNED` | präziser Angriff bei bestätigtem Ziel | geeignete Payload, Zieltyp, Laser-/Koordinatenverwendung |
| AUTO-Auftrag | `PLANNED` | automatische Wahl eines geeigneten Angriffsprofils, falls im MOOSE-Stand geeignet | Verhalten und Kontrollierbarkeit gegen feste Auftragstypen vergleichen |

## 6. Afghanistan-NSL und Zielschutz

Die verbindliche Datenanalyse, Schutzlogik und MOOSE-Planung steht in:

- [`Afghanistan No-Strike List (NSL)`](../28-no-strike-list-afghanistan.md)

Für alle offensiven Auftragstypen gilt: Erkennung oder feindliche Koalitionszugehörigkeit ersetzt keine positive NSL-Prüfung. Die konkreten Methoden gelten erst nach Quellcodeprüfung und DCS-Test als `VALIDATED`.

## 7. Kandidaten für spätere Architekturentscheidungen

| Modul / Klasse | Global | Status | Möglicher Nutzen | Noch offene Entscheidung |
|---|---|---|---|---|
| `Ops.OpsZone` | `OPSZONE` | `CANDIDATE` | Operative Zonen mit Besitz- und Zustandslogik | Prüfen, ob die Kampagnenzonen damit vollständig abbildbar sind |
| `Ops.Operation` | `OPERATION` | `CANDIDATE` | Mehrstufige operative Abläufe | Nutzen gegenüber projektgesteuerten Kampagnenphasen prüfen |

Kandidaten dürfen nicht ohne den verbindlichen Rechercheweg als Architekturstandard übernommen werden.

## 8. Bewusst derzeit nicht verwendet

| Modul / Klasse | Status | Entscheidung |
|---|---|---|
| `Ops.Chief` | `NOT_USED` | Zielauswahl, Kampagnenlogik und Auftragserzeugung bleiben zunächst bei `CampaignState`, `MissionGenerator`, `RedDirector` und deren Adaptern. |
| `Ops.Fleet` / `Ops.NavyGroup` | `NOT_USED` | Der aktuelle Afghanistan-Kampagnenumfang enthält keine operative Seestreitkraft. |
| `Ops.Airboss` | `NOT_USED` | Keine Trägeroperationen im aktuellen Kampagnenscope. |

## 9. Direkte DCS-API-Nutzung

Direkte DCS-API-Aufrufe sind keine MOOSE-Module und werden deshalb getrennt betrachtet.

Aktuell bekannte Fälle:

| API | Verwendung | Bewertung |
|---|---|---|
| `timer.scheduleFunction` | Fallback, falls `SCHEDULER` beim Laden nicht verfügbar ist | Nur als dokumentierter Fallback zulässig |
| `env.info` | Projektlogging | Zulässig; MOOSE-Logging kann ergänzend geprüft werden |
| `coalition.side.BLUE` | Konstruktorparameter für `COMMANDER` | DCS-Konstante, von MOOSE erwartet |
| `AI.Skill.HIGH` | Skill-Konfiguration von SQUADRONs | DCS-Konstante, über MOOSE-Methode gesetzt |

## 10. Zugehörige Architektur

Die verbindliche Ausarbeitung für ISR, FAC, AFAC, JTAC, CAS, UAV, BDA und AAR steht in:

- [`ISR-FAC-CAS-AAR.md`](ISR-FAC-CAS-AAR.md)

Die verbindliche Ausarbeitung für No-Strike- und Zielschutz steht in:

- [`Afghanistan No-Strike List (NSL)`](../28-no-strike-list-afghanistan.md)

## 11. Aktualisierungsregel

Bei jeder neuen MOOSE-basierten Implementierung ist dieser Index im selben Commit oder Pull Request zu aktualisieren.

Ein Statuswechsel auf `VALIDATED` erfordert:

1. dokumentierten MOOSE-Stand,
2. konkreten OMW-Quellpfad,
3. reproduzierbaren DCS-Test,
4. Ergebnisbericht,
5. Eintrag in [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md).
