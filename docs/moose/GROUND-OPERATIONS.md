---
document_id: OMW-MOOSE-GROUND-OPERATIONS
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE ground-operations evaluation scope
  - source-reviewed behavior of ARMYGROUP, BRIGADE, PLATOON, COHORT, OPSGROUP and OPSTRANSPORT for the ARMY ground foundation
  - required tests for ground asset selection, movement, return and transport
not_authoritative_for:
  - accepted ground runtime architecture
  - final BRIGADE topology
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - unclassified MOOSE ground-operations reference
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE-Bodenoperationen in Operation Mountain Watch

## 1. Status

```text
PLANNED – Source-Review erweitert; vollständige Bodenoperationsarchitektur noch nicht technisch akzeptiert
```

Der vollständige frühere Prüf- und Klassenentwurf bleibt erhalten:

- [`Legacy-MOOSE-Ground-Operations`](../evidence/source-records/legacy-moose-ground-operations.md)

Diese Datei dokumentiert nur den für die aktuelle ARMY Ground Foundation geprüften MOOSE-Stand. Source-Review ist kein DCS-Runtime-Nachweis.

## 2. Geprüfte MOOSE-Provenienz

Für diesen Review ist die vom Projektinhaber am 18.08.2026 bereitgestellte aktuelle Mission maßgeblich:

```text
Mission artifact: OMW_Template_v12_groundworks(1).miz
Mission SHA-256: 3c634370d43d57ed4788c55d991c903441cdfa57709581af61debb4105f9a078
Embedded file: l10n/DEFAULT/Moose.lua
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
MOOSE build marker: 2026-06-14T16:11:05+02:00-73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

Der eingebettete Hash stimmt mit dem bereits im Projekt gepinnten MOOSE-2.9.18-Artefakt überein. Die `.miz` wurde ausschließlich gelesen; sie wurde durch ChatGPT nicht verändert.

## 3. Aktuelle Ground-OPS-Kandidatenhierarchie

```text
COMMANDER
    |
    +-- BRIGADE / operational Ground Node
            |
            +-- PLATOON / role and asset pool
                    |
                    +-- ARMYGROUP
                            |
                            +-- physical DCS GROUP
```

Diese Hierarchie bleibt ein technisches Kandidatenmodell. Eine MOOSE-`BRIGADE` ist keine automatische Abbildung einer historischen Brigade, und die vier OMW-Ground-Nodes Jalalabad, Joyce, Wright und Bostick sind noch nicht verbindlich als exakt vier `BRIGADE`-Instanzen festgelegt.

`CampaignState` bleibt die strategische Ressourcenautorität. `BRIGADE`/WAREHOUSE, `PLATOON` und `ARMYGROUP` dürfen nur die operative Materialisierung und MOOSE-interne Assetverwaltung übernehmen; daraus darf keine zweite strategische Personal-, Fahrzeug-, Ammo-, Fuel- oder Supply-Wahrheit entstehen.

## 4. Source-verifizierte Klassen und Verträge

### 4.1 `COMMANDER`

Der gepinnte MOOSE-Stand enthält den öffentlichen Pfad:

```lua
COMMANDER:AddBrigade(Brigade)
COMMANDER:AddMission(Mission)
COMMANDER:AddOpsTransport(Transport)
```

`AddBrigade` delegiert auf `AddLegion` und bindet die `BRIGADE` an den `COMMANDER`. Damit kann dieselbe COMMANDER-Ebene grundsätzlich AIRWINGs und BRIGADEs verwalten. Für OMW bleibt `MissionDemand` die fachliche Tasking-Autorität; `COMMANDER` ist Ausführungs-/Selektionsschicht, keine strategische Entscheidungsinstanz.

### 4.2 `BRIGADE`

Source-verifiziert:

```lua
BRIGADE:New(WarehouseName, BrigadeName)
BRIGADE:AddPlatoon(Platoon)
BRIGADE:AddAssetToPlatoon(Platoon, Nassets)
BRIGADE:AddRetreatZone(RetreatZone)
BRIGADE:AddRearmingZone(RearmingZone)
BRIGADE:AddRefuellingZone(RefuellingZone)
BRIGADE:LoadBackAssetInPosition(Templatename, Position)
```

`AddPlatoon` fügt den `PLATOON` als Cohort der Brigade hinzu, registriert dessen Assetgruppen im LEGION-/WAREHOUSE-Pool, setzt die Brigade am Platoon und startet den Platoon-FSM bei Bedarf.

`LoadBackAssetInPosition(...)` ist für OMW ein **expliziter Risikopfad**: die Funktion ist als Persistenz-/Mission-Restart-Helfer dokumentiert und materialisiert eine gespeicherte Ground-Gruppe über `SPAWN:NewWithAlias(...):SpawnFromCoordinate(Position)`. Sie darf daher nicht als transparente Reconstitution eines beobachtbaren Feldverbandes verwendet werden. Ein späterer Einsatz wäre nur an einem kontrollierten, für Spieler nicht beobachtbaren Materialisierungspunkt zulässig und müsste separat akzeptiert werden.

### 4.3 `PLATOON` und `COHORT`

`PLATOON` erbt im gepinnten Stand von `COHORT`:

```lua
PLATOON:New(TemplateGroupName, Ngroups, PlatoonName)
COHORT:AddMissionCapability(MissionTypes, Performance)
COHORT:SetMissionRange(Range)
COHORT:CanMission(Mission)
```

Der Konstruktor setzt Ground-Kategorie und fügt `AUFTRAG.Type.NOTHING` als Grundfähigkeit hinzu. Die eigentliche rollenbezogene Selektion stammt weitgehend aus `COHORT`.

Für Ground-Templates setzt `COHORT:New(...)` standardmäßig:

```text
mission range = 75 NM
```

`CanMission(...)` prüft source-verifiziert mindestens:

1. Cohort ist `OnDuty`;
2. Missionsart ist in den Mission Capabilities enthalten;
3. Zielentfernung liegt innerhalb der Engage Range.

Eine auf der Mission gesetzte `Mission.engageRange` kann die Cohort-Range erweitern, weil der Source-Pfad `math.max(self.engageRange, Mission.engageRange)` verwendet. Deshalb darf eine OMW-Rollenbegrenzung nicht ausschließlich auf `PLATOON:SetMissionRange(...)` vertrauen, wenn Missionen selbst eine größere Engage Range erhalten.

Folgerung für den späteren OMW-Vertrag:

```text
PLATOON role
= mission capability filter
+ bounded mission range
+ MissionDemand target/domain constraints
```

Die konkrete Rollenmatrix pro Node bleibt offen und benötigt anschließend DCS-Selektionsnachweise.

### 4.4 `ARMYGROUP` und Return-/Persistent-Field-Lifecycle

`ARMYGROUP` ist die operative physische Ground-Gruppe. Source-verifiziert sind unter anderem Routing-/Waypoint-, Mission-, Rearm-, Retreat-, RTZ- und Returned-FSM-Pfade.

Besonders relevant ist `RTZ`:

```text
mobile ARMYGROUP outside return zone
-> waypoint to random coordinate in return zone
-> physical route

non-mobile ARMYGROUP outside return zone
-> Teleport(zone:GetCoordinate(), 0, true)
-> RTZ retrigger
```

Der zweite Pfad widerspricht der OMW-Regel gegen beobachtbare Teleports. Für die produktive ARMY Ground Foundation gilt daher:

```text
DO NOT USE automatic RTZ for immobile field assets outside their return zone.
```

Für mobile Gruppen ist der Source-Pfad grundsätzlich physisch geroutet. Wegen DCS-Ground-Pathfinding ist er trotzdem erst nach einem Test mit den konkreten OMW-Road- und Withdrawal-Ankern zulässig.

Der vollständige normale Return-Pfad ist source-seitig eindeutig:

```text
ARMYGROUP:onafterReturned(...)
-> self.legion:__AddAsset(10, self.group, 1)
-> WAREHOUSE:onafterAddAsset(...)
-> returned asset marked spawned=false/requested=false
-> current physical group is removed
```

`WAREHOUSE:onafterAddAsset(...)` dokumentiert ausdrücklich, dass eine noch lebende Gruppe beim Hinzufügen zum Warehouse-Stock zerstört wird. Für eine bekannte OPSGROUP ruft der Source `opsgroup:Despawn(0, true)` und anschließend `opsgroup:__Stop(-0.01)` auf; andernfalls folgt `group:Destroy()`.

Damit ist für OMW nicht mehr nur ein abstraktes Despawn-Risiko bekannt: **`Returned` führt im normalen LEGION/WAREHOUSE-Rückgabepfad nach der verzögerten AddAsset-Verarbeitung zur Entfernung der physischen Gruppe.** Der Return-Punkt ist deshalb eine harte Visual-Boundary-Frage.

Zusätzlich ist jetzt ein vorhandener MOOSE-Pfad für **physisch im Feld verbleibende** Ground-Assets source-verifiziert:

```lua
AUFTRAG:SetReturnToLegion(false)
```

Die öffentliche Methode setzt `mission.legionReturn=false`. Beim Ende der Mission übernimmt `OPSGROUP:onafterMissionDone(...)` diesen Wert über `self:SetReturnToLegion(Mission.legionReturn)`. Wenn die Gruppe einer Legion angehört, nicht zur Legion zurückkehren soll und nach dem Mission-Cleanup nur noch ein Wegpunkt vorhanden ist, erzeugt MOOSE einen neuen Wegpunkt an der **aktuellen Position**, entfernt den alten Wegpunkt und lässt die Ground-/Naval-Group dort halten. Der Source-Kommentar beschreibt den Fall ausdrücklich als Gruppe, die nach Missionsende **nicht** zurückkehrt, sondern dort bleibt, wo ihre letzte Mission endet.

Für OMW ist damit ein eigener Parallel-Lifecycle für diesen Grundfall **nicht erforderlich**. Der Kandidatenvertrag lautet:

```text
mission needs physical field persistence
-> AUFTRAG:SetReturnToLegion(false)
-> mission completes
-> ARMYGROUP remains physical at current position
-> no Returned -> Warehouse AddAsset path at mission end
```

Grenzen:

- Source-Review beweist noch kein DCS-Verhalten mit den konkreten OMW-Gruppen und Missionstypen.
- Der Mechanismus löst nicht automatisch Reconstitution nach Missionsneustart, Verlustersatz oder späteren gezielten Rückzug.
- Ein späterer Auftrag kann weiterhin einen Return auslösen, wenn dessen Lifecycle entsprechend konfiguriert ist.
- Für mobile Rückverlegung in den Bestand bleibt der physische Weg bis zu einer nicht beobachtbaren Return Zone plus anschließender Warehouse-Rückgabe der bevorzugte MOOSE-first-Kandidat.
- Für dauerhaft stationäre OP-/FOB-Defense-Gruppen ist `SetReturnToLegion(false)` jetzt der primäre MOOSE-first-Testkandidat vor jeder Eigenentwicklung.

Produktive Konsequenz:

```text
FIELD_PERSISTENCE
-> test AUFTRAG:SetReturnToLegion(false) first

RETURNED_TO_WAREHOUSE
-> route mobile group physically to a player-non-observable return boundary
-> then allow Returned -> Warehouse AddAsset

IMMOBILE_RETURN
-> automatic RTZ path remains excluded outside the return zone
```

### 4.5 `OPSTRANSPORT` und `OPSGROUP` Cargo

Source-verifiziert:

```lua
OPSTRANSPORT:New(CargoGroups, PickupZone, DeployZone)
OPSTRANSPORT:SetEmbarkZone(...)
OPSTRANSPORT:SetDisembarkZone(...)
OPSTRANSPORT:SetDisembarkActivation(...)
OPSTRANSPORT:SetDisembarkCarriers(...)
OPSTRANSPORT:SetDisembarkInUtero(...)
OPSTRANSPORT:AddPathTransport(PathGroup, Reversed, Radius, TransportZoneCombo)
OPSTRANSPORT:SetRequiredCarriers(...)
OPSTRANSPORT:SetTime(...)
OPSTRANSPORT:SetPriority(...)
```

`AddPathTransport` liest die Mission-Editor-Wegpunkte einer angegebenen Gruppe und filtert den Pfad über deren Group Category. Damit ist die Funktion für OMW prinzipiell interessant, weil vorab validierte Ground-Routen als explizite Transportpfade vorgegeben werden können, statt beliebiges dynamisches Pathfinding zu verlangen.

Der Cargo-Lifecycle ist nicht rein abstrakt. Der gepinnte Source zeigt beim Unload konkret:

```text
OPSGROUP:onafterUnload(...)
-> cargo status becomes NOTCARGO
-> template is copied
-> unit coordinates are rewritten around the unload coordinate
-> OpsGroup:_Respawn(0, Template)
```

`SetDisembarkActivation(false)` kann die Gruppe dabei als late activated anlegen. `SetDisembarkInUtero(...)` und `SetDisembarkCarriers(...)` bieten weitere Transferpfade, ändern aber nichts daran, dass der normale coordinate-based Unload eine physische Re-Materialisierung über `_Respawn(...)` enthält.

Das ist nicht automatisch ein sichtbarer Teleport: während des Transports ist die Gruppe Cargo, und ein Entladen am Carrier kann visuell plausibel sein. Für OMW muss aber in DCS verifiziert werden, **wo**, **wann** und **wie** die Gruppe beim Embark/Load und Unload/Disembark verschwindet beziehungsweise erscheint. Insbesondere für OP-Reinforcement in Sichtweite von Spielern ist der Source allein kein Acceptance-Nachweis.

`OPSTRANSPORT` ist deshalb weiterhin `PLANNED`, nicht `VALIDATED`.

## 5. Offizielle MOOSE-Demos und Tests

Die offiziellen Repositories `FlightControl-Master/MOOSE_MISSIONS` und `FlightControl-Master/MOOSE_MISSIONS_UNPACKED` wurden für die aktuellen Ground-OPS-Klassennamen durchsucht.

Ergebnis des aktuellen Reviews:

```text
BRIGADE        no direct class-use hit found
ARMYGROUP      no direct class-use hit found
OPSTRANSPORT   no direct class-use hit found
PLATOON        keyword hits exist, but reviewed Warehouse example uses WAREHOUSE assets directly
```

Als relevante Ground-Transport-Referenz wurde `WHS-020 - Self Propelled Ground Troops` geprüft. Das Beispiel zeigt Ground-Asset-Transfers zwischen zwei MOOSE-WAREHOUSE-Instanzen, verwendet jedoch nicht die aktuelle `COMMANDER -> BRIGADE -> PLATOON -> ARMYGROUP`-Hierarchie und ist deshalb kein Acceptance-Beweis für die OMW-Ground-OPS-Architektur.

Das Fehlen eines gefundenen direkten Beispiels ist **kein** Beweis, dass es in sämtlichen historischen Demo-Ständen keines gibt. Für den gepinnten OMW-Stand bleibt der tatsächlich eingebettete Source maßgeblich; die projektspezifische Kombination benötigt einen eigenen reproduzierbaren DCS-Test.

## 6. OMW-Ausschlüsse aus dem Source-Review

Bis zur expliziten Acceptance sind mindestens folgende Pfade ausgeschlossen:

```text
1. BRIGADE:LoadBackAssetInPosition(...) in player-observable areas
2. ARMYGROUP RTZ for immobile groups when outside the return zone
3. automatic reconstitution by arbitrary SpawnFromCoordinate positions
4. ARMYGROUP Returned -> WAREHOUSE AddAsset at a player-observable return boundary
5. OPSTRANSPORT coordinate unload/materialization in visible areas without DCS verification
6. arbitrary Ground-AI routes without validated road/assembly/withdrawal anchors
```

`AUFTRAG:SetReturnToLegion(false)` ist **nicht** in dieser Ausschlussliste: der gepinnte Source enthält genau diesen öffentlichen Ground-/Naval-Persistenzpfad. Er bleibt jedoch bis zum OMW-DCS-Test `SOURCE_REVIEWED`, nicht `VALIDATED`.

Diese Ausschlüsse sind keine Nicht-MOOSE-Ausnahme. Sie begrenzen lediglich MOOSE-Funktionen, deren konkreter Source-Pfad mit OMW-Governance kollidieren kann.

## 7. Aktueller Architekturstand

Nach dem Source-Review ist folgende Aussage belastbar:

```text
COMMANDER
-> can own multiple BRIGADE legions

BRIGADE
-> owns operational PLATOON/asset pools

PLATOON/COHORT
-> can restrict mission type and mission range

AUFTRAG
-> SetReturnToLegion(false) can keep army/navy mission assets in the field after mission completion

ARMYGROUP
-> executes physical ground movement and mission FSM
-> can remain at its current position after mission completion when legionReturn=false
-> Returned normally hands the group back to LEGION/WAREHOUSE
-> Warehouse AddAsset removes the physical returned group

OPSTRANSPORT
-> can coordinate cargo/carrier transport and predefined transport paths
-> normal coordinate unload re-materializes cargo through OPSGROUP:_Respawn
```

Noch **nicht** belastbar entschieden ist:

```text
- exactly four OMW Ground Nodes = exactly four MOOSE BRIGADEs
- exact PLATOON role matrix and group strengths
- restart/reconstitution contract for persistent field groups
- exact hidden return/despawn boundaries
- production OPSTRANSPORT workflow for OP reinforcement/resupply
```

Diese Punkte hängen teilweise von Owner-Entscheidungen und teilweise von DCS-Laufzeitverhalten ab.

## 8. Nächste Acceptance-Schritte

Vor produktiver Runtime-Implementierung sind mindestens erforderlich:

1. einen minimalen BRIGADE/PLATOON-Selektionsversuch mit zwei unterschiedlich begrenzten Rollen bauen;
2. Mission Capability und Range einschließlich eines AUFTRAG mit eigener `engageRange` prüfen;
3. eine Ground-Mission mit `AUFTRAG:SetReturnToLegion(false)` beenden und verifizieren, dass die ARMYGROUP physisch an der aktuellen Position bestehen bleibt;
4. anschließend derselben Feldgruppe einen Folgeauftrag geben und prüfen, dass keine unbeabsichtigte Re-Materialisierung oder Warehouse-Dublette entsteht;
5. mobile ARMYGROUP-Rückkehr auf einer validierten Route bis zu einer **nicht beobachtbaren** Return Zone prüfen und dort `Returned -> __AddAsset -> WAREHOUSE:onafterAddAsset` beobachten;
6. immobile RTZ bewusst **nicht** verwenden;
7. OPSTRANSPORT mit einem Ground-Carrier und vorgegebenem `AddPathTransport`-Pfad prüfen;
8. Embark/Load/Unload/Disembark einschließlich `_Respawn(...)` auf sichtbare Sprünge, Aktivierungszustand und Multiplayer-Synchronität beobachten;
9. Restart/Reconstitution für im Feld verbleibende Gruppen separat definieren und testen;
10. erst danach die konkrete Node-/PLATOON-Topologie festlegen und Runtime-Code produzieren.

## 9. Architekturgrenze

CampaignState entscheidet über strategischen Bestand, verfügbare Ressourcen, Auftragsfreigabe und strategische Folgen. MOOSE führt die operative Auswahl, physische Gruppen und deren FSM aus.

Eigene Watchguard-, Routing-, Scheduler-, Transport- oder Reconstitution-Logik darf erst nach dokumentierter MOOSE-Lücke und ausdrücklicher Projektinhaberfreigabe produktiv werden.
