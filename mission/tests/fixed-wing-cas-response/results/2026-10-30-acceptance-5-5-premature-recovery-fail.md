---
document_id: OMW-RESULT-FIXED-WING-CAS-A5-5-20261030
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - exact supplied A5-5 premature recovery evidence
not_authoritative_for:
  - production acceptance or DCS validation of A5-6
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: 1242c53629caad57637e92d0c999e79034f081ca
validated_in_dcs: false
---

# A5-5 – unmittelbare Recovery nach Join, FAIL

## Ergebnis

Alle drei CAS-Two-Ships erhalten durch den neuen OMW-Fuel-Adapter kurz nach
Join RTB. Kein AO-Eintritt. Alle sechs Flugzeuge landen an Home; alle drei
exakten Assets werden zurueckgegeben. Das ist kein CAS-/Fuel-Policy-PASS.
Die vom Owner beobachteten engen Kreise am Anfang sind ein separater offener
Fehler. Ein konstruierter Racetrack beweist keine geflogene Bahn.

## Reale Provenienz

| Artefakt | SHA256 / Wert |
|---|---|
| Source | `1242c53629caad57637e92d0c999e79034f081ca` |
| Builder | `OMW-FIXED-WING-CAS-RESPONSE-A5-5` |
| realer Owner-Build / embedded Bundle | `FE387CD3EE6DD12BEBD8024927E982573F42969C6412F87428039DD31356FBE4` |
| hochgeladene MIZ `(7)` | `7FC3443869975EDA3A65A05EA736639FEA30B6C714DE12CEB346EF7F0B5580A0` |
| interner mission-Inhalt | `2F8C92A9C14557B85885989554D8B0E329C3A13CB90F5F56A2E530F46F5F1BBB` |
| embedded Moose.lua | `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915` |
| MOOSE Commit | `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54` |
| `dcs(9).log` | `E44640CAF0F1A37AB8A03F3114944FBEAD90137FAA89D5C4F26C00CDE558B395` |
| `debrief(9).log` | `CC837EDEA7113B37D4021D778B17ACC2DA93EB061FBFF8607E9B666D8BE409A4` |

DCS: **2.9.31.29434 MT** laut Original-Log. Dateinummern sind Uploadnamen,
keine Testidentitaet. Runtime-Befunde wurden aus den realen Dateien gelesen.
Observer-Client/MP sind kein positiv abgenommener Scope dieses Laufs.

## Ereignisse (Missionssekunden seit Tagesbeginn)

| Profil | Join | Holding-Clear | RTB | Differenz Join/RTB | Grund |
|---|---:|---:|---:|---:|---|
| A-10 | 55040 | 55070 | 55115 | 75 s | TRANSIT_NOT_FUEL_SUPPORTED |
| F-16 | 55120 | 55130 | 55190 | 70 s | NO_RESERVE_SAFE_HOME_OR_TANKER |
| F-15E | 56135 | 56150 | 56240 | 105 s | TRANSIT_NOT_FUEL_SUPPORTED |

Jeweils RTB requestDelayS=0; die A5-4-17-Minuten-Verzoegerung ist hier nicht
die Ursache. CAS wird vom OMW-Adapter geschlossen. FuelLow ist kein Nachweis
fuer den neuen unmittelbaren Abbruch.

F-16 Wingman bei 55190 s: availableKg=4934.0126931667, rateKgS=2.2791344542065,
allowanceKg=6153.6630263576, tripKg=1122.5560430465. Das 60-s-Join-/Steigflugfenster
wird auf Rueckweg und 45 Minuten Reserve extrapoliert. A5-5 qualifiziert diese
Proben nicht nach Flugphase. Dies ist die nachgewiesene Regressionsgrenze.

Tanker: NELSON meldet On-Station erst nach den A-10-/F-16-Entscheidungen;
PATTY/MILHOUSE/KRUSTY ebenfalls spaeter. Zur F-15E-Entscheidung ist NELSON
bereits on station. Dessen exakter Ablehnungsgrund ist mit A5-5 nicht
rekonstruierbar, weil einzelne Filterzweige keine Diagnose liefern.

## Physische Rueckkehr

| Profil | Lead Home-Landung | Wingman Home-Landung | exakter Asset-Return |
|---|---:|---:|---:|
| A-10 / Kandahar | 56022 | 56203 | 56693, UID 77 |
| F-16 / Bagram | 56062 | 56201 | 56705, UID 7 |
| F-15E / Bagram | 56856 | 56930 | 57464, UID 3 |

Debrief bestaetigt sechs Landungen fuer die sechs CAS-Airframes. Separat
protokollierte AH-64-Abstuerze sind keine Verluste dieser sechs Fixed-Wing-Assets.
TWO_SHIP_ELEMENT_MISSING kann hier beim Bodenkontakt vor ElementLanded auftreten:
A5-5 verwechselt weniger airborne Elemente mit fehlenden lebenden Elementen.
Deshalb recoveryComplete=false trotz physischer Home-Rueckkehr; nicht als
fehlende Landung oder fehlende Asset-Rueckgabe ausgeben.

## Gegenbeleg A5-4

`dcs(8).log`: F-16 Join 55355 (15:22:35), CAS execute 56041 (15:34:01),
beide erstmals im AO 56345 (15:39:05), RTB 57910 (16:05:10).
42m35s nach Join bis RTB, 16m30s Join bis erster AO, 26m05s erster AO bis RTB.
Nur 45.003 s gemeinsame beobachtete Aufenthaltszeit im engen 5-NM-Kreis;
keine 26 Minuten durchgehender geometrischer AO-Aufenthalt behaupten.
AO-Fuel Lead/Wingman 79.2599/70.0408 %, kurz vor FuelLow 40.7004/29.5352 %.
Die spaetere Wingman-Kraftstofferschoepfung bleibt negative Recovery-Evidenz.

## A5-6 Source-Korrektur und offene Sperre

Gemeinsame Module behalten MOOSE als einzigen physischen Ausfuehrer.
Qualifizierte Level-Cruise-Proben statt pauschaler Join-/Climb-Hochrechnung;
Referenzbasis und gelernte Cruise-Basis werden getrennt geloggt. 45 Minuten
bleiben erhalten. Fehlender aktueller Tanker beendet nicht automatisch den
Transit, solange Home mit Reserve erreichbar bleibt. Ungueltige Daten werden
weiter als Fehler behandelt. Tankerkandidaten erhalten konkrete Filtergruende.
Lebende Bodenflugzeuge gelten nicht als vermisst.

376 originale Telemetrieproben als kleine Lua-Testfixture; A5-4-Massen sind
explizit aus Fraktion und internem Typvorrat rekonstruiert. Replay prueft die
realen A5-5-Fruehabbruchzeitpunkte aller drei Typen gegen aufgezeichnete
Home-Routenzeiten und die A5-4-F16-Reserveverletzung. Das ist Source-/Policy-
Evidenz, keine neue Flugphysik oder DCS-Acceptance.

Die fruehe Lead-Flugfuehrung ist NICHT behoben. Queue-Airborne-Grenze ist
quellenbelegt, die Kausalitaet der engen Kreise nicht. Konstruktor-Assertion
und passive Queue-/Waypoint-Diagnose verbessern die Beweislage, sind keine
Racetrack-Flugfreigabe. A5-6 bleibt DCS_BLOCKED_DEPARTURE. Standardbuilder bricht
ab; `-AllowBlockedDiagnosticBuild` dient ausschliesslich CI/Source-Review und
schreibt die Sperre in den Bundlekopf. Keine neue Owner-Testanweisung.


## Statische Pruefung des Korrekturstands

Lokal: 26 Vertrags-/Adaptertests plus vier Replaypruefungen unter Lua 5.3
(texlua); Syntax der lexikalischen Komposition bestanden. Dokumentvalidator:
0 Fehler / 0 Warnungen; kompletter Diff und Whitespace geprueft.
Lua-5.1- und echter PowerShell-Build-Nachweis erfolgen separat ueber den
A5-6-CI-Job. Ein solcher CI-PASS hebt den Departure-Blocker nicht auf.
