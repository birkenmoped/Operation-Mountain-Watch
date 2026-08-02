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
| `Wrapper.Airbase` | `AIRBASE` | `VALIDATED` | Jalalabad und Salerno suchen, Name und ID prüfen; lokale Parking-Funktionen nur bei belastbarem Vertrag | Jalalabad Complete Node PASS; Salerno Stage 18 PASS |
| `Ops.Airwing` | `AIRWING` | `VALIDATED` | Lokaler Ressourcen- und Einsatzmanager; Airbase-Zuordnung, Squadrons, Payloads, Missionsqueue und Assetanforderung | Jalalabad Grundstart PASS; Salerno COMMANDER-CAS bis `started` PASS |
| `Ops.Squadron` | `SQUADRON` | `VALIDATED` | Typgebundene Bestände mit Gruppierung, Skill und Mission Capabilities | Jalalabad 4/4; Salerno 5/5; Salerno-AH-64 für CAS rekrutiert |
| `Functional.Warehouse` | `WAREHOUSE` | `VALIDATED` über `AIRWING` | Physische Ressourcenbasis der AIRWINGs und registrierte Assetbestände | Laufende AIRWINGs; Salerno 20 Assets, davon ein Asset aktiv auf Mission |
| `Ops.Auftrag` | `AUFTRAG` | `IN_USE_PARTIAL` | Missionstypen, Capabilities und kontrollierter CAS-Dispatch | Salerno-CAS `planned -> requested -> scheduled -> started`; taktischer Abschluss und Recovery offen |
| `Ops.Commander` | `COMMANDER` | `VALIDATED` für Start und isolierten CAS-Dispatch | Blue Commander erstellen, AIRWING anbinden, starten, Missionseignung prüfen, Mission auswählen und Assetanforderung auslösen | Jalalabad Grundstart PASS; Salerno Stage 18 PASS |
| `Core.Scheduler` | `SCHEDULER` | `VALIDATED` | Verzögerte Konstruktion, Runtime-Snapshots und kontrollierter Cleanup | Jalalabad- und Salerno-Bundles ohne relevanten OMW-Timerfehler |
| `Wrapper.Group` | `GROUP` | `VALIDATED` | Late-Activation-Templates finden und prüfen; Payloadvorlagen an AIRWING übergeben | Squadron-Konstruktion und Payloadregistrierung bestanden |
| `Wrapper.Unit` | `UNIT` | `VALIDATED` | Typnamen und Namen prüfen; optionaler Warehouse-Anker | Validatoren bestanden |
| `Wrapper.Static` | `STATIC` | `VALIDATED` | Warehouse-Anker und sichtbare Luftfahrzeug-Statics finden und validieren | Jalalabad und Salerno Objektprüfungen bestanden |
| `Core.Zone` | `ZONE` | `VALIDATED` | Benannte Zonen finden; Salerno-Zielzone an CAS-AUFTRAG übergeben | Zonenprüfung bestanden; Salerno-CAS konstruiert und gestartet |
| MOOSE Template Database | `_DATABASE` | `INTERNAL_RESTRICTED` | Unbesetzte Client- und Late-Activation-Gruppen in der Template-Datenbank validieren | Nur für Diagnose/Validierung; keine allgemeine Produktions-API |

## 3. Implizit verwendete Basisklassen

Die folgenden MOOSE-Klassen werden durch die oben genannten OPS-Klassen geerbt oder intern verwendet. Sie sind für Architektur- und Eventanalysen relevant, werden im aktuellen OMW-Code aber nicht direkt konstruiert.

| Modul / Klasse | Status | Bedeutung für OMW |
|---|---|---|
| `Core.Base` | `IN_USE_PARTIAL` | Gemeinsame Basisklasse und Logging-/Scheduling-Funktionen vieler MOOSE-Klassen |
| `Core.Fsm` | `IN_USE_PARTIAL` | Zustandsautomaten von AIRWING, COMMANDER und AUFTRAG; Salerno bestätigte `NotReadyYet -> OnDuty` und Missionsfortschritt bis `started` |
| `Ops.Legion` | `IN_USE_PARTIAL` | Gemeinsame Legion-Basis; Salerno bestätigte COMMANDER-Auswahl und MissionRequest an ein AIRWING |
| `Ops.Cohort` | `IN_USE_PARTIAL` | Gemeinsame Bestandsbasis; Salerno bestätigte Eignungsprüfung und Rekrutierung aus einem AH-64-SQUADRON |

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
| `Core.Event` | `EVENT` | `PLANNED` | Zentrale Reaktion auf Birth, Dead, Crash, Land, Takeoff und weitere DCS-Ereignisse | Eventdaten, Event-ID 61 und Mehrfachmeldungen versionsbezogen testen |
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

## 7. Produktionsentscheidung COMMANDER

Die lokalen COMMANDER-Objekte in den Jalalabad- und Salerno-Testfixtures bleiben aus Gründen der Reproduzierbarkeit erhalten.

Für die spätere Kampagnenruntime ist genau ein theaterweiter BLUE COMMANDER vorgesehen:

```text
Flugplatzmodule
  -> exportieren lokale AIRWINGs

zentrales BLUE-COMMANDER-Modul
  -> registriert alle AIRWINGs
  -> startet genau einen COMMANDER
  -> nimmt theaterweite AUFTRAG-/OPSTRANSPORT-Objekte entgegen
```

Ein eigener Produktions-COMMANDER je Flugplatz ist nicht vorgesehen.

## 8. Direkte DCS-API-Nutzung

Direkte DCS-API-Aufrufe sind keine MOOSE-Module und werden deshalb getrennt betrachtet.

| API | Verwendung | Bewertung |
|---|---|---|
| `timer.scheduleFunction` | Fallback, falls `SCHEDULER` beim Laden nicht verfügbar ist | Nur als dokumentierter Fallback zulässig |
| `env.info` | Projektlogging | Zulässig; MOOSE-Logging wird ergänzend verwendet |
| `coalition.side.BLUE` | Konstruktorparameter für `COMMANDER` | DCS-Konstante, von MOOSE erwartet |
| `AI.Skill.HIGH` | Skill-Konfiguration von SQUADRONs | DCS-Konstante, über MOOSE-Methode gesetzt |

## 9. Salerno-Nachweisstand

```text
MOOSE commit:      73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
OMW commit:        dba0465afbff14fb719abdeb1f9b06e24ff24717
BuilderVersion:    SAL-COMMANDER-SELECTION-18
Bundle SHA-256:    75ea74cdaa60800899345924fc4eb450c15211d605bf972767d9d68e265421ee
DCS version:       2.9.28.26385
Result:            PASS
```

Nachweis:

- [`Salerno COMMANDER selection stage 18`](../../mission/tests/salerno-air-operations/results/2026-08-02-salerno-commander-selection-18-pass.md)

## 10. Aktualisierungsregel

Bei jeder neuen MOOSE-basierten Implementierung ist dieser Index im selben Commit oder Pull Request zu aktualisieren.

Ein Statuswechsel auf `VALIDATED` erfordert:

1. dokumentierten MOOSE-Stand;
2. konkreten OMW-Quellpfad;
3. reproduzierbaren DCS-Test;
4. Ergebnisbericht;
5. Eintrag in [`VERIFIED-METHODS.md`](VERIFIED-METHODS.md).
