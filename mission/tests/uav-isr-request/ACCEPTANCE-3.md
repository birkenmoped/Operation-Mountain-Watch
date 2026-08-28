# UAV ISR Acceptance 3 — Kandahar On-Station orbit

> **Status: A3-13 ist ein DCS-Testkandidat, keine Produktionsfreigabe.**
> A3-12 mit lokaler Retry-Queue ist verworfen. A3-13 übergibt jeden gültigen
> Auftrag unmittelbar an die MOOSE-AIRWING-Queue. Der vollständige Fehler- und
> Entscheidungsverlauf steht in
> [docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md](../../../docs/handoffs/2026-08-28-uav-isr-request-error-and-decision-register.md).

## Verbindlicher A3-13-Ablauf

1. Exakter BLUE-F10-Marker `UAV RECON` wird über das ISR-Cell-Menü eingereicht.
2. Der Dispatcher erzeugt einen `AUFTRAG:NewORBIT_CIRCLE` und ruft unmittelbar
   `AIRWING:AddMission(mission)` auf.
3. MOOSE hält den Auftrag in seiner AIRWING-Missionswarteschlange und entscheidet
   allein über verfügbare Assets, Start und Turnover.
4. Erst beim MOOSE-`Started`-Lifecycle wird CampaignState atomar reserviert und
   konsumiert.
5. Nach der MOOSE-physischen Rückkehr wird CampaignState gutgeschrieben.
   Eine CampaignState/MOOSE-Differenz führt zu einem sichtbaren
   `RECONCILIATION_REQUIRED`-Fall, einer MOOSE-Rückkehr und einer Sperre weiterer
   ISR-Dispatches; sie wird nicht durch eine lokale Retry-Queue kaschiert.

Profil: 25.000 ft MSL, 180 kt IAS, Kreisorbit über dem Marker;
`SetDuration(2700)` begrenzt die Zeit nach MOOSE-`Executing` auf 45 Minuten.

## Was dieser Build noch beweisen muss

- mehrere nachgelagerte Requests bleiben in der MOOSE-Queue und starten nach
  Rückkehr/Turnover automatisch;
- ein Bodenabbruch vor bestätigtem Takeoff wird physisch entfernt und erhält
  ausschließlich im dokumentierten Acceptance-Ausnahmefall keinen Turnover;
- ein echter Flug behält den regulären MOOSE-Turnover und zeigt die ungefähre
  Restzeit als Spielerhinweis;
- CampaignState und MOOSE stimmen bei physischem Start und Rückkehr überein;
- eine absichtlich herbeigeführte Differenz wird sichtbar gesperrt, nicht
  automatisch „korrigiert“.

## Narrow no-takeoff recall exception

MOOSE stellt öffentliche Cohort-Methoden `SetTurnoverTime`,
`GetRepairTime` und `IsRepaired`, aber keine öffentliche per-Asset-Methode
zur Turnover-Ausnahme bereit. Der direkte Zugriff auf das interne
`Asset.Treturned` bleibt deshalb nur eine eng begrenzte Acceptance-Ausnahme;
keine Produktionswartungspolitik. Die Recherchebasis und die lokale
`Moose.lua`-SHA-256
`e3b750921ee22cfb37dd1cec7549831a9165ffe64cd26be154b49e63e001a915`
sind im Fehlerregister festgehalten.

## Build

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build-uav-isr-request-acceptance-3.ps1
```

Ein erzeugter Hash belegt nur das Bundle. PASS erfordert die oben genannten
DCS-Beobachtungen mit denselben Request-IDs in Log und Spieleranzeige.
