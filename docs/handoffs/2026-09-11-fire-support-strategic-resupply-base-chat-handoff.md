---
document_id: OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911
status: PLANNED
document_class: CHAT_HANDOFF_AND_IMPLEMENTATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - handoff context for FireSupStratResupply base-module planning
  - required MOOSE-first research and implementation sequence
  - known Stage-3 evidence, failures, limits and regression requirements
not_authoritative_for:
  - generic DCS runtime acceptance
  - permission to bypass MOOSE public APIs
  - a claim that every site or support type is already implemented
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-handoff
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Chat-Handoff und Implementierungsplan: standortunabhängige Fire-Support-/Strategic-Resupply-Basis

## 1. Zweck dieser Übergabe

Dieses Dokument übergibt einem Folgechat den vollständigen fachlichen, technischen und evidenzbezogenen Arbeitsstand für ein künftig standortunabhängiges Modul mit der fachlichen Rolle:

```text
FireSupStratResupply_base.lua
```

Die konkrete Repository-Datei soll der bestehenden Namenskonvention folgen:

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
```

Es ist **noch kein Implementierungsauftrag und keine Runtime-Acceptance**. Der Folgechat darf erst nach den hier verlangten MOOSE-Prüfungen und der erforderlichen Projektinhaberentscheidung produktiven Lua-Code entwickeln.

Dieses Dokument enthält bewusst auch frühere Fehlannahmen, fehlende Nachweise und verworfene Lösungsansätze. Sie dürfen nicht erneut als offene Designoptionen behandelt werden.

## 2. Verbindliche Arbeitsregeln

Der Folgechat muss vor jeder Änderung diese Dokumente auf dem aktuellen `main` lesen und gegen den tatsächlich ausgecheckten Branch prüfen:

1. [Projekt-Governance – `OMW-GOV-001`](../00-project-governance.md)
2. [MOOSE-First-Entwicklungsrichtlinie – `OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md)
3. [Testmissionen bauen, übertragen und validieren – `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION`](../22-test-mission-build-transfer-and-validation-workflow.md)
4. [Dokumentmetadaten und Provenienz – `OMW-GOV-DOCUMENT-METADATA`](../DOCUMENT-METADATA-POLICY.md)
5. [Stage-3 CAS Tactical Corridor Decision](../moose/STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md)
6. [Stage-3 CAS Lifecycle and Recovery Law](../moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md)
7. [MOOSE-first-Gesetz für Unterstützungsanforderungen und deren Ablauf](../moose/MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md), solange dessen Pull Request noch offen ist: Branch `agent/moose-support-request-lifecycle-law`, nicht fälschlich als bereits auf `main` geltende Datei behandeln.

Zusätzlich gelten ohne Ausnahme:

- **MOOSE-first:** Erst Dokumentation, gepinnte `Moose.lua` und offizielle MOOSE-Demos/Tests prüfen; erst danach eine Lücke dokumentieren.
- **Öffentliche MOOSE-APIs:** Keine privaten Tabellen, keine `_DeleteQueueItem...`- oder vergleichbaren internen Methoden.
- **Kein zweiter Dispatcher:** OMW darf weder Assetwahl noch Verfügbarkeitsqueue, Retry-Schleifen oder Rekrutierung parallel zu MOOSE nachbauen.
- **CampaignState ist strategisch autoritativ:** MOOSE/DCS liefert bestätigte physische Lifecycle-Ereignisse; CampaignState übernimmt sie idempotent. Eine DCS-Gruppe ist keine zweite strategische Ressource.
- **Keine MIZ-Mutation:** Der Assistent baut Lua; Sven bindet das Bundle manuell in die MIZ ein. Eine übergebene MIZ wird nur lesend auf Objektvertrag und Hash geprüft.
- **Keine Behauptung ohne Evidenz:** Ein Build beweist Syntax, Konsistenz und Hashkette, aber kein DCS-Verhalten. Jede Runtime-Aussage benötigt den exakten Branch, Commit, Bundle-, MIZ-, MOOSE- und Log-Nachweis.

## 3. Ausgangslage auf `main`

Die Stage-3-Arbeit zum Fire Support und Strategic Resupply wurde über den Branch

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

in Pull Request #144 nach `main` integriert. Sven bestätigte lokal anschließend:

```text
main HEAD: c10628e1fb917854f720cb5f3051ff5f0dc595af
```

Dieser Commit ist ein historischer Übergabepunkt, nicht automatisch der künftig aktuelle `main`-HEAD. Vor jeder Folgearbeit gilt daher:

```powershell
git fetch origin
git switch <Arbeitsbranch>
git pull --ff-only origin <Arbeitsbranch>
git merge-base --is-ancestor origin/main HEAD
git status --short
```

Die letzte Bedingung ist nur eine Bestandsaufnahme. Bei lokalen, fremden oder unklaren Änderungen darf nichts zurückgesetzt, gelöscht oder überschrieben werden.

Der verwendete MOOSE-Stand der Stage-3-Prüfung lautet:

```text
MOOSE commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:   E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 4. Was der Honaker/Wright-Test tatsächlich belegt – und was nicht

Die Testmission war absichtlich ein konkreter Acceptance-Case:

```text
Bedrohter Standort:        COP Honaker
CAS-Heimat / Testbestand:  Jalalabad / AH-64
Strategischer Zielstandort: Wright
```

Sie ist **kein** generisches Produktionsmodul.

Festgehaltene, konkrete Testeigenschaften:

- CAS verwendet MOOSE `AUFTRAG:NewPATROLZONE(...)` und `SetEngageDetected(...)`.
- Der Einsatzweg folgt einer bereits konfigurierten OMW-Route; Ingress und Egress sind dynamisch auf dieser Hin- beziehungsweise Rückroute abgeleitet.
- Es gibt keine festen Editor-Marker und keine künstliche Battle Position.
- Im Test galt eine dynamische Gate-Zieldistanz von 3,5 NM; dies ist keine globale Regel für alle CAS-Muster oder Standorte.
- CAS-No-Contact basiert ausschließlich auf dem eigenen MOOSE-/DCS-Sensorbild der zugewiesenen Fluggruppe (`FLIGHTGROUP:GetDetectedGroups()`), nicht auf Incident-Listen, F10-Sichtbarkeit, roten Gruppenlisten oder `KnowTarget()`.
- Der Honaker-spezifische Release verlangte: unterstütztes Element kennt keine Angreifer mehr, CAS ist physisch on station und das eigene Sensorbild war mindestens 30 Sekunden stabil ohne relevanten Kontakt.
- Physische Rückkehr ist erst nach Landung am Heimatflugplatz **und** `AIRWING:OnAfterLegionAssetReturned(...)` strategisch als Rückgabe zu buchen.
- CAS on station hält nur **neue** ARTY-Feueraufträge im selben taktischen Raum zurück. Bereits laufende Feueraufträge werden nicht künstlich beendet.

Für eine spätere generische Basis dürfen davon nur die abstrakten Invarianten übernommen werden. Die konkreten Werte, Honaker-Bedingungen, Jalalabad-Bindung und Wright-Logistik sind zu parametrisieren oder als Testfixture zu belassen.

Der letzte dokumentierte Full-Response-Stand hatte Runtime-Evidenz für CAS-Dispatch, On-Station-/Reverse-Route und Recovery. Eine CAS-Waffenwirkung trat im beobachteten Lauf nicht ein, weil ARTY die relevanten Ziele bereits bekämpft hatte. Deshalb blieb die volle Terminal-Acceptance des Tests geplant; daraus darf keine allgemeine CAS-Waffen- oder Mehrstandort-Acceptance abgeleitet werden.

## 5. Fehler, Irrwege und verbindlich verworfene Ansätze

### 5.1 Feste CAS-Marker oder künstliche Battle Position

Verworfen. Es existieren und werden keine dauerhaft gesetzten `CAS_INGRESS`, `CAS_EGRESS` oder Battle-Position-Marker verlangt.

Richtig ist:

```text
konfigurierte tatsächliche Owner-Hinroute
-> dynamischer Ingress-Gate auf dieser Route
-> dynamischer AO-Anker des Auftrags
-> dynamischer Egress-Gate auf der tatsächlichen Owner-Rückroute
-> gleiche Route rückwärts zum Heimatflugplatz
```

Die vorhandene Route ist im Gebirgsgelände der taktische Korridor. Der Adapter darf sie in öffentliche MOOSE-Missions- und Waypoint-APIs übersetzen, aber keine Terrain-Masking-Heuristik oder neue Route erfinden.

### 5.2 Honaker/Jalalabad/Wright als Produktionsannahme

Verworfen. Diese Namen dürfen nicht im Base-Modul, dessen Zustandslogik oder generischen Acceptance-Kriterien fest verdrahtet werden.

Sie gehören ausschließlich in eine Standort-/Testkonfiguration.

### 5.3 Eine fehlende Unterstützung blockiert alle anderen

Verworfen. Guard, QRF, ARTY, CAS und Resupply sind unabhängige Optionen.

```text
ARTY nicht möglich        != CAS/QRF/Guard/Resupply blockieren
CAS nicht verfügbar       != ARTY/QRF/Guard/Resupply blockieren
kein lokales Personal     != externe ARTY/CAS oder laufenden Resupply blockieren
```

Eine Deconfliction-Regel darf nur den konkreten taktischen Konflikt begrenzen, beispielsweise neue ARTY-Fire-Missions bei physisch on-station befindlichem CAS.

### 5.4 Eigene Vorselektion oder eigene Retry-/Dispatch-Queue

Verworfen. OMW soll nicht vorab aus Kandidatenlisten entscheiden, welches Luft- oder Bodenasset gerade geeignet sei. MOOSE soll Rekrutierung, Verfügbarkeit und Warteschlange verwalten.

Eine fachliche Ablaufzeit oder Incident-Ende ist keine Assetwahl. Sie darf nur über den öffentlichen MOOSE-Lifecycle an einen Auftrag weitergegeben werden.

### 5.5 Rohes Incident-Ende als CAS-Ende

Verworfen. Alarmzone, `OPSZONE:Defeated`, Incident-Teilnehmer, rohe RED-Zähler, C2-Feuerbeobachtung oder `AUFTRAG:Cancel()` allein beweisen weder ein reguläres CAS-Ende noch die physische Recovery.

Die Alarmzone bedeutet:

```text
threat-detection and response-trigger boundary
!= weapons engagement zone
!= CAS tactical area
!= mission-end condition
```

### 5.6 Unbestätigte Ressourcenbuchung

Verworfen. Ein Start, ein Rückkehrbefehl, `Done`, Cancel oder ein in Transit befindlicher Konvoi verändern den strategischen Zielbestand nicht.

- Rückkehrende Assets werden erst nach bestätigtem MOOSE-Rückkehrereignis wieder verfügbar.
- Lieferungen erhöhen den Zielbestand erst nach bestätigter physischer Lieferung.
- Ein Personaltransport im Transit stellt am Ziel noch keine Guard-/QRF-Mannschaft bereit.

### 5.7 Private MOOSE-Warehouse-Queue-Manipulation

Verworfen. Der gepinnte MOOSE-Stand enthält interne Löschmethoden, aber keine bestätigte öffentliche Einzelrequest-Expiry-/Cancel-API für rohe `WAREHOUSE:AddRequest(...)`-Requests. Diese Interna dürfen nicht als Lösung verwendet werden.

## 6. Verifizierter MOOSE-Lifecycle und offene Grenzen

Die folgenden Aussagen sind gegen die gepinnte `Moose.lua` geprüft. Sie sind source-reviewed, nicht DCS-validiert.

| MOOSE-Bereich | Bestätigtes Verhalten | Folge für die Base |
|---|---|---|
| `LEGION:AddMission` / `CheckMissionQueue` | Queue, Rekrutierungsversuch und `AUFTRAG:IsReadyToCancel()` | direkte Legion-/AIRWING-/BRIGADE-Aufträge können native Zeiten/Conditions nutzen |
| `COMMANDER` / `CHIEF` | geplante Missionen werden rekrutiert versucht; der geprüfte Planungsweg ruft für weiter PLANNED-Missionen nicht selbst `IsReadyToCancel()` auf | bei Incident-Ende oder fachlichem Ablauf muss ein minimaler Lifecycle-Adapter `AUFTRAG:Cancel()` auslösen |
| `AUFTRAG` | `SetTime`, Start-/Success-/Failure-Conditions und `Cancel()` vorhanden | native Auftragssprache verwenden; kein eigener FSM |
| `OPSTRANSPORT` | `SetTime`, `AddConditionStart`, `Cancel()` vorhanden; Cancel propagiert an MOOSE-Organisationen | Ablauf/Incident-Ende über `Cancel()`, nicht über nicht verifizierte Failure-API behaupten |
| `WAREHOUSE` | dauerhaft ungültige Requests werden intern verworfen; temporär unprozessierbare bleiben wartend | nicht durch OMW vorfiltern; Nullbestand-/Einzelrequest-Expiry bleibt offene API-Grenze |
| `ARTY` | eigene Target-Queue, `RemoveTarget`, `SetTimeToShot` | ARTY-Target-Lifecycle nur über MOOSE-ARTY führen |

Für einen bei `COMMANDER`/`CHIEF` wartenden, aber fachlich obsoleten Auftrag ist diese minimale projektspezifische Ergänzung zulässig und erforderlich:

```text
Incident-Ende oder einmalige fachliche Ablaufzeit
-> AUFTRAG:Cancel()
-> öffentlicher MOOSE-CHIEF/COMMANDER/LEGION-Cancelpfad
```

Sie darf **nicht** auswählen, rekrutieren oder wiederholen. Sie ist ereignisgebunden, nicht hochfrequent.

Die unaufgelöste WAREHOUSE-Grenze bleibt explizit offen:

```text
rohe WAREHOUSE-Anforderung mit dauerhaft leerem passenden Bestand
-> individuelle öffentliche Expiry-/Cancel-API im geprüften Stand nicht nachgewiesen
```

Vor einer generischen Ablaufgarantie muss der Folgechat entweder eine öffentliche MOOSE-API im tatsächlich eingesetzten Stand nachweisen oder einen bereits kontrollierbaren öffentlichen Auftrags-/OPSTRANSPORT-Lifecycle nutzen. Andernfalls ist eine zusätzliche MOOSE-first-Lückenanalyse plus ausdrückliche Projektinhaberfreigabe Pflicht.

## 7. Zielarchitektur der Base

Die Base ist ein **Incident-to-MOOSE-Orchestrator**, kein Combat- oder Resource-Dispatcher.

```text
Installation / lokale Lage
-> Incident und fachliche Bedarfe
-> OMW_FireSupStratResupply_Base
-> pro Support-Art ein kleiner MOOSE-Adapter
-> MOOSE COMMANDER/CHIEF/LEGION/AIRWING/BRIGADE/WAREHOUSE/ARTY
-> bestätigte MOOSE-Lifecycle-Ereignisse
-> idempotente CampaignState-Buchung
```

### 7.1 Verantwortung der Base

Die Base darf:

- Incident-Eröffnung, -Änderung, -Ende und fachliche Obsoleszenz entgegennehmen;
- pro Support-Art einen separaten, fachlich zulässigen Bedarf materialisieren;
- standortneutrale IDs und Konfigurationen validieren;
- die public-MOOSE-Adapter aufrufen;
- ihre eigenen Incident-/Demand-Korrelationen und Diagnosegründe verwalten;
- Incident-Ende und eine einmalige fachliche Ablaufzeit an `AUFTRAG:Cancel()` oder `OPSTRANSPORT:Cancel()` weiterreichen;
- bestätigte MOOSE-Ereignisse idempotent in `CampaignState` übernehmen.

Sie darf nicht:

- Assets selbst auswählen oder anhand eigener Kandidatenlisten ausschließen;
- eine zusätzliche Queue, einen eigenen Recruiter oder Timer-Retries bauen;
- MOOSE-Detection, Route-Planung, ARTY-Targeting oder Warehouse-Validierung ersetzen;
- eine Lieferung, Rückkehr oder einen Verlust aus Absicht statt physischem MOOSE-Ereignis buchen;
- statische CAS-Marker, künstliche BPs oder standortspezifische Namen voraussetzen.

### 7.2 Empfohlene Dateien

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
scripts/campaign/OMW_FireSupStratResupply_LifecycleAdapter.lua
scripts/campaign/OMW_FireSupStratResupply_CampaignStateAdapter.lua

scripts/ground/OMW_FireSupStratResupply_GuardAdapter.lua
scripts/ground/OMW_FireSupStratResupply_QrfAdapter.lua
scripts/ground/OMW_FireSupStratResupply_ArtyAdapter.lua
scripts/air-operations/OMW_FireSupStratResupply_CasAdapter.lua
scripts/logistics/OMW_FireSupStratResupply_ResupplyAdapter.lua
```

Bestehende Adapter sind vorher zu prüfen und nach Möglichkeit weiterzuverwenden, insbesondere:

```text
scripts/campaign/OMW_FobAttackFireSupportDemandPolicy.lua
scripts/ground/OMW_FobAttackFunctionalArtyDispatchAdapter.lua
scripts/air-operations/OMW_FobAttackCasDispatchAdapter.lua
scripts/air-operations/OMW_HelicopterFlightPathCorridor.lua
scripts/air-operations/OMW_HelicopterCasTacticalCorridor.lua
scripts/air-operations/OMW_OpsTransportCorridorAdapter.lua
scripts/ground/OMW_FixedFireSupportAmmoSupport.lua
```

Der Folgechat darf diese Dateinamen und Schnittstellen nicht voraussetzen, ohne sie auf dem aktuellen Branch zu lesen.

## 8. Konfigurationsvertrag

Alle Standortunterschiede gehören in Daten, nicht in Base-Code.

```lua
local sites = {
  FOB_JOYCE = {
    siteId = "FOB_JOYCE",
    alarmZoneName = "BLUE_GROUND_FOB_JOYCE",
    tacticalZoneName = "OMW_FOB_JOYCE_C2",
    campaignNodeId = "FOB_JOYCE",

    support = {
      guards = { enabled = true },
      qrf = { enabled = true },
      artillery = { enabled = true },
      cas = { enabled = true, corridorProfile = "JOYCE_HELICOPTER" },
      resupply = {
        enabled = true,
        classes = {
          "GROUND_PERSONNEL",
          "GROUND_AMMO_PACKAGE",
          "GROUND_FUEL_PACKAGE",
          "META_SUPPLY",
        },
      },
    },

    routes = {
      groundProfile = "JOYCE_GROUND",
      helicopterProfile = "JOYCE_HELICOPTER",
      fixedWingProfile = nil,
    },
  },
}
```

`enabled = true` bedeutet nur: Die Fähigkeit ist an diesem Standort fachlich vorgesehen und kann an MOOSE übergeben werden. Es bedeutet nicht, dass jetzt ein Asset vorhanden, erreichbar, bewaffnet, bemannt oder freigegeben ist.

Der Support-Adapter erhält einen standardisierten Bedarf:

```lua
local demand = {
  incidentId = "INCIDENT:FOB_JOYCE:000123",
  demandId = "DEMAND:...:CAS",
  siteId = "FOB_JOYCE",
  supportType = "CAS",
  requestedAt = timer.getTime(),
  tacticalContext = {
    alarmZone = "BLUE_GROUND_FOB_JOYCE",
    tacticalZone = "OMW_FOB_JOYCE_C2",
  },
  validity = {
    expiresAt = nil, -- missionsspezifisch bestimmen
    cancelWhenIncidentClosed = true,
  },
  correlationId = "stable-id",
}
```

Der Vertrag enthält absichtlich keine durch OMW vorgewählte Aircraft-, Cohort-, Battery- oder Carrier-ID.

## 9. Sonderfall: Auswahl des strategischen Herkunftspools

Hier besteht ein dokumentationspflichtiger Konflikt, der vor der Produktion aufgelöst werden muss.

Die aktuell auf `main` geltende Governance enthält die Aussage, CampaignState wähle den konkreten Herkunftspool und der MOOSE-Auftrag werde daran gebunden. In der aktuellen fachlichen Entscheidung für die Base soll MOOSE jedoch die geeigneten aktuell verfügbaren CAS- und Ground-Assets aus dem zulässigen Pool verwalten, ohne dass OMW eine Kandidatenliste vorfiltert.

Beides ist nicht zugleich uneingeschränkt wahr.

Vor Implementierung muss deshalb der Projektinhaber eine verbindliche Präzisierung auf `main` oder in einem zugelassenen ADR festlegen:

1. **Strategische Pool-Grenze:** CampaignState liefert nur die zulässige Organisations-/Besitzgrenze, etwa Operationsraum, Koalition, Assetklasse und Ressourcenrecht.
2. **Operative Auswahl innerhalb dieser Grenze:** MOOSE bestimmt Rekrutierung, aktuelle Verfügbarkeit, Warteschlange und Ausführung.
3. **Keine OMW-Kandidatenwahl:** Der Base-Adapter trifft weder Typ-, Squadron-, Cohort- noch ETA-Entscheidungen.
4. **Keine unzulässige Vermischung strategischer Bestände:** Falls verschiedene Pools unterschiedliche strategische Eigentümer haben, muss die konfigurierte MOOSE-Organisation diese Grenze technisch erhalten oder die Governance muss ein gemeinsames Poolmodell ausdrücklich zulassen.

Bis zu dieser Entscheidung bleibt eine global optimierende Auswahl nach Ankunftszeit, Verfügbarkeit und Muster über mehrere strategische Pools **PLANNED**. Der Honaker-Test bindet aktuell eine konkrete Jalalabad-AH-64-Testressource und beweist diese generische Auswahl nicht.

## 10. CAS-Routenvertrag für die Base

Für Drehflügler ist der bereits entwickelte Korridoransatz wiederzuverwenden, aber zu generalisieren:

```text
Heimatflugplatz
-> konfigurierte tatsächliche OMW_HelicopterFlightPath-Variante
-> Hinroute zum Zielstandort
-> dynamischer Ingress-Gate auf dieser Hinroute
-> dynamischer AO-Anker für PATROLZONE
-> dynamischer Egress-Gate auf der Rückroute
-> gleiche Owner-Route rückwärts
-> Heimatflugplatz
```

Erforderliche Korrekturen vor generischem Einsatz:

- testbezogene Namen wie `honakerReference` und `westReference` durch neutrale Begriffe ersetzen;
- Zielabstand, akzeptierte Toleranz, Höhe, Geschwindigkeit und Routeprofil aus einer Asset-/Missionsprofil-Konfiguration beziehen;
- eine eigene Fixed-Wing-Route nicht ohne separaten MOOSE-first-Review aus dem Helikopteradapter ableiten;
- keine Annahme treffen, dass jeder Standort eine 3–4-NM-Gate-Geometrie besitzt;
- bei fehlender gültiger Owner-Route oder fehlendem Gate den konkreten CAS-Bedarf mit einem überprüfbaren Grund abbrechen beziehungsweise durch den normalen MOOSE-/Demand-Lifecycle beenden; keine Ersatzgeometrie erfinden.

Die öffentliche MOOSE-Schnittstelle bleibt eng:

```lua
mission:SetMissionIngressCoord(...)
mission:SetMissionWaypointCoord(...)
mission:SetMissionEgressCoord(...)
flightGroup:AddWaypoint(...)
flightGroup:UpdateRoute()
```

Die Korridorlogik ergänzt Owner-Transitsegmente erst, wenn die MOOSE-Missionswaypoints vorhanden sind. Dazu ist der vorhandene öffentliche Callback-Ansatz zu verwenden, nicht ein Blind-Timer oder nativer DCS-Controller-Task.

## 11. Resupply- und Personalvertrag

Resupply umfasst mindestens:

```text
GROUND_PERSONNEL
GROUND_AMMO_PACKAGE
GROUND_FUEL_PACKAGE
META_SUPPLY
```

Die Base darf keine lokale Verfügbarkeit fingieren.

Beispiel, das zwingend zu unterstützen ist:

```text
erster Angriff
-> FOB verliert Personal
-> MOOSE-Resupply für Personal wird gestartet

zweiter Angriff während des Personaltransits
-> lokale Guard-/QRF-Kohorte kann wegen fehlenden bestätigten Personals nicht entstehen
-> bereits laufender Personaltransport bleibt im normalen MOOSE-Lifecycle
-> externe ARTY und/oder CAS können unabhängig weiter angefordert werden
-> erst bestätigte Lieferung erhöht den Zielbestand
-> ein weiterhin gültiger MOOSE-Groundauftrag kann danach rekrutiert werden
```

Die strategische Buchung erfolgt genau einmal, mit stabiler Correlation-/Settlement-ID, nur nach bestätigtem Ereignis.

## 12. Vorgeschriebene Implementierungsreihenfolge

### Gate 0 – Bestandsaufnahme und Behördenlage

- aktuellen `main`, Arbeitsbranch und uncommitted Dateien prüfen;
- alle in Abschnitt 2 genannten Regeln lesen;
- für jede wiederzuverwendende Datei den tatsächlichen aktuellen Inhalt, nicht eine historische Übergabe, prüfen;
- den Konflikt aus Abschnitt 9 verbindlich entscheiden und dokumentieren;
- das Lifecycle-Gesetz aus PR #147 entweder nach `main` integrieren oder im Folgebranch eindeutig als offene, noch nicht main-gültige Grundlage ausweisen.

**Kein Lua-Code vor Abschluss von Gate 0.**

### Gate 1 – MOOSE-First-Gap-Analyse

Für Guard, QRF, ARTY, CAS, Bodenresupply und Luftresupply separat dokumentieren:

```yaml
requirement:
moose_version:
moose_documentation_checked:
moose_classes_and_methods_evaluated:
moose_source_locations:
official_examples_checked:
verified_limitation:
smallest_required_fallback:
integration_with_moose:
planned_acceptance_test:
```

Bei einer fehlenden MOOSE-Funktion ist die ausdrückliche Freigabe des Projektinhabers einzuholen. Das gilt auch für jeden neuen Lifecycle-Adapter, der über die bereits source-geprüfte Cancel-Weitergabe hinausgeht.

### Gate 2 – Datenvertrag ohne DCS-Ausführung

- Standortregistry und Support-Profil als reine Lua-Daten definieren;
- stabile Standort-, Incident-, Demand-, Ressourcen- und Settlement-IDs definieren;
- Syntax-/Unit-Test: Honaker/Wright als erste Konfiguration, Joyce als zweite Konfiguration;
- keine MIZ ändern und keine statischen CAS-Marker einführen.

### Gate 3 – Base und minimale Adapter

- `OMW_FireSupStratResupply_Base.lua` ausschließlich als Koordinator implementieren;
- jeden Supportbedarf getrennt erzeugen;
- public MOOSE-Auftrag beziehungsweise -Transport nur an die vorhandene MOOSE-Organisation weiterreichen;
- Incident-Ende und Einmal-Ablauf über public `Cancel()` weiterreichen;
- lückenlose Logs mit Incident-, Demand-, Standort- und Ressourcen-ID erzeugen;
- keine Assetscan-/Retry-Schleife.

### Gate 4 – Rückwärtskompatible Stage-3-Regression

Die vorhandene Honaker/Wright-Konfiguration muss funktional unverändert bleiben:

- Alarm löst die vorgesehenen Bedarfe aus;
- QRF/Guard bleiben vom lokalen Incident-Lifecycle korrekt getrennt;
- ARTY, CAS und Resupply blockieren sich nicht außerhalb dokumentierter Deconfliction;
- CAS verwendet eigene Detektion und dynamische Owner-Routen;
- Rückgabe/Lieferung wird nur nach bestätigtem MOOSE-Ereignis gebucht.

### Gate 5 – Zweiter, unabhängiger Standort

FOB Joyce oder ein vergleichbar vorbereiteter Standort muss als **zweite** Konfiguration getestet werden. Der Test darf weder Honaker-Namen noch Jalalabad- oder Wright-spezifische Routen unbemerkt voraussetzen.

### Gate 6 – DCS-Acceptance und Produktionsentscheidung

Erst nach den folgenden Nachweisen darf die Base als produktiv vorgeschlagen werden.

## 13. Verbindliche Acceptance-Matrix

| Nr. | Situation | Minimaler Nachweis |
|---:|---|---|
| 1 | temporär kein passendes CAS- oder Ground-Asset, später Rückkehr | MOOSE wartet; Start nur bei weiter gültigem Bedarf |
| 2 | Incident endet vor Rekrutierung | geplanter `COMMANDER`-/`CHIEF`-Auftrag wird über `AUFTRAG:Cancel()` entfernt |
| 3 | fachliche Frist endet vor Rekrutierung | gleicher Cancel-/Queue-Entfernungsnachweis |
| 4 | direkte `LEGION`-/`AIRWING`-/`BRIGADE`-Queue | native `SetTime`/Conditions führen zum vorgesehenen Cancel |
| 5 | keine ARTY in Reichweite oder keine ARTY-Munition | ARTY wird nicht geleistet; CAS/QRF/Guard/Resupply bleiben unabhängig |
| 6 | kein CAS verfügbar | ARTY/QRF/Guard/Resupply bleiben unabhängig |
| 7 | Personalresupply unterwegs, zweiter Angriff | kein lokales Guard/QRF vor bestätigter Lieferung; externe Optionen bleiben möglich |
| 8 | Resupply aller vier Klassen | Lieferung wird je Klasse erst nach physischem MOOSE-Ereignis idempotent gebucht |
| 9 | CAS-Route an Standort A und B | dynamische Gates auf realen Owner-Routen; keine festen Marker, keine erfundene BP |
| 10 | CAS-Normalende | eigene Sensorlage, missionsprofilgerechte Freigabe, Route rückwärts, Landung und AIRWING-/LEGION-Rückgabe |
| 11 | `WAREHOUSE` dauerhaft ungültig | MOOSE entfernt die Anfrage selbst; keine private OMW-Manipulation |
| 12 | `WAREHOUSE` temporär blockiert | MOOSE verarbeitet später, wenn es wieder möglich ist |
| 13 | `WAREHOUSE` ohne passenden Bestand | dokumentierte offene Grenze; keine behauptete Bereinigung ohne neue öffentliche MOOSE-API oder genehmigte Ausnahme |
| 14 | Restart/Mehrfachereignis | CampaignState bleibt idempotent, keine Doppelbuchung und keine stille Bestandskorrektur |

Jeder DCS-Lauf benötigt die vollständige Build-/MIZ-/Hashkette aus Dokument 22. Tests mit geändertem Bundle oder geänderter MIZ machen frühere Runtime-Belege nicht ungültig, aber auch nicht auf den neuen Stand übertragbar.

## 14. Erwartetes Ergebnis des Folgechats

Der Folgechat liefert zunächst nur:

1. geprüfte Bestandsaufnahme des aktuellen Branches;
2. MOOSE-first-Gap-Analyse je Support-Art;
3. die dokumentierte Entscheidung zum strategischen Poolkonflikt;
4. Datenvertrag und Acceptance-Plan;
5. erst nach Genehmigung die schlanke Base sowie ihre Adapter;
6. Build-Befehle für das Lua-Bundle, niemals eine bearbeitete MIZ;
7. nach jedem DCS-Test einen Ergebnisbericht mit positiven und negativen Nachweisen.

Er darf nicht:

- aus dem Honaker-Test ohne zweiten Standort eine generische Produktivfunktion erklären;
- nicht bestätigtes MOOSE- oder DCS-Verhalten erfinden;
- die offene WAREHOUSE-Einzelrequest-Grenze verdecken;
- die bestehenden Regeln durch eine neue Detaildokumentation stillschweigend überschreiben;
- Fehlersymptome durch unkontrollierte zusätzliche Timer, Direkt-Controller-Tasks oder globale Scanlogik kaschieren.

## 15. Kurzfassung für den Start eines Folgechats

> Wir wollen eine standortunabhängige MOOSE-first-Basis für Guard, QRF, ARTY, CAS und mehrklassigen Resupply entwickeln. Die Base ist nur Incident-to-MOOSE-Koordinator; MOOSE verwaltet Rekrutierung, Queue, Ausführung und physische Lifecycle-Ereignisse, CampaignState die strategische Persistenz. Standortdaten, Routen und Supportprofile sind Konfiguration. Keine festen CAS-Marker, keine künstliche Battle Position, keine zweite Assetauswahl/Queue und keine MIZ-Mutation. Honaker/Wright/Jalalabad sind ein konkretes Testfixture, keine globale Produktionsannahme. Vor Lua: aktuelles `main` und die in diesem Handoff verlinkten verbindlichen Regeln lesen, MOOSE-Dokumentation + gepinnte Source + offizielle Demos prüfen, Poolkonflikt entscheiden, Lifecycle-Gesetz-Status prüfen. Danach erst Datenvertrag, Adapter und zwei unabhängige DCS-Acceptance-Standorte.
