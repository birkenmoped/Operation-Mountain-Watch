---
document_id: OMW-PLAN-ARMY-GROUND-RETURN-SETTLEMENT
status: PLANNED
document_class: DECISION_PREPARATION
owning_policy: OMW-GOV-001
authoritative_for:
  - decision inputs and mandatory gates for a future ARMY Ground CampaignState return-settlement adapter
not_authoritative_for:
  - a strategic vehicle quantity or source-node decision
  - production resource credits
  - a runtime implementation or DCS acceptance result
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/army-ground-foundation-reconciliation
source_commit: PENDING_OWNER_DECISION
validated_in_dcs: false
supersedes:
superseded_by:
---

# ARMY Ground – Rückgabe-Settlement: Entscheidungsgrundlage

## 1. Ausgangslage

Acceptance 4-2 bestätigte ausschließlich den operativen MOOSE-Handoff in Fenty:

~~~text
ARMYGROUP:RTZ(existing Fenty ACCESS zone, OnRoad)
-> Returned
-> LEGION:__AddAsset(10, group, 1)
-> WAREHOUSE AddAsset
-> temporary physical DCS group removal
~~~

Dieser Vorgang ändert CampaignState nicht. Er beweist daher weder strategische Verfügbarkeit noch einen strategischen Credit.

## 2. Bereits vorhandenes, verifiziertes Muster

Der auf main dokumentierte AAR-Adapter verwendet die generische CampaignState-Transaktionsfolge:

~~~text
CanMaterialize
-> ReserveResource
-> Consume
-> confirmed runtime handoff
-> CreditResourceOnce
~~~

Das Muster ist für die dortigen count-basierten KC-135-Pools praktisch validiert. Es darf nicht ohne eine Ground-spezifische Eigentümerentscheidung auf Fahrzeuge übertragen werden.

## 3. Zwingende Eigentümerentscheidungen

| Entscheidung | Warum sie vor Implementierung nötig ist | Derzeitiger Stand |
|---|---|---|
| Strategische Ressource | Legt fest, welche Ground-Ressource eine materialisierte Patrouille repräsentiert. | Offen; keine neue Menge ableiten. |
| Source Node / Parent | Bestimmt den strategischen Pool für Reserve, Verlust und eventuelle Rückgabe. Operativer Warehouse-Host ist nicht automatisch dieser Parent. | Fenty/Jalalabad muss explizit zugeordnet werden; Fortress und Honaker bleiben offen. |
| Commitmenge | Entscheidet, ob die vier M-ATV als vier zählbare Ressourcen oder als andere explizite Einheit gebucht werden. | Offen. |
| Erfolgsereignis | Legt fest, ob nur der bestätigte MOOSE-Handoff ein Credit-Ereignis ist. | Für den künftigen Test vorgeschlagen; noch nicht entschieden. |
| Teilverlust | Definiert, wie zerstörte/einzelne verlorene Fahrzeuge vor einem Gruppen-Handoff behandelt werden. | Offen; A4 enthält keinen Loss-Test. |
| Restart | Definiert, wie konsumierte, aber weder handoff- noch lossbestätigte Ground-Commitments beim Restart behandelt werden. | Offen. |

## 4. Unveränderliche Grenzen

~~~text
CampaignState = sole strategic authority
MOOSE WAREHOUSE = operational mirror and lifecycle
DCS GROUP / UNIT = temporary physical representation
strategic parent != physical dispatch origin
Warehouse AddAsset != automatic CampaignState credit
~~~

Eine Rückgabe darf daher ausschließlich nach einer bestätigten, idempotenten CampaignState-Operation strategische Verfügbarkeit wiederherstellen. Das MOOSE-Warehouse bleibt dabei kein zweiter strategischer Bestand.

## 5. Vorgeschlagener zukünftiger Acceptance-Scope

Nach den Entscheidungen aus Abschnitt 3 soll ein eigener Fenty-Einzeltest vor jeder Ausweitung entstehen:

~~~text
CampaignState CanMaterialize for approved resource/source
-> exactly one reserve + consume with runtime correlation ID
-> unchanged BRIGADE / PLATOON / WAREHOUSE materialization
-> verified mobile ARMYGROUP return to existing Fenty ACCESS zone
-> Returned -> Warehouse AddAsset
-> exactly one approved strategic handoff credit
-> compare CampaignState available / committed / loss audit values
~~~

Zusätzlich sind mindestens zu prüfen:

- kein Credit bei fehlendem `Returned`-Ereignis;
- kein Credit nach bestätigtem Verlust;
- keine Doppelgutschrift bei wiederholtem Callback oder Restart-Reconciliation;
- operativer Warehouse-Bestand und CampaignState-Status werden getrennt geloggt;
- keine neue `.miz`-Änderung durch ChatGPT.

## 6. Nicht Gegenstand dieser Vorbereitung

~~~text
production quantity decisions for Fortress or Honaker
automatic vehicle generation
CampaignState changes in Acceptance 4
cross-site deployment policy
OPSTRANSPORT
merge to main
~~~

## 7. Nächste Entscheidung

Der Projektinhaber entscheidet die sechs Punkte aus Abschnitt 3 für den ersten Fenty-Produktionsscope. Erst danach dürfen der kleinste CampaignState-Adapter, der Initialstock-Eintrag und ein eigener DCS-Acceptance-Test entworfen werden.
