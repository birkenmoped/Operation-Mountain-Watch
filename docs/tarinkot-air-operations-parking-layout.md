---
document_id: OMW-AIR-TKOT-PARKING-LAYOUT
status: BINDING
document_class: AIR_OPERATIONS_PARKING_LAYOUT
owning_policy: OMW-GOV-001
authoritative_for:
  - Tarinkot client and AI helicopter parking separation
  - required parking-layout input for all future Tarinkot AIRWING, SQUADRON and G8C builds
not_authoritative_for:
  - historical G6/G7 acceptance provenance
  - a changed Mission Editor layout
  - a successful AI spawn, AIRWING dispatch or vertical departure
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/tarinkot-object-contract-reconciliation
source_commit: 714705e261cd9a329752a2e4345dc6bcbde21c79
validated_in_dcs: false
supersedes: []
superseded_by: []
---

# Tarinkot Air Operations – Parkplatzvertrag

## 1. Zweck und Geltungsgrenze

Dieser Vertrag hält die vom Projektinhaber am 9. August 2026 vorgegebene Trennung von Client- und KI-Helikopterpositionen fest. Er verhindert insbesondere, dass ein Client-Slot in einer AIRWING-/SQUADRON-Prüfung als KI-Pool oder als KI-Preflight-Gate verwendet wird.

Dieser Vertrag ist auf `main` verbindlich. Abweichende frühere Branch- oder Testartefakte dürfen ihn nicht stillschweigend überschreiben.

## 2. Verbindliche Zuordnung

```yaml
clients:
  AH64:
    - terminal_id: 21
      mission_editor_label: C04-H
    - terminal_id: 8
      mission_editor_label: C05-H
  CH47:
    - terminal_id: 3
      mission_editor_label: C07-H

ai_parking:
  AH64:
    - terminal_id: 20
      mission_editor_label: C01-H
    - terminal_id: 19
      mission_editor_label: C21-H
  UH60:
    - terminal_id: 23
      mission_editor_label: C11-H
    - terminal_id: 27
      mission_editor_label: C12-H
    - terminal_id: 30
      mission_editor_label: C14-H
  CH47:
    - terminal_id: 32
      mission_editor_label: C08-H
    - terminal_id: 29
      mission_editor_label: C09-H
    - terminal_id: 10
      mission_editor_label: C10-H
```

Kompaktform:

```yaml
client_terminal_ids: [21, 8, 3]
ai_terminal_ids:
  AH64: [20, 19]
  UH60: [23, 27, 30]
  CH47: [32, 29, 10]
```

## 3. Harte Invarianten

- `21`, `8` und `3` sind ausschließlich Client-Positionen. Sie dürfen weder in `SQUADRON:SetParkingIDs()`, KI-Payloads noch in einem KI-Parking-Preflight erscheinen.
- KI-Preflight und Runtime-Telemetrie müssen die neun `ai_terminal_ids` getrennt von den Client-Positionen ausgeben.
- Die zwei AH-64-KI-Positionen tragen jeweils eine Zwei-Schiff-Gruppe. Sie ersetzen weder Client-Slots noch erhöhen sie die Anzahl gleichzeitig zulässiger AH-64-Gruppen.
- Die Zuordnung ist eine Layoutvorgabe, kein Nachweis für erfolgreichen Spawn, fehlendes Taxi oder vertikales Abheben. Diese Aussagen benötigen weiterhin einen dokumentierten DCS-Lauf.

## 4. Historische Abgrenzung und erforderliche Umsetzung

Frühere G6/G7-Dokumente und Bundles mit `AH64: [21, 4]` und Client-Ausschluss `20` bleiben unveränderte Evidenz ihres damaligen Branch-/Commit-/DCS-Stands. Sie sind kein Nachweis und keine Freigabe für diesen Vertrag.

Der am 9. August 2026 protokollierte G8C-Lauf bestätigt die praktische Relevanz der Abgrenzung: Sein eingebetteter G7-Teil prüfte `21,4`, bewertete `21` als nicht bereit und blockierte G8C vor jeder Missionsanlage. Davor liegende G7-v5-Läufe protokollierten dagegen `AH64 ids=20,19` und erreichten den G7-PASS. Daraus wird keine Aussage zum Vertikalstart abgeleitet.

Vor einem weiteren G8C-Build muss die verwendete G7-Quelle diesen Vertrag exakt abbilden. Erforderliche statische Marker sind:

```text
clientTerminalIDs=21,8,3
AH64 parkingIDs=20,19
UH60 parkingIDs=23,27,30
CH47 parkingIDs=32,29,10
```

Bis diese Quellangleichung separat implementiert und geprüft ist, bleibt G8C `BLOCKED_LAYOUT_CONTRACT_MISMATCH`; ein DCS-Lauf wäre kein Test des dokumentierten Vertrags.
