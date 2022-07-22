FROM ubuntu:20.04

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ENV TARGETARCH=linux-x64
ENV DEBIAN_FRONTEND=noninteractive

# Packages
RUN echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes
RUN apt-get update && apt-get install -y --no-install-recommends apt-utils
RUN apt-get update && apt-get install -y --no-install-recommends \
    bc \
    ca-certificates \
    curl \
    fonts-liberation \
    git \
    iputils-ping \
    jq \
    libicu* \
    libssl1.0 \
    libunwind8 \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo2 \
    libcups2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxkbcommon0 \
    libxrandr2 \
    locales \
    net-tools \
    netcat \
    python3 \
    python3-pip \
    software-properties-common \
    sudo \
    tree \
    tzdata \
    unzip \
    vim \
    wget \
    xdg-utils \
    xvfb \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# AWS CLI
RUN curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip

# AZ CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash
RUN echo "AZURE_EXTENSION_DIR=/usr/local/lib/azureExtensionDir" | tee -a /etc/environment \
    && mkdir -p /usr/local/lib/azureExtensionDir

# Docker CE
RUN curl --silent -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
RUN apt-get update && apt-get install -y docker-ce

# DotNet Core
RUN wget https://dot.net/v1/dotnet-install.sh -O /usr/local/bin/dotnet-install.sh && chmod +x /usr/local/bin/dotnet-install.sh
RUN mkdir -p /opt/tools
RUN dotnet-install.sh --channel LTS -InstallDir /opt/tools/dotnet-versions/lts
RUN ln -s /opt/tools/dotnet-versions/lts /opt/tools/dotnet
RUN ln -s /opt/tools/dotnet/dotnet /usr/local/bin/dotnet

# Google Chrome
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN dpkg -i google-chrome-stable_current_amd64.deb && rm google-chrome-stable_current_amd64.deb

ENV SDKMAN_DIR /root/.sdkman
RUN curl -s https://get.sdkman.io | bash
RUN chmod a+x ${SDKMAN_DIR}/bin/sdkman-init.sh
RUN set -x \
    && echo "sdkman_auto_answer=true" > ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_auto_selfupdate=false" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_insecure_ssl=false" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_curl_connect_timeout=300" >> ${SDKMAN_DIR}/etc/config \
    && echo "sdkman_curl_max_time=300" >> ${SDKMAN_DIR}/etc/config
RUN [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
RUN source ${SDKMAN_DIR}/bin/sdkman-init.sh && sdk install java 11.0.12-open

# NodeJS
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n \
    && chmod +x /usr/local/bin/n \
    && n lts \
    && npm install npm@latest @angular/cli@latest eslint@latest grunt@latest jshint@latest typescript@latest --location=global \
    && rm /usr/local/bin/node \
    && n lts

# Clean up
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove
RUN rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

WORKDIR /azp

RUN mkdir ./patches
COPY ./patches/AgentService.js ./patches/
COPY ./start.sh .
COPY ./start-once.sh .
RUN chmod +x start.sh
RUN chmod +x start-once.sh

CMD ["./start-once.sh"]
