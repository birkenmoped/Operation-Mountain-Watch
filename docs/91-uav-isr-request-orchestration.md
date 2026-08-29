---
document_id: OMW-UAV-ISR-REQUEST-MAIN-RECONCILIATION
status: DRAFT
document_class: TECHNICAL_RECONCILIATION_AND_GAP_ANALYSIS
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local UAV ISR reconciliation assessment
  - MOOSE AIRWING queue and individual asset selection gap
  - prohibited reuse of earlier ISR dispatcher patterns
not_authoritative_for:
  - production UAV ISR architecture
  - DCS runtime acceptance
  - MOOSE-internal overrides
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
base_branch: main
base_commit: 99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa
source_branch: agent/uav-isr-request-main-reconciliation
source_commit: PENDING_MERGE
validated_in_dcs: false
supersedes:
  - branch-local assumption that AIRWING:AddMission can queue a preselected individual asset
  - branch-local use of squadron.assets and Asset.Treturned as production integration APIs
superseded_by:
---

# UAV ISR Request – Main-Reconciliation und MOOSE-Gap-Analyse

## 1. Zweck und Ausgangspunkt

Dieser Branch beginnt **neu von `main`** bei Commit
`99d4d88d9b9eea2026fe525ebab4e29ff60cdbfa`. Der frühere Branch
`agent/uav-isr-request-orchestration` ist zu diesem Zeitpunkt gegenüber
`main` divergent (110 eigene, 185 fehlende Commits) und darf nicht blind
gemergt oder als aktuelle Produktionsbasis getestet werden.

Die frühere Acceptance-3-Implementierung wird nicht übernommen, weil sie zwei
nach `main` verbindlich unzulässige Muster enthält:

- Zugriff auf `squadron.assets`, um ein Asset zu finden;
- Änderung von `Asset.Treturned`, um nach einem Recall vor Take-off eine
  individuelle MOOSE-Turnoverzeit zu entfernen.

Beides sind MOOSE-Internelemente, nicht die für eine Produktionsintegration
zugesagten öffentlichen Verträge.

## 2. Gesicherte MOOSE-Erkenntnisse

Geprüfter Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
```

| Anforderung | Öffentlicher MOOSE-Pfad | Befund |
|---|---|---|
| Physische Mission warten lassen | `AIRWING:AddMission(mission)` | Der Auftrag wird in die AIRWING-Queue aufgenommen und beginnt erst bei verfügbaren Airframes und Payloads. |
| Pool auf eine SQUADRON beschränken | `AUFTRAG:AssignSquadrons({ squadron })` | Die AIRWING-Auswahl wird auf diese SQUADRON begrenzt. |
| Einzelnes Asset einer Mission zuordnen | `AUFTRAG:AddAsset(asset)` | Öffentlicher Auftragspfad; das Asset hat eine MOOSE-`uid`. |
| Asset beim Aufbau erfassen | `WAREHOUSE:OnAfterNewAsset(..., asset, ...)` | Öffentlicher Callback; liefert das neue Asset mit `uid`, nachdem MOOSE es angelegt hat. Die Bagram-Foundation verwendet diesen Callback bereits. |
| Vorselektiertes Asset sofort anfordern | `LEGION:MissionAssign(mission, legions)` | MOOSE-FSM-Pfad, aber keine normale AIRWING-Queue. |
| Einzelne Rückkehr ohne Turnover freigeben | öffentliche API | Nicht gefunden. `COHORT:SetTurnoverTime` und `GetRepairTime` arbeiten pro COHORT; `Asset.Treturned` ist intern. |

Quellenprüfung: eingebettelte MOOSE-Dokumentation und `Moose.lua`,
verbindliche Main-Dokumente
`OMW-MOOSE-AIRWING-SQUADRON-WAREHOUSE-LIFECYCLE`,
`OMW-GOV-001` und `OMW-GOV-MOOSE-FIRST`. Die offizielle AIRWING-Dokumentation
beschreibt `AddMission` als Queue-Pfad; die Signaturen und Seiteneffekte
wurden gegen den tatsächlich gepinnten Quellstand geprüft.

## 3. Die geprüfte Lücke

Die beiden öffentlichen Wege sind **nicht kombinierbar**, ohne ihr jeweiliges
Semantikversprechen zu verlieren:

```text
AIRWING:AddMission
  -> MOOSE queue
  -> MOOSE rekrutiert das passende freie Asset aus der zugewiesenen SQUADRON

AUFTRAG:AddAsset + LEGION:MissionAssign
  -> vorselektiertes einzelnes Asset
  -> direkter MOOSE-Request, keine AIRWING-Queue
```

`AIRWING:AddMission` rekrutiert bei Fälligkeit gemäß
`AUFTRAG:GetRequiredAssets()` selbst. Ein vorheriges
`AUFTRAG:AddAsset(asset)` verhindert diese Rekrutierung nicht; es kann daher
zu einer zweiten Auswahl beziehungsweise einer falschen Assetbindung führen.
Dies ist kein zulässiger Weg, um eine strategische OMW-Ressourcen-ID an eine
AIRWING-Queued Mission zu binden.

Damit existiert im geprüften öffentlichen MOOSE-Stand **kein einzelner
Aufruf**, der zugleich garantiert:

1. stabile strategische Ressourcen-ID vor Disposition;
2. exakt dieses einzelne MOOSE-Asset;
3. normale AIRWING-Queue einschließlich MOOSE-Turnover.

## 4. Konsequenz aus der Main-Governance

Die aktuelle `main`-Governance fordert gleichzeitig:

- CampaignState wählt vor Disposition konkrete strategische Ressource und
  Herkunftspool;
- MOOSE führt Queue, Spawn, Lifecycle, Rückkehr und Verlust physisch aus;
- jede strategische Ressource hat eine stabile OMW-ID;
- Unterschiede werden gesperrt und gezielt entschieden, nicht still
  nachgebucht.

Der alte A3-13-Ansatz erfüllt diese Bedingungen nicht: Er lässt MOOSE den Pool
wählen und versucht die spätere Zuordnung über interne Tabellen zu erraten.
Der noch ältere lokale Retry-Dispatcher war ebenfalls falsch: Er duplizierte
die MOOSE-Queue.

## 5. Zulässige nächste Architekturentscheidung

Vor einer neuen Test-LUA muss der Projektinhaber eine der folgenden
MOOSE-konformen Richtungen festlegen:

| Option | Queue | Einzelressource vor Disposition | Offene Konsequenz |
|---|---|---|---|
| A: Ein-AIRWING-Queue, Mapping nach MOOSE-Auswahl | vollständig MOOSE | nein | widerspricht der aktuellen Main-Regel „Ressource vor Disposition“. |
| B: eine MOOSE-SQUADRON/AIRWING-Domäne je strategischer UAV-Ressource | MOOSE je Einzelressource | ja | gleichzeitige Warteschlangen/Reserve-Semantik in CampaignState müssen als strategischer Vertrag entworfen werden. |
| C: `AddAsset + MissionAssign` | kein AIRWING-Queue-Pfad | ja | MOOSE-Queue wird bewusst nicht genutzt; nur mit ausdrücklicher Governance-Änderung zulässig. |
| D: kleine MOOSE-Interne Ausnahme | potenziell beide | potenziell beide | gemäß MOOSE-first nur nach nachgewiesener Lücke und ausdrücklicher Owner-Freigabe; derzeit nicht implementiert. |

Option B ist der einzige bislang identifizierte Pfad, der die Assetbindung mit
MOOSE-Ausführung beibehält. Sie löst aber nicht automatisch das gewünschte
Mehrfach-Queueing auf einer bereits reservierten Einzelressource. Dieser
strategische Buchungs- und Cancel-Vertrag muss vor Implementierung entschieden
und getestet werden.

## 6. Nicht wiederholen

- Keine lokale Dispatch-/Retry-Queue neben MOOSE.
- Kein `Asset.Treturned = nil`.
- Kein Zugriff auf `squadron.assets` als Produktions-API.
- Keine Rückgutschrift bei `AUFTRAG:Done` oder Cancel; erst nach bestätigter
  physischer MOOSE-Rückkehr beziehungsweise Verlust.
- Keine Behauptung, ein Turnover-Bypass sei vorhanden, solange nur der interne
  Zeitstempel bekannt ist.
- Kein DCS-Test dieser Reconciliation, bevor die gewählte Option vollständig
  implementiert und statisch geprüft wurde.

## 7. Erforderliche Nachweise nach der Entscheidung

1. stabile OMW-Ressourcen-ID ↔ MOOSE-Bindung;
2. Queue, Start, Cancel vor Spawn, Cancel am Boden, Cancel nach Take-off,
   On-station, Return, Loss und erneute Disposition;
3. Doppelte Lifecycle-Ereignisse idempotent;
4. Server-/Missionsrestart mit erneutem Bindungslauf;
5. absichtliche CampaignState/MOOSE-Abweichung: Sperre, Diagnose und
   zielgerichtete Entscheidung;
6. DCS-Provenienz mit exakt geladener MOOSE-Datei, MIZ- und Bundle-Hash.

Bis dahin ist dieser Zweig **DRAFT** und kein Testkandidat.
