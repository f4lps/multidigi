# Guide de configuration CAT — Icom, Yaesu, HRD

Ce guide explique comment relier MultiDigi à ta radio pour la lecture de
fréquence et le PTT automatique, dans les 3 configurations possibles :
**CAT série direct** (câble USB-CAT branché directement sur le PC),
**via HRD** (Ham Radio Deluxe fait l'intermédiaire), ou **OmniRig/FLRig**
(non couverts en détail ici, principe similaire à HRD).

Tout se règle dans **⚙ Réglages généraux → onglet Réglages PSK**, section
**"🎛️ RADIO CAT / PTT — intégré aux réglages"**.

---

## ⚠️ À lire avant de brancher quoi que ce soit

- Les réglages CAT (port, baudrate, protocole, PTT) **ne commandent jamais
  l'émission tout seuls**. Mais une radio mal configurée peut rester
  bloquée en émission (porteuse) si le mauvais protocole ou une mauvaise
  option est utilisé — **vérifie toujours que l'antenne est en bonne
  condition et reste à proximité du bouton d'arrêt d'urgence / de
  l'alimentation pendant les premiers tests.**
- La case **"⚠️ Forcer DTR/RTS actifs"** ne doit **jamais** être cochée en
  Yaesu : sur de nombreux câbles CAT+PTT Yaesu, la ligne RTS est câblée
  directement sur le PTT matériel du transceiver — l'activer met la radio
  en émission dès la connexion, sans aucune commande CAT. Elle est
  réservée à de rares adaptateurs Icom qui en ont besoin pour fonctionner
  du tout (et elle se masque automatiquement dès que le protocole n'est
  pas "Icom CI-V").

---

## 1. Radio Icom — CAT série direct (CI-V)

**Câble :** USB-CI-V (beaucoup d'Icom récents, IC-7300/7610/705/9700...
ont un port USB intégré qui fait aussi office d'interface CI-V — un
simple câble USB suffit, pas besoin d'adaptateur externe).

**Réglages côté radio** (menu SET de la radio, les noms varient un peu
selon le modèle) :

| Réglage radio          | Valeur                                   |
|-------------------------|-------------------------------------------|
| CI-V Baud Rate           | Fixe une valeur (ex. 19200 ou 57600) — **pas** "Auto" |
| CI-V Address             | Note l'adresse hexa (ex. `0x94` pour l'IC-7300) |
| CI-V Transceive          | OFF (évite le bruit sur le bus si tu n'en as pas besoin) |
| CI-V USB Port (si USB)  | "Unlink from [REMOTE]" ou équivalent, pour un port CAT dédié |

**Réglages côté MultiDigi :**

| Champ           | Valeur                                    |
|------------------|---------------------------------------------|
| Port COM         | Le port qui correspond au câble (vérifie dans le Gestionnaire de périphériques Windows, ou utilise **🔍 Auto-détecter le port**) |
| Baudrate         | **Identique** à celui réglé sur la radio    |
| Protocole        | Icom CI-V                                   |
| CI-V Adresse     | La même adresse que sur la radio (ex. `0x94 (IC-7300)`) |
| Forcer DTR/RTS   | Laisse **décoché** sauf si la fréquence ne remonte jamais malgré des réglages corrects (rare, certains adaptateurs USB-CI-V bas de gamme en ont besoin) |

Clique **CONNECTER**. Le message affiché indique la fréquence lue si ça
fonctionne, ou un diagnostic précis sinon (aucun octet reçu, réponse
illisible, erreur d'E/S...).

---

## 2. Radio Yaesu — CAT série direct

Il existe **deux protocoles CAT Yaesu totalement différents et
incompatibles** — le bon choix dépend du modèle :

### 2a. Yaesu récent (protocole ASCII, type Kenwood)

**Modèles concernés :** FT-891, FT-991/991A, FTDX10, FTDX101D/MP,
FT-710, FT-DX1200/3000/5000, FT-450, FT-2000, et globalement tout ce qui
est sorti après ~2010.

**Réglages côté radio** (menu SET → interface CAT) :

| Réglage radio     | Valeur                                       |
|--------------------|-------------------------------------------------|
| CAT RATE           | Fixe une valeur (ex. 38400) — note-la          |
| CAT TOT (timeout)  | Valeur par défaut, pas besoin de toucher        |
| CAT RTS            | **Enable** seulement si ton câble en a besoin pour l'alimentation — sinon Disable (voir l'avertissement PTT plus haut) |

**Réglages côté MultiDigi :**

| Champ        | Valeur                                         |
|---------------|---------------------------------------------------|
| Port COM      | Le port du câble CAT (souvent un adaptateur USB-série type Silicon Labs CP210x ou FTDI) |
| Baudrate      | Identique au CAT RATE réglé sur la radio          |
| Protocole     | **Yaesu CAT ASCII (FT-891/991/FTDX/710)**         |

Le champ "CI-V Adresse" et la case "Forcer DTR/RTS" se masquent
automatiquement avec ce protocole (ils ne concernent que l'Icom).

### 2b. Yaesu ancien (protocole CAT binaire 5 octets)

**Modèles concernés :** FT-847, FT-857(D), FT-897(D), FT-100(D).

Réglages identiques dans l'esprit (CAT RATE côté radio, même baudrate
côté MultiDigi), mais choisis le protocole **"Yaesu CAT (ancien,
FT-847/857/897)"**.

### Comment savoir lequel choisir si tu doutes ?

Essaie l'ASCII moderne en premier (c'est le plus courant aujourd'hui).
Si la connexion échoue avec un message clair (pas de réponse), essaie
l'ancien. Dans tous les cas, **ne jamais cocher "Forcer DTR/RTS"** en
Yaesu, quel que soit le protocole choisi.

---

## 3. Ham Radio Deluxe (HRD)

HRD sert d'intermédiaire entre MultiDigi et la radio : MultiDigi ne parle
plus directement au port série, il parle en réseau à HRD, qui lui-même
pilote la radio. Deux réglages **distincts** sont nécessaires côté HRD —
ne les confonds pas, ce sont deux fonctions différentes de HRD.

### 3a. HRD Rig Control (pilotage radio — fréquence, PTT, mode)

1. Dans **HRD Rig Control**, connecte-toi normalement à ta radio (choix
   du modèle, port COM, baudrate — comme d'habitude dans HRD).
2. HRD doit rester **ouvert et connecté à la radio** pendant que tu
   utilises MultiDigi.
3. Dans HRD, va dans les réglages réseau du Rig Control pour vérifier le
   port du serveur TCP (par défaut **7809** — ne change que si tu l'as
   toi-même modifié).
4. Côté MultiDigi, dans la section **"HRD IP Server"** du panneau CAT :
   - Hôte : `127.0.0.1` (si MultiDigi et HRD tournent sur le même PC)
   - Port : `7809` (ou ta valeur personnalisée)
5. Clique **Connecter HRD**.

### 3b. HRD Logbook (log automatique des QSO — fenêtre "Logger le QSO")

C'est une fonction séparée : MultiDigi envoie les QSO à logger vers HRD
Logbook via UDP, au format ADIF.

1. Dans **HRD Logbook**, va dans **File → QSO Forwarding** (le nom exact
   de ce menu **varie selon la version de HRD** — 6.8 et 6.9 par exemple
   n'utilisent pas forcément le même port par défaut).
2. Active la réception UDP ADIF et note le **port** affiché (souvent
   2333, mais vérifie — c'est la valeur qui compte, pas une supposition).
3. Côté MultiDigi, dans la fenêtre **"Logger le QSO" → onglet HRD
   Logbook** :
   - IP : `127.0.0.1`
   - Port : **la valeur exacte lue dans HRD** à l'étape 2
4. Ce port est mémorisé automatiquement une fois réglé correctement.

**Piège fréquent :** si le log ne remonte pas dans HRD alors que "Envoyer
vers HRD Logbook" ne renvoie pas d'erreur, c'est presque toujours parce
que le port ne correspond pas exactement à celui affiché dans HRD (les
deux logiciels doivent utiliser le même numéro).

---

## En cas de problème

Le bouton **CONNECTER** affiche toujours un message de diagnostic précis
(pas juste "échec") : aucun octet reçu, réponse illisible avec le contenu
brut, ou erreur d'E/S avec le message système exact. Ce message est la
première chose à regarder — il indique généralement si le souci vient du
port/câble, du baudrate, ou du protocole choisi.
