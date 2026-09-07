# Reprise MultiDigi — 7 septembre 2026 (fin de session)

## Fichier à utiliser

`MultiDigi_FINAL_JS8_20260904.py` — version actuelle du code : **8.4.5**
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
  - `v8.4.2` et `v8.4.3-dev` (diagnostic CAT) — jamais publiées comme
    releases séparées (directement remplacées par 8.4.3).
  - **`v8.4.3`** — corrige la cause réelle du silence CAT série (adresse
    CI-V jamais convertie en entier). ⚠️ Publiée d'abord avec un tag erroné
    `v4.8.3` (chiffres inversés à la saisie) + mauvais fichier joint
    (`MultiDigi.exe` seul au lieu de l'installeur) → supprimée et
    republiée correctement. **Toujours vérifier après publication** avec :
    `curl -s https://api.github.com/repos/f4lps/multidigi/releases/latest`
    (voir tag_name et assets) avant de considérer une release comme bonne.
  - **`v8.4.4`** — première tentative de correctif du ralentissement CAT
    série (verrouillage des accès port + pause du sondage pendant le PTT).
    Insuffisante : le vrai problème était ailleurs (voir 8.4.5).
  - **`v8.4.5`** (dernière, actuelle) — corrige la cause réelle du
    ralentissement RX/TX en CAT série direct (CPU saturé en continu).
    Vérifiée correcte via l'API (tag `v8.4.5`, un seul asset
    `MultiDigi_Setup_8.4.5.exe` 139 Mo) et testée en direct sur la machine
    de l'utilisateur (CPU retombe de ~90% à ~1-2% une fois connecté).

## ✅ Résolu — CAT série ne remontait pas la fréquence (→ 8.4.3)

Cause réelle : dans le panneau CAT **réellement utilisé** par
l'utilisateur (`_toggle_cat` du panneau intégré aux Réglages PSK, vers la
ligne ~29050), `addr = self._civ.currentText()` passait le **texte
affiché** du menu déroulant (`"0x94 (IC-7300)"`) tel quel comme adresse
CI-V à `connect_serial`, au lieu de l'entier `0x94`. Chaque commande CI-V
levait donc une `TypeError` avant même de partir sur le port série — d'où
le silence total malgré un port/câble/radio fonctionnels. Corrigé en
extrayant l'entier hexa comme le fait déjà l'autre panneau CAT (celui de
"Réglages généraux", `_toggle_cat` vers la ligne ~38500).

## ✅ Résolu — Ralentissement RX/TX en CAT série direct (8.4.4 insuffisante → vraie cause en 8.4.5)

Signalé juste après la 8.4.3 : "ça rame en réception et émission", mais
confirmé par l'utilisateur comme **spécifique au CAT série direct**
(jamais avec HRD, qui passe par le réseau).

**Tentative 8.4.4 (insuffisante) :** hypothèse initiale = contention entre
le thread de sondage fréquence (`_FreqPollThread`, toutes les 3s) et les
actions PTT/QSY/changement de mode, qui écrivaient toutes sur le port
série sans synchronisation cohérente. Correctifs appliqués (gardés, restent
corrects et utiles) : toutes les écritures série passent par
`RadioController._lock`, et un flag `_tx_active` fait sauter le sondage
fréquence pendant une émission. **N'a pas suffi** : l'utilisateur a
continué de signaler le ralentissement après mise à jour en 8.4.4.

**Vraie cause trouvée en 8.4.5**, par mesure CPU en direct sur la machine
de l'utilisateur (accès complet à sa machine dans cette session — toujours
privilégier une mesure réelle `Get-Process ... CPU` à une hypothèse quand
c'est possible) : dès que le CAT série est connecté, le processus
consommait **~90% d'un cœur CPU en continu** (pas des pics ponctuels),
retombant à ~1-3% à la déconnexion. Cause : `RadioController.
_icom_get_freq_debug` (et les autres lectures série) appelaient
`serial_port.read(n)` avec un `timeout` pyserial — mais sur le pont série
virtuel de l'utilisateur (Eltima), ce timeout n'était visiblement pas
respecté correctement par le driver, laissant le thread de sondage
fréquence bloqué dans `read()` bien plus longtemps que prévu, en continu.

Corrigé en remplaçant tous les `serial_port.read(n)` directs (lecture
fréquence Icom/Yaesu, confirmation d'écriture fréquence) par une nouvelle
méthode `RadioController._read_with_deadline(max_bytes, deadline_s)`
(classe `RadioController`, juste avant `_icom_get_freq`) : sonde
`serial_port.in_waiting` nous-mêmes avec de petites pauses (`time.sleep
(0.02)`) jusqu'à un délai maximum fixé côté code, sans jamais dépendre du
timeout interne (potentiellement cassé) du driver pour ce port précis.

**Confirmé corrigé** par mesure directe avant publication : CPU retombe à
~1-2% avec le CAT connecté, aussi bien sur la source Python que sur
l'exécutable compilé 8.4.5.

## Fonctionnalités ajoutées / corrigées lors des sessions précédentes (4-7 sept 2026)

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
  HRD) jamais mémorisés — persistés dans `_logbook_settings`. Le port UDP
  ADIF (2333 par défaut) reste éditable à la main — signalé par
  l'utilisateur que ça peut différer entre HRD 6.8 et 6.9 (visible dans
  HRD : File → QSO Forwarding → UDP Receive port). Pas de détection
  automatique implémentée (demande abandonnée par l'utilisateur, "pas
  grave").
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
6. **Taper le tag AU CLAVIER avec attention** (`vX.Y.Z`) — un tag mal
   saisi (ex. chiffres inversés `v4.8.3` au lieu de `v8.4.3`) casse la
   détection de mise à jour car les tags sont comparés numériquement.
7. Glisser **uniquement** `installer\Output\MultiDigi_Setup_X.Y.Z.exe`
   dans les assets — ne pas laisser traîner `dist\MultiDigi\MultiDigi.exe`
   (inutile seul, sans son dossier `_internal`).
8. Publier — l'utilisateur doit le faire lui-même (accès au compte
   GitHub), Claude peut l'assister pas à pas mais n'a pas d'accès direct
   au navigateur de l'utilisateur (Claude in Chrome non installé/connecté
   lors de cette session — passer par des instructions textuelles).
9. **Toujours vérifier après coup** avec :
   `curl -s -H "Accept: application/vnd.github+json" https://api.github.com/repos/f4lps/multidigi/releases/latest`
   → contrôler `tag_name` (doit correspondre exactement) et `assets`
   (un seul fichier, le bon installeur, la bonne taille).

## Astuce diagnostic (utile pour les prochaines sessions)

Cette session tourne **directement sur la machine de l'utilisateur**
(F4LPS) — accès complet PowerShell/Bash. Pour un problème de performance
ou de comportement runtime, **mesurer en direct plutôt que deviner** :
`Get-Process -Name MultiDigi | Select CPU, Threads` avant/après une action
(ex. connecter/déconnecter le CAT) donne une réponse factuelle en
quelques secondes, bien plus fiable qu'une hypothèse de code lue en
diagonale. Ça a permis de trouver la vraie cause du ralentissement CAT
(8.4.5) après qu'une première hypothèse plausible mais fausse (8.4.4)
n'ait pas suffi.

## Sécurité radio (toujours valable)

- Ne jamais lancer automatiquement un test qui commande le PTT.
- Les automatismes HB et ACK JS8 restent désactivés par défaut à chaque
  lancement.
- Le CAT auto-détection (bouton) ne fait que des lectures, jamais de PTT.

## Points restants à vérifier / améliorer

- ~~Confirmer avec l'utilisateur, en usage réel prolongé (RX+TX), que le
  ralentissement a bien disparu en 8.4.5.~~ **Confirmé par l'utilisateur
  le 7 sept 2026 : "ça fonctionne bien."** Dossier clos.
- Vérifier la connexion HRD réelle (l'utilisateur confirme qu'elle
  fonctionne — testé dans cette session via la fenêtre "Logger le QSO" →
  HRD Logbook, semble opérationnel).
- Le port UDP ADIF HRD Logbook (2333 par défaut) peut différer selon la
  version de HRD (6.8 vs 6.9) — l'utilisateur le sait et ajuste
  manuellement, pas de détection auto demandée pour l'instant.
- Les macros ont été relues (code correct), pas testées en conditions
  réelles par l'utilisateur.
- Tester en réception radio réelle les modes JS8 SLOW/FAST/40/60.
