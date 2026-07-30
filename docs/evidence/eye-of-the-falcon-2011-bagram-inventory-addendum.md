# Bagram 2011 aviation source addendum

## Inherited authority

This branch inherits the project-wide source policy for:

```text
122362406-Afghanistan-order-of-battle-july-2011.pdf
```

and the central first-party source record:

```text
docs/evidence/source-records/10th-cab-eye-of-the-falcon-2011-source-record.md
```

## Utility UH-60 correction

The June 2011 `Eye of the Falcon` (`pdf_8984.pdf`) directly identifies:

```text
A Company, 1st Battalion, 169th General Support Aviation Regiment
Task Force Phoenix
UH-60 Black Hawk
```

The documented 11 June mission operated in the Bagram/Parwan support area. Therefore the Bagram Utility-UH-60 company is no longer to be described only as an unidentified or generic `3-10 GSAB UH-60` element.

Binding branch interpretation:

```yaml
Bagram_UH60_Utility:
  unit: A Company, 1-169 Aviation Regiment
  attached_to: Task Force Phoenix
  aircraft_family: UH-60 Black Hawk
  exact_inventory: unresolved
```

TF Phoenix / 3-10 GSAB remains the command umbrella. A/1-169 is the directly evidenced flying company.

## Army MEDEVAC

The January, February, April, July and August 2011 brigade publications identify:

```text
C Company, 3-10 Aviation Regiment
Mountain Dustoff
UH-60 MEDEVAC
```

The company operated throughout RC-East and had a documented FOB Shank assignment/relationship. Missions also used FOB Fenty/Jalalabad for forward treatment and patient transfer.

Therefore:

```text
TF Phoenix administrative association
!= all Mountain Dustoff aircraft permanently based at Bagram
```

No complete Mountain Dustoff aircraft count may be added to the Bagram logical inventory without a date-specific basing source.

## USAF HH-60G remains separate

```text
83rd Expeditionary Rescue Squadron
HH-60G
Bagram Airfield
```

is a separate USAF personnel-recovery pool. It must not be merged with Army Mountain Dustoff in ORBAT, AIRWING, SQUADRON, warehouse or loss accounting.

## Task Force Mountain Eagle

The April 2011 `Eye of the Falcon` (`pdf_8632.pdf`) states that brigade avionics supported more than 170 aircraft across OH-58, AH-64, UH-60 and CH-47 families.

This is a brigade-wide RC-East maintenance workload:

```text
over 170 supported aircraft
!= Bagram aircraft inventory
!= TF Phoenix aircraft inventory
```

## Current Bagram inventory status

```yaml
UH60_Utility:
  unit_identity: resolved
  unit: A/1-169 AVN attached to TF Phoenix
  exact_count: open

Army_MEDEVAC:
  unit_identity: resolved
  unit: C/3-10 AVN Mountain Dustoff
  physical_distribution: distributed_RC_East
  Bagram_count: open

USAF_HH60G:
  unit_identity: resolved
  unit: 83rd ERQS
  exact_count: open
```

This addendum supersedes branch text that describes the Bagram Utility-UH-60 company as wholly unidentified.