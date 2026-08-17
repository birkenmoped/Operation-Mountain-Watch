---
document_id: OMW-AIR-TASKING-PLAN-PHASE2-AIRWING-BRIGADE-VERIFICATION
status: DRAFT
document_class: VERIFICATION_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local Phase 2 source review of AIRWING and BRIGADE for Air Tasking integration
  - branch-local LEGION execution boundary below COMMANDER
  - source-reviewed autonomous mission-generation and resource-side-effect boundaries relevant to OMW
not_authoritative_for:
  - new DCS runtime acceptance
  - final production adapter implementation
  - final SQUADRON or PLATOON capability verification
  - final AUFTRAG mission-type mapping
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/air-tasking-plan-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Air Tasking Plan – Phase 2 AIRWING / BRIGADE Capability Verification

## 1. Zweck

Dieses Dokument prüft `AIRWING` und `BRIGADE` als die beiden für OMW derzeit relevanten `LEGION`-Ausprägungen unterhalb von `COMMANDER`.

Verifikationsbaseline:

```text
MOOSE source line: develop
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

Geprüft wurden:

```text
Moose Development/Moose/Ops/AirWing.lua
Moose Development/Moose/Ops/Brigade.lua
relevante gemeinsame LEGION-/COMMANDER-Verträge
bestehende OMW AIRWING-/SQUADRON-/WAREHOUSE-Lifecycle-Evidenz
offizielle MOOSE_MISSIONS develop Beispiele fuer AIRWING und BRIGADE
```

Diese Prüfung erzeugt keinen neuen DCS-Validierungsstatus.

## 2. Gemeinsame MOOSE-Hierarchie

Beide Klassen erben von `LEGION`:

```text
COMMANDER
   ↓
LEGION
   ├── AIRWING
   │      ↓
   │   SQUADRON
   │      ↓
   │   FLIGHTGROUP
   │
   └── BRIGADE
          ↓
       PLATOON
          ↓
       ARMYGROUP
```

Damit bestätigt der gepinnte Quellstand die in der OMW-Foundation vorgesehene Trennung:

```text
CampaignState / MissionDemand / Air Tasking
= strategische und fachliche Autorität

COMMANDER
= operative Missionszuweisung und Asset-Rekrutierung

AIRWING / BRIGADE
= LEGION-seitige Asset-, Warehouse- und Missionsausführung
```

`AIRWING` und `BRIGADE` sind keine Ersatzinstanzen für `CampaignState`.

## 3. AIRWING – Konstruktion und Verantwortung

Quellgeprüfte Signatur:

```lua
AIRWING:New(warehousename, airwingname)
```

`AIRWING:New(...)` erbt von:

```lua
LEGION:New(warehousename, airwingname)
```

Der Airwing ist damit an einen MOOSE-Warehouse-/Legion-Pfad gebunden.

Der Quellkommentar beschreibt den Airwing als Verband mehrerer `SQUADRON`s mit:

```text
- airframes/assets
- payloads
- warehouse/airbase binding
- AUFTRAG mission queue
```

Für OMW gilt weiterhin:

```text
AIRWING asset/warehouse state
!= CampaignState strategic resource authority
```

## 4. AIRWING:AddSquadron(...)

Quellgeprüfte Signatur:

```lua
AIRWING:AddSquadron(Squadron)
```

Der gepinnte Quellpfad führt mindestens aus:

```text
1. Squadron in self.cohorts eintragen
2. AddAssetToSquadron(Squadron, Squadron.Ngroups)
3. AWACS/TANKER Spezialpayloads gegebenenfalls registrieren
4. RELOCATECOHORT-Payload registrieren
5. Squadron:SetAirwing(self)
6. Squadron gegebenenfalls starten
```

Diese Reihenfolge stimmt mit der bestehenden OMW-Lifecycle-Evidenz überein.

### 4.1 Relevanter DCS-STORAGE-Seiteneffekt

Der gepinnte `AIRWING:AddSquadron(...)`-Quellpfad besitzt zusätzlich einen wichtigen Seiteneffekt:

```text
wenn ein zugeordnetes DCS STORAGE limited aircraft verwendet:
  -> fehlende Aircraft-Menge kann via STORAGE:AddItem(...) ergänzt werden

wenn limited liquids verwendet werden:
  -> fehlender Jetfuel kann via STORAGE:AddLiquid(...) ergänzt werden
```

Das ist für OMW eine Integrationsgrenze.

Es folgt ausdrücklich nicht:

```text
AIRWING stock
= strategisch autoritativer Aircraft-Bestand
```

und auch nicht:

```text
DCS STORAGE mutation by AIRWING
= CampaignState resource decision
```

Für die spätere produktive Air-Tasking-Anbindung muss deshalb der bereits vorhandene CampaignState-/STORAGE-/Warehouse-Vertrag erhalten bleiben. Phase 2 genehmigt keine zweite Ressourcenhoheit.

## 5. AIRWING Mission Queue

Der Airwing besitzt einen eigenen Mission-Queue-Pfad über den geerbten `LEGION`-Mechanismus.

Die offizielle Airwing-Demo zeigt den nativen Pfad:

```text
SQUADRON:New(...)
-> AddMissionCapability(...)
-> AIRWING:New(...)
-> AIRWING:AddSquadron(...)
-> AIRWING:NewPayload(...)
-> AIRWING:Start()
-> AUFTRAG erstellen
-> AIRWING:AddMission(...)
```

Das bestätigt konzeptionell, dass ein `AIRWING` Missionen auch direkt ohne `COMMANDER` erhalten kann.

OMW nutzt für die zentrale Air-Tasking-Architektur jedoch bevorzugt:

```text
Air Tasking adapter
-> COMMANDER
-> AIRWING
```

Direkter `AIRWING:AddMission(...)`-Dispatch bleibt technisch vorhanden und für bestehende Foundation-/Acceptance-Scope bereits praktisch belegt, darf aber nicht parallel eine zweite zentrale OMW-Air-Tasking-Instanz bilden.

## 6. AIRWING FlightOnMission FSM event

`AIRWING:New(...)` registriert:

```text
FlightOnMission
```

Callback-Vertrag:

```lua
AIRWING:OnAfterFlightOnMission(From, Event, To, FlightGroup, Mission)
```

Der offizielle Fighter-Wing-Demo nutzt genau diesen Callback, um die erzeugte `FLIGHTGROUP` und den zugehörigen `AUFTRAG` zu beobachten.

Für OMW ist dies ein geeigneter MOOSE-seitiger Beobachtungspunkt für spätere Runtime-Korrelation, aber noch kein Ersatz für den fachlichen `EXECUTION_ATTEMPT`-Status der Air-Tasking-Domain.

## 7. AIRWING autonome Missionsgeneratoren

Der `AIRWING:onafterStatus(...)`-Pfad ruft im gepinnten Quellstand unter anderem auf:

```text
CheckCAP()
CheckTANKER()
CheckAWACS()
CheckRescuhelo()
CheckRECON()
CheckTransportQueue()
CheckMissionQueue()
```

Die Methoden:

```text
SetNumberCAP(...)
SetNumberTankerBoom(...)
SetNumberTankerProbe(...)
SetNumberAWACS(...)
SetNumberRecon(...)
SetNumberRescuehelo(...)
```

können dazu führen, dass `AIRWING` selbständig fehlende Dauer-/Patrolmissionen als neue `AUFTRAG`-Objekte erzeugt und seiner Mission Queue hinzufügt.

Beispiel aus dem Quellpfad:

```text
CheckTANKER()
-> AUFTRAG:NewTANKER(...)
-> self:AddMission(mission)
```

Für die zentrale OMW-Air-Tasking-Foundation gilt deshalb:

```text
AIRWING autonomous mission generation
must not silently bypass
MissionDemand / AIR_SUPPORT_REQUEST / AIR_TASKING_MISSION
```

Diese Funktionen sind nicht generell verboten. Werden sie später eingesetzt, muss ihr Scope ausdrücklich mit der OMW-Domain vereinbar sein. Für den aktuellen Foundation-Pfad werden sie nicht als zweite strategische Missionsquelle eingeplant.

## 8. AIRWING Payload- und Capability-Auswahl

`AIRWING` verwaltet missionsbezogene Payloads über unter anderem:

```text
NewPayload(...)
FetchPayloadFromStock(...)
GetPayloadCapabilities(...)
CountPayloadsInStock(...)
```

Der gepinnte Quellcode wählt Payloads nach:

```text
mission compatibility
aircraft type
availability
performance
```

Damit liegt ein Teil der physischen Missionsdurchführbarkeit bewusst im MOOSE-Layer.

Für OMW bedeutet das:

```text
Air Tasking mission requirement
-> MOOSE AUFTRAG / COMMANDER
-> AIRWING/SQUADRON capability and payload selection
```

OMW soll diese Auswahl nicht als parallelen eigenen Aircraft-/Payload-Dispatcher nachbauen.

## 9. BRIGADE – Konstruktion und Verantwortung

Quellgeprüfte Signatur:

```lua
BRIGADE:New(WarehouseName, BrigadeName)
```

Auch `BRIGADE` erbt von:

```lua
LEGION:New(WarehouseName, BrigadeName)
```

Der Quellkommentar definiert die Brigade als Warehouse-gebundenen Verband aus einem oder mehreren `PLATOON`s.

Damit ist `BRIGADE` der natürliche MOOSE-LEGION-Layer für bodengebundene OMW-Verbände, soweit ein entsprechender produktiver Ground-Ops-Scope später freigegeben und validiert wird.

## 10. BRIGADE:AddPlatoon(...)

Quellgeprüfte Signatur:

```lua
BRIGADE:AddPlatoon(Platoon)
```

Der Quellpfad:

```text
1. Platoon in self.cohorts eintragen
2. AddAssetToPlatoon(Platoon, Platoon.Ngroups)
3. Platoon:SetBrigade(self)
4. Platoon gegebenenfalls starten
```

Damit entspricht die Struktur funktional dem AIRWING/SQUADRON-Muster:

```text
AIRWING -> SQUADRON
BRIGADE -> PLATOON
```

Die konkrete SQUADRON-/PLATOON-Prüfung bleibt der nächste gesonderte Phase-2-Schritt.

## 11. BRIGADE Mission Queue und ArmyOnMission

`BRIGADE` nutzt ebenfalls den geerbten LEGION-Mission-Queue-Pfad.

Zusätzlich registriert `BRIGADE:New(...)` das FSM-Ereignis:

```text
ArmyOnMission
```

Callback-Vertrag:

```lua
BRIGADE:OnAfterArmyOnMission(From, Event, To, ArmyGroup, Mission)
```

Die offizielle Brigade-Demo zeigt:

```text
PLATOON:New(...)
-> AddMissionCapability(...)
-> BRIGADE:New(...)
-> BRIGADE:AddPlatoon(...)
-> BRIGADE:Start()
-> AUFTRAG:NewPATROLZONE(...)
-> BRIGADE:AddMission(...)
-> OnAfterArmyOnMission(...)
```

Damit sind Konstruktion, direkte Mission Queue und der vorgesehene `ARMYGROUP`-Callback in der offiziellen Demo-Linie bestätigt.

Dies ist keine OMW-DCS-Acceptance für `BRIGADE`.

## 12. BRIGADE autonome Supply-Missionen

Der `BRIGADE:onafterStatus(...)`-Pfad prüft neben Mission- und Transportqueues auch:

```text
rearmingZones
refuellingZones
```

Wenn eine konfigurierte Zone keine aktive Mission besitzt oder die vorige Mission beendet ist, erzeugt BRIGADE selbständig:

```text
AUFTRAG:NewAMMOSUPPLY(...)
AUFTRAG:NewFUELSUPPLY(...)
```

und fügt die Mission über `self:AddMission(...)` hinzu.

Für OMW ist das eine vergleichbare Grenze wie die autonomen AIRWING-Patrolgeneratoren:

```text
MOOSE convenience automation
!= automatically OMW strategic demand authority
```

Solche Features dürfen später nur in einem klar definierten Scope verwendet werden, der CampaignState/MissionDemand nicht umgeht.

## 13. BRIGADE LoadBackAssetInPosition(...)

Der gepinnte Quellstand enthält:

```lua
BRIGADE:LoadBackAssetInPosition(Templatename, Position)
```

Diese Methode rekonstruiert Ground-Assets aus extern gespeicherten OpsGroup-Daten und erzeugt dazu interne Warehouse-/Request-Strukturen.

Für OMW Phase 2 wird daraus ausdrücklich keine Persistenzentscheidung abgeleitet.

OMW besitzt bereits einen eigenen CampaignState-/Persistenzvertrag. Die Methode wird deshalb nur als vorhandene MOOSE-Funktion erfasst und nicht als autoritativer OMW-Restore-Pfad übernommen.

## 14. OMW Authority Boundary

Für die Air-Tasking-Foundation ergibt sich nach CHIEF-, COMMANDER-, AIRWING- und BRIGADE-Prüfung:

```text
CampaignState
    = strategic state/resource authority

MissionDemand / AIR_SUPPORT_REQUEST / AIR_TASKING_MISSION
    = OMW domain planning and authority boundary

COMMANDER
    = MOOSE operational C2, mission assignment and asset recruitment

AIRWING / BRIGADE
    = MOOSE LEGION execution and local asset/warehouse mission capability

SQUADRON / PLATOON
    = MOOSE COHORT capability and asset pools

FLIGHTGROUP / ARMYGROUP
    = physical OPSGROUP execution
```

Nicht vorgesehen ist:

```text
OMW own parallel aircraft selector
OMW own parallel payload selector
OMW own parallel LEGION mission queue
OMW own CHIEF replacement
```

## 15. Externe AAR-Pools bleiben Sonderfall

Die bereits dokumentierten externen OMW-AAR-Pools `MANAS` und `AL_UDEID` sind bewusst keine `AIRWING`-/`SQUADRON`-/WAREHOUSE-Bestände.

Deren bestehender Pfad bleibt:

```text
CampaignState count
-> OMW AAR strategic adapter
-> SPAWN
-> FLIGHTGROUP
-> AUFTRAG
```

Diese Phase-2-Prüfung ändert diesen akzeptierten Scope nicht.

## 16. Verifikationsstatus

Für diesen Branch gilt:

```text
AIRWING
- source reviewed at pinned MOOSE commit
- official develop demo path inspected
- existing OMW runtime evidence remains valid only for its documented provenance
- no new DCS validation claimed

BRIGADE
- source reviewed at pinned MOOSE commit
- official develop demo path inspected
- no new OMW DCS validation claimed
```

Besonders relevante source-reviewed Grenzen:

```text
AIRWING:AddSquadron(...) can affect limited DCS STORAGE aircraft/fuel
AIRWING status loop can autonomously create CAP/TANKER/AWACS/RECON/RESCUEHELO missions
BRIGADE status loop can autonomously create AMMOSUPPLY/FUELSUPPLY missions
both AIRWING and BRIGADE are LEGION execution layers, not CampaignState authority
```

## 17. Ergebnis für Phase 2

Der Manifest-Punkt kann branch-lokal als abgeschlossen markiert werden:

```text
[x] AIRWING-/BRIGADE-relevante APIs prüfen
```

Die Prüfung bestätigt die MOOSE-First-Richtung:

```text
Air Tasking
-> small adapter
-> COMMANDER
-> AIRWING / BRIGADE
```

statt eigener paralleler Asset-/Dispatch-Logik.

Noch nicht abgeschlossen sind insbesondere:

```text
SQUADRON / PLATOON
AUFTRAG construction and mission types
Mission Assignment / lifecycle / FSM callbacks as integrated contract
FLIGHTGROUP / ARMYGROUP lifecycle
full official-example reconciliation
Authority/allocation cases
final OMW-to-MOOSE adapter boundary
Gate 2
```

Kein Runtime-Code wurde geändert. Kein DCS-Test wurde durchgeführt. `validated_in_dcs` bleibt `false`.
