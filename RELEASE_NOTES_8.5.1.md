# MultiDigi 8.5.1

**Correctif de la 8.5.0** : chez certains OM, le mode radio ne changeait pas et le CW n'était plus envoyé.
La 8.5.0 changeait le mode et envoyait le CW par la radio sans pouvoir toujours le vérifier. La 8.5.1 ne fait plus rien
qu'elle ne puisse vérifier, et redevient comme avant sinon.

## Ce qui change
- **Deux options** dans Réglages → RADIO CAT → « Mode radio et CW » :
  - *Corriger le mode radio automatiquement* (coché) : ramène en USB une radio en CW, AM, FM ou RTTY, **seulement si la
    radio confirme** (liaison CI-V, OmniRig, FLRig). USB, LSB et DATA ne sont jamais modifiés. Avec HRD seul, MultiDigi ne
    touche plus au mode.
  - *CW par le manipulateur de la radio* (coché, Icom) : le morse est fabriqué par la radio si elle répond en CI-V, est
    confirmée en CW et a **BK-IN** activé (vérifié) ; sinon le CW part en audio.
- Le port du panneau RADIO CAT n'est ouvert que si l'option CW par le manipulateur est cochée, et un échec n'est plus retenté
  pendant 60 s.
- Si la radio est en CW et ne peut pas être passée en USB, l'émission audio est **refusée avec un message clair** au lieu de
  passer en émission sans morse.
- Journal `multidigi_radio.log` (dossier utilisateur) : ce que MultiDigi a décidé pour le mode radio et le CW.

## Rappel 8.5.0
Décodeur CW FIT (mots adaptatifs, lettres collées séparées, plus de « ? » parasites), port COM occupé nommé, Tracker sans
GPU + `multidigi_crash.log`.

## Installation
Lance `MultiDigi_Setup_8.5.1.exe` : mise à jour par-dessus, réglages conservés.
