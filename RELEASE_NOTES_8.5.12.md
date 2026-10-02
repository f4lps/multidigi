# MultiDigi 8.5.12

## Sécurité : la radio repasse en réception si MultiDigi s'arrête pendant une émission
Si MultiDigi s'arrête brutalement pendant une émission (plantage Windows, « Fin de tâche »…), il ne peut plus rien
faire lui-même et la radio pouvait rester en émission. Désormais, au démarrage, MultiDigi lance un petit **gardien**
(une deuxième copie de MultiDigi.exe, invisible, qui ne fait qu'attendre). Si MultiDigi disparaît sans fermeture
normale, le gardien ouvre lui-même la liaison radio et la remet en réception, en une seconde environ :
- CAT Icom (CI-V) : arrêt du CW en cours + TX OFF ;
- CAT Yaesu (FT-891, FT-991A, FTDX10… et FT-817/857/897) : TX OFF ;
- HRD, FLRig, OmniRig : PTT relâché ;
- port CAT auxiliaire du CW natif : arrêt du CW + TX OFF.

À la fermeture normale, le gardien ne fait rien. Ce qu'il a fait est noté dans `%LOCALAPPDATA%\F4LPS\ptt_guard.log`.
Il ne remplace pas le minuteur d'émission (TOT) de la radio : garde-le activé.

## Cause du plantage du 2 octobre corrigée
MultiDigi s'est arrêté net en passant en émission (« access violation » dans la bibliothèque audio). Deux émissions
avaient été lancées presque en même temps (par exemple une réponse JS8 automatique et un clic) et ouvraient la carte son
au même instant, ce que la bibliothèque audio ne supporte pas.
- Une deuxième émission est refusée tant que la précédente n'est pas terminée.
- L'ouverture et la fermeture de la carte son ne se font plus jamais en même temps dans deux parties du programme.

## Correction
Au démarrage, le chargement des réglages s'interrompait sur les macros (« Chargement réglages PSK impossible ») : seule
la première macro était relue et l'identité de la station n'était pas mise à jour. Corrigé.

## Installation
Lance `MultiDigi_Setup_8.5.12.exe` : mise à jour par-dessus, réglages conservés.
