---
document_id: OMW-ARCH-CAMPAIGN-STATE
status: BINDING
document_class: DOMAIN_MODEL
owning_policy: OMW-GOV-001
authoritative_for:
  - CampaignState strategic authority
  - persistent strategic entity identity
  - separation of strategic state from DCS and MOOSE representations
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only resource scope wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: 666ef7a4a6fad52cc1aaecc7d0953e4d112dc8ff
validated_in_dcs: false
---

# 04 – CampaignState

## 1. Autorität

`CampaignState` ist die einzige strategische Wahrheit für Ressourcen, Entitäten, Verluste, Aufträge und persistente Zustände.

DCS-Gruppen, CTLD-Fracht, MOOSE-Warehouses, AIRWING-/SQUADRON-Bestände, Statics und andere Laufzeitobjekte bilden diesen Zustand ab. Sie dürfen ihn nicht unabhängig besitzen oder erhöhen.

Der ursprüngliche Objektentwurf bleibt unverändert erhalten:

- [`Legacy-CampaignState-Grundlage`](evidence/source-records/legacy-04-campaign-state.md)

Übergeordnete Produktionsarchitektur:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## 2. Kernobjekte

Mindestens vorgesehen:

- `AirbaseState`;
- `FOBState`;
- `RedNetworkState` und `RedSiteState`;
- `StrategicEntity`;
- `CargoManifest`;
- `MissionDemand`;
- `CSARIncident`;
- `IntelligenceRecord`;
- `SettlementSupportState`.

Jedes Objekt besitzt eine stabile ID, einen Schema- und Zustandsstatus sowie nachvollziehbare Beziehungen zu Ressourcen und Aufträgen.

## 3. Repräsentationsregel

```text
CampaignState entity
→ optional MOOSE/DCS representation
→ events and observed result
→ validated state transition
→ persisted CampaignState
```

Laufzeitnamen oder MOOSE-Wrapper sind keine persistenten Primärschlüssel.

## 4. Ressourcen

Ressourcen werden nur getrennt geführt, wenn sie spielerische oder strategische Wirkung besitzen. Dazu zählen insbesondere:

- Personal;
- Fahrzeuge und Luftfahrzeuge;
- Munition;
- Treibstoff;
- Baumaterial und Versorgungsgüter;
- Cargo-Manifeste;
- Bereitschaft, Schaden und Verluste.

## 5. Persistenz

Gespeichert werden strategische IDs und Domänendaten, nicht flüchtige Controller-, Wrapper- oder Scheduler-Zustände.

Jeder Speicherstand benötigt:

- Schema-Version;
- Kampagnen- und Missionskennung;
- Migrationspfad;
- Integritätsprüfung;
- reproduzierbare Rekonstruktion der zulässigen Laufzeitobjekte.

## 6. DCS-Runtime-Evidenz: CampaignState -> STORAGE Fuel Mirror

Am 10.08.2026 wurde auf `agent/campaignstate-storage-multinode-sync` der bestehende einseitige Fuel-Mirror-Pfad in einer gemeinsamen Sieben-Knoten-Matrix geprüft:

```text
CampaignState
  -> OMW_CampaignStateStorageSync
  -> OMW_StorageFuelAdapter
  -> MOOSE STORAGE
  -> DCS Airbase Warehouse
```

Getesteter Source-/Builder-Stand:

```text
Commit: e54b6c4eba126979a57efdbc86f485cde03f69e5
BuilderVersion: CAMPAIGNSTATE-STORAGE-MULTINODE-1
Bundle SHA-256: 3de006db91bb2888b5e2dd67662eae39454df9a5d2258d57e5ce9008c9f7ff00
DCS: 2.9.28.26385 MT
MOOSE: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Mission filename: OMW_Template_v8_AirOps_rdy.miz
```

Geprüfte operative STORAGE-Endpunkte:

```text
Bagram
Jalalabad
Kandahar
Kandahar Heliport
FOB Salerno
Tarinkot
Shindand Heliport
```

### 6.1 Lauf mit Spieler-Spawn auf Jalalabad

Mit einem OH-58D-Spieler-Spawn auf Jalalabad ergab der Harness:

```text
nodesExpected=7
nodesPassed=6
nodesFailed=1
status=FAIL
```

Nur Jalalabad schlug beim exakten `SetLiquid()`-Readback/Restore fehl. Vor Testbeginn lag dort der native JETFUEL-Bestand bereits bei `99666.309997559 kg` statt `100000 kg`. Die übrigen sechs Knoten bestanden vollständig.

Artifact-Hashes:

```text
DCS log SHA-256: bc21980d05fc08bf9ba91bc53a65d31807705c0b867e9306c29e34c40646cc5a
Debrief SHA-256: 2f91450a0698ed62a7e690186e40d0b8f0ca2e8659a9f45019e311f06554efd8
```

Dieser Lauf belegt eine wichtige Runtime-Grenze: native DCS-Fuelbuchungen eines aktiven Luftfahrzeugs können denselben Warehouse-Bestand während eines streng synchronen Mirror-Write/Readback-Fensters verändern.

### 6.2 Wiederholung ohne Spieler-Spawn

Der unmittelbar folgende Lauf ohne Spieler-Spawn ergab:

```text
nodesExpected=7
nodesPassed=7
nodesFailed=0
status=PASS
direction=CampaignState-to-STORAGE
campaignStateMutation=false
reverseOverwrite=false
persistence=false
automaticAircraftDebit=false
```

Alle sieben Knoten bestanden CampaignState-Snapshot, initialen Plan mit zwei Änderungen, Write/Readback, zweiten Plan mit `changeCount=0`, Idempotenz, fehlende Rückmutation und Restore.

Artifact-Hashes:

```text
DCS log SHA-256: 9f81fef5d283f1ca6b94b72e55e9b258e6cc8680ae01f016ad92e47aade8071b
Debrief SHA-256: 35c3eba64237b24e4210e210f58d7313169ee9da82b6a388bab5cebf39e87ab0
```

### 6.3 Architekturfolgerung

Die strategische Hoheit bleibt unverändert bei `CampaignState`. Der bestätigte Pfad ist ein einseitiger operativer Mirror und kein zweites Ressourcenbuch:

```text
CampaignState resource stock
!= MOOSE WAREHOUSE / AIRWING asset stock
!= MOOSE STORAGE / DCS warehouse liquids/items
```

Die DCS-Runtime-Evidenz bestätigt den technischen Mirror für alle sieben Knoten unter einem ruhigen Sync-Fenster. Sie genehmigt noch keine automatische Produktionsstrategie für konkurrierenden Verbrauch. Insbesondere bleiben Locking, Retry, Toleranz, Event-Buchung, Transaktionsmodell und Reconciliation gesonderte Architekturentscheidungen.

Der Test darf noch nicht als vollständige `ACCEPTED_TECHNICAL_BASELINE` hochgestuft werden, solange der exakte SHA-256 der tatsächlich ausgeführten `.miz` und der darin eingebettete Bundle-Hash für den 7/7-Lauf nicht nachgewiesen sind. Diese Werte dürfen nicht aus älteren Missionen abgeleitet oder geraten werden.
