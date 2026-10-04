---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE
status: PLANNED
document_class: MOOSE_TECHNICAL_NOTE
owning_policy: OMW-GOV-001
authoritative_for:
  - generic Fire Support / Strategic Resupply production package boundary
  - production builder composition contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
---

# Fire Support / Strategic Resupply – Production Base

Status: SOURCE_IMPLEMENTED / QRF-GUARD-CAS-ARTY-TEILPFADE DCS-VALIDIERT / STRATEGIC RESUPPLY UND COMBINED MULTI-DEMAND OFFEN

## Zweck

Der Builder

```text
tools/build-fire-support-strategic-resupply-production-base.ps1
```

erzeugt ein einzelnes, im DCS-Missionsskript ladbares Basispaket fuer die generische Fire-Support-/Strategic-Resupply-Architektur:

```text
mission/fire-support-strategic-resupply/dist/OMW_FireSupStratResupply_Base.lua
```

Das Paket ist ein **Composition Package**, keine fertige missionsspezifische Konfiguration. Es buendelt die vorhandenen Domain-, MOOSE- und Adapterbausteine, legt aber keine fehlenden Missionsparameter stillschweigend fest.

## Exportierter Vertrag

Nach dem Laden stellt das Bundle bereit:

```text
OMW.FireSupStratResupply
OMW.FireSupStratResupply.New(spec)
OMW_FIRE_SUPPORT_STRATEGIC_RESUPPLY_BASE_LOADED = 1
```

`New(spec)` verdrahtet automatisch die im Bundle enthaltenen Module sowie standardmaessig:

```text
SiteRegistry
SupportProfiles
IdContract
```

Missionsspezifische Laufzeitobjekte bleiben Eingaben des Aufrufers, insbesondere BRIGADE-Instanzen, Guard-PATHLINE-/Template-Aufloesung, QRF-Zielkoordinaten, konkrete Alarm-/Perimeterzonen, COMMANDER-Objekte, ARTY-/CAS-Geometrie, CampaignState-/Resource-Store und Transportresolver.

## Gebuendelte Funktionsbereiche

Das Production Base Bundle enthaelt die generische Verdrahtung fuer:

- persistente Guard-Demands und MOOSE-Guard-Lifecycle;
- die eng freigegebene Guard-PATHLINE-Materialisierungsausnahme;
- lokalen QRF-Dispatch ueber MOOSE;
- den autoritativen Installation-Attack-Incident-Pfad;
- optionale physische Alarm-Evidence ueber den vorhandenen MOOSE-`EVENTHANDLER`-/`WEAPON`-Adapter;
- optionale MOOSE-OPSZONE-Perimeter;
- optionale externe ARTY-/CAS-Eskalation ueber COMMANDER;
- strategische Resource-Shortage-Auswertung ohne eigene Ressourcenhoheit;
- Ground-/Air-Resupply ueber MOOSE OPSTRANSPORT/STORAGE;
- bestaetigungsgebundenes, idempotentes CampaignState-Settlement.

## Autoritaetsgrenzen

Der Builder aendert die bindende Ressourcen- und Missionsautoritaet nicht:

```text
CampaignState/store
= strategische Persistenz und Ressourcenhoheit

CampaignState/store
= strategische Persistenz und Ressourcenhoheit ohne parallele operative Assetwahl

MOOSE organisation / AUFTRAG / COMMANDER / BRIGADE / WAREHOUSE / OPSTRANSPORT
= operative Provider-/Asset-Selektion, Rekrutierung und physischer Lifecycle

OMW FireSupStratResupply Base
= Demand-/Incident-Koordination und Adapterverdrahtung
```

Das Bundle folgt ADR 0008 und nimmt keine eigene operative Provider-/Asset-Vorauswahl vor. C2/OMW definiert Bedarf sowie fachliche Missionsanforderungen; MOOSE `COMMANDER`/`LEGION` selektiert innerhalb der konfigurierten Organisationen. Nach der Auswahl muss jedoch das passende owner-authored Ausfuehrungsprofil (Route, Release, Recovery) fuer den tatsaechlich ausgewaehlten Provider gebunden werden.

## Physische Alarm-Evidence

Der bereits vorhandene `OMW_GroundInstallationAlarmEvidenceAdapter` ist nun optional im Production Package verdrahtbar. Er verwendet die in der bindenden Multi-Evidence-Entscheidung bereits source-reviewten MOOSE-Bausteine `EVENTHANDLER`, `EVENTS` und `WEAPON` und speist Evidence ausschliesslich in den bestehenden autoritativen `InstallationIncidentRuntime` ein.

Der Runtime-Vertrag lautet:

```text
alarmEvidence.sites[siteId].alarmZone
+ blueCoalition / redCoalition
+ optional weapon/event tracking configuration
-> OMW_GroundInstallationAlarmEvidenceAdapter
-> InstallationIncidentRuntime:ReportEvidence(...)
-> OMW_GroundInstallationAttackIncident
-> InstallationIncidentBridge
-> Base
```

Die Runtime stellt dafuer bereit:

```text
StartAlarmEvidence()
StopAlarmEvidence()
```

Ohne `alarmEvidence` bleibt die Funktion optional und meldet explizit `ALARM_EVIDENCE_NOT_CONFIGURED`.

Wichtig: Diese Verdrahtung erzeugt **keine** Alarmgeometrie. `alarmZone` muss missionsspezifisch und autoritativ injiziert werden. Ebenso bleibt `shouldTrackWeapon` optional; die Composition startet keine globale hochfrequente Weapon-Verfolgung.

## Missionsgeometrie bleibt injiziert

Der Builder erfindet insbesondere nicht:

```text
Alarmradien
Installationsanker
QRF-Zielkoordinaten
ARTY-Ziele
CAS-Zonen/-Geometrie
Resupply-Routen oder Transportzonen
```

Diese Werte muessen aus den zustaendigen Mission-Editor-/Fachbaselines stammen und werden in die Runtime injiziert.

## ACCESS-Zonen

`ZON_BLUE_GND_*_ACCESS` verbleiben absichtlich im `SiteRegistry`, weil sie zum Convoy-/Access-Vertrag gehoeren koennen. Der Builder prueft jedoch separat, dass die gebuendelten Guard- und Perimeter-Implementierungen keine solchen Zonennamen referenzieren.

Damit gilt weiterhin strikt:

```text
ACCESS = Convoy/Access
ACCESS != Guard
ACCESS != Alarmperimeter
ACCESS != Incidentqualifikation
```

## Incident- und Perimetervertrag

Das Bundle verwendet den reconcilierten Pfad:

```text
MOOSE OPSZONE / physische Installation-Evidence
-> OMW_GroundInstallationAttackIncident
-> OMW_FireSupStratResupply_InstallationIncidentBridge
-> OMW_FireSupStratResupply_Base
-> initial lokale QRF
```

Ein Clear bzw. `OPSZONE:Defeated` ist kein Mission-Ende und schliesst den Installation-Incident nicht automatisch. ARTY/CAS bleiben explizite C2-Eskalation.

## Guard-Materialisierung

Die produktive Ausnahme bleibt auf den bereits vom Projektinhaber freigegebenen engen Scope begrenzt: exakte Guard-Einheitengeometrie am ersten Segment der owner-authored Guard-PATHLINE unmittelbar vor der MOOSE-Warehouse-Materialisierung. Rekrutierung, Assetwahl, PLATOON-/ARMYGROUP-/AUFTRAG-Lifecycle bleiben bei MOOSE.

Diese Ausnahme wird durch das Production Base Bundle weder auf QRF noch auf Alarm-Evidence, ARTY, CAS, Convoys oder Resupply erweitert.

## Build-Schutz

Der Builder:

- prueft alle erforderlichen Quelldateien und deren `SchemaVersion`-Vertrag;
- prueft zentrale Runtime-/Alarm-Evidence-/Materialisierungs-/Incident-/Resupply-Marker;
- verbietet MIST, `MissionScripting.lua`-Manipulation und `os.execute` im gebuendelten Source;
- prueft Guard-/Perimeter-Source separat auf verbotene `ZON_BLUE_GND_*_ACCESS`-Kopplung;
- schreibt UTF-8 ohne BOM;
- veraendert keine `.miz`;
- schreibt Git-Commit, Builder-Version sowie Builder- und Bundle-SHA-256 in die Build-Ausgabe.

## Verifikationsstatus

Der Production-Package-Pfad fuer Six-Site Guard sowie Installation-Incident/QRF ist durch Acceptance 1 und Acceptance 2 auf den dort exakt dokumentierten Branch-/Commit-/Bundle-/Missions-/DCS-/MOOSE-Staenden technisch akzeptiert.

Die neue physische Alarm-Evidence-Verdrahtung ist dagegen zunaechst **SOURCE_REVIEWED / CI-GATED**, aber noch nicht DCS-validiert. Vor einer solchen DCS-Acceptance muss eine Testkonfiguration mit klar als Fixture gekennzeichneter Alarmzone beziehungsweise eine aktuelle autoritative Produktionsgeometrie vorliegen. Historische Stage-3-1000-m-Zonen werden nicht zur Produktionsgeometrie hochgestuft.

Ebenso sind ARTY/CAS und Resupply im Production Package noch nicht als Gesamtpfad DCS-validiert; konkrete taktische beziehungsweise Transportgeometrie wird nicht erfunden.

## Naechstes Base-Gate: Acceptance 6

Die verworfene Honaker Stage-3-Acceptance wird nicht als Nachweis der variablen Base weiterverwendet. Der naechste Runtime-Nachweis konzentriert sich auf die Befehls- und Auswahlkette selbst:

```text
FOB Joyce physical attack
-> production perimeter / installation incident
-> production QRF direct-target response
-> explicit Base CAS escalation
-> generic ExternalSupportRuntime
-> generic CommanderBridge
-> MOOSE COMMANDER across multiple running AIRWINGs
-> runtime-selected provider
-> runtime-selected operational asset / OPSGROUP
```

Der Acceptance-Harness darf keine konkrete Basis, SQUADRON oder Aircraft-Art als CAS-Provider vorgeben. Mindestens zwei CAS-faehige AIRWINGs muessen als reale Kandidaten in demselben COMMANDER registriert sein, damit ein PASS eine tatsaechliche Auswahl und nicht nur einen Ein-Kandidaten-Dispatch belegt.

Der erste Lauf stoppt nach positiver physischer `OpsOnMission`-Evidenz. CAS-Routing, Weapons Employment, RTB, ARTY, Rearm und Strategic Resupply werden bewusst nicht in denselben Lauf gepackt. Damit bleibt der Harness klein und ein Fehler kann eindeutig der Command-/Selection-Kette zugeordnet werden.

Artefakte:

```text
mission/tests/fire-support-strategic-resupply-production-base-runtime/ACCEPTANCE-6.md
mission/tests/fire-support-strategic-resupply-production-base-runtime/src/06-c2-provider-selection-acceptance.lua
tools/build-fire-support-strategic-resupply-production-base-acceptance-6.ps1
```

## Acceptance-6-Ergebnis und korrigierter Base-Weg

Acceptance 6 ist nach realem DCS-Lauf `REJECTED`. Der Harness meldete zu frueh PASS, sobald ein physisches CAS-OPSGROUP auf Mission war. Danach folgten genau die bereits verbotenen Regressionen: direkte Rotary-Wing-Luftlinie statt Owner-Route, FuelLow/Bingo statt regulärer No-Contact-/Supported-Element-Release, direkter niedriger RTB, Verlust eines Assets und keine nachgewiesene physische Recovery des ueberlebenden Assets.

Der naechste Base-Schritt darf deshalb **nicht** wieder nur Dispatch testen. Der minimale gueltige externe-CAS-Vertrag lautet:

```text
installation support requirement
-> C2/OMW mission capability/profile constraints
-> MOOSE COMMANDER/LEGION provider + asset selection
-> bind matching provider/platform execution profile
   - owner route
   - ingress/egress
   - target/detection policy
   - release policy
   - recovery route
   - physical landing/asset return
-> execution evidence
-> release
-> physical recovery
```

Fuer einen Base-Test duerfen unterschiedliche Sites weiterhin unterschiedliche Subsysteme pruefen, z. B. Joyce fuer QRF und ein zweiter geeigneter Standort fuer CAS. Der CAS-Harness darf dabei aber weder Provider noch Lifecycle hardcoden; er darf nur den realen C2/OMW-Auswahlentscheid und dessen gebundenes Profil beobachten.

## Acceptance 7 – naechster Runtime-Gate

Nach dem verworfenen A6-Lauf prueft A7 nicht mehr nur Dispatch. Die Acceptance verbindet die bereits akzeptierte Ground-Base mit dem kompletten Rotary-Wing-CAS-Ausfuehrungsvertrag:

```text
Joyce attack
-> production incident
-> production QRF direct-target response
-> Base CAS demand
-> PATROLZONE_ENGAGE + AIR_ATTACKHELO requirement
-> MOOSE COMMANDER/LEGION provider + asset selection
-> selected-provider owner-route profile bound before MissionAssign completes
-> owner corridor
-> own detection / stable no-contact release
-> reverse owner route
-> physical landing
-> LegionAssetReturned
```

Der generische CAS Factory-Pfad ist dafuer auf Schema 3 angehoben. Neu ist ausschliesslich die Weitergabe vorhandener MOOSE-AUFTRAG-Filter (`SetRequiredAttribute` / `SetRequiredProperty`); es wird keine eigene Asset-Selektion gebaut.

Fail-closed gilt zwingend: waehlt MOOSE einen Provider ohne bekanntes owner-authored Ausfuehrungsprofil, wird `MissionAssign` vor dem LEGION-Request abgewiesen. Ein direkter Flug ist kein Fallback.

Production builder fuer diesen Source-Stand:

```text
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-20
```

## A9 – shared production CAS lifecycle

Nach der Lifecycle-Preservation-Korrektur darf der Acceptance-Harness den CAS-Lifecycle nicht mehr selbst besitzen. Der gemeinsame produktive Pfad ist jetzt:

```text
Base CAS demand
-> CasMissionFactory
-> CommanderBridge
-> MOOSE COMMANDER / LEGION selects provider + asset
-> CasLifecycleRuntime
   -> selected-provider owner profile
   -> owner route / tactical ingress-egress
   -> AUFTRAG executing
   -> own FLIGHTGROUP detection
   -> supported-element + stable no-contact release
   -> CommanderBridge Cancel
   -> reverse route
   -> physical home landing
   -> exact LegionAssetReturned
```

Production source:

```text
scripts/campaign/OMW_FireSupStratResupply_CasLifecycleRuntime.lua
schema OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-LIFECYCLE-RUNTIME-1

scripts/campaign/OMW_FireSupStratResupply_CasReleasePolicy.lua
schema OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-CAS-RELEASE-POLICY-1
```

Production builder:

```text
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-25
```

Der Builder `...-25` bleibt die exakte A9-CAS-Provenienz. Der aktuelle Source-Head nach der ARTY-Reconciliation verwendet fuer neue Builds:

```text
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-26
```

Neu in Builder 26 ist ausschliesslich die Functional-ARTY Selection/Handoff-Verdrahtung:

```text
ARTY demand
-> AUFTRAG:NewARTY selection descriptor
-> COMMANDER:CanMission
-> COMMANDER:RecruitAssetsForMission
-> selected MOOSE asset/Legion
-> identity mapping to existing Functional ARTY
-> ARTY:AssignTargetCoord
```

Der Selection-`AUFTRAG` wird in diesem Modus nicht mit `COMMANDER:AddMission` ausgefuehrt. Damit bleibt die bestehende Functional-`ARTY`-Instanz der einzige Fire-Control-Owner und der akzeptierte M1083-/CampaignState-Rearm-Pfad unveraendert. Dieser neue ARTY-Handoff ist `SOURCE_IMPLEMENTED / DCS_PENDING`; er veraendert den DCS-validierten A9-CAS-Scope nicht.

A9 ist absichtlich observer-only. Sein Builder und ein eigener statischer Contract-Test verbieten CAS-Detection-, Route-, Cancel-, FuelLow-, Landing- und Legion-return-Ownership im Harness.

Die konkrete CAS-Release-Policy bleibt profilabhaengig. Die Base hat keinen globalen 30-Sekunden-No-Contact-Default. Ein Composition Root muss den freigegebenen Release-Policy-Modus und dessen Parameter injizieren; A9 verwendet `SUPPORTED_ELEMENT_STABLE_NO_CONTACT` mit 30 Sekunden ausschliesslich als Testprofil.

## Acceptance 9 – finaler DCS-Status

Der gemeinsame produktive Rotary-Wing-CAS-Pfad ist fuer den exakt dokumentierten A9-Scope DCS-validiert.

```text
source commit: c956b7b03b82c4ab04e529d09b1ff9bf4e480bf2
Acceptance bundle SHA-256: D2172B83EDC527A2280754A0CC0A8F575C741082B4271A77F2D6E60688D1B3B0
DCS: 2.9.29.27468
MOOSE: 2.9.18 / 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
result: PASS
```

Damit sind im A9-Scope real bestaetigt:

```text
MOOSE provider/asset selection
owner-authored rotary route
tactical corridor
own FLIGHTGROUP detection
profile-specific release
controlled mission closure
reverse recovery route
physical home landing
exact LegionAssetReturned
no FuelLow before release
no false post-return asset loss
```

Nicht durch A9 validiert sind ARTY, ARTY rearm, strategic resupply, fixed-wing CAS oder andere Site-/Provider-Ausfuehrungsprofile.

## A10 closure and next Base boundary – 02.10.2026

Der Fixed-Fire-Support-Reconciliation-Block ist fuer die exakte A10-Provenienz geschlossen:

~~~text
real MOOSE Fixed ARTY/Mortar assets
-> exact emplacement materialization
-> COMMANDER/LEGION real-asset selection
-> Functional ARTY fire
-> reservation release
-> accepted M1083/CampaignState rearm
= DCS PASS
~~~

A10 provenance: source commit 4c8793a9b155f85e7a229117725fca55f58987c3; mission SHA-256 95F28962F15659399051813F426A1401797EA95F931588349F9EAB1523E28232; bundle SHA-256 FA0CD024F050BA19DECAEE9AB1EF71C35B976346A327D118EFCC59DC249C84C9; DCS 2.9.30.28536 MT; pinned MOOSE.

Aktuelle offenen Production-Base-Grenzen:

~~~text
1. obsolete descriptor composition cleanup
2. selected 2B11 fire path in combined runtime
3. Strategic Resupply physical OPSTRANSPORT/STORAGE lifecycle + settlement
4. true concurrent multi-demand orchestration across installations
5. CAS multi-demand/provider-profile coverage without hard-coded provider
6. combined multi-FOB/COP Acceptance 11
~~~

Acceptance 11 muss ARTY, mortar, CAS und Strategic Resupply in demselben Lauf abdecken und darf keine konkrete Batterie, AIRWING/SQUADRON oder Carrier-Instanz vorgeben.


## Source-Closure nach A10 – 02.10.2026

Der allgemeine Production-Base-Source-Stand wurde nach dem A10-PASS weiter reconciliert. Fuer neue Builds gilt jetzt:

```text
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-31
```

Die aktive Composition enthaelt **nicht mehr** den superseded
`OMW_FireSupStratResupply_ArtySelectionDescriptorRegistry.lua`. Die Datei und ihr
Contract-Test bleiben ausschliesslich als historische Source-Evidenz im Repository; sie
werden nicht mehr in das Production-Base-Bundle eingebettet und stellen keine zweite
rekrutierbare Fixed-Fire-Support-Repräsentation dar.

Der reale Fixed-Fire-Support-Pfad bleibt:

```text
RealAssetRegistry
-> real PLATOON / site BRIGADE / Warehouse Assetitem
-> MOOSE COMMANDER CanMission + RecruitAssetsForMission
-> selected asset.flightgroup
-> exact physical GROUP
-> Functional ARTY
```

Der gleiche Registry-/Functional-ARTY-Vertrag ist source-seitig nun auch explizit fuer
`2B11 mortar` abgedeckt. Der gepinnte MOOSE-Range-Vertrag bleibt
`500..7000 m`. Das ist **keine** DCS-Akzeptanz eines von MOOSE ausgewaehlten
2B11-Feuerauftrags; dieser Nachweis bleibt A11.

### Strategic Resupply – generischer Source-Vertrag geschlossen

`StorageTransportFactory` und `TransportSettlement` trennen jetzt explizit zwei
verschiedene Mengen:

```text
demand.quantity
= strategische CampaignState-Menge

descriptor.cargoAmount
= explizit aufgeloeste physische DCS-STORAGE-Menge
```

Es existiert keine implizite 1:1-Annahme mehr. Der physische Resolver muss
`cargoAmount` angeben. CampaignState reserviert und verbucht weiterhin ausschliesslich
`demand.quantity`.

Ohne projektspezifischen In-Transit-Observer verwendet das Settlement den vorhandenen
MOOSE-`OPSTRANSPORT`-Statuszyklus als Beobachtungspunkt. Der strategische Transfer wird
erst auf `IN_TRANSIT` gesetzt, wenn physischer STORAGE-Cargo geladen ist und alle aktuell
zugewiesenen MOOSE-Carrier die Pickup-Zone verlassen haben. Es wird dafuer kein eigener
Scheduler und kein Carrier-Selector eingefuehrt.

```text
shortage
-> MissionDemand
-> CampaignState reservation
-> OPSTRANSPORT/STORAGE
-> COMMANDER:RecruitAssetsForTransport(transport, physicalManifestWeight, physicalManifestWeight)
-> MOOSE COMMANDER/LEGION selects and reserves eligible carrier asset(s)
-> OPSTRANSPORT:AddAsset(selected Assetitem)
-> COMMANDER:TransportAssign
-> LEGION transport request / physical execution
-> STORAGE loaded + assigned carriers outside pickup
-> CampaignState IN_TRANSIT
-> MOOSE STORAGE delivered/lost
-> idempotent CampaignState DELIVERED/LOST
```

Status: `SOURCE_IMPLEMENTED / CI_PENDING / DCS_REVALIDATION_PENDING`.

Der Recruitment-Handoff ist keine Neuentwicklung des Strategic-Resupply-Lifecycles,
sondern die Generalisierung des bereits im Stage-3-OPSTRANSPORT-Pfad verwendeten
MOOSE-Recruitment/TransportAssign-Vertrags. Die fruehere Base-Vereinfachung ueber
`COMMANDER:AddOpsTransport` allein wurde entfernt, weil sie reines STORAGE-Cargo im
gepinnten Queue-Pfad nicht korrekt zur Carrier-Rekrutierung fuehrt.

### Concurrency / Provider-Autonomie

Die Contract-Suite prueft nun explizit unabhaengige gleichzeitige ARTY-Reservations,
mehrere aktive Resupply-Shortage-Episoden und demand-spezifische CAS-Release-Zustaende.
CAS-Provider ohne gueltiges Owner-Execution-Profile bleiben weiterhin fail-closed; OMW
waehlt keinen Ersatzprovider.

Damit ist die allgemeine Source-Composition fuer den naechsten kombinierten
Multi-Site-Test vorbereitet. A11 bleibt bis zum realen DCS-Lauf
`PLANNED / NOT RELEASED FOR DCS`; insbesondere sind concurrent CAS recovery,
MOOSE-selected 2B11 fire und Strategic-Resupply-Carrier-Lifecycle noch nicht praktisch
validiert.


## Base-31 – Strategic-Resupply route preservation

Vor A11 wurde eine weitere Lifecycle-Preservation-Grenze geschlossen. Stage 3 hatte
nicht nur STORAGE-Recruitment, sondern auch den owner-authored Rotary-Transportweg
bereits ueber die gemeinsame Produktionskomponente
`OMW_OpsTransportCorridorAdapter.lua` ausgefuehrt.

Base-31 bettet diesen bestehenden Adapter nun wieder in die allgemeine Composition ein:

~~~text
MOOSE carrier recruitment
-> exact selected Assetitem
-> selected Legion AssetSpawned
-> asset.flightgroup
-> existing OpsTransportCorridorAdapter
-> OnAfterTransport outbound owner route
-> OnAfterDelivered reverse owner route
~~~

Das ist keine neue Routing-Architektur und kein Acceptance-eigener Lifecycle.
Provider-/Carrier-Auswahl bleibt MOOSE. Ohne expliziten, aufgeloesten owner-authored
Korridor gibt es bei `routeRequired=true` keinen Direct-Line-Fallback.

Der allgemeine geroutete Strategic-Resupply-Scope bleibt bis zum realen A11-Lauf
`DCS_REVALIDATION_PENDING`.
