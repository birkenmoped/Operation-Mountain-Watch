---
document_id: OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2
status: PLANNED
document_class: ACCEPTANCE_TEST
owning_policy: OMW-GOV-001
authoritative_for:
  - reconciled Stage 3 combined Honaker attack, local response, Wright fire support and Jalalabad Air-AMMO full-response acceptance contract
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - OMW-TEST-STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-1 for future full-response runs
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
base_status:
  qrf: ACCEPTED_TECHNICAL_BASELINE
  guard: ACCEPTED_TECHNICAL_BASELINE
---

# Stage 3 Acceptance 2 – reconciled full response

## 1. Zweck

Acceptance 2 ersetzt fuer kuenftige Full-Response-Laeufe die veraltete Guard-/QRF-Semantik aus Acceptance 1. Sie fuehrt keinen neuen lokalen Ground-Response-Vertrag ein, sondern konsumiert die bereits in DCS akzeptierten Production-Base-Baselines A4/A5.

Die zu pruefende Gesamtfolge lautet:

```text
physical RED intrusion at COP Honaker
-> production installation alarm / incident
-> incident-local GUARD materializes locally
-> production QRF direct-target response
-> generic FSSR C2 ARTY/CAS support demands
-> deterministic Acceptance providers: Wright L118 / Jalalabad AH-64D
-> Wright ARTY support
-> local M1083 rearm
-> strategic AMMO reorder
-> Jalalabad CH-47 MOOSE OPSTRANSPORT Air-AMMO resupply
-> existing CAS support/recovery contract
-> all participating physical assets complete their own MOOSE lifecycle
```

Die feste Zuordnung `Wright L118`, `Jalalabad AH-64D` und `Jalalabad CH-47` ist ausschliesslich Bestandteil dieser reproduzierbaren Acceptance-Testumgebung. Sie ist **keine** Produktionsregel der variablen `fire-support-strategic-resupply_base`.

## 2. Verbindliche geerbte Ground-Baselines

### 2.1 GUARD

Production Base Acceptance 5 ist die technische Referenz fuer GUARD.

```text
NORMAL
-> no physical Guard
-> no Guard demand

qualified RED perimeter presence
-> installation incident
-> GUARD demand INSTALLATION_ATTACK_LOCAL_GUARD
-> local MOOSE AUFTRAG:NewONGUARD(...)
-> no persistent PATHLINE patrol
-> no proactive SetEngageDetected()
-> no OMW EngageTarget cycle

incident close
-> Guard demand Cancel
-> MOOSE ReturnToLegion / RTZ / Returned
```

Acceptance 2 darf weder eine persistente Guard-Mission beim Missionsstart erzeugen noch den historischen PATHLINE-Rundlauf wieder einfuehren.

### 2.2 QRF

Production Base Acceptance 4 / A4-8 ist die technische Referenz fuer QRF.

```text
incident
-> INSTALLATION_ATTACK_INITIAL_QRF
-> AUFTRAG:NewONGUARD(initial threat coordinate) as recruitment/materialization anchor only
-> same physical ARMYGROUP
-> nearest living authorized incident UNIT in the 5-NM tactical zone
-> ARMYGROUP:EngageTarget(concrete UNIT, speed, "On Road")
-> target dead -> MOOSE Disengage -> reacquire
-> no living authorized incident target remains
-> mission Cancel / SetReturnToLegion(true)
-> RTZ / Returned / Warehouse lifecycle
```

Acceptance 2 darf insbesondere nicht verwenden:

```text
SetEngageDetected as QRF target authority
PATROLZONE / HuntingPatrol
GROUNDATTACK
custom QRF target scheduler
custom QRF road router
incident-close-only QRF release
perimeter-clear-only QRF release
supported-element/C2 release as replacement for target exhaustion
```

## 3. Honaker Alarm- und Tactical-Semantik

Fuer `COP_HONAKER` gilt die aktuelle SiteRegistry-Baseline:

```text
alarm anchor: WH_BLUE_GND_HONAKER
alarm radius: 2743.2 m / 9000 ft
QRF tactical area: 5 NM
```

Der Alarmperimeter ist ausschliesslich Detection-/Response-Trigger und keine WEZ, kein Battlespace und keine Mission-Endbedingung. Die historische Acceptance-1-Konstante `SECURITY_RADIUS_M = 1000` darf fuer den produktiven Honaker-Alarm nicht weiterverwendet werden.

## 4. Produktions-Base und C2-Grenze

Die allgemeine FSSR-Base besitzt die variable Support-Grenze bereits:

```text
attacked installation
-> installation incident
-> Base:RequestIncidentSupport(..., ARTY/CAS)
-> C2/external support boundary
-> suitable provider / tool
```

`GROUND_INSTALLATION_STANDARD` klassifiziert ARTY und CAS als `C2_ESCALATION_EXTERNAL`. Die Base selbst waehlt keine konkrete Batterie, keinen AIRWING, keine SQUADRON und kein operatives Asset.

Acceptance 2 prueft **nicht erneut die allgemeine Provider-Selektion**. Fuer die reproduzierbare Honaker-Testumgebung werden hinter derselben generischen Demand-Grenze gezielt die bereits bekannten Testprovider gebunden:

```text
ARTY demand -> ACCEPTANCE_DETERMINISTIC_WRIGHT -> Wright Functional MOOSE ARTY
CAS demand  -> ACCEPTANCE_DETERMINISTIC_JALALABAD_AH64D -> Jalalabad AH-64D
```

Diese Acceptance-Adapter duerfen nicht in die Produktions-SiteRegistry oder die allgemeine Support-Policy uebernommen werden.

## 5. Keine doppelte Ground-Response-Implementierung

Der neue Full-Response-Harness konsumiert beziehungsweise beobachtet die Production-Base-Implementierung. Er implementiert GUARD oder QRF nicht parallel erneut.

Verbindlich wiederverwendet werden insbesondere:

```text
OMW_FireSupStratResupply_Base
OMW_FireSupStratResupply_InstallationIncidentRuntime
OMW_FireSupStratResupply_InstallationIncidentBridge
OMW_FireSupStratResupply_PerimeterRuntime
OMW_FireSupStratResupply_PerimeterBridge
OMW_FobThreatOpsZoneAdapter
OMW_FireSupStratResupply_GuardRuntime
OMW_FireSupStratResupply_GuardMissionFactory
OMW_FireSupStratResupply_QrfRuntime
OMW_FireSupStratResupply_QrfMissionFactory
OMW_GroundRoadSpawnAdapter
```

Acceptance-Code darf beobachten, physische Teststimuli erzeugen und Ergebnisbedingungen pruefen. Er darf keine eigene Guard-/QRF-Mission, keine QRF-Targetauswahl und keine QRF-Rueckkehrlogik als Ersatz fuer die Produktions-Base einfuehren.

## 6. ARTY-Vertrag

Der Stage-3-Wright-Pfad bleibt als deterministischer Testprovider erhalten:

```text
generic FSSR ARTY support demand
-> Acceptance binds Wright as deterministic provider
-> C2-observed eligible RED ground target
-> caller-owned MOOSE ARTY FSM / AssignTargetCoord
-> real Fire At Point
-> physical EVENTS.Shot evidence
-> physical ammunition decreases
-> local M1083 rearm on the same ARTY FSM
-> CampaignState AMMO consumption exactly once
-> Wright reaches strategic reorder threshold
```

Damit wird **keine zweite produktive ARTY-Architektur** eingefuehrt. Die allgemeine FSSR-Provider-Auswahl bleibt ausserhalb der Honaker-Testfixierung variabel; Acceptance 2 bindet Wright nur, damit die bekannte End-to-End-Kette reproduzierbar geprueft werden kann.

Wenn CAS physisch ON STATION ist, darf keine neue ARTY-Fire-Mission in denselben taktischen Raum eingereiht werden. Bereits laufende MOOSE-Fire-Lifecycles werden nicht kuenstlich abgebrochen. Ein Follow-on-Fire-Demand darf nur fuer einen frischen, noch nicht im aktuellen Zyklus abgearbeiteten C2-Kontakt entstehen.

## 7. CAS-Vertrag

Acceptance 2 behaelt die bestehende Stage-3-CAS-Geometrie und Recovery-Semantik:

```text
Jalalabad
-> configured logical OMW_FlightPath
-> WEST
-> dynamic CAS ingress / mission area / egress
-> WEST reverse
-> configured logical OMW_FlightPath reverse
-> Jalalabad
```

CAS verwendet sein eigenes MOOSE/DCS-Detektionsbild. Kein `KnowTarget()`-Inject und kein raw RED count als CAS-Release-Autoritaet. Der supported-element/no-contact CAS-Closure-Vertrag bleibt separat und besitzt keine QRF-Release-Autoritaet.

Der generische `OMW_FireSupStratResupply_CasMissionFactory` Schema 2 besitzt source-seitig `PATROLZONE_ENGAGE`. Acceptance 2 bindet fuer den deterministischen Stage-3-Lauf jedoch weiterhin den bereits entwickelten Jalalabad-AH-64-Testprovider hinter der generischen FSSR-C2-Demand-Grenze. Dadurch wird die Provider-Auswahl nicht in die allgemeine Factory hart codiert.

## 8. Strategic Air-AMMO / OPSTRANSPORT

Der bestehende MOOSE-OPSTRANSPORT-Pfad bleibt Gegenstand der Full-Response-Acceptance:

```text
Wright AMMO reaches reorder threshold
-> exactly one strategic RESUPPLY demand
-> CampaignState transfer reservation
-> MOOSE OPSTRANSPORT
-> deterministic Acceptance carrier pool: Jalalabad CH-47
-> STORAGE load / transport / unload / Delivered
-> configured OMW_FlightPath outbound
-> configured OMW_FlightPath reverse return
-> physical Jalalabad landing / LEGION return
-> CampaignState delivered exactly once
```

CampaignState bleibt strategische Ressourcenautoritaet. MOOSE bleibt operative Transport- und physische Lifecycle-Autoritaet.

## 9. Acceptance-2 PASS-Kriterien

Ein Gesamt-PASS benoetigt mindestens:

```text
1. no physical Honaker Guard before qualified alarm
2. physical RED intrusion qualifies through the production perimeter path
3. exactly one installation incident for the attack lifecycle
4. exactly one incident-local Guard demand
5. Guard materializes locally on MOOSE ONGUARD without persistent PATHLINE patrol
6. exactly one initial QRF demand
7. QRF materializes through the accepted ACCESS / GroundRoadSpawnAdapter path
8. QRF reaches MOOSE direct concrete incident UNIT engagement
9. QRF uses its accepted On Road direct-target lifecycle
10. Guard returns after authoritative incident close
11. QRF is not cancelled merely by perimeter clear or incident close
12. QRF returns after its own target-exhaustion lifecycle
13. generic FSSR ARTY and CAS support demands are created through the Base C2 boundary
14. deterministic Acceptance provider binding selects Wright/Jalalabad only inside the test harness
15. Wright ARTY produces real physical shot evidence and ammunition decrease
16. local M1083 rearm completes and returns
17. strategic AMMO reorder creates exactly one active RESUPPLY demand
18. CH-47 OPSTRANSPORT completes physical STORAGE delivery
19. Wright / Jalalabad strategic AMMO settlement is correct and exactly once
20. CAS follows its own accepted task / release / recovery contract
21. all ARTY cycles are terminal before PASS
22. no acceptance-owned replacement Ground routing, target authority or resource authority
```

## 10. Explizit verbotene Regressionen

```text
persistent Guard on mission start
Guard PATHLINE repeated circuit
Guard SetEngageDetected
1000-m Honaker production alarm radius
Acceptance-owned AUFTRAG:NewONGUARD for Guard/QRF
QRF SetEngageDetected target authority
QRF supported-element release
QRF incident-close release
QRF perimeter-clear release
QRF Vee march default
PATROLZONE/HuntingPatrol for QRF
GROUNDATTACK for QRF
custom QRF target scheduler
custom QRF road router
CAS AIRWING/SQUADRON hardcoding inside generic FSSR production factory
Wright hardcoding inside generic FSSR production SiteRegistry/policy
Acceptance-owned ExpireDemand/Cancel as Ground tactical completion
Mission Editor alarm-zone proliferation
```

## 11. Staged Artefakte

Acceptance 2 ist source-seitig implementiert und fuer Commit `b2808d01a744b422688d8c2f85a6baa4a8c66b69` owner-lokal reproduzierbar gebaut. Die DCS-Validierung ist noch offen.

Source-Teile:

```text
mission/tests/stage3-honaker-wright-full-response/src/a2/01-core.lua
mission/tests/stage3-honaker-wright-full-response/src/a2/02-cas.lua
mission/tests/stage3-honaker-wright-full-response/src/a2/03-logistics.lua
mission/tests/stage3-honaker-wright-full-response/src/a2/04-fire-support.lua
mission/tests/stage3-honaker-wright-full-response/src/a2/05-runtime.lua
```

Builder:

```text
tools/build-stage3-honaker-wright-full-response-acceptance-2.ps1
BuilderVersion: STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2-1
```

Output nach lokalem Build:

```text
mission/tests/stage3-honaker-wright-full-response/dist/OMW_Stage3_Honaker_Wright_Full_Response_Acceptance_2.lua
```

Der Builder zieht zuerst die aktuelle FSSR Production Base 19 ein und besitzt Anti-Regression-Gates gegen die historischen Ground-Annahmen aus Acceptance 1.

## 12. Aktueller Status

```text
DONE:
- A4/A5 local Ground authority inherited
- Honaker 2743.2-m / 9000-ft production alarm inherited
- no Acceptance-owned Guard/QRF mission implementation
- generic FSSR ARTY/CAS demand boundary consumed
- deterministic Wright/Jalalabad test-provider bindings isolated to Acceptance
- existing Wright Functional ARTY + M1083 rearm retained
- existing CAS own-detection / supported-element release retained
- existing CH-47 OPSTRANSPORT / CampaignState chain retained
- Acceptance-2 builder and anti-regression markers staged

DONE:
- GitHub Lua syntax/contract validation for build commit
- owner-local build and SHA-256 provenance

OPEN:
- owner-local Mission Editor embedding
- one real DCS full-response run
```

Bis diese offenen Nachweise vorliegen, bleibt Acceptance 2 `PLANNED` und `validated_in_dcs: false`.


## 13. Owner-local Build-Provenienz 18.09.2026

Der Projektinhaber hat Acceptance 2 auf exakt folgendem Source-Stand gebaut:

```text
branch: agent/fire-support-strategic-resupply-base-gate0
source commit: b2808d01a744b422688d8c2f85a6baa4a8c66b69
build status: VERIFIED_LOCAL_BUILD
DCS status: NOT VALIDATED
```

Builder und Bundles:

```text
Production BuilderVersion:
OMW-FIRE-SUPPORT-STRATEGIC-RESUPPLY-PRODUCTION-BASE-19

Production builder SHA-256:
2463B10AC996D762D8903AE8F6C7C006E28C806DF61D290B2D74E2A3BF38D0F2

Production bundle SHA-256:
63BC68E52FC22CAA79FB53A28DEFBCBFB283BF162DDD95811C45BC2E605884C6

Acceptance BuilderVersion:
STAGE3-HONAKER-WRIGHT-FULL-RESPONSE-ACCEPTANCE-2-1

Acceptance builder SHA-256:
24922F58C127D85130A28E0ED6208DFED985F2E199CF5363CA249521FCC60B5A

Acceptance bundle SHA-256:
1D976567FC9E848194251C4FB4B9D1786F645B930B789B93291BABE1921DF1A4
```

Acceptance-2 Source-Teile:

```text
01-core.lua
7A655DA6EFA0FAFD048E455A3B5A80E2534CF345906A10D9FF971D76498E3701

02-cas.lua
819AF0BA1E6E8FA15A8E4EB3F2A23D7889E3FEC7FF4897566AABF4940C82ABEF

03-logistics.lua
54ECB83CD140AD1E40B4120B572144E81D1AF887DB454964A41051B64F9971A1

04-fire-support.lua
7E620C78CAB20C4389B66C27C99E58F2D8AEF7871002A45629E8DC46737F5790

05-runtime.lua
6F1FB1D5FEE7C23B44F0A30CFC78FF65B0433C5203AD5644ED5D994C64137044
```

MOOSE-Provenienz des Bundles:

```text
release: 2.9.18
commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
```

Die vom Builder ausgegebenen Hashes stimmen mit den anschliessend separat ausgefuehrten `Get-FileHash -Algorithm SHA256`-Pruefungen ueberein. Der lokale Git-Status enthielt nur untracked generierte `dist/`-Artefakte und keine versionierten lokalen Aenderungen.

Damit ist die Source/Builder/Bundle-Kette bis zum lokal erzeugten Acceptance-2-Bundle belegt. Die Mission-Editor-/`.miz`-Handhabung liegt beim Projektinhaber und wird von ChatGPT weder automatisiert noch inspiziert oder veraendert. Nach der owner-lokalen Einbindung folgt der reale DCS-Full-Response-Lauf; erst dessen reale Runtime-Evidenz kann `validated_in_dcs: true` begruenden.
