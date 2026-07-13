# ADR 0006 – Virtualisierte rote Zwischenstellungen und vorbereitete Strongpoints

- Status: Accepted
- Date: 2026-07-13

## Context

Rote Kräfte sollen sich glaubwürdig in Dörfern, Städten, Compounds, Wadis, Baumreihen und Gebirgsräumen verbergen. DCS bietet keine allgemein belastbare Projektannahme, nach der Infanterie beliebige Scenery-Gebäude automatisch betreten, Räume besetzen und aus Fenstern kämpfen kann.

Dauerhaft sichtbare Infanteriegruppen in jeder Siedlung wären taktisch unglaubwürdig und würden die Serverleistung belasten. Bewaffnete Häuser oder ähnliche Assets können vorbereitete Stellungen darstellen, würden bei flächendeckender Verwendung jedoch Gegner verraten und erheblichen Missionseditor-Aufwand erzeugen.

## Decision

Ruhende und nicht beobachtete rote Kräfte werden grundsätzlich virtualisiert.

- Spielrelevante Siedlungen erhalten ein Register geprüfter Hide Sites und Fluchtwege.
- Der `ConcealmentManager` wählt geeignete Hide Sites, reserviert sie und steuert Materialisierung und Dematerialisierung.
- Materialisierung erfolgt nur an geprüften, gedeckten und nicht direkt beobachteten Positionen.
- Operativer Zellzustand und physischer Concealment-Zustand werden getrennt gespeichert.
- Beliebige Scenery-Häuser gelten nicht als automatisch begehbar oder garnisonierbar.
- Durchsuchungen werden als Kampagnenprozess mit mehreren möglichen Ergebnissen modelliert.
- Bewaffnete Häuser oder ähnliche Assets werden nur für ausgewählte, vorbereitete Strongpoints verwendet.
- Strongpoints bleiben mit Personal, Munition und Wirkung im CampaignState verknüpft.

## Consequences

### Positive

- Rote Kräfte stehen nicht unglaubwürdig offen in Siedlungen.
- Große Teile der gegnerischen Präsenz können ohne permanente physische Gruppen simuliert werden.
- Aufklärung, Durchsuchung, Flucht und überraschender Kontakt werden spielerisch abbildbar.
- Materialisierung kann an Deckung, Sichtlinie und Missionslage angepasst werden.
- Bewaffnete Häuser bleiben besondere taktische Ziele statt generischer Gegnerindikatoren.
- Persistenz benötigt keine flüchtigen DCS-Gruppennamen oder Innenraumzustände.

### Negative

- Hide Sites und Fluchtwege müssen im Mission Editor geprüft werden.
- Sichtlinien- und Materialisierungslogik benötigen sorgfältige Tests.
- Hausdurchsuchungen bleiben abstrahiert und sind kein echter Innenraumkampf.
- Strongpoints erfordern zusätzliche Assets, Templates und Balancing.
- Sichtbares Pop-in kann nur reduziert, nicht unter allen Umständen mathematisch ausgeschlossen werden.

## Rules

- Keine Annahme einer generischen Gebäudeinnenraum-Navigation.
- Keine dauerhaft aktive Infanterie in jedem Dorf.
- Keine Materialisierung auf direkt beobachteten oder offenen Positionen.
- Jede produktive Hide Site besitzt stabile ID, Zone, Kapazität, Rollen und mindestens einen geprüften Ausweg.
- Operativer Zellzustand und Concealment-Zustand bleiben getrennt.
- Bewaffnete Häuser werden nur als explizite Strongpoints eingesetzt.
- Ein Strongpoint erzeugt kein unabhängiges Personal oder Munition.
- Durchsuchungsergebnisse werden aus CampaignState, Intelligence und Suchbedingungen abgeleitet.
- Überlebende dürfen erst nach Kontaktende, ausreichender Entfernung und fehlender Beobachtung wieder virtualisiert werden.
- Vollständige Innenraum- und Zivilsimulation ist nicht Bestandteil des ersten Prototyps.
