# ADR 0005 – Hybride DCS-Warehouse-Integration

- Status: Accepted
- Date: 2026-07-13

## Context

Operation Mountain Watch benötigt sichtbare und spielerisch nutzbare Logistikbestände. Native DCS-Warehouses können Flugzeuge, Waffen, Flüssigkeiten und geeignete Cargo-Inhalte verwalten. Gleichzeitig enthält die Kampagne strategische Ressourcen wie Personal, Ingenieurkapazität, Baumaterial, Intelligence und Moral, die nicht vollständig oder sinnvoll als native DCS-Warehouse-Items abgebildet werden können.

Ein natives Warehouse an jedem FOB, COP, OP, Checkpoint und temporären Landeplatz würde Konfiguration, Synchronisierung und Benutzeroberfläche unnötig aufblähen. Eine ausschließlich abstrakte Simulation würde dagegen die native DCS-Interaktion und die für Spieler sichtbaren Bestände an wichtigen Basen ungenutzt lassen.

## Decision

Die Kampagne verwendet eine hybride Architektur.

- `CampaignState` bleibt die autoritative und persistente Quelle für strategische Ressourcen.
- Native DCS-Warehouses werden an dauerhaften, spielerrelevanten Logistikknoten eingesetzt.
- Jalalabad/FOB Fenty und FOB Connolly erhalten im ersten Prototyp eine native Warehouse-Anbindung.
- Bagram und Kabul werden strategisch geführt und erhalten eine native Anbindung, sobald sie physisch und spielerisch genutzt werden.
- Kleine COPs, OPs, Checkpoints und temporäre Landezonen verwenden ausschließlich abstrahierte lokale Bestände.
- Ein eigener `WarehouseAdapter` kapselt alle Zugriffe auf DCS `Warehouse` und MOOSE `STORAGE`.
- Jede Lieferung und Bestandskorrektur wird über eine idempotente Transaktion verbucht.
- Strategische Ressourcen ohne belastbare native Abbildung bleiben ausschließlich im CampaignState.

## Consequences

### Positive

- Spieler können an wichtigen Basen native DCS-Bestände nutzen und einsehen, soweit der jeweilige Warehouse-Typ dies unterstützt.
- Flugzeugbewaffnung, Betankung und geeignete Cargo-Prozesse können reale Bestände beeinflussen.
- Strategische Kampagnenlogik bleibt unabhängig von DCS-internen Itemnamen.
- Kleine Posten bleiben leichtgewichtig.
- Persistenz und Wiederherstellung bleiben kontrollierbar.
- Fehler oder fehlende Warehouse-Funktionen können auf einen abstrakten Lagerbetrieb zurückfallen.

### Negative

- Zwei Bestandsebenen müssen synchronisiert werden.
- DCS-Itemnamen und Warehouse-Verhalten müssen versionsbezogen getestet werden.
- Direkter Spielerverbrauch erzeugt Abgleichsbedarf.
- Nicht jeder Warehouse-Typ bietet zwingend dieselbe Spieleroberfläche.
- Transaktionen, Reconciliation und Diagnoseprotokolle erhöhen den Implementierungsaufwand.

## Rules

- CampaignState ist die persistente Autorität.
- Domänenmodule greifen nicht direkt auf DCS-Warehouse-Funktionen zu.
- Jeder physische Warehouse-Knoten besitzt stabile ID, Capabilities und explizite Übergabezonen.
- Lieferungen werden genau einmal über eine Transaktions-ID verbucht.
- Unbekannte Differenzen werden nicht stillschweigend übernommen.
- Kein natives Warehouse an jedem OP, Checkpoint oder temporären Landeplatz.
- Spieleranzeige ersetzt keine technische Bestandsprüfung.
- Unbegrenzte Bestände sind nur in ausdrücklich markierten Testmodi erlaubt.
- Mapping und Validierung werden mit DCS- und MOOSE-Version dokumentiert.
