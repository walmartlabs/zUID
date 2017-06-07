#!/bin/sh
# This script is used to sync MVS libs back to USS for Git compatibility
# Update working directory for project
# Update PDS names to local source lib names
cd /apps/DEV/INFDS/zUID
cp -TUS a=.md "//'SYS3.CICS.ZCLOUD.IP.ZUID.MD.V010000'" . 2> /dev/null
cp -TUS a=.txt "//'SYS3.CICS.ZCLOUD.IP.ZUID.TXT.V010000'" ./txt 2> /dev/null
cp -TUS a=.asm "//'SYS3.CICS.ZCLOUD.IP.ZUID.ASM.V010000'" ./asm 2> /dev/null
cp -TUS a=.cbl "//'SYS3.CICS.ZCLOUD.IP.ZUID.CBL.V010000'" ./cbl 2> /dev/null
cp -TUS a=.exec "//'SYS3.CICS.ZCLOUD.IP.ZUID.EXEC.V010000'" ./exec 2> /dev/null
cp -TUS a=.jcl "//'SYS3.CICS.ZCLOUD.IP.ZUID.JCL.V010000'" ./jcl 2> /dev/null
cp -TUS a=.rdo "//'SYS3.CICS.ZCLOUD.IP.ZUID.RDO.V010000'" ./rdo 2> /dev/null
