             CMD        PROMPT('SRVPGM DOC Generator')

             PARM       KWD(SRVOBJ) TYPE(WORKFILE) MIN(1) +
                          PROMPT('Service Program Name')
             PARM       KWD(PATH) TYPE(*PNAME) LEN(50) +
                          DFT('/RPGDOC') PROMPT('Directory for Documentation')

 WORKFILE:   QUAL       TYPE(*NAME) LEN(10) MIN(1) EXPR(*YES)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) CHOICE('*LIBL, Name') +
                          PROMPT('Library')
