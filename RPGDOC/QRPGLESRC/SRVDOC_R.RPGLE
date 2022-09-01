     /**
      * Reads Object Information about specified service Program and
      * creates a list of exported procedures.
      * <br />
      * COPYRIGHT &copy; 2004,2005,2006,2009 by Chris Wolcott
      * All rights reserved.
      * Redistribution and use in source and binary forms, with or without
      * modification, are permitted provided that the following conditions are met:
      * <br />    Redistribution of source code must retain the above copyright
      *     notice, this list of conditions and the following disclaimer.
      * <br />    Redistribution in binary form must reproduce the above copyright
      *     notice, this list of conditions and the following disclaimer in the
      *     documentation and/or other materials provided with the distribution.
      * <br />    Neither my name nor the names of any contributors may be used to
      *     endorse or promote products derived from this software without specific
      *     prior written permission.
      * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
      * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
      * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
      * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
      * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
      * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
      * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
      * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
      * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
      * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
      * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
      * <br />
      *  author Chris Wolcott - 06-May-04  Written
      *  version V0R1M0
      *  return Error Status.  0 if successfull, -1 if errors occured.
      */

     H DATFMT(*ISO) TIMFMT(*ISO)
     H BNDDIR('QC2LE')

     H NOMAIN                                                                   *MOD
     H*DFTACTGRP(*NO) ACTGRP(*CALLER)                                           *PGM

     H OPTIMIZE(*FULL)                                                          *PRD
     H*DEBUG                                                                    *TST

     HCOPYRIGHT('COPYRIGHT 2004,2005,2006,2009 by Chris Wolcott.  +
     H           ALL RIGHTS RESERVED          +
     H           This program released as Open Source Software under the BSD +
     H           License.          +
     H           See http://www.opensource.org/licenses/bsd-license.php')

     �*========================================================================*�
     �*�  Global File Specifications                                          �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Global Procedure Definitions                                        �*�
     �*========================================================================*�

     D SRVDOC          PR            10I 0 EXTPROC('SRVDOC_R')
     D  pQualName                    20A
     D  pText                        50A

     D GetModInf       PR                  EXTPGM('QBNLMODI')
     D  $UsrSpc                      20A   CONST
     D  $Format                       8A   CONST
     D  $QualNm                      20A   CONST
     D  $ErrorCode                  256A   OPTIONS(*NOPASS)

     D GetSPgInf       PR                  EXTPGM('QBNLSPGM')
     D  $UsrSpc                      20A   CONST
     D  $Format                       8A   CONST
     D  $QualNm                      20A   CONST
     D  $ErrorCode                  256A   OPTIONS(*NOPASS)

     D CrtUsrSpc       PR                  EXTPGM('QUSCRTUS')
     D  $UsrSpc                      20A   CONST
     D  $ExtAtr                      10A   CONST
     D  $InitSiz                     10I 0 CONST
     D  $InitVal                      1A   CONST
     D  $PubAut                      10A   CONST
     D  $Text                        50A   CONST
     D  $Replace                     10A   CONST
     D  $ErrorCode                  256A   OPTIONS(*NOPASS)

     D RtvPtrUS        PR                  ExtPgm('QUSPTRUS')
     D  $UsrSpc                      20A   CONST
     D  $p_UsrSpc                      *

     D SndPgmMsg       PR                  EXTPGM('QMHSNDPM')
     D  $MsgID                        7A   CONST
     D  $QualNm                      20A   CONST
     D  $MsgDta                     256A   CONST
     D  $MsgDtaLen                   10I 0 CONST
     D  $MsgTyp                      10A   CONST
     D  $CallStck                    10A   CONST
     D  $CallStckCntr                10I 0 CONST
     D  $MsgKey                       4A
     D  $ErrorCode                  256A   OPTIONS(*NOPASS)

     D getExporter     PR            10A   VARYING
     D   pExport                     50A   CONST
     D                                     VARYING

     D mkBllt          PR           256A
     D  pStmt                        92A   CONST

     D toUPPER         PR           132A   VARYING
     D  pStmt                       132A   CONST

     D OffsetPtr       PR              *
     D   pPointer                      *   Value
     D   pOffset                     10I 0 Value

      /COPY QRPGLESRC,IFSPROCS

     �*========================================================================*�
     �*�  Global Data Specifications                                          �*�
     �*========================================================================*�

     D PUBLST          C                   CONST('<b>Public Procedures:  </b>')
     D NONE            C                   CONST('<i>None</i>')
     D sLn             C                   CONST('<tr><td>')
     D eLn             C                   CONST('</td></tr>')
     D bLn             C                   CONST('<br />')

     D f_OUT           S               *
     D outFile         S            256A
     D HTML            S            256A
     D wrtHEAD         S               N
     D HTMLn           S            256A
     D wCnt            S             10I 0
     D wStr            S            132A
     D ndx             S             10I 0
     D ModNames        S             10A    DIM(301)

      * List HEADER (Generic Header for List API's)
     D p_ObjHdr        S               *
     D p_PgmHdr        S               *
     D p_SPgHdr        S               *
     D p_ModHdr        S               *
     D p_LstHdr        S               *
     D LstHdr          DS                   BASED(p_LstHdr)
     D  lhUsrAra                     64A
     D  lhSize                       10I 0
     D  lhDsLvl                       4A
     D  lhFormat                      8A
     D  lhAPI                        10A
     D  lhCrtDT                      13A
     D  lhStatus                      1A                                        I:Incom C:Com P:Part
     D  lhSpcSiz                     10I 0
     D  lhInpOff                     10I 0
     D  lhInpSiz                     10I 0
     D  lhHdrOff                     10I 0
     D  lhHdrSiz                     10I 0
     D  lhLstOff                     10I 0
     D  lhLstSiz                     10I 0
     D  lhEntCnt                     10I 0
     D  lhEntSiz                     10I 0
     D  lhCCSID                      10I 0
     D  lhCntry                       2A
     D  lhLang                        3A
     D  lhSubSet                      1A
     D  lhReserv                     42A

      *  Module List
     D p_ModLst        S               *
     D ModLst_t        DS                   BASED(p_ModLst)                     PGML0100 & SPGL0100
     D  mlName                       10A
     D  mlLibrary                    10A
     D  mlModNm                      10A
     D  mlModLb                      10A
     D  mlSrcFile                    10A
     D  mlSrcLib                     10A
     D  mlSrcMbr                     10A
     D  mlModAtr                     10A
     D  mlModCrtTS                   13A
     D  mlSrcUpdTS                   13A
     D  mlSrtSeqNm                   10A
     D  mlSrtSeqLb                   10A
     D  mlLngID                      10A
     D  mlOptLvl                     10I 0
     D  mlMaxOpt                     10I 0
     D  mlDbgDta                     10A
     D  mlRlsCrtOn                    6A
     D  mlRlsCrtFor                   6A
     D  mlRsrvd                      20A
     D  mlUsrMod                      1A
     D  mlLicPgm                     13A
     D  mlPTFNbr                      5A
     D  mlAPARNbr                     6A
     D  mlUCrtDta                     1A
     D  mlModCCSID                   10I 0
     D  mlJunk                      846A

      *  Module Information - Exports / Procedures
     D p_ModInf        S               *
     D ModInf_t        DS                   BASED(p_ModInf)
     D  miSize                       10I 0                                      MODL0100 & MODL0300
     D  miName                       10A
     D  miLibrary                    10A
     D  miSymTyp                      1A                                        00:PROC  01:DATA/EP
     D  miRsrvd1                      3A
     D  miNmOff                      10I 0
     D  miNmLen                      10I 0
     D  miArgOpt                     10A
     D  miRsrvd2                      1A

     D p_ModSym        S               *
     D miModSymNm      S           2048A    BASED(p_ModSym)

      *  Service Program List
     D p_SPgLst        S               *
     D SPgLst_t        DS                   BASED(p_SPgLst)
     D  slName                       10A                                        PGML0200
     D  slLibrary                    10A
     D  slSPgNm                      10A
     D  slSPgLb                      10A
     D  slSPgSig                     16A

      *  Export List
     D p_ExpLst        S               *
     D ExpLst_t        DS                   BASED(p_ExpLst)
     D  elName                       10A                                        PGML0300 & SPGL0300
     D  elLibrary                    10A
     D  elItmSiz                     10I 0
     D  elNmCCSID                    10I 0
     D  elItmNmLen                   10I 0
     D  elItmNm                     256A

      *  Procedure List
     D p_PrcLst        S               *
     D PrcLst_t        DS                   BASED(p_PrcLst)
     D  plName                       10A                                        SPGL0600
     D  plLibrary                    10A
     D  plPrcCCSID                   10I 0
     D  plPrcNmLen                   10I 0
     D  plPrcNm                     256A
     D  plPrcArgOpt                  10A

     D ModEntry        S             10I 0
     D ModEntries      S             10I 0
     D SPgEntry        S             10I 0
     D SPgEntries      S             10I 0
     D Offset          S             10I 0

     DmiSpcNm          C                   const('LSTMODI   QTEMP     ')
     DolSpcNm          C                   const('LSTOBJR   QTEMP     ')
     DpiSpcNm          C                   const('LSTILEI   QTEMP     ')
     DsiSpcNm          C                   const('LSTSPGI   QTEMP     ')

      * Program Status
     D PROGDS         SDS
     D   PGMQ            *PROC
     D   WSID                244    253
     D   USRID               254    263

      * ERROR CODE Layout
     D ErrCode_t       DS
     D  ecBytes                1      4B 0 INZ(256)
     D  ecAvail                5      8B 0 INZ(0)
     D  ecMSGID                9     15
     D  ecReserv              16     16
     D  ecMSGDTA              17    256

     D MsgKey          S              4A

     �*========================================================================*�
     �*�  Global Procedure Interface                                          �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Global Input Specifications                                         �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Global Code Specifications                                          �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Sub-Procedure Specifications                                        �*�
     �*========================================================================*�

     /**
      * Logic Driver.  Runs in two passes.  First gets general information about
      * the source member, including a list of subroutines and procedures.  The
      * second gets specific information on each subroutine and procedure.
      *  return Error Status.  0 if successfull, -1 if errors occured.
      */
     P SRVDOC          B                   EXPORT

     D SRVDOC          PI            10I 0
     D  pQualName                    20A
     D  pText                        50A

     D rtnCd           S             10I 0
     D SRVPGM          S             10A   VARYING
     D PrcName         S             75A   VARYING

      /free
              rtnCd   = *ZERO;
              wrtHEAD = *ON;
              SRVPGM  = %TRIM(%SUBST(pQualName : 1 : 10));

              outFile = 'SP_' + SRVPGM + '.html' + X'00';
              f_OUT = ifsOpn( outFile : 'w codepage=1252');
              IF  ferror(f_OUT) > *ZERO;
                  CALLP perror('Error on 1st open of IFS file');
              ENDIF;
              ifsCLO( f_OUT );
              IF  ferror(f_OUT) > *ZERO;
                  perror('Error on 1st close of IFS file');
              ENDIF;
              f_OUT = ifsOpn( outFile : 'a+ codepage=37');
              IF  ferror(f_OUT) > *ZERO;
                  perror('Error on 2nd open of IFS file');
              ENDIF;

              ndx      = *ZERO;
              ModNames = *BLANKS;
              CrtUsrSpc(siSpcNm: 'SRVPGM' : 1 : X'00'  :
                        '*ALL'  : 'User Space' : '*YES' :
                        ErrCode_t);
              CrtUsrSpc(miSpcNm: 'MODULE' : 1 : X'00'  :
                        '*ALL'  : 'User Space' : '*YES' :
                        ErrCode_t);

       // Print Description

              HTMLn = '<p><table>';
              EXSR Wrt_HTML;
              HTMLn = sLn + pText + eLn;
              EXSR Wrt_HTML;
              HTMLn = '</table></p>';
              EXSR Wrt_HTML;

       // Get a list of Exported Symbols
       // If no error, print each entry except for known System Objects

              GetSPgInf(siSpcNm : 'SPGL0300' : pQualName : ErrCode_t);

              IF  (ecAvail > *ZERO);
                  SPgEntries = *ZERO;
                  SndPgmMsg(ecMSGID  : 'QCPFMSG   *LIBL     ' :
                            ecMSGDTA : 240 : '*STATUS' :'*EXT':
                            0 : MsgKey : ErrCode_t);
              ELSE;
                  RtvPtrUS (siSpcNm: p_SPgHdr);
                  p_LstHdr = p_SPgHdr;
                  SPgEntries = lhEntCnt;

                  FOR SPgEntry = 1 TO SPgEntries;
                      p_LstHdr = p_SPgHdr;
                      Offset = ((SPgEntry-1) * lhEntSiz) + lhLstOff;
                      p_ExpLst = OffsetPtr(p_LstHdr : Offset);

                      IF  elItmNmLen > *ZERO;
       //                 CDEXPNM  = %SUBST(elItmNm:1:elItmNmLen);
       //                 CDOBJLB  = olLibrary;
       //                 CDOBJNM  = olName;
       //                 CDOBJTY  = olType;
       //                 CDEXPTY  = 'DTA';
       //                 CDEXPFM  = '*UNKNOWN';
                      ENDIF;
                  ENDFOR;

              ENDIF;

       // Get a list of component Modules
       // If no error, print each entry except for known System Objects

              GetSPgInf(siSpcNm : 'SPGL0100' : pQualName : ErrCode_t);

              IF  (ecAvail > *ZERO);
                  SPgEntries = *ZERO;
                  SndPgmMsg(ecMSGID  : 'QCPFMSG   *LIBL     ' :
                            ecMSGDTA : 240 : '*STATUS' :'*EXT':
                            0 : MsgKey : ErrCode_t);
              ELSE;
                  RtvPtrUS (siSpcNm: p_SPgHdr);
                  p_LstHdr = p_SPgHdr;
                  SPgEntries = lhEntCnt;

                  FOR SPgEntry = 1 to SPgEntries;
                      p_LstHdr = p_SPgHdr;
                      Offset = ((SPgEntry-1) * lhEntSiz) + lhLstOff;
                      p_ModLst = OffsetPtr(p_LstHdr : Offset);

                      IF  mlModLb <> 'QSYS      ';
                          ndx           = ndx + 1;
                          ModNames(ndx) = mlModNm;
                      ENDIF;
                  ENDFOR;
              ENDIF;

       // Get a list of Exported Procedures
       // If no error, print each entry except for known System Objects

              GetSPgInf(siSpcNm : 'SPGL0600' : pQualName : ErrCode_t);

              IF  (ecAvail > *ZERO);
                  SPgEntries = *ZERO;
                  SndPgmMsg(ecMSGID  : 'QCPFMSG   *LIBL     ' :
                            ecMSGDTA : 240 : '*STATUS' :'*EXT':
                            0 : MsgKey : ErrCode_t);
              ELSE;
                  HTMLn = '<p><table>';
                  EXSR Wrt_HTML;
                  HTMLn = PUBLST;
                  EXSR Wrt_HTML;
                  RtvPtrUS (siSpcNm: p_SPgHdr);
                  p_LstHdr = p_SPgHdr;
                  SPgEntries = lhEntCnt;

                  IF  SPgEntries < 1;
                      HTMLn = sLn + NONE + eLn;
                      EXSR Wrt_HTML;
                  ENDIF;
                  FOR SPgEntry = 1 TO SPgEntries;
                      p_LstHdr = p_SPgHdr;
                      Offset = ((SPgEntry-1) * lhEntSiz) + lhLstOff;
                      p_PrcLst = OffsetPtr(p_LstHdr : Offset);
                      IF  plPrcNmLen > *ZERO;
                          PrcName = %SUBST(plPrcNm:1:plPrcNmLen);
                          HTMLn = mkBllt('<a href="' + getExporter(PrcName) +
                                         '.html#' + PrcName + '">' + PrcName +
                                         '</a>');
                          EXSR Wrt_HTML;
                      ENDIF;
                  ENDFOR;
                  HTMLn = '</table></p>';
                  EXSR Wrt_HTML;
              ENDIF;

              HTMLn = '</body></html>';                 //Terminate HTML
              EXSR Wrt_HTML;
              ifsCLO( f_OUT );
              IF  ferror(f_OUT) > *ZERO;
                  perror('Error on final close of IFS file');
              ENDIF;

              *INLR = *ON;
              RETURN rtnCd;
      /end-free

     /**
      * Directs writing of the HTML lines.
      */

      /free
              BEGSR Wrt_HTML;

              IF  wrtHEAD;
                  EXSR Wrt_HEAD;
                  wrtHEAD = *OFF;
              ENDIF;

              HTML = HTMLn;
              EXSR Wrt_HTMLOUT;

              ENDSR;
      /end-free

     /**
      * Writes the HTML HEAD section and starts BODY.
      */

      /free
              BEGSR Wrt_HEAD;

              HTML = '<html>';
              EXSR Wrt_HTMLOUT;
              HTML = '<head>';
              EXSR Wrt_HTMLOUT;
              IF  pText = *BLANKS;
                  HTML = '<title>Service Program ' + SRVPGM;
              ELSE;
                  HTML = '<title>Service Program ' + SRVPGM + ' - ' + pText;
              ENDIF;
              HTML = %trim(HTML) + '</title>';
              EXSR Wrt_HTMLOUT;
              HTML = '<meta name="Generator" content="Open Source SRVDOC" />';
              EXSR Wrt_HTMLOUT;
              HTML = '</head>';
              EXSR Wrt_HTMLOUT;
              HTML = '<body>';
              EXSR    Wrt_HTMLOUT;
              HTML = '<h1>Service Program ' + SRVPGM + '</h1>';
              EXSR Wrt_HTMLOUT;

              ENDSR;
      /end-free

     /**
      * Perform actual WRITE to HTMLOUT file.
      */

      /free
              BEGSR Wrt_HTMLOUT;

              ifsWrt( %TRIM( HTML ) + X'25' : f_OUT );
              IF  ferror(f_OUT) > *ZERO;
                  perror('Error on write to IFS file');
              ENDIF;

              ENDSR;
      /end-free

     P SRVDOC          E

     �*========================================================================*�
     �*�  Sub Procedures                                                      �*�
     �*========================================================================*�

     /**
      * Make Bulleted Line.  Adds the HTML to make line a bulleted list item.
      *  param pStmt Statement line to examine
      *  return HTML for a bulletted table row
      */

     P mkBllt          B

     D mkBllt          PI           256A
     D  pStmt                        92A   CONST

      /free
              RETURN '<tr><td>&nbsp;&nbsp;&#149;&nbsp;' + %TRIM(pStmt) +
                                                                   '</td></tr>';
      /end-free

     P                 E

     �*========================================================================*�

     /**
      * Search component modules for the specified Export name.
      *  param 50A Export Name to search for.
      *  return Exporting Module, else *UNKNOWN.
      */

     P getExporter     B

     D getExporter     PI            10A   VARYING
     D   pExport                     50A   CONST
     D                                     VARYING

     D QualMod         S             20A
     D ndx             S             10I 0

      /Free
              FOR ndx = 1 TO 301;
                  IF  ModNames(ndx) = *BLANKS;
                      RETURN 'UNKNOWN';
                  ENDIF;
                  QualMod = ModNames(ndx)  + '*LIBL     ';
                  GetModInf(miSpcNm : 'MODL0300' : QualMod : ErrCode_t);
                  IF  (ecAvail > *ZERO);
                      ModEntries = *ZERO;
                      SndPgmMsg(ecMSGID  : 'QCPFMSG   *LIBL     ' :
                                ecMSGDTA : 240 : '*STATUS' :'*EXT':
                                0 : MsgKey : ErrCode_t);
                  ELSE;
                      RtvPtrUS (miSpcNm : p_ModHdr);
                      p_LstHdr = p_ModHdr;
                      ModEntries = lhEntCnt;
                      Offset = lhLstOff;

                      FOR ModEntry = 1 TO ModEntries;
                          p_LstHdr = p_ModHdr;
                          p_ModInf = OffsetPtr(p_LstHdr : Offset);
                          Offset = Offset + miSize;
                          p_ModSym = OffsetPtr(p_LstHdr : miNmOff);

                          IF  miNmLen > *ZERO AND
                              miSymTyp <> X'01';
                              IF  (pExport = %SUBST(miModSymNm : 1 : miNmLen));
                                  RETURN %TRIM(miName);
                              ENDIF;
                          ENDIF;

                      ENDFOR;
                  ENDIF;
              ENDFOR;

              RETURN '*UNKNOWN';
      /end-Free

     P getExporter     E
     �*========================================================================*�

     /**
      * Calcualte new Pointer based on specified offset.
      *  param   * Address to start at.
      *  param 10I Offset from Address.
      *  return Pointer to new address.
      */

     P OffsetPtr       B

     D OffsetPtr       PI              *
     D   pPointer                      *   Value
     D   pOffset                     10I 0 Value

     D pNewAddr        S               *
     D wkMove          S              1A   DIM(4097) BASED(pNewAddr)

      /Free
              pNewAddr = pPointer;

              IF  pOffset > 0;
                  DOW pOffset > 4096;
                      pNewAddr = %addr( wkMove(4097) );
                      pOffset = pOffset - 4096;
                  ENDDO;
                  pNewAddr = %addr(wkMove(pOffset + 1));
              ENDIF;

              RETURN pNewAddr;
      /end-Free

     P OffsetPtr       E
