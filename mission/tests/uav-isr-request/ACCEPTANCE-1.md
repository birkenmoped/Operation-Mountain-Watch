---
document_id: OMW-TEST-UAV-ISR-REQUEST-ACCEPTANCE-1
status: DCS_PENDING
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - Phase 1 UAV ISR marker and group-menu acceptance procedure
  - required evidence for the isolated Phase 1 DCS run
not_authoritative_for:
  - physical UAV spawning or routing
  - CampaignState UAV reservations
  - MQ-1/MQ-9 weapon release, AFAC, laser designation, or target marking
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/uav-isr-request-orchestration
source_commit: PENDING_BUILD
validated_in_dcs: false
---

# UAV ISR Request – Acceptance 1

## 1. Zweck und enger Scope

Acceptance 1 prüft ausschließlich die Phase-1-Integration der bereits source-getesteten Player-ISR-Anforderung:

```text
BLUE map marker (exactly UAV RECON)
-> F10 group menu
-> group-owned queued request / own status / own cancel
```

Der Lauf erzeugt weder physische UAVs noch eine `CampaignState`-Reservierung. Er nutzt weder `AIRWING`, `SQUADRON` noch `AUFTRAG` und enthält keine Waffenfreigabe, AFAC-/Laserlogik oder Ziel-/Kontaktmarker. Die normale DCS Fog-of-War-Lage wird durch diesen Test nicht ergänzt oder verändert.

Der Submit-Radius von **10.000 m** ist nur ein Acceptance-1-Testparameter. Er ist keine Produktionsentscheidung für die spätere ISR-Cell.

## 2. Eingangsvoraussetzungen

| Gegenstand | Erforderlicher Stand |
|---|---|
| Ausgangsmission | Unveränderte Kopie von `OMW_Template_v20.miz`; das Original bleibt unangetastet. |
| Testartefakt | Neue Arbeitskopie, z. B. `OMW_UAV_ISR_Request_Acceptance_1.miz`. |
| MOOSE | Vor dem Acceptance-Bundle geladen; Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, SHA-256 `e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`. |
| Clients | Zwei besetzbare BLUE-Clientgruppen in derselben Multiplayer-Mission. |
| Server | Native DCS Fog of War aktiv wie in der gewählten OMW-v20-Baseline. |

## 3. Bundle bauen

Im dedizierten UAV-ISR-Worktree ausführen:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-1.ps1
```

Der Builder erzeugt ausschließlich:

```text
mission/tests/uav-isr-request/dist/OMW_UAV_ISR_Request_Acceptance_1.lua
```

Er mutiert keine `.miz`. Vor einer DCS-Aussage sind der Builder-Output und der SHA-256 des erzeugten Bundles zu protokollieren.

## 4. Mission-Editor-Einbindung

1. `OMW_Template_v20.miz` im Dateisystem in die neue Acceptance-Datei kopieren; nicht im Original arbeiten.
2. Die neue Acceptance-Datei im DCS Mission Editor öffnen.
3. Sicherstellen, dass der vorhandene `Moose.lua`-Lade-Trigger unverändert bleibt und zeitlich vor dem neuen Bundle ausgeführt wird.
4. Einen zusätzlichen Trigger mit **DO SCRIPT FILE** hinzufügen, der genau auf `OMW_UAV_ISR_Request_Acceptance_1.lua` zeigt.
5. Keine weitere Produktionslogik, keine UAV-Templates und keine Spawn-/Routen-Trigger für diesen Test hinzufügen oder ändern.
6. Unter dem neuen Acceptance-Dateinamen speichern.

Die Injektion ist nur gültig, wenn der zusätzliche Bundle-Trigger nach dem MOOSE-Load ausgeführt wird. Die Testdatei darf danach nicht als produktive OMW-Baseline oder als Beleg für UAV-Dispatch verwendet werden.

## 5. Durchführung

1. Mission als Multiplayer-Server starten; zwei unterschiedliche BLUE-Clientgruppen besetzen.
2. In Gruppe A einen BLUE-Kartenmarker mit exakt `UAV RECON` in höchstens 10 km Entfernung setzen.
3. In Gruppe A `F10 Other -> Command -> ISR Cell -> Submit nearest UAV marker` wählen.
4. In Gruppe A `Own request status` wählen und die Request-ID/den Zustand notieren.
5. In Gruppe B das eigene Menü öffnen; es darf kein Detailstatus und keine Abbruchmöglichkeit für den Request von Gruppe A geben.
6. In Gruppe A `Cancel own queued request` wählen; anschließend erneut `Own request status` prüfen.
7. Die Negativfälle aus Abschnitt 6 durchführen.
8. Einen Slotwechsel bzw. Rejoin einer Testgruppe prüfen und beobachten, ob das gruppenspezifische Menü nach der erneuten Belegung funktionsfähig bleibt.

## 6. Mindestfälle und Passkriterien

| ID | Testfall | Passkriterium |
|---|---|---|
| A1-01 | Exakter BLUE-Marker + Submit | Genau ein gruppengebundener `QUEUED`-Request wird gemeldet. |
| A1-02 | Falscher Text oder RED-Marker | Kein Request; erklärende Gruppenmeldung. |
| A1-03 | Kein gültiger Marker in 10 km | Kein Request; erklärende Gruppenmeldung. |
| A1-04 | Zwei gleich nahe gültige Marker | Kein Request; Mehrdeutigkeit wird gemeldet. |
| A1-05 | Eigener Status | Nur die Eigentümergruppe erhält ID und Status ihres Requests. |
| A1-06 | Fremde Gruppe | Keine Detailansicht und keine Fremdstornierung. |
| A1-07 | Eigener Cancel | Der wartende eigene Request wird entfernt; eine zweite Stornierung bleibt wirkungslos. |
| A1-08 | Marker wird gelöscht | Bereits akzeptierter Request bleibt gebunden; für eine neue Abgabe ist ein erneutes Marker-Ändern erforderlich. |
| A1-09 | Rejoin / erneute Clientgruppenbelegung | Menüregistrierung und Gruppenbesitz werden beobachtet und eindeutig als PASS/FAIL notiert. |
| A1-10 | Physische Nebenwirkung | Kein UAV erscheint, startet, routet oder wird reserviert; keine Ziel-/Kontaktmarker entstehen. |

## 7. Pflichtprovenienz

Für einen DCS-PASS sind in einem Ergebnisdokument mindestens festzuhalten:

```text
Acceptance source/build commit:
BuilderVersion:
generated bundle SHA-256:
Acceptance MIZ filename and SHA-256:
internal mission SHA-256:
embedded Moose.lua SHA-256:
DCS version / MT or ST:
server multiplayer and Fog-of-War settings:
two BLUE client group names and group IDs:
executed A1 test cases with PASS/FAIL:
dcs.log SHA-256:
debrief.log SHA-256:
observed limitations:
```

Bis zu diesem Evidenzsatz bleibt der Status `DCS_PENDING`. Ein erfolgreicher GitHub-Lua-Contract-Test ist kein Ersatz für A1-01 bis A1-10 in DCS.

## 8. Offene Runtime-Grenzen

- Das tatsächliche Verhalten von `SET_CLIENT` bei inaktiven, belegten und erneut belegten Clients ist in diesem Scope zu beobachten, nicht vorwegzunehmen.
- Das bewusst breite `MARKEROPS_BASE:New("", {})`-Filterverhalten und der konservative Cache-Reset nach Marker-Delete benötigen DCS-Beobachtung.
- DCS-F10-Menülebensdauer, Kartenmarkerereignisse und native Fog-of-War-Sichtbarkeit sind server-/missionskonfigurationsabhängig.
- Der Test trifft keine Aussage über Terrain, Höhen, Endurance, Holding, MQ-1/MQ-9-Auswahl, die 45-Minuten-On-Station-Regel oder den gemeinsamen Chief-/Commander-Pool. Das sind spätere Phasen.
