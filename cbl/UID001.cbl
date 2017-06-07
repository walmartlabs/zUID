       IDENTIFICATION DIVISION.
       PROGRAM-ID.      UID001.
      ******************************************************************
      ** Sample CICS program initiated via a terminal.                **
      ** Call zUID service to request a UID.                          **
      ** Program shows 2 example using a URIMAP and native URL.       **
      ** Make sure to set the hostname:port and @path@ variables.     **
      ******************************************************************
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       INPUT-OUTPUT SECTION.
       DATA DIVISION.
       FILE SECTION.

      *----------------------------------------------------------------
       WORKING-STORAGE SECTION.
      *----------------------------------------------------------------
       01  URIMAP-NAME                 PIC X(08) VALUE 'UID00101'.
       01  SESSION-TOKEN               PIC X(08).
       01  FULL-URL.
           05  FILLER                  PIC X(26) VALUE
               'http://hostname:port@path@'.
           05  FILLER                  PIC X(21) VALUE
               '?OPTIONS(FORMAT=GUID)'.
       01  UID-GUID-VALUE              PIC X(36).
       01  UID-PLAIN-VALUE REDEFINES UID-GUID-VALUE PIC X(32).
       01  UID-ESS-VALUE REDEFINES UID-GUID-VALUE PIC X(34).
       01  UID-LENGTH                  PIC 9(09) COMP.
       01  HTTP-STATUS-CODE            PIC 9(04) COMP.
       01  HTTP-STATUS-LEN             PIC 9(09) COMP.
       01  HTTP-STATUS-TEXT            PIC X(100).
       01  FORMAT-GUID                 PIC X(20) VALUE
           'OPTIONS(FORMAT=GUID)'.
       01  URL-SCHEME-NAME             PIC X(05).
       01  URL-SCHEME-CVDA             PIC 9(09) COMP.
       01  URL-HOST-NAME               PIC X(255).
       01  URL-HOST-NAME-LEN           PIC 9(09) COMP.
       01  URL-PATH-NAME               PIC X(255).
       01  URL-PATH-NAME-LEN           PIC 9(09) COMP.
       01  URL-QUERY-STRING            PIC X(255).
       01  URL-QUERY-STRING-LEN        PIC 9(09) COMP.
       01  URL-PORT-NBR                PIC 9(09) COMP.

       01  TERM-RESPONSE.
           05  FILLER                  PIC X(19) VALUE 'Msg: '.
           05  TERM-MSG                PIC X(61) VALUE 'Ok'.
           05  FILLER                  PIC X(19) VALUE
               'URIMAP GUID Value: '.
           05  TERM-URIMAP             PIC X(61) VALUE SPACES.
           05  FILLER                  PIC X(19) VALUE
               'URL GUID Value: '.
           05  TERM-URL                PIC X(61) VALUE SPACES.

       01  CICS-MSG.
           05  CICS-MSG-TEXT           PIC X(34).
           05  FILLER                  PIC X(09) VALUE ' EIBRESP='.
           05  CICS-MSG-RESP           PIC 9(04).
           05  FILLER                  PIC X(10) VALUE ' EIBRESP2='.
           05  CICS-MSG-RESP2          PIC 9(04).

       01  CICS-MSG2.
           05  CICS-MSG-HTTP           PIC X(20).
           05  FILLER                  PIC X(06) VALUE ' HTTP='.
           05  CICS-MSG-CODE           PIC 9(03).
           05  FILLER                  PIC X(01) VALUE ':'.
           05  CICS-MSG-STATUS         PIC X(31).

      *----------------------------------------------------------
       PROCEDURE DIVISION.
      *----------------------------------------------------------

      *    *--------------------------------------------------------*
      *    * Two different examples included.                       *
      *    * A1000 shows how to call zUID service using URIMAP.     *
      *    * A2000 shows how to call zUID with a URL.               *
      *    *--------------------------------------------------------*
           PERFORM A1000-EXAMPLE-URIMAP THRU A1000-EXIT.
           PERFORM A2000-EXAMPLE-URL THRU A2000-EXIT.
           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

      ******************************************************************
      * Use a URIMAP defintion to execute the service.                 *
      ******************************************************************

       A1000-EXAMPLE-URIMAP.

           MOVE SPACES                   TO UID-GUID-VALUE.
           MOVE LENGTH OF UID-GUID-VALUE TO UID-LENGTH.

           PERFORM A1100-OPEN-CONNECTION THRU A1100-EXIT.
           PERFORM A1200-EXECUTE-SERVICE THRU A1200-EXIT.
           PERFORM A1300-CLOSE-CONNECTION THRU A1300-EXIT.

           MOVE UID-GUID-VALUE           TO TERM-URIMAP.

       A1000-EXIT.
           EXIT.

      ******************************************************************
      * Open the HTTP connection with the URIMAP name.                 *
      ******************************************************************

       A1100-OPEN-CONNECTION.

      *    *--------------------------------------------------------*
      *    * Open the URIMAP to establish connection to service.    *
      *    *  Host:   _your_host_name_ (installation specific)      *
      *    *  Port:   80 (can override this if needed)              *
      *    *  Path:   _your_path_name_ (based on installation)      *
      *    *  Scheme: HTTP                                          *
      *    *  Usage:  CLIENT                                        *
      *    *--------------------------------------------------------*
           EXEC CICS WEB OPEN
                SESSTOKEN( SESSION-TOKEN )
                URIMAP   ( URIMAP-NAME )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              GO TO A1100-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                     TO CICS-MSG-RESP.
           MOVE EIBRESP2                    TO CICS-MSG-RESP2.
           MOVE 'A1100: WEB_OPEN ERROR:'    TO CICS-MSG-TEXT.
           MOVE CICS-MSG                     TO TERM-MSG.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A1100-EXIT.
           EXIT.

      ******************************************************************
      * Execute the zUID service with the WEB CONVERSE API.            *
      ******************************************************************

       A1200-EXECUTE-SERVICE.

           MOVE LENGTH OF HTTP-STATUS-TEXT    TO HTTP-STATUS-LEN.

      *    *--------------------------------------------------------*
      *    * Execute the service and return the new GUID formatted  *
      *    * value in UID-GUID-VALUE.                               *
      *    * You can change the FORMAT-GUID to retrieve the         *
      *    * format you need.                                       *
      *    *   OPTIONS=(FORMAT=PLAIN)                               *
      *    *   OPTIONS=(FORMAT=ESS)                                 *
      *    *   OPTIONS=(FORMAT=GUID)                                *
      *    *--------------------------------------------------------*
           EXEC CICS WEB CONVERSE
                SESSTOKEN  ( SESSION-TOKEN )
                GET
                QUERYSTRING( FORMAT-GUID )
                QUERYSTRLEN( LENGTH OF FORMAT-GUID )
                INTO       ( UID-GUID-VALUE )
                TOLENGTH   ( UID-LENGTH )
                STATUSCODE ( HTTP-STATUS-CODE )
                STATUSLEN  ( HTTP-STATUS-LEN )
                STATUSTEXT ( HTTP-STATUS-TEXT )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL) AND HTTP-STATUS-CODE = 200
              GO TO A1200-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                      TO CICS-MSG-RESP.
           MOVE EIBRESP2                     TO CICS-MSG-RESP2.
           MOVE 'A1200: WEB_CONVERSE ERROR:' TO CICS-MSG-TEXT.
           MOVE CICS-MSG                     TO TERM-MSG.

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE HTTP-STATUS-CODE          TO CICS-MSG-CODE
              MOVE HTTP-STATUS-TEXT          TO CICS-MSG-STATUS
              MOVE 'A1200: HTTP ERROR'       TO CICS-MSG-HTTP
              MOVE CICS-MSG2                 TO TERM-MSG
           END-IF.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A1200-EXIT.
           EXIT.

      ******************************************************************
      * Close the open connection.                                     *
      ******************************************************************

       A1300-CLOSE-CONNECTION.

      *    *--------------------------------------------------------*
      *    * Close open connection.                                 *
      *    *--------------------------------------------------------*
           EXEC CICS WEB CLOSE
                SESSTOKEN( SESSION-TOKEN )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              GO TO A1300-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                      TO CICS-MSG-RESP.
           MOVE EIBRESP2                     TO CICS-MSG-RESP2.
           MOVE 'A1300: WEB_CLOSE ERROR:'    TO CICS-MSG-TEXT.
           MOVE CICS-MSG                     TO TERM-MSG.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A1300-EXIT.
           EXIT.

      ******************************************************************
      * Use a native URL to execute the service.                       *
      ******************************************************************

       A2000-EXAMPLE-URL.

           MOVE SPACES                   TO UID-GUID-VALUE.
           MOVE LENGTH OF UID-GUID-VALUE TO UID-LENGTH.

           PERFORM A2100-EXTRACT-WEB-VALUES THRU A2100-EXIT.
           PERFORM A2200-OPEN-CONNECTION THRU A2200-EXIT.
           PERFORM A2300-SEND-REQUEST THRU A2300-EXIT.
           PERFORM A2400-RECEIVE-REQUEST THRU A2400-EXIT.
           PERFORM A1300-CLOSE-CONNECTION THRU A1300-EXIT.

           MOVE UID-GUID-VALUE           TO TERM-URL.

       A2000-EXIT.
           EXIT.

      ******************************************************************
      * Parse the URL string to get the HOST, PATH, QUERY STRING and   *
      * PORT number.                                                   *
      ******************************************************************

       A2100-EXTRACT-WEB-VALUES.

           MOVE LENGTH OF URL-HOST-NAME    TO URL-HOST-NAME-LEN.
           MOVE LENGTH OF URL-PATH-NAME    TO URL-PATH-NAME-LEN.
           MOVE LENGTH OF URL-QUERY-STRING TO URL-QUERY-STRING-LEN.
           MOVE SPACES                     TO URL-SCHEME-NAME,
                                              URL-HOST-NAME,
                                              URL-PATH-NAME,
                                              URL-QUERY-STRING.

           EXEC CICS WEB PARSE
                URL        ( FULL-URL )
                URLLENGTH  ( LENGTH OF FULL-URL )
                SCHEMENAME ( URL-SCHEME-NAME )
                HOST       ( URL-HOST-NAME )
                HOSTLENGTH ( URL-HOST-NAME-LEN )
                PORTNUMBER ( URL-PORT-NBR )
                PATH       ( URL-PATH-NAME )
                PATHLENGTH ( URL-PATH-NAME-LEN )
                QUERYSTRING( URL-QUERY-STRING )
                QUERYSTRLEN( URL-QUERY-STRING-LEN )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              GO TO A2100-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                       TO CICS-MSG-RESP.
           MOVE EIBRESP2                      TO CICS-MSG-RESP2.
           MOVE 'A2100: WEB_PARSE_URL ERROR:' TO CICS-MSG-TEXT.
           MOVE CICS-MSG                      TO TERM-MSG.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A2100-EXIT.
           EXIT.

      ******************************************************************
      * Create an HTTP connection from the parameters parsed from      *
      * the URL.                                                       *
      ******************************************************************

       A2200-OPEN-CONNECTION.

           IF URL-SCHEME-NAME = 'HTTPS'
              MOVE DFHVALUE(HTTPS)       TO URL-SCHEME-CVDA
           ELSE
              MOVE DFHVALUE(HTTP)        TO URL-SCHEME-CVDA
           END-IF.

      *    *--------------------------------------------------------*
      *    * Open connection from the parsed values of the URL.     *
      *    *--------------------------------------------------------*
           EXEC CICS WEB OPEN
                SESSTOKEN ( SESSION-TOKEN )
                HOST      ( URL-HOST-NAME )
                HOSTLENGTH( URL-HOST-NAME-LEN )
                PORTNUMBER( URL-PORT-NBR )
                SCHEME    ( URL-SCHEME-CVDA )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              GO TO A2200-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                       TO CICS-MSG-RESP.
           MOVE EIBRESP2                      TO CICS-MSG-RESP2.
           MOVE 'A2200: WEB_OPEN ERROR:'      TO CICS-MSG-TEXT.
           MOVE CICS-MSG                      TO TERM-MSG.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A2200-EXIT.
           EXIT.

      ******************************************************************
      * Use the WEB SEND API to send the HTTP request.                 *
      ******************************************************************

       A2300-SEND-REQUEST.

      *    *--------------------------------------------------------*
      *    * Send the service request.                              *
      *    *--------------------------------------------------------*
           EXEC CICS WEB SEND
                SESSTOKEN  ( SESSION-TOKEN )
                GET
                PATH       ( URL-PATH-NAME )
                PATHLENGTH ( URL-PATH-NAME-LEN )
                QUERYSTRING( URL-QUERY-STRING )
                QUERYSTRLEN( URL-QUERY-STRING-LEN )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL)
              GO TO A2300-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                       TO CICS-MSG-RESP.
           MOVE EIBRESP2                      TO CICS-MSG-RESP2.
           MOVE 'A2300: WEB_SEND ERROR:'      TO CICS-MSG-TEXT.
           MOVE CICS-MSG                      TO TERM-MSG.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A2300-EXIT.
           EXIT.

      ******************************************************************
      * Receive the HTTP response with the WEB RECEIVE API.            *
      ******************************************************************

       A2400-RECEIVE-REQUEST.

      *    *--------------------------------------------------------*
      *    * Receive the web service request into UID-GUID-VALUE.   *
      *    *--------------------------------------------------------*
           EXEC CICS WEB RECEIVE
                SESSTOKEN  ( SESSION-TOKEN )
                INTO       ( UID-GUID-VALUE )
                LENGTH     ( UID-LENGTH )
                STATUSCODE ( HTTP-STATUS-CODE )
                STATUSLEN  ( HTTP-STATUS-LEN )
                STATUSTEXT ( HTTP-STATUS-TEXT )
                NOHANDLE
           END-EXEC.

           IF EIBRESP = DFHRESP(NORMAL) AND HTTP-STATUS-CODE = 200
              GO TO A2400-EXIT
           END-IF.

      *    *--------------------------------------------------------*
      *    * Handle your error condition.                           *
      *    *--------------------------------------------------------*
           MOVE EIBRESP                       TO CICS-MSG-RESP.
           MOVE EIBRESP2                      TO CICS-MSG-RESP2.
           MOVE 'A2400: WEB_CONVERSE ERROR:'  TO CICS-MSG-TEXT.
           MOVE CICS-MSG                      TO TERM-MSG.

           IF EIBRESP = DFHRESP(NORMAL)
              MOVE HTTP-STATUS-CODE          TO CICS-MSG-CODE
              MOVE HTTP-STATUS-TEXT          TO CICS-MSG-STATUS
              MOVE 'A2400: HTTP ERROR'       TO CICS-MSG-HTTP
              MOVE CICS-MSG2                 TO TERM-MSG
           END-IF.

           PERFORM Z1000-EXIT-PROGRAM THRU Z1000-EXIT.

       A2400-EXIT.
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

