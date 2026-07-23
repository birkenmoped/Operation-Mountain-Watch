# 21 – Klassifikation alliierter Stützpunkte

## Ziel

Dieses Dokument legt eine einheitliche Terminologie für alliierte Stützpunkte in Operation Mountain Watch fest. Historische Bezeichnungen werden beibehalten; zusätzlich erhält jeder Standort eine funktionale Kampagnenklasse für Logistik, Warehouse-Nutzung, Garnison, Missionsgenerierung und Virtualisierung.

Die Terminologie orientiert sich unter anderem an:

https://www.patreon.com/graveyard4DCS/posts/guide-to-soup-of-126847873

Der Guide dient als strukturierende Fachreferenz. Konkrete historische Einstufungen einzelner Standorte werden bei Bedarf zusätzlich gegen zeitgenössische oder spezialisierte Quellen geprüft.

## Grundsatz

Die Bezeichnung eines Standorts richtet sich nicht allein nach seiner sichtbaren Größe im Mission Editor und nicht nach der Zahl seiner Static Objects.

Entscheidend sind:

- historische Bezeichnung;
- operative Funktion;
- unterstützte Verbände und Außenposten;
- Logistik- und Führungsrolle;
- Dauerhaftigkeit;
- Art der dort vorgesehenen Missionen.

Ein Standort kann deshalb eine historische Bezeichnung und eine davon getrennte interne Kampagnenklasse besitzen.

```lua
{
  locationId = "LOC_FOB_CONNOLLY",
  displayName = "FOB Connolly",
  historicalDesignation = "FOB",
  campaignBaseClass = "FOB",
}
```

Bei unsicherer oder wechselnder historischer Bezeichnung wird dies dokumentiert und nicht durch eine erfundene eindeutige Einstufung ersetzt.

## Hierarchisches Grundmodell

```text
MOB / strategische Airbase
└── FOB / regionaler Hub
    └── COP / dauerhafte vorgeschobene Präsenz
        ├── PB oder VPB / kleiner oder temporärer Patrouillenstützpunkt
        └── OP / Beobachtung und Frühwarnung
```

Die Hierarchie beschreibt typische Unterstützungsbeziehungen, keine zwingend starre Befehlskette. Ein FOB kann mehrere COPs versorgen; COPs können durch PBs und OPs ergänzt werden.

## Basisklassen

### MOB – Main Operating Base

Großer logistischer und administrativer Theaterknoten oberhalb eines typischen FOB.

Typische Eigenschaften:

- umfangreiche strategische Reserven;
- größere Flugplatz- und Wartungsinfrastruktur;
- Führungs-, Verwaltungs- und Personalverlegungsfunktion;
- Versorgung mehrerer regionaler Knoten;
- hohe Dauerhaftigkeit.

Kampagnenfolgen:

- bevorzugter nativer Warehouse-Knoten;
- große Kapazitäten;
- Quelle strategischer Verstärkungen;
- nur begrenzte direkte taktische Verwundbarkeit im ersten Prototyp.

### FOB – Forward Operating Base

Dauerhafter regionaler Stützpunkt und Hub für einen größeren Operationsraum.

Typische Eigenschaften:

- bedeutende Garnison;
- Führungs- und Intelligence-Funktion;
- Vorräte, Wartung und medizinische Fähigkeiten;
- Unterstützung mehrerer vorgeschobener Standorte;
- Ausgangspunkt für QRF, Konvois, Patrouillen und Luftbewegungen.

Kampagnenfolgen:

- Kandidat für natives DCS-Warehouse;
- vollständiges CampaignState-Basenobjekt;
- mehrere Liefer- und Übergabezonen;
- eigener Schadens-, Belagerungs- und Wiederaufbauzustand.

### COP – Combat Outpost

Kleinerer dauerhafter Kampf- und Patrouillenstützpunkt nahe dem taktischen Einsatzraum.

Typische Eigenschaften:

- ständige lokale Präsenz;
- Patrouillen- und Beobachtungsaufträge;
- begrenzte Vorräte und Wartung;
- höhere Abhängigkeit von FOB oder Airbase;
- höhere Verwundbarkeit gegen indirektes Feuer, Belagerung und Unterbrechung der Versorgung.

Kampagnenfolgen:

- standardmäßig abstrakter lokaler Bestand;
- natives Warehouse nur bei klarer Spielerrelevanz und technischer Eignung;
- begrenzte Garnison und Ausbauzustände;
- häufiges Ziel für Nachschub-, QRF- und Entsatzmissionen.

### PB – Patrol Base

Kleiner, häufig temporärer Stützpunkt für Patrouillen oder zeitlich begrenzte Operationen.

Typische Eigenschaften:

- geringe Personalstärke;
- minimale Infrastruktur;
- kurze Versorgungsreichweite;
- schnelle Einrichtung, Verlegung oder Aufgabe;
- enge Verbindung zu lokalen Patrouillen und Bevölkerungskontakt.

Kampagnenfolgen:

- kein natives Warehouse;
- ausschließlich abstrahierte Bestände;
- einfache Ausbau- oder Abbauzustände;
- kann als temporäres Missionsziel erzeugt werden.

### VPB – Vehicle Patrol Base

Patrol Base mit Schwerpunkt auf fahrzeuggebundenen Patrouillen.

Zusätzliche Anforderungen:

- befahrbare Zufahrt;
- Stell- und Wendeflächen;
- Treibstoff- und Fahrzeugversorgung;
- gegebenenfalls kleine Reparaturfähigkeit.

Kampagnenfolgen entsprechen grundsätzlich einer PB, ergänzt um Fahrzeugkapazität und straßengebundene Logistik.

### OP – Observation Post

Beobachtungs- und Frühwarnstellung, häufig auf Geländehöhen oder an dominanten Sichtachsen.

Typische Eigenschaften:

- sehr kleine Besatzung;
- Sensor-, Funk- und Beobachtungsfunktion;
- dauerhaft oder temporär besetzt;
- geringe materielle Infrastruktur;
- hohe Abhängigkeit von Nachschub und Ablösung.

Kampagnenfolgen:

- kein natives Warehouse;
- abstrakte Bestände für Personal, Munition, Wasser und Kommunikationsfähigkeit;
- Einfluss auf Aufklärung, Warnzeit und Zielerfassung;
- möglicher Evakuierungs-, Entsatz- oder Wiederbesetzungsauftrag.

### FSB – Fire Support Base

Stellung für Artillerie- oder Feuerunterstützung. In Afghanistan wurden Artilleriemittel häufig in größeren FOBs untergebracht; eigenständige FSBs sind daher kein Standardbaustein der Kampagne.

Kampagnenfolgen:

- nur bei historisch oder operativ begründetem Standort;
- Munition und Feuerbereitschaft als eigene Ressourcen;
- kein automatisch eigener großer Logistikknoten.

### PRT – Provincial Reconstruction Team

Militärisch-zivile Organisation oder Standortfunktion für Wiederaufbau, Governance und Stabilisierung.

Kampagnenfolgen:

- erzeugt Stabilitäts-, Schutz-, Transport- und Infrastrukturmissionen;
- besitzt politische und zivile Bedeutung zusätzlich zur militärischen Sicherung;
- kann an einem FOB oder eigenständigen Standort angesiedelt sein.

PRT ist nicht automatisch eine Größenklasse wie FOB oder COP, sondern primär eine Funktion beziehungsweise Organisation.

### CMOC – Civil-Military Operations Center

Koordinationsfunktion zwischen militärischen Kräften, Behörden und zivilen Organisationen.

Kampagnenfolgen:

- Intelligence- und Stabilitätswirkung;
- Schutz- und Verbindungseinsätze;
- keine automatische Warehouse- oder Garnisonsklasse.

### BCC – Border Coordination Center

Koordinationsknoten für grenznahe Sicherheitskräfte und grenzüberschreitende Abstimmung.

Kampagnenfolgen:

- Grenzüberwachung und Intelligence;
- Kontrolle von Bewegungen und Versorgungskorridoren;
- Missionen für Verbindung, Schutz, Interdiction und Reaktion auf Grenzereignisse;
- kann mit einem Checkpoint, COP oder FOB verbunden sein.

## Einordnung für Operation Mountain Watch

### Bagram Airfield

Funktionale Kampagnenklasse:

```text
MOB / STRATEGIC_BASE
```

Bagram ist strategischer Theaterknoten für Reserven, größere Luftstreitkräfte, Wartung und übergeordnete Logistik.

### Kabul

Funktionale Kampagnenklasse:

```text
STRATEGIC_REAR_NODE
```

Kabul erfüllt politische, administrative und logistische Rückraumfunktionen. Die genaue historische Basenbezeichnung hängt vom konkret modellierten Teilstandort ab und wird nicht pauschal als ein einzelner FOB ausgegeben.

### Jalalabad Airfield / FOB Fenty

Funktionale Kampagnenklasse:

```text
REGIONAL_AIRBASE_FOB_HUB
```

Die native Airbase und der militärisch-operative Fenty-Bereich bilden gemeinsam den regionalen Hub für Task Force Bastogne. Es wird kein separater Fenty-Standort erzeugt.

### FOB Connolly

Funktionale Kampagnenklasse:

```text
FOB
```

Connolly ist permanenter vorgeschobener Logistikknoten und Ziel des ersten vertikalen Prototyps.

### Afghanische Kontrollpunkte

Funktionale Kampagnenklassen je Standort:

```text
CHECKPOINT
COP
OP
```

Die Klasse wird nach tatsächlicher Funktion vergeben. Ein kleiner Kontrollpunkt wird nicht allein wegen Mauern oder eines Helipads zum FOB.

### Mehtar Lam, Blessing und spätere Standorte

Die historische Bezeichnung wird beibehalten. Vor Aufnahme werden Funktion, Zeitraum, unterstützte Standorte und tatsächliche Rolle geprüft. Ein Community-Template bestimmt nicht automatisch die Kampagnenklasse.

## Auswirkung auf Warehouses

| Basisklasse | Standard-Warehouse-Modus |
|---|---|
| MOB / große Airbase | `STRATEGIC_NATIVE` oder vorübergehend `STRATEGIC_ABSTRACT` |
| bedeutender FOB | `FOB_NATIVE` oder getesteter abstrakter Fallback |
| COP | `LOCAL_ABSTRACT`, nur begründete Ausnahme nativ |
| PB / VPB | `LOCAL_ABSTRACT` |
| OP | `LOCAL_ABSTRACT` oder `NO_STORAGE` |
| temporäre LZ / DZ | `NO_STORAGE` |
| PRT / CMOC / BCC | nach physischem Trägerstandort, nicht nach Funktionsnamen |

Eine Basisklasse allein erzeugt kein Warehouse. Spielerrelevanz, DCS-Fähigkeiten, Persistenzanforderungen und technische Tests bleiben erforderlich.

## Auswirkung auf Static Templates

Die historische Standortbezeichnung und die Template-Identität werden nicht durch die Kampagnenklasse ersetzt.

Beispiele:

```text
FOB Connolly bleibt FOB Connolly.
COP Michigan bleibt COP Michigan.
OP Restrepo bleibt OP Restrepo.
```

Ein großes Community-Template wird nicht automatisch zum FOB erklärt, und ein kleines Template wird nicht umbenannt, um eine andere geplante Basis zu repräsentieren.

## Datenmodell

Vorgesehene Felder:

```lua
{
  locationId = "LOC_EXAMPLE",
  displayName = "Example",
  historicalDesignation = "COP",
  campaignBaseClass = "COP",
  parentSupportNodeId = "LOC_FOB_EXAMPLE",
  permanence = "PERMANENT",
  warehouseMode = "LOCAL_ABSTRACT",
  functions = {
    "PATROL",
    "OBSERVATION",
    "QRF_STAGING",
  },
}
```

Mögliche Werte für `permanence`:

- `PERMANENT`
- `SEMI_PERMANENT`
- `TEMPORARY`
- `MISSION_ONLY`

## Regeln

- Historische Namen und Akronyme werden nicht nach sichtbarer Größe umgedeutet.
- `historicalDesignation` und `campaignBaseClass` bleiben getrennte Felder.
- Ein FOB kann COPs unterstützen; ein COP kann PBs und OPs unterstützen.
- PBs, VPBs und OPs erhalten standardmäßig keine nativen Warehouses.
- PRT, CMOC und BCC beschreiben primär Funktionen oder Organisationen, nicht automatisch eine Basengröße.
- Static-Template-Verfügbarkeit ändert keine Klassifikation ohne fachliche Prüfung.
- Unsichere Einstufungen werden als offen dokumentiert statt erfunden.
