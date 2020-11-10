apt-get update -y
apt-get install -y wget curl git
wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_darwin_amd64.zip
git clone https://github.com/PRASHANTH337/sample-repo-code.git
apt-get install -y unzip
unzip ./terraform_0.12.2_darwin_amd64.zip -d /usr/local/bin
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
apt-get install -y jq
ibmcloud login --apikey 37nT_NsWWoMXkYTmyD9BPDWcfybY6TUCc-cCweNZtYwj 
ibmcloud target -o prasraon@in.ibm.com -s dev
bash /sample-repo-code/collect.sh
git clone https://prashanth337:7b1a12af653fd82d4ebd343eea647a38d8073ed3@github.com/PRASHANTH337/collector.git
cd collector
git config --global user.email "prashanth@gmail.com"
git config --global user.name "prash"
mv /powervs* .
data=$(date '+%B%d')
