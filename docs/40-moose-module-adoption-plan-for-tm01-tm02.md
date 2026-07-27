---
document_id: OMW-PLAN-TM01-TM02-MOOSE-ADOPTION
status: PLANNED
document_class: IMPLEMENTATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - proposed MOOSE adoption order for TM01 and TM02
  - module replacement and verification plan
not_authoritative_for:
  - completed production adoption
  - non-MOOSE exception approval
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: review/tm01-tm02-moose-first
source_commit:
validated_in_dcs: false
---

# 40 – MOOSE-Adoptionsplan für TM01 und TM02

## 1. Status und Einordnung

```text
Status: PLANNED
Implementation planning: started
```

Dieses Dokument setzt die Ergebnisse aus Dokument 39 in eine kontrollierte Prüf- und Adoptionsreihenfolge um.

Der vollständige bisherige Plan bleibt unverändert erhalten:

- [`Legacy-Adoptionsplan`](evidence/source-records/legacy-40-moose-module-adoption-plan.md)

## 2. Verbindliche Regel

CampaignState und projektspezifische Fachpolitik bleiben OMW-Verantwortung. MOOSE übernimmt die Laufzeitorchestrierung, wo eine passende Klasse vorhanden und im verwendeten Stand nachgewiesen ist.

Eine technisch notwendige Eigenlogik ist nicht automatisch genehmigt. Produktionsnutzung erfordert die ausdrückliche Projektinhaberfreigabe nach Dokument 00 und 26.

## 3. Vorrangige MOOSE-Prüfziele

- `Functional.Movement`;
- `Core.Pathline`;
- `Core.Astar`;
- `Core.MarkerOps_Base`;
- `Core.Goal`;
- `Core.Message`;
- `Core.SpawnStatic`;
- `Core.Scheduler`;
- `Core.Fsm`;
- `Wrapper.Group`;
- `Ops.ArmyGroup` und `Ops.OpsGroup`;
- MOOSE-`SET_*`-Klassen und Eventhandling.

## 4. Geplante Zuordnung

| Problemklasse | Primärer MOOSE-Kandidat | OMW-Verantwortung |
|---|---|---|
| globale Bewegungsbegrenzung | `MOVEMENT` | Kampagnenpriorität und Freigabepolitik |
| geprüfte Routengeometrie | `PATHLINE` | Segmentdaten und Missionsdesign |
| Netzwerkpfadwahl | `Core.Astar` | Kosten, Eignung und strategische Regeln |
| Meldungen | `MESSAGE` | Inhalt, Sprache und Empfängerpolitik |
| Zeitsteuerung | `SCHEDULER` | fachliche Intervalle und Abbruchbedingungen |
| Zustandsautomaten | `FSM` | Kampagnenzustände und Persistenz |
| Gruppenlebenszyklus | `GROUP` / `OPSGROUP` / `ARMYGROUP` | stabile IDs und strategische Folgen |

## 5. Adoptionskriterien

Ein Modul gilt erst als produktiv übernommen, wenn:

- API und Signatur im gepinnten MOOSE-Stand geprüft sind;
- Abhängigkeiten und Initialisierungsreihenfolge dokumentiert sind;
- ein reproduzierbarer DCS-Test vorliegt;
- Regressionen gegen den bisherigen Teststand geprüft sind;
- verbleibende Eigenlogik separat genehmigt ist;
- CampaignState und MOOSE keine parallele Autorität besitzen.
