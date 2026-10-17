# MultiDigi 8.5.15

## JS8 : réponse aux indicatifs avec une barre oblique (SV2BBO/A, F/DL1ABC, EA8/F4XXX…)
MultiDigi refusait de répondre à ces indicatifs : les commandes dirigées (SNR, ACK, 73, réponse automatique à un HB…)
ne savaient compacter que les indicatifs simples, et l'émission n'avait pas lieu (« Indicatif JS8 non compactable »).

Comme JS8Call, la commande part maintenant en deux trames : la première porte ton indicatif, la seconde l'indicatif
complet du correspondant et la commande. Le correspondant lit par exemple « F4LPS: SV2BBO/A SNR -12 ». Cela marche
aussi quand c'est ton indicatif qui a une barre oblique (F4LPS/P vers SV2BBO/A, ou SV2BBO/A vers F4LPS).

Avec des indicatifs simples, rien ne change (une seule trame).

## Installation
Lance `MultiDigi_Setup_8.5.15.exe` : mise à jour par-dessus, réglages conservés.
