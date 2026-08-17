---
document_id: OMW-HANDOFF-ARMY-GROUND-FOUNDATION-2026-08-18
status: PLANNED
document_class: IMPLEMENTATION_HANDOFF
owning_policy: OMW-GOV-001
authoritative_for:
  - current continuation state of the Jalalabad and Kunar ARMY ground foundation
  - branch, source, decision and open-task context for the next development chat
not_authoritative_for:
  - final ground-force ORBAT strengths
  - final MOOSE BRIGADE topology
  - final Mission Editor object state
  - merge or Ready-for-Review authorization
  - DCS runtime acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: agent/army-ground-foundation-reconciliation
source_commit: e6e0bdeea991f51745c05ed214bf4176e5abbd11
validated_in_dcs: false
---

# ARMY Ground Foundation – Chat-Handoff 18.08.2026

## 1. Zweck

Dieses Handoff übergibt den aktuellen Arbeitsstand der BLUE-ARMY-/Ground-Foundation für den engeren Jalalabad-/Kunar-Raum an einen neuen Chat. Es fasst den tatsächlich dokumentierten Stand, die getroffenen Owner-Entscheidungen, die bereits geprüfte historische Evidenz, den MOOSE-first-Arbeitsstand und die noch offenen To-dos zusammen.

Die zentrale Arbeitsdatei bleibt:

- [`ARMY Ground Foundation – Arbeitsstand und To-do`](../../mission/tests/army-ground-foundation/TODO.md)

Dieses Handoff ersetzt die To-do-Datei nicht, sondern erklärt, wie der nächste Chat sie fortführen soll.

## 2. Verbindlicher Startpunkt für den neuen Chat

Repository:

```text
birkenmoped/Operation-Mountain-Watch
```

Aktiver Entwicklungsbranch:

```text
agent/army-ground-foundation-reconciliation
```

Quellstand, auf dem dieses Handoff basiert:

```text
e6e0bdeea991f51745c05ed214bf4176e5abbd11
```

Lokal durch den Projektinhaber verifizierter TODO-Hash dieses Quellstands:

```text
mission/tests/army-ground-foundation/TODO.md
SHA256 A2702968DE1148471538B935546A4540482DFB60D51647E0132C729DBA8A7D9A
```

`main` stand bei Anlage dieses Arbeitsbranches auf:

```text
08f679926e5ac059e9853f54ffa7bb634063eaa4
```

Das ist der Merge-Commit von PR #108 `Document Kunar ground-site reconciliation and FOB Bostick`.

## 3. Pflichtprüfung zu Beginn des neuen Chats

Vor weiterer Analyse, Dokumentänderung oder Lua-Entwicklung mindestens vollständig prüfen:

```text
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
docs/11-bases-and-fobs.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
docs/64-afghanistan-order-of-battle-july-2011.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/army-ground-foundation/TODO.md
this handoff
```

Für MOOSE-Entscheidungen zusätzlich die tatsächlich verwendete `Moose.lua`, die passende MOOSE-Dokumentation und offizielle Demo-/Testmissionen prüfen. Keine MOOSE-Methode, Signatur oder FSM-Eigenschaft aus Erinnerung erfinden.

## 4. Verbindliche Arbeitsgrenzen

Recherche-/Kampagnenzeitraum:

```text
01.08.2010–31.12.2011
```

Für die **aktive BLUE-Ground-ORBAT** ist durch Owner-Entscheidung ein einheitlicher Stand festgelegt:

```text
JULY 2011
```

Das bedeutet:

- Installationsaktivität, Schließungen und Übergaben werden weiterhin über den gesamten OMW-Zeitraum bewertet.
- Aktive Einheiten werden nicht aus mehreren Rotationen gleichzeitig gemischt.
- Frühere/spätere Einheiten bleiben historischer Kontext.
- Wenn der Juli-2011-ORBAT einen Bereich ausdrücklich nicht vollständig erfasst, etwa PRT, Medical, Logistics oder Intelligence, dürfen ergänzende zeitnahe Primärquellen verwendet werden. Die Ergänzung muss als solche gekennzeichnet bleiben.

## 5. Aktuelles ARMY-Spielfeld

Der aktuelle Ground-Operationsraum ist bewusst enger als RC-East insgesamt.

```text
Jalalabad / FOB Fenty
        +
Nangarhar / Kunar
        +
Asadabad / central Kunar
        +
northern Kunar / Bostick sector
```

**FOB Salerno / Khost und angrenzende Installationen sind für diesen Arbeitsstrang ausgeschlossen.** Die Wege für lokale QRF-, Patrol- und Resupply-Logik wären für den Jalalabad-/Kunar-Raum zu lang.

Camp Fiaz in Asadabad wird ebenfalls bewusst nicht physisch in OMW aufgenommen. FOB Wright deckt den für die Kampagne benötigten Asadabad-Knoten ab.

## 6. Vier aktuelle Ground Nodes

Die derzeitige Arbeitshypothese lautet:

```text
BLUE COMMANDER
|
+-- BRIGADE_JALALABAD          [TO_VERIFY]
|   +-- Jalalabad / FOB Fenty
|   +-- local Nangarhar assets
|
+-- BRIGADE_JOYCE              [TO_VERIFY]
|   +-- FOB Joyce
|   +-- COP Honaker-Miracle
|   +-- OP JoJo
|
+-- BRIGADE_WRIGHT             [STRONG_CANDIDATE]
|   +-- FOB Wright
|   +-- local Asadabad assets
|
+-- BRIGADE_BOSTICK            [STRONG_CANDIDATE]
    +-- FOB Bostick
    +-- OP Mustang
    +-- OP Clydesdale
    +-- OP Stallion
```

Wichtig: `BRIGADE_*` ist hier eine **technische MOOSE-/Ground-Node-Arbeitshypothese**, keine Behauptung, dass jede Node einer realen historischen Brigade entspricht.

## 7. Juli-2011-ORBAT-Zuordnung

Aus `OMW-HIST-AFGHANISTAN-ORBAT-2011-07`:

```text
TF Bronco / 3rd BCT, 25th Infantry Division
HQ: Jalalabad Airfield
AO: Kunar, Nangarhar, Nuristan

TF Steel / 3-7 Field Artillery
Jalalabad Airfield
Brigade artillery support / parts of Nangarhar

TF Wolfhound / 2-27 Infantry
FOB Bostick, Naray
northern Kunar

TF Cacti / 2-35 Infantry
FOB Joyce, Chawkay
southern Kunar
```

Weitere im Juli-2011-ORBAT genannte TF-Bronco-Bataillonsstandorte wie FOB Shinwar oder FOB Connolly sind historisch relevant, gehören aber **nicht automatisch** zum aktuellen vierteiligen OMW-Ground-Node-Modell. Vor einer Aufnahme muss geprüft werden, ob sie für das Gameplay und die vorgesehenen Reaktionswege tatsächlich notwendig sind.

## 8. Node-spezifischer Arbeitsstand

### 8.1 Jalalabad / FOB Fenty

- regionaler Higher-HQ-/Logistik-/Aviation-Hub;
- `TF Bronco / 3rd BCT, 25th ID` als Juli-2011-Higher-HQ-Kontext;
- `TF Steel / 3-7 FA` am Jalalabad Airfield im Juli-2011-ORBAT;
- Ground Defense und QRF sind im OMW-Zeitraum historisch gestützt, unter anderem durch Angriffe auf FOB Fenty;
- lokale Juli-2011-Ground-/Security-/QRF-Teilverbände müssen noch genauer bestimmt werden.

### 8.2 Joyce / Honaker-Miracle / JoJo

Juli-2011-Baseline:

```text
TF Cacti / 2-35 Infantry
FOB Joyce
southern Kunar
```

Arbeitsmodell:

```text
FOB Joyce
└── COP Honaker-Miracle
    └── OP JoJo
```

Belegt beziehungsweise stark gestützt:

- Joyce als aktiver Ground-/Logistik-Hub;
- CH-47-/Sling-Load-Resupply und Fuel-Handling 2011;
- Honaker-Miracle als aktiver COP;
- eigener Fuel Point auf Honaker-Miracle 2011;
- zwei M777A2 von Battery C / 3-321 Field Artillery am 30.07.2011 auf Honaker-Miracle;
- OP JoJo als realer/geolokalisierter Outpost oberhalb des COP gestützt; konkrete Juli-2011-Besetzungsdaten bleiben offen.

### 8.3 Wright / Asadabad

Owner-Entscheidung:

```text
FOB Wright: IN SCOPE
Camp Fiaz: OUT OF SCOPE
```

Wright ist kein im Juli-2011-ORBAT ausgewiesenes Maneuver-Battalion-HQ wie Joyce oder Bostick. Das ist **keine Aussage über fehlende Bedeutung**, sondern eine Scope-Grenze der Quelle. Der ORBAT schließt unter anderem PRT, Medical, Logistics und Intelligence nicht vollständig ein.

Belastbarer Juli-2011-Ground-Ansatz:

```text
1-14th Illinois Agribusiness Development Team
└── Security Force Platoon
```

Das SECFOR-Platoon ist im Juli 2011 für FOB-Sicherung und externe Missionssicherung belegt.

Zusätzlich im OMW-Zeitraum bestätigt oder stark gestützt:

- Kunar PRT / provincial support;
- 102nd Forward Surgical Team;
- FARP / Aviation Support;
- Fuel storage / fuel tanker logistics;
- größere MRAP-/Fahrzeugpräsenz;
- M777-/3-321-FA-Präsenz 2010;
- erheblicher Fuel-/Vehicle-Schaden bei einem Angriff am 15.11.2010;
- Incinerators / dauerhafte Support-Infrastruktur;
- Aktivität bis mindestens Ende November 2011.

Offen: exakte M777-Battery-/Platoon-Zuordnung auf Wright im Juli 2011. Der 2010er Nachweis darf nicht automatisch als identische Juli-2011-Stationierung behandelt werden.

### 8.4 Bostick / Mustang / Clydesdale / Stallion

Juli-2011-Baseline:

```text
TF Wolfhound / 2-27 Infantry
FOB Bostick / Naray
northern Kunar
```

Owner-Entscheidung für OMW:

```text
FOB Bostick
├── OP Mustang       -> northern overwatch
├── OP Clydesdale    -> central overwatch
└── OP Stallion      -> southern overwatch
```

Bostick wird vom Projektinhaber manuell im Mission Editor aufgebaut.

Evidenzstand:

- Bostick 2010 und Juli 2011 klar aktiv;
- OP Mustang: real und im Februar 2011 aktiv durch C Troop / 1-32 Cav / TF Bandit belegt;
- OP Clydesdale: realer Standort durch DoD-POEMS bestätigt;
- OP Stallion: historische Existenz/Lage durch OEF Base Tracker bzw. ergänzende Hinweise gestützt;
- Clydesdale/Stallion werden in OMW als sinnvolle Overwatch-Positionen des Bostick-Komplexes geplant; das ist eine bewusste Missionsdesignentscheidung und darf nicht als Beweis einer exakt gleichartigen Juli-2011-Besetzung formuliert werden.

## 9. Geschlossene oder nicht aktive Systeme

Korengal-Komplex:

```text
KOP / Korengal Outpost
OP 1
OP 2 [historische Identität/Namensfrage teilweise offen]
Restrepo
```

Der US-Komplex wurde im April 2010 aufgegeben und liegt damit vor OMW-Beginn. Für OMW keine aktive BLUE-Garnison.

Keating/Fritsche wurden bereits 2009 aufgegeben und sind ebenfalls keine aktiven OMW-BLUE-Installationen.

COP Michigan war innerhalb des OMW-Zeitraums zunächst aktiv und wurde Ende März 2011 geschlossen; für eine Juli-2011-aktive Ground-Baseline ist damit keine aktive US-Garnison vorzusehen.

## 10. OP-Parent-Regel

Owner-/Architekturentscheidung:

```text
OP active only if:
- assigned parent FOB/COP is active
  OR
- an explicit replacement parent is documented
```

Ein OP besitzt nicht automatisch:

```text
independent personnel pool
independent warehouse
independent QRF origin
independent patrol origin
```

OP-Besatzung, Verstärkung, Ablösung und Versorgung müssen aus den Ressourcen der Parent-Formation beziehungsweise des Parent-Ground-Nodes stammen.

Diese Regel ist wichtig für Bostick und Joyce und schließt gleichzeitig unsinnige aktive Rest-OPs eines bereits geschlossenen Parent-Komplexes aus.

## 11. Physische Installationsdarstellung

Eine aktive und angreifbare BLUE-Installation darf nicht auf ein rein symbolisches Minimalmodell aus Zelt + Helipad reduziert werden. Die Kampagne soll Angriffe auf Installationen und Nachschubwege ermöglichen; deshalb müssen aktive FOBs/COPs als verteidigbare physische Orte funktionieren.

Je nach Standort gehören dazu insbesondere:

```text
- glaubwürdiger Perimeter / Schutzbauwerke
- Fighting Positions / Towers
- kontrollierte Zufahrt
- interne Verkehrs-/Fahrzeugflächen
- Fuel-/Logistikbereiche
- Artillerie-/Mörserstellungen, wenn belegt oder genehmigt
- HLP/FARP/LZ, wenn belegt
- Medical/Support-Bereiche
- Gelände, Höhenzüge und Anmarschachsen
```

ChatGPT verändert keine `.miz`-Datei. Die physischen Installationen und Templates werden durch den Projektinhaber im Mission Editor aufgebaut; ChatGPT liefert danach die dokumentierte Build-/Integrationsanweisung.

## 12. MOOSE-first Arbeitsstand

Bereits als Kandidatenhierarchie identifiziert:

```text
COMMANDER
    |
    +-- BRIGADE / operational Ground Node
            |
            +-- PLATOON / role pool
                    |
                    +-- ARMYGROUP
                            |
                            +-- physical DCS GROUP
```

Source-Prüfung des tatsächlich verwendeten MOOSE-Stands hat bereits ergeben:

- `BRIGADE` arbeitet als `LEGION`-/WAREHOUSE-basierter Ground-Asset-Pool;
- `PLATOON`/`COHORT` kann Mission Capabilities und Mission Range begrenzen;
- `ARMYGROUP` repräsentiert die physisch agierende Ground Group;
- Assets derselben Brigade können grundsätzlich im Feld weitergeführt werden;
- bestimmte `RTZ`-/Return-Pfade können bei nicht mobilen Gruppen Teleport-Verhalten enthalten; solche Pfade sind wegen OMW-Governance nicht ungeprüft zulässig;
- `OPSTRANSPORT` ist als taktischer Transportbaustein relevant und noch weiter zu prüfen.

Nicht beschlossen:

```text
- ob exakt vier Ground Nodes = exakt vier MOOSE BRIGADEs
- exakte PLATOON-Zuschnitte
- konkrete DCS-Templates/Stärken
- finale Transport-/Return-/Reconstitution-Pfade
```

Wichtig: reale Task Force/Battalion-Identität, Installation, MOOSE-Pool und DCS-Gruppe sind getrennte Konzepte.

```text
FOB_BOSTICK
!= TF_WOLFHOUND_2_27
!= BRIGADE_BOSTICK
!= physical ARMYGROUP
```

CampaignState bleibt strategische Ressourcenautorität.

## 13. Verwendete und wichtige Quellen

Projektintern:

- `docs/64-afghanistan-order-of-battle-july-2011.md`;
- `docs/11-bases-and-fobs.md`;
- DoD-POEMS `Wright and vicinity, Afghanistan (2003-2014)`;
- U.S. Army Combat Studies Institute, `Vanguard of Valor: Small Unit Actions in Afghanistan`;
- OEF Base Tracker / ArcGIS.

Wichtige externe Primär-/starke Quellen, die bereits ausgewertet wurden:

```text
DVIDS – Bostick / 1-32 Cav / 3-321 FA
DVIDS – Joyce / TF Cacti / CH-47 resupply
DVIDS – Honaker-Miracle / C/3-321 FA / M777A2
DVIDS – Wright / 1-14th Illinois ADT / SECFOR
DVIDS – Wright / 102nd FST
DVIDS – Wright / 3-321 FA / M777
DoD/US military image captions collected via Commons/PICRYL where original metadata is identifiable
```

Sekundärquellen wurden als Research Index genutzt, unter anderem Alchetron, Wikipedia, Global Conflict Maps, Long War Journal, SOFMAG, Frontlines of Freedom und Video-/Bildbeschreibungen. Sie überschreiben keine Primärquelle.

Die vom Nutzer bereitgestellte `3/3 Marines Command Chronology 01 Jul–18 Nov 2011` ist für Wright/Kunar **nicht relevant**: sie betrifft 3rd Battalion, 3rd Marines und den späteren Einsatz im Garmsir District, Helmand. Nicht für die Kunar-ORBAT verwenden.

## 14. Aktuelle Repository-Probleme vor einem späteren Merge

PR #108 ist bereits gemergt:

```text
PR #108
merge commit: 08f679926e5ac059e9853f54ffa7bb634063eaa4
```

Auf `main` sind danach jedoch veraltete Dokumentmetadaten/Registereinträge verblieben:

```text
docs/11-bases-and-fobs.md
  source_branch: agent/kunar-ground-site-reconciliation
  source_commit: PENDING_MERGE

docs/SUBPROJECT-REGISTRY.md
  source_branch: agent/kunar-ground-site-reconciliation
  source_commit: PENDING_MERGE
  PR #108 weiterhin als offen geführt
```

Das widerspricht `OMW-GOV-DOCUMENT-METADATA`: `PENDING_MERGE` ist auf `main` nicht zulässig. Der nächste Chat soll diese Reconciliation auf dem aktuellen ARMY-Branch mit erledigen, bevor ein späterer Merge vorgeschlagen wird.

## 15. Konkrete nächste Arbeiten

Die vollständige Checkbox-Liste steht in `mission/tests/army-ground-foundation/TODO.md`. Priorität für den nächsten Chat:

1. aktuellen Branch und alle oben genannten Governance-/Fachdokumente erneut prüfen;
2. `docs/11-bases-and-fobs.md` auf den aktuellen Wright-/Bostick-/Joyce-/OP-Parent-Stand bringen;
3. `docs/SUBPROJECT-REGISTRY.md` nach PR #108 bereinigen und den neuen ARMY-Branch korrekt aufnehmen, sobald ein PR existiert;
4. `docs/moose/PROJECT-CLASS-INDEX.md` für COMMANDER/BRIGADE/PLATOON/ARMYGROUP/OPSTRANSPORT nachführen, ohne `VALIDATED` zu behaupten;
5. MOOSE-Demos/Tests für BRIGADE/PLATOON/ARMYGROUP/OPSTRANSPORT gegen den gepinnten MOOSE-Stand weiter prüfen;
6. Mission-Capability-/Range-Selektion und Return/Reinforcement/Reconstitution-Pfade verifizieren;
7. Jalalabad/Fenty Ground-/Security-/QRF-Teilverbände für Juli 2011 weiter präzisieren;
8. Joyce/Bostick Company-/Platoon-Zuordnungen soweit belastbar ergänzen;
9. Wrights exakte Juli-2011-Artilleriezuordnung weiter recherchieren, ohne 2010 automatisch fortzuschreiben;
10. erst danach konkrete PLATOON-Rollen und DCS-Ground-Templates ableiten.

## 16. Merge-/Acceptance-Grenze

Der aktuelle Stand ist **Planung und Reconciliation**, keine Runtime-Acceptance.

```text
NO DCS ACCEPTANCE YET
NO FINAL BRIGADE TOPOLOGY YET
NO FINAL PLATOON COMPOSITION YET
NO FINAL DCS GROUND TEMPLATE STRENGTHS YET
NO MIZ MUTATION BY CHATGPT
```

Der aktuelle Branch soll vorerst weitergeführt werden. Ein Merge auf `main` ist erst sinnvoll, wenn die Dokument-Reconciliation abgeschlossen, der vollständige Diff geprüft und die Dokumentationsvalidierung/CI grün ist. Ready-for-Review und Merge benötigen weiterhin die ausdrückliche Freigabe des Projektinhabers.

## 17. Direkt kopierbarer Auftrag für den neuen Chat

```text
Wir übernehmen die weitere Entwicklung der OMW BLUE ARMY Ground Foundation.

Arbeite auf:
agent/army-ground-foundation-reconciliation

Lies zuerst vollständig:
AGENTS.md
docs/00-project-governance.md
docs/26-moose-first-development-policy.md
docs/DOCUMENT-METADATA-POLICY.md
docs/SUBPROJECT-REGISTRY.md
docs/11-bases-and-fobs.md
docs/37-campaign-architecture-and-dynamic-mission-design.md
docs/64-afghanistan-order-of-battle-july-2011.md
docs/moose/PROJECT-CLASS-INDEX.md
mission/tests/army-ground-foundation/TODO.md
docs/handoffs/2026-08-18-army-ground-foundation-chat-handoff.md

Verbindlich:
- Recherchezeitraum 01.08.2010–31.12.2011.
- aktive Ground-ORBAT-Baseline = JULY 2011.
- aktuelles Spielfeld = Jalalabad, Joyce, Wright, Bostick.
- Salerno/Khost und Camp Fiaz bleiben für diesen Scope außen vor.
- CampaignState bleibt strategische Ressourcenautorität.
- MOOSE-first; keine Methoden erfinden.
- Installationen, historische Formationen, MOOSE-Pools und physische DCS-Gruppen strikt trennen.
- OPs hängen von einem aktiven Parent ab und besitzen keine eigene Ressourcenhoheit.
- ChatGPT verändert keine .miz-Dateien.

Fahre anhand der bestehenden To-do-Liste fort. Bearbeite ruhig mehrere eng zusammenhängende Prüfungen parallel. Dokumentiere gesicherte Befunde, Unsicherheiten und Owner-Entscheidungen sauber. Vor einem Merge müssen insbesondere docs/11, docs/moose/PROJECT-CLASS-INDEX.md und docs/SUBPROJECT-REGISTRY.md reconciled und die Dokumentationsvalidierung grün sein.
```
