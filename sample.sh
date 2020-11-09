#!/bin/bash
wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip
apt install -y unzip
unzip ./terraform_0.12.2_linux_amd64.zip -d /usr/local/bin
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
yum install -y jq
ibmcloud login --apikey 37nT_NsWWoMXkYTmyD9BPDWcfybY6TUCc-cCweNZtYwj -o prasraon@in.ibm.com -s dev
bash /sample-repo-code/collect.sh
RUN git clone git@github.com:PRASHANTH337/collector.git
cd collector
git config --global user.email "prashanth@gmail.com"
git config --global user.name "prash"
mv /powervs* .
data=$(date '+%B%d')
git add .
git commit -m "$data"
git push origin master


