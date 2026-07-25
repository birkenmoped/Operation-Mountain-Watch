# Jalalabad AH-64D SQUADRON construction acceptance

## Ziel

Diese Stufe ergänzt genau ein zweischiffiges, spät aktiviertes AH-64D-KI-Template und prüft ausschließlich:

- den tatsächlichen DCS-Typnamen,
- die Gruppenstärke von zwei Luftfahrzeugen,
- die Umrechnung des Bestands von acht AH-64D in vier Asset-Gruppen,
- `SQUADRON:New()`,
- `SetGrouping(2)`,
- CAS-Capability,
- `AIRWING:AddSquadron()` und `AIRWING:GetSquadron()`.

Das AIRWING wird weiterhin nicht gestartet. Es werden keine AUFTRAG-Missionen erzeugt und keine Luftfahrzeuge gespawnt.

## Mission-Editor-Objekt

```text
Koalition:        BLUE
Land:             USA
Luftfahrzeug:     AH-64D BLK II
Anzahl:           2
Skill:            High
Späte Aktivierung: aktiviert
Uncontrolled:     deaktiviert
Startart:         Takeoff from parking cold
```

Exakter Gruppenname:

```text
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
```

Einheitennamen:

```text
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-1
TPL_AIR_US_JBAD_AH64D_CAS_2SHIP-2
```

Die Gruppe wird auf zwei freien Hubschrauberpositionen in Jalalabad platziert. Für diese Konstruktionsstufe genügt eine DCS-Standardbewaffnung.

## Erwartete Diagnose

```text
[OMW][DumpAircraftTypes] Group=TPL_AIR_US_JBAD_AH64D_CAS_2SHIP Unit=1 ... Type=AH-64D_BLK_II ...
[OMW][DumpAircraftTypes] Group=TPL_AIR_US_JBAD_AH64D_CAS_2SHIP Unit=2 ... Type=AH-64D_BLK_II ...
```

Erwartete Abschlussmeldung:

```text
[OMW][AirOps.JBAD.AH64D] SQUADRON constructed and linked. name=SQ_US_JBAD_AH64D_B_1_10_AVN aircraft=8 assetGroups=4 groupSize=2 capability=CAS. AIRWING not started.
```

## PASS-Kriterien

- Warehouse-Anker und AIRWING bleiben fehlerfrei verfügbar.
- Das OH-58D-SQUADRON wird weiterhin erfolgreich konstruiert.
- Das AH-64D-Template wird mit exakt zwei Einheiten erkannt.
- Beide Einheiten melden `AH-64D_BLK_II`.
- Das AH-64D-SQUADRON wird mit vier Asset-Gruppen konstruiert und mit dem AIRWING verknüpft.
- Es tritt kein `Error in timer function` aus dem Jalalabad-Air-Ops-Bundle auf.
- Es erscheint kein AH-64D in der Mission, weil das Template spät aktiviert und das AIRWING ungestartet bleibt.

## Außerhalb dieser Stufe

- Spieler-Slots,
- UH-60-Templates,
- Luftfahrzeug-Statics,
- Payload-Pools,
- COMMANDER,
- AUFTRAG-Missionen,
- AIRWING-Start,
- Dispatch- und Gleichzeitigkeitstests.
