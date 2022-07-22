# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins build node.
FROM ubuntu:20.04
MAINTAINER Nilton Gouvea <niltongouveajr@gmail.com>

# Variables
ARG user=devops
ARG pass=devops
ARG group=devops
ARG uid=1000
ARG gid=1000
ARG home=/home/devops
ARG shell=/bin/bash

# Apt-get
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -q autoclean -y ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install libgbm1 -y

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
RUN apt-get --fix-broken install -y
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y ansible apt-transport-https bc build-essential ca-certificates curl dbus-x11 diffstat dos2unix elinks firefox fontconfig fonts-liberation fuse gnupg2 iputils-ping jq ldap-utils libappindicator3-1 libfontconfig1-dev libgconf-2-4 libnspr4 libnss3 libpq-dev libsecret-1-dev libunwind-dev libxss1 mysql-client net-tools nfs-common nfs-kernel-server ntp ntpdate perl postgresql python python-passlib python3 python3-passlib python3-pip rpm ruby ruby-dev software-properties-common sqlite3 subversion sudo tree ttf-dejavu unzip vim wget xdg-utils x11-apps x11-xkb-utils x11vnc xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic xvfb zip
RUN curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py && python2 get-pip.py && rm get-pip.py

# Install ASP Net Core
COPY files/dotnet-install.sh /usr/local/bin/dotnet-install.sh
RUN dotnet-install.sh --channel LTS -InstallDir /opt/tools/dotnet-versions/lts
RUN ln -s /opt/tools/dotnet-versions/lts /opt/tools/dotnet

# Install AWS Clients
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip
RUN sudo wget https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest -O /usr/local/bin/ecs-cli && sudo chmod +x /usr/local/bin/ecs-cli
COPY files/amazon-ecs-public-key.gpg amazon-ecs-public-key.gpg
RUN gpg --import amazon-ecs-public-key.gpg
RUN curl -o ecs-cli.asc https://amazon-ecs-cli.s3.amazonaws.com/ecs-cli-linux-amd64-latest.asc && gpg --verify ecs-cli.asc /usr/local/bin/ecs-cli
RUN rm amazon-ecs-public-key.gpg ecs-cli.asc
RUN sudo su - ${user} -c "pip3 install awsebcli --upgrade --user"

# Install Azure Client
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install Docker CE
RUN curl --silent -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
RUN apt-get update
RUN apt-get install -y docker-ce
RUN usermod -a -G docker "${user}"

# Install Fastlane
RUN sudo gem install fastlane -NV
RUN sudo gem install bundler -NV
RUN sudo gem install bundler:1.14.2 -NV

# Install Flutter
RUN cd /opt/tools && git clone https://github.com/flutter/flutter.git -b stable && chown -R ${user}:${group} /opt/tools/flutter 
RUN sudo su - ${user} -c "cd /opt/tools/flutter/bin && ./flutter --version && ./flutter precache && ./flutter config --no-analytics && ./flutter config --android-studio-dir /android-sdk-linux-complete"  

# Install Google Chrome Stable
COPY files/google-chrome-stable_89.0.4389.72.deb google-chrome-stable_89.0.4389.72.deb
RUN dpkg -i google-chrome-stable_89.0.4389.72.deb ; mv /opt/google/chrome /opt/google/chrome-89.0.4389.72
RUN ln -s /opt/google/chrome-89.0.4389.72 /opt/google/chrome ; chown -h ${user}:${group} /opt/google ; rm google-chrome-stable*.deb 
COPY files/use_chrome ${home}/.local/bin/use_chrome
RUN chown ${user}:${group} ${home}/.local/bin/use_chrome ; chmod +x ${home}/.local/bin/use_chrome
COPY files/chromedriver-89.0.4389.23 ${home}/.local/bin/chromedriver-89.0.4389.23
RUN ln -s ${home}/.local/bin/chromedriver-89.0.4389.23 ${home}/.local/bin/chromedriver
RUN chown -R ${user}:${group} ${home}/.local/bin/chromedriver*

# Install Java SDK Manager and JDK 8
ENV SDKMAN_DIR ${home}/.sdkman
RUN sudo su - ${user} -c "curl -s https://get.sdkman.io | bash"
RUN sudo su - ${user} -c "chmod a+x ${SDKMAN_DIR}/bin/sdkman-init.sh"
RUN set -x \
    && echo "sdkman_auto_answer=true" > ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_auto_selfupdate=false" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_insecure_ssl=false" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_curl_connect_timeout=300" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_curl_max_time=300" >> ${SDKMAN_DIR}/etc/config \
    && chown ${user}:${group} ${SDKMAN_DIR}/etc/config
WORKDIR ${SDKMAN_DIR}
RUN sudo su - ${user} -c "[[ -s \"${SDKMAN_DIR}/bin/sdkman-init.sh\" ]] && source \"${SDKMAN_DIR}/bin/sdkman-init.sh\""
RUN sudo su - ${user} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java 8.0.265-open"
RUN sudo su - ${user} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java 11.0.12-open"
RUN sudo su - ${user} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java 14.0.2-open"
RUN sudo su - ${user} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java 17.0.3-zulu"
RUN ln -s ${home}/.sdkman/candidates/java/8.0.265-open /opt/tools/java8 ; ln -s ${home}/.sdkman/candidates/java/11.0.12-open /opt/tools/java11 ; ln -s ${home}/.sdkman/candidates/java/14.0.2-open /opt/tools/java14 ; ln -s ${home}/.sdkman/candidates/java/17.0.3-zulu /opt/tools/java17
RUN ln -s ${home}/.sdkman/candidates/java/11.0.12-open ${home}/.sdkman/candidates/java/11.0.7-open ; ln -s ${home}/.sdkman/candidates/java/14.0.2-open ${home}/.sdkman/candidates/java/14.0.1-open
COPY files/java8.tar.bz2 /opt/tools
RUN cd /opt/tools && mv java8 java8- && tar xjvf java8.tar.bz2 && rm java8.tar.bz2 && chown -R ${user}:${group} /opt/tools && ln -s ${home}/.sdkman/candidates/java/current/bin/java /usr/local/bin/java
RUN sudo su - ${user} -c "source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java java8 /opt/tools/java8 && sdk default java java8 && sdk use java java8 && sdk current java"
COPY files/tzupdater.jar ${home}/
RUN ${home}/.sdkman/candidates/java/current/bin/java -jar ${home}/tzupdater.jar -v -u -l https://www.iana.org/time-zones/repository/releases/tzdata2021e.tar.gz ; ${home}/.sdkman/candidates/java/current/bin/java -jar ${home}/tzupdater.jar -V
RUN rm ${home}/tzupdater.jar

# Install NodeJS version management
RUN apt-get install -y npm
RUN npm install n@latest -g && N_PREFIX=/root/n n 16.15.0 && npm install @angular/cli@13.3.0 grunt@latest jshint@latest eslint@latest typescript@latest -g
RUN apt-get purge -y npm* ; apt-get -q -y autoclean ; apt-get -q -y autoremove 
RUN sudo su - ${user} -c "N_PREFIX=${home}/n n 16.15.0"
RUN ln -s ${home}/n/bin/node /usr/local/bin/node ; ln -s ${home}/n/bin/npm /usr/local/bin/npm
RUN sudo su - ${user} -c "npm install @angular/cli@13.3.0 grunt@latest jshint@latest eslint@latest typescript@latest -g"
RUN rm /usr/local/bin/node ; rm /usr/local/bin/npm

# Install PhantomJS
WORKDIR ${home}
COPY files/phantomjs-2.1.1-linux-x86_64.tar.bz2 ${home}/
RUN tar xjvf phantomjs-2.1.1-linux-x86_64.tar.bz2
RUN mv phantomjs-2.1.1-linux-x86_64 /opt/tools/phantomjs
RUN rm phantomjs-2.1.1-linux-x86_64.tar.bz2

# Setting for sshd
RUN sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd 
COPY files/sshd_config /etc/ssh/sshd_config
RUN chmod 644 /etc/ssh/sshd_config

RUN mkdir ${home}/.ssh
COPY files/authorized_keys ${home}/.ssh/ 
COPY files/config ${home}/.ssh/ 
COPY files/id_rsa ${home}/.ssh/ 
COPY files/id_rsa.pub ${home}/.ssh/ 
RUN chown -R ${user}:${group} ${home}/.ssh
RUN chmod 700 ${home}/.ssh ; chmod 600 ${home}/.ssh/*

# SSH port
EXPOSE 2200

# Xvfb
COPY files/xvfb /etc/init.d/xvfb
RUN chmod +x /etc/init.d/xvfb

# Clean up
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove
RUN rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

# Docker registries and credentials
RUN mkdir ${home}/.docker
COPY files/config.json ${home}/.docker/ 
COPY files/certs.d /etc/docker/certs.d
RUN chown -R ${user}:${group} ${home}/.docker
RUN chmod 600 ${home}/.docker/config.json

# Environment
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN mkdir -p /opt/tools
RUN echo 'export CHROME_BIN=/usr/bin/google-chrome' > /etc/environment
RUN echo 'export JAVA_HOME=/opt/tools/java8' >> /etc/environment
RUN echo 'export LC_ALL=en_US.UTF-8' >> /etc/environment
RUN echo 'export LANG=en_US.UTF-8' >> /etc/environment
RUN echo 'export N_PREFIX=/home/devops/n' >> /etc/environment
RUN echo 'export PATH=~/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/tools/dotnet:/opt/tools/phantomjs/bin:/home/devops/n/bin' >> /etc/environment
RUN echo "source ${home}/.sdkman/bin/sdkman-init.sh" >> /etc/environment
RUN cat /etc/environment > /tmp/00-env-vars.sh && echo 'sudo chmod 777 /var/run/docker.sock' >> /tmp/00-env-vars.sh && chmod +x /tmp/00-env-vars.sh && mv /tmp/00-env-vars.sh /etc/profile.d
RUN sed -i 's|env bash|env bash\nset +x|g' ${home}/.sdkman/bin/sdkman-init.sh && chmod +x ${home}/.sdkman/bin/sdkman-init.sh
RUN ln -sf /bin/bash /bin/sh
ENV DISPLAY :99
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu/
ENV XVFB_SCREEN_SIZE 1024x768x24

# Run
#CMD ["/usr/sbin/sshd", "-D"]
CMD /etc/init.d/xvfb start && /usr/sbin/sshd -D
