# MultiDigi 8.5.0

## Nouveautés

### CW
- **Nouveau moteur de décodage « CW FIT »** (mode par défaut de la famille CW) : il ajuste le timing Morse sur le signal.
  Meilleur sur signaux faibles, QSB et manipulation à la main, silencieux sur du bruit.
- **Séparation des mots** adaptée à l'espacement réel de l'opérateur ; les lettres collées sont séparées ;
  plus de « ? » inventés.
- **CW envoyé par le manipulateur de la radio** (Icom, commande CI-V 0x17), comme CW Terminal : le morse est fabriqué
  par la radio (BK-IN requis). Repli en audio pour les autres radios.

### Radio
- **Mode radio automatique** : famille CW → la radio passe en CW ; toutes les autres familles → USB.
  Le changement est fait en CI-V et **vérifié par relecture** ; si la radio ne confirme pas, un message orange le dit.
- Connexion CAT plus claire : un port COM déjà utilisé est **attribué au logiciel fautif** (ex. « COM13 déjà utilisé par
  OmniRig.exe ») ; un port ouvert dont la radio ne répond pas s'affiche en orange.

### Tracker
- La carte s'affiche **sans accélération GPU** : évite la fermeture brutale du programme au démarrage du Tracker sur
  certains PC (pilote graphique). Pour réactiver le GPU : variable d'environnement `MULTIDIGI_MAP_GPU=1`.
- Journal de plantage `multidigi_crash.log` (dossier utilisateur) à joindre à un rapport de problème.

## Installation
Télécharger `MultiDigi_Setup_8.5.0.exe` et l'exécuter (aucun droit administrateur). La mise à jour se fait par-dessus la
version précédente ; les réglages sont conservés.

Guide de configuration radio (Icom, Yaesu, HRD) : [CAT_SETUP.md](CAT_SETUP.md).
