#!/bin/bash

message=$1

#find . -name '*.t2t' -exec txt2tags -t html {} \;

git commit . -m "$message"

git push origin master --force

cd ..
#lftp infonet -e "mirror -X '.git/*' --reverse --delete --only-newer --ignore-time --verbose abbypan.github.com public_html;exit"
