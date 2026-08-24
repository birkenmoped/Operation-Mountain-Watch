---
document_id: OMW-AWACS-ACCEPTANCE-5
status: DRAFT
document_class: ACCEPTANCE_PLAN
owning_policy: OMW-GOV-001
authoritative_for:
  - E-3A DCS performance matrix test
  - AWACS altitude and IAS fuel-consumption evidence
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: agent/awacs-external-lifecycle-foundation
source_commit: GIT_HISTORY
supersedes:
superseded_by:
validated_in_dcs: true
---

# AWACS Acceptance 5 – E-3A Performance Matrix

## Ziel

Der Test ermittelt in einem einzigen DCS-Lauf die tatsächlich erreichbare Geschwindigkeit und den relativen Treibstoffverbrauch des DCS-E-3A-Modells bei drei für OMW relevanten Höhen und fünf IAS-Sollwerten. Er dient ausschließlich zur Auswahl belastbarer Engineering-Werte für Transit, On-Station und AAR-Rendezvous. Er ändert keine Produktionsbaseline.

## Testmatrix

```text
              230 KIAS  250 KIAS  270 KIAS  290 KIAS  310 KIAS
FL250            X         X         X         X         X
FL320            X         X         X         X         X
FL350            X         X         X         X         X
```

Insgesamt werden 15 E-3A gleichzeitig aus dem bestehenden Late-Activation-Template `OMW_C2_E3A_WIZARD` erzeugt.

## Geometrie

Die komplette Geometrie wird vom Testskript mit MOOSE erzeugt. Im Mission Editor sind keine Marker, Zonen, Routen oder 15 Einzeltrigger anzulegen.

```text
Reference: 30.10 N / 61.85 E
Heading: 090 true
Lane spacing: 12 NM
Stabilization leg: 20 NM
Measurement leg: 200 NM
```

Die fünf Geschwindigkeits-Lanes werden seitlich versetzt erzeugt. Die drei Höhenblöcke verwenden dieselbe horizontale Lane-Geometrie und sind vertikal getrennt.

## Namen

```text
OMW_TEST_E3_FL250_IAS230 ... OMW_TEST_E3_FL250_IAS310
OMW_TEST_E3_FL320_IAS230 ... OMW_TEST_E3_FL320_IAS310
OMW_TEST_E3_FL350_IAS230 ... OMW_TEST_E3_FL350_IAS310
```

MOOSE ergänzt beim tatsächlichen Spawn seinen normalen Runtime-Suffix. Die logische Test-ID bleibt in jeder Telemetriezeile vollständig erhalten.

## MOOSE-First

Verwendet werden ausschließlich verifizierte MOOSE-Abstraktionen für den physischen Test:

```text
SPAWN:NewWithAlias(...)
SPAWN:InitHeading(...)
SPAWN:InitSpeedKnots(...)
SPAWN:SpawnFromCoordinate(...)
FLIGHTGROUP:New(...)
FLIGHTGROUP:AddWaypoint(...)
FLIGHTGROUP:GetFuelMin()
FLIGHTGROUP:GetAltitude()
POSITIONABLE:GetAirspeedIndicated()
POSITIONABLE:GetAirspeedTrue()
COORDINATE:NewFromLLDD(...)
COORDINATE:Translate(...)
UTILS.IasToTas(...)
SCHEDULER:New(...)
```

`FLIGHTGROUP:AddWaypoint()` übernimmt im gepinnten MOOSE-Source einen Speed-Wert in knots und erzeugt daraus den DCS-Air-Waypoint. Für die Testmatrix wird der gewünschte KIAS-Wert deshalb vorher mit `UTILS.IasToTas()` auf die jeweilige Testhöhe umgerechnet. Die tatsächlich geflogene IAS wird anschließend unabhängig mit `POSITIONABLE:GetAirspeedIndicated()` beobachtet.

Es gibt keine Native-DCS-Routenlogik, keine `trigger.action`-Marker und keine eigenen World-Scans.

## Fuel-Normalisierung

Das Testskript verändert den Template-Fuelwert nicht. Alle 15 Spawns erben denselben Fuelstand aus `OMW_C2_E3A_WIZARD`. Für den vorgesehenen Teststand ist dies der aktuelle WIZARD-Templatewert von ungefähr 77 Prozent beziehungsweise rund 50.050 kg. Damit wird der für den sichtbaren Produktionseintritt relevante Gross-Weight-Bereich untersucht.

Fuel wird im Test nur über den im gepinnten MOOSE-Stand vorhandenen `FLIGHTGROUP:GetFuelMin()`-Prozentwert ausgewertet. Nicht verifizierte Methoden wie `GetCurrentFuelKgs()` oder `GetFuelMassMax()` werden ausdrücklich nicht verwendet.

## Messung

Jeder Flug erhält zunächst 20 NM zur Stabilisierung. Erst am Messstart wird Fuel und Zeit erfasst. Anschließend folgt die 200-NM-Messstrecke.

Während der Messung wird alle 30 Sekunden protokolliert:

```text
testId
targetAltFt
targetIASKt
actualAltFt
actualIASKt
actualTASKt
fuelPct
distanceToEndNm
```

Am Ende wird pro Profil eine `SUMMARY`-Zeile ausgegeben mit:

```text
elapsedSec
sample count
average altitude
average IAS
average TAS
maximum IAS error
fuel start/end/burn percent
fuel burn percent per 100 NM
fuel burn percent per hour
classification
```

## Klassifikation

Die Klassifikation ist eine OMW-Testdefinition und kein Herstellerlimit:

```text
STABLE:
>=90 percent der Messsamples innerhalb +/-5 KIAS vom Soll

UNSUSTAINABLE:
>=20 percent der Messsamples mehr als 15 KIAS vom Soll entfernt

MARGINAL:
alle übrigen Fälle
```

Die Fuelwerte dürfen nur zwischen Profilen verglichen werden, die den Lauf physisch vollständig absolvieren und deren Flugverhalten plausibel bleibt.

## DCS-Ablauf

Für den Test muss in der Test-MIZ nur Folgendes vorhanden sein:

```text
Moose.lua
Late-Activation template OMW_C2_E3A_WIZARD
OMW_AWACS_Acceptance_5.lua
```

Acceptance 5 startet sich selbst. Es werden keine Produktions-AWACS-Foundation, kein AAR-Controller, keine AWACS-Aufgabe, kein CampaignState und keine weiteren Acceptance-Skripte für diesen isolierten Performance-Lauf benötigt.

## DCS-Versuch 2026-08-24 – erster Start nicht auswertbar

Der erste reale DCS-Start von Acceptance 5 erzeugte keine Performance-Evidenz. DCS brach das Laden des generierten Bundles unmittelbar in Zeile 1 ab:

```text
Mission script error: [string "l10n/DEFAULT/OMW_AWACS_Acceptance_5.lua"]:1: unexpected symbol near ''
```

Die hochgeladene Test-MIZ bestätigte als Ursache ein UTF-8-BOM `EF BB BF` vor dem ersten Lua-Kommentar des generierten Bundles. Der Builder verwendete `Set-Content -Encoding UTF8`; Windows PowerShell 5.1 schreibt dabei ein BOM, während PowerShell 7+ standardmäßig BOM-freies UTF-8 erzeugt. Dadurch konnte der Linux-/PowerShell-7-CI-Lauf das Windows-spezifische Artefakt nicht reproduzieren.

Der Builder wurde deshalb auf explizites `System.Text.UTF8Encoding(false)` umgestellt und prüft das generierte Bundle zusätzlich binär auf ein unerwartetes BOM. Dieser Versuch ist ausdrücklich **kein DCS-PASS und kein Performance-Ergebnis**; die 15 Profile wurden nicht gestartet.

## DCS-Versuch 2026-08-24 – vollständiger Multi-Test

Der zweite Lauf verwendete das BOM-freie Acceptance-5-Bundle.

```text
Branch:                  agent/awacs-external-lifecycle-foundation
Runtime source HEAD:     9a3738a2f974d2e895249b69359e17684cc0660e
Acceptance-5 bundle SHA: 0faf6503a5ef465b8cd613049065c6389cca58bd4cc0b4f0ecb8b243c88a6c60
Moose.lua SHA-256:       e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
MOOSE commit:            73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
DCS:                     2.9.28.26385 MT
Profiles:                15
Stabilization:           20 NM
Measurement:             200 NM per profile
Result marker:           ALL_COMPLETE profiles=15
```

MIZ-SHA256 und internal-mission-SHA256 für diesen zweiten Lauf liegen noch nicht als reale Konsolenausgabe vor. Deshalb bleibt das Dokument trotz erfolgreichem DCS-Lauf `DRAFT` und wird noch nicht zu `ACCEPTED_TECHNICAL_BASELINE` hochgestuft.

Der Projektinhaber beobachtete zusätzlich, dass alle 15 Flugzeuge ihren jeweiligen Endpunkt physisch erreichten und erst danach Kurs und Höhe änderten. Das Verhalten nach dem Endpunkt liegt außerhalb des 200-NM-Messfensters und beeinflusst die bereits geschriebenen `SUMMARY`-Werte nicht.

### Vollständige Ergebnis-Matrix

| Höhe | Soll IAS | Ø IAS | Ø TAS | Fuel Start | Fuel Ende | Fuel / 200 NM | Fuel / 100 NM | Fuel / h | Bewertung |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| FL250 | 230 | 230.0 | 327.7 | 76.204 % | 68.358 % | 7.846 % | 3.923 % | 12.333 % | STABLE |
| FL250 | 250 | 250.0 | 356.2 | 76.216 % | 68.503 % | 7.713 % | 3.856 % | 13.221 % | STABLE |
| FL250 | 270 | 270.0 | 384.7 | 76.184 % | 67.480 % | 8.704 % | 4.352 % | 16.068 % | STABLE |
| FL250 | 290 | 290.0 | 413.2 | 76.075 % | 66.546 % | 9.529 % | 4.765 % | 19.057 % | STABLE |
| FL250 | 310 | 310.0 | 441.7 | 75.984 % | 65.646 % | 10.338 % | 5.169 % | 22.151 % | STABLE |
| FL320 | 230 | 230.0 | 355.1 | 76.275 % | 68.824 % | 7.450 % | 3.725 % | 12.710 % | STABLE |
| FL320 | 250 | 250.0 | 386.0 | 76.238 % | 68.271 % | 7.968 % | 3.984 % | 14.784 % | STABLE |
| FL320 | 270 | 270.0 | 416.9 | 76.176 % | 67.569 % | 8.607 % | 4.303 % | 17.308 % | STABLE |
| FL320 | 290 | 290.0 | 447.8 | 76.101 % | 67.122 % | 8.979 % | 4.490 % | 19.471 % | STABLE |
| FL320 | 310 | 310.0 | 478.6 | 76.001 % | 65.753 % | 10.247 % | 5.124 % | 23.798 % | STABLE |
| FL350 | 230 | 231.1 | 368.7 | 76.233 % | 68.729 % | 7.504 % | 3.752 % | 13.307 % | STABLE |
| FL350 | 250 | 250.0 | 398.7 | 76.186 % | 68.319 % | 7.867 % | 3.934 % | 15.144 % | STABLE |
| FL350 | 270 | 270.0 | 430.6 | 76.179 % | 67.856 % | 8.323 % | 4.162 % | 17.318 % | STABLE |
| FL350 | 290 | 290.0 | 462.5 | 76.138 % | 67.171 % | 8.967 % | 4.484 % | 20.049 % | STABLE |
| FL350 | 310 | 296.6 | 473.0 | 76.093 % | 66.556 % | 9.537 % | 4.769 % | 21.866 % | MARGINAL |

Der einzige nicht als `STABLE` klassifizierte Fall ist `FL350 / 310 KIAS`. Die E-3A erreichte dort im Mittel nur 296.6 KIAS, maximal 13.4 KIAS unter Soll. `FL350 / 290 KIAS` wurde dagegen exakt gehalten.

### Kernaussagen aus dem Multi-Test

1. **FL350 ist für den sichtbaren Transit technisch tragfähig.** `270 KIAS` und `290 KIAS` wurden beide stabil gehalten. `310 KIAS` liegt im getesteten Gross-Weight-Bereich bereits am Leistungsrand und wird nicht als Produktions-Sollwert empfohlen.
2. **Fuel pro Strecke und Fuel pro Stunde müssen getrennt bewertet werden.** Für Transit ist `Fuel / 100 NM` maßgeblich; für Station-Time ist `Fuel / h` maßgeblich.
3. **FL320 / 230 KIAS** ist der niedrigste gemessene Streckenverbrauch der gesamten Matrix (`3.725 % / 100 NM`), während **FL250 / 230 KIAS** den niedrigsten gemessenen Stundenverbrauch (`12.333 % / h`) liefert. Acceptance 5 ist jedoch ein Geradeausflugtest und beweist keine Racetrack-Turn-Stall-Margin.
4. **FL320 / 250 KIAS** wurde stabil gehalten und bildet einen sinnvollen Engineering-Kompromiss für den AWACS-Racetrack: mehr Speed-Margin als 230 KIAS, aber deutlich geringerer Fuel-Burn als 270/290/310 KIAS.
5. **FL250 / 270 KIAS** und **FL250 / 290 KIAS** wurden beide stabil gehalten und bilden eine geeignete DCS-Basis für ein getrenntes AAR-Contact- und Rendezvous-Profil.

## Diskussion und daraus abgeleitete OMW-Engineering-Baseline

Die nach dem Multi-Test geführte Auswertung wurde ausdrücklich von nicht belegten Hersteller- oder Stall-Aussagen getrennt. Acceptance 5 beweist nur das tatsächlich beobachtete DCS-Verhalten im 200-NM-Geradeausflug bei dem verwendeten Template-Gewicht.

### Transit

Zwei technisch sinnvolle FL350-Profile bleiben dokumentiert:

```text
ECONOMICAL NORMAL TRANSIT
FL350 / 270 KIAS
~430.6 KTAS
4.162 % Fuel / 100 NM
17.318 % Fuel / h

FAST NORMAL TRANSIT
FL350 / 290 KIAS
~462.5 KTAS
4.484 % Fuel / 100 NM
20.049 % Fuel / h
```

`FL350 / 310 KIAS` wird verworfen. Für die weitere OMW-Implementierung ist `FL350 / 270 KIAS` die bevorzugte normale Transit-Baseline; `FL350 / 290 KIAS` bleibt als getestete Fast-Transit-Option dokumentiert.

### AWACS-Racetrack

```text
OMW ENGINEERING BASELINE
FL320 / 250 KIAS
~386.0 KTAS
3.984 % Fuel / 100 NM
14.784 % Fuel / h
```

Die Auswahl von 250 statt 230 KIAS ist eine Engineering-Entscheidung zur zusätzlichen Speed-Margin für Racetrack-Turns und den höheren Gross-Weight-Zustand nach AAR. Acceptance 5 selbst enthält keine Kurven- oder Stall-Grenzprüfung; Aussagen über konkrete Stall-Margins dürfen daraus nicht abgeleitet werden.

### Air-to-Air Refuelling

Der Projektinhaber stellte zusätzlich einen receiver-spezifischen AAR-Tabellenausschnitt für `E-3A/D/F` bereit. Dort wird als Optimum `FL250 / 275 KIAS / M0.66` und als Receiver-Rendezvous-IAS `310 KIAS` ausgewiesen. Diese externe Referenz wird nicht als Zwang interpretiert, WIZARD bis an den oberen Rand seiner DCS-Leistungsfähigkeit zu betreiben.

Die OMW-Engineering-Baseline nutzt daher die in Acceptance 5 stabil bestätigten konservativeren Werte:

```text
LISA / AAR CONTACT
FL250 / 270 KIAS

WIZARD RENDEZVOUS
FL250 / 290 KIAS

Closure margin
+20 KIAS

PRE-CONTACT
290 -> 270 KIAS
```

Damit wird Rendezvous-Speed bewusst von Contact-/Transfer-Speed getrennt. Das korrigiert das zuvor beobachtete unplausible Verhalten, bei dem WIZARD einem zu schnellen LISA-Track lange hinterherfliegen musste.

### Reserve-/Bingo-Diskussion

Die bestehende Fuel-Orchestrierung bleibt vorerst:

```text
65 %  LISA pre-dispatch
40 %  fallback AAR trigger
25 %  critical contingency / no more waiting without established refuel path
```

Acceptance 5 liefert für `FL350 / 270 KIAS` einen gemessenen Stundenverbrauch von `17.318 % / h`. Eine 45-Minuten-Reserve entspricht rein rechnerisch rund `13.0 %` Fuel-Fraction im stabilisierten Geradeausflug. Zusätzlich sind Rückflugstrecke, Climb/Acceleration, Routing-/Diversion-Allowance und eine Mindestankunfts-/Landing-Reserve zu berücksichtigen.

Daraus folgt ausdrücklich **keine** neue validierte Bingo-Formel. Die diskutierte Größenordnung bestätigt lediglich, dass `25 %` als Critical-Egress-Schwelle nicht nach unten korrigiert werden sollte, bevor die für OMW/Tanker bereits verwendete Reserve- und Landing-Fuel-Systematik vollständig abgeglichen ist.

Eine brauchbare Arbeitszerlegung für die weitere Fuel-Policy ist:

```text
fuel to recovery point
+ diversion allowance
+ 45 min final reserve
+ landing minimum
= operational bingo / critical recovery requirement
```

Die konkrete Prozentaufteilung bleibt `DCS_PENDING` beziehungsweise `SOURCE_RECONCILIATION_PENDING` und darf nicht als reale E-3A-Handbuchvorgabe ausgegeben werden.

## Acceptance-Evidenz und Statusgrenze

Der Lauf bestätigt für den dokumentierten DCS-/MOOSE-/Bundle-Stand:

```text
15/15 profiles completed
14 profiles STABLE
1 profile MARGINAL: FL350 / 310 KIAS
runtime-generated 20 NM stabilization + 200 NM measurement geometry works
MOOSE IAS->TAS route calibration and independent IAS/TAS observation work in DCS
```

Nicht bestätigt werden durch Acceptance 5:

```text
Racetrack turn performance / stall margin
post-AAR heavy-weight orbit behavior
real E-3A certified performance limits
real-world bingo/landing reserve values
production AWACS lifecycle with the new selected speeds
LISA AAR lifecycle at FL250 / 270 KIAS
WIZARD rendezvous at FL250 / 290 KIAS
```

Für eine Hochstufung zu `ACCEPTED_TECHNICAL_BASELINE` fehlen weiterhin die realen SHA-256-Werte der tatsächlich getesteten zweiten MIZ und ihrer internal `mission`-Datei. Die Produktionsänderung der AWACS-/LISA-Geschwindigkeiten benötigt anschließend einen eigenen vollständigen Lifecycle-/AAR-DCS-Lauf.
