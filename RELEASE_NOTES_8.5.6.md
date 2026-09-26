# MultiDigi 8.5.6

## HRD (Yaesu et autres radios) : émission plus fiable et diagnostic
- **Bouton d'émission retrouvé plus sûrement.** Le nom du bouton de HRD varie selon la radio. MultiDigi cherche d'abord un nom exact
  (TX, PTT, MOX, Transmit), puis un nom qui commence par TX / PTT en écartant les boutons voisins (TX Clarifier, TX Monitor, Tuner…).
  La liste des boutons est lue même si HRD la sépare par des points-virgules ou des retours à la ligne.
- **Commande d'émission vérifiée** : si HRD refuse la commande, MultiDigi réessaie une fois, pour l'émission comme pour le retour en
  réception (la radio ne doit pas rester en émission).
- **Journal de diagnostic** `multidigi_radio.log` (dossier utilisateur) : à la connexion, MultiDigi y note ce que HRD annonce (radio,
  version, mode, liste des boutons, bouton d'émission retenu) ; chaque émission y note le bouton utilisé et le résultat. En cas de
  problème avec une Yaesu et HRD, ce fichier dit exactement ce qui se passe.

## Rappel
8.5.5 : port du serveur IP de HRD détecté (HRD 6.8 : 7809, HRD 6.9 : autre).
8.5.4 : Yaesu en CAT direct (PTT `TX1;` / `TX0;`, DTR/RTS bas, 2 bits d'arrêt, modes `MD0x;`), JS8 (réponse aux HB avec le SNR, log
automatique vers le Tracker et les journaux cochés).

## Installation
Lance `MultiDigi_Setup_8.5.6.exe` : mise à jour par-dessus, réglages conservés.
