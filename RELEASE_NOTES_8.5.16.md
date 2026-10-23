# MultiDigi 8.5.16

## Recherche d'indicatif : plus d'indicatifs refusés à tort
- Les indicatifs dont le préfixe se termine par un chiffre étaient refusés (« Indicatif invalide ») et aucune recherche
  n'était lancée : Slovénie (S52AL), Bosnie (E73A), Macédoine du Nord (Z35T), Émirats (A61BK), Qatar (A71BX),
  Saint-Marin (T77C)… Ils sont maintenant acceptés et recherchés.
- Pour un indicatif avec préfixe de pays (EA8/F4XXX, F/DL1ABC), MultiDigi recherchait la partie avant la barre
  (« EA8 », « F »), donc sans résultat. Il recherche maintenant l'indicatif de l'opérateur (F4XXX, DL1ABC).

Rappel 8.5.15 : réponse JS8 aux indicatifs avec une barre oblique (SV2BBO/A…).

## Installation
Lance `MultiDigi_Setup_8.5.16.exe` : mise à jour par-dessus, réglages conservés.
