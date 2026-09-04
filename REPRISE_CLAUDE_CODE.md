# Reprise MultiDigi — 4 septembre 2026

## Fichier à utiliser

`MultiDigi_FINAL_JS8_20260904.py`

Cette copie est identique à la dernière version testée :
`MultiDigi_V97_TEST_NORMAL_FAST_MULTI.py`.

Ne pas modifier le fichier historique protégé
`MultiDigi_V96_CRC_TO_BAND_ACTIVITY_TRACE.py`.

## État fonctionnel

- RX JS8 NORMAL optimisé et affichage rapide des trames CRC valides.
- TX JS8 réel : Huffman DATA, CRC12, LDPC(174,87), Costas et 8-FSK.
- Trames structurées HB, CQ, CQ DX et commandes dirigées.
- Modes JS8 SLOW, NORMAL, FAST, JS8 40 et JS8 60.
- Prévalidation JS8 avant toute commande PTT.
- RSID désactivé pour JS8 afin de ne pas corrompre les directives structurées.
- Barre JS8 : HB, CQ, REPLY, SNR, INFO, STATUS, RR, ACK et 73.
- Réseau HB automatique avec intervalle de 1 à 60 minutes.
- Confirmation optionnelle avant émission automatique.
- ACK HB automatique limité à un ACK par indicatif toutes les 30 minutes.
- Bouton ARRÊT AUTO et réinitialisation HB/ACK sur OFF à chaque lancement.
- Le panneau DIAGNOSTIC RX est masqué mais les diagnostics internes restent actifs.
- Le bouton principal est nommé ÉMETTRE.
- Le Tracker propose le filtre JS8 dans Trafic mondial ; il regroupe toutes les variantes JS8.

## Sécurité radio

- Ne jamais lancer automatiquement un test qui commande le PTT.
- Les tests Python existants fabriquent seulement de l'audio en mémoire.
- Les automatismes HB et ACK doivent rester OFF au démarrage.
- L'utilisateur a confirmé avoir reçu des réponses à une émission JS8 réelle.

## Tests

- `test_js8_tx.py` : TX JS8, CRC/LDPC, trames structurées, cinq vitesses,
  protection RSID et reconnaissance JS8 du Tracker.
- `test_all_modems_smoke.py` : construction RX/TX et génération audio finie
  pour chaque variante enregistrée (PSK, Olivia, Contestia, DominoEX, RTTY,
  Hell, CW et JS8).
- Une suite complète de 55 tests avait réussi avant les derniers petits ajouts UI.
- Après les derniers ajouts : 10 tests ciblés JS8 réussis et smoke-test de tous
  les modems réussi.

Commandes conseillées sous Windows :

```powershell
$env:PYTHONIOENCODING='utf-8'
& 'C:\Program Files\Python311\python.exe' -m py_compile MultiDigi_FINAL_JS8_20260904.py
& 'C:\Program Files\Python311\python.exe' -m unittest test_js8_tx.py test_all_modems_smoke.py
```

## Points restant à améliorer

- Le scanner pleine bande priorise volontairement JS8 NORMAL pour préserver la
  sensibilité et la latence. Ne pas annoncer un vrai MULTI cinq vitesses tant
  que les performances réelles n'ont pas été validées.
- Tester en réception radio réelle les modes JS8 SLOW/FAST/40/60.
- Tester longuement Olivia, Contestia, DominoEX, RTTY et Hell sur signaux réels ;
  le smoke-test confirme leur construction et leur génération audio, pas leur
  sensibilité sur l'air.
- Vérifier le comportement réel du réseau HB et des ACK automatiques sur une
  période longue, avec puissance réduite et surveillance opérateur.
- Un lancement Qt hors écran a signalé un ancien avertissement rattrapé pendant
  le chargement des réglages : attribut `_macro_edits` pas encore créé. Cela ne
  bloquait pas l'interface, mais pourra être nettoyé.

## Référence protocole

Les paramètres JS8 et les formats structurés ont été portés depuis les sources
JS8Call/JS8Call-improved (Varicode, JS8Submode et constantes communes).
