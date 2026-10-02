# MultiDigi 8.5.9 — réception CW

- Le moteur CW FIT pilote seul son suivi de fréquence. Le waterfall affiche la fréquence réellement suivie et ne déplace plus son ancre à chaque correction.
- La case Alignement automatique commande le suivi Fit.
- La capture CW utilise un callback et une file bornée, indépendants du traitement DSP. Une perte audio signalée réinitialise le décodage pour ne pas fabriquer une lettre à travers une coupure.
- Si le périphérique impose un autre débit, le moteur CW est reconstruit avec le débit effectivement ouvert.
- La fenêtre CW affiche la confiance et le contraste du moteur Fit plutôt que les mesures absentes de l'ancien moteur.

Validation locale : tests de suivi et d'ancre, arrêt AFC, débit 44,1/48 kHz, diagnostics Qt, capture simulée et reprise après coupure. Sur une capture radio de 59,95 s à 645,996 Hz, les cœurs CW Terminal et MultiDigi avant modification produisent exactement le même texte. Les différences d'affichage et de filtrage des mots restent distinctes. Aucun taux d'erreur réel ni supériorité sur CW Terminal n'est établi sans transcription de référence.

L'ancienne version est conservée dans dist/MultiDigi. La nouvelle version est dans dist-cw-8.5.9/MultiDigi. Pour une distribution, utiliser l'installeur complet ; ne pas copier l'exécutable seul sans son dossier _internal.

Essai supplémentaire en réception réelle : 424 blocs traités à 44 100 Hz sur environ 20 secondes, file vide en fin de mesure, arrêt propre. Texte reçu : « 8CWG OE8CWG CQ CQ CQ DE OE8CWG OE8CWG AR K ». Cet essai vérifie le fonctionnement en direct ; il ne mesure pas un gain de taux d'erreur.
