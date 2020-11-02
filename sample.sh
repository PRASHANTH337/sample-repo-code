#!/bin/bash
bash /sample-repo-code/collect.sh 
cd collector
git config --global user.email "prashanth@gmail.com"
git config --global user.name "prash"
mv /powervs* .
data=$(date '+%B%d')
git add .
git commit -m "$data"
git push origin master


