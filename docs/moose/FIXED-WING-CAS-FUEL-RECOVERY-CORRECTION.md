---
document_id: OMW-MOOSE-FIXED-WING-CAS-FUEL-RECOVERY-CORRECTION
status: DRAFT
document_class: CORRECTION_DESIGN_AND_EXCEPTION_REQUEST
owning_policy: OMW-GOV-001
authoritative_for:
  - source-reviewed A5-4 correction proposal and explicitly bounded approval request
not_authoritative_for:
  - approved numerical receiver reserves or a validated recovery implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fixed-wing-cas-coverage-ground-alert-decision
source_commit: 0fa37a82b71512a212de7ce49ab40a6a1bbfe995
validated_in_dcs: false
implementation_status: BLOCKED_PENDING_EXPLICIT_OWNER_EXCEPTION
---

# Fixed-Wing CAS – konsolidierter Fuel-/Recovery-Korrekturvertrag

## 1. Ergebnis und Freigabegrenze

A5-4 ist fuer den [dokumentierten Lauf](../../mission/tests/fixed-wing-cas-response/results/2026-10-28-acceptance-5-4-loss-reconstruction.md) FAIL. Die folgenden A5-5-Aenderungen sind ein konkreter Entwurf, keine implementierte oder DCS-validierte Korrektur. Es wird kein neuer DCS-Kandidat gebaut oder freigegeben, solange die hier benannten Ausnahme-/Reserveentscheidungen fehlen.

Owner-Auftrag im Chat am 28.10.2026: den fehlgeschlagenen Test konsolidiert korrigieren. Die anschliessende Source-Pruefung weist eine neue Luecke jenseits der bisherigen Departure-Holding-Ausnahmen nach. Der allgemeine Fehlerbehebungsauftrag wird nicht stillschweigend als Freigabe neuer interner Feldmutationen oder numerischer Receiver-Reserven behandelt.

## 2. Lifecycle-Inheritance vor Implementierung

| Feld | Wiederverwendung / Grenze |
|---|---|
| inherited_contract | `ACCEPTED-LIFECYCLE-PRESERVATION-LAW.md`, `STAGE3-CAS-LIFECYCLE-RECOVERY-LAW.md` §§16–20; keine Uebernahme der AH-64-Geometrie |
| accepted_source_paths | bestehende AirOps-Bootstraps fuer Bagram/Kandahar; `scripts/air-operations/OMW_AAR_Controller.lua`, `OMW_AirOps_AAR_Bootstrap.lua`; MOOSE COMMANDER/LEGION/AIRWING/SQUADRON/AUFTRAG/FLIGHTGROUP |
| evidence | AAR-7: `7d55a1383cbf3f52ea776d7354b37dbe5a920466`, exakte Provenienz in `docs/89-aar-acceptance-7-finalization.md`; A9 nur Rotary-Wing-CAS; A4/A5 Fixed-Wing bleiben negative/partielle Evidenz |
| invariants | ein physisches Two-Ship; MOOSE besitzt Task/FSM/Route/RTB/Landing/Return; kein strategischer Recredit vor bestaetigtem Ereignis; Fuel-Abbruch ist kein normaler CAS-Erfolg |
| reuse_mode | DIRECT_REUSE fuer Tanker-/AirOps-Lifecycle; MINIMAL_ADAPTER nur fuer belegte Receiver-Policy-Luecke, erst nach Freigabe |
| harness_role | Trigger, individuelle Telemetrie, Event-/Asset-Korrelation, Assertions; keine Fuel-/Recovery-FSM im Harness |
| changed_boundary | Fixed-Wing-Receiver-Entscheidung und freigegebener Post-RTB-AAR-Handoff; kein Neubau des Tankercontrollers |
| owner_approval | neue Fuel-Policy-Ergaenzung, Receiver-Reserve und unten begrenzte `currbase`-Ausnahme noch OFFEN |
| revalidation_scope | alle drei Two-Ships: Departure/Join, Fuel-Entscheidung, AAR/Resume, CAS-Ende, Recovery-AAR, sechs Landungen und exakter Asset-Return |

## 3. MOOSE-first – Dokumentation, Source und Beispielgrenzen

Geprueft: bereitgestellte und MIZ-eingebettete MOOSE 2.9.18, Commit `73d3ed119cd9e7e3f2cfcabbaa34513d30529b54`, SHA256 `E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915`.

Offizielle Dokumentation: [Ops.FlightGroup](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Ops.FlightGroup.html), [Ops.Auftrag](https://flightcontrol-master.github.io/MOOSE_DOCS_DEVELOP/Documentation/Ops.Auftrag.html), [Wrapper.Controllable](https://flightcontrol-master.github.io/MOOSE_DOCS/Documentation/Wrapper.Controllable.html). Online-Dokumentation ist nicht automatisch versionsgleich; die folgenden Aussagen beruhen auf dem gepinnten Source.

| Schnittstelle / Sourcezeilen in der gepinnten Datei | Quellenbefund | Konsequenz |
|---|---|---|
| `SetFuelLowThreshold`, ca. 203814; Fuel-State-Check ca. 204528 | oeffentliche veraenderbare Prozentgrenze gegen `GetFuelMin`; kein streckenabhaengiges Bingo-Modell | Schwelle allein beweist keine Rueckkehrreserve |
| Diagnoseblock ca. 204439–204486 | Restflugzeit aus momentaner Fuel-Differenz nur bei `verbose>=4`; lokale Variablen, keine Return-Entscheidung | kein vorhandener oeffentlicher Recovery-Budget-Service; Diagnose nicht als Sicherheitsmodell ausgeben |
| `UNIT:GetFuel`, ca. 61557 | Fraktion relativ zum internen Tankvorrat; kann mit Zusatztanks >1 sein | keine Prozent-vom-Gesamttank-Verwechslung |
| `UNIT:GetCurrentFuelKgs`, `GetFuelMassMax`, ca. 62425 | oeffentliche Massen-/Bezugsdaten | individuelle Bilanz in kg, Prozent nur Darstellung; keine Fuel-Mutation |
| `FLIGHTGROUP:Refuel` / `onafterRefuel`, ca. 206366 | pausiert Mission, routet zur Koordinate, erzeugt gruppenweiten DCS-Refuel-Task | kein expliziter Tanker-Target-Lock; keine einzelne Wingman-Route |
| `onafterRefueled`, ca. 206404; `_CheckGroupDone`, ca. 205750 | MOOSE prueft danach u.a. pausierte Missionen und kann unpausieren | CAS-Endabsicht muss alte CAS-Fortsetzung verhindern, ohne AAR zu sperren |
| `onbeforeRTB`, ca. 205892 | kann bei FuelGood und verbleibenden Tasks RTB zurueckstellen | Anfrage und bestaetigtes RTB getrennt erfassen; kein Erfolg allein durch Log-Latch |
| `onafterRTB`, ca. 205995 | `CancelAllMissions`, danach eigener Landing-Pfad | Tasks kontrolliert ueber oeffentliche Missions-APIs schliessen; kein eigener Flugcontroller |
| `_LandAtAirbase`, ca. 206090; `onbeforeRTB`, ca. 205913 | setzt `currbase` bereits beim RTB; spaeteres RTB zur gleichen Base kann deshalb abgewiesen werden | wichtige neue Post-RTB-AAR-Luecke, siehe §5 |
| `ClearToLand`, ca. 204118 | wirkt nur auf bestehenden Holding-Zustand/Flag | kein Ersatz fuer die durch Refuel ersetzte Recovery-Route |
| `SetProhibitAfterburner`, ca. 203626 / 178624 | oeffentliche gruppen-/missionsbezogene Konfiguration vorhanden | kein eigener Throttle-/Wingman-Controller erforderlich |
| `TaskOrbit`, ca. 52571 | vierter Parameter erzeugt RACE_TRACK; x/z werden zu DCS x/y | vorhandene eng begrenzte A5-Ausnahme beibehalten, keine neue globale Erweiterung |

Offizielle Demo geprueft: [AID-A2G-363 CAS Airplanes Patrol Refuel](https://github.com/FlightControl-Master/MOOSE_MISSIONS/blob/master/AI/AI_A2G_Dispatcher/AID-A2G-363%20-%20CAS%20Airplanes%20Patrol%20Refuel/AID-A2G-363%20-%20CAS%20Airplanes%20Patrol%20Refuel.lua), Blob `19a13b20a99f36bed73676640c65f504243b2e51`. Sie verwendet den aelteren AI_A2G_DISPATCHER und eine feste Fuel-Grenze. Sie belegt keinen COMMANDER/AIRWING-Two-Ship-Handoff, keine variable Bingo-Bilanz und keine Recovery-AAR nach RTB. Ein Wechsel auf diesen Dispatcher waere kein minimaler Fix.

## 4. Vorgeschlagener kleinster Fuel-Policy-Adapter

Geplanter Ort: `scripts/air-operations/OMW_FixedWingCasFuelPolicy.lua`, als gemeinsame Produktionskomponente komponiert, nicht in den Acceptance-Harness kopiert. Kein eigener DCS-Controller, keine Wegpunktverfolgung, kein zweiter Scheduler fuer MOOSE-FSM-Aufgaben.

Der Adapter bewertet je lebendem Element:

```text
available fuel kg
- predicted burn over the explicitly profiled recovery route
- approach/holding/landing allowance
- required landing/divert reserve where applicable
= recovery margin kg
```

Massgeblich ist die kleinste Marge, nicht ausschliesslich Lead-Fuel oder derselbe feste Prozentwert fuer jede Position. Hinflug, Aufschliessen, AAR-Zugang/Warten und Rueckkehr werden getrennt bilanziert. Der Betrag fuer den Flug zum CAS-Ziel ist kein Bestandteil der reinen Bingo-to-recovery-Menge; er gehoert zur zusaetzlichen Missionsbindung vor Weiterflug.

Verbrauchsprognose: individuelle beobachtete Fuel-Abnahme, explizites Flugprofil und Route; keine uebernommene KC-135-/E-3-Verbrauchsrate. AAR-Zunahme, Shutdown-/Ejection-Werte und fehlende Telemetrie duerfen kein vermeintlich sparsames Modell erzeugen. Augenblicksverbrauch allein und Luftlinie/nominale Geschwindigkeit allein sind unzureichend. Ohne belastbare Eingaben bleibt weitere CAS-Bindung gesperrt; eine laufende physische Gruppe wird dadurch nicht despawnt oder ihr Recovery-Monitor abgeschaltet.

**Reservevorschlag zur ausdruecklichen Entscheidung:** 45 Minuten zusaetzlicher Fuel-Bedarf je Element auf Basis des konservativen profilierten Recovery-Verbrauchs, zusaetzlich zum berechneten Streckenverbrauch. Dies ist ein vorgeschlagener A5-Testparameter, keine historische Vorschrift und keine bereits genehmigte Receiver-Reserve. Der bisherige 45-Minuten-ZEITpuffer ist hierfuer keine bestehende Freigabe. Anflug und Holding duerfen nicht zugleich nochmals voll als separate 45 Minuten doppelt aufgeschlagen werden; die Implementierung muss die Komponenten offen ausweisen. Vorgeschriebener Divert-Bedarf muss gegebenenfalls separat hinzukommen.

Die Policy darf nur bestehende oeffentliche MOOSE-Missions-/Fuel-/Refuel-/RTB-Schnittstellen anfordern. Sie besitzt keine physische Flug-FSM und keinen Ressourcenbestand. Eine Safety-AAR wird durch CAS-Zeitablauf niemals gesperrt. Nach CAS-Endabsicht duerfen keine neuen CAS-Auftraege angenommen werden.

## 5. Post-RTB-AAR: neue, praezise Ausnahme zur Entscheidung

Im gepinnten Source setzt `_LandAtAirbase` `self.currbase=airbase`, obwohl die Gruppe noch fliegt. `Refuel` ersetzt die physische Route; `Refueled` allein baut nicht garantiert den vorherigen Landing-Pfad wieder auf. `onbeforeRTB` und `onbeforeLandAtAirbase` weisen denselben Zielflugplatz bei passendem `currbase` ab. `_CheckGroupDone` prueft ebenfalls dieses Feld. Ein weiterer unbedingter `RTB(home)`-Aufruf ist deshalb kein belastbarer Post-AAR-Fix.

Kein oeffentlicher Setter zum gezielten Zuruecksetzen dieses Zwischenzustands wurde im gepinnten FLIGHTGROUP-API gefunden. `ClearToLand` rekonstruiert keine ersetzte Route. Ein kuenstliches `Airborne`-Ereignis oder ein neues Landungsrouting wird nicht als Scheinloesung eingesetzt.

**Beantragte Minimal-Ausnahme, noch NICHT genehmigt oder implementiert:** einmal pro tatsaechlich beendetem Recovery-AAR-Zyklus ausschliesslich `flight.currbase=nil`, unmittelbar vor dem erneuten oeffentlichen `flight:RTB(destination)`.

Zwingende Guards:

1. Dieselbe physische MOOSE-FLIGHTGROUP hat vorher ein echtes RTB-Ereignis und danach ein echtes Refuel-/Refueled-Ereignis durchlaufen.
2. Recovery-Absicht ist final; es existiert kein fortzusetzender CAS-Auftrag.
3. Die ueberlebenden Elemente sind tatsaechlich airborne; kein bestaetigter Land-/Asset-Return-Zustand wird geloescht.
4. Der gespeicherte `currbase` entspricht genau dem weiter gueltigen Recovery-Ziel; homebase, destbase, legion, cohort, Aufgaben-/Ressourcen-IDs und alle anderen MOOSE-Interna bleiben unangetastet.
5. Pro Zyklus idempotent protokollieren; MOOSE fuehrt danach RTB/Landing/Return selbst aus. Keine direkte `_LandAtAirbase`-Nutzung, kein Moose.lua-Patch.

Die bestehende Owner-Ausnahme fuer `missionHoldingCoord=nil` genehmigt diese neue Feldmutation ausdruecklich NICHT. Falls ein nachweislich geeigneter oeffentlicher Weg gefunden wird, entfaellt die interne Ausnahme; eine solche Alternative muss denselben Lifecycle erhalten.

## 6. Weitere Aenderungen im selben Korrektursatz

- Departure-Staging pro Basis fest konfigurieren und anhand vorhandener AIP-/Mission-/Terrain-Evidenz begruenden. Die bisherige Acht-Richtungs-Minimum-Heuristik entfaellt. Keine jetzt erfundenen safe coordinates, kein pauschaler 5-/13-NM-Track fuer beide Basen.
- F-16/F-15E: oeffentliche Afterburner-Restriktion fuer Departure/Join vorschlagen; Wiederfreigabe gemaess Missionsprofil. DCS muss die tatsaechliche Wirkung und Formation bestaetigen. Fuel-Logs allein beweisen keinen Nachbrennerzustand.
- CAS-Endabsicht, Mission-Closure-Anfrage und bestaetigtes RTB getrennt loggen. Aktiven CAS kontrolliert ueber bestehende oeffentliche MOOSE-Cancel-/Done-Ereignisse schliessen, statt einen RTB-Request bei laufendem Task als vollzogen zu behandeln.
- Tankerzugang mit individueller Fuel-/Zeitmarge bewerten; `distance < homeDistance` nicht als pauschale Sicherheitsbedingung verwenden. A-10-Kandidaten schliessen KRUSTY ein. Aktiver kompatibler Tanker ist noch kein Beweis fuer erreichbare Aufnahme-/Fuel-/Zeitkapazitaet. Reserve-Tracks nur ueber bestehenden MissionDemand-Vertrag, kein automatisches fremdes Reserve-Tanker-Tasking.
- CAS-Ausfuehrung, AO-/Standby-Geometrie und echte Two-Ship-Aufenthaltszeit trennen. Die F-15E-121-Minuten-Differenz ist kein belegter reiner Transit. Der 5-NM-Beobachtungskreis wird nicht ohne Geometrienachweis vergroessert, um ein PASS zu erzeugen.
- Individuelle Position/AGL/MSL/Fuel/Geschwindigkeit und echte aktuelle Airborne-/Land-Zustaende beobachten; historische Takeoff-Zaehler entsprechend benennen. Boolean `false` nicht durch Lua-`and/or` zu `unknown` umdeuten.
- `OnAfterElementLanded` plus exact `LegionAssetReturned` mit Flight-/Asset-Identitaet korrelieren. Spaeteres Despawn nach Return ist Cleanup, kein neuer Verlust.

## 7. Pruefung und ein integrierter DCS-Test

Vor Build: genehmigte Grenzen dokumentieren; Lua-Syntax; meaningful Policy-Tests fuer unterschiedliche Elementverbraeuche, Route/Reserve, Betankung, ungueltige Daten und unveraenderliche Sortieuhr; Source-Replay der realen A5-4-Sicherheitsverletzungen; voller Diff; Dokumentvalidator. Replay ist keine DCS-Validierung und beweist keine neue Flugtrajektorie.

Erst danach neuer Builder/Remote-Commit, echter Owner-Build und SHA256-Kette. Ein gemeinsamer DCS-Lauf prueft alle drei Two-Ships. Fruehe FAIL-/Stop-Kriterien: ungesicherte Fuel-to-land-/Tanker-Marge, ungeeigneter Departure-Pfad, schwere AAR-Trennung, keine echte Closure-/RTB-Bestaetigung oder drohender Verlust. Das FAIL stoppt keine notwendige Recovery-Beobachtung.

PASS erfordert sechs individuelle Landungen beziehungsweise separat dokumentierten genehmigten Divert, exakte Asset-Rueckgaben, keine neue CAS-Fortsetzung nach Final-Recovery, erlaubte Safety-AAR und vollstaendige reale Provenienz. Vor dieser Owner-Acceptance bleibt A5-5 DCS_PENDING.

Reviewstand dieses Dokumentationssatzes: `python3 tools/validate_documentation.py .` mit 0 Fehlern / 0 Warnungen; `git diff --check` ohne Befund. Hashes und Debrief-Elementereignisse wurden erneut aus den Originalanhaengen berechnet/geparst: drei individuelle Landungen, drei individuelle Abstuerze und 1020 s zwischen A-10-RTB-Anforderung und RTB-Ereignis. Acht bereits im Ausgangsbranch vorhandene Metadatenfehler in vier unmittelbar zugehoerigen A5-/Research-Dokumenten wurden ohne Aenderung ihrer fachlichen Ergebnisse korrigiert. Kein Lua-/Builder-/MIZ-Code geaendert, daher kein neuer Lua-/Build-/DCS-Test behauptet.

## 8. Entscheidungsvorlage

Beantragt wird eine gemeinsame ausdrueckliche Freigabe fuer:

1. den beschriebenen minimalen Fuel-Policy-Adapter ueber oeffentlichen MOOSE-Schnittstellen;
2. den vorgeschlagenen 45-Minuten-Fuel-Zuschlag als initialen A5-Testparameter gemaess §4;
3. ausschliesslich die in §5 begrenzte `currbase=nil`-Mutation nach bestaetigter Post-RTB-Recovery-AAR, falls kein tragfaehiger oeffentlicher Pfad nachgewiesen wird.

Das ist keine Freigabe fuer eigene Flugcontroller, weitere MOOSE-Interna, einen Patch an Moose.lua, MIZ-Aenderungen, automatische Produktionsabnahme oder einen neuen DCS-Test ohne vorherigen Source-/Build-/Hash-Preflight.
