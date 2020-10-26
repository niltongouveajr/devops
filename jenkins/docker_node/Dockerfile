# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM ubuntu:18.04
MAINTAINER Nilton Gouvea <niltongouveajr@gmail.com>

# Variables
ARG user=hudson
ARG pass=hudson
ARG group=hudson
ARG uid=1002
ARG gid=1002
ARG home=/var/lib/hudson
ARG shell=/bin/bash

# Apt-get
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y --no-install-recommends apt-utils

# Locale
RUN apt-get install -y locales
RUN apt-get install -y tzdata
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Add User
RUN groupadd "${group}" -g "${gid}"
RUN useradd "${user}" -d "${home}" -s "${shell}" -u "${uid}" -g "${gid}" -m
RUN echo "${user}:${pass}" | chpasswd

# Install SSH server
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

# Install Utilities
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y ansible apt-transport-https bc build-essential ca-certificates cloc cpp cppcheck curl dbus-x11 diffstat dos2unix elinks firefox fontconfig fonts-liberation gnupg2 iputils-ping ldap-utils libappindicator3-1 libfontconfig1-dev libxss1 libnspr4 libnss3 libunwind-dev net-tools nfs-common nfs-kernel-server ntp ntpdate perl python python-minimal python-passlib rpm ruby ruby-dev sloccount software-properties-common sqlite3 subversion sudo tree unzip vim wget xdg-utils x11-apps x11-xkb-utils x11vnc xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic xvfb zip
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y libpq-dev mysql-client postgresql python-pip python3-pip
RUN apt-get install -y libgconf-2-4

# Install ASP Net Core
ADD files/dotnet-install.sh /usr/local/bin/dotnet-install.sh
RUN dotnet-install.sh --channel LTS -InstallDir /opt/tools/dotnet-versions/lts
#RUN dotnet-install.sh --channel 2.2 -InstallDir /opt/tools/dotnet-versions/2.2
#RUN dotnet-install.sh --channel 3.0 -InstallDir /opt/tools/dotnet-versions/3.0
RUN ln -s /opt/tools/dotnet-versions/lts /opt/tools/dotnet

# Install AWS Clients
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip
RUN sudo wget https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest -O /usr/local/bin/ecs-cli && sudo chmod +x /usr/local/bin/ecs-cli
ADD files/amazon-ecs-public-key.gpg amazon-ecs-public-key.gpg
RUN gpg --import amazon-ecs-public-key.gpg
RUN curl -o ecs-cli.asc https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.asc && gpg --verify ecs-cli.asc /usr/local/bin/ecs-cli
RUN rm amazon-ecs-public-key.gpg ecs-cli.asc
RUN sudo su - ${user} -c "pip install awsebcli --upgrade --user"
#RUN sudo su - ${user} -c "pip3 install awsebcli --upgrade --user"

# Install Azure Client
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker CE
RUN curl --silent -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get update
RUN apt-get install -y docker-ce
RUN usermod -a -G docker "${user}"

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

# Fastlane
RUN sudo gem install fastlane -NV
RUN sudo gem install bundler -NV
RUN sudo gem install bundler:1.14.2 -NV

# Install Google Chrome Stable
ADD files/google-chrome-stable_71.0.3578.80.deb google-chrome-stable_71.0.3578.80.deb
ADD files/google-chrome-stable_75.0.3770.80.deb google-chrome-stable_75.0.3770.80.deb
RUN dpkg -i google-chrome-stable_71.0.3578.80.deb ; mv /opt/google/chrome /opt/google/chrome-71.0.3578.80
RUN dpkg -i google-chrome-stable_75.0.3770.80.deb ; mv /opt/google/chrome /opt/google/chrome-75.0.3770.80
#RUN wget --quiet https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN dpkg -i google-chrome-stable_current_amd64.deb
RUN ln -s /opt/google/chrome-75.0.3770.80 /opt/google/chrome ; chown -h ${user}:${group} /opt/google/chrome
ADD files/use_chrome /usr/local/bin/use_chrome
ADD files/chromedriver usr/local/bin/chromedriver
RUN chmod +x /usr/local/bin/use_chrome
RUN chown ${user}:${group} /opt/google ; rm google-chrome-stable*.deb

# Install Helm
ADD files/helm /usr/local/bin/helm

# Install Java SDK Manager and JDK 8
RUN apt-get install -y openjdk-8-jdk
RUN sudo su - ${user} -c "curl -s https://get.sdkman.io | bash"
RUN mkdir -p ${home}/.sdkman/candidates/java && chown ${user}:${group} ${home}/.sdkman/candidates/java
RUN ln -s /usr/lib/jvm/java-8-openjdk-amd64/jre ${home}/.sdkman/candidates/java/jdk8
RUN sudo su - ${user} -c "source ${home}/.sdkman/bin/sdkman-init.sh && sdk use java jdk8"

# Install NodeJS version management
ENV PREFIX=${home}/n
ENV N_PREFIX=${home}/n
RUN apt-get install -y npm
RUN npm install -g n
RUN apt-get purge -y node-* npm*
RUN sudo su - ${user} -c "N_PREFIX=${home}/n n lts"
RUN N_PREFIX=/root/n n lts && sudo /root/n/bin/npm install @angular/cli@latest grunt@latest jshint@latest tslint@latest typescript@latest -g

# Install PhantomJS
ADD files/phantomjs-2.1.1-linux-x86_64.tar.bz2 /tmp
RUN mv /tmp/phantomjs-2.1.1-linux-x86_64 /opt/tools/phantomjs

# Install Terraform Client
ADD files/terraform /usr/local/bin/terraform

# Setting for sshd
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd 
RUN sed -i /etc/ssh/sshd_config \
        -e 's/#Port.*/Port 2200/' \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#RSAAuthentication.*/RSAAuthentication yes/'  \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication yes/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/'
RUN mkdir ${home}/.ssh
ADD files/authorized_keys ${home}/.ssh/ 
ADD files/config ${home}/.ssh/ 
ADD files/id_rsa ${home}/.ssh/ 
ADD files/id_rsa.pub ${home}/.ssh/ 
RUN chown -R ${user}:${group} ${home}/.ssh
RUN chmod 700 ${home}/.ssh ; chmod 600 ${home}/.ssh/*

# SSH port
EXPOSE 2200

# SSL certificate
ADD files/ssl/certs/cert-ca.crt /etc/ssl/certs/cert-ca.crt
ADD files/ssl/certs/cert.crt /etc/ssl/certs/cert.crt
ADD files/ssl/private/cert.key /etc/ssl/private/cert.key

# Xvfb
ADD files/xvfb /etc/init.d/xvfb
RUN chmod +x /etc/init.d/xvfb

# Clean up
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove
RUN rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Docker registries and credentials
RUN mkdir ${home}/.docker
ADD files/config.json ${home}/.docker/ 
ADD files/certs.d /etc/docker/certs.d
RUN chown -R ${user}:${group} ${home}/.docker
RUN chmod 600 ${home}/.docker/config.json

# Python3 qpdf and pikepdf
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y cmake
RUN wget https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz && tar xzvf libjpeg-turbo-2.0.4.tar.gz
RUN cd libjpeg-turbo-2.0.4 && mkdir build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=RELEASE -DENABLE_STATIC=FALSE -DCMAKE_INSTALL_DOCDIR=/usr/share/doc/libjpeg-turbo-2.0.4 -DCMAKE_INSTALL_DEFAULT_LIBDIR=lib .. && make && make test && rm -f /usr/lib/libjpeg.so* && make install
RUN wget https://github.com/qpdf/qpdf/releases/download/release-qpdf-10.0.1/qpdf-10.0.1.tar.gz && tar xzvf qpdf-10.0.1.tar.gz
RUN cd qpdf-10.0.1 && ./configure --prefix=/usr --disable-static --docdir=/usr/share/doc/qpdf-10.0.1 && make && make install && pip3 install pikepdf
RUN rm -rf libjpeg-turbo-2.0.4.tar.gz qpdf-10.0.1.tar.gz libjpeg-turbo-2.0.4 qpdf-10.0.1

# Environment
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /opt/tools
RUN echo 'export CHROME_BIN=/usr/bin/google-chrome' > /etc/environment
RUN echo 'export JAVA_HOME=/opt/tools/java' >> /etc/environment
RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment
RUN echo 'export LANG=en_US.UTF-8' >> /etc/environment
RUN echo 'export N_PREFIX=/var/lib/hudson/n' >> /etc/environment
RUN echo 'export PATH=~/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/tools/dotnet:/opt/tools/phantomjs/bin:/var/lib/hudson/n/bin' >> /etc/environment
RUN echo "source ${home}/.sdkman/bin/sdkman-init.sh" >> /etc/environment
RUN cat /etc/environment > /tmp/00-env-vars.sh
RUN echo 'sudo chmod 777 /var/run/docker.sock' >> /tmp/00-env-vars.sh
RUN chmod +x /tmp/00-env-vars.sh
RUN mv /tmp/00-env-vars.sh /etc/profile.d
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java14
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java13
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java12
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java11
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java10
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java9
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java8
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java7
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java6
RUN ln -s ${home}/.sdkman/candidates/java/current /opt/tools/java
RUN sed -i 's|env bash|env bash\nset +x|g' ${home}/.sdkman/bin/sdkman-init.sh
RUN chmod +x ${home}/.sdkman/bin/sdkman-init.sh
RUN ln -sf /bin/bash /bin/sh
RUN chown -R ${user}:${group} /opt/tools
ENV DISPLAY :99
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/
ENV XVFB_SCREEN_SIZE 1024x768x24

# Run
#CMD ["/usr/sbin/sshd", "-D"]
CMD /etc/init.d/xvfb start && /usr/sbin/sshd -D
