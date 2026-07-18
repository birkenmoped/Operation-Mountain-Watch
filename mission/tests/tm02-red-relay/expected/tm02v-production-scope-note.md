# TM02V – Produktionsabgrenzung nach der Netzarchitekturentscheidung

## Status

TM02V bleibt ein gültiger technischer Test für:

- dynamische Personalkontingente;
- Gruppengrößen bis zum konfigurierten Maximum;
- unabhängige Proxy- und physische Repräsentationen;
- Pack/Unpack;
- Retention an Ziel- oder Zwischenknoten;
- Verluste und exakte Personalbilanz;
- mehrere gleichzeitig aktive Gruppen.

## Nicht mehr als Produktionsregel zu verwenden

Der feste Testbaum:

```text
HQ
├── A
│   ├── AA
│   └── AB
└── B
    ├── BA
    └── BB
```

ist ein kontrollierter Testdatensatz. Das spätere Produktionssystem darf daraus nicht ableiten:

- dass jeder Knoten genau einen Elternknoten besitzt;
- dass Personal ausschließlich aus dem Haupt-HQ kommt;
- dass jeder Knoten dauerhaft voll besetzt bleiben muss;
- dass jeder Knoten exakt zehn Mann halten muss;
- dass ein Zehn-Mann-Bedarf immer als `6 + 4` bedient wird;
- dass eine top-down Hierarchie die einzige zulässige Verteilungsregel ist.

## Version 6

Die Konfiguration:

```text
maxTeamStrength = 6
maxActivePackets = 6
```

bleibt für einen isolierten Gruppengrößen- und Parallelitätstest sinnvoll.

Die erwartete Zerlegung leerer Zehnerziele in `6 + 4` ist jedoch nur eine Folge dieses künstlichen Testzustands. Sie ist kein produktives Verteilungsdogma.

## Produktionsziel

Das spätere System verwendet:

- ein kostenbewertetes Netzwerk;
- mehrere mögliche Personalquellen;
- dynamische Knotenbestände statt fester Eigentumsgruppen;
- Stationen mit Grundwache, Bereitschaftsziel und harter Kapazität;
- begrenzte und verzögerte Kommandeursentscheidungen;
- mobile Teams bis sechs Mann;
- Angriffe aus zwei unabhängigen Sechserteams;
- dynamisch besetzte und dauerhaft zerstörbare Standorte.

Der geplante Nachfolgetest ist:

```text
TM02W – Red network commander acceptance
```

Siehe:

- `docs/26-red-force-network-command-intelligence-and-sites.md`
- `mission/tests/tm02-red-relay/expected/tm02w-red-network-commander-acceptance.md`

## Konsequenz für die laufende Abnahme

Ein weiterer TM02V-Version-6-DCS-Lauf kann weiterhin die Packetgrenze sechs, sechs aktive Proxies und vollständige Bilanzierung prüfen.

Er gilt nicht als Abnahme der späteren Netz-, Führungs-, HUMINT-, Standort- oder Angriffsarchitektur.