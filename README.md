# RPGDOC
Si vous avez obtenu le SAVF : (V5R2M0 ou supérieur)
=============================================

Créez un SAVF sur votre iSeries avec le nom RPGDOC. CRTSAVF FILE(RPGDOC) TEXT('Générateur de documentation de programme RPGDOC')
CREER une bibliothèque sur l'iSeries appelée RPGDOC CRTLIB LIB(RPGDOC) TEXT('RPGDOC Program Documentation Generator')
Créez un répertoire IFS nommé RPGDOC. CRTDIR DIR('/RPGDOC') DTAAUT(*RWX) OBJAUT(*ALL)

Extraire l'objet RPGDOC.SAVF dans un dossier non compressé.
FTP à votre iSeries à partir du PC où réside ce fichier.
Utilisez les commandes suivantes pour placer le SAVF sur votre iSeries :

BIN
CD 
PUT 
fichier local : RPGDOC.SAVF
fichier distant : RPGDOC
QUIT

Vous pouvez maintenant restaurer les objets du SAVF dans la bibliothèque RPGDOC.
RSTOBJ OBJ(*ALL) SAVLIB(RPGDOC) DEV(*SAVF) SAVF(RPGDOC)

Si vous avez obtenu l'archive du fichier source :
========================================

CREER une bibliothèque sur l'iSeries appelée RPGDOC CRTLIB LIB(RPGDOC) TEXT('RPGDOC Program Documentation Generator')
Créez un répertoire IFS nommé RPGDOC. CRTDIR DIR('/RPGDOC') DTAAUT(*RWX) OBJAUT(*ALL) 
Créez les fichiers physiques sources. CRTSRCF FILE(RPGDOC/QRPGLESRC) RCDLEN(118) TEXT('RPGDOC RPGLE Source Members')
CRTSRCF FILE(RPGDOC/QPNLSRC) RCDLEN(118) TEXT('RPGDOC PNLGRP Source Members')
CRTSRCF FILE(RPGDOC/QCMDSRC) RCDLEN(118) TEXT('RPGDOC CMD Source Members')
CRTSRCF FILE(RPGDOC/QCLSRC) RCDLEN(118) TEXT('RPGDOC CLLE Membres sources')

Extrayez le contenu de l'archive RPGDOC dans un dossier non compressé.
FTP depuis le PC où se trouve ce dossier vers l'iSeries sur lequel vous venez de créer les objets ci-dessus.
(START - ALL PROGRAMS - ACCESSORIES - COMMAND PROMPT - FTP (iseries DNS))
Utilisez les commandes FTP suivantes pour placer le SAVF sur votre iSeries une fois que vous vous êtes connecté :

ASC
CD RPGDOC
LCD 
PUT
fichier local : RPGDOC_R.RPGLE
fichier distant : QRPGLESRC.RPGDOC_R
PUT
fichier local : RPGDOC.CLLE
fichier distant : QCLSRC.RPGDOC
PUT
fichier local : RPGDOC.CMD
fichier distant : QCMDSRC.RPGDOC
PUT
fichier local : RPGDOC.PNLGRP
fichier distant : QPNLSRC.RPGDOC
PUT
fichier local : CRTRPGDOC.RPGLE
fichier distant : QRPGLESRC.CRTRPGDOC 
QUITTER

Compilez le source CRTRPGDOC et exécutez-le en tapant CRTRPGDOC ('RPGDOC') <- Spécifiez l'emplacement final des objets finis.
Il compilera les autres objets RPGDOC dans la bibliothèque que vous aurez spécifiée.
![image](https://user-images.githubusercontent.com/13730057/187934530-f3d52db7-353c-4be2-989e-e5c09873e3d6.png)

Utilisation RPGDOC

Ajoutez RPGDOC à votre *LIBL ADDLIBLE RPGDOC
Tapez et demandez (F4) la commande "RPGDOC". Entrez les informations 
informations requises et appuyez sur ENTER. (F1 affichera un écran d'AIDE)
![image](https://user-images.githubusercontent.com/13730057/187934578-14758e1c-74b1-425e-b1b8-afd99bd3dc0d.png)
