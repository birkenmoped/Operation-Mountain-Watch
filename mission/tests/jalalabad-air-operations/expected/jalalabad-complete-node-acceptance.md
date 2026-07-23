# Jalalabad AirOps – vorheriger Abschlussauftrag außer Kraft

## Status

```text
STOP – NICHT ALS ABSCHLUSSAUFTRAG AUSFÜHREN
```

Der vorherige Abschlussauftrag basierte auf einer unvollständigen lokalen ORBAT:

```text
24 OH-58D
 8 AH-64D
 6 UH-60-Familie
```

Zeitgenössische Berichte zu Task Force Shooter sowie Satellitenbilder von Jalalabad aus dem Jahr 2011 belegen zusätzlich ein substantielles CH-47-Schwerlastkontingent. Jalalabad darf ohne diesen Bestandteil nicht als vollständiger Air-Ops-Knoten abgenommen werden.

## Korrigierter Arbeitsstand

Vorläufige, evidenzbasierte Planungsgröße:

```text
24 OH-58D
 8 AH-64D
 6 UH-60-Familie
 8 CH-47 Schwerlast
```

Die CH-47-Zahl ist ein Arbeitswert aus der sichtbaren 2011er Belegung und dem dokumentierten Umfang der regionalen Heavy-Lift-Kompanie. Die genaue Unterstellung wird bis zur abschließenden Rotationszuordnung neutral als Task-Force-Shooter-Heavy-Lift-Element geführt.

## Weiterhin gültig

Bereits bestätigte technische Ergebnisse bleiben bestehen:

- Jalalabad als MOOSE-Airbase ID 19,
- 50 auslesbare Parking-Einträge,
- Warehouse-Anker `WH_AIR_US_JALALABAD`,
- natives DCS-Warehouse und MOOSE-Storage,
- AIRWING-Konstruktion und Airbase-Zuordnung,
- OH-58D-Typ und OH-58D-SQUADRON-Konstruktion,
- AH-64D-Typ und AH-64D-SQUADRON-Konstruktion.

Nicht mehr gültig ist ausschließlich die Behauptung, der bisherige 24/8/6-Stand bilde Jalalabad vollständig ab.

## Technische Sperre

Der aktuelle Branch enthält eine harte Abschlussblockade:

```text
CorrectionPending.CH47 = true
```

Solange die überarbeitete CH-47-Umsetzung nicht vorliegt, muss der Finalizer melden:

```text
[OMW][AirOps.JBAD.COMPLETE] RESULT: INCOMPLETE
```

AIRWING und COMMANDER dürfen dabei nicht gestartet werden.

## Nächster gültiger Arbeitsauftrag

Dieser Dateiname wird erst wieder als ausführbarer Abschlussauftrag verwendet, nachdem die folgenden CH-47-Bestandteile vollständig ergänzt wurden:

- CH-47-SQUADRON,
- KI-Template für Heavy Lift,
- Spieler-Slots gemäß endgültiger Entscheidung,
- gepoolte CH-47-Statics,
- C1-C14-/Heavy-Lift-Parking-Konzept,
- Heavy-Lift-Bereitstellungs- und Ladezone,
- Validierung des tatsächlich verfügbaren DCS-Typs,
- aktualisierte Gesamtbestands- und Abschlussprüfung.

Dokumentation der Korrektur:

```text
results/2026-07-23-jalalabad-ch47-orbat-correction.md
```
