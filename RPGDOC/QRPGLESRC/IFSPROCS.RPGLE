     /**
      * C IFS API Prototypes.
      * To create, open with codepage 1252, close, then open again with
      * codepage 37.  This will automatically translate ASCII<->EBCDIC.
      *
      * File mode are typical C values:
      * 'r'  - Open as Input, error if not exist
      * 'w'  - Open as Output.  Clears existing file.
      * 'a'  - Open append, but does NOT update EOF. (Use 'a+')
      * 'r+' - Open as Input/Output, error if not exist.
      * 'w+' - Open as Input/Output.  Clears existing file.
      * 'a+' - Open append.
      * (Add a 'b' if accessing a BINARY file instead of a text file)
      *
      * @author Chris Wolcott - 13-JUN-06  Modified
      * @version V0R1M0
      * @see (QSYSINC/H) MBR(IFS)
      */

      /IF  NOT DEFINED(C_DEFS)
      /DEFINE C_DEFS
     D O_LARGEFILE     C                   536870912
     D SEEK_SET        C                   0
     D SEEK_CUR        C                   1
     D SEEK_END        C                   2
      /ENDIF

     D ifsOpn          PR              *   EXTPROC('_C_IFS_fopen')
     D  fileName                       *   VALUE OPTIONS(*STRING)
     D  filemode                       *   VALUE OPTIONS(*STRING)

      * SEEK_SET - BOF | SEEK_CUR - COF - Current position | SEEK_END - EOF
     D ifsSeek         PR              *   EXTPROC('_C_IFS_fseek')
     D  stream_FILE                    *   VALUE
     D  pos_offset                   10I 0 Value
     D  pos_origin                   10I 0 Value                                SET / CUR / END

     D ifsTell         PR            10I 0 EXTPROC('_C_IFS_ftell')              Return cur position
     D  stream_FILE                    *   VALUE

     D ifsRd           PR              *   EXTPROC('_C_IFS_fgets')
     D  inBuffer                       *   VALUE OPTIONS(*STRING)
     D  inBufLen                     10I 0 VALUE
     D  stream_FILE                    *   VALUE

      * Use r+ to open, fSeek to position and ifsWrt to UPDATE a record
     D ifsWrt          PR              *   EXTPROC('_C_IFS_fputs')
     D  inBuffer                       *   VALUE OPTIONS(*STRING)
     D  stream_FILE                    *   VALUE

     D ifsCLO          PR              *   EXTPROC('_C_IFS_fclose')
     D  stream_FILE                    *   VALUE

     D ifsEOF          PR              *   EXTPROC('_C_IFS_feof')
     D  stream_FILE                    *   VALUE

     D ferror          PR            10I 0 EXTPROC('_C_IFS_ferror')
     D  stream_FILE                    *   VALUE

     D perror          PR                  EXTPROC('_C_IFS_perror')
     D   msgStr                        *   VALUE OPTIONS(*STRING)

