# MultiDigi 8.5.7

## Yaesu + HRD : comme CW Terminal
- **Mode de la radio réglé par HRD.** Avec une Yaesu reliée par HRD, MultiDigi lit le mode de la radio. Pour les modes numériques
  (FT8, JS8, PSK…), il la passe en **DATA-U** si elle n'est pas déjà dans un mode audio, puis relit le mode pour vérifier. Si HRD ne
  connaît pas DATA-U pour cette radio, il essaie d'autres noms et, en dernier recours, **USB**. Avant, MultiDigi ne changeait jamais le
  mode par HRD : une Yaesu restée en CW passait en émission sans rien envoyer.
- **Jamais de commandes Icom vers une Yaesu.** Si le protocole du panneau RADIO CAT est resté sur « Icom » (le réglage par défaut),
  MultiDigi pouvait ouvrir un port de la radio pour y envoyer des trames CI-V (Icom). Il ne le fait plus quand HRD annonce une Yaesu.
- Rappel 8.5.6 : bouton d'émission de HRD trouvé par son nom exact (TX, MOX, PTT), comme dans CW Terminal ; CW par la ligne DTR du port
  « Standard ». Les versions 8.5.5 et antérieures pouvaient appuyer sur un autre bouton de HRD (par exemple celui du clarifier) : la
  radio ne passait pas en émission.

## Corrections
- **LoTW** : l'envoi échouait à chaque fois (« name 'shutil' is not defined »). Il fonctionne. Le mot de passe TQSL n'est plus affiché
  en clair dans la console.
- **Tracker** : la saisie manuelle d'un QSO et les sauvegardes automatiques du fichier de données (avant nettoyage, avant recalage)
  échouaient. Corrigé.
- **Tracker, recherche du nom des stations (QRZ, HamQTH, HamDB, Callook)** : quand un service trouvait le nom, une erreur le faisait
  perdre et la station restait « sans nom » (rien n'était mis en cache). Corrigé.

## Si ta Yaesu ne marche toujours pas avec HRD
Envoie-moi le fichier `multidigi_radio.log` de ton dossier utilisateur (`C:\Users\<toi>`). À la connexion, MultiDigi y note ce que HRD
annonce (radio, mode, boutons) et le bouton d'émission choisi ; à chaque changement de mode, ce qui a été tenté et le résultat.

## Installation
Lance `MultiDigi_Setup_8.5.7.exe` : mise à jour par-dessus, réglages conservés.
