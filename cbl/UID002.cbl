       IDENTIFICATION DIVISION.
       PROGRAM-ID.      UID002.
      ******************************************************************
      ** Sample CICS program initiated via a terminal.                **
      ** Example shows how to call zUID with LINK PROGRAM.            **
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       DATA DIVISION.
       FILE SECTION.

      *----------------------------------------------------------------
       WORKING-STORAGE SECTION.
      *----------------------------------------------------------------

      **------------------------------------------------------------*
      ** COMMAREA for ZUID001 routine.                              *
      **------------------------------------------------------------*
       01  ZUID-COMM-AREA.
           05  FILLER             PIC  X(04) VALUE 'LINK'.
           05  CA-STATUS-CODE     PIC  X(03).
           05  FILLER             PIC  X(09).
           05  CA-FORMAT          PIC  X(05) VALUE 'PLAIN'.
               88  CA-FORMAT-PLAIN     VALUE 'PLAIN'.
               88  CA-FORMAT-ESS       VALUE 'ESS'.
               88  CA-FORMAT-GUID      VALUE 'GUID'.
           05  FILLER             PIC  X(11).
           05  CA-UID             PIC  X(36).
           05  FILLER             PIC  X(92).

       01  TERM-RESPONSE.
           05  FILLER                  PIC X(07) VALUE 'Msg: '.
           05  TERM-MSG                PIC X(73) VALUE 'Ok'.
           05  FILLER                  PIC X(07) VALUE 'PLAIN:'.
           05  TERM-PLAIN              PIC X(73).
           05  FILLER                  PIC X(07) VALUE 'ESS:'.
           05  TERM-ESS                PIC X(73).
           05  FILLER                  PIC X(07) VALUE 'GUID:'.
           05  TERM-GUID               PIC X(73).

       01  CICS-MSG.
           05  CICS-MSG-TEXT           PIC X(34).
           05  FILLER                  PIC X(09) VALUE ' EIBRESP='.
           05  CICS-MSG-RESP           PIC 9(04).
           05  FILLER                  PIC X(10) VALUE ' EIBRESP2='.
           05  CICS-MSG-RESP2          PIC 9(04).

      *----------------------------------------------------------
       PROCEDURE DIVISION.
      *----------------------------------------------------------

           PERFORM A1000-CALL-ZUID001-PLAIN THRU A1000-EXIT.
           PERFORM A2000-CALL-ZUID001-ESS THRU A2000-EXIT.
           PERFORM A3000-CALL-ZUID001-GUID THRU A3000-EXIT.
           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

      ******************************************************************
      * Setup COMMAREA for ZUID001 to get a PLAIN UID.                 *
      * Go call routine.                                               *
      ******************************************************************

       A1000-CALL-ZUID001-PLAIN.

           MOVE SPACES                          TO CA-UID.
           SET  CA-FORMAT-PLAIN                 TO TRUE.
           PERFORM B1000-CALL-ZUID001 THRU B1000-EXIT.
           MOVE CA-UID                          TO TERM-PLAIN.

       A1000-EXIT.
           EXIT.

      ******************************************************************
      * Setup COMMAREA for ZUID001 to get a ESS UID.                   *
      * Go call routine.                                               *
      ******************************************************************

       A2000-CALL-ZUID001-ESS.

           MOVE SPACES                          TO CA-UID.
           SET  CA-FORMAT-ESS                   TO TRUE.
           PERFORM B1000-CALL-ZUID001 THRU B1000-EXIT.
           MOVE CA-UID                          TO TERM-ESS.

       A2000-EXIT.
           EXIT.

      ******************************************************************
      * Setup COMMAREA for ZUID001 to get a GUID UID.                  *
      * Go call routine.                                               *
      ******************************************************************

       A3000-CALL-ZUID001-GUID.

           MOVE SPACES                          TO CA-UID.
           SET  CA-FORMAT-GUID                  TO TRUE.
           PERFORM B1000-CALL-ZUID001 THRU B1000-EXIT.
           MOVE CA-UID                          TO TERM-GUID.

       A3000-EXIT.
           EXIT.

      ******************************************************************
      * Call ZUID001 routine to get a new UID value.                   *
      * COMMAREA initialized prior to calling this paragraph.          *
      ******************************************************************

       B1000-CALL-ZUID001.

           EXEC CICS LINK
                PROGRAM( 'ZUID001' )
                COMMAREA( ZUID-COMM-AREA )
                LENGTH  ( LENGTH OF ZUID-COMM-AREA )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              IF CA-STATUS-CODE = 200
                 GO TO B1000-EXIT
              ELSE
                 MOVE CA-STATUS-CODE            TO TERM-MSG
                 PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT
              END-IF
           ELSE
      *       *-----------------------------------------------------*
      *       * Handle your error condition.                        *
      *       *-----------------------------------------------------*
              MOVE EIBRESP                      TO CICS-MSG-RESP
              MOVE EIBRESP2                     TO CICS-MSG-RESP2
              MOVE 'B1000: LINK PROGRAM ERROR:' TO CICS-MSG-TEXT
              MOVE CICS-MSG                     TO TERM-MSG
              PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT
           END-IF.

       B1000-EXIT.
           EXIT.

      ******************************************************************
      * All done, post appropiate message to terminal and exit.        *
      ******************************************************************

       Z1000-EXIT-PROGRAM.

      *    *--------------------------------------------------------*
      *    * Send response to terminal.                             *
      *    *--------------------------------------------------------*
           EXEC CICS SEND
                FROM  ( TERM-RESPONSE )
                LENGTH( LENGTH OF TERM-RESPONSE )
                ERASE
                NOHANDLE
           END-EXEC.

           EXEC CICS RETURN
           END-EXEC.

       Z1000-EXIT.
           EXIT.

