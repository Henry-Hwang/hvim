#!/bin/sh
# generate tag file for lookupfile plugin
echo -e "!_TAG_FILE_SORTED\t2\t/2=foldcase/" > filenametags
find . -not -regex '.*\.\(png\|gif\)' -type f -printf "%f\t%p\t1\n" | \
    sort -f >> filenametags

ctags -R .

echo "let g:LookupFile_TagExpr='\"filenametags\"'" >  sessionx.vim
echo "set tags+=$(pwd)/tags" >> sessionx.vim
