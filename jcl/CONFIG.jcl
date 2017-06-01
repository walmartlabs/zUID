//CONFIG   JOB MSGCLASS=R,NOTIFY=&SYSUID
//**********************************************************************
//* This job will modify the members in the .SOURCE and .JCL libraries
//*
//* Steps for this job to complete successfully
//* --------------------------------------------------------------------
//* 1) Modify JOB card to meet your system installation standards
//*
//* 2) Modify the CONFIG member in the .TXT dataset before submitting
//*
//* 3) Change all occurrences of the following:
//*    @srclib_prfx@   to the multi-node prefix of your source libs
//*    @source_vrsn@   to the 7-char version id of your source libs
//*
//* 4) Submit the job
//**********************************************************************
//* Modify ASMZUID JCL
//**********************************************************************
//STEP01   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.JCL(ASMZUID)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace ASMZUID JCL
//**********************************************************************
//STEP02    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.JCL(ASMZUID)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify DEFID## JCL
//**********************************************************************
//STEP03   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.JCL(DEFID##)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace DEFID## JCL
//**********************************************************************
//STEP04    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.JCL(DEFID##)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUID JCL
//**********************************************************************
//STEP05   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUID)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUID JCL
//**********************************************************************
//STEP06    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUID)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUIDN JCL
//**********************************************************************
//STEP07   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUIDN)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUIDN JCL
//**********************************************************************
//STEP08    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUIDN)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUIDS JCL
//**********************************************************************
//STEP09   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUIDS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUIDS JCL
//**********************************************************************
//STEP10    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.JCL(CSDZUIDS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUID CSD definition source
//**********************************************************************
//STEP11   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUID)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUID CSD definition source
//**********************************************************************
//STEP12    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUID)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUIDN CSD definition source
//**********************************************************************
//STEP13   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUIDN)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUIDN CSD definition source
//**********************************************************************
//STEP14    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUIDN)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZUIDS CSD definition source
//**********************************************************************
//STEP15   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUIDS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZUIDS CSD definition source
//**********************************************************************
//STEP16    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.RDO(CSDZUIDS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZUIDPLT CSD definition source
//**********************************************************************
//STEP17   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.ASM(ZUIDPLT)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,
//            DSN=@srclib_prfx@.@source_vrsn@.TXT(CONFIG)
//SYSTSIN  DD *
 EXEC '@srclib_prfx@.@source_vrsn@.EXEC(REXXREPL)'
/*
//**********************************************************************
//* Replace ZUIDPLT CSD definition source
//**********************************************************************
//STEP18    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,
//             DSN=@srclib_prfx@.@source_vrsn@.ASM(ZUIDPLT)
//SYSIN     DD DUMMY
//*
//
