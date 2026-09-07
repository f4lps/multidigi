# Reprise MultiDigi — 7 septembre 2026

## Fichier à utiliser

`MultiDigi_FINAL_JS8_20260904.py` — version actuelle du code : **8.4.3**
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

## ✅ Résolu (7 sept 2026, session suivante) — CAT série ne remontait pas la fréquence

Cause réelle trouvée et corrigée en **8.4.3**, grâce au diagnostic ajouté
en 8.4.3-dev (voir historique git) : dans le panneau CAT **réellement
utilisé** par l'utilisateur (`_toggle_cat` du panneau intégré aux Réglages
PSK, vers la ligne ~29050), `addr = self._civ.currentText()` passait le
**texte affiché** du menu déroulant (`"0x94 (IC-7300)"`) tel quel comme
adresse CI-V à `connect_serial`, au lieu de l'entier `0x94`. Chaque commande
CI-V (`bytes([0xFE,0xFE,addr,...])`) levait donc une `TypeError` avant même
de partir sur le port série — d'où le silence total malgré un port/câble/
radio fonctionnels (confirmé par le diagnostic : `'str' object cannot be
interpreted as an integer`). L'autre panneau CAT (celui de l'écran
"Réglages généraux", `_toggle_cat` vers la ligne ~38500) faisait déjà la
conversion hex correctement — c'est pour ça que ce chemin-là n'était
peut-être jamais suspecté. Tout le travail précédent (DTR/RTS forcés,
timing, délais) n'était probablement pas la vraie cause, mais reste en
place (inoffensif, peut aider sur d'autres adaptateurs).

**Prochaine étape :** demander à l'utilisateur de retester en 8.4.3 (depuis
les sources ou un nouvel exécutable/installeur à publier) pour confirmer
que la fréquence s'affiche enfin. Si oui : reconstruire l'exécutable +
l'installeur (procédure ci-dessous) et publier la release 8.4.3.

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
