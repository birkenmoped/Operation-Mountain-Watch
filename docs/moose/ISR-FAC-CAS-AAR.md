---
document_id: OMW-MOOSE-ISR-FAC-CAS-AAR
status: PLANNED
document_class: TECHNICAL_ARCHITECTURE
owning_policy: OMW-GOV-001
authoritative_for:
  - planned MOOSE-based ISR, contact, FAC/JTAC, CAS, strike and BDA integration
  - separation of sensing, decision, tasking, designation and effects
  - CAS-to-AAR interface boundary for AAR-capable assets
not_authoritative_for:
  - active ORBAT or mission-specific ROE
  - AAR track geometry, tanker lifecycle, source-domain stock, relief or tanker acceptance
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - earlier version that treated AAR as an internal sub-architecture of ISR/FAC/CAS
superseded_by:
source_branch: main
source_commit: 36c9d71cc2f80497753b58b70d22418d354c4f71
validated_in_dcs: partial
---

# ISR-, FAC-, AFAC-, JTAC- und CAS-Architektur mit AAR-Schnittstelle

## 1. Status und Abgrenzung

Die vollständige ISR-/FAC-/CAS-Kette ist weiterhin `PLANNED`.

AAR ist dagegen ein separates, bereits implementiertes und akzeptiertes Air-Ops-Subsystem. Dieses Dokument regelt deshalb nur noch die Schnittstelle eines AAR-fähigen CAS-/Strike-Assets zur bestehenden AAR-Fähigkeit.

Verbindliche AAR-Referenzen:

- [`OMW-AAR-ISAF-ACO`](../29-isaf-2009-2013-air-to-air-refueling.md)
- [`OMW-AAR-ACCEPTANCE-7-FINALIZATION`](../89-aar-acceptance-7-finalization.md)
- [`OMW-MOOSE-AAR-LRC-TRANSIT`](AAR-LRC-TRANSIT.md)
- [`OMW-MOOSE-VERIFIED-METHODS-AAR-ACCEPTANCE-7`](VERIFIED-METHODS-AAR-ACCEPTANCE-7.md)

Für Fog of War, `INTEL`, `PLAYERRECCE`, `INTEL_DLINK` und RECON gilt zusätzlich [`OMW-MOOSE-FOG-OF-WAR-RECCE`](FOG-OF-WAR-RECCE.md).

## 2. Gesamtarchitektur

```text
Sensor / Beobachtung
-> Kontakt-/Intelligence-Modell
-> Zielentwicklung / Entscheidung
-> Spieler- oder KI-Auftrag
-> Markierung / Koordinatenübergabe
-> Wirkung
-> BDA
-> CampaignState-Folge
```

Aufklärung, Kontaktverwaltung, Zielentscheidung, Spielerauftrag, KI-Auftrag, Markierung, Wirkung und BDA bleiben getrennte Schichten. Kein einzelner FAC-, FACA-, CAS- oder AUFTRAG-Typ bildet automatisch die gesamte Kette ab.

Vorrangig zu prüfende MOOSE-Bausteine sind `INTEL`, `TARGET`, `PLAYERRECCE`, `DESIGNATE`, `PLAYERTASKCONTROLLER`, `AUFTRAG`, `COMMANDER`, `AIRWING`, `SQUADRON` und `FLIGHTGROUP`.

## 3. Setting 1 – Spieleraufklärung

### Variante 1 – Eigenbekämpfung

```text
Spieler entdeckt Ziel
-> optional Meldung an HQ / Lagebild
-> eigener Angriff
-> BDA / Zielstatus
```

### Variante 2 – Spieler als AFAC für AI-Unterstützung

```text
Spieler entdeckt und meldet Ziel
-> Identifikation / Freigabe
-> AI-Unterstützung anfordern
-> geeignetes AI-Asset auswählen
-> Spieler markiert / lasert / übergibt Koordinaten
-> Angriff
-> BDA
```

Der Spielerlaser ist nicht automatisch die technische Zielautorisierung. DCS-AI-Verhalten mit Spielerlaser, passendem Code und geeigneter Munition muss separat validiert werden.

### Variante 3 – Spieler markiert für Spieler

```text
Spieler entdeckt Ziel
-> Spielerauftrag
-> CAS-/Strike-Spieler übernimmt
-> AFAC übermittelt Zielinformation und gegebenenfalls Laser-Code
-> Markierung / Lasing
-> Angriff
-> BDA
```

`PLAYERRECCE` und Player-Task-Funktionalität sind hierfür vorrangige MOOSE-Kandidaten.

## 4. Setting 2 – UAV-Aufklärung

### Variante 1 – reine ISR-Meldung

```text
UAV erkennt Kontakt / Cluster
-> Lagebild aktualisieren
-> HQ / MissionDemand verarbeitet Information
-> Spieler- oder AI-Auftrag aus letzter bekannter Lage
```

### Variante 2 – bewaffnete UAV greift selbst an

```text
UAV erkennt Ziel
-> Identifikation / ROE / Freigabe
-> eigener Angriff bei geeigneter Bewaffnung
-> erneute Beobachtung / BDA
```

Automatische Bekämpfung jedes erkannten Kontaktes ist nicht zulässig.

### Variante 3 – UAV unterstützt Spieler-CAS

```text
UAV erkennt Ziel
-> Spielerauftrag
-> Spieler übernimmt
-> UAV hält Track
-> Markierung / Laser / Koordinaten
-> Angriff
-> BDA
```

### Variante 4 – kein Spieler übernimmt

```text
UAV erkennt Ziel
-> Spielerauftrag wird angeboten
-> kein geeigneter Spieler übernimmt rechtzeitig
-> Ziel bleibt gültig
-> MissionDemand / Commander wählt AI-Unterstützung
-> Angriff
-> BDA
```

Dringlichkeit, Freundnähe, Zielwert, Track-Alter, ROE, Waffenwirkung und Verfügbarkeit sind einzubeziehen.

## 5. Setting 3 – Bodenpatrouille mit Feindkontakt

```text
Patrouille / FOB-Kraft hat Feindkontakt
-> TIC / Support Demand
-> eigene Position + Zielinformation + Dringlichkeit
-> geeignete Assets bewerten
-> Spielerflug ODER AI-CAS ODER bewaffnete UAV ODER andere genehmigte Unterstützung
-> JTAC/FAC markiert soweit verfügbar
-> Wirkung / BDA
```

Ein Boden-JTAC kann Laser, Rauch oder andere unterstützte Markierungen bereitstellen. Sichtlinie, Reichweite, Überleben des JTAC und Zielaktualität sind zu berücksichtigen.

## 6. Asset-Auswahl

Das nächstgelegene Asset ist nicht automatisch das beste Asset. Zu bewerten sind mindestens:

```text
Missionsfähigkeit
+ ETA / Entfernung
+ geeignete A/G-Bewaffnung
+ Treibstoff / AAR-Fähigkeit
+ aktuelle Aufgabe und Priorität
+ Bedrohungsverträglichkeit
+ Markierungsfähigkeit
+ Spielerstatus
```

Der Scoring-Mechanismus ist OMW-Orchestrierung und darf MOOSE-Asset- und Missionslogik nicht unnötig ersetzen.

## 7. CAS ist Bereitschaft, nicht Einmalangriff

```text
Launch
-> CAS station / loiter
-> Target Assignment A
-> Angriff
-> zurück zur CAS-Bereitschaft
-> Target Assignment B
-> Angriff
-> zurück zur CAS-Bereitschaft
-> ...
-> RTB / Ablösung erst bei operativem Missionsende
```

Ein konkreter Zielauftrag und die Lebensdauer des CAS-Sorties sind getrennt zu behandeln.

Vor Implementierung ist gegen die gepinnte `Moose.lua` und offizielle Beispiele zu prüfen, ob `AUFTRAG:NewCAS()`, `AUFTRAG:NewCASENHANCED()` oder eine andere MOOSE-Kombination den gewünschten Lifecycle abbildet.

## 8. Missionsfähigkeits- und Winchester-Bewertung

Nicht die Gesamtzahl verbliebener Waffen ist entscheidend, sondern die Eignung für die aktuelle Zielart und ROE.

```text
Kann der Flug für die aktuelle Aufgabe noch sinnvoll wirken?
```

Beispiele: nur Luft-Luft-Waffen bedeuten keine normale CAS-Fähigkeit; nur Kanone kann für bestimmte leichte Ziele noch genügen; ungelenkte Waffen können bei enger Freundnähe ungeeignet sein.

## 9. AAR-Schnittstelle

AAR wird nicht durch die ISR-/FAC-/CAS-Komponente erzeugt, disponiert oder betrieben.

Für AAR-fähige Assets stehen die separat geregelten OMW-Tankertracks zur Verfügung. Die vier STANDARD-Tracks laufen gemäß der verbindlichen AAR-Baseline bis zu einer später genehmigten ATO-/Zeitfensterregel kontinuierlich; RESERVE-Tracks bleiben MissionDemand-gesteuert.

Daher ist Fuel Low bei einem AAR-fähigen CAS-/Strike-Asset nicht automatisch Missionsende:

```text
Asset missionsfähig?
-> Fuel ausreichend: Mission fortsetzen
-> Fuel niedrig und AAR sinnvoll/verfügbar:
   bestehende AAR-Fähigkeit nutzen
   -> kompatiblen geeigneten Tanker anfliegen
   -> refuel
   -> bisherigen Auftrag / CAS-Bereitschaft fortsetzen
-> kein sinnvoller/erreichbarer AAR-Pfad:
   Bingo / RTB / Ablösung
```

Nicht Gegenstand dieses Dokuments sind Tanker-Spawning, Track-Geometrie, Callsigns, Frequenzen, TACAN, Relief, Tanker-FuelLow, Source Domains, KC-135-Pools oder AAR-Acceptance.

## 10. BDA und ROE

Ein ausgeführter Angriff ist nicht automatisch ein zerstörtes Ziel. Vorgesehene BDA-Zustände sind beispielsweise:

```text
NOT_ASSESSED
-> PARTIAL
-> EFFECTIVE
-> DESTROYED
-> INCONCLUSIVE
-> REATTACK_REQUIRED
```

Vor einer Bekämpfung sind mindestens Identifikation, No-Strike-Regeln, Friendly-Nähe, Track-Alter, Markierungszuordnung, Waffenwirkung, Freigabestatus und Einsatzfähigkeit zu prüfen.

## 11. Noch offene OMW-Orchestrierung

Offen bleiben insbesondere:

- exakter Spieler-Meldeweg;
- `PLAYERRECCE`-Einbindung für OH-58D und weitere Module;
- Verhältnis `INTEL` / `TARGET` / Player Task;
- Designation-/Laser-Kopplung für Spieler und AI;
- Wahl und Lifecycle des MOOSE-CAS-Auftrags;
- missionsabhängige Waffenbewertung;
- Asset-Scoring und Spieler-zu-AI-Eskalation;
- BDA-Rückführung in das Lagebild.

AAR-Track-, Tanker- und Relief-Fragen sind keine offenen Entscheidungen dieses Dokuments.

## 12. Testgrenze

Die noch offene ISR-/FAC-/CAS-Kette benötigt getrennte DCS-Tests für Spieler-Recon, UAV-INTEL, Player Tasks, Spieler-/AI-Designation, Boden-JTAC, CAS-Retasking, Rückkehr zur CAS-Bereitschaft, Waffenbewertung und BDA.

Für AAR ist nur noch die **Schnittstelle** zu testen:

```text
AAR-fähiger CAS-Flug
-> Fuel Low
-> bestehende AAR-Fähigkeit nutzen
-> Refuel
-> dieselbe CAS-Mission fortsetzen
```

Dieser Test wiederholt nicht die bereits abgeschlossene AAR-Acceptance.
