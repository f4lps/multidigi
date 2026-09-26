# Reprise MultiDigi — 7 septembre 2026 (fin de session)

## ⏩ Session du 20 septembre 2026 — moteur CW « FIT » + diagnostics de connexion (version 8.5.0, NON publiée)

**Où :** branche locale `cw-fit-et-connexions` (créée depuis `main` = 8.4.7 ; **rien n'est fusionné dans `main`,
rien n'est poussé, aucune release publiée**). `PROGRAM_VERSION_TAG` et `MyAppVersion` sont déjà à **8.5.0**.

### Pourquoi
Mêmes problèmes que sur CW Terminal : décodage CW faible (rafales de E/T/I, lettres perdues, échec sur QSB et
manipulation à la main) et connexions CAT peu lisibles. Ce qui a été mis au point et validé dans CW Terminal
V1.9 (dossier `C:\Users\14frs\Documents\radio\CW_Terminal_Dev`, dépôt public `f4lps/CW-Terminal`) a été repris ici.

### Ce qui a changé (fichier unique `MultiDigi_FINAL_JS8_20260904.py`)
1. **Nouveau mode CW « CW FIT »** (`CW_MODES`, choisi **par défaut** pour la famille CW ; NEXT et CLASSIC restent
   disponibles). Moteur `CWFitDecoder` + `CWFitBackend` (juste avant `CW_MODES`), branché dans `_CWModemAdapter`.
   Principe : au lieu de décider « point/trait » élément par élément, on ajuste sur ~7 s d'enveloppe le triplet
   (seuil, longueur du dit, biais de front) qui colle le mieux à la grammaire Morse ; le résidu sert de confiance,
   le bruit n'émet rien. Réparation des creux de fading, hystérésis large (queue des traits), correction à un
   élément près (`......` → `5`). Code copié de `cw_fit_decoder.py` de CW Terminal (identifiants renommés).
   - `_CWModemAdapter.reset()` : ne remplace plus le moteur FIT par un `CWSkimmerV3Decoder`.
   - ⚠️ Constat NON corrigé : `reset()` remplace *toujours* CLASSIC/NEXT par un `CWSkimmerV3Decoder` (probable bug
     historique, laissé tel quel pour ne pas changer le comportement des anciens modes).
2. **Port COM occupé → on nomme le coupable** : `_f4lps_port_holders()` + `_f4lps_port_busy_message()` (juste avant
   `class RadioController`). `connect_serial` renvoie « Port COM13 déjà utilisé par : CW_Terminal.exe (PID …) ».
   Méthode : `QueryDosDeviceW` (COMx → nom NT) + table des handles système, restreinte aux handles de type
   « File » puis `GetFileType == CHAR`. **Limite** : les services et programmes lancés en administrateur ne sont
   pas inspectables (~170 processus sur 365 sur cette machine) → message générique honnête dans ce cas.
3. **Statut orange** (au lieu du ✅ vert) quand `connect_serial` renvoie « ⚠️ aucun octet reçu » : port ouvert
   mais radio muette ≠ connexion réussie (deux panneaux : `_toggle_cat` des Réglages PSK et celui de la fenêtre).
4. **Auto-détection du port** : signale les ports occupés et par quel programme.
5. README, `CAT_SETUP.md` (section « Port COM occupé, ou radio qui ne répond pas ») mis à jour.
6. **CW « natif » + mode radio automatique** (demande de l'utilisateur après un test en direct : PTT sans morse
   parce que la radio était en mode CW alors que MultiDigi envoyait une note **audio**, ce qu'une radio en CW ignore).
   Décision : MultiDigi envoie maintenant le CW **comme CW Terminal** — texte confié au manipulateur de la radio par
   CI-V `0x17` (messages de 30 caractères au plus, découpés par mots, attente de la durée réelle du morse entre deux
   messages, `0x14 0x0C` pour la vitesse, `0x17 0xFF` pour l'arrêt, **aucun PTT** : la radio passe en TX toute seule
   en BK-IN). Et **le mode radio suit la famille** : CW → `set_mode_cw()`, toutes les autres → `set_mode_usb()`.
   - `RadioController` : `cw_link()`, `cw_open_aux()` (port CAT auxiliaire pour HRD/FLRig/OmniRig ; DTR/RTS coupés
     AVANT l'ouverture ; vérifie que la radio répond), `cw_close_aux()`, `cw_clean_text()`, `cw_send_speed()`,
     `cw_send_text()`, `cw_stop()`, `get_mode_name()` (HRD, OmniRig, FLRig, CI-V 0x04 ; lecture seule).
   - `CWNativeTxThread` (juste avant `PSKTxThread`, **mêmes signaux**, donc toute la fin d'émission existante est
     réutilisée) ; `PSKMainWindow._cw_native_prepare()`, `_apply_radio_mode_for_family()`, `_start_tx_cw_native()` ;
     `_launch_tx` court-circuite le PTT et l'audio en CW natif ; déclencheurs : `_on_family_changed` (+300 ms) et
     `_restart_freq_poll` (+700 ms, appelé à chaque connexion CAT).
   - Liaison CI-V pour le CW en HRD : le port du panneau RADIO CAT (`_cat_settings`: port/baud/civ), ici COM13.
   - **Repli audio** (radio non-Icom, aucune liaison CI-V possible) : la radio est mise en USB et l'ancienne boîte
     `_cw_radio_mode_ok()` (« Passer en USB et émettre ») reste en garde-fou.
   - ⚠️ Non fait : CW natif Yaesu (KY) ; pas de test sur radio réelle (à faire : BK-IN requis, vérifier que `0x17`
     enchaîne bien les messages de 30 caractères sans trou audible).
   - Tests (sans radio, `CW_Terminal_Dev/`) : `test_md_native.py` (fausse radio COM16/COM17 + faux HRD qui mémorise
     le mode, **dossier utilisateur temporaire : ne touche jamais aux réglages réels**), `test_md_cwmode.py`.

### ✅ MISE À JOUR (même jour, plus tard) — points A et B corrigés, À RE-TESTER SUR LE VRAI POSTE
- **A (bascule de mode)** : `RadioController.civ_read_mode()` / `civ_set_mode()` (CI-V `06 01`/`06 03`, relecture `04`, 3 essais,
  vrai succès/échec) ; `PSKMainWindow._open_civ_aux()`, `_set_radio_mode(want)` (CI-V d'abord, secours HRD avec
  `set dropdown {Mode} <NOM> <index>` puis relecture), `_cw_native_prepare` et `_apply_radio_mode_for_family` l'utilisent ;
  liaison auxiliaire ouverte seulement le temps du changement pour les familles non-CW ; si le mode n'est pas confirmé,
  message orange dans la barre d'état et CW en audio (repli). `test_md_native.py` : faux HRD qui IGNORE `set mode`, radio de
  départ en AM → TOUT PASSE. Reste à voir sur la vraie radio (COM13 doit être libre : un seul MultiDigi).
- **B (mots)** : `WORD_GAP = 4.8` (au lieu de 5.5 en dur), balayage 4.4–5.5 : signal réel 110 → 119 mots, aucun mot collé,
  CER synthétique 5,0 % → 4,7 %. Appliqué dans `cw_fit_decoder.py` (CW Terminal, non publié : V1.9.2 à décider) et dans
  `CWFitDecoder` de MultiDigi.
- Toujours vrai : la radio de l'utilisateur est peut-être restée en AM (le nouveau code la remettra en CW/USB à la connexion).

### 📦 MultiDigi 8.5.0 — installateur PRÊT, NON PUBLIÉ (20 septembre 2026)
- `installer/Output/MultiDigi_Setup_8.5.0.exe` (145 482 835 octets, SHA256 c3f0525c83349992234f170bc49d5eeba40085e8b14f4006aedbc6000844b75d),
  construit à partir du commit f4e62df (contient : CW FIT, mots adaptatifs, plus de « ? », CW natif, mode radio CI-V vérifié,
  port occupé nommé, Tracker sans GPU + `multidigi_crash.log`). Build ~10 min (PyInstaller) + Inno Setup.
- Testé : l'exe démarre (dossier utilisateur temporaire), journal de plantage écrit, fenêtre Tracker + carte OK en rendu logiciel.
  NON testé : installation propre / mise à jour par-dessus 8.4.7 sur un autre PC, CW natif et bascule de mode avec l'exe installé.
- Notes de version : `RELEASE_NOTES_8.5.0.md`. Reste (avec accord explicite) : fusion `cw-fit-et-connexions` -> `main`, push,
  release GitHub `f4lps/multidigi` avec l'installateur (gh CLI absent : passer par l'API avec le jeton de `git credential fill`).
- CW Terminal 1.9.2 : code commité (f3a39a9) mais installateur NON construit (arrêté sur demande, priorité MultiDigi).

### 📡 JS8 : réponse HB avec SNR + log auto vers les logs cochés (26 septembre 2026) — codé et testé, NON compilé / NON publié
- **HB -> réponse `SNR <dB>`** (`_js8_maybe_ack_hits`, `_prepare_js8_command(kind, number)`) : d'après la doc JS8Call, les réponses aux
  heartbeats utilisent la commande SNR (cmd 25) et non ACK. Rapport = `hit['snr_db']` arrondi, borné -30..+31 ; repli ACK si
  inconnu. Aller-retour encodage/décodage vérifié (`JS8TXEncoder._pack_message_frames` -> `JS8RXDecoder._decode_js8_payload_v25`).
- **Log auto** (`js8_reply_log_cb` -> `_js8_maybe_log_reply` -> `_auto_log_qso(send_external=True)`) : Tracker (déjà fait) + envoi différé
  (QTimer 60 ms) via `QSOLogDialog(...)` NON affiché et `_send_selected_logs(interactive=False)` -> (envoyés, erreurs) ; les cases
  lues sont `_logbook_settings['logsel_*']`. Résultat dans `js8_auto_status` + `multidigi_radio.log` (la barre d'état est écrasée
  par la recherche d'indicatif).
- ⚠️ Points ouverts : (1) la macro `<add-log>` (73+Log) garde l'ancien comportement (Tracker seul) ; (2) les journaux EN LIGNE (QRZ, eQSL,
  ClubLog, WaveLog, LoTW) s'exécutent dans le fil de l'interface (timeout jusqu'à 20 s si Internet est coupé) : à passer en fil séparé si
  gênant ; (3) RST loggué = celui des champs (599) et non le SNR reçu ; (4) le mode envoyé aux journaux est « JS8 » (ADIF MFSK/JS8 pour QRZ).
- Test : `CW_Terminal_Dev/test_md_js8.py`. Notes de version en brouillon : `RELEASE_NOTES_8.5.4.md` (avec le correctif Yaesu).

### 🔧 Audit du protocole Yaesu (26 septembre 2026) — corrigé dans le code, NON compilé, NON publié
Signalé : « personne n'arrive à se connecter correctement, surtout pour l'envoi, en CAT ou par HRD ». Sources : Hamlib
(`newcat.c`, `ft991.c`, `ft891.c`, `ftdx10.c`) et le code de CW Terminal (`YaesuModernCAT`, validé sur un FTDX10).
- **`RX;` n'existe pas chez Yaesu** : `_yaesu_ascii_ptt_off` l'envoyait, la radio répondait `?;` et **restait en émission**.
  Maintenant `TX0;` + relecture `TX;` (3 essais) ; `TX1;` + relecture.
- **pyserial lève DTR et RTS à l'ouverture par défaut** (`_rts_state = _dtr_state = True`) : la 8.4.7 n'avait supprimé que le
  forçage explicite, la radio pouvait donc partir en émission dès CONNECTER (RTS = PTT sur port « Standard » / câbles CAT+PTT).
  Yaesu : ouverture avec DTR/RTS bas (`Serial()` + `dtr/rts=False` + `open()`), y compris dans « Auto-détecter le port ».
  ⚠️ **Icom : inchangé** (DTR/RTS toujours levés à l'ouverture) — même risque potentiel avec une interface Icom dont RTS est le PTT.
- **2 bits d'arrêt** pour les deux protocoles Yaesu (Hamlib : FT-891/991/FTDX10 = 2 ; CW Terminal aussi) ; MultiDigi mettait 1.
- **Vitesse** : recherche 38400/4800/9600/19200/115200 (`_yaesu_connect_finish`), reprise dans le panneau ; identification `ID;`.
  Port « Enhanced » : nouvel essai RTS levé ; port « Standard » : jamais levé.
- **Ancien protocole binaire** : PTT `0x0F` remplacé par `0x08` / `0x88` (FT-847/857/897 ; FT-100 non géré).
- **Modes Yaesu** (`MD0;` / `MD0x;`, relecture) : `get_mode_name`, `yaesu_set_mode`, branche Yaesu dans `_set_radio_mode`
  (CW/AM/FM/RTTY -> DATA-USB ; USB/LSB/DATA laissés). Le CW reste en audio (pas de CW natif Yaesu : `KY` possible plus tard).
- `ptt_on` / `ptt_off` ne tuent plus les erreurs en silence : tout va dans `multidigi_radio.log` (`_f4lps_radio_log`).
- Test : `CW_Terminal_Dev/test_md_yaesu.py` (fausse radio EN MÉMOIRE, aucun port COM : COM16/17 sont pris par les logiciels de
  l'utilisateur) ; ATTENTION `test_md_native.py`, `test_md_cwmode.py`, `test_md_connect.py` exigent COM16/17 LIBRES : les relancer
  quand les ports sont libres (ils avaient passé avant ce changement).
- **À corriger aussi dans CW Terminal** (publié en 1.9.2, non modifié) : `YaesuModernCAT.set_mode_cw` envoie `MD7;` et
  `set_mode_usb` `MD2;` — la syntaxe Yaesu est `MD0x;` (x = 3 CW, 7 CW-R, 2 USB, C DATA-USB) ; `MD7;` n'est pas un CW-U valide.
- Non testé sur une vraie radio Yaesu. Reste à faire : version (8.5.4), compilation, essai chez un OM Yaesu, puis publication.

### 🧩 Plantage du Tracker chez un OM (Windows 11, AMD x64, installateur) — à suivre
- Symptôme : le programme se ferme au démarrage du Tracker (carte OSM = QtWebEngine/Chromium). Plantage natif, non
  interceptable en Python ; cause probable = pilote GPU de son PC. Le paquet est bon (QtWebEngineProcess.exe, icudtl.dat et
  les .pak sont dans `dist/MultiDigi/_internal/PyQt5/Qt5`).
- Fait (commit 41db5d8) : `_f4lps_crash_guard()` dans `main()` : Chromium sans GPU (`--disable-gpu --disable-gpu-compositing`,
  désactivable par `MULTIDIGI_MAP_GPU=1`) + `faulthandler` vers `~/multidigi_crash.log`.
- Décision de l'utilisateur : PAS de version spéciale pour cet OM ; le correctif partira avec la prochaine version.
  S'il replante après : lui demander `multidigi_crash.log`, sa carte graphique et la date du pilote (mise à jour du pilote AMD).

### ⚠️ POINTS OUVERTS après le test en direct (fin de session du 20 septembre 2026) — À TRAITER EN PREMIER

**A. La bascule automatique CW/USB ne marche pas sur le vrai poste.**
- Cause trouvée : sur le vrai serveur HRD de l'utilisateur (Win4Icom, radio `IC-7300`), la commande `set mode USB` /
  `set mode CW` (utilisée par `RadioController.set_mode_usb/set_mode_cw`) **n'a aucun effet** (réponse vide, `get mode`
  inchangé) et ces fonctions renvoient `True` sans vérifier. Le faux HRD de `test_md_native.py` acceptait `set mode`
  parce que **cette syntaxe avait été inventée pour le test** : test trop indulgent, à corriger.
- Ce que dit le vrai serveur (lecture seule) : `get id` = « Ham Radio Deluxe », `get dropdowns` = `Mode,Data,Filter,AGC,…`,
  `get dropdown-list {Mode}` = `LSB,USB,AM,CW,RTTY,FM,CW-R,RTTY-R` (accolades obligatoires ; sans accolades → vide),
  `get dropdown-text {Mode}` = `Mode: CW`. Syntaxe d'écriture essayée : `set dropdown {Mode} USB 2` a fait passer en USB
  **une fois** ; ensuite le mode lu est resté bloqué sur `AM` quelle que soit la commande (`CW 3/4/5…`, index 1..8) et le
  rafraîchissement de `get mode` peut prendre plusieurs secondes (radio distante). **HRD n'est pas fiable pour changer
  de mode ici.**
- Correctif prévu : changer et lire le mode en **CI-V** sur la liaison auxiliaire (`cw_link()`, COM13) : `FE FE 94 E0 06 01 FD`
  (USB), `… 06 03 …` (CW), lecture `… 04 …` (réponse `FE FE E0 94 04 <mode> <filtre> FD`, mode : 0 LSB, 1 USB, 2 AM, 3 CW,
  4 RTTY, 5 FM, 7 CW-R, 8 RTTY-R) ; vérifier par relecture ; HRD (`set dropdown {Mode} <texte> <index 1-based>`) seulement
  en secours ; faire renvoyer un vrai succès/échec ; pour les familles non-CW, ouvrir la liaison seulement le temps du
  changement (ne pas garder COM13 en permanence). Corriger le faux HRD de test pour imiter le vrai (`set mode` → vide).
- Même défaut probable dans CW Terminal (`set mode DATA-U/USB` du repli audio HRD) : à vérifier, peu d'impact car son CW
  passe par CI-V.

**B. Le moteur CW FIT sépare mal les mots** (retour utilisateur : « il décode plutôt bien mais ne sépare pas bien les
mots »).
- Constat sur le signal réel (segment SM5X, `CW_Terminal_Dev/fixed_seg.npy`, 515 silences ≥ 1,9 unité) : espaces entre
  lettres ≈ 3–3,5 unités (pic), espaces entre mots ≈ 5,5–7 ; le seuil actuel `xs >= 5.5` (dans `_read`, en dur, 2 endroits :
  `isolated` et l'évènement `('s', …)`) tombe **dans la vallée** (5,0–5,5 : 12 évènements, 4,5–5,0 : 19) → mots collés.
- À faire : rendre le seuil paramétrable (`WORD_GAP`, défaut 5.5), balayer 4.4–5.5 sur le segment réel (compter
  `TEST SM5X` exact, `TESTSM5X` collé et mots coupés à tort) **et** sur le banc synthétique (`bench_cw.py`, gaps de 7
  unités, gigue 18 %), éventuellement seuil adaptatif (milieu entre les médianes des deux groupes de silences).
  Reporter dans `cw_fit_decoder.py` (CW Terminal, dépôt public → V1.9.2) **et** dans le bloc `CWFitDecoder` de MultiDigi.
- État : **pas encore modifié** (l'édition a été interrompue).

**C. ⚠️ Radio laissée en AM par mes essais.** Pendant les tests HRD, le mode de l'IC-7300 de l'utilisateur (parti de CW,
aucune émission) est resté sur `AM`. À remettre en CW (dans HRD, ou par le correctif A). COM13 était tenu par son MultiDigi
(PID 31196, lancé à 14:22), donc impossible de le remettre en CI-V depuis ici.

**D. Divers.**
- Détection du « qui tient le port » validée sur le vrai PC : COM13 → `python.exe` (MultiDigi), COM11 → `OmniRig.exe`,
  COM15 → `HamRadioDeluxe.exe`.
- Les tests `test_md_*.py` doivent utiliser un dossier utilisateur temporaire (fait dans `test_md_native.py`) pour ne
  jamais toucher `C:\Users\14frs\psk_terminal_settings.json` pendant que MultiDigi tourne.
- Décisions en attente : fusionner/publier MultiDigi 8.5.0 (reconstruction 30–90 min) ; supprimer la release `v1.9` de
  CW Terminal ; CW Terminal 1.9.2 (détection du port occupé, garde « déjà ouvert », DTR/RTS coupés à l'ouverture) ;
  manuel `.docx` encore en V1.8. Toute publication : uniquement avec l'accord explicite de l'utilisateur.

### Mesures (pour ne pas les refaire)
- Banc synthétique (mêmes signaux que CW Terminal, 2 essais/scénario), erreur moyenne par caractère :
  **FIT ≈ 4 %**, NEXT ≈ 32 %, CLASSIC ≈ 40 % (`CW_Terminal_Dev/bench_multidigi.py`). Mon générateur est idéal.
- **Signal réel** (240 s, station SM5X, vérité = affichage de CW Skimmer) : `TEST SM5X` exact **15** fois avec FIT,
  **4** avec NEXT, **0** avec CLASSIC (`CW_Terminal_Dev/real_md.py`, segment `fixed_seg.npy`).
- Tests : `CW_Terminal_Dev/test_md_cwfit.py` (adaptateur, registre, reset, 44,1 et 48 kHz, bruit pur) et
  `CW_Terminal_Dev/test_md_connect.py` (détection du coupable, messages, radio absente/présente sur la paire
  virtuelle libre COM16/COM17, **aucune vraie radio touchée**) : tout passe. Fenêtre `PSKMainWindow` vérifiée
  en hors-écran : famille CW → modes `CW FIT / CW CLASSIC / CW NEXT`, moteur actif `CWFitBackend`.

### Montage matériel de l'utilisateur (utile pour tout diagnostic CAT)
- Radio IC-7300 (CI-V `0x94`) pilotée **à distance** par **Win4Icom Suite** (`ConnectionType=NETWORK`), qui expose
  un serveur « HRD » sur le port 7809 et des ports auxiliaires côté **VSPD/Eltima** : paires COM10↔11, 12↔13,
  14↔15, 16↔17. Win4Icom tient COM10/COM12/COM14 (AUX1/2/3) ; **les logiciels se branchent sur l'autre extrémité**
  (COM13 pour MultiDigi et CW Terminal). COM16/COM17 sont libres (utilisables pour des tests avec une fausse radio).
- `C:\Users\14frs\psk_terminal_settings.json` est le fichier de réglages **réellement utilisé** (celui du dossier du
  programme est ancien) : `cat_settings` = COM13, 57600, icom, `0x94`, `force_dtr_rts` faux.
- Piège vécu : deux logiciels (CW Terminal / MultiDigi) ne peuvent pas ouvrir COM13 en même temps.

### Reste à faire / décisions à prendre avec l'utilisateur
- **Tester en conditions réelles** (sa radio + un signal CW) : choisir « CW FIT » dans la liste des modes CW.
  Son réglage mémorisé est `mode = "CW NEXT"` : il **ne bascule pas tout seul** sur FIT.
- Si validé : fusionner la branche dans `main`, reconstruire (commande de reconstruction plus bas ; 30-90 min),
  tester `dist\MultiDigi\MultiDigi.exe`, publier `v8.5.0` (voir procédure ; l'API GitHub permet aussi de créer la
  release et d'envoyer l'installeur avec le jeton `repo` du gestionnaire d'identifiants Git — **seulement avec
  l'accord explicite de l'utilisateur**, puis toujours vérifier via `releases/latest`).
- Idée non faite : porter dans CW Terminal (V1.9.2) la détection du programme qui tient le port.

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
