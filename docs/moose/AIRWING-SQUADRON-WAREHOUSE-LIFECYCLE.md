---
document_id: OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE
status: BINDING
document_class: TECHNICAL_LIFECYCLE_AND_TEST_GOVERNANCE
owning_policy: OMW-GOV-001
authoritative_for:
  - AIRWING, SQUADRON and WAREHOUSE lifecycle in the pinned MOOSE 2.9.18 artifact
  - mandatory pre-start and post-start assertion boundaries
  - vertical-helicopter option propagation
  - COMMANDER start and selection sequence
  - observer-client handling in AirOps acceptance tests
  - static gates before another long DCS test
not_authoritative_for:
  - airfield-specific ORBAT, object names or parking IDs
  - actual vertical departure before a dedicated DCS dispatch acceptance
  - tactical mission completion, recovery or persistence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - undocumented assumptions that SQUADRON.assets is populated by AIRWING:AddSquadron()
  - ad-hoc pre-start asset assertions
  - test-specific observer-client overrides that hide detected clients
superseded_by:
source_branch: agent/consolidate-air-ops-lifecycle-governance
source_commit: PENDING_MERGE
validated_in_dcs: partial
moose_release: 2.9.18
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# AIRWING, SQUADRON und WAREHOUSE – Lifecycle und Testgrenzen

## 1. Zweck

Dieses Dokument legt den verbindlichen technischen Ablauf für alle OMW-AirOps-Knoten fest. Es verhindert insbesondere folgende wiederkehrende Fehler:

- Prüfung von `squadron.assets` vor `AIRWING:Start()` gegen den später erwarteten Assetbestand;
- Gleichsetzung von Warehouse-Stock, COHORT-/SQUADRON-Assets und gespawnter Runtime-Gruppe;
- Bewertung einer gesetzten AIRWING-Option als bereits bewiesenes DCS-Flugverhalten;
- COMMANDER-Tests ohne `COMMANDER:Start()`;
- Ausblendung eines aktiven Beobachter-Clients durch manipulierte Zählfunktionen;
- Wiederverwendung eines Struktur-PASS nach einer veränderten oder neu gespeicherten `.miz`.

Für den gepinnten MOOSE-Stand sind Dokumentation, Quellcode und OMW-Runtime-Evidenz gemeinsam maßgeblich.

## 2. Geprüfte MOOSE-Quellpfade

Geprüft wurden im eingebetteten Artefakt mindestens:

```text
SQUADRON:New()
COHORT:New()
AIRWING:AddSquadron()
AIRWING:AddAssetToSquadron()
WAREHOUSE:AddAsset()
COHORT:AddAsset()
AIRWING:onafterStart()
WAREHOUSE:onafterStart()
AIRWING:FlightOnMission path
AIRWING:SetOptionPreferVerticalLanding()
FLIGHTGROUP:SetOptionPreferVertical()
CONTROLLABLE:OptionPreferVerticalLanding()
COMMANDER:New()
COMMANDER:AddAirwing()
COMMANDER:AddLegion()
COMMANDER:onafterStart()
COMMANDER:onafterStatus()
```

Die Regeln dieses Dokuments gelten nur für den oben genannten MOOSE-Commit und das identische `Moose.lua`-Artefakt. Bei einer geänderten MOOSE-Datei ist die Lifecycle-Prüfung erneut auszuführen.

## 3. Verbindliche Lifecycle-Matrix

| Phase | Auslöser | `airwing.cohorts` | `airwing.stock` | `squadron.assets` | Runtime-`OPSGROUP` | Zulässige Hauptprüfung |
|---|---|---:|---:|---:|---:|---|
| P0 Konstruktion | `SQUADRON:New()` | noch nicht registriert | unverändert | leer | 0 | Template, `Ngroups`, Gruppierung, Capabilities, Parking-Konfiguration |
| P1 Registrierung | `AIRWING:AddSquadron()` | SQUADRON eingetragen | Assetgruppen synchron registriert | weiterhin leer beziehungsweise noch nicht als COHORT-Bestand gebunden | 0 | kumulativer Warehouse-Stock, Cohort-Anzahl, Payloadregistrierung |
| P2 Startaufruf | `AIRWING:Set...`; danach `AIRWING:Start()` | vollständig | registrierter Stock vorhanden | Bindung beginnt im WAREHOUSE-/LEGION-Startpfad | 0 erwartet | Optionsreihenfolge und Startaufruf |
| P3 stabiler Idle-Stand | verzögerte Prüfung nach Start | vollständig | Sollbestand | `Ngroups` je SQUADRON | 0 | SQUADRON-Assetzahl, `Asset.cohort`, `Asset.legion`, `Asset.squadname`, geerbte `asset.parkingIDs` |
| P4 Dispatch | `AIRWING:AddMission()` oder COMMANDER-Zuweisung | vollständig | sinkt beziehungsweise wechselt Status | Assets vorhanden | erwartete Gruppen entstehen | Auswahl, Request, `OpsOnMission`, AUFTRAG-Zustand |
| P5 Rückkehr/Recovery | Landung, Rückgabe oder Despawn | vollständig | Rückgabe abhängig vom getesteten Pfad | Assetstatus aktualisiert | 0 nach Cleanup erwartet | Rückkehr, Verlust, Stranded, Recovery und Persistenz separat |

## 4. Bedeutung der zentralen Tabellen

### 4.1 `SQUADRON:New()`

`SQUADRON:New(template, Ngroups, name)` erzeugt ein SQUADRON-/COHORT-Objekt. `Ngroups` ist die Anzahl der zu registrierenden **Assetgruppen**, nicht die Zahl der Luftfahrzeuge. In dieser Phase ist `squadron.assets` noch kein Beweis für den späteren Bestand.

Zulässig vor `AIRWING:AddSquadron()`:

```text
Template vorhanden
Template-Unitzahl korrekt
DCS-Typ korrekt
Ngroups korrekt
Grouping korrekt
Capabilities korrekt
SQUADRON.parkingIDs korrekt konfiguriert
```

### 4.2 `AIRWING:AddSquadron()`

Der geprüfte MOOSE-Code führt in dieser Reihenfolge aus:

```text
SQUADRON in airwing.cohorts eintragen
AIRWING:AddAssetToSquadron(Squadron, Squadron.Ngroups)
automatisches RELOCATECOHORT-Payload registrieren
Squadron:SetAirwing(self)
SQUADRON-FSM bei Bedarf starten
```

`AIRWING:AddAssetToSquadron()` registriert über `WAREHOUSE:AddAsset()` die Assetgruppen im Warehouse-Stock. Daraus folgt:

```text
AIRWING:AddSquadron() PASS
=> airwing.stock ist kumulativ erhöht
=> airwing.cohorts enthält die SQUADRON
!= squadron.assets ist bereits vollständig gebunden
```

### 4.3 `AIRWING:Start()`

`AIRWING:onafterStart()` ruft den Startpfad des übergeordneten WAREHOUSE auf. Im anschließenden Initialisierungs- und Zuordnungspfad werden Warehouse-Assets dem COHORT/SQUADRON zugeordnet. `COHORT:AddAsset()` setzt:

```lua
Asset.squadname = self.name
Asset.legion = self.legion
Asset.cohort = self
table.insert(self.assets, Asset)
```

Darum ist eine positive Sollbestandsprüfung von `squadron.assets` erst **nach** dem AIRWING-/WAREHOUSE-Start zulässig.

## 5. Verbindliche Pre-Start-Prüfregeln

Vor `AIRWING:Start()` müssen geprüft werden:

```text
AIRBASE und Warehouse eindeutig aufgelöst
Objektvertrag vollständig
keine unerwartete MIZ-Abweichung
SQUADRONs vollständig konstruiert
airwing.cohorts == erwartete SQUADRON-Zahl
airwing.stock == kumulativ erwartete Assetgruppen
Capabilities und Payloads vollständig
Mission-, Transport- und Requestqueues leer
keine Runtime-OPSGROUPs
Startart und Safe-Parking-Konfiguration gesetzt
Vertikaloption bei Helikopter-AIRWING vor Start gesetzt
```

Vor Start ausdrücklich unzulässig:

```text
squadron.assets gegen Ngroups > 0 als PASS/FAIL-Gate prüfen
asset.parkingIDs aus squadron.assets als bereits geerbten Runtimevertrag prüfen
sichtbare Runtime-Platzierung behaupten
vertikalen Abflug behaupten
Missionserfolg oder Recovery behaupten
```

Eine rein diagnostische Feststellung `squadronAssetsBeforeStart=0` ist zulässig, wenn sie als erwarteter Deferred-Zustand bezeichnet und nicht als Fehler gewertet wird.

## 6. Verbindliche Post-Start-Prüfregeln

Die Post-Start-Prüfung erfolgt verzögert, damit der WAREHOUSE-/LEGION-Startpfad abgeschlossen ist. Sie muss mindestens erfassen:

```text
AIRWING state == Running
#airwing.cohorts == erwartete SQUADRON-Zahl
#airwing.stock == erwartete registrierte Assetgruppen
#squadron.assets == Ngroups je SQUADRON
Asset.squadname == SQUADRON-Name
Asset.cohort == SQUADRON-Objekt
Asset.legion == AIRWING
asset.parkingIDs == SQUADRON.parkingIDs, sofern Parking im Scope liegt
Missionqueue == 0 bei einem Idle-Test
Transportqueue == 0 bei einem Idle-Test
Requestqueue == 0 bei einem Idle-Test
Runtime-OPSGROUPs == 0 bei einem Idle-Test
keine spontanen Spawns
```

Interne Tabellenkonsistenz bleibt von sichtbarer DCS-Platzierung getrennt:

```text
asset.parkingIDs korrekt
!= tatsächlicher Spawnplatz korrekt
```

## 7. Vertikale Helikopter-Option

### 7.1 AIRWING-Konfiguration

Für MOOSE-gemanagte Helikopterflüge lautet der verbindliche Konfigurationspfad:

```lua
airwing:SetOptionPreferVerticalLanding()
airwing:Start()
```

Die Option muss vor `AIRWING:Start()` gesetzt sein.

### 7.2 MOOSE-Weitergabe

Im geprüften MOOSE-Quellstand setzt `AIRWING:SetOptionPreferVerticalLanding()` zunächst nur:

```lua
self.OptionPreferVerticalLanding = true
```

Im nativen `FlightOnMission`-Pfad wird die Option auf die tatsächlich erzeugte FLIGHTGROUP weitergereicht:

```lua
FlightGroup:SetOptionPreferVertical()
```

`FLIGHTGROUP:SetOptionPreferVertical()` ruft bei einer lebenden Gruppe auf:

```lua
self:GetGroup():OptionPreferVerticalLanding()
```

Dies setzt die DCS-AI-Option `AI.Option.Air.id.PREFER_VERTICAL`.

### 7.3 Nachweisgrenze

Folgende Aussagen sind getrennt zu behandeln:

```text
Option vor AIRWING-Start gesetzt: statisch und in G7 prüfbar
Option durch nativen Dispatch auf FLIGHTGROUP weitergegeben: in G8 telemetrisch zu prüfen
Hubschrauber hebt tatsächlich vertikal vom Stand ab: nur visuell und in DCS akzeptierbar
```

Raw-`SPAWN`, nachträgliche `UNIT:OptionPreferVerticalLanding()`-Versuche und standalone FLIGHTGROUP-Experimente sind kein Ersatz für den nativen AIRWING-/AUFTRAG-Pfad.

## 8. COMMANDER-Sequenz

Verbindlicher Acceptance-Pfad:

```lua
local commander = COMMANDER:New(...)
commander:AddAirwing(airwing)
commander:Start()
local canMission = commander:CanMission(mission)
commander:AddMission(mission)
commander:Status()
```

Bedeutung:

- `COMMANDER:New()` erzeugt den FSM im Ausgangszustand `NotReadyYet`;
- `AddAirwing()` ruft nur `AddLegion()` auf und setzt die Verknüpfung;
- `AddAirwing()` startet den COMMANDER nicht;
- `COMMANDER:Start()` führt `onafterStart()` aus, startet nötigenfalls angehängte LEGIONs und plant den Statuszyklus;
- `COMMANDER:Status()` beziehungsweise der normale Statuszyklus führt `CheckMissionQueue()` aus.

PASS verlangt positive Ereignisse und darf nicht allein aus dem Fehlen eines Fehlers abgeleitet werden:

```text
NotReadyYet -> OnDuty
CanMission == true
MissionAssign
AIRWING MissionRequest
erwartetes Asset OpsOnMission
AUFTRAG mindestens started
```

## 9. Observer-Client-Policy

Ein aktiver Beobachter-Client ist zulässig, wenn alle folgenden Bedingungen erfüllt sind:

```text
Clientgruppe und Unit sind Bestandteil des bestätigten Objektvertrags
Client-TerminalID ist hart aus sämtlichen KI-Parkingpools ausgeschlossen
Test erzeugt keine Mission oder Spawnbewegung, die durch den Client verfälscht wird
Client wird ausschließlich zur visuellen Beobachtung verwendet
Detektion und Blockierbewertung werden getrennt protokolliert
```

Pflichttelemetrie:

```text
observerClientsDetected=<n>
observerClientsAllowed=<n>
observerClientsBlocking=<n>
observerClientUnits=<names>
policyReason=HARD_EXCLUDED_CLIENT_TERMINAL|...
```

Unzulässig ist eine Funktionsüberschreibung, die einen tatsächlich erkannten Client durch Rückgabe `0` aus dem Endergebnis verschwinden lässt. Der tatsächliche Zählwert bleibt erhalten; nur der separate Blockierwert darf `0` sein.

## 10. MIZ-Änderungs- und Transferregel

Jedes Speichern, Überschreiben, Neuverpacken oder Übertragen einer `.miz` erzeugt ein neues Testartefakt. Der frühere Struktur-PASS bleibt historische Evidenz, ist aber nicht automatisch auf die neue Datei übertragbar.

Nach jeder MIZ-Änderung sind mindestens neu zu erfassen:

```text
MIZ-Dateiname
MIZ-SHA-256
interner mission-SHA-256
Moose.lua-SHA-256
Testbundle-SHA-256
Builder-Version
Git-Commit
Objektvertragssmoke für alle im nächsten Gate verwendeten Objekte
Trigger-/Ressourcenreferenz auf das erwartete Bundle
```

Eine unveränderte sichtbare Missionsoberfläche genügt nicht. Mission-Editor-Speichern kann Namen, IDs, Ressourcen oder eingebettete Dateien verändern.

## 11. Statische Sperre vor langem DCS-Test

Ein weiterer längerer DCS-Lauf ist gesperrt, bis alle folgenden Prüfungen PASS sind:

```yaml
documentation_links_resolve: true
lifecycle_matrix_applied: true
prestart_assertions_valid: true
poststart_assertions_present: true
observer_policy_non_masking: true
vertical_policy_before_start: true
commander_sequence_valid_if_applicable: true
builder_guard_pass: true
source_bundle_hash_chain_complete: true
miz_bundle_identity_checked: true
previous_failures_documented: true
```

Bei einem statischen FAIL wird kein 30-Minuten-Lauf gestartet. Korrigiert wird zuerst der kleinste betroffene technische Bereich.

## 12. Builder-Guard

Der zentrale Guard liegt unter:

```text
tools/Test-AirOpsLifecycleGuards.ps1
```

Ein AirOps-Builder muss ihn vor der Bundle-Erzeugung gegen seine Source ausführen. Für G7-ähnliche Foundation-Tests sind mindestens folgende Guardklassen verpflichtend:

- keine positive `squadron.assets`-Sollbestandsprüfung im Konstruktions-/Pre-Start-Pfad;
- Warehouse-Stock-Prüfung vor Start;
- SQUADRON-Asset- und Parking-Vererbungsprüfung nach Start;
- `SetOptionPreferVerticalLanding()` vor `AIRWING:Start()`;
- keine Observer-Zählwertmaskierung;
- keine verbotenen COMMANDER-, AUFTRAG-, OPSTRANSPORT- oder SPAWN-Pfade im Foundation-Gate.

## 13. Akzeptierte Tarinkot-Evidenz vom 4. August 2026

Der G7-Lauf mit Builder-Version `TKOT-G7-AIRWING-FOUNDATION-3` bestätigte für den dokumentierten Stand:

```text
AIRWING Running
3 SQUADRONs
5 registrierte Assetgruppen
7 registrierte Luftfahrzeuge
3 Rollen-Payloads
3 automatische RELOCATECOHORT-Payloads
5 Warehouse-Stockgruppen
2/2/1 SQUADRON-Assets nach Start
0 Missionen
0 Transporte
0 Requests
0 OPSGROUPs
0 deliberate Spawns
1 erkannter Beobachter-Client auf hart ausgeschlossener Clientposition
```

Der Kern-G7-Foundation-Test ist damit bestanden. Der Endmarker meldete wegen einer Test-Harness-Überschreibung fälschlich `activePlayerClients=0`, obwohl der gleiche Lauf zuvor einen Client erkannt hatte. Diese einzelne Ergebnisfeldangabe ist verworfen; maßgeblich sind künftig getrennte Detected-/Allowed-/Blocking-Felder.

G8 bleibt bis zum Abschluss der zentralen Konsolidierung und der statischen Guard-Prüfung blockiert.
