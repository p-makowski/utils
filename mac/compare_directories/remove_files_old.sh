diff -rcw MagentoCommunity_1-8-0-0 MagentoCommunity_1-9-0-1 | grep "^Only in MagentoCommunity_1-8-0-0" > diff.txt
vim diff.txt
:%s/Only in MagentoCommunity_1-8-0-0\//rm -rf /g
:%s/: /\//g
:wq




