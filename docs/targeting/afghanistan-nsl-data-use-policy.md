---
document_id: OMW-TARGETING-AFGHANISTAN-NSL-DATA-USE
status: BINDING
authoritative_for:
  - NSL-specific implementation handling
  - NSL attribution and artifact separation
owning_policy: OMW-GOV-SOURCE-USE
scenario_period: 2010-08-01/2011-12-31
source_branch: agent/afghanistan-nsl-documentation
validated_in_dcs: false
---

# Afghanistan-NSL v1.0 – Datenverwendung und Umsetzung

## 1. Autorität

Die projektweite Entscheidung über Quellen, Originaldateien, normalisierte Daten, abgeleitete Projektdateien und Veröffentlichungsumfang wird ausschließlich zentral geführt:

- `OMW-GOV-SOURCE-USE` – `docs/sources/graveyard-of-empires.md`.

Dieses Dokument ist keine parallele Lizenz- oder Quellenrichtlinie. Es konkretisiert nur die technische Behandlung der Afghanistan-NSL v1.0.

## 2. Projektentscheidung für die NSL

```text
Status: APPROVED_FOR_PROJECT_USE
Datensatz: Afghanistan NSL v1.0
Einträge: 2.954
Quelle: Graveyard of Empires
```

Nach der zentralen Projektentscheidung sind zulässig und vorgesehen:

- Einlesen der bereitgestellten CombatFlite-, KML- und KMZ-Dateien;
- unveränderte Ablage der Originaldateien nach Entscheidung des Projektmanagers beziehungsweise Autors;
- Normalisierung aller 2.954 Einträge;
- Konvertierung der WGS84-Koordinaten für DCS und MOOSE;
- Filterung und Alignment gegen die jeweils verwendete DCS-Afghanistan-Kartenversion;
- Ergänzung projektbezogener Metadaten, Schutzradien, Kategorien und Prüfstatus;
- Speicherung als Lua-, JSON-, CSV-, GeoJSON- oder anderes Laufzeitformat;
- Einbindung in Missionen, Testpakete und veröffentlichte Projektartefakte;
- Verwendung als verpflichtende Zielschutzprüfung vor offensiver Missions- oder Auftragserzeugung.

Die fehlende ausdrückliche Lizenzbezeichnung ist nach der getroffenen Projektentscheidung kein Implementierungsblocker für die vorgesehene OMW-/DCS-Nutzung.

## 3. Attribution

Sämtliche Credits für ursprüngliche Recherche und Quelldatensatz gehen an:

- **Graveyard of Empires**
- <https://www.patreon.com/cw/graveyard4DCS>

Empfohlener Attributionstext:

> Afghanistan No-Strike List v1.0: original research and source dataset by Graveyard of Empires. Project-specific normalization, validation and DCS/MOOSE integration by Operation Mountain Watch.

Attribution und Provenienz sind mindestens zu führen in:

- Quellartefakt-Manifesten und Hashlisten;
- normalisierten Datensätzen;
- generierten Laufzeitdateien;
- Dokumentation und Quellenregister;
- relevanten Missionsbriefings und Credits;
- Release-Hinweisen für Missionspakete mit NSL-Daten.

## 4. Trennung der Datenebenen

| Ebene | Verbindliche Behandlung |
|---|---|
| ursprüngliche CombatFlite-/KML-/KMZ-Dateien | unverändert mit Hash, Quelle, Version und Zugriffsnachweis führen |
| normalisierte WGS84-Daten | als OMW-Arbeitsdaten mit unveränderter Quell-ID und Provenienz führen |
| DCS-/MOOSE-Koordinaten | als kartenversionabhängige Ableitung führen |
| Kategorien und Bezeichnungen | Quelle, Korrektur und OMW-Normalisierung getrennt dokumentieren |
| Schutzradien und Schutzpolygone | als eigenständige OMW-Sicherheits- und Gameplay-Entscheidungen kennzeichnen |
| Alignment-, Audit- und Acceptance-Daten | als OMW-Prüfergebnisse mit DCS-Version führen |

Die ursprünglichen WGS84-Werte werden niemals durch DCS-abgeleitete Werte überschrieben.

## 5. Zugriff und konkrete Nutzungsbedingungen

Für die derzeit verwendete v1.0 und die drei frei zugänglichen Begleitbeiträge gilt die Projektfreigabe. Nicht rechtmäßig zugängliche spätere Versionen oder zusätzliche Paywall-Inhalte werden nicht automatisch übernommen.

Erklärt der Urheber später konkrete abweichende Nutzungsbedingungen, wird der betroffene Projektbestand geprüft und erforderlichenfalls angepasst. Diese Risikobehandlung ändert nicht die gegenwärtige technische Freigabe.

## 6. Technische Mindestregeln

1. Jeder Import erhält Quellenname, Quellversion, Dateihash und Importzeitpunkt.
2. Jeder normalisierte Datensatz behält die ursprüngliche NSL-ID.
3. Konvertierung und Alignment nennen die verwendete DCS-Kartenversion.
4. Bekannte Lücken der v1.0 werden sichtbar geführt.
5. Welterbestätten und kritische Energieinfrastruktur werden ergänzt oder als offene Schutzdatenlücke behandelt.
6. Automatische offensive Auftragserzeugung arbeitet bei fehlender oder fehlerhafter NSL-Prüfung `fail closed`.
7. Änderungen an Koordinaten, Kategorien, Schutzgeometrien oder Freigabestatus werden auditiert.
8. Die Runtime-Integration erfolgt MOOSE-first.
9. Jede verbleibende Nicht-MOOSE-Ergänzung benötigt eine dokumentierte technische Lücke und ausdrückliche Projektinhaberfreigabe.
10. Erst ein reproduzierbarer DCS-Test darf die Laufzeitfunktion als `ACCEPTED_TECHNICAL_BASELINE` kennzeichnen.

## 7. Verweise

- [`OMW-TARGETING-AFGHANISTAN-NSL – Fach- und Architekturdokument`](../48-afghanistan-no-strike-list.md)
- [`OMW-GOV-SOURCE-USE – zentrale Quellen- und Dateinutzung`](../sources/graveyard-of-empires.md)
- [`OMW-GOV-MOOSE-FIRST – verbindliche Entwicklungsrichtlinie`](../26-moose-first-development-policy.md)

## 8. Supersede-Regel

Frühere Aussagen, die für die NSL eine eigene parallele Quellen-/Lizenzautorität begründeten oder die Projektfreigabe an eine zusätzliche schriftliche Lizenz knüpften, sind ersetzt. Ebenso ersetzt sind Formulierungen, die aus dem Veröffentlichungszweck eine allgemein geltende Rechtslage ableiten.

Verbindlich ist ausschließlich:

1. die konkrete Projektentscheidung des Projektinhabers;
2. die zentrale Quellenregel `OMW-GOV-SOURCE-USE`;
3. diese technische NSL-Umsetzungsregel.
