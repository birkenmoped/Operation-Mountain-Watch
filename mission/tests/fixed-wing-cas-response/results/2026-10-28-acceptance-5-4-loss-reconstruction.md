---
document_id: OMW-RESULT-FIXED-WING-CAS-A5-4-20261028
status: HISTORICAL_TEST_FIXTURE
document_class: TEST_RESULT
owning_policy: OMW-GOV-001
authoritative_for:
  - observed A5-4 element fuel and loss/landing events in the supplied artifacts
not_authoritative_for:
  - accepted production CAS or an implemented A5-5 fix
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: 0fa37a82b71512a212de7ce49ab40a6a1bbfe995
validated_in_dcs: false
runtime_result: FAIL
---

# A5-4 – individuelle Fuel-/Verlustrekonstruktion vom 28.10.2026

## Provenienz und Grenzen

Der Owner bestaetigt: `dcs(8).log` und `debrief(8).log` sind die gewuenschten Logs; nur der Upload-Zaehler wurde erhoeht. Das Debrief ist bytegleich mit dem im Chat-Handoff als `debrief(7).log` bezeichneten Artefakt. Der DCS-Log-Hash ist verschieden; ohne die alte Datei wird keine Byte-/Prefix-Gleichheit behauptet.

| Artefakt | SHA256 |
|---|---|
| `dcs(8).log` | `34F7FBCDB13FFE8E78CE7471B36E74E6CE3BE31CED0413CE5AFA2160E38F5787` |
| `debrief(8).log` | `8474B72C673AEF7764E07D352B6172F3A2847CA86A217E4411A2ABF15F69827C` |
| `OMW_Template_v26_GroundWorks_Ready(5).miz` | `6373A2FCB6C8589CB9FA88773E12656AF6AB386A67865E63D51E114AB7BC21E9` |
| ZIP-Eintrag `mission` | `89C086494C0215311974B057C5A37F39FD16A15B425AB9D369EE9F30694E3ED8` |
| eingebettetes `OMW_FixedWing_CAS_Response_Acceptance_5.lua` | `7DF284281EFDB45E2EFD136F59E42C95F3BCB4F4D69D84CA6369FF616863DCE9` |
| eingebettetes `Moose.lua` und separat bereitgestelltes `Moose.lua` | `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915` |

Bundle-Kopf: BuilderVersion `OMW-FIXED-WING-CAS-RESPONSE-A5-4`, GitCommit `0fa37a82b71512a212de7ce49ab40a6a1bbfe995`, GeneratedUtc `2026-10-28T17:48:44.1072117Z`. MOOSE 2.9.18, dokumentierter Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`. DCS-Log: `2.9.31.29434 MT`.

Die MIZ enthaelt `ResKey_Action_248 -> OMW_FixedWing_CAS_Response_Acceptance_5.lua` und den zugehoerigen Script-Trigger. Debrief nennt den originalen Owner-Missionspfad ohne Upload-Suffix. Die hochgeladene MIZ ist damit exakt identifiziert und ihr eingebettetes Bundle entspricht dem dokumentierten Owner-Build. Das Log selbst enthaelt keinen zur Laufzeit ermittelten MIZ-Hash; die kryptografische Bindung der ausgefuehrten Dateikopie ist dadurch nicht unabhaengig bewiesen. Keine MIZ-Mutation vorgenommen.

## Zeit- und Elementkorrelation

Missionsstart im `mission`-Eintrag: 54000 s = 15:00:00. Debrief-`t` ist die seit Start vergangene Zeit; DCS-A5-`time` ist Uhrzeit in Sekunden seit Mitternacht. Die unterschiedlichen Wallclock-/Beschleunigungsintervalle sind nicht als Flugzeit zu verwenden.

Die Zuordnung wird ueber die individuellen Takeoff-Zeiten des A5-Logs und die uebereinstimmenden Debrief-Takeoff-Ereignisse hergestellt; danach bleibt die Debrief-Objekt-ID fuer Land/Eject/Crash dieselbe.

| Element | Debrief MissionID / Objekt-ID | Takeoff (Missionsuhr) | Individuelles Ergebnis |
|---|---|---|---|
| F-16 `AID-7-01` | 1000055 / 16949504 | 15:10:25.095 | Bagram Land 16:27:59.155; Engine shutdown 16:34:36.335 |
| F-16 `AID-7-02` | 1000056 / 16949760 | 15:17:04.525 | Eject 16:25:38.625; Crash 16:25:47.885 |
| F-15E `AID-1-01` | 1000110 / 16961536 | 15:26:35.467 | Bagram Land 17:59:09.727; Engine shutdown 18:06:37.637 |
| F-15E `AID-1-02` | 1000111 / 16961792 | 15:32:21.537 | Bagram Land 18:00:38.997; Engine shutdown 18:08:21.647 |
| A-10 `AID-77-01` | 1000079 / 16954624 | 15:07:46.687 | Eject 22:38:47.047; Crash 22:39:06.707 |
| A-10 `AID-77-02` | 1000080 / 16954880 | 15:13:43.317 | Eject 22:48:14.497; Crash 22:48:23.087 |

Gemeinsame Prefixe: F-16 `SQ_US_BGRM_F16C_121_EFS_`, F-15E `SQ_US_BGRM_F15E_335_EFS_`, A-10 `SQ_US_KAF_A10C_74_EFS_`. Debrief-Ereignisse 2039/2041: F-16-Wingman Eject/Crash; 2042: Lead Land; 2185/2186: beide F-15E Land; 2204/2206 und 2208/2210: beide A-10 Eject/Crash.

## Fuel-Vergleich vor/nach Departure-Join

`UNIT:GetFuel()` liefert die Fraktion relativ zum internen Tankvorrat, mit Zusatztanks auch >1. Die folgenden Prozentwerte sind Fraktion mal 100, keine Prozent-vom-Gesamttank-Angabe. PP = Prozentpunkte. Die Telemetrie tastet alle 15 s ab.

| F-16 | Takeoff-nahe Probe | Join-Probe 15:22:35 | Abnahme | Takeoff bis Join |
|---|---|---|---|---|
| Lead | 15:10:20: 162.93 % | 128.58 % | 34.35 PP | ca. 12 min 10 s |
| Wingman | 15:17:05: 161.17 % | 116.67 % | 44.50 PP | ca. 5 min 31 s |

Der Wingman hat trotz spaeterem Start beim Join 11.91 PP weniger. Sein hoeherer Verbrauch vor dem Join ist belegt; Nachbrennereinsatz ist anhand dieser Telemetrie nicht direkt nachgewiesen. Unterschiedliche Flugphasen verhindern eine Gleichsetzung der durchschnittlichen Abnahme mit einem vergleichbaren stationaeren Triebwerksverbrauch.

| Abschnitt | Lead Anfang -> Ende | Wingman Anfang -> Ende | Abnahme Lead / Wingman |
|---|---|---|---|
| F-16 Join 15:22:35 -> beide AO 15:39:05 | 128.58 -> 79.26 % | 116.67 -> 70.04 % | 49.32 / 46.63 PP |
| F-15E Join 15:34:20 -> beide erstmals AO 17:35:51 | 115.09 -> 29.82 % | 115.74 -> 38.13 % | 85.28 / 77.60 PP |
| A-10 Join 15:16:05 -> erste AAR-Anforderung 16:10:06 | 92.24 -> 64.92 % | 96.48 -> 69.70 % | 27.31 / 26.78 PP |
| A-10 Probe nach AAR-1 17:12:06 -> beide AO 17:24:51 | 93.69 -> 88.17 % | 99.98 -> 94.12 % | 5.53 / 5.87 PP |
| A-10 Probe nach AAR-2 19:24:06 -> beide wieder AO 19:32:36 | 97.51 -> 94.22 % | 99.96 -> 95.83 % | 3.28 / 4.13 PP |

Wichtige Grenzen: Die F-15E meldet MOOSE-MISSION_EXECUTE schon 15:45:00, beide Elemente aber erst 17:35:51 im beobachteten 5-NM-Kreis. Der lange Abschnitt ist kein belegter reiner Transit. Bei der A-10 liegt AAR zwischen Join und erstem AO-Eintritt; die Nettoaenderung ueber diesen Gesamtabschnitt waere kein Verbrauch. Die AAR-Proben liegen drei Sekunden vor AAR-1-Refueled bzw. zwei Sekunden nach AAR-2-Refueled; diese Stichproben sind kein exakter Fuel-Wert zum Eventzeitpunkt.

## F-16 FuelLow und Verlust

- 16:05:06, vier Sekunden vor FuelLow: Lead 40.7004 %, Wingman 29.5352 %.
- 16:05:10: MOOSE FuelLow-Minimum 29.4417 %, `AAR_NOT_AVAILABLE reason=NO_ELIGIBLE_ACTIVE_TANKER_CLOSER_THAN_HOME`, unmittelbares MOOSE RTB.
- 16:21:40: FuelCritical-Minimum 9.1178 %.
- Letzte Wingman-Probe 16:25:36: Fraktion `0.00084401242202148` = 0.0844 %, 7849.54 ft MSL, TAS 301.00 kt, GS 297.24 kt; 2.625 s spaeter Eject, 11.885 s spaeter Crash.
- Lead landet separat. Seine letzte Boden-/Stillstandsprobe 16:34:36 zeigt 17.1960 %.

MOOSE `GetFuelMin` und der Status-Check ueberwachen das schlechteste Element. Es ist kein Lead-only-FuelLow. Hier loeste der Wingman den Rueckkehrbedarf aus, die 30-%-Schwelle sicherte seine reale Recovery dennoch nicht ab. Treibstofferschoepfung ist die stark gestuetzte Verlustursache, ein individueller Nullwert vor Eject liegt nicht vor. Die Graveyard-F-16-Position ist x=130142.34375, z=278445.28125, alt=1477.16 m; sie liegt ca. 3.36 NM vom aus dem Departure-Track rekonstruierbaren Bagram-Anker. Keine durchgehenden individuellen Positions-/AGL-Samples: zusaetzliche Gelaende-/Anflugfaktoren sind nicht ausgeschlossen.

## A-10: angeforderter RTB ist nicht bestaetigter RTB

| Missionsuhr | Ereignis / individuelle Fuel-Werte |
|---|---|
| 17:12:09 | AAR-1 Refueled; Gruppenminimum 93.69 % |
| 19:02:13 | FuelLow und AAR-2 PATTY gewaehlt; Minimum 29.91 % |
| 19:24:04 | AAR-2 Refueled; Minimum 97.52 % |
| 21:05:52 | `SORTIE_FINAL_RTB_ORDERED`; Lead 39.1938 %, Wingman 42.2090 %; geschaetzte Rueckkehrzeit 7344.31 s |
| 21:05:52 bis 21:22:37 | A5-Beobachter meldet weiter `missionState=executing`, beide im AO; Final-RTB-Latch bereits gesetzt |
| 21:22:43 | FuelLow 29.7532 %; A5-FuelLow-Callback ueberspringt AAR wegen Final-RTB-Latch |
| 21:22:52 | erstes bestaetigtes `MOOSE_RTB`, Lead 29.6679 %, Wingman 32.8563 % |
| 22:16:43 | FuelCritical, Minimum 9.8700 % |
| 22:38:13 | MOOSE Holding; kein Landungsnachweis |
| 22:38:37 | letzte Lead-Probe vor Eject: 0.0700 % |
| 22:38:52 | Lead-Fraktion 0, nach Eject und vor Crash, noch 10199 ft MSL |
| 22:48:07 | letzte Wingman-Probe vor Eject: 0.0289 % |
| 22:48:22 | Wingman-Fraktion 0, nach Eject und vor Crash, noch 3553 ft MSL |

Differenz RTB-Anforderung -> MOOSE RTB: 1020 s = 17 min. Dabei sinken Lead/Wingman um 9.53/9.35 PP. Die MOOSE-`onbeforeRTB`-Task-Sperre bei FuelGood passt zum beobachteten Verhalten; der konkrete intern ablehnende Check ist nicht als Diagnosezeile protokolliert. Die reine Anfrage als vollzogene Rueckkehr zu behandeln, ist unabhaengig davon falsch.

Die Nullwerte werden NICHT vor dem jeweiligen Ausstieg behauptet. Die unmittelbar vorher fast aufgebrauchten Vorratswerte, deren Abnahme, anschliessender Nullwert und Crash stuetzen Fuel-Exhaustion sehr stark. Beide A-10 haben keine physische Recovery. Ein `AUFTRAG success` ist hier kein Erfolgsnachweis.

## F-15E und offene Asset-Rueckgabe

Beide F-15E-Landungen und Triebwerksabschaltungen sind im Debrief belegt. Der Lead zeigt unmittelbar vor Shutdown noch ca. 15.77 % und erst danach in einer Boden-/Stillstandsprobe 0. Dieser Nullwert ist keine Fuel-Out-Evidenz. Ein exact `LegionAssetReturned`-/Asset-Recredit-PASS fuer alle drei Two-Ships ist aus der vorhandenen A5-Instrumentierung nicht nachgewiesen. Spaetere physische Gruppenentfernung ersetzt diesen Nachweis nicht.

## Source-Befunde und offene Ursachen

1. `requestAar` sperrt bei `finalRtbAtS`; `OnAfterFuelLow` ruft die Auswahl dann nicht einmal auf. Deshalb muss kein `AAR_BLOCKED_FINAL_RTB`-Log im A-10-FuelLow auftreten, obwohl die Sperre wirksam ist.
2. A-10-Allowlist nur PATTY/MILHOUSE; KRUSTY fehlt. Distanz zur Homebase wird als hartes Ausschlusskriterium verwendet. Keine daraus abgeleitete Behauptung, dass kein geeigneter Tanker im Einsatzraum existierte.
3. Logs zeigen KRUSTY-/MILHOUSE-Betrieb und Relief. Das belegt ohne individuellen Zugangskorridor und Kapazitaetspruefung keine sichere konkrete Recovery-Zuweisung.
4. `airborne=record.airborneCount` ist ein historischer Takeoff-/Airborne-Zaehler. Er bleibt auch bei `alive=0` gleich 2. `goingForFuel` verwendet `and/or` und kann echtes `false` zu `unknown` machen.
5. `indicatedAirSpeedKts` ist die MOOSE-Approximation aus TAS und Hoehe, keine direkt ausgelesene Cockpit-IAS oder Nachbrennertelemetrie.
6. Racetrack-Konfiguration/Task-Erzeugung sind belegt; tatsaechliche individuelle Orbit-Geometrie/Formation und Gelaendefreiheit nicht vollstaendig. AAR-Formation bleibt ohne die erste Laufkopie/Screenshots bzw. neue Positionsdaten ursachenseitig offen.

Naechster Schritt: [konsolidierter Korrektur-/Ausnahmevertrag](../../../../docs/moose/FIXED-WING-CAS-FUEL-RECOVERY-CORRECTION.md). A5-4 erneut zu fliegen ist kein geeigneter Sicherheitsnachweis. Kein A5-5-Runtime-Code, neuer Owner-Build oder DCS-PASS wird durch diese Rekonstruktion behauptet.
