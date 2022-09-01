     /**
      * Reads RPGLE source members and creates 'JAVADOC' type  output.
      * Comments (if any) must start on line 1 and before each procedure
      * or subroutine definition.  ('P' spec or 'BEGSR' operation.)
      * Source must have appropriate comments and use prototyped
      * procedure calls for best results.
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
      *  author Chris Wolcott - 23-FEB-05  Added list of Sub-routines
      *  author Chris Wolcott - 16-JUN-06  Added ability to parse /free
      *  author Chris Wolcott - 30-JUL-09  Added extended name support
      *  version V0R1M0
      *  param  pMbr  Source member being documented.
      *  param  pText Text associated with source member.
      *  return Error Status.  0 if successfull, -1 if errors occured.
      */

     H DATFMT(*ISO) TIMFMT(*ISO)
     H OPTION(*SRCSTMT : *NODEBUGIO : *EXPDDS : *SHOWCPY)
     H BNDDIR('QC2LE')

     H NOMAIN                                                                   *MOD
     H*DFTACTGRP(*NO) ACTGRP(*CALLER)                                           *PGM

     H OPTIMIZE(*NONE)                                                          *TST
     H*OPTIMIZE(*FULL)                                                          *PRD
     H DEBUG(*YES)

     HCOPYRIGHT('COPYRIGHT 2004,2005,2006,2009 by Chris Wolcott.  +
     H           ALL RIGHTS RESERVED          +
     H           This program released as Open Source Software under the BSD +
     H           License.          +
     H           See http://www.opensource.org/licenses/bsd-license.php')

     �*========================================================================*�
     �*�  Global File Specifications                                          �*�
     �*========================================================================*�

     FSRCMBR    IF   F32766        DISK    USROPN
     F                                     INFDS(SrcFdBk)
      * Source Member(s)

     �*========================================================================*�
     �*�  Global Procedure Definitions                                        �*�
     �*========================================================================*�

     D RPGDOC          PR            10I 0 EXTPROC('RPGDOC_R')
     D   pMbr                        10A   CONST
     D   pText                       50A   CONST

     D getDocTag       PR            10A
     D  pStmt                        92A   CONST

     D getDocPrm       PR            15A
     D  pStmt                        92A   CONST

     D fmtDocPrm       PR            92A
     D  pStmt                        92A   CONST

     D mkBllt          PR           256A
     D  pStmt                        92A   CONST

     D getOpCode       PR            10A   VARYING
     D  pStmt                              LIKEDS(SRCDTA)

     D getFactor1      PR            14A   VARYING
     D  pStmt                              LIKEDS(SRCDTA)

     D getMsgDsc       PR           132A   VARYING
     D  pStmt                        20A   VALUE

     D isComment       PR             1N
     D  pStmt                              LIKEDS(SRCDTA)

     D wrtHTML         PR
     D  pHTML                       256A   VARYING
     D                                     CONST

     D addDesc         PR
     D  pDesc                       256    CONST

     D rmvColorCd      PR           256    VARYING
     D  pDesc                       256    CONST VARYING

     D rtvMsgD         PR                  EXTPGM('QMHRTVM')
     D  msgInfo                     156A
     D  msgInfoLen                   10I 0
     D  fmtName                       8A
     D  msgID                         7A
     D  qualMsgF                     20A
     D  msgDta                        1A
     D  lenMsgDta                    10I 0
     D  rplSubVal                    10A
     D  rtnFmtCtlChr                 10A
     D  errCd                       256A

     D toUPPER         PR           132A   VARYING
     D  pStmt                       132A   CONST

      /COPY QRPGLESRC,IFSPROCS

     �*========================================================================*�
     �*�  Global Data Specifications                                          �*�
     �*========================================================================*�

     D BADSRC          C                   CONST('Can not open input file')
     D BADTAG          C                   CONST('Unknown Tag encountered')
     D MODLST          C                   CONST('<b>Modification List: </b>')
     D MSGLST          C                   CONST('<b>Message List: </b>')
     D PRMLST          C                   CONST('<b>Parameters: </b>')
     D RTRN            C                   CONST('<b>Returns: </b>')
     D VRSN            C                   CONST('<b>Version: </b>')
     D SUBLST          C                   CONST('<b>Sub-Routines:</b>')
     D PUBLST          C                   CONST('<b>Public&nbsp;Procedures: -
     D                                            </b>')
     D PRILST          C                   CONST('<b>Private&nbsp;Procedures: -
     D                                            </b>')
     D NONE            C                   CONST('<i>None</i>')
     D NOTHNG          C                   CONST('<i>Nothing</i>')
     D sTbl            C                   CONST('<p><table>')
     D sLn             C                   CONST('<tr><td>')
     D eLn             C                   CONST('</td></tr>')
     D eTbl            C                   CONST('</table></p>')
     D bLn             C                   CONST('<br />')

     D UPPER           C                   CONST('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
     D lower           C                   CONST('abcdefghijklmnopqrstuvwxyz')

     D HTML            DS           256
     D                         1    256A

     D SRCDTA          DS           100    EXPORT
     D   DOC_Line              6    100A
     D   DOC_Stmt              9    100A
     D   FREE_Stmt            12    100A
     D   RPG_Spec              6      6A
     D   RPG_Cmt               7      7A
     D   RPG_Line              7    100A
     D   RPG_Stmt              7     80A
     D   RPG_Cmmnts           81    100A
     D** RPG D-Spec fields
     D   RPG_Name              7     21A
     D   RPG_Type             24     25A
     D   RPG_VarD             33     42A
     D   RPG_KeyWrd           44     80A
     D** RPG C-Spec fields
     D   RPG_Fctr1            12     25A
     D   RPG_Opcode           26     35A
     D   RPG_Fctr2            36     49A
     D   RPG_ExtFctr2         36     80A
     D   RPG_Result           50     63A
     D   RPG_RLen             64     68A
     D   RPG_RDPt             69     70A

     D dspMsg          S             50A
     D extendedFieldName...
     D                 S               N
     D mbrNm           S             10A   VARYING
     D mbrTxt          S             50A   VARYING
     D accptDoc        S               N
     D passOne         S               N
     D inCmt           S               N
     D inFree          S               N
     D inIntDef        S               N
     D inJvaDoc        S               N
     D inList          S               N
     D isPgm           S               N
     D isCpy           S               N
     D isPub           S               N
     D isSubRtn        S               N
     D wrtHEAD         S               N
     D thisName        S            100A   VARYING
     D HTMLn           S            256A   VARYING
     D CUR_Tag         S             10A
     D HLD_Tag         S             10A
     D hasParm         S              1N
     D hasRtrn         S              1N
     D hld_SRCSEQ      S              6S 2
     D f_OUT           S               *
     D outFile         S            256A
     D curOpCode       S             10A   VARYING
     D curFactr1       S             14A   VARYING
     D wCnt            S             10I 0
     D wCnt2           S             10I 0
     D wName           S            100A   VARYING
     D wStr            S            132A   VARYING
     D posCmt          S             10I 0

     D desR            S              7P 0
     D HTM_Des         S            256A   DIM(1024)

     D extR            S              7P 0
     D                 DS
     D HTM_Ext                      356A   DIM(1024)
     D   intName                    100A   OVERLAY(HTM_Ext)
     D   extName                    100A   OVERLAY(HTM_Ext:*NEXT)

     D pubR            S              7P 0
     D                 DS
     D HTM_Pub                      356A   DIM(1024)
     D   pubRtrn                     21A   OVERLAY(HTM_Pub)
     D   pubName                    100A   OVERLAY(HTM_Pub:*NEXT)
     D   pubParm                    220A   OVERLAY(HTM_Pub:*NEXT)

     D priR            S              7P 0
     D                 DS
     D HTM_Pri                      356A   DIM(1024)
     D   priRtrn                     21A   OVERLAY(HTM_Pri)
     D   priName                    100A   OVERLAY(HTM_Pri:*NEXT)
     D   priParm                    220A   OVERLAY(HTM_Pri:*NEXT)

     D subR            S              7P 0
     D                 DS
     D HTM_Sub                      256A   DIM(1024)
     D   subName                    100A   OVERLAY(HTM_Sub)

      * Feedback Data Structure
     D SrcFdBk         DS
     D   File            *FILE
     D   OpnInd                9      9N
     D   EofInd               10     10N
     D   StsCd           *STATUS
     D   OpCd            *OPCODE
     D   RtnNm           *ROUTINE
     D   LineNbr              30     37A
     D   RecFmt          *RECORD
     D   FileNm               83     92A
     D   FileLib              93    102A
     D   RecLen              125    126I 0
     D   FileMbr             129    138A

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

     D msgInfo_t       DS
     D  miBytes                      10I 0 INZ(156)
     D  miAvail                      10I 0 INZ(0)
     D  miMsgBytes                   10I 0 INZ(132)
     D  miMsgAvail                   10I 0 INZ(0)
     D  miMsgHlpBytes                10I 0 INZ(0)
     D  miMsgHlpAvail                10I 0 INZ(0)
     D  miMsgTxt                    132A   INZ(*BLANKS)

     �*========================================================================*�
     �*�  Global Procedure Interface                                          �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Global Input Specifications                                         �*�
     �*========================================================================*�

     ISRCMBR    DS
     I                             S    1    6 2SRCSEQ
     I                             S    7   12 0SRCDAT
     I                             A   13  112  SRCDTA

     �*========================================================================*�
     �*�  Global Code Specifications                                          �*�
     �*========================================================================*�

     �*========================================================================*�
     �*�  Sub-Procedure Specifications                                        �*�
     �*========================================================================*�

     /**
      *�Logic Driver.  Runs in two passes.  First gets geenral information about
      *�the source member, including a list of subroutines and procedures.  The
      *�second gets specific information on each subroutine and procedure.
      *� param  pMbr  Source member being documented.
      *� param  pText Text associated with source member.
      *� return Error Status.  0 if successfull, -1 if errors occured.
      */
     P RPGDOC          B                   EXPORT

     D RPGDOC          PI            10I 0
     D   pMbr                        10A   CONST
     D   pText                       50A   CONST

     D rtnCd           S             10I 0

      /free
              mbrNm   = %TRIM(pMbr);
              mbrTxt  = %TRIM(pText);
              rtnCd   = *ZERO;
              isPgm   = *ON;
              isCpy   = *ON;
              inFree  = *OFF;
              passOne = *ON;
              wrtHEAD = *ON;
              extR    = *ZERO;
              pubR    = *ZERO;
              priR    = *ZERO;
              subR    = *ZERO;
              HTM_Ext = *HIVAL;
              HTM_Pub = *HIVAL;
              HTM_Pri = *HIVAL;
              HTM_Sub = *HIVAL;
              EXSR      INIT;
              hld_SRCSEQ = *ZERO;

              OPEN(E)   SRCMBR;
              IF  %ERROR;
                  dspMsg = BADSRC + ' ' + mbrNm;
                  DSPLY    dspMsg;
                  rtnCd = -1;
              ELSE;
                  outFile = %TRIM( FileMbr) + '.html' + X'00';
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

       //�Pass ONE - Collect overall Info on Program/Module

                  EXSR Rd_SRCMBR;
                  EXSR getComments;                        // Get PGM comments
                  DOU %EOF(SRCMBR);                        // Build Primary
                      EXSR    ParseSrc;                    //  descriptive sect.
                      EXSR    Rd_SRCMBR;
                  ENDDO;
                  EXSR    PrintMain;

                  passOne = *OFF;

       //�Pass TWO - Collect spcific info on Procedures/Sub-Routines

                  SETLL   *START SRCMBR;                   //Reset file and
                  desR  = *ZERO;                           // position it to
                  HTM_DES = *HIVAL;                        // code section.
                  hld_SRCSEQ = *ZERO;
                  EXSR Rd_SRCMBR;
                  DOU (%EOF(SRCMBR))
                   OR (RPG_Spec = 'C') OR inFree
                   OR (RPG_Spec = 'P');
                      EXSR  Rd_SRCMBR;
                  ENDDO;

                  DOU %EOF(SRCMBR);                        //Build secondary
                      EXSR ParseSrc;                       // descriptive sect.
                      EXSR Rd_SRCMBR;
                  ENDDO;

                  wrtHTML('</body></html>');               //Terminate HTML
                  ifsCLO( f_OUT );
                  IF  ferror(f_OUT) > *ZERO;
                      perror('Error on final close of IFS file');
                  ENDIF;
                  CLOSE   SRCMBR;
              ENDIF;

              *INLR = *ON;
              RETURN rtnCd;

        //**
        //*�Initialization Routine.  Called at Program entry and after each section
        //*�is printed.  (Generic, Procedure & Subroutine)
        //*/

              BEGSR INIT;

              desR     = *ZERO;
              HTM_Des  = *HIVAL;

              accptDoc = *OFF;
              inCmt    = *OFF;
              inJvaDoc = *OFF;
              inList   = *OFF;
              inIntDef = *OFF;
              isPub    = *ON;
              thisName = *BLANKS;
              HLD_Tag  = *BLANKS;

              ENDSR;

        //**
        //*�Parse source lines.  Output appropriate lines to HTML file for each
        //*�specification type.  Look for the end of Interface definitions if in
        //*�&quot;C&quot; specs or //free.
        //*/

              BEGSR ParseSrc;

              IF  RPG_Spec = 'C' OR inFree;
                  curOpCode = getOpCode(SRCDTA);
              ENDIF;

              IF  inIntDef;

         //�Currently defining an Interface - Is this the end?

                  IF  (RPG_Spec='D' AND RPG_Type <> *BLANKS)
                  OR  ((RPG_Spec='C' OR inFree) AND curOpCode <> 'PARM');
                      IF  inList;
                          HTMLn = HTMLn + ')';
                      ELSE;
                          HTMLn = '(' + NONE + ')';
                      ENDIF;
                      IF  isPub;
                          pubParm(pubR) = HTMLn;
                      ELSE;
                          priParm(priR) = HTMLn;
                      ENDIF;
                      inIntDef = *OFF;
                      inList = *OFF;
                      IF  NOT passOne;
                          isSubRtn = *OFF;
                          EXSR    printMthd;
                      ENDIF;
                  ENDIF;
              ENDIF;

              SELECT;
                WHEN RPG_Spec = 'A';

                WHEN RPG_Spec = 'H';
                  IF  isPgm;
                      IF  (%SCAN('NOMAIN' : toUPPER(RPG_Line)) <> 0)
                      AND (NOT isComment(SRCDTA));
                          isPgm = *OFF;
                      ENDIF;
                  ENDIF;

                WHEN RPG_Spec = 'D';
                  EXSR    DataSpec;

                WHEN RPG_Spec = 'I';
                  isCpy = *OFF;

                WHEN RPG_Spec = 'C' or inFree;
                  isCpy = *OFF;
                  EXSR    CodeSpec;

                WHEN RPG_Spec = 'P';
                  isCpy = *OFF;

                  IF  %SCAN('...' : RPG_LINE) > 1;
                      extendedFieldName = *ON;
                      wName = %SUBST(RPG_LINE : 1 : %SCAN('...' : RPG_LINE)-1);
                  ENDIF;

                  IF  toUPPER(RPG_Type) = 'B ';
                      IF  extendedFieldName;
                          thisName = wName + %TRIM(RPG_Name);
                      ELSE;
                          thisName = %TRIM(RPG_Name);
                      ENDIF;
                      IF  %SCAN('EXPORT': toUPPER(RPG_KeyWrd)) > *ZERO;
                          isPub = *ON;
                      ELSE;
                          isPub = *OFF;
                      ENDIF;
                      IF  NOT passOne;
                           EXSR    getComments;
                      ENDIF;
                      extendedFieldName = *OFF;
                  ENDIF;
                  IF  toUPPER(RPG_Type) = 'E ';
                      extendedFieldName = *OFF;
                  ENDIF;

                WHEN RPG_Spec = 'O';
                  isCpy = *OFF;
              ENDSL;

              ENDSR;

        //**
        //*�Process CALCULATION specs.  Look for beginning of SubRoutines and handle
        //*�interface definitions for *PLIST entries.
        //*/

              BEGSR CodeSpec;

              IF  curOpCode = 'BEGSR';
                  IF  passOne;
                      subR = subR + 1;
                      subName(subR) = getFactor1(SRCDTA);
                  ELSE;
                      isSubRtn = *ON;
                      thisName = getFactor1(SRCDTA);
                      EXSR    getComments;
                      EXSR    printMthd;
                  ENDIF;
              ENDIF;

              IF  curOpCode = 'ENDSR';
                  isSubRtn = *OFF;
              ENDIF;

              IF  inIntDef;                                // In PLIST sect -
                  IF  curOpCode = 'PARM';                  // List all ACTIVE
                      IF  NOT isComment(SRCDTA);           //  paramters until
                          IF  inList;                      //  PLIST sect ends.
                              HTMLn = HTMLn + ' : ';       // 2nd+ parm in list
                          ELSE;
                              HTMLn = HTMLn + '(';         // 1st parm in list
                              inList = *ON;
                          ENDIF;
                          addDesc( mkBllt(RPG_Result) );
                          IF  RPG_RDPt = *BLANKS;
                              IF   RPG_RLen = *BLANKS;
                                  HTMLn = HTMLn + ' NotDef ';
                              ELSE;
                                  HTMLn = HTMLn + ' ' + %TRIM(RPG_RLen) + 'A';
                              ENDIF;
                          ELSE;
                              HTMLn = HTMLn + ' ' + %TRIM(RPG_RLen) + 'S' +
                                                                       RPG_RDPt;
                          ENDIF;
                      ENDIF;
                  ELSE;
                      inIntDef = *OFF;
                      inList   = *OFF;
                  ENDIF;
              ENDIF;

              IF  curOpCode = 'PLIST'                      // Only *ENTRY PLIST
              AND toUPPER(RPG_Fctr1) = '*ENTRY';           // is needed.  Any
                  isPub = *ON;                             // others are calls.
                  pubR = pubR + 1;
                  pubRtrn(pubR) = NOTHNG;
                  pubName(pubR) = '*ENTRY';
                  inIntDef = *ON;
                  IF  desR <= *ZERO
                  OR  HTM_Des(desR) = eTbl;
                      addDesc(sTbl);
                  ENDIF;
                  addDesc(sLn + '&nbsp;' + eLn);
                  addDesc(sLn + PRMLST + eLn);
              ENDIF;

              ENDSR;

        //**
        //*�Process DATA specs.  Handle Interface definitions, etc.
        //*/

              BEGSR DataSpec;

              IF  %SCAN('...' : RPG_LINE) > 1;
                  extendedFieldName = *ON;
                  wName = %SUBST(RPG_LINE : 1 : %SCAN('...' : RPG_LINE)-1);
              ENDIF;

              IF  inIntDef AND RPG_Type = *BLANK           // In PI section -
              AND NOT isComment(SRCDTA);                   // List all ACTIVE
                  IF  RPG_Name = *BLANK;   // Continuation //  parms until end.
                  ELSE;
                      IF  RPG_VarD = *BLANK;
                          IF  %SCAN('LIKE('    : toUPPER(RPG_KeyWrd)) > *ZERO
                          OR  %SCAN('LIKEDS('  : toUPPER(RPG_KeyWrd)) > *ZERO
                          OR  %SCAN('LIKEREC(' : toUPPER(RPG_KeyWrd)) > *ZERO
                          OR  %SCAN('EXTFMT('  : toUPPER(RPG_KeyWrd)) > *ZERO;
                              RPG_VarD = 'LikeRef';
                          ELSE;
                              RPG_VarD = NONE;
                          ENDIF;
                      ELSE;
                          IF  %SUBST(RPG_VarD : 8 : 1) = *BLANK;
                              IF  %SUBST(RPG_VarD : 9 : 2) = *BLANK;
                                  %SUBST(RPG_VarD : 8 : 1) = 'A';
                              ELSE;
                                  %SUBST(RPG_VarD : 8 : 1) = 'P';
                              ENDIF;
                          ENDIF;
                      ENDIF;
                      IF  inList;                          // Continue PI HTML
                          HTMLn = HTMLn + ' : ' + %TRIM(RPG_VarD); // 2nd parm
                      ELSE;
                          HTMLn = '(' + %TRIM(RPG_VarD);           // 1st parm
                          inList = *ON;
                      ENDIF;
                  ENDIF;
              ENDIF;

              SELECT;
                WHEN toUPPER(RPG_Type) = 'PR';
                  extR = extR + 1;
                  intName(extR) = %TRIM(RPG_Name);
                  wStr = toUpper(RPG_KeyWrd);
                  wCnt = %SCAN('EXTPROC' : wStr);
                  IF  wCnt > *ZERO;
                      wCnt2 = %SCAN(')' : wStr : wCnt);
                      wCnt  = %SCAN('(' : wStr : wCnt) + 1;
                      wCnt2 = wCnt2 - wCnt - 1;
                      IF  %SCAN('*JAVA' : wStr : wCnt) > *ZERO;
                          extName(extR) = 'JAVA Class';
                      ELSE;
                          extName(extR) = %TRIM(
                                          %XLATE('''' : ' ' :
                                          %SUBST(%TRIM(RPG_KeyWrd) :
                                                              wCnt : wCnt2) ) );
                      ENDIF;
                  ELSE;
                      extName(extR) = intName(extR);
                  ENDIF;

                WHEN toUPPER(RPG_Type) = 'PI';             // Start of PI section
                  IF  RPG_VarD = *BLANK;                   // Determine rtrn Cde
                      IF  %SCAN('LIKE('    : toUPPER(RPG_KeyWrd)) > *ZERO
                      OR  %SCAN('LIKEDS('  : toUPPER(RPG_KeyWrd)) > *ZERO
                      OR  %SCAN('LIKEREC(' : toUPPER(RPG_KeyWrd)) > *ZERO
                      OR  %SCAN('EXTFMT('  : toUPPER(RPG_KeyWrd)) > *ZERO;
                          HTMLn = 'LikeRef';
                      ELSE;
                          HTMLn = NOTHNG;
                      ENDIF;
                  ELSE;
                      IF  %SUBST(RPG_VarD : 8 : 1) = *BLANK;
                          IF  %SUBST(RPG_VarD : 9 : 2) = *BLANK;
                              %SUBST(RPG_VarD : 8 : 1) = 'A';
                          ELSE;
                              %SUBST(RPG_VarD : 8 : 1) = 'P';
                          ENDIF;
                      ENDIF;
                      HTMLn = %TRIM(RPG_VarD);
                  ENDIF;
                  IF  isPub;                               // Start HTML for PI
                      pubR = pubR + 1;
                      pubRtrn(pubR) = HTMLn;
                      IF  extendedFieldName;
                          pubName(pubR) = wName + %TRIM(RPG_Name);
                      ELSE;
                          pubName(pubR) = %TRIM(RPG_Name);
                      ENDIF;
                  ELSE;
                      priR = priR + 1;
                      priRtrn(priR) = HTMLn;
                      IF  extendedFieldName;
                          priName(priR) = wName + %TRIM(RPG_Name);
                      ELSE;
                          priName(priR) = %TRIM(RPG_Name);
                      ENDIF;
                  ENDIF;
                  inIntDef = *ON;
                  extendedFieldName = *OFF;
              ENDSL;

              ENDSR;

        //**
        //*�Print Program/Module Section.  Print description and handle and
        //*�comment tags.  Also include lists of any Public/Private procedures
        //*�and subroutines.
        //*/

              BEGSR printMain;

              FOR wCnt = 1 to desR;                        // Description
                  wrtHTML(HTM_Des(wCnt));
              ENDFOR;

              IF  NOT isCpy;
                  EXSR printLists;
              ENDIF;

              ENDSR;

       //**
       //*�Prints the lists of Private & Public procedures as well as
       //*�a list of sub-routines (if any).
       //*/

              BEGSR printLists;

              wrtHTML(sTbl);
              wrtHTML(sLn + PUBLST + eLn);                 // Public Methods
              IF  pubR = *ZERO;
                  wrtHTML( mkBllt(NONE) );
              ELSE;
                  FOR wCnt = 1 TO pubR;
                      wStr = %TRIM(pubName(wCnt));
                      FOR wCnt2 = 1 to extR;
                          IF  pubName(wCnt) = intName(wCnt2);
                              wStr = %TRIM(extName(wCnt2));
                              LEAVE;
                          ENDIF;
                      ENDFOR;
                      wrtHTML(mkBllt(%TRIM(pubRtrn(wCnt)) + ' <a href="#' +
                              wStr + '">' + %TRIM(pubName(wCnt)) + '</a>' +
                              pubParm(wCnt)) );
                  ENDFOR;
              ENDIF;
              wrtHTML(eTbl);

              wrtHTML(sTbl);
              wrtHTML(sLn + PRILST + eLn);                 // Private Methods
              IF  priR = *ZERO;
                  wrtHTML( mkBllt(NONE) );
              ELSE;
                  FOR wCnt = 1 TO priR;
                      wrtHTML(mkBllt(%TRIM(priRtrn(wCnt))+' <a href="#' +
                              %TRIM(priName(wCnt)) + '">' +
                              %TRIM(priName(wCnt)) + '</a>' + priParm(wCnt)) );
                  ENDFOR;
              ENDIF;
              wrtHTML(eTbl);

              wrtHTML(sTbl);
              wrtHTML(sLn + SUBLST + eLn);                 // Sub-Routines
              IF  subR = *ZERO;
                  wrtHTML( mkBllt(NONE) );
              ELSE;
                  FOR wCnt = 1 TO subR;
                      wrtHTML(mkBllt('<a href="#' +
                              %TRIM(subName(wCnt)) + '">' +
                              %TRIM(subName(wCnt)) + '</a>') );
                  ENDFOR;
              ENDIF;
              wrtHTML(eTbl);
              wrtHTML('<hr><br />');

              IF  isPgm;                                   // Show Pub Entry
                  wrtHTML('<a name="' + %TRIM(pubName(1)) +
                         '"><table width="100%" height="35pt" ' +
                         'bgcolor="#eeeeee"><tr><td>' +
                         %TRIM(pubRtrn(1)) + '<strong> '   +
                         %TRIM(pubName(1)) + '</strong > ' +
                         %TRIM(pubParm(1)) );
                  wrtHTML('</td></tr></table></a>');
                  wrtHTML('<small>[public]</small>');

                  IF  (desR > *ZERO)
                  AND (%SUBST(HTM_Des(desR) : 1 : 8) = sLn);
                      addDesc(eTbl);
                  ENDIF;
                  inList = *ON;
                  FOR wCnt = 1 TO desR;
                      IF  %SCAN(': </b>' : HTM_Des(wCnt)) > *ZERO;
                          inList = *OFF;
                      ENDIF;
                      IF  %SCAN(PRMLST : HTM_Des(wCnt)) <> *ZERO
                      OR  %SCAN(RTRN   : HTM_Des(wCnt)) <> *ZERO;
                          inList = *ON;
                      ENDIF;
                      IF  inList;
                          wrtHTML(HTM_Des(wCnt));
                      ENDIF;
                  ENDFOR;
              ENDIF;

              EXSR    INIT;

              ENDSR;
      /end-free

     /**
      *�Print Procedure Section.  Print description and handle and comment tags.
      */

      /free
              BEGSR printMthd;

         //�%LOOKUP does not work on Arrays subFields.  (DIMed DS's)

              IF  isSubRtn;
                  wrtHTML('<a name="' + %TRIM(thisName) +
                          '"><table width="100%" height="35pt" ' +
                          'bgcolor="#eeeeee"><tr><td><strong>' +
                          %TRIM(thisName) + '</td></tr></table></a>' );
                  wrtHTML('<small>[sub-routine]</small>');
              ELSE;
                  FOR wCnt = 1 TO pubR;
                      IF  thisName = pubName(wCnt);
                          wStr = %TRIM(thisName);
                          FOR wCnt2 = 1 to extR;
                              IF  thisName = intName(wCnt2);
                                  wStr = %TRIM(extName(wCnt2));
                                  LEAVE;
                              ENDIF;
                          ENDFOR;
                          wrtHTML('<a name="' + wStr +
                                  '"><table width="100%" height="35pt" ' +
                                  'bgcolor="#eeeeee"><tr><td>' +
                                  %TRIM(pubRtrn(wCnt)) + '<strong> '  +
                                  %TRIM(pubName(wCnt)) + '</strong> ' +
                                 %TRIM(pubParm(wCnt))+'</td></tr></table></a>');
                          wrtHTML('<small>[public]</small>');
                          LEAVE;
                      ENDIF;
                  ENDFOR;
                  FOR wCnt = 1 TO priR;
                      IF  thisName = priName(wCnt);
                          wrtHTML('<a name="' + %TRIM(priName(wCnt)) +
                                  '"><table width="100%" height="35pt" ' +
                                  'bgcolor="#eeeeee"><tr><td>' +
                                  %TRIM(priRtrn(wcnt)) + '<strong> '  +
                                  %TRIM(priName(wCnt)) + '</strong> ' +
                                 %TRIM(priParm(wCnt))+'</td></tr></table></a>');
                          wrtHTML('<small>[private]</small>');
                          LEAVE;
                      ENDIF;
                  ENDFOR;
              ENDIF;

              IF  desR = *ZERO;
                  wrtHTML('&nbsp;');
              ELSE;
                  FOR wCnt = 1 TO desR by 1;
                      wrtHTML(HTM_Des(wCnt));
                  ENDFOR;
              ENDIF;

              EXSR    INIT;

              ENDSR;
      /end-free

     /**
      *�Get Comments.  If a Subroutine or Procedure is found, rewind the source
      *�member to get any comments that may be associated with it.
      */

      /free
              BEGSR getComments;

              hld_SRCSEQ = SRCSEQ;
              IF  SRCSEQ > 1;
                  DOU %EOF(SRCMBR)
                   OR NOT (isComment(SRCDTA) OR toUPPER(RPG_Name) = '/FREE');
                      EXSR    Rp_SRCMBR;
                  ENDDO;
              ENDIF;

              accptDoc = *ON;
              desR = *ZERO;
              HTM_Des = *HIVAL;

              DOW NOT %EOF(SRCMBR)                         // Ignore any 'H'
              AND RPG_Spec = 'H'  AND RPG_Cmt <> '*';      // specs before
                  EXSR    Rd_SRCMBR;                       // comment block.
              ENDDO;

              DOU %EOF(SRCMBR)
               OR NOT isComment(SRCDTA);

                  SELECT;
                    WHEN AccptDoc
                     AND (DOC_LINE= '/**  ' OR (%SCAN('//**  ': DOC_Line) > 0));
                      inJvaDoc = *ON;                      // Start JAVADOC Cmt
                      inCmt    = *OFF;                     // Delete any old style
                      desR     = *ZERO;                    //  comment bock
                      HTM_Des  = *HIVAL;
                      hasParm  = *OFF;
                      hasRtrn  = *OFF;
                      addDesc(sTbl);

                    WHEN inJvaDoc;
                      IF  (%SCAN('//*/  ': DOC_Line) > 0)
                      OR  %SUBST(DOC_Line:2:6) = '*/    ';
                          accptDoc = *OFF;
                          EXSR    endJvaDoc;
                      ELSE;                                // In JAVADOC Cmt
                          EXSR    parseJVADOC;
                      ENDIF;

                    WHEN accptDoc AND isComment(SRCDTA);
                      IF  NOT inCmt;
                          inCmt    = *ON;
                          hasParm  = *OFF;
                          hasRtrn  = *OFF;
                          addDesc(sTbl + sLn + %TRIM(rmvColorCd(DOC_Line))+eLn);
                      ENDIF;
                      IF  RPG_Cmt = '*';
                          addDesc(sLn + %TRIM(rmvColorcd(DOC_STMT)) + eLn);
                      ELSE;
                          addDesc(sLn + %TRIM(rmvColorCd(FREE_STMT)) + eLn);
                      ENDIF;
                  ENDSL;

                  EXSR    Rd_SRCMBR;
              ENDDO;

              IF  inCmt                                    // End old style
              AND NOT isComment(SRCDTA);                   //  comment block
                  inCmt    = *OFF;
                  accptDoc = *OFF;
                  addDesc(eTbl);
              ENDIF;

              DOW SRCSEQ < hld_SRCSEQ
              AND NOT %EOF(SRCMBR);
                  EXSR    Rd_SRCMBR;
              ENDDO;

              ENDSR;
      /end-free

     /**
      *�Parse the JAVADOC comments.  Look for each supported tag and output the
      *�appropriate lines to the HTML file.
      */

      /free
              BEGSR parseJVADOC;

              CUR_Tag = getDocTag(DOC_Stmt);
              IF  inFree;
                  posCmt = 12;
              ELSE;
                  posCmt = 09;
              ENDIF;

              IF  CUR_Tag <> HLD_Tag;                      // Place a blank line
                  addDesc(sLn + '&nbsp;' + eLn);
                  inList = *OFF;
              ENDIF;

              SELECT;
                WHEN CUR_Tag = ' author   ';
                  IF  NOT inList;
                      inList = *ON;
                      addDesc(sLn + MODLST + eLn);
                  ENDIF;
                  addDesc( mkBllt(%SUBST(DOC_Stmt : posCmt)) );

                WHEN CUR_Tag = ' param    '
                  OR CUR_Tag = ' parm     ';
                    hasParm  = *ON;
                    IF  NOT inList;
                        inList = *ON;
                        addDesc(sLn + PRMLST + eLn);
                    ENDIF;
                    addDesc( mkBllt(fmtDocPrm(DOC_Stmt)) );

                  WHEN CUR_Tag = ' return   '
                    OR CUR_Tag = ' returns  ';
                    hasRtrn  = *ON;
                    IF  hasParm = *OFF;
                        hasParm = *ON;
                        addDesc(sLn + PRMLST + eLn);
                        addDesc( mkBllt(NONE) );
                        addDesc(sLn + '&nbsp;' + eLn);
                    ENDIF;
                    addDesc(sLn + RTRN + %TRIM(%SUBST(DOC_Stmt : posCmt))+ eLn);

                WHEN CUR_Tag = ' see      ';
                  addDesc(sLn + '<i>See also</i> </b><a href="' +
                          %TRIM(getDocPrm(DOC_Stmt)) + '.html">' +
                          %TRIM(getDocPrm(DOC_Stmt)) + '</a>' + eLn);

                WHEN CUR_Tag = ' throws   ';
                    IF  hasParm = *OFF AND hasRtrn = *OFF;
                        hasParm = *ON;
                        hasRtrn = *ON;
                        addDesc(sLn + PRMLST + eLn);
                        addDesc( mkBllt(NONE) );
                        addDesc(sLn + '&nbsp;' + eLn);
                        addDesc(sLn + RTRN + NOTHNG + eLn);
                    ENDIF;
                    IF  NOT inList;
                        inList = *ON;
                        addDesc(sLn + MSGLST + eLn);
                    ENDIF;
                    addDesc( mkBllt( getMsgDsc( %SUBST(DOC_Stmt : posCmt) ) ) );

                WHEN CUR_Tag = ' version  ';
                    addDesc(sLn +VRSN+%TRIM(%SUBST(DOC_Stmt:posCmt + 1)) + eLn);

                OTHER;
                  IF  %SUBST(CUR_Tag : 1 : 1) = ' ';
                      dspMsg = mbrNm + ': ' +BADTAG + ' ' + Cur_Tag;
                      DSPLY    dspMsg;
                      addDesc(sLn + 'INVALID TAG: ' + %TRIMR(DOC_Stmt) + eLn);
                  ELSE;
                      IF  RPG_Cmt = '*';
                          addDesc(sLn + %TRIM(rmvColorcd(DOC_Stmt))  + eLn);
                      ELSE;
                          addDesc(sLn + %TRIM(rmvColorCd(FREE_Stmt)) + eLn);
                      ENDIF;
                  ENDIF;
              ENDSL;

              HLD_Tag = CUR_Tag;

              ENDSR;
      /end-free

     /**
      *�Ends processing of the JAVADOC statements
      */

      /free
              BEGSR endJvaDoc;

              inJvaDoc = *OFF;

              IF  hasParm = *OFF;
                  hasParm = *ON;
                  IF  isSubRtn;
                      addDesc(sLn + '&nbsp;' + eLn);
                  ELSE;
                      addDesc(sLn + PRMLST + eLn);
                      addDesc( mkBllt(NONE) );
                  ENDIF;
              ENDIF;

              IF  hasRtrn = *OFF;
                  hasRtrn = *ON;
                  addDesc(sLn + '&nbsp;' + eLn);
                  IF  NOT isSubRtn;
                      addDesc(sLn + RTRN + NOTHNG + eLn);
                  ENDIF;
              ENDIF;

              addDesc(eTbl);
              inList = *OFF;

              ENDSR;
      /end-free

     /**
      *�Perform actual READ of SRCMBR file.
      */

      /free
              BEGSR Rd_SRCMBR;

              READ     SRCMBR;

              IF  toUPPER(RPG_Name) = '/FREE ';
                  inFree = *ON;
              ELSE;
                  IF  inFree AND (toUPPER(RPG_Name) = '/END-FREE');
                      inFree = *OFF;
                  ENDIF;
              ENDIF;
              RPG_Spec = toUPPER(RPG_Spec);

              ENDSR;
      /end-free

     /**
      *�Perform actual READ PREVIOUS of SRCMBR file.
      */

      /free
              BEGSR Rp_SRCMBR;

              READP     SRCMBR;

              IF  toUPPER(RPG_Name) = '/FREE ';
                  inFree = *OFF;
              ELSE;
                  IF  inFree AND (toUPPER(RPG_Name) = '/END-FREE');
                      inFree = *ON;
                  ENDIF;
              ENDIF;
              RPG_Spec = toUPPER(RPG_Spec);

              ENDSR;
      /end-free

     P RPGDOC          E

     �*========================================================================*�
     �*�  Sub Procedures                                                      �*�
     �*========================================================================*�

     /**
      *�Gets the JVADOC Tag (if any) from the current line
      *� param pStmt Statement line to examine
      *� return Current Tag, else *BLANKS
      */

     P getDocTag       B

     D getDocTag       PI            10A
     D  pStmt                        92A   CONST

     D bgnTag          S              7P 0
     D endTag          S              7P 0
     D curTag          S             10A

      /free
              curTag = *BLANKS;
              bgnTag = %SCAN(' ' : pStmt : 1);
              IF  bgnTag > *ZERO;
                  endTag = %SCAN(' ' : pStmt : bgnTag);
                  curTag = %SUBST(pStmt : bgnTag : endTag);
              ENDIF;

              RETURN %XLATE(UPPER : lower : curTag);
      /end-free

     P                 E

     �*========================================================================*�

     /**
      *�Gets the Parameter Name from the current line
      *� param pStmt Statement line to examine
      *� return Parameter Name else *BLANKS
      */

     P getDocPrm       B

     D getDocPrm       PI            15A
     D  pStmt                        92A   CONST

     D bgnPos          S              7P 0
     D endPos          S              7P 0
     D parmNm          S             15A

      /free
              parmNm = *BLANKS;
              bgnPos = %SCAN(' ':pStmt:1);
              bgnPos = %SCAN(' ':pStmt:bgnPos);
              DOW bgnPos < 92
              AND %SUBST(pStmt:bgnPos:1) = *BLANK;
                  bgnPos = bgnPos + 1;
              ENDDO;
              endPos = %SCAN(' ':pStmt:bgnPos);
              IF  endPos <= bgnPos
              OR  endPos  > 92;
                  parmNm = *BLANKS;
              ELSE;
                  parmNm = %SUBST(pStmt:bgnPos:endPos);
              ENDIF;

              RETURN parmNm;
      /end-free

     P                 E

     �*========================================================================*�

     /**
      *�Gets a formated parameter description. 'parm : definition'
      *� param pStmt Statement line to examine
      *� return Parameter Name else *BLANKS
      */

     P fmtDocPrm       B

     D fmtDocPrm       PI            92A
     D  pStmt                        92A   CONST

     D bgnPos          S              7P 0
     D endPos          S              7P 0
     D wrkLen          S              7P 0
     D prmDef          S             92A

      /free
              bgnPos = %SCAN(' ':pStmt:1);                 // Find ' param'
              endPos = %SCAN(' ':pStmt:bgnPos);

              bgnPos = endPos;                             // Skip *BLANKS to
              DOW bgnPos < 256                             // find Parm Name
              AND %SUBST(pStmt:bgnPos:1) = *BLANK;
                  bgnPos = bgnPos + 1;
              ENDDO;
              endPos = %SCAN(' ':pStmt:bgnPos);

              wrkLen = endPos - bgnPos;
              prmDef = %SUBST(pStmt:bgnPos:wrkLen);        // Parse Parm Name
              %SUBST(prmDef:16:1) = ':';

              %SUBST(prmDef:18)=%TRIM(%SUBST(pStmt:endPos));

              RETURN prmDef;
      /end-free

     P                 E

     �*========================================================================*�

     /**
      *�Make Bulleted Line.  Adds the HTML to make line a bulleted list item.
      *� param pStmt Statement line to examine
      *� return HTML for a bulletted table row
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
      *�Looks for OPCODE in //free or non-//free source lines.  If it is a 'C'
      *�specification, the OPERATION value is returned.  If //free, then return
      *�first non-blank value unless there is an '=', then return 'EVAL'.
      *� param pStmt Statement line to examine
      *� return OPCODE in UPPERCASE else blank
      */

     P getOpCode       B

     D getOpCode       PI            10A   VARYING
     D  pStmt                              LIKEDS(SRCDTA)

     D opCode          S             10A   VARYING
     D pos             S             10I 0

      /free
              %LEN(opCode) = 0;
              IF  RPG_Spec = 'C';
                  opCode = RPG_Opcode;
              ELSE;
                  IF  inFree
                  AND NOT isComment(pStmt);
                      IF  %SCAN('=' : RPG_Stmt) > *ZERO;
                          opCode = 'EVAL';
                      ELSE;
                          pos = %CHECK('; ' : RPG_Line);
                          IF  pos > *ZERO;
                              opCode = %SUBST(RPG_Line : pos :
                                             %SCAN(' ' : RPG_Line : pos) - pos);
                          ENDIF;
                      ENDIF;
                  ELSE;
                      opCode = *BLANK;
                  ENDIF;
              ENDIF;

              RETURN toUPPER(opCode);
      /end-free

     P getOpCode       E

     �*========================================================================*�

     /**
      *�Looks for FACTOR 1 in //free or non-//free source lines.  If it is a 'C'
      *�specification, the FACTOR 1 value is returned.  If //free, then return
      *�first non-blank value after the current Opcode.
      *� param pStmt Statement line to examine
      *� return FACTOR 1 in original case else blank if no FACTOR 1 found
      */

     P getFactor1      B

     D getFactor1      PI            14A   VARYING
     D  pStmt                              LIKEDS(SRCDTA)

     D factr1          S             14A   VARYING
     D pos             S             10I 0
     D len             S             10I 0
     D wLine           S            100A   VARYING

      /free
              factr1 = *BLANKS;
              IF  RPG_Spec = 'C';
                  factr1 = RPG_Fctr1;
              ELSE;
                  IF  inFree
                  AND NOT isComment(pStmt);
                      wLine = toUPPER(RPG_Line);
                      pos = %SCAN(curOpCode : wLine) + %LEN(CurOpCode);
                      pos = %CHECK('; ' : wLine : pos);
                      IF  pos > *ZERO;
                          len = %SCAN(';' : wLine);
                          IF  len < 1;
                              len = %LEN(wLine);
                          ENDIF;
                          factr1 = %TRIM(%SUBST(%TRIM(RPG_Line):pos:len - pos));
                      ENDIF;
                  ELSE;
                      factr1 = *BLANK;
                  ENDIF;
              ENDIF;

              RETURN factr1;
      /end-free

     P getFactor1      E

     �*========================================================================*�

     /**
      *�Get Message Description.  Calls API to retrieve text of message in a
      *�message file.  Used to populate *THROWS tag output.
      *� param pStmt Statement line to examine
      *� return MSGF(MSGID) - MSG TEXT
      */

     P getMsgDsc       B

     D getMsgDsc       PI           132A   VARYING
     D  pStmt                        20A   VALUE

     D                 DS
     D  qualMsgF                     20A
     D    msgFN                      10A   OVERLAY(qualMsgF)
     D                               10A   OVERLAY(qualMsgF : *NEXT)
     D                                     INZ('*LIBL     ')
     D  msgTxt         S            132A   VARYING

     D msgInfo_t       DS
     D  miBytes                      10I 0 INZ(156)
     D  miAvail                      10I 0 INZ(0)
     D  miMsgBytes                   10I 0 INZ(132)
     D  miMsgAvail                   10I 0 INZ(0)
     D  miMsgHlpBytes                10I 0 INZ(0)
     D  miMsgHlpAvail                10I 0 INZ(0)
     D  miMsgTxt                    132A   INZ(*BLANKS)

     D msgID           S              7A
     D fmtName         S              8A   INZ('RTVM0100')
     D szMsgInfo       S             10I 0 INZ(%SIZE(msgInfo_t))
     D SPACE           S              1A   INZ(*BLANK)
     D ZERO            S             10I 0 INZ(*ZERO)
     D YES             S             10A   INZ('*YES      ')
     D NO              S             10A   INZ('*NO       ')

      /free
              MONITOR;
                  msgFN = %SUBST(pStmt : 1 : %SCAN('(' : pStmt) - 1);
                  msgID = %SUBST(pStmt : %SCAN('(' : pStmt) + 1 : 7);
                  rtvMsgD( msgInfo_t : szMsgInfo : fmtName : msgID :
                           qualMsgF  : SPACE : ZERO : NO : YES : errCode_t);

                  IF  ecAvail > *ZERO;
                      msgTxt = ecMSGID + ' received trying to get test';
                  ELSE;
                      msgTxt = %SUBST(miMsgTxt : 1 : miMsgAvail);
                  ENDIF;
              ON-ERROR;
                  msgTxt = 'Invalid MsgFile specification in Source File';
              ENDMON;

              RETURN %TRIM(pStmt) + ' - ' + msgTxt;
      /end-free

     P getMsgDsc       E

     �*========================================================================*�

     /**
      *�Force UPPERCASE.  Trims and converts string to be UPPERCASE.
      *� param pStmt Word to convert
      *� return Word in UPPERCASE
      */

     P toUPPER         B

     D toUPPER         PI           132A   VARYING
     D  pStmt                       132A   CONST

     D UP              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'

      /free
              RETURN %XLATE(lo : UP : %TRIM(pSTMT));
      /end-free

     P toUPPER         E

     �*========================================================================*�

     /**
      *�Determines if line is a comment line.  Depending if source is in /FREE
      *�or not, check for a '*' in position 7 or scan for '//' as the first
      *�characters in the line.  Blank lines are concidered a Comment.
      *� param pStmt Statement line to examine
      *� return True if a comment, False if not.
      */

     P isComment       B

     D isComment       PI             1N
     D  pStmt                              LIKEDS(SRCDTA)

     D isCmt           S               N
     D posCmt          S             10I 0

      /free
              isCmt = *OFF;

              SELECT;
                WHEN inFree;
                  posCmt = %SCAN('//' : RPG_Line);
                  IF  posCmt > *ZERO
                  AND posCmt = %CHECK(' ' : RPG_Line);
                      isCmt = *ON;
                  ELSE;
                      IF  RPG_Line = *BLANKS;
                          isCmt = *ON;
                      ENDIF;
                  ENDIF;
                WHEN NOT inFree;
                  IF  RPG_Cmt = '*' OR RPG_Line = *BLANKS;
                      isCmt = *ON;
                  ENDIF;
              ENDSL;

              RETURN isCmt;
      /end-free

     P isComment       E

     �*========================================================================*�

     /**
      *�Adds line to Description array.
      *� param pDesc Description to enter.
      */

     P addDesc         B

     D addDesc         PI
     D  pDesc                       256    CONST

     D  wDesc          S            256

      /free
              IF  %SUBST(pDesc : 1 : 1) < *BLANK;     // Remove COLOR codes...
                  wDesc = %SUBST(pDesc : 2 : 255);
              ELSE;
                  wDesc = pDesc;
              ENDIF;

              desR = desR + 1;
              IF  desR < 1025;
                  HTM_Des(desR) = wDesc;
              ENDIF;

              RETURN;
      /end-free

     P addDesc         E

     �*========================================================================*�

     /**
      *�Replaces all 5250 color codes with a blank.
      *� param pDesc Line to work with.
      *� return Line with any color codes replaced by blanks.
      */

     P rmvColorCd      B

     D rmvColorCd      PI           256A   VARYING
     D  pDesc                       256A   CONST VARYING

     D EVER            S             10I 0
     D ndx             S             10I 0
     D pos             S             10I 0
     D rtnVal          S            256A   VARYING

     D                 DS
     D ColorCds                            INZ(X'20212223242628292A2C+
     D                                           303132333638393A3B3C3E')
     D ColorCd                        1A   OVERLAY(ColorCds) DIM(21)

      /free
              rtnVal = pDesc;
              FOR ndx = 1 TO 21 BY 1;
                  pos = 1;
                  FOR EVER;
                      pos = %SCAN(ColorCd(ndx) : rtnVal : pos);
                      IF  pos = *ZERO;
                          LEAVE;
                      ELSE;
                          %SUBST(rtnVal : pos : 1) = ' ';
                      ENDIF;
                  ENDFOR;
              ENDFOR;

              RETURN rtnVal;
      /end-free

     P rmvColorCd      E

     �*========================================================================*�

     /**
      *�Outputs HTML to output File.  If header has no been written, writes it
      *�first then writes the HTML line.
      *� param pHTML Line to write out.
      */

     P wrtHTML         B

     D wrtHTML         PI
     D  pHTML                       256A   VARYING
     D                                     CONST

     D sTtl            C                   CONST('<title>')
     D eTtl            C                   CONST('</title>')

      /free
              IF  wrtHEAD;
                  wrtHEAD = *OFF;
                  EXSR Wrt_HEAD;
              ENDIF;

              ifsWrt( pHTML + X'25' : f_OUT );
              IF  ferror(f_OUT) > *ZERO;
                  perror('Error on write to IFS file');
              ENDIF;

              RETURN;

       //**
       //*�Writes the HTML HEAD section and starts BODY.
       //*/

              BEGSR Wrt_HEAD;

              wrtHTML('<html>');
              wrtHTML('<head>');
              IF  isCPY;
                  IF  mbrTxt = *BLANKS;
                      wrtHTML(sTtl +'CopyBook ' + mbrNm + eTtl);
                  ELSE;
                      wrtHTML(sTtl +'CopyBook ' + mbrNm + ' - ' + mbrTxt +
                              eTtl);
                  ENDIF;
                  pubRtrn(1) = NOTHNG;
                  pubName(1) = mbrNm;
                  pubParm(1) = '(' + NONE + ')';
              ELSE;
                  IF  isPgm;
                      IF  mbrTxt = *BLANKS;
                          wrtHTML(sTtl +'Program ' + mbrNm + eTtl);
                      ELSE;
                          wrtHTML(sTtl +'Program ' + mbrNm + ' - ' + mbrTxt +
                                  eTtl);
                      ENDIF;
                      pubRtrn(1) = NOTHNG;
                      pubName(1) = mbrNm;
                      pubParm(1) = '(' + NONE + ')';
                  ELSE;
                      IF  mbrTxt = *BLANKS;
                          wrtHTML(sTtl + 'Module ' + mbrNm + eTtl);
                      ELSE;
                          wrtHTML(sTtl + 'Module ' + mbrNm + ' - ' + mbrTxt +
                                  eTtl);
                      ENDIF;
                  ENDIF;
              ENDIF;
              wrtHTML('<meta name="Generator" content="Open Source RPGDOC" />');
              wrtHTML('</head>');
              wrtHTML('<body>');
              IF  isCpy;
                  wrtHTML('<h1>CopyBook ' + mbrNm + '</h1>');
              ELSE;
                  IF  isPgm;
                      wrtHTML('<h1>Program ' + mbrNm + '</h1>');
                  ELSE;
                      wrtHTML('<h1>Module '  + mbrNm + '</h1>');
                  ENDIF;
              ENDIF;

              ENDSR;
      /end-free

     P wrtHTML         E
