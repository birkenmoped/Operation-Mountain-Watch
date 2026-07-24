# Jalalabad Phase 1 – verbindliche Architektur- und Regression-Checkliste

Status: verbindlicher Abnahmevertrag  
Bezug: `docs/27-jalalabad-air-operations-phase1-postmortem-and-guardrails.md`

Diese Checkliste ist vor jedem DCS-Test, vor jeder dynamischen Spieleranforderung und vor der Übertragung des Air-Operations-Modells auf einen weiteren Flugplatz anzuwenden.

## A. Missionsdatei und Arbeitsgrenze

- [ ] Der Assistent hat keine `.miz` erstellt oder verändert, sofern dies nicht ausdrücklich beauftragt wurde.
- [ ] Vor Missionseditor-Arbeiten wurde eindeutig festgelegt: unverändert weiterverwenden, neu speichern oder noch nicht bearbeiten.
- [ ] Der Projektinhaber hat das lokal gebaute Bundle in der vorhandenen `DO SCRIPT FILE`-Aktion erneut ausgewählt und die Mission gespeichert.
- [ ] Der lokale Commit im Bundle-Kopf entspricht dem erwarteten GitHub-Commit.
- [ ] Builder-SHA-256 und unabhängiger `Get-FileHash` stimmen überein.

## B. Ebenentrennung

Für jeden Luftfahrzeugtyp sind getrennt dokumentiert:

- [ ] logischer Flugzeugbestand;
- [ ] Zahl der technischen ME-Templates;
- [ ] Einheitenzahl je Template;
- [ ] MOOSE-Grouping;
- [ ] Zahl physischer DCS-Gruppen je Auftrag;
- [ ] Zahl Luftfahrzeuge je Auftrag;
- [ ] Zahl verfügbarer MOOSE-Asset-Gruppen;
- [ ] sichtbare Statics;
- [ ] Client-Gruppen;
- [ ] taktisches Paketmodell.

Keine dieser Zahlen darf ohne Bezeichnung als „Bestand“, „Gruppe“ oder „Asset“ ausgegeben werden.

## C. Zentraler Paketvertrag

Erwarteter Vertrag:

```text
OH58D_RECON = PHYSICAL_TWO_SHIP
  TemplateUnits=2
  Grouping=2
  RequiredGroups=1
  RequiredAircraft=2
  AssetGroups=12
  InventoryAircraft=24
  RuntimeUnitSuffixes=-01,-02

AH64D_CAS = PHYSICAL_TWO_SHIP
  TemplateUnits=2
  Grouping=2
  RequiredGroups=1
  RequiredAircraft=2
  AssetGroups=4
  InventoryAircraft=8
  RuntimeUnitSuffixes=-01,-02

UH60 = INDEPENDENT_SINGLE_SHIP_ASSETS
  TemplateUnits=1
  Grouping=1
  AssetGroups=8
  InventoryAircraft=8
  RuntimeUnitSuffixes=-01
  MEDEVAC package later requires coordinated Lead+Guard

CH47_CARGO = SINGLE_SHIP
  TemplateUnits=1
  Grouping=1
  RequiredGroups=1
  RequiredAircraft=1
  AssetGroups=8
  InventoryAircraft=8
  RuntimeUnitSuffixes=-01
```

Pflichtbedingungen:

- [ ] `AssetGroups * Grouping == InventoryAircraft` für jeden SQUADRON.
- [ ] `RequiredGroups * Grouping == RequiredAircraft` für jeden Ein-Gruppen-Auftrag.
- [ ] `SetGrouping(...)` wird ausschließlich aus dem zentralen Vertrag gesetzt.
- [ ] Manifest, Observer, Factory und Controller lesen dieselbe Paketdefinition.
- [ ] Keine spätere Lua-Datei überschreibt `Grouping`, `ExpectedGroups`, `ExpectedAircraft`, Suffixe oder Asset-Bestand.
- [ ] Ein Two-Ship-Template mit `SetGrouping(1)` ist ein harter Startfehler.
- [ ] Ein `PHYSICAL_TWO_SHIP` mit `RequiredGroups=2` ist ein harter Startfehler.

## D. Exakte Runtime-Identität

- [ ] Kein type-only oder type-first Fallback.
- [ ] Runtime-Gruppe entspricht dem exakten SQUADRON-/AID-Präfix.
- [ ] Single-Ship-Einheit heißt exakt `<group>-01`.
- [ ] Physical-Two-Ship-Einheiten heißen exakt `<group>-01` und `<group>-02`.
- [ ] Beide Two-Ship-Einheiten gehören zum selben Gruppennamen.
- [ ] Authoring-Templates und Client-Gruppen sind ausdrücklich ausgeschlossen.
- [ ] Birth, Engine Start, Takeoff, Land, Shutdown, Crash und Dead verwenden dieselbe Identitätsregel.

## E. Parking und Ramp-Darstellung

- [ ] ME-Templates sind Authoring-Seeds und stehen außerhalb operativer Parkpositionen.
- [ ] Statics werden nicht als AIRWING-Assets gezählt.
- [ ] Client-TerminalIDs sind gegen dynamische Spawns geschützt.
- [ ] Static-TerminalIDs sind dokumentiert und blacklisted, sofern sie echte DCS-Parkknoten belegen.
- [ ] Dynamische Pools überschneiden sich weder untereinander noch mit Client-/Static-Positionen.
- [ ] Ein Two-Ship-Pool kann mindestens zwei geeignete Positionen für eine physische Gruppe bereitstellen.

## F. Readiness-Gates

Global blockierend sind nur gemeinsame Basisfehler:

- [ ] AIRWING/SQUADRON nicht aufgebaut;
- [ ] Paketvertrag ungültig;
- [ ] Parking-Pools ungültig;
- [ ] exakter Namensvertrag ungültig;
- [ ] gemeinsame Pflichtobjekte fehlen;
- [ ] Bestand nicht sauber oder Mission Queue nicht leer.

Auftragsspezifisch:

- [ ] OH-58D-Fehler blockiert nicht AH-64D, UH-60 oder CH-47.
- [ ] AH-64D-Fehler blockiert nicht die übrigen Aufträge.
- [ ] UH-60-Load-/Drop-Fehler blockiert nicht RECON, CAS oder Cargo.
- [ ] Der konkrete Blockgrund wird unverändert in Log und F10 weitergegeben.
- [ ] `mission-editor-objects-missing` wird nur bei tatsächlich fehlenden ME-Objekten verwendet.

## G. OH-58D RECON

Vor Start:

- [ ] drei RECON-Zonen vorhanden;
- [ ] Route und Geländeprofil protokolliert;
- [ ] Range-/Terrain-Werte sind als Telemetrie oder Warnung gekennzeichnet, sofern kein validiertes Leistungsmodell existiert;
- [ ] keine erfundene Fuel-Grenze blockiert den Test;
- [ ] Egress-/Rückkorridor ist explizit definiert.

DCS-Abnahme:

- [ ] genau eine Runtime-Gruppe;
- [ ] genau zwei Einheiten `-01` und `-02`;
- [ ] beide spawnen innerhalb des OH-58D-Pools;
- [ ] beide starten Triebwerke;
- [ ] beide heben ab;
- [ ] Formation bleibt operationell zusammen und zieht sich nicht über mehrere Meilen auseinander;
- [ ] Hinflug folgt der vorgesehenen Zonenfolge;
- [ ] Rückflug erfolgt über `RECON_03 -> RECON_02 -> RECON_01 -> Jalalabad` oder einen später ausdrücklich abgenommenen Korridor;
- [ ] kein ungeplanter direkter Konturenflug vom letzten Punkt zum Flugplatz;
- [ ] keine sinnlosen stationären Pirouetten;
- [ ] Fuel-Telemetrie ist für beide Einheiten vorhanden;
- [ ] beide landen in Jalalabad;
- [ ] `LandingCount=2`;
- [ ] Bestand wird als eine Asset-Gruppe freigegeben;
- [ ] finaler Teststatus PASS erst nach vollständigem Lifecycle und Inventarfreigabe.

## H. AH-64D CAS

- [ ] genau eine Runtime-Gruppe;
- [ ] genau zwei Einheiten `-01` und `-02`;
- [ ] kein Ersatz durch zwei unabhängige Single-Ship-Assets;
- [ ] beide fliegen als physisches Two-Ship;
- [ ] Zielerfüllung wird physisch nachgewiesen;
- [ ] beide kehren gemeinsam zurück;
- [ ] beide Landungen werden gezählt;
- [ ] ein mögliches Wingman-Landeproblem wird in Routing/Landing/Lifecycle gelöst, nicht durch Änderung auf `Grouping=1`;
- [ ] Asset-Gruppe wird vollständig freigegeben.

## I. UH-60 TROOPTRANSPORT

- [ ] Test ist ausdrücklich Single-Ship und wird nicht als vollständiges MEDEVAC bezeichnet.
- [ ] Infanterietemplate besitzt keine eigene Marschroute.
- [ ] Load- und Drop-Zone sind getrennt und überlappen nicht.
- [ ] Infanterie befindet sich bei Missionsstart in der Load-Zone und nicht in der Drop-Zone.
- [ ] Engine Start und Takeoff erfolgen vor Zielerfüllung.
- [ ] Pickup wird beobachtet.
- [ ] Dropoff wird erst nach Pickup bestätigt.
- [ ] bloße Infanteriebewegung erfüllt das Ziel nicht.
- [ ] UH-60 kehrt zurück und landet.
- [ ] Bestand wird freigegeben.

## J. UH-60 MEDEVAC-Folgemeilenstein

Vor Implementierung dynamischer MEDEVAC-Anfragen:

- [ ] Lead- und Guard-Templates bleiben Single-Ship.
- [ ] ein Paketkoordinator reserviert beide Gruppen atomar.
- [ ] gemeinsame Package-ID vorhanden.
- [ ] Lead und Guard besitzen getrennte Rollen/Payloads.
- [ ] kein unvollständiges Paket startet.
- [ ] Guard bleibt operationell beim Lead.
- [ ] RTB, Abort und Verluste werden paketweit und gruppenweise ausgewertet.
- [ ] Freigabe erfolgt erst nach Abschluss beider Gruppen.

## K. CH-47 CARGOTRANSPORT

- [ ] genau eine Runtime-Gruppe und eine Einheit;
- [ ] Cargo befindet sich anfangs in der Pickup-Zone;
- [ ] Cargo-Zustellung in der Drop-Zone wird physisch nachgewiesen;
- [ ] MOOSE-Terminalzustände werden nur bei bereits belegter physischer Zielerfüllung normalisiert;
- [ ] ohne Cargo-Zustellung bleibt `FAILED`/`CANCELLED` ein Fehler;
- [ ] CH-47 kehrt zurück und landet;
- [ ] Bestand wird freigegeben.

## L. Status- und Lifecycle-Auswertung

- [ ] Status wird pro Poll neu aus dem aktuellen Zustand berechnet.
- [ ] kein stale `landing-count-mismatch`, wenn die Landungen vollständig sind.
- [ ] nach vollständiger Landung und vor Freigabe wird `awaiting-inventory-release` oder eine gleichwertige aktuelle Ursache angezeigt.
- [ ] Gruppen- und Flugzeugzähler werden getrennt geführt.
- [ ] ein Two-Ship erzeugt `BirthCount=2`, aber `BornGroupCount=1`.
- [ ] Reservation Bounds verwenden Asset-Gruppen, nicht Luftfahrzeugzahlen.
- [ ] Verlust eines Wingman wird als Einzelverlust innerhalb einer Asset-Gruppe erfasst und nicht still als vollständige Rückgabe behandelt.

## M. Vertikalstart/-landung

- [ ] `AIRWING:SetOptionPreferVerticalLanding()` ist aktiviert, sofern in der gepinnten MOOSE-Version verfügbar.
- [ ] das Log kennzeichnet die Option als Präferenz und nicht als Garantie.
- [ ] DCS-Verhalten wird visuell geprüft.
- [ ] unnötiges Rollen zur Startbahn wird dokumentiert, falls DCS die Präferenz nicht beachtet.

## N. Dokumentation und Änderungsdisziplin

- [ ] Jede Architekturänderung aktualisiert zuerst den zentralen Vertrag.
- [ ] Jede abweichende MOOSE-Semantik wird mit Quelle oder DCS-Nachweis dokumentiert.
- [ ] Heuristische Werte sind ausdrücklich als Heuristik gekennzeichnet.
- [ ] Keine neue nachgelagerte Override-Datei ersetzt eine notwendige Konsolidierung.
- [ ] Keine DCS-PASS-Behauptung ohne vollständigen Laufzeitnachweis.
- [ ] Fehlerbefund, Ursache, Korrektur und Regressionstest werden gemeinsam dokumentiert.

## O. Freigabe für weitere Flugplätze

Die Übertragung auf Bagram, Kabul, Kandahar oder einen anderen Flugplatz ist blockiert, solange einer der folgenden Punkte offen ist:

- [ ] OH-58D-DCS-Abnahme bestanden;
- [ ] AH-64D-DCS-Abnahme bestanden;
- [ ] UH-60-TROOP-DCS-Abnahme bestanden;
- [ ] CH-47-DCS-Abnahme bestanden;
- [ ] Gesamtablauf ohne Cross-Test-Blockierung bestanden;
- [ ] Asset-Bestand nach jedem Test vollständig und korrekt wiederhergestellt;
- [ ] keine bekannte Paketmodell-, Routing-, Event- oder Statusregression offen.
