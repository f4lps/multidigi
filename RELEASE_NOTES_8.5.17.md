# MultiDigi 8.5.17

## Nouvel onglet SSTV
Les fréquences SSTV ont leur propre onglet « 📺 SSTV », à part des modes numériques : 80 m, 40 m, 20 m, 15 m, 10 m et
2 m (dont l'écoute de l'ISS). Un clic passe la radio dans le bon mode (LSB, USB ou FM) et sur la bonne fréquence.

## MultiDigi arrive sur Linux, et sur Mac en essai
- **Windows** : `MultiDigi_Setup_8.5.17.exe`, mise à jour par-dessus, réglages conservés.
- **Linux** (64 bits, Ubuntu 22.04 / Debian 12 ou plus récent) : `multidigi_8.5.17_amd64.deb`, ou
  `MultiDigi-8.5.17-linux-x86_64.tar.gz` pour les autres distributions.
- **Mac, EN ESSAI** : `MultiDigi-8.5.17-mac-arm64-essai.dmg` (Apple Silicon, M1 et suivants) ou
  `MultiDigi-8.5.17-mac-x86_64-essai.dmg` (Intel).

Installation sous Linux, puis déconnexion et reconnexion pour avoir accès aux ports série :

```
sudo apt install ./multidigi_8.5.17_amd64.deb
sudo usermod -aG dialout $USER
```

Sur Mac : le programme n'est pas signé par Apple. Au premier lancement, fais clic droit > Ouvrir, puis autorise le
micro : c'est lui qui donne accès à l'entrée audio de la radio.

**Important.** Les versions Linux et Mac démarrent et leurs fonctions ont été contrôlées sur ordinateur, mais elles
n'ont pas encore été essayées avec une vraie radio. Pour les premières émissions, utilise une charge fictive. La
version Mac est un essai : merci de signaler ce qui ne marche pas à developpement@lesf4.fr.

Absent hors Windows pour le moment : PSK Reporter, OmniRig. HRD fonctionne seulement à travers le réseau.

Rappel 8.5.16 : recherche d'indicatif, préfixes chiffrés acceptés (S52AL, E73A, A61BK…).
