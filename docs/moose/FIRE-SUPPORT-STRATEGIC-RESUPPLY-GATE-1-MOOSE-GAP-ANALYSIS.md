---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE1-GAP-ANALYSIS
status: PLANNED
document_class: TECHNICAL_GAP_ANALYSIS
owning_policy: OMW-GOV-001
authoritative_for:
  - Gate-1 MOOSE-first gap analysis for Guard, QRF, ARTY, CAS, ground resupply and air resupply
  - source-reviewed MOOSE candidates and verified limitations for the future site-independent Fire Support / Strategic Resupply base
  - smallest permitted integration boundary before any productive Lua implementation
not_authoritative_for:
  - DCS runtime acceptance
  - approval of Native-DCS, private-MOOSE or parallel-dispatch fallback implementations
  - site-specific tactical timings, routes or resource quantities
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Gate 1 – MOOSE-First-Gap-Analyse für Fire Support und Strategic Resupply

## 1. Zweck und Gate-Grenze

Dieses Dokument erfüllt Gate 1 aus `OMW-HANDOFF-FIRE-SUPPORT-STRATEGIC-RESUPPLY-BASE-20260911` für die sechs getrennt zu prüfenden Fähigkeiten:

```text
Guard
QRF
ARTY
CAS
Ground Resupply
Air Resupply
```

Gate 1 ist ausschließlich Quellen-, Architektur- und Integrationsanalyse. Es wird kein produktiver Lua-Code erzeugt und keine `.miz` geändert.

Die Ressourcenautorität folgt `OMW-ADR-0008-FIRE-SUPPORT-STRATEGIC-RESUPPLY-RESOURCE-AUTHORITY`:

```text
MissionDemand / fachlicher Bedarf
-> öffentliche MOOSE-Organisation / Auftrag / Transport
-> MOOSE selektiert und rekrutiert operative Assets
-> MOOSE / DCS führt physisch aus
-> bestätigtes physisches Lifecycle-Ereignis
-> idempotente strategische Buchung
```

Damit ist jede OMW-Kandidatenliste oder operative Asset-Vorselektion vor MOOSE für diesen Scope ausgeschlossen.

## 2. Geprüfte Provenienz und Quellen

Verbindlicher MOOSE-Stand:

```text
MOOSE release:       2.9.18
MOOSE commit:        73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256:   E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Geprüft wurden insbesondere:

```text
docs/26-moose-first-development-policy.md
docs/moose/VERSION-AND-SOURCES.md
docs/moose/PROJECT-CLASS-INDEX.md
docs/moose/VERIFIED-METHODS.md
docs/moose/GROUND-OPERATIONS.md
docs/moose/MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md
docs/moose/STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md
docs/moose/AIR-TASKING-C2-LIFECYCLE.md
docs/moose/MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md
docs/moose/GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md
docs/adr/0008-fire-support-strategic-resupply-resource-authority.md
```

Zusätzlich wurden die tatsächlich verwendete `Moose.lua` und die bereits dokumentierten offiziellen MOOSE-Beispielprüfungen herangezogen.

Wichtige gemeinsame Projektgrenze:

```text
CHIEF = REJECTED_FOR_PROJECT_USE
COMMANDER = bevorzugte projektweite Aggregations-/Rekrutierungsschicht
```

Der gepinnte MOOSE-Source enthält CHIEF-Funktionalität. Das macht CHIEF jedoch nicht zu einem OMW-Produktionskandidaten. Für diesen Gate-1-Scope wird keine bestehende Projektentscheidung zugunsten von CHIEF wieder geöffnet.

## 3. Gemeinsame Source-Befunde

Der gepinnte Source bestätigt den für die Base benötigten Grundmechanismus:

```text
COMMANDER:CheckMissionQueue()
-> RecruitAssetsForMission(mission)
-> Auswahl geeigneter Assets / Legions
-> MissionAssign(...)
```

Damit ist MOOSE selbst die operative Rekrutierungsinstanz, wenn mehrere registrierte AIRWINGs oder BRIGADEs für einen Bedarf in Frage kommen.

Weiterhin source-verifiziert:

```text
COHORT:AddMissionCapability(...)
LEGION / AIRWING / BRIGADE mission queues
AUFTRAG:SetTime(...)
AUFTRAG:AddConditionStart(...)
AUFTRAG:AddConditionSuccess(...)
AUFTRAG:AddConditionFailure(...)
AUFTRAG:Cancel()
OPSTRANSPORT:SetTime(...)
OPSTRANSPORT:AddConditionStart(...)
OPSTRANSPORT:Cancel()
```

Für noch beim COMMANDER geplante und fachlich obsolet gewordene AUFTRAGs bleibt der bereits verbindlich dokumentierte minimale OMW-Lifecycle-Adapter zulässig:

```text
Incident-Ende / fachliche Expiry
-> AUFTRAG:Cancel()
```

Dieser Adapter darf weder Asset-Selektion noch Rekrutierung noch eine zweite Queue übernehmen.

## 4. Zusammenfassung

| Fähigkeit | Primärer MOOSE-Pfad | Gate-1-Ergebnis |
|---|---|---|
| Guard | `COMMANDER -> BRIGADE -> PLATOON/COHORT -> AUFTRAG:NewONGUARD/NewARMOREDGUARD` | MOOSE-native Zusammensetzung vorhanden; kein eigener Guard-FSM erforderlich |
| QRF | `COMMANDER -> BRIGADE -> PLATOON/COHORT -> passender Ground-AUFTRAG` | MOOSE-native Rekrutierung vorhanden; QRF ist OMW-Fachrolle, kein fehlendes Frameworkobjekt |
| ARTY | `COMMANDER -> BRIGADE/PLATOON -> AUFTRAG:NewARTY` oder bereits konfigurierte `ARTY`-Instanz im festen Batterie-Scope | generische Rekrutierung und feste Batterie sind zu trennen; dynamische Mehrbatterie-Acceptance offen |
| CAS | `COMMANDER -> AIRWING/SQUADRON -> AUFTRAG CAS/CASENHANCED/PATROLZONE` | native Mehr-AIRWING-Rekrutierung vorhanden; generische OMW-Vorselektion entfällt |
| Ground Resupply | je Ressourcendomäne `BRIGADE/PLATOON/ARMYGROUP + AUFTRAG` oder `OPSTRANSPORT`; DCS-`STORAGE` für native Stores | kein Einheitsmodell für META- und DCS-Stores; Auswahl des nativen Modells ist Daten-/Ressourcenvertrag |
| Air Resupply | `COMMANDER/AIRWING + AUFTRAG` für abstrakte META-Carrier-Repräsentation oder `OPSTRANSPORT` für reales Cargo/STORAGE | native Kandidaten vorhanden; generischer OPSTRANSPORT-Air-Scope noch DCS-testpflichtig |

Keiner dieser Befunde rechtfertigt derzeit einen Native-DCS-Dispatcher, eine eigene Asset-Auswahl oder eine private MOOSE-Queue-Manipulation.

## 5. Guard

```yaml
requirement: >-
  Einen fachlich angeforderten lokalen Sicherungsbedarf an einer Installation als
  eigenständige Support-Fähigkeit an MOOSE übergeben. MOOSE soll ein geeignetes
  Ground-Asset aus den registrierten operativen Pools auswählen, materialisieren,
  zum Sicherungsort führen und den Missionslifecycle besitzen.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "PROJECT-CLASS-INDEX.md"
  - "GROUND-OPERATIONS.md"
  - "AIR-TASKING-C2-LIFECYCLE.md"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "COMMANDER:AddBrigade / AddMission / RecruitAssetsForMission"
  - "BRIGADE / PLATOON / COHORT capability and mission queue"
  - "COHORT:AddMissionCapability"
  - "AUFTRAG:NewONGUARD"
  - "AUFTRAG:NewARMOREDGUARD"
  - "AUFTRAG:NewPATROLZONE"
  - "AUFTRAG:SetTime / Cancel"
moose_source_locations:
  - "COMMANDER:CheckMissionQueue / RecruitAssetsForMission in pinned Moose.lua"
  - "AUFTRAG NewONGUARD / NewARMOREDGUARD / NewPATROLZONE in pinned Moose.lua"
  - "PLATOON inherits COHORT in pinned Moose.lua"
official_examples_checked:
  - "OPS - Brigade/Brigade - 010 - Patrol Mission"
  - "WHS-020 - Self Propelled Ground Troops (Warehouse evidence only)"
verified_limitation: >-
  MOOSE besitzt keine OMW-spezifische Fachklasse namens Guard. Das ist keine
  Frameworklücke: die Fachrolle kann mit Ground-AUFTRAG und BRIGADE/PLATOON-
  Rekrutierung ausgedrückt werden. Ground-AI-Pathfinding, konkrete Sicherungsgeometrie
  und beobachtbarer Return bleiben standortbezogen DCS-testpflichtig.
smallest_required_fallback: >-
  Kein Nicht-MOOSE-Fallback erforderlich. Ein kleiner Adapter darf ausschließlich
  den Guard-Bedarf in den passenden öffentlichen AUFTRAG übersetzen, Gültigkeit/
  Cancel weiterreichen und Lifecycle-Ereignisse korrelieren. Eine eigene
  Asset-Selektion oder Queue ist verboten.
integration_with_moose: >-
  Guard-Demand -> Ground-AUFTRAG -> COMMANDER oder bewusst engere BRIGADE-Grenze ->
  MOOSE COHORT-Rekrutierung -> ARMYGROUP -> DCS. Die Wahl der konkreten Einheit
  bleibt bei MOOSE.
planned_acceptance_test: >-
  Zwei Guard-fähige Ground-Pools registrieren; einen Pool temporär binden;
  verifizieren, dass MOOSE ohne OMW-Kandidatenliste ein geeignetes Asset rekrutiert.
  Zusätzlich: kein Asset verfügbar -> Auftrag wartet; spätere Verfügbarkeit -> Start
  nur bei weiterhin gültigem Bedarf; Incident-Ende vor Rekrutierung -> nativer Cancel;
  keine Teleports oder sichtbare Reconstitution.
```

## 6. QRF

```yaml
requirement: >-
  Einen zeitkritischen Ground-Reaktionsbedarf an MOOSE übergeben, ohne eine zweite
  QRF-Assetliste, Retry-Queue oder projektspezifische Rekrutierungslogik zu bauen.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "PROJECT-CLASS-INDEX.md"
  - "GROUND-OPERATIONS.md"
  - "AIR-TASKING-C2-LIFECYCLE.md"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "COMMANDER:AddMission / RecruitAssetsForMission"
  - "BRIGADE / PLATOON / COHORT"
  - "COHORT:AddMissionCapability / SetMissionRange / CanMission"
  - "AUFTRAG:NewPATROLZONE"
  - "AUFTRAG:NewONGUARD / NewARMOREDGUARD"
  - "AUFTRAG:SetTime / AddConditionFailure / Cancel"
moose_source_locations:
  - "COMMANDER recruitment path in pinned Moose.lua"
  - "COHORT capability/range path in pinned Moose.lua"
  - "Ground AUFTRAG constructors in pinned Moose.lua"
official_examples_checked:
  - "OPS - Brigade/Brigade - 010 - Patrol Mission"
verified_limitation: >-
  Es gibt keine separate OMW-QRF-Klasse in MOOSE. QRF ist eine fachliche Rolle.
  Welcher öffentliche Ground-AUFTRAG die konkrete QRF-Taktik ausdrückt, hängt vom
  Einsatzprofil ab. Exakte Straßen-/Gebirgsroute und DCS-Ground-AI-Verhalten sind
  nicht durch den Klassenvertrag garantiert.
smallest_required_fallback: >-
  Kein eigener QRF-FSM. Der kleinste zulässige Adapter mappt QRF-Demand auf einen
  vorhandenen Ground-AUFTRAG und vorhandene owner-authored Route/Anchors. Erst falls
  eine erforderliche Route mit öffentlichen MOOSE-Mitteln nachweislich nicht
  darstellbar ist, wäre eine separate Ausnahmeentscheidung erforderlich.
integration_with_moose: >-
  QRF-Demand -> AUFTRAG + Capability/Range -> COMMANDER -> BRIGADE/PLATOON recruitment
  -> ARMYGROUP execution. OMW setzt fachliche Priorität/Gültigkeit, nicht das Asset.
planned_acceptance_test: >-
  Mehrere QRF-fähige PLATOONs mit unterschiedlicher Verfügbarkeit; native Auswahl,
  Queue und spätere Rekrutierung prüfen. Route zu vorbereitetem Response-Anchor,
  Missionende, mobile Rückkehr/Handoff und Cancel bei fachlicher Expiry physisch in
  DCS prüfen. Keine sichtbaren Teleports.
```

## 7. ARTY

```yaml
requirement: >-
  Indirekten Feuerunterstützungsbedarf aus einem Incident an MOOSE übergeben. Für
  die generische Base darf OMW keine konkrete Batterie vor MOOSE auswählen.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "PROJECT-CLASS-INDEX.md"
  - "VERIFIED-METHODS.md"
  - "GROUND-OPERATIONS.md"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "COMMANDER / BRIGADE / PLATOON / COHORT recruitment"
  - "AUFTRAG:NewARTY"
  - "ARTY:AssignTargetCoord / AssignAttackGroup / RemoveTarget / SetTimeToShot"
  - "ARTY rearm callbacks and SetRearmingGroup paths"
  - "AUFTRAG:NewAMMOSUPPLY"
moose_source_locations:
  - "AUFTRAG:NewARTY in pinned Moose.lua"
  - "ARTY target queue and rearm paths in pinned Moose.lua"
  - "BRIGADE mission queue and rearming-zone AMMOSUPPLY generation in pinned Moose.lua"
official_examples_checked:
  - "Existing project review of MOOSE ARTY / AmmoTruck examples"
  - "Ground Brigade example set used as composition evidence"
verified_limitation: >-
  Der bestehende OMW_FobAttackFunctionalArtyDispatchAdapter besitzt bewusst eine
  bereits ausgewählte caller-owned ARTY-Instanz und ist daher kein generischer
  Mehrbatterie-Recruiter. Die existierende DCS-Acceptance belegt den festen
  Bostick-Batterie-/Rearm-Scope, nicht COMMANDER-gesteuerte Auswahl aus mehreren
  Batterien. Reichweite, Munition, Feuererfolg und CAS-Deconfliction müssen im
  generischen Pfad separat akzeptiert werden.
smallest_required_fallback: >-
  Kein paralleler Batterieselector. Primärer generischer Kandidat ist
  AUFTRAG:NewARTY über COMMANDER/BRIGADE/PLATOON. Der bestehende Functional-ARTY-
  Adapter bleibt nur für einen bewusst fest konfigurierten Batterie-Scope nutzbar.
  Eine zusätzliche Eigenlogik ist vorerst nicht genehmigt.
integration_with_moose: >-
  ARTY-Demand -> AUFTRAG:NewARTY -> COMMANDER -> fähige BRIGADE/PLATOON-Rekrutierung
  -> ARMYGROUP/DCS fire task. Alternativ bei explizit fixer Batterie: vorhandene ARTY-
  Instanz und deren native Target-Queue. Beide Betriebsmodelle dürfen nicht
  unbemerkt vermischt werden.
planned_acceptance_test: >-
  Mindestens zwei ARTY-fähige Batteriepools; eine Batterie nicht verfügbar oder
  ungeeignet; MOOSE-Rekrutierung ohne OMW-Vorselektion nachweisen. Feuerauftrag,
  No-shot/Timeout, Cancel, Munitions-/Rearm-Grenze und CAS-on-station-Deconfliction
  separat prüfen. Bestehenden Fixed-Battery-Test als Regression erhalten.
```

## 8. CAS

```yaml
requirement: >-
  Einen CAS-Bedarf an die gemeinsame operative MOOSE-Organisation übergeben, sodass
  MOOSE aus den registrierten AIRWINGs/SQUADRONs geeignete und verfügbare Assets
  rekrutiert. OMW darf keine Typ-/Squadron-/ETA-Kandidatenmatrix vorwegnehmen.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "PROJECT-CLASS-INDEX.md"
  - "VERIFIED-METHODS.md"
  - "MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md"
  - "AIR-TASKING-C2-LIFECYCLE.md"
  - "STAGE3-CAS-Tactical/Lifecycle references"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "COMMANDER:AddAirwing / AddMission / RecruitAssetsForMission"
  - "AIRWING / SQUADRON / COHORT capabilities"
  - "AUFTRAG:NewCAS / NewCASENHANCED / NewPATROLZONE"
  - "AUFTRAG:SetEngageDetected"
  - "AUFTRAG ingress / waypoint / egress methods"
  - "AIRWING:AddMission"
  - "FLIGHTGROUP lifecycle callbacks"
moose_source_locations:
  - "COMMANDER:CheckMissionQueue and RecruitAssetsForMission in pinned Moose.lua"
  - "CAS/PATROLZONE constructors in pinned Moose.lua"
  - "AUFTRAG cancel lifecycle in pinned Moose.lua"
official_examples_checked:
  - "OPS - Airwing/Airwing - 010 - Fighter Wing"
  - "OPS - Commander/Commander - 020 - Bombing with Airwings"
verified_limitation: >-
  Der aktuelle OMW_FobAttackCasDispatchAdapter benötigt genau ein AIRWING und kann
  zusätzlich AssignSquadrons() setzen. Das ist für ein historisches/festes Testfixture
  zulässig, aber für die generische Base zu eng und würde bei mehreren zulässigen
  AIRWINGs die MOOSE-Selektion vorwegnehmen. Der dynamische Gebirgskorridor bleibt
  eine separate owner-authored Missionsgeometrie und ist nicht identisch mit
  Asset-Rekrutierung.
smallest_required_fallback: >-
  Kein eigener CAS-Selector. Für die generische Base AUFTRAG an COMMANDER übergeben.
  Direkter AIRWING:AddMission-Pfad ist nur zulässig, wenn die konfigurierte operative
  Besitz-/Organisationsgrenze absichtlich genau dieses eine AIRWING ist. Keine
  AssignSquadrons-Vorselektion im generischen Mehrpool-Pfad.
integration_with_moose: >-
  CAS-Demand -> CAS/PATROLZONE AUFTRAG mit fachlicher Geometrie/Gültigkeit -> BLUE
  COMMANDER -> native AIRWING/SQUADRON-Rekrutierung -> FLIGHTGROUP -> DCS -> physische
  Recovery -> strategisches Settlement.
planned_acceptance_test: >-
  Zwei oder mehr CAS-fähige AIRWINGs registrieren. Primärer Kandidat gebunden/nicht
  verfügbar, anderer verfügbar: MOOSE muss selbst rekrutieren. Alle Assets gebunden:
  Auftrag bleibt geplant und startet nach Rückkehr nur bei weiter gültigem Bedarf.
  Expiry/Incident-Ende -> Cancel. On-station, eigener Sensorpfad, dynamischer
  Owner-Korridor, physische Heimlandung und LegionAssetReturned als getrennte
  Nachweise prüfen.
```

## 9. Ground Resupply

```yaml
requirement: >-
  Bodenversorgung für unterschiedliche Ressourcendomänen physisch darstellen, ohne
  MOOSE/DCS-Bestand und CampaignState als zwei unabhängige Autoritäten zu führen.
  META-Ressourcen und native DCS-STORAGE-Güter dürfen nicht künstlich auf dasselbe
  Transportmodell gezwungen werden.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "GROUND-OPERATIONS.md"
  - "MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md"
  - "STORAGE-WAREHOUSE-RESOURCE-FOUNDATION.md"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "BRIGADE / PLATOON / ARMYGROUP + Ground AUFTRAG"
  - "WAREHOUSE:AddRequest / SetSpawnZone"
  - "AUFTRAG:NewAMMOSUPPLY / NewFUELSUPPLY"
  - "OPSTRANSPORT:New / AddPathTransport / SetRequiredCarriers / SetTime / Cancel"
  - "OPSTRANSPORT:AddCargoStorage"
  - "STORAGE item/liquid methods"
moose_source_locations:
  - "WAREHOUSE request/self-request and OPSTRANSPORT creation paths in pinned Moose.lua"
  - "OPSTRANSPORT troop/STORAGE cargo implementation in pinned Moose.lua"
  - "BRIGADE AMMOSUPPLY/FUELSUPPLY auto-mission path in pinned Moose.lua"
official_examples_checked:
  - "WHS-020 - Self Propelled Ground Troops"
  - "WAREHOUSE off-road path/self-request examples embedded in pinned MOOSE source"
verified_limitation: >-
  Es gibt keinen einzigen korrekten Resupply-Pfad für alle Ressourcenklassen.
  Abstracte META-Ressourcen wie Personal oder Verpflegung sind keine automatischen
  MOOSE-Cargoobjekte. DCS-STORAGE-Güter können dagegen über OPSTRANSPORT:AddCargoStorage
  physisch/nativ repräsentiert werden. AddPathTransport besitzt im gepinnten Source
  einen Reversed-Parameter, dessen geprüfter Funktionskörper ihn nicht auswertet.
  Sichtbares coordinate-based Cargo-Unload/Respawn und Ground-AI-Routing benötigen
  eigene DCS-Acceptance. Für rohe WAREHOUSE:AddRequest-Anforderungen bleibt die
  individuelle öffentliche Nullbestand-Expiry/Cancel-Grenze offen.
smallest_required_fallback: >-
  Kein eigener Resupply-Dispatcher. Pro Ressourcenklasse wird der kleinste native
  MOOSE-Pfad gewählt: META/abstrakte Menge -> MOOSE-Carrier als physische
  Repräsentation bei strategischer CampaignState-Buchung; reale DCS-STORAGE-Güter ->
  OPSTRANSPORT/STORAGE. Exakte Routing- oder Warehouse-Expiry-Ergänzungen bleiben
  gesperrt, bis eine konkrete MOOSE-Lücke separat belegt und vom Projektinhaber
  genehmigt wird.
integration_with_moose: >-
  Resource contract entscheidet zwischen (A) Ground AUFTRAG mit BRIGADE/PLATOON/
  ARMYGROUP für abstrakten Cargo-Transfer oder (B) OPSTRANSPORT mit realem Cargo bzw.
  STORAGE. MOOSE rekrutiert Carrier/Assets und besitzt die physische Ausführung;
  strategisches Settlement erfolgt nur aus bestätigtem Lifecycle-Ereignis.
planned_acceptance_test: >-
  Getrennte Tests für META-PERSONNEL/SUPPLY und native STORAGE-AMMO/FUEL. Für beide:
  MOOSE-Carrier-Auswahl, wartender Bedarf, Verlust, bestätigte Lieferung und
  idempotentes Settlement. Zusätzlich Ground-Route, sichtbares Materialisieren/
  Unload, Return/Handoff sowie WAREHOUSE permanent-invalid versus temporary-blocked
  Verhalten prüfen. Die offene Nullbestand-Expiry darf nicht durch private APIs
  kaschiert werden.
```

## 10. Air Resupply

```yaml
requirement: >-
  Luftversorgung zu einem vorbereiteten LZ-/Zielknoten durch MOOSE ausführen lassen,
  mit nativer Auswahl eines geeigneten Carriers und ohne CampaignState als operative
  Aircraft-/Carrier-Selektionsinstanz.
moose_version:
  release: "2.9.18"
  commit: "73d3ed119cd9e7e3f2cfcabbaa34513d30529b54"
  moose_lua_sha256: "E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915"
moose_documentation_checked:
  - "GROUND-AIR-PERSONNEL-RESUPPLY-STAGE-1D-P-ACCEPTANCE-4-FINAL.md"
  - "PROJECT-CLASS-INDEX.md"
  - "VERIFIED-METHODS.md"
  - "MISSION-DEMAND-RESUPPLY-CAS-SOURCE-REVIEW.md"
  - "MOOSE-SUPPORT-REQUEST-LIFECYCLE-LAW.md"
moose_classes_and_methods_evaluated:
  - "COMMANDER / AIRWING / SQUADRON / COHORT recruitment"
  - "AUFTRAG:NewLANDATCOORDINATE"
  - "AIRWING:AddMission"
  - "PATHLINE and FLIGHTGROUP waypoint/lifecycle methods"
  - "OPSTRANSPORT with helicopter/airplane carriers"
  - "OPSTRANSPORT:AddCargoStorage"
  - "OPSTRANSPORT:SetTime / Cancel"
moose_source_locations:
  - "OPSTRANSPORT carrier/cargo implementation in pinned Moose.lua"
  - "COMMANDER recruitment path in pinned Moose.lua"
  - "accepted Stage 1D-P source/runtime evidence for LANDATCOORDINATE/PATHLINE"
official_examples_checked:
  - "Existing OPSTRANSPORT source examples for troop and STORAGE transport"
  - "OPS - Airwing/Airwing - 010 - Fighter Wing"
verified_limitation: >-
  Stage 1D-P beweist einen exakt gebundenen Jalalabad-CH-47-META-PERSONNEL-Pfad,
  nicht generische Carrier-Auswahl über mehrere AIRWINGs und nicht generischen
  OPSTRANSPORT-Air-Cargo. OPSTRANSPORT ist projektweit weiterhin SOURCE_REVIEWED.
  Der vorhandene OMW_OpsTransportCorridorAdapter ergänzt bei Feld-LZs öffentliche
  FLIGHTGROUP-Waypoints, ersetzt aber den MOOSE-Transportlifecycle nicht und benötigt
  für den generischen Scope eigene DCS-Acceptance.
smallest_required_fallback: >-
  Kein eigener Airlift-Dispatcher. Abstrakte META-Lieferung kann den akzeptierten
  AUFTRAG/LANDATCOORDINATE-Ansatz generalisieren, jedoch mit COMMANDER-Rekrutierung,
  wenn mehrere AIRWINGs zulässig sind. Reale Group-/STORAGE-Cargo nutzt vorrangig
  OPSTRANSPORT. Nur eine nachgewiesene Feld-LZ-/Routing-Lücke darf durch den bereits
  eng begrenzten öffentlichen Waypoint-Adapter ergänzt werden.
integration_with_moose: >-
  Air-resupply demand -> passender AUFTRAG oder OPSTRANSPORT -> COMMANDER/AIRWING
  recruitment -> FLIGHTGROUP carrier -> owner-authored corridor/LZ -> bestätigtes
  TaskDone/Delivered-Ereignis je Transportmodell -> idempotentes Settlement ->
  physische Rückkehr.
planned_acceptance_test: >-
  Mehrere geeignete Airlift-Pools mit mindestens einem gebundenen/unverfügbaren
  Carrier; MOOSE-Auswahl und Queue nachweisen. Je Ressourcenmodell Delivery-Ereignis
  korrekt unterscheiden. Feld-LZ, Route, Verlust, Cancel vor Rekrutierung,
  physische Heimlandung und Return-Event prüfen. Stage-1D-P als Regression erhalten.
```

## 11. Gate-1-Entscheidungen und offene Ausnahmen

Gate 1 findet für alle sechs Fähigkeiten mindestens einen MOOSE-nativen primären Integrationspfad. Deshalb wird **keine** neue Nicht-MOOSE-/Native-DCS-Ausnahme beantragt.

Explizit offen und weiterhin genehmigungspflichtig bleiben:

```text
1. exakte Ground-Routing-Ergänzung, falls öffentliche MOOSE-Routen den konkreten
   Produktionsvertrag nachweislich nicht erfüllen;
2. eine individuelle Expiry-/Cancel-Ergänzung für rohe WAREHOUSE:AddRequest-Requests,
   falls der produktive Resupply-Pfad diese überhaupt benötigt;
3. jede Verwendung privater WAREHOUSE-Interna außerhalb der bereits exakt
   acceptancegebundenen historischen Ausnahme;
4. jede neue sichtbare Reconstitution-/Respawn-Lösung außerhalb bestätigter MOOSE-
   Lifecycle-Pfade.
```

Diese Punkte sind **keine** stillschweigend genehmigten Implementierungsaufträge.

## 12. Bestehende Adapter – Gate-1-Reuse-Klassifikation

```text
OMW_FobAttackFireSupportDemandPolicy.lua
  -> REUSE: fachlicher Demand, keine Asset-Selektion

OMW_FobAttackFunctionalArtyDispatchAdapter.lua
  -> REUSE_FOR_FIXED_BATTERY_ONLY
     nicht generischer Batterie-Recruiter

OMW_FobAttackCasDispatchAdapter.lua
  -> REUSE_WITH_REFACTOR_BOUNDARY
     aktueller one-AIRWING / optional AssignSquadrons-Pfad ist Testfixture-tauglich,
     aber nicht der generische COMMANDER-Mehrpool-Pfad

OMW_HelicopterFlightPathCorridor.lua
  -> REUSE: owner-authored Route-/Waypoint-Adapter innerhalb dokumentierter Grenzen

OMW_HelicopterCasTacticalCorridor.lua
  -> REUSE_AFTER_GENERALIZATION
     Stage-3-/Honaker-Begriffe und 3-4-NM-Testband nicht globalisieren

OMW_OpsTransportCorridorAdapter.lua
  -> CONDITIONAL_REUSE
     nur wenn öffentlicher MOOSE-Transportlifecycle erhalten bleibt und Feld-LZ-
     Route die Ergänzung tatsächlich benötigt

OMW_FixedFireSupportAmmoSupport.lua
  -> REUSE_FOR_FIXED_LOCAL_AMMO_SUPPORT
     dedizierter Materializer, keine generische strategische Resupply-Autorität
```

## 13. Gate-1-Ergebnis

```yaml
gate_1_status: COMPLETE_SOURCE_REVIEWED
dcs_validated: false
productive_lua_changed: false
miz_changed: false
new_native_dcs_exception_required: false
new_private_moose_exception_required: false
next_gate: GATE_2_DATA_CONTRACT
```

Gate 2 darf auf dieser Analyse den Standort- und Support-Datenvertrag definieren. Es darf weiterhin keine OMW-Asset-Vorselektion, keine Parallelqueue und keine doppelte Ressourcenautorität einführen.
