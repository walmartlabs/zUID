//ASMZUID  JOB @job_parms@
//**********************************************************************
//* Assemble the source code
//**********************************************************************
//PROC     JCLLIB ORDER=(@proc_lib@)
//**********************************************************************
//* Assemble and link ZUIDPLT
//**********************************************************************
//ZUIDPLT  EXEC DFHEITAL,PROGLIB=@program_lib@
//TRN.SYSIN  DD DISP=SHR,DSN=@source_lib@(ZUIDPLT)
//*
//LKED.SYSIN DD *
   NAME ZUIDPLT(R)
/*
//**********************************************************************
//* Assemble and link ZUID001
//**********************************************************************
//ZUID001  EXEC DFHEITAL,PROGLIB=@program_lib@
//TRN.SYSIN  DD DISP=SHR,DSN=@source_lib@(ZUID001)
//*
//LKED.SYSIN DD *
   NAME ZUID001(R)
/*
//**********************************************************************
//* Assemble ZUIDSTCK without CICS translator
//**********************************************************************
//ASM    EXEC PGM=ASMA90,
//            REGION=2M,
//            PARM='DECK,NOOBJECT,LIST'
//SYSLIB   DD DSN=SYS1.MACLIB,DISP=SHR
//SYSUT1   DD UNIT=SYSDA,SPACE=(1700,(400,400))
//SYSUT2   DD UNIT=SYSDA,SPACE=(1700,(400,400))
//SYSUT3   DD UNIT=SYSDA,SPACE=(1700,(400,400))
//SYSPUNCH DD DSN=&&OBJECT,
//            UNIT=SYSDA,DISP=(,PASS),
//            SPACE=(400,(100,100))
//SYSPRINT DD SYSOUT=*
//SYSIN    DD DISP=SHR,DSN=@source_lib@(ZUIDSTCK)
//**********************************************************************
//* Link-edit ZUIDSTCK
//**********************************************************************
//LKED   EXEC PGM=IEWL,REGION=2M,
//            PARM='LIST,XREF',COND=(7,LT,ASM)
//SYSLIB   DD DUMMY
//SYSIN DD *
  MODE AMODE(31),RMODE(ANY)
  SETSSI C3C3C3C5
/*
//SYSLMOD  DD DISP=SHR,DSN=@program_lib@(ZUIDSTCK)
//SYSUT1   DD UNIT=SYSDA,DCB=BLKSIZE=1024,
//            SPACE=(1024,(200,20))
//SYSPRINT DD SYSOUT=*
//SYSLIN   DD DSN=&&OBJECT,DISP=(OLD,DELETE)
//         DD DDNAME=SYSIN