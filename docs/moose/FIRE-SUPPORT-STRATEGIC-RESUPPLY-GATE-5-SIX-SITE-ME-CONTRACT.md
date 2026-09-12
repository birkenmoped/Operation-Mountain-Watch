---
document_id: OMW-MOOSE-FIRE-SUPPORT-STRATEGIC-RESUPPLY-GATE5-SIX-SITE-ME-CONTRACT
status: PLANNED
document_class: MISSION_EDITOR_CONTRACT
owning_policy: OMW-GOV-001
authoritative_for:
  - corrected Gate-5 object contract for the six current Ground Foundation sites
  - existing Guard PATHLINE inventory in the reviewed v23 mission
  - runtime-generated installation alarm-perimeter boundary
  - correction history and anti-regression notes for this scope
not_authoritative_for:
  - generic six-site DCS runtime acceptance
  - Guard personnel strength or CampaignState quantity decisions
  - QRF composition or local-fire asset selection
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - branch-local Gate-5 assumption that six Guard PATHLINEs still had to be created
  - branch-local Gate-5 assumption that ZON_BLUE_GND_<SITE>_ALARM must exist as Mission Editor trigger zones
superseded_by:
source_branch: agent/fire-support-strategic-resupply-base-gate0
source_commit: PENDING_MERGE
validated_in_dcs: false
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_artifact_sha256: E3B750921EE22CFB37DD1CEC7549831A9165FFE64CD26BE154B49E63E001A915
---

# Gate 5 – korrigierter Six-Site-Vertrag

## 1. Zweck

Dieses Dokument hält den korrigierten Stand für die sechs Ground-Foundation-Sites fest und dokumentiert ausdrücklich die Fehlannahmen, die während der Gate-5-Arbeit erneut eingeführt wurden.

Der Zweck ist nicht nur die aktuelle Lösung zu beschreiben, sondern zu verhindern, dass bereits geklärte Punkte in späteren Chats erneut als offene Mission-Editor-Aufgaben behandelt werden.

Aktueller Scope:

```text
Jalalabad / FOB Fenty
COP Fortress
FOB Joyce
FOB Wright
COP Honaker-Miracle
FOB Bostick
```

## 2. Korrekturprotokoll – 12.09.2026

### 2.1 Erneut eingeführte Fehlannahme: Guard-PATHLINEs fehlten

Während der Gate-5-Ausarbeitung wurde fälschlich angenommen, die sechs Guard-PATHLINEs müssten erst vom Projektinhaber im Mission Editor neu angelegt werden.

Der Projektinhaber widersprach und verwies darauf, dass diese Objekte bereits in der bereitgestellten Mission vorhanden sind.

Die anschließend erneut read-only geprüfte Mission bestätigte den Einwand.

Geprüftes Missionsartefakt:

```text
OMW_Template_v23_GroundWorks_base(1).miz
SHA-256:
3DD8DFC0CE1A79A2C1D57A0ADEC0E2E5B1DC5AF9F35AA58F3F1A46F93F23871E
```

In der internen `mission`-Datei wurden alle sechs vereinbarten PATHLINE-Namen gefunden:

```text
OMW_RTE_BLUE_GUARD_FENTY_01
OMW_RTE_BLUE_GUARD_FORTRESS_01
OMW_RTE_BLUE_GUARD_JOYCE_01
OMW_RTE_BLUE_GUARD_WRIGHT_01
OMW_RTE_BLUE_GUARD_HONAKER_01
OMW_RTE_BLUE_GUARD_BOSTICK_01
```

Korrigierter Stand:

```text
PATHLINE-Erstellung im Mission Editor: NICHT ERFORDERLICH
PATHLINE-Existenz in v23: READ-ONLY BESTÄTIGT
DCS-Laufzeitverhalten aller sechs Routen: NOCH NICHT GENERISCH VALIDATED
```

### 2.2 Erneut eingeführte Fehlannahme: Alarmzonen müssten in der MIZ existieren

Während derselben Gate-5-Ausarbeitung wurden zusätzlich folgende Mission-Editor-Triggerzonen erfunden und anschließend sogar im Registry-/Testvertrag verlangt:

```text
ZON_BLUE_GND_FENTY_ALARM
ZON_BLUE_GND_FORTRESS_ALARM
ZON_BLUE_GND_JOYCE_ALARM
ZON_BLUE_GND_WRIGHT_ALARM
ZON_BLUE_GND_HONAKER_ALARM
ZON_BLUE_GND_BOSTICK_ALARM
```

Auch dies war falsch und widersprach dem bereits vorhandenen Runtime-Adapter.

Der Projektinhaber wies darauf hin, dass die Alarm-/Security-Grenzen zur Laufzeit erzeugt werden und keine Mission-Editor-Triggerzonen sind. Die erneute Source-Prüfung bestätigte diese Korrektur.

Maßgeblicher bestehender Adapter:

```text
scripts/ground/OMW_FobThreatOpsZoneAdapter.lua
```

Sein Vertrag lautet sinngemäß und im Source explizit:

```text
installation anchor
+ configured radius
-> MOOSE ZONE_RADIUS:New(...)
-> MOOSE OPSZONE:New(...)
-> Attacked / Defeated / Evaluated lifecycle
```

Damit gilt:

```text
Mission-Editor-Alarmzone: NICHT ERFORDERLICH
Runtime-ZONE_RADIUS: ERFORDERLICH
MOOSE OPSZONE: ERFORDERLICH
Alarmzone bleibt Trigger-/Detection-Grenze, keine Engagement- oder Mission-End-Grenze
```

Die read-only Prüfung der v23-Mission fand folgerichtig keine `ZON_BLUE_GND_*_ALARM`-Objekte.

## 3. Verbindliche Anti-Regressionsregel für Folgearbeit

Vor jeder Behauptung, dass ein Mission-Editor-Objekt neu erstellt werden müsse, ist in dieser Reihenfolge zu prüfen:

```text
1. aktuelle Fach-/Ground-Baseline
2. tatsächlich bereitgestellte aktuelle MIZ read-only
3. bestehender Runtime-Code
4. erst dann fehlendes Objekt deklarieren
```

Ein Objekt darf nicht aufgrund eines geplanten Namens oder einer früheren Annahme als fehlend behandelt werden.

Insbesondere gilt für diesen Scope ausdrücklich:

```text
Guard-PATHLINEs:
-> EXISTIEREN bereits in der geprüften v23-MIZ
-> NICHT erneut anlegen

Alarm-/Security-Perimeter:
-> werden zur Laufzeit durch MOOSE ZONE_RADIUS + OPSZONE erzeugt
-> KEINE ZON_BLUE_GND_<SITE>_ALARM Triggerzonen in der MIZ verlangen
```

## 4. Korrigierter Six-Site-Objektvertrag

| Site | Installation-ID | Warehouse | ACCESS | vorhandene Guard-PATHLINE |
|---|---|---|---|---|
| Fenty | `BLUE_GROUND_HUB_JALALABAD_FENTY` | `WH_BLUE_GND_FENTY` | `ZON_BLUE_GND_FENTY_ACCESS` | `OMW_RTE_BLUE_GUARD_FENTY_01` |
| Fortress | `BLUE_GROUND_COP_FORTRESS` | `WH_BLUE_GND_FORTRESS` | `ZON_BLUE_GND_FORTRESS_ACCESS` | `OMW_RTE_BLUE_GUARD_FORTRESS_01` |
| Joyce | `BLUE_GROUND_FOB_JOYCE` | `WH_BLUE_GND_JOYCE` | `ZON_BLUE_GND_JOYCE_ACCESS` | `OMW_RTE_BLUE_GUARD_JOYCE_01` |
| Wright | `BLUE_GROUND_FOB_WRIGHT` | `WH_BLUE_GND_WRIGHT` | `ZON_BLUE_GND_WRIGHT_ACCESS` | `OMW_RTE_BLUE_GUARD_WRIGHT_01` |
| Honaker-Miracle | `BLUE_GROUND_COP_HONAKER_MIRACLE` | `WH_BLUE_GND_HONAKER` | `ZON_BLUE_GND_HONAKER_ACCESS` | `OMW_RTE_BLUE_GUARD_HONAKER_01` |
| Bostick | `BLUE_GROUND_FOB_BOSTICK` | `WH_BLUE_GND_BOSTICK` | `ZON_BLUE_GND_BOSTICK_ACCESS` | `OMW_RTE_BLUE_GUARD_BOSTICK_01` |

Gemeinsames physisches Guard-Template im bestehenden Vertrag:

```text
TPL_BLUE_GND_INF_RIFLE_SQUAD_9
```

Für den Alarm-/Security-Perimeter gibt es bewusst **keine Mission-Editor-Spalte**, weil dessen Geometrie nicht als statisches Triggerzonenobjekt aus der MIZ bezogen wird.

## 5. MOOSE-first Runtime-Grenze

Die bestehende technische Richtung bleibt:

```text
site / installation anchor
-> runtime ZONE_RADIUS
-> OPSZONE
-> Alarm-/Threat-Evidence
-> Response-Demand
```

Die projektweite Governance bleibt unverändert:

```text
alarm perimeter
= threat-detection and response-trigger boundary
!= tactical battlespace
!= weapons engagement zone
!= fire-support target area
!= CAS engagement area
!= mission-end condition
```

Ein `OPSZONE:Defeated` beendet daher einen bereits ausgelösten QRF-, ARTY- oder CAS-Auftrag nicht automatisch.

## 6. Registry-/Testkorrektur

Die während der fehlerhaften Gate-5-Ausarbeitung eingeführten `alarmZone`-Felder im

```text
scripts/campaign/OMW_FireSupStratResupply_SiteRegistry.lua
```

werden entfernt.

Der Gate-2-Test darf keine Mission-Editor-Alarmzone mehr verlangen. Er muss stattdessen absichern, dass:

```text
- alle sechs Site-Verträge vorhanden sind;
- die sechs bereits vorhandenen Guard-PATHLINE-Namen gebunden sind;
- keine alarmZone-ME-Abhängigkeit wieder eingeführt wird;
- keine operative Asset-Vorselektion entsteht.
```

## 7. Was als Nächstes wirklich offen ist

Nicht offen ist die Erstellung der sechs PATHLINEs oder sechs neuen Alarmzonen.

Offen ist vielmehr die eigentliche generische Runtime-Integration und deren DCS-Prüfung:

```text
- bestehende sechs PATHLINEs aus dem MIZ-Vertrag verwenden;
- persistenten Guard-Lifecycle an den sechs Sites generisch anschließen;
- Runtime-ZONE_RADIUS/OPSZONE pro Site aus dem bestehenden Adaptervertrag aufbauen;
- keine zweite Assetwahl oder eigene Queue neben MOOSE einführen;
- anschließend einen gezielten Build und einen echten DCS-Acceptance-Lauf durchführen.
```

## 8. Dokumentationspflicht aus diesem Fehler

Für diesen Arbeitszweig gilt ab jetzt als zusätzliche Arbeitsdisziplin:

```text
Bei jedem fachlichen oder technischen Schritt, an dem
- eine Annahme verworfen wird,
- eine neue Evidenz gefunden wird,
- der Projektinhaber korrigiert,
- ein Runtime-Vertrag bestätigt wird,
- eine Designentscheidung getroffen oder zurückgenommen wird,

wird die zuständige Dokumentation im selben Arbeitsschritt aktualisiert.
```

Ziel ist ausdrücklich, vermeidbare Wiederholungen bereits gelöster Fehler in Folgechats zu verhindern.

## 9. Lokale Verifikation und Tooling-Korrektur – 12.09.2026

Der Projektinhaber hat den korrigierten Gate-5-Stand real lokal per Fast-Forward auf

```text
d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9
```

übernommen. Der Changeset bestand exakt aus dem Gate-5-Dokument, der SiteRegistry und dem Gate-2-Test. Die real lokal gemessenen SHA-256-Werte wurden in

```text
results/2026-09-12-fire-support-gate5-correction-local-verification.md
```

festgehalten.

Dabei wurde ein weiterer vermeidbarer Arbeitsfehler sichtbar: Es wurde erneut ein direkter lokaler

```text
lua tests\mission-demand\run.lua
```

Aufruf verlangt, obwohl auf dem Owner-Windows-Arbeitsplatz kein `lua`-Interpreter verfügbar ist. PowerShell meldete entsprechend `CommandNotFoundException`.

Dies ist ausdrücklich **kein Gate-5-Test-Failure**, sondern eine bekannte lokale Tooling-Grenze. Für Folgearbeit gilt daher zusätzlich:

```text
- keine direkten lokalen lua-/luac-Aufträge auf diesem Owner-Arbeitsplatz,
  solange keine geänderte Tooling-Baseline ausdrücklich bestätigt wurde;
- vorhandene versionierte PowerShell-Builder lokal verwenden;
- Lua-Syntax-/Unit-Tests über die vorhandene CI ausführen, wenn lokal kein Interpreter vorhanden ist;
- vor jeder lokalen Testanweisung zuerst die bekannte lokale Tooling-Baseline berücksichtigen.
```

Für exakt den korrigierten Head `d5a7ce1cdfb9c8c5e7e94abda159aea5455a82f9` waren die Repository-Prüfungen bereits erfolgreich:

```text
Documentation validation: PASS
run 34701334906

MissionDemand validation: PASS
run 34701334907
```

Der lokale Worktree enthielt nach der Verifikation nur die beiden bereits bekannten generierten `dist/`-Verzeichnisse; keine tracked lokale Änderung wurde gemeldet.

Gate 5 bleibt `PLANNED` und `validated_in_dcs: false`, weil die generische Six-Site-Runtime noch nicht in DCS akzeptiert ist. Die Existenz der sechs PATHLINEs in der genannten v23-MIZ ist dagegen read-only bestätigt und darf nicht erneut als offene ME-Arbeit dargestellt werden.