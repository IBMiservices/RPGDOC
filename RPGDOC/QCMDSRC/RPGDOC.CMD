             CMD        PROMPT('RPG DOC Generator')

             PARM       KWD(RPGSRC) TYPE(WORKFILE) PROMPT('RPG Source File')
             PARM       KWD(MBR) TYPE(*NAME) LEN(10) DFT(*ALL) +
                          SPCVAL((*ALL)) CHOICE('*ALL, Name') +
                          PROMPT('Member name')
             PARM       KWD(PATH) TYPE(*PNAME) LEN(50) +
                          DFT('/RPGDOC') PROMPT('Directory for Documentation')

 WORKFILE:   QUAL       TYPE(*NAME) LEN(10) DFT(QRPGLESRC )
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) CHOICE('*LIBL, Name') +
                          PROMPT('Library')
