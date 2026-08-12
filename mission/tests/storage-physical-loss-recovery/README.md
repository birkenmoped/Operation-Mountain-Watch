---
document_id: OMW-TEST-STORAGE-PHYSICAL-LOSS-RECOVERY
status: ACCEPTED_TECHNICAL_BASELINE
document_class: TEST_PROJECT_INDEX
owning_policy: OMW-GOV-001
authoritative_for:
  - physical aircraft-loss STORAGE recovery correlation
  - distinction between OPSGROUP despawn loss and real DCS explosion loss
  - AH-64D external-store, aircraft and liquid recovery observation after destruction
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/storage-physical-loss-recovery
source_commit: PENDING_MERGE
validated_in_dcs: true
base_branch: agent/airborne-ammo-parking-correlation
base_commit: 8724c670f2898f5ed14aee676afb365e126ca7a8
merged_to_main: false
acceptance_branch: agent/storage-physical-loss-recovery
acceptance_commit: 5f40fb1e4e97049a6a9c6db57bfa087da7d5df99
acceptance_mission: OMW_Template_v8_AirOps_rdy.miz
acceptance_mission_sha256: 11e4651368be6cbcfd2f9d200621fe62e9a9da93d9776ca4b04269425a896ba4
dcs_version: 2.9.28.26385 MT
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# Physischer Aircraft-Loss und STORAGE-Recovery

## 1. Ziel und Ergebnis

Der frühere kontrollierte Aircraft-Loss-Test verwendete `OPSGROUP:Destroy()`. Der gepinnte MOOSE-Quellstand zeigt, dass dieser Pfad für Flugzeuge ein `UnitLost`-Event erzeugt und die DCS-Unit anschließend mit `unit:destroy()` entfernt. Der dabei beobachtete STORAGE-Recredit ist deshalb kein ausreichender Nachweis für einen physisch zerstörten Totalverlust.

`STORAGE-PHYSICAL-LOSS-RECOVERY-1` isolierte genau diese offene Frage:

```text
AH-64D TwoShip materialisieren
-> bekannten STORAGE-Debit bestätigen
-> reale DCS-Schadensursache über MOOSE UNIT:Explode()
-> 30 s warten
-> Aircraft-, Liquid- und Weapon-STORAGE erneut lesen
-> Recredit klassifizieren
```

Der DCS-Lauf vom 12.08.2026 bestand vollständig. Das Debrief führt zwei AH-64D im Graveyard. Der Harness protokollierte einen `UNIT:Explode(1500)`-Aufruf; die Explosion vernichtete beide eng beieinander stehenden AH-64D, sodass anschließend `unitsAliveAfter=0` und eine verlorene TwoShip-Assetgruppe beobachtet wurden.

## 2. Acceptance-Provenienz

```text
Branch: agent/storage-physical-loss-recovery
Source/Builder commit: 5f40fb1e4e97049a6a9c6db57bfa087da7d5df99
BuilderVersion: STORAGE-PHYSICAL-LOSS-RECOVERY-1
Bundle SHA-256: 3236db339aff985eb493c81d87d72089744d06c123bef56e6e4eb4ffb33a5587
MIZ: OMW_Template_v8_AirOps_rdy.miz
MIZ SHA-256: 11e4651368be6cbcfd2f9d200621fe62e9a9da93d9776ca4b04269425a896ba4
DCS: 2.9.28.26385 MT
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
dcs.log SHA-256: 7e0a835ee2ca3061d22ae9f68ef923f47dda48c0cef50fa86dd876f1bbf9362b
debrief.log SHA-256: 803fa74793e53df44fbe4b55a636a5a354ca3ba4e06f750b20b6c03b51c3c22a
```

Das im MIZ eingebettete Bundle wurde separat auf denselben SHA-256 `3236db339aff985eb493c81d87d72089744d06c123bef56e6e4eb4ffb33a5587` geprüft.

## 3. Runtime-Befund

Bekannter Materialisierungsvertrag:

```text
AH-64D_BLK_II          -2
JETFUEL             -2280 kg
HYDRA_70_M151          -76
AGM_114K                -4
IAFS_ComboPak_100       -2
```

Nach physischer Zerstörung:

```text
AH-64D aircraft recovery: NONE, recovered 0 / debited 2
JETFUEL recovery:         NONE, recovered 0 / debited 2280 kg
M151 recovery:            NONE, recovered 0 / debited 76
AGM-114K recovery:        NONE, recovered 0 / debited 4
IAFS recovery:            NONE, recovered 0 / debited 2
unitsAliveAfter:          0
SQUADRON total assets:    4 -> 3 Assetgruppen
```

Finaler Harness-Marker:

```text
status=PASS
storeRecovery=NONE
aircraftRecovery=NONE
liquidRecovery=NONE
physicalLossMethod=MOOSE_UNIT_EXPLODE
storageMutation=false
campaignStateMutation=false
```

Damit ist für den exakt dokumentierten Stand praktisch belegt: Ein physisch zerstörter AH-64D-TwoShip wird von DCS/STORAGE nicht durch Rückgabe von Aircraft, geladenen Stores oder materialisiertem JETFUEL kompensiert.

## 4. Interpretation des früheren `OPSGROUP:Destroy()`-Tests

Der frühere `OPSGROUP:Destroy()`-Loss bleibt als technischer MOOSE-Asset-Loss-Pfad gültig, aber nicht als Proxy für einen katastrophalen physischen Verlust. Der dort beobachtete Store-Recredit darf nicht auf Crash/Explosion/Graveyard übertragen werden.

```text
OPSGROUP:Destroy()
-> programmgesteuerte Entfernung / UnitLost-Lifecycle
-> nicht gleich physischer Totalverlust

UNIT:Explode()
-> reale DCS-Schadensursache
-> Graveyard / keine lebenden Units
-> in diesem Lauf kein Aircraft-, Fuel- oder Store-Recredit
```

## 5. MOOSE-First-Prüfung

Im tatsächlich verwendeten `Moose.lua` ist `UNIT:Explode(power, delay)` als öffentliche Wrapper-Methode vorhanden. Sie erzeugt über `self:GetCoordinate():Explosion(power)` eine Explosion an der aktuellen Unit-Position. Für den Test wurde daher keine native `trigger.action.explosion`-Parallellogik eingeführt.

Der Harness verwendet:

```text
FLIGHTGROUP:GetGroup()
-> GROUP:GetUnits()
-> UNIT:Explode(1500)
```

Explizit nicht verwendet:

```text
OPSGROUP:Destroy()
FlightGroup:Destroy()
unit:destroy()
trigger.action.explosion
coalition.addGroup
SPAWN
STORAGE mutation
CampaignState mutation
custom ReturnToLegion()
```

## 6. Verbindliche Owner-Entscheidungen nach dem Test

Der Projektinhaber hat am 12.08.2026 für die spätere CampaignState-/AirOps-Integration festgelegt:

```text
PHYSICAL_TOTAL_LOSS
-> Aircraft verloren
-> verbleibender Fuel verloren
-> verbleibende Waffen/Stores verloren
-> keine strategische Gutschrift
```

Für Außen-/Notlandungen gilt dagegen keine automatische Totalverlustregel. Geplante Außenlandungen, insbesondere MOOSE-Transport-/`LANDATCOORDINATE`-Aufträge, dürfen nicht als Notlandung fehlklassifiziert werden.

Vorgesehene Klassifikation:

```text
planned off-field landing / transport landing
-> normal mission landing, no loss handling

unexpected landing at or within 5 km of a recovery-capable friendly airbase/heliport/FARP
-> RECOVERABLE_FORCED_LANDING

unexpected landing outside that recovery envelope
-> OFF_FIELD_UNRECOVERABLE candidate
```

Nur Standorte mit tatsächlicher Aviation-Recovery-Infrastruktur gelten als recovery-capable. Ein gewöhnliches FOB/COP ohne Airfield-/Helipad-/FARP-Strukturen genügt nicht.

Zusätzliche Evidenz für eine echte Notlandung kann insbesondere sehr niedriger Fuel-Stand liefern. `<= 5 %` verbleibender Fuel ist als starkes Signal vorgesehen, aber nicht als alleiniger Trigger. Ejection-/Crew-Verhalten ist bei Helicopter-Modulen nicht einheitlich und darf ebenfalls nicht alleinige Klassifikationsgrundlage sein.

## 7. Recovery- und Repair-Vertrag V1

Für einen als recoverable klassifizierten Forced Landing gilt zunächst eine abstrakte V1-Bergung ohne simulierten Fahrzeugkonvoi:

```text
RECOVERABLE_FORCED_LANDING
-> RECOVERY_IN_PROGRESS
-> 30 Minuten abstrakte Recovery-Zeit
-> bis Recovery-Ende keine Aircraft-/Fuel-/Store-Gutschrift
-> Recovery-Ende: physisches Aircraft wird aus der Welt entfernt / als geborgen behandelt
-> verbleibender Fuel und verbleibende Stores werden sofort strategisch gutgeschrieben
-> Aircraft -> RECOVERED_AWAITING_REPAIR
-> feste Repair-Sperrzeit: 6 Stunden
-> danach Aircraft -> AVAILABLE
```

Es werden keine künstlichen DCS-Schadensstufen, Repair-Prozente oder Health-to-Repair-Konvertierungen eingeführt.

Für einen nicht recoverable Forced Landing ist als spätere Integrationsregel vorgesehen:

```text
OFF_FIELD_UNRECOVERABLE
-> Aircraft, Fuel und Stores strategisch verloren
-> überlebende Crew nach Möglichkeit über vorhandenes MOOSE CSAR/AICSAR abbilden
-> keine doppelte Crew-Erzeugung bei vorhandenem nativen Ejection-Fall
-> Aircraft nach 5 bis 10 Minuten verzögert physisch zerstören
```

Die eigentliche Forced-Landing-Erkennung, CSAR-Kopplung und Recovery-Implementierung ist mit diesem Acceptance-Test noch nicht implementiert oder DCS-validiert.

## 8. Spätere Gameplay-Erweiterung

Eine umkämpfte Recovery-Site mit maximal etwa 30 Minuten Sicherungsauftrag bleibt als spätere Kampagnenerweiterung vorgesehen. RED könnte die Site bedrohen und BLUE beispielsweise mit OH-58/AH-64 sichern. Diese V2-Idee ist ausdrücklich **nicht** Bestandteil der Foundation-V1 und erzeugt derzeit keine Implementierungsfreigabe.

## 9. Build

```text
Source:
mission/tests/storage-physical-loss-recovery/src/01-storage-physical-loss-recovery.lua

Builder:
tools/build-storage-physical-loss-recovery.ps1

Bundle:
mission/tests/storage-physical-loss-recovery/dist/OMW_Storage_Physical_Loss_Recovery_Test.lua

BuilderVersion:
STORAGE-PHYSICAL-LOSS-RECOVERY-1
```
