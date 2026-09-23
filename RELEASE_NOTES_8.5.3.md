# MultiDigi 8.5.3

**Correctif : le Tracker ne fige plus l'interface à l'ouverture** (message Windows « ne répond pas », obligé de relancer
le programme).

## Cause
À l'ouverture, le Tracker recharge tout le journal des contacts. Le tableau recalculait son défilement **après chaque
contact** : avec un journal de quelques milliers de contacts, l'ouverture prenait des dizaines de secondes (3 000 contacts :
21 s ; 20 000 contacts : plusieurs minutes), ce que Windows signale comme « ne répond pas ». Un OM actif, avec un long
historique, était touché ; un journal court ne l'était pas.

## Correctif
Le défilement est regroupé en un seul, après le chargement. Mesures : 3 000 contacts **21 s → 0,9 s** ; 20 000 contacts
**2,9 s** ; journal court inchangé.

## Note
Le fichier-témoin de la carte web s'appelle maintenant `multidigi_map_crash2.flag` : un ancien témoin laissé par un gel de
la 8.5.2 n'empêche plus la carte de s'afficher.

## Installation
Lance `MultiDigi_Setup_8.5.3.exe` : mise à jour par-dessus, réglages et journal conservés.
