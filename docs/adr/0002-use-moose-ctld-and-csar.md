# ADR-0002: MOOSE CTLD und MOOSE CSAR

## Status

Angenommen für den ersten Prototyp

## Kontext

Ciribob DCS-CTLD und DCS-CSAR sind bewährte Systeme, benötigen jedoch MIST und verwenden ein zusätzliches prozedurales Objekt- und Eventmodell. MOOSE enthält eigene CTLD- und CSAR-Implementierungen, die sich direkter in MOOSE-Events und die geplante Architektur integrieren lassen.

## Entscheidung

Der erste Prototyp verwendet MOOSE CTLD und MOOSE CSAR. Ciribob CTLD/CSAR und MIST werden nicht parallel geladen.

Vor endgültiger Festlegung müssen folgende Funktionen in DCS getestet werden:

- C-130J Dynamic Cargo und Luftabwurf
- Erkennung der stabilen Endposition eines Pakets
- CTLD-Aufnahme, Absetzen und Bau aus mehreren Lieferungen
- MOOSE-CSAR-Ereignisse, Funkbaken und Rückgabe an eine Rettungseinrichtung
- Integration eigener Capture- und Kampagnenlogik

## Konsequenzen

- Ein einheitliches MOOSE-Event- und Objektmodell reduziert Integrationscode.
- Fehlende Funktionen werden zuerst durch kleine Adapter ergänzt.
- Ein Wechsel zu Ciribob CTLD oder CSAR erfolgt nur nach einem dokumentierten, reproduzierbaren Funktionsdefizit.
