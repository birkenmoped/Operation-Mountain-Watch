---
document_id: OMW-VIRTUALIZATION
status: BINDING
document_class: REPRESENTATION_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - strategic versus physical representation rules
  - materialization and dematerialization safety constraints
  - preservation of campaign identity across representation changes
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - prototype-only virtualization wording
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit:
validated_in_dcs: false
---

# 07 – Virtualisierung und physische Repräsentation

## 1. Zweck

Entfernte Einheiten und Transporte können als strategische Entitäten geführt werden, solange keine relevante physische Interaktion möglich ist. Die Virtualisierung reduziert DCS-KI-, Sensor-, Wegfindungs- und Kollisionslast, ohne strategische Identität oder Ressourcen zu verlieren.

Der vollständige frühere Entwurf bleibt unverändert erhalten:

- [`Legacy-Virtualisierungsentwurf`](evidence/source-records/legacy-07-virtualization.md)

Übergeordnete Architektur:

- [`OMW-ARCH-CAMPAIGN-DYNAMIC-MISSION`](37-campaign-architecture-and-dynamic-mission-design.md)

## 2. Virtueller Zustand

Eine virtualisierte Entity besitzt mindestens:

- stabile CampaignState-ID;
- Zusammensetzung und Verluste;
- Fracht und Ressourcen;
- Auftrag und Ziel;
- Route, Segment und mathematische Position;
- Geschwindigkeit und Zeitstempel;
- Exposure-, Tracking- und Kontaktstatus;
- keine aktive DCS-Gruppe.

## 3. Materialisierung

Materialisierung ist erforderlich bei:

- Spieler- oder relevanter KI-Nähe;
- bevorstehender Beobachtungs- oder Kampfchance;
- aktivem Eskorte-, Recon- oder Intercept-Auftrag;
- Annäherung an Ziel, FOB, Cache, Checkpoint oder Hinterhalt;
- zwingendem Exposure Window.

Spawns erfolgen nur an validierten Ankern, mit korrekter Fahrtrichtung und außerhalb plausibler unmittelbarer Beobachtung.

## 4. Dematerialisierung

Nur zulässig, wenn:

- kein Spieler oder relevanter Sensor die Gruppe beobachtet oder verfolgt;
- kein Kampf, Waffeneinsatz oder unmittelbarer Kontakt besteht;
- keine Be-/Entladung, Landung oder Zielinteraktion läuft;
- Mindestzeit und Mindestdistanz erfüllt sind;
- der Zustand vollständig in CampaignState überführt werden kann.

Aktivierungs- und Deaktivierungsgrenzen verwenden Hysterese.

## 5. Fairness- und Sicherheitsregel

Unzulässig sind:

- sichtbare Teleportation;
- Dematerialisierung während Aufklärung, Verfolgung oder Kampf;
- Zurücksetzen einer entdeckten Gruppe als Stuck-Recovery;
- Verlust von Fracht, Schäden oder Entity-ID beim Wechsel;
- Proxy-Fahrzeuge als unabhängige zweite strategische Wahrheit.

## 6. Acceptance

Zu testen sind insbesondere:

- Pack/Unpack mit Beobachtungsstatus;
- Watchguard für verpackte und entpackte Gruppen;
- Stuck-Recovery ohne unfairen Teleport;
- Verluste und Frachtzustand;
- Multiplayer-Synchronisation;
- Missionsneustart und Persistenz;
- Performancegrenzen und Exposure Windows.
