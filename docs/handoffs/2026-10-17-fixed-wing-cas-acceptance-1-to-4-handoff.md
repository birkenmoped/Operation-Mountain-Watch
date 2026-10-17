---
document_id: OMW-HANDOFF-FIXED-WING-CAS-2026-10-17
status: DRAFT
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - historische branch-lokale CAS-Response-Acceptance-1-bis-4-Evidenz und Arbeitsuebergabe
not_authoritative_for:
  - projektweite CAS-Produktionsfreigabe
  - sichere Fuel-, AAR- und Recovery-Policy
  - DCS-validierte Acceptance 5
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# Handoff: Fixed-Wing CAS Response, Acceptance 1–4 (17.10.2026)

## 0. Anweisung an den uebernehmenden Chat

Dieses Dokument **vollstaendig** lesen, danach die aktuellen Dokumente auf **main**: `AGENTS.md`, `docs/00-project-governance.md`, `docs/26-moose-first-development-policy.md`, `docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `docs/DOCUMENT-METADATA-POLICY.md`, passende AIRWING-/AAR-/CampaignState-Baselines und `docs/moose/PROJECT-CLASS-INDEX.md`. Anschliessend den Ist-Stand auf dem CAS-Branch und die tatsaechlich verwendete `Moose.lua` lesen. Bei Konflikten ausschliesslich die Governance-Hierarchie anwenden. **Keine neue A5-Lua erstellen, bevor die A4-Fehler gegen den gepinnten MOOSE-Source und produktive AWACS-/AAR-Lifecycles abgeglichen sind.** Keine Halluzination von Commits, Hashes oder Runtime-Ergebnissen.

Repository: `birkenmoped/Operation-Mountain-Watch`. Draft PR [#151](https://github.com/birkenmoped/Operation-Mountain-Watch/pull/151), Branch `agent/fixed-wing-cas-coverage-ground-alert-decision`. A4-Testcode HEAD/Bundle-Quelle: **`ae4961a46cbe2bd47dfbb1a67426e480798b2135`**. Die hier dokumentierte Uebergabe ist eine **nachtraegliche Dokumentation**, nicht der damals getestete Code-Commit. Der Besitzer arbeitet im separaten Worktree `P:\DCS-DEV\Operation-Mountain-Watch-cas-ground-alert`; `main` und andere Worktrees nicht veraendern. GitHub-Arbeit (Implementierung, Diff, Tests, Dokumentation, Commit, Push) durch ChatGPT; anschliessend **eine nummerierte PowerShell-Anweisung** fuer Owner: `Set-Location` explizit voranstellen, Pull/Build/SHA, reale Konsolenausgabe abwarten. Python ist auf der Windows-Entwicklungsmaschine **nicht vorhanden**; Dokumentationschecks per GitHub Actions. **Nur der Besitzer bearbeitet .miz/ME**. Kein CODEX.

## 1. Ziel und verbindliche Gespraechsentscheidungen

Gleicher DCS-Testlauf mit **drei echten MOOSE-C2-CAS-Anforderungen**:
1. F-16C Two-Ship aus Bagram sofort;
2. A-10C II Two-Ship aus Kandahar nach 60 s;
3. F-15E Two-Ship aus Bagram erst nach beiden F-16-Takeoffs (Bagram-DCS-ATC kreuzt Startbahn bei Wingman getrennt; kein zeitgleicher zweiter Two-Ship-Request).

AO Honaker (Testzone), MOOSE `COMMANDER`/`AIRWING`/`SQUADRON`/`AUFTRAG:NewCAS`. Two-Ship-Join vor Abflug in Richtung AO: Bagram-Jets und ab A4 auch Kandahar-A-10. CAS-Alarmrotte: **schneller** Transit mit brauchbarer Fuel-/Kampfreserve; Nachbrenner darf sinnvoll sein, wird nicht blind erzwungen. Scheduled-CAS-Standby: **verbrauchsoptimierter** Transit und moeglicherweise AAR vor AO. Transit-, Orbit- und RTB-Hoehen/-Geschwindigkeiten trennen, aber MOOSE-Routing und Fuel-FSM behalten. Kein vorgeplanter Tankerzwang fuer Alarm-CAS; vorhandenen Tanker je Erreichbarkeit, Betankungssystem, Aktivitaet und OMW-Fachzuordnung waehlen; kein eigener DCS-Flugcontroller.

A-10-Kandidaten fuer **diesen** Honaker-Test: **PATTY** (RC-East) und **MILHOUSE** (Recovery nach Kandahar); **KRUSTY ausgeschlossen**. Fastjets: **NELSON**, bei tatsaechlicher Eignung und Verfuegbarkeit auch weitere FAST-Tanker (A4-Testliste LISA/MOE). Die Rolle von C2 bei gesondertem Receiver-AAR-MissionDemand ist **noch nicht entschieden/implementiert**. CampaignState ist strategische Ressourcenautoritaet; physischer Lifecycle bei MOOSE. Keine unerlaubten Native-DCS- oder MIST-Alternativen.

## 2. Versionen, Builds, Test-Evidenz und Abnahmestatus

| Acceptance | Source-Commit | lokaler Bundle-SHA-256 (Owner-Konsole) | Kernbefund |
|---|---|---|---|
| A1 | `147e74ccc17d22aa47cba8f133532014f51d6c10` | `C6DAE11DF56FA2A941C2FFD0CEF7363A4127F2F1C48560D3A7911B09129CB37F` | Zwei Bagram-Jets gestartet; nach Start Runway-Sequencing, Wingman-Afterburner-Aufholen/Fuel; tiefer Gebirgstransit; A-10 nicht rekrutiert; DCS Access Violation beobachtet; F-16-Lead GBU-12-Einsatz |
| A2 | `2aef5664408639d03d7d568e1e78d62db9535914` | `CA99395C125040058CFB66023B789749435521CA7684A041628D88275E3CF74E` | Bagram-Formation und hochgelegener Hinflug verbessert; A-10 weiterhin nicht rekrutiert; F-15E-Verlust bei RTB; RTB zu niedrig |
| A3 | `08e54252aeba88245cff70e1d4a7fda47f2883e3` | `19E6C3054F90D7538BA65F6AA4A898F37BE8BE54794C3EDFD50CA0B000CF41ED` | alle drei Formationen rekrutiert; A-10 noch **ohne** Join; Transit viel langsamer als geplant; F-16-Wingman und beide A-10 mit Fuel=0 verloren; F-15E beidseitig zurueck |
| **A4** | **`ae4961a46cbe2bd47dfbb1a67426e480798b2135`** | **`284F001BD397DC171F4EB17B8676E75BAA37AC00D2588D59724804722E3C7FA8`** | alle drei Two-Ships rekrutiert/gejoint; A-10 bei PATTY betankt, aber kein nachgewiesener CAS-AO-Eintritt; F-16-Wingman sowie zwei A-10 verloren, F-15E beide in Bagram gelandet; Gesamtstatus **FAIL** |

DCS-Log A4: vom Owner hochgeladen **`dcs(3).log`** (37.185 Zeilen), Debrief **`debrief(3).log`** (158.887 Zeilen), beide 17.10.2026, DCS **2.9.30.28738 MT**; Mission laut Debrief `OMW_Template_v26_GroundWorks_Ready.miz`, MOOSE-Version im Projektstand **2.9.18**. Die exakten **MIZ- und eingebetteten MOOSE-SHA256-Werte sind in dieser Uebergabe NICHT unabhaengig belegt**. Den Owner-Bundle-Hash nicht als MIZ-Hash ausgeben. A4-Lua-5.1-/Builder-/Dokumentations-CI war PASS; **kein DCS-Acceptance-PASS**, nicht als `VALIDATED` deklarieren.

## 3. A4: exakter MOOSE-Request-/Dispatch-Verlauf (Log-Zeit = SecondsOfToday)

Alle drei MOOSE-Requests erstellt und an C2 uebergeben:
- F-16: `54065` (15:01:05); Flight `SQ_US_BGRM_F16C_121_EFS_AID-7`, zwei Elemente; Takeoffs `54625`/`55024`; Join `55025` mit Abstand 3155 m; `MISSION_EXECUTE` `55972`.
- A-10: `54125` (15:02:05); Flight `SQ_US_KAF_A10C_74_EFS_AID-70`; Takeoffs `54466`/`54823`; Join `54830`, Abstand 3483 m. Nach AAR **kein `MISSION_EXECUTE`, `ELEMENT_IN_AO` oder `TWO_SHIP_IN_AO` im A4-Observer**.
- F-15E: `55024` (15:17:04), also exakt beim zweiten F-16-Takeoff; Flight `SQ_US_BGRM_F15E_335_EFS_AID-6`; Takeoffs `55594`/`55940`; Join `55940`, Abstand 429 m; `MISSION_EXECUTE` `56722`; `ELEMENT_IN_AO` beide `63591`, `TWO_SHIP_IN_AO` `63591` (elapsed 8567 s vom Request). **Achtung:** AO-Erkennung/Logger-Zeit und DCS-Wahrnehmung muessen getrennt betrachtet werden; eine reine `success`-FSM-Meldung ist kein AO-Beweis.

Flight-config A4: F-16 `SetDefaultSpeed(450)`, F-15E `460`, A-10 `260`; `mission:SetMissionSpeed(...)` getrennt vom Orbit `350/350/230` kn. Cruise/RTB via `SetDefaultAltitude(22000)` ft MSL. Kandahar-A-10-Holding: 12000 ft MSL/210 kn und Join bis 2 NM; Bagram-Jet-Holding 16000 ft/250 kn. A-10 COHORT/AUFTRAG `SetMissionRange(400)` NM, benoetigt fuer >330-NM-Kandahar-Honaker-Route. Die Werte sind **Testkonfiguration**, keine globale Leistungs-/Fuel-Policy.

## 4. A4: AAR-Befund

`OMW.AAR.GetActive(area,profile)` aus `scripts/air-operations/OMW_AAR_Controller.lua`, im Test via MOOSE Receiver-Kompatibilitaet und physische Tanker-Availability eingegrenzt. MOOSE `FLIGHTGROUP:Refuel(tankerCoordinate)` ausfuehrender Mechanismus; kein Native-DCS-AAR.

- `AAR_SELECTED` `58191` (**16:09:51**): A-10, **PATTY**, physischer Tanker `OMW_AAR_KC135_PATTY#001`, Fleet-Fuel-Min `64.891946315765`, Testgrund `A10_EARLY_AAR_TEST_THRESHOLD`, Distanz Tanker `156.14 NM`. Dieser 65-%-Fruehausloeser ist **nicht** als Produktionsregel genehmigt.
- `AAR_REFUELED` `61295` (**17:01:35**): `count=1`, `fuel=98.039668798447`. Damit ist die **MOOSE-Refueled-FSM fuer die A-10-Flightgroup** belegt; die Weiterfuehrung des CAS-Auftrags **nicht**.
- Beobachtete MOOSE-Mission der A-10 ging spaeter in `done`/`success` ueber, **ohne nachgewiesenen CAS-AO-Eintritt**. Nach Betankung Richtung Kandahar, keine bestaetigte Fortsetzung nach Honaker. Untersuchung `PauseMission`, `Refueled`, `OnAfterRefueled`, `AUFTRAG`-FSM sowie Eintritts-/Logger-Semantik zwingend. **Noch keine bewiesene MOOSE-Fehlerursache**.

Jet-FuelLow: F-16 `58900` (**16:21:40**), `24.8663 %`; F-15E `63580` (**17:39:40**), `24.9334 %`. Beide meldeten `AAR_NOT_AVAILABLE reason=NO_ELIGIBLE_ACTIVE_TANKER_CLOSER_THAN_HOME` und `AAR_FALLBACK_MOOSE_RTB`. Dies beweist nur, dass die **A4-Eignungs-/Entfernungslogik** keinen Kandidaten akzeptierte, **nicht**, dass es keine Tanker in DCS gab. Automatisches 50-NM-FuelLowRefuel und FuelLowRTB waren A4-seitig deaktiviert; Adapter ruft bei erfolgloser Suche MOOSE-RTB; gepinnte FuelCritical-RTB-Semantik bleibt.

## 5. A4: Verluste, letzte Telemetrie und Debrief

**Endgueltige Bilanz: 6 gestartete CAS-Flugzeuge; 3 gelandet, 3 verloren.**

| Element | Letzte relevante A4-Telemetrie (SecondsOfToday) | Fuel-Fraktion | Hoehe ft MSL | Debrief |
|---|---|---:|---:|---|
| F-16C `AID-7-01` Lead | `60666` | `0.088796` | 4901 | auf Bagram angekommen; mindestens Bodenmessung |
| **F-16C `AID-7-02` Wingman** | **`60126`** | **`0`** | **8093** | **Ejection `t=6125.625`, Crash `t=6132.725` (Mission seit Start)** |
| A-10C `AID-70-01` | `63066` | `0.868570` | 12202 | **Crash `t=9072.277`** |
| A-10C `AID-70-02` | `63186` | `0.865751` | 13770 | **Crash `t=9190.107`** |
| F-15E `AID-6-01` | `65751` | `0` **nach Landung/Boden** | 4902 | auf Bagram gelandet, Engine Shutdown `t=11528.627` |
| F-15E `AID-6-02` | `65751` | `0.097149` | 4902 | auf Bagram gelandet, Engine Shutdown `t=11759.037` |

**Evidenzgrenzen:**
- F-16-Wingman Fuel exakt 0 bei noch erheblicher Fluggeschwindigkeit und Ejection/Crash im Debrief: starker Nachweis Fuel-bedingten Verlustes, unmittelbare aerodynamische Ursache nicht im Detail rekonstruiert. Lead kam zurueck, hatte aber geringe Reserve.
- Die A-10-Observer enden **deutlich vor** den Debrief-Crashs; Fuel um 86–87 % am **letzten Beobachtungspunkt** widerlegt nur *sofortigen* Fuel=0-Verlust zu diesem Zeitpunkt. **KEIN Schluss**, dass sie beim Crash noch 86 % hatten oder dass Terrain-Kontakt bewiesen sei. Gerade diese Telemetrie-/Event-Luecke und die MOOSE-Mission `success` vor dem physischen Verlust untersuchen.
- F-15E-Lead `fuel=0` ganz am Ende ist **nach** dem Landen/Engine-Shutdown, **kein** Crash, kein Beleg Fuel=0 im Anflug. Der Wingman hatte am Boden ca. 9.7 %. Beide F-15E-Engine-Shutdowns im Debrief: `t=11528.627` und `11759.037`, entsprechend etwa 18:12:09 und 18:15:59 Missionszeit. A4-Resultat dieser Rotte: **beide zurueck**, Fuel-Reserve problematisch; keine pauschale Aussage `Fuel-Haushalt bestanden`.
- `time=` im A4-Logger ist `SecondsOfToday` (ca. 15:00 Missionbeginn), im Debrief sind `t=` **relative Sekunden seit Missionsstart**. **Nicht direkt gleichsetzen**; Ursprung und Observer-Verlustzeitpunkt fuer Korrelation sauber abgleichen.
- `FLIGHT_OBSERVER alive=0` nach `missionState=success` kann auch nach normalem physischem Abschluss entstehen; nie ohne Debrief eine Kollision behaupten.

## 6. Erfolge, Rueckschlaege, Fehler und Schlussfolgerungen A1–A4

**Erfolgreich demonstriert (branch-/testlaufgebunden, nicht als produktive Baseline):**
- Echte MOOSE-C2-Requests, Squadron-Rekrutierung, 2-Aircraft-Dispatch fuer alle drei Muster nach Range-Konfiguration.
- Bagram-F16/F15-Holding/Join gegen aufeinanderfolgende DCS-ATC-Runway-Crossings; seit A4 ebenfalls A-10-Kandahar-Join.
- Verbesserte Terrain-Clearance im Hin-/RTB-Cruise durch MOOSE-Default-Altitude 22000 ft (nicht als universell sichere komplette Anflugroute abgenommen).
- Technische Entkopplung MissionSpeed/OrbitSpeed in A4; IAS/TAS/GS/Fuel/Hoehen-Telemetrie.
- A-10 PATTY korrekt nach OMW-Track-Policy ausgewaehlt, MOOSE-Refueled-FSM erfolgreich.
- A4 F-15E-Rotte beide sicher gelandet, aber geringer Resttreibstoff.

**Nicht bestanden bzw. noch offen:**
- A-10 nach AAR **keine nachgewiesene Rueckkehr zum CAS-Auftrag/AO**, Mission vorzeitig `success`.
- A-10 beide spaeter verloren; Crashgrund trotz hohem *fruehem* Fuel nicht bewiesen.
- Wiederholter F-16-Wingman-Verlust vor Landung mit Fuel 0 bei etwa 25%-FuelLow-RTB: weiterer Recovery-/Tanker-Policy-Fehler, Bagram-ATC-/Anflugqueue nicht ausreichend behandelt.
- A4 Tankerfilter nach Luftlinie `distanceToTanker < distanceToHome`, 500 NM, aktiver Track, Receiver-Kompatibilitaet: **keine** Reichweiten-/Zeit-/Fuel-Prognose fuer Rendezvous oder sichere Basislandung; NELSON/Fastjet-AAR im Lauf nicht erfolgt.
- `GetActive` und `OnAfterRefueled` nutzen Runtime-/FSM-Verhalten, muessen mit tatsaechlichen Signaturen/Gesamtzustand nochmals abgeglichen werden; keine neue parallele AAR-/C2-Engine.
- Festwert `A10_PRE_AO_AAR_TRIGGER_PCT=65` war nur Test; A4 hat `FuelLowRTB(false)` und `FuelLowRefuel(false)` fuer eigene Policy gesetzt: vor Adoption explizite **Lifecycle-Preservation-Pruefung**; vorherige produktive MOOSE-Entscheidungen nicht durch Harness-Logik ersetzen.
- **Keine** automatische C2-AAR-ReceiverDemand-Integration als proven behaupten; diskutiertes Ziel, noch offene Architekturentscheidung.
- Bisherige F-16/F-15E CAS-Lifecycle-Logs zeigen nicht in jedem Lauf AO-/Targeting-Nachweise; `success` allein ist keine erfolgreiche CAS-Wirkung.

## 7. Naechster Arbeitsplan, ohne vorschnelle A5-Implementierung

1. Provenienz fuer A4 vervollstaendigen (tatsaechlicher MIZ-Hash, eingebetteter Bundle-Hash, Moose.lua-Hash, Trigger-Ladereihenfolge, lokale DCS-Version) nur anhand **realer Owner-Ausgaben**. `dcs(3).log` und `debrief(3).log` als historische Rohdaten vorhalten; falls nicht repo-verfuegbar, erneuten Upload im neuen Chat verlangen, niemals erfundene Log-Korrelation.
2. A4-A-10 **AAR -> Refueled -> Mission-FSM -> RTB -> physischer Verlust** gegen tatsaechliche gepinnte MOOSE-Methoden und produktives `scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua` / `OMW_AAR_Controller.lua` korrelieren. Besonders `missionState=done/success` ohne `ELEMENT_IN_AO`, betroffene Callback- und `Refuel`-Seiteneffekte.
3. A-10-Einzelverlust anhand Debrief-`t` und Observer-`SecondsOfToday` mit physischem Tracking-/Koordinatenverlauf pruefen; pruefen, ob Observer nach Missionsabschluss aufhoert, obwohl Flugzeuge physisch weiterfliegen. Terrain-/AI-Path- oder unsichere RTB-Routen **als Hypothesen** behandeln, nicht als Fakten.
4. F-16 Recovery: Fuel-Verlauf Lead/Wingman bei AO-Ende, MOOSE FuelLow, AAR-Rejection, RTB, Bagram-ATC, Holding und Landing; pruefen, ob bereits geerbte AWACS-AAR-Logik fuer rechtzeitigere/geeignetere Fuel-Reaktion wiederverwendbar ist.
5. Architekturentscheidung mit Owner: MOOSE-/C2-AAR-Vertrag getrennt fuer **Alarm-CAS** (Response-Zeit, ausreichender On-Station-/Recovery-Fuel) und **Scheduled CAS** (wirtschaftlicher Transit, evtl. Pre-AO-PATTY). Keine pauschale Pflichtbetankung, kein erfundener Fuel-Safety-Algorithmus, keine unautorisierte Native-DCS-Ausnahme. Tankerpolicy A-10 PATTY/MILHOUSE, Fastjet NELSON plus kompatible aktive Kandidaten.
6. Erst nach Quellenabgleich kleinste MoOSe-first-Korrektur als **A5-Plan/Implementierung**; A1–A4-Artefakte unveraendert lassen, separate neue Source/Builder/CI/Acceptance, Dokumentationsindex aktualisieren; CI PASS ist kein DCS PASS.
7. Owner-PowerShell: explizit `Set-Location 'P:\DCS-DEV\Operation-Mountain-Watch-cas-ground-alert'`, `git pull --ff-only`, `git rev-parse HEAD`, separater Builder, `Get-FileHash`, reale Ausgabe. Erst dann Owner-Only ME `.miz` und DCS-Test. PR #151 bleibt **Draft**, kein Merge, kein Ready ohne ausdrueckliche Freigabe.

## 8. Unveraenderte wichtige Pfade

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/moose/ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md
docs/air-operations-fixed-wing-cas-coverage-and-ground-alert-decision.md
docs/88-air-tasking-plan-foundation.md
docs/29-isaf-2009-2013-air-to-air-refueling.md
docs/moose/AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md
scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V3.lua
scripts/air-operations/OMW_AAR_Controller.lua
mission/tests/fixed-wing-cas-response/README.md
mission/tests/fixed-wing-cas-response/ACCEPTANCE-1.md
mission/tests/fixed-wing-cas-response/ACCEPTANCE-2.md
mission/tests/fixed-wing-cas-response/ACCEPTANCE-3.md
mission/tests/fixed-wing-cas-response/ACCEPTANCE-4.md
mission/tests/fixed-wing-cas-response/src/acceptance-4-three-flight-joined-aar.lua
tools/build-fixed-wing-cas-response-acceptance-4.ps1
.github/workflows/fixed-wing-cas-response-validation.yml
docs/DOCUMENT-REGISTRY.md
docs/SUBPROJECT-REGISTRY.md
```

**Uebergabestatus:** Nur dokumentarische Reconciliation. Kein neuer Lua-Code, kein A5, keine .miz-Modifikation, kein DCS-Lauf durch ChatGPT. PR #151 bleibt Draft.
