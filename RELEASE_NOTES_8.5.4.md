# MultiDigi 8.5.4  (BROUILLON — non publié)

## JS8
- **Réponse automatique à un HB avec le SNR reçu.** Quand « Réponse automatique aux HB reçus » est cochée, MultiDigi répond
  `INDICATIF: SNR -12` (commande JS8 « SNR », comme JS8Call : les réponses aux heartbeats utilisent SNR et non plus ACK), avec le
  rapport en dB avec lequel le HB a été décodé. Sans mesure exploitable, il retombe sur ACK. Une seule réponse par indicatif
  toutes les 30 minutes (inchangé) ; la confirmation avant envoi, si elle est cochée, affiche le SNR.
- **Log automatique = logs cochés + Tracker.** Avec « Log auto QSO quand on me répond » (JS8), le contact est enregistré dans le
  **Tracker** ET envoyé à **tous les journaux cochés** de « Logger le QSO » (HRD, N1MM+, DXLog, Win-Test, WinRef, Log32,
  Log4OM, WaveLog, ClubLog, eQSL, LoTW, QRZ.com), avec les réglages déjà mémorisés. Le résultat (envoyé à…, erreur éventuelle par
  journal) s'affiche dans l'encart « AUTOMATISMES JS8 » et dans `multidigi_radio.log`. Mode ADIF : `MFSK` / `JS8` pour QRZ.

## Yaesu (CAT direct)
- **`RX;` n'existe pas chez Yaesu** : la radio restait en émission après le PTT. Maintenant `TX1;` puis `TX0;`, avec relecture de
  l'état d'émission et nouvel essai si la radio reste en émission.
- **DTR et RTS restent bas à l'ouverture du port** (pyserial les levait par défaut : émission dès CONNECTER sur les interfaces où
  RTS est le PTT), y compris pendant « Auto-détecter le port ».
- **2 bits d'arrêt**, **recherche de la vitesse** (38400 / 4800 / 9600 / 19200 / 115200 : la vitesse trouvée est reprise), radio
  identifiée par `ID;`.
- **Mode lu et changé par `MD0x;`, toujours vérifié** : CW, AM, FM, RTTY ramenés en DATA-USB pour les modes audio ; USB, LSB et DATA
  ne sont jamais modifiés.
- Ancien protocole binaire (FT-847/857/897) : PTT `08` / `88` (et non `0F`).
- Erreurs de PTT non plus avalées : tout dans `multidigi_radio.log`. Guide `CAT_SETUP.md` : nouvelle section Yaesu.

## Rappel
Version 8.5.3 : le Tracker ne fige plus à l'ouverture avec un long journal.
