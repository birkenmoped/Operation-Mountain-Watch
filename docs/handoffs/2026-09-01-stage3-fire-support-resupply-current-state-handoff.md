---
document_id: OMW-HANDOFF-STAGE3-FIRE-SUPPORT-RESUPPLY-CURRENT-STATE-2026-09-01
status: PLANNED
document_class: DEVELOPMENT_STATUS_AND_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local current status of Stage 3 Honaker/Wright/Jalalabad full-response work
  - exact Build 1-12 local provenance supplied by the project owner
  - latest DCS failure boundary and next MOOSE-first correction target
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-alarm-evidence
source_commit: PENDING_MERGE
validated_in_dcs: false
base_branch: agent/fire-support-strategic-resupply-closure
base_commit: 40051fa657dd2df22352532e1f5bcdf37d17f846
main_checked_commit: 6c9b5530c5524f109e7def739bd2d01e2aa4efc6
pull_request: 144
---

# Stage 3 Fire Support / Strategic Resupply – aktueller Projektstatus 2026-09-01

## 1. Arbeitsstand

Aktiver Branch:

```text
agent/fire-support-strategic-resupply-alarm-evidence
```

Branch-HEAD vor dieser Statusdokumentation:

```text
203b49e061340b4629bb5e1e3b49f860320d419e
```

Aktuell geprüfter `main`-Stand:

```text
6c9b5530c5524f109e7def739bd2d01e2aa4efc6
```

Pull Request:

```text
#144
state: OPEN
mode: DRAFT
base: agent/fire-support-strategic-resupply-closure
head: agent/fire-support-strategic-resupply-alarm-evidence
```

Der Branch ist nicht als Stage-3-Baseline akzeptiert und darf nicht als DCS-validiert bezeichnet werden.

## 2. Verbindliche Arbeitsgrundlage

Vor weiterer Entwicklung gelten mindestens:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
```

Operation Mountain Watch bleibt MOOSE-first. Vor einer weiteren Guard-Korrektur sind passende MOOSE-Dokumentation, der tatsächlich gepinnte Source, Signaturen und vorhandene Framework-Wege zu prüfen. Keine weitere Objektart darf aus einem Namensschema erraten werden.

Gepinnter MOOSE-Stand:

```text
MOOSE release: 2.9.18
MOOSE commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

## 3. Build 1-10 – historischer FAIL und bereits bekannte Teilnachweise

Der reale Build-1-10-DCS-Lauf bleibt FAIL. Er hat Teilpfade wie Wright-ARTY, M1083-Rearm, CampaignState-Wright-AMMO 16 -> 15 und den Reorder-Schwellwert 15/30 erreicht, aber den Gesamtverbund nicht validiert.

Zu den damals festgestellten Problemen gehörten insbesondere CAS-Flugprofil/Lifecycle, Guard/QRF-Baseline und der fehlerhafte RESUPPLY-Dedupe-Assertion-Pfad.

Historische Evidenz bleibt unverändert in:

```text
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-09-01-CAS-QRF-RESUPPLY.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-08-31-EXECUTION-GAPS.md
```

## 4. Owner-freigegebene Build-1-11-Korrekturen

Der Projektinhaber hat die folgenden Korrekturen freigegeben:

```text
1. CAS-Lifecycle über native MOOSE MissionIngress/MissionEgress.
2. PATROLZONE + SetEngageDetected statt CASENHANCED für den Acceptance-Pfad.
3. nur ein Höhensteuerungspfad.
4. missionUID-gebundener owner-authored Helicopter Corridor.
5. PATHLINE-Suffixvertrag _R<number> / _L<number> / kein Suffix = Centerline.
6. Guard soll die owner-authored Route verwenden.
7. QRF auf die vom Projektinhaber bestimmte reale Zusammensetzung bringen.
8. RESUPPLY-Dedupe semantisch statt Lua-Tabellenidentität prüfen.
9. erst danach erneuter Gesamt-DCS-Test.
```

Die CAS-/Corridor-/Dedupe-Korrekturen bleiben bis zu einem realen erfolgreichen DCS-Lauf `DCS_PENDING`.

## 5. Aktueller QRF-Vertrag – Entscheidung des Projektinhabers

Die frühere Annahme einer separaten 9-Mann-Infanteriegruppe plus zusätzlicher Fahrzeuggruppe wurde verworfen.

Verbindlicher Stage-3-QRF-Vertrag ist jetzt:

```text
Template: TPL_BLUE_GND_QRF_MIXED_6
Composition: 5 infantry + 1 MRAP
DCS/MOOSE representation: one GROUP
Embark/Disembark: not used
Personnel debit: 5 GROUND_PERSONNEL
```

Nicht mehr Teil des Stage-3-Sollvertrags:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
TPL_BLUE_GND_QRF_MIXED_4
separate infantry mission + separate vehicle mission
embark/disembark lifecycle
```

Der Projektinhaber hat ausdrücklich `1 x MRAP + 5 x Infanterie` und `keine Embark/Disembark` entschieden.

## 6. Build 1-12 – reale lokale Build-Provenienz

Der Projektinhaber führte den korrigierten Build am 01.09.2026 lokal aus.

Worktree:

```text
P:\DCS-DEV\Operation-Mountain-Watch-fire-support-strategic-resupply
```

Verifizierter HEAD:

```text
203b49e061340b4629bb5e1e3b49f860320d419e
```

Builder:

```text
tools\build-stage3-honaker-wright-full-response-acceptance-1-12.ps1
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1-12
```

Erzeugtes Bundle:

```text
mission\tests\stage3-honaker-wright-full-response\dist\OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_1.lua
```

Reale lokale Ausgabe:

```text
QRFTemplate: TPL_BLUE_GND_QRF_MIXED_6
QRFComposition: 5 infantry + 1 MRAP in one DCS/MOOSE GROUP
QRFEmbarkDisembark: false
QRFPersonnelDebit: 5 GROUND_PERSONNEL
SHA256: 62C31BFCF877F97C2F3FDECE57A2AF0C596B56F9343FF5DB9B9F6F50F7360826
MizMutation: false
```

Der unmittelbar vorherige Versuch war kein Build-1-12-PASS: der Wrapper erzeugte erst das alte Build-1-11-Bundle und brach anschließend an einem fehlerhaften String-Transform-Marker ab. Dieser Versuch und sein Hash `F332BB72...` sind keine gültige Build-1-12-Provenienz.

## 7. Wichtiger Builder-/Source-Zustand

Build 1-12 wurde als nachgelagerter Transform-Builder auf Basis des Build-1-11-Bundles erzeugt. Dieser Weg diente der unmittelbaren Korrektur des QRF-Vertrags, ist aber nicht die gewünschte dauerhafte Source-Struktur.

Vor dem nächsten regulären Builderstand ist zu normalisieren:

```text
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua
-> muss selbst den aktuellen QRF-Vertrag enthalten

standard Stage-3 builder
-> soll deterministisch aus aktueller Source bauen
-> keine fortgesetzte Patch-Kaskade über bereits gebaute Bundles
```

Die Source-Datei ist wieder die technische Wahrheit; Wrapper-Transforms dürfen nicht die produktive Entwicklungsrichtung ersetzen.

## 8. Aktueller realer DCS-Lauf nach Build 1-12

DCS-Version laut realem Log:

```text
DCS/2.9.29.27278 (x86_64; MT; Windows NT 10.0.26200)
```

Ausgeführte Mission:

```text
C:\Users\Sven\Saved Games\DCS.openbeta\Missions\OMW_Template_v21_GroundWorks.miz
```

Der Lauf hat den QRF-Templatefehler des vorherigen Tests beseitigt. MOOSE registrierte:

```text
Register Group: TPL_BLUE_GND_QRF_MIXED_6
Register Unit: TPL_BLUE_GND_QRF_MIXED_6_01
...
Register Unit: TPL_BLUE_GND_QRF_MIXED_6_06
```

Damit ist nachgewiesen, dass das neue Template im getesteten Missionsstand als GROUP mit sechs DCS-Units vorhanden und für MOOSE sichtbar war. Der Lauf validiert noch nicht die QRF-Ausführung oder ihre taktische Wirkung.

## 9. Aktueller Blocker: Guard-Objektart falsch implementiert

Der Stage-3-Lauf scheiterte früh mit:

```text
[STAGE 3][FAIL] missing OMW_RTE_BLUE_GUARD_HONAKER_01
```

Das bedeutet nicht, dass die Route in der Mission fehlt.

Im selben realen DCS-Log registriert MOOSE:

```text
Register PATHLINE: OMW_RTE_BLUE_GUARD_HONAKER_01 (Line drawing with 13 points)
```

Zusätzlich werden die übrigen Guard-Routen nach demselben Muster als PATHLINE registriert, unter anderem Joyce, Wright, Bostick, Fenty und Fortress.

Der Stage-3-Code behandelt `OMW_RTE_BLUE_GUARD_HONAKER_01` aktuell dagegen als GROUP und sucht sie mit einem GROUP-Lookup. Das ist die konkrete Ursache des aktuellen FAIL.

Fehlerhafte Annahme:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01 == GROUP
```

Tatsächlich beobachtet:

```text
OMW_RTE_BLUE_GUARD_HONAKER_01 == MOOSE PATHLINE
```

Damit war auch die bisher dokumentierte direkte Verwendung von `GROUP:PatrolRoute()` für genau dieses Objekt technisch falsch abgeleitet.

## 10. MOOSE-first-Fundstelle für den Guard-Fix

Der gepinnte `Moose.lua` dokumentiert ausdrücklich:

```text
Mission-Editor line drawings are automatically registered as PATHLINEs.
PATHLINE:FindByName(...)
PATHLINE:GetCoordinates()
```

Der nächste Guard-Fix darf deshalb nicht wieder eine gleichnamige GROUP voraussetzen.

Zwingender Prüfweg vor Implementierung:

```text
1. reale physische Guard-GROUP/Template-Quelle im aktuellen Ground-/ORBAT-/ME-Vertrag bestimmen
2. OMW_RTE_BLUE_GUARD_HONAKER_01 mit PATHLINE:FindByName(...) auflösen
3. PATHLINE:GetCoordinates() verwenden
4. gegen gepinnte Moose.lua prüfen, welcher öffentliche Ground-Routingweg die vorhandene physische Guard-GROUP entlang dieser Koordinaten routet
5. vorhandene MOOSE-Waypoint-/OPSGROUP-/ARMYGROUP-/GROUP-Mechanismen priorisieren
6. keine Native-DCS-/Parallelsteuerung ohne dokumentierte Lücke und neue Eigentümerfreigabe
7. erst danach Build 1-13 oder entsprechend nächsten regulären Builderstand erstellen
```

`OPSGROUP:Route(waypoints, delay)` ist im gepinnten Source vorhanden, ist aber noch nicht allein deshalb als endgültige Guard-Lösung beschlossen. Zuerst muss die korrekte physische Guard-Entität und der passendste öffentliche MOOSE-Pfad aus dem Projektstand bestimmt werden.

## 11. Aktueller Teststatus der Teilketten

```text
QRF template availability            CONFIRMED in current DCS log
QRF deployment/engagement            NOT TESTED in Build-1-12 run because preflight failed earlier
Guard PATHLINE availability           CONFIRMED in current DCS log
Guard physical patrol                 NOT TESTED; current code uses wrong object type
CAS PATROLZONE dispatch               NOT TESTED in Build-1-12 run
CAS corridor R500 -> WEST             NOT TESTED in Build-1-12 run
CAS weapon employment                 NOT TESTED in Build-1-12 run
Wright ARTY                           not revalidated by this run
M1083 local rearm                     not revalidated by this run
RESUPPLY semantic dedupe              not reached in this run
CH-47 CARGOTRANSPORT                  not reached in this run
Combined Stage-3 result               FAIL / validated_in_dcs=false
```

Frühere Teilnachweise bleiben nur für ihre exakt dokumentierte Provenienz gültig und werden durch diesen kurzen Preflight-FAIL weder erweitert noch aufgehoben.

## 12. Aktuelle Mission-Editor-Fakten aus dem realen Log

Im getesteten Missionsstand waren für MOOSE sichtbar:

```text
TPL_BLUE_GND_QRF_MIXED_6             GROUP, six registered units
OMW_FlightPath_R500                  PATHLINE, 84 points
OMW_FlightPath_WEST                  PATHLINE, 34 points
OMW_RTE_BLUE_GUARD_HONAKER_01        PATHLINE, 13 points
```

Die aktuelle Mission-Datei selbst konnte in der Chat-Laufzeit wegen eines Attachment-/Runtime-Mount-Problems nicht direkt als ZIP geöffnet werden. Das ist eine Werkzeug-/Sitzungsgrenze und kein nachgewiesener Fehler der `.miz`. Die oben genannten Fakten stammen aus dem realen DCS-/MOOSE-Log des ausgeführten Missionsstands.

## 13. Bekannte Fehler in der bisherigen Bearbeitung

Für die Fortsetzung ausdrücklich festhalten:

```text
- QRF-Zusammensetzung wurde zuvor aus Annahmen statt aus dem owner-approved Template-Vertrag abgeleitet.
- OMW_RTE_BLUE_GUARD_HONAKER_01 wurde aus dem Namen fälschlich als GROUP statt als PATHLINE behandelt.
- Build 1-12 wurde zunächst mit einem unzureichend geprüften String-Transform-Wrapper gebaut; der erste lokale Versuch schlug deshalb nach dem alten 1-11-Build fehl.
```

Arbeitskorrektur für weitere Schritte:

```text
Mission-/Template-Objektart zuerst verifizieren
-> gepinnte MOOSE-Repräsentation und Methode prüfen
-> Source direkt korrigieren
-> deterministischen Builder prüfen
-> erst danach lokalen Build anfordern
-> erst nach realem Hash neuen DCS-Test durchführen
```

## 14. Unmittelbar nächster zulässiger Arbeitsschritt

Noch keinen neuen DCS-Test anfordern.

Zuerst:

```text
A. aktuellen Branch gegen main und zuständige Ground-/Guard-Baselines prüfen
B. physische Honaker-Guard-GROUP beziehungsweise ihr Template eindeutig bestimmen
C. PATHLINE-zu-Ground-Route ausschließlich MOOSE-first entwerfen
D. aktuelle Stage-3-Source auf QRF_MIXED_6 normalisieren
E. Builder auf direkte Source-Erzeugung normalisieren
F. Acceptance-Dokument und relevante MOOSE-Dokumentation auf den tatsächlichen PATHLINE-Vertrag korrigieren
G. Diff / verfügbare Tests / Dokumentation prüfen
H. Commit + Remote-Push
I. erst dann neuer lokaler PowerShell-Build und realer SHA-256
J. erst nach bestätigtem Bundle nächster DCS-Lauf
```

## 15. Nicht verändern / nicht behaupten

Bis zum nächsten dokumentierten DCS-Lauf gilt:

```text
- kein Stage-3-PASS
- kein VALIDATED für Guard, neue QRF-Ausführung oder PATROLZONE-CAS
- keine Behauptung, dass AH-64D-Hellfire-/Standoff-Verhalten gelöst ist
- keine Behauptung, dass strategischer CH-47-Resupply im aktuellen Stand funktioniert
- keine neue Native-DCS-Guardsteuerung ohne MOOSE-Lückenprüfung und Eigentümerfreigabe
- keine erfundenen Mission-/Bundle-/MOOSE-Hashes
```

## 16. Relevante Dateien

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md

docs/moose/STAGE3-BUILD-1-11-RECONCILIATION.md
docs/moose/STAGE3-CAS-GUARD-QRF-ROUTING-AUDIT.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/stage3-honaker-wright-full-response/ACCEPTANCE-1.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-09-01-CAS-QRF-RESUPPLY.md
mission/tests/stage3-honaker-wright-full-response/FAIL-2026-08-31-EXECUTION-GAPS.md
mission/tests/stage3-honaker-wright-full-response/src/01-honaker-wright-full-response-acceptance.lua

tools/build-stage3-honaker-wright-full-response-acceptance-1.ps1
tools/build-stage3-honaker-wright-full-response-acceptance-1-12.ps1
```

Dieses Dokument ist ein branch-lokaler Status-/Übergabenachweis. Es ersetzt keine repositoryweite Governance und keine DCS-Acceptance.