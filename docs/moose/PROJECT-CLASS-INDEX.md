---
document_id: OMW-MOOSE-CLASS-INDEX
status: BINDING
document_class: MOOSE_CLASS_REGISTER
owning_policy: OMW-GOV-001
authoritative_for:
  - project MOOSE class statuses
  - planned MOOSE integration candidates
  - scope boundaries of class-level evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - class index without complete governance metadata
superseded_by:
source_branch: agent/complete-documentation-authority-migration
source_commit: PENDING_MERGE
validated_in_dcs: partial
---

# MOOSE-Projektklassenindex

## 1. Zweck

Dieser Index führt den Projektstatus der für **Operation Mountain Watch** relevanten MOOSE-Klassen und Module.

Der vollständige frühere Klassenindex mit allen Einträgen bleibt unverändert erhalten:

- [`Legacy-MOOSE-Klassenindex`](../evidence/source-records/legacy-moose-project-class-index.md)

## 2. Statusbedeutung

```text
CANDIDATE                    fachlich relevant, noch nicht geprüft
PLANNED                      zur Prüfung oder Einführung vorgesehen
IN_USE_PARTIAL               einzelne Funktionen werden verwendet
VALIDATED_FOR_DOCUMENTED_SCOPE
                             nur der konkret dokumentierte Testumfang ist belegt
INTERNAL_RESTRICTED          ausschließlich Diagnose-/Adapterzugriff
REJECTED_FOR_PROJECT_USE     bewusst nicht vorgesehen
```

Diese Klassenstatus sind keine Governance-Dokumentstatuswerte.

## 3. Aktuell besonders relevante Klassen

| Klasse | Projektstatus | Geltungsgrenze |
|---|---|---|
| `AIRBASE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Jalalabad-Suche, ID und Parking-Blacklist auf PR #18 |
| `AIRWING` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Konstruktion und Grundstart des Jalalabad-Knotens |
| `SQUADRON` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | vier Jalalabad-Bestände und Payloadregistrierung |
| `COMMANDER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | AIRWING-Anbindung und Grundstart |
| `AUFTRAG` | `IN_USE_PARTIAL` | Capability-/Payloadzuordnung; taktische Ausführung offen; `NewRECON()` registriert ein Asset nicht automatisch als `INTEL`-Agent |
| `WAREHOUSE` | `IN_USE_PARTIAL` | Warehouse-Funktion über AIRWING; strategische Logistik offen |
| `SCHEDULER` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | geordnete Konstruktion und Diagnose |
| `GROUP`, `UNIT`, `STATIC`, `ZONE` | `VALIDATED_FOR_DOCUMENTED_SCOPE` | Template-, Static-, Warehouse- und Zonenvalidierung |
| `ARMYGROUP`, `BRIGADE`, `OPSGROUP` | `PLANNED` | Bodenoperations- und Bestandsmodell |
| `OPSTRANSPORT` | `PLANNED` | taktischer Transport |
| `CTLD`, `CSAR`, `AICSAR` | `PLANNED` / teilweise verwendet | separate Acceptance erforderlich |
| `INTEL` | `PLANNED` | primäres taktisches Lagebild; Sensorarten, räumliche Filter, Kontakt-/Clusterereignisse und kontrollierte HUMINT-Einspeisung; Laufzeitnachweis im gepinnten MOOSE-Stand fehlt |
| `INTEL_DLINK` | `CANDIDATE` | Aggregation getrennter Luft-, Boden- und HUMINT-Netze; Cache, Deduplizierung und Performance offen |
| `PLAYERRECCE` | `CANDIDATE` | spielergeführte Aufklärung, Zielberichte und OH-58D-Kiowa-Autolase; Modul- und Multiplayerprüfung offen |
| `TARS` | `CANDIDATE` | verzögerte Foto-/IMINT-Aufklärung mit Rückkehr und Debrief; Verfügbarkeit und CampaignState-Integration offen |
| `DETECTION_*` | `PLANNED`, eingeschränkt | nur für DESIGNATE oder nachgewiesene Spezialfälle; kein paralleles strategisches Lagebild neben `INTEL` |
| `Core.Astar`, `PATHLINE`, `MOVEMENT` | `PLANNED` | Routing und Bewegungsbegrenzung |
| `_DATABASE` | `INTERNAL_RESTRICTED` | nur Diagnose und Templateprüfung |
| `CHIEF` | `REJECTED_FOR_PROJECT_USE` | bleibt in der aktuellen Produktionsarchitektur `NOT_USED`; direkte Zonenlogik darf das Fog-of-War-Modell nicht umgehen |

## 4. Fog-of-War- und RECCE-Grenzen

- [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md) ist die vollständige Fähigkeits- und Grenzenanalyse.
- `AUFTRAG:NewRECON()` ist ein Bewegungs-/Missionsauftrag und registriert das eingesetzte Asset nicht automatisch als `INTEL`-Agent.
- `INTEL:SetForgetTime()` ist im geprüften Develop-Stand als obsolet und nicht funktionsfähig dokumentiert.
- Direkte Zonen- oder Datenbankscans dürfen das Fog-of-War-Modell nicht umgehen.
- `CHIEF` bleibt für die aktuelle Produktionsarchitektur `NOT_USED`; eine spätere Neubewertung muss seine direkte Zonenlogik berücksichtigen.

## 5. Nachweisregel

Ein Klassenstatus wird nur angehoben, wenn:

- die verwendete MOOSE-Version identifiziert ist;
- API und Signatur geprüft sind;
- Mission, OMW-Commit und relevante Hashes dokumentiert sind;
- beobachtetes Verhalten und Einschränkungen festgehalten sind;
- der Nachweis im Methodenregister oder Acceptance-Bericht verlinkt ist.
