---
document_id: OMW-PLAN-UAV-ISR-REQUEST-ORCHESTRATION
status: DRAFT
authoritative_for:
  - proposed UAV ISR request development order
  - proposed multiplayer request contract
  - MOOSE-first investigation scope
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/uav-isr-request-orchestration
source_commit: 8ba6f7b1be42111723ad70d337ed466f76a2b716
validated_in_dcs: false
document_class: DEVELOPMENT_ORDER
owning_policy: OMW-GOV-001
---

# Entwicklungsauftrag: Multiplayer-UAV-ISR-Anforderungen

## 1. Status und Zweck

Dieses Dokument ist ein Entwicklungsauftrag und eine Arbeitsliste. Es fasst den fachlichen Entscheidungsstand zur Spieleranforderung von militärischer UAV-Aufklärung zusammen und legt die notwendige, MOOSE-first-konforme Entwicklungs- und Acceptance-Reihenfolge fest.

Es ist **kein** Nachweis eines funktionierenden DCS-Laufzeitverhaltens und erzeugt keine neue produktive Baseline. Vor der Implementierung sind die offenen Projektinhaberentscheidungen in Abschnitt 8 zu bestätigen und in die zuständigen Fachdokumente zu übernehmen.

## 1.1 Ausführungsgrenze der Entwicklungsumgebung

Im lokalen OMW-Arbeitsverzeichnis werden weder Python noch Lua als Entwicklungs- oder Testlaufzeit vorausgesetzt. Deshalb gilt:

- Dokumentations- und statische Repository-Prüfungen erfolgen im veröffentlichten Repository über die vorhandene CI, nicht durch lokale Python-Aufrufe.
- Lua wird nicht lokal ausgeführt oder durch einen lokalen Lua-Interpreter „akzeptiert“.
- DCS-Laufzeitaussagen entstehen ausschließlich aus einem reproduzierbar gebauten, in DCS geladenen Missionsartefakt samt der dafür erforderlichen Logs und Hashes.

Ein lokales `git pull` dient nur dem Abgleich des Worktrees mit dem veröffentlichten Branch.

## 2. Zielbild

BLUE-Spielergruppen können begrenzte militärische ISR-Unterstützung anfordern, ohne spezielle Client-Slots zu benötigen.

```text
F10 map marker: UAV RECON
        +
F10 radio: Command -> ISR Cell -> Submit nearest UAV marker
        |
        v
CampaignState request and reservation decision
        |
        v
MOOSE AIRWING / SQUADRON / AUFTRAG physical execution
```

Die Anforderung erzeugt keinen UAV-Spawn. Sie erzeugt einen Bedarf. `CampaignState` bleibt die einzige Autorität für strategischen Bestand, Reservierung, Verlust, Turnaround und Restart-Reconciliation. Die physische Ausführung erfolgt über MOOSE.

Die erste produktive Stufe umfasst ausschließlich unbewaffnete beziehungsweise `WeaponHold`-geführte **RECON**. AFAC, Laserdesignation und Waffenwirkung sind ausdrücklich nicht Teil dieses Auftrags.

## 3. Fachlicher Hintergrund

Im Afghanistan-Zeitraum 2010--2011 waren größere MQ-1-/MQ-9-ähnliche Plattformen knappe, theaterweit priorisierte ISR-Mittel. Sie wurden nicht dauerhaft exklusiv an einzelne Bodenverbände gebunden. OMW bildet dies als gemeinsamen UAV-Pool ab:

```text
CampaignState stock
  -> ISR Cell request queue
  -> one physical UAV sortie can serve several sequential requests
  -> recovery and turnaround before the asset becomes available again
```

Ein einzelner Spielerrequest ist somit ein zeitlich begrenzter Teilauftrag einer UAV-Sortie, nicht automatisch eine vollständige Start--Recon--Return-Mission.

## 4. Gegenwärtiger geprüfter MOOSE-Stand

Die Aussagen dieses Abschnitts beziehen sich auf die für die Planung geprüfte MOOSE-Quellreferenz. Sie gelten erst nach Versions-/Hashabgleich gegen den tatsächlichen OMW-Bundle-Stand als für eine Implementierung verwendbar. Die auf `main` bereits akzeptierten AWACS-Methoden sind keine UAV- oder RECON-Acceptance.

| Bedarf | Nachgewiesener MOOSE-Baustein | Verifizierte Aussage | Grenze |
|---|---|---|---|
| Kartenmarker erfassen | `MARKEROPS_BASE` | Reagiert auf Add/Change/Remove; Callback erhält Text, Koordinate, Marker-ID, Koalition und optional Spielername. | Gruppenbezug ist aus dem Marker-Callback nicht garantiert. |
| Gruppenmenü | `MENU_GROUP`, `MENU_GROUP_COMMAND` | Ein Befehl wird im Kontext der auslösenden DCS-Gruppe registriert und führt eine Funktion aus. | DCS-Funkmenüs erfassen keine freie Koordinate. |
| Laufzeit-Zielbereich | `COORDINATE`, `ZONE_RADIUS` | Markerkoordinate kann als Zentrum einer zeitweiligen Recon-Zone dienen. | Radius/No-go-Prüfungen sind OMW-Fachregeln. |
| Recon-Auftrag | `AUFTRAG:NewRECON(ZoneSet, Speed, Altitude, Adinfinitum, Randomly, Formation)` | Erstellt eine RECON-Mission; sie setzt `WeaponHold` und passive Verteidigung. | Verhalten des konkreten UAV-Templates ist in DCS zu testen. |
| Folgeaufträge | `OPSGROUP:AddMission`, Mission Queue, `_QueueUpdate` | Ein laufender OPSGROUP kann weitere AUFTRAG-Missionen in einer Prioritätsqueue führen. | Übergang UAV `RECON A -> RECON B`, Route und Treibstoff müssen in DCS getestet werden. |
| Dringende Umpriorisierung | OPSGROUP-Queue-Logik | Eine höher priorisierte als urgent markierte Mission kann eine laufende Mission verdrängen. | Für UAV-ISR erst nach eigenem DCS-Test freigeben. |
| Gruppenmeldung/-marker | `MESSAGE:ToGroup`, `MARKER:ToGroup` | Informationen und F10-Marker können einer bestimmten Gruppe angezeigt werden. | Native F10-Sichtbarkeitsoptionen des Servers können Fog of War unterlaufen. |
| Zielmeldung/Designation | `DESIGNATE` | Meldet erkannte Ziele an eine definierte Attack-Group-Menge und entfernt Zielbezug bei Verlust der Detektion. | Kein Ersatz für den gesamten OMW-Request- und Marker-Lifecycle. |
| CHIEF-Zonenlogik | `CHIEF`, `AUFTRAG.Type.RECON` | CHIEF kann RECON als Ressource einer nicht eigenen, nicht leeren strategischen Zone rekrutieren. | Kein fertiger Player-request-to-UAV-Dispatcher; `ZoneAttacked` löst keine UAV-Anforderung aus. |

Nicht verwenden für gruppenspezifische Fog-of-War-Darstellung:

- `INTEL:SetClusterAnalysis(..., true)` erzeugt Cluster-Marker koalitionsweit;
- `INTEL:SetForgetTime(...)` ist im geprüften Quellstand als `OBSOLETE, not functional` gekennzeichnet.

Vor Codearbeit sind zusätzlich die zu diesem MOOSE-Stand passenden offiziellen MOOSE-Demos für Marker, Menu, AIRWING/AUFTRAG/OPSGROUP und Detection/DESIGNATE zu prüfen und zu dokumentieren.

## 5. Vorgeschlagener Multiplayer-Request-Vertrag

### 5.1 Bedienablauf

1. Eine BLUE-Clientgruppe setzt einen F10-Kartenmarker mit exakt `UAV RECON`.
2. Die Gruppe wählt `Command -> ISR Cell -> Submit nearest UAV marker`.
3. Das System akzeptiert ausschließlich einen einzelnen gültigen BLUE-Marker innerhalb eines festzulegenden Submit-Radius.
4. Der Request wird mit stabiler Request-ID, anfordernder Gruppe, Marker-ID und Zielkoordinate gespeichert.
5. Eine erfolgreiche Abgabe bindet die Zielkoordinate an die Request-ID; spätere Markeränderungen ändern den Auftrag nicht.

Mehrdeutige Marker, ungültige Texte, fremde Koalition, No-go-Zonen oder fehlender Marker führen zu einer gruppenspezifischen, erklärenden Ablehnung.

### 5.2 Eigentum, Rechte und Sichtbarkeit

| Regel | Vorgeschlagene Entscheidung |
|---|---|
| Anforderungsrecht | Jede BLUE-Clientgruppe darf anfordern. |
| Request-Eigentümer | DCS-Gruppen-ID/stabile OMW-Entity-ID; Spielername nur Diagnosemetadatum. |
| Maximalmenge | Eine wartende oder aktive Anfrage je Gruppe. |
| Fremde Requests | Nicht abbrechbar und nicht detailliert sichtbar. |
| Eigene Requests | Wartende Anfrage stornierbar; nach Start nur geordneter Recall. |
| Statusanzeige | Gruppenbezogen über `MENU_GROUP_COMMAND` und `MESSAGE:ToGroup`. |
| Zielinformationen | Nur für die anfordernde Gruppe; keine automatische koalitionsweite Feindlage. |

Bei OMWs Clientregel "eine Clientgruppe = ein Luftfahrzeug" ist Gruppenbesitz der korrekte Mehrspielerbezug. Sollte später eine Gruppe mehrere unabhängige Spieler enthalten, teilen diese bewusst Requeststatus und Abbruchrecht.

### 5.3 Request- und Sortie-Status

```text
Request: DRAFT_MARKER -> QUEUED -> RESERVED -> ASSIGNED -> ON_STATION
                                  |                       |
                                  v                       v
                              CANCELLED                COMPLETED

UAV sortie: AVAILABLE -> RESERVED -> LAUNCHING -> EN_ROUTE
            -> ON_STATION -> TRANSIT_NEXT -> HOLDING -> RETURNING
            -> RECOVERED -> TURNAROUND -> AVAILABLE
```

Ein Request ist nicht gleich einer Sortie. Ein aktives UAV kann mehrere Requests nacheinander bedienen.

### 5.4 Kapazität und Queue

Wenn kein UAV verfügbar ist, bleibt eine gültige Anfrage in `QUEUED`. Die anfordernde Gruppe sieht mindestens Request-ID, Queue-Position und Grund.

Beispiel:

```text
ISR-042: QUEUED
Reason: all UAV assets are committed.
Queue position: 2.
```

Eine ETA darf nur gemeldet werden, wenn sie aus dokumentierten realen Laufzeitwerten ableitbar ist. Sie darf nicht geschätzt oder simuliert werden.

### 5.5 Abbruch und Recall

| Requestzustand | Eigentümergruppe | Systemverhalten |
|---|---|---|
| `QUEUED` | Cancel | Request entfernen. |
| `RESERVED` / `LAUNCHING` | Cancel | Reservierung sauber freigeben, sofern noch kein physischer Start erfolgt ist. |
| `EN_ROUTE` / `ON_STATION` | Recall | Auftrag geordnet beenden; UAV wird für Folgerequest oder RTB entschieden. Kein Despawn. |
| `RETURNING` / `RECOVERED` | Kein Cancel | Lifecycle läuft zu Ende. |

### 5.6 Sortie-Persistenz und Holding

Nach einem Request kehrt das UAV nicht zwangsläufig nach Kandahar zurück. Die ISR-Zelle bewertet vor jeder Folgebeauftragung:

```text
remaining endurance
- protected return reserve to Kandahar
- safety margin
- transit to next request
- minimum on-station commitment
= deployable time
```

Nur bei positiver Bewertung wird die nächste Mission der laufenden UAV-Sortie zugewiesen. Liegt kein geeigneter Folgeauftrag vor, darf das UAV nur für eine begrenzte, noch festzulegende Zeit in einer sicheren Holding-Zone verbleiben. Danach RTB. Ein endloser Wartekreis allein wegen einer beliebig alten Queue ist ausgeschlossen.

### 5.7 Bewaffnung und Feuerfreigabe

Stage 1 bis einschließlich der ersten produktiven Freigabe:

```text
mission type: RECON only
ROE: WeaponHold
no player weapon release
no AFAC
no laser designation
```

Ein späteres bewaffnetes UAV ist ein eigenständiger Fire-Support-Entscheidungsstrang. Es benötigt ein separates ROE-/Zielidentifikations-/Freigabemodell und darf nicht als Untermenü der ersten Recon-Funktion implementiert werden.

### 5.8 Fog of War

Das UAV-Lagebild wird gruppenspezifisch ausgegeben:

```text
active UAV reconnaissance zone
  + currently detected contact
  -> MESSAGE:ToGroup and/or MARKER:ToGroup
  -> only to request owner group
  -> withdraw/update on contact loss or request completion
```

Die DCS-Server-/Missionseinstellungen für F10-Sichtbarkeit sind ein eigenes Acceptance-Gate. Sie dürfen keine gegnerischen Einheiten allgemein sichtbar machen und damit das MOOSE-gesteuerte Lagebild entwerten.

## 6. Architektur- und Authority-Grenzen

| Bereich | Autorität | Nicht zulässig |
|---|---|---|
| Bestand, Reservierung, Verlust, Turnaround, Restart | `CampaignState` | eigene parallele Bestandstabelle im ISR-Koordinator, AIRWING oder DCS Warehouse |
| Request-Policy und Queue | OMW ISR Request Coordinator | generische MOOSE-Funktionen oder CampaignState-Ownership nachbauen |
| Physische Flugausführung | MOOSE `AIRWING` / `SQUADRON` / `AUFTRAG` / `OPSGROUP` | native DCS-Spawn-/Route-Parallelpfade ohne Freigabe |
| Kontakt-/Spielerpräsentation | MOOSE group-scoped Message/Marker/Designation | koalitionsweite Allwissenheit durch INTEL-Cluster-Markierung |
| CHIEF | strategische Bedarfe und Zonenlogik | als alleinigen Besitzer der Spielerrequest-Queue verwenden |

Der OMW ISR Request Coordinator ist ein kleiner projektspezifischer Adapter. Seine Verantwortung endet bei Validierung, Requestzustand und Übergabe an CampaignState/MOOSE. Er erstellt keine physische DCS-Gruppe selbst.

## 7. Missionseditor- und Datenvoraussetzungen

Vor Runtime-Implementierung erforderlich:

- verbindlich gewählter DCS-UAV-Typ als historisch dokumentierter OMW-Asset;
- Heimatbasis Kandahar einschließlich realem Template, Parking-/Start-/Recovery-Nachweis;
- AIRWING-/SQUADRON-/Warehouse-/CampaignState-Assetvertrag ohne doppelte Ressourcenhoheit;
- sichere Transit-, Holding- und Rückkehrbereiche einschließlich Höhen- und Wettergrenzen;
- Request- und Recon-Zonenregeln, No-go-/NSL-/Basis-/Schutzbereichsprüfung;
- BLUE-Clientgruppen-Set und gruppenspezifische Menülebensdauer;
- DCS-F10-/Multiplayer-Sichtbarkeitseinstellungen als dokumentierte Baseline;
- definierter Persistenzbereich für CampaignState und dokumentierte Restart-Reconciliation.

## 8. Offene Projektinhaberentscheidungen (BLOCKING)

| ID | Entscheidung | Warum blockierend |
|---|---|---|
| D1 | UAV-Typ, Anzahl, Bewaffnungsvorhandensein und OMW-historischer Ersatz | Bestimmt Template, Sensorik, Endurance, AIRWING-Stock und Tests. |
| D2 | Endgültige Heimatbasis und Transit-/Holding-Konzept | Kandahar ist aktuelle Annahme, aber noch keine bestätigte Mission-Editor-Baseline. |
| D3 | Submit-Radius, Recon-Radius, On-Station-Minimum, Hold-Limit und Rückkehrreserve | Definiert Gültigkeit, Fairness und Sortieentscheidung. |
| D4 | Prioritätsmodell einschließlich zulässiger Preemption | Verhindert missbräuchliche oder unverständliche Queue-Änderungen. |
| D5 | Verhalten bei Spielerdisconnect, Gruppenverlust, Slotwechsel und Request-Ablauf | Erforderlich für Multiplayer- und Restart-Konsistenz. |
| D6 | Zielanzeigeformat: Text, gruppenspezifische Marker oder beides | Bestimmt Fog-of-War-Umsetzung und Performance. |
| D7 | Umfang der ersten Akzeptanz: nur einzelne Sortie oder bereits Mehrfachbeauftragung | Bestimmt Testdauer und Risiko. |

## 9. Entwicklungsreihenfolge

### Phase 0 -- Worktree, Baseline und Dokumentationsrecherche

- [x] Dedizierten Worktree und Branch angelegt: `agent/uav-isr-request-orchestration`.
- [x] Exakten Ausgangscommit festgehalten: `8ba6f7b1be42111723ad70d337ed466f76a2b716` auf `origin/main`.
- [ ] Den für die spätere Testmission verwendeten MOOSE-Bundle-Commit und Artefakt-Hash festhalten.
- [ ] Aktuelle OMW-AIRWING-, SQUADRON-, CampaignState-, Warehouse-, ORBAT-, Naming- und Mission-Editor-Dokumente auf dem Ausgangsstand lesen.
- [ ] Relevante offizielle MOOSE-Demos/Tests prüfen und Konstruktoren, Voraussetzungen, FSMs und Einschränkungen dokumentieren.
- [ ] `docs/moose/PROJECT-CLASS-INDEX.md` und passende Themendokumentation vorbereiten, aber noch nicht als `VALIDATED` markieren.

### Phase 1 -- Fachvertrag und reine UI-/Marker-Acceptance

- [ ] D1--D7 entscheiden und den verbindlichen Fachvertrag dokumentieren.
- [ ] MOOSE-first-Gap-Nachweis für die Marker-zu-Gruppenmenü-Korrelation schreiben; kleinsten OMW-Adapter abgrenzen.
- [ ] `MARKEROPS_BASE` für gültige BLUE-`UAV RECON`-Marker konfigurieren.
- [ ] Gruppenmenü mit Submit-, Own-status- und Own-cancel-Ansicht implementieren.
- [ ] Eindeutigkeitsprüfung für nächsten gültigen Marker, Marker-ID-Bindung und Fehlermeldungen implementieren.
- [ ] Noch keine UAV-Reservierung, kein Spawn, keine Waffenlogik.
- [ ] Multiplayer-DCS-Acceptance: zwei BLUE-Gruppen, nahe/mehrdeutige/ungültige Marker, private Statusausgabe, kein Fremdabbruch.

### Phase 2 -- CampaignState-Request und Ressourcenreservierung

- [ ] Stabile ISR-Request-Entity-ID und erlaubte Zustandsübergänge definieren.
- [ ] Request-Queue, Ablaufzeit, Gruppenquote und atomare Reservierung im CampaignState-Adapter integrieren.
- [ ] Sicherstellen, dass kein anderer Bestand neben CampaignState UAV-Verfügbarkeit besitzt.
- [ ] Cancel/Recall vor physischem Start und Fehler-/Rollbackpfade testen.
- [ ] Restart-Reconciliation für `QUEUED` und `RESERVED` dokumentieren und testen.

### Phase 3 -- Einzelne physische UAV-RECON-Sortie

- [ ] UAV-Template und AIRWING/SQUADRON/Warehouse-Vertrag im Mission Editor einrichten.
- [ ] Aus CampaignState-Reservierung einen `AUFTRAG:NewRECON(...)` erzeugen und MOOSE die Ausführung überlassen.
- [ ] Start, Taxi/Parking, Anflug, Recon, Rückkehr, Landung und Turnaround in DCS prüfen.
- [ ] Verlust-, Abbruch- und kein-beobachtbarer-Despawn-Verhalten prüfen.
- [ ] Erst nach DCS-PASS relevante Methoden in `docs/moose/VERIFIED-METHODS.md` markieren.

### Phase 4 -- Mehrfachbeauftragung, Holding und Ressourcenverbrauch

- [ ] Folge-RECON-Mission an bereits fliegenden UAV-OPSGROUP nur über nachgewiesene MOOSE-Missionsqueue integrieren.
- [ ] Bedingung für Direktverlegung, begrenzte Holding und RTB nach D3 implementieren.
- [ ] Queue-Priorität ohne Preemption testen.
- [ ] Optional und separat: urgent-Preemption mit kontrolliertem MissionCancel/Neuauftrag testen.
- [ ] DCS-Acceptance: `RECON A -> RECON B -> RTB`, inklusive tatsächlicher Treibstoff-/Routenbeobachtung.

### Phase 5 -- Gruppenbezogenes Lagebild / Fog of War

- [ ] Detektionsquelle, Sensor-/LOS-Grenzen und Kontaktablauf nach D6 festlegen.
- [ ] Nur gruppenspezifische `MESSAGE:ToGroup`/`MARKER:ToGroup` einsetzen.
- [ ] Kontaktverlust, Missionsende und Recall entfernen/aktualisieren die Gruppenanzeige.
- [ ] DCS-F10-Sichtbarkeitsbaseline gegenprüfen.
- [ ] Multiplayer-DCS-Acceptance: Anforderer sieht Kontakt, andere BLUE-Gruppe sieht ihn nicht; Verlust der Detektion entfernt/entwertet die Anzeige.

### Phase 6 -- Vollständige Integration und Dokumentation

- [ ] CHIEF-Strategic-RECON und Player-ISR-Requests nur über den gemeinsamen CampaignState-Pool reconciliieren.
- [ ] Statistik, Logs und Fehlerzustände mit Request-ID, UAV-Entity-ID und Owner-Group-ID erfassen.
- [ ] Dokumentregister prüfen und Dokumentnummer reservieren, bevor ein bindendes Folgepapier entsteht.
- [ ] Vollständige Diffs, Syntax-/Tests, MOOSE-Dokumentation, Acceptance-Report und Handoff aktualisieren.
- [ ] Nur nach dem dokumentierten DCS-Teststand auf `VALIDATED` setzen.

## 10. Mindest-Acceptance-Matrix

| Test | Erwartetes Ergebnis |
|---|---|
| Gültiger Marker + Submit | Genau ein gruppengebundener `QUEUED`-Request entsteht. |
| Kein/ungültiger/mehrdeutiger Marker | Kein Request, verständliche Gruppenmeldung. |
| Zwei Spielergruppen | Jede sieht ausschließlich den eigenen Status. |
| Fremdabbruch | Nicht verfügbar bzw. wirkungslos; keine Statusänderung. |
| Eigener Cancel in Queue | Request entfernt, keine Bestandsänderung außer ggf. aufgehobener Reservierung. |
| Voller Pool | Eindeutiger Queue-Status ohne UAV-Spawn. |
| Einzel-RECON | Physischer Start, Recon, Recovery und CampaignState-Abrechnung stimmen überein. |
| Folgeauftrag | Ein UAV fliegt nach genügend Restzeit `A -> B` ohne unnötiges RTB. |
| Unzureichende Rückkehrreserve | UAV verweigert Folgeauftrag und kehrt geordnet zurück. |
| Recall | Geordnete Missionsbeendigung; kein Teleport/Despawn. |
| Kontaktanzeige | Nur berechtigte Gruppe erhält aktuelle Kontakte. |
| Kontaktverlust | Gruppenanzeige wird entfernt/aktualisiert. |
| Restart | Keine doppelte Reservierung, kein Duplikat-Spawn, konsistenter Requeststatus. |

## 11. Aktueller Stand

- Fachliches Zielbild und Multiplayer-Grundsätze sind erarbeitet.
- Der dedizierte Arbeitszweig ist auf `8ba6f7b1be42111723ad70d337ed466f76a2b716` angelegt; der Remote-Zweig trägt denselben Namen.
- MOOSE-Quellprüfung für Marker, Gruppenmenü, RECON, OPSGROUP-Missionsqueue, CHIEF-Grenze und gruppenspezifische Nachrichten/Marker ist als Planungsrecherche erfolgt, jedoch noch nicht gegen das Testmissions-Bundle gehasht oder in DCS akzeptiert.
- Der Main-Stand enthält keine produktive OMW-Laufzeit unter `src/` oder `mission/`; ein UAV-Mission-Editor-Template, ein CampaignState-Integrationspunkt und ein DCS-Test für diese Funktion existieren daher auf diesem Zweig noch nicht.
- Keine Aussage in diesem Dokument ist als `VALIDATED` zu verstehen.

## 12. Übergabehinweis

Bei einer Übergabe sind mindestens mitzuteilen:

```text
Arbeitsbranch und Basiscommit:
MOOSE-Datei/Hash:
Entschiedene D1--D7:
Mission-Editor-UAV-Template und Hash:
CampaignState-/AIRWING-Ressourcenvertrag:
Aktueller Phasenstatus:
Ausgeführte Tests mit DCS-/Bundle-/Missionshash:
Offene Risiken und nächste konkrete Acceptance:
```
