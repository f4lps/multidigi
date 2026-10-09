# MultiDigi 8.5.13

## eQSL : les QSO partent enfin
L'envoi vers eQSL.cc n'a jamais fonctionné : MultiDigi transmettait le login et le mot de passe sous des noms qu'eQSL ne
connaît pas, et eQSL répondait « Error: Missing eQSL_User ». Aucun QSO n'arrivait, et MultiDigi affichait seulement
« ⚠️ Vérifier réponse ». Maintenant l'envoi suit la documentation d'eQSL (ImportADIF) :
- login et mot de passe dans l'en-tête ADIF (EQSL_USER / EQSL_PSWD), envoyés en POST (le mot de passe n'apparaît plus
  dans l'adresse) ;
- le « QTH Nickname » est transmis (APP_EQSL_QTH_NICKNAME) : utile si ton compte eQSL a plusieurs QTH ;
- mode et sous-mode corrects (PSK / BPSK31, MFSK / JS8…).

La réponse d'eQSL est lue : « ✅ eQSL envoyé », « ✅ déjà dans eQSL (doublon) », ou « ❌ » avec le message exact d'eQSL
(par exemple « No match on eQSL_User/eQSL_Pswd » = login ou mot de passe faux). Le log automatique compte une erreur
eQSL comme un échec au lieu d'un envoi réussi.

## Fenêtre de log : les réglages sont gardés
Les identifiants et adresses des journaux n'étaient pas enregistrés (sauf HRD, QRZ et HamQTH) : ils revenaient vides à
chaque ouverture, et le log automatique partait donc sans identifiants. Sont maintenant mémorisés, dès que tu quittes
le champ : eQSL (login, mot de passe, QTH Nickname), ClubLog, WaveLog (adresse, clé API), LoTW (TQSL, station, mot de
passe), et les adresses / ports de N1MM+, DXLog, Win-Test, WinRef, Log4OM et Log32.

Après la mise à jour : ouvre une fois la fenêtre LOG, onglet eQSL, saisis ton login et ton mot de passe eQSL (et ton
QTH Nickname si tu en as un), puis envoie un QSO pour vérifier.

## Installation
Lance `MultiDigi_Setup_8.5.13.exe` : mise à jour par-dessus, réglages conservés.
