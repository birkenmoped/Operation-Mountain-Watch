---
document_id: OMW-HANDOFF-2026-10-14-FSSR-PRODUCTION-RECONCILIATION
status: DRAFT
document_class: RECONCILIATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - documentation of the 2026-10-14 owner observation and production reconciliation work scope
not_authoritative_for:
  - implementation details or carrier-capacity values not authorized by the approved main logistics policy
  - new MOOSE or native-DCS implementation exceptions
  - acceptance or validation of a new production build
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-production-bootstrap
source_commit: a01b163a0db13b772db1d30aee4c38741f0b010a
validated_in_dcs: false
---

# FSSR – Production Reconciliation nach DCS-Lauf vom 14.10.2026

## AKTUELLER STAND / CHAT-WECHSEL – zuerst lesen

**Fortschreibung 16.10.2026:** Die neuesten vom Projektinhaber festgelegten fachlichen Absprachen und die aus dem realen DCS-Lauf gemeldeten Symptome stehen in **Abschnitt 21**. Fuer einen Chatwechsel **zuerst Abschnitt 21**, danach Abschnitte 19–20 fuer den Build-/MIZ-Stand und Abschnitte 1–18 fuer Architektur- und Fehlerhistorie lesen. Aeltere Statushinweise am Dokumentanfang sind historische Momentaufnahmen und werden durch diese spaetere datierte Fortschreibung konkretisiert; sie begruenden keinen aktuelleren DCS-PASS.

Dieses Dokument ist die **fortlaufende, jederzeit uebergabefaehige Arbeitsakte**. Bei einem neuen Chat **zuerst Abschnitt 12 (kompakte Betriebs-/Uebergabeakte) lesen**, danach die vorangegangenen Abschnitte fuer Ursachen, Quellen und Entscheidungen. Die Metadaten `source_commit` im Header kennzeichnen den urspruenglichen Test-/Aufzeichnungsstand, **nicht** den neuesten Git-HEAD. Der jeweils aktuelle Remote-HEAD muss vor neuer Arbeit per GitHub abgefragt werden.

Letzter vom Projektinhaber real lokal verifizierter Source-HEAD: `a134022f80606d9c353869d1c11f365b2e8c6c24` (siehe Abschnitt 11). Der letzte Dokumentations-Commit vor der hier beschriebenen Fortsetzung war `56f566d9d12f6ab64c434384654ee280577fc2ad`, vom Nutzer per `git pull --ff-only` und SHA-256 bestaetigt. **Kein Production-DCS-PASS** fuer die neue ARTY-Continuation oder M1083-Composition.

## 1. Einordnung und Beweisgrenzen

Dieses Handoff dokumentiert die vom Projektinhaber bereitgestellte Gesprächs-/Auswertungsaufzeichnung `Eingefügter Text(20261014-202154).txt`. Die dort genannten Log- und Debrief-Befunde sind **übernommene Testauswertung**, nicht unabhängig hier erneut geprüfte Rohlogs. Es erfolgt weder eine neue DCS-Validierung noch eine neue fachliche Freigabe. Für die endgültige Acceptance sind die ursprünglichen `dcs(20261014-191645).log`, `debrief(20261014-191647).log`, die tatsächlich gespeicherte `.miz` mit Hash sowie DCS-/MOOSE-Version gegen den konkreten Lauf zu archivieren.

Ausgangsstand laut aufgezeichneter lokaler Prüfung:

- Branch `agent/fire-support-strategic-resupply-production-bootstrap`, Commit `a01b163a0db13b772db1d30aee4c38741f0b010a`.
- Base Builder 34; Runtime 13; InstallationIncidentBridge 6; Base-Bundle SHA-256 `ACB0D888206F58AD3FF9A6D674335A1508CA86D952DBCB206620B1A8A9605A8A`.
- Production Bootstrap 4; Production-Bundle SHA-256 `B71D66B93FCC02778B30E5FD5C20DA6F266268269A1D8D8E329BE95DE2C735A5`.
- Im Mission Editor mussten **beide** Dateien `OMW_FireSupStratResupply_Base.lua` und `OMW_FireSupStratResupply_Production.lua` ausgetauscht werden.
- Der Bootstrap sollte nach MOOSE-Materialisierung aller vier Fixed-Fire-Assets den Security-Perimeter aktivieren und erst danach `OMW_FSSR_READY=1` setzen; maßgeblicher Vertrag: `mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-12.md`.
- Diese Build-/Hash-Angaben sind Provenienz der vorliegenden Gesprächsaufzeichnung, kein hier neu ausgeführter Build.

## 2. ARTY-/Mörser-Regression: One-cycle statt sustained engagement

Im beschriebenen Lauf: Honaker setzte 2B11-Mörser zur Selbstverteidigung ein; Wrights L118 wurde für Joyce ausgewählt. Laut der vorliegenden Auswertung wurden jeweils exakt vier physische Schüsse beobachtet (Honaker: t=53.288/56.473/57.620/60.657; Wright: t=68.777/69.842/72.774/73.818). Fortress meldete einen funktionalen ARTY-Abschluss, ohne dass die Auswertung physische Fortress-Schüsse nachwies.

Die aufgezeichnete Source-Analyse benennt im Production-Bootstrap aus Acceptance 11 übernommene Begrenzungen:

```lua
maxEngagements = 1
acceptedRadiusM = 50
acceptedShots = 4
```

Der Target-Resolver lieferte dort `shots=4` und `radiusM=50`. **Präzisierung:** Vier Schuss pro einzelner Fire Mission sind nicht an sich falsch; der ältere Full-Response-Pfad verwendete ebenfalls `FIRE_SHELLS=4`. Die Regression ist das Ende **des gesamten Bedarfs** nach nur einer solchen Fire Mission. Der frühere `queueNextFireMission(...)`-Pfad evaluierte erneut das lebende C2-Zielbild und stellte weitere begrenzte Fire Missions ein. Die Aufzeichnung nennt einen früheren Lauf mit 14 Fire Missions / 42 `EVENTS.Shot` als historische Evidenz; Provenienz ist vor technischer Wiederakzeptanz am Originalbericht abzugleichen.

**Wiederherzustellende Sollsemantik (Owner-Bestätigung in der Gesprächsaufzeichnung):**

1. C2/Fire Observation liefert geeignete lebende RED-Ground-Targets; der Incident-Clear allein ist kein Ende der Zielautorität.
2. MOOSE COMMANDER/LEGION selektiert ein verfügbares physisches Fixed-Fire-Asset; nur die vorhandene Functional-`ARTY`-Instanz kontrolliert das Feuer.
3. Begrenzte Fire Mission durchführen; nach CeaseFire lebendes Zielbild/Wirkung erneut auswerten; bei weiter geeignetem Ziel und verfügbarer Batterie/Munition nächste Fire Mission ansetzen.
4. Selbstverteidigung/eigener Bedarf hat Vorrang. Fällt dieser weg, wird die Batterie für geeignete fremde Site-Demands in Reichweite freigegeben. Cross-Site-Selektion Wright → Joyce wurde im Test beobachtet. `NO_AVAILABLE_ARTY_PROVIDER` während anderweitiger Reservierung ist grundsätzlich zulässig; nach terminalem Release muss das Asset wieder auswählbar sein.
5. Sobald CAS **physisch ON STATION** ist, keine neuen ARTY-Fire-Missions eröffnen; eine bereits laufende Fire Mission nicht künstlich abbrechen.
6. Bedarfsfortsetzung ist bei fehlender physischer Munition zu pausieren und nach bestätigtem Rearm/Resupply bei fortbestehendem Zielbild wiederaufzunehmen. Keine unbegründete automatische endlose Retry-Schleife.
7. `complete` ist nicht automatisch Schussnachweis: Fortress benötigt physische Shot-/Result-Evidenz oder einen klaren No-Fire-Terminalgrund.

**Nicht** als Lösung akzeptieren: `shots=4` pauschal auf 20/50 erhöhen, zweiten ARTY-Fire-Control-Owner einführen oder die vorhandene C2-/Functional-ARTY-Kette ersetzen.

## 3. Lokaler Munitionstransport: akzeptierten M1083-Rearm wieder anschließen

Die historische akzeptierte Kette ist:

```text
existing Functional ARTY instance
-> physical ammunition falls / rearm required
-> local M1083 from the site's MOOSE Warehouse
-> existing MOOSE ARTY:Rearm() lifecycle
-> CampaignState GROUND_AMMO_PACKAGE consumption
-> ARTY Rearmed
-> M1083 returns to Warehouse stock
-> continued fire if C2 target picture still requires it
```

Wiederzuverwenden, nicht neu zu implementieren:

- `OMW_FixedFireSupportAmmoSupport`
- `OMW_FixedFireSupportAmmoRearmService`
- `OMW_GroundAmmoRearmAdapter`
- Functional-ARTY-Owner aus `OMW_FobAttackFunctionalArtyDispatchAdapter.lua`

Die mitgeteilte historische A10-Rearm-Evidenz für Wright lautet 300 → 296 → 301 physische Runden und M1083-Return-to-stock; die exakte technische Referenz steht in `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md` und `docs/moose/FIXED-FIRE-SUPPORT-REARM.md`. In Bootstrap-4 ist diese Verkabelung laut Gesprächsanalyse noch unvollständig. Site-Scope: Bostick, Wright, Fortress, Honaker. CampaignState bleibt alleinige strategische Ressourcenautorität.

## 4. Strategischer Ground-/Air-Resupply: vorhandene Capabilities reaktivieren

**Ground:**

```text
CampaignState shortage -> ResourceDemandPolicy / ResupplyMonitor
-> GROUND_RESUPPLY -> MOOSE AUFTRAG:NewAMMOSUPPLY
-> existing GroundAmmoResupplyExecutor / AMMOSUPPLY transport
-> road convoy / delivery / confirmed CampaignState settlement / return
```

Die Gesprächsaufzeichnung nennt den historisch akzeptierten Fall Jalalabad → Wright und die Templates `TPL_BLUE_CONVOY_LIGHT_06` sowie `TPL_BLUE_CONVOY_STANDARD_07`. Daraus folgt **keine** genehmigte LIGHT/STANDARD-Auswahlregel nach einer selbst erfundenen Kapazitätsgrenze. Ground-AI-Routen/Anchors sowie Return-to-stock sind gegen ihre dokumentierte Acceptance wiederzuverwenden.

**Air:**

```text
CampaignState shortage -> AIR_RESUPPLY
-> existing Production ResupplyTransportRuntime
-> MOOSE OPSTRANSPORT + STORAGE
-> COMMANDER:RecruitAssetsForTransport()
-> MOOSE-selected CH-47 carrier
-> owner-authored FlightPath / delivery / reverse FlightPath
-> landing / LegionAssetReturned / TransportSettlement
```

Die Gesprächsaufzeichnung nennt A11-PASS für Jalalabad → Wright, 15 `GROUND_AMMO_PACKAGE`, CH-47-Profil 125 kt / 250-m-Lead-Turn. Das ist historische, standgebundene Acceptance-Evidenz, keine Erlaubnis zum Einschleusen der A11-`STORAGE`-Testfixture in Production.

Erforderliche Production-Reconciliation:

- `GroundInitialStock`-Reorderwerte → `OMW_ResourceDemandPolicy` → `OMW_FireSupStratResupply_ResupplyMonitor`; keine künstliche Shortage.
- Vorhandenen GroundAmmoResupplyExecutor/AMMOSUPPLY und die vorhandenen Convoy-Templates/validierten Routen einsetzen.
- Vorhandenen Air-`OPSTRANSPORT`/`STORAGE`-/COMMANDER-/FlightPath-/Settlement-Pfad einsetzen.
- Produktiven physischen Transport-/STORAGE-Descriptor **aus einer autoritativen Konfiguration** injizieren. Bis dahin bleibt der A12-Status `OMW_FSSR_RESUPPLY_READY=0` / `STRATEGIC_RESUPPLY_NOT_CONFIGURED` ein vorgeschriebener fail-closed Zustand; nicht per Acceptance-Fixture umgehen.
- Settlement nur nach bestätigter physischer Lieferung, idempotent und durch CampaignState.
- Keine Jalalabad/Wright-Testspezialwerte als generische Production-Policy.

### Owner-Entscheidung vom 14.10.2026: Ground oder Air – auf `main` verbindlich

`docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-MONITOR.md` sieht den injizierten Vertrag `selectSupportType(candidate, site, snapshot)` vor. Der Projektinhaber hat am 14.10.2026 die grundsätzliche Bedarfspriorisierung ausdrücklich freigegeben und auf `main` im bindenden `docs/05-logistics.md`, Abschnitt 2.1, dokumentieren lassen (Commit `b348a589642e13f60ce7541e4820bd973dd848f5`). **Kritisch/zeitkritisch:** rechtzeitige geeignete Luftversorgung hat vor Kosten Vorrang; Straßenkonvoi ist Fallback bzw. Ergänzung, wenn Lufttransport nicht verfügbar, unzureichend oder nicht rechtzeitig geeignet ist. **Regulär/planbar:** Wirtschaftlichkeit und Kapazität dominieren; bei passierbarer Straße werden Lebensmittel und allgemeine Versorgung bevorzugt am Boden transportiert. Fixed Wing bleibt für geeignete Flugplätze möglich. Das ist eine fachliche Policy, keine fertig implementierte `selectSupportType`-Strategie. Verbindliche Nutzlast-/Volumenwerte je Konvoityp, CH-47 und C-130 sowie die Umrechnung normalisierter CampaignState-Pakete sind vor Implementierung nachzuweisen; es werden keine Kapazitätsrangfolgen erfunden. MOOSE besitzt weiterhin die operative Assetwahl.

## 5. CAS: real beobachtetes Multi-Flight-Engagement erhalten und aufklären

Die aufgezeichnete Orchestration führt vier getrennte CAS-Demands:

```text
AID-158 -> COP_HONAKER
AID-159 -> FOB_JOYCE
AID-160 -> FOB_WRIGHT
AID-161 -> COP_FORTRESS
```

**Eigener visueller DCS-Testbefund des Projektinhabers:** Über Honaker operierten **gleichzeitig zwei AH-64D-Two-Ships (insgesamt vier Apaches)**; beide Flights bekämpften dort aktiv **unterschiedliche** RED-Ziele. Dies ist keine bloße Streckenüberschneidung. Das Verhalten wurde als taktisch nützlich beurteilt und darf nicht ohne Ursachenanalyse weggefiltert werden.

**Ursache ungeklärt:** Die diskutierte `PATROLZONE + SetEngageDetected`-Konfiguration (laut Gespräch: 5 NM Zone, 5 NM Detection-/Engagement-Range, Ground Units) lässt überlappende Zielräume oder opportunistische MOOSE-Zielerfassung als **Hypothese** zu. Ein formelles C2-/MOOSE-Retask ist nicht belegt. Die identischen Sensorzähler `detectedTotal=3 eligible=1` für Honaker/Wright identifizieren **keinen** tatsächlichen zweiten Flight oder Zielkontakt.

Folgende zusätzliche, ausschließlich beobachtende Evidence ist in einer nächsten Acceptance zu planen (konkrete MOOSE-Events/Signaturen erst gegen die gepinnte `Moose.lua` prüfen):

```text
CAS_TARGET_DETECTED: demandId, flight/asset identity, assignedSite,
                     targetGroup/entityId, targetCoordinate,
                     distanceToAssignedSite, relatedIncident
CAS_TARGET_ENGAGED: demandId, flight/asset identity, assignedSite,
                    targetGroup/entityId
```

Ziel der Diagnose ist die Unterscheidung zwischen formellem Retask, PATROLZONE-Überlappung, `SetEngageDetected`-Zielwahl, falschem AO-Anchor und sinnvoller Unterstützung eines benachbarten Incidents. Keine neue CAS-Zielsteuerung und keine Veränderung funktionierender Korridore vor dieser Evidenz.

**Waypoint `28: Waypoint UID=3`:** Nach der referierten Source-Analyse `missionUid=3` / dynamischer `PATROLZONE_DYNAMIC_AO_ANCHOR_NOT_BP`, nicht Erstkontakt. Die konkrete Kartenkoordinate fehlt; sie ist mit Demand-Ziel und Incident-Koordinate zu vergleichen, weil ein weit entfernter AO-Anchor eine Geometrieregression sein kann.

**AH-64-Verlust:** Ein einzelner AH-64D (MissionID 1000080) ist laut übernommener Debrief-Auswertung abgestürzt. Vorherige Infanterietreffer wurden berichtet; **Treibstoffmangel als Ursache ist nicht belegt**. Flight-Level-`CAS_HOME_LANDED` genügt nicht als Nachweis, dass alle Elemente eines Two-Ships verlustfrei in den AIRWING-/CampaignState-Bestand zurückgeführt werden dürfen. Asset-Level-Verlust und -Recovery prüfen.

## 6. Reconciliation-Arbeitsreihenfolge und Abnahme

1. Den Original-DCS-Lauf vom 14.10.2026 mit vollständiger Provenienz sichern; beobachtete Facts, übernommene Auswertung und Hypothesen strikt trennen.
2. Akzeptierte A9/A10/A11-Implementierungen gegen die aktuelle Production-Komposition abgleichen: `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md` ist Reuse-Gate; nichts parallel neu schreiben.
3. ARTY-Continuation und Fire-Mission-Ende korrekt wieder anbinden; keine pauschale Erhöhung der Einzelsalve; anhaltendes Zielbild und CAS-On-Station-Deconfliction absichern.
4. Lokalen M1083-/Functional-ARTY-Rearm für vier Standorte wieder anschließen; physische Rearm-Evidenz, Ressourcenbuchung und Return-to-stock nachweisen.
5. Ground- und Air-Transportpfade mit **produktiver** Descriptor-/STORAGE-Konfiguration reconciliieren; Resource-Demand-Schwellen aus realem CampaignState; kein künstlicher Stock-Mangel.
6. Die auf `main` in `docs/05-logistics.md` Abschnitt 2.1 beschlossene Ground-/Air-Priorisierung übernehmen, aber vor der technischen Policy die tatsächlichen Carrier-Kapazitäten, Manifestumrechnung und MOOSE-Verträge nachweisen; noch kein Dispatch-PASS.
7. CAS-Flights nach AID, tatsächlichem Ziel, Korridor, Anchor, Recovery und Asset-Level-Loss instrumentieren; zunächst ohne Verhaltensänderung.
8. Syntax/Tests/Diff, tatsächliche Builder-/Bundle-Hashes und dann reale DCS-Acceptance durchführen; `VALIDATED` nur für konkret nachgewiesene Ergebnisse.

### Relevante bestehende Referenzen

- `AGENTS.md`; `docs/00-project-governance.md`; `docs/26-moose-first-development-policy.md`
- `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`
- `docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE.md`
- `docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-MONITOR.md`
- `docs/moose/FIXED-FIRE-SUPPORT-REARM.md`
- `mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-12.md`
- `mission/tests/ground-ammo-rearm-integration/results/2026-08-22-acceptance-2-11-runtime.md`

**Status:** Dokumentierte Reconciliation-Anforderung, keine implementierte Runtime-Änderung. Kein neuer Runtime-PASS. Die Ground-versus-Air-Bedarfspriorisierung ist inzwischen auf `main` fachlich verbindlich entschieden; Carrier-Kapazitäten, konkrete Selektionslogik und DCS-Acceptance bleiben offen.


## 7. Production-Source-Readback 14.10.2026 – verbindlicher Reconciliation-Gate

Dieser Abschnitt ist ein **Quellcodebefund**, keine neue Runtime-Acceptance. Die in diesem Abschnitt genannten Dateien wurden auf dem FSSR-Branch gelesen; die fachliche Ground-/Air-Priorität kommt aus `docs/05-logistics.md` auf `main` (Commit `b348a589642e13f60ce7541e4820bd973dd848f5`).

### 7.1 ARTY-Continuation – konkret fehlende Verbindung

In `scripts/campaign/OMW_FireSupStratResupply_ProductionBootstrap.lua`:

- `resolveFunctionalOwner` erzeugt jeweils `ARTY:New(...)`, `SetWaitForShotTime(120)`, `Start()`, behält jedoch `maxEngagements=1` und `acceptedShots=4` bei.
- `resolveArtyTarget` verwendet ausschließlich `incident.context.physicalTargetGroup`, sofern lebendig, und liefert `shots=4, radiusM=50`; eine längerlebige C2-Target-Picture-/Retarget-Quelle ist hier **nicht** angeschlossen.
- `requestExternalSupport` erzeugt einen ARTY-Request-Key `INSTALLATION_ATTACK_C2_ARTY_INITIAL`. Dieser beschreibt einen initialen Demand, nicht automatisch weitere Fire Missions.
- `scripts/campaign/OMW_FireSupStratResupply_ArtySelectionRuntime.lua` setzt im `ARTY.OnAfterCeaseFire`-Hook `entry.completed=true`, führt `LEGION.UnRecruitAssets` aus und protokolliert „functional ARTY fire complete“. Es existiert an dieser Schnittstelle keine nachgewiesene neuerliche C2-Target-Picture-Auswertung oder Fortsetzungsaufforderung. Ein bestätigtes `CeaseFire` liefert dort zugleich **keinen** physischen `EVENTS.Shot`-Beweis.

**Notwendige Korrekturgrenze:** Vor der Wiederanbindung des Retarget-Cycles müssen die ursprüngliche autoritative `C2_FIRE_OBSERVATION`, deren lebende Zielgruppen und die alten `queueNextFireMission`-Ausführungspfade quellen- und acceptancebezogen nachgewiesen werden. Kein eigener zusätzlicher World-Scan oder eigenes Selektions-/Polling-Subsystem. Das aktuelle `OnAfterCeaseFire`-Release darf nicht mit einer zusätzlichen parallelen ARTY-Mission umgangen werden. Das physische `Shot`-Evidence-/No-Fire-Verhalten muss separat klassifiziert werden.

### 7.2 Lokaler Rearm – Vertrag vorhanden, Composition fehlt

`OMW_FixedFireSupportAmmoSupport.lua`, `OMW_FixedFireSupportAmmoRearmService.lua` und `OMW_GroundAmmoRearmAdapter.lua` existieren weiterhin. Der Rearm-Service erwartet eine Standort-/Warehouse-/Spawn-Zone-Konfiguration, einen Materializer, die echte ARTY-Instanz und CampaignState-Transaktionsdaten. Er kann `startArty=false` für den bereits laufenden Functional-Owner verwenden und nach bestätigtem MOOSE-Rearm das Rückführen des M1083 zum Warehouse koordinieren.

Im aktuell geprüften `ProductionBootstrap.lua` wird kein `FixedFireSupportAmmoRearmService.New` oder `FixedFireSupportAmmoSupport.New` aufgerufen. Die bereits erzeugten `state.artyOwners` werden nicht durch einen produktiv verdrahteten Rearm-Service ergänzt.

**Notwendige Korrekturgrenze:** Site-spezifische M1083-Templates, Spawnzonen, CampaignState-Node-IDs, Rearm-Schwellen/Mengen und Warehouse-Rückgabeverträge zuerst gegen `docs/moose/FIXED-FIRE-SUPPORT-REARM.md`, die Ground-Manifeste und die echte `.miz` prüfen. Vier separate Batterie-Services dürfen nicht unkontrolliert dasselbe MOOSE-Materialisierungsasset doppelt registrieren.

### 7.3 Strategic Resupply – Runtime vorhanden, Production-Descriptor fehlt

`ProductionBootstrap.buildResupplySpec()` aktiviert den Transportvertrag nur bei explizitem `config.resupply`. Er verlangt:

```text
resupply.selectSupportType(candidate, site, snapshot)
resupply.transport
resolveGroundTransport and/or resolveAirTransport
groundCommander / airCommander
CampaignState-backed store and resource rows
```

Ohne diesen Vertrag bleibt Resupply absichtlich deaktiviert. `OMW_FireSupStratResupply_ResupplyMonitor` besitzt keine eigene Scheduling-/Retry-/Bestandsautorität. `OMW_FireSupStratResupply_StorageTransportFactory` bildet physische `OPSTRANSPORT`-/STORAGE-Deskriptoren, wählt aber keine eigenen Carrier. Der bereits existierende `OMW_GroundAmmoResupplyExecutor` ist ein eigener akzeptierter AMMOSUPPLY-Ground-Execution-Pfad und **nicht** durch ein beliebiges `resolveGroundTransport` schon integriert.

**Notwendige Korrekturgrenze:** Für Ground muss geklärt werden, welcher akzeptierte MOOSE-Execution-Vertrag im FSSR-Production-Transport zur Anwendung kommt, ohne GroundAmmoResupplyExecutor und OPSTRANSPORT zu doppelten Transport-Ownern für dieselbe Cargo-ID zu machen. Für Air muss der produktive STORAGE-/Cargo-/FlightPath-Descriptor nachgewiesen werden. Die fachlich beschlossene Critical-vs-Regular-Priorisierung alleine ersetzt keine Transportfähigkeit, keine konkrete Lade-/Entladerepräsentation und keine quantitative Paket-zu-Carrier-Zuordnung.

### 7.4 Kein vorzeitiger PASS

Offene Tests vor technischem Abschluss:

1. Wiederholte physische ARTY-Missionen nach je vier Schuss, solange lebende autorisierte Ziele existieren und CAS nicht ON STATION ist.
2. Keine weitere neue ARTY-Mission bei CAS ON STATION; keine künstliche Unterbrechung einer laufenden Salve.
3. Fortress: `CeaseFire` ohne `Shot` darf nicht als erfolgreiches physisches Feuer gelten.
4. Vier Site-Batterien: realer M1083-Rearm mit derselben Functional ARTY, CampaignState-Verbrauch, Rückführung und Wiederaufnahme.
5. Reorder-Schwelle: echter `CampaignState`-Mangel, genau ein Shortage-Demand pro Episode, kein Fake-Stock.
6. Ground- und Air-Lieferung: echte physische Ankunft, Einmalgutschrift, Verlust-/Teil-Liefersemantik sowie keine doppelte Transportautorität.
7. Auswahl nach `main`-Policy für kritisch/regulär unter tatsächlicher Capacity-/Erreichbarkeitsprüfung.
8. Keine Regression bei bereits akzeptierter QRF, CAS-Korridoren, Flugzeug-Recovery und ARTY-Selection-only.

**Prüfstatus:** SOURCE_REVIEWED / RECONCILIATION_PENDING. Der Source-Readback allein rechtfertigt keine Änderung der laufenden Missionsdatei, keinen neuen Build-Hash und kein `VALIDATED`.


## 8. Production-Implementierung: opt-in M1083-Rearm-Komposition (14.10.2026)

**Source-Status: IMPLEMENTED / DCS_PENDING.** Die Production-Bootstrap-Source und der Production-Bootstrap-Builder wurden geändert. Der vorhandene funktionale ARTY-/Mörser-Fire-Control-Owner wird ausdrücklich beibehalten. Die A10-Module selbst bleiben unverändert und werden in das Production-Bundle eingebettet:

```text
OMW_GroundSupportMaterializer.lua
OMW_FixedFireSupportAmmoSupport.lua
OMW_GroundAmmoRearmAdapter.lua
OMW_FixedFireSupportAmmoRearmService.lua
```

### Lifecycle-Inheritance-Map

| Feld | Übernommener Vertrag |
|---|---|
| inherited_contract | MOOSE Local M1083 materialization → bestehender Functional ARTY `Rearm()` → CampaignState CONSUMED/COMPLETED → Rückkehr zum MOOSE Warehouse |
| accepted_source_paths | die vier unverändert eingebetteten Ground-Module sowie der bereits laufende `ARTY`-Owner |
| evidence | `docs/moose/FIXED-FIRE-SUPPORT-REARM.md`; Fixed Fire Support Rearm Acceptance 2-11; FSSR Production A10 als vorhandene Composition-Referenz |
| invariants | genau ein ARTY-Fire-Control-Owner pro Batterie; `startArty=false`; keine zweite Ressourcenhoheit; Materialisierung und Return-to-stock über MOOSE |
| reuse_mode | DIRECT_REUSE der vier Ground-Module plus MINIMAL_ADAPTER im Bootstrap |
| harness_role | spätere Acceptance triggert/observiert, besitzt aber weder Rearm-FSM noch Recredit |
| changed_boundary | optionale Creation pro MOOSE-materialisierter Fixed-Fire-Batterie und explizite Request-Weiterleitung |
| owner_approval | keine Änderung der akzeptierten Rearm-Lifecycle-Invarianten; neue Non-MOOSE-Parallelimplementierung wird nicht eingeführt |
| revalidation_scope | Builder-Bundling, MOOSE-Site-Warehouse/ZONE-Integration, vier physische M1083-Rearm-/Return-Lifecycles und CampaignState-Settlement |

### Produktionskonfiguration

Die Funktion wird **nicht automatisch aktiviert**. Optionaler Input:

```lua
OMW.FireSupStratResupplyProductionConfig.localArtyRearm = {
  BOSTICK = {
    nodeId = "GROUND_NODE_BOSTICK",
    supportZoneName = "ZON_BLUE_GND_BOSTICK_RESUPPLY",
    supportTemplateName = "TPL_BLUE_GND_SUP_M1083",
    platoonName = "PLT_FSSR_PROD_REARM_BOSTICK",
    assignment = "OMW:PROD:BOSTICK:AMMO-SUPPORT",
    carrierEntityId = "FSSR-BOSTICK-M1083",
    alias = "Bostick L118",
  },
}
```

Das ist **ein Konfigurationsschema und Beispiel, keine bestätigte `.miz`-Konfiguration**. Weitere Asset-Keys: `WRIGHT`, `FORTRESS`, `HONAKER`. `nodeId`, `supportZoneName`, `supportTemplateName`, `platoonName`, `assignment`, `carrierEntityId`, `alias` sind pro Eintrag Pflicht. Die Werte müssen aus der echten Mission und den CampaignState-/Warehouse-Baselines validiert sein; keine automatische Ergänzung aus A10-Testdaten.

Nach MOOSE-Materialisierung des definierten Fixed-Fire-Assets wird für den entsprechend konfigurierten Standort genau ein bestehender Rearm-Service aufgebaut. Ein fachlich autorisierter Caller kann über `OMW.FireSupStratResupplyProduction.RequestLocalArtyRearm(assetId, spec)` einen Request an den vorhandenen Service weitergeben. Dessen `transactionId`, `quantity`, `missionDemandId`, etwaige Rearm-Distanzen und die strategische Verfügbarkeit stammen ausdrücklich vom fachlich autorisierten Caller. `artilleryGroup` wird aus der vom MOOSE Asset Registry materialisierten Batterie gebunden, `startArty=false` erzwungen. Die Erstellung des Service löst **noch keinen Rearm** aus.

**Nicht implementiert:** Munitionsmangel-Ereignis/Threshold → Produktions-Request, ARTY-Continuation nach `CeaseFire`, neuer C2-Target-Resolver und Strategic Ground-/Air-Transportdescriptor. Diese Nachbarfunktionen benötigen ihren eigenen Reuse-/MOOSE-/Acceptance-Abgleich. Kein automatischer Scheduler zur Request-Erzeugung.

**DCS-Gate:** Der Builder und die Lua-Quellen sind noch nicht lokal gebaut oder in DCS geprüft. `OMW_FSSR_READY` kann deshalb aus dieser Source-Änderung nicht als erfolgreicher neuer Test interpretiert werden. Die Production-Bundle-Datei in der `.miz` darf nicht ohne echte Build-Hashes und gezielte Regression ausgetauscht werden.


## 9. ARTY-CeaseFire-/Loss-Eventbruecke (14.10.2026)

Der FSSR-Produktionsstand wurde um einen **optionalen, ereignisgebundenen Completion-Callback** erweitert. Dies ist eine minimale Schnittstelle zur Wiederanbindung des bereits vorgesehenen C2-Retarget-Lifecycles, **noch keine automatische ARTY-Continuation**.

`OMW_FireSupStratResupply_ArtySelectionRuntime.lua` bindet an den **bestehenden** MOOSE-Functional-ARTY-Owner (`OnAfterCeaseFire` und `OnAfterDead`). Erst nach `LEGION.UnRecruitAssets` ruft es `onFireMissionFinished(demand, context, entry, reason)` fuer diesen Fire-Mission-Handle genau einmal auf. Auch der Cancel-vor-Start wird als `CANCELLED_BEFORE_FIRE_START` signalisiert. Fehler des externen Listeners werden protokolliert, duerfen aber den MOOSE-FSM-Hook nicht zerstoeren. Ein `CeaseFire` bleibt nur ein MOOSE-FSM-Ereignis und ist **kein** unabhaengiger physischer `Shot`-Beweis.

Der Callback wird durch `OMW_FireSupStratResupply_ExternalSupportRuntime.lua` und die Production-Konfiguration `OMW.FireSupStratResupplyProductionConfig.onArtyFireMissionFinished` lediglich **weitergereicht**. Ohne diesen optionalen Callback bleibt die aktuelle Fire-Selection-Semantik unveraendert. Ein Listener darf keine eigenen MOOSE-Asset-Reservierungen, Zielscans oder parallelen ARTY-Owner einfuehren.

### Lifecycle-Inheritance-Map

| Feld | Reconciliation |
|---|---|
| inherited_contract | Ein Functional ARTY pro physischer Batterie, `AssignTargetCoord`, `OnAfterCeaseFire`, `LEGION.UnRecruitAssets` |
| accepted_source_paths | `OMW_FireSupStratResupply_ArtySelectionRuntime.lua`, `OMW_FobAttackFunctionalArtyDispatchAdapter.lua`, urspruenglicher C2-Fire-Observation-Pfad noch zu rekonstruieren |
| evidence | FSSR ARTY Selection A10/A12; historische Fire-Continuation nur als vergangene Testbeobachtung, nicht als Production-PASS |
| invariants | Selection-only MOOSE AUFTRAG; keine zweite ARTY-FSM, kein neuer Scheduler, keine ungepruefte Folgesalve |
| reuse_mode | MINIMAL_ADAPTER am bereits vorhandenen MOOSE-FSM-Hook |
| harness_role | einmalige Eventzustellung/Abbruch beobachten; physisches `EVENTS.Shot` getrennt nachweisen |
| changed_boundary | Optionaler Completion-/Failure-Callback mit Demand-/Context-/Owner-Korrelation |
| owner_approval | Keine geaenderte Feuerdoktrin; Zielauswahl und Fortsetzung verbleiben in der bisherigen C2-Verantwortung |
| revalidation_scope | Lua-Unit-Test fuer exactly-once und Cancel; DCS-Test von MOOSE-`CeaseFire`/`Dead` inkl. physischem Schussbeleg erforderlich |

**Offen:** Ein verbindlicher C2-Listener muss nach dem Event lebende autorisierte Gegner, CAS ON STATION, physische Munition, Pending-Rearm und geeignete MOOSE-Provider pruefen. Der historische `queueNextFireMission`-Pfad wurde inzwischen **im Stage-3-A2-Acceptance-Harness auf `main` lokalisiert**, ist aber **keine** vorhandene produktive C2-Komponente. Er darf gemaess Lifecycle-Preservation-Law nicht aus dem Harness kopiert und als bereits abgenommene Production-Continuation ausgegeben werden. Daher wird weder ein automatisches erneutes `RequestIncidentSupport` noch eine selbstentwickelte Ersatzschleife aktiviert. Ground-/Air-Strategic-Resupply bleibt unveraendert fail-closed ohne produktiven Transportdescriptor.

### 9.1 Historische Fire-Continuation-Quelle – nachtraeglich lokalisiert

`mission/tests/stage3-honaker-wright-full-response/src/a2/04-fire-support.lua` (auf `main`) enthaelt `selectNextFireTarget()`, `queueNextFireMission(demandId)` und die zugehoerige `onTargetComplete`-Bindung. `selectNextFireTarget()` stoppt neue Fire-Mission-Targets, wenn `state.casOnStation` gilt, liest zuerst `c2FireObservationGroups()`, faellt bei leerer Beobachtung auf `incidentGroups()` zurueck und schliesst zuvor bearbeitete Source-Gruppen durch `state.fireScheduledSourceGroups` aus. Die neue Zuweisung erfolgt mittels `state.fireAdapter:QueueTarget(demandId,target)`; der zugrundeliegende Functional-ARTY-Lifecycle wird nicht ersetzt.

Die groessere historische Source `mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua` weist zudem getrennt `EVENTS.Shot`, `verifyFireComplete` und `onFireRejected` nach. Das sind wichtige **Akzeptanz-Invarianten**, keine pauschale Production-Freigabe fuer deren fixturegebundene `state.*`-Tabellen oder eigene Beobachtungs-Schleifen.

**Verbindliche Naechste-Gate-Fragen vor echter Continuation:**

- Welche produktive MOOSE-OPSZONE/Incident-Instanz ist die autoritative C2-Zielquelle (nicht die Perimeter-Trigger-Zone)?
- Wie wird `CAS ON STATION` aus dem bestehenden CAS-Lifecycle bereitgestellt?
- Wie werden existierende physische Artilleriemunition, `OnAfterRearmed` und M1083-Request ohne erfundene Schwellwerte dem C2-Listener gemeldet?
- Soll der neue Demand aus dem bestaetigten Abschluss-Callback erzeugt werden oder muessen MOOSE-/MissionDemand-Callbacks zur Vermeidung reentranten Dispatches entkoppelt werden?
- Wie wird unabhaengige `EVENTS.Shot`-Evidenz je Functional-ARTY-Target abgebildet und ein FALSE-PASS bei Fortress verhindert?

Der bestehende Abschluss-Callback ist jetzt ein moeglicher **Reuse-Hook**. Alle Fragen beduerfen einer konkreten Quellen-/MOOSE- und Acceptance-Pruefung vor Production-Aktivierung; keine zusaetzliche Owner-Entscheidung ueber bereits gebilligte Grundsaetze wird unterstellt.


## 10. Base-Bundle-Readback und korrigierte Builder-Diagnostik (14.10.2026)

Der Projektinhaber hat fuer Source-HEAD `128ee20c19e418a9773f560e1df06db9f4fae6ab` beide Bundles lokal erfolgreich gebaut. Reale Konsole:

```text
Base Builder 34
Base Bundle SHA-256:
DCD4C788C8DBED6029383C45DA9F0ABB36ED77E71AA849ABD79324751F1D3B7F

Production Bootstrap Builder 5
Production Bundle SHA-256:
3DE95321470D48FDB7AB25C1169C6D7EFE32CFB8E2F642FF7317F839EC8D4BB4

MizMutation: false
```

Der Base-Builder 34 verlangte korrekt `ARTY-SELECTION-RUNTIME-2` und `EXTERNAL-SUPPORT-RUNTIME-4` als Source-/Bundle-Marker. Die Zeile `ArtySelectionRuntimeSchema: ...-1` war dagegen ein **statisch veralteter Diagnose-String**, kein Nachweis eines tatsaechlich eingebundenen alten Runtime-Moduls.

Der anschliessende Base-Builder 35 extrahiert die tatsächlichen `Runtime.SchemaVersion`-Werte aus den gebuendelten ARTY-Selection- und External-Support-Quellen und gibt beide aus. Die neue ARTY-Completion-Unit-Test-Suite behandelt `OnAfterCeaseFire`, fruehen Cancel, `OnAfterDead`, doppelte terminale Events und fehlerhafte externe C2-Listener. Diese Tests wurden als Source-Tests erweitert, aber noch **nicht lokal ausgefuehrt**.

**Ausstehend:** Build-35-Readback, Testausfuehrung und spaeter DCS. Der zuvor bestaetigte Build-34-Hash ist nicht fuer Builder 35 wiederzuverwenden. Keine neue `.miz`-Mutation, kein neuer DCS-PASS.


## 11. Lokaler Base-35-Build – reale Konsolenevidenz (14.10.2026)

Der Projektinhaber hat den FSSR-Branch auf Commit `a134022f80606d9c353869d1c11f365b2e8c6c24` synchronisiert und den Production-Base-Builder 35 erfolgreich ausgefuehrt. Die Konsole meldet `ArtySelectionRuntimeSchema: ...-2`, `ExternalSupportRuntimeSchema: ...-4` und der gesonderte Markercheck auf `onFireMissionFinished` im erzeugten Bundle ergibt PASS.

```text
GitCommit: a134022f80606d9c353869d1c11f365b2e8c6c24
BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-35
BuilderSHA256: 973820DF44D14F55D7A489739B28C64CC10988717C079AF4255239CB848B8118
BundleSHA256: 0CB17F45D44870F58D944EAE8B8F68A95BEF55845F2083FA0B65240236467909
MizMutation: false
```

Ein separater `Get-FileHash -Algorithm SHA256` bestaetigt exakt denselben Base-Bundle-Hash. `git status --short` enthaelt ausschliesslich das bereits existierende untracked Verzeichnis `mission/fire-support-strategic-resupply/`.

**Beweisgrenze:** Build und Marker sind bestaetigt; die ARTY-Unit-Tests und MOOSE-/DCS-Runtime sind dadurch **nicht** ausgefuehrt oder validiert. Es wurde kein neuer Trigger fuer die ARTY-Continuation aktiviert. Der C2-Quellenabgleich zeigt bereits die Incident-Quelle `sourceIncidentCoordinator:GetParticipants(true)` im bestehenden `InstallationIncidentBridge`; die CAS-On-Station-Quelle und die bewaffnete Wiederaufnahme muessen gesondert gegen den aktiven CAS-Lifecycle und bestehende Support-Lifecycle-Reservierungen geprueft werden. Keine parallele `C2_FIRE_OBSERVATION`-Weltabfrage, keine Annahme, dass Perimeter-Clear ein Missionsende ist.


## 12. SELBSTSTAENDIGE UEBERGABEAKTE – fortlaufend pflegen

### 12.1 Auftrag und Arbeitsmodus

**Konkreter Owner-Auftrag:** `Production-Reconciliation der ARTY-/Moerser-Continuation und der vorhandenen M1083-/Ground-/Air-Resupply-Lifecycles`. Der Projektinhaber hat zusaetzlich angewiesen, **jeden Arbeitsschritt so zu dokumentieren, dass jederzeit ein anderer Chat ohne Informationsverlust uebernehmen kann**. Dieses Dokument ist die fortzufuehrende Handoff-Datei. Nicht nur die Ergebnisse, sondern auch abgewiesene Ansaetze, Fehlannahmen, Source-Luecken, lokale Testdaten, exakte Commits und verbleibende Blocker sind hier zu pflegen.

Repository: `birkenmoped/Operation-Mountain-Watch`.
Aktiver Arbeitsbranch: `agent/fire-support-strategic-resupply-production-bootstrap`.
Letzte reale Nutzer-Verifikation: `git pull --ff-only` bis `56f566d9d12f6ab64c434384654ee280577fc2ad`, danach `Get-FileHash` dieses Handoffs SHA-256 `D70C705619998A36F25B88F7B57D02624151FCDEE338D8FCF08A869F1EF044CB`. Anschliessend wurde fuer die **vorliegende** Fortsetzung zunaechst nur eine weitere Quellenpruefung durchgefuehrt; der neue Handoff-Commit wird aus der GitHub-Toolantwort entnommen und dem Projektinhaber zur lokalen Verifikation mitgeteilt, nicht vorweg angenommen.

Lokaler Nutzer-Worktree: `P:\DCS-DEV\Operation-Mountain-Watch-fssr-production-bootstrap`. Das Verzeichnis `mission/fire-support-strategic-resupply/` existiert untracked und wurde bewusst **nicht** geloescht, bewegt oder versioniert. Die `.miz` nicht stillschweigend veraendern.

### 12.2 Verbindliche Normen und Abhaengigkeiten – zuerst pruefen

Autoritaetsreihenfolge laut `docs/00-project-governance.md`:
`main`-Owner-Entscheidung / `BINDING` -> belegter exakter DCS-Acceptance-Stand -> Manifeste -> Handoffs -> historische Quellen. Pflichtdateien:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md
docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md
docs/moose/FIXED-FIRE-SUPPORT-REARM.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE.md
docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-MONITOR.md
docs/05-logistics.md                              [main: binding Abschnitt 2.1]
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-12.md
```

MOOSE-first, gepinnter Referenzstand **2.9.18**, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, `Moose.lua` SHA-256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`. Neue MOOSE-Klassen/-Methoden muessen gegen die tatsaechlich gebundelte `Moose.lua` verifiziert werden, nicht anhand von vermuteten APIs. CampaignState ist alleinige strategische Ressourcenautoritaet; MOOSE besitzt physische Assetwahl und FSM-Lifecycles. Neue Native-DCS- oder Parallelimplementierungen beduerfen ausdruecklicher Owner-Freigabe. Code/Identifiers/Logs/Commits Englisch; Design-Dokumentation Deutsch. Kein CODEX. PR-/Merge-/MIZ- und DCS-Acceptance-Gates beachten.

### 12.3 Source-Karte / unveraenderte akzeptierte Module

| Verantwortlichkeit | Aktuelle Source / Nachweis | Verbindliche Grenze |
|---|---|---|
| Production-Einstieg | `scripts/campaign/OMW_FireSupStratResupply_ProductionBootstrap.lua` | Bootstrap-5; kein Testfixture / kuenstlicher Bestand |
| Generische Base | `scripts/campaign/OMW_FireSupStratResupply_Runtime.lua` | Runtime-13; per `p.New(...)` komponiert |
| Physische ARTY-Registrierung | `scripts/campaign/OMW_FireSupStratResupply_ArtyRealAssetRegistry.lua` | Vier feste Batterien; MOOSE BRIGADE/PLATOON; Selection-only, keine zweite Mission |
| Funktionales ARTY-Feuer | `scripts/campaign/OMW_FireSupStratResupply_ArtySelectionRuntime.lua` | Schema 2; `AssignTargetCoord`; `OnAfterCeaseFire`-/`Dead`-Abschlussnotifikation genau einmal |
| Externer C2-Support | `scripts/campaign/OMW_FireSupStratResupply_ExternalSupportRuntime.lua` | Schema 4; optionalen ARTY-Finish-Callback weiterreichen |
| Incident-Zielautoritaet | `scripts/campaign/OMW_FireSupStratResupply_InstallationIncidentBridge.lua` | `incident.context.sourceIncidentCoordinator:GetParticipants(true)` |
| Incident-/Demand-Semantik | `scripts/campaign/OMW_FireSupStratResupply_Base.lua` | `RequestIncidentSupport` dedupliziert nach `requestKey`, `Cancel`/Incident-Close nicht mit physischen Lifecycle-Enden verwechseln |
| CAS-Status | `scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua` | `entry.executing`, `releaseRequested`, `homeLanded`, `assetReturned`; **kein verifizierter produktionstauglicher On-Station-Status-Resolver fuer ARTY** |
| Local M1083 materialisieren | `scripts/ground/OMW_GroundSupportMaterializer.lua`; `OMW_FixedFireSupportAmmoSupport.lua` | BRIGADE/PLATOON/WAREHOUSE; keine zweite SPAWN-Implementierung |
| Local M1083 rearmen | `scripts/ground/OMW_FixedFireSupportAmmoRearmService.lua`; `OMW_GroundAmmoRearmAdapter.lua` | Ein Functional-ARTY-Owner, `startArty=false`; `OnBeforeRearm`/ `OnAfterRearmed` bindet CampaignState |
| Strategische Shortage | `scripts/campaign/OMW_ResourceDemandPolicy.lua`; `OMW_FireSupStratResupply_ResupplyMonitor.lua` | Ereignis-/Aufrufer-gesteuerte `EvaluateAll` oder `EvaluateRow`; ein Demand pro Shortage-Episode |
| Ground-Versorgung | `scripts/ground/OMW_GroundAmmoResupplyExecutor.lua` | akzeptierter `AUFTRAG:NewAMMOSUPPLY`-Pfad; nicht parallel zu zweitem OPSTRANSPORT-Owner verwenden |
| Ground-/Air-Transport | `scripts/campaign/OMW_FireSupStratResupply_ResupplyTransportRuntime.lua`, `OMW_FireSupStratResupply_StorageTransportFactory.lua`, `OMW_FireSupStratResupply_TransportSettlement.lua` | MOOSE `OPSTRANSPORT`/`STORAGE`; produktiver Descriptor fehlt |
| Alter Fire-Continuation-Test | `mission/tests/stage3-honaker-wright-full-response/src/a2/04-fire-support.lua` | `queueNextFireMission` / `selectNextFireTarget`; **Test-Harness**, kein kopierbarer produktiver C2-Owner |

### 12.4 Bewiesener lokaler Buildstand (nicht DCS-validiert)

Vom Nutzer selbst in PowerShell geliefert:

```text
Local verified HEAD: a134022f80606d9c353869d1c11f365b2e8c6c24
Builder: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-35
Builder SHA-256: 973820DF44D14F55D7A489739B28C64CC10988717C079AF4255239CB848B8118
Base bundle SHA-256: 0CB17F45D44870F58D944EAE8B8F68A95BEF55845F2083FA0B65240236467909
ArtySelectionRuntimeSchema: ...-2
ExternalSupportRuntimeSchema: ...-4
Base bundle contains onFireMissionFinished: PASS
MizMutation: false
```

Letzter ebenfalls real bestaetigter Production-Bootstrap-5-Build im selben vorangegangenen Feature-Stand (exakter vorheriger HEAD `128ee20c19e418a9773f560e1df06db9f4fae6ab`):

```text
Bootstrap Builder SHA-256: B951D52BFE99793317ED7B80C6005B744F9A2C18EAAF3AE532AC70E932E1B40A
Production bundle SHA-256: 3DE95321470D48FDB7AB25C1169C6D7EFE32CFB8E2F642FF7317F839EC8D4BB4
MizMutation: false
```

Diese beiden Bundle-Hashes sind **nicht als gemeinsamer neu erzeugter Bundle-Satz am selben Commit** nachgewiesen. Vor einer DCS-Acceptance beide Bundles auf demselben finalen Source-HEAD erneut bauen und real hashen. Der Head `56f566d9...` hat nur Dokumentation geaendert. Alte DCS-Aufzeichnungen mit frueheren Bundles (Abschnitte 1–6) nicht auf diese Builds hochrechnen. Unit-Test-Ausfuehrung bislang **nicht** durch lokale Ausgabe belegt.

### 12.5 Fachlicher Soll-Vertrag, ohne Policy-Neuerfindung

```text
authentischer Installation-Incident / C2-Gefechtsraum
  -> lebende autorisierte RED-Ground-Ziele
  -> physischer CAS-ON-STATION-Status (keine neue ARTY-Aufnahme)
  -> MOOSE COMMANDER rekrutiert verfuegbare geeignete Batterie
  -> bestehender Functional ARTY:AssignTargetCoord(...; kurze Salve)
  -> MOOSE Fire-Completion + unabhaengiges EVENTS.Shot
  -> nach MOOSE Release erneut autorisierte C2-Bedarfs-/Zielentscheidung
  -> physische Munition? ja: naechste begrenzte Fire Mission
  -> Nachladen noetig? bestehender lokaler M1083-Rearm-Request
       -> MOOSE Rearm/OnAfterRearmed
       -> CampaignState CONSUMED/COMPLETED
       -> M1083 Warehouse ReturnToStock
       -> C2-Continuation nur sofern weiterhin Bedarf und CAS frei
  -> lokaler strategischer Ressourcenmangel:
       ResourceDemandPolicy -> ResupplyMonitor
       -> reale Ground-/Air-Transportausfuehrung
       -> bestaetigte physische Lieferung
       -> genau ein CampaignState-Credit
```

Die `main`-Policy `docs/05-logistics.md` Abschnitt 2.1 (Commit `b348a589642e13f60ce7541e4820bd973dd848f5`) ist freigegeben: **kritische Versorgung: rechtzeitiger Lufttransport vor Kosten, Ground-Fallback/Ergaenzung; regulare Versorgung: Kosten/Kapazitaet vor Geschwindigkeit**. Keine frei erfundenen CH-47/C-130/Konvoi-Kapazitaeten, keine eigenmaechtige Umrechnung `GROUND_AMMO_PACKAGE` in physische Tonnen oder Ladevolumen.

### 12.6 Source-Review dieser Fortsetzung: C2 und CAS – nachgewiesen/offen

**Nachgewiesen:** `InstallationIncidentBridge:OnIncidentStarted` uebernimmt `sourceIncidentCoordinator` in den Base-Incident-Kontext. `CasLifecycleRuntime` liest denselben `GetParticipants(true)`-Bestand fuer Supported-Element-Clear. Das wiederverwendbare API-Zielbild existiert also. Ebenso `CasLifecycleRuntime:GetState(demandId)` und `GetStateByMission(mission)`.

**Nicht nachgewiesen:** `entry.executing=true` ist noch kein belastbarer geografisch/zeitlich qualifizierter physischer `CAS ON STATION`-Nachweis. Die schon vorhandene `CasLifecycleRuntime` muss dafuer quellen- und MOOSE-konform analysiert werden. Mehrere CAS-Demands/AOs koennen ueberlappen; weder `releaseRequested` noch eine einzelne Site-Demand-ID bilden automatisch die gesamten Kampfzonenbelegungen ab. Vor neuer ARTY-Continuation muss ein **autoritatives** read-only Deconfliction-Signal an die C2-Entscheidung angeschlossen werden. Ein zusaetzlicher staendiger Enemy-World-Scan ist nicht erlaubt.

**Nachgewiesen:** `Base:RequestIncidentSupport(incidentId, "ARTY", {requestKey=...})` ist pro Request-Key dedupliziert. Der initiale Key `INSTALLATION_ATTACK_C2_ARTY_INITIAL` darf also nicht fuer alle weiteren Salven wiederverwendet werden. Neue Cycle-Keys beduerfen einer kollisionsfreien, fachlich an autorisierter Fire-Mission-/Demand-Identitaet gebundenen Regel.

**Nicht nachgewiesen:** Der aus der A2-Harness `queueNextFireMission` uebernommene Anti-Double-Engagement-Set-Mechanismus ist kein produktiv genehmigter alleiniger Target-Resolver. Der historische `EVENTS.Shot`-Nachweis muss fuer die aktuellen MOOSE-ARTY-Targets erhalten bleiben, sonst droht Fortress erneut `CeaseFire` ohne physischen Feuerbeleg. Kein unbegrenztes Retry bei gescheitertem Schuss/Provider.

**Nachgewiesen:** Bootstrap-5 kann bei vorhandener `config.localArtyRearm[assetId]` einen vorhandenen `FixedFireSupportAmmoRearmService` konfigurieren und `RequestLocalArtyRearm(assetId, spec)` durchleiten. Ohne gueltige Standortkonfiguration und autorisierten Request geschieht nichts. Die automatische Munitions-/Rearm-Ausloesung **ist nicht implementiert**. Die benoetigten Zonen `ZON_BLUE_GND_{BOSTICK,WRIGHT,FORTRESS,HONAKER}_RESUPPLY` sind aus A10 bekannt, muessen jedoch gegen die aktuell verwendete `.miz` geprueft werden. Ground- und Air-Strategic-Resupply sind weiterhin fail-closed, sofern nicht gezielt physische Deskriptoren injiziert werden.

### 12.7 Naechste Arbeitspakete mit eindeutigen Exit-Gates

| Prioritaet | Auftrag | Nachweis fuer Abschluss |
|---|---|---|
| P0 | Vollstaendiger Readback des funktionierenden A2-Feuerpfades, der autoritativen Incident-C2-Quellen und des CAS-Lifecycles | Lebenszyklus-Inheritance-Map + gepruefte MOOSE-FSM-/API-Signaturen; kein neuer Target-Scan |
| P0 | Genauen ARTY-C2-Continuation-Kontrakt dokumentieren: laufender Demand, neuer Cycle-Key, pro Fire-Mission Exactly-once, physische Shot-Evidenz, Selbstverteidigungsprioritaet, CAS-Sperre | deterministische Tests fuer 2+ Salven, No-Shot, Provider busy, CAS On Station, Incident close und Reentranz |
| P1 | C2-Reconciliation **als kleine Production-Composition**, nicht im Acceptance-Harness, an den bereits existierenden Completion-Hook anschliessen | Source Diff, Unit-Tests, lokaler Base/Bootstrap-Build; DCS mit Honaker/Wright/Joyce/Fortress |
| P1 | Lokal-Rearm-Ausloeser an bestaetigte physische Ammo-/Mangel-Evidenz anbinden; vorhandene M1083-Services viermal konfigurieren | Mission-Editor-Template/Zonen, MOOSE Rearm/Return, idempotente CampaignState-Buchungen, Wiederaufnahme nach Rearm |
| P2 | Ground-/Air-Resupply auf produktive SOURCE-/STORAGE-Deskriptoren und geeignete Routen reconciliieren | keine doppelte Transporthoheit; End-to-end Ground und Air einschliesslich Carrier-Rueckkehr |
| P2 | Shortage-Priorisierung kritisch/regulaer gemaess bindendem `main`, erst nach Kapazitaetsbeleg | Tests beider Prioritaeten, Fallback, fehlende Assets, idempotentes Settlement |
| P3 | A12-/Produktions-Acceptance real in DCS | identischer Commit/Build/Bundle/Miz/MOOSE/DCS-Nachweis; Logs/Events/Hashes; `VALIDATED` nur dann |

**Bei unbekanntem Source-Vertrag nicht raten.** Kein neues `ARTY:New`, keine parallel neu geschriebene `NewAMMOSUPPLY`-/`OPSTRANSPORT`-Lifecycle-Steuerung, keine stillschweigende MIZ-Bearbeitung. Neue Architektur-/Nicht-MOOSE-Ausnahme immer erst dem Projektinhaber vorlegen. Beibehalten: QRF/CAS-/Warehouse- und Ground-Road-Acceptance-Invarianten, unabhaengiges CAS-Multiflight-Engagement nicht ohne Evidenz filtern.

### 12.8 Verifikationsprozess und Chatwechsel-Regel

ChatGPT erledigt per GitHub-App: Source lesen, minimal implementieren, vollstaendigen Diff pruefen, Dokumentations-/Moose-Class-Index bei neuer MOOSE-Nutzung pflegen, Tests soweit tatsaechlich ausfuehrbar, committen und remote pushen. Nur **nach** Remote-Commit erhaelt der Projektinhaber **eine nummerierte PowerShell-Anweisung** fuer `git pull`, die relevanten Builder, Hash-Abgleich und `git status --short`. Der Projektinhaber sendet die echte Ausgabe; neue Builds/Hashes/DCS-Runtime niemals erfinden. Die lokale PowerShell-Execution-Policy hat zuvor `& .\tools\...` verhindert; akzeptierter, real erfolgreicher Weg war `powershell.exe -NoProfile -ExecutionPolicy Bypass -File '.\tools\<builder>.ps1'`. Das aendert nicht systemweit die Execution-Policy.

Vor jedem weiteren Chatwechsel hier eintragen: Source-Branch, Remote-HEAD, geaenderte Dateien, verwendete MOOSE-Fundstelle/Signatur, Tests (ausgefuehrt vs. nur geschrieben), reale Nutzer-Build-Hashes, Status DCS, Risiken und den **naechsten unmittelbaren Auftrag**. Die `source_commit`-Metadaten des Original-Handoffs sind historische Herkunft und muessen nicht so umgedeutet werden, als waeren sie der aktuelle Build.

**Sofortiger Fortsetzungssatz fuer einen neuen Chat (mit Scope):**

> Arbeite auf `agent/fire-support-strategic-resupply-production-bootstrap`. Lies vollstaendig `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, `docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md` und `docs/handoffs/2026-10-14-fssr-production-reconciliation.md` (insbesondere Abschnitt 12). Gleiche aktuellen Remote-HEAD und Source gegen das Handoff ab. Setze die ARTY-/Moerser-Continuation und lokale M1083-/Ground-/Air-Resupply-Reconciliation MOOSE-first fort. Baue keinen parallelen Targeting-/Transport-/Rearm-Lifecycle; implementiere nur mit nachgewiesenem C2-/CAS-/Shot-/Ammo-Vertrag. Dokumentiere Entscheidungen, Aenderungen, Tests und reale Hashes nach jedem Schritt in derselben fortlaufenden Uebergabedatei. Aendere keine `.miz` ohne erforderliche Owner-Freigabe; keine DCS-PASS-Behauptung ohne realen Test; kein CODEX.


## 13. Source-Schritt: physische CAS-AO-Belegung als read-only C2-Adapter (15.10.2026)

**Auftrag und Anlass:** Der Projektinhaber bestaetigte am 15.10.2026 den vorigen Handoff-Commit `94f6a6bf8d2892ab39de582c6c165d7f477ccf2a` durch einen realen `git pull --ff-only`, korrekten HEAD-Readback sowie den SHA-256-Hash
`5E7FE52AE41A2D9C619553AFB3BE8474A83E21A403751CDF1386D02108488E8D`. Das untracked Verzeichnis `mission/fire-support-strategic-resupply/` wurde unveraendert beibehalten.

**Ziel dieser Source-Aenderung:** Ein bereits existierendes CAS-Flight im fuer eine ARTY-Zielkoordinate relevanten MOOSE-AO nachweisen, ohne die bisherige CAS-FSM, Missionsbelegung, PATROLZONE, taktische Korridore, Release, RTB oder Ressourcenhoheit zu veraendern.

**Produktive Source:** `scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua`, Schema 2. Neue **read-only** Methode `Instance:IsOnStationAt(coordinate)`:
- durchsucht ausschliesslich bereits im CAS-Lifecycle registrierte Missions-`entry`-Objekte;
- verwendet die existierende MOOSE-`_omwFssrCasGeometry.zone:IsCoordinateInZone(...)` fuer **Zielkoordinate und physische Flight-Koordinate**; keine selbstgeschriebene Zonen-/Geometrielogik;
- liefert `true, "CAS_PHYSICALLY_IN_SHARED_AO", demandId` fuer physisch im relevanten Einsatzraum befindliche CAS-Flights;
- liefert `nil, "CAS_AO_PRESENCE_UNRESOLVED"`, wenn fuer einen potentiell relevanten aktiven Flight der physische Ort bzw. die Zone nicht eindeutig abfragbar ist;
- liefert `false, "NO_CAS_PHYSICALLY_ON_STATION"`, wenn keine aktive und physisch dort bestaetigte CAS-Belegung festgestellt wird;
- ignoriert `releaseRequested` **nicht**, solange der Flight physisch noch im AO sein kann: ein angeforderter RTB-/Release ist kein physischer Egress oder Return;
- beruehrt keinen ARTY-Dispatch. Es gibt keinen neuen Scheduler, keine Kuenstliche `CAS_ON_STATION`-Flag-Autoritaet und keine Aenderung am CAS-Lifecycle.

**MOOSE-First / Lifecycle-Inheritance-Map:**

| Feld | Nachweis |
|---|---|
| inherited_contract | bereits verwendete `CasLifecycleRuntime`-MissionEntry und `MOOSE ZONE:IsCoordinateInZone`, `FLIGHTGROUP:GetCoordinate`; MOOSE uebernimmt Flugbetrieb und FSM |
| accepted_source_paths | `OMW_FireSupStratResupply_CasLifecycleRuntime.lua`, `OMW_HelicopterCasTacticalCorridor.lua`, Binding-Abschnitt im CAS-Lifecycle |
| evidence | bisherige CAS-Route-/Recovery-Acceptances gelten nur fuer urspruengliche Provenienz; neuer Occupancy-Adapter **DCS_PENDING** |
| invariants | OnAfterOpsOnMission/Flight-Binding, Route, Detektion, taktischer Release, Landung und LegionReturn unveraendert |
| reuse_mode | MINIMAL_ADAPTER: lesender Accessor der bestehenden Mission- und Flight-Referenzen |
| harness_role | nur False/True/Unknown-Beobachtung, keine eigene Dispatch-/Recovery-FSM |
| changed_boundary | physisch belegter gemeinsamer CAS-AO als getrenntes C2-Lesesignal |
| owner_approval | keine neue Non-MOOSE-/DCS-Abweichung, keine taktische Semantikaenderung |
| revalidation_scope | Unit-Test des CAS-AO-Belegungs-Accessors; DCS-Test mit zwei Fluegen ueber benachbarten AOs, Egress, Positionsunbekannt und Retour |

**Builder:** `tools/build-fire-support-strategic-resupply-production-base.ps1` Version 36 erfordert `CAS-LIFECYCLE-RUNTIME-2` und gibt das Quellen-Schema anstelle einer hartkodierten Diagnose aus. Die Tests in `tests/mission-demand/test_fire_support_strategic_resupply_cas_lifecycle_runtime.lua` ergaenzen physische AO-Belegung, unbekannte Flight-Koordinate und den Zeitraum zwischen Release und wirklicher Rueckkehr. **Source implementiert; Tests/Build/Hashes/DCS erst durch reale Ausgaben nachweisen.**

**Ausdruecklich noch offen:** Der neue Accessor wird von der ARTY-Continuation noch **nicht** aktiv verwendet. Insbesondere muessen physische Schuss-Evidenz, autorisierte Zielauswahl, MissionDemand-Cycle-Key, Reentranzschutz und M1083-Rearm-Completion vor automatischem Folgefeuer verbunden werden. Die dreiwertige CAS-Antwort `nil` darf spaeter **niemals** als Freigabe zum Schiessen interpretiert werden. Die Methode ist ein abgrenzbarer Teil der Integration, kein Full-Response-/Fire-Continuation-PASS.

### 13.1 Unmittelbare Uebergabeanweisung fuer den naechsten Chat

Arbeite auf `agent/fire-support-strategic-resupply-production-bootstrap`, lies Abschnitt 12 **und Abschnitt 13** dieser Datei sowie Governance und Accepted Lifecycle Law. Ermittle den aktuellen Remote-HEAD vor jeder Aenderung. Fuehre die Completion-Reconciliation nach der realen Builder-/Testausgabe fuer Base 36 fort, indem du zuerst den bereits genehmigten C2-Target- und `EVENTS.Shot`-Quellenvertrag mit dem neuen read-only CAS-AO-Belegungssignal kombinierst. Kein direktes `CeaseFire -> neuer ARTY-Dispatch` ohne Shot- und CAS-Beweis; vorhandene M1083-Rearm-Services weiterverwenden. Dokumentiere jeden Schritt hier mit Commit, Source, Tests, Hashes, Risiken, offenem Schritt und ggf. DCS-Provenienz. Kein CODEX, kein eigenmaechtiges `.miz`-Edit, keine erfundenen Tests.


## 14. Base-36-Build-Fehler: reproduzierbarer Marker-Mismatch und Hotfix (15.10.2026)

**Originalbefund aus der realen PowerShell des Projektinhabers** nach `git pull --ff-only` auf Remote-HEAD `884d8e7012c34558c6bd62df8f2dba66fe1591b9`:

```text
ExpectedCommit / ActualCommit:
884d8e7012c34558c6bd62df8f2dba66fe1591b9

BuilderVersion: geplant Production Base 36
Bundle marker missing: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1
PowerShell: FSSR Production Base build failed
Post-error marker check:
Missing Production Base marker: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-2
Post-error Get-FileHash:
0CB17F45D44870F58D944EAE8B8F68A95BEF55845F2083FA0B65240236467909
Handoff SHA-256:
BD2D9E593CE9BF88C7F5A87BF7FDC5088ED7608A12BB8F5CD26DDE165236184D
git status --short:
?? mission/fire-support-strategic-resupply/
```

**Einordnung:** Der Base-36-Builder akzeptierte in seinem **Source-Contract-Marker-Set** bereits `...CAS-LIFECYCLE-RUNTIME-2`, verlangte aber **weiter hinten im separaten Bundle-Marker-Set** weiterhin `...-1`. Das fuehrte nach Assembly und vor der finalen Ausgabe zu einem absichtlichen `throw`; kein neues Bundle wurde geschrieben. Der danach abgefragte SHA-256 war exakt der bereits bekannte **Base-35-Bundle-Hash**, also ein Altartefakt, **kein** fehlgeschlagener/teilweise erfolgreicher Base-36-Build. Das ausgegebene `PASS: CAS occupancy integration present in Base bundle` wurde vom Nutzer trotz vorheriger `throw`-Anweisungen manuell erreicht und ist in diesem Fehlerlauf **kein gueltiger PASS**. Die Source-Schemata selbst blieben `CAS-LIFECYCLE-RUNTIME-2`.

**Korrektur:** `tools/build-fire-support-strategic-resupply-production-base.ps1` verlangt nun in **beiden** Marker-Listen `CAS-LIFECYCLE-RUNTIME-2`; der Builder wurde auf **Production Base 37** erhoeht. Kein CAS-Lifecycle-/ARTY-/M1083-Lua-Verhalten ist durch diesen Hotfix geaendert worden. Die Vollstaendigkeit der Build-Diagnostik wird weiterhin nach realem lokalen Durchlauf belegt, nicht vorab behauptet.

**Verifikations-Gate:** Projektinhaber zieht den neuen Remote-HEAD und fuehrt **nur den Base-37-Builder** mit `powershell.exe -NoProfile -ExecutionPolicy Bypass -File` aus. Bei Build-Exitcode ungleich Null sofort Stop; keine Marker- oder Hash-Pruefung alter `dist`-Dateien als PASS interpretieren. Nach Erfolg: `CAS-LIFECYCLE-RUNTIME-2`, `IsOnStationAt`, `CAS_PHYSICALLY_IN_SHARED_AO`, `CAS_AO_PRESENCE_UNRESOLVED` im Bundle suchen und `Get-FileHash -Algorithm SHA256` neu aufzeichnen. Die lokal vorhandene untracked `mission/fire-support-strategic-resupply/`-Struktur **nicht bereinigen**.

**Unveraendert ausstehend:** Lua-Unit-Tests und DCS-Acceptance fuer CAS-On-Station, ARTY-Continuation, M1083-Rearm und strategische Ground-/Air-Resupply. Dokumentations- und Source-Hotfix ist nicht gleich DCS-VALIDATED. Der naechste neue Chat muss **Abschnitt 12, 13 und 14** lesen; nach jedem weiteren Lauf die reale SHA-256-Provenienz und eventuelle Fehlversuche hier anfuegen.


## 15. Production Base 37 – durch Projektinhaber lokal verifizierter Build (15.10.2026)

**Reale Nutzerkonsole:** `git pull --ff-only` aus `P:\DCS-DEV\Operation-Mountain-Watch-fssr-production-bootstrap` holte den Hotfix per Fast-Forward von `884d8e70` auf `9e7e54a7`. `ExpectedCommit` und `ActualCommit` waren identisch:

```text
GitCommit:
9e7e54a7e65ab1d91630a751c4fe2a0e0ecaf793
BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-37
BuilderSHA256:
C2BE8BF4801BD0A65BBC4E274DA9D24F1D946D7B068BFE811A8F27B1C7C3376C
BundleSHA256:
4D58402067C95E116A76EEFCFC437FA92278D03000FAA111D6F73F7FE4D38EF4
HandoffSHA256 (lokales Dokument vor diesem neuen Anhang):
B4E4859C43F541CB14CB4F2BFB869F368AC462FD524E056B8780F62411A2281F
MizMutation: false
```

Der Builder lief diesmal erfolgreich durch. `ArtySelectionRuntimeSchema: ...-2`, `ExternalSupportRuntimeSchema: ...-4` und `CasLifecycleRuntimeSchema: ...-2` wurden ausgegeben. Der anschliessende gebuendelte Markercheck fuer `CAS-LIFECYCLE-RUNTIME-2`, `IsOnStationAt`, `CAS_PHYSICALLY_IN_SHARED_AO` und `CAS_AO_PRESENCE_UNRESOLVED` meldete:

```text
PASS: Production Base 37 CAS occupancy markers verified
```

Ein **separates** `Get-FileHash -Algorithm SHA256` bestaetigte den identischen Bundle-Hash `4D58402067C95E116A76EEFCFC437FA92278D03000FAA111D6F73F7FE4D38EF4`. Das alte Base-35-Artefakt ist dadurch fuer diese lokale Build-Pruefung ersetzt. `git status --short` zeigte ausschliesslich das untracked generierte Verzeichnis `mission/fire-support-strategic-resupply/`, das unveraendert erhalten bleiben muss.

**Praezise Beweisgrenze:** Die lokalen Builds, Schemata und Marker sind jetzt `BUILD_VERIFIED` fuer diesen **exakten** Commit. Der Produktions-Callback `onArtyFireMissionFinished`, die CAS-AO-Methode und M1083-Rearm sind damit noch **nicht** im DCS-Verhalten validiert. Die geaenderten Lua-Unit-Tests sind aus dieser Konsolenausgabe ebenfalls **nicht** ausgefuehrt. Eine physische `EVENTS.Shot`-Evidenz, autoritative C2-Continuation, CAS-Deconfliction als aktive Feuerfreigabe sowie Rearm/Transport-Settlement bleiben offen.

**Naechste Arbeit:** Quellengepruefte Verbindung zwischen `GetParticipants(true)`, belegter physischer Schusszahl, `CasLifecycleRuntime:IsOnStationAt` und den bestehenden MOOSE-ARTY-Selection-/Rearm-Lifecycles. Vor Umsetzung die Event-/FSM-Signaturen und die fehlenden Release-/Retarget-Invarianten gegen die gepinnte MOOSE-Source und die akzeptierten Stage-3-Quellen nachweisen; keine zweite Zielerfassung, kein pauschales `CeaseFire -> neue Salve`, kein Scheduler-Ersatz. Die Dokumentation weiterhin nach **jedem** technischen Schritt mit Branch, Commit, Source, Testergebnissen, echten lokalen Hashes und naechstem Gate fortschreiben.

**Neuer Chat:** Vor jeglicher Arbeit insbesondere Abschnitte 12 bis 15 dieser Datei lesen; lokaler Buildstand Base 37 ist real, DCS-PASS ist es nicht.


## 16. ARTY-Events.Shot / CeaseFire-Reconciliation – Source-Schritt (15.10.2026)

### 16.1 Ausgangslage und reale lokale Provenienz

Der Projektinhaber hat die letzte dokumentarische Synchronisierung auf `1759ada43be0c78f4dc40836771931df1c0cb52f` real mit `git pull --ff-only` und Commit-Abgleich bestaetigt; SHA-256 des Handoffs nach diesem Pull:
`A67FD58532F7B72A064858F11F02CC65BC433659000A0DDA021ADCF10FB5EA82`.
Die letzte **real durch den Owner lokal buildverifizierte** FSSR-Base bleibt `Production Base 37` auf Commit `9e7e54a7e65ab1d91630a751c4fe2a0e0ecaf793`; Base-Bundle-SHA-256 `4D58402067C95E116A76EEFCFC437FA92278D03000FAA111D6F73F7FE4D38EF4`, Builder-SHA-256 `C2BE8BF4801BD0A65BBC4E274DA9D24F1D946D7B068BFE811A8F27B1C7C3376C`. Der Dokumentations-Commit `1759ada4...` erzeugte kein neues Bundle. `mission/fire-support-strategic-resupply/` bleibt untracked/erhaltenswert.

### 16.2 Gepinnte MOOSE-API und akzeptierte historische Quelle

Gepinnte `Moose.lua` 2.9.18, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, lokaler Source-Readback:
- `ARTY:OnEventShot(EventData)` etwa Zeile **97517**: `EventData.IniGroupName`, `self.groupname`, `self.currentTarget` und `self.Nshots`; nur die eigene lebende Gruppe und das aktuelle MOOSE-Target zaehlen als ARTY-Schussereignis.
- `ARTY:onafterOpenFire(..., target)` etwa Zeile **98307** setzt `self.currentTarget = target`.
- `ARTY:onafterCeaseFire(..., target)` etwa Zeile **98387** bearbeitet den Abschluss, ohne eine physische Schusszahl als separate OMW-C2-Autoritaet zu beweisen.

Die urspruengliche Stage-3-A2-Acceptance `mission/tests/stage3-honaker-wright-full-response/src/a2/04-fire-support.lua` hat diesen Guard bereits eingesetzt: sie verkettet `state.arty.OnEventShot`, filtert `IniGroupName` auf die Batterie und korreliert mit dem aktiven ARTY-Target. `verifyFireComplete` lehnt `NO_MOOSE_ARTY_EVENTS_SHOT` ab. Dies wurde als **Akzeptanzinvariante**, nicht als paralleles Fire-Control-Modul, uebernommen.

### 16.3 Implementierung

`scripts/campaign/OMW_FireSupStratResupply_ArtySelectionRuntime.lua`, jetzt **Schema 3**, registriert am existierenden Functional-ARTY-Owner ein **verkettetes** `OnEventShot`; die bestehende MOOSE-Hook-Verarbeitung laeuft weiterhin zuerst. Es wird **kein** separater `EVENTHANDLER` eingerichtet, keine neue `ARTY:New`-Instanz und kein Schuss-/Frame-Scheduler. Zaehlung erfolgt nur, wenn
`eventData.IniGroupName == arty.groupname`, `arty.currentTarget.name` zum registrierten Target gehoert, die gleiche ARTY-Instanz Besitzautoritaet hat, ein `OpenFire` beobachtet wurde und die Mission nicht bereits freigegeben ist. Das Entry-Feld `physicalShots` beginnt bei 0. Es ist reine taktische Event-Evidenz, **kein** CampaignState-Stock-/Verbrauchszahler.

Bei `OnAfterCeaseFire` meldet der vorhandene optionale Completion-Callback:
- `CEASE_FIRE` nur mit `physicalShots > 0`;
- `NO_PHYSICAL_SHOT_EVIDENCE` bei 0 korrelierten Shot-Events, sofern der Auftrag nicht storniert wurde;
- `CANCELLED_AFTER_FIRE_START` unveraendert bei Cancel.
`OnAfterDead`, frueher Cancel, Exactly-once-Callback und MOOSE-`LEGION.UnRecruitAssets`-Release bleiben in der bestehenden Verantwortung. **Ein erfolgreicher MOOSE-CeaseFire-Callback bedeutet weiterhin nicht automatisch eine neue C2-Fire-Mission oder die nachgewiesene Wirkung der Geschosse.**

Das zugehoerige Testmodul `tests/mission-demand/test_fire_support_strategic_resupply_arty_selection_runtime.lua` testet eigene gegen fremde Schuesse, positive Shot-/CeaseFire-Korrelation und Fortress-artiges CeaseFire ohne Shot-Event. Base-Builder **38** verlangt `ARTY-SELECTION-RUNTIME-3` und die neuen No-Shot-/Event-Log-Marker im generierten Bundle.

### 16.4 Lifecycle-Inheritance und Beweisgrenzen

| Feld | Inhalt |
|---|---|
| inherited_contract | Sole MOOSE Functional ARTY, `ARTY:OnEventShot`, `ARTY:AssignTargetCoord`, `OnAfterOpenFire`/`OnAfterCeaseFire`, `LEGION.UnRecruitAssets` |
| accepted_source_paths | `OMW_FobAttackFunctionalArtyDispatchAdapter.lua`; `stage3-honaker-wright-full-response/src/a2/04-fire-support.lua`; gepinnte `Moose.lua` |
| evidence | Vorherige Stage-3-A2-Schussevidenz nur im damals getesteten Fixture; neuer Production-Einsatz noch ohne DCS-PASS |
| invariants | Genau eine MOOSE-ARTY-FSM; Selection-only COMMMANDER; keine staendige Eigenerfassung von Zielen; MOOSE-Rearm am selben ARTY-Owner |
| reuse_mode | Vorhandenen MOOSE-Eventhandler verkettet; minimale Eventbeobachtung |
| harness_role | Source-Tests verifizieren Schusskorrelation und No-Shot-False-Positive; kein eigener ARTY-Lifecycle |
| changed_boundary | Completion-Callback-Grund `NO_PHYSICAL_SHOT_EVIDENCE`; zusaetzliches Entry-Feld `physicalShots` |
| owner_approval | Keine neue taktische Doktrin oder Non-MOOSE-Ausnahme; Verhalten entspricht bereits dokumentierter physischer Fire-Evidence-Anforderung |
| revalidation_scope | Lua-Syntax/Unit-Test, Base-38-Builder und physischer DCS-Schussnachweis Honaker/Wright/Fortress, danach C2-Continuation |

**Offen:** Die neue C2-Continuation muss die dreiwertige `CAS:IsOnStationAt`-Antwort, autoritative lebende Incident-Targets, eigene Batteriemunition, Rearm-Status und neue deduplizierte Cycle-Keys zusammenfuehren. Der Callback allein feuert **keine** Folgesalve. Nicht bei No-Shot blind erneut disponieren (sonst unendliche Fehlerspirale). Beim lokalen Build stets zusammenhaengenden PowerShell-Block verwenden und bei Builder-Fehler sofort stoppen, um Alt-Bundle-Hashes nicht als PASS auszugeben.

### 16.5 Status fuer den naechsten Chat

Branch `agent/fire-support-strategic-resupply-production-bootstrap`. Vollstaendig lesen: Governance/AGENTS/MOOSE-First, Accepted-Lifecycle-Matrix, dieses Handoff Abschnitte **12 bis 16**. Letzter verifizierter lokaler Base-Build ist 37, nicht 38. Die realen neuen Builder-38-Hashes stehen **noch aus**. Vor einer technischen Weiterentwicklung die geloesten Event-Vertraege und die noch nicht verbundene C2-Fire-Continuation nachvollziehen; als naechstes reentranzsichere C2-/CAS-/Munition-/Rearm-Kette mit den vorhandenen Ownern bauen und im selben Dokument fortschreiben.


## 17. Owner-Readback: Production Base 38 erfolgreich gebaut (15.10.2026)

**Verifizierte Quelle:** Original-PowerShell-Ausgabe des Projektinhabers im Arbeitsverzeichnis `P:\DCS-DEV\Operation-Mountain-Watch-fssr-production-bootstrap`. `git pull --ff-only` uebernahm `1759ada4..6b24e42c` per Fast-Forward; `ExpectedCommit` und `ActualCommit` stimmten exakt ueberein.

```text
GitCommit:
6b24e42c257d783c2bcb9ae68e4564b08ecb7340
BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-38
ArtySelectionRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-3
ExternalSupportRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-EXTERNAL-SUPPORT-RUNTIME-4
CasLifecycleRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-2
BuilderSHA256:
8F61CA5334CC2B8CDFDDF80D196A69745DAD808486E8CA1265C8D159410AC809
BundleSHA256:
786A37491F1D21EC7763162DB691E7F25116B8308EE9C8A0192EB86204207019
HandoffSHA256 (vor diesem Anhang):
6992D82FFF702DEFE36A215463A1FA3DF69F04AA89DC97554B15CE506E779EC5
MizMutation: false
```

Der Builder endete erfolgreich. Der nachgelagerte Markercheck `ARTY-SELECTION-RUNTIME-3`, `NO_PHYSICAL_SHOT_EVIDENCE`, `functional ARTY physical shot` und `CAS_PHYSICALLY_IN_SHARED_AO` meldete `PASS: Production Base 38 markers verified`. Der unabhaengig ausgefuehrte `Get-FileHash -Algorithm SHA256` bestaetigte exakt den Bundle-Hash `786A37491F1D21EC7763162DB691E7F25116B8308EE9C8A0192EB86204207019`. `git status --short` zeigte ausschliesslich das vorhandene untracked `mission/fire-support-strategic-resupply/` (generierte Artefakte; nicht entfernen).

**Abnahmegrenze:** `BUILD_VERIFIED` ausschliesslich fuer diese Revision und diesen lokalen Base-38-Build. **Kein** belegter Lua-Unit-Test-Lauf, **kein** DCS-/MOOSE-Runtime-PASS und **keine** bereits aktivierte C2-gesteuerte ARTY-Continuation. Insbesondere ist physischer `ARTY:OnEventShot` im Bundle erkennbar, seine tatsaechliche Korrelation mit MOOSE-`OnAfterCeaseFire` im Missionslauf aber noch nicht bestaetigt. Der reale DCS-False-Positive bei Fortress ist nicht damit als geloest validiert.

**Naechster fachlicher Auftrag:** Mit dem vorhandenen `onArtyFireMissionFinished`-Hook, dem neuen Shot-Evidence-Entry `physicalShots`, `sourceIncidentCoordinator:GetParticipants(true)` und `CasLifecycleRuntime:IsOnStationAt` eine reentranzsichere, deduplizierte C2-Fire-Continuation anhand des bestehenden MissionDemand-/Functional-ARTY-Owners entwickeln. Vor neuem Dispatch Zielberechtigung, Munition, CAS-AO-Status und vorhandene M1083-Rearm-Reservierung pruefen; bei `NO_PHYSICAL_SHOT_EVIDENCE` nicht blind wiederholen. Anschliessend den bestehenden M1083-Rearm-/CampaignState- und Ground-/Air-Transportpfad anschliessen. Die dokumentierten akzeptierten Stage-3-A2-Lifecycles bleiben Reuse-Baseline, nicht zur Produktion zu kopierende Testfixtures.

**Chatwechsel:** Zuerst `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, die `BINDING`-Implementierungsmatrix und dieses Handoff (insb. Abschnitte 12–17) lesen. Aktuellen GitHub-HEAD vor jeder Arbeit erneut abfragen; neue Commits, Tests und **nur reale** Hashes hier fortschreiben. Kein CODEX, keine eigenmaechtige `.miz`-Mutation.


## 18. Groesseres Arbeitspaket: Full Fire-Support Response / C2-Continuation + M1083 (15.10.2026)

### 18.1 Arbeitsauftrag, Scope und vorherige reale Evidenz

Der Projektinhaber hat nach den kleinteiligen Base-35/37/38-Zyklen ausdruecklich die **zusammenhaengende Implementierung groesserer Funktionspakete** angeordnet. Dieser Abschnitt dokumentiert das komplette neue Fire-Support-Paket. Zwischenkommits dienen der GitHub-Entwicklung und verlangen **keinen** einzelnen Owner-Build; danach werden beide Production-Bundles **einmal zusammen** mit identischem Git-HEAD gebaut und gehasht. Die Uebergabeakte ist wie angeordnet jederzeit fortzufuehren und vollstaendig.

Die letzte vom Projektinhaber lokal bestaetigte Dokumentations-Synchronisierung vor diesem Paket war `b8b77292443e96c22c9186c8c61f3457eb135d05` mit Handoff-SHA-256 `A8F5F40FE90BBBAD88E22C1DBE13FA57D0B1C669A649EC2F2C04BCDCB5CB07EF`. Letzter physischer **Base**-Build war Base 38 aus Source-Commit `6b24e42c257d783c2bcb9ae68e4564b08ecb7340`, Bundle-SHA-256 `786A37491F1D21EC7763162DB691E7F25116B8308EE9C8A0192EB86204207019`. Diese sind **historisch** und duerfen nicht als Ergebnisse der neuen Base 39 / Bootstrap 7 verwendet werden.

### 18.2 End-to-End-Source-Design – Bestandserhaltung statt Neuentwicklung

```text
GroundInstallationAttackIncident / OPSZONE
  -> sourceIncidentCoordinator:GetParticipants(true)
  -> Incident C2 CAS + ARTY als unabhaengige Requirements
  -> MOOSE COMMANDER:CanMission/RecruitAssetsForMission
  -> bestehender einziger ARTY:AssignTargetCoord / OnAfterOpenFire
  -> MOOSE ARTY:OnEventShot / OnAfterCeaseFire
  -> bestätigtes physicalShots > 0, selection already released
  -> eventgebundene einmalige MOOSE SCHEDULER-Deferral (1 s)
  -> lebende autorisierte RED-Ground-Gruppen, neuer Request-Key
  -> CasLifecycleRuntime:IsOnStationAt(targetCoordinate) == false
  -> ARTY:GetAmmo(false) >= acceptedShots
  -> Base:RequestIncidentSupport(incidentId, "ARTY", C2 continuation)
  -> MOOSE erneute Providerwahl, bestehender Functional ARTY
  -> weitere kurze begrenzte Salve
ODER
  -> physische Ammo unter acceptedShots
  -> bestehender FixedFireSupportAmmoRearmService:Request
  -> MOOSE ARTY:Rearm (startArty=false)
  -> CampaignState GROUND_AMMO_PACKAGE qty=1
  -> OnAfterRearmed, ReturnToStock
  -> erneute C2-Entscheidung bei lebendem Ziel und freiem CAS-AO
```

Keine eigene RED-World-Erkennung, keine neue operative Asset-Preselection, kein zweiter Functional ARTY, kein AUFTRAG-FireAtPoint-Owner, kein neuer Warehouse-/CampaignState-Settlementpfad, kein eigener periodischer Scheduler. Bereits laufende ARTY-Feuerauftraege werden bei CAS-Ankunft **nicht** kuenstlich abgebrochen.

### 18.3 Dateien und Produktivgrenzen

- **NEU:** `scripts/campaign/OMW_FireSupStratResupply_FireContinuation.lua`, Schema `OMW-FSSR-FIRE-CONTINUATION-2`. Reine C2-Composition, kein neuer Fire-Control-Owner. Nimmt nur `CEASE_FIRE` mit `entry.physicalShots > 0` und nachweisbar freigegebener MOOSE-Selection an. Dedupliziert nach Demand-ID, stellt den Folgeschritt mit **einem** gepinnten MOOSE `SCHEDULER:New(nil,callback,{},1)`-One-Shot hinter den Original-`OnAfterCeaseFire`-Callback. Bewertet bekannte lebende C2-Ground-Teilnehmer, CAS-Occupancy (false/true/unknown), physische Ammo, bestehenden Rearm-Service und neue Request-Keys. Keine spin-/polling-/frame-loop; Reevaluation nur bei nachfolgenden CAS-/Rearm-Events. Bei No-Shot/Dead/Cancel kein automatisches Retarget.
- **GEAENDERT:** `scripts/campaign/OMW_FireSupStratResupply_ProductionBootstrap.lua`, Schema 7. Verbindet `onArtyFireMissionFinished` mit der neuen Continuation, leitet CAS-Evidence und `onRearmed` weiter, nutzt `sourceIncidentCoordinator:GetParticipants(true)` als **einzige** taktische Zielquelle, validiert C2-Targets im selektierten `resolveArtyTarget` und verweigert jede **neue** ARTY-Targetvergabe bei `CAS:IsOnStationAt(coordinate) ~= false`. Die externe `config.onArtyFireMissionFinished` bleibt ein gekapselter Beobachter; technische Callbackfehler werden geloggt und unterbrechen nicht den neuen C2-Listener.
- **GEAENDERT:** `scripts/campaign/OMW_FireSupStratResupply_Base.lua`, Schema 5. Nach `incident.closed` bleibt **ausschliesslich** ein explizit qualifizierter ARTY-Folgeauftrag moeglich: `continuationAfterIncidentClose=true`, `cancelWhenIncidentClosed=false` sowie `context.sourceTargetGroup` verpflichtend. Die eigentliche Lebend-/Feind-/Koordinatenvalidierung liegt weiterhin beim source-autoritativen `resolveArtyTarget`; initiales ARTY, CAS, Guard/QRF bleiben bei geschlossenem Incident gesperrt. Somit beendet allein ein freier Security-Perimeter keine weiterhin C2-autorisierte Fire-Unterstuetzung. Kein generisches Wiedereroeffnen des Incidents.
- **GEAENDERT:** `tools/build-fire-support-strategic-resupply-production-base.ps1` Version 39; verlangt `BASE-5`. `tools/build-fire-support-strategic-resupply-production-bootstrap.ps1` Version 7; bundelt neu `FireContinuation` vor `ProductionBootstrap` und verlangt `FIRE-CONTINUATION-2`.
- **NEU:** `tests/mission-demand/test_fire_support_strategic_resupply_fire_continuation.lua` sowie `test_fire_support_strategic_resupply_closed_arty_continuation.lua`; registriert in `tests/mission-demand/run.lua`. `test_fire_support_strategic_resupply_production_bootstrap.lua` prueft die neue Schema-/Integrationsgrenze und den A10-Default.

### 18.4 A10-Rearm-Konfiguration produktiv wiederverwendet

Die Produktion verwendet jetzt, solange `config.localArtyRearm` **nicht explizit anders** konfiguriert ist, die vorgefundene in DCS A10 verwendete M1083-Grundlage fuer alle vier Batterien:

| ARTY-ID | Standort und CampaignState-Knoten | vorhandene MOOSE RESUPPLY-Zone |
|---|---|---|
| `BOSTICK` | `FOB_BOSTICK`, `GROUND_NODE_BOSTICK` | `ZON_BLUE_GND_BOSTICK_RESUPPLY` |
| `WRIGHT` | `FOB_WRIGHT`, `GROUND_NODE_WRIGHT` | `ZON_BLUE_GND_WRIGHT_RESUPPLY` |
| `FORTRESS` | `COP_FORTRESS`, `GROUND_NODE_FORTRESS` | `ZON_BLUE_GND_FORTRESS_RESUPPLY` |
| `HONAKER` | `COP_HONAKER`, `GROUND_NODE_HONAKER` | `ZON_BLUE_GND_HONAKER_RESUPPLY` |

Je Standort: bestaetigtes A10-Template `TPL_BLUE_GND_SUP_M1083`, ein Support-Asset, `GROUND_AMMO_PACKAGE` Menge **1** pro Rearm, `500 m` Spawnzonengrenze, `100 m` Rearm-/Return-Grenze, `onRoad=false`; dedizierte MOOSE-PLATOON-/BRIGADE-IDs pro Standort. Die existierenden `FixedFireSupportAmmoSupport`, `GroundSupportMaterializer`, `GroundAmmoRearmAdapter`, `FixedFireSupportAmmoRearmService` bleiben **unveraendert** und besitzen Warehouse-Materialisierung, ARTY:Rearm, CampaignState Settlement und Return-to-stock.

**Fail-closed ME-Gate:** Die im konkreten Production-`.miz` erwarteten vier Zonen und das M1083-Late-Activation-Template werden beim Start in der jeweiligen MOOSE-Missionsumgebung nachgewiesen. Fehlt ein Objekt, faellt `ProductionBootstrap.Start` mit einem **konkreten** Fehler zurueck; keine unsichtbaren Spawns oder neue `.miz`-Objekte. Die historische A10-`.miz`-Evidenz beweist noch nicht, dass alle Objekte in der zuletzt gespeicherten Production-`.miz` enthalten sind. `config.localArtyRearm=false` ist als ausdrueckliches Disable/Notfall-Fail-Closed moeglich; ein explizites Table ersetzt die Defaults und muss vollstaendig spezifiziert sein. Keine auto-konstruierte strategische Ground-/Air-Resupply-STORAGE-Fixture.

### 18.5 Source-/MOOSE-Recherche und Acceptance-Invarianten

**Bindende Vorlagen:** `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, `docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`, `mission/tests/fire-support-strategic-resupply-production-base-runtime/src/10-production-real-arty-selection-rearm-acceptance.lua` sowie `mission/tests/stage3-honaker-wright-full-response/src/a2/04-fire-support.lua`.

**Source-confirmed gepinnte `Moose.lua` 2.9.18:**
- `SCHEDULER:New(MasterObject, SchedulerFunction, SchedulerArguments, Start, Repeat, RandomizeFactor, Stop)` um Zeile 13174: Einmaliges Start=1, kein Repeat; benutzte Hook-Initialisierung bestaetigt.
- `ARTY:OnEventShot(EventData)` um Zeile 97517; bestehender Functional ARTY zaehlt `IniGroupName` und `currentTarget`.
- `ARTY:GetAmmo(display)` um Zeile 99163: reale physische MOOSE-Munitionsabfrage, keine CampaignState-Simulation.
- `ZONE_BASE:IsCoordinateInZone`, `FLIGHTGROUP/OPSGROUP:GetCoordinate`: CAS-AO-Abfrage ist aus Abschnitt 13 source-reviewed.

**Offene Risiken / DCS-Gates:** unbestaetigtes ME-Objektinventar der Production-Mission (vier Zonen + Template); MOOSE-Fire-CeasFire-Callback-Reihenfolge; physische ammo-Grenzwerte, M1083 Materialisierung und Rueckkehr fuer jede Batterie; C2-Target-/Range-Abweisung und parallele MOOSE-Provider-Bindungen; Interaktion mehrerer gleichzeitiger CAS-AOs; Kampagnenrestart- und Asset-Verlust. Insbesondere prueft die Fortsetzung vor erneuter Rekrutierung konservativ den physischen Ammo-Stand der **zuletzt feuernden** Batterie; sie wahlt **keine** andere Batterie, wenn diese Ammo fehlt. Dies bewahrt MOOSE-Auswahlautoritaet, kann aber die volle dynamische Provider-Ausnutzung bis zur Rearm-Reconciliation einschraenken. Kein falscher Full-DCS-PASS.

### 18.6 CI und gemeinsame Owner-Verifikation

Die GitHub-`MissionDemand validation` wurde fuer den zusammengefuehrten C2-Continuation-Test in `tests/mission-demand/run.lua` aktiviert. Ein vorgefundenes **altes** Failure `production bootstrap missing ...BOOTSTRAP-4` entstand durch einen nicht nachgefuehrten Contract-Test und wurde auf das neue Schema aktualisiert. Fuer einen vorlaeufigen Source-Stand der Paketentwicklung meldete die GitHub-CI **PASS** fuer die gesamte MissionDemand-Suite, einschliesslich `test_fire_support_strategic_resupply_fire_continuation`; die finalen End-Commits und ihr jeweiliger Workflow-Status sind separat zu lesen. Es werden **nur** konkret angezeigte erfolgreiche Runs als CI-PASS bezeichnet; CI ersetzt keinen DCS-Test.

**Naechster lokaler Owner-Schritt, erst nach finalem Remote-Commit:** ein einziger zusammenhaengender PowerShell-Block `git pull --ff-only` -> HEAD-Pruefung -> **beide** Builder (Base 39 + Bootstrap 7) -> Markerchecks -> SHA-256 **beider** erzeugten Bundles -> SHA-256 dieses Handoffs -> `git status --short`. Keine lokale `.miz`-Mutation durch die Builder. Output samt Hashes aus der wirklichen Konsole zurueckgeben. Vorbereitete DCS-Acceptance erst danach, mit korrigiertem Missionseditor-Skript-Paar und exaktem `.miz`-Hash.

### 18.7 Naechster unmittelbarer Auftrag / Chatwechsel

**Dieses Paket nicht als DCS VALIDATED interpretieren.** Zuerst finalen CI-Status und ein gemeinsames lokales Base39/Bootstrap7-Build-Readback sichern. Dann genau **einen** DCS-End-to-End-Lauf mit mindestens zwei ARTY-Fire-Missions, CAS-On-Station-Sperre und M1083-Rearm an Wright/Honaker/Fortress validieren; Fehler mit akzeptierter A10-/Stage3-Historie vergleichen und nicht parallel neue MOOSE-FSMs erfinden. Fuer Strategic Resupply verbleibt `OMW_FSSR_RESUPPLY_READY=0` ohne authentische Transport-/STORAGE-Deskriptoren; diese bilden das nachfolgende **separate grosse Arbeitspaket**.

Ein neuer Chat liest zuerst Governance, Accepted Implementation Matrix und die Abschnitte **12 bis 18** dieser Datei, synchronisiert den aktuellen Remote-HEAD und erhaelt damit die vollstaendige Source-/Provenienz-, Entscheidungs-, Test- und To-do-Historie. Das untracked `mission/fire-support-strategic-resupply/` niemals bereinigen; keine CODEX-Anweisungen.


### 18.8 Finaler GitHub-CI- und Source-Review-Readback

**GitHub Actions ist fuer die neu integrierte Produktionsgrenze GRUEN.** Die GitHub-App meldete zum Source-/CI-Commit `e5c53460a13b307a27f8f728e9722ac3bc7f9fcd`:
- `MissionDemand validation` = **success**, Run-ID `38799969972`.
- `Documentation validation` = **success**, Run-ID `38799969921`.
- Die MissionDemand-Suite enthaelt inzwischen auch die neuen Tests fuer C2-Fire-Continuation sowie den bewusst engen ARTY-Closed-Incident-Vertrag.
- Die CI-Workflow-Datei `.github/workflows/mission-demand-validation.yml` wurde so ergaenzt, dass `OMW_FireSupStratResupply_ArtySelectionRuntime.lua`, `OMW_FireSupStratResupply_FireContinuation.lua` und `OMW_FireSupStratResupply_ProductionBootstrap.lua` ausdruecklich mit `luac5.4 -p` auf Syntax geprueft werden.
- Die bereits zuvor beobachtete CI-Regression durch den stale Bootstrap-Schema-4-String ist auf Schema 7 korrigiert.

**Abschliessende Regression-Massnahmen innerhalb desselben grossen Pakets:**
- Die C2-Rotation behandelt neben spaeteren Fire-Missions auch die urspruengliche physische Initiatorgruppe als vorheriges Ziel; bei mehreren lebenden Zielen wird nicht ohne Grund stets dieselbe Gruppe erneut ausgewählt.
- Eine erfolgreich als `OnAfterRearmed` bestaetigte, aber weiterhin unzureichende physische Munition loest nicht ungeprueft eine zweite M1083-Transaktion aus.
- Die Revaluation aus CAS-Evidence beschraenkt sich auf bedeutungsvolle `CAS_CONTROLLED_RELEASE`, `CAS_HOME_LANDED`, `CAS_LEGION_ASSET_RETURNED`, `CAS_LIFECYCLE_COMPLETE` und `CAS_LIFECYCLE_FAILED`-Events; **keine** sensorbedingte 5-Sekunden-ARTY-Retry-Queue.
- Ein freigegebenes MOOSE-ARTY-Asset kann wartende andere Incidents einmalig erneut bewerten lassen. Kein globales Polling.
- Der Bootstrap-7-PowerShell-Builder wurde nach Source-Review repariert: `$policy.Contains(...)` erhaelt exakt **einen** Ressourcen-Policy-Marker; `FIRE-CONTINUATION-2` wird separat im Bundle geprueft.
- Beide gebuendelten Files und beide Builder wurden gegen die aktuell finalen Source-Schemata abglichen: `Production Base 39` erwartet `BASE-5`, `Production Bootstrap 7` bundelt `FireContinuation-2` mit `Bootstrap-7`.

**Verbleibende, aus der CI NICHT ableitbare Evidenz:** die zwei realen Windows-PowerShell-Builds und Hashes auf identischem aktuellen Source-Commit; Existenz der vier A10-M1083-Zonen und des Templates in der aktuell gespeicherten Production-`.miz`; realer MOOSE-Dispatch, Ziel-/CAS-/Shot-/Rearm-Verlauf und Return-to-Stock in DCS. Nichts davon als `VALIDATED` behaupten. Strategic Ground-/Air-Resupply verbleibt anschliessendes grosses Paket, keine neue Mock-STORAGE-Policy.

**Fortsetzungssatz fuer einen neuen Chat:** Lies Governance, Accepted-Lifecycle-Matrix und dieses Handoff Abschnitte 12–18 vollstaendig. Das Source-Paket ist mit GitHub-CI `success` fuer oben genannten Commit abgesichert; fordere nur einen gemeinsamen Base-39/Bootstrap-7-Windows-Build/Hash-Readback an, vergleiche dessen reale Ausgabe, bereite dann die qualifizierte Full-Response-DCS-Acceptance vor. Keine einzelnen Zwischen-Builds oder Dokumentations-Pulls pro Callback; Dokumentation weiterhin bei jedem fachlich zusammenhaengenden Schritt im selben Handoff fortfuehren.


## 19. Owner-verifizierter gemeinsamer Windows-Build – Base 39 + Bootstrap 7 (15.10.2026)

**Reale Quelle:** vom Projektinhaber am 15.10.2026 zurueckgegebene vollstaendige PowerShell-Konsole aus `P:\DCS-DEV\Operation-Mountain-Watch-fssr-production-bootstrap` (Originalausgabe der beiden Builder, separater Markerpruefung, dreier Get-FileHash-Abfragen und git status). `git pull --ff-only` hat den Arbeitsbranch `agent/fire-support-strategic-resupply-production-bootstrap` von `b8b77292` auf `2382e962` per Fast-Forward aktualisiert. Erwarteter und tatsaechlicher HEAD waren identisch.

```text
GitCommit:
2382e962623e5c0591f608812cad05cf172d22e2

Production Base BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-39
BaseSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-5
ArtySelectionRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-ARTY-SELECTION-RUNTIME-3
CasLifecycleRuntimeSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-2
Production Base BuilderSHA256:
612DE7BD785A01EB7F41B979FC01E9D2E434D8A20590F4186D8653673596BC3F
Production Base BundleSHA256:
4C5C8AFAC3F0D492B445ED48AE4B5C88670C559769BB21F8B73CA412B4C104F6

Production Bootstrap BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-7
BootstrapSchema:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-7
FireContinuationSchema:
OMW-FSSR-FIRE-CONTINUATION-2
Production Bootstrap BuilderSHA256:
C9A6298531E13B489FF445EF54BC9DF630FD82DC0A2FF30ED3F005E99880CBE3
Production Bootstrap SourceSHA256:
10DD5FEA8C7A7694335F8D6EF65C7F4F39B840B7C28176A8222E8C0368F45014
FireContinuationSourceSHA256:
D1BB0BEE151E412705BBB1CB0C216285E6C5123DF424E3BD1E36C7FC283D4DB5
ResourceDemandPolicySHA256:
76D449C711B308ECF22E87C5F30E16B896750EB3F98F632B10927691DBEEF332
Production Bootstrap BundleSHA256:
3AD1C0B70086D6E7A0E574C03D69C6D0344684BDFB2643BBF734DA2306E52B5D

Handoff SHA256 before adding this section:
956385611825B88B418331867322161651A649A8F6E0D73291888488FF59ABC3
```

Beide Windows-Builder liefen ohne Fehler durch und meldeten denselben Git-Commit. Anschliessend wurde der Markercheck `PASS: Base 39 and Bootstrap 7 integration markers verified` ausgegeben: `BASE-5`, `ARTY-SELECTION-RUNTIME-3`, `CAS-LIFECYCLE-RUNTIME-2`, `BOOTSTRAP-7`, `FIRE-CONTINUATION-2`, `C2_FIRE_CONTINUED`, `continuationAfterIncidentClose` und `TPL_BLUE_GND_SUP_M1083` waren im jeweils erwarteten Bundle vorhanden. Die separaten `Get-FileHash -Algorithm SHA256`-Ausgaben **stimmen exakt** mit den oben genannten Bundle-Hashes ueberein.

`MizMutation: false` wurde von beiden Buildern protokolliert. `git status --short` zeigt ausschliesslich `?? mission/fire-support-strategic-resupply/` (untracked, generiertes Verzeichnis). Dieses Verzeichnis **nicht bereinigen oder in Git aufnehmen**, solange keine separate Freigabe vorliegt.

**Abnahme-Status:** `BUILD_VERIFIED` fuer beide Bundles am exakt genannten Git-Commit, inklusive realer Hash-Readbacks. Der vorherige GitHub-CI-Run `38799969972` bestand mit MissionDemand/Lua-Syntax-Checks fuer die Source-Revision; `Documentation validation` Run `38799969921` ebenfalls erfolgreich. KEIN Production-DCS-PASS fuer die neuen C2-Rearm-/CAS-/ARTY-Lifecycles. Alle Aussagen zur physischen Funktionsfaehigkeit bleiben `DCS_PENDING`.

**Naechster zusammenhaengender Gate:** ohne weitere kleinteilige Owner-Builds die reale aktuell verwendete Produktions-`.miz` mit der Mission-Editor-/Load-Order-/Object-Baseline abgleichen. Fuer die DCS-Acceptance muessen in der Mission das Base-39-Bundle **vor** Bootstrap-7 geladen und die vorhandenen vier M1083-Spawnzonen, die Support-Templategruppe sowie die Warehouse-/ARTY-Gruppen eindeutig identifiziert werden. Danach Full Response als **eine** End-to-End-Acceptance gegen die uebernommenen A10/Stage3-Owner pruefen, insbesondere 2+ ARTY-Fire-Cycles, CAS-Deconfliction bei belegtem/unklarem AO, keine No-Shot-Fortsetzung, OnAfterRearmed/physische Ammo und M1083-Return-to-Stock. DCS-Mission-/Log- und Hash-Provenienz erst nach tatsaechlichem Test erfassen.

**Arbeitsrhythmus:** Nicht nach diesem Dokumentationscommit gesondert zu pullen/bauen auffordern; der naechste lokale Arbeitsblock soll die vollstaendige DCS-Acceptance-Vorbereitung bzw. eine spaetere wirklich notwendige Source-Gesamtveraenderung zusammenfassen.

**Chatwechsel:** Ab jetzt Abschnitte 12–19 und Governance/Accepted-Lifecycle-Matrix lesen. Das letzte exakt real verifizierte Bundlepaar stammt aus Git-Commit `2382e962...` (Hashes oben), waehrend der jeweils aktuelle GitHub-Dokumentations-HEAD neuer sein kann. Keine alten Hashes einem neueren Source-Build zuschreiben. Kein CODEX, keine `.miz`-Mutation ohne Genehmigung.


## 20. Direkte v26-MIZ-Bestandsaufnahme vor DCS-Full-Response-Acceptance (15.10.2026)

**Vom Owner hochgeladenes unveraendertes DCS-Archiv** `OMW_Template_v26_GroundWorks_Ready(2).miz`. Es wurde in der aktiven Runtime unter dem explizit bereitgestellten Upload-Pfad als ZIP/DCS-MIZ direkt gelesen. Kein OCR, keine MIZ-Aenderung, kein DCS-Start.

```text
Mission filename: OMW_Template_v26_GroundWorks_Ready(2).miz
ZIP members: 19
Mission member: mission (3,827,221 bytes uncompressed)
Warehouses member: warehouses (3,319,588 bytes uncompressed)
MIZ SHA-256:
562A4F63899100ADABE47C15E3A6B0B1E52D62445B6CBC6EA5D48812A5731629
Embedded Moose.lua SHA-256:
E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

### 20.1 Verifiziertes Mission-Editor-Inventar aus `mission`

| ARTY-Standort | Feste Gruppe (exakter ME-Gruppenname) | Warehouse-Marker | RESUPPLY-Triggerzone |
|---|---|---|---|
| Bostick | `TPL_BLUE_GND_BOSTICK_FS_ARTY_L118_2` | `WH_BLUE_GND_BOSTICK` | `ZON_BLUE_GND_BOSTICK_RESUPPLY` |
| Wright | `TPL_BLUE_GND_WRIGHT_FS_ARTY_L118_2` | `WH_BLUE_GND_WRIGHT` | `ZON_BLUE_GND_WRIGHT_RESUPPLY` |
| Fortress | `TPL_BLUE_GND_FORTRESS_FS_ARTY_L118_1` | `WH_BLUE_GND_FORTRESS` | `ZON_BLUE_GND_FORTRESS_RESUPPLY` |
| Honaker | `TPL_BLUE_GND_HONAKER_FS_MORTAR_2B11_2` | `WH_BLUE_GND_HONAKER` | `ZON_BLUE_GND_HONAKER_RESUPPLY` |

Jeder der vier ARTY-Gruppennamen ist im `mission`-Member genau einmal als Gruppenname enthalten. Das Rearm-Template `TPL_BLUE_GND_SUP_M1083` ist als Gruppe (eine `CHAP_M1083`-Unit, `lateActivation = true`) vorhanden; seine Units tragen `TPL_BLUE_GND_SUP_M1083_01`. Die vier RESUPPLY-Zonen sind als benannte Mission-Triggerzones mit eindeutiger Position vorhanden. Alle vier RESUPPLY-Zonen: Radius 15.24 m (jeweils direkt vor dem Zonennamen im selben Triggerzonen-Eintrag nachgewiesen). Die Zonen sind **nicht erst zu erstellen**. Der vorhandene physische Abstand, Terrain-Freiheit, MOOSE-Materialisierung, M1083-Bewegung/Return und DCS-/CampaignState-Buchung sind **nur in DCS** zu validieren.

### 20.2 Nachgewiesene Mission-Trigger-/Load-Order

`l10n/DEFAULT/mapResource` enthaelt die erforderlichen Scriptdateien:
```text
ResKey_Action_6   -> Moose.lua
ResKey_Action_238 -> OMW_AirOps_Warehouse_Base.lua
ResKey_Action_239 -> OMW_Ground_Base.lua
ResKey_Action_246 -> OMW_FireSupStratResupply_Base.lua
ResKey_Action_247 -> OMW_FireSupStratResupply_Production.lua
```

Die Mission hat `trigrules[12]` mit Namen `LOAD_FIRESUPSTRATRESUPPLY_BASE`; ihre Bedingungen sind `OMW_WAREHOUSE_READY = 1`, `OMW_GROUND_READY = 1` und `TIME MORE 30 s`. Die beiden Aktionen laden `ResKey_Action_246` **vor** `ResKey_Action_247` im **selben Trigger**. MOOSE wird bereits in `trigrules[1]` geladen, Warehouse und Ground in frueheren Triggern. Load-Order ist deshalb **im MIZ-Source-Snapshot korrekt**; tatsaechliche Run-Time-Readiness bleibt im DCS-Log nachzuweisen.

### 20.3 Entscheidender Befund: Eingebettete Bundles sind veraltet

Das hochgeladene v26-Missionsarchiv enthaelt:

```text
l10n/DEFAULT/OMW_FireSupStratResupply_Base.lua
  BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-34
  GitCommit: a01b163a0db13b772db1d30aee4c38741f0b010a

l10n/DEFAULT/OMW_FireSupStratResupply_Production.lua
  BuilderVersion: OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BOOTSTRAP-4
  GitCommit: a01b163a0db13b772db1d30aee4c38741f0b010a
```

Die **letzten wirklich lokal gebauten** Source-Artefakte dagegen stammen beide aus `2382e962623e5c0591f608812cad05cf172d22e2` (Abschnitt 19):

```text
Base 39 SHA-256:
4C5C8AFAC3F0D492B445ED48AE4B5C88670C559769BB21F8B73CA412B4C104F6
Bootstrap 7 SHA-256:
3AD1C0B70086D6E7A0E574C03D69C6D0344684BDFB2643BBF734DA2306E52B5D
```

**Folgerung:** Das unveraenderte hochgeladene v26-Archiv ist als **Mission-Editor-Ausgangsbasis** geeignet, aber **noch nicht als ARTY-/CAS-/M1083-Acceptance-Build**. Dazu muessen exakt die beiden vorhandenen Skript-Ressourcen im Archiv durch den oben hashverifizierten Bundle-Satz ersetzt und die daraus erzeugte Acceptance-`.miz` separat gehasht werden. Die Triggerstruktur muss dazu **nicht neu angelegt** werden. Keine neue Zone, kein neues Template, keine anderen Missionsobjekte. Das Paar darf niemals nur teilweise aktualisiert werden.

**Entscheidungs-/Genehmigungsgrenze:** Nach Governance ohne explizite Freigabe keine eigene `.miz`-Mutation. Die hochgeladene Datei wurde nicht veraendert; auch keine gepatchte Acceptance-Kopie erzeugt. Freigabe fuer die Erstellung einer separaten, eindeutig benannten Acceptance-`.miz` mit **nur** diesen beiden Bundle-Resource-Replacements beim Owner einholen, falls ChatGPT diese Mutation uebernehmen soll. Alternativ fuehrt der Owner den bestehenden Mission-Editor-Tausch beider Do-Script-File-Ressourcen lokal durch und liefert den realen Missions-Hash.

### 20.4 Uebergabe-/DCS-Gate

- Bereits bewiesen: vier reale ARTY-Gruppen, vier Warehouse-Marker, vier RESUPPLY-Zonen, M1083-Late-Activation-Gruppe, MOOSE-SHA, Load-Order und Readiness-Bedingungen.
- Noch **nicht** bewiesen: die generierten Base-39-/Bootstrap-7-Bundles sind in einer neuen Missionsdatei gespeichert; deren Missions-Hash; DCS-Start/Initialisierung, C2-Zielautoritaet, CAS/ARTY-Deconfliction, physischer `EVENTS.Shot`-Nachweis, M1083-Rearm/CampaignState-Settlement und multi-cycle Fire.
- **Unmittelbarer naechster Schritt:** Eine separate v26-Full-Response-Acceptance-`.miz` mit ausschliesslich den beiden eingebetteten verifizierten Bundles erstellen (Owner-Genehmigung erforderlich), dann Hash/Archiv-Diff und reale DCS-Acceptance mit Logs/Debrief pruefen. Dokumentations-HEAD nach diesem Eintrag nicht mit dem Source-Bundle-Commit verwechseln. Kein isolierter Dokumentations-Pull verlangen. Kein CODEX.


## 21. Owner-Entscheidungen 16.10.2026: fortbestehender C2-Unterstuetzungsbedarf, abgestufte Verteidigung und Fixed-Wing-CAS

**Status:** Verbindlicher fachlicher Sollauftrag des Projektinhabers, **noch keine genehmigte neue Non-MOOSE-Architektur und keine vollstaendig implementierte/validierte Production-Umsetzung**. Dieser Abschnitt ist Teil der kontinuierlich gefuehrten FSSR-Handoff-Akte und muss bei allen kuenftigen fachlich relevanten Entscheidungen, DCS-Befunden, Implementierungen und Test-Readbacks fortgeschrieben werden. **Keine neue isolierte Uebergabedatei**, solange die bestehende Akte erhalten und nutzbar bleibt. Keine Details nur im Chat belassen.

### 21.1 Reale Beobachtungen aus dem DCS-Lauf 16.10.2026

Vom Projektinhaber bereitgestellt: `dcs(20261016-205624).log`, `debrief(20261016-205623).log`, zuvor die von ihm manuell mit beiden FSSR-Bundles aktualisierte v26-`.miz`. Die Protokollauswertung im Gespraech bezog sich auf DCS `2.9.30.28738 MT`, Base **39**, Bootstrap **7**, verifizierte Bundle-Provenienz siehe Abschnitt 19. **Die statische Uebertragungs-/MIZ-Provenienz darf nicht aus einem identischen Dateinamen abgeleitet werden; interne Hashkette vor DCS-PASS erneut vollstaendig pruefen.** Die DCS-/Debrief-Logs sind reale Owner-Evidenz; bei neuem Chat nur konkrete, am Original belegte Events als bestaetigte Logbeobachtung ausgeben, nicht Spekulationen der frueheren Chat-Auswertung als neue Fakten praesentieren.

**Vom Owner direkt beobachtet:**
- Wright unterstuetzte Joyce mit Artillerie bis zum Ende der dortigen Feuerauftraege, danach blieb seine Batterie ohne Auftrag. Trotz weiterbestehender Bedrohung/Unterstuetzungsbedarfs bei Honaker wurde Wright weder ersichtlich erneut disponiert noch wirksam fuer Honaker rekrutiert.
- Honakers zwei 2B11-Moerser stellten nach dem initialen Feuer das Schiessen ein; ein M1083-Ammotruck kam physisch **nahe** bei den Moersern zum Stehen und blieb dort **bis zum Missionsabbruch bei Ingame-Zeit 19:06 Uhr**. Keine sichtbare Wiederaufnahme des Feuers. Ein grober Distanz-/Anfahrfehler soll angesichts dieser Position **nicht** ohne neue Evidenz zur Hauptursache erklaert werden.
- Eine zerstoerte QRF wurde bei weiterhin bestehender Bedrohung nicht nachweisbar durch eine weitere verfuegbare QRF-Einheit ersetzt.
- Honaker-AH-64D-Two-Ship: eine Maschine ging beim fruehen Angriff verloren, Ursache (Feindwirkung, Gelande, Flugfehler) ungeklart. Die zweite bekaempfte zahlreiche RED-Einheiten, kreiste dann laengere Zeit ueber dem AO bei einer sichtbaren verletzten Rest-RED-Einheit; keine gesicherte Aussage zur eigenen Detektion, Waffenvorrat, Auftrag-/Release-Lage oder CAS-Sensorverfuegbarkeit. Der ueberlebende AH-64 **landete schliesslich**; die vorherige Vermutung eines sicheren RTB-Absturzes hat sich in diesem Lauf gerade **nicht** bestaetigt.

**In der bisherigen Log-Auswertung berichtete Ereignisse, vor einer neuen Root-Cause-Festlegung am Original nachpruefen:**
- Wiederholte physische Honaker-/Wright-ARTY-Schussereignisse, Wright/Joyce-Folgemissionen bis `CYCLE_18`.
- M1083-Request, Supportmaterialisierung und CampaignState-Consumption sind geloggt; ausstehend beziehungsweise in der Auswertung nicht gefunden: `LOCAL_ARTY_REARMED` / physisch bestaetigtes `OnAfterRearmed`. **Materialisiert + strategisch gebucht != Munition physisch vollstaendig nachgeladen.**
- `CAS_ASSET_LOSS` mit `initialAlive=2`, `alive=1`, spaeter `CAS_FUEL_LOW_BEFORE_CONTROLLED_RELEASE` und dennoch sichtbare/tatsaechlich protokollierte Landung eines AH-64. Flugzeugverlust-/Return-/CampaignState-Settlement nur assetgenau akzeptieren.
- Noch kein sicherer Nachweis, **welche** der Schnittstellen (Bedarfserzeugung, Queuing, COMMANDER-Providerfreigabe, erneute Selektion, Beobachtung/Release) Wrights nachfolgende Honaker-Unterstuetzung konkret verhinderte. Nicht vorschnell ausschliesslich dem MOOSE COMMANDER oder der FSSR-Queue die Root Cause zuschreiben.

**Rearm-Dauer:** Keine unbelegte pauschale Minutenzahl angeben. Die gepinnte MOOSE-`ARTY`-/DCS-Umsetzung, tatsaechlich gemessene Ammo-Werte, `Rearm`-/`Rearming`-/`Rearmed`-FSM-Events und die gegebenenfalls physische Entfernung sind nachzuweisen. **Truck steht nahe** ist relevante Negativ-Evidenz gegen ein offensichtliches Anfahrtsproblem, beweist aber alleine keinen erfolgreichen Engine-Rearm. Bei anhaltender Blockade eine begrenzte Lifecycle-/Ammo-Diagnostik vorsehen, keine neue eigene Rearm-FSM.

### 21.2 Neue verbindliche taktische Dispositionsdoktrin

**Grundsatz (Owner 16.10.2026): Solange ein FOB/COP angegriffen wird, besteht grundsaetzlich Unterstuetzungsbedarf.** Alle aktuell geeigneten und verfuegbaren Mittel sind als Einsatz-/Anforderungsoptionen zu beruecksichtigen; kein Auftrag und kein bestimmtes Asset darf stillschweigend mit der Gesamterfuellung des Bedarfs gleichgesetzt werden. Lokal fuehrt die Einrichtung eigene Kraefte, externe Verfuegbarkeit/Prioritaet/Allokation entscheidet C2 ueber vorhandene MOOSE-Instanzen.

**Vom Owner festgelegte Reihenfolge nach voraussichtlicher Zeit bis zur Wirkung (KEINE starre sequentielle Wartebedingung):**

1. Eigene/nahe lokale Mittel:
   1. bereits **aktive Patrouille in der Umgebung**;
   2. standorteigene **Moerser/ARTY**, soweit vorhanden und einsetzbar;
   3. **QRF** aus verfuegbaren lokalen Kraeften/autoritativen Warehouse-Ressourcen.
2. Externe Mittel:
   1. **Moerser/ARTY anderer verfuegbarer FOBs/COPs**;
   2. **CAS**, Rotary- und Fixed-Wing.

**Wesentliche Klarstellung:** Die oben genannte Reihenfolge ist eine **Reihenfolge typischer Wirksamkeitszeiten**, keine zwingende serielle Anforderungsfolge. **CAS fruehzeitig/parallel disponieren**, weil Alarmierung, Start, Anflug, Sensor-/Engagementbereitschaft laenger dauern koennen. Lokale Patrouillen, Mörser, QRF und externe ARTY ueberbruecken diese Zeit. Ein passender bereits airborne befindlicher Jet kann schneller im AO sein als ein noch nicht gestarteter Helikopter; **C2 bewertet tatsaechliche voraussichtliche Verfuegbarkeit**, nicht nur Muster/Basis. Keine automatisch erfundenen Reaktionszeiten.

**Fortbestand/Retasking:** Angriffs-/Unterstuetzungsbedarf bleibt offen, wenn
- eine eigene Batterie Winchester/auf M1083-Rearm wartet;
- eine lokal/extern angeforderte Batterie anderweitig reserviert ist (z. B. Wright zuerst bei Joyce);
- ein einzelner QRF-Einsatz durch bestaetigten physischen Verlust endet;
- CAS einen einzelnen Flugzeugverlust oder Fuel-/Winchester-/RTB-/Recovery-Zustand erreicht;
- ein einzelner konkreter MissionDemand/Fire Cycle abgeschlossen oder abgewiesen wurde.

Auf jedem fachlich relevanten, belegten Provider-/Bedarf-/Ressourcen-Lifecycle-Event muss der **noch offene Bedarf** erneut bewertet und einer geeigneten Ausfuehrung uebergeben werden koennen. Bei neu verfuegbarem Wright ist beispielsweise Honakers offener externer ARTY-Bedarf erneut dem **bestehenden** MOOSE COMMANDER/Recruitment vorzustellen. Die Queue-/Pending-Authority muss vor Implementierung gegen die tatsaechliche MOOSE-Version nachgewiesen werden: **keine parallele zweite MOOSE-Queue, keine eigene Provider-Rangliste, kein selbstgebautes Recruitment oder World-Scanning.** Keine permanente hochfrequente Polling-Loesung.

**QRF-Verlustersatz (Owner-MUSS):** Wird eine QRF physisch zerstoert, bleibt der Incident-/C2-Verteidigungsbedarf bestehen und ist **eine weitere QRF anzufordern/einzusetzen, solange geeignete Ressourcen im autoritativen CampaignState-Warehouse verfuegbar sind und die Bedrohung fortbesteht**. Kein unbegruendeter Fahrzeug-/Personal-Recredit, keine Scheinwiederbelebung der verlorenen Gruppe, keine zweite Ground-Road/Targeting-Implementierung. Bestehende `OMW_Ground_Base`-, `OMW_FireSupStratResupply_QrfRuntime`-, `On Road`-, `SetReturnToLegion`- und Settlement-Vertraege uebernehmen. Kein Ersatz, wenn kein autorisierter Bedarf mehr besteht oder keine geeigneten Ressourcen vorhanden sind; der unbediente Bedarf muss sichtbar/evident bleiben.

**Deconfliction/Authority bleibt verbindlich:** Keine *neue* ARTY-Feuermission bei CAS **physisch ON STATION im gemeinsamen AO** oder unklarer CAS-Belegung; bereits laufende ARTY-Salven nicht kuenstlich abbrechen. C2-Feuerbeobachtung, physisch lebende Incident-Ziele, eigener CAS-Sensorbericht und explizite Supported-Element-Release-Authority bleiben getrennte Autoritaeten. Kein Perimeter-Clear als automatisches CAS-Missionsende; ein Apache mit vorhandenem CAS-Auftrag bekommt nicht allein aus einem globalen RED-Count seine Sensorlage ersetzt. CAS-Release/RTB-/Recovery-Gates und festgelegte sichere Korridore duerfen nicht stillschweigend vereinfacht werden.

### 21.3 CAS-Provider: nicht nur Apache

**Neue ausdrueckliche Owner-Anforderung:** Externe CAS-Anforderungen muessen allgemein geeignete Hubschrauber **und Kampfflugzeuge** beruecksichtigen, soweit auf dem jeweils aktuellen ORBAT, den real konfigurierten AIRWING-/SQUADRON-Pools und ihrer Mission-/Payload-/Capability-Berechtigung verfuegbar:

- **AH-64D** aus **Jalalabad** (bestehender validierter Rotary-CAS-Pfad, Provenienz exakt beachten).
- **A-10** aus **Kandahar** (potenzieller Fixed-Wing-CAS-Provider, konkrete aktive Staffel/Typ/Beladung anhand der aktuellen Fach-/ORBAT-Baseline nachweisen).
- **F-16** und **F-15** aus **Bagram** (potenzielle Fixed-Wing-/Strike-CAS-Provider, konkrete Muster/Einheiten/Beladungen/Verfuegbarkeit ebenfalls erst anhand von `main` und der realen Production-Konfiguration bestaetigen).

Dies sind **Soll-Provideroptionen**, keine Behauptung, dass alle Muster/Staffeln bereits in dieser .miz sofort produktiv rekrutierbar sind. Kein pauschaler Fixed-Wing-DCS-PASS aus Rotary-A9 oder aus historischem Stage3-Test ableiten. MOOSE AIRWING/SQUADRON/COMMANDER/AUFTRAG uebersetzt den Bedarf; keine fixe haendische Luftfahrzeugwahl durch FSSR, kein eigener zweiter CAS-Lifecycle. Die unterschiedlichen Wirkzeiten durch Startvorbereitung/Anflug sind bei Priorisierung zu beruecksichtigen; Fuel-, Engagement-, Sensor-/Targeting-, Korridor-, Freigabe- und Return-/Loss-Vertraege bleiben fachlich notwendige gesonderte Acceptance-Gates fuer Fixed-Wing.

### 21.4 Naechstes grosses zusammenhaengendes Entwicklungs-/Reconciliation-Paket

**Kein neuer kleinteiliger Callback-/Builder-/Dokumentations-Pull-Zyklus.** Vor Source-Aenderungen aktuellen HEAD, autoritative `main`-Governance und Akzeptanzmatrix, letzte reale Logs/Debrief, Source-/MOOSE-Signaturen und vorhandene Produktionsschnittstellen gegenpruefen. Dann ein zusammenhaengendes, getestetes Paket:

1. Persistenten, zustandsbasierten Site-Supportbedarf definieren/mit bestehender Incident-/MissionDemand-/MOOSE-Vertragsstelle verbinden. Eigene Patrouille, Fixed ARTY, QRF und externe Mittel **parallel zeitgerecht** beauftragen; einzelne Ablehnungen/Loss/Rearm/Provider-Busy/Fire-Cycle-Abschluesse duerfen den Bedarf nicht konsumieren. Wright/Joyce -> Honaker als Pflichtfall, inklusive echter Queue-/Re-Recruitment-Evidenz.
2. M1083-/Functional-`ARTY`-Rearm-Bedingungen an gepinnter `Moose.lua`, akzeptierter A10-Rearm-Source und echter DCS-Logspur klaeren; bestaetigte `Rearmed`-Callback-/physische Ammo-Evidenz und Support-Return-to-stock mit CampaignState-Settlement. Keine Duplikation strategischer Ressourcenhoheit.
3. QRF physischer Totalausfall -> neue, MOOSE- und CampaignState-autorisierte QRF-Materialisierung mit bestehenden On-Road-/Target-/Return-Lifecycles; Loss/Recredit/No-Capacity eindeutig testen.
4. CAS-Lifecycle fuer AH-64D (Engagement/Sensor/Ammo/Fuel-low vor kontrollierter Freigabe, Two-Ship-Asset-Loss, sicherer Egress/RTB/Recovery) ohne Stueckwerk regressionsfest machen; danach geeignete A-10/F-16/F-15-Provider ueber vorhandene AIRWING-/SQUADRON-Vertraege **reconciliieren**, Fixed-Wing-Einsatz gesondert validieren.
5. CI-/Lua-/MOOSE-Source-/Diff-/Dokumentations-Pruefungen fuer den **Gesamtstand**, erst danach **eine** nummerierte Windows-PowerShell-Build-/SHA-Anweisung mit beiden Bundles, nicht pro Callback.
6. Owner aktualisiert ausschliesslich selbst im DCS Mission Editor die vorhandenen DO SCRIPT FILE-Lua-Bundles, speichert seine `.miz`, stellt deren echte Belege/Logs bereit und fliegt die **gebuendelte** Full-Response-Acceptance. **ChatGPT erstellt, mutiert, repariert, speichert oder uebertraegt keine .miz-Datei**, auch nicht eine Test-/Acceptance-Kopie. Originale nie ungefragt anfassen.
7. Jedes Source-/Builder-/Bundle-/MIZ-/DCS-/Debrief-/Resultatglied gemaess `docs/22-test-mission-build-transfer-and-validation-workflow.md` separat und eindeutig hash-/versionsbasiert protokollieren. `VALIDATED` erst nach echtem DCS-Nachweis. Nach Source-Aenderungen Akzeptanzmatrix, einschlaegige `docs/moose/`-Dokumente, Tests und **diese** Uebergabeakte synchron halten. Keine selbststaendige Merge-/Architekturausnahme-Genehmigung. **Kein CODEX**.

### 21.5 Fuer Chatwechsel: lesereihenfolge und Schutzregeln

1. `main`: `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, `docs/22-test-mission-build-transfer-and-validation-workflow.md`, `mission/tests/GOVERNANCE.md`.
2. `main`: `docs/moose/FIRE-SUPPORT-ACCEPTED-IMPLEMENTATION-MATRIX.md`, `docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `docs/moose/STAGE3-CAS-SUPPORT-REQUIREMENT-AND-ENGAGEMENT-DECISION.md`, `docs/moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md`, zuständige aktuelle AIRWING-/ORBAT-Fachbaseline.
3. Arbeitsbranch `agent/fire-support-strategic-resupply-production-bootstrap`: dieses Handoff **Abschnitte 19–21 zuerst** (anschliessend 1–18 zur Historie), dann aktuellen Source-HEAD, Production-Base-/Bootstrap-Code, Tests, akzeptierte A10-/Stage3-Lifecycles. Nicht alte Testergebnisse auf neue Commits uebertragen.
4. Bei einem weiteren Nutzerbefund **unmittelbar in Abschnitt 22 bzw. naechsten fortlaufenden Abschnitt ergaenzen**, mit `Entscheidung` / `Beobachtung` / `nachgewiesene Ursache` / `Hypothese` / `Implementierung` / `CI` / `DCS-PENDING` / `naechste Arbeit` und konkreter Provenienz. Keine stillen Grundsatzwechsel.
5. Untracked lokales `mission/fire-support-strategic-resupply/` nicht bereinigen; generierte `dist`-Artefakte sind keine Repository-Source. Eine neue Dokumentationsrevision allein erfordert **keinen gesonderten Owner-Pull**.
