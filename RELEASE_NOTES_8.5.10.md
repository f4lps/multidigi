# MultiDigi 8.5.10

## Fenêtre CW : waterfall où l'on voit les points et les traits
Même waterfall que CW Terminal 1.9.12. Chaque station est un trait vertical fin (environ 15 Hz à l'écran au lieu de 40 à
200 Hz), où les points et les traits apparaissent comme de petits tirets séparés.
- Une nouvelle ligne toutes les 11 ms environ, calculée sur un morceau d'audio adapté à la vitesse décodée (43 ms à 20 WPM).
- Réallocation spectrale : l'énergie de chaque signal est replacée à sa fréquence exacte. Deux stations proches restent
  séparées.
- Le trait vert est maintenant une ligne fine transparente avec un triangle en haut : il ne cache plus le signal.

## JS8 : une ligne par station, comme JS8Call
Un long message JS8 est envoyé en plusieurs trames. Avant, chaque trame occupait sa propre ligne dans « Band Activity ».
Maintenant, les trames d'une même station (même fréquence à ±10 Hz) se suivent sur une seule ligne, comme dans JS8Call :
« DL1ABC: F4LPS HELLO NICOLAS HOW ARE YOU TODAY BTU 73 ♢ ». Le losange ♢ marque la fin d'un message ; un nouveau
message de la même station s'ajoute à la suite. La ligne qui vient d'être mise à jour remonte en haut, l'indicatif reste
affiché même pour les trames de suite qui n'en portent pas, et l'info-bulle montre le message complet. Clic et double-clic
fonctionnent comme avant.

## Installation
Lance `MultiDigi_Setup_8.5.10.exe` : mise à jour par-dessus, réglages conservés.
