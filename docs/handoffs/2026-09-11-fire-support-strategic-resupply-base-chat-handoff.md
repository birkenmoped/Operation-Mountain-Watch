---
document_id: OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911
status: PLANNED
document_class: CHAT_HANDOFF_AND_IMPLEMENTATION_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - handoff context for FireSupStratResupply base-module planning
  - required MOOSE-first research and implementation sequence
  - known Stage-3 evidence, failures, limits and regression requirements
not_authoritative_for:
  - generic DCS runtime acceptance
  - permission to bypass MOOSE public APIs
  - a claim that every site or support type is already implemented
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-handoff
source_commit: 980340c9225a81921aed8995aa8f50cad7d1c215
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Chat-Handoff und Implementierungsplan: standortunabhängige Fire-Support-/Strategic-Resupply-Basis

> Hinweis zum aktuellen Folgebranch: Die ursprüngliche Übergabe bleibt historischer Planungsnachweis. Die auf Branch `agent/fire-support-strategic-resupply-base-gate0` dokumentierte Gate-4-Präzisierung trennt inzwischen persistenten Guard, incident-scoped Local Defense/C2-Support und threshold-driven Resupply. Maßgeblich für die laufende Gate-4-Arbeit ist `docs/moose/FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE-4-STAGE3-REGRESSION-PLAN.md` zusammen mit ADR 0008 und den weiterhin verbindlichen Governance-Dokumenten.

## 1. Zweck dieser Übergabe

Dieses Dokument übergibt einem Folgechat den vollständigen fachlichen, technischen und evidenzbezogenen Arbeitsstand für ein künftig standortunabhängiges Modul mit der fachlichen Rolle:

```text
FireSupStratResupply_base.lua
```

Die konkrete Repository-Datei soll der bestehenden Namenskonvention folgen:

```text
scripts/campaign/OMW_FireSupStratResupply_Base.lua
```

Es ist **noch kein Implementierungsauftrag und keine Runtime-Acceptance**. Der Folgechat darf erst nach den hier verlangten MOOSE-Prüfungen und der erforderlichen Projektinhaberentscheidung produktiven Lua-Code entwickeln.

Dieses Dokument enthält bewusst auch frühere Fehlannahmen, fehlende Nachweise und verworfene Lösungsansätze. Sie dürfen nicht erneut als offene Designoptionen behandelt werden.

## 2. Verbindliche Arbeitsregeln

Der Folgechat muss vor jeder Änderung diese Dokumente auf dem aktuellen `main` lesen und gegen den tatsächlich ausgecheckten Branch prüfen:

1. [Projekt-Governance – `OMW-GOV-001`](../00-project-governance.md)
2. [MOOSE-First-Entwicklungsrichtlinie – `OMW-GOV-MOOSE-FIRST`](../26-moose-first-development-policy.md)
3. [Testmissionen bauen, übertragen und validieren – `OMW-TEST-MISSION-BUILD-TRANSFER-VALIDATION`](../22-test-mission-build-transfer-and-validation-workflow.md)
4. [Dokumentmetadaten und Provenienz – `OMW-GOV-DOCUMENT-METADATA`](../DOCUMENT-METADATA-POLICY.md)
5. [Stage-3 CAS Tactical Corridor Decision](../moose/STAGE3-CAS-TACTICAL-CORRIDOR-DECISION.md)
6. [Stage-3 CAS Lifecycle and Recovery Law](../moose/STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md)
7. [MOOSE Support Request Lifecycle Law](../moose/MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md)

Zusätzlich gelten ohne Ausnahme:

- **MOOSE-first:** Erst Dokumentation, gepinnte `Moose.lua` und offizielle MOOSE-Demos/Tests prüfen; erst danach eine Lücke dokumentieren.
- **Öffentliche MOOSE-APIs:** Keine privaten Tabellen, keine `_DeleteQueueItem...`- oder vergleichbaren internen Methoden.
- **Kein zweiter Dispatcher:** OMW darf weder Assetwahl noch Verfügbarkeitsqueue, Retry-Schleifen oder Rekrutierung parallel zu MOOSE nachbauen.
- **CampaignState ist strategisch autoritativ:** MOOSE/DCS liefert bestätigte physische Lifecycle-Ereignisse; CampaignState übernimmt sie idempotent. Eine DCS-Gruppe ist keine zweite strategische Ressource.
- **Keine MIZ-Mutation:** Der Assistent baut Lua; Sven bindet das Bundle manuell in die MIZ ein. Eine übergebene MIZ wird nur lesend auf Objektvertrag und Hash geprüft.
- **Keine Behauptung ohne Evidenz:** Ein Build beweist Syntax, Konsistenz und Hashkette, aber kein DCS-Verhalten. Jede Runtime-Aussage benötigt den exakten Branch, Commit, Bundle-, MIZ-, MOOSE- und Log-Nachweis.

## 3. Ausgangslage auf `main`

Die Stage-3-Arbeit zum Fire Support und Strategic Resupply wurde über den Branch

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

in Pull Request #144 nach `main` integriert. Sven bestätigte lokal anschließend:

```text
main HEAD: c10628e1fb917854f720cb5f3051ff5f0dc595af
```

Dieser Commit ist ein historischer Übergabepunkt, nicht automatisch der künftig aktuelle `main`-HEAD.

Der verwendete MOOSE-Stand der Stage-3-Prüfung lautet:

```text
MOOSE commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:   E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 4. Was der Honaker/Wright-Test tatsächlich belegt – und was nicht

Die Testmission war absichtlich ein konkreter Acceptance-Case:

```text
Bedrohter Standort:        COP Honaker
CAS-Heimat / Testbestand:  Jalalabad / AH-64
Strategischer Zielstandort: Wright
```

Sie ist **kein** generisches Produktionsmodul.

Festgehaltene, konkrete Testeigenschaften:

- CAS verwendet MOOSE `AUFTRAG:NewPATROLZONE(...)` und `SetEngageDetected(...)`.
- Der Einsatzweg folgt einer bereits konfigurierten OMW-Route; Ingress und Egress sind dynamisch auf dieser Hin- beziehungsweise Rückroute abgeleitet.
- Es gibt keine festen Editor-Marker und keine künstliche Battle Position.
- Im Test galt eine dynamische Gate-Zieldistanz von 3,5 NM; dies ist keine globale Regel für alle CAS-Muster oder Standorte.
- CAS-No-Contact basiert ausschließlich auf dem eigenen MOOSE-/DCS-Sensorbild der zugewiesenen Fluggruppe (`FLIGHTGROUP:GetDetectedGroups()`), nicht auf Incident-Listen, F10-Sichtbarkeit, roten Gruppenlisten oder `KnowTarget()`.
- Der Honaker-spezifische Release verlangte: unterstütztes Element kennt keine Angreifer mehr, CAS ist physisch on station und das eigene Sensorbild war mindestens 30 Sekunden stabil ohne relevanten Kontakt.
- Physische Rückkehr ist erst nach Landung am Heimatflugplatz **und** `AIRWING:OnAfterLegionAssetReturned(...)` strategisch als Rückgabe zu buchen.
- CAS on station hält nur **neue** ARTY-Feueraufträge im selben taktischen Raum zurück. Bereits laufende Feueraufträge werden nicht künstlich beendet.

Für eine spätere generische Basis dürfen davon nur die abstrakten Invarianten übernommen werden. Die konkreten Werte, Honaker-Bedingungen, Jalalabad-Bindung und Wright-Logistik sind zu parametrisieren oder als Testfixture zu belassen.

## 5. Fehler, Irrwege und verbindlich verworfene Ansätze

### 5.1 Feste CAS-Marker oder künstliche Battle Position

Verworfen. Es existieren und werden keine dauerhaft gesetzten `CAS_INGRESS`, `CAS_EGRESS` oder Battle-Position-Marker verlangt.

### 5.2 Honaker/Jalalabad/Wright als Produktionsannahme

Verworfen. Diese Namen dürfen nicht im Base-Modul, dessen Zustandslogik oder generischen Acceptance-Kriterien fest verdrahtet werden.

### 5.3 Eine fehlende Unterstützung blockiert alle anderen

Verworfen. Guard, QRF, ARTY, CAS und Resupply sind unabhängige Optionen.

### 5.4 Eigene Vorselektion oder eigene Retry-/Dispatch-Queue

Verworfen. OMW soll nicht vorab aus Kandidatenlisten entscheiden, welches Luft- oder Bodenasset gerade geeignet sei. MOOSE soll Rekrutierung, Verfügbarkeit und Warteschlange verwalten.

### 5.5 Rohes Incident-Ende als CAS-Ende

Verworfen. Alarmzone, `OPSZONE:Defeated`, Incident-Teilnehmer, rohe RED-Zähler, C2-Feuerbeobachtung oder `AUFTRAG:Cancel()` allein beweisen weder ein reguläres CAS-Ende noch die physische Recovery.

### 5.6 Unbestätigte Ressourcenbuchung

Verworfen. Ein Start, ein Rückkehrbefehl, `Done`, Cancel oder ein in Transit befindlicher Konvoi verändern den strategischen Zielbestand nicht.

### 5.7 Private MOOSE-Warehouse-Queue-Manipulation

Verworfen. Der gepinnte MOOSE-Stand enthält interne Löschmethoden, aber keine bestätigte öffentliche Einzelrequest-Expiry-/Cancel-API für rohe `WAREHOUSE:AddRequest(...)`-Requests. Diese Interna dürfen nicht als Lösung verwendet werden.

## 6. Verifizierter MOOSE-Lifecycle und offene Grenzen

Die folgenden Aussagen sind gegen die gepinnte `Moose.lua` geprüft. Sie sind source-reviewed, nicht DCS-validiert.

| MOOSE-Bereich | Bestätigtes Verhalten | Folge für die Base |
|---|---|---|
| `LEGION:AddMission` / `CheckMissionQueue` | Queue, Rekrutierungsversuch und `AUFTRAG:IsReadyToCancel()` | direkte Legion-/AIRWING-/BRIGADE-Aufträge können native Zeiten/Conditions nutzen |
| `COMMANDER` / `CHIEF` | geplante Missionen werden rekrutiert versucht | bei Incident-Ende oder fachlichem Ablauf minimalen Lifecycle-Adapter über öffentliche Cancel-API verwenden |
| `AUFTRAG` | `SetTime`, Start-/Success-/Failure-Conditions und `Cancel()` vorhanden | native Auftragssprache verwenden; kein eigener FSM |
| `OPSTRANSPORT` | `SetTime`, `AddConditionStart`, `Cancel()` vorhanden | Ablauf/Incident-Ende über öffentliche Lifecycle-API, soweit fachlich zuständig |
| `WAREHOUSE` | dauerhaft ungültige Requests werden intern verworfen; temporär unprozessierbare bleiben wartend | nicht durch OMW vorfiltern; Nullbestand-/Einzelrequest-Expiry bleibt offene API-Grenze |
| `ARTY` | eigene Target-Queue, `RemoveTarget`, `SetTimeToShot` | ARTY-Target-Lifecycle nur über MOOSE-ARTY führen |

## 7. Zielarchitektur der Base

Die Base ist ein **Incident-/Site-/Resource-to-MOOSE-Orchestrator**, kein Combat- oder Resource-Dispatcher.

```text
Installation / lokale Lage / Ressourcenlage
-> persistente Site Security ODER Incident ODER qualifizierter Resupply-Bedarf
-> OMW_FireSupStratResupply_Base
-> pro Support-Art ein kleiner MOOSE-Adapter
-> MOOSE COMMANDER/LEGION/AIRWING/BRIGADE/WAREHOUSE/ARTY
-> bestätigte MOOSE-Lifecycle-Ereignisse
-> idempotente CampaignState-Buchung
```

Die genauere aktuelle Aktivierungssemantik steht im Gate-4-Regressionsplan.

## 8. Standortkonfiguration

Standortdaten und Supportfähigkeit bleiben reine Konfiguration. `enabled = true` bedeutet nur, dass eine Fähigkeit grundsätzlich vorgesehen ist; es bedeutet nicht, dass sie beim Incident automatisch gestartet wird.

## 9. Strategischer Herkunftspool

Der in der ursprünglichen Übergabe dokumentierte Konflikt wurde für diesen Scope durch ADR 0008 präzisiert: MOOSE verantwortet die operative Rekrutierung innerhalb der zulässigen Organisationsgrenze; OMW/CampaignState baut keine zweite operative Kandidatenwahl auf.

## 10. CAS-Routenvertrag für die Base

Für Drehflügler ist der bereits entwickelte Korridoransatz wiederzuverwenden und standortunabhängig zu konfigurieren. Keine festen CAS-Marker, keine künstliche Battle Position und keine erfundene Ersatzgeometrie.

## 11. Resupply- und Personalvertrag

Resupply umfasst mindestens die bereits im Projekt geführten strategischen Ressourcenklassen. Die Base darf keine lokale Verfügbarkeit fingieren. Der aktuelle Folgebranch präzisiert zusätzlich: Resupply ist **nicht** an einen Attack-Incident gekoppelt, sondern wird ausschließlich aus einem bereits qualifizierten Ressourcen-/Threshold-Bedarf erzeugt. Die Schwellenbewertung bleibt bei der vorhandenen ResourceDemand-Logik.

## 12. Vorgeschriebene Implementierungsreihenfolge

Gate 0 bis Gate 3 wurden auf dem Folgebranch bearbeitet. Gate 4 ist die rückwärtskompatible Stage-3-Regression. Maßgeblich ist hierfür der separate Gate-4-Regressionsplan.

## 13. Verbindliche Acceptance-Matrix

Die ursprüngliche Acceptance-Matrix bleibt als Planungsgrundlage bestehen. Sie wird durch die präzisierte Trennung von persistentem Guard, Incident-Support und threshold-driven Resupply ergänzt.

## 14. Erwartetes Ergebnis des Folgechats

Die Base darf nicht aus dem Honaker-Test ohne zweiten Standort eine generische Produktivfunktion erklären, kein unbestätigtes MOOSE-/DCS-Verhalten erfinden, die offene WAREHOUSE-Einzelrequest-Grenze verdecken oder bestehende Regeln stillschweigend überschreiben.

## 15. Kurzfassung für den Start eines Folgechats

> Wir wollen eine standortunabhängige MOOSE-first-Basis für persistente Site Security, lokale Incident-Defense, externen C2-Support und threshold-driven Resupply entwickeln. MOOSE verwaltet Rekrutierung, Queue, Ausführung und physische Lifecycle-Ereignisse; CampaignState die strategische Persistenz. Keine festen CAS-Marker, keine künstliche Battle Position, keine zweite Assetauswahl/Queue und keine MIZ-Mutation. Honaker/Wright/Jalalabad bleiben konkrete Testfixtures, keine globale Produktionsannahme.
