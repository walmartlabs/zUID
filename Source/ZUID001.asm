*                                                                       00010042
*  PROGRAM:    ZUID001                                                  00020042
*  AUTHOR:     Rich Jackson and Randy Frerking                          00030079
*  DATE:       April 1, 2014                                            00050042
*  COMMENTS:   z/OS Unique Identifier service.                          00060079
*                                                                       00070042
*                                                                       00080042
*********************************************************************** 00110042
* Dynamic Storage Area (Start)                                        * 00120042
*********************************************************************** 00130042
DFHEISTG DSECT                                                          00140042
W_STCKE  DS    CL16               Absolute time - UTC STCKE TOD         00170065
*                                                                       00180042
         DS   0F                                                        00181073
W_STCODE DS    CL02               Transaction start code                00190073
*                                                                       00190173
W_ID     DS   0F                                                        00190273
W_PLEX   DS    CL04               z/OS Sysplex ID                       00191043
W_ABS_E  DS    CL08               Absolute time - STCKE                 00240065
W_NC     DS    CL04               Named Counter value - fullword        00250053
*                                                                       00260042
D_NC     DS    CL08               Named Counter value - doubleword      00261053
*                                                                       00262053
W_FORMAT DS    CL01               Format type                           00270042
*                                 Plain                                 00280042
*                                 GUID                                  00290042
*                                 ESS                                   00300042
         DS   0F                                                        00301042
W_BYTE   DS    CL01               One byte                              00302042
         DS   0F                                                        00303042
BAS_REG  DS    F                  BAS Register                          00304042
*********************************************************************** 00305042
* WEB SEND parameters                                                 * 00306042
*********************************************************************** 00307042
         DS   0F                                                        00308042
S_LENGTH DS    F                  Send length                           00309042
S_ACTION DS    F                  Send action (immediate)               00310042
S_CONV   DS    F                  Server conversion type                00320042
S_CODE   DS    H                  HTTP STATUS code                      00321042
S_TEXT_L DS    F                  HTTP STATUS text length               00322042
S_TEXT   DS    CL32               HTTP STATUS text                      00322142
         DS   0F                                                        00322242
S_GUID   DS    CL36               GUID  format                          00322342
         DS   0F                                                        00322442
S_ESS    DS    CL34               ESS   format                          00322542
         DS   0F                                                        00322642
S_PLAIN  DS    CL32               Plain format                          00322742
         DS   0F                                                        00322842
*                                                                       00322942
*********************************************************************** 00323042
* Dynamic Storage Area (End)                                          * 00324042
*********************************************************************** 00325042
*                                                                       00326042
*********************************************************************** 00327042
* ESS  Response DSECT                                                 * 00328042
*********************************************************************** 00329042
ESS_DS   DSECT                                                          00330042
*********************************************************************** 00340042
* DFHCOMMAREA                                                         * 00350042
*********************************************************************** 00360042
DFHCA    DSECT                                                          00370042
CA_TYPE  DS    CL04               Request Type                          00372055
*                                 LINK                                  00372155
CA_SC    DS    CL03               Status code                           00372255
CA_M_L   EQU   *-CA_TYPE          Minimum length                        00372357
         DS    CL01                                                     00372457
CA_RC    DS    CL02               Reason code                           00373055
         DS    CL02                                                     00373157
CA_PGMID DS    CL03               Program ID                            00374057
         DS    CL01                                                     00374157
CA_FORM  DS    CL05               UID format                            00375055
*                                 ESS                                   00375155
*                                 B64B                                  00375255
*                                 GUID                                  00375355
*                                 PLAIN                                 00375455
         DS    CL03                                                     00376057
CA_REG   DS    CL06               Registry                              00377055
*                                 NONE   (default)                      00378055
*                                 BASIC  (URI Path, UserID, etc)        00379055
*                                 CUSTOM (BASIC + application data)     00379155
         DS    CL02                                                     00379257
CA_UID   DS    CL36               rzrUID                                00379355
         DS    CL12                                                     00379457
         DS    CL80               Future options                        00379557
CA_H_L   EQU   *-CA_TYPE          Header length                         00379656
CA_TEXT  DS    CL1024             Application text for CUSTOM registry  00379755
*********************************************************************** 00380042
* Control Section                                                     * 00390042
*********************************************************************** 00400042
ZUID001  DFHEIENT CODEREG=(R12),DATAREG=R10,EIBREG=R11                  00410042
ZUID001  AMODE 31                                                       00420042
ZUID001  RMODE 31                                                       00430042
         B     SYSDATE                 BRANCH AROUND LITERALS           00440042
         DC    CL08'ZUID001  '                                          00450042
         DC    CL48' -- z/OS Unique Identifier Service'                 00460079
         DC    CL08'        '                                           00470042
         DC    CL08'&SYSDATE'                                           00480042
         DC    CL08'        '                                           00490042
         DC    CL08'&SYSTIME'                                           00500042
SYSDATE  DS   0H                                                        00510042
*********************************************************************** 00520042
* Address DFHCOMMAREA                                                 * 00530042
*********************************************************************** 00540042
SY_0000  DS   0H                                                        00550042
         LH    R4,EIBCALEN             Load DFHCOMMAREA length          00560042
         L     R5,DFHEICAP             Load DFHCOMMAREA address         00570042
         USING DFHCA,R5                ... tell assembler               00580042
*                                                                       00580157
         LA    R1,CA_M_L               Load DFHCA minimum length        00580257
         CR    R4,R1                   EIBCALEN in range?               00580357
         BC    B'0100',RETURN          ... no,  issue RETURN            00580457
*                                                                       00580557
         CLC   0(4,R5),C_LINK          LINK request?                    00580657
         BC    B'1000',PC_0010         ... yes, process accordingly     00580757
*********************************************************************** 00590042
* Only HTTP GET requests are supported.                               * 00600042
*********************************************************************** 00610042
SY_0010  DS   0H                                                        00620042
         CLC   0(3,R5),C_GET           GET request?                     00630042
         BC    B'0111',ER_405          ... no,  STATUS(405)             00640042
*                                                                       00650042
         MVI   W_FORMAT,C'P'           Set format to default PLAIN      00660042
*********************************************************************** 00670042
* Parse DFHCOMMAREA  to find query string                             * 00680042
*********************************************************************** 00690042
SY_0020  DS   0H                                                        00700042
         CLI   0(R5),C'?'              Query string?                    00710042
         BC    B'1000',SY_0030         ... yes, process                 00720042
         LA    R5,1(,R5)               Point to next COMMAREA address   00730042
         BCT   R4,SY_0020              Continue parsing until R2=zero   00740042
         BC    B'1111',SY_0040         Continue processing              00750042
*********************************************************************** 00760042
* Check query string OPTIONS.                                         * 00770042
* Valid options are FORMAT=GUID, FORMAT=PLAIN, or FORMAT=ESS          * 00780042
* ?OPTIONS(FORMAT=xxxxx)                                              * 00790042
*********************************************************************** 00791042
SY_0030  DS   0H                                                        00792042
         LR    R1,R4                   Load remaining EIBCALEN          00792171
         S     R1,=F'1'                Subtract for EX instruction      00792271
         EX    R1,OC_0030              Execute OC                       00792371
*                                                                       00792471
         LA    R5,1(,R5)               Point past '?'                   00793042
         MVC   W_FORMAT,15(R5)         Move format request type         00794042
*                                                                       00794142
         CLC   0(21,R5),C_PLAIN        PLAIN format request?            00794242
         BC    B'1000',SY_0040         ... yes, continue process        00794342
         CLC   0(20,R5),C_GUID         GUID  format request?            00794442
         BC    B'1000',SY_0040         ... yes, continue process        00794542
         CLC   0(19,R5),C_ESS          ESS   format request?            00794646
         BC    B'1000',SY_0040         ... yes, continue process        00794742
*                                                                       00794842
         BC    B'1111',ER_400          ... no,  STATUS(400)             00794942
OC_0030  OC    0(0,R5),U_CASE          Set upper case                   00795071
*********************************************************************** 00795142
* Access Coordinated Universal Time (UTC) using STCKE                 * 00796065
*********************************************************************** 00796142
SY_0040  DS   0H                                                        00796242
         STCKE W_STCKE                 Retrieve UTC                     00796765
         MVC   W_ABS_E,W_STCKE         Move absoltue time               00796865
*                                                                       00797042
         EXEC CICS GET DCOUNTER(C_NC)                                  X00797153
               VALUE(D_NC)                                             X00797253
               WRAP                                                    X00797342
               NOHANDLE                                                 00798042
*                                                                       00798153
         OC    EIBRESP,EIBRESP         Zero return code?                00798277
         BC    B'0111',ER_503          ... no,  reject the request      00798377
*                                                                       00798477
         MVC   W_NC,D_NC+4             Only use first fullword          00799053
*********************************************************************** 00799842
* Get Sysplex ID.                                                     * 00799942
*********************************************************************** 00800042
SY_0050  DS   0H                                                        00800243
         L     R15,X'10'               Load CVT  address                00800547
         L     R15,X'8C'(0,R15)        Load ECVT address                00800647
         MVC   W_PLEX,8(R15)           Move Sysplex ID                  00800747
         TR    W_PLEX,C_TO_H           Switch zone and numeric bits     00800847
*                                                                       00801042
*********************************************************************** 00801142
* Determine format type and branch accordingly.                       * 00801242
*********************************************************************** 00801342
SY_0060  DS   0H                                                        00801443
         CLI   W_FORMAT,C'P'           Plain type?                      00801547
         BC    B'1000',SY_0100         ... yes, create plain text       00801647
         CLI   W_FORMAT,C'G'           GUID  type?                      00801747
         BC    B'1000',SY_0200         ... yes, create GUID  text       00801847
         CLI   W_FORMAT,C'E'           ESS   type?                      00801947
         BC    B'1000',SY_0300         ... yes, create ESS   text       00802047
*                                                                       00802142
*********************************************************************** 00802242
* Format type PLAIN requested.  Build the output accordingly.         * 00802342
*********************************************************************** 00802442
SY_0100  DS   0H                                                        00802542
         LA    R2,16                   Load ID length                   00802647
         LA    R3,W_ID                 Load ID address                  00802747
         LA    R5,S_PLAIN              Load Plain format address        00802847
*                                                                       00802942
*********************************************************************** 00803042
* Format type PLAIN requested.  Build the output accordingly.         * 00803142
*********************************************************************** 00803242
SY_0110  DS   0H                                                        00803342
         XC    W_BYTE,W_BYTE           Clear work area                  00803447
         MVZ   W_BYTE,0(R3)            Move ID zone bits                00803547
         TR    W_BYTE,H_TO_C           Convert to character             00803647
         MVC   0(1,R5),W_BYTE          Move character to buffer         00803747
         LA    R5,1(0,R5)              Point to next buffer byte        00803847
*                                                                       00803942
         XC    W_BYTE,W_BYTE           Clear work area                  00804047
         MVN   W_BYTE,0(R3)            Move ID numeric bits             00804147
         TR    W_BYTE,H_TO_C           Convert to character             00804247
         MVC   0(1,R5),W_BYTE          Move character to buffer         00804347
         LA    R5,1(0,R5)              Point to next buffer byte        00804447
         LA    R3,1(0,R3)              Point to next ID byte            00804547
         BCT   R2,SY_0110              Continue process                 00804647
*                                                                       00804742
         LA    R2,S_PLAIN              Load Plain format address        00804847
         MVC   S_LENGTH,=F'32'         Move Plain format length         00804947
         BC    B'1111',SY_0900         Issue WEB SEND                   00805047
*                                                                       00805142
*********************************************************************** 00805242
* Format type GUID  requested.  Build the output accordingly.         * 00805342
*********************************************************************** 00805442
SY_0200  DS   0H                                                        00805542
         LA    R2,16                   Load ID length                   00805647
         LA    R3,W_ID                 Load ID address                  00805747
         LA    R4,G_MARKER             Load GUID  marker address        00805847
         LA    R5,S_GUID               Load GUID  format address        00805947
*                                                                       00806042
*********************************************************************** 00806142
* Format type GUID  requested.  Build the output accordingly.         * 00806242
*********************************************************************** 00806342
SY_0210  DS   0H                                                        00806442
         XC    W_BYTE,W_BYTE           Clear work area                  00806547
         MVZ   W_BYTE,0(R3)            Move ID zone bits                00806647
         TR    W_BYTE,H_TO_C           Convert to character             00806747
         MVC   0(1,R5),W_BYTE          Move character to buffer         00806847
         LA    R5,1(0,R5)              Point to next buffer byte        00806947
*                                                                       00807042
         XC    W_BYTE,W_BYTE           Clear work area                  00807147
         MVN   W_BYTE,0(R3)            Move ID numeric bits             00807247
         TR    W_BYTE,H_TO_C           Convert to character             00807347
         MVC   0(1,R5),W_BYTE          Move character to buffer         00807447
         LA    R5,1(0,R5)              Point to next buffer byte        00807547
*                                                                       00807642
         CLI   0(R4),C'-'              Marker set?                      00807747
         BC    B'0111',SY_0220         ... no,  bypass hyphen           00807847
         MVI   0(R5),C'-'              Move hyphen                      00807947
         LA    R5,1(0,R5)              Point to next buffer byte        00808047
*                                                                       00808142
*********************************************************************** 00808242
* Continue the process until the GUID is complete.                    * 00808342
*********************************************************************** 00808442
SY_0220  DS   0H                                                        00808542
         LA    R4,1(,R4)               Point to next marker byte        00808647
         LA    R3,1(0,R3)              Point to next ID byte            00808747
         BCT   R2,SY_0210              Continue process                 00808847
*                                                                       00808942
         LA    R2,S_GUID               Load GUID  format address        00809047
         MVC   S_LENGTH,=F'36'         Move GUID  format length         00809147
         BC    B'1111',SY_0900         Issue WEB SEND                   00809247
*                                                                       00810042
*********************************************************************** 00811042
* Format type ESS   requested.  Build the output accordingly.         * 00811142
*********************************************************************** 00811242
SY_0300  DS   0H                                                        00811342
         LA    R2,16                   Load ID length                   00811447
         LA    R3,W_ID                 Load ID address                  00811547
         LA    R4,E_MARKER             Load ESS   marker address        00811647
         LA    R5,S_ESS                Load ESS   format address        00811747
*                                                                       00811842
*********************************************************************** 00811942
* Format type ESS   requested.  Build the output accordingly.         * 00812042
*********************************************************************** 00812142
SY_0310  DS   0H                                                        00812242
         XC    W_BYTE,W_BYTE           Clear work area                  00812347
         MVZ   W_BYTE,0(R3)            Move ID zone bits                00812447
         TR    W_BYTE,H_TO_C           Convert to character             00812547
         MVC   0(1,R5),W_BYTE          Move character to buffer         00812647
         LA    R5,1(0,R5)              Point to next buffer byte        00812747
*                                                                       00812842
         XC    W_BYTE,W_BYTE           Clear work area                  00812947
         MVN   W_BYTE,0(R3)            Move ID numeric bits             00813047
         TR    W_BYTE,H_TO_C           Convert to character             00813147
         MVC   0(1,R5),W_BYTE          Move character to buffer         00813247
         LA    R5,1(0,R5)              Point to next buffer byte        00813347
*                                                                       00813442
         CLI   0(R4),C'-'              Marker set?                      00813547
         BC    B'0111',SY_0320         ... no,  bypass hyphen           00813647
         MVI   0(R5),C'-'              Move hyphen                      00813747
         LA    R5,1(0,R5)              Point to next buffer byte        00813847
*                                                                       00813942
*********************************************************************** 00814042
* Continue the process until the ESS  is complete.                    * 00814142
*********************************************************************** 00814242
SY_0320  DS   0H                                                        00814342
         LA    R4,1(,R4)               Point to next marker byte        00814447
         LA    R3,1(0,R3)              Point to next ID byte            00814547
         BCT   R2,SY_0310              Continue process                 00814647
*                                                                       00814742
         LA    R2,S_ESS                Load ESS   format address        00814847
         MVC   S_LENGTH,=F'34'         Move ESS   format length         00814947
         BC    B'1111',SY_0900         Issue WEB SEND                   00815047
*                                                                       00815142
*********************************************************************** 00815242
* Process complete                                                    * 00815342
*********************************************************************** 00815442
SY_0900  DS   0H                                                        00815542
         L     R5,DFHEICAP             Load DFHCOMMAREA address         00815660
         CLC   0(4,R5),C_LINK          LINK request?                    00815758
         BC    B'1000',PC_0090         ... yes, process accordingly     00815858
*                                                                       00815958
         MVC   S_CODE,C_200            Move status code                 00816047
         MVC   S_TEXT,C_200_T          Move status text                 00816147
         MVC   S_TEXT_L,C_200_L        Move status text length          00816247
         BAS   R14,SY_SEND             Send response                    00816347
*                                                                       00816442
*********************************************************************** 00817042
* Return to caller                                                    * 00818042
**********************************************************************  00819042
RETURN   DS   0H                                                        00820042
         EXEC CICS RETURN                                               00830042
*                                                                       00840042
*********************************************************************** 00841042
* Send response                                                       * 00842042
*********************************************************************** 00843042
SY_SEND  DS   0H                                                        00844042
         ST    R14,BAS_REG             Save R14                         00844147
         USING ESS_DS,R2               R2 points to the response        00844247
*                                                                       00844342
*                                                                       00844467
         EXEC CICS WEB WRITE                                           X00844567
               HTTPHEADER (H_ACAO)                                     X00844667
               NAMELENGTH (H_ACAO_L)                                   X00844767
               VALUE      (M_ACAO)                                     X00844867
               VALUELENGTH(M_ACAO_L)                                   X00844967
               NOHANDLE                                                 00845067
*                                                                       00845167
*                                                                       00845267
         EXEC CICS WEB SEND                                            X00845367
               FROM      (ESS_DS)                                      X00845467
               FROMLENGTH(S_LENGTH)                                    X00845567
               STATUSCODE(S_CODE)                                      X00845667
               STATUSTEXT(S_TEXT)                                      X00845767
               STATUSLEN (S_TEXT_L)                                    X00845867
               MEDIATYPE (C_MEDIA)                                     X00845967
               SRVCONVERT                                              X00846042
               IMMEDIATE                                               X00847042
               NOHANDLE                                                 00848042
*                                                                       00849042
         L     R14,BAS_REG             Load R14                         00850047
         BCR   B'1111',R14             Return to caller                 00850147
*                                                                       00850242
*********************************************************************** 00850357
* Request initiated via LINK.                                         * 00850457
*********************************************************************** 00850557
PC_0010  DS   0H                                                        00850657
         LA    R1,CA_H_L               Load DFHCA header length         00850857
         CR    R4,R1                   EIBCALEN in range?               00850957
         BC    B'1011',PC_0020         ... yes, continue process        00851057
*                                                                       00851157
         MVC   CA_SC,=C'409'           Move status code 409             00851261
         BC    B'1111',RETURN          Return to calling program        00851357
*********************************************************************** 00851457
* Edit requested FORMAT.                                              * 00851557
*********************************************************************** 00851657
PC_0020  DS   0H                                                        00851757
         MVC   W_FORMAT,CA_FORM        Set format request type          00851857
*                                                                       00851957
         CLC   CA_FORM(5),C_PLAIN+15   PLAIN format request?            00852057
         BC    B'1000',PC_0030         ... yes, continue process        00852157
         CLC   CA_FORM(4),C_GUID+15    GUID  format request?            00852258
         BC    B'1000',PC_0030         ... yes, continue process        00852357
         CLC   CA_FORM(3),C_ESS+15     ESS  format request?             00852458
         BC    B'1000',PC_0030         ... yes, continue process        00852557
*                                                                       00852657
         XC    CA_UID,CA_UID           Null UID field                   00852776
         MVC   CA_UID(32),C_415_M      Move status code 415 message     00852876
         MVC   CA_SC,=C'415'           Move status code 415             00852961
         MVC   CA_RC,=C'01'            Move reason code  01             00853061
         MVC   CA_PGMID,=C'001'        Move program ID  001             00853157
         BC    B'1111',RETURN          Return to calling program        00853257
*********************************************************************** 00853358
* Jump back into the UID creation process.                            * 00853458
*********************************************************************** 00853558
PC_0030  DS   0H                                                        00853658
         BC    B'1111',SY_0040         Create UID                       00853758
*********************************************************************** 00853858
* Well, we're back.  Format the response and return to the calling    * 00853958
* program.                                                            * 00854058
*********************************************************************** 00854158
PC_0090  DS   0H                                                        00854258
         MVC   CA_SC,=C'200'           Move status code 200             00854361
         MVC   CA_RC,=C'00'            Move reason code  00             00854461
         MVC   CA_PGMID,=C'001'        Move program ID  001             00854558
         XC    CA_UID,CA_UID           Clear UID                        00854658
         LA    R15,CA_UID              Load target address              00854758
         L     R1,S_LENGTH             Load target length               00854859
         S     R1,=F'1'                Subtract 1 for MVC instruction   00854966
         EX    R1,MVC_0090             Execute MVC instruction          00855059
         BC    B'1111',RETURN          Return to calling program        00855158
*                                                                       00855258
MVC_0090 MVC   0(0,R15),0(R2)          Move UID to DFHCOMMAREA          00855358
*                                                                       00855458
*********************************************************************** 00855558
* STATUS 400                                                          * 00855658
**********************************************************************  00855758
ER_400   DS   0H                                                        00855858
         LA    R2,C_400_T              Load 400 error text              00855958
         MVC   S_LENGTH,C_400_L        Move 400 error length            00856058
         MVC   S_CODE,C_400            Move status code                 00856158
         MVC   S_TEXT,C_400_T          Move status text                 00856258
         MVC   S_TEXT_L,C_400_L        Move status text length          00856358
         BAS   R14,SY_SEND             Send response                    00856458
         BC    B'1111',RETURN          Return to CICS                   00856558
*                                                                       00856658
*********************************************************************** 00856742
* STATUS 405 (HTTP)                                                   * 00857072
**********************************************************************  00858042
ER_405   DS   0H                                                        00859042
         EXEC CICS ASSIGN STARTCODE(W_STCODE)                           00859172
         CLI   W_STCODE,C'U'           WEB request?                     00859272
         BC    B'0111',ER_405PC        ... no,  invalid LINK request    00859372
*                                                                       00859472
         LA    R2,C_405_T              Load 405 error text              00859547
         MVC   S_LENGTH,C_405_L        Move 405 error length            00859647
         MVC   S_CODE,C_405            Move status code                 00859747
         MVC   S_TEXT,C_405_T          Move status text                 00859847
         MVC   S_TEXT_L,C_405_L        Move status text length          00859947
         BAS   R14,SY_SEND             Send response                    00860047
         BC    B'1111',RETURN          Return to CICS                   00860147
*                                                                       00860272
*********************************************************************** 00860372
* STATUS 405 (LINK)                                                   * 00860472
**********************************************************************  00860572
ER_405PC DS   0H                                                        00860672
         XC    CA_UID,CA_UID           Null UID field                   00860775
         MVC   CA_UID(32),C_405_M      Move status code 405 message     00860875
         MVC   CA_SC,=C'405'           Move status code 405             00860972
         MVC   CA_RC,=C'01'            Move reason code  01             00861072
         MVC   CA_PGMID,=C'001'        Move program ID  001             00861172
         BC    B'1111',RETURN          Return to calling program        00861672
*********************************************************************** 00861777
* STATUS 503 (HTTP)                                                   * 00861877
**********************************************************************  00861977
ER_503   DS   0H                                                        00862077
         EXEC CICS ASSIGN STARTCODE(W_STCODE)                           00862177
         CLI   W_STCODE,C'U'           WEB request?                     00862277
         BC    B'0111',ER_503PC        ... no,  invalid LINK request    00862377
*                                                                       00862477
         LA    R2,C_503_T              Load 405 error text              00862577
         MVC   S_LENGTH,C_503_L        Move 405 error length            00862677
         MVC   S_CODE,C_503            Move status code                 00862777
         MVC   S_TEXT,C_503_T          Move status text                 00862877
         MVC   S_TEXT_L,C_503_L        Move status text length          00862977
         BAS   R14,SY_SEND             Send response                    00863077
         BC    B'1111',RETURN          Return to CICS                   00863177
*                                                                       00863277
*********************************************************************** 00863377
* STATUS 503 (LINK)                                                   * 00863477
**********************************************************************  00863577
ER_503PC DS   0H                                                        00863677
         XC    CA_UID,CA_UID           Null UID field                   00863777
         MVC   CA_UID(32),C_503_T      Move status code 503 message     00863877
         MVC   CA_SC,=C'503'           Move status code 503             00863977
         MVC   CA_RC,=C'01'            Move reason code  01             00864077
         MVC   CA_PGMID,=C'001'        Move program ID  001             00864177
         BC    B'1111',RETURN          Return to calling program        00864277
*                                                                       00864377
*********************************************************************** 00864477
* Define Constant                                                     * 00865077
*********************************************************************** 00870042
         DS   0F                                                        00880042
U_CASE   DC    24CL01' '               Upper Case mask                  00890071
         DS   0F                                                        00891071
G_MARKER DC    CL16'   - - - -      '  GUID marker                      00892071
         DS   0F                                                        00900042
E_MARKER DC    CL16'   -       -    '  ESS  marker                      00910042
         DS   0F                                                        00910142
C_NC     DC    CL16'ESSUID          '  ESSUID Named Counter             00910242
         DS   0F                                                        00910342
C_GUID   DC    CL16'OPTIONS(FORMAT=G'  GUID   format request            00910442
         DC    CL04'UID)'                                               00910542
         DS   0F                                                        00910642
C_PLAIN  DC    CL16'OPTIONS(FORMAT=P'  PLAIN  format request            00910742
         DC    CL05'LAIN)'                                              00910842
         DS   0F                                                        00910942
C_ESS    DC    CL16'OPTIONS(FORMAT=E'  ESSUID format request            00911042
         DC    CL03'SS)'                                                00911142
         DS   0F                                                        00911257
C_LINK   DC    CL04'LINK'              Program Control LINK             00911357
         DS   0F                                                        00911442
C_GET    DC    CL03'GET'               HTTP GET                         00911542
         DS   0F                                                        00911757
C_MEDIA  DC    CL56'text/plain'        Media type                       00911870
         DS   0F                                                        00911957
C_200    DC    H'200'                  Status code                      00912057
         DS   0F                                                        00912157
C_200_T  DC    CL16'Request Complete'  Status text                      00912257
         DC    CL16'                '                                   00912357
         DS   0F                                                        00913042
C_200_l  DC    F'32'                   Status length                    00914042
         DS   0F                                                        00915042
C_400    DC    H'400'                  Status code                      00916042
         DS   0F                                                        00917042
C_400_T  DC    CL16'Invalid Query St'  Status text                      00918042
         DC    CL16'ring option     '                                   00919042
         DS   0F                                                        00920042
C_400_L  DC    F'32'                   Status length                    00930042
         DS   0F                                                        00931042
C_405    DC    H'405'                  Status code                      00932042
         DS   0F                                                        00933042
C_405_T  DC    CL16'Invalid Request '  Status text HTTP                 00934074
         DC    CL16'Only GET Allowed'                                   00935042
         DS   0F                                                        00935172
C_405_M  DC    CL16'Request TYPE mus'  Status text LINK                 00935274
         DC    CL16't be LINK.      '                                   00935372
         DS   0F                                                        00935472
C_405_L  DC    F'32'                   Status length                    00935876
         DS   0F                                                        00935976
C_409    DC    H'409'                  Status code                      00936076
         DS   0F                                                        00936176
C_415    DC    H'415'                  Status code                      00936276
         DS   0F                                                        00936376
C_415_M  DC    CL16'Invalid FORMAT r'  Status text LINK                 00936476
         DC    CL16'equested.       '                                   00936576
*                                                                       00936677
         DS   0F                                                        00936777
C_503    DC    H'503'                  Status code                      00936877
         DS   0F                                                        00936977
C_503_T  DC    CL16'01-001 Named Cou'  Status text HTTP                 00937077
         DC    CL16'nter unavailable'                                   00937177
         DS   0F                                                        00937277
C_503_L  DC    F'32'                   Status length                    00937677
*                                                                       00937777
         DS   0F                                                        00937876
NULLS    DC    32XL01'00'                                               00937976
FOXES    DC    XL04'FFFFFFFF'                                           00938076
         DS   0F                                                        00938176
M_ACAO_L DC    F'01'                   HTTP Header message length       00938276
         DS   0F                                                        00938376
M_ACAO   DC    CL01'*'                 HTTP Header message              00938476
         DS   0F                                                        00938576
H_ACAO_L DC    F'27'                   HTTP Header length               00938676
         DS   0F                                                        00938776
H_ACAO   DC    CL16'Access-Control-A'  HTTP Header                      00938876
         DC    CL11'llow-Origin'       ...  continued                   00938976
         DS   0F                                                        00939076
*                                                                       00939176
*********************************************************************** 00939276
* Translate table - Hex to Character                                  * 00939376
*********************************************************************** 00939476
         DS   0F                                                        00939576
H_TO_C   DC    XL16'F0F1F2F3F4F5F6F7F8F9818283848586'       00-0F       00939676
         DC    XL16'F1000000000000000000000000000000'       10-1F       00939776
         DC    XL16'F2000000000000000000000000000000'       20-2F       00939842
         DC    XL16'F3000000000000000000000000000000'       30-3F       00939942
         DC    XL16'F4000000000000000000000000000000'       40-4F       00940042
         DC    XL16'F5000000000000000000000000000000'       50-5F       00940142
         DC    XL16'F6000000000000000000000000000000'       60-6F       00940242
         DC    XL16'F7000000000000000000000000000000'       70-7F       00940342
         DC    XL16'F8000000000000000000000000000000'       80-8F       00940442
         DC    XL16'F9000000000000000000000000000000'       90-9F       00940542
         DC    XL16'81000000000000000000000000000000'       A0-AF       00940650
         DC    XL16'82000000000000000000000000000000'       B0-BF       00940750
         DC    XL16'83000000000000000000000000000000'       C0-CF       00940850
         DC    XL16'84000000000000000000000000000000'       D0-DF       00940950
         DC    XL16'85000000000000000000000000000000'       E0-EF       00941050
         DC    XL16'86000000000000000000000000000000'       F0-FF       00941150
*                                                                       00941242
*********************************************************************** 00941344
* Translate table - Character to hex                                  * 00941444
*********************************************************************** 00941544
         DS   0F                                                        00941644
C_TO_H   DC    XL16'00000000000000000000000000000000'       00-0F       00941744
         DC    XL16'00000000000000000000000000000000'       10-1F       00941844
         DC    XL16'00000000000000000000000000000000'       20-2F       00941944
         DC    XL16'00000000000000000000000000000000'       30-3F       00942044
         DC    XL16'00000000000000000000000000000000'       40-4F       00942144
         DC    XL16'00000000000000000000000000000000'       50-5F       00942244
         DC    XL16'00000000000000000000000000000000'       60-6F       00942344
         DC    XL16'00000000000000000000000000000000'       70-7F       00942444
         DC    XL16'00000000000000000000000000000000'       80-8F       00942544
         DC    XL16'00000000000000000000000000000000'       90-9F       00942644
         DC    XL16'00000000000000000000000000000000'       A0-AF       00942744
         DC    XL16'00000000000000000000000000000000'       B0-BF       00942844
         DC    XL16'001C2C3C4C5C6C7C8C9C000000000000'       C0-CF       00942952
         DC    XL16'001D2D3D4D5D6D7D8D9D000000000000'       D0-DF       00943051
         DC    XL16'001E2E3E4E5E6E7E8E9E000000000000'       E0-EF       00943151
         DC    XL16'0F1F2F3F4F5F6F7F8F9F000000000000'       F0-FF       00943251
*                                                                       00943344
         DS   0F                                                        00943444
*                                                                       00943544
*********************************************************************** 00943644
* Literal Pool                                                        * 00943744
*********************************************************************** 00943844
         LTORG                                                          00943944
*                                                                       00944044
         DS   0F                                                        00944144
R0       EQU   0                                                        00944242
R1       EQU   1                                                        00945042
R2       EQU   2                                                        00946042
R3       EQU   3                                                        00947042
R4       EQU   4                                                        00948042
R5       EQU   5                                                        00949042
R6       EQU   6                                                        00950042
R7       EQU   7                                                        00960042
R8       EQU   8                                                        00970042
R9       EQU   9                                                        00980042
R10      EQU   10                                                       00990042
R11      EQU   11                                                       01000042
R12      EQU   12                                                       01010042
R13      EQU   13                                                       01020042
R14      EQU   14                                                       01030042
R15      EQU   15                                                       01040042
*                                                                       01050042
*********************************************************************** 01060042
* Communications Vector Table                                         * 01070062
**********************************************************************  01080042
         PRINT ON                                                       01080163
         CVT   DSECT=YES,LIST=YES                                       01080264
*                                                                       01081062
*********************************************************************** 01082062
* End of Program                                                      * 01083062
**********************************************************************  01084062
         END   ZUID001                                                  01090042