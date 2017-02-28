#/bin/sh
cd /apps/DEV/INFDV/zUID
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.MD.V010000'" . 2> /dev/null
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.TXT.V010000'" ./txt 2> /dev/null
cd /apps/DEV/INFDV/zUID/txt
for f in *; do mv "$f" "$f.txt"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.ASM.V010000'" ./asm 2> /dev/null
cd /apps/DEV/INFDV/zUID/asm
for f in *; do mv "$f" "$f.asm"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.CBL.V010000'" ./cbl 2> /dev/null
cd /apps/DEV/INFDV/zUID/cbl
for f in *; do mv "$f" "$f.cbl"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.CPY.V010000'" ./cpy 2> /dev/null
cd /apps/DEV/INFDV/zUID/cpy
for f in *; do mv "$f" "$f.cpy"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.EXEC.V010000'" ./exec 2> /dev/null
cd /apps/DEV/INFDV/zUID/exec
for f in *; do mv "$f" "$f.exec"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.IDCAMS.V010000'" ./idcams 2> /dev/null
cd /apps/DEV/INFDV/zUID/idcams
for f in *; do mv "$f" "$f.idcams"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.JCL.V010000'" ./jcl 2> /dev/null
cd /apps/DEV/INFDV/zUID/jcl
for f in *; do mv "$f" "$f.jcl"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.MAC.V010000'" ./mac 2> /dev/null
cd /apps/DEV/INFDV/zUID/mac
for f in *; do mv "$f" "$f.mac"; done 2> /dev/null
cd ..
cp -T -U "//'SYS3.CICS.ZCLOUD.IP.ZUID.RDO.V010000'" ./rdo 2> /dev/null
cd /apps/DEV/INFDV/zUID/rdo
for f in *; do mv "$f" "$f.rdo"; done 2> /dev/null
cd ..
