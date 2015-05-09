#!/bin/bash
diff -rcw MagentoCommunity_1-8-0-0 MagentoCommunity_1-9-0-1 | grep "^Only in MagentoCommunity_1-8-0-0" > diff.txt
vim diff.txt
:%s/Only in MagentoCommunity_1-8-0-0\//rm -rf /g
#:%s/: /\//g
#:wq

#http://linuxconfig.org/bash-scripting-tutorial



if [ -d "/tools/utils/mac/compare_directories/test" ]; then
	echo "Directory does not exist $1" 
	exit 1
fi
if [ -d ./$2 ]; then
        echo "Directory does not exist $2"
        exit 1
fi



