# TF Phoenix / Bagram - Quellenaddendum 2010-2011

## Quellenautorität

Primärer Juli-2011-Snapshot:

- `122362406-Afghanistan-order-of-battle-july-2011.pdf`;
- Wesley Morgan, *Afghanistan Order of Battle - Coalition Combat Forces in Afghanistan*, July 2011.

Zeitgenössische Ergänzungen:

- `pdf_7936.pdf`, *Falcon Flyer*, October/November 2010;
- `pdf_8886.pdf`, *Eye of the Falcon*, May 2011;
- DVIDS, `One Falcon to Another: 10th CAB takes control of RC-East aviation operations`;
- U.S. Army, `Task Force Phoenix supports largest air assault in RC-East`.

## Verbindlicher Bagram-Befund

```yaml
TF_Phoenix:
  lead_unit: 3-10 General Support Aviation Battalion
  base: Bagram Airfield
  status: confirmed
  organization: multifunctional task force with organic and attached companies
```

TF Phoenix darf nicht als unveränderte Friedensgliederung des 3-10 GSAB modelliert werden.

## UH-60

`pdf_7936.pdf` belegt einen TF-Phoenix-UH-60 am 23. November 2010 auf Bagram Airfield.

```yaml
UH60_utility:
  Bagram_presence: confirmed
  exact_company: unresolved
  exact_local_inventory: unresolved
```

Eine exakte Stückzahl darf nicht allein aus einer GSAB-MTOE oder einem einzelnen Bild abgeleitet werden.

## Army MEDEVAC und USAF Rescue

`pdf_7936.pdf` belegt C Company, 3-10 GSAB als nach Afghanistan verlegte Medical Evacuation Unit.

Sie ist getrennt zu führen von:

```text
83rd Expeditionary Rescue Squadron
HH-60G
Bagram Airfield
```

```text
C/3-10 GSAB Army MEDEVAC != 83rd ERQS USAF HH-60G
```

## CH-47-Companies

Belegt sind unterschiedliche Pools:

- B/3-10 Aviation: im März 2011 aus TF Phoenix herausgelöst und TF Shooter/FOB Fenty zugeteilt;
- B/1-168 Aviation: an TF Phoenix angegliedert und von Bagram eingesetzt;
- B/7-158 Aviation: separater 25-Aircraft-Einsatzpool mit eigener OMW-Rekonstruktion.

Die 13 Bagram-CH-47 aus der OMW-Verteilung `13/6/6` beziehen sich ausschließlich auf B/7-158 Aviation und nicht auf den gesamten CH-47-Bestand Bagrams.

## Weitere Bagram-Pools

Die zeitgenössische May-2011-Publikation führt getrennt:

- TF Phoenix;
- TF Eagle;
- TF ODIN-A;
- TF Taeguek.

Diese Elemente dürfen weder organisatorisch noch bestandsmäßig zusammengezogen werden.

## Bestandsregel

```text
assigned inventory != aircraft visible on ramp
transient aircraft != local inventory
attached company != organic company
company letter alone != unique unit identity
```
