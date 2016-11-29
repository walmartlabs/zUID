*
*  PROGRAM:    ZUIDPLT
*  AUTHOR:     Randy Frerking and Rich Jackson
*  DATE:       April 14, 2014
*  COMMENTS:   This program is designed to execute in both the PLT and
*              as a terminal transaction.
*
*              Create zUID 'named counter' to qualify a Site ID and
*              time with uniqueness.
*
*              ESSUID is the counter name.
*
***********************************************************************
* Dynamic Storage Area (Start)                                        *
***********************************************************************
DFHEISTG DSECT
ABSTIME  DS    D                  Absolute time
BAS_REG  DS    F                  Return register
SYSID    DS    CL04               CICS SYSID
APPLID   DS    CL08               CICS/VTAM APPLID
W_PACK   DS    CL08               Packed decimal work area
W_ZONE   DS    CL08               Zone   decimal work area
W_VALUE  DS    F                  QUERY counter value - full word
         DS   0D
D_VALUE  DS    CL08               QUERY counter value - double word
         DS   0F
STCODE   DS    CL02               Transaction start code
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
***********************************************************************
* Dynamic Storage Area (End)                                          *
***********************************************************************
*
*
***********************************************************************
* Control Section                                                     *
***********************************************************************
ZUIDPLT  DFHEIENT CODEREG=(R12),DATAREG=R10,EIBREG=R11
ZUIDPLT  AMODE 31
ZUIDPLT  RMODE 31
         B     SYSDATE                 BRANCH AROUND LITERALS
         DC    CL08'ZUIDPLT  '
         DC    CL48' -- rzressUID Named Counter creation            '
         DC    CL08'        '
         DC    CL08'&SYSDATE'
         DC    CL08'        '
         DC    CL08'&SYSTIME'
SYSDATE  DS   0H
***********************************************************************
* Assign resources                                                    *
***********************************************************************
SY_0010  DS   0H
         EXEC CICS ASSIGN APPLID(APPLID) SYSID(SYSID)                  X
               STARTCODE(STCODE) NOHANDLE
*
***********************************************************************
* Query  ESSUID named counter for rzressUID zCloud service            *
***********************************************************************
SY_0100  DS   0H
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
***********************************************************************
* Define ESSUID named counter for rzressUID zCloud service            *
***********************************************************************
SY_0200  DS   0H
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
***********************************************************************
* Error when defining ESSUID.  Send error message                     *
***********************************************************************
SY_0300  DS   0H
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
***********************************************************************
* Send terminal response                                              *
***********************************************************************
SY_0800  DS   0H
         CLI   STCODE,C'T'             Terminal task?
         BC    B'0111',SY_0900         ... no,  bypass SEND
         EXEC CICS SEND FROM(TD_DATA) LENGTH(TD_LEN)                   X
               ERASE NOHANDLE
***********************************************************************
* RETURN                                                              *
***********************************************************************
SY_0900  DS   0H
         EXEC CICS RETURN
***********************************************************************
* Format time stamp                                                   *
* Write TD Message                                                    *
* Issue WTO                                                           *
***********************************************************************
SY_LOG   DS   0H
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
         EXEC CICS WRITEQ TD QUEUE('@tdq@') FROM(TD_DATA)               X
               LENGTH(TD_LEN) NOHANDLE
*
         BC    B'0000',SY_9100         Bypass WTO
*
         EXEC CICS WRITE OPERATOR TEXT(TD_DATA) TEXTLENGTH(WTO_LEN)    X
               ROUTECODES(WTO_RC) NUMROUTES(WTO_RC_L) EVENTUAL         X
               NOHANDLE
***********************************************************************
* Label to bypass WTO                                                 *
***********************************************************************
SY_9100  DS   0H
         L     R14,BAS_REG             Load return register
         BCR   B'1111',R14             Return to caller
*
*
***********************************************************************
* Literal Pool                                                        *
***********************************************************************
         LTORG
*
         DS   0F
*
         DS   0F
C_UID    DC    CL16'ESSUID'            ESSUID counter name
         DS   0F
C_VAL    DC    XL08'0000000000000001'  Doubleword 1
C_MIN    DC    XL08'0000000000000001'  Doubleword 1
C_MAX    DC    XL08'00000000FFFFFFFF'  Doubleword 4294967295.
*
         DS   0F
C_MSG_00 DC   0CL75
         DC    CL25'YYYY/MM/DD HH:MM:SS ESSUI'
         DC    CL25'D available - Count: 9999'
         DC    CL25'999999                   '
*
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
*
         DS   0F
WTO_RC_L DC    F'02'                   WTO Routecode length
WTO_RC   DC    XL02'0111'
         DS   0F
*
***********************************************************************
* Register assignments                                                *
***********************************************************************
         DS   0F
R0       EQU   0
R1       EQU   1
R2       EQU   2
R3       EQU   3
R4       EQU   4
R5       EQU   5
R6       EQU   6
R7       EQU   7
R8       EQU   8
R9       EQU   9
R10      EQU   10
R11      EQU   11
R12      EQU   12
R13      EQU   13
R14      EQU   14
R15      EQU   15
*
         PRINT ON
***********************************************************************
* End of Program                                                      *
***********************************************************************
         END   ZUIDPLT