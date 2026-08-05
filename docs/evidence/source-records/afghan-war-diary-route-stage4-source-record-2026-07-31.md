---
document_id: OMW-EVIDENCE-AFGHAN-WAR-DIARY-ROUTE-STAGE4-2026-07-31
status: BINDING
document_class: SOURCE_RECORD
owning_policy: OMW-GOV-001
authoritative_for:
  - provenance, extraction method and terminology limits for stage-four Route/RTE/ASR analysis of the Afghan War Diary export
  - inventory of repeatedly attested non-MSR route codenames found in the full dataset
not_authoritative_for:
  - classification of every named route as an MSR
  - final route geometry or road centerline
  - historical continuity into 2010/2011
  - DCS PATHLINE acceptance
scenario_period: 2010-08-01/2011-12-31
source_period: 2004-01-01/2009-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
source_branch: main
source_commit: 6040bd378cff9c1c01f25e30d4a180bd250f9a19
validated_in_dcs: false
---

# Afghan War Diary – Route-, RTE- und ASR-Auswertung Stufe 4

## 1. Zweck

Stufe 4 erweitert die bisherige Suche nach `MSR` auf den vollständigen War-Diary-Datensatz mit 76.911 Berichten. Untersucht wurden explizite Formen:

```text
MSR <Name>
ASR <Name>
ROUTE <Name>
RTE <Name oder Code>
```

Der breite Rohsuchlauf erzeugte zahlreiche Sprachfragmente wie `route back`, `route travel ...` oder Statussätze. Diese Rohkandidaten wurden nicht als historische Routennamen übernommen.

Quellenklassifikation:

```text
INCORPORATED_WITH_LIMITS
```

## 2. Konservative Kuratierung

Ein Name wurde nur in die kuratierte Ergebnismenge aufgenommen, wenn:

1. er in mindestens zwei unterschiedlichen Berichten explizit nach `MSR`, `ASR`, `ROUTE` oder `RTE` vorkam;
2. er die Form eines Codenamens oder wiederkehrenden Routennamens hatte;
3. offensichtliche Berichtssprache, Richtungsangaben, Statusbegriffe, Entfernungen und Bewegungsanweisungen ausgeschlossen wurden;
4. Schreibvarianten wie `VOLKSWAGON`/`VOLKSWAGEN` beziehungsweise `FOSTER`/`FOSTERS` zusammengeführt wurden.

Die Kuratierung ergab:

```text
56 wiederholt belegte benannte Routen in der konservativen Arbeitsmenge
31 Namen neu gegenüber der MSR-Stufe 3
23 Namen mit mindestens einer expliziten MSR-Nennung
33 Namen nur als ASR, ROUTE oder RTE belegt
```

Die Zahl 56 ist kein Anspruch auf Vollständigkeit des gesamten afghanischen Routennetzes.

## 3. Verbindliche Terminologiegrenze

Für OMW gilt:

```text
MSR_EXPLICITLY_ATTESTED
= mindestens ein Bericht nennt ausdrücklich MSR <Name>

ASR_OR_ROUTE_ATTESTED
= mindestens ein Bericht nennt ASR <Name>, aber keine MSR-Nennung liegt vor

ROUTE_OR_RTE_ATTESTED
= wiederholt als ROUTE oder RTE genannt, aber nicht als MSR belegt
```

Ein `ROUTE`-, `RTE`- oder `ASR`-Codename darf nicht allein aufgrund seiner Häufigkeit als Main Supply Route klassifiziert werden.

## 4. Neu gegenüber Stufe 3: ASR oder Route

### 4.1 ASR- oder Route-belegte Namen

```text
REDSKINS
DALLAS
```

`REDSKINS` tritt überwiegend in RC South auf; `DALLAS` überwiegend in RC East. Beide benötigen eine getrennte Geometrie- und Funktionsprüfung.

### 4.2 Wiederholt als Route/RTE belegte Namen

```text
FOSTERS
COWBOYS
JEEP
FERRARI
VIOLET
DUCK
BMW
LAKE EFFECT
SUMMIT
CHICKEN
TORCH
BOTTLE
CIVIC
BROWN
DODGE
LITHIUM
HYENA
NISSAN
CHAINSAW
YUKON
BLUE
EXCEL
OREGON
OTTAWA
QUEBEC
MIATA
CORVETTE
PINK
MULE
```

Diese Namen sind reale wiederkehrende Codename-Kandidaten im War-Diary-Bestand. Ihre funktionale Einstufung bleibt offen.

## 5. Regionale Konzentrationen der neuen Namen

Die konservative Arbeitsmenge zeigt unter anderem:

- `FOSTERS`, `LAKE EFFECT`, `SUMMIT`, `CHICKEN`, `HYENA`, `OTTAWA`, `PINK` und `MULE` überwiegend in RC South;
- `JEEP`, `FERRARI`, `BMW`, `TORCH`, `DODGE`, `NISSAN`, `CHAINSAW`, `YUKON`, `EXCEL`, `QUEBEC`, `MIATA` und `CORVETTE` überwiegend in RC East;
- `VIOLET` überwiegend in RC Capital und RC East;
- `LITHIUM` überwiegend in RC West;
- `BOTTLE` in RC Capital, RC East und RC West;
- `OREGON` überwiegend in RC South.

Eine regionale Konzentration beweist keine durchgehende Liniengeometrie. Derselbe Codename kann theoretisch mehrfach oder lokal wiederverwendet worden sein.

## 6. Bedeutung für bereits dokumentierte MSRs

Stufe 4 bestätigt, dass die War Diaries unterschiedliche Routenterminologien nebeneinander verwenden. Dadurch müssen frühere Ergebnisse differenziert bleiben:

- `MSR California`, `MSR Vermont`, `MSR Illinois`, `MSR Nevada` und weitere explizit so benannte Routen bleiben als MSR-Namensbelege gültig;
- `Route Oregon` im War-Diary-Bestand ist ein zusätzlicher Namensbeleg, ersetzt aber nicht die separate Quellenprüfung zur Bezeichnung `MSR Oregon`;
- `Route Honda` oder `RTE Honda` ist nicht automatisch `MSR Honda`;
- `ASR Audi` beziehungsweise `Route Audi` ist nicht automatisch eine Main Supply Route.

## 7. Daten- und Geometriegrenzen

1. Ein Routenname kann in einem Bericht erwähnt werden, obwohl die Ereigniskoordinate nur in der Nähe liegt.
2. Wiederholte Namen können verschiedene Teilabschnitte oder zeitlich veränderte Bezeichnungen betreffen.
3. Routennamen können durch Einheiten lokal oder temporär vergeben worden sein.
4. Ein chronologisches oder räumliches Verbinden der Vorfallspunkte erzeugt keine valide Straße.
5. Die Quelle endet 2009; eine Verwendung für den OMW-Zeitraum 2010/2011 benötigt Kontinuitätsbelege.
6. Eine Übernahme in Dokument 49 oder den Missionseditor benötigt Kartenabgleich, Endpunktbelege und DCS-Befahrbarkeitsprüfung.

## 8. Arbeitsartefakte

Außerhalb des Repositorys wurden erzeugt:

```text
afg_war_diary_route_stage4_curated_analysis.xlsx
afg_war_diary_route_stage4_curated_mentions.csv
afg_war_diary_route_stage4_curated_summary.csv
afg_war_diary_route_stage4_new_names.csv
```

Die breite, nicht kuratierte Rohsuche wurde ebenfalls als technische Arbeitsdatei erhalten, ist aber nicht autoritativ.

## 9. Nächste Arbeit

1. pro neuem Namen die vollständigen Berichtskontexte und Koordinaten prüfen;
2. Endpunkt-, FOB-, Distrikt- und Einheitsbezüge extrahieren;
3. Namen mit wiederkehrenden geografischen Clustern priorisieren;
4. `Route Oregon`, `Route Horseshoe`, `Honda`, `Volkswagen`, `Fosters`, `Cowboys`, `Violet`, `Torch` und `Lithium` gegen Karten und weitere Primärquellen prüfen;
5. nur explizit belegte MSRs in das aktuelle MSR-Register übernehmen;
6. ASR- und lokale Route-Namen in einem getrennten Routentyp-Register führen.
