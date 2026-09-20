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

Status: SOURCE_REVIEWED / TEILPFADE DCS-VALIDIERT

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
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-24
```

A9 ist absichtlich observer-only. Sein Builder und ein eigener statischer Contract-Test verbieten CAS-Detection-, Route-, Cancel-, FuelLow-, Landing- und Legion-return-Ownership im Harness.

Die konkrete CAS-Release-Policy bleibt profilabhaengig. Die Base hat keinen globalen 30-Sekunden-No-Contact-Default. Ein Composition Root muss den freigegebenen Release-Policy-Modus und dessen Parameter injizieren; A9 verwendet `SUPPORTED_ELEMENT_STABLE_NO_CONTACT` mit 30 Sekunden ausschliesslich als Testprofil.
