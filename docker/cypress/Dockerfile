FROM cypress/base:12.1.0

# Variables
ARG user=hudson
ARG pass=hudson
ARG group=hudson
ARG uid=1002
ARG gid=1002
ARG home=/var/lib/hudson
ARG shell=/bin/bash
ARG CYPRESS_VERSION="3.2.0"

# Environment
ENV CI=1
ENV CYPRESS_CACHE_FOLDER=${home}/.cache

# Add User
RUN groupadd "${group}" -g "${gid}"
RUN useradd "${user}" -d "${home}" -s "${shell}" -u "${uid}" -g "${gid}" -m
RUN echo "${user}:${pass}" | chpasswd
WORKDIR ${home}

# Install Packages
RUN apt-get -q -y autoclean ; apt-get -q -y autoremove ; apt-get update
RUN apt-get install -y sudo
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Cypress
USER ${user}
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/var/lib/hudson/node_modules/.bin
RUN echo "whoami: $(whoami)"
RUN npm install "cypress@${CYPRESS_VERSION}" --save-dev
RUN cypress verify

# Cypress Cache List
RUN cypress cache path
RUN cypress cache list

# Versions
RUN echo  " node version:    $(node -v) \n" \
  "npm version:     $(npm -v) \n" \
  "yarn version:    $(yarn -v) \n" \
  "debian version:  $(cat /etc/debian_version) \n" \
  "user:            $(whoami) \n"

ENTRYPOINT ["cypress", "run"]
#CMD sleep 60000
