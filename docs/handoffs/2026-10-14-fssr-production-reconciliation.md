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
