---
document_id: OMW-EVIDENCE-JULY-2011-ORBAT-SOURCE-AUTHORITY
status: BINDING_PROJECT_DECISION
document_class: SOURCE_AUTHORITY_RULE
owning_policy: OMW-GOV-001
authoritative_for:
  - hierarchy for historical unit, command, location, role and area-of-responsibility decisions within the OMW campaign period
  - use of the July 2011 Afghanistan Order of Battle as the primary dated ORBAT snapshot
  - limits on how supplemental sources may modify or extend that snapshot
not_authoritative_for:
  - active DCS or MOOSE runtime acceptance
  - exact aircraft or personnel strength where the source does not explicitly state it
  - units or support categories explicitly omitted by the source
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
superseded_by:
source_branch: main
source_commit: 617eccaf4c43ff5bb52387a30709c38a287cd636
validated_in_dcs: false
---

# July 2011 Afghanistan Order of Battle – verbindliche Quellenautorität

## 1. Belegte Primärquelle

Für den innerhalb des OMW-Kampagnenzeitraums liegenden Referenzzeitpunkt **Juli 2011** gilt folgende bereitgestellte Quelldatei als primärer historischer ORBAT-Snapshot:

```text
122362406-Afghanistan-order-of-battle-july-2011.pdf
```

Bibliografische Zuordnung:

```text
Wesley Morgan
Afghanistan Order of Battle – Coalition Combat Forces in Afghanistan
Institute for the Study of War
July 2011
13 PDF pages including 123 footnotes
```

Die normalisierte Projektdokumentation dieser Quelle steht in:

```text
docs/64-afghanistan-order-of-battle-july-2011.md
```

## 2. Verbindliche Autoritätsregel

Für historische Entscheidungen zum Juli-2011-Snapshot ist diese Quelle vorrangig für:

- aktive Einheit und übergeordnete Formation;
- dokumentierten Stationierungs- oder Hauptstandort;
- dokumentierte Rolle und Area of Responsibility;
- dokumentierte Rotation beziehungsweise Ablösung;
- in den Fußnoten ausdrücklich zugeordnete Luftfahrzeug- und Ausrüstungstypen.

```text
JULY_2011_UNIT_AND_LOCATION_BASELINE
=
122362406-Afghanistan-order-of-battle-july-2011.pdf
```

Sie ist damit die historische Ausgangslage, aus der OMW seine zusammengesetzte, spielbare ORBAT ableitet.

## 3. Zulässige Nutzung ergänzender Quellen

Zusätzliche Dokumente, offizielle Einheitsberichte, Organisationsunterlagen, Einsatzberichte und Satellitenaufnahmen dürfen die Juli-2011-Baseline ergänzen, insbesondere für:

- Company-, Troop-, Platoon- oder Detachment-Zuordnung unterhalb der im ORBAT genannten Ebene;
- nominelle oder für den Einsatz zugewiesene Fluggerätstärke;
- zusätzlich zugeteilte Luftfahrzeuge;
- Mission-Ready-, Wartungs-, Reserve- oder Verluststatus;
- temporäre Forward Operating Locations und Außenstationierungen;
- konkrete Einsatzaufträge, Versorgungsflüge und Air-Assault-Aufgaben;
- sichtbaren Mindestbestand und Rampenkapazität auf Satellitenbildern;
- DCS-Ersatzmuster und spielbare OMW-Bestandsentscheidungen.

Solche Ergänzungen sind als `SOURCE_DERIVED`, `PROJECT_RECONSTRUCTION` oder `PROJECT_DECISION` zu kennzeichnen, wenn die exakte Aussage nicht wörtlich aus der Juli-2011-ORBAT stammt.

## 4. Unzulässige stillschweigende Änderungen

Eine ergänzende Quelle darf folgende Angaben nicht stillschweigend ersetzen:

- die im Juli 2011 genannte aktive Einheit;
- deren dokumentierte übergeordnete Formation;
- deren dokumentierten Standort;
- deren dokumentierte Rolle oder AOR.

Eine Abweichung ist nur zulässig, wenn eine belastbarere Quelle den konkreten Juli-2011-Eintrag ausdrücklich korrigiert oder dessen abweichenden Status für denselben Zeitpunkt belegt. Dann sind beide Quellen, der Widerspruch und die Projektentscheidung zu dokumentieren.

```text
SUPPLEMENTAL_SOURCE != SILENT_ORBAT_REPLACEMENT
```

## 5. Bekannte Grenzen der Primärquelle

Die Quelle ist stark, aber nicht vollständig. Nach ihrem eigenen Scope fehlen oder sind nicht vollständig erfasst unter anderem:

- black special operations units;
- Logistics Units;
- Transportation Units;
- Medical Units;
- Intelligence Units;
- Provincial Reconstruction Teams;
- einzelne Companies, Platoons, temporäre Detachments und tageweise Verlegungen.

Daraus folgt:

```text
NOT_LISTED != NOT_PRESENT
UNIT_LISTED != EXACT_STRENGTH_KNOWN
BASE_LISTED != EVERY_AIRCRAFT_PRESENT_ON_RAMP
```

## 6. Verhältnis zur aktiven OMW-ORBAT

Die historische Juli-2011-Quelle bestimmt die belegte Einheit-, Führungs- und Standortbasis. Die verbindlichen aktiven OMW-Bestände und Player-Slots bleiben Projektentscheidungen gemäß `OMW-AIR-ACTIVE-ORBAT` und den jeweiligen Basenmanifesten.

Der korrekte Ableitungsweg lautet:

```text
July 2011 ORBAT unit/location baseline
+ supplemental unit and strength evidence
+ satellite visual minimum and capacity evidence
+ documented DCS substitutions and gameplay limits
= binding OMW active inventory decision
```

Clients, KI-Templates und Statics sind Repräsentationen eines logischen Bestands und keine zusätzlichen historischen Luftfahrzeuge.

## 7. Anwendung auf Bagram

Für den Juli-2011-Snapshot sind damit unter anderem primär belegt:

```text
83rd Expeditionary Rescue Squadron – Bagram – HH-60G
774th Expeditionary Airlift Squadron – Bagram – C-130
TF Phoenix / 3-10 General Support Aviation – Bagram
```

Ergänzende Quellen dürfen hierzu Stückzahlen, Varianten, Untereinheiten, Detachments, Verfügbarkeit und spätere Rotationen klären. Sie dürfen die genannten Juli-2011-Einheiten und ihren Standort nicht ohne dokumentierten Gegenbeleg ersetzen.

## 8. Pflicht für Unterdokumentationen

Alle Flugplatzmanifeste, Implementierungsübergaben, Evidenzakten und Unterprojektzweige müssen diese Quellenhierarchie übernehmen. Wo ältere Texte eine andere Einheit oder einen anderen Standort ohne belastbare Juli-2011-Gegenquelle verwenden, ist die Abweichung bei der nächsten Bearbeitung zu korrigieren oder ausdrücklich als alternative Rotation beziehungsweise OMW-Kompositentscheidung zu kennzeichnen.
