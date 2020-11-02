#!/bin/bash
bash /sample-repo-code/collect.sh 
cd collector
git config --global user.email "prashanth@gmail.com"
git config --global user.name "prash"
mv /powervs* .
ls
data=$(date '+%B%d')
git add .
git commit -m "$data+1"
git push origin master
git pull


