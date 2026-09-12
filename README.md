# MultiDigi

Terminal radioamateur multi-modes numériques développé par **F4LPS**.

MultiDigi encode et décode plusieurs modes numériques HF/VHF directement
depuis la carte son (via l'interface radio), sans dépendre de logiciels
tiers pour le cœur du traitement du signal (Huffman, LDPC, CRC, Costas,
FSK/PSK réels).

## Modes supportés

- **PSK** — BPSK31, QPSK31, BPSK63, QPSK63, BPSK125, QPSK125
- **JS8** — SLOW, NORMAL, FAST, JS8 40, JS8 60 (Huffman DATA, CRC12,
  LDPC(174,87), Costas, 8-FSK, trames structurées HB/CQ/CQ DX/dirigées)
- **Olivia**, **Contestia**, **DominoEX**, **RTTY**, **Hell**, **CW**

## Fonctionnalités principales

- RX en continu avec détection automatique du centre, indicateur de
  verrouillage et diagnostic de signal
- TX réel avec prévalidation avant commande PTT
- Coloration du texte reçu (indicatifs, prénoms, CQ, RST, 73...) et
  surlignage des messages qui mentionnent votre propre indicatif
- Traduction du texte reçu à la demande, dans un panneau séparé (ne
  perturbe jamais la zone TX en cours de rédaction)
- Décodeur de langues (micro → reconnaissance vocale → traduction → TX)
- Réseau HB automatique JS8 avec ACK automatique (désactivés par défaut,
  redemandés à chaque lancement pour la sécurité radio)
- Log automatique du QSO quand une station vous répond en JS8
- Tracker intégré avec carte (QSO, callsigns entendus, trafic mondial)
- Export/import ADIF, intégration HRD, QRZ, eQSL, LoTW, PSK Reporter,
  WSJT-X (UDP)
- Trois thèmes d'interface : **Aluminium usé**, **Carbone**, **Néon**
- Vérificateur de mise à jour intégré (onglet À propos)

## Installation

### Option recommandée — installeur Windows

1. Va sur la page [Releases](../../releases) et télécharge le fichier
   `MultiDigi_Setup_X.Y.Z.exe` de la dernière version.
2. Lance l'installeur. Aucun droit administrateur n'est requis :
   l'installation se fait dans ton dossier utilisateur
   (`%LOCALAPPDATA%\MultiDigi`).
3. Lance MultiDigi depuis le raccourci créé (Menu Démarrer / Bureau).

### Option alternative — lancer depuis les sources Python

Nécessite **Python 3.11+** sur Windows.

```bash
pip install PyQt5 PyQtWebEngine numpy scipy pyaudio requests deep-translator SpeechRecognition
python MultiDigi_FINAL_JS8_20260904.py
```

## Configuration

Au premier lancement, ouvre **⚙ Réglages généraux** pour renseigner ton
indicatif, ton locator, tes réglages audio RX/TX, et éventuellement tes
identifiants HamQTH/QRZ/eQSL (stockés uniquement en local, jamais publiés).

## Configurer la radio (CAT) et HRD

Pour régler la connexion CAT avec ta radio Icom ou Yaesu (câble direct)
ou via Ham Radio Deluxe (pilotage + log automatique), suis le guide
[CAT_SETUP.md](CAT_SETUP.md).

## Sécurité radio

- Les automatismes (réseau HB, ACK) sont **désactivés par défaut** et le
  restent à chaque lancement — ils doivent être réactivés manuellement.
- Le programme prévalide toujours la trame avant toute commande PTT.
- Vérifie ta configuration CAT/PTT avant tout test en émission réelle.

## Mises à jour

Le programme vérifie automatiquement (silencieusement) s'il existe une
nouvelle version au démarrage, et propose de la télécharger. Tu peux
aussi vérifier manuellement via l'onglet **À propos → 🔄 Vérifier les
mises à jour**.

## Contact

F4LPS — developpement@lesf4.fr

---

*Logiciel libre pour radioamateurs. Aucune garantie n'est fournie ;
utilise-le sous ta propre responsabilité et dans le respect de la
réglementation applicable à ta licence radioamateur.*
