# AAR Core Fuel Planning Estimation – 14.08.2026

Diese Evidence-Notiz dokumentiert die vom Projektinhaber freigegebene Fortführung der bestehenden OMW-KC-135-Planungslogik für die drei bisher offenen Core-Areas `LISA`, `MOE` und `MILHOUSE`. Die bereits vorhandenen Werte für `KRUSTY`, `PATTY` und `NELSON` werden ausdrücklich nicht neu berechnet oder aufgerollt.

## Ausgangsbasis

Belegt sind die DCS-Seed-Werte der bestehenden KC-135-Templates:

- MANAS: 96 % = 87.072 kg = 191.961 lb;
- AL UDEID: 90 % = 81.630 kg = 179.963 lb;
- volle DCS-KC-135-Fuelmenge: 90.700 kg, entsprechend rund 199.959 lb.

Die historische AAR-Planung führt eigenständige Gate-to-Track-Verbrauchsabzüge. Aus den fünf vorhandenen Planungswerten lässt sich ein Planungsverbrauch von ungefähr 20 lb/NM mit hoher Sicherheit rekonstruieren. Eine wörtliche historische Definition dieser Konstante wurde in Repository, Commit-Historie oder PR-Diskussion nicht gefunden. Sie wird deshalb als `RECONSTRUCTED_PLANNING_METHOD` und nicht als historische Primärquellenangabe behandelt.

Für die drei offenen Core-Areas wird der Gate-to-Track-Anteil aus dem vorhandenen OMW-Origin-/Gate-Distanzmodell abgeleitet:

- MANAS -> North Gate: rund 300,0 NM;
- AL UDEID -> South Gate: rund 746,3 NM;
- LISA: 839,9 - 300,0 = rund 539,9 NM Gate-to-Track;
- MOE: 651,6 - 300,0 = rund 351,6 NM Gate-to-Track;
- MILHOUSE: 1022,3 - 746,3 = rund 276,0 NM Gate-to-Track.

Der geschätzte Transitverbrauch wird auf 100 lb als Planungswert gerundet:

- LISA: rund 10.800 lb;
- MOE: rund 7.000 lb;
- MILHOUSE: rund 5.500 lb.

Daraus folgen die geschätzten Fuel-at-Track-Werte:

- LISA: 181.161 lb / 82.173 kg;
- MOE: 184.961 lb / 83.897 kg;
- MILHOUSE: 174.463 lb / 79.135 kg.

## FuelLow-/Egress-Schätzung

Die bestehende Planungsserie verwendet area-/originabhängige ganze FuelLow-Prozentwerte. Die exakte ursprüngliche Reserveformel ist nicht mehr dokumentiert. Für die neuen Core-Areas wird deshalb die aus den bestehenden fünf Datensätzen rekonstruierbare Planung fortgeführt, ohne die vorhandenen Baseline-Werte neu zu berechnen.

Die verwendete Rekonstruktion ist:

```text
required_egress_fuel_lb ~= route_distance_basis_nm * 20 lb/NM + origin planning reserve
MANAS planning reserve ~= 30,000 lb
AL_UDEID planning reserve ~= 32,000 lb
fuel_low_pct = next whole percent of full DCS KC-135 fuel
```

Diese Rekonstruktion reproduziert die vorhandenen historischen Planungswerte für CLANCY/HOMER/KRUSTY/NELSON/PATTY und wird ausschließlich als OMW-Planungsschätzung fortgeführt. Daraus folgen:

- LISA / MANAS: 24 % -> 21.768 kg / 47.990 lb;
- MOE / MANAS: 22 % -> 19.954 kg / 43.991 lb;
- MILHOUSE / AL UDEID: 27 % -> 24.489 kg / 53.989 lb.

## Statusgrenze

Diese Werte sind `RECONSTRUCTED_PLANNING_ESTIMATE`. Sie sind keine Behauptung einer historischen KC-135-Performanceformel und keine neue DCS-Validierung. Die bestehende AAR-Mechanik-Acceptance bleibt unverändert; für diese reine Planungsfortschreibung ist kein neuer isolierter DCS-Test erforderlich.
