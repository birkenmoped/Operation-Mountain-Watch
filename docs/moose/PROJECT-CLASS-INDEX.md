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
| `Ops.Auftrag` | `AUFTRAG` | `IN_USE_PARTIAL` | Missionstypen und Capabilities für RECON, CAS, Slingload-Transport, Landung und Escort. `NewCARGOTRANSPORT` bleibt die native Autorität; ein dünner Adapter bindet wegen eines im gepinnten und aktuellen Develop-Quellstand bestätigten Verschachtelungsfehlers `groupId`/`zoneId` an die innere DCS-`CargoTransportation`-Task. | UH-60-PASS; CH-47-Fehllauf und Quellursache dokumentiert; korrigierter CH-47-DCS-Lauf offen |
| `Ops.FlightGroup` | `FLIGHTGROUP` | `IN_USE_PARTIAL` | Gebundene UH-60-/CH-47-Laufzeitgruppe, Vertikaloption, RTB-, Lande- und Terminalereignisse | UH-60-End-to-End-PASS; CH-47-Verlustpfad beobachtet |
| `Ops.OpsTransport` | `OPSTRANSPORT` | `IN_USE_PARTIAL` | UH-60-Truppentransport mit getrennten Pickup-/Embark- und Deploy-/Disembark-Zonen | UH-60-End-to-End-PASS; weitere Transportvarianten offen |
| `Core.Scheduler` | `SCHEDULER` | `VALIDATED` | Verzögerte, geordnete Konstruktion und Validierung der Jalalabad-Komponenten | Jalalabad-Bundle ohne relevanten Timerfehler |
| `Core.Spawn` | `SPAWN` | `IN_USE_PARTIAL` | CAS-Ziel und transportierbare Infanterie aus Mission-Editor-Templates erzeugen | Runtime-Spawns beobachtet; gesamter Phase-1-Ablauf offen |
| `Wrapper.Group` | `GROUP` | `VALIDATED` | Late-Activation-Templates finden und Einheiten prüfen; Payloadvorlagen an AIRWING übergeben | Squadron-Konstruktion und Payloadregistrierung bestanden |
| `Wrapper.Unit` | `UNIT` | `VALIDATED` | Typnamen und Namen von Template-Einheiten prüfen; optionaler Warehouse-Anker | Jalalabad-Validatoren bestanden |
| `Wrapper.Static` | `STATIC` | `VALIDATED` | Warehouse-Anker, sichtbare Luftfahrzeug-Statics und CH-47-Slingload finden und validieren | 20/20 Statics und Warehouse-Anker bestätigt; Slingload-Aufnahme beobachtet |
| `Core.Zone` | `ZONE` | `VALIDATED` | Benannte Mission-Editor-Zonen finden und Vollständigkeit prüfen | 11/11 Zonen bestätigt; CH-47-Zielzone besitzt die für DCS erforderliche ME-Zonen-ID |
| `Core.Zone` | `ZONE_RADIUS` | `IN_USE_PARTIAL` | Kleine Runtime-Landezonen an missionsseitig festgelegten Zonenmittelpunkten | UH-60-End-to-End-PASS |
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
| `Ops.ArmyGroup` | `ARMYGROUP` | `PLANNED` | Laufzeitsteuerung von Bodengruppen, insbesondere transportierbarer oder entpackter Gruppen | Verhalten bei Transport, Feindkontakt, Route und Festfahren prüfen |
| `Ops.Brigade` | `BRIGADE` | `PLANNED` | Bestands- und Einsatzmanager größerer Bodeneinheiten | Zusammenspiel mit CampaignState und COMMANDER klären |
| `Ops.CTLD` | `CTLD` | `PLANNED` | Spielerlogistik, Truppen und Fracht | Abgrenzung zu OPSTRANSPORT und CampaignState festlegen |
| `Ops.CSAR` | `CSAR` | `PLANNED` | CSAR-Spielmechanik und Rettungsaufträge | Abgrenzung zu MEDEVAC und Persistenz festlegen |
| `Functional.Rat` | `RAT` | `PLANNED` | Ausschließlich nicht persistenter, atmosphärischer Hintergrundverkehr | Kein Ressourcen- oder Bestandsübergang; Spawnlimits testen |
| `Core.Event` | `EVENT` | `PLANNED` | Zentrale Reaktion auf Birth, Dead, Crash, Land, Takeoff und weitere DCS-Ereignisse | Eventdaten und Mehrfachmeldungen versionsbezogen testen |
| `Core.Set` | `SET_GROUP`, weitere Sets | `PLANNED` | Dynamische Mengen von Gruppen, Zonen oder Objekten | Filter, Aktualisierung und Performance prüfen |

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

## 7. Direkte DCS-API- und Taskstruktur-Nutzung

Direkte DCS-API-Aufrufe und DCS-Taskstrukturen sind keine MOOSE-Module und werden deshalb getrennt betrachtet.

Aktuell bekannte Fälle:

| API / Struktur | Verwendung | Bewertung |
|---|---|---|
| `timer.scheduleFunction` | Fallback, falls `SCHEDULER` beim Laden nicht verfügbar ist | Nur als dokumentierter Fallback zulässig |
| `env.info` | Projektlogging | Zulässig; MOOSE-Logging kann ergänzend geprüft werden |
| `coalition.side.BLUE` | Konstruktorparameter für `COMMANDER` | DCS-Konstante, von MOOSE erwartet |
| `AI.Skill.HIGH` | Skill-Konfiguration von SQUADRONs | DCS-Konstante, über MOOSE-Methode gesetzt |
| `AUFTRAG.DCStask.params.tasks[*].params` | Übertragung der bereits von `AUFTRAG:NewCARGOTRANSPORT()` erzeugten Cargo- und Zielzonen-ID auf die tatsächlich ausgeführte innere `CargoTransportation`-Task | Eng begrenzter, fail-closed Adapter für den nachgewiesenen Upstream-Verschachtelungsfehler; kein eigener Missions-FSM; bei jedem MOOSE-Update erneut prüfen; DCS-Abnahme offen |

## 8. Aktualisierungsregel

Bei jeder neuen MOOSE-basierten Implementierung ist dieser Index im selben Commit oder Pull Request zu aktualisieren.

Ein Statuswechsel auf `VALIDATED` erfordert:

1. dokumentierten MOOSE-Stand,
2. konkreten OMW-Quellpfad,
3. reproduzierbaren DCS-Test,
4. Ergebnisbericht,
5. Eintrag in [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md).
