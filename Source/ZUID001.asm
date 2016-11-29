*
*  PROGRAM:    ZUID001
*  AUTHOR:     Rich Jackson and Randy Frerking
*  DATE:       April 1, 2014
*  COMMENTS:   z/OS Unique Identifier service.
*
*
***********************************************************************
* Dynamic Storage Area (Start)                                        *
***********************************************************************
DFHEISTG DSECT
W_STCKE  DS    CL16               Absolute time - UTC STCKE TOD
*
         DS   0F
W_STCODE DS    CL02               Transaction start code
*
W_ID     DS   0F
W_PLEX   DS    CL04               z/OS Sysplex ID
W_ABS_E  DS    CL08               Absolute time - STCKE
W_NC     DS    CL04               Named Counter value - fullword
*
D_NC     DS    CL08               Named Counter value - doubleword
*
W_FORMAT DS    CL01               Format type
*                                 Plain
*                                 GUID
*                                 ESS
         DS   0F
W_BYTE   DS    CL01               One byte
         DS   0F
BAS_REG  DS    F                  BAS Register
***********************************************************************
* WEB SEND parameters                                                 *
***********************************************************************
         DS   0F
S_LENGTH DS    F                  Send length
S_ACTION DS    F                  Send action (immediate)
S_CONV   DS    F                  Server conversion type
S_CODE   DS    H                  HTTP STATUS code
S_TEXT_L DS    F                  HTTP STATUS text length
S_TEXT   DS    CL32               HTTP STATUS text
         DS   0F
S_GUID   DS    CL36               GUID  format
         DS   0F
S_ESS    DS    CL34               ESS   format
         DS   0F
S_PLAIN  DS    CL32               Plain format
         DS   0F
*
***********************************************************************
* Dynamic Storage Area (End)                                          *
***********************************************************************
*
***********************************************************************
* ESS  Response DSECT                                                 *
***********************************************************************
ESS_DS   DSECT
***********************************************************************
* DFHCOMMAREA                                                         *
***********************************************************************
DFHCA    DSECT
CA_TYPE  DS    CL04               Request Type
*                                 LINK
CA_SC    DS    CL03               Status code
CA_M_L   EQU   *-CA_TYPE          Minimum length
         DS    CL01
CA_RC    DS    CL02               Reason code
         DS    CL02
CA_PGMID DS    CL03               Program ID
         DS    CL01
CA_FORM  DS    CL05               UID format
*                                 ESS
*                                 B64B
*                                 GUID
*                                 PLAIN
         DS    CL03
CA_REG   DS    CL06               Registry
*                                 NONE   (default)
*                                 BASIC  (URI Path, UserID, etc)
*                                 CUSTOM (BASIC + application data)
         DS    CL02
CA_UID   DS    CL36               rzrUID
         DS    CL12
         DS    CL80               Future options
CA_H_L   EQU   *-CA_TYPE          Header length
CA_TEXT  DS    CL1024             Application text for CUSTOM registry
***********************************************************************
* Control Section                                                     *
***********************************************************************
ZUID001  DFHEIENT CODEREG=(R12),DATAREG=R10,EIBREG=R11
ZUID001  AMODE 31
ZUID001  RMODE 31
         B     SYSDATE                 BRANCH AROUND LITERALS
         DC    CL08'ZUID001  '
         DC    CL48' -- z/OS Unique Identifier Service'
         DC    CL08'        '
         DC    CL08'&SYSDATE'
         DC    CL08'        '
         DC    CL08'&SYSTIME'
SYSDATE  DS   0H
***********************************************************************
* Address DFHCOMMAREA                                                 *
***********************************************************************
SY_0000  DS   0H
         LH    R4,EIBCALEN             Load DFHCOMMAREA length
         L     R5,DFHEICAP             Load DFHCOMMAREA address
         USING DFHCA,R5                ... tell assembler
*
         LA    R1,CA_M_L               Load DFHCA minimum length
         CR    R4,R1                   EIBCALEN in range?
         BC    B'0100',RETURN          ... no,  issue RETURN
*
         CLC   0(4,R5),C_LINK          LINK request?
         BC    B'1000',PC_0010         ... yes, process accordingly
***********************************************************************
* Only HTTP GET requests are supported.                               *
***********************************************************************
SY_0010  DS   0H
         CLC   0(3,R5),C_GET           GET request?
         BC    B'0111',ER_405          ... no,  STATUS(405)
*
         MVI   W_FORMAT,C'P'           Set format to default PLAIN
***********************************************************************
* Parse DFHCOMMAREA  to find query string                             *
***********************************************************************
SY_0020  DS   0H
         CLI   0(R5),C'?'              Query string?
         BC    B'1000',SY_0030         ... yes, process
         LA    R5,1(,R5)               Point to next COMMAREA address
         BCT   R4,SY_0020              Continue parsing until R2=zero
         BC    B'1111',SY_0040         Continue processing
***********************************************************************
* Check query string OPTIONS.                                         *
* Valid options are FORMAT=GUID, FORMAT=PLAIN, or FORMAT=ESS          *
* ?OPTIONS(FORMAT=xxxxx)                                              *
***********************************************************************
SY_0030  DS   0H
         LR    R1,R4                   Load remaining EIBCALEN
         S     R1,=F'1'                Subtract for EX instruction
         EX    R1,OC_0030              Execute OC
*
         LA    R5,1(,R5)               Point past '?'
         MVC   W_FORMAT,15(R5)         Move format request type
*
         CLC   0(21,R5),C_PLAIN        PLAIN format request?
         BC    B'1000',SY_0040         ... yes, continue process
         CLC   0(20,R5),C_GUID         GUID  format request?
         BC    B'1000',SY_0040         ... yes, continue process
         CLC   0(19,R5),C_ESS          ESS   format request?
         BC    B'1000',SY_0040         ... yes, continue process
*
         BC    B'1111',ER_400          ... no,  STATUS(400)
OC_0030  OC    0(0,R5),U_CASE          Set upper case
***********************************************************************
* Access Coordinated Universal Time (UTC) using STCKE                 *
***********************************************************************
SY_0040  DS   0H
         STCKE W_STCKE                 Retrieve UTC
         MVC   W_ABS_E,W_STCKE         Move absoltue time
*
         EXEC CICS GET DCOUNTER(C_NC)                                  X
               VALUE(D_NC)                                             X
               WRAP                                                    X
               NOHANDLE
*
         OC    EIBRESP,EIBRESP         Zero return code?
         BC    B'0111',ER_503          ... no,  reject the request
*
         MVC   W_NC,D_NC+4             Only use first fullword
***********************************************************************
* Get Sysplex ID.                                                     *
***********************************************************************
SY_0050  DS   0H
         L     R15,X'10'               Load CVT  address
         L     R15,X'8C'(0,R15)        Load ECVT address
         MVC   W_PLEX,8(R15)           Move Sysplex ID
         TR    W_PLEX,C_TO_H           Switch zone and numeric bits
*
***********************************************************************
* Determine format type and branch accordingly.                       *
***********************************************************************
SY_0060  DS   0H
         CLI   W_FORMAT,C'P'           Plain type?
         BC    B'1000',SY_0100         ... yes, create plain text
         CLI   W_FORMAT,C'G'           GUID  type?
         BC    B'1000',SY_0200         ... yes, create GUID  text
         CLI   W_FORMAT,C'E'           ESS   type?
         BC    B'1000',SY_0300         ... yes, create ESS   text
*
***********************************************************************
* Format type PLAIN requested.  Build the output accordingly.         *
***********************************************************************
SY_0100  DS   0H
         LA    R2,16                   Load ID length
         LA    R3,W_ID                 Load ID address
         LA    R5,S_PLAIN              Load Plain format address
*
***********************************************************************
* Format type PLAIN requested.  Build the output accordingly.         *
***********************************************************************
SY_0110  DS   0H
         XC    W_BYTE,W_BYTE           Clear work area
         MVZ   W_BYTE,0(R3)            Move ID zone bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
*
         XC    W_BYTE,W_BYTE           Clear work area
         MVN   W_BYTE,0(R3)            Move ID numeric bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
         LA    R3,1(0,R3)              Point to next ID byte
         BCT   R2,SY_0110              Continue process
*
         LA    R2,S_PLAIN              Load Plain format address
         MVC   S_LENGTH,=F'32'         Move Plain format length
         BC    B'1111',SY_0900         Issue WEB SEND
*
***********************************************************************
* Format type GUID  requested.  Build the output accordingly.         *
***********************************************************************
SY_0200  DS   0H
         LA    R2,16                   Load ID length
         LA    R3,W_ID                 Load ID address
         LA    R4,G_MARKER             Load GUID  marker address
         LA    R5,S_GUID               Load GUID  format address
*
***********************************************************************
* Format type GUID  requested.  Build the output accordingly.         *
***********************************************************************
SY_0210  DS   0H
         XC    W_BYTE,W_BYTE           Clear work area
         MVZ   W_BYTE,0(R3)            Move ID zone bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
*
         XC    W_BYTE,W_BYTE           Clear work area
         MVN   W_BYTE,0(R3)            Move ID numeric bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
*
         CLI   0(R4),C'-'              Marker set?
         BC    B'0111',SY_0220         ... no,  bypass hyphen
         MVI   0(R5),C'-'              Move hyphen
         LA    R5,1(0,R5)              Point to next buffer byte
*
***********************************************************************
* Continue the process until the GUID is complete.                    *
***********************************************************************
SY_0220  DS   0H
         LA    R4,1(,R4)               Point to next marker byte
         LA    R3,1(0,R3)              Point to next ID byte
         BCT   R2,SY_0210              Continue process
*
         LA    R2,S_GUID               Load GUID  format address
         MVC   S_LENGTH,=F'36'         Move GUID  format length
         BC    B'1111',SY_0900         Issue WEB SEND
*
***********************************************************************
* Format type ESS   requested.  Build the output accordingly.         *
***********************************************************************
SY_0300  DS   0H
         LA    R2,16                   Load ID length
         LA    R3,W_ID                 Load ID address
         LA    R4,E_MARKER             Load ESS   marker address
         LA    R5,S_ESS                Load ESS   format address
*
***********************************************************************
* Format type ESS   requested.  Build the output accordingly.         *
***********************************************************************
SY_0310  DS   0H
         XC    W_BYTE,W_BYTE           Clear work area
         MVZ   W_BYTE,0(R3)            Move ID zone bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
*
         XC    W_BYTE,W_BYTE           Clear work area
         MVN   W_BYTE,0(R3)            Move ID numeric bits
         TR    W_BYTE,H_TO_C           Convert to character
         MVC   0(1,R5),W_BYTE          Move character to buffer
         LA    R5,1(0,R5)              Point to next buffer byte
*
         CLI   0(R4),C'-'              Marker set?
         BC    B'0111',SY_0320         ... no,  bypass hyphen
         MVI   0(R5),C'-'              Move hyphen
         LA    R5,1(0,R5)              Point to next buffer byte
*
***********************************************************************
* Continue the process until the ESS  is complete.                    *
***********************************************************************
SY_0320  DS   0H
         LA    R4,1(,R4)               Point to next marker byte
         LA    R3,1(0,R3)              Point to next ID byte
         BCT   R2,SY_0310              Continue process
*
         LA    R2,S_ESS                Load ESS   format address
         MVC   S_LENGTH,=F'34'         Move ESS   format length
         BC    B'1111',SY_0900         Issue WEB SEND
*
***********************************************************************
* Process complete                                                    *
***********************************************************************
SY_0900  DS   0H
         L     R5,DFHEICAP             Load DFHCOMMAREA address
         CLC   0(4,R5),C_LINK          LINK request?
         BC    B'1000',PC_0090         ... yes, process accordingly
*
         MVC   S_CODE,C_200            Move status code
         MVC   S_TEXT,C_200_T          Move status text
         MVC   S_TEXT_L,C_200_L        Move status text length
         BAS   R14,SY_SEND             Send response
*
***********************************************************************
* Return to caller                                                    *
**********************************************************************
RETURN   DS   0H
         EXEC CICS RETURN
*
***********************************************************************
* Send response                                                       *
***********************************************************************
SY_SEND  DS   0H
         ST    R14,BAS_REG             Save R14
         USING ESS_DS,R2               R2 points to the response
*
*
         EXEC CICS WEB WRITE                                           X
               HTTPHEADER (H_ACAO)                                     X
               NAMELENGTH (H_ACAO_L)                                   X
               VALUE      (M_ACAO)                                     X
               VALUELENGTH(M_ACAO_L)                                   X
               NOHANDLE
*
*
         EXEC CICS WEB SEND                                            X
               FROM      (ESS_DS)                                      X
               FROMLENGTH(S_LENGTH)                                    X
               STATUSCODE(S_CODE)                                      X
               STATUSTEXT(S_TEXT)                                      X
               STATUSLEN (S_TEXT_L)                                    X
               MEDIATYPE (C_MEDIA)                                     X
               SRVCONVERT                                              X
               IMMEDIATE                                               X
               NOHANDLE
*
         L     R14,BAS_REG             Load R14
         BCR   B'1111',R14             Return to caller
*
***********************************************************************
* Request initiated via LINK.                                         *
***********************************************************************
PC_0010  DS   0H
         LA    R1,CA_H_L               Load DFHCA header length
         CR    R4,R1                   EIBCALEN in range?
         BC    B'1011',PC_0020         ... yes, continue process
*
         MVC   CA_SC,=C'409'           Move status code 409
         BC    B'1111',RETURN          Return to calling program
***********************************************************************
* Edit requested FORMAT.                                              *
***********************************************************************
PC_0020  DS   0H
         MVC   W_FORMAT,CA_FORM        Set format request type
*
         CLC   CA_FORM(5),C_PLAIN+15   PLAIN format request?
         BC    B'1000',PC_0030         ... yes, continue process
         CLC   CA_FORM(4),C_GUID+15    GUID  format request?
         BC    B'1000',PC_0030         ... yes, continue process
         CLC   CA_FORM(3),C_ESS+15     ESS  format request?
         BC    B'1000',PC_0030         ... yes, continue process
*
         XC    CA_UID,CA_UID           Null UID field
         MVC   CA_UID(32),C_415_M      Move status code 415 message
         MVC   CA_SC,=C'415'           Move status code 415
         MVC   CA_RC,=C'01'            Move reason code  01
         MVC   CA_PGMID,=C'001'        Move program ID  001
         BC    B'1111',RETURN          Return to calling program
***********************************************************************
* Jump back into the UID creation process.                            *
***********************************************************************
PC_0030  DS   0H
         BC    B'1111',SY_0040         Create UID
***********************************************************************
* Well, we're back.  Format the response and return to the calling    *
* program.                                                            *
***********************************************************************
PC_0090  DS   0H
         MVC   CA_SC,=C'200'           Move status code 200
         MVC   CA_RC,=C'00'            Move reason code  00
         MVC   CA_PGMID,=C'001'        Move program ID  001
         XC    CA_UID,CA_UID           Clear UID
         LA    R15,CA_UID              Load target address
         L     R1,S_LENGTH             Load target length
         S     R1,=F'1'                Subtract 1 for MVC instruction
         EX    R1,MVC_0090             Execute MVC instruction
         BC    B'1111',RETURN          Return to calling program
*
MVC_0090 MVC   0(0,R15),0(R2)          Move UID to DFHCOMMAREA
*
***********************************************************************
* STATUS 400                                                          *
**********************************************************************
ER_400   DS   0H
         LA    R2,C_400_T              Load 400 error text
         MVC   S_LENGTH,C_400_L        Move 400 error length
         MVC   S_CODE,C_400            Move status code
         MVC   S_TEXT,C_400_T          Move status text
         MVC   S_TEXT_L,C_400_L        Move status text length
         BAS   R14,SY_SEND             Send response
         BC    B'1111',RETURN          Return to CICS
*
***********************************************************************
* STATUS 405 (HTTP)                                                   *
**********************************************************************
ER_405   DS   0H
         EXEC CICS ASSIGN STARTCODE(W_STCODE)
         CLI   W_STCODE,C'U'           WEB request?
         BC    B'0111',ER_405PC        ... no,  invalid LINK request
*
         LA    R2,C_405_T              Load 405 error text
         MVC   S_LENGTH,C_405_L        Move 405 error length
         MVC   S_CODE,C_405            Move status code
         MVC   S_TEXT,C_405_T          Move status text
         MVC   S_TEXT_L,C_405_L        Move status text length
         BAS   R14,SY_SEND             Send response
         BC    B'1111',RETURN          Return to CICS
*
***********************************************************************
* STATUS 405 (LINK)                                                   *
**********************************************************************
ER_405PC DS   0H
         XC    CA_UID,CA_UID           Null UID field
         MVC   CA_UID(32),C_405_M      Move status code 405 message
         MVC   CA_SC,=C'405'           Move status code 405
         MVC   CA_RC,=C'01'            Move reason code  01
         MVC   CA_PGMID,=C'001'        Move program ID  001
         BC    B'1111',RETURN          Return to calling program
***********************************************************************
* STATUS 503 (HTTP)                                                   *
**********************************************************************
ER_503   DS   0H
         EXEC CICS ASSIGN STARTCODE(W_STCODE)
         CLI   W_STCODE,C'U'           WEB request?
         BC    B'0111',ER_503PC        ... no,  invalid LINK request
*
         LA    R2,C_503_T              Load 405 error text
         MVC   S_LENGTH,C_503_L        Move 405 error length
         MVC   S_CODE,C_503            Move status code
         MVC   S_TEXT,C_503_T          Move status text
         MVC   S_TEXT_L,C_503_L        Move status text length
         BAS   R14,SY_SEND             Send response
         BC    B'1111',RETURN          Return to CICS
*
***********************************************************************
* STATUS 503 (LINK)                                                   *
**********************************************************************
ER_503PC DS   0H
         XC    CA_UID,CA_UID           Null UID field
         MVC   CA_UID(32),C_503_T      Move status code 503 message
         MVC   CA_SC,=C'503'           Move status code 503
         MVC   CA_RC,=C'01'            Move reason code  01
         MVC   CA_PGMID,=C'001'        Move program ID  001
         BC    B'1111',RETURN          Return to calling program
*
***********************************************************************
* Define Constant                                                     *
***********************************************************************
         DS   0F
U_CASE   DC    24CL01' '               Upper Case mask
         DS   0F
G_MARKER DC    CL16'   - - - -      '  GUID marker
         DS   0F
E_MARKER DC    CL16'   -       -    '  ESS  marker
         DS   0F
C_NC     DC    CL16'ESSUID          '  ESSUID Named Counter
         DS   0F
C_GUID   DC    CL16'OPTIONS(FORMAT=G'  GUID   format request
         DC    CL04'UID)'
         DS   0F
C_PLAIN  DC    CL16'OPTIONS(FORMAT=P'  PLAIN  format request
         DC    CL05'LAIN)'
         DS   0F
C_ESS    DC    CL16'OPTIONS(FORMAT=E'  ESSUID format request
         DC    CL03'SS)'
         DS   0F
C_LINK   DC    CL04'LINK'              Program Control LINK
         DS   0F
C_GET    DC    CL03'GET'               HTTP GET
         DS   0F
C_MEDIA  DC    CL56'text/plain'        Media type
         DS   0F
C_200    DC    H'200'                  Status code
         DS   0F
C_200_T  DC    CL16'Request Complete'  Status text
         DC    CL16'                '
         DS   0F
C_200_l  DC    F'32'                   Status length
         DS   0F
C_400    DC    H'400'                  Status code
         DS   0F
C_400_T  DC    CL16'Invalid Query St'  Status text
         DC    CL16'ring option     '
         DS   0F
C_400_L  DC    F'32'                   Status length
         DS   0F
C_405    DC    H'405'                  Status code
         DS   0F
C_405_T  DC    CL16'Invalid Request '  Status text HTTP
         DC    CL16'Only GET Allowed'
         DS   0F
C_405_M  DC    CL16'Request TYPE mus'  Status text LINK
         DC    CL16't be LINK.      '
         DS   0F
C_405_L  DC    F'32'                   Status length
         DS   0F
C_409    DC    H'409'                  Status code
         DS   0F
C_415    DC    H'415'                  Status code
         DS   0F
C_415_M  DC    CL16'Invalid FORMAT r'  Status text LINK
         DC    CL16'equested.       '
*
         DS   0F
C_503    DC    H'503'                  Status code
         DS   0F
C_503_T  DC    CL16'01-001 Named Cou'  Status text HTTP
         DC    CL16'nter unavailable'
         DS   0F
C_503_L  DC    F'32'                   Status length
*
         DS   0F
NULLS    DC    32XL01'00'
FOXES    DC    XL04'FFFFFFFF'
         DS   0F
M_ACAO_L DC    F'01'                   HTTP Header message length
         DS   0F
M_ACAO   DC    CL01'*'                 HTTP Header message
         DS   0F
H_ACAO_L DC    F'27'                   HTTP Header length
         DS   0F
H_ACAO   DC    CL16'Access-Control-A'  HTTP Header
         DC    CL11'llow-Origin'       ...  continued
         DS   0F
*
***********************************************************************
* Translate table - Hex to Character                                  *
***********************************************************************
         DS   0F
H_TO_C   DC    XL16'F0F1F2F3F4F5F6F7F8F9818283848586'       00-0F
         DC    XL16'F1000000000000000000000000000000'       10-1F
         DC    XL16'F2000000000000000000000000000000'       20-2F
         DC    XL16'F3000000000000000000000000000000'       30-3F
         DC    XL16'F4000000000000000000000000000000'       40-4F
         DC    XL16'F5000000000000000000000000000000'       50-5F
         DC    XL16'F6000000000000000000000000000000'       60-6F
         DC    XL16'F7000000000000000000000000000000'       70-7F
         DC    XL16'F8000000000000000000000000000000'       80-8F
         DC    XL16'F9000000000000000000000000000000'       90-9F
         DC    XL16'81000000000000000000000000000000'       A0-AF
         DC    XL16'82000000000000000000000000000000'       B0-BF
         DC    XL16'83000000000000000000000000000000'       C0-CF
         DC    XL16'84000000000000000000000000000000'       D0-DF
         DC    XL16'85000000000000000000000000000000'       E0-EF
         DC    XL16'86000000000000000000000000000000'       F0-FF
*
***********************************************************************
* Translate table - Character to hex                                  *
***********************************************************************
         DS   0F
C_TO_H   DC    XL16'00000000000000000000000000000000'       00-0F
         DC    XL16'00000000000000000000000000000000'       10-1F
         DC    XL16'00000000000000000000000000000000'       20-2F
         DC    XL16'00000000000000000000000000000000'       30-3F
         DC    XL16'00000000000000000000000000000000'       40-4F
         DC    XL16'00000000000000000000000000000000'       50-5F
         DC    XL16'00000000000000000000000000000000'       60-6F
         DC    XL16'00000000000000000000000000000000'       70-7F
         DC    XL16'00000000000000000000000000000000'       80-8F
         DC    XL16'00000000000000000000000000000000'       90-9F
         DC    XL16'00000000000000000000000000000000'       A0-AF
         DC    XL16'00000000000000000000000000000000'       B0-BF
         DC    XL16'001C2C3C4C5C6C7C8C9C000000000000'       C0-CF
         DC    XL16'001D2D3D4D5D6D7D8D9D000000000000'       D0-DF
         DC    XL16'001E2E3E4E5E6E7E8E9E000000000000'       E0-EF
         DC    XL16'0F1F2F3F4F5F6F7F8F9F000000000000'       F0-FF
*
         DS   0F
*
***********************************************************************
* Literal Pool                                                        *
***********************************************************************
         LTORG
*
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
***********************************************************************
* Communications Vector Table                                         *
**********************************************************************
         PRINT ON
         CVT   DSECT=YES,LIST=YES
*
***********************************************************************
* End of Program                                                      *
**********************************************************************
         END   ZUID001