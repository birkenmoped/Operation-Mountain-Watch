---
document_id: OMW-MOOSE-GROUND-WAREHOUSE-RETURN-HOMEZONE-LIFECYCLE
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE_REFERENCE
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local source-reviewed MOOSE ground return-to-origin lifecycle
  - branch-local design rule for Warehouse spawnzone, ARMYGROUP homezone and ACCESS-zone evaluation
  - required DCS acceptance sequence before production-wide ground-return generalization
not_authoritative_for:
  - repository-wide binding production architecture before merge to main
  - removal of existing ZON_BLUE_GND_*_ACCESS mission-editor zones
  - installation-specific return geometry before DCS validation
  - DCS runtime validation of the newly documented default-homezone path
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fob-attack-support-demand
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# MOOSE Ground Warehouse Return / Homezone Lifecycle

## 1. Zweck

Dieses Dokument hält eine für **alle OMW-Bodenoperationen** relevante MOOSE-first-Erkenntnis fest, die während der Stage-2B-FOB-Attack-Arbeit sichtbar wurde.

Ausgangspunkt war die bisherige OMW-Praxis, für Ground-Materialisierung und Rückkehr gut erreichbare Mission-Editor-Zonen wie

```text
ZON_BLUE_GND_FORTRESS_ACCESS
ZON_BLUE_GND_JOYCE_ACCESS
ZON_BLUE_GND_WRIGHT_ACCESS
...
```

außerhalb oder am gut befahrbaren Rand von FOB-/COP-Strukturen zu verwenden. Der ursprüngliche Zweck dieser Zonen war **nicht**, einen eigenen strategischen Return-Lifecycle zu bauen. Sie sollten verhindern, dass DCS-Ground-AI beim Spawn, bei Abfahrt oder Rückkehr versucht, bis dicht an ein Warehouse innerhalb von HESCOs, Mauern, Zelten, Gebäuden oder anderen Statics zu fahren.

Die neue Source-Prüfung zeigt, dass MOOSE bereits einen vollständigen Return-to-Legion-/Homezone-Lifecycle besitzt. Deshalb muss vor weiterer projektspezifischer Return-Logik zuerst geprüft werden, ob der MOOSE-Standard oder eine reine `WAREHOUSE:SetSpawnZone(...)`-Konfiguration bereits genügt.

## 2. Geprüfte MOOSE-Provenienz

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die folgenden Aussagen stammen aus dem tatsächlich gepinnten `Moose.lua` und sind **SOURCE_REVIEWED**, nicht automatisch DCS-validiert.

## 3. MOOSE-Default für Warehouse- und Spawnzone

Ein normales, nicht schiffsbasiertes MOOSE-`WAREHOUSE` erzeugt beim Konstruktor zwei unterschiedliche Zonen um das zugrunde liegende Warehouse-`STATIC`/`UNIT`:

```text
WAREHOUSE zone:
center = Warehouse object position
radius = 500 m

WAREHOUSE spawnzone:
center = Warehouse object position
radius = 250 m
```

Source-Semantik:

```lua
self.zone = ZONE_RADIUS:New(..., warehouse:GetVec2(), 500)
self.spawnzone = ZONE_RADIUS:New(..., warehouse:GetVec2(), 250)
```

Die 500-m-`zone` und die 250-m-`spawnzone` sind nicht dasselbe. Für den hier betrachteten Ground-Return ist die `spawnzone` entscheidend.

## 4. Öffentliche MOOSE-Konfiguration `WAREHOUSE:SetSpawnZone(...)`

Der gepinnte Source enthält die öffentliche API:

```lua
WAREHOUSE:SetSpawnZone(zone, maxdist)
```

Semantik:

```text
self.spawnzone = zone
self.spawnzonemaxdist = maxdist or 5000
```

Damit kann OMW eine vorhandene, im Mission Editor gesetzte Zone als Warehouse-Spawnzone konfigurieren, ohne den Warehouse-/BRIGADE-/ARMYGROUP-Lifecycle nachzubauen.

Wichtig: `SetSpawnZone(...)` ist **keine reine Return-Zone**. Dieselbe `spawnzone` wird auch für Ground-Materialisierung verwendet. Eine Änderung muss deshalb immer Spawn/Departure **und** Return gemeinsam testen.

## 5. Herkunftsbindung durch LEGION / BRIGADE

Wenn `LEGION` nach Asset-Materialisierung das operative Objekt erzeugt, setzt MOOSE unter anderem:

```text
opsgroup.legion   = origin LEGION / BRIGADE
opsgroup.homezone = self.spawnzone
```

Für Ground-Assets entsteht daraus ein `ARMYGROUP` mit der Herkunfts-Legion und deren aktueller `spawnzone` als `homezone`.

Damit trägt die physische MOOSE-Repräsentation bereits die Herkunftsinformation, die für die normale Rückkehr benötigt wird. OMW soll diese Zuordnung nicht anhand des aktuellen Einsatzortes oder der unterstützten Zielbasis neu berechnen.

## 6. `ReturnToLegion` und Missionsende

Der gepinnte Source bestätigt:

```lua
OPSGROUP:SetReturnToLegion(Switch)
```

mit:

```text
true oder nil -> group returns to its legion
false         -> group stays where its last mission ends
```

Für `AUFTRAG` existiert:

```lua
AUFTRAG:SetReturnToLegion(Switch)
```

mit:

```text
true  -> assigned Ground/Naval assets return
false -> assigned assets do not return
nil   -> let the asset decide
```

Beim `MissionDone`-Pfad übernimmt `OPSGROUP` einen expliziten `Mission.legionReturn`-Wert. Ein projektspezifisches `SetReturnToLegion(false)` ist deshalb eine bewusste Abweichung vom normalen Rückkehrpfad und darf nicht versehentlich als Standard für QRF, Guard oder andere temporäre Ground-Missionen gesetzt werden.

## 7. `ARMYGROUP:RTZ(...)` und `self.homezone`

Der Source des `ARMYGROUP` verwendet für RTZ:

```text
explicit Zone
OR
self.homezone
```

also:

```lua
local zone = Zone or self.homezone
```

Für ein mobiles `ARMYGROUP` gilt:

```text
if already inside return zone
-> Returned()

else
-> Coordinate = zone:GetRandomCoordinate()
-> AddWaypoint(Coordinate, ...)
-> physical movement toward the zone
```

Damit verlangt MOOSE nicht, dass eine Ground-Gruppe exakt bis zum Warehouse-Objekt fährt. Bei unveränderter Default-Konfiguration genügt grundsätzlich die 250-m-`spawnzone` um das Warehouse.

### Wichtige Ground-AI-Einschränkung

Wenn sich innerhalb dieses 250-m-Kreises HESCOs, Mauern, Gebäude oder andere statische Hindernisse befinden, kann `GetRandomCoordinate()` dennoch einen für DCS-Ground-AI ungünstigen Punkt wählen. Die Default-Zone ist daher **nicht automatisch ausreichend**, nur weil ihr Radius 250 m beträgt.

### Immobile Gruppen

Der Source enthält für nicht mobile `ARMYGROUP`s außerhalb der Return-Zone einen Teleportpfad. Dieser bleibt nach OMW-Governance für beobachtbare Bereiche ausgeschlossen. Die hier geplanten Rückkehrtests gelten für mobile Ground-Gruppen.

## 8. `Returned` und Warehouse-Rückgabe

Der Source bestätigt für `ARMYGROUP:onafterReturned(...)`:

```lua
if self.legion then
  self.legion:__AddAsset(10, self.group, 1)
end
```

Der physische MOOSE-Lifecycle ist damit grundsätzlich:

```text
origin BRIGADE / LEGION
-> ARMYGROUP mission
-> mission end
-> return-to-legion decision
-> RTZ to explicit zone or self.homezone
-> Returned
-> origin legion __AddAsset(...)
-> Warehouse asset back in stock / physical cleanup
```

Die Herkunfts-Legion ist dabei maßgeblich. Eine Einheit, die von Wright nach Fortress eingesetzt wird, darf nach Missionsende nicht aufgrund ihres Zielortes dem Fortress-Warehouse gutgeschrieben werden.

## 9. OMW-Designentscheidung: Return-to-origin, nicht Return-to-target

Der Projektinhaber hat klargestellt:

```text
Jede Ground-Einheit kehrt zu ihrer Herkunftsbasis zurück.
```

Für eine temporär eingesetzte Ground-Gruppe gilt deshalb allgemein:

```text
origin CampaignState node
-> origin Warehouse / BRIGADE / PLATOON
-> ARMYGROUP
-> mission at any destination
-> normal MOOSE return-to-origin lifecycle
-> origin homezone / configured origin spawnzone
-> Returned
-> original Legion / Warehouse
-> CampaignState settlement against the original strategic deployment
```

Verbotene Verallgemeinerung:

```text
"Fortress was attacked"
-> therefore return every supporting group to Fortress ACCESS
-> therefore credit Fortress Warehouse
```

Eine solche Logik würde Herkunft, MOOSE-Legion und CampaignState-Ressourcenhoheit vermischen.

## 10. Bedeutung der vorhandenen `ZON_BLUE_GND_*_ACCESS`

Die vorhandenen ACCESS-Zonen werden **nicht** als Security-Perimeter definiert.

Ihr bisheriger OMW-Zweck bleibt:

```text
safe materialization / departure / arrival / return handoff geometry
```

Sie liegen typischerweise an gut erreichbaren Punkten außerhalb beziehungsweise am befahrbaren Rand der FOB-/COP-Strukturen, um Ground-AI nicht in statische Hindernisse zu zwingen.

Neue Entscheidung vor dem nächsten Test:

```text
ACCESS zones are retained.
They are NOT yet declared mandatory for every return.
They are NOT removed before DCS comparison against the native MOOSE homezone path.
```

## 11. MOOSE-first Prioritätsfolge für Ground-Return

Für zukünftige OMW-Bodenoperationen gilt auf diesem Branch folgende Prüf- und Implementierungsreihenfolge:

### Stufe 1 – nativer MOOSE-Default

```text
WAREHOUSE default spawnzone
= 250 m around Warehouse object

LEGION creates ARMYGROUP
-> homezone = spawnzone

mission completes
-> normal ReturnToLegion
-> RTZ(self.homezone)
-> Returned
-> origin Warehouse
```

Wenn dieser Pfad an einem Standort geometrisch und visuell sauber funktioniert, wird **kein zusätzlicher OMW-Return-Controller** eingeführt.

### Stufe 2 – öffentliche MOOSE-Konfiguration mit ACCESS

Wenn die 250-m-Defaultzone wegen FOB-/COP-Geometrie unzuverlässig ist:

```text
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_<ORIGIN>_ACCESS, maxdist)
```

Dann wird die vorhandene ACCESS-Geometrie zur MOOSE-eigenen `spawnzone` und damit automatisch zur `homezone` materialisierter Ground-Gruppen.

Der normale Return bleibt trotzdem:

```text
MissionDone
-> MOOSE ReturnToLegion
-> MOOSE RTZ(self.homezone)
-> Returned
-> origin Warehouse
```

Es wird nicht zusätzlich ein paralleler OMW-Despawn-/Return-Scheduler gebaut.

### Stufe 3 – explizites `ARMYGROUP:RTZ(zone, ...)` nur bei belegtem Bedarf

Ein explizites RTZ zu einer Zone bleibt als MOOSE-Funktion verfügbar und ist in früheren OMW-Acceptances bereits praktisch bestätigt. Es ist aber **nicht automatisch die Produktionsbaseline für jede Ground-Mission**.

Wenn es verwendet wird, muss die Zone zur **Herkunft** der Gruppe gehören, sofern keine bewusst andere MOOSE-Legion-/Relocation-Semantik vorgesehen und geprüft ist.

### Stufe 4 – eigener Fallback nur nach nachgewiesener MOOSE-Lücke

Erst wenn Default-Homezone, `SetSpawnZone(...)` und normaler ReturnToLegion-Lifecycle die Anforderung nachweislich nicht erfüllen, darf gemäß MOOSE-first-Policy eine zusätzliche OMW-Lösung entworfen und dem Projektinhaber zur Freigabe vorgelegt werden.

## 12. Bestehender akzeptierter Präzedenzfall

`mission/tests/ground-resupply-execution/ACCEPTANCE-5.md` hat für den dokumentierten Stage-1D-S-Scope real bestätigt:

```text
SUPPLY convoy
-> SetReturnToLegion(false)
-> mission cancel / MissionDone
-> delayed explicit ARMYGROUP:RTZ(Joyce ACCESS, OnRoad)
-> Returned
-> Warehouse AddAsset
-> physical cleanup
```

Dieser PASS beweist:

```text
explicit mobile ARMYGROUP RTZ to an ACCESS zone works in the tested scope
Returned -> Warehouse AddAsset works in the tested scope
```

Er beweist **nicht**:

```text
that every OMW Ground mission must use explicit RTZ
that every OMW Ground mission must use an ACCESS zone
that the native 250 m Warehouse homezone is unsuitable
```

Stage 1D-S bleibt eine gültige technische Referenz; die neue Source-Erkenntnis erweitert die Produktionsprüfung um den einfacheren nativen MOOSE-Pfad.

## 13. CampaignState-Grenze

CampaignState übernimmt nicht die physische Rückkehrsteuerung.

CampaignState-Aufgaben:

```text
select strategic origin pool
reserve deployment/resource exactly once
store stable deployment/resource/origin identity
keep resource unavailable while physically deployed
accept confirmed MOOSE lifecycle settlement idempotently
settle survivors / losses exactly once
reevaluate reorder/resupply after settlement
```

MOOSE-Aufgaben:

```text
physical materialization
mission execution
mission completion
return-to-origin movement
Returned lifecycle
Legion/Warehouse physical asset recovery
```

Ein `MissionDone`, `AUFTRAG:Cancel`, `ReturnToLegion`-Befehl oder `RTZ`-Befehl allein ist noch keine strategische Rückkehr. CampaignState darf die Ressource erst nach dem passenden bestätigten physischen Lifecycle-Ereignis beziehungsweise bestätigten Verlust abrechnen.

## 14. Verbindlicher Testplan vor Produktionsverallgemeinerung

Die folgenden Schritte sind vor einer projektweiten Festlegung der Ground-Return-Geometrie zu prüfen.

### Test A – nativer MOOSE-Homezone-Return

Ziel: beweisen, ob die Warehouse-zentrierte 250-m-Default-`spawnzone/homezone` an einem realen OMW-Standort ausreichend ist.

Testbedingungen:

```text
mobile Ground asset
origin Warehouse / BRIGADE known
no WAREHOUSE:SetSpawnZone override for the test Warehouse
no AUFTRAG:SetReturnToLegion(false)
no explicit ARMYGROUP:RTZ(customZone, ...)
mission completes through normal MOOSE lifecycle
```

Zu beobachten:

```text
real materialization
mission execution
MissionDone / normal completion
MOOSE begins return to self.homezone
physical route toward origin
no visible teleport
no drive-through of HESCOs/statics/buildings
Returned
origin Legion / Warehouse AddAsset
physical cleanup at a plausible handoff location
```

### Test B – ACCESS als öffentliche MOOSE-Spawn-/Homezone

Nur erforderlich, wenn Test A an der Standortgeometrie scheitert oder sichtbar ungeeignet ist.

Testbedingungen:

```text
WAREHOUSE:SetSpawnZone(ZON_BLUE_GND_<ORIGIN>_ACCESS, validated maxdist)
normal ReturnToLegion enabled
no explicit custom RTZ return controller
```

Zu beobachten:

```text
spawn/materialization occurs acceptably in ACCESS geometry
outbound departure remains valid
mission executes normally
return automatically targets the configured homezone
Returned / origin Warehouse AddAsset
no collision / no visible teleport / no wrong-base credit
```

### Test C – Cross-site origin provenance

Vor produktiver Generalisierung über mehrere Installationen muss mindestens ein Fall beweisen:

```text
asset originates at site A
mission target/support site is B
mission completes at/near B
asset returns to A
Returned credits the original A Legion/Warehouse
CampaignState settles against the original A deployment/node
```

Der Zielstandort B darf nicht allein aufgrund des Einsatzortes zum Rückkehr-Warehouse werden.

### Test D – CampaignState settlement

Für denselben physischen Ground-Lifecycle:

```text
reserve exactly once before deployment
no permanent consumption merely because the group materialized
Returned survivors released/credited exactly once
confirmed casualties consumed exactly once
duplicate callback/event delivery is idempotent
reorder/resupply evaluated only after settlement
```

### Test E – Regression bestehender Sonderpfade

Bereits akzeptierte Missionen mit bewusstem

```lua
SetReturnToLegion(false)
```

und späterem explizitem RTZ bleiben getrennte Sonderfälle. Sie dürfen nicht automatisch auf den neuen Default-Pfad umgestellt werden, ohne ihre eigene Acceptance zu wiederholen.

## 15. Entscheidungsmatrix nach Test

```text
A PASS, geometry acceptable
-> prefer native MOOSE default homezone
-> ACCESS remains available for other materialization/pathfinding purposes
-> no custom return logic

A FAIL because Warehouse-centered 250 m geometry is unsafe
B PASS
-> configure origin Warehouse spawnzone to site ACCESS zone
-> native MOOSE return lifecycle remains authoritative
-> no custom return logic

A FAIL and B FAIL
-> document exact MOOSE limitation
-> inspect smallest additional MOOSE-compatible adapter
-> obtain explicit owner approval before implementation
```

## 16. Konsequenz für Stage 2B Fortress

Der derzeitige Stage-2B-Acceptance-Harness enthält noch eine **testlokale explizite Fortress-Konfiguration**:

```text
BRIGADE:SetSpawnZone(ZON_BLUE_GND_FORTRESS_ACCESS, ...)
AUFTRAG:SetReturnToLegion(false)
explicit ARMYGROUP:RTZ(ZON_BLUE_GND_FORTRESS_ACCESS, ...)
```

Diese Kombination darf nach der neuen Source-/Design-Erkenntnis **nicht ungeprüft zur allgemeinen Ground-Produktionsarchitektur erklärt werden**.

Vor dem nächsten DCS-Lauf ist zu entscheiden, welcher Testzweck verfolgt wird:

```text
1. Stage 2B functional response acceptance using the already explicit ACCESS path
or
2. isolated/native return-homezone comparison before Stage 2B production generalization
```

Für die produktive Ground-Architektur hat der MOOSE-Default beziehungsweise die reine `SetSpawnZone(...)`-Konfiguration Priorität. Fortress bleibt nur der erste konkrete Teststandort, nicht die Definition des allgemeinen Rückkehrvertrags.

## 17. DCS-only offene Punkte

Source-Review kann folgende Fragen nicht beantworten:

```text
Is the default 250 m Warehouse-centered zone physically reachable at each OMW site?
Where does GetRandomCoordinate() place the actual return waypoint in the real mission geometry?
Will DCS Ground AI attempt to cross HESCO/static/building obstacles?
Is the eventual despawn/cleanup visually acceptable to nearby players?
Does an ACCESS-zone SetSpawnZone override preserve all accepted road-aligned materialization behavior at that site?
```

Diese Punkte bleiben bis zum dokumentierten DCS-Lauf `PENDING_DCS`.
