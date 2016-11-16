*                                                                       00000100
*  PROGRAM:    ZUIDPLT                                                  00000200
*  AUTHOR:     RANDY FRERKING.                                          00000300
*  SOURCE:     J1FRERK.CICS.ZUID(ZUIDPLT)                               00000400
*  DATE:       April 14, 2014                                           00000500
*  COMMENTS:   Create zUID 'named counter' to qualify a Site ID and     00000600
*              time with uniqueness.                                    00000600
*                                                                       00000800
*              ESSUID is the counter name.                              00000600
*              rzressUID is the service name.                           00000600
*                                                                       00000800
*  2014/04/14  J1FRERK - CREATED                                        00000810
*                                                                       00000840
*********************************************************************** 00000900
* Dynamic Storage Area (Start)                                        * 00001000
*********************************************************************** 00000900
DFHEISTG DSECT                                                          00001200
ABSTIME  DS    D                  Absolute time                         00001300
BAS_REG  DS    F                  Return register
SYSID    DS    CL04               CICS SYSID                            00001400
APPLID   DS    CL08               CICS/VTAM APPLID                      00001300
W_PACK   DS    CL08               Packed decimal work area              00001300
W_ZONE   DS    CL08               Zone   decimal work area              00001300
W_VALUE  DS    F                  QUERY counter value - full word       00001300
         DS   0D
D_VALUE  DS    CL08               QUERY counter value - double word     00001300
         DS   0F
STCODE   DS    CL02               Transaction start code                00001400
         DS   0F
*
WTO_LEN  DS    F                  WTO output length
TD_LEN   DS    H                  TD  output length
         DS   0F
TD_DATA  DS   0CL75               TD/WTO output
TD_DATE  DS    CL10
         DS    CL01
TD_TIME  DS    CL08
         DS    CL01
TD_MSG   DS    CL55
*
         ORG   TD_MSG
W_MSG_00 DS   0CL55               MSG 00 format
         DS    CL26               'ESSUID available - Count: '
W_COUNT  DS    CL10               Sequential counter
         DS    CL19               Spaces
         ORG   TD_MSG
W_MSG_01 DS   0CL55               MSG 01 format
         DS    CL27               'ESSUID created successfully'
         DS    CL28               spaces
         ORG   TD_MSG
W_MSG_02 DS   0CL55               MSG 02 format
         DS    CL24               'ESSUID error - EIBRESP: '
W_RESP   DS    CL04               EIBRESP
         DS    CL12               'EIBRESP2: '
W_RESP2  DS    CL04               EIBRESP2
         DS    CL11               Spaces
*
TD_L     EQU   *-TD_DATA
*
*********************************************************************** 00000900
* Dynamic Storage Area (End)                                          * 00001000
*********************************************************************** 00000900
*
*
*********************************************************************** 00000900
* Control Section                                                     * 00001000
*********************************************************************** 00000900
ZUIDPLT  DFHEIENT CODEREG=(R12),DATAREG=R10,EIBREG=R11
ZUIDPLT  AMODE 31
ZUIDPLT  RMODE 31
         B     SYSDATE                 BRANCH AROUND LITERALS           00014700
         DC    CL08'ZUIDPLT  '                                          00014800
         DC    CL48' -- rzressUID Named Counter creation            '   00014900
         DC    CL08'        '                                           00015000
         DC    CL08'&SYSDATE'                                           00015100
         DC    CL08'        '                                           00015200
         DC    CL08'&SYSTIME'                                           00015300
SYSDATE  DS   0H                                                        00015400
*********************************************************************** 00000900
* Assign resources                                                    * 00001000
*********************************************************************** 00000900
SY_0010  DS   0H                                                        00015900
         EXEC CICS ASSIGN APPLID(APPLID) SYSID(SYSID)                  X
               STARTCODE(STCODE) NOHANDLE
*
*********************************************************************** 00000900
* Query  ESSUID named counter for rzressUID zCloud service            * 00001000
*********************************************************************** 00000900
SY_0100  DS   0H                                                        00015900
         EXEC CICS QUERY DCOUNTER(C_UID)                               X
               VALUE  (D_VALUE)                                        X
               NOHANDLE
*
         OC    EIBRESP,EIBRESP         Normal response?
         BC    B'0111',SY_0200         ... no,  DEFINE the counter
*
         MVC   TD_DATA,C_MSG_00        Move message template
         MVC   W_VALUE,D_VALUE+4       Move fullword only
         L     R2,W_VALUE              Load current value
         CVD   R2,W_PACK               Convert to decimal
         UNPK  W_COUNT,W_PACK          Unpack current value
         OI    W_COUNT+9,X'F0'         Set sign bits
         BAS   R14,SY_LOG              Log the message
         BC    B'1111',SY_0800         Send response and RETURN
*
*********************************************************************** 00000900
* Define ESSUID named counter for rzressUID zCloud service            * 00001000
*********************************************************************** 00000900
SY_0200  DS   0H                                                        00015900
         EXEC CICS DEFINE DCOUNTER(C_UID)                              X
               VALUE  (C_VAL)                                          X
               MINIMUM(C_MIN)                                          X
               MAXIMUM(C_MAX)                                          X
               NOHANDLE
*
         OC    EIBRESP,EIBRESP         Normal response?
         BC    B'0111',SY_0300         ... no,  Send error message
*
         MVC   TD_DATA,C_MSG_01        Move message template
         BAS   R14,SY_LOG              Log the message
         BC    B'1111',SY_0800         Send response and RETURN
*********************************************************************** 00000900
* Error when defining ESSUID.  Send error message                     * 00001000
*********************************************************************** 00000900
SY_0300  DS   0H                                                        00015900
         MVC   TD_DATA,C_MSG_02        Move message template
*
         L     R2,EIBRESP              Load EIBRESP
         CVD   R2,W_PACK               Convert to decimal
         UNPK  W_RESP,W_PACK           Unpack EIBRESP
         OI    W_RESP+3,X'F0'          Set sign bits
*
         L     R2,EIBRESP2             Load EIBRESP2
         CVD   R2,W_PACK               Convert to decimal
         UNPK  W_RESP2,W_PACK          Unpack EIBRESP2
         OI    W_RESP2+3,X'F0'         Set sign bits
*
         BAS   R14,SY_LOG              Log the message
         BC    B'1111',SY_0800         Send response and RETURN
*********************************************************************** 00000900
* Send terminal response                                              * 00001000
*********************************************************************** 00000900
SY_0800  DS   0H                                                        00015900
         CLI   STCODE,C'T'             Terminal task?
         BC    B'0111',SY_0900         ... no,  bypass SEND
         EXEC CICS SEND FROM(TD_DATA) LENGTH(TD_LEN)                   X
               ERASE NOHANDLE
*********************************************************************** 00000900
* RETURN                                                              * 00001000
*********************************************************************** 00000900
SY_0900  DS   0H                                                        00015900
         EXEC CICS RETURN
*********************************************************************** 00000900
* Format time stamp                                                   * 00001000
* Write TD Message                                                    * 00001000
* Issue WTO                                                           * 00001000
*********************************************************************** 00000900
SY_LOG   DS   0H                                                        00015900
         ST    R14,BAS_REG             Save return register
*
         EXEC CICS ASKTIME ABSTIME(ABSTIME) NOHANDLE
         EXEC CICS FORMATTIME ABSTIME(ABSTIME) YYYYMMDD(TD_DATE)       X
               TIME(TD_TIME)  DATESEP('/') TIMESEP(':') NOHANDLE
*
         LA    R1,TD_L                 Load TD message length
         STH   R1,TD_LEN               Save TD Message length
         ST    R1,WTO_LEN              WTO length
*
         EXEC CICS WRITEQ TD QUEUE('ALOG') FROM(TD_DATA)               X
               LENGTH(TD_LEN) NOHANDLE
*
         EXEC CICS WRITEQ TD QUEUE('CSSL') FROM(TD_DATA)               X
               LENGTH(TD_LEN) NOHANDLE
*
         BC    B'0000',SY_9100         Bypass WTO
*
         EXEC CICS WRITE OPERATOR TEXT(TD_DATA) TEXTLENGTH(WTO_LEN)    X
               ROUTECODES(WTO_RC) NUMROUTES(WTO_RC_L) EVENTUAL         X
               NOHANDLE
*********************************************************************** 00000900
* Label to bypass WTO                                                 * 00001000
*********************************************************************** 00000900
SY_9100  DS   0H                                                        00015900
         L     R14,BAS_REG             Load return register
         BCR   B'1111',R14             Return to caller
*
*                                                                       00051400
*********************************************************************** 00000900
* Literal Pool                                                        * 00001000
*********************************************************************** 00000900
         LTORG                                                          00075000
*                                                                       00075100
         DS   0F
*                                                                       00075100
         DS   0F
C_UID    DC    CL16'ESSUID'            ESSUID counter name
         DS   0F
C_VAL    DC    XL08'0000000000000001'  Doubleword 1
C_MIN    DC    XL08'0000000000000001'  Doubleword 1
C_MAX    DC    XL08'00000000FFFFFFFF'  Doubleword 4294967295.
*                                                                       00075100
         DS   0F
C_MSG_00 DC   0CL75
         DC    CL25'YYYY/MM/DD HH:MM:SS ESSUI'
         DC    CL25'D available - Count: 9999'
         DC    CL25'999999                   '
*                                                                       00075100
         DS   0F
C_MSG_01 DC   0CL75
         DC    CL25'YYYY/MM/DD HH:MM:SS ESSUI'
         DC    CL25'D created successfully   '
         DC    CL25'                         '
         DS   0F
C_MSG_02 DC   0CL75
         DC    CL25'YYYY/MM/DD HH:MM:SS ESSUI'
         DC    CL25'D error - EIBRESP: 9999  '
         DC    CL25'EIBRESP2: 9999           '
*                                                                       00075100
         DS   0F
WTO_RC_L DC    F'02'                   WTO Routecode length
WTO_RC   DC    XL02'0111'
         DS   0F
*
*********************************************************************** 00000900
* Register assignments                                                * 00001000
*********************************************************************** 00000900
         DS   0F                                                        00085100
R0       EQU   0                                                        00085200
R1       EQU   1                                                        00085300
R2       EQU   2                                                        00085400
R3       EQU   3                                                        00085500
R4       EQU   4                                                        00085600
R5       EQU   5                                                        00085700
R6       EQU   6                                                        00085800
R7       EQU   7                                                        00085900
R8       EQU   8                                                        00086000
R9       EQU   9                                                        00086100
R10      EQU   10                                                       00086200
R11      EQU   11                                                       00086300
R12      EQU   12                                                       00086400
R13      EQU   13                                                       00086500
R14      EQU   14                                                       00086600
R15      EQU   15                                                       00086700
*
         PRINT ON                                                       00087100
*********************************************************************** 00000900
* End of Program                                                      * 00001000
*********************************************************************** 00000900
         END   ZUIDPLT                                                  00087500