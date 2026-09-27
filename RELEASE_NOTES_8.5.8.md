# MultiDigi 8.5.8

## Décodage CW (moteur CW FIT) : comme CW Terminal
Le moteur de décodage de MultiDigi est le même que celui de CW Terminal. La différence venait de ce qui l'entoure. MultiDigi
reprend maintenant les deux mécanismes de CW Terminal :

- **Espaces propres.** Le texte CW est écrit mot par mot : plus jamais deux espaces de suite, et les lettres isolées que le bruit
  fabrique entre les mots (E, T, I, M, N) ne s'affichent plus. Les mots de deux lettres douteux sur un signal faible sont écartés, sauf
  les abréviations CW (TU, DE, 73, OM, CQ…). Chaque mot s'affiche quand il est terminé, comme dans CW Terminal.
- **Calage fin automatique.** Si ton clic tombe un peu à côté du signal, le décodeur rejoint tout seul le pic, dans une fenêtre de
  ±40 Hz autour du clic, en glissant doucement. Il ne part jamais sur une autre station, et il ne bouge pas sur du bruit. Un nouveau clic
  redevient la référence.

Mesures sur un vrai enregistrement de contest (3 minutes) : plus aucun double espace (7 à 10 avant), deux à trois fois moins de
lettres parasites, et le même texte avec un clic juste ou décalé de 30 Hz. Sur signaux de test : 2,0 % de caractères faux au lieu
de 2,9 %.

Les moteurs CW CLASSIC et CW NEXT, et tous les autres modes, ne changent pas.

## Installation
Lance `MultiDigi_Setup_8.5.8.exe` : mise à jour par-dessus, réglages conservés.
