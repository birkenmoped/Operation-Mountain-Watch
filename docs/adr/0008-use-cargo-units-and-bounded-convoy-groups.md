# ADR 0008 – Cargo Units und begrenzte physische Konvoigruppen

- Status: Accepted
- Date: 2026-07-13

## Context

Operation Mountain Watch verwendet mehrere Transportwege: Straßenkonvois, interne Hubschrauberfracht, Außenlasten, gelandete C-130J-Lieferungen und Luftabwürfe. Die Plattformen besitzen unterschiedliche technische Schnittstellen, reale Leistungsgrenzen und DCS-spezifische Einschränkungen.

Eine direkte Gleichsetzung von Fahrzeugzahl, theoretischer Nutzlast und Kampagnenressourcen würde zu inkonsistentem Balancing führen. Gleichzeitig sind sehr große DCS-Bodengruppen auf engen Straßen, in Ortschaften, an Kreuzungen und bei Verlusten störanfällig.

## Decision

Operation Mountain Watch verwendet Cargo Units als gemeinsames strategisches Planungsmaß.

```text
1 CU = 1.000 kg nominale Transportmasse
```

CU wird in Schritten von `0.25 CU` geführt.

CU ersetzt weder tatsächliche Masse und Volumen noch technische Plattformgrenzen. Jede Lieferung speichert weiterhin mindestens reales Gewicht, Volumenklasse, Handling-Modus und Cargo-ID.

Die verbindlichen Kampagnen-Standardwerte lauten zunächst:

| Plattform | Standardkapazität |
|---|---:|
| schwerer Transport-Lkw | 2 CU |
| UH-1H intern | 1 CU |
| UH-1H Außenlast | 1 CU |
| UH-60L intern | 2 CU, vorläufig |
| UH-60L Außenlast | 3 CU, vorläufig |
| CH-47F intern | 5 CU |
| CH-47F Außenlast | 4 CU |
| C-130J gelandet | 12 CU |
| C-130J Luftabwurf | 8 CU |

Diese Werte sind konservative Missions- und Balancinggrenzen, keine technischen Maximalzuladungen.

Straßenkonvois werden physisch begrenzt:

```text
bevorzugt: 4–6 Fahrzeuge je DCS-Gruppe
Maximum:   8 Fahrzeuge je DCS-Gruppe
ab 9:      mehrere getrennte Serials
```

Der Standardkonvoi Fenty–Connolly besteht aus fünf bis sechs Fahrzeugen, darunter zwei schwere Fracht-Lkw mit insgesamt 4 CU und drei bis vier Sicherungs-, Führungs- oder Unterstützungsfahrzeuge.

Größere logische Konvois bleiben ein strategischer Auftrag, werden aber in mehrere physische DCS-Gruppen mit getrennten Controllern, Startabständen und eindeutiger Frachtzuordnung aufgeteilt.

Für die C-130J werden drei Ebenen getrennt:

1. offiziell bestätigte Funktionen;
2. Handbuch- und Moduldaten zu Gewicht, Schwerpunkt und unterstützten Lastarten;
3. konservative Kampagnen-Standardpakete.

Roll-on/Roll-off-Fahrzeugtypen und konkrete Fahrzeugkombinationen bleiben bis zum reproduzierbaren DCS-Test offen. Fahrzeuge bleiben persistente Entities und werden nicht in allgemeine CU umgewandelt.

## Consequences

### Positive

- alle Transportwege verwenden dasselbe strategische Vergleichsmaß;
- Teilverluste lassen sich je Fahrzeug oder Abwurfpaket verbuchen;
- Logistikaufträge können verständlich balanciert werden;
- technische Plattformgrenzen bleiben trotzdem maßgeblich;
- große Kolonnen blockieren nicht als eine einzige DCS-Gruppe die Route;
- C-130J-Annahmen werden nicht mit Herstellerangaben verwechselt.

### Negative

- CU und reale Frachtparameter müssen parallel gepflegt werden;
- Plattformprofile benötigen Versions- und Teststatus;
- mehrere Serials erhöhen den Verwaltungsaufwand des ConvoyManagers;
- C-130J-RORO bleibt bis zur Testauswertung eingeschränkt;
- vorläufige UH-60L-Werte müssen bei Mod-Updates erneut validiert werden.

## Rules

- Jede Cargo-ID wird genau einmal gutgeschrieben.
- Jede Fracht ist einem Träger oder Paket eindeutig zugeordnet.
- Eskorte trägt standardmäßig keine CU.
- CU überschreibt niemals Masse, Volumen, Schwerpunkt oder Performancegrenzen.
- Mehr als acht Fahrzeuge werden nicht als eine reguläre physische DCS-Konvoigruppe geplant.
- UH-60L-Kapazitäten bleiben versionsbezogen und vorläufig.
- C-130J-Standardwerte von 12 CU gelandet und 8 CU Airdrop sind Kampagnenpakete, keine Maximalzuladungen.
- Fahrzeugabwurf ist nicht Bestandteil des ersten Prototyps.
- RORO-Konfigurationen werden erst nach einem dokumentierten DCS-Test freigegeben.
