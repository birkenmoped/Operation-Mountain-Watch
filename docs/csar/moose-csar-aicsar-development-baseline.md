---
document_id: OMW-CSAR-MOOSE-AICSAR-DEVELOPMENT-BASELINE
status: PLANNED
document_class: ARCHITECTURE_AND_TEST_PLAN
owning_policy: OMW-CSAR-INDEX
authoritative_for:
  - current CSAR and AICSAR design baseline
  - reality versus playability decisions
  - MOOSE-first implementation scope
  - slot-lock candidate evaluation
  - planned CSAR and AICSAR test program
not_authoritative_for:
  - accepted DCS runtime behavior
  - final CampaignState schema
  - final multiplayer slot-lock implementation
scenario_period: 2010-08-01/2011-12-31
project_phase: COMPLETE_FOUNDATION_BUILD_PHASE
supersedes:
  - informal CSAR and AICSAR design discussion without consolidated baseline
superseded_by:
source_branch: main
source_commit:
validated_in_dcs: false
moose_branch: develop
moose_commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
moose_lua_sha256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
---

# MOOSE CSAR/AICSAR – Entwicklungsbaseline, Realismus, Spielbarkeit und Prüfplan

## 1. Zweck und Status

Dieses Dokument konsolidiert den aktuellen Diskussions-, Entscheidungs- und Prüfstand für die spätere Umsetzung von Personnel Recovery, Spieler-CSAR und AICSAR in **Operation Mountain Watch**.

Es dokumentiert ausdrücklich:

- fachliche Fakten und Begriffsabgrenzungen;
- verbindliche beziehungsweise aktuell festgelegte Gameplay-Entscheidungen;
- verworfene oder korrigierte Annahmen;
- MOOSE-Funktionen und bekannte Grenzen;
- bewusst zurückgestellte optionale Erweiterungen;
- offene technische Fragen;
- den geplanten Entwicklungs- und DCS-Testablauf.

Der Stand ist `PLANNED`. Es existiert noch keine technische Acceptance für das kombinierte CSAR-/AICSAR-/Slot-Lock-System.

## 2. Verbindliche Projektgrundsätze

### 2.1 MOOSE-First

Vor eigener Lua-Logik sind die vorhandenen MOOSE-Klassen, der Quellcode des tatsächlich eingebundenen MOOSE-Commits, die passende Develop-Dokumentation und offizielle Demo-Missionen zu prüfen.

Eigener Code ist nur zulässig, wenn:

1. MOOSE die Anforderung nicht oder nicht ausreichend abbildet;
2. die Lücke gegen den gepinnten MOOSE-Stand nachgewiesen wurde;
3. ein reproduzierbarer DCS-Test vorliegt;
4. die projektspezifische Ergänzung ausdrücklich freigegeben wird.

### 2.2 Eingefrorene MOOSE-Baseline

Operation Mountain Watch verwendet derzeit:

```text
MOOSE NG develop
Commit: 73d3ed119cd9e7e3f2cfcabbaa34513d30529b54
Moose.lua SHA-256: e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915
Projektseitig verändert: nein
```

Diese Baseline bleibt eingefroren. Neuere Develop-Commits und Changelogs werden nur von Zeit zu Zeit auf relevante Änderungen geprüft. Ein automatisches oder kurzfristiges Upgrade ist nicht vorgesehen.

## 3. Fachliche Einordnung: Personnel Recovery statt pauschaler Verwundung

### 3.1 Ausschuss bedeutet nicht automatisch schwere Verwundung

Ein ausgeschleuster Pilot ist zunächst **isoliertes Personal**. Ein Ausschuss oder Absturz bedeutet nicht automatisch:

- schwere Verwundung;
- unmittelbar bevorstehenden Tod;
- zwingende chirurgische Behandlung;
- laufende Golden Hour.

Ein unverletzter oder nur leicht verletzter Pilot kann durch SERE-Ausbildung, Überlebensausrüstung, Notration und Funkmittel grundsätzlich längere Zeit überleben und sich verborgen halten.

### 3.2 Keine Golden Hour für normalen Pilot-CSAR

Für reguläre Ejection-/Pilot-CSAR-Fälle wird nicht vorgesehen:

- kein medizinischer 60-Minuten-Countdown;
- kein automatischer Tod nach Zeitablauf;
- keine zufällige Verletzungsschwere;
- keine errechnete Überlebenswahrscheinlichkeit;
- kein pauschaler Role-2-/Role-3-Zwang.

Die Golden Hour ist fachlich für echte Traumaverwundungen relevant, beispielsweise nach IED, Explosion, Schussverletzung oder schwerem Bodenkampf. Sie ist nicht der geeignete Standardmechanismus für jeden ausgeschleusten Piloten.

### 3.3 Operativer Zeitdruck durch gegnerische Kräfte

Der für Pilot-CSAR vorgesehene realistische Zeitdruck entsteht perspektivisch durch:

```text
Abschuss / Ausschuss
→ RED erhält möglicherweise Kenntnis vom Vorfall
→ RED entsendet Such- oder Sicherungskräfte
→ BLUE und RED konkurrieren um den Piloten
→ Rettung, Gefangennahme oder Verlust
```

Die gegnerische Seite darf dabei nicht automatisch allwissend sein. Eine realistische RED-Erkenntnis-, Such- und Capture-Logik ist jedoch nicht Bestandteil der ersten Baseline.

## 4. Zielbild des Grundablaufs

```text
Spieler stürzt ab oder steigt aus
→ MOOSE erzeugt genau einen Downed Pilot
→ der konkrete Ursprungsslot wird dem Vorfall zugeordnet
→ der Ursprungsslot wird gesperrt
→ Spieler-CSAR oder AICSAR führt die Rettung durch
→ Pilot wird zu einer gültigen Recovery-Stelle zurückgebracht
→ der Ursprungsslot wird wieder freigegeben
```

Ein Vorfall darf niemals gleichzeitig unabhängig durch Spieler-CSAR und AICSAR doppelt verwaltet oder doppelt abgeschlossen werden.

## 5. Realität versus Spielbarkeit

### 5.1 Slot-Sperre als Gameplay-Konsequenz

Der konkrete abgestürzte Client-Slot soll gesperrt bleiben, bis der dazugehörige Pilot erfolgreich zurückgeführt wurde oder eine separat definierte Ersatzpersonalregel greift.

Beispiel:

```text
PLR_US_F16_BAGRAM_01
```

Gesperrt wird der konkrete Ursprungsslot, nicht pauschal:

- der Spieler;
- dessen UCID;
- die gesamte Gruppe;
- alle Flugzeugslots desselben Typs.

### 5.2 Selbstrettung durch denselben Spieler ist zulässig

Der abgestürzte Spieler darf:

- auf Spectator wechseln;
- einen zugelassenen Spieler-CSAR-Slot besetzen;
- seinen eigenen virtuellen Piloten abholen;
- den vollständigen Rettungsflug durchführen;
- dadurch den Ursprungsslot wieder freischalten.

Das ist personell nicht realistisch, aber für einen öffentlichen oder halböffentlichen Multiplayer-Server spielerisch sinnvoll. Es gibt keine kostenlose Freischaltung allein durch Slotwechsel oder Reconnect.

### 5.3 Identität und Zuordnung

Für Incident, Logging und Reconnect werden mindestens gespeichert:

```lua
incident = {
  originGroupName = "...",
  originUnitName = "...",
  originSlotId = "...",
  aircraftType = "...",
  homeBase = "...",
  playerUCID = "...",
  playerNameAtIncident = "...",
  state = "ISOLATED",
  slotLocked = true,
}
```

Die Slot-Sperre bezieht sich auf den Ursprungsslot. Die UCID dient der Wiedererkennung, Benachrichtigung und Revision, nicht als Sperrgegenstand.

## 6. Zugelassene und ausgeschlossene Rettungsluftfahrzeuge

### 6.1 Zugelassene Spieler-CSAR-Luftfahrzeuge

Aktuell vorgesehen:

- **UH-1H** als regulärer Spieler-CSAR-Hubschrauber;
- **UH-60 / Blackhawk-Mod** nur in Missionsvarianten, in denen der Mod ausdrücklich zugelassen und verfügbar ist.

### 6.2 AICSAR-Luftfahrzeug

Für AICSAR ist vorgesehen:

- **UH-60** als AI-Rettungshubschrauber.

### 6.3 Ausdrücklich nicht zugelassen

Die folgenden Typen werden nicht als CSAR-/MEDEVAC-Luftfahrzeuge zugelassen:

- **Mi-8**;
- **CH-47**.

Sie erhalten keine Berechtigung zur Aufnahme oder Rückführung von Downed Pilots.

### 6.4 Technische Zulassung

Die Berechtigung soll möglichst über eindeutige Gruppenpräfixe oder eine explizite Whitelist begrenzt werden, beispielsweise:

```text
PLR_US_CSAR_
PLR_US_MEDEVAC_
```

Nicht jeder Transporthubschrauber erhält automatisch CSAR-Funktionalität.

## 7. Spieler-CSAR mit `Ops.CSAR`

### 7.1 Vorgesehene Standardfunktionen

`Ops.CSAR` soll möglichst unverändert verwendet werden für:

- Ejection-Erkennung;
- Spawn des Downed Pilot aus einem ME-Infanterietemplate;
- Funkbake und Koordinatenmeldung;
- Rauch, Flares und optional IR-Strobe;
- F10-Menüs;
- Annäherungsüberwachung;
- Lauf des Piloten zum nah gelandeten Rettungshubschrauber;
- Hover-Pickup;
- Kapazitätsverwaltung;
- Rückführung zu MASH, FARP oder Airbase;
- FSM-Ereignisse wie `PilotDown`, `Boarded`, `Returning`, `Rescued` und `KIA`.

### 7.2 Sichtbarkeit und Verwundbarkeit

Relevante MOOSE-Optionen:

```lua
mycsar.immortalcrew = true
mycsar.invisiblecrew = false
```

Damit ist der Pilot sichtbar, aber unverwundbar.

Für einen echten Wettlauf gegen RED wäre zu testen:

```lua
mycsar.immortalcrew = false
mycsar.invisiblecrew = false
```

Der Pilot ist dann eine normale sichtbare, passive DCS-Bodeneinheit. MOOSE setzt für die Pilotengruppe standardmäßig Alarm State Green und ROE Hold Fire.

### 7.3 Tod eines Downed Pilot im normalen CSAR

Die MOOSE-Commit-Historie belegt, dass `Ops.CSAR` ausdrücklich um die Erkennung sterblicher Piloten und das FSM-Ereignis `KIA` erweitert wurde.

Historisch wurden unter anderem eingeführt:

- `DownedPilot.alive`;
- zentrale Prüfung von `group:IsAlive()`;
- FSM-Ereignis `KIA`;
- Entfernung beziehungsweise Deaktivierung toter Piloten in der aktiven Liste.

Eine lokal auskommentierte `__KIA`-Zeile in `_CheckWoundedGroupStatus()` ist nicht automatisch ein Defekt. In der historischen Implementierung wurde der KIA-Aufruf zentral über eine Tabellenprüfung ausgelöst, vermutlich zur Vermeidung doppelter Verarbeitung.

Für Operation Mountain Watch ist ausschließlich das Verhalten des gepinnten Commits maßgeblich. Es ist in DCS zu prüfen, ob der dort enthaltene Stand den Tod der gespawnten Pilotengruppe vollständig und fehlerfrei verarbeitet.

## 8. AICSAR mit `Functional.AICSAR`

### 8.1 Rolle

AICSAR ist als automatisierter Bereitschaftsdienst vorgesehen, damit offene Rettungsfälle auch ohne menschlichen CSAR-Piloten bearbeitet werden können.

### 8.2 Regionalisierung

Voraussichtlich sollen mehrere regionale AICSAR-Zellen statt einer globalen Instanz eingesetzt werden, beispielsweise:

- Bagram;
- Jalalabad / Fenty;
- Salerno;
- Kandahar.

Jede Instanz erhält:

- feste Heimatbasis;
- UH-60-Template;
- feste Recovery-/MASH-Zone;
- begrenztes Einsatzgebiet oder maximale Entfernung;
- begrenzte Zahl gleichzeitig verfügbarer Hubschrauber.

Diese Regionalisierung ist noch zu verifizieren, insbesondere hinsichtlich der Zuordnung eines Piloten zu genau einer AICSAR-Instanz.

### 8.3 Bekannte AI-Grenzen

AICSAR verwendet MOOSE-Transportlogik und benötigt eine tatsächliche AI-Landung beziehungsweise Beladung. Risikobereiche:

- Gebirge und steile Hänge;
- bebaute Gebiete;
- Wasser;
- ungeeignete oder blockierte Landeflächen;
- DCS-AI-Routing;
- fehlende Möglichkeit eines spielerähnlichen Hover-Loads.

Die Zuverlässigkeit in Afghanistan muss deshalb separat getestet werden.

### 8.4 Getöteter Pilot im AICSAR-Ablauf

AICSAR besitzt ein `PilotKIA`-Ereignis. Im geprüften Quellcode ist klar erkennbar, dass ein bereits aufgenommener Pilot beim Verlust des Rettungshubschraubers als KIA verarbeitet werden kann.

Noch nicht belastbar nachgewiesen ist der Fall:

```text
Pilot wird am Boden getötet
→ laufender AI-Transport wird abgebrochen
→ UH-60 kehrt kontrolliert zurück
→ Queue und Cargo werden bereinigt
```

Dieser Fall ist ein zwingender eigener Testpunkt.

## 9. Spieler- und AI-Ownership

### 9.1 Grundsatz

Spieler und AICSAR müssen auf demselben autoritativen Incident arbeiten. Ein Vorfall darf nicht durch zwei unabhängige Ejection-Handler doppelt erzeugt werden.

### 9.2 Minimaler Zustandsumfang

Für die erste Baseline sollen so wenige Zustände wie möglich verwendet werden:

```text
OPEN
AI_ASSIGNED
PLAYER_PICKED_UP
AI_PICKED_UP
DELIVERED
KIA_OR_LOST
```

Optional für später:

```text
PLAYER_INTENT
PLAYER_COMMITTED
CAPTURED
```

### 9.3 Grundregeln

```text
OPEN:
Spieler oder AI darf den Fall übernehmen.

AI_ASSIGNED:
Der Fall ist nicht mehr als offener Spielerauftrag anzubieten.

PLAYER_PICKED_UP:
AICSAR darf den Fall nicht mehr bearbeiten.

AI_PICKED_UP:
Spieler dürfen den Fall nicht mehr abschließen.

DELIVERED:
Der Ursprungsslot wird freigegeben.
```

Sobald ein AICSAR-Einsatz verbindlich gestartet wurde, soll der Vorfall nicht mehr als offen oder buchbar erscheinen. Ob dafür bereits MOOSE-Standardverhalten genügt oder eine minimale Ownership-Schicht erforderlich ist, muss getestet werden.

## 10. AICSAR-Auslösung und Spielerpriorität

### 10.1 Kein medizinischer Timer

AICSAR wird nicht durch Golden Hour oder einen Überlebenstimer ausgelöst.

### 10.2 Spieler benötigen Reaktionszeit

AICSAR soll nicht sofort starten, nur weil im Moment des Ausschusses kein Spieler in einem CSAR-Slot sitzt. Spieler benötigen Zeit, um:

- die Meldung zu sehen;
- einen aktuellen Einsatz zu beenden;
- in einen CSAR-Slot zu wechseln;
- den Hubschrauber zu starten.

### 10.3 MOOSE-Standard zuerst prüfen

AICSAR besitzt Standardoptionen für automatisches Verhalten in Abhängigkeit von menschlichen Hubschrauberpiloten. Zu prüfen ist, ob dies für OMW ausreicht.

Problem einer zu groben Standardprüfung:

```text
irgendein menschlicher Hubschrauberpilot ist aktiv
→ AICSAR wird möglicherweise zurückgehalten
```

Das beweist nicht, dass der Spieler:

- einen zugelassenen CSAR-Slot nutzt;
- den konkreten Fall übernehmen will;
- in Reichweite ist;
- innerhalb sinnvoller Zeit reagieren kann.

Nur falls MOOSE-Standard nicht genügt, darf eine minimale Dispatcher-Regel erwogen werden. Ein komplexes ETA-, Buchungs- oder medizinisches Timersystem ist nicht vorgesehen.

## 11. MOOSE-`NET` als Slot-Lock-Kandidat

### 11.1 Vorhandene Funktionen

Der gepinnte MOOSE-Stand enthält in `Wrapper.Net`:

```lua
NET:BlockSlot(Slot, Seconds)
NET:UnblockSlot(Slot)
```

Zusätzlich vorhanden sind unter anderem:

```lua
NET:BlockPlayer(...)
NET:BlockUCID(...)
NET:BlockSide(...)
```

Für OMW sind `BlockPlayer()` und `BlockUCID()` ungeeignet, weil der Spieler weiterhin andere zulässige Slots und insbesondere einen CSAR-Hubschrauber nutzen können soll.

### 11.2 Funktionsweise

`NET:BlockSlot()` speichert für eine DCS-Slot-ID einen Ablaufzeitpunkt:

```lua
self.BlockedSlots[Slot] = timer.getTime() + addon
```

`NET:IsAnyBlocked()` prüft diesen Eintrag beim `PlayerEnterUnit`- beziehungsweise `PlayerEnterAircraft`-Ereignis.

Die Funktion ist damit:

- zeitbasiert;
- nicht nativ zustandsbasiert „bis Pilot gerettet“;
- nicht automatisch persistent;
- nicht automatisch mit CSAR verknüpft;
- eine nachträgliche Reaktion nach Slot-Eintritt, keine nachgewiesene Vorab-Ausblendung.

### 11.3 Kritischer Quellcodepunkt

Beim Eintritt in einen blockierten Slot ruft MOOSE im geprüften Code `net.force_player_slot(...)` mit der aktuellen Seite und der aktuellen Unit-ID auf. Die konkrete Wirkung ist ohne DCS-Test nicht belastbar bestätigt.

Falls dieser Aufruf `false` liefert, wird als Fallback die Einheit nach kurzer Verzögerung zerstört. Das wäre keine saubere Vorab-Sperre und kann unerwünschte Nebenwirkungen haben.

### 11.4 Ergebnis der erweiterten MOOSE-Suche

Durchsucht wurden:

- der gepinnte MOOSE-Commit;
- aktueller MOOSE-Quellcode;
- Develop- und Stable-Dokumentation;
- `MOOSE_MISSIONS`;
- `MOOSE_MISSIONS_UNPACKED`;
- MOOSE-Issues;
- OMW-Dokumentation;
- Suchbegriffe wie `BlockSlot`, `BlockedSlots`, `net.force_player_slot`, `PlayerSlot`, `BlockPlayer`, `BlockUCID` und `CLIENTWATCH`.

Ergebnis:

- `Wrapper.Net:BlockSlot()` und `UnblockSlot()` sind der einzige konkrete MOOSE-native Slot-Lock-Kandidat;
- keine weitere eigenständige MOOSE-Klasse mit vergleichbarer Funktion wurde gefunden;
- keine offizielle Demo-Mission für `BlockSlot()` wurde gefunden;
- keine belastbare technische Acceptance für unseren Einsatzzweck liegt vor.

### 11.5 Aktuelle Bewertung

`NET:BlockSlot()` ist gemäß MOOSE-First zwingend zuerst zu testen, aber noch nicht als abschließend geeignete Lösung freigegeben.

Ein serverseitiger DCS-Hook wie `onPlayerTryChangeSlot` bleibt ausschließlich Fallback, falls der MOOSE-Ansatz im Dedicated-Server-Test nicht zuverlässig, selektiv und ohne unerwünschte Nebeneffekte funktioniert.

## 12. Slotfreigabe und Verlustfälle

### 12.1 Erfolgreiche Rettung

Der Slot bleibt gesperrt bei:

- bloßer Annäherung;
- Aufnahme des Piloten;
- Transport im Hubschrauber;
- Zwischenlandung.

Freigabe erst bei bestätigter Ablieferung:

```text
CSAR: Rescued / DELIVERED
AICSAR: PilotUnloaded / PilotRescued / DELIVERED
→ UnblockSlot(originSlotId)
```

### 12.2 KIA, Gefangennahme oder endgültiger Verlust

Ein Slot darf nicht dauerhaft verloren bleiben. Langfristig muss zwischen konkretem Pilotenschicksal und Staffelersatz unterschieden werden.

Aktuell noch offen:

```text
RECOVERED:
sofortige Freigabe nach Ablieferung

KIA_OR_LOST:
separate, deutlich längere Ersatzpersonal- oder Regenerationsregel
→ danach Slotfreigabe
```

Die konkrete Ersatzzeit oder ein späterer Pilotpool sind noch nicht festgelegt.

## 13. Gegnerischer Wettlauf

### 13.1 Erste mögliche Minimalstufe

Die kleinste technisch denkbare Stufe ist:

```text
Downed Pilot sichtbar und verwundbar
→ vorbereitete RED-Gruppe erkennt und bekämpft ihn
→ MOOSE verarbeitet KIA
```

Dies bildet spielmechanisch Verlust, aber noch keine realistische Gefangennahme ab.

### 13.2 Noch nicht Teil der Baseline

Nicht Bestandteil des ersten Entwicklungsauftrags:

- RED erhält glaubwürdig nur eine letzte bekannte Position;
- RED Commander erzeugt Suchauftrag;
- dynamische Suche in einem Gebiet;
- Capture-Radius und Gefangennahme statt Beschuss;
- HUMINT-/SIGINT-Folgeketten;
- spätere Gefangenenbefreiung.

Diese Punkte bleiben optionale spätere Erweiterung.

## 14. Bewusst zurückgestellte optionale Erweiterungen

### 14.1 Eigenständige Pilotbewegung und Evasion

Zurückgestellt:

- Pilot bewegt sich selbst zu einem besseren Pickup Point;
- Flucht vor RED-Kräften;
- Evasion Points;
- dynamische Beacon-Nutzung;
- letzte bekannte Position statt permanenter exakter Position;
- vollständiges SERE-Verhalten.

Der MOOSE-Standard „Pilot läuft auf kurze Distanz zum gelandeten Rettungshubschrauber“ bleibt erhalten.

### 14.2 Meta-CASEVAC für Bodentruppen

Zurückgestellt:

- IED-Verwundete;
- Verwundete aus Convoys;
- Verwundete nach Feuerkampf oder Explosion;
- MASCAL;
- medizinische Prioritäten;
- Golden-Hour-Planung;
- CampaignState-Verwundetenbestände.

DCS besitzt keine echte Verwundetensimulation. Solche Verletzten wären CampaignState-/Missionsmeta und müssten durch sichtbare Stellvertreter repräsentiert werden. Das ist legitim, aber nicht Teil der ersten CSAR-Baseline.

## 15. Korrigierte Annahmen und dokumentierte Irrwege

### 15.1 Verwundungs- und Todestimer

Frühere Überlegung:

```text
jeder ausgeschleuste Pilot ist verletzt
→ Überlebenschance sinkt
→ Golden-Hour-Timer
```

Korrektur:

- Ausschuss bedeutet nicht automatisch Verletzung;
- Golden Hour ist kein allgemeiner Pilot-CSAR-Timer;
- für reguläres Pilot-CSAR entfällt der medizinische Countdown.

### 15.2 Permanente Slot-Sperre bei Tod

Früheres Problem:

```text
Slot bleibt bis Rückkehr genau dieses Piloten gesperrt
+ Pilot kann sterben
→ Slot wäre dauerhaft verloren
```

Korrektur:

- Rettung und Ersatzpersonal sind getrennte Mechanismen;
- ein KIA-/Lost-Fall benötigt später eine Ersatzregel;
- permanenter Slotverlust ist nicht zulässig.

### 15.3 Eigenes Slot-Hook-System als erste Annahme

Frühere Annahme:

```text
echte Slot-Sperre erfordert zwingend eigenen DCS-Server-Hook
```

Korrektur:

- MOOSE enthält `NET:BlockSlot()` und `UnblockSlot()`;
- dieser MOOSE-native Ansatz ist zuerst zu testen;
- ein eigener Hook bleibt nur Fallback.

### 15.4 Zu frühe positive Bewertung von `NET:BlockSlot()`

Zwischenzeitlich wurde `NET:BlockSlot()` zu eindeutig als fertige Lösung bewertet.

Korrektur nach erweiterter Prüfung:

- Funktion ist vorhanden;
- keine offizielle Demo gefunden;
- nachträgliche statt nachgewiesener Vorab-Sperre;
- zeitbasiert statt zustandsbasiert;
- Dedicated-Server-Verhalten ungeprüft;
- verdächtige `net.force_player_slot()`-Parametrisierung;
- deshalb nur Testkandidat, noch keine Freigabe.

### 15.5 CSAR-KIA-Code vorschnell als unvollständig bewertet

Zwischenzeitlich wurde eine auskommentierte lokale `__KIA`-Zeile als Hinweis auf unvollständige KIA-Verarbeitung bewertet.

Korrektur nach Commit-Historie:

- Entwickler haben sterbliche Piloten und `KIA` ausdrücklich implementiert;
- der KIA-Aufruf wurde historisch zentral ausgeführt;
- die lokale Auskommentierung kann Doppelverarbeitung verhindern;
- maßgeblich bleibt der Test gegen den gepinnten Commit.

## 16. Geplanter Entwicklungs- und Prüfablauf

### Phase 1 – isolierte MOOSE-Baseline

1. `Ops.CSAR` mit einem Spieler-UH-1H einrichten.
2. `Functional.AICSAR` mit einem regionalen UH-60 einrichten.
3. Downed-Pilot-Template im Missionseditor anlegen.
4. Recovery-/MASH-Zonen anlegen.
5. Ejection und Pilot-Spawn prüfen.
6. Sicherstellen, dass genau ein Pilot entsteht.
7. Spieleraufnahme und Rückführung prüfen.
8. AI-Aufnahme und Rückführung prüfen.
9. Alle relevanten FSM-Callbacks protokollieren.
10. Noch keine produktive Slot-Lock-Kopplung.

### Phase 2 – CSAR/AICSAR-Zusammenspiel

1. Prüfen, ob beide Module denselben Ejection-Fall doppelt erzeugen.
2. Prüfen, ob eine gemeinsame physische Pilotengruppe genutzt werden kann.
3. Minimalen autoritativen Incident und Ownership-Regeln festlegen.
4. Spieler nimmt Pilot vor AI auf.
5. AI nimmt Pilot vor Spieler auf.
6. Bereits AI-zugewiesener Fall darf nicht offen bleiben.
7. Keine doppelte Rettung.
8. Keine doppelte Slotfreigabe.

### Phase 3 – isolierter MOOSE-`NET`-Slot-Lock-Test

Testaufbau:

- zwei getrennte F-16-Clientslots;
- ein separater zugelassener CSAR-Slot;
- Dedicated Server;
- mindestens zwei Spielerinstanzen, soweit möglich.

Prüfpunkte:

1. technische DCS-Slot-IDs loggen;
2. Slot 1 mit `NET:BlockSlot()` sperren;
3. Versuch, Slot 1 zu betreten;
4. beobachten, ob der Spieler:
   - nicht eintritt;
   - auf Spectator gesetzt wird;
   - im Slot verbleibt;
   - eine zerstörte Einheit erhält;
5. Slot 2 muss weiterhin nutzbar sein;
6. CSAR-Slot muss weiterhin nutzbar sein;
7. `UnblockSlot()` ausführen;
8. Slot 1 muss ohne Reconnect wieder nutzbar sein;
9. Multi-Unit-Gruppen separat prüfen;
10. Verhalten nach Respawn und erneutem Slotwechsel prüfen.

### Phase 4 – Kopplung an CSAR-Incident

1. Ejection dem Ursprungsslot zuordnen.
2. Slot erst sperren, wenn CSAR tatsächlich einen Downed Pilot erzeugt hat.
3. Slot bei `Boarded` weiterhin gesperrt lassen.
4. Slot erst bei bestätigtem `DELIVERED` freigeben.
5. Reconnect und Namensänderung über UCID nachvollziehen.
6. Selbstrettung durch denselben Spieler testen.
7. KIA-/Lost-Folge zunächst protokollieren, noch keine ungetestete Ersatzregel produktiv setzen.

### Phase 5 – verwundbarer Pilot und RED-Einwirkung

1. `immortalcrew=false`.
2. `invisiblecrew=false`.
3. vorbereitete RED-Gruppe erkennt und bekämpft den Piloten.
4. Prüfen, ob `Ops.CSAR` `KIA` auslöst.
5. Prüfen, ob Beacon, F10-Liste und interner Pilotendatensatz bereinigt werden.
6. Pilot stirbt vor AICSAR-Dispatch.
7. Pilot stirbt nach AICSAR-Dispatch.
8. Pilot stirbt während AI-Anflug.
9. AI-Hubschrauber wird vor Pickup zerstört.
10. AI-Hubschrauber wird nach Pickup zerstört.

### Phase 6 – Gelände- und Betriebszuverlässigkeit

Mindestens prüfen:

- flaches Gelände;
- enger Talboden;
- steiler Berghang;
- dichte Bebauung;
- Nacht;
- schlechtes Wetter;
- mehrere gleichzeitige Piloten;
- regionale AICSAR-Reichweitengrenzen;
- Queue und Helo-Limit;
- Missions-/Serverneustart, sofern Persistenz später aktiviert wird.

## 17. Vorläufige Abnahmekriterien

Eine erste produktive Baseline kann erst akzeptiert werden, wenn:

1. eine Ejection zuverlässig genau einen Incident erzeugt;
2. Spieler-CSAR den Piloten aufnehmen und zurückbringen kann;
3. AICSAR denselben Grundablauf ohne Spieler durchführen kann;
4. ein Incident niemals doppelt bearbeitet oder doppelt abgeschlossen wird;
5. der konkrete Ursprungsslot eindeutig zugeordnet wird;
6. ausschließlich dieser Slot gesperrt wird;
7. der abgestürzte Spieler weiterhin einen zugelassenen CSAR-Slot nutzen kann;
8. Mi-8 und CH-47 keine CSAR-/MEDEVAC-Berechtigung erhalten;
9. Slotfreigabe erst nach bestätigter Ablieferung erfolgt;
10. der MOOSE-`NET`-Ansatz auf Dedicated Server zuverlässig getestet ist;
11. ein eigener Hook nur bei nachgewiesenem MOOSE-Defizit verwendet wird;
12. kein Golden-Hour- oder medizinischer Todestimer für normale Ejection-Fälle existiert;
13. Pilot-Evasion und Meta-CASEVAC nicht versehentlich Teil der ersten Baseline werden;
14. alle verwendeten Methoden gegen Commit `73d3ed119...` verifiziert sind;
15. der Acceptance-Bericht MOOSE-, OMW-, Missions- und Bundle-Hashes enthält.

## 18. Offene Entscheidungen

Vor produktiver Umsetzung noch festzulegen:

- konkrete regionalen AICSAR-Zellen und Recovery-Ziele;
- maximale AICSAR-Reichweite je Zelle;
- Anzahl gleichzeitig verfügbarer UH-60;
- genaue Spieler-Reaktionsfrist vor AI-Dispatch, falls MOOSE-Standard nicht genügt;
- minimale Ownership- und Reservierungslogik;
- Slotfreigabe beziehungsweise Ersatzregel bei `KIA_OR_LOST`;
- Persistenz über Missionsneustarts;
- endgültige technische Identität des Slots: DCS-Slot-ID, Unit-ID und lesbarer ME-Unitname;
- ob `NET:BlockSlot()` genügt oder ein freigegebener Hook-Fallback erforderlich wird.

## 19. Aktueller Gesamtstand

```text
Fachliches Zielbild: festgelegt
MOOSE-Baseline: festgelegt und eingefroren
Spieler-CSAR-Modul: Ops.CSAR vorgesehen
AI-CSAR-Modul: Functional.AICSAR vorgesehen
Spieler-CSAR-Fluggerät: UH-1H, optional UH-60-Mod
AI-CSAR-Fluggerät: UH-60
Mi-8 zugelassen: nein
CH-47 zugelassen: nein
Golden-Hour-Timer für Ejection: verworfen
Pilot-Evasion: optionaler Spätausbau
Meta-CASEVAC: optionaler Spätausbau
Gegnerischer Wettlauf: Zielbild, erste Minimaltests geplant
Slot-Lock-Kandidat: MOOSE NET:BlockSlot()/UnblockSlot()
Slot-Lock technisch akzeptiert: nein
CSAR/AICSAR-Ownership akzeptiert: nein
Dedicated-Server-Testharness: noch anzulegen
Produktiver Implementierungsauftrag: nach Review dieses Dokuments und Festlegung der offenen Entscheidungen
```
