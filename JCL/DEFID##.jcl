//DEFID##  JOB @job_parms@
//**********************************************************************
//* Customize and define one instance of zUID
//**********************************************************************
//* Customize the DFHCSDUP DEFINE statements and pass to next step
//**********************************************************************
//CUSTOMIZ EXEC PGM=IKJEFT1B
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDID##)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&CSDCMDS,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD *
* Path is created as follows /uid/@org@/@appname@
 @appname@   sessionID
 @grp_list@  @csd_list@
 @id@        00
 @org@       devops
 @scheme@    http
/*
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Define the CSD definitions for one instance of zUID
//**********************************************************************
//DEFINE    EXEC  PGM=DFHCSDUP
//STEPLIB   DD    DISP=SHR,DSN=@cics_hlq@.SDFHLOAD
//DFHCSD    DD    DISP=SHR,DSN=@cics_csd@
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    DISP=SHR,DSN=&&CSDCMDS
//*
//