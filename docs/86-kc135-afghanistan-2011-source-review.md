---
document_id: OMW-HIST-KC135-AFGHANISTAN-2011-SOURCE-REVIEW
status: BINDING
document_class: HISTORICAL_SOURCE_REVIEW
owning_policy: OMW-GOV-001
authoritative_for:
  - source-qualified review of the supplied KC-135 publications
  - KC-135R fuel capacity, tanker employment and Afghanistan operating-pattern evidence
  - 2011 Afghanistan KC-135 unit and sortie corroboration from official USAF/AFCENT sources
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes: []
superseded_by:
source_branch: docs/kc135-afghanistan-source-review
source_commit: 738142bf4d44a21f64e4ad27fe57decde5847505
validated_in_dcs: false
---

# KC-135 über Afghanistan 2010-2011 - Quellenreview

## 1. Zweck und Quellenstatus

Dieses Dokument bewertet zwei neu bereitgestellte KC-135-Publikationen und gleicht sie mit der bestehenden OMW-AAR-Baseline sowie zeitgenössischen offiziellen USAF-/AFCENT-Quellen ab. Der Schwerpunkt liegt auf dem für OMW maßgeblichen Zeitraum 01.08.2010-31.12.2011.

Neu bereitgestellt wurden:

1. Robert S. Hopkins III, *Boeing KC-135 Stratotanker: More than just a Tanker*, Aerofax/Midland Publishing, 1997, ISBN 1-85780-069-9.
2. Robert S. Hopkins III, *The Boeing KC-135 Stratotanker: More Than a Tanker*, Crécy Publishing, vollständig überarbeitete und aktualisierte Ausgabe 2017, ISBN 978-1-910809-01-3.

Eine Suche nach Titel und Autor auf `main` ergab vor dieser Aufnahme keinen vorhandenen Projekteintrag für diese Werke. Es handelt sich aber **nicht um zwei unabhängige historische Quellen**: Die 2017er Crécy-Ausgabe ist ausdrücklich die vollständig überarbeitete und aktualisierte Fassung des erstmals 1997 erschienenen Werks. Für Afghanistan 2001-2014 ist daher die 2017er Ausgabe die relevante Fassung; die 1997er Ausgabe kann Afghanistan naturgemäß nicht behandeln.

Die neue Sekundärquelle ersetzt keine direkte OMW-Evidenz. Für exakte 2011er Einheiten und Einsatzdaten werden deshalb zusätzlich zeitgenössische offizielle USAF-/AFCENT-Veröffentlichungen herangezogen.

## 2. Einordnung der beiden Hopkins-Ausgaben

| Quelle | Evidenzklasse | Nutzen für OMW | Grenze |
|---|---|---|---|
| Hopkins 1997 | `BACKGROUND_ONLY` / `TYPE_REFERENCE` | KC-135R-Entwicklung, Systeme, Fuel-System und Leistungsrelationen | vor OEF und vor OMW-Zeitraum; keine Afghanistan-Evidenz |
| Hopkins 2017 | `POST_PERIOD_SYNTHESIS` mit `IN_PERIOD_CONTENT` | Afghanistan-Einsatzmuster, Manas/al-Udeid, SOAR/ARR, OEF-Statistiken, aktualisierte Fuel-Systemdaten | Sekundärwerk; aggregierte OEF-Werte sind nicht automatisch 2011-spezifisch |
| USAF/AFCENT 2011 | `DIRECT_OFFICIAL_IN_PERIOD` | konkrete Staffeln, Basierung, Einsatztag, Receiver, Sorties/Offload im Jahr 2011 | einzelne Meldungen/Snapshots, kein vollständiges Jahres-ORBAT |

## 3. KC-135R Fuel-System und Kapazität

Hopkins 2017 beschreibt für den KC-135R bei installiertem Upper-Deck-Tank:

```text
total usable fuel: 31,275 US gal
mass equivalent:   203,288 lb / 92,211 kg
primary fuel:       JP-8
```

Zusätzlich bleiben in jedem Hauptflügeltank ungefähr **300 US gal Standpipe Fuel** für den Tanker selbst reserviert; dieser Anteil kann nicht an Receiver abgegeben werden. Grundsätzlich kann der übrige Kraftstoff sowohl von den eigenen Triebwerken verbraucht als auch über den Refueling-Boom abgegeben werden.

Quelle: Hopkins 2017, Kapitel 4, Abschnitt `Fuel`.

Für die OMW-Planung ist diese Systemlogik wesentlich: **Tanker-Eigenverbrauch und Receiver-Offload greifen auf denselben Kraftstoffvorrat zu.** Ein längerer Transit reduziert deshalb direkt die später verfügbare Offload-/On-station-Reserve.

## 4. Reichweite, Offload und Verbrauch - was die Quelle tatsächlich belegt

### 4.1 Vergleichsprofil KC-135R

Hopkins dokumentiert ein Test-/Vergleichsprofil mit:

```text
2,000 NM outbound
+ refueling point
+ 2,000 NM return
```

Unter diesen Bedingungen konnte ein KC-135A ungefähr **40,000 lb** abgeben, ein KC-135R ungefähr **70,000 lb**. Der Text führt die höhere verbleibende Offload-Fähigkeit des R-Modells auf den geringeren Eigenverbrauch mit den F108/CFM56-Triebwerken zurück.

Quelle: Hopkins 1997/2017, KC-135R-Abschnitt zur Re-Engining-Performance.

Diese Angabe ist eine **missionsprofilabhängige Offload-Leistungsreferenz**, kein Fuel-Flow-Wert.

### 4.2 Kein belastbarer lb/h- oder gal/h-Wert

Weder die 1997er noch die 2017er Hopkins-Ausgabe liefert für einen Afghanistan-typischen KC-135R-Einsatz einen belastbaren konstanten Verbrauch in `lb/h`, `kg/h` oder `US gal/h`.

Daher gilt:

- aus `203,288 lb` Tankkapazität darf kein konstanter Stundenverbrauch abgeleitet werden;
- aus dem 4,000-NM-/70,000-lb-Offload-Profil darf kein einfacher Fuel-Flow rekonstruiert werden, weil Startgewicht, Reserve, Höhenprofil, Offloadzeit, Wetter und Receiver-Verhalten fehlen;
- die bereits in OMW verwendete ungefähr **20 lb/NM** große AAR-Transit-Planungsgröße bleibt `RECONSTRUCTED_PLANNING_ESTIMATE` und wird durch Hopkins **nicht** zu einem historischen Messwert aufgewertet.

## 5. Afghanistan-Betriebsmuster

Hopkins 2017 beschreibt Afghanistan ausdrücklich als Theater mit weitgehender alliierter Luftüberlegenheit und geringer Bedrohung für Tanker. Dort konnten KC-135 näher an den Kampfbereich und teilweise deutlich niedriger als bei klassischen rückwärtigen Tanker-Orbits betrieben werden, um Receiver-Zeit außerhalb des Einsatzraums zu minimieren.

Quelle: Hopkins 2017, Kapitel 5, `Operations and Relief`.

Das bestätigt für OMW grundsätzlich:

- Tanker müssen historisch nicht ausschließlich weit rückwärtig in großen Höhen gedacht werden;
- A-10-/SOF-Unterstützung konnte eine wesentlich nähere und niedrigere Tankerposition rechtfertigen;
- die produktive OMW-AAR-Geometrie bleibt dennoch eine eigene 2011-AIP-kompatible Designentscheidung und wird nicht direkt aus dieser Beschreibung abgeleitet.

## 6. Manas als Afghanistan-Tankerbasis

Hopkins 2017 nennt **Manas International Airport/Bishkek, Kyrgyzstan** ausdrücklich als KC-135-Deployment-Standort für die Afghanistan-Kriege.

Die offizielle USAF-Evidenz ist für 2011 noch präziser:

### 6.1 22nd Expeditionary Air Refueling Squadron

Am **18. November 2011** flog ein KC-135R der **22nd Expeditionary Air Refueling Squadron (22nd EARS)** vom Transit Center at Manas eine OEF-Tankermission über Afghanistan. Die 22nd EARS gehörte zur **376th Air Expeditionary Wing (376th AEW)**. Auf derselben Mission wurden unter anderem F-15E und F-16 über Afghanistan betankt. Das eingesetzte KC-135-Personal/Flugzeug wird in der Bilddokumentation mit der **117th Air Refueling Wing, Alabama Air National Guard** als Heimatverband verknüpft.

Quelle: U.S. Air Mobility Command, `Photo essay: Air refueling over Afghanistan`, 21 Nov 2011.

### 6.2 Manas Operationsstand Juni 2011

Eine offizielle AMC-Meldung vom **22. Juni 2011** bestätigt:

- KC-135 und Aircrews am Transit Center at Manas gehörten zur **22nd EARS**;
- die Wartung erfolgte durch die **376th Expeditionary Aircraft Maintenance Squadron**;
- beide Verbände gehörten zur **376th AEW**;
- Auftrag war AAR-Unterstützung für **Operation Enduring Freedom**.

Bis **31. Mai 2011** hatten AAR-Flugzeuge im gesamten USCENTCOM-AOR mehr als **466 million lb** Kraftstoff an mehr als **35,000 Receiver** abgegeben und mehr als **7,100 Sorties** geflogen. Diese Zahlen umfassen den gesamten CENTCOM-AOR und dürfen deshalb nicht als reine Afghanistan- oder 22nd-EARS-Zahlen gelesen werden.

Quelle: U.S. Air Mobility Command, `KC-135s keep Operation Enduring Freedom mission moving from Kyrgyzstan`, 22 Jun 2011.

### 6.3 Anteil an Afghanistan-AAR

Eine offizielle Air-Force-Meldung zum 25,000.-Mission-Meilenstein der 22nd EARS vom Mai 2012 sagt, dass die Staffel **ein Drittel der Luftbetankung für Koalitionsflugzeuge zur Unterstützung der internationalen Afghanistan-Einsätze** bereitstellte. Im vorangegangenen Jahr war die Sortie-Unterstützung der Staffel um **23 %** gestiegen.

Quelle: U.S. Air Force, `First refueling unit to reach 25,000 missions in single AOR`, 7 May 2012.

Das ist eine starke Nachperioden-Bestätigung für die hohe operative Bedeutung von Manas während 2011, aber keine exakte 2011er Jahresinventarliste.

## 7. Südliche Source Domain / 340th EARS

### 7.1 Direkter 2011er Afghanistan-Nachweis

Die **340th Expeditionary Air Refueling Squadron (340th EARS)** ist für Afghanistan 2011 direkt belegt. Am **8. Mai 2011** flog die Staffel mehrere KC-135-Tankermissionen über Afghanistan im Rahmen von OEF. Eine offizielle USAF-Bilddokumentation nennt unter anderem einen Boom Operator, der von der **349th Air Refueling Squadron, McConnell AFB** zur 340th EARS deployed war.

Quelle: U.S. Air Force, `Photo essay: Refueling the fight`, 24 May 2011; U.S. Air Force, `Deployed air refuelers surpass 350 million pounds of fuel delivered in 2011`, 18 May 2011.

### 7.2 Organisationszuordnung

Eine offizielle Meldung vom **26. April 2011** ordnet die 340th EARS der **379th Air Expeditionary Wing** an einer damals nicht öffentlich benannten Basis in Southwest Asia zu. Der Artikel zeigt/benennt KC-135 der 340th EARS bei Afghanistan-Unterstützung.

Quelle: U.S. Air Mobility Command / 379th AEW, `Expeditionary air refueling unit 'fuels the fight'`, 26 Apr 2011.

Die zeitgenössische Quelle nennt die Basis absichtlich nicht. OMW darf deshalb **nicht allein aus diesem Artikel** behaupten, dass jede 340th-EARS-Afghanistan-Sortie 2011 von Al Udeid startete.

Hopkins 2017 beschreibt jedoch für die Afghanistan-Unterstützung **al-Udeid AB, Qatar** als südlichen Heimat-/Deployment-Standort und nennt für eine spezielle KC-135R(ARR)-Mission eine Entfernung von rund **1,074 NM / 1,989 km** zwischen Afghanistan und al-Udeid. Diese Sekundärquelle stützt damit die OMW-Source-Domain `AL_UDEID`, ohne eine exakte 2011er Staffelstärke zu beweisen.

## 8. KC-135R(ARR), SOAR und A-10-Unterstützung

Hopkins 2017 listet **22 KC-135** als für `Special Operations Aerial Refueling (SOAR)` konfigurierte Flugzeuge. Die refuelable Variante wird im Buch als **KC-135R (ARR)** bezeichnet.

Für Afghanistan beschreibt Hopkins ein besonders OMW-relevantes Einsatzmuster:

1. A-10 im CAS-Einsatz konnten bei niedrigem Kraftstoffstand normalerweise den Einsatzraum verlassen, auf ungefähr **FL240-FL260** steigen, zum Tanker fliegen, refuelen und zurückkehren.
2. KC-135R(ARR) konnten näher am A-10-Einsatzgebiet und wesentlich niedriger operieren, im Beispiel ungefähr **8,000 ft AGL**.
3. Dadurch konnte jeweils ein A-10 mit kurzer Wegstrecke und geringer Steigzeit zum Tanker wechseln.
4. Der Navigator der Spezialmissions-KC-135 unterstützte präzise Routenplanung im afghanischen Hochgebirge und die Crew-Situational-Awareness.
5. Nach Verbrauch eines großen Teils des eigenen Kraftstoffs musste die KC-135R(ARR) nicht zwingend die rund **1,074 NM** nach al-Udeid zurückfliegen: Sie konnte selbst von einem Airborne-Standby-Tanker betankt werden und anschließend wieder zum niedrigeren/vorgeschobenen Support zurückkehren.

Quelle: Hopkins 2017, Kapitel 5, Abschnitt zu `Special Operations Aircraft (SOAR)` / KC-135R(ARR).

### OMW-Bedeutung

Diese Quelle liefert starke historische Plausibilität für:

- `SLOW`-AAR zur A-10-Unterstützung;
- näher am Kampfgebiet gelegene AAR-Positionen;
- deutlich niedrigere Spezialmissions-Tankerprofile als klassische Fast-Jet-Tankerprofile;
- Tanker-to-tanker refueling als reales Mittel zur Verlängerung einer Tankermission;
- al-Udeid als plausible südliche Source Domain.

Sie **genehmigt jedoch nicht automatisch** eine KC-135R(ARR)-Spezialvariante für die OMW-Produktion. Die aktuelle DCS-/MOOSE-Tankerbaseline und Mod-Grenzen aus Dokument 29 bleiben maßgeblich.

## 9. MPRS und Probe-and-Drogue über Afghanistan 2011

AFCENT dokumentierte am **8. Mai 2011** einen KC-135 der **340th EARS**, der über Afghanistan eine US-Navy **EA-6B Prowler** mittels **Multi-Point Refueling System (MPRS)** betankte. Der zugehörige Artikel beschreibt mehrere gleichzeitig über Afghanistan und Irak arbeitende Tankerlinien.

Quelle: U.S. Air Forces Central, `Multi-point refueling extends tanker capabilities`, 2011.

Der Artikel nennt für den damaligen Jahresstand außerdem mehr als **154 million lb JP-8**, die über **21,000 Flugstunden** in der Luft abgegeben worden seien. Dieser Wert ist eine theaterweite/AOR-Angabe und kein einzelner KC-135-Verbrauchswert.

Für OMW ist dies historischer Nachweis, dass MPRS im Afghanistan-Kontext 2011 real eingesetzt wurde. Die produktive OMW-MPRS-/Drogue-Freigabe bleibt trotzdem an DCS-/Mod-/MOOSE-Eignung und die bestehende AAR-Governance gebunden.

## 10. OEF-Gesamtbelastung der KC-135-Flotte

Hopkins 2017 liefert folgende OEF-Aggregate:

- OEF begann am 7. Oktober 2001 und endete am 28. Dezember 2014;
- in der Spitzenphase Oktober 2001 bis Februar 2002 flogen Tanker mehr als **5,000 Sorties**;
- 2006: **42,083 Receiver**, **871 million lb** abgegebener Kraftstoff;
- 2008: **86,288 Receiver** und **1.1 billion lb** abgegebener Kraftstoff;
- in den letzten sechs Jahren von OEF: **441,070 Receiver** und **5.9 billion lb / 2.68 billion kg** Kraftstoff.

Quelle: Hopkins 2017, Kapitel 5, `Operations and Relief`.

Diese Werte belegen die enorme Dauerbelastung des Tankersystems, dürfen aber nicht als 2011-spezifische Zahlen ausgegeben werden.

## 11. Flugzeit und Crew-Belastung

Hopkins beschreibt für die post-Cold-War-Einsatzrealität KC-135-Crews mit ungefähr zweimonatigen Theater-Rotationen bis zur jeweiligen Flugstundenbegrenzung, durchschnittlich **180-200 TDY-Tagen pro Jahr** und in intensiven Einsatzjahren **600-1,000 Flugstunden pro Jahr** für einzelne Flieger. Diese Werte sind **generische moderne KC-135-Operationswerte**, nicht Afghanistan-2011-spezifische Staffelstatistik.

Quelle: Hopkins 2017, Kapitel 5, `Operations and Relief`.

Als konkreter Afghanistan-Vergleich dokumentiert die USAF für den letzten Manas-KC-135-Einsatz im Februar 2014 eine etwa **sechsstündige** Mission mit A-10- und F-16-Refueling über Afghanistan. Das liegt außerhalb des OMW-Zeitraums und ist nur `POST_PERIOD_CONFIRMATION`, nicht die 2011er Standard-Sortiedauer.

Quelle: U.S. Air Force, `Manas KC-135s complete final mission, leave Kyrgyzstan`, 26/27 Feb 2014.

## 12. 2011er Einheiten - belastbar bestätigter Mindeststand

| Einheit | Übergeordnete Organisation / Source Domain | 2011er Afghanistan-Nachweis | Anmerkung |
|---|---|---|---|
| `22nd Expeditionary Air Refueling Squadron` | `376th Air Expeditionary Wing`, Transit Center at Manas, Kyrgyzstan | **direkt** | KC-135R über Afghanistan 18 Nov 2011; OEF-Auftrag auch Jun 2011 offiziell bestätigt |
| `376th Expeditionary Aircraft Maintenance Squadron` | `376th AEW`, Manas | **direkt** | Wartungsverband für die Manas-KC-135 im Jun 2011 |
| `117th Air Refueling Wing`, Alabama ANG | Rotation/Heimatverband zur 22nd EARS | **direkt für Nov 2011** | KC-135 der 18-Nov-2011-Mission wurde diesem Heimatverband zugeordnet |
| `340th Expeditionary Air Refueling Squadron` | `379th Air Expeditionary Wing`, Southwest Asia | **direkt** | mehrere AAR-Missionen über Afghanistan am 8 May 2011 |
| `349th Air Refueling Squadron`, McConnell AFB | Heimatverband einzelner 340th-EARS-Airmen | **direkt für May 2011** | offizieller Bildtext nennt Deployment eines Boom Operators |

Die Tabelle ist **kein vollständiges 2011er KC-135-ORBAT**. Expeditionary Squadrons wurden durch rotierende Active-/ANG-/AFRC-Crews und Flugzeuge gespeist. Eine einzelne Heimatverbandsnennung darf nicht in einen ganzjährigen exklusiven Bestand umgedeutet werden.

## 13. OMW-Folgerungen

Die neuen Quellen bestätigen mehrere bereits getroffene AAR-Grundentscheidungen:

1. **MANAS ist historisch stark belegt** als nördliche Afghanistan-KC-135-Source-Domain; 22nd EARS/376th AEW ist für 2011 direkt belegt.
2. **Südwestasiatische KC-135-Unterstützung ist 2011 direkt belegt** durch 340th EARS/379th AEW; Hopkins stützt zusätzlich al-Udeid als Afghanistan-Tankerstandort.
3. **SLOW/A-10-Support** hat ein reales historisches Analogon bis hin zu niedriger, näher am Kampfgebiet operierender KC-135R(ARR)-Unterstützung.
4. **MPRS über Afghanistan 2011** ist direkt offiziell belegt.
5. **Transitdistanz kostet direkt Offload und On-station-Endurance**, weil Receiver-Offload und Eigenverbrauch aus demselben Tankvorrat stammen.
6. Die Quelle liefert **keinen belastbaren konstanten Fuel-Burn-Wert**. Bestehende OMW-Verbrauchs-/Transitwerte bleiben Planungswerte mit ihrer bisherigen Evidenzklasse.
7. Die Quelle beweist **keine exakte 2011er Airframe-Stärke** für Manas oder al-Udeid und ändert daher nicht automatisch die OMW-Off-map-Pools.
8. Die aktuelle operative AAR-Governance in [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md) bleibt maßgeblich.

## 14. Nicht aus den Quellen abzuleiten

Aus diesem Review dürfen ohne zusätzliche Evidenz **nicht** abgeleitet werden:

- eine exakte 2011er KC-135-Gesamtzahl in Afghanistan oder an Manas/al-Udeid;
- eine konstante KC-135R-Verbrauchsrate in lb/h oder gal/h;
- dass alle 340th-EARS-Afghanistan-Sorties 2011 von al-Udeid starteten;
- dass jede Afghanistan-KC-135 niedrig flog;
- dass jede A-10-AAR-Mission KC-135R(ARR) verwendete;
- dass MPRS in OMW ohne DCS-/MOOSE-/Mod-Nachweis produktiv verfügbar ist;
- dass die OMW-Pools `OFFMAP_MANAS` oder `OFFMAP_AL_UDEID` aus den Hopkins-Zahlen historisch exakt abgeleitet wären.

## 15. Quellen

### 15.1 Bereitgestellte Publikationen

- Hopkins, Robert S. III. *Boeing KC-135 Stratotanker: More than just a Tanker*. Aerofax / Midland Publishing, 1997. ISBN 1-85780-069-9.
- Hopkins, Robert S. III. *The Boeing KC-135 Stratotanker: More Than a Tanker*. Crécy Publishing, 2017. ISBN 978-1-910809-01-3. Vollständig überarbeitete und aktualisierte Ausgabe des 1997er Werks.

### 15.2 Offizielle zeitgenössische / ergänzende Quellen

- U.S. Air Mobility Command, `KC-135s keep Operation Enduring Freedom mission moving from Kyrgyzstan`, 22 Jun 2011: https://www.amc.af.mil/News/Article-Display/Article/145616/kc-135s-keep-operation-enduring-freedom-mission-moving-from-kyrgyzstan/
- U.S. Air Mobility Command, `Photo essay: Air refueling over Afghanistan`, 21 Nov 2011: https://www.amc.af.mil/News/Article-Display/Article/145252/photo-essay-air-refueling-over-afghanistan/
- U.S. Air Force, `Deployed air refuelers surpass 350 million pounds of fuel delivered in 2011`, 18 May 2011: https://www.af.mil/News/Article-Display/Article/113304/deployed-air-refuelers-surpass-350-million-pounds-of-fuel-delivered-in-2011/
- U.S. Air Mobility Command / 379th AEW, `Expeditionary air refueling unit 'fuels the fight'`, 26 Apr 2011: https://www.amc.af.mil/News/Article-Display/Article/145743/expeditionary-air-refueling-unit-fuels-the-fight/
- U.S. Air Force, `Photo essay: Refueling the fight`, 24 May 2011: https://www.af.mil/News/Article-Display/Article/113246/photo-essay-refueling-the-fight/
- U.S. Air Forces Central, `Multi-point refueling extends tanker capabilities`, 2011: https://www.afcent.af.mil/News/Features/Display/Article/223584/multi-point-refueling-extends-tanker-capabilities/
- U.S. Air Force, `First refueling unit to reach 25,000 missions in single AOR`, 7 May 2012: https://www.af.mil/News/Article-Display/Article/111221/first-refueling-unit-to-reach-25000-missions-in-single-aor/
- U.S. Air Force, `Manas KC-135s complete final mission, leave Kyrgyzstan`, 26 Feb 2014: https://www.af.mil/News/Article-Display/Article/473433/manas-kc-135s-complete-final-mission-leave-kyrgyzstan/

## 16. Projektverweise

- [`OMW-AAR-ISAF-ACO`](29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-AIR-TASKING-AIRSPACE-CAS-REQUESTS`](54-air-tasking-airspace-control-cas-requests-and-mission-data.md)
- [`OMW-HIST-AFGHANISTAN-ORBAT-2011-07`](64-afghanistan-order-of-battle-july-2011.md)
- [`OMW-AIR-AFGHANISTAN-AIP-2008`](72-afghanistan-aip-2008-airspace-aerodromes-and-flight-procedures.md)
