# Jalalabad Phase 1 – Regression des Missionseditor-Objektvertrags

Stand: 2026-07-25  
Branch: `feature/jalalabad-airwing-phase1-functional-tests`

## Befund

Der DCS-Lauf mit BuilderVersion `JBAD-AIR-OPS-PHASE1-14-MOOSE-FIRST` initialisierte Manifest, Observer, Logistics, Factory, Controller, F10-Menü, AIRWING und COMMANDER. Der Controller blockierte anschließend mit elf angeblich fehlenden Missionseditor-Objekten.

Die geprüfte Mission `OMW_Jalalabad_AirOps_Phase1_Test.miz` enthält weiterhin die seit Phase 1 verwendeten Objektbezeichnungen. Die Objekte waren nicht gelöscht oder umbenannt worden.

## Ursache

Im MOOSE-first-Refactor waren die vorhandenen Namen im Manifest ohne Missionseditor-Migration durch nicht existierende Aliasnamen ersetzt worden:

```text
TZ_AIR_US_JBAD_...
TG_RED_JBAD_...
TG_BLUE_JBAD_...
ST_BLUE_JBAD_...
```

Diese Aliasnamen existieren nicht in der Testmission.

## Wiederhergestellter kanonischer Objektvertrag

```text
ZONE_TEST_US_JBAD_RECON_01
ZONE_TEST_US_JBAD_RECON_02
ZONE_TEST_US_JBAD_RECON_03
ZONE_TEST_US_JBAD_CAS
TPL_GROUND_RED_JBAD_PHASE1_CAS_TARGET
TPL_GROUND_BLUE_JBAD_PHASE1_UH60_TROOPS
ZONE_AIR_US_JBAD_LOGISTICS_LOAD
ZONE_TEST_US_JBAD_UH60_DROPOFF
TEST_CARGO_BLUE_JBAD_CH47_01
ZONE_AIR_US_JBAD_SLING_PICKUP
ZONE_AIR_US_JBAD_LOGISTICS_UNLOAD
```

## Korrektur

- `11-phase1-test-manifest.lua` auf die vorhandenen kanonischen Namen zurückgestellt;
- Manifestversion auf `JBAD-PHASE1-12` erhöht;
- BuilderVersion auf `JBAD-AIR-OPS-PHASE1-15-MOOSE-FIRST` erhöht;
- Builder blockiert künftig fehlende kanonische Namen und erfundene `TZ_`/`TG_`/`ST_`-Aliase;
- ausführbarer Lua-Smoke-Test prüft alle elf Objektnamen zusätzlich;
- CI-Headerprüfung um den Missionsobjektvertrag erweitert.

## Missionsdatei

Die `.miz` wurde nicht verändert. Für den nächsten Lauf ist ausschließlich das neu gebaute Lua-Bundle erneut in der bestehenden `DO SCRIPT FILE`-Aktion auszuwählen.

## Abnahmestatus

- Ursache identifiziert: PASS
- Repositorykorrektur: IMPLEMENTIERT
- Missionseditor-Änderung erforderlich: NEIN
- lokaler Builderlauf: AUSSTEHEND
- DCS-Lauf mit korrigiertem Bundle: AUSSTEHEND
