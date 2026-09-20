# MultiDigi 8.5.2

**Correctif** pour les PC où le Tracker ferme le programme au démarrage, et message plus clair quand le CW ne peut pas
partir par la radio.

## Tracker
- **Disjoncteur** : MultiDigi note qu'il crée la carte web ; si le programme plante à ce moment-là, le lancement suivant
  ouvre le Tracker avec la **grille locale** (sans carte web) et l'explique dans un message, au lieu de replanter.
  Pour réessayer la carte web : supprimer le fichier `multidigi_map_crash.flag` (dossier utilisateur).
- Toujours : carte sans accélération GPU, journal `multidigi_crash.log`.

## CW / mode radio
- Le message « La radio est en mode CW » indique maintenant **pourquoi** le CW ne peut pas partir par la radio
  (aucun port CI-V enregistré, radio non Icom, BK-IN désactivé, port occupé, mode CW non confirmé…).
- Rappel : le CW par le manipulateur de la radio demande une **radio Icom** avec un **port CI-V** : connexion série
  directe, ou, avec HRD/FLRig/OmniRig, un **port COM CI-V libre vers la radio** enregistré dans RADIO CAT
  (ex. port auxiliaire de Win4Icom). Sans cela, le CW part en audio et la radio doit être en USB.

## Installation
Lance `MultiDigi_Setup_8.5.2.exe` : mise à jour par-dessus, réglages conservés.
