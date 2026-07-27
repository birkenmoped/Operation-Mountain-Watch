# Afghanistan 2010 - CombatFlite-Einrichtungen, HLO-Abdeckung und Höhenlimits

## 1. Credits und Quellenbasis

**Credits für Recherche, Zusammenstellung, Karte und zugehörige Materialien:**

> **Graveyard of Empires**  
> <https://www.patreon.com/cw/graveyard4DCS>

Dieses Dokument kombiniert ausschließlich:

1. die bereitgestellte CombatFlite-Datei `mission.xml`,
2. Teil 7 der Serie, `HLO Operational Ceilings in Afghanistan`,
3. Teil 8 der Serie, `Relationship with Medical Support and 2010 Basing Example`.

Die Quellen werden nicht durch allgemeine Reichweiten-, Krankenhaus- oder Hubschrauberdaten ergänzt.

## 2. Integrität und Metadaten der XML

```text
Datei:   mission.xml
Größe:   2.049.457 Byte
SHA-256: 1c4e77588d3ae9dce684215e6641f74aabcc17cc2e59778a39a736033b2c824c
```

Im XML-Kopf stehen unter anderem:

```xml
<Theater>PersianGulf</Theater>
<MissionName>NEW MISSION</MissionName>
<Year>2025</Year>
<Month>1</Month>
<Day>16</Day>
```

Gleichzeitig enthält die Datei Afghanistan-Grenzen, Afghanistan-Regionen sowie die in Teil 8 gezeigte Afghanistan-CSAR-/CASEVAC-Struktur. `PersianGulf` wird daher als **Metadatenwiderspruch** dokumentiert und nicht eigenmächtig korrigiert.

## 3. Layerübersicht

| Layer | Referenzpunkte | Kreise | Polygone | direkt erkennbare Funktion |
|---|---:|---:|---:|---|
| `HOSPITALS` | 18 | 0 | 0 | medizinische Referenzpunkte mit Role-Bezeichnung |
| `AFGHANISTAN - BORDER` | 0 | 0 | 1 | Staatsgrenze |
| `AFGHANISTAN - REGIONS` | 0 | 0 | 34 | regionale Unterteilung |
| `PR HLO` | 0 | 10 | 0 | Hubschrauber-/Aufgabenbezeichnung und Radiuswert |

## 4. Medizinische Referenzpunkte aus `HOSPITALS`

Die XML enthält keinen Ortsnamen im jeweiligen Referenzpunkt. Deshalb ist die folgende Tabelle auf neutrale IDs, Originalbezeichnung und Koordinate beschränkt.

| ID | XML-Bezeichnung | Rolle im Textfeld | Breite | Länge |
|---:|---|---:|---:|---:|
| MED-01 | `SP - Role 2` | 2 | 34.210000 | 62.228333 |
| MED-02 | `US - Role 1` | 1 | 32.362222 | 62.168333 |
| MED-03 | `UK - Role 2` | 2 | 31.850513 | 64.223671 |
| MED-04 | `CA/NL - Role 3` | 3 | 31.505833 | 65.847778 |
| MED-05 | `US/NL - Role 2` | 2 | 32.604974 | 65.864410 |
| MED-06 | `US - Role 2` | 2 | 32.133889 | 66.898889 |
| MED-07 | `US - Role 2` | 2 | 32.936783 | 69.156183 |
| MED-08 | `US - Role 2` | 2 | 33.363393 | 69.955294 |
| MED-09 | `FR/GE - Role 2` | 2 | 34.565259 | 69.214629 |
| MED-10 | `US - Role 2` | 2 | 34.767641 | 71.068596 |
| MED-11 | `US - Role 2` | 2 | 35.209090 | 71.523142 |
| MED-12 | `GE - Role 2` | 2 | 37.122138 | 70.520124 |
| MED-13 | `GE - Role 2` | 2 | 36.665136 | 68.910879 |
| MED-14 | `NE/GE - Role 2` | 2 | 36.706944 | 67.209444 |
| MED-15 | `LI - Role 2` | 2 | 34.526389 | 65.270833 |
| MED-16 | `NO - Role 2` | 2 | 35.930556 | 64.761111 |
| MED-17 | `US - Role 3` | 3 | 34.946389 | 69.265000 |
| MED-18 | `HU - Role 1` | 1 | 35.950000 | 68.710000 |

Zählung der XML-Bezeichnungen:

| Role-Text | Anzahl |
|---|---:|
| `Role 1` | 2 |
| `Role 2` | 14 |
| `Role 3` | 2 |

## 5. Medizinische Einordnung aus Teil 8

Teil 8 beschreibt:

- **Role 1:** frontnahe Erste Hilfe und Stabilisierung,
- **Role 2:** Trauma- und chirurgische Stabilisierung auf größeren FOBs,
- **Role 3:** umfassende Behandlung im Einsatzgebiet einschließlich komplexer Chirurgie und Intensivmedizin.

Als namentliche Beispiele nennt der Beitrag:

- **Camp Bastion** als Role 2 mit späterem Upgrade auf Role 3,
- **Tarin Kowt** in einer Bildunterschrift als niederländisches Role-2-Hospital,
- **Bagram Airfield** als Role 3,
- **Kandahar Airfield** als Role 3.

Ein koordinatenbasierter Abgleich legt nahe, dass MED-03, MED-05, MED-17 und MED-04 diesen Punkten entsprechen. Diese Zuordnung ist eine **Projektanalyse**, kein wörtliches Ortsfeld der XML, und muss vor Missionseditor-Namensvergabe gegen Karte beziehungsweise Original-`.cf` bestätigt werden.

## 6. `PR HLO`-Kreise

| ID | XML-Bezeichnung | Radiuswert | Einheit | Breite | Länge |
|---:|---|---:|---|---:|---:|
| HLO-01 | `1 x AS-332 MEDEVAC` | 75 | **nicht angegeben** | 34.210000 | 62.228333 |
| HLO-02 | `1 x CH-47 MEDEVAC` | 120 | **nicht angegeben** | 31.850513 | 64.223671 |
| HLO-03 | `3 x HH-60 CSAR + 1 x HH-60 MEDEVAC` | 100 | **nicht angegeben** | 31.505833 | 65.847778 |
| HLO-04 | `1 x UH-60 MEDEVAC` | 80 | **nicht angegeben** | 32.604974 | 65.864410 |
| HLO-05 | `1 x UH-60 MEDEVAC` | 80 | **nicht angegeben** | 32.133889 | 66.898889 |
| HLO-06 | `1 x UH-60 MEDEVAC` | 80 | **nicht angegeben** | 33.363393 | 69.955294 |
| HLO-07 | `2 x UH-60 MEDEVAC` | 80 | **nicht angegeben** | 34.399474 | 70.499096 |
| HLO-08 | `2 x HH-60 CSAR + 5 x UH-60 MEDEVAC` | 100 | **nicht angegeben** | 34.946389 | 69.265000 |
| HLO-09 | `1 x EC-725 2 + x AB-212 MEDEVAC` | 50 | **nicht angegeben** | 34.565259 | 69.214629 |
| HLO-10 | `1 x CH-53 MEDEVAC` | 120 | **nicht angegeben** | 37.283823 | 67.318795 |

Die Zeichenfolge von HLO-09 wird exakt aus der XML übernommen. Eine vermutete Korrektur ist nicht zulässig.

## 7. Reichweitenannahmen aus Teil 8

Teil 8 bezeichnet die dargestellten Kreise als angenäherte **combat radii** und erklärt, dass die Berechnung:

- die höheren Höhen und Temperaturen Afghanistans berücksichtigt,
- keine Luftbetankung annimmt,
- 30 Minuten On-Station-Zeit enthält.

Der Beitrag nennt keine Maßeinheit für die Zahlen 50, 75, 80, 100 und 120. Auch das XML-Feld enthält keine Einheit. Deshalb gilt:

```text
Radiuswert vorhanden != Radiusmaßeinheit belegt
```

Die Kreise dürfen bis zur Prüfung der Originaldatei `CSAR & CASEVAC Helo Radius.cf` nicht als harte NM-, km- oder Metergrenzen umgesetzt werden.

## 8. Dedicated CSAR gegenüber CASEVAC/CR

Teil 8 beschreibt für das Basing-Beispiel 2010:

- dedizierte HH-60G-CSAR-Kräfte **nur in Kandahar und Bagram**,
- mögliche Vorverlegung eines CSAR-Hubschraubers näher an das Einsatzgebiet,
- breiter verteilte CASEVAC-Hubschrauber,
- fehlende gleichwertige CSAR-Ausbildung, -Ausrüstung und -Fähigkeit bei diesen CASEVAC-Kräften,
- mögliche Recovery eines ausgestiegenen Piloten durch CASEVAC-Kräfte als **Combat Recovery** statt dediziertem CSAR.

Der XML-Abgleich passt dazu:

- HLO-03 enthält `HH-60 CSAR` und liegt am Koordinatenpunkt der in der Quelle als Kandahar bezeichneten Role-3-/CSAR-Struktur.
- HLO-08 enthält `HH-60 CSAR` und liegt am Koordinatenpunkt der in der Quelle als Bagram bezeichneten Role-3-/CSAR-Struktur.
- Die übrigen HLO-Texte enthalten `MEDEVAC`, nicht `CSAR`.

Diese Capability-Trennung muss im späteren Missionsdesign erhalten bleiben.

## 9. Höhenlimits aus Teil 7

Die in Teil 7 gezeigte ONC-Planungskarte verwendet:

| Zone | Schwelle | Darstellung im Beitrag |
|---|---:|---|
| Gelb | über 8.000 ft / 2.500 m | nur besonders leistungsfähige Hubschrauber, beispielhaft CH-47, mit begrenzter Nutzlast |
| Rot | über 10.000 ft / 3.000 m | keine Hubschrauber-Combat-Operation; luftabgesetztes Rettungsteam und spätere Aufnahme in geringerer Höhe |

Die Quelle betont OGE-/IGE-Hover-Leistung, Temperatur, Gewicht, Treibstoff und Nutzlast als entscheidende Faktoren. Die farbigen Zonen sind eine quellenbasierte Planungsvereinfachung und keine universelle Leistungsgrenze jedes DCS-Luftfahrzeugs.

## 10. Medizinische Zeitkette

Teil 8 beschreibt die **10-1-2-Regel**:

- 10 Minuten bis zu lebensrettenden Maßnahmen,
- 1 Stunde bis zur Resuscitation,
- 2 Stunden bis zur vollständigen Behandlung.

Die Hubschrauber- und Hospitalstruktur muss deshalb als zusammenhängende Kette verstanden werden. Ein geometrisch erreichbarer Pickup ist nicht automatisch ein vollständiger medizinischer Missionserfolg.

## 11. Belastbare Nutzung in Operation Mountain Watch

### 11.1 Direkt nutzbar

- die 18 medizinischen Rohpunkte als Kandidatenliste,
- die 10 HLO-Mittelpunkte,
- die Originalbezeichnungen der Assets,
- die numerischen Radiuswerte mit Kennzeichnung `UNIT_UNKNOWN`,
- die Trennung von Bagram/Kandahar als dedizierten CSAR-Knoten gegenüber verteilten MEDEVAC-/CR-Knoten,
- die Höhenplanungszonen aus Teil 7,
- die Reichweitenannahmen aus Teil 8,
- die medizinischen Rollen und die 10-1-2-Zeitkette.

### 11.2 Vor Umsetzung zu bestätigen

1. Original-`.cf` und darin verwendete Radiusmaßeinheit.
2. Namentliche Zuordnung aller 18 medizinischen Koordinaten.
3. Namentliche Zuordnung aller 10 HLO-Mittelpunkte.
4. Übereinstimmung mit DCS-Afghanistan und OMW-Zeitraum.
5. DCS-taugliche Landezonen, Hoist- oder Übergabepunkte.
6. Leistung der konkret eingesetzten DCS-Hubschrauber bei Höhe, Temperatur und Missionsmasse.
7. Umsetzung der medizinischen Role- und STRATEVAC-Kette.

## 12. Nutzungsrechte und ausstehende Originalanhänge

Teil 7 erklärt für die HLO-Ceiling-Karte: Mitglieder dürfen die Datei nutzen, sie aber ohne Erlaubnis des Erstellers nicht teilen oder verändern. OMW übernimmt daher nur die beschriebenen Planungsregeln und verteilt die Karte nicht.

Weiterhin ausstehend:

- `ONC HLO Ceilings.pdf`,
- `ONC HLO Celilings.jpg`,
- `CSAR & CASEVAC Helo Radius.cf`.

Die bereitgestellte `mission.xml` bleibt die einzige unmittelbar auswertbare CombatFlite-Datendatei.

## 13. Quellen

- Graveyard of Empires, `Combat Search and Rescue: HLO Operational Ceilings in Afghanistan (7/8)`, 28.01.2025.
- Graveyard of Empires, `Combat Search and Rescue: Relationship with Medical Support and 2010 Basing Example (8/8)`, 01.02.2025.
- bereitgestellte CombatFlite-Datei `mission.xml`.
