# Jalalabad OH-58D SQUADRON construction – PASS

## Testlauf

```text
DCS-Zeitstempel: 2026-07-23 18:57:10 bis 18:57:50
Teststufe: OH-58D-Template und nicht gestartetes SQUADRON
```

## Ergebnis

PASS.

Bestätigt wurden:

- Templategruppe `TPL_AIR_US_JBAD_OH58D_RECON_2SHIP` ist vorhanden.
- Die Gruppe enthält exakt zwei Einheiten.
- Beide Einheiten verwenden den DCS-Typ `OH58D`.
- Der Warehouse-Anker `WH_AIR_US_JALALABAD` ist vorhanden.
- `AW_US_JALALABAD` wurde erneut fehlerfrei konstruiert und Jalalabad zugeordnet.
- Der Bestand von 24 OH-58D wurde für ein zweischiffiges Template in 12 Asset-Gruppen umgesetzt.
- `SQ_US_JBAD_OH58D_6_6_CAV` wurde konstruiert und mit dem AIRWING verknüpft.
- Die Missionsfähigkeit `RECON` wurde gesetzt.
- Das AIRWING blieb ungestartet; es wurde kein Flugauftrag erzeugt.

Maßgebliche Abschlussmeldung:

```text
[OMW][AirOps.JBAD.OH58D] SQUADRON constructed and linked. name=SQ_US_JBAD_OH58D_6_6_CAV aircraft=24 assetGroups=12 groupSize=2 capability=RECON. AIRWING not started.
```

MOOSE protokollierte das Asset mit:

```text
Template name  = TPL_AIR_US_JBAD_OH58D_RECON_2SHIP
Unit type      = OH58D
Attribute      = Air_AttackHelo
Units #        = 2
```

## Abgrenzung

Der beim Missionsende auftretende Fehler in `Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua` gehört nicht zum Jalalabad-Air-Ops-Bundle.

Nicht Bestandteil dieser Stufe waren:

- AIRWING-Start,
- AUFTRAG-Erzeugung,
- tatsächliche OH-58D-Spawns,
- Spieler-Slots,
- AH-64D- oder UH-60-SQUADRONs,
- Payload-Pools und Dispatch-Limits.
