# Reprise MultiDigi — 7 septembre 2026

## Fichier à utiliser

`MultiDigi_FINAL_JS8_20260904.py` — version actuelle du code : **8.4.2**
(constante `PROGRAM_VERSION_TAG` en haut du fichier).

## Dépôt GitHub

- **Dépôt :** https://github.com/f4lps/multidigi (compte GitHub : F4LPS,
  email nicolas.pouchain0426@orange.fr)
- Le code source (`main`) est toujours poussé à jour à la fin de chaque
  session de correctifs — vérifier `git log` pour voir les derniers commits.
- **Releases publiées avec installeur Windows :**
  - `v8.3.14` — première release (asset : le `.py` brut, avant l'installeur)
  - `v8.4.0` — premier installeur Windows (189 Mo, avec console de debug)
  - `v8.4.1` — traducteur + PTT Yaesu + suppression de la fenêtre console
    (145 Mo)
  - **`v8.4.2` — corrections RSID CW / persistance réglages CAT+HRD —
    codé et poussé sur GitHub, MAIS PAS ENCORE publié comme release avec
    installeur.** Le dernier commit (diagnostic CAT série, voir plus bas)
    n'a pas non plus de release.

## ⚠️ Dossier en cours — CAT série ne remonte pas la fréquence

Un utilisateur connecte MultiDigi en CAT série direct sur un port
**"ELTIMA Virtual Serial Port" (COM11)**, protocole Icom CI-V, 0x94
(IC-7300), 57600 bauds. Le port s'ouvre ("connecté") mais **aucune
fréquence ne s'affiche** (`get_frequency()` renvoie 0). Point clé donné par
l'utilisateur : **son autre logiciel "CW Terminal" (aussi de lui, F4LPS)
fonctionne en CAT direct sur ce même port** — donc le port lui-même est
fonctionnel, le bug est probablement dans notre séquence CI-V ou son timing,
pas dans le pont série virtuel.

Déjà tenté (dans `RadioController.connect_serial` / `_icom_get_freq`,
classe vers la ligne ~26400 du fichier) :
- DTR/RTS forcés à `True` à l'ouverture du port.
- Délai de stabilisation de 0.3s après ouverture avant le premier échange.
- 4 essais espacés de 0.3s au lieu de 2.
- Délai d'attente de réponse augmenté (0.25→0.35s Icom, 0.1→0.2s Yaesu).
- **Diagnostic ajouté** : `_icom_get_freq_debug()` renvoie aussi les octets
  bruts reçus ; si la lecture échoue, le message de connexion affiche soit
  "aucun octet reçu" soit "réponse reçue mais illisible : xx xx xx..."
  (hexdump), pour savoir si le silence est total ou si quelque chose répond
  mais mal interprété (mauvaise adresse CI-V, écho seul, bruit...).

**Prochaine étape impérative :** demander à l'utilisateur de relancer
`MultiDigi_FINAL_JS8_20260904.py` depuis les sources (pas encore
reconstruit en exécutable), se reconnecter en CAT série, et donner le
message exact affiché. Corriger en fonction de ce retour, puis reconstruire
l'exécutable + l'installeur (voir procédure ci-dessous) et publier une
nouvelle release.

## Fonctionnalités ajoutées / corrigées cette session (4-7 sept 2026)

- **Thèmes d'interface** : Aluminium usé (par défaut), Carbone, Néon
  (original) — sélecteur dans ⚙ Réglages généraux.
- **Traduction RX** à la demande (panneau séparé, ne touche jamais la zone
  TX) — bug corrigé : `deep_translator` renvoyait parfois une page d'erreur
  Google comme si c'était une traduction valide ; le code bascule
  maintenant sur la méthode de secours (testée, fonctionne).
- **Surlignage RX** : fond rouge sur les messages qui mentionnent notre
  indicatif (façon JS8Call).
- **Log auto JS8** quand une station répond (case à cocher, auto ET manuel
  via le bouton "73 + LOG" déjà existant).
- **Vérificateur de mise à jour intégré** (onglet À propos) — interroge les
  releases GitHub, propose le téléchargement.
- **Compteur de téléchargements** (onglet À propos, visible pour tous).
- **RSID supprimé pour CW** (comme pour JS8) — il s'insérait avant chaque
  message CW ("[RSID] CW NEXT").
- **PTT/fréquence Yaesu en CAT série directe** : n'existaient pas du tout
  avant (seule la lecture de fréquence marchait) — ajoutés
  (`_yaesu_set_freq`, `_yaesu_ptt_on/off`, protocole CAT 5 octets standard).
- **Réglages RADIO CAT jamais mémorisés** (port COM, baud, protocole, CI-V,
  hôtes/ports HRD et FLRig, rig OmniRig) — persistés maintenant dans
  `self._cat_settings` (clé JSON `cat_settings`).
- **Identifiants HRD Logbook** (IP/port dans "LOG QSO + Loggers" → onglet
  HRD) jamais mémorisés — persistés dans `_logbook_settings`.
- **Bouton "🔍 Auto-détecter le port"** dans le panneau RADIO CAT — teste
  chaque port série disponible en lecture seule (jamais d'émission).
- **Fenêtre console supprimée** de l'exécutable (`--windowed` au lieu de
  `--console`) — a nécessité d'ajouter un filet de sécurité
  `sys.stdout`/`sys.stderr` (None en mode fenêtré, des milliers de `print()`
  dans le code auraient fait planter le programme).
- **README.md** complet ajouté au dépôt GitHub.
- **Numéros de version incohérents** dans tout le programme (splash,
  titres de fenêtre, écran À propos) — tous basés maintenant sur
  `PROGRAM_VERSION_TAG`.

## Outillage installeur Windows (PyInstaller + Inno Setup)

- **Icône** : `installer/multidigi.ico` (générée avec `installer/make_icon.py`,
  badge sombre + signal radio dégradé magenta→cyan).
- **Script Inno Setup** : `installer/MultiDigi.iss` — installe dans
  `%LOCALAPPDATA%\MultiDigi` (aucun droit admin requis), penser à mettre
  à jour `MyAppVersion` avant chaque nouvelle release.
- **`installer/Output/`** contient l'installeur compilé — **jamais commité**
  (gitignore), à uploader manuellement sur la release GitHub.
- PyInstaller et Inno Setup 6 sont déjà installés sur cette machine.

### Commande de reconstruction complète (copier-coller)

```powershell
cd "C:\Users\14frs\Documents\radio\miltidigi"
Remove-Item -Recurse -Force build, dist, "installer\Output" -ErrorAction SilentlyContinue

& 'C:\Program Files\Python311\python.exe' -m PyInstaller --name MultiDigi --onedir --windowed --noconfirm `
  --icon "installer\multidigi.ico" `
  --exclude-module tensorflow --exclude-module tensorflow_intel --exclude-module tensorflow_io_gcs_filesystem `
  --exclude-module keras --exclude-module matplotlib --exclude-module PIL --exclude-module av `
  --exclude-module ctranslate2 --exclude-module onnxruntime --exclude-module click --exclude-module hf_xet `
  --exclude-module huggingface_hub --exclude-module transformers --exclude-module torch `
  --exclude-module IPython --exclude-module jupyter --exclude-module notebook --exclude-module pandas `
  --exclude-module sklearn `
  MultiDigi_FINAL_JS8_20260904.py

& 'C:\Program Files (x86)\Inno Setup 6\ISCC.exe' "installer\MultiDigi.iss"
```

⚠️ **Cette construction est très lente** (souvent 30-90 minutes réelles,
même si le journal PyInstaller n'avance parfois pas pendant de longues
minutes sur les hooks PyQt5/QtWebEngine/QtQml — c'est normal, pas bloqué,
vérifier le temps CPU du processus `python.exe` avec `tasklist` avant de
relancer). Toujours tester l'exe généré (`dist\MultiDigi\MultiDigi.exe`)
avant de compiler l'installeur.

Modules exclus car entraînés par erreur (dépendances transitives jamais
utilisées par le code) : tensorflow, matplotlib, PIL, av/ffmpeg,
ctranslate2, onnxruntime, torch, etc. — sans eux, le dossier `dist` passe
d'environ 614 Mo à 442 Mo.

### Procédure de publication d'une release

1. Mettre à jour `PROGRAM_VERSION_TAG` (haut du fichier .py) ET
   `MyAppVersion` (`installer\MultiDigi.iss`) — même numéro.
2. `git commit` + `git push`.
3. Reconstruire (commande ci-dessus).
4. Tester l'exe (`dist\MultiDigi\MultiDigi.exe`), vérifier le titre de
   fenêtre et l'absence de plantage.
5. Aller sur https://github.com/f4lps/multidigi/releases/new (⚠️ si le tag
   existe déjà, GitHub refuse — éditer la release existante plutôt via
   `/releases/edit/vX.Y.Z`).
6. Glisser `installer\Output\MultiDigi_Setup_X.Y.Z.exe` dans les assets.
7. Publier — je n'ai pas accès au compte GitHub, cette étape doit être
   faite manuellement par l'utilisateur (je peux ouvrir la page pour lui
   dans le navigateur).

## Sécurité radio (toujours valable)

- Ne jamais lancer automatiquement un test qui commande le PTT.
- Les automatismes HB et ACK JS8 restent désactivés par défaut à chaque
  lancement.
- Le CAT auto-détection (bouton) ne fait que des lectures, jamais de PTT.

## Points restants à vérifier / améliorer

- **CAT série direct sans réponse radio** (voir section dédiée en haut).
- Vérifier la connexion HRD réelle (l'utilisateur confirme qu'elle
  fonctionne, mais pas testée par Claude directement).
- Les macros ont été relues (code correct), pas testées en conditions
  réelles par l'utilisateur.
- Tester en réception radio réelle les modes JS8 SLOW/FAST/40/60.
