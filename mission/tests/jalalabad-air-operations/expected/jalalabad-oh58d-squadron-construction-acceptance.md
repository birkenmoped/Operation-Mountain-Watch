# Jalalabad OH-58D SQUADRON Construction – Mission Editor Setup and Acceptance

## Zweck

Diese Stufe prüft genau ein zweischiffiges OH-58D-KI-Template und die daraus abgeleitete Konstruktion eines MOOSE-`SQUADRON` innerhalb des bereits erfolgreich konstruierten Jalalabad-`AIRWING`.

Das AIRWING wird weiterhin nicht gestartet. Es wird kein Flugauftrag erzeugt und kein Luftfahrzeug gespawnt.

## Bestandsabbildung

Der historisch festgelegte Bestand beträgt 24 OH-58D. `SQUADRON:New()` erwartet als zweiten Parameter die Anzahl der Asset-Gruppen, nicht die Anzahl einzelner Luftfahrzeuge.

Bei einem 2-Ship-Template gilt daher:

```text
24 OH-58D / 2 Luftfahrzeuge je Gruppe = 12 Asset-Gruppen
```

Das Bundle konstruiert deshalb:

```text
Squadron: SQ_US_JBAD_OH58D_6_6_CAV
Template: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Aircraft: 24
Asset groups: 12
Grouping: 2
Capability: RECON
```

## Repository-Stand

Vor dem Test muss der aktuelle Branch gezogen, das Bundle neu gebaut und erneut in die Mission eingebettet werden.

```powershell
cd P:\DCS-DEV\Operation-Mountain-Watch

git pull --ff-only
git rev-parse HEAD

powershell.exe -NoProfile -ExecutionPolicy Bypass `
  -File ".\tools\build-jalalabad-air-operations-bundle.ps1"
```

Danach `mission\tests\jalalabad-air-operations\dist\OMW_AirOps_Jalalabad.lua` im vorhandenen `DO SCRIPT FILE` erneut auswählen und die Mission speichern.

## Einzige neue Mission-Editor-Gruppe

Lege eine BLUE-/USA-Hubschraubergruppe mit exakt diesen Eigenschaften an:

```text
Group name: TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Country: USA
Coalition: BLUE
Aircraft type: OH-58D
DCS internal type expected by test: OH58D
Number of units: 2
Skill: High
Late activation: enabled
Uncontrolled: disabled
```

Einheitennamen:

```text
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-1
TPL_AIR_US_JBAD_OH58D_RECON_2SHIP-2
```

## Platzierung

- Startpunkt auf Jalalabad.
- Startart `Takeoff from parking cold` beziehungsweise die deutschsprachige Entsprechung.
- Zwei freie Hubschrauber-Parkpositionen verwenden.
- Die Gruppe darf wegen `Late activation` beim Missionsstart nicht erscheinen.
- Für diesen Konstruktionstest ist kein besonderer Waffen-Payload erforderlich; DCS-Standardkonfiguration genügt.

## Unverändert lassen

Noch nicht anlegen:

```text
CLIENT_US_JBAD_...
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_LEAD_1SHIP
TPL_AIR_US_JBAD_UH60_MEDEVAC_COVER_1SHIP
STATIC_AIR_US_JBAD_...
ZONE_AIR_US_JBAD_...
```

Den vorhandenen Warehouse-Anker `WH_AIR_US_JALALABAD` nicht verändern.

## Testdurchführung

1. Mission starten.
2. Mindestens 20 Sekunden laufen lassen.
3. Prüfen, dass kein OH-58D sichtbar gespawnt wurde.
4. Mission beenden.
5. Nur die aktuelle `dcs.log` bereitstellen.

## Erwartete Logausgabe

Der Validator muss das Template erkennen:

```text
[OMW][ValidateMissionTemplates] OK GROUP TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
```

Der neue Testabschnitt muss beide Einheiten prüfen:

```text
[OMW][AirOps.JBAD.OH58D] Template unit=1 ... type=OH58D
[OMW][AirOps.JBAD.OH58D] Template unit=2 ... type=OH58D
```

Abschließend wird erwartet:

```text
[OMW][AirOps.JBAD.OH58D] SQUADRON constructed and linked. name=SQ_US_JBAD_OH58D_6_6_CAV aircraft=24 assetGroups=12 groupSize=2 capability=RECON. AIRWING not started.
```

## PASS-Kriterien

- Warehouse-Anker bleibt erkannt.
- AIRWING wird weiterhin fehlerfrei konstruiert und Jalalabad zugeordnet.
- Templategruppe wird unter dem exakten Gruppennamen gefunden.
- Die Gruppe enthält exakt zwei Einheiten.
- Beide Einheiten melden den DCS-Typ `OH58D`.
- `SQUADRON:New()` wird mit 12 Asset-Gruppen ausgeführt.
- `SetGrouping(2)`, `AddMissionCapability(RECON)` und `AIRWING:AddSquadron()` erzeugen keinen Lua-Fehler.
- `AIRWING:GetSquadron()` bestätigt die Verknüpfung.
- Kein `AIRWING:Start()`, kein Auftrag und kein Spawn.

## FAIL-Kriterien

- Template nicht gefunden oder falsch benannt.
- Gruppenstärke ungleich zwei.
- DCS-Typ ungleich `OH58D`.
- Fehler bei SQUADRON-Konstruktion, Capability oder AIRWING-Verknüpfung.
- sichtbarer unbeabsichtigter Spawn.
