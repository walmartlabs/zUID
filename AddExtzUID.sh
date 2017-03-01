#/bin/sh
cd /apps/DEV/INFDS/zUID
cd /apps/DEV/INFDS/zUID/txt
for f in *; do mv "$f" "$f.txt"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/asm
for f in *; do mv "$f" "$f.asm"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/cbl
for f in *; do mv "$f" "$f.cbl"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/cpy
for f in *; do mv "$f" "$f.cpy"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/exec
for f in *; do mv "$f" "$f.exec"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/idcams
for f in *; do mv "$f" "$f.idcams"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/jcl
for f in *; do mv "$f" "$f.jcl"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/mac
for f in *; do mv "$f" "$f.mac"; done 2> /dev/null
cd /apps/DEV/INFDS/zUID/rdo
for f in *; do mv "$f" "$f.rdo"; done 2> /dev/null
cd ..
