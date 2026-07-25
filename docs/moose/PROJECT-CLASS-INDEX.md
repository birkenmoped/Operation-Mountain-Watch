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
| `Ops.Auftrag` | `AUFTRAG` | `IN_USE_PARTIAL` | Missionstypen und Capabilities für RECON, CAS, Transport, Landung und Escort | Capability-/Payload-Konfiguration validiert; taktische Auftragserzeugung offen |
| `Ops.Commander` | `COMMANDER` | `VALIDATED` für Grundstart | Blue Commander erstellen, AIRWING anbinden und ohne spontane Missionen starten | Jalalabad Complete Node PASS |
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
| `Ops.FlightGroup` | `FLIGHTGROUP` | `PLANNED` | Laufzeitsteuerung gebundener Hubschrauber und Fluggruppen, Optionen, Missions- und Transportereignisse | Signaturen, Bindung durch AIRWING und FSM-Callbacks prüfen |
| `Ops.OpsTransport` | `OPSTRANSPORT` | `PLANNED` | Truppen- und Frachttransporte zwischen Lade- und Entladezonen | Carrier-/Cargo-Modell und Failure-/Success-Zustände in DCS validieren |
| `Ops.ArmyGroup` | `ARMYGROUP` | `PLANNED` | Laufzeitsteuerung von Bodengruppen, insbesondere transportierbarer oder entpackter Gruppen | Verhalten bei Transport, Feindkontakt, Route und Festfahren prüfen |
| `Ops.Brigade` | `BRIGADE` | `PLANNED` | Bestands- und Einsatzmanager größerer Bodeneinheiten | Zusammenspiel mit CampaignState und COMMANDER klären |
| `Ops.CTLD` | `CTLD` | `PLANNED` | Spielerlogistik, Truppen und Fracht | Abgrenzung zu OPSTRANSPORT und CampaignState festlegen |
| `Ops.CSAR` | `CSAR` | `PLANNED` | CSAR-Spielmechanik und Rettungsaufträge | Abgrenzung zu MEDEVAC und Persistenz festlegen |
| `Functional.Rat` | `RAT` | `PLANNED` | Ausschließlich nicht persistenter, atmosphärischer Hintergrundverkehr | Kein Ressourcen- oder Bestandsübergang; Spawnlimits testen |
| `Core.Event` | `EVENT` | `PLANNED` | Zentrale Reaktion auf Birth, Dead, Crash, Land, Takeoff und weitere DCS-Ereignisse | Eventdaten und Mehrfachmeldungen versionsbezogen testen |
| `Core.Set` | `SET_GROUP`, weitere Sets | `PLANNED` | Dynamische Mengen von Gruppen, Zonen oder Objekten | Filter, Aktualisierung und Performance prüfen |
| `Core.Spawn` | `SPAWN` | `PLANNED` | Dynamisches Erzeugen projektgesteuerter Gruppen, soweit AIRWING/BRIGADE dies nicht übernehmen | Vor Nutzung prüfen, ob OPS-/Warehouse-Assets geeigneter sind |

## 5. Kandidaten für spätere Architekturentscheidungen

| Modul / Klasse | Global | Status | Möglicher Nutzen | Noch offene Entscheidung |
|---|---|---|---|---|
| `Ops.Intel` | `INTEL` | `CANDIDATE` | Gemeinsames Lagebild und Zielerkennung | Abgrenzung zum eigenen `RedDirector` und CampaignState |
| `Ops.OpsZone` | `OPSZONE` | `CANDIDATE` | Operative Zonen mit Besitz- und Zustandslogik | Prüfen, ob die Kampagnenzonen damit vollständig abbildbar sind |
| `Ops.Target` | `TARGET` | `CANDIDATE` | Standardisierte Ziele für AUFTRAG und Operationen | Abgleich mit eigenem Missionsgenerator und Zielmodell |
| `Ops.Operation` | `OPERATION` | `CANDIDATE` | Mehrstufige operative Abläufe | Nutzen gegenüber projektgesteuerten Kampagnenphasen prüfen |
| `Core.Menu` | Menüklassen | `CANDIDATE` | Spieleranforderungen und Missionssteuerung | Bedienkonzept und Multiplayer-Rechte festlegen |
| `Core.Message` | `MESSAGE` | `CANDIDATE` | Standardisierte Spielerinformationen | Ausgabe- und Lokalisierungskonzept festlegen |

Kandidaten dürfen nicht ohne den verbindlichen Rechercheweg als Architekturstandard übernommen werden.

## 6. Bewusst derzeit nicht verwendet

| Modul / Klasse | Status | Entscheidung |
|---|---|---|
| `Ops.Chief` | `NOT_USED` | Zielauswahl, Kampagnenlogik und Auftragserzeugung bleiben zunächst bei `CampaignState`, `MissionGenerator`, `RedDirector` und deren Adaptern. |
| `Ops.Fleet` / `Ops.NavyGroup` | `NOT_USED` | Der aktuelle Afghanistan-Kampagnenumfang enthält keine operative Seestreitkraft. |
| `Ops.Airboss` | `NOT_USED` | Keine Trägeroperationen im aktuellen Kampagnenscope. |

## 7. Direkte DCS-API-Nutzung

Direkte DCS-API-Aufrufe sind keine MOOSE-Module und werden deshalb getrennt betrachtet.

Aktuell bekannte Fälle:

| API | Verwendung | Bewertung |
|---|---|---|
| `timer.scheduleFunction` | Fallback, falls `SCHEDULER` beim Laden nicht verfügbar ist | Nur als dokumentierter Fallback zulässig |
| `env.info` | Projektlogging | Zulässig; MOOSE-Logging kann ergänzend geprüft werden |
| `coalition.side.BLUE` | Konstruktorparameter für `COMMANDER` | DCS-Konstante, von MOOSE erwartet |
| `AI.Skill.HIGH` | Skill-Konfiguration von SQUADRONs | DCS-Konstante, über MOOSE-Methode gesetzt |

## 8. Aktualisierungsregel

Bei jeder neuen MOOSE-basierten Implementierung ist dieser Index im selben Commit oder Pull Request zu aktualisieren.

Ein Statuswechsel auf `VALIDATED` erfordert:

1. dokumentierten MOOSE-Stand,
2. konkreten OMW-Quellpfad,
3. reproduzierbaren DCS-Test,
4. Ergebnisbericht,
5. Eintrag in [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md).