# Jalalabad AH-64D SQUADRON construction – PASS

## Testlauf

```text
DCS: 2.9.28.26283 MT
Zeitfenster: 2026-07-23 19:41 UTC
MOOSE: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
```

## Bestätigte Missionseditor-Daten

```text
Gruppe: TPL_AIR_US_JBAD_AH64D_CAS_2SHIP
Einheiten: 2
Typ: AH-64D_BLK_II
Skill: High
```

## Bestätigte MOOSE-Konstruktion

```text
AIRWING: AW_US_JALALABAD
SQUADRON: SQ_US_JBAD_AH64D_B_1_10_AVN
ORBAT-Bestand: 8 Luftfahrzeuge
Template-Gruppengröße: 2
MOOSE-Asset-Gruppen: 4
Capability: CAS
AIRWING gestartet: nein (damalige isolierte Validierungsstufe)
```

Die Abschlussmeldung des Testbundles lautete:

```text
[OMW][AirOps.JBAD.AH64D] SQUADRON constructed and linked. name=SQ_US_JBAD_AH64D_B_1_10_AVN aircraft=8 assetGroups=4 groupSize=2 capability=CAS. AIRWING not started.
```

## Ergebnis

PASS. Typ, Gruppengröße, Bestandsumrechnung, SQUADRON-Konstruktion und Verknüpfung mit dem Jalalabad-AIRWING sind bestätigt.

Der beim Missionsende auftretende Fehler in `Saved Games\DCS.openbeta\Scripts\Hooks\bhHook.lua` gehört nicht zum OMW-AirOps-Bundle.
