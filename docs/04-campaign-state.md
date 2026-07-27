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
source_commit:
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
