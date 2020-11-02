FROM centos:latest
LABEL stage=intermediate
ARG SSH_KEY
RUN yum install -y git; \
    mkdir -p /root/.ssh/ && \
    echo "$SSH_KEY" > /root/.ssh/id_rsa && \
    chmod -R 600 /root/.ssh/ && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts; \
    git clone git@github.com:PRASHANTH337/sample-repo-code.git
RUN ls; \
    yum install -y wget unzip; \
    wget https://releases.hashicorp.com/terraform/0.12.2/terraform_0.12.2_linux_amd64.zip; \
    unzip ./terraform_0.12.2_linux_amd64.zip -d /usr/local/bin; \
    curl -fsSL https://clis.cloud.ibm.com/install/linux | sh; \
    yum install -y jq; \
    ibmcloud login --sso; \
    bash /sample-repo-code/collect.sh 
RUN git clone git@github.com:PRASHANTH337/collector.git; \
cd collector; \
git config --global user.email "prashanth@gmail.com"; \
git config --global user.name "prash"; \
mv /powervs* .; \
data=$(date '+%B%d'); \
git add .; \
git commit -m "$data"; \
git push origin master
RUN chmod 0744 /sample-repo-code/sample.sh; \
yum -y install crontabs; \
sed -i -e '/pam_loginuid.so/s/^/#/' /etc/pam.d/crond
ADD cron /etc/cron.d/cron_test
RUN chmod 0644 /etc/cron.d/cron_test; \
    crontab /etc/cron.d/cron_test
CMD crond && tail -f /dev/null
