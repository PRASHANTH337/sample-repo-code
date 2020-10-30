#/bin/bash
bash /sample-repo-code/collect.sh 
cd collector
mv /powervs* .
data=$(date '+%B%d')
git add .
git commit -m "$data"
git push origin master


