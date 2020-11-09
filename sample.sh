#!/bin/bash
git clone https://github.com/PRASHANTH337/sample-repo-code.git
bash /sample-repo-code/collect.sh
ls
pwd 
mv powervs* .
cd /collector
git config --global user.email "prashanth@gmail.com"
git config --global user.name "prash"
data=$(date '+%B%d')
git add .
git commit -m "$data"
git push origin master
git pull


