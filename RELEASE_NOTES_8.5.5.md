# MultiDigi 8.5.5

## HRD 6.8 / 6.9 : le port du serveur IP est détecté
Le serveur IP de HRD écoute sur le port **7809 avec HRD 6.8**, mais sur **un autre port avec HRD 6.9**. Quand le port du champ ne
répond pas, MultiDigi lit maintenant le port sur le processus HRD (`HamRadioDeluxe.exe`), puis essaie les ports usuels, se connecte,
**remet le champ à jour** et mémorise le bon port. Si HRD écoute mais ne répond pas, le message le dit (la radio est-elle connectée
dans HRD ?) ; si HRD est absent, le message rappelle de vérifier que le serveur IP est activé.

## Rappel des versions précédentes
8.5.4 : Yaesu (PTT `TX1;` / `TX0;`, DTR/RTS bas à l'ouverture, 2 bits d'arrêt, modes `MD0x;`), JS8 (réponse aux HB avec le SNR,
log automatique vers le Tracker et les journaux cochés en arrière-plan, RST = SNR, macro 73+Log), correctif WaveLog.

## Installation
Lance `MultiDigi_Setup_8.5.5.exe` : mise à jour par-dessus, réglages conservés.
