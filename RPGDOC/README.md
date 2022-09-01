Welcome to RGPDOC!

(C)opyright 2004, 2005, 2006, 2009 by Christopher Drue Wolcott  All rights reserved  

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    Redistribution of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.

    Redistribution in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

    Neither my name nor the names of any contributors may be used to
    endorse or promote products derived from this software without specific
    prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


Please send any improvements made, comments or ideas on how to better this product to wolcott@attglobal.net


This is an open source application to produce program documentation from the RPG program source.
Best results occur when you use the specified comment format.  
(See HELP on the RGPDOC command for more details.)


If you obtained the SAVF:  (V5R2M0 or higher)
=============================================

Create a SAVF on your iSeries with the name RPGDOC.  CRTSAVF FILE(RPGDOC) TEXT('RPGDOC Program Documentation Generator')
CREATE a library on the iSeries called RPGDOC        CRTLIB LIB(RPGDOC) TEXT('RPGDOC Program Documentation Generator')
Create an IFS directory named RPGDOC.                CRTDIR DIR('/RPGDOC') DTAAUT(*RWX) OBJAUT(*ALL)

Extract the RPGDOC.SAVF object to an uncompressed folder.
FTP to your iSeries from the PC where this file resides.
Use the following commands to put the SAVF on your iSeries:

BIN
CD <library with *SAVF>
PUT 
local file: RPGDOC.SAVF
remote file: RPGDOC
QUIT

Now you can restore the objects from the SAVF to the RPGDOC library.
                                                     RSTOBJ OBJ(*ALL) SAVLIB(RPGDOC) DEV(*SAVF) SAVF(RPGDOC)

If you obtained the source file archive:
========================================

CREATE a library on the iSeries called RPGDOC        CRTLIB LIB(RPGDOC) TEXT('RPGDOC Program Documentation Generator')
Create an IFS directory named RPGDOC.                CRTDIR DIR('/RPGDOC') DTAAUT(*RWX) OBJAUT(*ALL)  
Create the source physical files.                    CRTSRCF FILE(RPGDOC/QRPGLESRC) RCDLEN(118) TEXT('RPGDOC RPGLE Source Members')
                                                     CRTSRCF FILE(RPGDOC/QPNLSRC)   RCDLEN(118) TEXT('RPGDOC PNLGRP Source Members')
                                                     CRTSRCF FILE(RPGDOC/QCMDSRC)   RCDLEN(118) TEXT('RPGDOC CMD Source Members')
                                                     CRTSRCF FILE(RPGDOC/QCLSRC)    RCDLEN(118) TEXT('RPGDOC CLLE Source Members')

Extract the contents of the RPGDOC archive to an uncompressed folder.
FTP from the PC where this file resides to the iSeries you just created the above objects on.
(START - ALL PROGRAMS - ACCESSORIES - COMMAND PROMPT - FTP (iseries DNS))
Use the following FTP commands to put the SAVF on your iSeries once you've logged on:

ASC
CD RPGDOC
LCD <PC directory containing extracted files>
PUT
local file: RPGDOC_R.RPGLE
remote file: QRPGLESRC.RPGDOC_R
PUT
local file: RPGDOC.CLLE
remote file: QCLSRC.RPGDOC
PUT
local file: RPGDOC.CMD
remote file: QCMDSRC.RPGDOC
PUT
local file: RPGDOC.PNLGRP
remote file: QPNLSRC.RPGDOC
PUT
local file: CRTRPGDOC.RPGLE
remote file: QRPGLESRC.CRTRPGDOC	
QUIT

Compile the CRTRPGDOC source and run it by typeing CRTRPGDOC ('RPGDOC') <- Specify the final location of the finished objects.
It will compile the other RPGDOC objects in the library you specify.


TO USE:
========

Add RPGDOC to your *LIBL                             ADDLIBLE RPGDOC
Type and prompt (F4) the command "RPGDOC".  Enter the required 
information and press ENTER.  (F1 will display a HELP screen)

