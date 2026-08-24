---
document_id: OMW-HANDOFF-AWACS-EXTERNAL-LIFECYCLE-TODO-2026-08-24
status: PLANNED
document_class: HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - branch-local AWACS external lifecycle completion order
  - current progress and remaining work for PR 121
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: PENDING_MERGE
validated_in_dcs: false
---

# AWACS External Lifecycle – TODO und Abschlussreihenfolge

## 1. Geltungsbereich

Dieses Dokument beschreibt den aktuellen Arbeitsstand und die noch ausstehenden Schritte des Branches:

```text
agent/awacs-external-lifecycle-foundation
```

Zugehöriger Pull Request:

```text
PR #121 – Stage external AWACS lifecycle foundation
Status: Draft
```

Die Datei ist eine branch-lokale Arbeits- und Übergabereihenfolge. Sie ersetzt keine Governance auf `main` und erklärt keinen noch offenen AWACS-Produktionspfad eigenständig für validiert.

Maßgebliche Governance:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
```

Zentrale AWACS-Fachdokumente dieses Branches:

```text
docs/moose/AWACS-EXTERNAL-LIFECYCLE.md
docs/moose/AWACS-PERSISTENT-ORBIT-SENSOR-CONTROL.md
docs/moose/AWACS-FUEL-DRIVEN-AAR-LIFECYCLE.md
mission/tests/awacs-external-lifecycle/ACCEPTANCE.md
mission/tests/awacs-external-lifecycle/ACCEPTANCE-3.md
mission/tests/awacs-external-lifecycle/ACCEPTANCE-4.md
mission/tests/awacs-external-lifecycle/ACCEPTANCE-5.md
```

## 2. Zu erreichendes Ziel

Der Branch soll einen technisch belastbaren, MOOSE-first ausgeführten externen E-3A-WIZARD-Lifecycle für Operation Mountain Watch bereitstellen:

```text
strategische Quelle OFFMAP_AL_DHAFRA
-> sichtbare externe Materialisierung
-> ROSIE-Ingress
-> wirtschaftlicher Transit
-> APOC-Racetrack
-> zeitgesteuerte Sensor-/Emissionsfunktion
-> fuel-state-getriebene AAR-Bereitschaft
-> dedizierter Reserve-Tanker LISA
-> fallback auf kompatiblen aktiven Tanker
-> sichtbares AAR mit plausibler Höhe und Geschwindigkeit
-> Rejoin APOC
-> planmäßiger Service-Ende-Egress
-> ROSIE-Outbound
-> externer Handoff
-> Despawn und strategischer Recredit
```

Dabei gelten weiterhin:

```text
CampaignState = strategische Ressourcenautorität
DCS-Gruppen = temporäre physische Repräsentation
MOOSE = primäres Framework
keine parallele eigene Refuel- oder AWACS-Aufgabenlogik, wenn MOOSE den Pfad bereitstellt
keine .miz-Mutation durch ChatGPT
```

Der sichtbare AWACS dient in OMW primär als glaubwürdiger physischer AEW-/Sensor-Akteur. Der vollständige MOOSE-`AWACS`-Air-Controller mit Fighter Control, FEZ und ähnlichen Funktionen ist für diesen Scope nicht erforderlich.

## 3. Aktueller Fortschritt

### 3.1 External Routing Lifecycle

Acceptance 1 bestätigte für die exakt dokumentierte Provenienz den physischen Lifecycle:

```text
external spawn
-> ROSIE inbound
-> APOC
-> controlled egress
-> ROSIE outbound
-> external handoff
-> despawn / recredit
```

Dieser Nachweis bleibt auf seinen exakten Branch-/Commit-/MIZ-/DCS-/MOOSE-Stand begrenzt.

### 3.2 Persistenter APOC-Orbit und Sensorsteuerung

Die frühere Verwendung eines vollständigen DCS-AWACS-Mission-Task für reine Servicezustandswechsel wurde verworfen, weil Status-/Taskwechsel sichtbare Detours erzeugten.

Der aktuelle Entwurf trennt deshalb:

```text
physical orbit = persistent AUFTRAG:NewORBIT_RACETRACK(...)
service state   = emission/radar option
```

Die planmäßige Servicezeit bleibt:

```text
15:30 local / 1100Z -> service/emission active
23:30 local / 1900Z -> service off and true egress
```

Der frühere 5-NM-APOC-Gate darf die planmäßige 15:30-Aktivierung nicht mehr verzögern. Er bleibt nur für die physische Rejoin-Bestätigung nach AAR relevant.

### 3.3 Fuel-driven AAR und LISA

Der vollständige Acceptance-4-Lauf bestätigte bereits die physische MOOSE-AAR-Kette einschließlich LISA, Receiver-Refuel und Rückkehrlogik. Der Lauf zeigte zugleich zwei Orchestrierungsprobleme:

```text
1. WIZARD wartete trotz bereits vorausgeschickter LISA unnötig bis zum 40-%-Fallback.
2. LISA erhielt während eines laufenden WIZARD-Refuels bereits ihren FuelLow-Egress-Auftrag.
```

Daraus wurde die aktuelle Policy abgeleitet:

```text
65 %  -> LISA pre-dispatch
LISA ready -> WIZARD begins planned AAR immediately
40 %  -> fallback AAR trigger if planned LISA path is not ready
25 %  -> critical contingency if no established refuel path exists
```

LISA-FuelLow während eines aktiven WIZARD-Refuels soll den Tankvorgang nicht abbrechen; der LISA-Egress wird bis zum Abschluss des Receiver-Refuels zurückgestellt.

### 3.4 Acceptance 5 – E-3A Multi-Performance-Test

Acceptance 5 wurde als isolierter MOOSE-Test mit 15 gleichzeitig fliegenden E-3A ausgeführt:

```text
3 Höhen:
FL250 / FL320 / FL350

5 Sollgeschwindigkeiten:
230 / 250 / 270 / 290 / 310 KIAS

pro Profil:
20 NM Stabilisierung
200 NM Messstrecke
```

Alle 15 Flugzeuge erreichten ihren Zielpunkt. Erst nach Abschluss des jeweiligen Messsegments änderten sie Kurs beziehungsweise Höhe. Der Test endete mit `ALL_COMPLETE profiles=15`.

Die vollständige Matrix ist in `mission/tests/awacs-external-lifecycle/ACCEPTANCE-5.md` dokumentiert. Kernergebnisse:

| Höhe | IAS | avg TAS | Fuel / 100 NM | Fuel / h | Ergebnis |
|---|---:|---:|---:|---:|---|
| FL250 | 230 | 327.7 kt | 3.923 % | 12.333 % | STABLE |
| FL250 | 250 | 356.2 kt | 3.856 % | 13.221 % | STABLE |
| FL250 | 270 | 384.7 kt | 4.352 % | 16.068 % | STABLE |
| FL250 | 290 | 413.2 kt | 4.765 % | 19.057 % | STABLE |
| FL250 | 310 | 441.7 kt | 5.169 % | 22.151 % | STABLE |
| FL320 | 230 | 355.1 kt | 3.725 % | 12.710 % | STABLE |
| FL320 | 250 | 386.0 kt | 3.984 % | 14.784 % | STABLE |
| FL320 | 270 | 416.9 kt | 4.303 % | 17.308 % | STABLE |
| FL320 | 290 | 447.8 kt | 4.490 % | 19.471 % | STABLE |
| FL320 | 310 | 478.6 kt | 5.124 % | 23.798 % | STABLE |
| FL350 | 230 | 368.7 kt | 3.752 % | 13.307 % | STABLE |
| FL350 | 250 | 398.7 kt | 3.934 % | 15.144 % | STABLE |
| FL350 | 270 | 430.6 kt | 4.162 % | 17.318 % | STABLE |
| FL350 | 290 | 462.5 kt | 4.484 % | 20.049 % | STABLE |
| FL350 | 310 | 473.0 kt | 4.769 % | 21.866 % | MARGINAL |

Wichtig:

```text
14/15 profiles = STABLE
FL350 / 310 KIAS = MARGINAL
```

`FL350 / 310 KIAS` erreichte im Mittel nur etwa 296.6 KIAS und wird nicht als Produktionsprofil verwendet.

### 3.5 Aus Acceptance 5 abgeleitete Engineering-Baseline

Die anschließende Auswertung trennt gemessene DCS-Werte von operativen OMW-Entscheidungen.

Bevorzugtes normales Transitprofil:

```text
WIZARD TRANSIT
FL350 / 270 KIAS
~430.6 KTAS
~4.162 % fuel / 100 NM
```

Optionales schnelles Transitprofil:

```text
WIZARD FAST TRANSIT
FL350 / 290 KIAS
~462.5 KTAS
~4.484 % fuel / 100 NM
```

Bevorzugter APOC-Track:

```text
WIZARD ON-STATION
FL320 / 250 KIAS
~386.0 KTAS
~14.784 % fuel / h
```

Die Wahl von 250 statt 230 KIAS ist eine Engineering-Margin für Racetrack-Turns und höheren Gross-Weight-Zustand nach AAR. Acceptance 5 war ein Geradeaus-Test und beweist keine Stall- oder Turn-Margin.

### 3.6 AAR-Höhe und Geschwindigkeiten

Receiver-spezifische externe E-3-AAR-Evidenz nennt für E-3A/D/F einen Optimum-AAR-Wert in der Größenordnung:

```text
FL250 / 275 KIAS / M0.66
```

Der ebenfalls dokumentierte 310-KIAS-Rendezvouswert wird für OMW nicht blind übernommen. Acceptance 5 zeigt zwar, dass `FL250 / 310 KIAS` in DCS stabil erreichbar ist, OMW soll die E-3 jedoch nicht unnötig nahe am oberen Leistungsbereich betreiben.

Branch-lokale Engineering-Baseline:

```text
LISA AAR track / contact:
FL250 / 270 KIAS

WIZARD rendezvous:
FL250 / 290 KIAS

closure margin:
+20 KIAS

near contact:
290 -> 270 KIAS
```

Damit liegen beide verwendeten Profile innerhalb der tatsächlich in Acceptance 5 als `STABLE` gemessenen E-3-Zustände.

### 3.7 Reserve-/Critical-Fuel-Diskussion

Acceptance 5 misst für `FL350 / 270 KIAS`:

```text
17.318 % fuel / h
4.162 % fuel / 100 NM
```

Eine rein rechnerische 45-Minuten-Reserve entspräche damit unter denselben stabilisierten Testbedingungen ungefähr:

```text
~13.0 % fuel
```

Für eine operative Bingo-/Recovery-Grenze reicht dieser Wert allein nicht. Zusätzlich zu berücksichtigen sind mindestens:

```text
fuel to recovery / external handoff
climb and acceleration
routing / diversion allowance
45 min final reserve
minimum landing fuel / operational landing margin
```

Die bisherige `25 %` Critical-Grenze wird deshalb nicht nach unten gesetzt. Eine konkrete E-3A-Bingo-Formel ist noch nicht als reale Handbuchvorgabe verifiziert. Die erinnerte Tanker-Policy mit 45-Minuten-Reserve und Mindestlandemenge muss gegen die zuständige OMW-Tanker-Dokumentation beziehungsweise belastbare Primärquelle reconciliert werden.

## 4. Aktueller Code-Stand – wichtige Abweichung zur neuen Baseline

Der produktive branch-lokale Controller ist noch **nicht** auf die Acceptance-5-Ergebnisse umgestellt.

In `scripts/air-operations/OMW_AWACS_Controller_FullLifecycle_V2.lua` stehen derzeit noch unter anderem:

```text
WIZARD track:          FL320 / 300 kt
WIZARD transit:        FL350 / 440 kt target
WIZARD spawn speed:    440 kt
LISA AAR track:        FL320 / 300 kt
LISA transit:          300 kt
```

Diese Werte sind damit teilweise historischer Zwischenstand und müssen vor Abschluss des Branches gegen die neue dokumentierte Engineering-Baseline reconciliert werden.

## 5. Noch zu erledigende Schritte

### Stage A – Acceptance-5-Provenienz abschließen

- [ ] Reale SHA-256 der erfolgreich ausgeführten Acceptance-5-`.miz` erfassen.
- [ ] SHA-256 der internen `mission`-Datei dieser `.miz` erfassen.
- [ ] DCS-Version des erfolgreichen Acceptance-5-Laufs explizit in die Provenienz übernehmen.
- [ ] Bundle-SHA, MOOSE-SHA, Branch und Commit des tatsächlich ausgeführten Laufs vollständig gegen das Acceptance-Dokument abgleichen.
- [ ] Erst bei vollständiger Provenienz den zulässigen Acceptance-Status gemäß Governance neu bewerten; keinen Status erfinden.

### Stage B – Flugprofil in die Runtime übernehmen

- [ ] WIZARD normalen Transit von der bisherigen 440-kt-Zwischenbaseline auf `FL350 / 270 KIAS` umstellen.
- [ ] `FL350 / 290 KIAS` nur als klar benanntes optionales Fast-Transit-Profil vorsehen, falls dafür ein konkreter Runtime-Bedarf besteht; nicht automatisch überall verwenden.
- [ ] APOC-Racetrack auf `FL320 / 250 KIAS` umstellen.
- [ ] Spawn-/Initial-Speed so reconciliieren, dass der externe Spawn ohne sichtbaren unnötigen Beschleunigungs- oder Verzögerungssprung in das neue Transitprofil eintritt.
- [ ] Egress/Return-Transit auf dieselbe neue Normal-Transit-Baseline bringen, sofern keine separate belastbare Egress-Anforderung dagegen spricht.

### Stage C – LISA/AAR-Profil umstellen

- [ ] LISA dedicated AWACS AAR track von `FL320 / 300 kt` auf `FL250 / 270 KIAS` umstellen.
- [ ] LISA Ingress so gestalten, dass der Tanker vor `LISA_READY` tatsächlich auf FL250 und dem geplanten AAR-Speed stabilisiert ist.
- [ ] WIZARD AAR-Rendezvous auf `FL250 / 290 KIAS` mit anschließendem Übergang auf `270 KIAS` für Join/Contact auslegen.
- [ ] Vor Implementierung erneut im gepinnten MOOSE-Source prüfen, wie weit `FLIGHTGROUP:Refuel(...)` beziehungsweise der DCS-Refuel-Task Receiver-Anfluggeschwindigkeit und Höhenprofil selbst steuert.
- [ ] Falls MOOSE den gewünschten RV-Speed nicht direkt parametrisiert, zuerst prüfen, ob der gewünschte Zustand mit MOOSE-Waypoints/AUFTRAG-Konfiguration vor dem eigentlichen `Refuel(...)` hergestellt werden kann.
- [ ] Keine eigene Native-DCS-Refuel-Task-Parallelimplementierung ohne dokumentierte MOOSE-Lücke und ausdrückliche Owner-Freigabe.
- [ ] `LISA_READY`-Gate auf die neue FL250-AAR-Höhe und passende Toleranzen reconciliieren.

### Stage D – Fuel-/Bingo-Policy fachlich abschließen

- [ ] Zuständige OMW-Tanker-Dokumentation gezielt auf die verwendete Reserve-/Bingo-Systematik prüfen.
- [ ] Klären, ob die Tanker-Baseline tatsächlich `45 min final reserve + diversion allowance + minimum landing fuel` vorsieht und welchen Evidenzstatus sie besitzt.
- [ ] Dieselbe Systematik soweit fachlich passend auf WIZARD übertragen, ohne unbelegte Herstellerwerte zu behaupten.
- [ ] `65 % / 40 % / 25 %` danach erneut bewerten.
- [ ] Bis zu diesem Abgleich `25 % critical` nicht nach unten setzen.
- [ ] Sichtbaren DCS-Recovery-Fuel und den nicht physisch dargestellten strategischen Restflug nach Al Dhafra sauber getrennt halten.

### Stage E – Controller, Builder und Dokumentation reconciliieren

- [ ] `OMW_AWACS_Controller_FullLifecycle_V2.lua` auf die endgültigen Parameter aktualisieren.
- [ ] `OMW_AirOps_AWACS_Bootstrap.lua` nur ändern, falls die Controller-Schnittstelle dies tatsächlich benötigt.
- [ ] `tools/build-awacs-foundation.ps1` auf neue Builder-/Profilmetadaten aktualisieren.
- [ ] Acceptance-/MOOSE-Dokumente auf exakt dieselben Werte bringen.
- [ ] Alte Zwischenwerte `300 kt track`, `440 kt transit`, `FL320 LISA` in aktuellen nicht-historischen Abschnitten entfernen oder ausdrücklich als superseded kennzeichnen.
- [ ] `docs/moose/PROJECT-CLASS-INDEX.md` und `docs/moose/VERIFIED-METHODS.md` nur in dem Umfang aktualisieren, den reale DCS-Evidenz tatsächlich bestätigt.

### Stage F – statische Prüfung und Build

- [ ] Lua-5.1-Syntax aller geänderten AWACS-Quellen prüfen.
- [ ] Foundation-Bundle neu bauen.
- [ ] Acceptance-Bundle für den abschließenden Full-Lifecycle-Test neu bauen.
- [ ] UTF-8 ohne BOM für generierte DCS-Lua sicherstellen.
- [ ] vollständigen Diff prüfen.
- [ ] Dokumentationsvalidator ausführen und neue AWACS-bedingte Fehler beseitigen; bereits bestehende unabhängige Repositoryfehler getrennt dokumentieren.
- [ ] GitHub Actions für AWACS-Build/Syntax prüfen.

### Stage G – finaler DCS Full-Lifecycle Acceptance

Ein weiterer DCS-Lauf soll nur noch den **integrierten finalen Lifecycle** prüfen, nicht erneut einzelne Geschwindigkeiten erforschen.

Mindestens zu beobachten/protokollieren:

```text
WIZARD visible spawn
-> stable FL350 / 270 KIAS transit
-> ROSIE inbound
-> controlled transition to FL320 / 250 KIAS APOC racetrack
-> no status-change detours
-> 15:30 local sensor/emission activation without positional delay
-> LISA pre-dispatch at the intended fuel state
-> LISA established FL250 / 270 KIAS
-> WIZARD leaves APOC and reaches AAR geometry without excessive chase
-> receiver refuel succeeds
-> LISA FuelLow does not cancel an active WIZARD refuel
-> WIZARD rejoin APOC
-> sensor reactivation only after physical rejoin
-> 23:30 local service shutdown
-> controlled ROSIE outbound
-> external handoff / despawn / strategic recredit
```

Zusätzlich:

```text
fallback tanker path if LISA unavailable
critical 25-% contingency behavior
no arbitrary Afghan RTB
no observable task-change detour
no duplicate strategic debit/recredit
```

Nicht jeder negative Fallback muss künstlich in denselben langen Lauf injiziert werden, wenn dafür bereits belastbare getrennte Evidenz existiert. Der finale Acceptance-Plan muss vor Testbeginn festlegen, welche Gates zwingend in einem Lauf und welche über vorhandene Provenienz abgedeckt werden.

### Stage H – Abschluss und Merge-Vorbereitung

- [ ] Reale DCS-Logs und alle Hashes dokumentieren.
- [ ] Acceptance-Status ausschließlich nach vollständiger Provenienz setzen.
- [ ] AWACS-Fach- und MOOSE-Dokumentation final reconciliieren.
- [ ] PR #121 Beschreibung auf den realen Endstand aktualisieren.
- [ ] PR-Diff vollständig prüfen.
- [ ] `docs/SUBPROJECT-REGISTRY.md` mit PR #121 und seinem realen Endstatus abgleichen.
- [ ] PR bleibt Draft, bis der Projektinhaber ausdrücklich Ready for Review freigibt.
- [ ] Kein Merge ohne ausdrückliche Owner-Freigabe.

## 6. Aktuelle Prioritätsreihenfolge

Die nächsten Arbeiten erfolgen in dieser Reihenfolge:

```text
1. Acceptance-5-Provenienz vervollständigen
2. MOOSE-Source-Review für RV-/Refuel-Speed-Steuerung
3. WIZARD/LISA Runtime auf neue Profile umstellen
4. Fuel-/Bingo-Policy gegen Tanker-Baseline reconciliieren
5. Builder + Dokumentation aktualisieren
6. Syntax / Build / Diff / Documentation CI
7. ein finaler integrierter DCS-Full-Lifecycle-Test
8. Acceptance-Dokumentation und PR-Reconciliation
9. Owner-Freigabe für Ready for Review
10. erst danach Merge
```

## 7. Entscheidungsgrenzen

Bereits festgelegt beziehungsweise aus realer DCS-Evidenz als Engineering-Baseline abgeleitet:

```text
normal transit: FL350 / 270 KIAS
fast transit candidate: FL350 / 290 KIAS
APOC track: FL320 / 250 KIAS
LISA AAR: FL250 / 270 KIAS
WIZARD RV target: FL250 / 290 KIAS
planned closure margin: +20 KIAS
25 % critical fuel is not to be reduced before reserve reconciliation
```

Noch nicht stillschweigend zu entscheiden:

```text
exact final Bingo formula
exact minimum landing fuel
whether 45-minute reserve is binding AWACS policy or only inherited tanker practice
whether MOOSE/DCS receiver-task semantics require a different RV implementation
whether the optional fast-transit profile is needed in production
final PR Ready/Merge status
```

Diese Punkte benötigen entweder weitere Quellen-/MOOSE-Prüfung oder eine ausdrückliche Entscheidung des Projektinhabers.
