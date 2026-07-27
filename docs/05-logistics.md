---
document_id: OMW-LOGISTICS
status: BINDING
document_class: LOGISTICS_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - common logistics manifest and ownership model
  - supported strategic transport modes
  - one-time cargo credit and loss semantics
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only logistics wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 05 – Logistik

## 1. Zweck und Autorität

Logistik ist strategisch und spielerisch relevant, ohne unnötiges Mikromanagement. Hauptbasen verfügen über große strategische Reserven; lokale Knoten besitzen begrenzte, tatsächlich zu transportierende Bestände.

Der vollständige frühere Logistikentwurf bleibt unverändert erhalten:

- [`Legacy-Logistikarchitektur`](evidence/source-records/legacy-05-logistics.md)

Maßgebliche Grundlagen:

- [`OMW-ARCH-CAMPAIGN-STATE`](04-campaign-state.md)
- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)
- [`OMW-GOV-MOOSE-FIRST`](26-moose-first-development-policy.md)
- [`MOOSE-Logistik und Transport`](moose/LOGISTICS-AND-TRANSPORT.md)

## 2. Transportarten

- `ROAD_CONVOY`;
- `HELICOPTER_INTERNAL`;
- `HELICOPTER_SLING`;
- `FIXED_WING_LANDED`;
- `FIXED_WING_AIRDROP`;
- ausdrücklich genehmigte begrenzte AI-Notversorgung.

Kein Transportverfahren ersetzt automatisch die anderen. Kapazität, Reichweite, Infrastruktur, Bedrohung und Verfügbarkeit bestimmen die Auswahl.

## 3. Gemeinsames Manifestmodell

Jede Lieferung besitzt genau eine stabile Cargo-ID und ein Manifest mit mindestens:

```text
cargoId
resourceType
quantity
weight
volume
origin
destination
transportMode
carrierEntityId
status
reservationId
```

Zustände umfassen unter anderem:

```text
AVAILABLE
RESERVED
LOADING
INTERNAL
SLING
IN_TRANSIT
TRANSFERRED
DELIVERED
LOST
DESTROYED
```

Eine Cargo-ID darf einem Zielbestand genau einmal gutgeschrieben werden. Umschlag oder Wechsel des Transportmittels erzeugt keine neue Ressource.

## 4. CampaignState- und Laufzeittrennung

CampaignState führt Eigentum, Menge, Reservierung und Ergebnis. MOOSE CTLD, `OPSTRANSPORT`, DCS Dynamic Cargo, Slingload-Objekte und Gruppen führen die operative Darstellung aus.

Ein projektspezifischer Adapter darf nur nach der vollständigen MOOSE-Prüfung und ausdrücklicher Projektinhaberfreigabe eingesetzt werden.

## 5. Verlust und Abschluss

- zerstörte oder endgültig verlorene Fracht wird nicht gutgeschrieben;
- ein zerstörter Transport kann nicht allein durch vorheriges Entladen automatisch als erfolgreich gelten, wenn die Missionsbedingungen seinen Erhalt verlangen;
- stabile Endposition und gültige Übergabezone werden vor Gutschrift geprüft;
- Teillieferung, Notabwurf und Umschlag werden ausdrücklich modelliert;
- alle Zustandsänderungen werden mit Cargo- und Entity-ID protokolliert.

## 6. Acceptance

Jeder Transportpfad benötigt eigene Tests für:

- Aufnahme und Reservierung;
- Gewicht und Kapazität;
- Übergabe und Einmalgutschrift;
- Zerstörung, Abbruch und Disconnect;
- Multiplayer-Synchronisation;
- Persistenz und Missionsneustart;
- verwendete DCS- und MOOSE-Version.
